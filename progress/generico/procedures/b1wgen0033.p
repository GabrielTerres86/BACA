/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +----------------------------------------+--------------------------------------------------+
  | Rotina Progress                        | Rotina Oracle PLSQL                              |
  +----------------------------------------+--------------------------------------------------+
  | b1wgen0033.p                           | SEGU0001                                         |
  | cria_seguro                            | SEGU0001.pc_cria_seguro                          |
  | buscar_associados                      | SEGU0001.pc_buscar_associados                    |
  | buscar_pessoa_juridica                 | SEGU0001.pc_buscar_pessoa_juridica               |
  | buscar_titular                         | SEGU0001.pc_buscar_titular                       |
  | buscar_empresa                         | SEGU0001.pc_buscar_empresa                       |
  | busca_seguros                          | SEGU0001.pc_busca_seguros                        |
  | buscar_seguradora                      | SEGU0001.pc_buscar_seguradora                    |
  | atualizar_matricula                    | SEGU0001.pc_atualizar_matricula                  |
  | buscar_plano_seguro                    | SEGU0001.pc_buscar_plano_seguro                  |
  | calcular_data_debito                   | SEGU0001.pc_calcular_data_debito                 |
  | buscar_motivo_can                      | SEGU0001.pc_buscar_motivo_can                    |
  | cria-tabela-depara                     | SEGU0001.pc_cria_tabela_depara                   |
  +----------------------------------------+--------------------------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/

/*..............................................................................

    Programa: b1wgen0033.p
    Autor   : Guilherme
    Data    : Agosto/2008                     Ultima Atualizacao: 27/11/2017
           
    Dados referentes ao programa:
                
    Objetivo  : BO ref. a Seguros.
                    
    Alteracoes: Incluir procedure seguro_auto (Gabriel).
    
                30/03/2010 - Incluir procedure cria_seguro (Gabriel).
                
                24/08/2011 - Inclusao de procedures incluir_garantias,
                             alterar_garantias, excluir_garantias,
                             gerar_atualizacao_seg, buscar_associados,
                             buscar_coberturas_plano, desfaz_canc_seguro,
                             cancelar_seguro, buscar_motivo_can,
                             atualizar_seguro_vida, buscar_tip_seguro,
                             valida_inc_seguro, buscar_cooperativa,
                             buscar_empresa, imprimir_alt_seg_vida,
                             buscar_pessoa_juridica. Alteradas procedures
                             busca_seguros, buscar_proposta_seguro,
                             buscar_seguradora (Gati - Oliver)
                             
                19/10/2011 - Alteracao da chamada da procedure 
                             'buscar_coberturas_plano' para chamar 
                             'buscar_plano_seguro';
                           - Gravacao de temp-table tt-seg-geral.cdsegura na
                             procedure 'buscar_seguro_geral' (GATI - Eder)
                             
                07/12/2011 - Ajuste na quebra da pagina da impressao do seguro
                             residencial (Gabriel).             
                             
                16/12/2011 - Alterado as procedures abaixo para validar 
                             corretamente a idade nos seguros de vida:
                             - validar_criacao
                             - cria_seguro
                             (Adriano).             
                
                10/01/2012 - Retirado a validao para descricao da franquia na
                             rotina "incluir_garantias" e "alterar_garantias";
                           - Alteração no layout da Proposta de Seguro
                             Residencial (Tiago).
                             
                03/02/2012 - Correção na consulta da procedure 'buscar_end_coo'
                             para retornar sempre o prim. endereço residencial
                             (Lucas)
                             
                07/02/2012 - Correções na procedure 'cria_seguro' relativo a
                             contratação dos planos 14, 18, 24, 34, 44, 54 e 64.
                             (Lucas)
                             
                01/03/2012 - Ajuste na procedure cria_seguro para informar no
                             log qual tipo de seguro esta sendo efetivado
                             (Adriano).           
                             
                21/03/2012 - Ajuste na procedure cria_seguro para alimentar
                             a variavel aux_dstransa no final da procedure
                           - Corrigido FORMAT do campo rel_nrcpfcgc na proposta
                             de seguro residencial (Adriano).
                             
                04/04/2012 - Adicionado idorigem em chamada da proc. 
                             busca-endereco em BO 38. (Jorge)   
                             
                12/11/2012 - Alteracao na procedure 'cancelar_seguro' para 
                             visualizacao de log na tela 'verlog' (David Kruger).                         
                             
                18/12/2012 - Incluir tratamento para seguro tipo 3 e 
                             planos 11; 15; 21; 31; 41; 51 e 61 (Lucas R.)
                             
                28/02/2013 - Incluir titulo em impressao de seguro de vida
                             "Alteracao de Beneficiario" somente se for 
                             alteracao, incluir parametro cddopcao em 
                             procedure imprimir_alt_seg_vida (Lucas R.)
                
                25/07/2013 - Alteracao na procedure "buscar_seguro_geral"
                             para trazer a coluna "complend" na TEMP-TABLE 
                             "tt-seg-geral" e adicionado o parametro complend
                             na procedure "cria_seguro". (James)
                             
                05/08/2013 - Alterado para mostrar a mensagem: "SOLICITO AINDA
                             O CANCELAMENTO DO RESPECTIVO DÉBITO EM CONTA 
                             CORRENTE " somente se o tipo de seguro for 
                             Prestamista. (Reinert)
                             
                02/10/2013 - Ajustes para o banco ORACLE. Alterado parametro 
                             par_dtdebito da procedure atualizar_movtos_seg 
                             de LIKE crawseg.dtdebit para LIKE crawseg.dtdebito
                             (Douglas Pagel).
                
                08/10/2013 - Adicionado o simbolo de porcentagem para o IOF na
                             impressao da proposta de seguro residencial e
                             adicionada a informacao de IOF na impressao da 
                             proposta de seguro de vida (Carlos)
                             
                24/10/2013 - Alterada a procedure imprimir_alt_seg_vida para
                             utilizar os valores do plano do seguro 
                             (tt-plano-seg) no form f_vida. Alteracao da sigla 
                             PAC para PA (Carlos)
                
                27/11/2013 - Alteração para adequação de padrões de indentação e
                             desenvolvimento CECRED. (André - GATI)
                             
                20/02/2014 - Alteração do local do estado civil, da crapass para
                             a crapttl (Carlos)
                             
                05/03/2014 - Incluso VALIDATE (Daniel).
                
                25/03/2014 - Ajuste na procedure "atualizar_matricula",
                             para buscar a proxima sequencia crapmat.nrctrseg 
                             apartir banco Oracle (James)
                             
                25/06/2014 - Ajuste leitura crapseg na procedure busca_seguros
                             e retirado alert-box (Daniel).
                             
                01/07/2014 - #161084 Inclusao da validacao do preenchimento do
                             nome da cidade para o caso de o usuario nao 
                             pressionar [enter] no CEP, no cadastro do local de
                             risco (Carlos)
                             
                05/09/2014 - Alterado procedure imprimir_proposta_seguro, 
                             alterado chamada da procedure gera-pdf-impressao 
                             para gera-pdf-impressao-sem-pcl (Lucas R. #190062)
                            
                11/12/2014 - Conversão da fn_sequence para procedure para não
                             gerar cursores abertos no Oracle. (Dionathan)
                             
                04/02/2015 - Alteraco rotina cria_seguro para gravar a data do primeiro debito
                             para os seguros de Vida SD 235552 (Odirlei-AMcom) 
                             
                06/02/2015 - Alterado rotina de cancelar_seguro e desfaz_canc_seguro
                             para gravar e limpar campo contendo o codigo do operador
                             que efetuou a operação SD 251771 (Odirlei-Amcom)
                             
                16/02/2015 - Alterado rotina imprimir_alt_seg_vida, para imprimir
                             a proposta do contrato que esta sendo passado no parametro
                             e não ultimo do tipo de seguro SD254370 (Odirlei-AMcom)
                
                06/03/2015 - Ajustes na cria_seguro para gravar dia dos proximos debitos
                             do seguro de vida gerados pelo ayllos-web (Odirlei-AMcom)
                             
                09/03/2015 - Ajuste no seguro de vida para gravar o capital segurado
                             (James)

                27/04/2015 - Alteracao na proposta de seguro residencial impressa. 
                             (Jaison/Thiago - SD: 279759)

                11/05/2015 - Propostas com inicio de vigencia 06/04/2015 deverao 
                             utilizar informacoes da LAZAM, propostas anteriores 
                             a esta data deverao utilizar dados da Addmakler.
                             (Jaison/Thiago - SD: 279759)
                             
                11/06/2015 - Ajuste para gravar data de renovação para o seguro
                             de vida. (James)
                             
                03/07/2015 - Alterar mensagem do dia do Vencimento 
                            (Lucas Ranghetti #303749)
                            
                22/07/2015 - Retirar linha de próximo debito do form f_canc_debito
                             (Lucas Ranghetti #306198)
                             
                04/09/2015 - Adicionado validacao de idade para seguro de vida, 
                             caso tenha 65 anos ou mais, devera criticar com "647"
                             (Lucas Ranghetti #318225)
                             
                16/09/2015 - Ajustes para liberacao referente a conversao web
                             da tela ALTSEG
                             (Adriano).             
                             
                01/12/2015 - Incluir rotina saldo-devedor-cpf, que ira efetuar a
                             busca dos saldos devedores de emprestimos ativos 
                             (Lucas Ranghetti #365246)
                             
                16/02/2016 - Ajustado para que os relatorios de vida e de casa gerem duas vias
                             nos relatórios de contrato, conforme solicitado no chamado 384119. 
                             (Kelvin)
                          
				11/04/2016 - Retirado o "=" do ">=" para a critica 647 (Lucas Ranghetti #432127)

				07/06/2016 - M358 - Ajustes para nao incluir mais seguros que serao migrados (Tiago/Thiago)

                17/06/2016 - Inclusão de campos de controle de vendas - M181 ( Rafael Maciel - RKAM)

				09/11/2016 - Corrigido Problemas na impressao da proposta, nao limitar mais os 
				             resultados a 1 ano SD553284 (Tiago/Thiago).
								
				26/05/2017 - Alteracao no contrato conforme solicitado no chamado 655583. (Kelvin)
				
				21/06/2017 - Ajuste emergencial no formato do cnpj do contrato. (Kelvin #655583)

                12/06/2017 - Ajuste devido ao aumento do formato para os campos crapass.nrdocptl, crapttl.nrdocttl, 
			                 crapcje.nrdoccje, crapcrl.nridenti e crapavt.nrdocava
							 (Adriano - P339).

				04/08/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                 crapass, crapttl, crapjur 
							 (Adriano - P339).

                27/11/2017 - Chamado 792418 - Incluir opções de cancelamento 10 e 11
                             (Andrei Vieira - MOUTs)

..............................................................................*/
                    
{ sistema/generico/includes/b1wgen0038tt.i }
{ sistema/generico/includes/b1wgen0033tt.i }
{ sistema/generico/includes/b1wgen0002tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/ayllos/includes/var_online.i NEW }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/var_oracle.i }

DEF STREAM str_1.

DEF VAR rel_nmresemp    AS CHAR    FORMAT "x(15)"                     NO-UNDO.
DEF VAR rel_nmrelato    AS CHAR    FORMAT "x(40)" EXTENT 5            NO-UNDO.

DEF VAR rel_nrmodulo    AS INT     FORMAT "9"                         NO-UNDO.
DEF VAR rel_nmmodulo    AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]               NO-UNDO.

DEF VAR h-b1wgen0024    AS HANDLE                                     NO-UNDO.
DEF VAR h-b1wgen0038    AS HANDLE                                     NO-UNDO.
DEF VAR h-b1wgen0008    AS HANDLE                                     NO-UNDO.
DEF VAR h-b1wgen9999    AS HANDLE                                     NO-UNDO.
DEF VAR rel_nrdconta    AS INT EXTENT 2                               NO-UNDO.
DEF VAR rel_nrdconta2   LIKE crapseg.nrdconta                         NO-UNDO.
DEF VAR rel_nrdconta3   LIKE crapseg.nrdconta                         NO-UNDO.
DEF VAR tab_txcpmfcc    AS DECIMAL                                    NO-UNDO.
DEF VAR aux_vlpreseg    AS DECIMAL                                    NO-UNDO.
DEF VAR rel_nrdocttl    LIKE crapttl.nrdocttl                         NO-UNDO.
DEF VAR rel_dssubsti    AS CHAR                                       NO-UNDO.
DEF VAR rel_dstipseg    AS CHAR                                       NO-UNDO.
DEF VAR rel_dsseguro    AS CHAR                                       NO-UNDO.
DEF VAR rel_nmresseg    AS CHAR                                       NO-UNDO.
DEF VAR rel_nrctrseg    AS INT                                        NO-UNDO.
DEF VAR rel_cdcalcul    AS INT                                        NO-UNDO.
DEF VAR rel_tpplaseg    AS INT                                        NO-UNDO.
DEF VAR rel_ddvencto    AS INT                                        NO-UNDO.
DEF VAR rel_vlpreseg    AS DECIMAL                                    NO-UNDO.
DEF VAR rel_dsmorada    LIKE craptsg.dsmorada                         NO-UNDO.
DEF VAR aux_dsendres    AS CHAR                                       NO-UNDO.
DEF VAR rel_dsocupac    LIKE craptsg.dsocupac                         NO-UNDO.
DEF VAR rel_vlcobert    AS DECIMAL                                    NO-UNDO.
DEF VAR rel_dsbemseg    AS CHAR    EXTENT 5                           NO-UNDO.
DEF VAR rel_dsparcel    AS CHAR                                       NO-UNDO.
DEF VAR rel_dsmvtolt    AS CHAR                                       NO-UNDO.
DEF VAR rel_nmdsegur    AS CHAR                                       NO-UNDO.
DEF VAR rel_nrcpfcgc    AS CHAR                                       NO-UNDO.
DEF VAR rel_nmbenefi    AS CHAR    EXTENT 5                           NO-UNDO.
DEF VAR rel_dsgraupr    AS CHAR    EXTENT 5                           NO-UNDO.
DEF VAR rel_txpartic    AS DECIMAL EXTENT 5                           NO-UNDO.
DEF VAR rel_dtinivig    AS DATE                                       NO-UNDO.
DEF VAR rel_dtfimvig    AS DATE                                       NO-UNDO.
DEF VAR aux_cdcritic    AS INTE                                       NO-UNDO.
DEF VAR aux_dscritic    AS CHAR                                       NO-UNDO.
DEF VAR aux_nrdrowid    AS ROWID                                      NO-UNDO.
DEF VAR aux_dstransa    AS CHAR                                       NO-UNDO.
DEF VAR aux_dsorigem    AS CHAR                                       NO-UNDO.
DEF VAR aux_dssegvid    AS CHAR FORMAT "x(12)"                        NO-UNDO.
DEF VAR aux_nrcntseg    AS INT                                        NO-UNDO.
DEF VAR aux_nrctrseg    AS INT                                        NO-UNDO.
DEF VAR seg_nrcpfcgc    AS CHAR                                       NO-UNDO.
DEF VAR seg_dsestcvl    AS CHAR FORMAT "x(12)"                        NO-UNDO.
DEF VAR seg_dssexotl    AS CHAR FORMAT "x(020)"                       NO-UNDO.
DEF VAR tel_dscobert    AS CHAR FORMAT "x(050)"                       NO-UNDO.
DEF VAR aux_idadelmt    AS INT FORMAT "z9"                            NO-UNDO.
DEF VAR aux_idadelm2    AS INT FORMAT "z9"                            NO-UNDO.
DEF VAR rel_tracoseg    AS CHAR                                       NO-UNDO. 
DEF VAR rel_nmprimtl    AS CHAR                                       NO-UNDO.
DEF VAR aux_qtregist    AS INTE                                       NO-UNDO.
DEF VAR aux_premliqu    AS DECIMAL                                    NO-UNDO.
DEF VAR aux_valoriof    AS DECIMAL      INITIAL 7.38                  NO-UNDO.
DEF VAR aux_vliofper    AS CHAR                                       NO-UNDO.
DEF VAR aux_premitot    AS DECIMAL                                    NO-UNDO.
DEF VAR aux_comprela    AS CHAR                                       NO-UNDO.
DEF VAR rel_prestami    AS CHAR                                       NO-UNDO.
DEF VAR aux_vlmorada    AS DECI                                       NO-UNDO.
DEF VAR aux_dscgcseg    AS CHAR FORMAT "99.999.999/9999-99"			  NO-UNDO.
DEF VAR aux_nmresseg    LIKE crapcsg.nmresseg FORMAT "x(30)"          NO-UNDO.

DEF VAR aux_casa3325    AS CHAR FORMAT "x(76)"                        NO-UNDO.
DEF VAR aux_casa0401    AS CHAR FORMAT "x(76)"                        NO-UNDO.
DEF VAR aux_casa0402    AS CHAR FORMAT "x(76)"                        NO-UNDO.
DEF VAR aux_casa0403    AS CHAR FORMAT "x(76)"                        NO-UNDO.
DEF VAR aux_casa0404    AS CHAR FORMAT "x(76)"                        NO-UNDO.
DEF VAR aux_casa0405    AS CHAR FORMAT "x(76)"                        NO-UNDO.
DEF VAR aux_casa0406    AS CHAR FORMAT "x(76)"                        NO-UNDO.
DEF VAR aux_casa0407    AS CHAR FORMAT "x(76)"                        NO-UNDO.
DEF VAR aux_casa0408    AS CHAR FORMAT "x(76)"                        NO-UNDO.
DEF VAR aux_casa4307    AS CHAR FORMAT "x(76)"                        NO-UNDO.
DEF VAR aux_casa4308    AS CHAR FORMAT "x(76)"                        NO-UNDO.
DEF VAR aux_casa4309    AS CHAR FORMAT "x(76)"                        NO-UNDO.
DEF VAR aux_casa0611    AS CHAR FORMAT "x(76)"                        NO-UNDO.
DEF VAR aux_casa0614    AS CHAR FORMAT "x(76)"                        NO-UNDO.
DEF VAR aux_casa0617    AS CHAR FORMAT "x(76)"                        NO-UNDO.
DEF VAR aux_casa0618    AS CHAR FORMAT "x(76)"                        NO-UNDO.
DEF VAR aux_casa0619    AS CHAR FORMAT "x(76)"                        NO-UNDO.

/*Tabela DE/PARA de plano de seguros inativos*/
DEF TEMP-TABLE tt-pldepara NO-UNDO
    FIELD cdsegura LIKE craptsg.cdsegura
    FIELD tpseguro LIKE crapseg.tpseguro
    FIELD tpplasde LIKE crapseg.tpplaseg
    FIELD tpplaspa LIKE crapseg.tpplaseg.

FORM 
    "\022\024\033\120"     /* Reseta impressora */ 
    "\0330\033x0\033\017"
    "\033\1230                PROPOSTA DE SEGURO RESIDENCIAL" AT 20
    SKIP
    "CNPJ -" AT 22
    aux_dscgcseg
    SKIP
    "   Processo SUSEP - 15414.000146/2005-83" AT 13 
    SKIP
    "   Seguro garantido pela: " AT 12
    aux_nmresseg 
    SKIP(2)
    "Proposta: " AT 22
    tt-seguros.nrctrseg 
    "\022\024\033\120"     /* Reseta impressora */
    SKIP(2)
    "\0330\033x0\033\017"
    "\033\1230" 
    "\033\107Informacoes do Segurado, Objeto  Segurado  Residencia" AT 1
    "  e  Cobertura" 
    SKIP
    "Contratadas \033\110"
    SKIP(2)
    WITH NO-BOX COLUMN 5 NO-ATTR-SPACE NO-LABELS WIDTH 150 
    FRAME f_autori_casa_c.

FORM   
    "Estipulante:  "     tt-seguradora.nmrescec FORMAT "x(50)" 
    SKIP                                                         
    "Sub-Estipulante: "  tt-seguradora.nmrescop FORMAT "x(15)"             
    SKIP
    "Segurado: " tt-prop-seguros.nmdsegur
    SKIP
    "CPF: " rel_nrcpfcgc  FORMAT "x(18)"
    SPACE(10)
	SKIP
    "RG: " rel_nrdocttl
    SKIP(1)
    "LOCAL DE RISCO:"
    SKIP
    "Endereco: " aux_dsendres FORMAT "x(48)"
    SKIP
    "Bairro: " tt-prop-seguros.nmbairro
    SKIP
    "Cidade: " tt-prop-seguros.nmcidade
    "UF: "     tt-prop-seguros.cdufresd
    SPACE(10)
    "CEP "     tt-prop-seguros.nrcepend    
    SKIP(2)
    "Tipo de Residencia:" rel_dsmorada FORMAT "x(15)"
    "Tipo de Moradia:" AT 37 rel_dsocupac FORMAT "x(15)"
    SKIP(1)
    "Inicio de Vigencia: A partir das 24 horas do dia"
    rel_dtinivig FORMAT "99/99/9999"
    SKIP
    "Fim  de   Vigencia: " rel_dtfimvig FORMAT "99/99/9999"
    SKIP(1)
    "\033\107Coberturas Contratadas"
    "Limite Max. Indenizavel\033\110" AT 48
    SKIP(1)
    WITH NO-BOX COLUMN 5 NO-LABELS WIDTH 132 FRAME f_autori_casa_c_w_2.

FORM SKIP(1)
    "\033\107Franquia\033\110"
    SKIP(1)
    WITH NO-BOX COLUMN 5 NO-LABELS WIDTH 132 FRAME f_autori_casa_franq1.

FORM
    tt-gar-seg.dsgarant  FORMAT "x(44)" 
    tt-gar-seg.vlgarant
    WITH NO-BOX COLUMN 5 NO-ATTR-SPACE NO-LABELS WIDTH 150 DOWN 
    FRAME f_autori_casa_2.

FORM 
    tt-gar-seg.dsfranqu      
    WITH NO-BOX COLUMN 5 NO-ATTR-SPACE NO-LABELS WIDTH 150 DOWN 
    FRAME f_autori_casa_franq2.

FORM SKIP(2)
    "(*) A Cobertura de Incendio, Queda de  Raio  e  Explosao  abrange  o" 
    SKIP
    "predio e conteudo e garante tambem Queda de Aeronave e  Recomposicao"
    SKIP
    "de Documentos de acordo com  as  Condicoes  Gerais  e  Especiais  do"
    SKIP
    "Seguro."
    SKIP(2)
    "Premio Liquido"  AT    05
    "IOF"             AT    31
    "Premio Total"    AT    55
    SKIP
    aux_premliqu      AT    05
    aux_vliofper      AT    30
    aux_premitot      AT    55
    WITH NO-BOX COLUMN 5 NO-LABELS WIDTH 150 FRAME f_autori_casa_compl.

FORM SKIP(2)
    "\033\107Condicoes da  Assistencia  Residencial  24 horas  e  Comunicacao  de" 
    SKIP
    "Sinistro \033\110"
    SKIP(2)
    "Em caso de sinistros ou  solicitacao  de  assistencia  24  horas,  o" 
    SKIP
    "Segurado devera entrar em contato pelo telefone:  \033\1070800-725-2064\033\110.  As"
    SKIP
    "condicoes dos servicos de Assistencia 24 horas estao disponiveis com"  
    SKIP
    "a Estipulante ou Corretora de Seguros. Qualquer sinistro  que  possa"
    SKIP
    "acarretar a responsabilidade da Seguradora devera ser  imediatamente"
    SKIP
    "comunicado pelo Segurado, ou por quem sua vez fizer, pelo meio  mais"
    SKIP
    "rapido que dispuser, ratificando  posteriormente  por  escrito  pelo"
    SKIP
    "proprio Segurado conforme condicoes Gerais do  Seguro.  Este  seguro"
    SKIP
    "garante apenas \033\107residencias de ocupacao HABITUAL\033\110. O  presente  seguro"
    SKIP
    WITH NO-BOX COLUMN 5 NO-ATTR-SPACE NO-LABELS WIDTH 150 FRAME f_autori_casa_3.
    
FORM
    "rege-se pela proposta de seguro e pelas Condicoes Gerais e Especiais" 
    SKIP
    "da  apolice  de  Seguro  Compreensivo  Residencial,  em   poder   da"
    SKIP
    "Estipulante, podendo ser consultadas a  qualquer  momento.  SERVICOS"
    SKIP
    "DISPONIBILIZADOS  ATRAVES  DO  ASSISTENCIA  24  HORAS:  eletricista,"
    SKIP
    "chaveiro, vidraceiro, encanador, seguranca e vigilancia, conservacao" 
    SKIP
    "e limpeza, transporte de moveis, guarda de moveis, estada em  hotel,"
    SKIP
    "retorno antecipado, cobertura  provisoria  de  telhados,  amparo  de"
    SKIP
    "criancas, guarda de animais domesticos,  restaurante  e  lavanderia,"
    SKIP
    "transmissao  de  mensagens,  remocao  de  emergencia,   retorno   ao"
    WITH NO-BOX COLUMN 5 NO-ATTR-SPACE NO-LABELS WIDTH 150 FRAME f_autori_casa_3_1.

FORM 
    SKIP
    "domicilio apos alta hospitalar, assessoria administrativa.  SERVICOS" 
    SKIP
    "EMERGENCIAIS - SEM VINCULO AO EVENTO: organizacao e envio de flores,"
    SKIP
    "indicacao   de   profissional."
    WITH NO-BOX COLUMN 5 NO-ATTR-SPACE NO-LABELS WIDTH 150 FRAME f_autori_casa_3_2.

FORM 
    SKIP
    "domicilio apos alta hospitalar, assessoria administrativa.  SERVICOS" 
    SKIP
    "EMERGENCIAIS - SEM VINCULO AO EVENTO: indicacao  medico  hospitalar,"
    SKIP
    "organizacao  e  envio  de   flores,   indicacao   de   profissional."
    WITH NO-BOX COLUMN 5 NO-ATTR-SPACE NO-LABELS WIDTH 150 FRAME f_autori_casa_3_2_1.	

FORM 
    SKIP
    "Todos  os  servicos  disponibilizados  pela  assistencia  24  horas,"
    SKIP
    "possuem limites e condicoes contratuais que  deverao  ser  lidas  no"
    SKIP
    "manual do segurado.                                                 "
    SKIP
    SKIP(2)
    "\033\107Declaracao do Segurado"
    SKIP(2)
	"1) ter recebido e lido as condicoes contratuais  em  versao integral"
	SKIP
	"deste  seguro e estou de acordo; 2) que  as  informacoes  fornecidas"  
    SKIP
	"nesta proposta de seguro estao corretas, e que estou ciente de que a" 
    SKIP
	"veracidade das respostas prestadas neste documento  sao fundamentais" 
	SKIP
	"e  determinantes  para  a  precificacao  e  aceitacao  do  risco.  A"
	SKIP
	"inexatidao e/ou  omissao acarretam a perda do direito a indenizacao,"
	SKIP
	"conforme Art. 766 do Codigo Civil Brasileiro. 3) que comprometo-me a"
	SKIP
	"comunicar  por  escrito a Corretora e Seguradora, qualquer alteracao"
	SKIP
	"realizada  em  relacao  a  essa  proposta  ou qualquer alteracao nas"
	SKIP
	"condicoes  do  risco;  4) estar  de  acordo que o Estipulante  acima" 
	SKIP
	"forneca meus dados cadastrais e patrimoniais a Corretora e que  essa" 
	SKIP
	"disponibilize  a  Seguradora; 5) estar ciente  e  que  expressamente"  
	SKIP
	"autorizo  a  inclusao  de  todos  os  meus   dados   e   informacoes"   
	SKIP
	"relacionadas  ao  presente  seguro, assim como de todos os eventuais"   	
	SKIP
	"sinistros e ocorrencias  referentes ao mesmo, em banco de dados, aos" 
	SKIP
	"quais  a  seguradora podera recorrer para analise de riscos atuais e"
	SKIP
	"futuros  e na  liquidacao de processos de sinistros; 6) estou ciente"
	SKIP
	"que  a  Seguradora  dispora, para aceitacao ou recusa, de 15(quinze)"
	SKIP	
	"dias da data do recebimento desta  proposta em suas filiais. Em caso"
	SKIP
	"de  recusa da aceitacao desta proposta, o premio pago sera devolvido"
	SKIP
	"com correcao  monetaria estabelecida nas Condicoes Gerais do Seguro;"
	SKIP
	"7) que  estou  ciente de que o risco ora proposto sera aceito apenas"
	SKIP
	"se estiver de acordo com  as  regras de aceitacao da Seguradora e de"
	SKIP
	"que o nao pagamento da primeira parcela do seguro ate seu vencimento"
	SKIP
	"acarretara  o  cancelamento  do  seguro;  8)  a  Seguradora   podera"
	SKIP
	"enviar proposta  de renovacao   automatica  ao  Segurado, juntamente"
	SKIP
	"com  as  condicoes  para   renovacao  do   contrato  e  nao  havendo" 
	SKIP
	"manifestacao das  partes contratantes, o seguro  sera  renovado. Por"
    SKIP	
    aux_casa3325
    SKIP
    WITH NO-BOX COLUMN 5 NO-ATTR-SPACE NO-LABELS WIDTH 150 FRAME f_autori_casa_3_3.

FORM 
    SKIP
    "Todos  os  servicos  disponibilizados  pela  assistencia  24  horas,"
    SKIP
    "possuem limites e condicoes contratuais que  deverao  ser  lidas  no"
    SKIP
    "manual do segurado.                                                 "
    SKIP
    SKIP(2)
    "\033\107Declaracao do Segurado"
    SKIP(2)
    "Declaro para todos os fins e efeitos: 1)  ter  prestado  informacoes"
    SKIP
    "completas e  veridicas;  2)  ter  recebido  as  Condicoes  Gerais  e" 
    SKIP
    "Especiais do Seguro e estou de acordo com seu conteudo; 3) estar  de"
    SKIP
    "acordo para que o Estipulante acima forneca meus  dados cadastrais e" 
    SKIP
    "patrimoniais a Corretora e  que  essa  disponibilize  a  Seguradora;" 
    SKIP
    "4) que perderei o direito  a  uma  eventual  indenizacao  caso  seja" 
    SKIP
    "constatada a falsidade de qualquer informacao conforme  determina  o"  
    SKIP
    "Codigo Civil;  5)  estou  ciente  que  a  Seguradora  dispora,  para"  
    SKIP
    "aceitacao ou recusa, de 15(quinze) dias da data do recebimento desta" 
    SKIP
    "proposta em suas filiais. Em  caso  de  recusa  da  aceitacao  desta" 
    SKIP
    "proposta, o  premio  pago  sera  devolvido  com  correcao  monetaria" 
    SKIP
    "estabelecida nas Condicoes Gerais do Seguro. 6) estar ciente  e  que"
    SKIP
    "expressamente autorizo a inclusao de todos os  dados  e  informacoes"
    SKIP
    "relacionadas ao presente seguro assim como  de  todos  os  eventuais"
    SKIP
    "sinistros e ocorrencias referentes ao mesmo, em banco de dados,  aos"
    SKIP
    "quais a seguradora podera recorrer para analise de riscos  atuais  e"
    SKIP
    "futuros e na liquidacao de processos de  sinistros. 7) a  Seguradora"
    SKIP
    "podera  enviar  proposta  de  renovacao  automatica   ao   Segurado,"
    SKIP
    "juntamente com as condicoes para renovacao do contrato e nao havendo"   
    SKIP
    "manifestacao das partes contratantes, o  seguro  sera  renovado. Por"
    SKIP
    aux_casa3325
    SKIP
    WITH NO-BOX COLUMN 5 NO-ATTR-SPACE NO-LABELS WIDTH 150 FRAME f_autori_casa_3_3_1.	

FORM                                                                     
    aux_casa0401
    SKIP
    aux_casa0402
    SKIP
    aux_casa0403
    SKIP
    aux_casa0404
    SKIP
    aux_casa0405
    SKIP
    aux_casa0406
    SKIP
    aux_casa0407
    SKIP
    aux_casa0408
    SKIP(2)
    WITH NO-BOX COLUMN 5 NO-ATTR-SPACE NO-LABELS WIDTH 150 FRAME f_autori_casa_4.

FORM
    "\033\107Principais Exclusoes do Seguro Residencial                  "  
    SKIP(2) 
    "* Local de risco que nao seja o especificado no Certificado de      "
	SKIP
	"Seguro;"
    SKIP  
    "* Imovel de veraneio ou fim de semana, chacaras, sitios, fazendas;  "
    SKIP
    "* Imoveis coletivos (republicas, pensoes, asilos e similares);      "
    SKIP 
    "* Imovel que nao esteja  sendo  utilizado  para  fim  exclusivamente"
    SKIP
    "residencial,  mesmo  que  no  imovel  funcione  atividade  comercial"
    SKIP
    "informal;" 
    SKIP    
    "* Manutencao e utilizacao inadequada dos padroes  recomendados  pelo"
    SKIP
    "fabricante, deterioracao gradativa,  desarranjo  mecanico,  desgaste"
    SKIP
    "natural decorrente do uso, excesso ou falta de corda;               "
    SKIP    
    "* Erosao,  corrosao,  oxidacao,  ferrugem,   variacao   atmosferica," 
    SKIP  
    "incrustacao, fadiga;                                                "  
    SKIP
    WITH NO-BOX COLUMN 5 NO-ATTR-SPACE NO-LABELS WIDTH 150 FRAME f_autori_casa_4_1.
	
	FORM
    "\033\107Principais Exclusoes do Seguro Residencial                  "  
    SKIP(2) 
    "* Local de risco que nao seja o especificado na apolice de seguro;  "
    SKIP  
    "* Imovel de veraneio ou fim de semana, chacaras, sitios, fazendas;  "
    SKIP
    "* Imoveis coletivos (republicas, pensoes, asilos e similares);      "
    SKIP 
    "* Imovel que nao esteja  sendo  utilizado  para  fim  exclusivamente"
    SKIP
    "residencial,  mesmo  que  no  imovel  funcione  atividade  comercial"
    SKIP
    "informal;" 
    SKIP
    "* A  seguradora  aceitara,  no  entanto,  imoveis  residenciais  com"
    SKIP
    "pequena atividade informal (exclusivamente  costura),  desde  que  a"
    SKIP
    "caracteristica principal do risco nao seja alterada. Neste caso  nao"
    SKIP
    "serao  garantidos  quaisquer  bens  relacionados  a   esta   pequena"
    SKIP
    "atividade comercial, exceto para maquinas de costura, limitado  a  4"
    SKIP
    "(quatro) maquinas por vigencia de apolice;                          "
    SKIP
    "* Manutencao e utilizacao inadequada dos padroes  recomendados  pelo"
    SKIP
    "fabricante, deterioracao gradativa,  desarranjo  mecanico,  desgaste"
    SKIP
    "natural decorrente do uso, excesso ou falta de corda;               "
    SKIP    
    "* Erosao,  corrosao,  oxidacao,  ferrugem,   variacao   atmosferica," 
    SKIP  
    "incrustacao, fadiga;                                                "  
    SKIP
    WITH NO-BOX COLUMN 5 NO-ATTR-SPACE NO-LABELS WIDTH 150 FRAME f_autori_casa_4_1_1.

FORM
    "* Chuva, mofo, bolor e fungos, cupim, processo de limpeza,  acao  de" 
    SKIP
    "luz e animais daninhos;                                             "
    SKIP
    "* Imoveis desabitados, em  construcao,  em  reconstrucao,  alteracao"
    SKIP
    "estrutural ou reformas (quando esta  reforma  exigir  a  desocupacao"
    SKIP
    "temporaria do imovel e / ou que haja comprometimento na seguranca do"
    SKIP
    "imovel), inclusive  os  materiais  de construcao destinados  a  essa"
    SKIP
    "utilizacao;                                                         "
    SKIP
    "* Deslizamento  de  terra,  desmoronamento,  alagamento,   maremoto,"
    SKIP
    "inundacao, enchentes, terremoto, tremor de terra, erupcao  vulcanica"
    SKIP
    "e quaisquer outras convulsoes da natureza;                          "
    SKIP
    WITH NO-BOX COLUMN 5 NO-ATTR-SPACE NO-LABELS WIDTH 150 FRAME f_autori_casa_4_2.

FORM
    "* Simples  extravio,  saques,  furto   simples   e   desaparecimento"
    SKIP
    "inexplicavel,  inclusive  os  ocorridos  durante  ou  apos   eventos"
    SKIP
    "cobertos;                                                           "
    SKIP
    "* Dinheiro de  qualquer  especie,  cheques,  titulos,  papel  moeda,"
    SKIP
    "acoes,  selos,  moeda  cunhada  e  quaisquer   outros   papeis   que"
    SKIP
    "representem valor;                                                  "
    SKIP
    aux_casa4307
    SKIP
    aux_casa4308
    SKIP
    aux_casa4309
    SKIP
    "* Joias e relogios.                                                 "
    SKIP(1)
    WITH NO-BOX COLUMN 5 NO-ATTR-SPACE NO-LABELS WIDTH 150 FRAME f_autori_casa_4_3.

FORM
    "Observacoes importantes: \033\110"
    SKIP
    "1. Este  documento  nao  apresenta  todas  as  exclusoes  do  seguro"
    SKIP
    "contratado;                                                         "
    SKIP
    "2. Todas as exclusoes  estao  devidamente  descritas  nas  condicoes" 
    SKIP
    "gerais e especiais da apolice de seguro; Recomenda-se a  leitura  da"  
    SKIP
    "apolice de seguro residencial.                                      "
    WITH NO-BOX COLUMN 5 NO-ATTR-SPACE NO-LABELS WIDTH 150 FRAME f_autori_casa_4_4.

FORM
    SKIP(3)
    "Observacoes Gerais"
    SKIP
    '"A aceitacao do risco e a concretizacao do seguro estao  sujeitos  a'
    SKIP
    'analise da Seguradora."'
    SKIP
    '"O registro deste plano na SUSEP na implica, por parte da  Autarquia'
    SKIP
    ', incentivo ou recomendacao a sua comercializacao."'
    SKIP
    '"O Segurado podera consultar a situacao cadastral de seu corretor de'
    SKIP
    "seguros, no  site  www.susep.gov.br,  por  meio  do  numero  de  seu"
    SKIP
    'registro na SUSEP, nome completo, CNPJ ou CPF."'
    SKIP(2)
	"Telefones Uteis" 
    SKIP
	"Assistencia 24 Horas: 0800 725 2064"
	
	SKIP
	"Central de Atendimento a Sinistros Capitais e Regioes Metropolitanas" 
	SKIP
	"0800 7252064 (2° a 6º feira das 8h00 as 20h00)"
	SKIP
	"Central de Atendimento do Estipulante"
	SKIP
	"(47)3231-4646 (2º a 6º feira das 8h00 as 20h00)"
	SKIP
	"Central de Atendimento a Clientes com deficiencia auditiva ou de fala"
	SKIP
	"0800 724 5084 (24h00 por dia 7 dias por semana)"
	SKIP
	"Ouvidoria - ouvidoria@chubb.com"
	SKIP
	"0800 722 5059 (2º a 6º feira das 8h00 as 18h00)"
	SKIP
	"Caixa Postal 310, Agencia 72300019, CEP: 01031-970"
	SKIP
	"A Ouvidoria e um canal de comunicacao, imparcial e  independente, que"
	SKIP
	"as  Companhias  do  Grupo Chunn  disponibilizaram  para seus clientes"
	SKIP
	"e  colaboradores. E dever  desta  area  atuar de acordo com as normas" 
	SKIP
	"relativas  aos  direitos  dos  consumidores  e  a mediar,  esclarecer"
	SKIP
	",prevenir  e/ou  solucionar   possiveis   conflitos.  Este  canal  de"
	SKIP
	"comunicacao so pode ser utilizado quando clientes e colaboradores nao" 
    SKIP
	"encontrarem  uma  solucao  satisfatoria  para  suas  reclamacoes, nos" 
    SKIP
	"meios  tradicionais  de  atendimento das Companhias(SAC - Servicos de"
	SKIP
	"Atendimento  ao  Consumidor;  Fale Conosco; Sinistros; entre outros)."
	SKIP(2)
	"PELA  PRESENTE,  AUTORIZO  A  DEBITAR  MENSALMENTE  EM  MINHA  CONTA"
    SKIP
    "CORRENTE DE NUMERO " rel_nrdconta2 " , O  VALOR  DAS  PARCELAS  DO SEGURO" 
    SKIP
    "ABAIXO DESCRITO."
    SKIP
    "\033\107OBSERVACAO IMPORTANTE: CASO  NO  DIA  DO  DEBITO  NAO  EXISTA  SALDO"
    SKIP
    "DISPONIVEL NA CONTA  CORRENTE  INDICADA,  CONSIDERA-SE  CANCELADO  O" 
    SKIP
    "PRESENTE SEGURO.\033\110"
    WITH NO-BOX COLUMN 5 NO-ATTR-SPACE NO-LABELS WIDTH 150 FRAME f_autori_casa_5.

FORM
    SKIP(3)
    "Observacoes Gerais"
    SKIP
    '"A aceitacao do risco e a concretizacao do seguro estao  sujeitos  a'
    SKIP
    'analise da Seguradora."'
    SKIP
    '"O registro deste plano na SUSEP na implica, por parte da  Autarquia'
    SKIP
    ', incentivo ou recomendacao a sua comercializacao."'
    SKIP
    '"O Segurado podera consultar a situacao cadastral de seu corretor de'
    SKIP
    "seguros, no  site  www.susep.gov.br,  por  meio  do  numero  de  seu"
    SKIP
    'registro na SUSEP, nome completo, CNPJ ou CPF."'
    SKIP(2)
    "PELA  PRESENTE,  AUTORIZO  A  DEBITAR  MENSALMENTE  EM  MINHA  CONTA"
    SKIP
    "CORRENTE DE NUMERO " rel_nrdconta2 " , O  VALOR  DAS  PARCELAS  DO SEGURO" 
    SKIP
    "ABAIXO DESCRITO."
    SKIP
    "\033\107OBSERVACAO IMPORTANTE: CASO  NO  DIA  DO  DEBITO  NAO  EXISTA  SALDO"
    SKIP
    "DISPONIVEL NA CONTA  CORRENTE  INDICADA,  CONSIDERA-SE  CANCELADO  O" 
    SKIP
    "PRESENTE SEGURO.\033\110"
    WITH NO-BOX COLUMN 5 NO-ATTR-SPACE NO-LABELS WIDTH 150 FRAME f_autori_casa_5_1_1.	

FORM SKIP(2)
    "       TIPO          Proposta  Plano        Dia     Parcelas Mensais"
    SKIP
    "Seguro Residencial"
    rel_nrctrseg FORMAT "zz,zzz,zz9" AT 20 
    tt-prop-seguros.tpplaseg FORMAT "999" AT 33
    rel_ddvencto AT 37
    "R$" AT 55
    rel_dsparcel
    SKIP(3)
    "AUTORIZO A CONSULTA DE MINHAS INFORMACOES  CADASTRAIS  NOS  SERVICOS"
    SKIP
    "DE PROTECAO AO CREDITO (SPC, CERASA,...)"
    SKIP
    "ALEM DO CADASTRO DA CENTRAL DE RISCO DO  BANCO  CENTRAL  DO  BRASIL."
    SKIP(5)
    aux_casa0611
    SKIP
    rel_dsseguro FORMAT "x(40)"
    SKIP
    rel_nrdconta3
    SKIP(5)
    aux_casa0614
    SKIP
    crapope.nmoperad 1
    SKIP
    "Operador" AT 5
    SKIP(5)
    aux_casa0617
    SKIP
    aux_casa0618
    SKIP
    aux_casa0619 
    WITH NO-BOX COLUMN 5 NO-ATTR-SPACE NO-LABELS WIDTH 150 FRAME f_autori_casa_6.

FORM SKIP(1)
     "\033\016   AUTORIZACAO PARA DEBITO DE PLANO DE\024"
     SKIP(4)
     "\033\016" rel_dsseguro AT 15 FORMAT "x(25)" "\024"
     SKIP
     rel_dssubsti AT 23 FORMAT "x(40)"
     SKIP(4)
     WITH NO-BOX COLUMN 5 NO-ATTR-SPACE NO-LABELS WIDTH 150 FRAME f_autoriza_1.

FORM "PELA PRESENTE AUTORIZO A DEBITAR EM MINHA CONTA CORRENTE DE NUMERO"
     rel_nrdconta[1] FORMAT "zzzz,zzz,9" "," SKIP
     "O VALOR A VISTA DO SEGURO ABAIXO DESCRITO."
     SKIP(1)
     "OBSERVACAO IMPORTANTE: CASO NO DIA DO DEBITO NAO EXISTA"
     "SALDO POSITIVO NA CONTA" SKIP
     "CORRENTE INDICADA, CONSIDERA-SE CANCELADO O PRESENTE SEGURO."
     SKIP(1)
     "TIPO                   PROPOSTA    CALCULO PLANO DIA     VALOR A VISTA"
     SKIP(1)
     WITH NO-BOX COLUMN 5 NO-ATTR-SPACE NO-LABELS WIDTH 150 FRAME f_autoriza_2b.

FORM rel_dstipseg AT  1 FORMAT "x(20)"
     rel_nrctrseg AT 22 FORMAT "zz,zzz,zz9"
     rel_cdcalcul AT 33 FORMAT "zz,zzz,zzz"
     rel_tpplaseg AT 45 FORMAT "999"
     rel_ddvencto AT 51 FORMAT "99"
     rel_vlpreseg AT 57 FORMAT "zzz,zzz,zz9.99"
     SKIP(1)
     "BEM SEGURADO:" AT  1
     SKIP(1)
     rel_dsbemseg[1] AT  1 FORMAT "x(79)" SKIP
     rel_dsbemseg[2] AT  1 FORMAT "x(79)" SKIP
     rel_dsbemseg[3] AT  1 FORMAT "x(79)" SKIP
     rel_dsbemseg[4] AT  1 FORMAT "x(79)" SKIP
     rel_dsbemseg[5] AT  1 FORMAT "x(79)" 
     SKIP(2)
     "AUTORIZO A CONSULTA DE MINHAS INFORMACOES CADASTRAIS"
     "NOS SERVICOS DE PROTECAO AO" 
     SKIP
     "CREDITO (SPC, SERASA, CADIN, ...) ALEM DO CADASTRO DA CENTRAL"
     "DE RISCO DO BANCO" 
     SKIP
     "CENTRAL DO BRASIL."
     SKIP(2)
     rel_dsmvtolt    AT  1 FORMAT "x(40)"
     SKIP(5)
     "----------------------------------------" SKIP
     rel_nmprimtl    AT  1 FORMAT "x(40)"  SKIP
     rel_nrdconta[2] AT  1 FORMAT "zzzz,zzz,9"
     SKIP(5)
     "----------------------------------------" SKIP
     ~crapope.nmoperad    AT  1 FORMAT "x(40)"  SKIP
     "Operador"      AT  1
     SKIP(2)
     WITH NO-BOX COLUMN 5 NO-LABELS WIDTH 150 FRAME f_autoriza_3.

FORM "--> \033\105PARA USO DA DIGITACAO\033\106"
     "<----------------------------------------------------" SKIP
     "CONTA/DV  PROPOSTA  TIPO  DIA  PLANO         " AT 3
     "PREMIO INICIO VIG.    FIM VIG." SKIP
     "\033\105" SKIP
     rel_nrdconta[1] AT  1 FORMAT "zzzz,zzz,9"
     rel_nrctrseg    AT 12 FORMAT "zzzzz,zz9"
     rel_dstipseg    AT 23 FORMAT "x(4)"
     rel_ddvencto    AT 30 FORMAT "99"
     rel_tpplaseg    AT 36 FORMAT "999"
     rel_vlpreseg    AT 41 FORMAT "zzz,zzz,zz9.99"
     rel_dtinivig    AT 57 FORMAT "99/99/9999"
     rel_dtfimvig    AT 69 FORMAT "99/99/9999"
     SKIP
     "\033\106"
     WITH NO-BOX COLUMN 5 NO-LABELS WIDTH 150 FRAME f_digitacao.

FORM "PELA PRESENTE AUTORIZO A DEBITAR EM MINHA CONTA CORRENTE DE NUMERO"
     rel_nrdconta[1] FORMAT "zzzz,zzz,9" "," SKIP
     "A PARCELA INICIAL E AS PARCELAS MENSAIS DO SEGURO ABAIXO DESCRITO,"
     "PELO PERIODO" SKIP
     "DE VIGENCIA DO MESMO."
     SKIP(1)
     "AUTORIZO, TAMBEM, A RENOVACAO ANUAL DO MEU SEGURO, NAS MESMAS"
     "BASES OU  ATUALI-" SKIP
     "ZADO COM BASE EM VALOR DE MERCADO DO BEM SEGURADO COM O ENVIO"
     "DO NOVO  CERTIFI-" SKIP
     "CADO, OCASIAO EM QUE TEREI 15 DIAS PARA ACEITAR OU CANCELAR"
     "A RENOVACAO AUTOMA-" SKIP
     "TICA."
     SKIP(1)
     "OBSERVACAO IMPORTANTE: CASO NO DIA DO DEBITO NAO EXISTA"
     "SALDO POSITIVO NA CONTA" SKIP
     "CORRENTE INDICADA, CONSIDERA-SE CANCELADO O PRESENTE SEGURO."
     SKIP(1)     
     "TIPO                   PROPOSTA    CALCULO PLANO DIA     DEBITO MENSAL"
     SKIP(1)
     WITH NO-BOX COLUMN 5 NO-LABELS WIDTH 150 FRAME f_autoriza_2a.

FORM "\033\105"
     tt-cooperativa.nmextcop
     "\033\106"
     SKIP(1)
     "       PROPOSTA DE SEGURO DE VIDA"  
     aux_comprela  FORMAT "X(30)"
     SKIP(1)
     "\033\016" 
     aux_dssegvid               FORMAT "x(50)"  AT 5        
     "\024"
     SKIP
     "\033\105" 
     aux_nrcntseg     LABEL "CONTA/DV"  FORMAT "zzzz,zz9,9"     AT 60
     "\033\106"
     SKIP
     "\033\105" 
     aux_nrctrseg     LABEL "PROPOSTA"  FORMAT "zzzzzz,zz9"     AT 60 
     "\033\106"
     SKIP(1)
     "1. DADOS CADASTRAIS DO PROPONENTE" 
     SKIP(1)
     tt-prop-seguros.nrdconta   LABEL "Conta/dv"                AT 3
     tt-associado.cdagenci      LABEL "PA"
     tt-prop-seguros.nmdsegur   LABEL "Segurado"                AT 34
     SKIP(1)
     seg_nrcpfcgc               LABEL "C.P.F." FORMAT "x(015)"  AT 5
     seg_dsestcvl               LABEL "Estado civil"            AT 30
     SKIP
     tt-prop-seguros.dtnascsg   LABEL "Nascimento"
     seg_dssexotl               LABEL "Sexo"                    AT 38  
     SKIP(1)
     tt-prop-seguros.dsendres   LABEL "Endereco"                AT 3
     tt-prop-seguros.nmbairro   LABEL "Bairro"                  
     SKIP                                                       
     tt-prop-seguros.nmcidade   LABEL "Cidade"                  AT 5
     tt-prop-seguros.cdufresd   LABEL "U.F."                    AT 38
     tt-prop-seguros.nrcepend   LABEL "CEP"                     AT 57
     SKIP(1)
     "2. DADOS DO SEGURO" 
     SKIP(1)
     tt-prop-seguros.nrctrseg   LABEL "Contrato"                AT 2
     tt-prop-seguros.tpplaseg   LABEL "Plano"                   AT 33
     rel_ddvencto               LABEL "           Dia do debito"  FORMAT "99"
     SKIP
     tel_dscobert               LABEL "Cobertura"
     SKIP(1)
     tt-plano-seg.vlplaseg   LABEL "Valor do premio mensal" FORMAT "zzz,zz9.99"
     " IOF: 0,38%"
     aux_vlmorada            LABEL "Valor da cobertura"      AT 50
                                                            FORMAT "zzz,zz9.99"
     SKIP
     tt-prop-seguros.dtinivig LABEL "Inicio da vigencia"        AT 5
     "(apos as 24:00 horas)"
     SKIP(1)
     "3. BENEFICIARIOS"
     "PARENTESCO          % PARTIC"                             AT  42
     SKIP(1)         
     tt-seguros.nmbenvid[1] tt-seguros.dsgraupr[1] tt-seguros.txpartic[1] SKIP
     tt-seguros.nmbenvid[2] tt-seguros.dsgraupr[2] tt-seguros.txpartic[2] SKIP
     tt-seguros.nmbenvid[3] tt-seguros.dsgraupr[3] tt-seguros.txpartic[3] SKIP
     tt-seguros.nmbenvid[4] tt-seguros.dsgraupr[4] tt-seguros.txpartic[4] SKIP
     tt-seguros.nmbenvid[5] tt-seguros.dsgraupr[5] tt-seguros.txpartic[5]
     SKIP(1)
     "4. NA FALTA DE INDICACAO DE BENEFICIARIO, PREVALECERA O QUE"
     "ESTIPULA A LEGISLACAO."
     SKIP(1)
     "5. PELA PRESENTE AUTORIZO A DEBITAR DE MINHA CONTA CORRENTE O"
     "VALOR DO PREMIO MENSAL" SKIP
     "   CORRESPONDENTE AO SEGURO ACIMA DESCRITO. CASO NO DIA DO DEBITO NAO"
     "EXISTA SALDO"
     SKIP
     "   POSITIVO NA CONTA CORRENTE INDICADA, CONSIDERA-SE CANCELADO O"
     "PRESENTE SEGURO."
     WITH NO-BOX COLUMN 12 NO-LABELS SIDE-LABELS WIDTH 132 FRAME f_vida.

FORM     
     SKIP(1)
     "6. A IDADE LIMITE PARA CONTRATACAO DESTE SEGURO E DE" aux_idadelmt
     "ANOS. DECLARO-ME" "CIENTE DE"
     SKIP
     "   QUE ESTE SEGURO SERA CANCELADO AUTOMATICAMENTE AO ATINGIR"
     aux_idadelm2 "ANOS DE"      "IDADE."
     SKIP(1)
     "7. AUTORIZO A CONSULTA DE MINHAS INFORMACOES CADASTRAIS"
     "NOS SERVICOS DE PROTECAO AO" 
     SKIP
     "   CREDITO (SPC, SERASA, CADIN, ...) ALEM DO CADASTRO DA CENTRAL"
     "DE RISCO DO BANCO"  
     SKIP
     "   CENTRAL DO BRASIL."
     SKIP(1)
     rel_dsmvtolt    AT  1 FORMAT "x(40)"
     SKIP(3)
     "----------------------------------------" AT 1 
     rel_tracoseg    AT 44 FORMAT "x(40)" SKIP
     rel_nmprimtl    AT  1 FORMAT "x(40)"  
     rel_nmdsegur    AT 44 FORMAT "x(40)"  SKIP
     rel_nrdconta[2] AT  1 FORMAT "zzzz,zzz,9"
     SKIP(3)
     "----------------------------------------" SKIP
     crapope.nmoperad    AT  1 FORMAT "x(40)"  SKIP
     "Operador"      AT  1
     WITH NO-BOX COLUMN 12 NO-LABELS SIDE-LABELS WIDTH 132
     FRAME f_prestamista.

FORM     
     SKIP(1)
     "6. AUTORIZO A CONSULTA DE MINHAS INFORMACOES CADASTRAIS"
     "NOS SERVICOS DE PROTECAO AO" 
     SKIP
     "   CREDITO (SPC, SERASA, CADIN, ...) ALEM DO CADASTRO DA CENTRAL"
     "DE RISCO DO BANCO"   
     SKIP
     "   CENTRAL DO BRASIL."
     SKIP(4)
     rel_dsmvtolt    AT  1 FORMAT "x(40)"
     SKIP(3)
     "----------------------------------------" AT 1 
     rel_tracoseg    AT 44 FORMAT "x(40)" SKIP
     rel_nmprimtl    AT  1 FORMAT "x(40)"  
     rel_nmdsegur    AT 44 FORMAT "x(40)"  SKIP
     rel_nrdconta[2] AT  1 FORMAT "zzzz,zzz,9"
     SKIP(3)
     "----------------------------------------" SKIP
     crapope.nmoperad    AT  1 FORMAT "x(40)"  SKIP
     "Operador"      AT  1
     WITH NO-BOX COLUMN 12 NO-LABELS SIDE-LABELS WIDTH 132
     FRAME f_nao_prestamista.

FORM   tt-seguros.tpplaseg  AT 1    COLUMN-LABEL "Plano"
       tt-seguros.dtdebito  AT 7    COLUMN-LABEL "Debito"
       tt-seguros.nrdconta  AT 19   COLUMN-LABEL "Conta"
       tt-seguros.nrctrseg  AT 29   COLUMN-LABEL "Contrato"
       tt-seguros.vlant     AT 40   COLUMN-LABEL "Vl.Ant." 
                                    FORMAT "zzz9.99"
       tt-seguros.vlpreseg  AT 60   COLUMN-LABEL "Vl.Atual"
                                    FORMAT "zzz9.99"
       tt-seguros.dtmvtolt  AT 70   COLUMN-LABEL "Movto"
       WITH DOWN WIDTH 80 NO-BOX FRAME f_lista.



PROCEDURE calcular_data_vigencia:
    DEF INPUT PARAM par_cdcooper AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                       NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                       NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                       NO-UNDO. 
    DEF INPUT PARAM par_nmdatela AS CHAR                       NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                       NO-UNDO.
    DEF INPUT PARAM par_qtmesano AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_tpmesano AS CHAR                       NO-UNDO.

    DEF OUTPUT PARAM par_dtcalcul AS DATE                      NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR  aux_contador AS INT                               NO-UNDO.
    DEF VAR  aux_dtinicio AS DATE                              NO-UNDO.
    DEF VAR  aux_dtfimqtd AS DATE                              NO-UNDO.
    DEF VAR  aux_mesrefer AS INT                               NO-UNDO.
    DEF VAR  aux_anorefer AS INT                               NO-UNDO.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0.

    EMPTY TEMP-TABLE tt-erro.

    IF  NOT CAN-DO("M,A",par_tpmesano)  THEN
        DO:
            ASSIGN aux_dscritic = "TIPO DE PARAMETRO ERRADO.".
        END.

    IF  par_tpmesano = "M" AND par_qtmesano > 11 THEN
        DO:
            ASSIGN aux_dscritic = "Quantidade de meses deve estar entre 1 e 11.".
        END.

    IF  par_tpmesano = "A" THEN
        IF   DAY(par_dtmvtolt) = 29  AND  MONTH(par_dtmvtolt) = 2 THEN
            ASSIGN par_dtcalcul =  DATE(03,01,YEAR
                                        (par_dtmvtolt) + par_qtmesano).
        ELSE
            ASSIGN par_dtcalcul =  DATE(MONTH(par_dtmvtolt),DAY(par_dtmvtolt),
                                        YEAR(par_dtmvtolt) + par_qtmesano).

    IF   par_tpmesano = "M" THEN
        DO:
            ASSIGN aux_dtinicio = par_dtmvtolt - DAY(par_dtmvtolt)
                   aux_mesrefer = MONTH(par_dtmvtolt) + par_qtmesano
                   aux_anorefer = IF  aux_mesrefer > 12
                                  THEN 1
                                  ELSE 0
                   aux_mesrefer = IF  aux_mesrefer > 12
                                  THEN aux_mesrefer - 12
                                  ELSE aux_mesrefer
                   aux_dtfimqtd = DATE(aux_mesrefer,01,
                                       YEAR(par_dtmvtolt) + aux_anorefer)
                   aux_dtfimqtd = IF  aux_mesrefer = 2 AND
                                      DAY(par_dtmvtolt) = 31
                                  THEN IF YEAR(aux_dtfimqtd) MODULO 4 = 0
                                       THEN aux_dtfimqtd - 2
                                       ELSE aux_dtfimqtd - 3
                                  ELSE
                                      IF  aux_mesrefer = 2 AND
                                          DAY(par_dtmvtolt) = 30
                                          THEN IF YEAR(aux_dtfimqtd)
                                                          MODULO 4 = 0
                                               THEN aux_dtfimqtd - 1
                                               ELSE aux_dtfimqtd - 2
                                      ELSE
                                          aux_dtfimqtd - 1
                                          par_dtcalcul = (aux_dtfimqtd -
                                                          aux_dtinicio) +
                                                          par_dtmvtolt.
        END.

    EMPTY TEMP-TABLE tt-erro.

    IF  aux_cdcritic <> 0    OR
        aux_dscritic <> ""   THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF   par_flgerlog  THEN
                RUN proc_gerar_log (INPUT  par_cdcooper,
                                    INPUT  par_cdoperad,
                                    INPUT  aux_dscritic,
                                    INPUT  aux_dsorigem,
                                    INPUT  aux_dstransa,
                                    INPUT  FALSE,
                                    INPUT  par_idseqttl,
                                    INPUT  par_nmdatela,
                                    INPUT  par_nrdconta,
                                    OUTPUT aux_nrdrowid).   
            
            RETURN "NOK".
        END.

            
    IF  par_flgerlog  THEN
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

    RETURN "OK".
END PROCEDURE.

PROCEDURE validar_inclusao_vida:
    DEF INPUT PARAM par_cdcooper AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                       NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                       NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                       NO-UNDO. 
    DEF INPUT PARAM par_nmdatela AS CHAR                       NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                       NO-UNDO.
    DEF INPUT PARAM par_inpessoa LIKE crapass.inpessoa         NO-UNDO.
    DEF INPUT PARAM par_cdsitdct AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_dtnascsg AS DATE                       NO-UNDO.
    DEF INPUT PARAM par_nmdsegur AS CHAR                       NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_qtsegass AS INTE                               NO-UNDO.
    DEF VAR aux_vltotseg AS DECI                               NO-UNDO.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0.

    EMPTY TEMP-TABLE tt-erro.

    
    valida:
    DO:
        IF par_cdsitdct = 4 THEN
            DO:
                ASSIGN aux_cdcritic = 64.
                LEAVE valida.
            END.
        
        IF par_inpessoa <> 1 THEN
            DO:
                ASSIGN aux_cdcritic = 436.
                LEAVE valida.
            END.

        IF par_dtnascsg > par_dtmvtolt THEN
            DO:
                ASSIGN aux_cdcritic = 13.
                LEAVE valida.
            END.

        RUN busca_seguros(INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT par_cdoperad,
                          INPUT par_dtmvtolt,
                          INPUT par_nrdconta,
                          INPUT par_idseqttl,
                          INPUT par_idorigem,
                          INPUT par_nmdatela,
                          INPUT par_flgerlog,
                          OUTPUT TABLE tt-seguros,
                          OUTPUT aux_qtsegass,
                          OUTPUT aux_vltotseg,
                          OUTPUT TABLE tt-erro).

        RUN buscar_proposta_seguro (INPUT par_cdcooper,
                                    INPUT 0,
                                    INPUT 0,
                                    INPUT par_cdoperad,
                                    INPUT par_dtmvtolt,
                                    INPUT par_nrdconta,
                                    INPUT 1,
                                    INPUT 1,
                                    INPUT par_nmdatela,
                                    INPUT FALSE,
                                    OUTPUT TABLE tt-prop-seguros,
                                    OUTPUT aux_qtsegass,
                                    OUTPUT aux_vltotseg,
                                    OUTPUT TABLE tt-erro).

       FOR EACH  tt-seguros                     WHERE
           tt-seguros.cdcooper = par_cdcooper   AND
           tt-seguros.nrdconta = par_nrdconta   AND
           tt-seguros.tpseguro = 3              AND 
           tt-seguros.dtcancel = ?              AND
           tt-seguros.cdsitseg = 1 :
           
          FIND tt-prop-seguros                                 WHERE 
               tt-prop-seguros.cdcooper = par_cdcooper          AND
               tt-prop-seguros.nrdconta = tt-seguros.nrdconta   AND
               tt-prop-seguros.nrctrseg = tt-seguros.nrctrseg 
                                      NO-LOCK NO-ERROR.

           IF AVAIL tt-prop-seguros THEN 
               DO:
                  IF tt-prop-seguros.nmdsegur = par_nmdsegur THEN
                      DO:
                          ASSIGN aux_cdcritic = 648.
                          LEAVE valida.
                      END.
                END.
                
       END.
           
       IF NOT CAN-FIND (tt-seguros) THEN 
           RETURN "OK".
    END.

    EMPTY TEMP-TABLE tt-erro.

    IF  aux_cdcritic <> 0    OR
        aux_dscritic <> ""   THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF   par_flgerlog  THEN
                RUN proc_gerar_log (INPUT  par_cdcooper,
                                    INPUT  par_cdoperad,
                                    INPUT  aux_dscritic,
                                    INPUT  aux_dsorigem,
                                    INPUT  aux_dstransa,
                                    INPUT  FALSE,
                                    INPUT  par_idseqttl,
                                    INPUT  par_nmdatela,
                                    INPUT  par_nrdconta,
                                    OUTPUT aux_nrdrowid).   
            
            RETURN "NOK".
        END.

            
    IF  par_flgerlog  THEN
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

    RETURN "OK".
END PROCEDURE.

PROCEDURE validar_plano_seguro:
    DEF INPUT PARAM par_cdcooper AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                       NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                       NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                       NO-UNDO. 
    DEF INPUT PARAM par_nmdatela AS CHAR                       NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                       NO-UNDO.
    DEF INPUT PARAM par_cdsitpsg LIKE craptsg.cdsitpsg         NO-UNDO.
    DEF INPUT PARAM par_vlplaseg LIKE craptsg.vlplaseg         NO-UNDO.
    DEF INPUT PARAM par_vlmorada LIKE craptsg.vlmorada         NO-UNDO.
    DEF INPUT PARAM par_vlpreseg LIKE crapseg.vlpreseg         NO-UNDO.
    DEF INPUT PARAM par_vlcapseg LIKE craptsg.vlmorada         NO-UNDO.

    DEF OUTPUT PARAM par_nmdcampo AS CHAR                      NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0.

    EMPTY TEMP-TABLE tt-erro.

    IF par_cdsitpsg <> 1 THEN
       ASSIGN aux_cdcritic = 206.
    ELSE
     IF  par_vlplaseg <> par_vlpreseg THEN
        DO: 
            ASSIGN aux_cdcritic = 269.
            ASSIGN par_nmdcampo = "seg_vlpreseg".
        END. 
    ELSE
     IF  par_vlmorada <> par_vlcapseg THEN
        DO: 
            ASSIGN aux_cdcritic = 269.
            ASSIGN par_nmdcampo = "seg_vlcapseg".
        END.
   
         
    EMPTY TEMP-TABLE tt-erro.

    IF  aux_cdcritic <> 0    OR
        aux_dscritic <> ""   THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF   par_flgerlog  THEN
                RUN proc_gerar_log (INPUT  par_cdcooper,
                                    INPUT  par_cdoperad,
                                    INPUT  aux_dscritic,
                                    INPUT  aux_dsorigem,
                                    INPUT  aux_dstransa,
                                    INPUT  FALSE,
                                    INPUT  par_idseqttl,
                                    INPUT  par_nmdatela,
                                    INPUT  par_nrdconta,
                                    OUTPUT aux_nrdrowid).   
            
            RETURN "NOK".
        END.

            
    IF  par_flgerlog  THEN
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

    RETURN "OK".
END PROCEDURE.

PROCEDURE imprimir_termo_cancelamento:
    DEF INPUT PARAM par_cdcooper AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                       NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                       NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_nrctrseg LIKE crapseg.nrctrseg         NO-UNDO.
    DEF INPUT PARAM par_tpseguro LIKE crapseg.tpseguro         NO-UNDO.    
    DEF INPUT PARAM par_idseqttl AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                       NO-UNDO. 
    DEF INPUT PARAM par_nmdatela AS CHAR                       NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                       NO-UNDO.
    DEF INPUT PARAM par_nmendter AS CHAR FORMAT "x(20)"        NO-UNDO.

    DEF OUTPUT PARAM aux_nmarqimp AS CHAR                      NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                      NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador AS INT                                NO-UNDO.
    DEF VAR aux_nmarquiv AS CHAR                               NO-UNDO.
    DEF VAR aux_nmarqpdf AS CHAR                               NO-UNDO.
    DEF VAR aux_vltotseg AS DECI                               NO-UNDO.
    DEF VAR rel_dstipseg AS CHAR                               NO-UNDO.
    DEF VAR rel_dsseguro AS CHAR                               NO-UNDO.
    DEF VAR rel_nmresseg AS CHAR                               NO-UNDO.
    DEF VAR rel_nrctrseg AS INT                                NO-UNDO.
    DEF VAR rel_cdcalcul AS INT                                NO-UNDO.
    DEF VAR rel_tpplaseg AS INT                                NO-UNDO.
    DEF VAR rel_vlpreseg AS DECIMAL                            NO-UNDO.
    DEF VAR rel_vlcobert AS DECIMAL                            NO-UNDO.
    DEF VAR rel_dsbemseg AS CHAR    EXTENT 5                   NO-UNDO.
    DEF VAR rel_nrcpfcgc AS CHAR                               NO-UNDO.
    DEF VAR rel_nmbenefi AS CHAR    EXTENT 5                   NO-UNDO.
    DEF VAR rel_dsgraupr AS CHAR    EXTENT 5                   NO-UNDO.
    DEF VAR rel_txpartic AS DECIMAL EXTENT 5                   NO-UNDO.
    DEF VAR rel_dtinivig AS DATE                               NO-UNDO.
    DEF VAR rel_dtfimvig AS DATE                               NO-UNDO.
    DEF VAR aux_dsmesref AS CHAR                               NO-UNDO.
    DEF VAR aux_dsmotcan AS CHARACTER FORMAT "x(40)"           NO-UNDO.
    DEF VAR aux-numrvias AS INT                                NO-UNDO.
    DEF VAR aux_qtsegass    AS INTE                            NO-UNDO.

    FORM "\022\024\033\120\0332\033x0" WITH NO-BOX NO-LABELS FRAME f_config.

    FORM SKIP(1)
         "\033\016      CANCELAMENTO DE PLANO DE\024"
         SKIP(4)
         "\033\016" rel_dsseguro AT 13 FORMAT "x(25)" "\024"    
         SKIP(4)
         "PELA PRESENTE,  SOLICITO O CANCELAMENTO DO SEGURO ABAIXO DESCRITO,"
         "ONDE  A" SKIP
         tt-cooperativa.nmextcop FORMAT "x(50)"
         "CONSTA COMO ESTIPULANTE." SKIP(1)
         "SOLICITO AINDA O CANCELAMENTO DO RESPECTIVO DEBITO EM CONTA CORRENTE."
         SKIP(1)
         "TIPO DE SEGURO"
         "SEGURADORA" AT 41
         SKIP(1)
         "\033\105"
         rel_dstipseg AT  1 FORMAT "x(20)"
         rel_nmresseg AT 41 FORMAT "x(30)"
         "\033\106"
         SKIP(1)
         "PROPOSTA    PLANO   DIA          PARCELA  NUMERO DA APOLICE"
         SKIP(1)
         rel_nrctrseg AT  1 FORMAT "zz,zzz,zz9"
         rel_tpplaseg AT 15 FORMAT "999"
         rel_ddvencto AT 22 FORMAT "99"
         rel_vlpreseg AT 27 FORMAT "zzz,zzz,zz9.99"
         "___________________________" AT 43
         SKIP(1)
         WITH COLUMN 5 NO-LABELS WIDTH 132 FRAME f_cancelamento_1.
    
    FORM SKIP(1)
         "\033\016      CANCELAMENTO DE PLANO DE\024"
         SKIP(4)
         "\033\016" rel_dsseguro AT 13 FORMAT "x(25)" "\024"    
         SKIP(4)
         "PELA PRESENTE,  SOLICITO O CANCELAMENTO DO SEGURO ABAIXO DESCRITO,"
         "ONDE  A" SKIP
         tt-cooperativa.nmextcop FORMAT "x(50)"
         "CONSTA COMO ESTIPULANTE." SKIP(1)
         "SOLICITO AINDA O CANCELAMENTO DO RESPECTIVO DEBITO EM CONTA CORRENTE."
         SKIP(1)
         "TIPO DE SEGURO"
         "SEGURADORA" AT 41
         SKIP(1)
         "\033\105"
         rel_dstipseg AT  1 FORMAT "x(20)"
         rel_nmresseg AT 41 FORMAT "x(30)"
         "\033\106"
         SKIP(1)
         "PROPOSTA    PLANO   DIA          PARCELA  MOTIVO"
         SKIP(1)
         rel_nrctrseg AT  1 FORMAT "zz,zzz,zz9"
         rel_tpplaseg AT 15 FORMAT "999"
         rel_ddvencto AT 22 FORMAT "99"
         rel_vlpreseg AT 27 FORMAT "zzz,zzz,zz9.99"
         aux_dsmotcan AT 43
         SKIP(1)
         WITH COLUMN 5 NO-LABELS WIDTH 132 FRAME f_cancelamento_1_casa.
         
    FORM SKIP(1)
         "\033\016      CANCELAMENTO DE PLANO DE\024"
         SKIP(4)
         "\033\016" rel_dsseguro AT 13 FORMAT "x(25)" "\024"
         SKIP(4)
         "PELA PRESENTE,  SOLICITO O CANCELAMENTO DO SEGURO ABAIXO DESCRITO,"
         "ONDE  A" SKIP
         tt-cooperativa.nmextcop FORMAT "x(50)"
         "CONSTA COMO ESTIPULANTE." SKIP(1)
         "SOLICITO AINDA O CANCELAMENTO  DO  RESPECTIVO  DEBITO  EM  CONTA "
                      "CORRENTE."
         SKIP(1)
         "TIPO DE SEGURO"
         "SEGURADORA" AT 41
         SKIP(1)
         "\033\105"
         rel_dstipseg AT  1 FORMAT "x(20)"
         rel_nmresseg AT 41 FORMAT "x(30)"
         "\033\106"
         SKIP(1)
         "PROPOSTA    PLANO   DIA          PARCELA  MOTIVO"
         SKIP(1)
         rel_nrctrseg AT  1 FORMAT "zz,zzz,zz9"
         rel_tpplaseg AT 15 FORMAT "999"
         rel_ddvencto AT 22 FORMAT "99"
         rel_vlpreseg AT 27 FORMAT "zzz,zzz,zz9.99"
         aux_dsmotcan AT 43
         SKIP(1)
         WITH COLUMN 5 NO-LABELS WIDTH 132 FRAME f_canc_debito.     
         
    FORM SKIP(2)
         rel_dsmvtolt    AT  1 FORMAT "x(40)"
         SKIP(6)
         "----------------------------------------" SKIP
         rel_nmdsegur    AT  1 FORMAT "x(40)"  SKIP
         rel_nrdconta[1]    AT  1 FORMAT "zzzz,zzz,9"
         rel_nrcpfcgc    AT 23 FORMAT "x(18)"
         SKIP(7)
         "----------------------------------------" SKIP
         crapope.nmoperad    AT  1 FORMAT "x(40)"  SKIP
         "Operador"      AT  1
         SKIP(2)
         WITH COLUMN 5 NO-LABELS WIDTH 132 FRAME f_cancelamento_2.
    
    FORM SKIP(1)
         "\033\016      CANCELAMENTO DE PLANO DE\024"
         SKIP(4)
         "\033\016" rel_dsseguro AT 13 FORMAT "x(25)" "\024"
         SKIP(4)
         "PELA PRESENTE SOLICITO O CANCELAMENTO DO SEGURO ABAIXO DESCRITO, "
         "ONDE  A" SKIP
         tt-cooperativa.nmextcop FORMAT "x(50)"
         "CONSTA COMO ESTIPULANTE." SKIP(1)
         "TIPO DE SEGURO"
         "SEGURADORA" AT 43
         SKIP(1)
         rel_dstipseg AT  1 FORMAT "x(20)"
         rel_nmresseg AT 43 FORMAT "x(30)"
         SKIP(1)
         rel_prestami AT 1 FORMAT "x(70)"
         SKIP(1)
         "PROPOSTA    PLANO   DIA    PREMIO MENSAL  VALOR DA COBERTURA"
         SKIP(1)
         rel_nrctrseg AT  1 FORMAT "zz,zzz,zz9"
         rel_tpplaseg AT 15 FORMAT "999"
         rel_ddvencto AT 22 FORMAT "99"
         rel_vlpreseg AT 27 FORMAT "zzz,zzz,zz9.99"
         rel_vlcobert AT 47 FORMAT "zzz,zzz,zz9.99"
         SKIP(1)
         "BENEFICIARIO"
         "GRAU DE PARENTESCO" AT 42
         "% PARTIC." AT 63
         SKIP(1)
         rel_nmbenefi[1]    FORMAT "x(040)"
         rel_dsgraupr[1]    FORMAT "x(020)"
         rel_txpartic[1]    FORMAT "zz9.99"
         SKIP
         rel_nmbenefi[2]    FORMAT "x(040)"
         rel_dsgraupr[2]    FORMAT "x(020)"
         rel_txpartic[2]    FORMAT "zz9.99"
         SKIP
         rel_nmbenefi[3]    FORMAT "x(040)"
         rel_dsgraupr[3]    FORMAT "x(020)"
         rel_txpartic[3]    FORMAT "zz9.99"
         SKIP
         rel_nmbenefi[4]    FORMAT "x(040)"
         rel_dsgraupr[4]    FORMAT "x(020)"
         rel_txpartic[4]    FORMAT "zz9.99"
         SKIP
         rel_nmbenefi[5]    FORMAT "x(040)"
         rel_dsgraupr[5]    FORMAT "x(020)"
         rel_txpartic[5]    FORMAT "zz9.99"
         SKIP(3)
         rel_dsmvtolt    AT  1 FORMAT "x(40)"
         SKIP(6)
         "----------------------------------------" SKIP
         rel_nmdsegur    AT  1 FORMAT "x(40)"  SKIP
         rel_nrdconta[1]    AT  1 FORMAT "zzzz,zzz,9"
         rel_nrcpfcgc    AT 27 FORMAT "x(14)"
         SKIP(7)
         "----------------------------------------" SKIP
         crapope.nmoperad    AT  1 FORMAT "x(40)"  SKIP
         "Operador"      AT  1
         SKIP(2)
         WITH COLUMN 5 NO-LABELS WIDTH 132 FRAME f_cancel_vida.
    
    FORM " Aguarde... Imprimindo CANCELAMENTO DE SEGURO! "
         WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.
    
    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_dsmesref = "JANEIRO,FEVEREIRO,MARCO,ABRIL,MAIO,JUNHO," +
                          "JULHO,AGOSTO,SETEMBRO,OUTUBRO,NOVEMBRO,DEZEMBRO".

    EMPTY TEMP-TABLE tt-erro.

    impressao:
    DO:
        RUN busca_seguros(INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT par_cdoperad,
                          INPUT par_dtmvtolt,
                          INPUT par_nrdconta,
                          INPUT par_idseqttl,
                          INPUT par_idorigem,
                          INPUT par_nmdatela,
                          INPUT par_flgerlog,
                          OUTPUT TABLE tt-seguros,
                          OUTPUT aux_qtsegass,
                          OUTPUT aux_vltotseg,
                          OUTPUT TABLE tt-erro).

        IF   RETURN-VALUE <> "OK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                IF   AVAIL tt-erro   THEN
                    DO:
                        ASSIGN aux_dscritic = tt-erro.dscritic
                               aux_cdcritic = tt-erro.cdcritic.
                        LEAVE impressao.
                    END.
            END.

        FIND FIRST tt-seguros WHERE
                   tt-seguros.cdcooper = par_cdcooper  AND
                   tt-seguros.nrdconta = par_nrdconta  AND
                   tt-seguros.tpseguro = par_tpseguro  AND
                   tt-seguros.nrctrseg = par_nrctrseg  NO-ERROR.
        
        IF   NOT AVAILABLE tt-seguros  THEN
            DO:
                aux_cdcritic = 524.
                LEAVE impressao.
            END.

        IF  tt-seguros.cdsitseg = 3 OR
            tt-seguros.cdsitseg = 4 THEN
            LEAVE impressao.

        RUN buscar_associados (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT par_cdoperad,
                               INPUT par_dtmvtolt,
                               INPUT par_nrdconta,
                               INPUT par_idseqttl,
                               INPUT par_idorigem,
                               INPUT par_nmdatela,
                               INPUT par_flgerlog,
                               OUTPUT TABLE tt-associado,
                               OUTPUT TABLE tt-erro).

        IF   RETURN-VALUE <> "OK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                IF   AVAIL tt-erro   THEN
                    DO:
                        ASSIGN aux_dscritic = tt-erro.dscritic
                               aux_cdcritic = tt-erro.cdcritic.
                        LEAVE impressao.
                    END.
            END.

        FIND FIRST tt-associado                                 WHERE
                   tt-associado.cdcooper = par_cdcooper         AND
                   tt-associado.nrdconta = tt-seguros.nrdconta  NO-ERROR.

        RUN buscar_seguradora(INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT par_cdoperad,
                              INPUT par_dtmvtolt,
                              INPUT par_nrdconta,
                              INPUT par_idseqttl,
                              INPUT par_idorigem,
                              INPUT par_nmdatela,
                              INPUT par_flgerlog,
                              INPUT tt-seguros.tpseguro,
                              INPUT 0,
                              INPUT tt-seguros.cdsegura,
                              INPUT "",
                              OUTPUT aux_qtregist,
                              OUTPUT TABLE tt-seguradora,
                              OUTPUT TABLE tt-erro).

        IF   RETURN-VALUE <> "OK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                IF   AVAIL tt-erro   THEN
                    DO:
                        ASSIGN aux_dscritic = tt-erro.dscritic
                               aux_cdcritic = tt-erro.cdcritic.
                        LEAVE impressao.
                    END.
            END.

        FIND FIRST tt-seguradora WHERE
                   tt-seguradora.cdcooper = par_cdcooper        AND
                   tt-seguradora.cdsegura = tt-seguros.cdsegura NO-ERROR.

        IF   NOT AVAILABLE tt-seguradora   THEN
            ASSIGN rel_nmresseg = "NAO CADASTRADA".
        ELSE
            ASSIGN rel_nmresseg = tt-seguradora.nmresseg.

        IF   tt-seguros.tpseguro = 4 THEN
           ASSIGN rel_prestami = "".
        ELSE
           ASSIGN rel_prestami = "SOLICITO AINDA O CANCELAMENTO DO RESPECTIVO DEBITO EM CONTA CORRENTE.".


        IF  tt-seguros.tpseguro = 3 OR tt-seguros.tpseguro = 4  THEN
            DO:
                ASSIGN rel_nmbenefi[1] = tt-seguros.nmbenvid[1] 
                       rel_nmbenefi[2] = tt-seguros.nmbenvid[2] 
                       rel_nmbenefi[3] = tt-seguros.nmbenvid[3] 
                       rel_nmbenefi[4] = tt-seguros.nmbenvid[4] 
                       rel_nmbenefi[5] = tt-seguros.nmbenvid[5] 
                       rel_dsgraupr[1] = tt-seguros.dsgraupr[1] 
                       rel_dsgraupr[2] = tt-seguros.dsgraupr[2] 
                       rel_dsgraupr[3] = tt-seguros.dsgraupr[3] 
                       rel_dsgraupr[4] = tt-seguros.dsgraupr[4] 
                       rel_dsgraupr[5] = tt-seguros.dsgraupr[5] 
                       rel_txpartic[1] = tt-seguros.txpartic[1] 
                       rel_txpartic[2] = tt-seguros.txpartic[2] 
                       rel_txpartic[3] = tt-seguros.txpartic[3] 
                       rel_txpartic[4] = tt-seguros.txpartic[4] 
                       rel_txpartic[5] = tt-seguros.txpartic[5].

                RUN buscar_plano_seguro (INPUT  par_cdcooper,
                                         INPUT  par_cdagenci,
                                         INPUT  par_nrdcaixa,
                                         INPUT  par_cdoperad,
                                         INPUT  par_dtmvtolt,
                                         INPUT  par_nrdconta,
                                         INPUT  par_idseqttl,
                                         INPUT  par_idorigem,
                                         INPUT  par_nmdatela,
                                         INPUT  par_flgerlog,
                                         INPUT  tt-seguros.cdsegura,
                                         INPUT  tt-seguros.tpseguro,
                                         INPUT  tt-seguros.tpplaseg,
                                         OUTPUT TABLE tt-plano-seg,
                                         OUTPUT TABLE tt-erro).

                ASSIGN aux_dscritic = ""
                       aux_cdcritic = 0.

                FIND tt-plano-seg NO-ERROR.
                IF  AVAIL tt-plano-seg  THEN
                    ASSIGN rel_vlcobert = tt-plano-seg.vlmorada.
                ELSE
                    ASSIGN rel_vlcobert = 0.
            END. /* IF  tt-seguros.tpseguro = 3 OR 4  THEN */

        RUN buscar_cooperativa (INPUT par_cdcooper,
                                INPUT par_cdagenci,
                                INPUT par_nrdcaixa,
                                INPUT par_cdoperad,
                                INPUT par_dtmvtolt,
                                INPUT par_nrdconta,
                                INPUT par_idseqttl,
                                INPUT par_idorigem,
                                INPUT par_nmdatela,
                                INPUT par_flgerlog,
                                OUTPUT TABLE tt-cooperativa,
                                OUTPUT TABLE tt-erro).

        IF  RETURN-VALUE <> "OK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                IF   AVAIL tt-erro   THEN
                    DO:
                        ASSIGN aux_cdcritic = tt-erro.cdcritic
                               aux_dscritic = tt-erro.dscritic.
                        EMPTY TEMP-TABLE tt-erro.
                        LEAVE impressao.
                    END.
            END.

        FIND FIRST tt-cooperativa WHERE
                   tt-cooperativa.cdcooper = par_cdcooper  NO-ERROR.

        ASSIGN rel_dsseguro = IF (tt-seguros.tpseguro = 1 OR
                                  tt-seguros.tpseguro = 11)
                              THEN "SEGURO RESIDENCIAL"
                              ELSE
                              IF tt-seguros.tpseguro = 3 
                              THEN "SEGURO DE VIDA"
                              ELSE "SEGURO PRESTAMISTA"
               rel_dstipseg = rel_dsseguro
               rel_nrctrseg = tt-seguros.nrctrseg
               rel_tpplaseg = tt-seguros.tpplaseg
               rel_ddvencto = DAY(tt-seguros.dtdebito)
               rel_vlpreseg = tt-seguros.vlpreseg
               rel_nrdconta[1] = tt-seguros.nrdconta
               rel_nmdsegur = tt-associado.nmprimtl
               rel_dsmvtolt = TRIM(tt-cooperativa.nmcidade) + ", " +
                              STRING(DAY(par_dtmvtolt)) + " DE " +
                              CAPS(ENTRY(MONTH(par_dtmvtolt),aux_dsmesref))
                              + " DE " +
                              STRING(YEAR(par_dtmvtolt)) + ".".

        ASSIGN aux_dsmotcan = tt-seguros.dsmotcan.
            
        RUN buscar_proposta_seguro(INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT par_cdoperad,
                                   INPUT par_dtmvtolt,
                                   INPUT par_nrdconta,
                                   INPUT par_idseqttl,
                                   INPUT par_idorigem,
                                   INPUT par_nmdatela,
                                   INPUT par_flgerlog,
                                   OUTPUT TABLE tt-prop-seguros,
                                   OUTPUT aux_qtsegass,
                                   OUTPUT aux_vltotseg,
                                   OUTPUT TABLE tt-erro).

        IF   RETURN-VALUE <> "OK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                IF   AVAIL tt-erro   THEN
                    DO:
                        ASSIGN aux_dscritic = tt-erro.dscritic
                               aux_cdcritic = tt-erro.cdcritic.
                        LEAVE impressao.
                    END.
            END.

        FIND FIRST tt-prop-seguros WHERE
                   tt-prop-seguros.cdcooper = par_cdcooper         AND
                   tt-prop-seguros.nrdconta = tt-seguros.nrdconta  AND
                   tt-prop-seguros.nrctrseg = tt-seguros.nrctrseg
            NO-ERROR.

        IF   NOT AVAILABLE tt-prop-seguros THEN
            ASSIGN rel_nrcpfcgc = ""
                   rel_dsbemseg = FILL("_",80).
        ELSE
            DO:
                ASSIGN rel_nrcpfcgc = tt-prop-seguros.nrcpfcgc
                       rel_nmdsegur = tt-prop-seguros.nmdsegur.

                IF   (tt-prop-seguros.tpseguro = 1 OR
                      tt-prop-seguros.tpseguro = 11 ) THEN
                    ASSIGN rel_dsseguro    = "SEGURO RESIDENCIAL"
                           rel_dsbemseg[1] = "RESIDENCIA LOCALIZADA A RUA ..."
                           rel_dsbemseg[2] = ""
                           rel_dsbemseg[3] = "".
                ELSE
                    IF   tt-prop-seguros.tpseguro = 3 THEN
                        ASSIGN rel_dsseguro    = "SEGURO DE VIDA"
                               rel_dsbemseg[1] = " "
                               rel_dsbemseg[2] = " ".
                    ELSE
                        ASSIGN rel_dsseguro    = "SEGURO PRESTAMISTA"
                               rel_dsbemseg[1] = " "
                               rel_dsbemseg[2] = " ".
            END.

        ASSIGN aux_nmarquiv = "/usr/coop/" + tt-cooperativa.dsdircop +
                              "/rl/" + par_nmendter.

        UNIX SILENT VALUE("rm " + aux_nmarquiv + "* 2> /dev/null").

        ASSIGN aux_nmarquiv = aux_nmarquiv + STRING(TIME)
               aux_nmarqimp = aux_nmarquiv + ".ex"
               aux_nmarqpdf = aux_nmarquiv + ".pdf".

        /*numero de vias*/
        IF tt-seguros.tpseguro = 3 THEN
            ASSIGN aux-numrvias = 3.
        ELSE
            ASSIGN aux-numrvias = 2.

        OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

        DO aux_contador = 1 TO aux-numrvias:

            IF aux_contador > 1 THEN
                PAGE STREAM str_1.

            VIEW STREAM str_1 FRAME f_config.
    
            FIND FIRST crapope NO-LOCK           WHERE
                 crapope.cdcooper = par_cdcooper AND 
                 crapope.cdoperad = par_cdoperad NO-ERROR.
    
            IF tt-seguros.tpseguro = 3 OR tt-seguros.tpseguro = 4 THEN DO:
                DISPLAY STREAM str_1
                        rel_dsseguro rel_dstipseg rel_nmresseg rel_prestami 
                        rel_nrctrseg rel_tpplaseg rel_ddvencto rel_vlpreseg 
                        rel_vlcobert rel_dsmvtolt rel_nmdsegur 
                        tt-cooperativa.nmextcop rel_nrdconta[1]
                        rel_nrcpfcgc crapope.nmoperad
                        rel_nmbenefi[1] rel_dsgraupr[1] rel_txpartic[1]
                                        WHEN rel_txpartic[1] > 0
                        rel_nmbenefi[2] rel_dsgraupr[2] rel_txpartic[2]
                                        WHEN rel_txpartic[2] > 0
                        rel_nmbenefi[3] rel_dsgraupr[3] rel_txpartic[3]
                                        WHEN rel_txpartic[3] > 0
                        rel_nmbenefi[4] rel_dsgraupr[4] rel_txpartic[4]
                                        WHEN rel_txpartic[4] > 0
                        rel_nmbenefi[5] rel_dsgraupr[5] rel_txpartic[5]
                                        WHEN rel_txpartic[5] > 0
                         WITH FRAME f_cancel_vida.
            END.
            ELSE
                DO:
                     IF   tt-seguros.tpseguro   = 11 THEN 
                         DO:
                              IF DAY(par_dtmvtolt) >= 5                           AND
                                 DAY(par_dtmvtolt) <= DAY(tt-seguros.dtdebito)    THEN       
                                    DISPLAY STREAM str_1
                                          rel_dsseguro rel_dstipseg rel_nmresseg rel_nrctrseg
                                          rel_tpplaseg rel_ddvencto rel_vlpreseg tt-cooperativa.nmextcop
                                          tt-seguros.dtdebito tt-seguros.vlpreseg 
                                          WITH FRAME f_canc_debito. 
                              ELSE 
                                  DISPLAY STREAM str_1
                                        rel_dsseguro rel_dstipseg rel_nmresseg
                                        rel_nrctrseg rel_tpplaseg rel_ddvencto
                                        rel_vlpreseg tt-cooperativa.nmextcop
                                        aux_dsmotcan
                                        WITH FRAME f_cancelamento_1_casa.
                         END.
                     ELSE 
                         DISPLAY STREAM str_1
                              rel_dsseguro rel_dstipseg rel_nmresseg
                              rel_nrctrseg rel_tpplaseg rel_ddvencto
                              rel_vlpreseg tt-cooperativa.nmextcop
                              WITH FRAME f_cancelamento_1.

                    IF tt-seguros.tpseguro <> 11   THEN
                        DISPLAY STREAM str_1 "BEM SEGURADO:" AT  1
                                SKIP(1)
                                rel_dsbemseg[1] AT  1 FORMAT "x(73)" SKIP
                                rel_dsbemseg[2] AT  1 FORMAT "x(73)" SKIP
                                rel_dsbemseg[3] AT  1 FORMAT "x(73)" SKIP
                                rel_dsbemseg[4] AT  1 FORMAT "x(73)" SKIP
                                rel_dsbemseg[5] AT  1 FORMAT "x(73)" 
                                WITH COLUMN 5 NO-LABELS WIDTH 132.
                    
                    DISPLAY STREAM str_1
                            rel_dsmvtolt rel_nmdsegur rel_nrdconta[1]
                            rel_nrcpfcgc crapope.nmoperad
                            WITH FRAME f_cancelamento_2.
                END.
        END. /* DO i-cont = 1 TO aux-numrvias */
        OUTPUT STREAM str_1 CLOSE.

        RUN sistema/generico/procedures/b1wgen0024.p
            PERSISTENT SET h-b1wgen0024.

        RUN gera-pdf-impressao IN h-b1wgen0024 (INPUT aux_nmarqimp,
                                                INPUT aux_nmarqpdf).

        DELETE PROCEDURE h-b1wgen0024.

        /** Copiar pdf para visualizacao no Ayllos WEB **/
        IF  par_idorigem = 5  THEN
            DO:
                IF  SEARCH(aux_nmarqpdf) = ?  THEN
                    DO:
                        ASSIGN aux_dscritic = "Nao foi possivel " +
                                              "gerar a impressao.".
                        LEAVE impressao.
                    END.

                UNIX SILENT VALUE ('sudo /usr/bin/su - scpuser -c ' +
                '"scp ' + aux_nmarqpdf + ' scpuser@' + aux_srvintra +
                ':/var/www/ayllos/documentos/' + tt-cooperativa.dsdircop +
                '/temp/" 2>/dev/null').
            END.

        IF  par_idorigem = 5  THEN
            UNIX SILENT VALUE ("rm " + aux_nmarquiv + "* 2>/dev/null").
        ELSE
            UNIX SILENT VALUE ("rm " + aux_nmarqpdf + " 2>/dev/null").

        ASSIGN par_nmarqpdf =
            ENTRY(NUM-ENTRIES(aux_nmarqpdf,"/"),aux_nmarqpdf,"/").
    END. /* impressao */

    EMPTY TEMP-TABLE tt-erro.

    IF  aux_cdcritic <> 0    OR
        aux_dscritic <> ""   THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF   par_flgerlog  THEN
                RUN proc_gerar_log (INPUT  par_cdcooper,
                                    INPUT  par_cdoperad,
                                    INPUT  aux_dscritic,
                                    INPUT  aux_dsorigem,
                                    INPUT  aux_dstransa,
                                    INPUT  FALSE,
                                    INPUT  par_idseqttl,
                                    INPUT  par_nmdatela,
                                    INPUT  par_nrdconta,
                                    OUTPUT aux_nrdrowid).   
            
            RETURN "NOK".
        END.

            
    IF  par_flgerlog  THEN
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

    RETURN "OK".
END PROCEDURE.

PROCEDURE buscar_situacao_proposta:
    DEF INPUT PARAM par_cdcooper AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                       NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                       NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                       NO-UNDO. 
    DEF INPUT PARAM par_nmdatela AS CHAR                       NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                       NO-UNDO.
    DEF INPUT PARAM par_nrctrseg LIKE crapseg.nrctrseg         NO-UNDO.
    DEF INPUT PARAM par_tpseguro LIKE craptsg.tpseguro         NO-UNDO.

    DEF OUTPUT PARAM par_cdsitseg LIKE crapseg.cdsitseg        NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_qtsegass AS INTE                               NO-UNDO.
    DEF VAR aux_vltotseg AS DECI                               NO-UNDO.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0.

    EMPTY TEMP-TABLE tt-erro.

    valida:
    DO:
        EMPTY TEMP-TABLE tt-seguros.

        RUN busca_seguros (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT par_cdoperad,
                           INPUT par_dtmvtolt,
                           INPUT par_nrdconta,
                           INPUT par_idseqttl,
                           INPUT par_idorigem,
                           INPUT par_nmdatela,
                           INPUT par_flgerlog,
                           OUTPUT TABLE tt-seguros,
                           OUTPUT aux_qtsegass,
                           OUTPUT aux_vltotseg,
                           OUTPUT TABLE tt-erro).

        IF   RETURN-VALUE <> "OK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                IF   AVAIL tt-erro   THEN
                    DO:
                        ASSIGN aux_cdcritic = tt-erro.cdcritic
                               aux_dscritic = tt-erro.dscritic.
                        EMPTY TEMP-TABLE tt-erro.
                        LEAVE valida.
                    END.
            END.

        FIND FIRST tt-seguros                           WHERE
                   tt-seguros.cdcooper = par_cdcooper   AND
                   tt-seguros.nrdconta = par_nrdconta   AND
                   tt-seguros.tpseguro = par_tpseguro   AND
                   tt-seguros.nrctrseg = par_nrctrseg   NO-ERROR.
        IF NOT AVAIL tt-seguros THEN
            DO:
                ASSIGN aux_dscritic = "Seguro nao encontrado.".
                LEAVE valida.
            END.

        ASSIGN par_cdsitseg = tt-seguros.cdsitseg.
    END.

    EMPTY TEMP-TABLE tt-erro.

    IF  aux_cdcritic <> 0    OR
        aux_dscritic <> ""   THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF   par_flgerlog  THEN
                RUN proc_gerar_log (INPUT  par_cdcooper,
                                    INPUT  par_cdoperad,
                                    INPUT  aux_dscritic,
                                    INPUT  aux_dsorigem,
                                    INPUT  aux_dstransa,
                                    INPUT  FALSE,
                                    INPUT  par_idseqttl,
                                    INPUT  par_nmdatela,
                                    INPUT  par_nrdconta,
                                    OUTPUT aux_nrdrowid).   
            
            RETURN "NOK".
        END.

            
    IF  par_flgerlog  THEN
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

    RETURN "OK".
END PROCEDURE.

PROCEDURE valida_existe_plano_seg:
    DEF INPUT PARAM par_cdcooper AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                       NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                       NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                       NO-UNDO. 
    DEF INPUT PARAM par_nmdatela AS CHAR                       NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                       NO-UNDO.
    DEF INPUT PARAM par_cdsegura LIKE crapseg.cdsegura         NO-UNDO.    
    DEF INPUT PARAM par_tpseguro LIKE craptsg.tpseguro         NO-UNDO.
    DEF INPUT PARAM par_tpplaseg LIKE craptsg.tpplaseg         NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    FIND craptsg WHERE 
         craptsg.cdcooper = par_cdcooper AND 
         craptsg.cdsegura = par_cdsegura AND 
         craptsg.tpseguro = par_tpseguro AND 
         craptsg.tpplaseg = par_tpplaseg 
         NO-LOCK NO-ERROR.
    IF AVAIL craptsg THEN 
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /** Sequencia **/
                           INPUT 198,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

     RETURN "OK".


END PROCEDURE.

PROCEDURE buscar_plano_seguro:
    DEF INPUT PARAM par_cdcooper AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                       NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                       NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                       NO-UNDO. 
    DEF INPUT PARAM par_nmdatela AS CHAR                       NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                       NO-UNDO.
    DEF INPUT PARAM par_cdsegura LIKE crapseg.cdsegura         NO-UNDO.    
    DEF INPUT PARAM par_tpseguro LIKE craptsg.tpseguro         NO-UNDO.
    DEF INPUT PARAM par_tpplaseg LIKE craptsg.tpplaseg         NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-plano-seg.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0.

    EMPTY TEMP-TABLE tt-plano-seg.

    FOR EACH craptsg NO-LOCK WHERE
        (IF par_cdcooper <> 0 THEN
             craptsg.cdcooper = par_cdcooper
         ELSE TRUE) AND
        (IF par_cdsegura <> 0 THEN
             craptsg.cdsegura = par_cdsegura
         ELSE TRUE) AND
        (IF par_tpseguro <> 0 THEN
             craptsg.tpseguro = par_tpseguro
         ELSE TRUE) AND
        (IF par_tpplaseg <> 0 THEN
             craptsg.tpplaseg = par_tpplaseg
         ELSE TRUE):

        CREATE tt-plano-seg.
        BUFFER-COPY craptsg TO tt-plano-seg.

    END.
    
    IF NOT CAN-FIND(FIRST tt-plano-seg) THEN
       ASSIGN aux_cdcritic = 200.

    EMPTY TEMP-TABLE tt-erro.

    IF  aux_cdcritic <> 0    OR
        aux_dscritic <> ""   THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF   par_flgerlog  THEN
                RUN proc_gerar_log (INPUT  par_cdcooper,
                                    INPUT  par_cdoperad,
                                    INPUT  aux_dscritic,
                                    INPUT  aux_dsorigem,
                                    INPUT  aux_dstransa,
                                    INPUT  FALSE,
                                    INPUT  par_idseqttl,
                                    INPUT  par_nmdatela,
                                    INPUT  par_nrdconta,
                                    OUTPUT aux_nrdrowid).   
            
            RETURN "NOK".
        END.
            
    IF  par_flgerlog  THEN
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

    RETURN "OK".
END PROCEDURE.

PROCEDURE buscar_seguro_geral:
    DEF INPUT PARAM par_cdcooper AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                       NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                       NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                       NO-UNDO. 
    DEF INPUT PARAM par_nmdatela AS CHAR                       NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                       NO-UNDO.
    DEF INPUT PARAM par_cdsegura LIKE crapseg.cdsegura         NO-UNDO.    
    DEF INPUT PARAM par_tpseguro LIKE craptsg.tpseguro         NO-UNDO.
    DEF INPUT PARAM par_nrctrseg LIKE crapseg.nrctrseg         NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-seg-geral.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_qtsegass AS INTE                               NO-UNDO.
    DEF VAR aux_vltotseg AS DECI                               NO-UNDO.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-seg-geral.

    valida:
    DO:
        EMPTY TEMP-TABLE tt-seguros.

        RUN busca_seguros (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT par_cdoperad,
                           INPUT par_dtmvtolt,
                           INPUT par_nrdconta,
                           INPUT par_idseqttl,
                           INPUT par_idorigem,
                           INPUT par_nmdatela,
                           INPUT par_flgerlog,
                           OUTPUT TABLE tt-seguros,
                           OUTPUT aux_qtsegass,
                           OUTPUT aux_vltotseg,
                           OUTPUT TABLE tt-erro).

        IF   RETURN-VALUE <> "OK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                IF   AVAIL tt-erro   THEN
                    DO:
                        ASSIGN aux_cdcritic = tt-erro.cdcritic
                               aux_dscritic = tt-erro.dscritic.
                        EMPTY TEMP-TABLE tt-erro.
                        LEAVE valida.
                    END.
            END.

        FIND FIRST tt-seguros                           WHERE
                   tt-seguros.cdcooper = par_cdcooper   AND
                   tt-seguros.nrdconta = par_nrdconta   AND
                   tt-seguros.tpseguro = par_tpseguro   AND
                   tt-seguros.nrctrseg = par_nrctrseg   NO-ERROR.

        RUN buscar_proposta_seguro(INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT par_cdoperad,
                                   INPUT par_dtmvtolt,
                                   INPUT par_nrdconta,
                                   INPUT par_idseqttl,
                                   INPUT par_idorigem,
                                   INPUT par_nmdatela,
                                   INPUT par_flgerlog,
                                   OUTPUT TABLE tt-prop-seguros,
                                   OUTPUT aux_qtsegass,
                                   OUTPUT aux_vltotseg,
                                   OUTPUT TABLE tt-erro).

        IF   RETURN-VALUE <> "OK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                IF   AVAIL tt-erro   THEN
                    DO:
                        ASSIGN aux_cdcritic = tt-erro.cdcritic
                               aux_dscritic = tt-erro.dscritic.
                        EMPTY TEMP-TABLE tt-erro.
                        LEAVE valida.
                    END.
            END.

        RUN buscar_seguradora(INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT par_cdoperad,
                              INPUT par_dtmvtolt,
                              INPUT par_nrdconta,
                              INPUT par_idseqttl,
                              INPUT par_idorigem,
                              INPUT par_nmdatela,
                              INPUT par_flgerlog,
                              INPUT tt-seguros.tpseguro,
                              INPUT 0,
                              INPUT tt-seguros.cdsegura,
                              INPUT "",
                              OUTPUT aux_qtregist,
                              OUTPUT TABLE tt-seguradora,
                              OUTPUT TABLE tt-erro).

        IF   RETURN-VALUE <> "OK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                IF   AVAIL tt-erro   THEN
                    DO:
                        ASSIGN aux_cdcritic = tt-erro.cdcritic
                               aux_dscritic = tt-erro.dscritic.
                        EMPTY TEMP-TABLE tt-erro.
                        LEAVE valida.
                    END.
            END.

        FIND FIRST tt-seguradora WHERE
                   tt-seguradora.cdcooper = par_cdcooper         AND
                   tt-seguradora.cdsegura = tt-seguros.cdsegura  NO-ERROR.

        CASE par_tpseguro:
            WHEN 11 THEN DO:
                IF NOT AVAIL tt-seguros THEN DO:
                    FIND FIRST tt-prop-seguros WHERE
                           tt-prop-seguros.cdcooper = par_cdcooper  AND
                           tt-prop-seguros.nrdconta = par_nrdconta  AND
                           tt-prop-seguros.nrctrseg = par_nrctrseg  NO-ERROR.

                    IF NOT AVAIL tt-prop-seguros THEN LEAVE valida.

                    CREATE tt-seg-geral.
                    ASSIGN
                     tt-seg-geral.nmresseg = tt-seguradora.nmsegura
                     tt-seg-geral.dstipseg = IF tt-prop-seguros.tpseguro = 11
                                             THEN "CASA"
                                             ELSE ""
                     tt-seg-geral.cdsegura = tt-prop-seguros.cdsegura
                     tt-seg-geral.tpseguro = tt-prop-seguros.tpseguro
                     tt-seg-geral.nrctrseg = tt-prop-seguros.nrctrseg
                     tt-seg-geral.tpplaseg = tt-prop-seguros.tpplaseg
                     tt-seg-geral.ddvencto = DAY(tt-prop-seguros.dtdebito)
                     tt-seg-geral.vlpreseg = tt-prop-seguros.vlpreseg
                     tt-seg-geral.vltotpre = tt-prop-seguros.vlpremio
                     tt-seg-geral.dtinivig = tt-prop-seguros.dtinivig
                     tt-seg-geral.dtfimvig = tt-prop-seguros.dtfimvig
                     tt-seg-geral.dtcancel = ?
                     tt-seg-geral.qtmaxpar = tt-prop-seguros.qtparcel
                     tt-seg-geral.ddpripag = DAY(tt-prop-seguros.dtprideb)
                     tt-seg-geral.dsendres = tt-prop-seguros.dsendres
                     tt-seg-geral.nrendres = tt-prop-seguros.nrendres
                     tt-seg-geral.nmcidade = tt-prop-seguros.nmcidade
                     tt-seg-geral.nmbairro = tt-prop-seguros.nmbairro
                     tt-seg-geral.cdufresd = tt-prop-seguros.cdufresd
                     tt-seg-geral.nrcepend = tt-prop-seguros.nrcepend
                     tt-seg-geral.complend = tt-prop-seguros.complend.

                END. /* not avail tt-seguros */
                ELSE DO: /* avail tt-seguros */
                    FIND tt-prop-seguros WHERE
                         tt-prop-seguros.cdcooper = tt-seguros.cdcooper  AND
                         tt-prop-seguros.nrdconta = tt-seguros.nrdconta  AND
                         tt-prop-seguros.nrctrseg = tt-seguros.nrctrseg  AND
                         tt-prop-seguros.cdsegura = tt-seguros.cdsegura  AND
                         tt-prop-seguros.tpseguro = tt-seguros.tpseguro
                    NO-ERROR.

                    IF NOT AVAILABLE tt-prop-seguros THEN LEAVE valida.

                    FIND tt-seguradora WHERE
                         tt-seguradora.cdcooper = par_cdcooper         AND
                         tt-seguradora.cdsegura = tt-seguros.cdsegura  NO-ERROR.

                    CREATE tt-seg-geral.
                    ASSIGN
                     tt-seg-geral.nmresseg    = tt-seguradora.nmsegura
                     tt-seg-geral.dstipseg    = IF tt-seguros.tpseguro = 11 THEN
                                                   "CASA"
                                               ELSE ""
                     tt-seg-geral.cdsegura    = tt-seguros.cdsegura
                     tt-seg-geral.tpseguro    = tt-seguros.tpseguro
                     tt-seg-geral.nrctrseg    = tt-seguros.nrctrseg
                     tt-seg-geral.dtultalt    = tt-seguros.dtultalt
                     tt-seg-geral.tpplaseg    = tt-seguros.tpplaseg
                     tt-seg-geral.tpendcor    = tt-seguros.tpendcor
                     tt-seg-geral.dtdebito    = tt-seguros.dtdebito
                     tt-seg-geral.dtprideb    = tt-seguros.dtprideb
                     tt-seg-geral.ddvencto    = DAY(tt-seguros.dtdebito)
                     tt-seg-geral.vlpreseg    = tt-seguros.vlpreseg
                     tt-seg-geral.vltotpre    = tt-seguros.vlpremio
                     tt-seg-geral.dtinivig    = tt-seguros.dtinivig
                     tt-seg-geral.dtfimvig    = tt-seguros.dtfimvig
                     tt-seg-geral.dtcancel    = tt-seguros.dtcancel
                     tt-seg-geral.qtmaxpar    = tt-seguros.qtparcel
                     tt-seg-geral.ddpripag    = DAY(tt-seguros.dtprideb)
                     tt-seg-geral.dsendres    = tt-prop-seguros.dsendres
                     tt-seg-geral.nrendres    = tt-prop-seguros.nrendres
                     tt-seg-geral.nmcidade    = tt-prop-seguros.nmcidade
                     tt-seg-geral.nmbairro    = tt-prop-seguros.nmbairro
                     tt-seg-geral.cdufresd    = tt-prop-seguros.cdufresd
                     tt-seg-geral.nrcepend    = tt-prop-seguros.nrcepend
                     tt-seg-geral.complend    = tt-prop-seguros.complend
                     tt-seg-geral.flgclabe    = tt-seguros.flgclabe
                     tt-seg-geral.nmbenvid[1] = tt-seguros.nmbenvid[1]
                     tt-seg-geral.dtultalt    = tt-seguros.dtultalt
                     tt-seg-geral.dtmvtolt    = tt-seguros.dtmvtolt
                     tt-seg-geral.cdmotcan    = tt-seguros.cdmotcan
                     tt-seg-geral.dsmotcan    = tt-seguros.dsmotcan.
                END. /* avail tt-seguros */

                RUN busca_end_cor(INPUT par_cdcooper,
                                  INPUT par_cdagenci,
                                  INPUT par_nrdcaixa,
                                  INPUT par_cdoperad,
                                  INPUT par_dtmvtolt,
                                  INPUT par_nrdconta,
                                  INPUT par_idseqttl,
                                  INPUT par_idorigem,
                                  INPUT par_nmdatela,
                                  INPUT par_flgerlog,
                                  INPUT par_nrctrseg,
                                  INPUT tt-seguros.tpendcor,
                                  OUTPUT TABLE tt_end_cor,
                                  OUTPUT TABLE tt-erro).

                ASSIGN aux_dscritic = ""
                       aux_cdcritic = 0.

                FIND FIRST tt_end_cor NO-ERROR.
                IF AVAIL tt_end_cor   AND
                   AVAIL tt-seg-geral  THEN
                    DO:
                        ASSIGN tt-seg-geral.dsendres_2 = tt_end_cor.dsendres
                               tt-seg-geral.nrendres_2 = tt_end_cor.nrendres
                               tt-seg-geral.nmbairro_2 = tt_end_cor.nmbairro
                               tt-seg-geral.nrcepend_2 = tt_end_cor.nrcepend
                               tt-seg-geral.nmcidade_2 = tt_end_cor.nmcidade
                               tt-seg-geral.cdufresd_2 = tt_end_cor.cdufresd
                               tt-seg-geral.complend_2 = tt_end_cor.complend.
                    END.
            END. /* seguro = 11, casa */
            OTHERWISE DO: /* seguro de vida */

                CREATE tt-seg-geral.

                ASSIGN tt-seg-geral.dsseguro = (IF   par_tpseguro = 1 THEN
                                                   " Seguro Casa "
                                               ELSE
                                               IF   par_tpseguro = 2 THEN
                                                   " Seguro Auto "
                                               ELSE 
                                               IF   par_tpseguro = 3 THEN
                                                   " Seguro Vida "
                                               ELSE " Seguro Prestamista ")    +
                                               TRIM(STRING(tt-seguros.nrctrseg,
                                                   "zz,zzz,zz9")) + " - Dia " +
                                               STRING(DAY(tt-seguros.dtdebito),
                                                      "99") +
                                               " "
                       tt-seg-geral.dspesseg = IF tt-seguros.dtultalt = ? THEN
                                                 STRING(tt-seguros.dtmvtolt,
                                                        "99/99/9999")
                                               ELSE
                                                 STRING(tt-seguros.dtultalt,
                                                        "99/99/9999")
                       tt-seg-geral.vlpreseg = tt-seguros.vlpreseg
                       tt-seg-geral.cdsegura = tt-seguros.cdsegura
                       tt-seg-geral.qtpreseg = tt-seguros.qtprepag
                       tt-seg-geral.vlprepag = tt-seguros.vlprepag
                       tt-seg-geral.dtinivig = tt-seguros.dtinivig
                       tt-seg-geral.dtfimvig = tt-seguros.dtfimvig
                       tt-seg-geral.dtcancel = tt-seguros.dtcancel
                       tt-seg-geral.dtdebito = tt-seguros.dtdebito
                       tt-seg-geral.tpplaseg = tt-seguros.tpplaseg
                       
                       tt-seg-geral.nmbenefi[1] = tt-seguros.nmbenvid[1]
                       tt-seg-geral.nmbenefi[2] = tt-seguros.nmbenvid[2]
                       tt-seg-geral.nmbenefi[3] = tt-seguros.nmbenvid[3]
                       tt-seg-geral.nmbenefi[4] = tt-seguros.nmbenvid[4]
                       tt-seg-geral.nmbenefi[5] = tt-seguros.nmbenvid[5]

                       tt-seg-geral.dsgraupr[1] = tt-seguros.dsgraupr[1]
                       tt-seg-geral.dsgraupr[2] = tt-seguros.dsgraupr[2]
                       tt-seg-geral.dsgraupr[3] = tt-seguros.dsgraupr[3]
                       tt-seg-geral.dsgraupr[4] = tt-seguros.dsgraupr[4]
                       tt-seg-geral.dsgraupr[5] = tt-seguros.dsgraupr[5]

                       tt-seg-geral.txpartic[1] = tt-seguros.txpartic[1]
                       tt-seg-geral.txpartic[2] = tt-seguros.txpartic[2]
                       tt-seg-geral.txpartic[3] = tt-seguros.txpartic[3]
                       tt-seg-geral.txpartic[4] = tt-seguros.txpartic[4]
                       tt-seg-geral.txpartic[5] = tt-seguros.txpartic[5]
                       tt-seg-geral.dtultalt    = tt-seguros.dtultalt
                       tt-seg-geral.dtmvtolt    = tt-seguros.dtmvtolt
                       tt-seg-geral.cdmotcan    = tt-seguros.cdmotcan
                       tt-seg-geral.dsmotcan    = tt-seguros.dsmotcan
                       tt-seg-geral.vlseguro    = tt-seguros.vlseguro.
                       
                IF   tt-seguros.cdsitseg = 1   THEN
                    ASSIGN tt-seg-geral.dssitseg = "Ativo"
                           tt-seg-geral.dsevento = "".
                ELSE
                    IF   tt-seguros.cdsitseg = 2   THEN
                        ASSIGN tt-seg-geral.dssitseg = "Cancelado"
                               tt-seg-geral.dsevento = "Imprimir".
                    ELSE
                        IF   tt-seguros.cdsitseg = 4   THEN
                            ASSIGN tt-seg-geral.dssitseg = "Vencido"
                                   tt-seg-geral.dsevento = "".
                        ELSE
                            ASSIGN tt-seg-geral.dssitseg = "?????????"
                                   tt-seg-geral.dsevento = "".

                RUN buscar_plano_seguro (INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT par_cdoperad,
                                         INPUT par_dtmvtolt,
                                         INPUT par_nrdconta,
                                         INPUT par_idseqttl,
                                         INPUT par_idorigem,
                                         INPUT par_nmdatela,
                                         INPUT par_flgerlog,
                                         INPUT tt-seguros.cdsegura,
                                         INPUT tt-seguros.tpseguro,
                                         INPUT tt-seguros.tpplaseg,
                                         OUTPUT TABLE tt-plano-seg,
                                         OUTPUT TABLE tt-erro).

                ASSIGN aux_dscritic = ""
                       aux_cdcritic = 0.

                FIND tt-plano-seg NO-ERROR.

                IF  NOT AVAILABLE tt-plano-seg THEN
                    ASSIGN tt-seg-geral.vlcapseg = 0
                           tt-seg-geral.dscobert = "".
                ELSE
                  DO:
                      IF par_tpseguro = 3 THEN
                         ASSIGN tt-seg-geral.vlcapseg = tt-seg-geral.vlseguro.
                      ELSE
                         ASSIGN tt-seg-geral.vlcapseg = tt-plano-seg.vlmorada.

                      ASSIGN tt-seg-geral.dscobert = tt-plano-seg.dsmorada
                             tt-seg-geral.vlmorada = tt-plano-seg.vlmorada.
                  END.

                FIND tt-prop-seguros WHERE
                     tt-prop-seguros.cdcooper = par_cdcooper         AND
                     tt-prop-seguros.nrdconta = par_nrdconta         AND
                     tt-prop-seguros.nrctrseg = tt-seguros.nrctrseg  NO-ERROR.
                
                IF  NOT AVAILABLE tt-prop-seguros THEN
                    ASSIGN tt-seg-geral.nmdsegur = "".
                ELSE
                    ASSIGN tt-seg-geral.nmdsegur = tt-prop-seguros.nmdsegur.
            END.
        END CASE.
    END. /* valida: */

    EMPTY TEMP-TABLE tt-erro.

    IF  aux_cdcritic <> 0    OR
        aux_dscritic <> ""   THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF   par_flgerlog  THEN
                RUN proc_gerar_log (INPUT  par_cdcooper,
                                    INPUT  par_cdoperad,
                                    INPUT  aux_dscritic,
                                    INPUT  aux_dsorigem,
                                    INPUT  aux_dstransa,
                                    INPUT  FALSE,
                                    INPUT  par_idseqttl,
                                    INPUT  par_nmdatela,
                                    INPUT  par_nrdconta,
                                    OUTPUT aux_nrdrowid).   
            
            RETURN "NOK".
        END.

            
    IF  par_flgerlog  THEN
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

    RETURN "OK".
END PROCEDURE.

PROCEDURE atualizar_movtos_seg:
    DEF INPUT PARAM par_cdcooper AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                       NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                       NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                       NO-UNDO. 
    DEF INPUT PARAM par_nmdatela AS CHAR                       NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                       NO-UNDO.
    DEF INPUT PARAM par_nrtabela LIKE craptsg.nrtabela         NO-UNDO.
    DEF INPUT PARAM par_tpseguro LIKE craptsg.tpseguro         NO-UNDO.
    DEF INPUT PARAM par_tpplaseg LIKE craptsg.tpplaseg         NO-UNDO.
    DEF INPUT PARAM par_vlpercen AS DEC FORMAT "zzz,zz9.9999-" NO-UNDO.
    DEF INPUT PARAM par_dtdebito LIKE crawseg.dtdebito         NO-UNDO.
    DEF INPUT PARAM par_dtdespre AS DATE FORMAT "99/99/9999"   NO-UNDO.
    DEF INPUT PARAM par_nrctrseg LIKE crapseg.nrctrseg         NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador  AS INTE                    NO-UNDO.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-seguros.

    valida:
    DO:
        RUN gerar_atualizacao_seg(INPUT par_cdcooper,
                                  INPUT par_cdagenci,
                                  INPUT par_nrdcaixa,
                                  INPUT par_cdoperad,
                                  INPUT par_dtmvtolt,
                                  INPUT par_nrdconta,
                                  INPUT par_idseqttl,
                                  INPUT par_idorigem,
                                  INPUT par_nmdatela,
                                  INPUT par_flgerlog,
                                  INPUT par_nrtabela,
                                  INPUT par_tpseguro,
                                  INPUT par_tpplaseg,
                                  INPUT par_vlpercen,
                                  INPUT par_dtdebito,
                                  INPUT par_dtdespre,
                                  OUTPUT TABLE tt-seguros,
                                  OUTPUT TABLE tt-erro).
    
        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
                ASSIGN aux_cdcritic = IF AVAIL tt-erro THEN
                                          tt-erro.cdcritic
                                      ELSE 0
                       aux_dscritic = IF AVAIL tt-erro THEN
                                          tt-erro.dscritic
                                      ELSE "Nao foi possivel " +
                                           "concluir a operacao.".

                LEAVE valida.
            END.

        FIND FIRST tt-seguros WHERE
                   tt-seguros.cdcooper = par_cdcooper  AND
                   tt-seguros.nrdconta = par_nrdconta  AND
                   tt-seguros.tpseguro = par_tpseguro  AND
                   tt-seguros.nrctrseg = par_nrctrseg  NO-ERROR.
        IF NOT AVAIL tt-seguros THEN
            DO:
                ASSIGN aux_dscritic = "Seguro nao encontrado.".

                LEAVE valida.
            END.

       DO aux_contador = 1 TO 10:
       
          FIND FIRST crapseg WHERE 
                     crapseg.cdcooper = par_cdcooper  AND
                     crapseg.nrdconta = par_nrdconta  AND
                     crapseg.tpseguro = par_tpseguro  AND
                     crapseg.nrctrseg = par_nrctrseg  
               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
          IF NOT AVAIL crapseg THEN
             DO:
                IF LOCKED(crapseg) THEN
                   DO:
                     ASSIGN aux_cdcritic = 84.
                     PAUSE 1 NO-MESSAGE.
                     NEXT.
                   END.
                ELSE
                  ASSIGN aux_dscritic = "Seguro nao encontrado.".

                LEAVE valida.
             END.
           ELSE
              DO:
               ASSIGN crapseg.vlpreseg = tt-seguros.vlpreseg
                      aux_cdcritic     = 0
                      aux_dscritic     = "".
               LEAVE valida.
              END.
        END.
        
    END.

    EMPTY TEMP-TABLE tt-erro.

    IF  aux_cdcritic <> 0    OR
        aux_dscritic <> ""   THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF   par_flgerlog  THEN
                RUN proc_gerar_log (INPUT  par_cdcooper,
                                    INPUT  par_cdoperad,
                                    INPUT  aux_dscritic,
                                    INPUT  aux_dsorigem,
                                    INPUT  aux_dstransa,
                                    INPUT  FALSE,
                                    INPUT  par_idseqttl,
                                    INPUT  par_nmdatela,
                                    INPUT  par_nrdconta,
                                    OUTPUT aux_nrdrowid).   
            
            RETURN "NOK".
        END.

            
    IF  par_flgerlog  THEN
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

    RETURN "OK".
END PROCEDURE.

PROCEDURE imprimir_atual_movto_seg:
    DEF INPUT PARAM par_cdcooper AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                       NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                       NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                       NO-UNDO. 
    DEF INPUT PARAM par_nmdatela AS CHAR                       NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                       NO-UNDO.
    DEF INPUT PARAM par_nrtabela LIKE craptsg.nrtabela         NO-UNDO.
    DEF INPUT PARAM par_tpseguro LIKE craptsg.tpseguro         NO-UNDO.
    DEF INPUT PARAM par_tpplaseg LIKE craptsg.tpplaseg         NO-UNDO.
    DEF INPUT PARAM par_vlpercen AS DEC FORMAT "zzz,zz9.9999-" NO-UNDO.
    DEF INPUT PARAM par_dtdebito LIKE crapseg.dtdebito         NO-UNDO.
    DEF INPUT PARAM par_dtdespre AS DATE FORMAT "99/99/9999"   NO-UNDO.
    DEF INPUT PARAM par_nrctrseg LIKE crawseg.nrctrseg         NO-UNDO.
    DEF INPUT PARAM par_nmendter AS CHAR FORMAT "x(20)"        NO-UNDO.

    DEF OUTPUT PARAM par_nmarqimp AS CHAR                      NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                      NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nmarqpdf AS CHAR                               NO-UNDO.
    DEF VAR aux_nmarquiv AS CHAR                               NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-seguros.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0.

    valida:
    DO:
        FIND crapcop WHERE
             crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
        IF  NOT AVAILABLE crapcop  THEN
            DO:
                ASSIGN aux_cdcritic = 651
                       aux_dscritic = "".
                LEAVE valida.
            END.
    
        ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop +
                              "/rl/" + par_nmendter.
    
        UNIX SILENT VALUE("rm " + aux_nmarquiv + "* 2> /dev/null").
    
        ASSIGN aux_nmarquiv = aux_nmarquiv + STRING(TIME)
               par_nmarqimp = aux_nmarquiv + ".lst"
               aux_nmarqpdf = aux_nmarquiv + ".pdf".

        RUN gerar_atualizacao_seg(INPUT par_cdcooper,
                                  INPUT par_cdagenci,
                                  INPUT par_nrdcaixa,
                                  INPUT par_cdoperad,
                                  INPUT par_dtmvtolt,
                                  INPUT par_nrdconta,
                                  INPUT par_idseqttl,
                                  INPUT par_idorigem,
                                  INPUT par_nmdatela,
                                  INPUT par_flgerlog,
                                  INPUT par_nrtabela,
                                  INPUT par_tpseguro,
                                  INPUT par_tpplaseg,
                                  INPUT par_vlpercen,
                                  INPUT par_dtdebito,
                                  INPUT par_dtdespre,
                                  OUTPUT TABLE tt-seguros,
                                  OUTPUT TABLE tt-erro).
    
        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
                ASSIGN aux_cdcritic = IF AVAIL tt-erro THEN
                                          tt-erro.cdcritic
                                      ELSE 0
                       aux_dscritic = IF AVAIL tt-erro THEN
                                          tt-erro.dscritic
                                      ELSE "Nao foi possivel " +
                                           "concluir a operacao.".

                LEAVE valida.
            END.

        FIND FIRST tt-seguros WHERE
                   tt-seguros.cdcooper = par_cdcooper  AND
                   tt-seguros.nrdconta = par_nrdconta  AND
                   tt-seguros.tpseguro = par_tpseguro  AND
                   tt-seguros.nrctrseg = par_nrctrseg  NO-ERROR.
        IF NOT AVAIL tt-seguros THEN
            DO:
                ASSIGN aux_dscritic = "Seguro nao encontrado.".

                LEAVE valida.
            END.

        OUTPUT STREAM str_1 TO VALUE(par_nmarqimp) PAGED PAGE-SIZE 84.

        VIEW STREAM str_1  FRAME f_cabrel080_1.
    
        DISP STREAM str_1
            tt-seguros.tpplaseg   tt-seguros.dtdebito   tt-seguros.nrdconta
            tt-seguros.nrctrseg   tt-seguros.vlant   tt-seguros.vlpreseg
            tt-seguros.dtmvtolt
        WITH FRAME f_lista.
 
        DOWN STREAM str_1 WITH FRAME f_lista.

        OUTPUT STREAM str_1 CLOSE.

        RUN sistema/generico/procedures/b1wgen0024.p
            PERSISTENT SET h-b1wgen0024.
        
        RUN gera-pdf-impressao IN h-b1wgen0024 (INPUT par_nmarqimp,
                                                INPUT aux_nmarqpdf).
        
        DELETE PROCEDURE h-b1wgen0024.

        /** Copiar pdf para visualizacao no Ayllos WEB **/
        IF  par_idorigem = 5  THEN
            DO:
                IF  SEARCH(aux_nmarqpdf) = ?  THEN
                    DO:
                        ASSIGN aux_dscritic = "Nao foi possivel " +
                                              "gerar a impressao.".
                        LEAVE valida.
                    END.

                FIND crapcop WHERE
                     crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
                IF  NOT AVAILABLE crapcop  THEN
                    DO:
                        ASSIGN aux_cdcritic = 651
                               aux_dscritic = "".
                        LEAVE valida.
                    END.
        
                UNIX SILENT VALUE ('sudo /usr/bin/su - scpuser -c ' +
                '"scp ' + aux_nmarqpdf + ' scpuser@' + aux_srvintra +
                ':/var/www/ayllos/documentos/' + crapcop.dsdircop +
                '/temp/" 2>/dev/null').
            END.

        IF  par_idorigem = 5  THEN
            UNIX SILENT VALUE ("rm " + aux_nmarquiv + "* 2>/dev/null").
        ELSE
            UNIX SILENT VALUE ("rm " + aux_nmarqpdf + " 2>/dev/null").
        
        ASSIGN par_nmarqpdf =
            ENTRY(NUM-ENTRIES(aux_nmarqpdf,"/"),aux_nmarqpdf,"/").
    END.

    EMPTY TEMP-TABLE tt-erro.

    IF  aux_cdcritic <> 0    OR
        aux_dscritic <> ""   THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF   par_flgerlog  THEN
                RUN proc_gerar_log (INPUT  par_cdcooper,
                                    INPUT  par_cdoperad,
                                    INPUT  aux_dscritic,
                                    INPUT  aux_dsorigem,
                                    INPUT  aux_dstransa,
                                    INPUT  FALSE,
                                    INPUT  par_idseqttl,
                                    INPUT  par_nmdatela,
                                    INPUT  par_nrdconta,
                                    OUTPUT aux_nrdrowid).   
            
            RETURN "NOK".
        END.

    IF  par_flgerlog  THEN
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

    RETURN "OK".
END PROCEDURE.

PROCEDURE atualizar_matricula:
    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO. 
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-matricula.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nrctrseg AS INTE                            NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-matricula.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    FIND FIRST crapmat WHERE crapmat.cdcooper = par_cdcooper 
                             NO-LOCK NO-ERROR.
    IF AVAIL crapmat THEN
        DO:
            /* Buscar a proxima sequencia crapmat.nrctrseg */ 
            RUN STORED-PROCEDURE pc_sequence_progress
            aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPMAT"
                                                ,INPUT "NRCTRSEG"
                                                ,INPUT STRING(par_cdcooper)
                                                ,INPUT "N"
                                                ,"").
            
            CLOSE STORED-PROC pc_sequence_progress
            aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                              
            ASSIGN aux_nrctrseg = INTE(pc_sequence_progress.pr_sequence)
                                                      WHEN pc_sequence_progress.pr_sequence <> ?.
            
            BUFFER-COPY crapmat TO tt-matricula.
            ASSIGN tt-matricula.nrctrseg = aux_nrctrseg.
        END.
    ELSE
       ASSIGN aux_dscritic = "Matricula nao encontrada."
              aux_cdcritic = 71.
    
    IF  aux_cdcritic <> 0    OR
        aux_dscritic <> ""   THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF   par_flgerlog  THEN
                RUN proc_gerar_log (INPUT  par_cdcooper,
                                    INPUT  par_cdoperad,
                                    INPUT  aux_dscritic,
                                    INPUT  aux_dsorigem,
                                    INPUT  aux_dstransa,
                                    INPUT  FALSE,
                                    INPUT  par_idseqttl,
                                    INPUT  par_nmdatela,
                                    INPUT  par_nrdconta,
                                    OUTPUT aux_nrdrowid).   
            
            RETURN "NOK".
        END.

            
    IF  par_flgerlog  THEN
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

    RETURN "OK".
END PROCEDURE.

PROCEDURE busca_end_cor:
    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO. 
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                    NO-UNDO.
    DEF INPUT PARAM par_nrctrseg LIKE crawseg.nrctrseg      NO-UNDO.
    DEF INPUT PARAM par_tpendcor LIKE crapass.inpessoa      NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt_end_cor.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN aux_dscritic = "".

    EMPTY TEMP-TABLE tt_end_cor.

    CASE par_tpendcor:
        WHEN 1 THEN DO: /*Local de Risco*/
            FIND FIRST crawseg NO-LOCK WHERE
                       crawseg.cdcooper = par_cdcooper AND
                       crawseg.nrdconta = par_nrdconta AND
                       crawseg.nrctrseg = par_nrctrseg NO-ERROR.
            IF AVAIL crawseg THEN
            DO:
                CREATE tt_end_cor.
                ASSIGN tt_end_cor.dsendres = crawseg.dsendres
                       tt_end_cor.nrendres = crawseg.nrendres
                       tt_end_cor.nmbairro = crawseg.nmbairro
                       tt_end_cor.nrcepend = crawseg.nrcepend
                       tt_end_cor.nmcidade = crawseg.nmcidade
                       tt_end_cor.cdufresd = crawseg.cdufresd
                       tt_end_cor.complend = crawseg.complend.
            END.
        END.
        WHEN 2 THEN DO: /*Residencial*/
            FIND FIRST crapenc NO-LOCK WHERE
                       crapenc.tpendass = 10           AND
                       crapenc.cdcooper = par_cdcooper AND
                       crapenc.nrdconta = par_nrdconta NO-ERROR.
            IF NOT AVAIL crapenc THEN
                ASSIGN aux_dscritic = "Endereco nao encontrado. Efetue" +
                                      " cadastro na tela CONTAS.".
            ELSE DO:
                CREATE tt_end_cor.
                ASSIGN tt_end_cor.dsendres = crapenc.dsendere
                       tt_end_cor.nrendres = crapenc.nrendere
                       tt_end_cor.nmbairro = crapenc.nmbairro
                       tt_end_cor.nrcepend = crapenc.nrcepend
                       tt_end_cor.nmcidade = crapenc.nmcidade
                       tt_end_cor.cdufresd = crapenc.cdufende
                       tt_end_cor.complend = crapenc.complend.
            END.
        END.
        WHEN 3 THEN DO: /*Comercial*/
            FIND FIRST crapenc NO-LOCK WHERE
                       crapenc.tpendass = 9            AND
                       crapenc.cdcooper = par_cdcooper AND
                       crapenc.nrdconta = par_nrdconta NO-ERROR.
            IF NOT AVAIL crapenc THEN
                ASSIGN aux_dscritic = "Endereco nao encontrado. Efetue" +
                                      " cadastro na tela CONTAS.".
            ELSE DO:
                IF crapenc.dsendere = "" AND
                   crapenc.nrendere = 0 THEN
                   ASSIGN aux_dscritic = "Endereco nao encontrado. Efetue" +
                                         " cadastro na tela CONTAS.".
                ELSE 
                    DO:
                        CREATE tt_end_cor.
                        ASSIGN tt_end_cor.dsendres = crapenc.dsendere
                               tt_end_cor.nrendres = crapenc.nrendere
                               tt_end_cor.nmbairro = crapenc.nmbairro
                               tt_end_cor.nrcepend = crapenc.nrcepend
                               tt_end_cor.nmcidade = crapenc.nmcidade
                               tt_end_cor.cdufresd = crapenc.cdufende
                               tt_end_cor.complend = crapenc.complend.
                    END.
            END.
        END.
        OTHERWISE
            ASSIGN aux_dscritic = "Endereco nao encontrado. Efetue" +
                                  " cadastro na tela CONTAS.".
    END CASE.

    EMPTY TEMP-TABLE tt-erro.
    
    IF  aux_cdcritic <> 0    OR
        aux_dscritic <> ""   THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            
            IF   par_flgerlog  THEN
                RUN proc_gerar_log (INPUT  par_cdcooper,
                                    INPUT  par_cdoperad,
                                    INPUT  aux_dscritic,
                                    INPUT  aux_dsorigem,
                                    INPUT  aux_dstransa,
                                    INPUT  FALSE,
                                    INPUT  par_idseqttl,
                                    INPUT  par_nmdatela,
                                    INPUT  par_nrdconta,
                                    OUTPUT aux_nrdrowid).   
            
            RETURN "NOK".
        END.

    IF  par_flgerlog  THEN
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

    RETURN "OK".
END PROCEDURE.

PROCEDURE imprimir_proposta_seguro:
    DEF INPUT PARAM par_cdcooper AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                       NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                       NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                       NO-UNDO. 
    DEF INPUT PARAM par_nmdatela AS CHAR                       NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                       NO-UNDO.
    DEF INPUT PARAM par_tpseguro LIKE craptsg.tpseguro         NO-UNDO.
    DEF INPUT PARAM par_tpplaseg LIKE craptsg.tpplaseg         NO-UNDO.
    DEF INPUT PARAM par_cdsegura LIKE crapseg.cdsegura         NO-UNDO.    
    DEF INPUT PARAM par_nrctrseg LIKE crapseg.nrctrseg         NO-UNDO.
    DEF INPUT PARAM par_nmendter AS CHAR FORMAT "x(20)"        NO-UNDO.
    DEF INPUT PARAM par_reccraws AS CHAR                       NO-UNDO. 

    DEF OUTPUT PARAM aux_nmarqimp AS CHAR                      NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                      NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux2_contador AS INT                               NO-UNDO.
    DEF VAR aux3_contador AS INT                               NO-UNDO.
    DEF VAR aux_nmarquiv AS CHAR                               NO-UNDO.
    DEF VAR aux_nmarqpdf AS CHAR                               NO-UNDO.
    DEF VAR aux_qtsegass AS INTE                               NO-UNDO.
    DEF VAR aux_vltotseg AS DECI                               NO-UNDO.
    DEF VAR aux_dsmesref AS CHAR                               NO-UNDO.

    DEF VAR aux_cdempres LIKE crapemp.cdempres                 NO-UNDO.

    DEF VAR aux_nmarqtmp AS CHAR                               NO-UNDO.
    DEF VAR aux_nrpagina AS INT                                NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0.

    FORM "\0330\033x0\033\017" WITH NO-BOX NO-LABELS FRAME f_config. 

    carrega:
    DO:
        RUN buscar_cooperativa (INPUT par_cdcooper,
                                INPUT par_cdagenci,
                                INPUT par_nrdcaixa,
                                INPUT par_cdoperad,
                                INPUT par_dtmvtolt,
                                INPUT par_nrdconta,
                                INPUT par_idseqttl,
                                INPUT par_idorigem,
                                INPUT par_nmdatela,
                                INPUT par_flgerlog,
                                OUTPUT TABLE tt-cooperativa,
                                OUTPUT TABLE tt-erro).

        IF   RETURN-VALUE <> "OK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                IF   AVAIL tt-erro   THEN
                    DO:
                        ASSIGN aux_cdcritic = tt-erro.cdcritic
                               aux_dscritic = tt-erro.dscritic.
                        EMPTY TEMP-TABLE tt-erro.
                        LEAVE carrega.
                    END.
            END.

        FIND tt-cooperativa WHERE
             tt-cooperativa.cdcooper = par_cdcooper NO-ERROR.
            
        ASSIGN aux_nmarquiv = "/usr/coop/" + tt-cooperativa.dsdircop +
                              "/rl/" + par_nmendter.

        UNIX SILENT VALUE("rm " + aux_nmarquiv + "* 2> /dev/null").
    
        ASSIGN aux_nmarquiv = aux_nmarquiv + STRING(TIME)
               aux_nmarqimp = aux_nmarquiv + "_proposta_seguro.ex"
               aux_nmarqpdf = aux_nmarquiv + ".pdf"
               aux_dsmesref = "janeiro,fevereiro,marco,abril," +
                              "maio,junho,julho,agosto,setembro," +
                              "outubro,novembro,dezembro"
            
               aux_nrpagina = 0.

        RUN buscar_proposta_seguro (INPUT par_cdcooper,
                                    INPUT par_cdagenci,
                                    INPUT par_nrdcaixa,
                                    INPUT par_cdoperad,
                                    INPUT par_dtmvtolt,
                                    INPUT par_nrdconta,
                                    INPUT par_idseqttl,
                                    INPUT par_idorigem,
                                    INPUT par_nmdatela,
                                    INPUT par_flgerlog,
                                    OUTPUT TABLE tt-prop-seguros,
                                    OUTPUT aux_qtsegass,
                                    OUTPUT aux_vltotseg,
                                    OUTPUT TABLE tt-erro).

        IF   RETURN-VALUE <> "OK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                IF   AVAIL tt-erro   THEN
                    DO:
                        ASSIGN aux_cdcritic = tt-erro.cdcritic
                               aux_dscritic = tt-erro.dscritic.
                        EMPTY TEMP-TABLE tt-erro.
                        LEAVE carrega.
                    END.
            END.


        IF par_reccraws <> "" THEN
            FIND FIRST tt-prop-seguros WHERE
                       string(tt-prop-seguros.registro) = par_reccraws NO-ERROR.
        ELSE
            FIND FIRST tt-prop-seguros WHERE
                       tt-prop-seguros.cdcooper = par_cdcooper  AND
                       tt-prop-seguros.nrdconta = par_nrdconta  AND
                       tt-prop-seguros.tpseguro = par_tpseguro  AND
                       tt-prop-seguros.nrctrseg = par_nrctrseg  NO-ERROR.

        IF NOT AVAIL tt-prop-seguros THEN
            DO:                   
                ASSIGN aux_cdcritic = 535.
                EMPTY TEMP-TABLE tt-erro.
                LEAVE carrega.
            END.

        RUN buscar_associados(INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT par_cdoperad,
                              INPUT par_dtmvtolt,
                              INPUT par_nrdconta,
                              INPUT par_idseqttl,
                              INPUT par_idorigem,
                              INPUT par_nmdatela,
                              INPUT par_flgerlog,
                              OUTPUT TABLE tt-associado,
                              OUTPUT TABLE tt-erro).

        IF   RETURN-VALUE <> "OK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                IF   AVAIL tt-erro   THEN
                    DO:
                        ASSIGN aux_cdcritic = tt-erro.cdcritic
                               aux_dscritic = tt-erro.dscritic.
                        EMPTY TEMP-TABLE tt-erro.
                        LEAVE carrega.
                    END.
            END.

        FIND tt-associado WHERE
             tt-associado.cdcooper = par_cdcooper      AND 
             tt-associado.nrdconta = par_nrdconta  NO-ERROR.

        RUN buscar_titular(INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT par_cdoperad,
                           INPUT par_dtmvtolt,
                           INPUT par_nrdconta,
                           INPUT par_idseqttl,
                           INPUT par_idorigem,
                           INPUT par_nmdatela,
                           INPUT par_flgerlog,
                           OUTPUT TABLE tt-titular,
                           OUTPUT TABLE tt-erro).

        IF   RETURN-VALUE <> "OK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                IF   AVAIL tt-erro   THEN
                    DO:
                        ASSIGN aux_cdcritic = tt-erro.cdcritic
                               aux_dscritic = tt-erro.dscritic.
                        EMPTY TEMP-TABLE tt-erro.
                        LEAVE carrega.
                    END.
            END.

        FIND tt-titular WHERE
             tt-titular.cdcooper = par_cdcooper  AND
             tt-titular.nrdconta = par_nrdconta  AND
             tt-titular.idseqttl = par_idseqttl  NO-ERROR.

        IF   tt-associado.inpessoa = 1   THEN
            DO:
                ASSIGN aux_cdempres = tt-titular.cdempres.
            END.
        ELSE
            DO:
                RUN buscar_pessoa_juridica(INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT par_cdoperad,
                                           INPUT par_dtmvtolt,
                                           INPUT par_nrdconta,
                                           INPUT par_idseqttl,
                                           INPUT par_idorigem,
                                           INPUT par_nmdatela,
                                           INPUT par_flgerlog,
                                           OUTPUT TABLE tt-pess-jur,
                                           OUTPUT TABLE tt-erro).

                IF   RETURN-VALUE <> "OK"  THEN
                    DO:
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.
                        IF   AVAIL tt-erro   THEN
                            DO:
                                ASSIGN aux_cdcritic = tt-erro.cdcritic
                                       aux_dscritic = tt-erro.dscritic.
                                EMPTY TEMP-TABLE tt-erro.
                                LEAVE carrega.
                            END.
                    END.

                FIND tt-pess-jur WHERE
                     tt-pess-jur.cdcooper = par_cdcooper  AND
                     tt-pess-jur.nrdconta = par_nrdconta  NO-ERROR.

                ASSIGN aux_cdempres = tt-pess-jur.cdempres.
            END.

        RUN buscar_empresa(INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT par_cdoperad,
                           INPUT par_dtmvtolt,
                           INPUT par_nrdconta,
                           INPUT par_idseqttl,
                           INPUT par_idorigem,
                           INPUT par_nmdatela,
                           INPUT par_flgerlog,
                           INPUT aux_cdempres,
                           OUTPUT TABLE tt-empresa,
                           OUTPUT TABLE tt-erro).

        IF   RETURN-VALUE <> "OK"  THEN
             DO:
                 FIND FIRST tt-erro NO-LOCK NO-ERROR.
                 IF   AVAIL tt-erro   THEN
                     DO:
                         ASSIGN aux_cdcritic = tt-erro.cdcritic
                                aux_dscritic = tt-erro.dscritic.
                         EMPTY TEMP-TABLE tt-erro.
                         LEAVE carrega.
                     END.
             END.

        FIND tt-empresa WHERE
             tt-empresa.cdcooper = par_cdcooper  AND
             tt-empresa.cdempres = aux_cdempres  NO-ERROR.

        ASSIGN rel_nrdconta[1] = tt-prop-seguros.nrdconta
               rel_nrdconta[2] = tt-prop-seguros.nrdconta
               rel_dstipseg = "SEGURO RESIDENCIAL"
               rel_dssubsti = IF TRIM(tt-prop-seguros.lsctrant) <> "" THEN
                                 "(EM SUBSTITUICAO DA PROPOSTA " +
                                 STRING(INT(ENTRY(
                                     NUM-ENTRIES(tt-prop-seguros.lsctrant),
                                 tt-prop-seguros.lsctrant)),"zz,zzz,zz9") + ")"
                              ELSE ""
               rel_nrctrseg = tt-prop-seguros.nrctrseg
               rel_cdcalcul = tt-prop-seguros.cdcalcul
               rel_tpplaseg = tt-prop-seguros.tpplaseg
               rel_ddvencto = DAY(tt-prop-seguros.dtdebito)
               rel_vlpreseg = tt-prop-seguros.vlpreseg
               rel_dsmvtolt = TRIM(tt-cooperativa.nmcidade) + ", " + 
                              STRING(DAY(tt-prop-seguros.dtmvtolt)) + " DE " +
                              CAPS(ENTRY(
                                  MONTH(tt-prop-seguros.dtmvtolt),aux_dsmesref))
                              + " DE " + STRING(
                                  YEAR(tt-prop-seguros.dtmvtolt)) + "."
               rel_nmdsegur = tt-prop-seguros.nmdsegur
               rel_nmprimtl = tt-associado.nmprimtl
               
               rel_nrcpfcgc = tt-prop-seguros.nrcpfcgc
               
               rel_dtinivig = tt-prop-seguros.dtinivig
               rel_dtfimvig = tt-prop-seguros.dtfimvig.

        ASSIGN aux_dscritic = ""
               aux_cdcritic = 0.

        FIND FIRST tt-titular WHERE
                   tt-titular.nrdconta = par_nrdconta AND
                   tt-titular.cdcooper = par_cdcooper AND
                   tt-titular.tpdocttl = "CI" NO-ERROR.
        IF AVAIL tt-titular THEN
            ASSIGN rel_nrdocttl = tt-titular.nrdocttl.

        IF  (tt-prop-seguros.tpseguro = 1 OR
             tt-prop-seguros.tpseguro = 11)  THEN
            ASSIGN rel_dsseguro    = "SEGURO RESIDENCIAL"
                   rel_dsbemseg[1] = "RESIDENCIA LOCALIZADA A RUA " +
                                     tt-prop-seguros.dsendres
                   rel_dsbemseg[2] = "TEL.: " + tt-prop-seguros.nrfonres +
                                     "    BAIRRO: "  +
                                     tt-prop-seguros.nmbairro
                   rel_dsbemseg[3] = "CIDADE: " + tt-prop-seguros.nmcidade +
                                     "       U.F.: " +
                                     tt-prop-seguros.cdufresd + "    CEP: " + 
                                 STRING(tt-prop-seguros.nrcepend,"99,999,999").

        ASSIGN rel_dsbemseg[4] = ""
               rel_dsbemseg[5] = "".

        IF  tt-empresa.tpdebseg = 2   AND
            tt-empresa.inavsseg = 1   AND
            rel_ddvencto     < 11  THEN
            IF  tt-associado.cdtipcta = 5  OR
                tt-associado.cdtipcta = 6  OR
                tt-associado.cdtipcta = 7  OR
                tt-associado.cdtipcta = 17 OR
                tt-associado.cdtipcta = 18 OR
                tt-associado.cdsitdct = 5  THEN
                IF  aux_cdempres =  1   OR
                   (aux_cdempres =  4   AND
                   (tt-associado.cdagenci = 14   OR
                    tt-associado.cdagenci = 15)) THEN
                    ASSIGN aux_vlpreseg    = ROUND(rel_vlpreseg *
                                                   (1 + tab_txcpmfcc),2)
                           rel_dsbemseg[4] = "O ASSOCIADO DEVERA DEIXAR" +
                                             " EM CONTA " +
                                             "CORRENTE O VALOR DE R$" +
                                            STRING(aux_vlpreseg,"zzz,zz9.99") +
                                             ", PARA  QUE"
                           rel_dsbemseg[5] = "POSSA SER EFETUADO O" +
                                             " DEBITO DA " +
                                             "PRIMEIRA PARCELA.".

        RUN busca_seguros(INPUT par_cdcooper,
                                  INPUT par_cdagenci,
                                  INPUT par_nrdcaixa,
                                  INPUT par_cdoperad,
                                  INPUT par_dtmvtolt,
                                  INPUT par_nrdconta,
                                  INPUT par_idseqttl,
                                  INPUT par_idorigem,
                                  INPUT par_nmdatela,
                                  INPUT par_flgerlog,
                                  OUTPUT TABLE tt-seguros,
                                  OUTPUT aux_qtsegass,
                                  OUTPUT aux_vltotseg,
                                  OUTPUT TABLE tt-erro).

        IF   RETURN-VALUE <> "OK"  THEN
             DO:
                 FIND FIRST tt-erro NO-LOCK NO-ERROR.
                 IF   AVAIL tt-erro   THEN
                     DO:
                         ASSIGN aux_cdcritic = tt-erro.cdcritic
                                aux_dscritic = tt-erro.dscritic.
                         EMPTY TEMP-TABLE tt-erro.
                         LEAVE carrega.
                     END.
             END.

        RUN buscar_seguradora(INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT par_cdoperad,
                              INPUT par_dtmvtolt,
                              INPUT par_nrdconta,
                              INPUT par_idseqttl,
                              INPUT par_idorigem,
                              INPUT par_nmdatela,
                              INPUT par_flgerlog,
                              INPUT tt-prop-seguros.tpseguro,
                              INPUT 0,
                              INPUT tt-prop-seguros.cdsegura,
                              INPUT "",
                              OUTPUT aux_qtregist,
                              OUTPUT TABLE tt-seguradora,
                              OUTPUT TABLE tt-erro).

        IF   RETURN-VALUE <> "OK"  THEN
             DO:
                 FIND FIRST tt-erro NO-LOCK NO-ERROR.
                 IF   AVAIL tt-erro   THEN
                     DO:
                         ASSIGN aux_cdcritic = tt-erro.cdcritic
                                aux_dscritic = tt-erro.dscritic.
                         EMPTY TEMP-TABLE tt-erro.
                         LEAVE carrega.
                     END.
             END.

        FIND tt-seguradora WHERE
             tt-seguradora.cdcooper = par_cdcooper AND
             tt-seguradora.cdsegura = tt-prop-seguros.cdsegura
             NO-ERROR.

        FIND tt-seguros WHERE
             tt-seguros.cdcooper = par_cdcooper  AND 
             tt-seguros.cdsegura = tt-prop-seguros.cdsegura  AND
             tt-seguros.nrdconta = tt-prop-seguros.nrdconta  AND
             tt-seguros.nrctrseg = tt-prop-seguros.nrctrseg  NO-ERROR.

        RUN buscar_plano_seguro(INPUT par_cdcooper,
                                INPUT par_cdagenci,
                                INPUT par_nrdcaixa,
                                INPUT par_cdoperad,
                                INPUT par_dtmvtolt,
                                INPUT par_nrdconta,
                                INPUT par_idseqttl,
                                INPUT par_idorigem,
                                INPUT par_nmdatela,
                                INPUT par_flgerlog,
                                INPUT tt-prop-seguros.cdsegura,
                                INPUT tt-prop-seguros.tpseguro,
                                INPUT tt-prop-seguros.tpplaseg,
                               OUTPUT TABLE tt-plano-seg,
                               OUTPUT TABLE tt-erro).

        IF   RETURN-VALUE <> "OK"  THEN
             DO:
                 FIND FIRST tt-erro NO-LOCK NO-ERROR.
                 IF   AVAIL tt-erro   THEN
                     DO:
                         ASSIGN aux_cdcritic = tt-erro.cdcritic
                                aux_dscritic = tt-erro.dscritic.
                         EMPTY TEMP-TABLE tt-erro.
                         LEAVE carrega.
                     END.
             END.

        FIND tt-plano-seg WHERE
             tt-plano-seg.cdcooper = par_cdcooper               AND 
             tt-plano-seg.cdsegura = tt-prop-seguros.cdsegura   AND
             tt-plano-seg.tpseguro = tt-prop-seguros.tpseguro   AND
             tt-plano-seg.cdsitpsg = 1                          AND
             tt-plano-seg.tpplaseg = tt-prop-seguros.tpplaseg   NO-ERROR.


        RUN buscar_garantias(INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT par_cdoperad,
                             INPUT par_dtmvtolt,
                             INPUT par_nrdconta,
                             INPUT par_idseqttl,
                             INPUT par_idorigem,
                             INPUT par_nmdatela,
                             INPUT par_flgerlog,
                             INPUT tt-prop-seguros.cdsegura,
                             INPUT tt-prop-seguros.tpseguro,
                             INPUT tt-prop-seguros.tpplaseg,
                             INPUT 0,
                            OUTPUT TABLE tt-gar-seg,
                            OUTPUT TABLE tt-erro).
            
        OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

        VIEW STREAM str_1 FRAME f_config.
      
        IF  AVAILABLE tt-seguros THEN
            ASSIGN rel_tpplaseg = tt-seguros.tpplaseg
                   rel_ddvencto = DAY(tt-seguros.dtdebito)
                   rel_vlpreseg = tt-seguros.vlpreseg.

        /* Descricao com as parcelas a serem pagas */
        ASSIGN rel_dsparcel = STRING(rel_vlpreseg,"zz,zz9.99")
               rel_dsparcel = REPLACE(rel_dsparcel," ", "").

        IF AVAIL tt-plano-seg THEN
            ASSIGN rel_dsmorada = tt-plano-seg.dsmorada
                   rel_dsocupac = tt-plano-seg.dsocupac.
        ELSE 
            ASSIGN rel_dsmorada = ""
                   rel_dsocupac = "".

        IF  AVAILABLE tt-seguros THEN
            ASSIGN rel_vlpreseg = tt-seguros.vlpreseg * tt-seguros.qtparcel.
        ELSE
            ASSIGN rel_vlpreseg = tt-prop-seguros.vlpreseg *
                                  tt-prop-seguros.qtparcel.

        ASSIGN aux_dsendres = TRIM(tt-prop-seguros.dsendres) +
                       ", " + TRIM(STRING(tt-prop-seguros.nrendres))
			   aux_dscgcseg = STRING(tt-seguradora.nrcgcseg,'99999999999999')
			   aux_nmresseg = TRIM(tt-seguradora.nmresseg).
		
		
		/*Primeira via*/
        DISPLAY STREAM str_1 
                aux_dscgcseg 
                aux_nmresseg
                tt-seguros.nrctrseg
                WITH FRAME f_autori_casa_c.                     
        
        DISPLAY STREAM str_1
                tt-seguradora.nmrescec
                tt-seguradora.nmrescop 
                tt-prop-seguros.nmdsegur 
                rel_nrcpfcgc 
                rel_nrdocttl
                aux_dsendres
                tt-prop-seguros.nrcepend
                tt-prop-seguros.nmbairro
                tt-prop-seguros.nmcidade 
                tt-prop-seguros.cdufresd
                rel_dsmorada
                rel_dsocupac
                rel_dtinivig
                rel_dtfimvig WITH FRAME f_autori_casa_c_w_2.
        
        ASSIGN aux2_contador = 0.

        FOR EACH tt-gar-seg WHERE
                 tt-gar-seg.cdcooper = par_cdcooper  AND
                 tt-gar-seg.cdsegura = tt-prop-seguros.cdsegura  AND
                 tt-gar-seg.tpseguro = tt-prop-seguros.tpseguro  AND
                 tt-gar-seg.tpplaseg = tt-prop-seguros.tpplaseg:

            ASSIGN aux2_contador = aux2_contador + 1.
            DISP STREAM str_1
                tt-gar-seg.dsgarant
                tt-gar-seg.vlgarant AT 52  
                WITH FRAME f_autori_casa_2.

            DOWN STREAM str_1 WITH FRAME f_autori_casa_2.
             
        END.

        DISPLAY STREAM str_1 WITH FRAME f_autori_casa_franq1.
            
        FOR EACH tt-gar-seg WHERE
                 tt-gar-seg.cdcooper = par_cdcooper  AND
                 tt-gar-seg.cdsegura = tt-prop-seguros.cdsegura  AND
                 tt-gar-seg.tpseguro = tt-prop-seguros.tpseguro  AND
                 tt-gar-seg.tpplaseg = tt-prop-seguros.tpplaseg:

            IF tt-gar-seg.dsfranqu <> " " THEN
                DO:
                    ASSIGN aux2_contador = aux2_contador + 1.
                    DISP STREAM str_1
                        tt-gar-seg.dsfranqu   
                        WITH FRAME f_autori_casa_franq2.

                    DOWN STREAM str_1 WITH FRAME f_autori_casa_franq2.
                END.
             
        END.

        FIND FIRST crapope NO-LOCK WHERE
                   crapope.cdcooper = par_cdcooper AND 
                   crapope.cdoperad = par_cdoperad NO-ERROR.

        ASSIGN rel_nrdconta2 = par_nrdconta
               aux_premitot  = tt-prop-seguros.vlpreseg * 12
               aux_premliqu  = aux_premitot / ((aux_valoriof / 100) + 1)
               aux_vliofper  = STRING(aux_valoriof) + "%".
        
        DISP STREAM str_1
            aux_premliqu 
            aux_vliofper 
            aux_premitot 
            WITH FRAME f_autori_casa_compl.

        /* Propostas com inicio de vigencia maior ou igual a 06/04/2015 */
        IF  rel_dtinivig >= 04/06/2015 THEN
            DO:
                ASSIGN 
                aux_casa3325 = "este instrumento  de  mandato, outorgo  a  LAZAM  -  MDS Corretora e\033\110"
                aux_casa0401 = "\033\107Administradora de Seguros S/A, inscrita no  CNPJ 48.114.367/0002-43,"
                aux_casa0402 = "com  endereco  na  Rua  Ingo  Hering,  20  -  Blumenau/SC,  registro"
                aux_casa0403 = "SUSEP  100059188  e  a    Cooperativa  Central  de  Credito  Urbano,"
                aux_casa0404 = "inscrita no CNPJ 05.463.212/0001-29, os poderes especificos  para  a"
                aux_casa0405 = "contratacao do seguro objeto da presente proposta, com o objetivo de"
                aux_casa0406 = "garantir os  riscos  futuros,  na forma estabelecida  nas  condicoes"
                aux_casa0407 = "contratuais deste seguro, podendo o presente ser revogado a qualquer"
                aux_casa0408 = "momento,  mediante  minha  expressa manifestacao.\033\110           "
                aux_casa4307 = "* Equipamentos portateis,  incluindo   palmtops,   telefone celular,"
                aux_casa4308 = "pager, aparelhos  de  mp3,  IPOD's,  receptores GPS,   transmissores"
                aux_casa4309 = "portateis e similares;                                              "
                aux_casa0611 = "_____________________________________________________  "
                aux_casa0614 = "_____________________________________________________"
                aux_casa0617 = "_____________________________________________________  "
                aux_casa0618 = "LAZAM - MDS Corretora e Administradora de Seguros S/A"
                aux_casa0619 = "SUSEP: 100059188".
            END.
        ELSE
            DO:
                ASSIGN 
                aux_casa3325 = "este instrumento  de  mandato,  outorgo  a  ADDmakler,  inscrita  no\033\110"
                aux_casa0401 = "\033\107CNPJ 85.326.522/0001-09, com endereco  na  Rua  Ingo  Hering,  20  -"
                aux_casa0402 = "Blumenau/SC,  registro  SUSEP  029.224.101.290-20  e  a  Cooperativa"
                aux_casa0403 = "Central de Credito Urbano, inscrita no CNPJ  05.463.212/0001-29,  os"
                aux_casa0404 = "poderes especificos para a contratacao do seguro objeto da  presente"
                aux_casa0405 = "proposta, com o objetivo de garantir os  riscos  futuros,  na  forma"
                aux_casa0406 = "estabelecida  nas  condicoes contratuais  deste  seguro,  podendo  o"
                aux_casa0407 = "presente ser revogado a qualquer momento,  mediante  minha  expressa"
                aux_casa0408 = "manifestacao.\033\110                                               "
                aux_casa4307 = "* Equipamentos portateis, incluindo  notebooks,  laptops,  palmtops,"
                aux_casa4308 = "telefone celular, pager, aparelhos de  mp3, IPOD's,  receptores GPS,"
                aux_casa4309 = "transmissores portateis e similares;                                "
                aux_casa0611 = "_____________________________________________          "
                aux_casa0614 = "_____________________________________________"
                aux_casa0617 = "_____________________________________________          "
                aux_casa0618 = "Add Makler Corretora de Seguros"
                aux_casa0619 = "SUSEP: 02922410129020".
            END.
        
        DISP STREAM str_1 WITH FRAME f_autori_casa_3.
        DISP STREAM str_1 WITH FRAME f_autori_casa_3_1.

		/* Propostas com inicio de vigencia maior ou igual a 20/06/2016 */
        IF  rel_dtinivig > 06/20/2017 THEN 
			DO:
				DISP STREAM str_1 WITH FRAME f_autori_casa_3_2.
				
				DISP STREAM str_1 
				 aux_casa3325
				 WITH FRAME f_autori_casa_3_3.
				 
				DISP STREAM str_1
 					 aux_casa0401 
					 aux_casa0402
					 aux_casa0403
					 aux_casa0404
					 aux_casa0405
					 aux_casa0406
					 aux_casa0407
					 aux_casa0408
					 WITH FRAME f_autori_casa_4.
				
				DISP STREAM str_1 WITH FRAME f_autori_casa_4_1.
				
				DISP STREAM str_1 WITH FRAME f_autori_casa_4_2.

				DISP STREAM str_1
					 aux_casa4307
					 aux_casa4308
					 aux_casa4309
					 WITH FRAME f_autori_casa_4_3.

				DISP STREAM str_1 WITH FRAME f_autori_casa_4_4.
				
				DISP STREAM str_1 
					 rel_nrdconta2
					 WITH FRAME f_autori_casa_5.
			END.
		ELSE
			DO:
				DISP STREAM str_1 WITH FRAME f_autori_casa_3_2_1.
				
				DISP STREAM str_1 
				 aux_casa3325
				 WITH FRAME f_autori_casa_3_3_1.
				 
				DISP STREAM str_1
 					 aux_casa0401 
					 aux_casa0402
					 aux_casa0403
					 aux_casa0404
					 aux_casa0405
					 aux_casa0406
					 aux_casa0407
					 aux_casa0408
					 WITH FRAME f_autori_casa_4.
				
				DISP STREAM str_1 WITH FRAME f_autori_casa_4_1_1.
				
				DISP STREAM str_1 WITH FRAME f_autori_casa_4_2.

				DISP STREAM str_1
					 aux_casa4307
					 aux_casa4308
					 aux_casa4309
					 WITH FRAME f_autori_casa_4_3.

				DISP STREAM str_1 WITH FRAME f_autori_casa_4_4.

				DISP STREAM str_1 
					 rel_nrdconta2
					 WITH FRAME f_autori_casa_5_1_1.
			END.

        DISP STREAM str_1
            rel_nrctrseg 
            tt-prop-seguros.tpplaseg
            rel_ddvencto 
            rel_dsparcel
            aux_casa0611
            tt-prop-seguros.nmdsegur @ rel_dsseguro
            aux_casa0614
            crapope.nmoperad
            aux_casa0617
            aux_casa0618
            aux_casa0619
            par_nrdconta @ rel_nrdconta3
            WITH FRAME f_autori_casa_6.
        
        PAGE STREAM str_1.
        
        /*Segunda via*/
        DISPLAY STREAM str_1 
                aux_dscgcseg 
                aux_nmresseg
                tt-seguros.nrctrseg
                WITH FRAME f_autori_casa_c.                     
        
        DISPLAY STREAM str_1
                tt-seguradora.nmrescec
                tt-seguradora.nmrescop 
                tt-prop-seguros.nmdsegur 
                rel_nrcpfcgc 
                rel_nrdocttl
                aux_dsendres
                tt-prop-seguros.nrcepend
                tt-prop-seguros.nmbairro
                tt-prop-seguros.nmcidade 
                tt-prop-seguros.cdufresd
                rel_dsmorada
                rel_dsocupac
                rel_dtinivig
                rel_dtfimvig WITH FRAME f_autori_casa_c_w_2.
        
        ASSIGN aux2_contador = 0.

        FOR EACH tt-gar-seg WHERE
                 tt-gar-seg.cdcooper = par_cdcooper  AND
                 tt-gar-seg.cdsegura = tt-prop-seguros.cdsegura  AND
                 tt-gar-seg.tpseguro = tt-prop-seguros.tpseguro  AND
                 tt-gar-seg.tpplaseg = tt-prop-seguros.tpplaseg:

            ASSIGN aux2_contador = aux2_contador + 1.
            DISP STREAM str_1
                tt-gar-seg.dsgarant
                tt-gar-seg.vlgarant AT 52  
                WITH FRAME f_autori_casa_2.

            DOWN STREAM str_1 WITH FRAME f_autori_casa_2.
             
        END.

        DISPLAY STREAM str_1 WITH FRAME f_autori_casa_franq1.
            
        FOR EACH tt-gar-seg WHERE
                 tt-gar-seg.cdcooper = par_cdcooper  AND
                 tt-gar-seg.cdsegura = tt-prop-seguros.cdsegura  AND
                 tt-gar-seg.tpseguro = tt-prop-seguros.tpseguro  AND
                 tt-gar-seg.tpplaseg = tt-prop-seguros.tpplaseg:

            IF tt-gar-seg.dsfranqu <> " " THEN
                DO:
                    ASSIGN aux2_contador = aux2_contador + 1.
                    DISP STREAM str_1
                        tt-gar-seg.dsfranqu   
                        WITH FRAME f_autori_casa_franq2.

                    DOWN STREAM str_1 WITH FRAME f_autori_casa_franq2.
                END.
             
        END.

        FIND FIRST crapope NO-LOCK WHERE
                   crapope.cdcooper = par_cdcooper AND 
                   crapope.cdoperad = par_cdoperad NO-ERROR.

        ASSIGN rel_nrdconta2 = par_nrdconta
               aux_premitot  = tt-prop-seguros.vlpreseg * 12
               aux_premliqu  = aux_premitot / ((aux_valoriof / 100) + 1)
               aux_vliofper  = STRING(aux_valoriof) + "%".
        
        DISP STREAM str_1
            aux_premliqu 
            aux_vliofper 
            aux_premitot 
            WITH FRAME f_autori_casa_compl.

        /* Propostas com inicio de vigencia maior ou igual a 06/04/2015 */
        IF  rel_dtinivig >= 04/06/2015 THEN
            DO:
                ASSIGN 
                aux_casa3325 = "este instrumento  de  mandato, outorgo  a  LAZAM  -  MDS Corretora e\033\110"
                aux_casa0401 = "\033\107Administradora de Seguros S/A, inscrita no  CNPJ 48.114.367/0002-43,"
                aux_casa0402 = "com  endereco  na  Rua  Ingo  Hering,  20  -  Blumenau/SC,  registro"
                aux_casa0403 = "SUSEP  100059188  e  a    Cooperativa  Central  de  Credito  Urbano,"
                aux_casa0404 = "inscrita no CNPJ 05.463.212/0001-29, os poderes especificos  para  a"
                aux_casa0405 = "contratacao do seguro objeto da presente proposta, com o objetivo de"
                aux_casa0406 = "garantir os  riscos  futuros,  na forma estabelecida  nas  condicoes"
                aux_casa0407 = "contratuais deste seguro, podendo o presente ser revogado a qualquer"
                aux_casa0408 = "momento,  mediante  minha  expressa manifestacao.\033\110           "
                aux_casa4307 = "* Equipamentos portateis,  incluindo   palmtops,   telefone celular,"
                aux_casa4308 = "pager, aparelhos  de  mp3,  IPOD's,  receptores GPS,   transmissores"
                aux_casa4309 = "portateis e similares;                                              "
                aux_casa0611 = "_____________________________________________________  "
                aux_casa0614 = "_____________________________________________________"
                aux_casa0617 = "_____________________________________________________  "
                aux_casa0618 = "LAZAM - MDS Corretora e Administradora de Seguros S/A"
                aux_casa0619 = "SUSEP: 100059188".
            END.
        ELSE
            DO:
                ASSIGN 
                aux_casa3325 = "este instrumento  de  mandato,  outorgo  a  ADDmakler,  inscrita  no\033\110"
                aux_casa0401 = "\033\107CNPJ 85.326.522/0001-09, com endereco  na  Rua  Ingo  Hering,  20  -"
                aux_casa0402 = "Blumenau/SC,  registro  SUSEP  029.224.101.290-20  e  a  Cooperativa"
                aux_casa0403 = "Central de Credito Urbano, inscrita no CNPJ  05.463.212/0001-29,  os"
                aux_casa0404 = "poderes especificos para a contratacao do seguro objeto da  presente"
                aux_casa0405 = "proposta, com o objetivo de garantir os  riscos  futuros,  na  forma"
                aux_casa0406 = "estabelecida  nas  condicoes contratuais  deste  seguro,  podendo  o"
                aux_casa0407 = "presente ser revogado a qualquer momento,  mediante  minha  expressa"
                aux_casa0408 = "manifestacao.\033\110                                               "
                aux_casa4307 = "* Equipamentos portateis, incluindo  notebooks,  laptops,  palmtops,"
                aux_casa4308 = "telefone celular, pager, aparelhos de  mp3, IPOD's,  receptores GPS,"
                aux_casa4309 = "transmissores portateis e similares;                                "
                aux_casa0611 = "_____________________________________________          "
                aux_casa0614 = "_____________________________________________"
                aux_casa0617 = "_____________________________________________          "
                aux_casa0618 = "Add Makler Corretora de Seguros"
                aux_casa0619 = "SUSEP: 02922410129020".
            END.
        
        DISP STREAM str_1 WITH FRAME f_autori_casa_3.
        DISP STREAM str_1 WITH FRAME f_autori_casa_3_1.

		/* Propostas com inicio de vigencia maior ou igual a 20/06/2017 */
        IF  rel_dtinivig > 06/20/2017 THEN 
			DO:
				DISP STREAM str_1 WITH FRAME f_autori_casa_3_2.
				
				DISP STREAM str_1 
				 aux_casa3325
				 WITH FRAME f_autori_casa_3_3.
				 
				DISP STREAM str_1
 					 aux_casa0401 
					 aux_casa0402
					 aux_casa0403
					 aux_casa0404
					 aux_casa0405
					 aux_casa0406
					 aux_casa0407
					 aux_casa0408
					 WITH FRAME f_autori_casa_4.
				
				DISP STREAM str_1 WITH FRAME f_autori_casa_4_1.
				
				DISP STREAM str_1 WITH FRAME f_autori_casa_4_2.

				DISP STREAM str_1
					 aux_casa4307
					 aux_casa4308
					 aux_casa4309
					 WITH FRAME f_autori_casa_4_3.

				DISP STREAM str_1 WITH FRAME f_autori_casa_4_4.
				
				DISP STREAM str_1 
					 rel_nrdconta2
					 WITH FRAME f_autori_casa_5.
			END.
		ELSE
			DO:
				DISP STREAM str_1 WITH FRAME f_autori_casa_3_2_1.
				
				DISP STREAM str_1 
				 aux_casa3325
				 WITH FRAME f_autori_casa_3_3_1.
				 
				DISP STREAM str_1
 					 aux_casa0401 
					 aux_casa0402
					 aux_casa0403
					 aux_casa0404
					 aux_casa0405
					 aux_casa0406
					 aux_casa0407
					 aux_casa0408
					 WITH FRAME f_autori_casa_4.
				
				DISP STREAM str_1 WITH FRAME f_autori_casa_4_1_1.
				
				DISP STREAM str_1 WITH FRAME f_autori_casa_4_2.

				DISP STREAM str_1
					 aux_casa4307
					 aux_casa4308
					 aux_casa4309
					 WITH FRAME f_autori_casa_4_3.

				DISP STREAM str_1 WITH FRAME f_autori_casa_4_4.

				DISP STREAM str_1 
					 rel_nrdconta2
					 WITH FRAME f_autori_casa_5_1_1.
			END.

        DISP STREAM str_1
            rel_nrctrseg 
            tt-prop-seguros.tpplaseg
            rel_ddvencto 
            rel_dsparcel
            aux_casa0611
            tt-prop-seguros.nmdsegur @ rel_dsseguro
            aux_casa0614
            crapope.nmoperad
            aux_casa0617
            aux_casa0618
            aux_casa0619
            par_nrdconta @ rel_nrdconta3
            WITH FRAME f_autori_casa_6.

        EMPTY TEMP-TABLE tt-erro.
                
        OUTPUT STREAM str_1 CLOSE.        

        /** Copiar pdf para visualizacao no Ayllos WEB **/
        IF  par_idorigem = 5  THEN
            DO:
                RUN sistema/generico/procedures/b1wgen0024.p
                    PERSISTENT SET h-b1wgen0024.
                
                RUN gera-pdf-impressao-sem-pcl IN h-b1wgen0024 
                                              (INPUT aux_nmarqimp,
                                               INPUT aux_nmarqpdf).
                 
                DELETE PROCEDURE h-b1wgen0024.       

                IF  SEARCH(aux_nmarqpdf) = ?  THEN
                    DO: 
                        ASSIGN aux_dscritic = "Nao foi possivel " +
                                              "gerar a impressao.".
                        LEAVE carrega.
                    END. 

                UNIX SILENT VALUE ('sudo /usr/bin/su - scpuser -c ' +
                '"scp ' + aux_nmarqpdf + ' scpuser@' + aux_srvintra +
                ':/var/www/ayllos/documentos/' + tt-cooperativa.dsdircop +
                '/temp/" 2>/dev/null').
            END.

        IF  par_idorigem = 5  THEN
            UNIX SILENT VALUE ("rm " + aux_nmarquiv + "* 2>/dev/null").
        ELSE
            UNIX SILENT VALUE ("rm " + aux_nmarqpdf + " 2>/dev/null").
        
        ASSIGN par_nmarqpdf =
            ENTRY(NUM-ENTRIES(aux_nmarqpdf,"/"),aux_nmarqpdf,"/").

    END. /* carrega */

    EMPTY TEMP-TABLE tt-erro.

    IF  aux_cdcritic <> 0    OR
        aux_dscritic <> ""   THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF   par_flgerlog  THEN
                RUN proc_gerar_log (INPUT  par_cdcooper,
                                    INPUT  par_cdoperad,
                                    INPUT  aux_dscritic,
                                    INPUT  aux_dsorigem,
                                    INPUT  aux_dstransa,
                                    INPUT  FALSE,
                                    INPUT  par_idseqttl,
                                    INPUT  par_nmdatela,
                                    INPUT  par_nrdconta,
                                    OUTPUT aux_nrdrowid).   
            
            RETURN "NOK".
        END.

            
    IF  par_flgerlog  THEN
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

    RETURN "OK".
END PROCEDURE.

PROCEDURE imprimir_alt_seg_vida:
    DEF INPUT PARAM par_cdcooper AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                       NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                       NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                       NO-UNDO. 
    DEF INPUT PARAM par_nmdatela AS CHAR                       NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                       NO-UNDO.
    DEF INPUT PARAM par_tpseguro LIKE craptsg.tpseguro         NO-UNDO.
    DEF INPUT PARAM par_tpplaseg LIKE craptsg.tpplaseg         NO-UNDO.
    DEF INPUT PARAM par_cdsegura LIKE crapseg.cdsegura         NO-UNDO.    
    DEF INPUT PARAM par_nrctrseg LIKE crapseg.nrctrseg         NO-UNDO.
    DEF INPUT PARAM par_nmendter AS CHAR FORMAT "x(20)"        NO-UNDO.
    DEF INPUT PARAM par_reccraws AS CHAR                       NO-UNDO. 
    DEF INPUT PARAM par_cddopcao AS CHAR                       NO-UNDO.

    DEF OUTPUT PARAM par_nmarqimp AS CHAR                      NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                      NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF BUFFER b-tt-seguros FOR tt-seguros.

    DEF VAR aux_nmarquiv AS CHAR                               NO-UNDO.
    DEF VAR aux_nmarqpdf AS CHAR                               NO-UNDO.
    DEF VAR aux_qtsegass AS INTE                               NO-UNDO.
    DEF VAR aux_vltotseg AS DECI                               NO-UNDO.
    DEF VAR aux_dsmesref AS CHAR                               NO-UNDO.
    
    DEF VAR aux_nmarqtmp AS CHAR                               NO-UNDO.
    DEF VAR aux_nrpagina AS INT                                NO-UNDO.
    DEF VAR aux_cdempres LIKE crapemp.cdempres                 NO-UNDO.
    DEF VAR aux_vlsdeved AS DECI                               NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-associado.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0.

    FORM "\022\024\033\115\0332\033x0" WITH NO-BOX NO-LABELS FRAME f_config.
    carrega:
    DO:
        RUN buscar_cooperativa (INPUT par_cdcooper,
                                INPUT par_cdagenci,
                                INPUT par_nrdcaixa,
                                INPUT par_cdoperad,
                                INPUT par_dtmvtolt,
                                INPUT par_nrdconta,
                                INPUT par_idseqttl,
                                INPUT par_idorigem,
                                INPUT par_nmdatela,
                                INPUT par_flgerlog,
                                OUTPUT TABLE tt-cooperativa,
                                OUTPUT TABLE tt-erro).
                    
        IF   RETURN-VALUE <> "OK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                IF   AVAIL tt-erro   THEN
                    DO:
                        ASSIGN aux_cdcritic = tt-erro.cdcritic
                               aux_dscritic = tt-erro.dscritic.
                        EMPTY TEMP-TABLE tt-erro.
                        LEAVE carrega.
                    END.
            END.

        FIND tt-cooperativa WHERE
             tt-cooperativa.cdcooper = par_cdcooper NO-ERROR.
    
        ASSIGN aux_nmarquiv = "/usr/coop/" + tt-cooperativa.dsdircop +
                              "/rl/" + par_nmendter.
    
        UNIX SILENT VALUE("rm " + aux_nmarquiv + "* 2> /dev/null").
    
        ASSIGN aux_nmarquiv = aux_nmarquiv + STRING(TIME)
               par_nmarqimp = aux_nmarquiv + ".lst"
               aux_nmarqpdf = aux_nmarquiv + ".pdf"
               aux_dsmesref = "janeiro,fevereiro,marco,abril," +
                              "maio,junho,julho,agosto,setembro," +
                              "outubro,novembro,dezembro"
            
               aux_nrpagina = 0.
        
        EMPTY TEMP-TABLE tt-prop-seguros.

        RUN buscar_proposta_seguro (INPUT par_cdcooper,
                                    INPUT par_cdagenci,
                                    INPUT par_nrdcaixa,
                                    INPUT par_cdoperad,
                                    INPUT par_dtmvtolt,
                                    INPUT par_nrdconta,
                                    INPUT par_idseqttl,
                                    INPUT par_idorigem,
                                    INPUT par_nmdatela,
                                    INPUT par_flgerlog,
                                    OUTPUT TABLE tt-prop-seguros,
                                    OUTPUT aux_qtsegass,
                                    OUTPUT aux_vltotseg,
                                    OUTPUT TABLE tt-erro).

        IF   RETURN-VALUE <> "OK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                IF   AVAIL tt-erro   THEN
                    DO:
                        ASSIGN aux_cdcritic = tt-erro.cdcritic
                               aux_dscritic = tt-erro.dscritic.
                        EMPTY TEMP-TABLE tt-erro.
                        LEAVE carrega.
                    END.
            END.
                
        IF  par_reccraws <> "" THEN
            FIND FIRST tt-prop-seguros WHERE
                       STRING(tt-prop-seguros.registro) = par_reccraws NO-ERROR.
        /* Caso receber o contrato como parametro
         utiliza-lo como filtro */
        ELSE IF par_nrctrseg <> 0 THEN
            FIND LAST tt-prop-seguros WHERE
                      tt-prop-seguros.cdcooper = par_cdcooper  AND
                      tt-prop-seguros.nrdconta = par_nrdconta  AND
                      tt-prop-seguros.tpseguro = par_tpseguro AND
                      tt-prop-seguros.nrctrseg = par_nrctrseg  
                      NO-LOCK NO-ERROR.
        ELSE
            FIND LAST tt-prop-seguros WHERE
                      tt-prop-seguros.cdcooper = par_cdcooper  AND
                      tt-prop-seguros.nrdconta = par_nrdconta  AND
                      tt-prop-seguros.tpseguro = par_tpseguro 
                      NO-LOCK NO-ERROR.
            
        IF  NOT AVAIL tt-prop-seguros THEN
            DO:
                 ASSIGN aux_cdcritic = 535.
                 EMPTY TEMP-TABLE tt-erro.
                 LEAVE carrega.
             END.           

        EMPTY TEMP-TABLE tt-seguros.

        RUN busca_seguros (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT par_cdoperad,
                           INPUT par_dtmvtolt,
                           INPUT par_nrdconta,
                           INPUT par_idseqttl,
                           INPUT par_idorigem,
                           INPUT par_nmdatela,
                           INPUT par_flgerlog,
                           OUTPUT TABLE tt-seguros,
                           OUTPUT aux_qtsegass,
                           OUTPUT aux_vltotseg,
                           OUTPUT TABLE tt-erro).

        IF   RETURN-VALUE <> "OK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                IF   AVAIL tt-erro   THEN
                    DO:
                        ASSIGN aux_cdcritic = tt-erro.cdcritic
                               aux_dscritic = tt-erro.dscritic.
                        EMPTY TEMP-TABLE tt-erro.
                        LEAVE carrega.
                    END.
            END.

        FIND FIRST tt-seguros WHERE
              tt-seguros.cdcooper = par_cdcooper   AND
              tt-seguros.nrdconta = par_nrdconta   AND
              tt-seguros.tpseguro = tt-prop-seguros.tpseguro   AND
              tt-seguros.nrctrseg = tt-prop-seguros.nrctrseg   NO-ERROR.

        EMPTY TEMP-TABLE tt-associado.
            
        RUN buscar_associados (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT par_cdoperad,
                               INPUT par_dtmvtolt,
                               INPUT par_nrdconta,
                               INPUT par_idseqttl,
                               INPUT par_idorigem,
                               INPUT par_nmdatela,
                               INPUT par_flgerlog,
                               OUTPUT TABLE tt-associado,
                               OUTPUT TABLE tt-erro).

        IF   RETURN-VALUE <> "OK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                IF   AVAIL tt-erro   THEN
                    DO:
                        ASSIGN aux_cdcritic = tt-erro.cdcritic
                               aux_dscritic = tt-erro.dscritic.
                        EMPTY TEMP-TABLE tt-erro.
                        LEAVE carrega.
                    END.
            END.

        EMPTY TEMP-TABLE tt-titular.
            
        RUN buscar_titular (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT par_cdoperad,
                            INPUT par_dtmvtolt,
                            INPUT par_nrdconta,
                            INPUT par_idseqttl,
                            INPUT par_idorigem,
                            INPUT par_nmdatela,
                            INPUT par_flgerlog,
                            OUTPUT TABLE tt-titular,
                            OUTPUT TABLE tt-erro).

        IF   RETURN-VALUE <> "OK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                IF   AVAIL tt-erro   THEN
                    DO:
                        ASSIGN aux_cdcritic = tt-erro.cdcritic
                               aux_dscritic = tt-erro.dscritic.
                        EMPTY TEMP-TABLE tt-erro.
                        LEAVE carrega.
                    END.
            END.

        FIND FIRST tt-titular WHERE
                   tt-titular.cdcooper = par_cdcooper          AND
                   tt-titular.nrdconta = par_nrdconta AND
                   tt-titular.idseqttl = par_idseqttl NO-ERROR.

        RUN buscar_plano_seguro (INPUT  tt-prop-seguros.cdcooper,
                                 INPUT  par_cdagenci,
                                 INPUT  par_nrdcaixa,
                                 INPUT  par_cdoperad,
                                 INPUT  par_dtmvtolt,
                                 INPUT  tt-prop-seguros.nrdconta,
                                 INPUT  par_idseqttl,
                                 INPUT  par_idorigem,
                                 INPUT  par_nmdatela,
                                 INPUT  par_flgerlog,
                                 INPUT  tt-prop-seguros.cdsegura,
                                 INPUT  tt-prop-seguros.tpseguro,
                                 INPUT  tt-prop-seguros.tpplaseg,
                                 OUTPUT TABLE tt-plano-seg,
                                 OUTPUT TABLE tt-erro).

        IF   RETURN-VALUE <> "OK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                IF   AVAIL tt-erro   THEN
                    DO:
                        ASSIGN aux_cdcritic = tt-erro.cdcritic
                               aux_dscritic = tt-erro.dscritic.
                        EMPTY TEMP-TABLE tt-erro.
                        LEAVE carrega.
                    END.
            END.

        FIND tt-plano-seg NO-ERROR.

        FIND FIRST tt-associado WHERE
                   tt-associado.cdcooper = par_cdcooper  AND
                   tt-associado.nrdconta = par_nrdconta  NO-ERROR.


        IF  NOT AVAILABLE tt-plano-seg  THEN
            ASSIGN tel_dscobert = "".
        ELSE
            ASSIGN tel_dscobert = tt-plano-seg.dsmorada
                   aux_idadelmt = tt-plano-seg.nrtabela
                   aux_idadelm2 = tt-plano-seg.nrtabela.

         IF  par_cddopcao = "A" OR par_cddopcao = "ALTERAR" THEN
            ASSIGN aux_comprela = " - Alteracao de Beneficiario".
        ELSE
            ASSIGN aux_comprela = "".

        /* estado civil */
        FIND crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                           crapttl.nrdconta = par_nrdconta AND
                           crapttl.idseqttl = 1 NO-LOCK.
        IF  AVAIL crapttl THEN
            FIND FIRST gnetcvl NO-LOCK WHERE
                       gnetcvl.cdestcvl = crapttl.cdestcvl NO-ERROR.

        ASSIGN
         rel_dsmvtolt =
              TRIM(tt-cooperativa.nmcidade) + ", "                      +
              STRING(DAY(tt-prop-seguros.dtmvtolt)) + " DE "            +
              CAPS(ENTRY(MONTH(tt-prop-seguros.dtmvtolt),aux_dsmesref)) +
              " DE " + STRING(YEAR(tt-prop-seguros.dtmvtolt)) + "."
        
         rel_nmprimtl =
              IF (tt-prop-seguros.tpseguro = 3 AND
                  tt-prop-seguros.tpsegvid = 2 AND 
                  tt-prop-seguros.nrcpfcgc = STRING(tt-associado.nrcpfstl))
              THEN tt-prop-seguros.nmdsegur
              ELSE tt-associado.nmprimtl
        
         rel_nmdsegur =
              IF (tt-prop-seguros.tpsegvid = 2 AND 
                  tt-prop-seguros.nrcpfcgc = STRING(tt-associado.nrcpfstl)) OR
                 (tt-prop-seguros.tpsegvid = 1)
              THEN ""
              ELSE tt-prop-seguros.nmdsegur
                            
         rel_tracoseg =
              IF (tt-prop-seguros.tpsegvid = 2 AND
                  tt-prop-seguros.nrcpfcgc = STRING(tt-associado.nrcpfstl)) OR
                 (tt-prop-seguros.tpsegvid = 1)
              THEN ""
              ELSE "----------------------------------------"
        
         rel_nrdconta[1] = tt-prop-seguros.nrdconta
         rel_nrdconta[2] = tt-prop-seguros.nrdconta
         rel_ddvencto = DAY(tt-prop-seguros.dtdebito)
         
         rel_ddvencto = IF   rel_ddvencto > 28 
                        THEN 28
                        ELSE rel_ddvencto
                            
         seg_nrcpfcgc = tt-prop-seguros.nrcpfcgc
         seg_dsestcvl = IF  AVAIL gnetcvl THEN gnetcvl.rsestcvl ELSE " "
         seg_dssexotl = IF   tt-prop-seguros.cdsexosg = 1
                        THEN "MASCULINO"
                        ELSE "FEMININO"
         aux_nrcntseg = tt-prop-seguros.nrdconta
         aux_nrctrseg = tt-prop-seguros.nrctrseg
         aux_dssegvid = IF tt-prop-seguros.tpsegvid = 2
                        THEN "     CONJUGE" 
                        ELSE "     TITULAR" 
        
         aux_dssegvid = IF tt-prop-seguros.tpseguro = 4
                        THEN "     PRESTAMISTA" 
                        ELSE aux_dssegvid .

        /* Se for prestamista */
        IF  tt-prop-seguros.tpseguro = 4 THEN
            DO:
                RUN saldo-devedor-cpf (INPUT par_cdcooper,
                                       INPUT par_dtmvtolt,
                                       INPUT par_cdoperad,
                                       INPUT tt-prop-seguros.nrcpfcgc,
                                      OUTPUT aux_vlsdeved,
                                      OUTPUT aux_dscritic).
        
                IF  RETURN-VALUE <> "OK" THEN
                    LEAVE carrega.

                ASSIGN aux_vlmorada = aux_vlsdeved.
            END.
        ELSE
            ASSIGN aux_vlmorada = tt-plano-seg.vlmorada.

        OUTPUT STREAM str_1 TO VALUE(par_nmarqimp) PAGED PAGE-SIZE 87.

        VIEW STREAM str_1 FRAME f_config.
        
        /* Primeira via */
        DISPLAY STREAM str_1
        tt-cooperativa.nmextcop    aux_comprela aux_dssegvid    aux_nrcntseg
        aux_nrctrseg                tt-prop-seguros.nrdconta    
        tt-associado.cdagenci       tt-prop-seguros.nmdsegur    seg_nrcpfcgc
        seg_dsestcvl                tt-prop-seguros.dtnascsg    seg_dssexotl
        tt-prop-seguros.dsendres    tt-prop-seguros.nmbairro
        tt-prop-seguros.nmcidade    tt-prop-seguros.cdufresd
        tt-prop-seguros.nrcepend    tt-prop-seguros.nrctrseg
        tt-prop-seguros.dtinivig    tt-prop-seguros.tpplaseg
        tt-plano-seg.vlplaseg       aux_vlmorada                 rel_ddvencto
        tel_dscobert
        tt-seguros.nmbenvid[1] tt-seguros.dsgraupr[1] tt-seguros.txpartic[1]
                                           WHEN tt-seguros.txpartic[1] > 0
        tt-seguros.nmbenvid[2] tt-seguros.dsgraupr[2] tt-seguros.txpartic[2]
                                           WHEN tt-seguros.txpartic[2] > 0
        tt-seguros.nmbenvid[3] tt-seguros.dsgraupr[3] tt-seguros.txpartic[3]
                                           WHEN tt-seguros.txpartic[3] > 0
        tt-seguros.nmbenvid[4] tt-seguros.dsgraupr[4] tt-seguros.txpartic[4]
                                           WHEN tt-seguros.txpartic[4] > 0
        tt-seguros.nmbenvid[5] tt-seguros.dsgraupr[5] tt-seguros.txpartic[5]
                                           WHEN tt-seguros.txpartic[5] > 0
        WITH FRAME f_vida.

        FIND FIRST crapope NO-LOCK           WHERE
             crapope.cdcooper = par_cdcooper AND 
             crapope.cdoperad = par_cdoperad NO-ERROR.

        IF  tt-prop-seguros.tpseguro = 4  THEN
            DISPLAY STREAM str_1 aux_idadelmt aux_idadelm2 rel_dsmvtolt 
                           rel_nmprimtl rel_nrdconta[2] 
                           rel_nmdsegur rel_tracoseg crapope.nmoperad
            WITH FRAME f_prestamista.
        ELSE
            DISPLAY STREAM str_1 rel_dsmvtolt rel_nmprimtl rel_nrdconta[2] 
                           rel_nmdsegur rel_tracoseg crapope.nmoperad
            WITH FRAME f_nao_prestamista.

        /* Segunda via */

        PAGE STREAM str_1.

        DISPLAY STREAM str_1
        tt-cooperativa.nmextcop   aux_comprela aux_dssegvid   aux_nrcntseg   
        aux_nrctrseg  tt-prop-seguros.nrdconta   tt-associado.cdagenci
        tt-prop-seguros.nmdsegur
        seg_nrcpfcgc   seg_dsestcvl   tt-prop-seguros.dtnascsg   seg_dssexotl
        tt-prop-seguros.dsendres   tt-prop-seguros.nmbairro
        tt-prop-seguros.nmcidade   tt-prop-seguros.cdufresd
        tt-prop-seguros.nrcepend   tt-prop-seguros.nrctrseg
        tt-prop-seguros.dtinivig   tt-prop-seguros.tpplaseg
        tt-plano-seg.vlplaseg      aux_vlmorada                  rel_ddvencto
        tel_dscobert   tt-seguros.nmbenvid[1]   tt-seguros.dsgraupr[1]
        tt-seguros.txpartic[1] WHEN tt-seguros.txpartic[1] > 0
        tt-seguros.nmbenvid[2]   tt-seguros.dsgraupr[2]
        tt-seguros.txpartic[2] WHEN tt-seguros.txpartic[2] > 0
        tt-seguros.nmbenvid[3]   tt-seguros.dsgraupr[3]   tt-seguros.txpartic[3]
            WHEN tt-seguros.txpartic[3] > 0
        tt-seguros.nmbenvid[4]   tt-seguros.dsgraupr[4]   tt-seguros.txpartic[4]
            WHEN tt-seguros.txpartic[4] > 0
        tt-seguros.nmbenvid[5]   tt-seguros.dsgraupr[5]   tt-seguros.txpartic[5]
            WHEN tt-seguros.txpartic[5] > 0
        WITH FRAME f_vida.

        IF  tt-prop-seguros.tpseguro = 4  THEN
            DISPLAY STREAM str_1
            aux_idadelmt   aux_idadelm2   rel_dsmvtolt   rel_nmprimtl
            rel_nrdconta[2]   rel_nmdsegur   rel_tracoseg   crapope.nmoperad
            WITH FRAME f_prestamista.
        ELSE
            DISPLAY STREAM str_1
            rel_dsmvtolt   rel_nmprimtl   rel_nrdconta[2]   rel_nmdsegur
            rel_tracoseg   crapope.nmoperad
                WITH FRAME f_nao_prestamista.

        /*IF  tt-prop-seguros.tpseguro <> 4 THEN
            DO:
                /* Terceira via */
                PAGE STREAM str_1.

                DISPLAY STREAM str_1
                    tt-cooperativa.nmextcop   aux_comprela aux_dssegvid    
                    aux_nrcntseg  aux_nrctrseg   tt-prop-seguros.nrdconta
                    tt-associado.cdagenci
                    tt-prop-seguros.nmdsegur   seg_nrcpfcgc   seg_dsestcvl
                    tt-prop-seguros.dtnascsg   seg_dssexotl
                    tt-prop-seguros.dsendres   tt-prop-seguros.nmbairro
                    tt-prop-seguros.nmcidade   tt-prop-seguros.cdufresd
                    tt-prop-seguros.nrcepend   tt-prop-seguros.nrctrseg
                    tt-prop-seguros.dtinivig   tt-prop-seguros.tpplaseg
                    tt-plano-seg.vlplaseg      aux_vlmorada
                    rel_ddvencto   tel_dscobert
                    tt-seguros.nmbenvid[1]   tt-seguros.dsgraupr[1]
                    tt-seguros.txpartic[1]
                       WHEN tt-seguros.txpartic[1] > 0
                    tt-seguros.nmbenvid[2]   tt-seguros.dsgraupr[2]
                    tt-seguros.txpartic[2] 
                       WHEN tt-seguros.txpartic[2] > 0
                    tt-seguros.nmbenvid[3]   tt-seguros.dsgraupr[3]
                    tt-seguros.txpartic[3] 
                       WHEN tt-seguros.txpartic[3] > 0
                    tt-seguros.nmbenvid[4]   tt-seguros.dsgraupr[4]
                    tt-seguros.txpartic[4] 
                       WHEN tt-seguros.txpartic[4] > 0
                    tt-seguros.nmbenvid[5]   tt-seguros.dsgraupr[5]
                    tt-seguros.txpartic[5]
                       WHEN tt-seguros.txpartic[5] > 0
                WITH FRAME f_vida.

                DISPLAY STREAM str_1
                    rel_dsmvtolt   rel_nmprimtl   rel_nrdconta[2]
                    rel_nmdsegur   rel_tracoseg   crapope.nmoperad
                WITH FRAME f_nao_prestamista.

                /* Quarta via */

                PAGE STREAM str_1.

                DISPLAY STREAM str_1
                    tt-cooperativa.nmextcop  aux_comprela aux_dssegvid    
                    aux_nrcntseg  aux_nrctrseg   tt-prop-seguros.nrdconta
                    tt-associado.cdagenci
                    tt-prop-seguros.nmdsegur   seg_nrcpfcgc   seg_dsestcvl
                    tt-prop-seguros.dtnascsg   seg_dssexotl
                    tt-prop-seguros.dsendres   tt-prop-seguros.nmbairro
                    tt-prop-seguros.nmcidade   tt-prop-seguros.cdufresd
                    tt-prop-seguros.nrcepend   tt-prop-seguros.nrctrseg
                    tt-prop-seguros.dtinivig   tt-prop-seguros.tpplaseg
                    tt-plano-seg.vlplaseg      aux_vlmorada
                    rel_ddvencto   tel_dscobert   tt-seguros.nmbenvid[1]
                    tt-seguros.dsgraupr[1]   tt-seguros.txpartic[1] 
                       WHEN tt-seguros.txpartic[1] > 0
                    tt-seguros.nmbenvid[2]   tt-seguros.dsgraupr[2]
                    tt-seguros.txpartic[2] 
                       WHEN tt-seguros.txpartic[2] > 0
                    tt-seguros.nmbenvid[3]   tt-seguros.dsgraupr[3]
                    tt-seguros.txpartic[3] 
                       WHEN tt-seguros.txpartic[3] > 0
                    tt-seguros.nmbenvid[4]   tt-seguros.dsgraupr[4]
                    tt-seguros.txpartic[4] 
                       WHEN tt-seguros.txpartic[4] > 0
                    tt-seguros.nmbenvid[5]   tt-seguros.dsgraupr[5]
                    tt-seguros.txpartic[5]
                       WHEN tt-seguros.txpartic[5] > 0
                WITH FRAME f_vida.

                DISPLAY STREAM str_1
                    rel_dsmvtolt   rel_nmprimtl   rel_nrdconta[2]
                    rel_nmdsegur   rel_tracoseg   crapope.nmoperad 
                WITH FRAME f_nao_prestamista.
            END. */           

        OUTPUT STREAM str_1 CLOSE.

        RUN sistema/generico/procedures/b1wgen0024.p
            PERSISTENT SET h-b1wgen0024.
        
        RUN gera-pdf-impressao IN h-b1wgen0024 (INPUT par_nmarqimp,
                                                INPUT aux_nmarqpdf).
        
        DELETE PROCEDURE h-b1wgen0024.

        /** Copiar pdf para visualizacao no Ayllos WEB **/
        IF  par_idorigem = 5  THEN
            DO:
                IF  SEARCH(aux_nmarqpdf) = ?  THEN
                    DO:
                        ASSIGN aux_dscritic = "Nao foi possivel " +
                                              "gerar a impressao.".
                        LEAVE carrega.
                    END.

                UNIX SILENT VALUE ('sudo /usr/bin/su - scpuser -c ' +
                '"scp ' + aux_nmarqpdf + ' scpuser@' + aux_srvintra +
                ':/var/www/ayllos/documentos/' + tt-cooperativa.dsdircop +
                '/temp/" 2>/dev/null').
            END.

        IF  par_idorigem = 5  THEN
            UNIX SILENT VALUE ("rm " + aux_nmarquiv + "* 2>/dev/null").
        ELSE
            UNIX SILENT VALUE ("rm " + aux_nmarqpdf + " 2>/dev/null").
        
        ASSIGN par_nmarqpdf =
            ENTRY(NUM-ENTRIES(aux_nmarqpdf,"/"),aux_nmarqpdf,"/").
    END.

    EMPTY TEMP-TABLE tt-erro.

    IF  aux_cdcritic <> 0    OR
        aux_dscritic <> ""   THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF   par_flgerlog  THEN
                RUN proc_gerar_log (INPUT  par_cdcooper,
                                    INPUT  par_cdoperad,
                                    INPUT  aux_dscritic,
                                    INPUT  aux_dsorigem,
                                    INPUT  aux_dstransa,
                                    INPUT  FALSE,
                                    INPUT  par_idseqttl,
                                    INPUT  par_nmdatela,
                                    INPUT  par_nrdconta,
                                    OUTPUT aux_nrdrowid).   
            
            RETURN "NOK".
        END.

            
    IF  par_flgerlog  THEN
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

    RETURN "OK".
END PROCEDURE.

PROCEDURE buscar_titular:
    DEF INPUT PARAM par_cdcooper AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                       NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                       NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                       NO-UNDO. 
    DEF INPUT PARAM par_nmdatela AS CHAR                       NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                       NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-titular.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-titular.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0.

    FIND FIRST crapttl NO-LOCK WHERE
               crapttl.cdcooper = par_cdcooper  AND
               crapttl.nrdconta = par_nrdconta  AND
               crapttl.idseqttl = par_idseqttl  NO-ERROR.
    IF AVAIL crapttl THEN
        DO:
            CREATE tt-titular.
            BUFFER-COPY crapttl TO tt-titular.
        END.
    ELSE
        DO:
            ASSIGN aux_dscritic = "Titular nao encontrado.".
        END.

    EMPTY TEMP-TABLE tt-erro.

    IF  aux_cdcritic <> 0    OR
        aux_dscritic <> ""   THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF   par_flgerlog  THEN
                RUN proc_gerar_log (INPUT  par_cdcooper,
                                    INPUT  par_cdoperad,
                                    INPUT  aux_dscritic,
                                    INPUT  aux_dsorigem,
                                    INPUT  aux_dstransa,
                                    INPUT  FALSE,
                                    INPUT  par_idseqttl,
                                    INPUT  par_nmdatela,
                                    INPUT  par_nrdconta,
                                    OUTPUT aux_nrdrowid).   
            
            RETURN "NOK".
        END.

            
    IF  par_flgerlog  THEN
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

    RETURN "OK".
END PROCEDURE.

PROCEDURE buscar_empresa:
    DEF INPUT PARAM par_cdcooper AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                       NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                       NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                       NO-UNDO. 
    DEF INPUT PARAM par_nmdatela AS CHAR                       NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                       NO-UNDO.
    DEF INPUT PARAM par_cdempres LIKE crapemp.cdempres         NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-empresa.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-empresa.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0.

    FIND FIRST crapemp NO-LOCK WHERE
               crapemp.cdcooper = par_cdcooper  AND
               crapemp.cdempres = par_cdempres  NO-ERROR.
    IF AVAIL crapemp THEN
        DO:
            CREATE tt-empresa.
            BUFFER-COPY crapemp TO tt-empresa.
        END.
    ELSE
        DO:
            ASSIGN aux_cdcritic = 40.
        END.

    EMPTY TEMP-TABLE tt-erro.

    IF  aux_cdcritic <> 0    OR
        aux_dscritic <> ""   THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF   par_flgerlog  THEN
                RUN proc_gerar_log (INPUT  par_cdcooper,
                                    INPUT  par_cdoperad,
                                    INPUT  aux_dscritic,
                                    INPUT  aux_dsorigem,
                                    INPUT  aux_dstransa,
                                    INPUT  FALSE,
                                    INPUT  par_idseqttl,
                                    INPUT  par_nmdatela,
                                    INPUT  par_nrdconta,
                                    OUTPUT aux_nrdrowid).   
            
            RETURN "NOK".
        END.

            
    IF  par_flgerlog  THEN
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

    RETURN "OK".
END PROCEDURE.

PROCEDURE buscar_pessoa_juridica:
    DEF INPUT PARAM par_cdcooper AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                       NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                       NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                       NO-UNDO. 
    DEF INPUT PARAM par_nmdatela AS CHAR                       NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                       NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-pess-jur.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-pess-jur.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0.

    FIND FIRST crapjur NO-LOCK WHERE
               crapjur.cdcooper = par_cdcooper  AND
               crapjur.nrdconta = par_nrdconta  NO-ERROR.
    IF AVAIL crapjur THEN
        DO:
            CREATE tt-pess-jur.
            BUFFER-COPY crapjur TO tt-pess-jur.
        END.
    ELSE
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Cadastro pessoa juridica não encontrado.".

    EMPTY TEMP-TABLE tt-erro.

    IF  aux_cdcritic <> 0    OR
        aux_dscritic <> ""   THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF   par_flgerlog  THEN
                RUN proc_gerar_log (INPUT  par_cdcooper,
                                    INPUT  par_cdoperad,
                                    INPUT  aux_dscritic,
                                    INPUT  aux_dsorigem,
                                    INPUT  aux_dstransa,
                                    INPUT  FALSE,
                                    INPUT  par_idseqttl,
                                    INPUT  par_nmdatela,
                                    INPUT  par_nrdconta,
                                    OUTPUT aux_nrdrowid).   
            
            RETURN "NOK".
        END.

            
    IF  par_flgerlog  THEN
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

    RETURN "OK".
END PROCEDURE.

PROCEDURE buscar_cooperativa:
    DEF INPUT PARAM par_cdcooper AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                       NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                       NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                       NO-UNDO. 
    DEF INPUT PARAM par_nmdatela AS CHAR                       NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                       NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-cooperativa.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-cooperativa.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0.

    FIND FIRST crapcop NO-LOCK WHERE
               crapcop.cdcooper = par_cdcooper NO-ERROR.
    IF AVAIL crapcop THEN
        DO:
            CREATE tt-cooperativa.
            BUFFER-COPY crapcop TO tt-cooperativa.
        END.
    ELSE
        ASSIGN aux_cdcritic = 651.

    EMPTY TEMP-TABLE tt-erro.

    IF  aux_cdcritic <> 0    OR
        aux_dscritic <> ""   THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF   par_flgerlog  THEN
                RUN proc_gerar_log (INPUT  par_cdcooper,
                                    INPUT  par_cdoperad,
                                    INPUT  aux_dscritic,
                                    INPUT  aux_dsorigem,
                                    INPUT  aux_dstransa,
                                    INPUT  FALSE,
                                    INPUT  par_idseqttl,
                                    INPUT  par_nmdatela,
                                    INPUT  par_nrdconta,
                                    OUTPUT aux_nrdrowid).   
            
            RETURN "NOK".
        END.

            
    IF  par_flgerlog  THEN
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

    RETURN "OK".
END PROCEDURE.

PROCEDURE buscar_associados:
    DEF INPUT PARAM par_cdcooper AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                       NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                       NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                       NO-UNDO. 
    DEF INPUT PARAM par_nmdatela AS CHAR                       NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                       NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-associado.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-associado.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0.

    FIND FIRST crapass NO-LOCK WHERE
               crapass.cdcooper = par_cdcooper  AND
               crapass.nrdconta = par_nrdconta NO-ERROR.
    IF AVAIL crapass THEN
        DO:
            CREATE tt-associado.
            BUFFER-COPY crapass TO tt-associado.

			FOR FIRST crapttl FIELDS (nrcpfcgc) 
			    WHERE crapttl.cdcooper = par_cdcooper AND
			          crapttl.nrdconta = par_cdcooper AND
					  crapttl.idseqttl = 2
			          NO-LOCK:

              ASSIGN tt-associado.nrcpfstl = crapttl.nrcpfcgc.

	        END.

			FOR FIRST craptfc FIELDS(nrdddtfc nrtelefo)
		        WHERE craptfc.cdcooper = par_cdcooper AND
			          craptfc.nrdconta = par_nrdconta AND
				  	  craptfc.idseqttl = 1            AND
					  craptfc.tptelefo = 1 /*Residencial*/
					  NO-LOCK:
				    
			  ASSIGN tt-associado.nrfonemp = string(craptfc.nrdddtfc) + string(craptfc.nrtelefo).
				
		    END.

        END.
    ELSE
        ASSIGN aux_cdcritic = 9.

    EMPTY TEMP-TABLE tt-erro.

    IF  aux_cdcritic <> 0    OR
        aux_dscritic <> ""   THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF   par_flgerlog  THEN
                RUN proc_gerar_log (INPUT  par_cdcooper,
                                    INPUT  par_cdoperad,
                                    INPUT  aux_dscritic,
                                    INPUT  aux_dsorigem,
                                    INPUT  aux_dstransa,
                                    INPUT  FALSE,
                                    INPUT  par_idseqttl,
                                    INPUT  par_nmdatela,
                                    INPUT  par_nrdconta,
                                    OUTPUT aux_nrdrowid).   
            
            RETURN "NOK".
        END.

            
    IF  par_flgerlog  THEN
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

    RETURN "OK".
END PROCEDURE.

PROCEDURE gerar_atualizacao_seg:
    DEF INPUT PARAM par_cdcooper AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                       NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                       NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                       NO-UNDO. 
    DEF INPUT PARAM par_nmdatela AS CHAR                       NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                       NO-UNDO.
    DEF INPUT PARAM par_nrtabela LIKE craptsg.nrtabela         NO-UNDO.
    DEF INPUT PARAM par_tpseguro LIKE craptsg.tpseguro         NO-UNDO.
    DEF INPUT PARAM par_tpplaseg LIKE craptsg.tpplaseg         NO-UNDO.
    DEF INPUT PARAM par_vlpercen AS DEC FORMAT "zzz,zz9.9999-" NO-UNDO.
    DEF INPUT PARAM par_dtdebito LIKE crapseg.dtdebito         NO-UNDO.
    DEF INPUT PARAM par_dtdespre AS DATE FORMAT "99/99/9999"   NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-seguros.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_acrescimo AS DEC                               NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0.

    FOR EACH craptsg NO-LOCK WHERE
             craptsg.cdcooper = par_cdcooper  AND
             craptsg.tpseguro = par_tpseguro  AND
             (craptsg.tpplaseg = par_tpplaseg   OR
              par_tpplaseg     = 0)            AND
             (craptsg.nrtabela = par_nrtabela   OR
              par_nrtabela     = 0)
        BREAK BY craptsg.tpseguro
              BY craptsg.tpplaseg 
              BY craptsg.nrtabela:

        IF  FIRST-OF(craptsg.tpseguro) OR
            FIRST-OF(craptsg.tpplaseg) THEN
            DO:
                FOR EACH crapseg NO-LOCK WHERE
                         crapseg.cdcooper = par_cdcooper        AND
                         crapseg.nrdconta > 0:

                    IF  crapseg.tpseguro  = craptsg.tpseguro   AND
                        crapseg.cdsitseg  = 1                  AND
                        crapseg.tpplaseg  = craptsg.tpplaseg   AND
                        crapseg.dtmvtolt  < par_dtdespre       AND
                       (crapseg.dtdebito >= par_dtdebito) 
                        THEN 
                            DO:
                                CREATE tt-seguros.
                                ASSIGN tt-seguros.tpseguro  = crapseg.tpseguro
                                       tt-seguros.tpplaseg  = crapseg.tpplaseg
                                       tt-seguros.dtdebito  = crapseg.dtdebito
                                       tt-seguros.nrseqdig  = crapseg.nrseqdig
                                       tt-seguros.cdagenci  = crapseg.cdagenci
                                       tt-seguros.cdbccxlt  = crapseg.cdbccxlt
                                       tt-seguros.tpendcor  = crapseg.tpendcor
                                       tt-seguros.nrdconta  = crapseg.nrdconta
                                       tt-seguros.nrctrseg  = crapseg.nrctrseg
                                       tt-seguros.dtmvtolt  = crapseg.dtmvtolt
                                       tt-seguros.cdsegura  = crapseg.cdsegura
                                       tt-seguros.flgclabe  = crapseg.flgclabe
                                       tt-seguros.vlant     = crapseg.vlpreseg
                                       tt-seguros.dtultalt  = crapseg.dtultalt
                                       aux_acrescimo        = (crapseg.vlpreseg *
                                                              (par_vlpercen / 100))
                                       tt-seguros.vlpreseg  = crapseg.vlpreseg +
                                                              aux_acrescimo
                                       tt-seguros.registro  = recid(crapseg).
                            END.
                END.
            END.   
    END.          

    EMPTY TEMP-TABLE tt-erro.

    IF  aux_cdcritic <> 0    OR
        aux_dscritic <> ""   THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF   par_flgerlog  THEN
                RUN proc_gerar_log (INPUT  par_cdcooper,
                                    INPUT  par_cdoperad,
                                    INPUT  aux_dscritic,
                                    INPUT  aux_dsorigem,
                                    INPUT  aux_dstransa,
                                    INPUT  FALSE,
                                    INPUT  par_idseqttl,
                                    INPUT  par_nmdatela,
                                    INPUT  par_nrdconta,
                                    OUTPUT aux_nrdrowid).   
            
            RETURN "NOK".
        END.

            
    IF  par_flgerlog  THEN
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

    RETURN "OK".
END PROCEDURE.

PROCEDURE valida_inc_seguro:
    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO. 
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                    NO-UNDO.
    DEF INPUT PARAM par_inpessoa AS INT                     NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN aux_dscritic = "".

    IF par_inpessoa = 0 THEN
        DO:
            RUN buscar_associados (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT par_cdoperad,
                                   INPUT par_dtmvtolt,
                                   INPUT par_nrdconta,
                                   INPUT par_idseqttl,
                                   INPUT par_idorigem,
                                   INPUT par_nmdatela,
                                   INPUT par_flgerlog,
                                   OUTPUT TABLE tt-associado,
                                   OUTPUT TABLE tt-erro).
        
            IF   RETURN-VALUE <> "OK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                    IF   AVAIL tt-erro   THEN
                        DO:
                            ASSIGN aux_cdcritic = tt-erro.cdcritic
                                   aux_dscritic = tt-erro.dscritic.
                        END.
                END.
        
            FIND tt-associado WHERE
                 tt-associado.cdcooper = par_cdcooper  AND
                 tt-associado.nrdconta = par_nrdconta  NO-ERROR.

            ASSIGN par_inpessoa = tt-associado.inpessoa.
        END.
        
    IF  par_inpessoa <> 1  THEN
        ASSIGN aux_dscritic = "Opcao bloqueada para pessoa juridica.".

    EMPTY TEMP-TABLE tt-erro.

    IF  aux_cdcritic <> 0    OR
        aux_dscritic <> ""   THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF   par_flgerlog  THEN
                RUN proc_gerar_log (INPUT  par_cdcooper,
                                    INPUT  par_cdoperad,
                                    INPUT  aux_dscritic,
                                    INPUT  aux_dsorigem,
                                    INPUT  aux_dstransa,
                                    INPUT  FALSE,
                                    INPUT  par_idseqttl,
                                    INPUT  par_nmdatela,
                                    INPUT  par_nrdconta,
                                    OUTPUT aux_nrdrowid).   
            
            RETURN "NOK".
        END.

            
    IF  par_flgerlog  THEN
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

    RETURN "OK".
END PROCEDURE.

PROCEDURE buscar_seq_matricula:
    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO. 
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-matricula.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-matricula.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    FOR EACH crapmat NO-LOCK WHERE
             crapmat.cdcooper = par_cdcooper:
        CREATE tt-matricula.
        BUFFER-COPY crapmat TO tt-matricula.
    END.

    IF NOT CAN-FIND(FIRST tt-matricula) THEN
        ASSIGN aux_dscritic = "Matricula nao encontrada."
               aux_cdcritic = 71.

    EMPTY TEMP-TABLE tt-erro.

    IF  aux_cdcritic <> 0    OR
        aux_dscritic <> ""   THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF   par_flgerlog  THEN
                RUN proc_gerar_log (INPUT  par_cdcooper,
                                    INPUT  par_cdoperad,
                                    INPUT  aux_dscritic,
                                    INPUT  aux_dsorigem,
                                    INPUT  aux_dstransa,
                                    INPUT  FALSE,
                                    INPUT  par_idseqttl,
                                    INPUT  par_nmdatela,
                                    INPUT  par_nrdconta,
                                    OUTPUT aux_nrdrowid).   
            
            RETURN "NOK".
        END.

            
    IF  par_flgerlog  THEN
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

    RETURN "OK".

END PROCEDURE.

PROCEDURE buscar_feriados:
    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO. 
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                    NO-UNDO.
    DEF INPUT PARAM par_dtferiad LIKE crapfer.dtferiad      NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-feriado.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-feriado.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    FOR EACH crapfer NO-LOCK WHERE
             crapfer.cdcooper = par_cdcooper AND
             (IF par_dtferiad <> ? THEN
                  crapfer.dtferiad = par_dtferiad
              ELSE TRUE):
        CREATE tt-feriado.
        BUFFER-COPY crapfer TO tt-feriado.
    END.

    IF NOT CAN-FIND(FIRST tt-feriado) THEN
        ASSIGN aux_dscritic = "Nenhum feriado foi encontrado.".

    EMPTY TEMP-TABLE tt-erro.

    IF  aux_cdcritic <> 0    OR
        aux_dscritic <> ""   THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF   par_flgerlog  THEN
                RUN proc_gerar_log (INPUT  par_cdcooper,
                                    INPUT  par_cdoperad,
                                    INPUT  aux_dscritic,
                                    INPUT  aux_dsorigem,
                                    INPUT  aux_dstransa,
                                    INPUT  FALSE,
                                    INPUT  par_idseqttl,
                                    INPUT  par_nmdatela,
                                    INPUT  par_nrdconta,
                                    OUTPUT aux_nrdrowid).   
            
            RETURN "NOK".
        END.

    IF  par_flgerlog  THEN
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

    RETURN "OK".
END PROCEDURE.

PROCEDURE buscar_end_coo:
    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO. 
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                    NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-end-coop.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-end-coop.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    FOR FIRST crapenc NO-LOCK WHERE
             crapenc.cdcooper = par_cdcooper  AND
             crapenc.nrdconta = par_nrdconta  AND
             (IF par_idseqttl <> 0 THEN
                  crapenc.idseqttl = par_idseqttl
              ELSE TRUE)                      AND
              crapenc.dsendere <> ""          AND
              crapenc.tpendass = 10:  /* Residencial */ 

        CREATE tt-end-coop.
        BUFFER-COPY crapenc TO tt-end-coop.
    END.

    IF NOT CAN-FIND(FIRST tt-end-coop) THEN
        ASSIGN aux_dscritic = "Endereco nao encontrado.".

    EMPTY TEMP-TABLE tt-erro.

    IF  aux_cdcritic <> 0    OR
        aux_dscritic <> ""   THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF   par_flgerlog  THEN
                RUN proc_gerar_log (INPUT  par_cdcooper,
                                    INPUT  par_cdoperad,
                                    INPUT  aux_dscritic,
                                    INPUT  aux_dsorigem,
                                    INPUT  aux_dstransa,
                                    INPUT  FALSE,
                                    INPUT  par_idseqttl,
                                    INPUT  par_nmdatela,
                                    INPUT  par_nrdconta,
                                    OUTPUT aux_nrdrowid).   
            
            RETURN "NOK".
        END.

            
    IF  par_flgerlog  THEN
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

    RETURN "OK".

END PROCEDURE.

PROCEDURE buscar_inf_conjuge:
    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO. 
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-inf-conj.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-inf-conj.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    FOR EACH crapcje NO-LOCK WHERE
             crapcje.cdcooper = par_cdcooper  AND
             crapcje.nrdconta = par_nrdconta  AND
             (IF par_idseqttl <> 0 THEN
                  crapcje.idseqttl = par_idseqttl
              ELSE
                  TRUE):
         
        CREATE tt-inf-conj.

        BUFFER-COPY crapcje TO tt-inf-conj.

    END.

    IF NOT CAN-FIND(FIRST tt-inf-conj) THEN
       ASSIGN aux_dscritic = "Conjuge nao encontrado.".

    EMPTY TEMP-TABLE tt-erro.

    IF  aux_cdcritic <> 0    OR
        aux_dscritic <> ""   THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF   par_flgerlog  THEN
                RUN proc_gerar_log (INPUT  par_cdcooper,
                                    INPUT  par_cdoperad,
                                    INPUT  aux_dscritic,
                                    INPUT  aux_dsorigem,
                                    INPUT  aux_dstransa,
                                    INPUT  FALSE,
                                    INPUT  par_idseqttl,
                                    INPUT  par_nmdatela,
                                    INPUT  par_nrdconta,
                                    OUTPUT aux_nrdrowid).   
            
            RETURN "NOK".
        END.

            
    IF  par_flgerlog  THEN
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

    RETURN "OK".

END PROCEDURE.

PROCEDURE buscar_tip_seguro:
    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO. 
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                    NO-UNDO.
    DEF INPUT PARAM par_cdsegura LIKE crapseg.cdsegura      NO-UNDO.
    DEF INPUT PARAM par_tpseguro LIKE crapseg.tpseguro      NO-UNDO.
    DEF INPUT PARAM par_nrctrseg LIKE crapseg.nrctrseg      NO-UNDO.

    DEF OUTPUT PARAM par_dstipseg AS CHAR NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           par_dstipseg = "".

    CASE par_tpseguro:
        WHEN 1 OR
        WHEN 3 THEN
            ASSIGN par_dstipseg = "VIDA".
        WHEN 4 THEN
            ASSIGN par_dstipseg = "PRESTAMISTA".
        WHEN 11 THEN
            ASSIGN par_dstipseg = "CASA".
        WHEN 0 THEN
            ASSIGN par_dstipseg = "CASA;VIDA;PRESTAMISTA".
        OTHERWISE DO:
            ASSIGN aux_cdcritic = 513.
        END.
    END CASE.

    EMPTY TEMP-TABLE tt-erro.

    IF  aux_cdcritic <> 0    OR
        aux_dscritic <> ""   THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF   par_flgerlog  THEN
                RUN proc_gerar_log (INPUT  par_cdcooper,
                                    INPUT  par_cdoperad,
                                    INPUT  aux_dscritic,
                                    INPUT  aux_dsorigem,
                                    INPUT  aux_dstransa,
                                    INPUT  FALSE,
                                    INPUT  par_idseqttl,
                                    INPUT  par_nmdatela,
                                    INPUT  par_nrdconta,
                                    OUTPUT aux_nrdrowid).   
            
            RETURN "NOK".
        END.

            
    IF  par_flgerlog  THEN
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

    RETURN "OK".
END PROCEDURE.

PROCEDURE buscar_seguradora:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO. 
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                    NO-UNDO.
    DEF INPUT PARAM par_tpseguro LIKE craptsg.tpseguro      NO-UNDO.
    DEF INPUT PARAM par_cdsitpsg LIKE craptsg.cdsitpsg      NO-UNDO.
    DEF INPUT PARAM par_cdsegura LIKE craptsg.cdsegura      NO-UNDO.
    DEF INPUT PARAM par_nmsegura LIKE crapcsg.nmsegura      NO-UNDO.

    DEF OUTPUT PARAM par_qtregist AS INTE                   NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-seguradora.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-seguradora.
    EMPTY TEMP-TABLE tt-erro.

    DEF BUFFER crabcop FOR crapcop.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           par_qtregist = 0.

    FIND crapcop WHERE crapcop.cdcooper = 3 NO-LOCK NO-ERROR.

    FIND crabcop WHERE crabcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    valida:  
    FOR EACH crapcsg NO-LOCK                    WHERE
             crapcsg.cdcooper = par_cdcooper    AND
             (IF par_cdsegura <> 0              THEN
                  crapcsg.cdsegura = par_cdsegura
              ELSE TRUE)                        AND
              (IF par_nmsegura <> ""            THEN
                  crapcsg.nmsegura MATCHES "*" + par_nmsegura + "*"
              ELSE TRUE):

        IF NOT crapcsg.flgativo THEN NEXT.
     
        IF par_tpseguro <> 0 OR
           par_cdsitpsg <> 0 THEN DO:
            FIND FIRST craptsg NO-LOCK WHERE
                       craptsg.cdcooper = par_cdcooper      AND
                       craptsg.cdsegura = crapcsg.cdsegura  AND
                       
                       craptsg.tpseguro = (IF par_tpseguro = 0 THEN
                                              craptsg.tpseguro
                                          ELSE
                                              par_tpseguro) AND
                       craptsg.cdsitpsg = (IF par_cdsitpsg = 0 THEN
                                              craptsg.cdsitpsg
                                          ELSE
                                              par_cdsitpsg) NO-ERROR.
            IF NOT AVAIL craptsg THEN NEXT.
        END.

        ASSIGN par_qtregist = par_qtregist + 1.

        CREATE tt-seguradora.
        ASSIGN tt-seguradora.cdsegura = crapcsg.cdsegura
               tt-seguradora.nmsegura = crapcsg.nmsegura
               tt-seguradora.nmresseg = crapcsg.nmresseg
               tt-seguradora.cdcooper = crapcsg.cdcooper
               tt-seguradora.nrlimprc = crapcsg.nrlimprc
               tt-seguradora.nrultprc = crapcsg.nrultprc
               tt-seguradora.nrcgcseg = crapcsg.nrcgcseg
               tt-seguradora.nmrescec = crapcop.nmextcop 
               tt-seguradora.nmrescop = crabcop.nmrescop.
    END.

    IF NOT CAN-FIND(FIRST tt-seguradora) THEN DO:
        ASSIGN aux_cdcritic = 556.
    END.

    EMPTY TEMP-TABLE tt-erro.

    IF  aux_cdcritic <> 0    OR
        aux_dscritic <> ""   THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF   par_flgerlog  THEN
                RUN proc_gerar_log (INPUT  par_cdcooper,
                                    INPUT  par_cdoperad,
                                    INPUT  aux_dscritic,
                                    INPUT  aux_dsorigem,
                                    INPUT  aux_dstransa,
                                    INPUT  FALSE,
                                    INPUT  par_idseqttl,
                                    INPUT  par_nmdatela,
                                    INPUT  par_nrdconta,
                                    OUTPUT aux_nrdrowid).   
            
            RETURN "NOK".
        END.

            
    IF  par_flgerlog  THEN
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

    RETURN "OK".
END PROCEDURE.

PROCEDURE busca_seguros:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO. 
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-seguros.
    DEF OUTPUT PARAM aux_qtsegass AS INTE.
    DEF OUTPUT PARAM aux_vltotseg AS DECI.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-seguros.
    
    DEF VAR qtd_motcance        AS DECI                     NO-UNDO.
    
    ASSIGN aux_qtsegass = 0
           aux_vltotseg = 0
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Listar seguros."
           aux_cdcritic = 0
           aux_dscritic = "".


    IF par_nrdconta <> 0 THEN DO:

    
        FOR EACH crapseg NO-LOCK WHERE
                 crapseg.cdcooper = par_cdcooper AND 
                 crapseg.nrdconta = par_nrdconta:
            
			/* Problemas na impressao da proposta,
			   nao limitar mais os resultados a 1 ano SD553284 Tiago/Thiago

            IF   (crapseg.cdsitseg = 2 AND
                 crapseg.dtcancel < (par_dtmvtolt - 365)) OR
                 (crapseg.cdsitseg = 4 AND
                 crapseg.dtfimvig < (par_dtmvtolt - 365)) THEN
                 NEXT.

              */

            CREATE tt-seguros.
            ASSIGN tt-seguros.cdcooper      = crapseg.cdcooper
                   tt-seguros.cdagenci      = crapseg.cdagenci
                   tt-seguros.dtcancel      = crapseg.dtcancel
                   tt-seguros.cdmotcan      = crapseg.cdmotcan
                   tt-seguros.nrdconta      = crapseg.nrdconta
                   tt-seguros.tpendcor      = crapseg.tpendcor
                   tt-seguros.dtiniseg      = crapseg.dtiniseg
                   tt-seguros.cdsegura      = crapseg.cdsegura
                   tt-seguros.flgclabe      = crapseg.flgclabe
                   tt-seguros.nrctrseg      = crapseg.nrctrseg
                   tt-seguros.tpplaseg      = crapseg.tpplaseg
                   tt-seguros.dtprideb      = crapseg.dtprideb
                   tt-seguros.dtdebito      = crapseg.dtdebito
                   tt-seguros.tpseguro      = crapseg.tpseguro
                   tt-seguros.cdsitseg      = crapseg.cdsitseg
                   tt-seguros.nrseqdig      = crapseg.nrseqdig
                   tt-seguros.nrdolote      = crapseg.nrdolote
                   tt-seguros.cdbccxlt      = crapseg.cdbccxlt
                   tt-seguros.nrseqdig      = crapseg.nrseqdig
                   tt-seguros.dsseguro      = 
                          (IF (crapseg.tpseguro    = 1 OR
                               crapseg.tpseguro    = 11 ) THEN "CASA" ELSE
                           IF crapseg.tpseguro = 2 THEN "AUTO"
                           ELSE IF crapseg.tpseguro = 3 THEN "VIDA"
                                   ELSE 
                                   IF crapseg.tpseguro = 4 THEN "PRST"
                                   ELSE "    ")
                   tt-seguros.vlpreseg      = crapseg.vlpreseg
                   tt-seguros.dtinivig      = crapseg.dtinivig
                   tt-seguros.qtprevig      = IF crapseg.tpseguro = 11 THEN
                                                crapseg.qtprepag
                                            ELSE
                                                (crapseg.qtprepag -
                                                (IF crapseg.indebito > 0 THEN 
                                                     1 
                                                 ELSE 0))
                   tt-seguros.registro      = RECID(crapseg)
                   tt-seguros.nmbenvid[1]   = crapseg.nmbenvid[1]
                   tt-seguros.nmbenvid[2]   = crapseg.nmbenvid[2]
                   tt-seguros.nmbenvid[3]   = crapseg.nmbenvid[3]
                   tt-seguros.nmbenvid[4]   = crapseg.nmbenvid[4]
                   tt-seguros.nmbenvid[5]   = crapseg.nmbenvid[5]
                   tt-seguros.dsgraupr[1]   = crapseg.dsgraupr[1]
                   tt-seguros.dsgraupr[2]   = crapseg.dsgraupr[2]
                   tt-seguros.dsgraupr[3]   = crapseg.dsgraupr[3]
                   tt-seguros.dsgraupr[4]   = crapseg.dsgraupr[4]
                   tt-seguros.dsgraupr[5]   = crapseg.dsgraupr[5]
                   tt-seguros.txpartic[1]   = crapseg.txpartic[1]
                   tt-seguros.txpartic[2]   = crapseg.txpartic[2]
                   tt-seguros.txpartic[3]   = crapseg.txpartic[3]
                   tt-seguros.txpartic[4]   = crapseg.txpartic[4]
                   tt-seguros.txpartic[5]   = crapseg.txpartic[5]
                   tt-seguros.dtultalt      = crapseg.dtultalt
                   tt-seguros.vlprepag      = crapseg.vlprepag
                   tt-seguros.qtprepag      = crapseg.qtprepag
                   tt-seguros.dtultalt      = crapseg.dtultalt
                   tt-seguros.dtmvtolt      = crapseg.dtmvtolt
                   /** TOTAIS **/
                   aux_qtsegass = aux_qtsegass + 1.
    
            IF crapseg.cdsitseg = 3 and
               crapseg.tpseguro = 11  THEN
                ASSIGN tt-seguros.dsstatus = "Ativo"
                       aux_vltotseg        = aux_vltotseg +
                                             IF crapseg.flgunica THEN
                                                 0
                                             ELSE crapseg.vlpreseg.
            ELSE
            IF  crapseg.cdsitseg = 1    THEN
                ASSIGN tt-seguros.dsstatus  = "Ativo"
                       aux_vltotseg         = aux_vltotseg + IF crapseg.flgunica THEN
                                                     0
                                               ELSE crapseg.vlpreseg. 
            ELSE
            IF  crapseg.cdsitseg = 2    THEN
                tt-seguros.dsstatus = "Cancelado".
            ELSE
            IF  crapseg.cdsitseg = 3    THEN  /* Substituicao seguro AUTO */ 
                tt-seguros.dsstatus = "S" +
                                      TRIM(STRING(crapseg.nrctratu,"zzzzz,zz9")).
            ELSE
            IF   crapseg.cdsitseg = 4   THEN
                 tt-seguros.dsstatus = "Vencido".
            ELSE
                 tt-seguros.dsstatus = "?????????".
                                         
            FIND FIRST crawseg NO-LOCK WHERE
                       crawseg.cdcooper = crapseg.cdcooper  AND
                       crawseg.nrdconta = crapseg.nrdconta  AND
                       crawseg.nrctrseg = crapseg.nrctrseg  NO-ERROR.
            IF AVAIL crawseg THEN
                ASSIGN tt-seguros.vlseguro = crawseg.vlseguro
                       tt-seguros.dtfimvig = crawseg.dtfimvig
                       tt-seguros.tpplaseg = crawseg.tpplaseg
                       tt-seguros.nmdsegur = crawseg.nmdsegur.
    
            RUN buscar_motivo_can (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT par_cdoperad,
                                   INPUT par_dtmvtolt,
                                   INPUT par_nrdconta,
                                   INPUT par_idseqttl,
                                   INPUT par_idorigem,
                                   INPUT par_nmdatela,
                                   INPUT par_flgerlog,
                                   INPUT crapseg.cdmotcan,
                                   INPUT "",
                                   OUTPUT qtd_motcance,
                                   OUTPUT TABLE tt-mot-can,
                                   OUTPUT TABLE tt-erro).
    
            FIND FIRST tt-mot-can WHERE
                       tt-mot-can.cdmotcan = tt-seguros.cdmotcan NO-ERROR.
            IF  AVAIL tt-mot-can  THEN
                ASSIGN tt-seguros.dsmotcan = tt-mot-can.dsmotcan.
             
        END.  /*  Fim da leitura do crapseg  */    

    END.
    ELSE
    DO:

            FOR EACH crapseg NO-LOCK WHERE
                 crapseg.cdcooper = par_cdcooper:
    
            IF (crapseg.nrdconta <> par_nrdconta AND par_nrdconta <> 0) THEN NEXT.
            
            CREATE tt-seguros.
            ASSIGN tt-seguros.cdcooper      = crapseg.cdcooper
                   tt-seguros.cdagenci      = crapseg.cdagenci
                   tt-seguros.dtcancel      = crapseg.dtcancel
                   tt-seguros.cdmotcan      = crapseg.cdmotcan
                   tt-seguros.nrdconta      = crapseg.nrdconta
                   tt-seguros.tpendcor      = crapseg.tpendcor
                   tt-seguros.dtiniseg      = crapseg.dtiniseg
                   tt-seguros.cdsegura      = crapseg.cdsegura
                   tt-seguros.flgclabe      = crapseg.flgclabe
                   tt-seguros.nrctrseg      = crapseg.nrctrseg
                   tt-seguros.tpplaseg      = crapseg.tpplaseg
                   tt-seguros.dtprideb      = crapseg.dtprideb
                   tt-seguros.dtdebito      = crapseg.dtdebito
                   tt-seguros.tpseguro      = crapseg.tpseguro
                   tt-seguros.cdsitseg      = crapseg.cdsitseg
                   tt-seguros.nrseqdig      = crapseg.nrseqdig
                   tt-seguros.nrdolote      = crapseg.nrdolote
                   tt-seguros.cdbccxlt      = crapseg.cdbccxlt
                   tt-seguros.nrseqdig      = crapseg.nrseqdig
                   tt-seguros.dsseguro      = 
                          (IF (crapseg.tpseguro    = 1 OR
                               crapseg.tpseguro    = 11 ) THEN "CASA" ELSE
                           IF crapseg.tpseguro = 2 THEN "AUTO"
                           ELSE IF crapseg.tpseguro = 3 THEN "VIDA"
                                   ELSE 
                                   IF crapseg.tpseguro = 4 THEN "PRST"
                                   ELSE "    ")
                   tt-seguros.vlpreseg      = crapseg.vlpreseg
                   tt-seguros.dtinivig      = crapseg.dtinivig
                   tt-seguros.qtprevig      = IF crapseg.tpseguro = 11 THEN
                                                crapseg.qtprepag
                                            ELSE
                                                (crapseg.qtprepag -
                                                (IF crapseg.indebito > 0 THEN 
                                                     1 
                                                 ELSE 0))
                   tt-seguros.registro      = RECID(crapseg)
                   tt-seguros.nmbenvid[1]   = crapseg.nmbenvid[1]
                   tt-seguros.nmbenvid[2]   = crapseg.nmbenvid[2]
                   tt-seguros.nmbenvid[3]   = crapseg.nmbenvid[3]
                   tt-seguros.nmbenvid[4]   = crapseg.nmbenvid[4]
                   tt-seguros.nmbenvid[5]   = crapseg.nmbenvid[5]
                   tt-seguros.dsgraupr[1]   = crapseg.dsgraupr[1]
                   tt-seguros.dsgraupr[2]   = crapseg.dsgraupr[2]
                   tt-seguros.dsgraupr[3]   = crapseg.dsgraupr[3]
                   tt-seguros.dsgraupr[4]   = crapseg.dsgraupr[4]
                   tt-seguros.dsgraupr[5]   = crapseg.dsgraupr[5]
                   tt-seguros.txpartic[1]   = crapseg.txpartic[1]
                   tt-seguros.txpartic[2]   = crapseg.txpartic[2]
                   tt-seguros.txpartic[3]   = crapseg.txpartic[3]
                   tt-seguros.txpartic[4]   = crapseg.txpartic[4]
                   tt-seguros.txpartic[5]   = crapseg.txpartic[5]
                   tt-seguros.dtultalt      = crapseg.dtultalt
                   tt-seguros.vlprepag      = crapseg.vlprepag
                   tt-seguros.qtprepag      = crapseg.qtprepag
                   tt-seguros.dtultalt      = crapseg.dtultalt
                   tt-seguros.dtmvtolt      = crapseg.dtmvtolt
                   /** TOTAIS **/
                   aux_qtsegass = aux_qtsegass + 1.
    
            IF crapseg.cdsitseg = 3 and
               crapseg.tpseguro = 11  THEN
                ASSIGN tt-seguros.dsstatus = "Ativo"
                       aux_vltotseg        = aux_vltotseg +
                                             IF crapseg.flgunica THEN
                                                 0
                                             ELSE crapseg.vlpreseg.
            ELSE
            IF  crapseg.cdsitseg = 1    THEN
                ASSIGN tt-seguros.dsstatus  = "Ativo"
                       aux_vltotseg         = aux_vltotseg + IF crapseg.flgunica THEN
                                                     0
                                               ELSE crapseg.vlpreseg. 
            ELSE
            IF  crapseg.cdsitseg = 2    THEN
                tt-seguros.dsstatus = "Cancelado".
            ELSE
            IF  crapseg.cdsitseg = 3    THEN  /* Substituicao seguro AUTO */ 
                tt-seguros.dsstatus = "S" +
                                      TRIM(STRING(crapseg.nrctratu,"zzzzz,zz9")).
            ELSE
            IF   crapseg.cdsitseg = 4   THEN
                 tt-seguros.dsstatus = "Vencido".
            ELSE
                 tt-seguros.dsstatus = "?????????".
                                         
            FIND FIRST crawseg NO-LOCK WHERE
                       crawseg.cdcooper = crapseg.cdcooper  AND
                       crawseg.nrdconta = crapseg.nrdconta  AND
                       crawseg.nrctrseg = crapseg.nrctrseg  NO-ERROR.
            IF AVAIL crawseg THEN
                ASSIGN tt-seguros.vlseguro = crawseg.vlseguro
                       tt-seguros.dtfimvig = crawseg.dtfimvig
                       tt-seguros.tpplaseg = crawseg.tpplaseg
                       tt-seguros.nmdsegur = crawseg.nmdsegur.
    
            RUN buscar_motivo_can (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT par_cdoperad,
                                   INPUT par_dtmvtolt,
                                   INPUT par_nrdconta,
                                   INPUT par_idseqttl,
                                   INPUT par_idorigem,
                                   INPUT par_nmdatela,
                                   INPUT par_flgerlog,
                                   INPUT crapseg.cdmotcan,
                                   INPUT "",
                                   OUTPUT qtd_motcance,
                                   OUTPUT TABLE tt-mot-can,
                                   OUTPUT TABLE tt-erro).
    
            FIND FIRST tt-mot-can WHERE
                       tt-mot-can.cdmotcan = tt-seguros.cdmotcan NO-ERROR.
            IF  AVAIL tt-mot-can  THEN
                ASSIGN tt-seguros.dsmotcan = tt-mot-can.dsmotcan.
             
        END.  /*  Fim da leitura do crapseg  */

    END.



    EMPTY TEMP-TABLE tt-erro.
    
    IF   aux_cdcritic <> 0    OR
         aux_dscritic <> ""   THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1, /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

             IF   par_flgerlog  THEN
                  RUN proc_gerar_log (INPUT  par_cdcooper,
                                      INPUT  par_cdoperad,
                                      INPUT  aux_dscritic,
                                      INPUT  aux_dsorigem,
                                      INPUT  aux_dstransa,
                                      INPUT  FALSE,
                                      INPUT  par_idseqttl,
                                      INPUT  par_nmdatela,
                                      INPUT  par_nrdconta,
                                      OUTPUT aux_nrdrowid).   

             RETURN "NOK".

         END.

    IF   par_flgerlog  THEN
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
    RETURN "OK".
END.

PROCEDURE buscar_proposta_seguro:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO. 
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-prop-seguros.
    DEF OUTPUT PARAM aux_qtsegass AS INTE.
    DEF OUTPUT PARAM aux_vltotseg AS DECI.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-prop-seguros.
    
    ASSIGN aux_qtsegass = 0
           aux_vltotseg = 0
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Listar propostas de seguros.".
    
    FOR EACH crawseg WHERE
             crawseg.cdcooper = par_cdcooper  AND
             crawseg.nrdconta = par_nrdconta  NO-LOCK.

        CREATE tt-prop-seguros.
        ASSIGN tt-prop-seguros.dtiniseg = crawseg.dtiniseg
               tt-prop-seguros.nrctrseg = crawseg.nrctrseg
               tt-prop-seguros.flgunica = crawseg.flgunica
               tt-prop-seguros.dtdebito = crawseg.dtdebito
               tt-prop-seguros.tpseguro = crawseg.tpseguro
               tt-prop-seguros.dsseguro = 
                      (IF (crawseg.tpseguro = 1 OR
                            crawseg.tpseguro = 11 ) THEN "CASA" ELSE
                       IF crawseg.tpseguro = 2 THEN "AUTO"
                       ELSE IF crawseg.tpseguro = 3 THEN "VIDA"
                               ELSE 
                               IF crawseg.tpseguro = 4 THEN "PRST"
                               ELSE "    ")
               tt-prop-seguros.vlbenefi = crawseg.vlbenefi
               tt-prop-seguros.nmempres = crawseg.nmempres
               tt-prop-seguros.nrcadast = crawseg.nrcadast
               tt-prop-seguros.nrfonemp = crawseg.nrfonemp
               tt-prop-seguros.nrfonres = crawseg.nrfonres
               tt-prop-seguros.dsmarvei = crawseg.dsmarvei
               tt-prop-seguros.dstipvei = crawseg.dstipvei
               tt-prop-seguros.nranovei = crawseg.nranovei
               tt-prop-seguros.nrmodvei = crawseg.nrmodvei
               tt-prop-seguros.nrdplaca = crawseg.nrdplaca
               tt-prop-seguros.qtpasvei = crawseg.qtpasvei
               tt-prop-seguros.dschassi = crawseg.dschassi
               tt-prop-seguros.ppdbonus = crawseg.ppdbonus
               tt-prop-seguros.flgdnovo = crawseg.flgdnovo
               tt-prop-seguros.flgrenov = crawseg.flgrenov
               tt-prop-seguros.cdapoant = crawseg.cdapoant
               tt-prop-seguros.nmsegant = crawseg.nmsegant
               tt-prop-seguros.flgdutil = crawseg.flgdutil
               tt-prop-seguros.flgvisto = crawseg.flgvisto
               tt-prop-seguros.flgnotaf = crawseg.flgnotaf
               tt-prop-seguros.flgapant = crawseg.flgapant
               tt-prop-seguros.flgrepgr = crawseg.flgrepgr
               tt-prop-seguros.dtfimvig = crawseg.dtfimvig
               tt-prop-seguros.cdcalcul = crawseg.cdcalcul
               tt-prop-seguros.vldfranq = crawseg.vldfranq
               tt-prop-seguros.vldcasco = crawseg.vldcasco
               tt-prop-seguros.vlverbae = crawseg.vlverbae
               tt-prop-seguros.flgassis = crawseg.flgassis
               tt-prop-seguros.vldanmat = crawseg.vldanmat
               tt-prop-seguros.vldanpes = crawseg.vldanpes
               tt-prop-seguros.vldanmor = crawseg.vldanmor
               tt-prop-seguros.vlappmor = crawseg.vlappmor
               tt-prop-seguros.vlappinv = crawseg.vlappinv
               tt-prop-seguros.flgcurso = crawseg.flgcurso
               tt-prop-seguros.vldifseg = crawseg.vldifseg
               tt-prop-seguros.vlfrqobr = crawseg.vlfrqobr
               tt-prop-seguros.nrendres = crawseg.nrendres
               tt-prop-seguros.cdsegura = crawseg.cdsegura
               tt-prop-seguros.vlpreseg = crawseg.vlpreseg
               tt-prop-seguros.vlpremio = crawseg.vlpremio
               tt-prop-seguros.nmbenefi = crawseg.nmbenefi
               tt-prop-seguros.dtinivig = crawseg.dtinivig
               tt-prop-seguros.nmcpveic = crawseg.nmcpveic
               tt-prop-seguros.dtmvtolt = crawseg.dtmvtolt
               tt-prop-seguros.tpsegvid = crawseg.tpsegvid
               tt-prop-seguros.dtprideb = crawseg.dtprideb
               tt-prop-seguros.nrcpfcgc = crawseg.nrcpfcgc
               tt-prop-seguros.nmdsegur = crawseg.nmdsegur
               tt-prop-seguros.qtparcel = crawseg.qtparcel
               tt-prop-seguros.nrdconta = crawseg.nrdconta
               tt-prop-seguros.cdsexosg = crawseg.cdsexosg
               tt-prop-seguros.dtnascsg = crawseg.dtnascsg
               tt-prop-seguros.dsendres = crawseg.dsendres
               tt-prop-seguros.nmbairro = crawseg.nmbairro
               tt-prop-seguros.nmcidade = crawseg.nmcidade
               tt-prop-seguros.cdufresd = crawseg.cdufresd
               tt-prop-seguros.nrcepend = crawseg.nrcepend
               tt-prop-seguros.complend = crawseg.complend
               tt-prop-seguros.tpplaseg = crawseg.tpplaseg
               tt-prop-seguros.vlseguro = crawseg.vlseguro
               tt-prop-seguros.cdcooper = crawseg.cdcooper
               tt-prop-seguros.registro = RECID(crawseg)
               tt-prop-seguros.lsctrant =  crawseg.lsctrant 
               /** TOTAIS **/
               aux_qtsegass = aux_qtsegass + 1
               aux_vltotseg = aux_vltotseg + IF  crawseg.flgunica THEN
                                                 0
                                             ELSE 
                                                 crawseg.vlpreseg.


    END.  /*  Fim do FOR EACH -- Leitura do crawseg  */

    EMPTY TEMP-TABLE tt-erro.
    
    IF   aux_cdcritic <> 0    OR
         aux_dscritic <> ""   THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1, /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

             IF   par_flgerlog  THEN
                  RUN proc_gerar_log (INPUT  par_cdcooper,
                                      INPUT  par_cdoperad,
                                      INPUT  aux_dscritic,
                                      INPUT  aux_dsorigem,
                                      INPUT  aux_dstransa,
                                      INPUT  FALSE,
                                      INPUT  par_idseqttl,
                                      INPUT  par_nmdatela,
                                      INPUT  par_nrdconta,
                                      OUTPUT aux_nrdrowid).   

             RETURN "NOK".

         END.

    IF   par_flgerlog  THEN
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
    RETURN "OK".

END PROCEDURE.


PROCEDURE seguro_auto:

    DEF INPUT  PARAM par_cdcooper AS INTE                   NO-UNDO.
    DEF INPUT  PARAM par_cdagenci AS INTE                   NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa AS INTE                   NO-UNDO.
    DEF INPUT  PARAM par_cdoperad AS CHAR                   NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt AS DATE                   NO-UNDO.
    DEF INPUT  PARAM par_nrdconta AS INTE                   NO-UNDO.
    DEF INPUT  PARAM par_nrctrseg AS INTE                   NO-UNDO.
    DEF INPUT  PARAM par_idseqttl AS INTE                   NO-UNDO.
    DEF INPUT  PARAM par_idorigem AS INTE                   NO-UNDO.
    DEF INPUT  PARAM par_nmdatela AS CHAR                   NO-UNDO.
    DEF INPUT  PARAM par_flgerlog AS LOGI                   NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-seguros_autos.

    EMPTY TEMP-TABLE tt-seguros_autos.

    FIND crawseg WHERE crawseg.cdcooper = par_cdcooper   AND
                       crawseg.nrdconta = par_nrdconta   AND
                       crawseg.nrctrseg = par_nrctrseg   AND
                       crawseg.tpseguro = 2              NO-LOCK NO-ERROR.
    
    IF   AVAILABLE crawseg   THEN
         DO:
             CREATE tt-seguros_autos.
             ASSIGN tt-seguros_autos.nmdsegur = crawseg.nmdsegur
                    tt-seguros_autos.dsmarvei = crawseg.dsmarvei
                    tt-seguros_autos.dstipvei = crawseg.dstipvei
                    tt-seguros_autos.nranovei = crawseg.nranovei
                    tt-seguros_autos.nrmodvei = crawseg.nrmodvei
                    tt-seguros_autos.nrdplaca = crawseg.nrdplaca
                    tt-seguros_autos.dtinivig = crawseg.dtinivig
                    tt-seguros_autos.dtfimvig = crawseg.dtfimvig
                    tt-seguros_autos.qtparcel = crawseg.qtparcel
                    tt-seguros_autos.vlpreseg = crawseg.vlpreseg
                    tt-seguros_autos.dtdebito = DAY(crawseg.dtdebito)
                    tt-seguros_autos.vlpremio = crawseg.vlpremio.
         END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE cria_seguro:

    DEF INPUT PARAM par_cdcooper  AS INTE                   NO-UNDO.
    DEF INPUT PARAM par_cdagenci  AS INTE                   NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa  AS INTE                   NO-UNDO.
    DEF INPUT PARAM par_cdoperad  AS CHAR                   NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt  AS DATE                   NO-UNDO.
    DEF INPUT PARAM par_nrdconta  AS INTE                   NO-UNDO.
    DEF INPUT PARAM par_idseqttl  AS INTE                   NO-UNDO.
    DEF INPUT PARAM par_idorigem  AS INTE                   NO-UNDO. 
    DEF INPUT PARAM par_nmdatela  AS CHAR                   NO-UNDO.
    DEF INPUT PARAM par_flgerlog  AS LOGI                   NO-UNDO.
    DEF INPUT PARAM par_cdmotcan  LIKE crapseg.cdmotcan     NO-UNDO.
    DEF INPUT PARAM par_cdsegura  LIKE crapseg.cdsegura     NO-UNDO.
    DEF INPUT PARAM par_cdsitseg  LIKE crapseg.cdsitseg     NO-UNDO.
    DEF INPUT PARAM par_dsgraupr1 AS CHAR FORMAT "x(20)"    NO-UNDO.
    DEF INPUT PARAM par_dsgraupr2 AS CHAR FORMAT "x(20)"    NO-UNDO.
    DEF INPUT PARAM par_dsgraupr3 AS CHAR FORMAT "x(20)"    NO-UNDO.
    DEF INPUT PARAM par_dsgraupr4 AS CHAR FORMAT "x(20)"    NO-UNDO.
    DEF INPUT PARAM par_dsgraupr5 AS CHAR FORMAT "x(20)"    NO-UNDO.
    DEF INPUT PARAM par_dtaltseg  LIKE crapseg.dtaltseg     NO-UNDO.
    DEF INPUT PARAM par_dtcancel  LIKE crapseg.dtcancel     NO-UNDO.
    DEF INPUT PARAM par_dtdebito  LIKE crapseg.dtdebito     NO-UNDO.
    DEF INPUT PARAM par_dtfimvig  LIKE crapseg.dtfimvig     NO-UNDO.
    DEF INPUT PARAM par_dtiniseg  LIKE crapseg.dtiniseg     NO-UNDO.
    DEF INPUT PARAM par_dtinivig  LIKE crapseg.dtinivig     NO-UNDO.
    DEF INPUT PARAM par_dtprideb  LIKE crapseg.dtprideb     NO-UNDO.    
    DEF INPUT PARAM par_dtultalt  LIKE crapseg.dtultalt     NO-UNDO.
    DEF INPUT PARAM par_dtultpag  LIKE crapseg.dtultpag     NO-UNDO.
    DEF INPUT PARAM par_flgclabe  LIKE crapseg.flgclabe     NO-UNDO.
    DEF INPUT PARAM par_flgconve  LIKE crapseg.flgconve     NO-UNDO.
    DEF INPUT PARAM par_flgunica  LIKE crapseg.flgunica     NO-UNDO.
    DEF INPUT PARAM par_indebito  LIKE crapseg.indebito     NO-UNDO.
    DEF INPUT PARAM par_lsctrant  LIKE crapseg.lsctrant     NO-UNDO.
    DEF INPUT PARAM par_nmbenvid1 AS CHAR FORMAT "x(40)"    NO-UNDO.
    DEF INPUT PARAM par_nmbenvid2 AS CHAR FORMAT "x(40)"    NO-UNDO.
    DEF INPUT PARAM par_nmbenvid3 AS CHAR FORMAT "x(40)"    NO-UNDO.
    DEF INPUT PARAM par_nmbenvid4 AS CHAR FORMAT "x(40)"    NO-UNDO.
    DEF INPUT PARAM par_nmbenvid5 AS CHAR FORMAT "x(40)"    NO-UNDO.
    DEF INPUT PARAM par_nrctratu  LIKE crapseg.nrctratu     NO-UNDO.
    DEF INPUT PARAM par_nrctrseg  LIKE crapseg.nrctrseg     NO-UNDO.
    DEF INPUT PARAM par_nrdolote  AS INTE                   NO-UNDO.
    DEF INPUT PARAM par_qtparcel  LIKE crapseg.qtparcel     NO-UNDO.    
    DEF INPUT PARAM par_qtprepag  LIKE crapseg.qtprepag     NO-UNDO.
    DEF INPUT PARAM par_qtprevig  LIKE crapseg.qtprevig     NO-UNDO.
    DEF INPUT PARAM par_tpdpagto  LIKE crapseg.tpdpagto     NO-UNDO.
    DEF INPUT PARAM par_tpendcor  LIKE crapseg.tpendcor     NO-UNDO. 
    DEF INPUT PARAM par_tpplaseg  LIKE crapseg.tpplaseg     NO-UNDO.    
    DEF INPUT PARAM par_tpseguro  LIKE crapseg.tpseguro     NO-UNDO.    
    DEF INPUT PARAM par_txpartic1 AS DECIMAL FORMAT ">>9.99"NO-UNDO.
    DEF INPUT PARAM par_txpartic2 AS DECIMAL FORMAT ">>9.99"NO-UNDO.
    DEF INPUT PARAM par_txpartic3 AS DECIMAL FORMAT ">>9.99"NO-UNDO.
    DEF INPUT PARAM par_txpartic4 AS DECIMAL FORMAT ">>9.99"NO-UNDO.
    DEF INPUT PARAM par_txpartic5 AS DECIMAL FORMAT ">>9.99"NO-UNDO.
    DEF INPUT PARAM par_vldifseg  LIKE crapseg.vldifseg     NO-UNDO.
    DEF INPUT PARAM par_vlpremio  LIKE crapseg.vlpremio     NO-UNDO.
    DEF INPUT PARAM par_vlprepag  LIKE crapseg.vlprepag     NO-UNDO.
    DEF INPUT PARAM par_vlpreseg  LIKE crapseg.vlpreseg     NO-UNDO.
    DEF INPUT PARAM par_vlcapseg  LIKE craptsg.vlmorada     NO-UNDO.
    DEF INPUT PARAM par_cdbccxlt  AS INTE                   NO-UNDO.
    DEF INPUT PARAM par_nrcpfcgc LIKE crawseg.nrcpfcgc      NO-UNDO.
    DEF INPUT PARAM par_nmdsegur LIKE crawseg.nmdsegur      NO-UNDO.
    DEF INPUT PARAM par_vltotpre LIKE crapseg.vlpremio      NO-UNDO.    
    DEF INPUT PARAM par_cdcalcul LIKE crawseg.cdcalcul      NO-UNDO.
    DEF INPUT PARAM par_vlseguro LIKE crawseg.vlseguro      NO-UNDO.
    DEF INPUT PARAM par_dsendres LIKE crawseg.dsendres      NO-UNDO.
    DEF INPUT PARAM par_nrendres LIKE crawseg.nrendres      NO-UNDO.
    DEF INPUT PARAM par_nmbairro LIKE crawseg.nmbairro      NO-UNDO.
    DEF INPUT PARAM par_nmcidade LIKE crawseg.nmcidade      NO-UNDO.
    DEF INPUT PARAM par_cdufresd LIKE crawseg.cdufresd      NO-UNDO.
    DEF INPUT PARAM par_nrcepend LIKE crawseg.nrcepend      NO-UNDO.
    DEF INPUT PARAM par_cdsexosg AS INT                     NO-UNDO.
    DEF INPUT PARAM par_cdempres LIKE crapemp.cdempres      NO-UNDO.
    DEF INPUT PARAM par_dtnascsg AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_complend LIKE crawseg.complend      NO-UNDO.
    
    DEF OUTPUT PARAM par_flgsegur AS LOG                    NO-UNDO.
    DEF OUTPUT PARAM par_crawseg AS RECID                   NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nrseqdig  AS INTE                           NO-UNDO.
    DEF VAR aux_contador  AS INTE                           NO-UNDO.
    DEF VAR aux_nrdeanos  AS INTEGER                        NO-UNDO.
    DEF VAR aux_nrdmeses  AS INTEGER                        NO-UNDO.
    DEF VAR aux_dsdidade  AS CHAR                           NO-UNDO.
    DEF VAR h-b1wgen0001  AS HANDLE                         NO-UNDO.
    DEF VAR aux_qtsegass  AS INTE                           NO-UNDO.
    DEF VAR aux_vltotseg  AS DECI                           NO-UNDO.
    DEF VAR aux_cdempres  LIKE par_cdempres                 NO-UNDO.
    DEF VAR aux_dtrenova  LIKE crapseg.dtrenova             NO-UNDO.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,",")).
           
    EMPTY TEMP-TABLE tt-pldepara.

	/*enquanto o crps604 puder renovar os tipos de seguros
	  caregados na temp-table ira carregar ela apenas qdo
	  a solicitacao vier de alguma tela*/
	IF  TRIM(par_nmdatela) <> "" THEN 
		DO: 
			RUN cria-tabela-depara(OUTPUT TABLE tt-pldepara).
		END.
    
    EMPTY TEMP-TABLE tt-erro.

    valida:
    DO:

        /*Procuro se esta na tabela de|para e preencho as variaveis de acordo
          caso encontre na tabela*/
        FIND tt-pldepara WHERE tt-pldepara.cdsegura = par_cdsegura
                           AND tt-pldepara.tpseguro = par_tpseguro
                           AND tt-pldepara.tpplasde = par_tpplaseg
                                                      NO-LOCK NO-ERROR.

		/*Se encontrar nao deixa incluir o seguro*/											   
        IF  AVAIL(tt-pldepara) THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Este plano de seguro esta bloqueado para contratacao.".
                EMPTY TEMP-TABLE tt-erro.
                LEAVE valida.
            END.

        RUN buscar_associados (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT par_cdoperad,
                               INPUT par_dtmvtolt,
                               INPUT par_nrdconta,
                               INPUT par_idseqttl,
                               INPUT par_idorigem,
                               INPUT par_nmdatela,
                               INPUT par_flgerlog,
                               OUTPUT TABLE tt-associado,
                               OUTPUT TABLE tt-erro).
            
        IF  RETURN-VALUE <> "OK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                IF   AVAIL tt-erro   THEN
                    DO:
                        ASSIGN aux_cdcritic = tt-erro.cdcritic
                               aux_dscritic = tt-erro.dscritic.
                        EMPTY TEMP-TABLE tt-erro.
                        LEAVE valida.
                    END.
            END.
                     
        FIND FIRST tt-associado WHERE
                   tt-associado.cdcooper = par_cdcooper  AND
                   tt-associado.nrdconta = par_nrdconta  NO-ERROR.

        IF par_nrcpfcgc = "0" THEN
            ASSIGN par_nrcpfcgc = STRING(tt-associado.nrcpfcgc).


        ASSIGN aux_cdempres = par_cdempres.

        IF par_idorigem = 5 THEN
            DO:
                IF tt-associado.inpessoa <> 1  THEN /* juridica */
                    DO: 
                        RUN buscar_pessoa_juridica(INPUT par_cdcooper,
                                                   INPUT par_cdagenci,
                                                   INPUT par_nrdcaixa,
                                                   INPUT par_cdoperad,
                                                   INPUT par_dtmvtolt,
                                                   INPUT par_nrdconta,
                                                   INPUT par_idseqttl,
                                                   INPUT par_idorigem,
                                                   INPUT par_nmdatela,
                                                   INPUT par_flgerlog,
                                                   OUTPUT TABLE tt-pess-jur,
                                                   OUTPUT TABLE tt-erro).
        
                        IF   RETURN-VALUE <> "OK"  THEN
                            DO:
                                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                IF   AVAIL tt-erro   THEN
                                    DO:
                                        ASSIGN aux_cdcritic = tt-erro.cdcritic
                                               aux_dscritic = tt-erro.dscritic.
                                        EMPTY TEMP-TABLE tt-erro.
                                        LEAVE valida.
                                    END.
                            END.

                        FIND FIRST tt-pess-jur WHERE
                                   tt-pess-jur.cdcooper = par_cdcooper  AND
                                   tt-pess-jur.nrdconta = par_nrdconta  NO-ERROR.

                        ASSIGN aux_cdempres = tt-pess-jur.cdempres.
                        
                    END. /* juridica */
            END.
        
        RUN buscar_titular(INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT par_cdoperad,
                           INPUT par_dtmvtolt,
                           INPUT par_nrdconta,
                           INPUT par_idseqttl,
                           INPUT par_idorigem,
                           INPUT par_nmdatela,
                           INPUT par_flgerlog,
                           OUTPUT TABLE tt-titular,
                           OUTPUT TABLE tt-erro).

        IF   RETURN-VALUE <> "OK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                IF   AVAIL tt-erro   THEN
                    DO:
                        ASSIGN aux_cdcritic = tt-erro.cdcritic
                               aux_dscritic = tt-erro.dscritic.
                        EMPTY TEMP-TABLE tt-erro.
                        LEAVE valida.
                    END.
            END.

        FIND FIRST tt-titular WHERE
            tt-titular.cdcooper = par_cdcooper  AND
            tt-titular.nrdconta = par_nrdconta  NO-ERROR.
               
            
        IF tt-associado.inpessoa = 1 AND par_cdempres = 0 THEN 
            ASSIGN aux_cdempres = tt-titular.cdempres.
        

        RUN buscar_empresa (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT par_cdoperad,
                            INPUT par_dtmvtolt,
                            INPUT par_nrdconta,
                            INPUT par_idseqttl,
                            INPUT par_idorigem,
                            INPUT par_nmdatela,
                            INPUT par_flgerlog,
                            INPUT aux_cdempres,
                            OUTPUT TABLE tt-empresa,
                            OUTPUT TABLE tt-erro).
            

        IF   RETURN-VALUE <> "OK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                IF   AVAIL tt-erro   THEN
                    DO:
                        ASSIGN aux_cdcritic = tt-erro.cdcritic
                               aux_dscritic = tt-erro.dscritic.
                        EMPTY TEMP-TABLE tt-erro.
                        LEAVE valida.
                    END.
            END.

        FIND FIRST tt-empresa WHERE
                   tt-empresa.cdcooper = par_cdcooper       AND
                   tt-empresa.cdempres = aux_cdempres  NO-ERROR.

        IF par_tpseguro = 4 OR
           par_tpseguro = 3 THEN
           DO:
                IF  par_tpplaseg = 14 OR
                    par_tpplaseg = 18 OR
                    par_tpplaseg = 24 OR 
                    par_tpplaseg = 34 OR
                    par_tpplaseg = 44 OR
                    par_tpplaseg = 54 OR
                    par_tpplaseg = 64  THEN
                    DO:
                        EMPTY TEMP-TABLE tt-seguros.
                       
                        RUN busca_seguros(INPUT par_cdcooper,
                                          INPUT par_cdagenci,
                                          INPUT par_nrdcaixa,
                                          INPUT par_cdoperad,
                                          INPUT par_dtmvtolt,
                                          INPUT par_nrdconta,
                                          INPUT par_idseqttl,
                                          INPUT par_idorigem,
                                          INPUT par_nmdatela,
                                          INPUT par_flgerlog,
                                          OUTPUT TABLE tt-seguros,
                                          OUTPUT aux_qtsegass,
                                          OUTPUT aux_vltotseg,
                                          OUTPUT TABLE tt-erro). 
                         
                        FIND FIRST tt-seguros WHERE tt-seguros.cdcooper = par_cdcooper    AND
                                                    tt-seguros.nrdconta = par_nrdconta    AND
                                                    tt-seguros.tpseguro = 3               AND 
                                                    tt-seguros.dtcancel = ?               AND
                                                    tt-seguros.cdsitseg = 1               AND
                                                   (tt-seguros.tpplaseg = 14              OR
                                                    tt-seguros.tpplaseg = 18              OR
                                                    tt-seguros.tpplaseg = 24              OR 
                                                    tt-seguros.tpplaseg = 34              OR
                                                    tt-seguros.tpplaseg = 44              OR
                                                    tt-seguros.tpplaseg = 54              OR
                                                    tt-seguros.tpplaseg = 64)
                                                    NO-LOCK NO-ERROR.
                                
                        IF AVAIL tt-seguros THEN 
                           DO:
                               ASSIGN aux_cdcritic = 648.
                              
                               EMPTY TEMP-TABLE tt-seguros.
                              
                               RUN gera_erro (INPUT par_cdcooper,
                                              INPUT par_cdagenci,
                                              INPUT par_nrdcaixa,
                                              INPUT 1, /** Sequencia **/
                                              INPUT aux_cdcritic,
                                              INPUT-OUTPUT aux_dscritic).
                              
                               ASSIGN  tt-erro.cdcritic = aux_cdcritic
                                       tt-erro.dscritic = aux_dscritic.
                              
                               RETURN "NOK".
                          
                           END.


                    END.

           /*seguros do tipo prest/vida não passam o código da seguradora
            realizada busca das informações da mesma conforme o tipo do plano 
            e o plano informado*/

                RUN buscar_seguradora(INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT par_nrdcaixa,
                                      INPUT par_cdoperad,
                                      INPUT par_dtmvtolt,
                                      INPUT par_nrdconta,
                                      INPUT par_idseqttl,
                                      INPUT par_idorigem,
                                      INPUT par_nmdatela,
                                      INPUT par_flgerlog,
                                      INPUT par_tpseguro,
                                      INPUT 1,
                                      INPUT par_cdsegura,
                                      INPUT "",
                                      OUTPUT aux_qtregist,
                                      OUTPUT TABLE tt-seguradora,
                                      OUTPUT TABLE tt-erro).

                IF   RETURN-VALUE <> "OK"  THEN
                    DO:
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.
                        IF   AVAIL tt-erro   THEN
                            DO:
                                ASSIGN aux_cdcritic = tt-erro.cdcritic
                                       aux_dscritic = tt-erro.dscritic.
                                EMPTY TEMP-TABLE tt-erro.
                                LEAVE valida.
                            END.
                    END.
        
                FIND FIRST tt-seguradora WHERE
                           tt-seguradora.cdcooper = par_cdcooper  AND
                           (IF par_cdsegura <> 0 THEN
                               tt-seguradora.cdsegura = par_cdsegura
                            ELSE TRUE) NO-ERROR.
        
                IF par_cdsegura = 0 THEN
                    ASSIGN par_cdsegura = tt-seguradora.cdsegura.

                RUN atualizar_matricula(INPUT par_cdcooper,
                                        INPUT par_cdagenci,
                                        INPUT par_nrdcaixa,
                                        INPUT par_cdoperad,
                                        INPUT par_dtmvtolt,
                                        INPUT par_nrdconta,
                                        INPUT par_idseqttl,
                                        INPUT par_idorigem,
                                        INPUT par_nmdatela,
                                        INPUT par_flgerlog,
                                        OUTPUT TABLE tt-matricula,
                                        OUTPUT TABLE tt-erro).

                IF   RETURN-VALUE <> "OK"  THEN
                    DO:
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.
                        IF   AVAIL tt-erro   THEN
                            DO:
                                ASSIGN aux_cdcritic = tt-erro.cdcritic
                                       aux_dscritic = tt-erro.dscritic.
                                EMPTY TEMP-TABLE tt-erro.
                                LEAVE valida.
                            END.
                    END.

                FIND FIRST tt-matricula WHERE
                           tt-matricula.cdcooper = par_cdcooper  NO-ERROR.

                ASSIGN par_nrctrseg = tt-matricula.nrctrseg.
                
            END.

         RUN buscar_plano_seguro( INPUT par_cdcooper,
                                  INPUT par_cdagenci,
                                  INPUT par_nrdcaixa,
                                  INPUT par_cdoperad,
                                  INPUT par_dtmvtolt,
                                  INPUT par_nrdconta,
                                  INPUT par_idseqttl,
                                  INPUT par_idorigem,
                                  INPUT par_nmdatela,
                                  INPUT par_flgerlog,
                                  INPUT par_cdsegura,
                                  INPUT par_tpseguro,
                                  INPUT par_tpplaseg,
                                  OUTPUT TABLE tt-plano-seg,
                                  OUTPUT TABLE tt-erro).

        IF   RETURN-VALUE <> "OK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                IF   AVAIL tt-erro   THEN
                    DO:
                        ASSIGN aux_cdcritic = tt-erro.cdcritic
                               aux_dscritic = tt-erro.dscritic.
                        EMPTY TEMP-TABLE tt-erro.
                        LEAVE valida.
                    END.
            END.

        FIND FIRST tt-plano-seg                                     WHERE
                   tt-plano-seg.cdcooper = par_cdcooper             AND
                   tt-plano-seg.cdsegura = par_cdsegura             AND
                   tt-plano-seg.tpseguro = par_tpseguro             AND
                   tt-plano-seg.tpplaseg = par_tpplaseg             NO-ERROR.
        
        /* realiza calculo da data de debito para origem web
          11 - Casa
           3 - Vida  */
        IF par_idorigem = 5  AND 
           (par_tpseguro = 11 OR 
            par_tpseguro =  3) THEN
            DO:
                
                RUN calcular_data_debito(INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT par_cdoperad,
                                         INPUT par_dtmvtolt,
                                         INPUT par_nrdconta,
                                         INPUT par_idseqttl,
                                         INPUT par_idorigem,
                                         INPUT par_nmdatela,
                                         INPUT par_flgerlog,
                                         INPUT par_flgunica,
                                         INPUT tt-plano-seg.qtmaxpar,
                                         INPUT tt-plano-seg.mmpripag,
                                         INPUT par_dtdebito,
                                         INPUT par_dtprideb,
                                         OUTPUT par_dtdebito,
                                         OUTPUT par_dtprideb,
                                         OUTPUT TABLE tt-erro).
            END.

        IF par_tpseguro = 11 THEN
            DO:
                /* Este tratamento foi feito devido aos seguros que vencem 
                   em feriado/final de semana, onde o mes de vencimento eh
                   diferente do dia da renovacao. Nestes casos deve-se
                   criar o registro com data do proximo dia util para
                   contabilizar junto aos seguros do proximo mes  */ 
                IF   par_cdsitseg = 3  THEN  /* Renovacao */ 
                     par_dtmvtolt = par_dtprideb.
                
                DO WHILE TRUE:
                    DO aux_contador = 1 TO 10: /* Lock da craplot */
            
                       FIND craplot WHERE
                            craplot.cdcooper = par_cdcooper           AND
                            craplot.dtmvtolt = par_dtmvtolt           AND
                            craplot.cdagenci = tt-associado.cdagenci  AND
                            craplot.cdbccxlt = par_cdbccxlt           AND
                            craplot.nrdolote = par_nrdolote
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
            
                       IF   NOT AVAILABLE craplot   THEN
                            IF   LOCKED craplot   THEN
                                 DO:
                                     aux_cdcritic = 84.
                                     PAUSE 1 NO-MESSAGE.
                                     NEXT.
                                 END.
                       aux_cdcritic = 0.
                       LEAVE.
                    END.
                    LEAVE.
                END.
                /* verifica validação da craplot*/
                IF aux_cdcritic <> 0 THEN LEAVE valida.
        
                IF   NOT AVAILABLE craplot   THEN
                     DO:
                         CREATE craplot.
                         ASSIGN craplot.cdcooper = par_cdcooper
                                craplot.dtmvtolt = par_dtmvtolt
                                craplot.cdagenci = tt-associado.cdagenci
                                craplot.cdbccxlt = par_cdbccxlt
                                craplot.nrdolote = par_nrdolote
                                craplot.tplotmov = 15
                                craplot.cdhistor = 0
                                craplot.nrseqdig = 1
                                craplot.flgltsis = YES
                                craplot.tpdmoeda = 1.
                         VALIDATE craplot.
                     END.
            
                ASSIGN craplot.qtcompln = craplot.qtcompln + 1
                       craplot.qtinfoln = craplot.qtinfoln + 1
                       craplot.vlcompcr = craplot.vlcompcr + par_vlpreseg
                       craplot.vlinfocr = craplot.vlinfocr + par_vlpreseg.
                

                ASSIGN aux_nrseqdig = par_nrctrseg.
                /* Pra nao dar erro na chave crapseg3 */
                FOR EACH crapseg WHERE
                         crapseg.cdcooper = par_cdcooper          AND
                         crapseg.dtmvtolt = par_dtmvtolt          AND
                         crapseg.cdagenci = tt-associado.cdagenci AND
                         crapseg.cdbccxlt = par_cdbccxlt          AND
                         crapseg.nrdolote = par_nrdolote          NO-LOCK
                    BREAK BY crapseg.nrseqdig:
            
                    ASSIGN aux_nrseqdig = crapseg.nrseqdig + 1.
                END.
            END.

        IF par_nmdsegur = "" THEN
            ASSIGN par_nmdsegur = IF AVAIL tt-associado THEN 
                                  tt-associado.nmprimtl 
                                  ELSE "".
                       
        CREATE crawseg.

        ASSIGN crawseg.dtmvtolt = par_dtmvtolt
               crawseg.dtdebito = par_dtdebito
               crawseg.nrdconta = par_nrdconta
               crawseg.nrctrseg = par_nrctrseg
               crawseg.tpseguro = par_tpseguro
               crawseg.cdsegura = par_cdsegura
               crawseg.nrcpfcgc = par_nrcpfcgc
               crawseg.nmdsegur = CAPS(par_nmdsegur)
               crawseg.dtinivig = par_dtinivig
               crawseg.dtiniseg = par_dtinivig
               crawseg.dtfimvig = IF  par_tpseguro = 3 OR par_tpseguro = 4 
                                    THEN ? 
                                  ELSE par_dtfimvig
               crawseg.vlpremio = IF  par_tpseguro = 11 THEN
                                  tt-plano-seg.vlplaseg
                                  ELSE 0
               crawseg.vlpreseg = par_vlpreseg
               crawseg.cdcalcul = par_cdcalcul
               crawseg.tpplaseg = par_tpplaseg
               crawseg.vlseguro = par_vlseguro
               crawseg.dtprideb = par_dtprideb
               crawseg.flgunica = par_flgunica
               crawseg.dsendres = CAPS(par_dsendres)
               crawseg.nrendres = par_nrendres
               crawseg.nmbairro = CAPS(par_nmbairro)
               crawseg.nmcidade = CAPS(par_nmcidade)
               crawseg.cdufresd = par_cdufresd
               crawseg.nrcepend = par_nrcepend
               crawseg.cdcooper = par_cdcooper
               crawseg.complend = CAPS(par_complend).
                                       
        /*campos do seguro_i.p*/
        IF par_tpseguro = 3 OR
           par_tpseguro = 4 THEN
            DO:
                
                ASSIGN crawseg.dtnascsg = par_dtnascsg 
                       crawseg.vlbenefi = 0
                       crawseg.nrcadast = tt-associado.nrcadast
                       crawseg.nrfonemp = tt-associado.nrfonemp
                       crawseg.nrfonres = tt-associado.nrfonres
                       crawseg.dsmarvei = ""
                       crawseg.dstipvei = ""
                       crawseg.nranovei = 0
                       crawseg.nrmodvei = 0
                       crawseg.nrdplaca = ""
                       crawseg.qtpasvei = 0
                       crawseg.dschassi = ""
                       crawseg.ppdbonus = 0
                       crawseg.flgdnovo = FALSE
                       crawseg.flgrenov = FALSE
                       crawseg.cdapoant = ""
                       crawseg.nmsegant = ""
                       crawseg.flgdutil = TRUE
                       crawseg.flgnotaf = FALSE
                       crawseg.flgapant = FALSE
                       crawseg.vldfranq = 0
                       crawseg.vldcasco = 0
                       crawseg.vlverbae = 0
                       crawseg.flgassis = FALSE
                       crawseg.vldanmat = 0
                       crawseg.vldanpes = 0
                       crawseg.vldanmor = 0
                       crawseg.vlappmor = 0
                       crawseg.vlappinv = 0
                       crawseg.flgcurso = FALSE
                       crawseg.flgrepgr = FALSE
                       crawseg.nrctrato = 0
                       crawseg.flgvisto = FALSE
                       crawseg.vlfrqobr = 0
                       crawseg.qtparcel = 0
                       crawseg.nmempres = IF AVAIL tt-empresa THEN
                                              CAPS(tt-empresa.nmextemp)
                                          ELSE ""
                       crawseg.tpsegvid = IF crawseg.nmdsegur =
                                             tt-associado.nmprimtl 
                                          THEN 1
                                          ELSE 2
                       crawseg.nmbenefi = IF par_tpseguro = 3 OR 
                                             par_tpseguro = 4 THEN
                                              ""
                                          ELSE CAPS(par_nmdsegur)
                       crawseg.cdsexosg = IF par_cdsexosg <> 0 THEN
                                              par_cdsexosg
                                          ELSE tt-associado.cdsexotl 
                       crawseg.nrctrseg = par_nrctrseg.

                    


            END.
        ELSE
                ASSIGN crawseg.qtparcel = IF tt-plano-seg.flgunica THEN 1
                                          ELSE tt-plano-seg.qtmaxpar.
    
        VALIDATE crawseg.

        ASSIGN par_crawseg = RECID(crawseg).

        /* Inicio - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
        IF par_cdagenci = 0 THEN
          ASSIGN par_cdagenci = glb_cdagenci.
        /* Fim - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */


        CREATE crapseg.

        ASSIGN crapseg.cdcooper = par_cdcooper
               crapseg.cdoperad = par_cdoperad
               crapseg.dtmvtolt = par_dtmvtolt
               crapseg.nrseqdig = IF par_tpseguro = 11 THEN 
                                    aux_nrseqdig
                                  ELSE par_nrctrseg
               crapseg.nrctrseg = par_nrctrseg
               crapseg.cdagenci = tt-associado.cdagenci
               crapseg.cdbccxlt = par_cdbccxlt
               crapseg.nrdolote = par_nrdolote
               crapseg.cdsitseg = par_cdsitseg
               crapseg.dtaltseg = par_dtaltseg
               crapseg.dtcancel = par_dtcancel
               crapseg.dtdebito = par_dtdebito
               crapseg.dtinivig = crawseg.dtinivig
               crapseg.dtfimvig = crawseg.dtfimvig
               crapseg.cdsegura = par_cdsegura
               crapseg.indebito = par_indebito
               crapseg.nrdconta = par_nrdconta
               crapseg.dtultpag = IF par_tpseguro <> 11 THEN 
                                     par_dtmvtolt
                                  ELSE ?
               crapseg.dtiniseg = par_dtiniseg
               crapseg.qtparcel = crawseg.qtparcel
               crapseg.dtprideb = par_dtprideb
               crapseg.qtprepag = par_qtprepag
               crapseg.qtprevig = par_qtprevig
               crapseg.vlprepag = par_vlprepag
               crapseg.vldifseg = par_vldifseg
               crapseg.flgunica = par_flgunica
               crapseg.tpseguro = par_tpseguro
               crapseg.tpplaseg = par_tpplaseg
               crapseg.vlpreseg = par_vlpreseg
               crapseg.lsctrant = par_lsctrant
               crapseg.nrctratu = par_nrctratu
               crapseg.tpendcor = par_tpendcor
               crapseg.nmbenvid[1] = CAPS(par_nmbenvid1)
               crapseg.nmbenvid[2] = CAPS(par_nmbenvid2)
               crapseg.nmbenvid[3] = CAPS(par_nmbenvid3)
               crapseg.nmbenvid[4] = CAPS(par_nmbenvid4)
               crapseg.nmbenvid[5] = CAPS(par_nmbenvid5)
               crapseg.txpartic[1] = par_txpartic1
               crapseg.txpartic[2] = par_txpartic2
               crapseg.txpartic[3] = par_txpartic3
               crapseg.txpartic[4] = par_txpartic4
               crapseg.txpartic[5] = par_txpartic5
               crapseg.dsgraupr[1] = CAPS(par_dsgraupr1)
               crapseg.dsgraupr[2] = CAPS(par_dsgraupr2)
               crapseg.dsgraupr[3] = CAPS(par_dsgraupr3)
               crapseg.dsgraupr[4] = CAPS(par_dsgraupr4)
               crapseg.dsgraupr[5] = CAPS(par_dsgraupr5)
               crapseg.cdmotcan    = par_cdmotcan
               crapseg.flgconve    = par_flgconve
               crapseg.nrctratu    = par_nrctratu
               crapseg.qtprepag    = par_qtprepag
               crapseg.qtprevig    = par_qtprevig
               crapseg.tpdpagto    = par_tpdpagto
               crapseg.tpendcor    = par_tpendcor
               crapseg.vldifseg    = par_vldifseg
               crapseg.vlpremio    = crawseg.vlpremio
               /* Inicio - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
               crapseg.cdopeori = par_cdoperad
               crapseg.cdageori = par_cdagenci
               crapseg.dtinsori = TODAY
               /* Fim - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
               crapseg.vlprepag    = par_vlprepag.

        IF par_tpseguro = 1   OR
           par_tpseguro = 11  THEN
            ASSIGN crapseg.flgclabe = par_flgclabe.

        IF par_tpseguro = 3 OR
           par_tpseguro = 4 THEN
            DO:
                ASSIGN crapseg.nrseqdig = crapseg.nrctrseg
                       /* para o tipo de seguro VIDA deve gravar 
                         data do pimeiro debito */
                       crapseg.dtprideb = 
                           IF par_tpseguro = 4 THEN 
                              ?
                           ELSE
                              crapseg.dtprideb  
                       crapseg.vldifseg = 0
                       crapseg.flgunica = FALSE.

            END.

        /* Seguro de Vida */
        IF par_tpseguro = 3 THEN
           DO:
              /* Renovacao do seguro de vida, sempre ocorrera no maximo dia 27 */
              IF DAY(crapseg.dtinivig) >= 29 THEN
                 DO:
                     ASSIGN aux_dtrenova = DATE(MONTH(crapseg.dtinivig),
                                                28,
                                                YEAR(crapseg.dtinivig) + 1).
                 END.
              ELSE
                 DO:
                     ASSIGN aux_dtrenova = DATE(MONTH(crapseg.dtinivig),
                                                DAY(crapseg.dtinivig),
                                                YEAR(crapseg.dtinivig) + 1).
                 END.

              ASSIGN crapseg.dtrenova = aux_dtrenova.

           END. /* END IF par_tpseguro = 3 THEN */

        VALIDATE crapseg.

    END. /* valida: */

    EMPTY TEMP-TABLE tt-erro.
    /* Caso seja efetuada alguma alteracao na descricao deste log,
              devera ser tratado o relatorio de "demonstrativo produtos por
              colaborador" da tela CONGPR. (Fabricio - 04/05/2012) */
    ASSIGN aux_dstransa = "Efetivado o seguro do tipo: " +
                          IF (par_tpseguro = 1   OR
                              par_tpseguro = 11) THEN 
                              "SEGURO RESIDENCIAL."
                          ELSE
                             IF par_tpseguro = 3 THEN
                                "SEGURO DE VIDA."
                             ELSE "SEGURO PRESTAMISTA.".

   
    
    IF   aux_cdcritic <> 0    OR
         aux_dscritic <> ""   THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1, /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             
             IF   par_flgerlog  THEN
                  RUN proc_gerar_log (INPUT  par_cdcooper,
                                      INPUT  par_cdoperad,
                                      INPUT  aux_dscritic,
                                      INPUT  aux_dsorigem,
                                      INPUT  aux_dstransa,
                                      INPUT  FALSE, 
                                      INPUT  par_idseqttl,
                                      INPUT  par_nmdatela,
                                      INPUT  par_nrdconta,
                                      OUTPUT aux_nrdrowid).   
             RETURN "NOK".

         END.    
    
     /*A par_flgerlog esta vindo como FALSE para evitar que entre na mesma 
      condicao abaixo, feita nas demais procedures, chamdas dentro da 
      cria_seguro. Assim, nao gerando varios registros na craplgm*/
    par_flgerlog = TRUE.
    
    IF par_flgerlog  THEN
       DO:
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

       END.
 
     /* Abaixo e verificado se e seguro de VIDA e para os planos abaixo, 
        retorna par_flgsegur = true para mensagen alerta */
     IF  par_tpseguro = 3 AND
         CAN-DO("11,15,21,31,41,51,61",STRING(par_tpplaseg)) THEN 
         ASSIGN par_flgsegur = TRUE.
     ELSE
         ASSIGN par_flgsegur = FALSE.
        
    RETURN "OK".


END PROCEDURE.

PROCEDURE validar_criacao:

    DEF INPUT PARAM par_cdcooper    AS INTE                     NO-UNDO.   
    DEF INPUT PARAM par_cdagenci    AS INTE                     NO-UNDO.   
    DEF INPUT PARAM par_nrdcaixa    AS INTE                     NO-UNDO.   
    DEF INPUT PARAM par_cdoperad    AS CHAR                     NO-UNDO.   
    DEF INPUT PARAM par_dtmvtolt    AS DATE                     NO-UNDO.   
    DEF INPUT PARAM par_nrdconta    AS INTE                     NO-UNDO.   
    DEF INPUT PARAM par_idseqttl    AS INTE                     NO-UNDO.   
    DEF INPUT PARAM par_idorigem    AS INTE                     NO-UNDO.   
    DEF INPUT PARAM par_nmdatela    AS CHAR                     NO-UNDO.   
    DEF INPUT PARAM par_flgerlog    AS LOGI                     NO-UNDO.   
    DEF INPUT PARAM par_cdsegura    LIKE crapseg.cdsegura       NO-UNDO.   
    DEF INPUT PARAM par_dddebito    AS INT                      NO-UNDO.   
    DEF INPUT PARAM par_dtfimvig    LIKE crapseg.dtfimvig       NO-UNDO.   
    DEF INPUT PARAM par_dtinivig    LIKE crapseg.dtinivig       NO-UNDO.   
    DEF INPUT PARAM par_dtprideb    LIKE crapseg.dtprideb       NO-UNDO.   
    DEF INPUT PARAM par_nmbenvid1   AS CHAR FORMAT "x(40)"      NO-UNDO.   
    DEF INPUT PARAM par_nmbenvid2   AS CHAR FORMAT "x(40)"      NO-UNDO.   
    DEF INPUT PARAM par_nmbenvid3   AS CHAR FORMAT "x(40)"      NO-UNDO.   
    DEF INPUT PARAM par_nmbenvid4   AS CHAR FORMAT "x(40)"      NO-UNDO.   
    DEF INPUT PARAM par_nmbenvid5   AS CHAR FORMAT "x(40)"      NO-UNDO.   
    DEF INPUT PARAM par_nrctrseg    LIKE crapseg.nrctrseg       NO-UNDO.   
    DEF INPUT PARAM par_nrdolote    AS INTE                     NO-UNDO.   
    DEF INPUT PARAM par_tpplaseg    LIKE crapseg.tpplaseg       NO-UNDO.   
    DEF INPUT PARAM par_tpseguro    LIKE crapseg.tpseguro       NO-UNDO.   
    DEF INPUT PARAM par_txpartic1   AS DECIMAL FORMAT ">>9.99"  NO-UNDO.   
    DEF INPUT PARAM par_txpartic2   AS DECIMAL FORMAT ">>9.99"  NO-UNDO.   
    DEF INPUT PARAM par_txpartic3   AS DECIMAL FORMAT ">>9.99"  NO-UNDO.   
    DEF INPUT PARAM par_txpartic4   AS DECIMAL FORMAT ">>9.99"  NO-UNDO.   
    DEF INPUT PARAM par_txpartic5   AS DECIMAL FORMAT ">>9.99"  NO-UNDO.   
    DEF INPUT PARAM par_vlpreseg    LIKE crapseg.vlpreseg       NO-UNDO.   
    DEF INPUT PARAM par_vlcapseg    LIKE craptsg.vlmorada       NO-UNDO.   
    DEF INPUT PARAM par_cdbccxlt    AS INTE                     NO-UNDO.   
    DEF INPUT PARAM par_nrcpfcgc    LIKE crawseg.nrcpfcgc       NO-UNDO.   
    DEF INPUT PARAM par_nmdsegur    LIKE crawseg.nmdsegur       NO-UNDO.   
    DEF INPUT PARAM par_nmcidade    LIKE crawseg.nmcidade       NO-UNDO.   
    DEF INPUT PARAM par_nrcepend    LIKE crawseg.nrcepend       NO-UNDO. 
    DEF INPUT PARAM par_tpendcor    LIKE crapseg.tpendcor       NO-UNDO. 
    DEF INPUT PARAM par_nrpagina    AS INT                      NO-UNDO.    
    DEF INPUT PARAM par_dtnascsg    AS DATE                     NO-UNDO.
                                                                                                                                                                   
    DEF OUTPUT PARAM par_crawseg    AS RECID                    NO-UNDO.                                                                                           
    DEF OUTPUT PARAM par_nmdcampo   AS CHAR                     NO-UNDO.                           
    DEF OUTPUT PARAM TABLE FOR tt-erro.                                                                                       

    DEF VAR aux_nrseqdig  AS INTE                    NO-UNDO.
    DEF VAR aux_contador  AS INTE                    NO-UNDO.
    DEF VAR aux_nrdeanos  AS INTEGER                 NO-UNDO.
    DEF VAR aux_nrdmeses  AS INTEGER                 NO-UNDO.
    DEF VAR aux_dsdidade  AS CHAR                    NO-UNDO.
    DEF VAR h-b1wgen0001  AS HANDLE                  NO-UNDO.
    DEF VAR aux_qtsegass  AS INTE                    NO-UNDO.
    DEF VAR aux_vltotseg  AS DECI                    NO-UNDO.
    DEF VAR aux_dtdebito  AS DATE                    NO-UNDO.

    /*par_nrpagina foi utilizado para realizar as validações de seguro  do
    tipo casa de acordo com a frame */              
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Efetivar o seguro automaticamente." .

    EMPTY TEMP-TABLE tt-erro.
    
    valida:
    DO:
        IF par_cdsegura = 0  AND
           par_tpseguro = 11 THEN
            DO:
                ASSIGN aux_dscritic = "Seguradora deve ser informada.".
                LEAVE valida.
            END.

        IF par_nrpagina = 1 OR 
           par_tpseguro <> 11 THEN
            DO:
                RUN buscar_seguradora(INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT par_nrdcaixa,
                                      INPUT par_cdoperad,
                                      INPUT par_dtmvtolt,
                                      INPUT par_nrdconta,
                                      INPUT par_idseqttl,
                                      INPUT par_idorigem,
                                      INPUT par_nmdatela,
                                      INPUT par_flgerlog,
                                      INPUT par_tpseguro,
                                      INPUT 1,
                                      INPUT par_cdsegura,
                                      INPUT "",
                                      OUTPUT aux_qtregist,
                                      OUTPUT TABLE tt-seguradora,
                                      OUTPUT TABLE tt-erro).
        
                IF  RETURN-VALUE <> "OK"  THEN
                    DO:
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.
                        IF   AVAIL tt-erro   THEN
                            DO:
                                ASSIGN aux_cdcritic = tt-erro.cdcritic
                                       aux_dscritic = tt-erro.dscritic.
                                EMPTY TEMP-TABLE tt-erro.
                                LEAVE valida.
                            END.
                    END.
        
                FIND FIRST tt-seguradora WHERE
                           tt-seguradora.cdcooper = par_cdcooper  AND
                           (IF par_cdsegura <> 0 THEN
                               tt-seguradora.cdsegura = par_cdsegura
                            ELSE TRUE) NO-ERROR.
                            
                RUN buscar_plano_seguro(INPUT par_cdcooper,
                                        INPUT par_cdagenci,
                                        INPUT par_nrdcaixa,
                                        INPUT par_cdoperad,
                                        INPUT par_dtmvtolt,
                                        INPUT par_nrdconta,
                                        INPUT par_idseqttl,
                                        INPUT par_idorigem,
                                        INPUT par_nmdatela,
                                        INPUT par_flgerlog,
                                        INPUT tt-seguradora.cdsegura,
                                        INPUT par_tpseguro,
                                        INPUT par_tpplaseg,
                                        OUTPUT TABLE tt-plano-seg,
                                        OUTPUT TABLE tt-erro).
        
                IF   RETURN-VALUE <> "OK"  THEN
                    DO:
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.
                        IF   AVAIL tt-erro   THEN
                            DO:
                                ASSIGN aux_cdcritic = tt-erro.cdcritic
                                       aux_dscritic = tt-erro.dscritic.
                                EMPTY TEMP-TABLE tt-erro.
                                LEAVE valida.
                            END.
                    END.
        
                IF par_cdsegura = 0 THEN
                    ASSIGN par_cdsegura = tt-seguradora.cdsegura.
        
                /* realizada inclusão da critica 200 visto que pode ser passado
                o código do plano igual a zero e a buscar_plano_seguros ter re-
                tornado todos os registros de planos existeste par_tpplaseg = 0*/
                FIND FIRST tt-plano-seg WHERE
                           tt-plano-seg.cdcooper = par_cdcooper             AND
                           tt-plano-seg.cdsegura = tt-seguradora.cdsegura   AND
                           tt-plano-seg.tpseguro = par_tpseguro             AND
                           tt-plano-seg.tpplaseg = par_tpplaseg             
                           NO-ERROR.

                IF NOT AVAIL tt-plano-seg THEN
                    DO:
                        ASSIGN aux_cdcritic = 200.
                        LEAVE valida.
                    END.

                RUN sistema/generico/procedures/b1wgen0001.p 
                        PERSISTENT SET h-b1wgen0001.
            
                RUN ver_capital IN h-b1wgen0001(INPUT par_cdcooper,
                                                INPUT par_nrdconta,
                                                INPUT 0, 
                                                INPUT 0,
                                                INPUT 0,
                                                INPUT par_dtmvtolt,
                                                INPUT par_nmdatela,
                                                INPUT par_idorigem,
                                                OUTPUT TABLE tt-erro).

                IF   RETURN-VALUE <> "OK"  THEN
                    DO:
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.
                        IF   AVAIL tt-erro   THEN
                            DO:
                                ASSIGN aux_cdcritic = tt-erro.cdcritic
                                       aux_dscritic = tt-erro.dscritic.
                                EMPTY TEMP-TABLE tt-erro.
                                LEAVE valida.
                            END.
                    END.

                RUN ver_cadastro IN h-b1wgen0001(INPUT par_cdcooper,
                                                 INPUT par_nrdconta,
                                                 INPUT par_cdagenci, 
                                                 INPUT par_nrdcaixa,
                                                 INPUT par_dtmvtolt,
                                                 INPUT par_idorigem,
                                                 OUTPUT TABLE tt-erro).
        
                IF   RETURN-VALUE <> "OK"  THEN
                    DO:
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.
                        IF   AVAIL tt-erro   THEN
                            DO:
                                ASSIGN aux_cdcritic = tt-erro.cdcritic
                                       aux_dscritic = tt-erro.dscritic.
                                EMPTY TEMP-TABLE tt-erro.
                                LEAVE valida.
                            END.
                    END.
                 DELETE PROCEDURE h-b1wgen0001.
            END.
        
        /* Validação dados seguro CASA,  1 página */ 
        IF par_nrpagina  = 1 THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "".

                IF par_nrctrseg = 0  THEN
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Numero da proposta incorreto."
                           par_nmdcampo = "seg_nrctrseg".
                ELSE
                IF par_dddebito = 0 THEN
                     ASSIGN aux_cdcritic = 0
                            aux_dscritic = "Dia deve ser diferente de zero."
                            par_nmdcampo = "seg_ddvencto".
                ELSE
                IF par_dddebito > 28 OR par_dddebito = ? THEN
                     ASSIGN aux_cdcritic = 0
                            aux_dscritic = "Dia deve ser menor ou igual a 28."
                            par_nmdcampo = "seg_ddvencto".
                ELSE
                IF ( par_dddebito > 0 AND par_dddebito > tt-plano-seg.ddmaxpag)
                    OR tt-plano-seg.ddmaxpag = 0 THEN 
                     DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Dia deve ser menor ou igual a 28."
                               par_nmdcampo = "seg_ddvencto".
                        /*
                        LEAVE valida. */
                    END.
                ELSE
                IF par_nrcepend = 0 THEN
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "CEP deve ser diferente de zero."
                           par_nmdcampo = "seg_nrcepend".
                ELSE
                    DO:
                        RUN sistema/generico/procedures/b1wgen0038.p 
                            PERSISTENT SET h-b1wgen0038.
        
                        RUN busca-endereco IN h-b1wgen0038
                            (INPUT par_nrcepend,
                             INPUT "", /* dsendere */
                             INPUT "", /* nmcidade */
                             INPUT "", /* cdufende */
                             INPUT 1,  /* nrregist */
                             INPUT 1,  /* nriniseq */
                             INPUT par_idorigem,
                             OUTPUT aux_qtregist,
                             OUTPUT TABLE tt-endereco).
        
                        DELETE PROCEDURE h-b1wgen0038.
        
                        FIND FIRST tt-endereco NO-LOCK NO-ERROR.
                        IF NOT AVAIL tt-endereco THEN
                            ASSIGN aux_dscritic = "CEP nao encontrado."
                                   par_nmdcampo = "seg_nrcepend".
                    END.
                
                IF  par_nmcidade = "" THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Pressioner [enter] no CEP para preencher a cidade."
                           par_nmdcampo = "seg_nrcepend".
                END.

                IF aux_cdcritic <> 0   OR
                   aux_dscritic <> ""  THEN LEAVE valida.
            END. /* par_nrpagina = 1 */
       
        /* Validação dados seguro CASA,  2 página */
        IF par_nrpagina  = 2 THEN
            DO:
             RUN busca_end_cor(INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT par_cdoperad,
                              INPUT par_dtmvtolt,
                              INPUT par_nrdconta,
                              INPUT par_idseqttl,
                              INPUT par_idorigem,
                              INPUT par_nmdatela,
                              INPUT par_flgerlog,
                              INPUT par_nrctrseg,
                              INPUT par_tpendcor,
                              OUTPUT TABLE tt_end_cor,
                              OUTPUT TABLE tt-erro).

                IF   RETURN-VALUE <> "OK"  THEN
                    DO:
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.
                        IF   AVAIL tt-erro   THEN
                            DO:
                                ASSIGN aux_cdcritic = tt-erro.cdcritic
                                       aux_dscritic = tt-erro.dscritic.
                                EMPTY TEMP-TABLE tt-erro.
                                LEAVE valida.
                            END.
                    END.

                /* Se nao for a vista, cacula a data do proximo debito */
                RUN busca_seguros(INPUT par_cdcooper,
                                  INPUT par_cdagenci,
                                  INPUT par_nrdcaixa,
                                  INPUT par_cdoperad,
                                  INPUT par_dtmvtolt,
                                  INPUT par_nrdconta,
                                  INPUT par_idseqttl,
                                  INPUT par_idorigem,
                                  INPUT par_nmdatela,
                                  INPUT par_flgerlog,
                                  OUTPUT TABLE tt-seguros,
                                  OUTPUT aux_qtsegass,
                                  OUTPUT aux_vltotseg,
                                  OUTPUT TABLE tt-erro).

                RUN buscar_proposta_seguro(INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT par_cdoperad,
                                           INPUT par_dtmvtolt,
                                           INPUT par_nrdconta,
                                           INPUT par_idseqttl,
                                           INPUT par_idorigem,
                                           INPUT par_nmdatela,
                                           INPUT par_flgerlog,
                                           OUTPUT TABLE tt-prop-seguros,
                                           OUTPUT aux_qtsegass,
                                           OUTPUT aux_vltotseg,
                                           OUTPUT TABLE tt-erro).

                /* verifica se ja foi aprovado */
                FIND tt-seguros WHERE
                     tt-seguros.cdcooper = par_cdcooper  AND
                     tt-seguros.cdsegura = par_cdsegura  AND
                     tt-seguros.nrdconta = par_nrdconta  AND
                     tt-seguros.nrctrseg = par_nrctrseg  
                     NO-ERROR.
 
                IF  AVAILABLE tt-seguros THEN
                    DO:
                        ASSIGN aux_cdcritic = 536.
                        LEAVE valida.

                    END.

                    
                /* verifica se ja exixte a proposta */
                FIND tt-prop-seguros WHERE
                     tt-prop-seguros.cdcooper = par_cdcooper  AND
                     tt-prop-seguros.cdsegura = par_cdsegura  AND
                     tt-prop-seguros.nrdconta = par_nrdconta  AND
                     tt-prop-seguros.nrctrseg = par_nrctrseg  
                     NO-ERROR.

                IF  AVAILABLE tt-prop-seguros THEN
                    DO:
                        ASSIGN aux_cdcritic = 573.
                        LEAVE valida.
                    END.

        END. /* par_nrpagina <> 1 */
        
        IF par_tpseguro = 4 /* prestamista */ THEN
            DO:
               IF par_vlpreseg <> 0 THEN
                    DO:
                        ASSIGN aux_cdcritic = 269
                             par_nmdcampo = "seg_vlpreseg".
                        LEAVE valida.
                    END.     
            END.              

        IF par_tpseguro = 3  OR     /* vida */
           par_tpseguro = 4  THEN   /* prestamista */
            DO:
                RUN validar_plano_seguro(INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT par_cdoperad,
                                         INPUT par_dtmvtolt,
                                         INPUT par_nrdconta,
                                         INPUT par_idseqttl,
                                         INPUT par_idorigem,
                                         INPUT par_nmdatela,
                                         INPUT par_flgerlog,
                                         INPUT tt-plano-seg.cdsitpsg,
                                         INPUT tt-plano-seg.vlplaseg,
                                         INPUT tt-plano-seg.vlmorada,
                                         INPUT par_vlpreseg,
                                         INPUT par_vlcapseg,
                                         OUTPUT par_nmdcampo,
                                         OUTPUT TABLE tt-erro).
        
                IF   RETURN-VALUE <> "OK"  THEN
                    DO:
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.
                        IF   AVAIL tt-erro   THEN
                            DO:
                                ASSIGN aux_cdcritic = tt-erro.cdcritic
                                       aux_dscritic = tt-erro.dscritic.
                                EMPTY TEMP-TABLE tt-erro.
                                LEAVE valida.
                            END.
                    END.

                RUN sistema/generico/procedures/b1wgen9999.p
                    PERSISTENT SET h-b1wgen9999.

                RUN idade IN h-b1wgen9999(INPUT par_dtnascsg, 
                                          INPUT par_dtmvtolt,
                                          OUTPUT aux_nrdeanos,
                                          OUTPUT aux_nrdmeses,
                                          OUTPUT aux_dsdidade).

                DELETE PROCEDURE h-b1wgen9999.            
				
                IF aux_nrdeanos > tt-plano-seg.nrtabela THEN
                    DO:
                        ASSIGN aux_cdcritic = 647
                               par_nmdcampo = "seg_vlpreseg".

                        LEAVE valida.
                    END.
                
                IF aux_nrdeanos < 14 THEN
                    DO:
                        ASSIGN aux_dscritic = "Idade minima permitida: 14 anos."
                               par_nmdcampo = "seg_vlpreseg".

                        LEAVE valida.
                    END.

                IF par_nmdsegur = ""  OR
                   par_nrcpfcgc = "0" THEN
                   DO: 
                     ASSIGN aux_cdcritic = 25.
                     LEAVE valida.
                   END.
            END.

        IF par_tpseguro = 3 THEN /* vida */
            DO:
                IF par_txpartic1 > 100 OR
                   par_txpartic2 > 100 OR
                   par_txpartic3 > 100 OR
                   par_txpartic4 > 100 OR
                   par_txpartic5 > 100 THEN
                    DO:
                        ASSIGN aux_cdcritic = 180
                               par_nmdcampo = "tel_txpartic".
                        LEAVE valida.
                    END.

                IF par_txpartic1 +
                   par_txpartic2 +
                   par_txpartic3 +
                   par_txpartic4 +
                   par_txpartic5 <> 100 AND
                   par_txpartic1 +
                   par_txpartic2 +
                   par_txpartic3 +
                   par_txpartic4 +
                   par_txpartic5 <> 0 THEN
                    DO:
                        ASSIGN aux_cdcritic = 180
                               par_nmdcampo = "tel_txpartic".
                        LEAVE valida.
                    END.
                
                IF (par_txpartic1 <> 0 AND
                    par_nmbenvid1  = "") OR
                   (par_txpartic2 <> 0 AND
                    par_nmbenvid2  = "") OR
                   (par_txpartic3 <> 0 AND
                    par_nmbenvid3  = "") OR
                   (par_txpartic4 <> 0 AND
                    par_nmbenvid4  = "") OR
                   (par_txpartic5 <> 0 AND
                    par_nmbenvid5  = "") THEN
                    DO:
                        ASSIGN aux_cdcritic = 301
                               par_nmdcampo = "tel_nmbenefi".
                        LEAVE valida.
                    END.

                IF (par_txpartic1  = 0 AND
                    par_nmbenvid1 <> "") OR
                   (par_txpartic2  = 0 AND
                    par_nmbenvid2 <> "") OR
                   (par_txpartic3 = 0 AND
                    par_nmbenvid3 <> "") OR
                   (par_txpartic4 = 0 AND
                    par_nmbenvid4 <> "") OR
                   (par_txpartic5 = 0 AND
                    par_nmbenvid5 <> "") THEN
                    DO:
                        ASSIGN aux_cdcritic = 301
                               par_nmdcampo = "tel_nmbenefi".
                        LEAVE valida.
                    END.
                
                IF par_vlpreseg = 0 THEN
                    DO:
                        ASSIGN aux_cdcritic = 375
                               par_nmdcampo = "seg_vlpreseg".
                        LEAVE valida.
                    END.
            END.

        IF aux_cdcritic <> 0 THEN LEAVE valida.
    END. /* valida: */

    EMPTY TEMP-TABLE tt-erro.
    
    IF   aux_cdcritic <> 0    OR
         aux_dscritic <> ""   THEN 
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1, /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             
             IF   par_flgerlog  THEN
                  RUN proc_gerar_log (INPUT  par_cdcooper,
                                      INPUT  par_cdoperad,
                                      INPUT  aux_dscritic,
                                      INPUT  aux_dsorigem,
                                      INPUT  aux_dstransa,
                                      INPUT  FALSE, 
                                      INPUT  par_idseqttl,
                                      INPUT  par_nmdatela,
                                      INPUT  par_nrdconta,
                                      OUTPUT aux_nrdrowid).   

             RETURN "NOK".

         END.
    
    IF   par_flgerlog  THEN
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
    RETURN "OK".
END PROCEDURE.

PROCEDURE atualizar_seguro:
    DEF INPUT PARAM par_cdcooper    AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci    AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa    AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad    AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt    AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta    AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idseqttl    AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem    AS INTE                    NO-UNDO. 
    DEF INPUT PARAM par_nmdatela    AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_flgerlog    AS LOGI                    NO-UNDO.
    DEF INPUT PARAM par_tpseguro    LIKE crapseg.tpseguro      NO-UNDO.
    DEF INPUT PARAM par_nrctrseg    LIKE crapseg.nrctrseg      NO-UNDO.
    DEF INPUT PARAM par_cdsegura    LIKE crapgsg.cdsegura      NO-UNDO.
    DEF INPUT PARAM par_cdsitseg    LIKE crapseg.cdsitseg      NO-UNDO.
    DEF INPUT PARAM par_dsgraupr1   AS CHAR FORMAT "x(20)"     NO-UNDO.
    DEF INPUT PARAM par_dsgraupr2   AS CHAR FORMAT "x(20)"     NO-UNDO.
    DEF INPUT PARAM par_dsgraupr3   AS CHAR FORMAT "x(20)"     NO-UNDO.
    DEF INPUT PARAM par_dsgraupr4   AS CHAR FORMAT "x(20)"     NO-UNDO.
    DEF INPUT PARAM par_dsgraupr5   AS CHAR FORMAT "x(20)"     NO-UNDO.
    DEF INPUT PARAM par_nmbenvid1   AS CHAR FORMAT "x(40)"     NO-UNDO.
    DEF INPUT PARAM par_nmbenvid2   AS CHAR FORMAT "x(40)"     NO-UNDO.
    DEF INPUT PARAM par_nmbenvid3   AS CHAR FORMAT "x(40)"     NO-UNDO.
    DEF INPUT PARAM par_nmbenvid4   AS CHAR FORMAT "x(40)"     NO-UNDO.
    DEF INPUT PARAM par_nmbenvid5   AS CHAR FORMAT "x(40)"     NO-UNDO.
    DEF INPUT PARAM par_txpartic1   AS DECIMAL FORMAT ">>9.99" NO-UNDO.
    DEF INPUT PARAM par_txpartic2   AS DECIMAL FORMAT ">>9.99" NO-UNDO.
    DEF INPUT PARAM par_txpartic3   AS DECIMAL FORMAT ">>9.99" NO-UNDO.
    DEF INPUT PARAM par_txpartic4   AS DECIMAL FORMAT ">>9.99" NO-UNDO.
    DEF INPUT PARAM par_txpartic5   AS DECIMAL FORMAT ">>9.99" NO-UNDO.
                                                      
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEFINE VARIABLE aux_contador AS INTEGER     NO-UNDO.

    valida:
    DO:

        FIND FIRST crapass NO-LOCK WHERE
                   crapass.cdcooper = par_cdcooper AND
                   crapass.nrdconta = par_nrdconta NO-ERROR.
        IF  NOT AVAILABLE crapass THEN
            DO:
                ASSIGN aux_cdcritic = 9.
                LEAVE valida.
            END.

        IF  par_cdsitseg <> 1 THEN
            DO:
                ASSIGN aux_cdcritic = 525.
                LEAVE valida.
            END.

        IF par_tpseguro = 3 THEN
            DO:
                IF par_txpartic1 > 100 OR
                   par_txpartic2 > 100 OR
                   par_txpartic3 > 100 OR
                   par_txpartic4 > 100 OR
                   par_txpartic5 > 100 THEN
                    DO:
                        ASSIGN aux_cdcritic = 180.
                        LEAVE valida.
                    END.

                IF par_txpartic1 +
                   par_txpartic2 +
                   par_txpartic3 +
                   par_txpartic4 +
                   par_txpartic5 <> 100 AND
                   par_txpartic1 +
                   par_txpartic2 +
                   par_txpartic3 +
                   par_txpartic4 +
                   par_txpartic5 <> 0 THEN
                    DO:
                        ASSIGN aux_cdcritic = 180.
                        LEAVE valida.
                    END.
                
                IF (par_txpartic1 <> 0 AND
                    par_nmbenvid1  = "") OR
                   (par_txpartic2 <> 0 AND
                    par_nmbenvid2  = "") OR
                   (par_txpartic3 <> 0 AND
                    par_nmbenvid3  = "") OR
                   (par_txpartic4 <> 0 AND
                    par_nmbenvid4  = "") OR
                   (par_txpartic5 <> 0 AND
                    par_nmbenvid5  = "") THEN
                    DO:
                        ASSIGN aux_cdcritic = 301.
                        LEAVE valida.
                    END.

                IF (par_txpartic1  = 0 AND
                    par_nmbenvid1 <> "") OR
                   (par_txpartic2  = 0 AND
                    par_nmbenvid2 <> "") OR
                   (par_txpartic3 = 0 AND
                    par_nmbenvid3 <> "") OR
                   (par_txpartic4 = 0 AND
                    par_nmbenvid4 <> "") OR
                   (par_txpartic5 = 0 AND
                    par_nmbenvid5 <> "") THEN
                    DO:
                        ASSIGN aux_cdcritic = 301.
                        LEAVE valida.
                    END.
            END.

        DO aux_contador = 1 TO 10:
        
            FIND FIRST crapseg WHERE
                       crapseg.cdcooper = par_cdcooper  AND
                       crapseg.nrdconta = par_nrdconta  AND
                       crapseg.tpseguro = par_tpseguro  AND
                       crapseg.nrctrseg = par_nrctrseg  
                 EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
            
            IF AVAIL crapseg THEN
                DO:
                    ASSIGN crapseg.txpartic[1] = par_txpartic1
                           crapseg.nmbenvid[1] = par_nmbenvid1
                           crapseg.dsgraupr[1] = par_dsgraupr1
                           crapseg.txpartic[2] = par_txpartic2
                           crapseg.nmbenvid[2] = par_nmbenvid2
                           crapseg.dsgraupr[2] = par_dsgraupr2
                           crapseg.txpartic[3] = par_txpartic3
                           crapseg.nmbenvid[3] = par_nmbenvid3
                           crapseg.dsgraupr[3] = par_dsgraupr3
                           crapseg.txpartic[4] = par_txpartic4
                           crapseg.nmbenvid[4] = par_nmbenvid4
                           crapseg.dsgraupr[4] = par_dsgraupr4
                           crapseg.txpartic[5] = par_txpartic5
                           crapseg.nmbenvid[5] = par_nmbenvid5
                           crapseg.dsgraupr[5] = par_dsgraupr5
                           crapseg.dtultalt    = par_dtmvtolt
                           aux_cdcritic        = 0.
                    LEAVE.
                END.
            ELSE
                DO: 
                    IF LOCKED(crapseg) THEN
                       DO:
                          ASSIGN aux_cdcritic = 84.
                          PAUSE 1 NO-MESSAGE.
                          NEXT.
                       END.
                    ELSE 
                       DO:
                          ASSIGN aux_cdcritic = 535.
                          LEAVE valida.
                       END.
                END.
        END.
    END.

    EMPTY TEMP-TABLE tt-erro.

    IF   aux_cdcritic <> 0    OR
         aux_dscritic <> ""   THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1, /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

             IF   par_flgerlog  THEN
                  RUN proc_gerar_log (INPUT  par_cdcooper,
                                      INPUT  par_cdoperad,
                                      INPUT  aux_dscritic,
                                      INPUT  aux_dsorigem,
                                      INPUT  aux_dstransa,
                                      INPUT  FALSE,
                                      INPUT  par_idseqttl,
                                      INPUT  par_nmdatela,
                                      INPUT  par_nrdconta,
                                      OUTPUT aux_nrdrowid).   

             RETURN "NOK".
         END.

    IF   par_flgerlog  THEN
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

    RETURN "OK".
END PROCEDURE.

PROCEDURE cancelar_seguro:
    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO. 
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                    NO-UNDO.
    DEF INPUT PARAM par_tpseguro LIKE crapseg.tpseguro      NO-UNDO.
    DEF INPUT PARAM par_nrctrseg LIKE crapseg.nrctrseg      NO-UNDO.
    DEF INPUT PARAM par_cdmotcan LIKE crapseg.cdmotcan      NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEFINE VARIABLE aux_contador  AS INTEGER     NO-UNDO.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0.
             
    IF  par_flgerlog  THEN
        ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
               aux_dstransa = "Cancelado o seguro do tipo: " +
                               IF (par_tpseguro = 1   OR
                                   par_tpseguro = 11) THEN 
                                   "SEGURO RESIDENCIAL."
                               ELSE
                               IF par_tpseguro = 2 THEN
                                  "SEGURO AUTOMOVEL"
                               ELSE
                               IF par_tpseguro = 3 THEN
                                  "SEGURO DE VIDA."
                               ELSE 
                                  "SEGURO PRESTAMISTA.".


    EMPTY TEMP-TABLE tt-erro.

    valida:
    DO:
        IF par_tpseguro  = 11 AND
            (par_cdmotcan = 0 OR
             par_cdmotcan > 9) THEN
            DO:
                ASSIGN aux_dscritic = "Motivo nao cadastrado.".
                LEAVE valida.
            END.
        
        DO aux_contador = 1 TO 10:
        
            FIND FIRST crapseg WHERE
                       crapseg.cdcooper = par_cdcooper AND
                       crapseg.nrdconta = par_nrdconta AND
                       crapseg.tpseguro = par_tpseguro AND
                       crapseg.nrctrseg = par_nrctrseg 
                  EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
            IF AVAIL crapseg THEN
                DO:
                    IF  crapseg.tpseguro = 3 AND
                        MONTH(crapseg.dtdebito) < MONTH(par_dtmvtolt) AND
                        YEAR(crapseg.dtdebito)  < YEAR(par_dtmvtolt)  THEN
                        ASSIGN aux_dscritic = "ATENCAO! Cancelamento nao" +
                                              " permitido nessa data.".
                    ELSE
                        DO:

                            /* Inicio - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
                            IF par_cdagenci = 0 THEN
                              ASSIGN par_cdagenci = glb_cdagenci.
                            /* Fim - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */


                        
                             ASSIGN crapseg.cdsitseg = 2
                                   crapseg.dtcancel = par_dtmvtolt
                                   crapseg.dtfimvig = IF crapseg.tpseguro = 3
                                                      THEN par_dtmvtolt
                                                      ELSE crapseg.dtfimvig
                                   crapseg.cdmotcan = par_cdmotcan
               					   /* Inicio - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
                                   crapseg.cdopeexc = par_cdoperad
                                   crapseg.cdageexc = par_cdagenci
                                   crapseg.dtinsexc = TODAY
               					   /* Fim - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
                                   crapseg.cdopecnl = par_cdoperad.
                        END.
                    ASSIGN aux_cdcritic = 0.
                END.
            ELSE 
               DO:
                  IF LOCKED(crapseg) THEN
                     DO:
                        ASSIGN aux_cdcritic = 84.
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                     END.
                  ELSE
                     DO:
                        ASSIGN aux_dscritic = "Nao encontrado contrato" +
                                              " de seguro.".
                        LEAVE.
                     END.
                
               END.
        END.
    END.

    EMPTY TEMP-TABLE tt-erro.
    
    IF  aux_cdcritic <> 0    OR
        aux_dscritic <> ""   THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            
            IF   par_flgerlog  THEN
                RUN proc_gerar_log (INPUT  par_cdcooper,
                                    INPUT  par_cdoperad,
                                    INPUT  aux_dscritic,
                                    INPUT  aux_dsorigem,
                                    INPUT  aux_dstransa,
                                    INPUT  FALSE,
                                    INPUT  par_idseqttl,
                                    INPUT  par_nmdatela,
                                    INPUT  par_nrdconta,
                                    OUTPUT aux_nrdrowid).   
            
            RETURN "NOK".
            
        END.
    
    IF  par_flgerlog  THEN
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
   
    RETURN "OK".
    
END PROCEDURE.

PROCEDURE desfaz_canc_seguro:
    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO. 
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                    NO-UNDO.
    DEF INPUT PARAM par_tpseguro LIKE crapseg.tpseguro      NO-UNDO.
    DEF INPUT PARAM par_nrctrseg LIKE crapseg.nrctrseg      NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEFINE VARIABLE aux_contador AS INTEGER     NO-UNDO.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0.

    EMPTY TEMP-TABLE tt-erro.

    valida:
    DO aux_contador = 1 TO 10:

        FIND FIRST crapseg  WHERE
                   crapseg.cdcooper = par_cdcooper AND
                   crapseg.nrdconta = par_nrdconta AND
                   crapseg.tpseguro = par_tpseguro AND
                   crapseg.nrctrseg = par_nrctrseg 
             EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
        IF AVAIL crapseg THEN
            DO:
                /* So pode desfazer no mesmo dia do cancelamento */
                IF   crapseg.dtcancel <> par_dtmvtolt   THEN
                    ASSIGN aux_cdcritic = 13.
                ELSE
                    DO:
                        ASSIGN crapseg.cdsitseg = 1 /* Ativo */
                               crapseg.dtcancel = ?
                               crapseg.cdopecnl = ""
                               crapseg.cdmotcan = 0.
                               /* Seguro VIDA */
                               IF crapseg.tpseguro = 3 THEN
                                  crapseg.dtfimvig = ?.
                    END.
                ASSIGN aux_cdcritic = 0.
            END.
        ELSE 
               DO:
                  IF LOCKED(crapseg) THEN
                     DO:
                        ASSIGN aux_cdcritic = 84.
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                     END.
                  ELSE
                     DO:
                        ASSIGN aux_dscritic = "Nao encontrado contrato" +
                                              " de seguro.".
                        LEAVE.
                     END.
                
               END.

    END.

    EMPTY TEMP-TABLE tt-erro.
    
    IF  aux_cdcritic <> 0    OR
        aux_dscritic <> ""   THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF   par_flgerlog  THEN
                RUN proc_gerar_log (INPUT  par_cdcooper,
                                    INPUT  par_cdoperad,
                                    INPUT  aux_dscritic,
                                    INPUT  aux_dsorigem,
                                    INPUT  aux_dstransa,
                                    INPUT  FALSE,
                                    INPUT  par_idseqttl,
                                    INPUT  par_nmdatela,
                                    INPUT  par_nrdconta,
                                    OUTPUT aux_nrdrowid).   
            
            RETURN "NOK".
        END.

            
    IF  par_flgerlog  THEN
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

    RETURN "OK".
END PROCEDURE.

PROCEDURE buscar_motivo_can:
    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO. 
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                    NO-UNDO.
    DEF INPUT PARAM par_cdmotcan AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_dsmotcan AS CHAR                    NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                   NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-mot-can.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    valida:
    DO:
        IF par_cdmotcan > 11 THEN
            DO:
                ASSIGN aux_dscritic = "Motivo nao cadastrado".
                LEAVE valida.
            END.

        ASSIGN par_qtregist = 9.

        CREATE tt-mot-can.
        ASSIGN tt-mot-can.cdmotcan = 1
               tt-mot-can.dsmotcan = "Nao Interesse pelo Seguro".
               
        CREATE tt-mot-can.
        ASSIGN tt-mot-can.cdmotcan = 2
               tt-mot-can.dsmotcan = "Desligamento da Empresa (Estipulante)".
               
        CREATE tt-mot-can.
        ASSIGN tt-mot-can.cdmotcan = 3
               tt-mot-can.dsmotcan = "Falecimento".
               
        CREATE tt-mot-can.
        ASSIGN tt-mot-can.cdmotcan = 4
               tt-mot-can.dsmotcan = "Outros".
               
        CREATE tt-mot-can.
        ASSIGN tt-mot-can.cdmotcan = 5
               tt-mot-can.dsmotcan = "Alteracao de endereco".
               
        CREATE tt-mot-can.
        ASSIGN tt-mot-can.cdmotcan = 6
               tt-mot-can.dsmotcan = "Alteracao de plano".
               
        CREATE tt-mot-can.
        ASSIGN tt-mot-can.cdmotcan = 7
               tt-mot-can.dsmotcan = "Venda do imovel".
               
        CREATE tt-mot-can.
        ASSIGN tt-mot-can.cdmotcan = 8
               tt-mot-can.dsmotcan = "Insuficiencia de saldo".
               
        CREATE tt-mot-can.
        ASSIGN tt-mot-can.cdmotcan = 9
               tt-mot-can.dsmotcan = "Encerramento de conta".

        CREATE tt-mot-can.
        ASSIGN tt-mot-can.cdmotcan = 10
               tt-mot-can.dsmotcan = "Insatisfacao".

        CREATE tt-mot-can.
        ASSIGN tt-mot-can.cdmotcan = 11
               tt-mot-can.dsmotcan = "Perdido para a concorrencia".

        IF par_cdmotcan <> 0 THEN DO:
            FOR EACH tt-mot-can WHERE
                     tt-mot-can.cdmotcan <> par_cdmotcan:
                DELETE tt-mot-can.
                ASSIGN par_qtregist = par_qtregist - 1.
            END.
        END.
    END.

    IF par_dsmotcan <> "" AND par_cdmotcan = 0 THEN
        FOR EACH tt-mot-can:
            IF NOT tt-mot-can.dsmotcan MATCHES "*" + par_dsmotcan + "*" THEN DO:
                DELETE tt-mot-can.
                ASSIGN par_qtregist = par_qtregist - 1.
            END.
        END.

    

    EMPTY TEMP-TABLE tt-erro.

    IF  aux_cdcritic <> 0    OR
        aux_dscritic <> ""   THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF   par_flgerlog  THEN
                RUN proc_gerar_log (INPUT  par_cdcooper,
                                    INPUT  par_cdoperad,
                                    INPUT  aux_dscritic,
                                    INPUT  aux_dsorigem,
                                    INPUT  aux_dstransa,
                                    INPUT  FALSE,
                                    INPUT  par_idseqttl,
                                    INPUT  par_nmdatela,
                                    INPUT  par_nrdconta,
                                    OUTPUT aux_nrdrowid).   
            
            RETURN "NOK".
        END.

            
    IF  par_flgerlog  THEN 
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

    RETURN "OK".

END PROCEDURE.

PROCEDURE incluir_garantias:
    DEF INPUT PARAM par_cdsegura LIKE crapgsg.cdsegura      NO-UNDO.
    DEF INPUT PARAM par_tpseguro LIKE crapgsg.tpseguro      NO-UNDO.
    DEF INPUT PARAM par_tpplaseg LIKE crapgsg.tpplaseg      NO-UNDO.
    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO. 
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                    NO-UNDO.
    DEF INPUT PARAM par_dsgarant LIKE crapgsg.dsgarant      NO-UNDO.
    DEF INPUT PARAM par_vlgarant LIKE crapgsg.vlgarant      NO-UNDO.
    DEF INPUT PARAM par_dsfranqu LIKE crapgsg.dsfranqu      NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nrseqinc LIKE crapgsg.nrseqinc NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    IF par_dsgarant = "" THEN
        ASSIGN aux_dscritic = "Descricao da garantia deve ser informada.".
    ELSE
    IF par_vlgarant = 0 THEN
        ASSIGN aux_dscritic = "Valor da garantia deve ser informado.".

    IF  aux_dscritic = "" THEN
        DO:
            FOR LAST crapgsg NO-LOCK WHERE
                     crapgsg.cdcooper = par_cdcooper  AND
                     crapgsg.cdsegura = par_cdsegura  AND
                     crapgsg.tpseguro = par_tpseguro  AND
                     crapgsg.tpplaseg = par_tpplaseg  
                     BY crapgsg.nrseqinc:
            END.
        
            ASSIGN aux_nrseqinc = IF AVAIL crapgsg THEN crapgsg.nrseqinc + 1 ELSE 1.
        
            CREATE crapgsg.
            ASSIGN crapgsg.nrseqinc = aux_nrseqinc
                   crapgsg.cdsegura = par_cdsegura
                   crapgsg.tpseguro = par_tpseguro
                   crapgsg.tpplaseg = par_tpplaseg
                   crapgsg.cdcooper = par_cdcooper
                   crapgsg.dsgarant = par_dsgarant
                   crapgsg.vlgarant = par_vlgarant
                   crapgsg.dsfranqu = par_dsfranqu.
            VALIDATE crapgsg.
        END.

    EMPTY TEMP-TABLE tt-erro.

    IF  aux_cdcritic <> 0    OR
        aux_dscritic <> ""   THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF   par_flgerlog  THEN
                RUN proc_gerar_log (INPUT  par_cdcooper,
                                    INPUT  par_cdoperad,
                                    INPUT  aux_dscritic,
                                    INPUT  aux_dsorigem,
                                    INPUT  aux_dstransa,
                                    INPUT  FALSE,
                                    INPUT  par_idseqttl,
                                    INPUT  par_nmdatela,
                                    INPUT  par_nrdconta,
                                    OUTPUT aux_nrdrowid).   
            
            RETURN "NOK".
        END.

            
    IF  par_flgerlog  THEN
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

    RETURN "OK".
    
END PROCEDURE.

PROCEDURE alterar_garantias:
    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO. 
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                    NO-UNDO.
    DEF INPUT PARAM par_dsgarant LIKE crapgsg.dsgarant      NO-UNDO.
    DEF INPUT PARAM par_vlgarant LIKE crapgsg.vlgarant      NO-UNDO.
    DEF INPUT PARAM par_dsfranqu LIKE crapgsg.dsfranqu      NO-UNDO.
    DEF INPUT PARAM par_cdsegura LIKE crapgsg.cdsegura      NO-UNDO.
    DEF INPUT PARAM par_tpseguro LIKE crapgsg.tpseguro      NO-UNDO.
    DEF INPUT PARAM par_tpplaseg LIKE crapgsg.tpplaseg      NO-UNDO.
    DEF INPUT PARAM par_nrseqinc LIKE crapgsg.nrseqinc      NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEFINE VARIABLE aux_contador  AS INTEGER     NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    valida:
    DO:

        IF par_dsgarant = "" THEN
        ASSIGN aux_dscritic = "Descricao da garantia deve ser informada.".
        ELSE
        IF par_vlgarant = 0 THEN
            ASSIGN aux_dscritic = "Valor da garantia deve ser informado.".
        ELSE
        IF aux_dscritic <> "" OR 
           aux_cdcritic <> 0  THEN
            LEAVE valida.
        
        DO aux_contador = 1 TO 10:
        
            FIND FIRST crapgsg  WHERE
                       crapgsg.cdcooper = par_cdcooper  AND
                       crapgsg.cdsegura = par_cdsegura  AND
                       crapgsg.tpseguro = par_tpseguro  AND
                       crapgsg.tpplaseg = par_tpplaseg  AND
                       crapgsg.nrseqinc = par_nrseqinc 
                 EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
    
            IF NOT AVAIL crapgsg THEN
                DO:
                   IF LOCKED(crapseg) THEN
                       DO:
                          ASSIGN aux_cdcritic = 84.
                          PAUSE 1 NO-MESSAGE.
                          NEXT.
                       END.
                    ELSE
                       DO:
                          ASSIGN aux_dscritic = "Nao encontrada garantia de seguro".
                          LEAVE valida.
                       END.
                END.
             ELSE 
                DO:
                   ASSIGN crapgsg.dsgarant = par_dsgarant
                          crapgsg.vlgarant = par_vlgarant
                          crapgsg.dsfranqu = par_dsfranqu
                          aux_cdcritic     = 0.

                END.

        END.

        
    END.

    EMPTY TEMP-TABLE tt-erro.

    IF  aux_cdcritic <> 0    OR
        aux_dscritic <> ""   THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF   par_flgerlog  THEN
                RUN proc_gerar_log (INPUT  par_cdcooper,
                                    INPUT  par_cdoperad,
                                    INPUT  aux_dscritic,
                                    INPUT  aux_dsorigem,
                                    INPUT  aux_dstransa,
                                    INPUT  FALSE,
                                    INPUT  par_idseqttl,
                                    INPUT  par_nmdatela,
                                    INPUT  par_nrdconta,
                                    OUTPUT aux_nrdrowid).   
            
            RETURN "NOK".
        END.
            
    IF  par_flgerlog  THEN
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

    RETURN "OK".
END PROCEDURE.

PROCEDURE excluir_garantias:
    DEF INPUT PARAM par_nrseqinc LIKE crapgsg.nrseqinc      NO-UNDO.
    DEF INPUT PARAM par_cdsegura LIKE crapgsg.cdsegura      NO-UNDO.
    DEF INPUT PARAM par_tpseguro LIKE crapgsg.tpseguro      NO-UNDO.
    DEF INPUT PARAM par_tpplaseg LIKE crapgsg.tpplaseg      NO-UNDO.
    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO. 
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                    NO-UNDO.
    DEF INPUT PARAM par_dsgarant LIKE crapgsg.dsgarant      NO-UNDO.
    DEF INPUT PARAM par_vlcobert LIKE crapgsg.vlgarant      NO-UNDO.
    DEF INPUT PARAM par_dsfranqu LIKE crapgsg.dsfranqu      NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEFINE VARIABLE aux_contador  AS INTEGER     NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    DO aux_contador = 1 TO 10.
        
        FIND FIRST crapgsg  WHERE
                   crapgsg.nrseqinc = par_nrseqinc  AND
                   crapgsg.cdcooper = par_cdcooper  AND
                   crapgsg.cdsegura = par_cdsegura  AND
                   crapgsg.tpplaseg = par_tpplaseg  AND
                   crapgsg.tpseguro = par_tpseguro 
             EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
        IF AVAIL crapgsg THEN
            DO:
                DELETE crapgsg.
                ASSIGN aux_cdcritic = 0.
                LEAVE.
            END.
        ELSE
            DO:
                IF LOCKED (crapseg) THEN
                    DO:
                        ASSIGN aux_cdcritic = 84.
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
                ELSE
                    DO:
                        ASSIGN aux_dscritic = "Nao encontrada garantia de seguro.".
                        LEAVE.
                    END.
            END.
    END.

    EMPTY TEMP-TABLE tt-erro.

    IF  aux_cdcritic <> 0    OR
        aux_dscritic <> ""   THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF   par_flgerlog  THEN
                RUN proc_gerar_log (INPUT  par_cdcooper,
                                    INPUT  par_cdoperad,
                                    INPUT  aux_dscritic,
                                    INPUT  aux_dsorigem,
                                    INPUT  aux_dstransa,
                                    INPUT  FALSE,
                                    INPUT  par_idseqttl,
                                    INPUT  par_nmdatela,
                                    INPUT  par_nrdconta,
                                    OUTPUT aux_nrdrowid).   
            
            RETURN "NOK".
        END.
            
    IF  par_flgerlog  THEN
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

    RETURN "OK".
END PROCEDURE.

PROCEDURE buscar_garantias:
    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO. 
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                    NO-UNDO.
    DEF INPUT PARAM par_cdsegura LIKE crapgsg.cdsegura      NO-UNDO.
    DEF INPUT PARAM par_tpseguro LIKE crapgsg.tpseguro      NO-UNDO.
    DEF INPUT PARAM par_tpplaseg LIKE crapgsg.tpplaseg      NO-UNDO.
    DEF INPUT PARAM par_nrseqinc LIKE crapgsg.nrseqinc      NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-gar-seg.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-gar-seg.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    IF par_tpseguro = 0 THEN
        ASSIGN aux_dscritic = "Tipo seguro deve ser informado.".
    ELSE
    IF par_tpplaseg = 0 THEN
        ASSIGN aux_dscritic = "Tipo do plano deve ser informado.".
    ELSE
    IF par_cdsegura = 0 THEN
        ASSIGN aux_dscritic = "Codigo da seguradora deve ser informado.".
    ELSE
    IF par_tpseguro <> 3 AND par_tpseguro <> 4 AND par_tpseguro <> 11  THEN
        ASSIGN aux_dscritic = "Tipo seguro invalido.".
    ELSE 
        DO:
    
            RUN buscar_plano_seguro(INPUT par_cdcooper,
                                    INPUT par_cdagenci,
                                    INPUT par_nrdcaixa,
                                    INPUT par_cdoperad,
                                    INPUT par_dtmvtolt,
                                    INPUT par_nrdconta,
                                    INPUT par_idseqttl,
                                    INPUT par_idorigem,
                                    INPUT par_nmdatela,
                                    INPUT par_flgerlog,
                                    INPUT par_cdsegura,
                                    INPUT par_tpseguro,
                                    INPUT par_tpplaseg,
                                    OUTPUT TABLE tt-plano-seg,
                                    OUTPUT TABLE tt-erro).
        
            IF   RETURN-VALUE <> "OK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                    IF   AVAIL tt-erro   THEN
                        DO:
                            ASSIGN aux_cdcritic = tt-erro.cdcritic
                                   aux_dscritic = tt-erro.dscritic.
                            EMPTY TEMP-TABLE tt-erro.
                        END.
                END.
        END.

    IF aux_dscritic = "" THEN 
        DO:
            FOR EACH crapgsg NO-LOCK WHERE
                (IF par_cdcooper <> 0 THEN
                     crapgsg.cdcooper = par_cdcooper
                 ELSE TRUE) AND
                     crapgsg.cdsegura = par_cdsegura AND
                     crapgsg.tpplaseg = par_tpplaseg AND
                     crapgsg.tpseguro = par_tpseguro AND
                (IF par_nrseqinc <> 0 THEN
                     crapgsg.nrseqinc = par_nrseqinc
                 ELSE TRUE):
                CREATE tt-gar-seg.
                BUFFER-COPY crapgsg TO tt-gar-seg.
            END.
        END.
    
    EMPTY TEMP-TABLE tt-erro.

    IF  aux_cdcritic <> 0    OR
        aux_dscritic <> ""   THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF   par_flgerlog  THEN
                RUN proc_gerar_log (INPUT  par_cdcooper,
                                    INPUT  par_cdoperad,
                                    INPUT  aux_dscritic,
                                    INPUT  aux_dsorigem,
                                    INPUT  aux_dstransa,
                                    INPUT  FALSE,
                                    INPUT  par_idseqttl,
                                    INPUT  par_nmdatela,
                                    INPUT  par_nrdconta,
                                    OUTPUT aux_nrdrowid).   
            
            RETURN "NOK".
        END.
            
    IF  par_flgerlog  THEN
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

    RETURN "OK".
END PROCEDURE.

PROCEDURE atualizar_plano_seguro:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO. 
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                    NO-UNDO.
    DEF INPUT PARAM par_cdsegura LIKE craptsg.cdsegura      NO-UNDO.
    DEF INPUT PARAM par_cdsitpsg LIKE craptsg.cdsitpsg      NO-UNDO.
    DEF INPUT PARAM par_dsmorada LIKE craptsg.dsmorada      NO-UNDO.
    DEF INPUT PARAM par_ddcancel LIKE craptsg.ddcancel      NO-UNDO.
    DEF INPUT PARAM par_dddcorte LIKE craptsg.dddcorte      NO-UNDO.
    DEF INPUT PARAM par_ddmaxpag LIKE craptsg.ddmaxpag      NO-UNDO.
    DEF INPUT PARAM par_dsocupac LIKE craptsg.dsocupac      NO-UNDO.
    DEF INPUT PARAM par_flgunica LIKE craptsg.flgunica      NO-UNDO.
    DEF INPUT PARAM par_inplaseg LIKE craptsg.inplaseg      NO-UNDO.
    DEF INPUT PARAM par_mmpripag LIKE craptsg.mmpripag      NO-UNDO.
    DEF INPUT PARAM par_nrtabela LIKE craptsg.nrtabela      NO-UNDO.
    DEF INPUT PARAM par_qtdiacar LIKE craptsg.qtdiacar      NO-UNDO.
    DEF INPUT PARAM par_qtmaxpar LIKE craptsg.qtmaxpar      NO-UNDO.
    DEF INPUT PARAM par_tpplaseg LIKE craptsg.tpplaseg      NO-UNDO.
    DEF INPUT PARAM par_tpseguro LIKE craptsg.tpseguro      NO-UNDO.
    DEF INPUT PARAM par_vlmorada LIKE craptsg.vlmorada      NO-UNDO.
    DEF INPUT PARAM par_vlplaseg LIKE craptsg.vlplaseg      NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEFINE VARIABLE aux_contador AS INTEGER     NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    
    Contador:
    DO aux_contador = 1 TO 10:

       FIND FIRST craptsg WHERE craptsg.cdcooper = par_cdcooper AND   
                                craptsg.cdsegura = par_cdsegura AND   
                                craptsg.tpseguro = par_tpseguro AND   
                                craptsg.tpplaseg = par_tpplaseg
                                EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
       
       IF NOT AVAIL craptsg THEN
          IF LOCKED(craptsg) THEN
             DO: 
                IF aux_contador = 10 THEN
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
              DO:
                  CREATE craptsg.

                  ASSIGN craptsg.cdcooper = par_cdcooper
                         craptsg.cdsegura = par_cdsegura
                         craptsg.tpseguro = par_tpseguro
                         craptsg.tpplaseg = par_tpplaseg.

                  VALIDATE craptsg.
                  
              END.

       ASSIGN craptsg.cdsitpsg = par_cdsitpsg
              craptsg.ddcancel = par_ddcancel
              craptsg.dddcorte = par_dddcorte
              craptsg.ddmaxpag = par_ddmaxpag
              craptsg.dsocupac = par_dsocupac
              craptsg.flgunica = par_flgunica
              craptsg.inplaseg = par_inplaseg
              craptsg.mmpripag = par_mmpripag
              craptsg.nrtabela = par_nrtabela
              craptsg.qtdiacar = par_qtdiacar
              craptsg.qtmaxpar = par_qtmaxpar
              craptsg.vlmorada = par_vlmorada
              craptsg.vlplaseg = par_vlplaseg
              craptsg.dsmorada = par_dsmorada
              aux_cdcritic     = 0.

        LEAVE.
       
    END.

    IF aux_cdcritic <> 0  OR
       aux_dscritic <> "" THEN
       DO:
           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1, /** Sequencia **/
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).

           IF par_flgerlog  THEN
              RUN proc_gerar_log (INPUT  par_cdcooper,
                                  INPUT  par_cdoperad,
                                  INPUT  aux_dscritic,
                                  INPUT  aux_dsorigem,
                                  INPUT  aux_dstransa,
                                  INPUT  FALSE,
                                  INPUT  par_idseqttl,
                                  INPUT  par_nmdatela,
                                  INPUT  par_nrdconta,
                                  OUTPUT aux_nrdrowid).   
           
           RETURN "NOK".

       END.

    IF par_flgerlog  THEN
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

    RETURN "OK".

END PROCEDURE.

PROCEDURE calcular_data_debito:
    DEF INPUT PARAM par_cdcooper    AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdagenci    AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa    AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdoperad    AS CHAR NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt    AS DATE NO-UNDO.
    DEF INPUT PARAM par_nrdconta    AS INTE NO-UNDO.
    DEF INPUT PARAM par_idseqttl    AS INTE NO-UNDO.
    DEF INPUT PARAM par_idorigem    AS INTE NO-UNDO. 
    DEF INPUT PARAM par_nmdatela    AS CHAR NO-UNDO.
    DEF INPUT PARAM par_flgerlog    AS LOGI NO-UNDO.
    DEF INPUT PARAM par_flgunica    AS LOGI NO-UNDO.
    DEF INPUT PARAM par_qtmaxpar    AS INT  NO-UNDO.
    DEF INPUT PARAM par_mmpripag    AS INTE NO-UNDO.
    DEF INPUT PARAM par_dtdebini    AS DATE NO-UNDO.
    DEF INPUT PARAM par_dtpriini    AS DATE NO-UNDO.
              
    DEF OUTPUT PARAM par_dtdebito   AS DATE NO-UNDO.
    DEF OUTPUT PARAM par_dtpripag   AS DATE NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_dtdebito            AS DATE NO-UNDO.
    DEF VAR aux_dtprideb            AS DATE NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    IF   NOT par_flgunica AND par_qtmaxpar <> 1   THEN
        DO: /* calcula a data para o proximo mes */

            RUN sistema/generico/procedures/b1wgen0008.p
                PERSISTENT SET h-b1wgen0008.
        
            RUN calcdata IN h-b1wgen0008 (INPUT par_cdcooper,
                                          INPUT par_cdagenci,
                                          INPUT par_nrdcaixa,
                                          INPUT "",
                                          INPUT DATE(MONTH(par_dtmvtolt),
                                                     DAY(par_dtdebini),
                                                     YEAR(par_dtmvtolt)),
                                          INPUT  1,
                                          INPUT  "M",
                                          INPUT  0,
                                          OUTPUT aux_dtdebito,
                                          OUTPUT TABLE tt-erro).

            DELETE PROCEDURE h-b1wgen0008.
        END.    
    ELSE
        ASSIGN aux_dtdebito = DATE(MONTH(par_dtmvtolt),
                                   DAY(par_dtpriini),
                                   YEAR(par_dtmvtolt)).
    
    ASSIGN aux_dtprideb = IF par_mmpripag > 0 THEN
                              aux_dtdebito
                          ELSE
                              DATE(MONTH(par_dtmvtolt),
                                   DAY(par_dtpriini),
                                   YEAR(par_dtmvtolt)).

    ASSIGN par_dtdebito = aux_dtdebito
           par_dtpripag = aux_dtprideb.

    EMPTY TEMP-TABLE tt-erro.

    IF   aux_cdcritic <> 0    OR
         aux_dscritic <> ""   THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1, /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

             IF   par_flgerlog  THEN
                  RUN proc_gerar_log (INPUT  par_cdcooper,
                                      INPUT  par_cdoperad,
                                      INPUT  aux_dscritic,
                                      INPUT  aux_dsorigem,
                                      INPUT  aux_dstransa,
                                      INPUT  FALSE,
                                      INPUT  par_idseqttl,
                                      INPUT  par_nmdatela,
                                      INPUT  par_nrdconta,
                                      OUTPUT aux_nrdrowid).   

             RETURN "NOK".

         END.

    IF   par_flgerlog  THEN
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
    RETURN "OK".
END PROCEDURE.


PROCEDURE pi_atualizar_perc_seg:

    DEF INPUT PARAM par_cdcooper    AS INTE                     NO-UNDO.
    DEF INPUT PARAM par_cdagenci    AS INTE                     NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa    AS INTE                     NO-UNDO.
    DEF INPUT PARAM par_cdoperad    AS CHAR                     NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt    AS DATE                     NO-UNDO.
    DEF INPUT PARAM par_nrdconta    AS INTE                     NO-UNDO.
    DEF INPUT PARAM par_idseqttl    AS INTE                     NO-UNDO.
    DEF INPUT PARAM par_idorigem    AS INTE                     NO-UNDO. 
    DEF INPUT PARAM par_nmdatela    AS CHAR                     NO-UNDO.
    DEF INPUT PARAM par_flgerlog    AS LOGI                     NO-UNDO.
    DEF INPUT PARAM par_nrtabela    LIKE craptsg.nrtabela       NO-UNDO.
    DEF INPUT PARAM par_tpseguro    LIKE crapseg.tpseguro       NO-UNDO.  
    DEF INPUT PARAM par_tpplaseg    LIKE craptsg.tpplaseg       NO-UNDO.
    DEF INPUT PARAM par_dtdespre    AS DATE                     NO-UNDO.
    DEF INPUT PARAM par_dtpagmto    AS DATE                     NO-UNDO.
    DEF INPUT PARAM par_vlpercen    AS DEC                      NO-UNDO.
    DEF INPUT PARAM par_nrregist    AS INT                      NO-UNDO.
    DEF INPUT PARAM par_nriniseq    AS INT                      NO-UNDO.

    DEF OUTPUT PARAM par_qtregist   AS INT                      NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR cratseg.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_qtsegass  AS INTE                               NO-UNDO.
    DEF VAR aux_vltotseg  AS DECI                               NO-UNDO.
    DEF VAR aux_acrescimo AS DECI                               NO-UNDO.
    DEF VAR aux_nrregist  AS INT                                NO-UNDO.

    EMPTY TEMP-TABLE cratseg. 

    ASSIGN aux_nrregist = par_nrregist.

    IF par_tpseguro <> 3 THEN
       DO:
          RUN gera_erro (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1, /** Sequencia **/
                         INPUT 513,
                         INPUT-OUTPUT aux_dscritic).
     
          IF   par_flgerlog  THEN
               RUN proc_gerar_log (INPUT  par_cdcooper,
                                   INPUT  par_cdoperad,
                                   INPUT  aux_dscritic,
                                   INPUT  aux_dsorigem,
                                   INPUT  aux_dstransa,
                                   INPUT  FALSE,
                                   INPUT  par_idseqttl,
                                   INPUT  par_nmdatela,
                                   INPUT  par_nrdconta,
                                   OUTPUT aux_nrdrowid).   
     
          RETURN "NOK".
     
       END.

    IF par_vlpercen = 0 THEN
       DO:
          ASSIGN aux_cdcritic = 0 
                 aux_dscritic = "Informe o valor do percentual.".
    
          RUN gera_erro (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1, /** Sequencia **/
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic).
    
          IF   par_flgerlog  THEN
               RUN proc_gerar_log (INPUT  par_cdcooper,
                                   INPUT  par_cdoperad,
                                   INPUT  aux_dscritic,
                                   INPUT  aux_dsorigem,
                                   INPUT  aux_dstransa,
                                   INPUT  FALSE,
                                   INPUT  par_idseqttl,
                                   INPUT  par_nmdatela,
                                   INPUT  par_nrdconta,
                                   OUTPUT aux_nrdrowid).   
    
          RETURN "NOK".
    
       END.
    
    RUN buscar_plano_seguro (INPUT par_cdcooper,
                             INPUT 0,
                             INPUT 0,
                             INPUT par_cdoperad,
                             INPUT par_dtmvtolt,
                             INPUT 0,
                             INPUT 1,
                             INPUT 1,
                             INPUT par_nmdatela,
                             INPUT FALSE,
                             INPUT 0,
                             INPUT par_tpseguro,
                             INPUT par_tpplaseg,
                             OUTPUT TABLE tt-plano-seg,
                             OUTPUT TABLE tt-erro).

    FOR EACH tt-plano-seg 
        WHERE tt-plano-seg.cdcooper = par_cdcooper  
          AND tt-plano-seg.tpseguro = par_tpseguro  
          AND (tt-plano-seg.tpplaseg = par_tpplaseg OR par_tpplaseg = 0)
          AND (tt-plano-seg.nrtabela = par_nrtabela OR par_nrtabela = 0) NO-LOCK
        BREAK BY tt-plano-seg.tpseguro
              BY tt-plano-seg.tpplaseg 
              BY tt-plano-seg.nrtabela: 

        IF FIRST-OF(tt-plano-seg.tpseguro) OR FIRST-OF(tt-plano-seg.tpplaseg) THEN DO: 
            
            FOR EACH crapseg FIELDS(nrdconta cdsitseg tpplaseg dtmvtolt
                                    dtdebito tpseguro nrctrseg vlpreseg) USE-INDEX crapseg4
                WHERE crapseg.cdcooper = par_cdcooper 
                  AND crapseg.tpseguro  = tt-plano-seg.tpseguro:

                IF  crapseg.nrdconta > 0
                AND crapseg.cdsitseg  = 1                
                AND crapseg.tpplaseg  = tt-plano-seg.tpplaseg 
                AND crapseg.dtmvtolt  <  par_dtdespre 
                AND (crapseg.dtdebito >= par_dtpagmto) THEN DO: 

                    ASSIGN par_qtregist = par_qtregist + 1.

                    /* controles da paginação */
                    IF  (par_qtregist < par_nriniseq) OR
                        (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                        NEXT.
                    
                    IF aux_nrregist > 0 THEN
                       DO:
                          CREATE cratseg.
                          ASSIGN 
                              cratseg.tpseguro = crapseg.tpseguro
                              cratseg.tpplaseg = crapseg.tpplaseg
                              cratseg.dtdebito = crapseg.dtdebito
                              cratseg.nrdconta = crapseg.nrdconta
                              cratseg.nrctrseg = crapseg.nrctrseg
                              cratseg.dtmvtolt = crapseg.dtmvtolt
                              cratseg.vlpreseg = crapseg.vlpreseg.
                          
                          ASSIGN aux_acrescimo   = (crapseg.vlpreseg * (par_vlpercen / 100)).
                          
                          ASSIGN cratseg.vlatual = crapseg.vlpreseg + aux_acrescimo.
                          
                          ASSIGN cratseg.registro = recid(crapseg).
                       END.
                    
                    ASSIGN aux_nrregist = aux_nrregist - 1.

                END.
            END.
        END.
    END.

    EMPTY TEMP-TABLE tt-erro.

    IF aux_cdcritic <> 0 OR aux_dscritic <> "" THEN 
       DO:
          RUN gera_erro (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1, /** Sequencia **/
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic).
         
          IF par_flgerlog  THEN
             RUN proc_gerar_log (INPUT  par_cdcooper,
                                 INPUT  par_cdoperad,
                                 INPUT  aux_dscritic,
                                 INPUT  aux_dsorigem,
                                 INPUT  aux_dstransa,
                                 INPUT  FALSE,
                                 INPUT  par_idseqttl,
                                 INPUT  par_nmdatela,
                                 INPUT  par_nrdconta,
                                 OUTPUT aux_nrdrowid).   

          RETURN "NOK".
          
       END.

    IF par_flgerlog THEN
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

    RETURN "OK".

END PROCEDURE.

PROCEDURE pi_atualizar_valor_seg:

   DEF INPUT PARAM par_cdcooper    AS INTE                     NO-UNDO. 
   DEF INPUT PARAM par_cdagenci    AS INTE                     NO-UNDO. 
   DEF INPUT PARAM par_nrdcaixa    AS INTE                     NO-UNDO. 
   DEF INPUT PARAM par_cdoperad    AS CHAR                     NO-UNDO. 
   DEF INPUT PARAM par_dtmvtolt    AS DATE                     NO-UNDO. 
   DEF INPUT PARAM par_nrdconta    AS INTE                     NO-UNDO. 
   DEF INPUT PARAM par_idseqttl    AS INTE                     NO-UNDO. 
   DEF INPUT PARAM par_idorigem    AS INTE                     NO-UNDO. 
   DEF INPUT PARAM par_nmdatela    AS CHAR                     NO-UNDO. 
   DEF INPUT PARAM par_flgerlog    AS LOGI                     NO-UNDO. 
   DEF INPUT PARAM par_nrtabela    LIKE craptsg.nrtabela       NO-UNDO. 
   DEF INPUT PARAM par_tpseguro    LIKE crapseg.tpseguro       NO-UNDO. 
   DEF INPUT PARAM par_tpplaseg    LIKE craptsg.tpplaseg       NO-UNDO. 
   DEF INPUT PARAM par_dtdespre    AS DATE                     NO-UNDO. 
   DEF INPUT PARAM par_dtpagmto    AS DATE                     NO-UNDO. 
   DEF INPUT PARAM par_vlpercen    AS DEC                      NO-UNDO. 
   DEF OUTPUT PARAM TABLE FOR tt-erro.

   DEF VAR aux_contador AS INT                                 NO-UNDO.
   DEF VAR aux_qtregist AS INT                                 NO-UNDO.  

   EMPTY TEMP-TABLE cratseg.

   IF par_tpseguro <> 3 THEN
      DO:
         RUN gera_erro (INPUT par_cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_nrdcaixa,
                        INPUT 1, /** Sequencia **/
                        INPUT 513,
                        INPUT-OUTPUT aux_dscritic).

         IF   par_flgerlog  THEN
              RUN proc_gerar_log (INPUT  par_cdcooper,
                                  INPUT  par_cdoperad,
                                  INPUT  aux_dscritic,
                                  INPUT  aux_dsorigem,
                                  INPUT  aux_dstransa,
                                  INPUT  FALSE,
                                  INPUT  par_idseqttl,
                                  INPUT  par_nmdatela,
                                  INPUT  par_nrdconta,
                                  OUTPUT aux_nrdrowid).   

         RETURN "NOK".

      END.

   IF par_vlpercen = 0 THEN
      DO:
         ASSIGN aux_cdcritic = 0 
                aux_dscritic = "Informe o valor do percentual.".

         RUN gera_erro (INPUT par_cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_nrdcaixa,
                        INPUT 1, /** Sequencia **/
                        INPUT aux_cdcritic,
                        INPUT-OUTPUT aux_dscritic).

         IF   par_flgerlog  THEN
              RUN proc_gerar_log (INPUT  par_cdcooper,
                                  INPUT  par_cdoperad,
                                  INPUT  aux_dscritic,
                                  INPUT  aux_dsorigem,
                                  INPUT  aux_dstransa,
                                  INPUT  FALSE,
                                  INPUT  par_idseqttl,
                                  INPUT  par_nmdatela,
                                  INPUT  par_nrdconta,
                                  OUTPUT aux_nrdrowid).   

         RETURN "NOK".

      END.

   RUN pi_atualizar_perc_seg ( INPUT par_cdcooper,   
                                input 0,              
                                input 0,              
                                input par_cdoperad,   
                                input par_dtmvtolt,   
                                input 0,              
                                input 1,              
                                input 1,              
                                input par_nmdatela,   
                                input FALSE,
                                INPUT par_nrtabela,
                                INPUT par_tpseguro, 
                                INPUT par_tpplaseg,
                                INPUT par_dtdespre,
                                INPUT par_dtpagmto,
                                INPUT par_vlpercen,
                                INPUT 9999, /*nrregist*/
                                INPUT 1, /*nriniseq*/
                                OUTPUT aux_qtregist,
                                OUTPUT TABLE cratseg,
                                OUTPUT TABLE tt-erro).

   IF   RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            IF   AVAIL tt-erro   THEN
                DO:
                    ASSIGN aux_cdcritic = tt-erro.cdcritic
                           aux_dscritic = tt-erro.dscritic.
                    EMPTY TEMP-TABLE tt-erro.
                END.
        END.

    FOR  EACH cratseg NO-LOCK:

         DO aux_contador = 1 TO 10:
             
             FIND crapseg WHERE RECID(crapseg) = cratseg.registro 
                                EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
             IF NOT AVAIL crapseg THEN
                DO:
                   IF LOCKED(crapseg) THEN
                      DO:
                         ASSIGN aux_cdcritic = 84.
                         PAUSE 1 NO-MESSAGE.
                         NEXT.
                      END.
                END.
             ELSE
                DO:
                   ASSIGN crapseg.vlpreseg = cratseg.vlatual
                          aux_cdcritic     = 0.
                   LEAVE.
                END.
         END.
    END.

    IF   aux_cdcritic <> 0    OR
         aux_dscritic <> ""   THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1, /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

             IF   par_flgerlog  THEN
                  RUN proc_gerar_log (INPUT  par_cdcooper,
                                      INPUT  par_cdoperad,
                                      INPUT  aux_dscritic,
                                      INPUT  aux_dsorigem,
                                      INPUT  aux_dstransa,
                                      INPUT  FALSE,
                                      INPUT  par_idseqttl,
                                      INPUT  par_nmdatela,
                                      INPUT  par_nrdconta,
                                      OUTPUT aux_nrdrowid).   

             RETURN "NOK".

         END.

    IF   par_flgerlog  THEN
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
    RETURN "OK".
    
END PROCEDURE.



/*............................................................................*/



PROCEDURE imprimir_seg_atualizados:

  DEF INPUT PARAM par_cdcooper    AS INTE                     NO-UNDO. 
  DEF INPUT PARAM par_cdagenci    AS INTE                     NO-UNDO. 
  DEF INPUT PARAM par_nrdcaixa    AS INTE                     NO-UNDO. 
  DEF INPUT PARAM par_cdoperad    AS CHAR                     NO-UNDO. 
  DEF INPUT PARAM par_dtmvtolt    AS DATE                     NO-UNDO. 
  DEF INPUT PARAM par_nrdconta    AS INTE                     NO-UNDO. 
  DEF INPUT PARAM par_idseqttl    AS INTE                     NO-UNDO. 
  DEF INPUT PARAM par_idorigem    AS INTE                     NO-UNDO. 
  DEF INPUT PARAM par_nmdatela    AS CHAR                     NO-UNDO. 
  DEF INPUT PARAM par_flgerlog    AS LOGI                     NO-UNDO. 
  DEF INPUT PARAM par_nrtabela    LIKE craptsg.nrtabela       NO-UNDO. 
  DEF INPUT PARAM par_tpseguro    LIKE crapseg.tpseguro       NO-UNDO. 
  DEF INPUT PARAM par_tpplaseg    LIKE craptsg.tpplaseg       NO-UNDO. 
  DEF INPUT PARAM par_dtdespre    AS DATE                     NO-UNDO. 
  DEF INPUT PARAM par_dtpagmto    AS DATE                     NO-UNDO. 
  DEF INPUT PARAM par_vlpercen    AS DEC                      NO-UNDO. 
  DEF OUTPUT PARAM par_nmarqimp   AS CHAR                     NO-UNDO.
  DEF OUTPUT PARAM par_nmarqpdf   AS CHAR                     NO-UNDO.
  DEF OUTPUT PARAM TABLE FOR tt-erro.

  DEF VAR aux_nmendter AS CHAR                                NO-UNDO.
  DEF VAR aux_server   AS CHAR                                NO-UNDO.
  DEF VAR aux_qtregist AS INT                                 NO-UNDO.

  INPUT THROUGH basename `tty` NO-ECHO.
      
  SET aux_nmendter WITH FRAME f_terminal.

  INPUT THROUGH basename `hostname -s` NO-ECHO.
  IMPORT UNFORMATTED aux_server.
  INPUT CLOSE.
  
  ASSIGN aux_nmendter = substr(aux_server,length(aux_server) - 1) +
                        aux_nmendter.

  EMPTY TEMP-TABLE tt-erro.

  impressao:
  DO:
     RUN buscar_cooperativa (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT par_cdoperad,
                             INPUT par_dtmvtolt,
                             INPUT par_nrdconta,
                             INPUT par_idseqttl,
                             INPUT par_idorigem,
                             INPUT par_nmdatela,
                             INPUT par_flgerlog,
                             OUTPUT TABLE tt-cooperativa,
                             OUTPUT TABLE tt-erro).
     
     IF RETURN-VALUE <> "OK"  THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  AVAIL tt-erro   THEN
               DO:
                   ASSIGN aux_cdcritic = tt-erro.cdcritic
                          aux_dscritic = tt-erro.dscritic.
                   
                   LEAVE impressao.

               END.
        END.
         
     FIND FIRST tt-cooperativa WHERE
                tt-cooperativa.cdcooper = par_cdcooper  NO-ERROR.
     
     ASSIGN par_nmarqimp = "/usr/coop/" + tt-cooperativa.dsdircop +
                           "/rl/" + aux_nmendter.
     
     IF SEARCH(par_nmarqimp) <> ? THEN
        UNIX SILENT VALUE("rm " + par_nmarqimp + "* 2> /dev/null").
     
     ASSIGN par_nmarqimp = par_nmarqimp + STRING(TIME)
            par_nmarqimp = par_nmarqimp + ".ex"
            par_nmarqpdf = par_nmarqimp + ".pdf".
     
      RUN pi_atualizar_perc_seg ( INPUT par_cdcooper,   
                                 input 0,              
                                 input 0,              
                                 input par_cdoperad,   
                                 input par_dtmvtolt,   
                                 input 0,              
                                 input 1,              
                                 input 1,              
                                 input par_nmdatela,   
                                 input FALSE,
                                 INPUT par_nrtabela,
                                 INPUT par_tpseguro, 
                                 INPUT par_tpplaseg,
                                 INPUT par_dtdespre,
                                 INPUT par_dtpagmto,
                                 INPUT par_vlpercen,
                                 INPUT 9999, /*nrregist*/
                                 INPUT 1, /*nriniseq*/
                                 OUTPUT aux_qtregist,
                                 OUTPUT TABLE cratseg,
                                 OUTPUT TABLE tt-erro).
     
      IF RETURN-VALUE <> "OK"  THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.

             IF   AVAIL tt-erro   THEN
                 DO:
                     ASSIGN aux_cdcritic = tt-erro.cdcritic
                            aux_dscritic = tt-erro.dscritic.
             
                     LEAVE impressao.

                 END.
         END.
     
     
     OUTPUT STREAM str_1 TO VALUE(par_nmarqimp) PAGED PAGE-SIZE 84.
     
     FOR EACH cratseg NO-LOCK
           BY cratseg.tpseguro
              BY cratseg.tpplaseg
                 BY cratseg.dtdebito
                    BY cratseg.nrdconta
                       BY cratseg.nrctrseg:
            
         DISP STREAM str_1
              cratseg.tpplaseg COLUMN-LABEL "Plano"    
              cratseg.dtdebito COLUMN-LABEL "Debito"   
              cratseg.nrdconta COLUMN-LABEL "Conta"    
              cratseg.nrctrseg COLUMN-LABEL "Contrato" 
              cratseg.vlpreseg COLUMN-LABEL "Vl.Ant."  
              cratseg.vlatual  COLUMN-LABEL "Vl.Atual" 
              cratseg.dtmvtolt COLUMN-LABEL "Movto"   
              WITH WIDTH 80.  
                               
     END.
     
     OUTPUT STREAM str_1 CLOSE.
     
     IF NOT VALID-HANDLE(h-b1wgen0024) THEN
        RUN sistema/generico/procedures/b1wgen0024.p
            PERSISTENT SET h-b1wgen0024.
     
     RUN gera-pdf-impressao IN h-b1wgen0024 (INPUT par_nmarqimp,
                                             INPUT par_nmarqpdf).
     
     IF VALID-HANDLE(h-b1wgen0024) THEN
        DELETE PROCEDURE h-b1wgen0024.
     
     /** Copiar pdf para visualizacao no Ayllos WEB **/
     IF  par_idorigem = 5  THEN
         DO:
             IF  SEARCH(par_nmarqpdf) = ?  THEN
                 DO:
                     ASSIGN aux_dscritic = "Nao foi possivel " +
                                           "gerar a impressao.".
                     LEAVE impressao.
                 END.
     
             UNIX SILENT VALUE ('sudo /usr/bin/su - scpuser -c ' +
             '"scp ' + par_nmarqpdf + ' scpuser@' + aux_srvintra +
             ':/var/www/ayllos/documentos/' + tt-cooperativa.dsdircop +
             '/temp/" 2>/dev/null').
         END.
     
     IF par_idorigem = 5  THEN
        DO:
           IF SEARCH(par_nmarqimp) <> ? THEN
              UNIX SILENT VALUE ("rm " + par_nmarqimp + "* 2>/dev/null").
        END.
     ELSE
        DO:
           IF SEARCH(par_nmarqpdf) <> ? THEN
              UNIX SILENT VALUE ("rm " + par_nmarqpdf + " 2>/dev/null").
        END.
     
     ASSIGN par_nmarqpdf =
         ENTRY(NUM-ENTRIES(par_nmarqpdf,"/"),par_nmarqpdf,"/").
            
  END.

  IF aux_cdcritic <> 0  OR
     aux_dscritic <> "" THEN
     DO:
         RUN gera_erro (INPUT par_cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_nrdcaixa,
                        INPUT 1, /** Sequencia **/
                        INPUT aux_cdcritic,
                        INPUT-OUTPUT aux_dscritic).
  
         IF  par_flgerlog  THEN
             RUN proc_gerar_log (INPUT  par_cdcooper,
                                 INPUT  par_cdoperad,
                                 INPUT  aux_dscritic,
                                 INPUT  aux_dsorigem,
                                 INPUT  aux_dstransa,
                                 INPUT  FALSE,
                                 INPUT  par_idseqttl,
                                 INPUT  par_nmdatela,
                                 INPUT  par_nrdconta,
                                 OUTPUT aux_nrdrowid).   
         
         RETURN "NOK".

     END.
         
  IF par_flgerlog  THEN
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
  
  RETURN "OK".

END PROCEDURE.

/* Buscar saldo devedor de todos emprestimos por cpf */
PROCEDURE saldo-devedor-cpf:

    DEF INPUT PARAM par_cdcooper AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                               NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_nrcpfcgc AS DECI                               NO-UNDO.

    DEF OUTPUT PARAM par_vlsdeved AS DECI                              NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                              NO-UNDO.

    DEF VAR aux_qtregist AS INTE                                       NO-UNDO.
    DEF VAR h-b1wgen0002 AS HANDLE                                     NO-UNDO.
    
    /* Buscar todos os emprestimos ativos por cpf */
    FOR EACH crapass WHERE crapass.cdcooper = par_cdcooper AND
                           crapass.nrcpfcgc = par_nrcpfcgc
                           NO-LOCK:
        
        IF  NOT VALID-HANDLE(h-b1wgen0002)  THEN
            RUN sistema/generico/procedures/b1wgen0002.p
                PERSISTENT SET h-b1wgen0002.

         RUN obtem-dados-emprestimos IN h-b1wgen0002
                                   ( INPUT par_cdcooper,
                                     INPUT 0,  /** agencia **/
                                     INPUT 0,  /** caixa **/
                                     INPUT par_cdoperad,
                                     INPUT "sldepr.p",
                                     INPUT 1,  /** origem **/
                                     INPUT crapass.nrdconta,
                                     INPUT 1,  /** idseqttl **/
                                     INPUT par_dtmvtolt,
                                     INPUT ?,
                                     INPUT par_dtmvtolt,
                                     INPUT 0, /** Contrato **/
                                     INPUT "sldepr.p",
                                     INPUT 0, /* inproces */
                                     INPUT FALSE, /** Log **/
                                     INPUT TRUE,
                                     INPUT 0, /** nriniseq **/
                                     INPUT 0, /** nrregist **/
                                    OUTPUT aux_qtregist,
                                    OUTPUT TABLE tt-erro,
                                    OUTPUT TABLE tt-dados-epr ).
        
         IF  VALID-HANDLE(h-b1wgen0002) THEN
             DELETE OBJECT h-b1wgen0002.
        
         IF  RETURN-VALUE <> "OK"  THEN
             DO:
                 FIND FIRST tt-erro NO-LOCK NO-ERROR.
        
                 IF  AVAILABLE tt-erro  THEN
                     ASSIGN par_dscritic = tt-erro.dscritic.
                 ELSE
                     ASSIGN par_dscritic = "Erro no carregamento"
                                          + " de emprestimos.".
                
                 RETURN "NOK".
             END.

             /* Somar saldo devedor  */
             FOR EACH tt-dados-epr NO-LOCK:

                 ASSIGN par_vlsdeved = par_vlsdeved + tt-dados-epr.vlsdeved.
             END.
    END.

    RETURN "OK".

END.

/*Criacao dos registros da tabela DE/PARA de plano de seguros inativos*/
PROCEDURE cria-tabela-depara:
    DEF OUTPUT PARAM TABLE FOR tt-pldepara.

    EMPTY TEMP-TABLE tt-pldepara.

    CREATE tt-pldepara.
    ASSIGN tt-pldepara.cdsegura = 5011
           tt-pldepara.tpseguro = 11
           tt-pldepara.tpplasde = 11
           tt-pldepara.tpplaspa = 41.

    CREATE tt-pldepara.
    ASSIGN tt-pldepara.cdsegura = 5011
           tt-pldepara.tpseguro = 11
           tt-pldepara.tpplasde = 12    
           tt-pldepara.tpplaspa = 42.

    CREATE tt-pldepara.
    ASSIGN tt-pldepara.cdsegura = 5011
           tt-pldepara.tpseguro = 11
           tt-pldepara.tpplasde = 13    
           tt-pldepara.tpplaspa = 43.

    CREATE tt-pldepara.
    ASSIGN tt-pldepara.cdsegura = 5011
           tt-pldepara.tpseguro = 11
           tt-pldepara.tpplasde = 21    
           tt-pldepara.tpplaspa = 41.

    CREATE tt-pldepara.
    ASSIGN tt-pldepara.cdsegura = 5011
           tt-pldepara.tpseguro = 11
           tt-pldepara.tpplasde = 22    
           tt-pldepara.tpplaspa = 42.

    CREATE tt-pldepara.
    ASSIGN tt-pldepara.cdsegura = 5011
           tt-pldepara.tpseguro = 11
           tt-pldepara.tpplasde = 23    
           tt-pldepara.tpplaspa = 43.

    CREATE tt-pldepara.
    ASSIGN tt-pldepara.cdsegura = 5011
           tt-pldepara.tpseguro = 11
           tt-pldepara.tpplasde = 31    
           tt-pldepara.tpplaspa = 41.

    CREATE tt-pldepara.
    ASSIGN tt-pldepara.cdsegura = 5011
           tt-pldepara.tpseguro = 11
           tt-pldepara.tpplasde = 32    
           tt-pldepara.tpplaspa = 42.

    CREATE tt-pldepara.
    ASSIGN tt-pldepara.cdsegura = 5011
           tt-pldepara.tpseguro = 11
           tt-pldepara.tpplasde = 33    
           tt-pldepara.tpplaspa = 43.

    CREATE tt-pldepara.
    ASSIGN tt-pldepara.cdsegura = 5011
           tt-pldepara.tpseguro = 11
           tt-pldepara.tpplasde = 171   
           tt-pldepara.tpplaspa = 201.

    CREATE tt-pldepara.
    ASSIGN tt-pldepara.cdsegura = 5011
           tt-pldepara.tpseguro = 11
           tt-pldepara.tpplasde = 172   
           tt-pldepara.tpplaspa = 202.

    CREATE tt-pldepara.
    ASSIGN tt-pldepara.cdsegura = 5011
           tt-pldepara.tpseguro = 11
           tt-pldepara.tpplasde = 173   
           tt-pldepara.tpplaspa = 203.

    CREATE tt-pldepara.
    ASSIGN tt-pldepara.cdsegura = 5011
           tt-pldepara.tpseguro = 11
           tt-pldepara.tpplasde = 181   
           tt-pldepara.tpplaspa = 201.

    CREATE tt-pldepara.
    ASSIGN tt-pldepara.cdsegura = 5011
           tt-pldepara.tpseguro = 11
           tt-pldepara.tpplasde = 182   
           tt-pldepara.tpplaspa = 202.

    CREATE tt-pldepara.
    ASSIGN tt-pldepara.cdsegura = 5011
           tt-pldepara.tpseguro = 11
           tt-pldepara.tpplasde = 183    
           tt-pldepara.tpplaspa = 203.

    CREATE tt-pldepara.
    ASSIGN tt-pldepara.cdsegura = 5011
           tt-pldepara.tpseguro = 11
           tt-pldepara.tpplasde = 191   
           tt-pldepara.tpplaspa = 201.

    CREATE tt-pldepara.
    ASSIGN tt-pldepara.cdsegura = 5011
           tt-pldepara.tpseguro = 11
           tt-pldepara.tpplasde = 192   
           tt-pldepara.tpplaspa = 202.

    CREATE tt-pldepara.
    ASSIGN tt-pldepara.cdsegura = 5011
           tt-pldepara.tpseguro = 11
           tt-pldepara.tpplasde = 193   
           tt-pldepara.tpplaspa = 203.

    CREATE tt-pldepara.
    ASSIGN tt-pldepara.cdsegura = 5011
           tt-pldepara.tpseguro = 11
           tt-pldepara.tpplasde = 331   
           tt-pldepara.tpplaspa = 361.

    CREATE tt-pldepara.
    ASSIGN tt-pldepara.cdsegura = 5011
           tt-pldepara.tpseguro = 11
           tt-pldepara.tpplasde = 332   
           tt-pldepara.tpplaspa = 362.

    CREATE tt-pldepara.
    ASSIGN tt-pldepara.cdsegura = 5011
           tt-pldepara.tpseguro = 11
           tt-pldepara.tpplasde = 333   
           tt-pldepara.tpplaspa = 363.

    CREATE tt-pldepara.
    ASSIGN tt-pldepara.cdsegura = 5011
           tt-pldepara.tpseguro = 11
           tt-pldepara.tpplasde = 341   
           tt-pldepara.tpplaspa = 361.

    CREATE tt-pldepara.
    ASSIGN tt-pldepara.cdsegura = 5011
           tt-pldepara.tpseguro = 11
           tt-pldepara.tpplasde = 342   
           tt-pldepara.tpplaspa = 362.

    CREATE tt-pldepara.
    ASSIGN tt-pldepara.cdsegura = 5011
           tt-pldepara.tpseguro = 11
           tt-pldepara.tpplasde = 343   
           tt-pldepara.tpplaspa = 363.

    CREATE tt-pldepara.
    ASSIGN tt-pldepara.cdsegura = 5011
           tt-pldepara.tpseguro = 11
           tt-pldepara.tpplasde = 351   
           tt-pldepara.tpplaspa = 361.

    CREATE tt-pldepara.
    ASSIGN tt-pldepara.cdsegura = 5011
           tt-pldepara.tpseguro = 11
           tt-pldepara.tpplasde = 352   
           tt-pldepara.tpplaspa = 362.

    CREATE tt-pldepara.
    ASSIGN tt-pldepara.cdsegura = 5011
           tt-pldepara.tpseguro = 11
           tt-pldepara.tpplasde = 353   
           tt-pldepara.tpplaspa = 363.

    RETURN "OK".
END PROCEDURE.
