/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL                     |
  +---------------------------------+-----------------------------------------+
  | procedures/b1wgen0030i.p        | DSCT0002                                |
  |   gera-impressao-limite         | DSCT0002.pc_gera_impressao_limite       |
  |   gera-impressao-bordero        | DSCT0002.pc_gera_impressao_bordero      |
  +---------------------------------+-----------------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/

/*.............................................................................

    Programa: b1wgen0030i.p
    Autor   : Lucas Lunelli
    Data    : Agosto/2012                     Ultima Atualizacao: 27/06/2016
           
    Dados referentes ao programa:
                
    Objetivo  : BO30 - Impressoes de Desconto de Títulos e Limite
                    
    Alteracoes: 12/11/2012 - Ajuste na procedure gera-impressao-limite para
                             apresentar o grupo eocnomico (Adriano).
                             
                13/02/2013 - Alteraçoes para o Projeto GED - Fase 2 (Lucas). 
                
                24/04/2013 - Ajuste para nao exibir campos de percentual de tit.
                             protestados e em cartório em caso de cobrança 
                             SEM REGISTRO (Lucas).          
                             
                06/05/2013 - Adicionado Tp. de Docmto GED na área de uso da 
                             Digitalizaçao (Lucas).
                             
                09/05/2013 - Inserido uma quebra de pagina antes de mostrar o 
                             frame de "Historico dos Ratings" na procedure 
                             gera-impressao-limite (Adriano).  
                
                13/08/2013 - Nova forma de chamar as agencias, de PAC agora 
                             a escrita será PA (André Euzébio - Supero).    
                             
                25/06/2014 - Inclusao do uso da temp-table tt-grupo na b1wgen0138tt.
                            (Chamado 130880) - (Tiago Castro - RKAM)
                            
                01/08/2014 - Inclusao do "PARA USO DA DIGITALIZACAO".
                             (Chamado 131438) - (Tiago Castro - RKAM)
                  
                25/08/2014 - Ajustes referentes ao Projeto CET 
                             (Lucas Ranghetti/Gielow)

                02/12/2014 - De acordo com a circula 3.656 do Banco Central, substituir nomenclaturas 
                             Cedente por Beneficiário e  Sacado por Pagador 
                             Chamado 229313 (Jean Reddiga - RKAM).    
                             
                31/12/2014 - Ajuste format numero contrato/bordero na area
                             de 'USO DA DIGITALIZACAO'; adequacao ao format
                             pre-definido para nao ocorrer divergencia ao 
                             pesquisar no SmartShare. 
                             (Chamado 181988) - (Fabricio)
               
                26/01/2015 - Alterado o formato do campo nrctremp para 8 
                             caracters (Kelvin - 233714)
                             
                28/08/2015 - Ajustado para mostrar CPF do avalista corretamente
                             assim como do conjuge. (Jorge/Gielow) - SD 290885

                27/06/2016 - Listagem das restricoes aprovadas pelo coordenador.
                             Busca do operador que aprovou. (Jaison/James)
                
				15/09/2016 - Inclusao dos parametros default na rotina oracle
				             pc_imprime_limites_cet PRJ314 (Odirlei-AMcom)

..............................................................................*/

{ sistema/generico/includes/b1wgen0030tt.i }
{ sistema/generico/includes/b1wgen0002tt.i }
{ sistema/generico/includes/b1wgen9999tt.i }
{ sistema/generico/includes/b1wgen0043tt.i }

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/b1wgen0138tt.i }

{ sistema/generico/includes/var_oracle.i }

DEF STREAM str_1.
DEF STREAM str_dsctit.

DEF STREAM str_2.
DEF STREAM str_3.
DEF STREAM str_4.

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF VAR aux_nmarquiv AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                           NO-UNDO.
DEF VAR rel_nmrescop AS CHAR EXTENT 2                                  NO-UNDO.    

DEF VAR h-b1wgen0030 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0024 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen9999 AS HANDLE                                         NO-UNDO.

/*****************************************************************************/
/**           Procedure para gerar impressoes de bordero de tit.            **/
/*****************************************************************************/
PROCEDURE gera-impressao-bordero:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagecxa AS INTE  /** PAC Operador   **/   NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE  /** Nr. Caixa      **/   NO-UNDO.
    DEF  INPUT PARAM par_cdopecxa AS CHAR  /** Operador Caixa **/   NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idimpres AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrborder AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgemail AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.    

    DEF VAR rel_dscpfcgc AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdtraco AS CHAR                                    NO-UNDO.
    DEF VAR rel_tpcobran AS CHAR                                    NO-UNDO.
    DEF VAR rel_prtitcar AS CHAR                                    NO-UNDO.
    DEF VAR rel_prtitpro AS CHAR                                    NO-UNDO.
    DEF VAR rel_vltottit AS DECI EXTENT 3                           NO-UNDO.
    DEF VAR rel_vltotliq AS DECI EXTENT 3                           NO-UNDO.
    DEF VAR rel_qttottit AS INTE EXTENT 3                           NO-UNDO.
    DEF VAR rel_qtrestri AS INTE EXTENT 3                           NO-UNDO.
    DEF VAR rel_vlmedtit AS DECI EXTENT 3                           NO-UNDO.
    DEF VAR rel_nrdconta AS INTE                                    NO-UNDO.
    DEF VAR rel_numconta AS INTE                                    NO-UNDO. 
    DEF VAR rel_qtdprazo AS INTE                                    NO-UNDO.
    DEF VAR aux_tpdocged AS INTE                                    NO-UNDO.
    DEF VAR aux_extncont AS INTE    INIT 1                          NO-UNDO.
    /* Ctrl de indice do Extent: 1 - S/ Reg. / 2 - Cob. Reg. / 3 - Todos */

    DEF VAR h-b1wgen0002 AS HANDLE                                  NO-UNDO.
    
    DEF VAR aux_cdopecoo AS CHARACTER INIT ""                       NO-UNDO.
    DEF VAR aux_dsopecoo AS CHARACTER                               NO-UNDO.

/*  Configuracao da impressora .............................................. */
FORM "\022\024\033\120\033\017\0330\033x0" WITH NO-BOX NO-LABELS FRAME f_config.
/* FORM "\022\024\033\115\0330\033x0" WITH NO-BOX NO-LABELS FRAME f_config. */

FORM crapcop.nmextcop FORMAT "x(70)"
     SKIP(1)
     WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_coop.

/*  Cabecalhos .............................................................. */

FORM "BORDERO DE DESCONTO DE TITULOS"
     "PARA USO DA DIGITALIZACAO"                             AT  87
     SKIP(1)
     tt-dados_tits_bordero.nrdconta      FORMAT "zzzz,zzz,9" AT  87
     tt-dados_tits_bordero.nrborder      FORMAT "z,zzz,zz9"  AT 104
     aux_tpdocged                        FORMAT "zz9"        AT 118
     SKIP(1)
     WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_cab_bordero.
     
FORM "DEMONSTRATIVO PARA ANALISE DE DESCONTO DE TITULOS" 
     "PARA USO DA DIGITALIZACAO"                                    AT  87
     SKIP(1)
     tt-dados_tits_bordero.nrdconta  NO-LABEL FORMAT "zzzz,zzz,9" AT  87
     tt-dados_tits_bordero.nrborder  NO-LABEL FORMAT "z,zzz,zz9"  AT 104
     aux_tpdocged                    NO-LABEL FORMAT "zz9"        AT 118
     SKIP(1)
     WITH NO-BOX WIDTH 132 FRAME f_cab_analise.

/*  Titulos descontados ..................................................... */

FORM tt-dados_tits_bordero.nrdconta FORMAT "zzzz,zzz,9" AT  1 LABEL 
     "Conta/dv" "-"  tt-dados_tits_bordero.nmprimtl FORMAT "x(50)"
     "          PA:" tt-dados_tits_bordero.cdagenci
     SKIP(1)
     tt-dados_tits_bordero.nrborder AT  1 LABEL "Bordero"
     tt-dados_tits_bordero.nrctrlim AT 37 LABEL "Contrato"
     tt-dados_tits_bordero.vllimite AT 74 LABEL "Limite"
     SKIP(1)
     "Taxa aplicada:"               AT  1
     tt-dados_tits_bordero.txdanual NO-LABEL FORMAT "z9.999999" "% aa     "
     tt-dados_tits_bordero.txmensal NO-LABEL FORMAT "z9.999999" "% am     "
     tt-dados_tits_bordero.txdiaria NO-LABEL FORMAT "9.9999999" "% ad"
     SKIP(1)
     "TITULOS ENTREGUES PARA DESCONTO:"
     SKIP(1)
     WITH NO-BOX NO-LABELS SIDE-LABELS WIDTH 132 FRAME f_identifica.
     
FORM "Vencimento  Nosso Numero                Valor   Valor Liquido"  AT  1
     "Prz  Pagador                              CPF/CNPJ"             AT 64
     SKIP(1)
     WITH NO-BOX NO-LABELS SIDE-LABELS WIDTH 132 FRAME f_identifica_cab.

FORM tt-tits_do_bordero.dtvencto    FORMAT "99/99/9999"
     tt-tits_do_bordero.nossonum    FORMAT "99999999999999999"   AT 13
     tt-tits_do_bordero.vltitulo    FORMAT "zzz,zzz,zz9.99"      AT 32
     tt-tits_do_bordero.vlliquid    FORMAT "zzz,zzz,zz9.99-"     AT 48
     rel_qtdprazo                   FORMAT "zz9-"                AT 64
     tt-tits_do_bordero.nmsacado    FORMAT "x(32)"               AT 69
     rel_dscpfcgc                   FORMAT "X(19)"               AT 103
     WITH NO-BOX WIDTH 132 NO-LABELS DOWN FRAME f_titulos.

FORM SKIP(1)
     tt-tits_do_bordero.flgregis LABEL "Tipo de Cobranca" SKIP(1)
     WITH NO-BOX SIDE-LABELS WIDTH 132 FRAME f_tpcobran.

FORM SKIP (1)
     "TOTAL(S/ REG) ==>"   AT  1
     rel_qttottit[1]       AT 18  FORMAT "z,zz9" "TITULOS"
     rel_vltottit[1]       AT 32  FORMAT "zzz,zzz,zz9.99"
     rel_vltotliq[1]       AT 48  FORMAT "zzz,zzz,zz9.99-" 
     "    VLR. MEDIO:"
     rel_vlmedtit[1]              FORMAT "zz,zzz,zz9.99"     
     rel_qtrestri[1]       AT 95  FORMAT "z,zz9" "RESTRICAO(OES)"
     SKIP(1)
     WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_total_sr.

FORM SKIP(1)
     "TOTAL(REGIST) ==>"   AT  1
     rel_qttottit[2]       AT 18  FORMAT "z,zz9" "TITULOS"
     rel_vltottit[2]       AT 32  FORMAT "zzz,zzz,zz9.99"
     rel_vltotliq[2]       AT 48  FORMAT "zzz,zzz,zz9.99-" 
     "    VLR. MEDIO:"
     rel_vlmedtit[2]              FORMAT "zz,zzz,zz9.99"     
     rel_qtrestri[2]       AT 95  FORMAT "z,zz9" "RESTRICAO(OES)"
     SKIP(1)
     WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_total_cr.

FORM SKIP(1)
     "TOTAL ==>"           AT  1
     rel_qttottit[3]       AT 18  FORMAT "z,zz9" "TITULOS"
     rel_vltottit[3]       AT 32  FORMAT "zzz,zzz,zz9.99"
     rel_vltotliq[3]       AT 48  FORMAT "zzz,zzz,zz9.99-" 
     "    VLR. MEDIO:"
     rel_vlmedtit[3]              FORMAT "zz,zzz,zz9.99"     
     rel_qtrestri[3]       AT 95  FORMAT "z,zz9" "RESTRICAO(OES)"
     SKIP(1)
     WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_total.

/*  Restricoes .............................................................. */

FORM "===>"
     tt-dsctit_bordero_restricoes.dsrestri FORMAT "x(60)"
     WITH NO-BOX NO-LABELS DOWN WIDTH 132 FRAME f_restricoes.

FORM aux_dsdtraco FORMAT "x(132)"
     WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_traco.

FORM SKIP(3)
     tt-dados_tits_bordero.nmcidade FORMAT "x(15)" AT 1 "," tt-dados_tits_bordero.ddmvtolt FORMAT "99" "de" 
     tt-dados_tits_bordero.dsmesref FORMAT "x(9)"
     "de" tt-dados_tits_bordero.aamvtolt FORMAT "9999" SKIP(5)
     "___________________________________________" AT  1 
     "___________________________________________" AT 90 SKIP
     tt-dados_tits_bordero.nmprimtl AT  1 FORMAT "x(50)"
     "Operador:"      AT 90 tt-dados_tits_bordero.nmoperad FORMAT "x(32)" SKIP(5)
     "___________________________________________" AT 1 SKIP  
     tt-dados_tits_bordero.nmresco1 FORMAT "x(40)" AT 1 SKIP
     tt-dados_tits_bordero.nmresco2 FORMAT "x(40)" AT 1
     SKIP(5)
     "___________________________________________" AT 1
     "___________________________________________" AT 90 SKIP
     "Testemunha" AT 1  
     "Testemunha" AT 90
     WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_final.

/*  Proposta de Limite de descontos de titulos ............................. */

FORM tt-proposta_bordero.nmextcop FORMAT "x(50)"
     SKIP(1)
     "\033\016PROPOSTA DE DESCONTO DE TITULOS\024"
     SKIP(3)     
     "\033\105\DADOS DO ASSOCIADO\033\106"
     SKIP(1)
     "Conta/dv:\033\016" tt-proposta_bordero.nrdconta FORMAT "zzzz,zzz,9" "\024"
     "Matricula:" AT 27  tt-proposta_bordero.nrmatric FORMAT "zzz,zz9"
     "PA:"    AT 54  tt-proposta_bordero.dsagenci FORMAT "x(25)"
     SKIP(1)
     "Nome    :"        tt-proposta_bordero.nmprimtl FORMAT "x(50)"
     "Adm COOP:"  AT 76 tt-proposta_bordero.dtadmiss FORMAT "99/99/9999"
     SKIP(1)
     "Empresa :"        tt-proposta_bordero.nmempres FORMAT "x(35)"
     "Secao:"     AT 47 tt-proposta_bordero.nmdsecao FORMAT "x(20)"
     "Adm empr:"  AT 76 tt-proposta_bordero.dtadmemp FORMAT "99/99/9999"
     SKIP(1)
     "Fone/Ramal:" AT 42 tt-proposta_bordero.telefone FORMAT "x(20)"
     SKIP(1)
     "Tipo de Conta:"           tt-proposta_bordero.dstipcta FORMAT "x(25)"
     "Situacao da Conta:" AT 67 tt-proposta_bordero.dssitdct FORMAT "x(10)"
     SKIP(1)
     "Ramo de Atividade:"       tt-proposta_bordero.dsramati FORMAT "x(40)"                 
     SKIP(2)
     WITH NO-BOX NO-LABELS WIDTH 96 FRAME f_pro_dados.

FORM "\033\105RECIPROCIDADE\033\106"
     "Saldo Medio do Trimestre:" AT 20 tt-proposta_bordero.vlsmdtri FORMAT "zzz,zzz,zz9.99"
     "Capital:"                  AT 77 tt-proposta_bordero.vlcaptal FORMAT "zzz,zzz,zz9.99-"
     SKIP(1)
     "Plano:"                          tt-proposta_bordero.vlprepla FORMAT "zzz,zzz,zz9.99"
     "Aplicacoes:"               AT 70 tt-proposta_bordero.vlaplica FORMAT "zzz,zzz,zz9.99"
     SKIP(2)
     "\033\105RENDA MENSAL\033\106"
     "Salario:"                  AT 31 tt-proposta_bordero.vlsalari FORMAT "zzz,zzz,zz9.99"
     "Salario do Conjuge:"       AT 66 tt-proposta_bordero.vlsalcon FORMAT "zzz,zzz,zz9.99" 
     SKIP(1)
     "Faturamento Mensal:"       AT 16 tt-proposta_bordero.vlfatura
     "Outras:"                   AT 74 tt-proposta_bordero.vloutras FORMAT "zzz,zzz,zz9.99"
     SKIP(2)
     "\033\105LIMITES\033\106"
     "Cheque Especial:"      AT 20 tt-proposta_bordero.vllimcre FORMAT "zzz,zzz,zz9.99"
     "Cartoes de Credito:"   AT 66 tt-proposta_bordero.vltotccr FORMAT "zzz,zzz,zz9.99"
     SKIP
     "Desconto de Cheques:"  AT 12 tt-proposta_bordero.vllimchq FORMAT "zzz,zzz,zz9.99"
     "Desconto de Titulos:"  AT 61 tt-proposta_bordero.vllimpro FORMAT "zzz,zzz,zz9.99"
     SKIP(2)
     "\033\105CARTEIRA DE COBRANCA:\033\106"
     SKIP(1)
     "\033\105TIPO DE COBRANCA:\033\106" AT 01 tt-proposta_bordero.tpcobran FORMAT "X(25)"
     SKIP(1)
     "Quantidade de Boletos da Carteira de Cobranca:     "   
     tt-proposta_bordero.qtdbolet  FORMAT "zzz,zz9"
     SKIP
     "          Valor Medio da Carteira de Cobranca:" 
     tt-proposta_bordero.vlmedbol  FORMAT "z,zzz,zz9.99"
     SKIP(1)
     "            Valor Medio por Titulo Descontado:"    
     tt-proposta_bordero.vlmeddsc  FORMAT "z,zzz,zz9.99" 
     SKIP
     "   Quantidade de Titulos nao Pagos por Pagador:    "    
     tt-proposta_bordero.qttitsac  FORMAT "zzz,zz9"  
     " (ultimos"  tt-proposta_bordero.nrmespsq  FORMAT "z9"   "meses)"
     SKIP
     "  Percentual de Titulos nao Pagos por Beneficiario:"    
     tt-proposta_bordero.perceden  FORMAT "x(20)"
     SKIP
     rel_prtitpro                  AT 11 FORMAT "x(36)"
     tt-proposta_bordero.prtitpro        FORMAT "x(20)"
     SKIP
     rel_prtitcar                  AT 17 FORMAT "x(30)"
     tt-proposta_bordero.prtitcar        FORMAT "x(20)"
     SKIP(1)
     "\033\105BENS:\033\106"
     tt-proposta_bordero.dsdeben1 AT 12 FORMAT "x(85)" SKIP
     tt-proposta_bordero.dsdeben2 AT 08 FORMAT "x(85)" SKIP
     SKIP(1)
     "\033\105DESCONTO PROPOSTO:\033\106"
     " \033\016"        tt-proposta_bordero.vltottit FORMAT "zzz,zzz,zz9.99" 
     "\024" "(\033\016" tt-proposta_bordero.qttottit FORMAT "zz,zz9" "\024" "Titulos )"
     WITH NO-BOX NO-LABELS WIDTH 130 FRAME f_pro_rec.
     
FORM SKIP(1)
     "\033\105SEM ENDIVIDAMENTO NA COOPERATIVA DE CREDITO\033\106" SKIP(2)
     WITH NO-BOX WIDTH 96 FRAME f_sem_divida.

FORM SKIP(2)
     "\033\105ENDIVIDAMENTO NA COOPERATIVA DE CREDITO EM"
     tt-proposta_bordero.dtcalcul FORMAT "99/99/9999" "\033\106"     
     SKIP(1)
     "Saldo do Desconto:" 
     tt-proposta_bordero.vlslddsc FORMAT "zzz,zzz,zz9.99"
     tt-proposta_bordero.qtdscsld FORMAT "zz,zz9"
     "Titulos"           
     "Maior Titulo:" AT 60      
     tt-proposta_bordero.vlmaxdsc FORMAT "zzz,zzz,zz9.99"      
     SKIP
     "Valor Medio:"  AT 61
     tt-proposta_bordero.valormed FORMAT "zzz,zzz,zz9.99" 
     SKIP(1)
     " Contrato  Saldo Devedor Prestacoes"
     "Linha de Credito  Finalidade" AT 51
     SKIP(1)
     WITH NO-BOX NO-LABELS WIDTH 96 FRAME f_pro_ed1.
                                                                  
FORM tt-emprsts.nrctremp AT  1 FORMAT "zz,zzz,zz9"
     tt-emprsts.vlsdeved AT 12 FORMAT "zzz,zzz,zz9.99"
     tt-emprsts.dspreapg AT 27 FORMAT "x(11)"
     tt-emprsts.vlpreemp AT 39 FORMAT "zzzz,zz9.99"
     "\033\017"
     tt-emprsts.dslcremp FORMAT "x(30)"
     tt-emprsts.dsfinemp FORMAT "x(28)"
     "\022\033\115"
     WITH NO-BOX NO-LABELS DOWN WIDTH 120 FRAME f_dividas.

FORM "--------------            ------------" AT 11
     SKIP
     tt-proposta_bordero.vlsdeved AT 11 FORMAT "zzz,zzz,zz9.99"
     tt-proposta_bordero.vlpreemp AT 37 FORMAT "zzzzz,zz9.99"
     SKIP(1)
     WITH NO-BOX NO-LABELS WIDTH 96 FRAME f_tot_div.

FORM SKIP(2)
     "AUTORIZO A CONSULTA DE MINHAS INFORMACOES CADASTRAIS"
     "NOS SERVICOS DE PROTECAO AO CREDITO" AT 54 
     "(SPC, SERASA, CADIN, ...) ALEM DO CADASTRO DA CENTRAL"
     "DE RISCO DO BANCO CENTRAL DO BRASIL." AT 55
     SKIP(2)
     "\033\105OBSERVACOES:\033\106"
     SKIP(1)
     WITH NO-BOX NO-LABELS WIDTH 96 FRAME f_autorizo.

FORM tt-proposta_bordero.dsobser1 AT 1 FORMAT "x(94)"
     SKIP                         
     tt-proposta_bordero.dsobser2 AT 1 FORMAT "x(94)"
     SKIP                         
     tt-proposta_bordero.dsobser3 AT 1 FORMAT "x(94)"
     SKIP                         
     tt-proposta_bordero.dsobser4 AT 1 FORMAT "x(94)"
     WITH NO-BOX NO-LABELS WIDTH 120 DOWN FRAME f_observac.

FORM "\033\105A P R O V A C A O\033\106"
     SKIP(2)
     "___________________________________________" AT  4
     "___________________________________________" AT 58 SKIP
     tt-proposta_bordero.nmprimtl AT 4 FORMAT "x(50)"
     "Operador:" AT 58 tt-proposta_bordero.nmoperad FORMAT "x(32)"
     SKIP(3)
     "___________________________________________" AT  4
     tt-proposta_bordero.nmcidade FORMAT "x(15)" AT 58 "," 
     tt-proposta_bordero.ddmvtolt FORMAT "99" "de" 
     tt-proposta_bordero.dsmesref FORMAT "x(9)"
     "de" tt-proposta_bordero.aamvtolt FORMAT "9999" SKIP
     rel_nmrescop[1] FORMAT "x(40)" AT 4 SKIP
     rel_nmrescop[2] FORMAT "x(40)" AT 4
     SKIP(4)
     "___________________________________________" AT 4
     "___________________________________________" AT 58 SKIP
     "Testemunha" AT 4
     "Testemunha" AT 58 SKIP
     WITH NO-BOX NO-LABELS WIDTH 100 FRAME f_aprovacao.
     
FORM SKIP(1)
     "RELACAO DE TITULOS NAO PAGOS POR PAGADOR:"
     SKIP(1)
     "Nome                                     Quantidade   Valor Total"
     SKIP(1)
     WITH NO-BOX WIDTH 132 FRAME f_cab_naopagos.
     
FORM SKIP(1)
     "RESTRICAO(OES) APROVADA(AS)"
     WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_descricao_coordenador.

FORM SKIP
     WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_restricao_coordenador.
     
FORM tt-sacado_nao_pagou.nmsacado  FORMAT "x(40)"
     tt-sacado_nao_pagou.qtdtitul  FORMAT "z,zz9"      AT 47  
     tt-sacado_nao_pagou.vlrtitul  FORMAT "zz,zz9.99"  AT 57
     WITH DOWN NO-BOX NO-LABEL WIDTH 132 FRAME f_naopagos.

FORM SKIP(5)
     WITH NO-BOX WIDTH 137 FRAME f_linhas.

EMPTY TEMP-TABLE tt-erro.

ASSIGN aux_dsdtraco = FILL("-",132).

FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

IF  NOT AVAILABLE crapcop  THEN
    DO:
        ASSIGN aux_cdcritic = 651
               aux_dscritic = "".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagecxa,
                       INPUT par_nrdcaixa,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
                                   
        IF  par_flgerlog  THEN
            RUN proc_gerar_log (INPUT par_cdcooper,
                                INPUT par_cdopecxa,
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

/* Adquire informaçoes sobre o Bordero */
FIND crapbdt WHERE crapbdt.cdcooper = par_cdcooper  AND 
                   crapbdt.nrdconta = par_nrdconta  AND 
                   crapbdt.nrborder = par_nrborder  
                   NO-LOCK NO-ERROR NO-WAIT.

IF  NOT AVAILABLE crapbdt THEN
    DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Nao foi possivel encontrar Bordero.".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagecxa,
                       INPUT par_nrdcaixa,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
                                   
        IF  par_flgerlog  THEN
            RUN proc_gerar_log (INPUT par_cdcooper,
                                INPUT par_cdopecxa,
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

/***  Buscar as informacoes para Impressao  ***/ 
RUN sistema/generico/procedures/b1wgen0030.p PERSISTENT SET h-b1wgen0030.

IF  NOT VALID-HANDLE(h-b1wgen0030)  THEN
    DO:
        MESSAGE "Handle Invalido para h-b1wgen0030".
        RETURN.
    END.
ELSE
    DO:
        RUN busca_dados_impressao_dsctit IN h-b1wgen0030(INPUT par_cdcooper,
                                                         INPUT par_cdagecxa,
                                                         INPUT par_nrdcaixa,
                                                         INPUT par_cdopecxa,
                                                         INPUT par_nmdatela,
                                                         INPUT par_idorigem,
                                                         INPUT par_nrdconta,
                                                         INPUT par_idseqttl,    
                                                         INPUT par_dtmvtolt,
                                                         INPUT par_dtmvtopr,
                                                         INPUT par_inproces,
                                                         INPUT par_idimpres,
                                                         INPUT crapbdt.nrctrlim,
                                                         INPUT par_nrborder,  /** Bordero **/
                                                         INPUT FALSE,
                                                         INPUT 2,            /* Bordero Tit. */
                                                         OUTPUT TABLE tt-erro,
                                                         OUTPUT TABLE tt-emprsts,
                                                         OUTPUT TABLE tt-proposta_limite,
                                                         OUTPUT TABLE tt-contrato_limite,        
                                                         OUTPUT TABLE tt-dados-avais,
                                                         OUTPUT TABLE tt-dados_nota_pro,
                                                         OUTPUT TABLE tt-proposta_bordero,
                                                         OUTPUT TABLE tt-dados_tits_bordero,
                                                         OUTPUT TABLE tt-tits_do_bordero,
                                                         OUTPUT TABLE tt-dsctit_bordero_restricoes,
                                                         OUTPUT TABLE tt-sacado_nao_pagou).

        DELETE PROCEDURE h-b1wgen0030.

        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
                IF  AVAILABLE tt-erro  THEN
                    ASSIGN aux_dscritic = tt-erro.dscritic.
                ELSE
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Nao foi possivel gerar a impressao.".
         
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagecxa,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,           /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
                    END.
         
                IF  par_flgerlog  THEN
                    RUN proc_gerar_log (INPUT par_cdcooper,
                                        INPUT par_cdopecxa,
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
    END.

ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + "/rl/" + par_dsiduser.

UNIX SILENT VALUE("rm " + aux_nmarquiv + "* 2>/dev/null").

ASSIGN aux_nmarquiv = aux_nmarquiv + STRING(TIME)
       aux_nmarqimp = aux_nmarquiv + ".ex"
       aux_nmarqpdf = aux_nmarquiv + ".pdf"
       rel_prtitpro = "  Percentual de Titulos Protestados:"
       rel_prtitcar = "  Qtd. de Titulos em Cartorio:".

FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND         
                   craptab.nmsistem = "CRED"         AND         
                   craptab.tptabela = "GENERI"       AND         
                   craptab.cdempres = 00             AND         
                   craptab.cdacesso = "DIGITALIZA"   AND
                   craptab.tpregist = 4    /* Contrato Desc. Tit. (GED) */
                   NO-LOCK NO-ERROR NO-WAIT.
        
IF  AVAIL craptab THEN
    ASSIGN aux_tpdocged = INT(ENTRY(3,craptab.dstextab,";")).

OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) APPEND PAGED PAGE-SIZE 87.

IF  par_idimpres = 5 THEN   /* COMPLETA */
    VIEW STREAM str_1 FRAME f_config.

IF  par_idimpres = 5 OR   /* COMPLETA */
    par_idimpres = 7 THEN /* TITULOS */
    DO:
        FIND FIRST tt-dados_tits_bordero NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE tt-dados_tits_bordero  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Nao foi possivel gerar a impressao.".
        
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagecxa,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                                           
                IF  par_flgerlog  THEN
                    RUN proc_gerar_log (INPUT par_cdcooper,
                                        INPUT par_cdopecxa,
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

        DISPLAY STREAM str_1 crapcop.nmextcop WITH FRAME f_coop.
          
        IF  crapbdt.insitbdt = 2 THEN /* Em analise */
            DISPLAY STREAM str_1 
                           tt-dados_tits_bordero.nrdconta                   
                           tt-dados_tits_bordero.nrborder
                           aux_tpdocged                   
                           WITH FRAME f_cab_analise.
        ELSE
            DISPLAY STREAM str_1 
                         tt-dados_tits_bordero.nrdconta
                         tt-dados_tits_bordero.nrborder
                         aux_tpdocged
                         WITH FRAME f_cab_bordero.
        
        DISPLAY STREAM str_1
                tt-dados_tits_bordero.nrdconta  tt-dados_tits_bordero.nmprimtl 
                tt-dados_tits_bordero.cdagenci  tt-dados_tits_bordero.nrborder
                tt-dados_tits_bordero.nrctrlim
                tt-dados_tits_bordero.vllimite
                tt-dados_tits_bordero.txdanual  tt-dados_tits_bordero.txmensal
                tt-dados_tits_bordero.txdiaria
                WITH FRAME f_identifica.

        FOR EACH tt-tits_do_bordero NO-LOCK           
                    BREAK BY tt-tits_do_bordero.flgregis DESC
                          BY tt-tits_do_bordero.nrinssac:
        
            IF FIRST-OF (tt-tits_do_bordero.flgregis) THEN
                IF tt-tits_do_bordero.flgregis = TRUE THEN
                    ASSIGN aux_extncont = 2.
                ELSE
                    ASSIGN aux_extncont = 1.
        
            ASSIGN rel_vltottit[aux_extncont] = rel_vltottit[aux_extncont] + tt-tits_do_bordero.vltitulo
                   rel_vltotliq[aux_extncont] = rel_vltotliq[aux_extncont] + tt-tits_do_bordero.vlliquid
                   rel_qttottit[aux_extncont] = rel_qttottit[aux_extncont] + 1.
        
            IF   tt-tits_do_bordero.dtlibbdt <> ?  THEN
                 ASSIGN rel_qtdprazo = tt-tits_do_bordero.dtvencto -
                                             tt-tits_do_bordero.dtlibbdt.
            ELSE
                 ASSIGN rel_qtdprazo = tt-tits_do_bordero.dtvencto -
                                       par_dtmvtolt.

            IF  LENGTH(STRING(tt-tits_do_bordero.nrinssac)) > 11   THEN
                ASSIGN rel_dscpfcgc = STRING(tt-tits_do_bordero.nrinssac,
                                               "99999999999999")
                       rel_dscpfcgc = STRING(rel_dscpfcgc,"xx.xxx.xxx/xxxx-xx").
            ELSE
                ASSIGN rel_dscpfcgc = STRING(tt-tits_do_bordero.nrinssac,
                                              "99999999999")
                       rel_dscpfcgc = STRING(rel_dscpfcgc,"xxx.xxx.xxx-xx").
          
            IF FIRST-OF (tt-tits_do_bordero.flgregis) THEN
               DO:
                   DISPLAY STREAM str_1 tt-tits_do_bordero.flgregis WITH FRAME f_tpcobran.
                   VIEW STREAM str_1 FRAME f_identifica_cab.
               END.
        
            DISPLAY STREAM str_1
                    tt-tits_do_bordero.dtvencto   tt-tits_do_bordero.nossonum
                    tt-tits_do_bordero.vltitulo   tt-tits_do_bordero.vlliquid
                    rel_qtdprazo                  tt-tits_do_bordero.nmsacado
                    rel_dscpfcgc
                    WITH FRAME f_titulos.
                 
            DOWN STREAM str_1 WITH FRAME f_titulos.
        
            IF   LINE-COUNTER(str_1) >  PAGE-SIZE(str_1)   THEN
                 DO:
                     PAGE STREAM str_1.
                     
                     DISPLAY STREAM str_1 crapcop.nmextcop WITH FRAME f_coop.
        
                     IF   crapbdt.insitbdt = 2 THEN /*Analise */
                          DISPLAY STREAM str_1 
                                         tt-dados_tits_bordero.nrdconta                   
                                         tt-dados_tits_bordero.nrborder   
                                         aux_tpdocged                   
                                         WITH FRAME f_cab_analise.
                     ELSE
                          DISPLAY STREAM str_1 
                                      tt-dados_tits_bordero.nrdconta
                                      tt-dados_tits_bordero.nrborder
                                      aux_tpdocged 
                                      WITH FRAME f_cab_bordero.
                          
                     DISPLAY STREAM str_1
                         tt-dados_tits_bordero.nrdconta tt-dados_tits_bordero.nmprimtl 
                         tt-dados_tits_bordero.cdagenci tt-dados_tits_bordero.nrborder
                         tt-dados_tits_bordero.nrctrlim 
                         tt-dados_tits_bordero.vllimite 
                         tt-dados_tits_bordero.txdanual tt-dados_tits_bordero.txmensal      
                         tt-dados_tits_bordero.txdiaria 
                         WITH FRAME f_identifica.
        
                     VIEW STREAM str_1 FRAME f_identifica_cab.
        
                 END.
            
            /*  Leitura das restricoes para o titulo  */
            FOR EACH tt-dsctit_bordero_restricoes  WHERE 
                     tt-dsctit_bordero_restricoes.nrdocmto =
                                        tt-tits_do_bordero.nrdocmto  NO-LOCK:

                /* Nao imprimir restriçoes referentes a 
                        titulos protestados ou em cartório */
                IF  tt-dsctit_bordero_restricoes.nrseqdig = 90 OR
                    tt-dsctit_bordero_restricoes.nrseqdig = 91 OR 
                    tt-dsctit_bordero_restricoes.nrseqdig = 11 THEN
                    NEXT.
            
                DISPLAY STREAM str_1 tt-dsctit_bordero_restricoes.dsrestri
                               WITH FRAME f_restricoes.
        
                DOWN STREAM str_1 WITH FRAME f_restricoes.

                ASSIGN rel_qtrestri[aux_extncont] = rel_qtrestri[aux_extncont] + 1.
                         
                IF   LINE-COUNTER(str_1) >  PAGE-SIZE(str_1)   THEN
                     DO:
                         PAGE STREAM str_1.
                     
                         DISPLAY STREAM str_1 crapcop.nmextcop WITH FRAME f_coop.
        
                              /* Em Analise */
                         IF   crapbdt.insitbdt = 2  THEN
                              DISPLAY STREAM str_1 
                                             tt-dados_tits_bordero.nrdconta                   
                                             tt-dados_tits_bordero.nrborder   
                                             aux_tpdocged                   
                                             WITH FRAME f_cab_analise.
                         ELSE
                              DISPLAY STREAM str_1 
                                             tt-dados_tits_bordero.nrdconta                   
                                             tt-dados_tits_bordero.nrborder   
                                             aux_tpdocged                   
                                             WITH FRAME f_cab_bordero.
        
                         DISPLAY STREAM str_1
                            tt-dados_tits_bordero.nrdconta    tt-dados_tits_bordero.nmprimtl 
                            tt-dados_tits_bordero.cdagenci    tt-dados_tits_bordero.nrborder
                            tt-dados_tits_bordero.nrctrlim
                            tt-dados_tits_bordero.vllimite
                            tt-dados_tits_bordero.txdanual    tt-dados_tits_bordero.txmensal
                            tt-dados_tits_bordero.txdiaria   
                            WITH FRAME f_identifica.
                            
                         VIEW STREAM str_1 FRAME f_identifica_cab.
                         
                     END.
         
            END.  /*  Fim do FOR EACH -- Leitura das restricoes  */
            
            DISPLAY STREAM str_1 aux_dsdtraco WITH FRAME f_traco.  
        
            IF  LINE-COUNTER(str_1) >  PAGE-SIZE(str_1)   THEN
                DO:
                    PAGE STREAM str_1.
                     
                    DISPLAY STREAM str_1 crapcop.nmextcop WITH FRAME f_coop.
                    
                    IF  crapbdt.insitbdt = 2 THEN /*Analise */
                        DISPLAY STREAM str_1 
                                         tt-dados_tits_bordero.nrdconta                   
                                         tt-dados_tits_bordero.nrborder   
                                         aux_tpdocged                   
                                         WITH FRAME f_cab_analise.
                    ELSE
                         DISPLAY STREAM str_1 
                                         tt-dados_tits_bordero.nrdconta                   
                                         tt-dados_tits_bordero.nrborder   
                                         aux_tpdocged                   
                                         WITH FRAME f_cab_bordero.
                    
                    DISPLAY STREAM str_1
                        tt-dados_tits_bordero.nrdconta  tt-dados_tits_bordero.nmprimtl 
                        tt-dados_tits_bordero.cdagenci  tt-dados_tits_bordero.nrborder
                        tt-dados_tits_bordero.nrctrlim  
                        tt-dados_tits_bordero.vllimite  
                        tt-dados_tits_bordero.txdanual  tt-dados_tits_bordero.txmensal
                        tt-dados_tits_bordero.txdiaria  
                        WITH FRAME f_identifica.
                        
                    VIEW STREAM str_1 FRAME f_identifica_cab.
                                            
                 END.
        
            IF LAST-OF (tt-tits_do_bordero.flgregis) THEN
                DO:
                    ASSIGN rel_vlmedtit[aux_extncont] = ROUND(rel_vltottit[aux_extncont] 
                                                                         / rel_qttottit[aux_extncont],2).
        
                    IF (aux_extncont = 1) THEN
                        DISPLAY STREAM str_1 rel_qttottit[aux_extncont]  rel_qtrestri[aux_extncont]
                                             rel_vltottit[aux_extncont]  rel_vltotliq[aux_extncont]
                                             rel_vlmedtit[aux_extncont]
                                             WITH FRAME f_total_sr.
        
                    IF (aux_extncont = 2) THEN
                        DISPLAY STREAM str_1 rel_qttottit[aux_extncont]  rel_qtrestri[aux_extncont]
                                             rel_vltottit[aux_extncont]  rel_vltotliq[aux_extncont]
                                             rel_vlmedtit[aux_extncont]
                                             WITH FRAME f_total_cr.
                END.
        
        END.  /*  Fim do FOR EACH  */
        
        IF  rel_qttottit[1] > 0 AND
            rel_qttottit[2] > 0 THEN
            DO:
                ASSIGN rel_qttottit[3] = rel_qttottit[1] + rel_qttottit[2]
                       rel_qtrestri[3] = rel_qtrestri[1] + rel_qtrestri[2]
                       rel_vltottit[3] = rel_vltottit[1] + rel_vltottit[2]
                       rel_vltotliq[3] = rel_vltotliq[1] + rel_vltotliq[2]
                       rel_vlmedtit[3] = ROUND(rel_vltottit[3] 
                                                             / rel_qttottit[3],2).
          
                DISPLAY STREAM str_1 rel_qttottit[3]  rel_qtrestri[3]
                                     rel_vltottit[3]  rel_vltotliq[3]
                                     rel_vlmedtit[3]
                                     WITH FRAME f_total.
            END. 

        IF  LINE-COUNTER(str_1) >  PAGE-SIZE(str_1) - 2 THEN
            DO:
                PAGE STREAM str_1.
                  
                DISPLAY STREAM str_1 crapcop.nmextcop WITH FRAME f_coop.
            
                IF   crapbdt.insitbdt = 2 THEN /* Em analise */
                     DISPLAY STREAM str_1 
                                    tt-dados_tits_bordero.nrdconta                   
                                    tt-dados_tits_bordero.nrborder   
                                    aux_tpdocged                   
                                    WITH FRAME f_cab_analise.
                ELSE
                     DISPLAY STREAM str_1 
                                   tt-dados_tits_bordero.nrdconta                   
                                   tt-dados_tits_bordero.nrborder   
                                   aux_tpdocged                   
                                   WITH FRAME f_cab_bordero.
            
                DISPLAY STREAM str_1
                        tt-dados_tits_bordero.nrdconta  tt-dados_tits_bordero.nmprimtl 
                        tt-dados_tits_bordero.cdagenci  tt-dados_tits_bordero.nrborder
                        tt-dados_tits_bordero.nrctrlim  
                        tt-dados_tits_bordero.vllimite  
                        tt-dados_tits_bordero.txdanual  tt-dados_tits_bordero.txmensal
                        tt-dados_tits_bordero.txdiaria  
                        WITH FRAME f_identifica.
                        
            END.

        /* Verifica se tem operador coordenador de liberacao ou analise */
        IF crapbdt.cdopcolb <> " " THEN
        DO:
           ASSIGN aux_cdopecoo = crapbdt.cdopcolb.
        END.
        ELSE
        DO:
           IF crapbdt.cdopcoan <> " " THEN
           DO:
              ASSIGN aux_cdopecoo = crapbdt.cdopcoan.
           END.
        END.

        IF  aux_cdopecoo <> ""  THEN
            DO:
                FIND crapope WHERE crapope.cdcooper = par_cdcooper  AND
                                   crapope.cdoperad = aux_cdopecoo  NO-LOCK NO-ERROR.
                IF  AVAILABLE crapope  THEN
                    ASSIGN aux_dsopecoo = aux_cdopecoo + " - " + crapope.nmoperad.

                DISPLAY STREAM str_1 aux_dsopecoo
                                     WITH FRAME f_descricao_coordenador.

                /* Restricoes liberadas/analisadas pelo coordenador */
                FOR EACH tt-dsctit_bordero_restricoes 
                   WHERE tt-dsctit_bordero_restricoes.flaprcoo = TRUE 
                         BREAK BY tt-dsctit_bordero_restricoes.dsrestri:
                    
                    IF FIRST-OF(tt-dsctit_bordero_restricoes.dsrestri) THEN
                       DO:
                           DISPLAY STREAM str_1 tt-dsctit_bordero_restricoes.dsrestri FORMAT "x(132)"
                                                WITH FRAME f_restricao_coordenador.
                                                
                           DOWN STREAM str_1 WITH FRAME f_restricao_coordenador.
                       END.
                END.
                DISPLAY STREAM str_1 WITH FRAME f_restricao_coordenador.
            END.
        
        IF  CAN-FIND (FIRST tt-sacado_nao_pagou NO-LOCK) THEN
            DO:
                VIEW STREAM str_1 FRAME f_cab_naopagos.
                  
                FOR EACH tt-sacado_nao_pagou NO-LOCK BY tt-sacado_nao_pagou.nmsacado:
                  
                    DISPLAY STREAM str_1 tt-sacado_nao_pagou.nmsacado 
                                         tt-sacado_nao_pagou.qtdtitul
                                         tt-sacado_nao_pagou.vlrtitul  
                                         WITH FRAME f_naopagos.
                                  
                    DOWN STREAM str_1 WITH FRAME f_naopagos.
                END.          
            END.
        
        IF  LINE-COUNTER(str_1) >  PAGE-SIZE(str_1) - 17   THEN
            DO: 
                PAGE STREAM str_1.
                 
                DISPLAY STREAM str_1 crapcop.nmextcop WITH FRAME f_coop.
               
                IF  crapbdt.insitbdt = 2  THEN /* Em analise */
                    DISPLAY STREAM str_1 
                                    tt-dados_tits_bordero.nrdconta
                                    tt-dados_tits_bordero.nrborder
                                    aux_tpdocged
                                    WITH FRAME f_cab_analise.
                ELSE
                    DISPLAY STREAM str_1 
                                tt-dados_tits_bordero.nrdconta
                                tt-dados_tits_bordero.nrborder
                                aux_tpdocged
                                WITH FRAME f_cab_bordero.
               
                DISPLAY STREAM str_1
                        tt-dados_tits_bordero.nrdconta  tt-dados_tits_bordero.nmprimtl 
                        tt-dados_tits_bordero.cdagenci  tt-dados_tits_bordero.nrborder
                        tt-dados_tits_bordero.nrctrlim  
                        tt-dados_tits_bordero.vllimite  
                        tt-dados_tits_bordero.txdanual  tt-dados_tits_bordero.txmensal
                        tt-dados_tits_bordero.txdiaria  
                        WITH FRAME f_identifica.            
            END.
            
        DISPLAY STREAM str_1 tt-dados_tits_bordero.nmoperad  tt-dados_tits_bordero.ddmvtolt
                             tt-dados_tits_bordero.dsmesref  tt-dados_tits_bordero.aamvtolt
                             tt-dados_tits_bordero.nmprimtl
                             tt-dados_tits_bordero.nmresco1
                             tt-dados_tits_bordero.nmresco2
                             tt-dados_tits_bordero.nmcidade
                             WITH FRAME f_final.
        
    END.  /* COMPLETA e TITULOS */

IF  par_idimpres = 5 OR   /* COMPLETA */
    par_idimpres = 6 THEN /*PROPOSTA */
    DO:
        FIND FIRST tt-proposta_bordero NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE tt-proposta_bordero THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Nao foi possivel gerar a impressao.".
        
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagecxa,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
        
                IF  par_flgerlog  THEN
                    RUN proc_gerar_log (INPUT par_cdcooper,
                                        INPUT par_cdopecxa,
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
        
        PAGE STREAM str_1.
                          
        PUT STREAM str_1 CONTROL "\0330\033x0\022\033\115" NULL.
        
        ASSIGN rel_numconta = tt-proposta_bordero.nrdconta.

        RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT
                    SET h-b1wgen9999.
            
        IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
            DO:
                ASSIGN aux_dscritic = "Handle invalido para BO " +
                                      "b1wgen9999.".
                LEAVE.
            END.

        RUN divide-nome-coop IN h-b1wgen9999 (INPUT crapcop.nmextcop,
                                              OUTPUT rel_nmrescop[1],
                                              OUTPUT rel_nmrescop[2]).

        DELETE PROCEDURE h-b1wgen9999.

        DISPLAY STREAM str_1
                tt-proposta_bordero.nrdconta      tt-proposta_bordero.nrmatric  
                tt-proposta_bordero.dsagenci
                tt-proposta_bordero.nmprimtl      tt-proposta_bordero.dtadmemp  
                tt-proposta_bordero.nmempres
                "" @ tt-proposta_bordero.nmdsecao tt-proposta_bordero.telefone
                tt-proposta_bordero.dstipcta      tt-proposta_bordero.dssitdct  
                tt-proposta_bordero.dtadmiss
                tt-proposta_bordero.nmextcop      tt-proposta_bordero.dsramati
                tt-proposta_bordero.nrborder      FORMAT "z,zzz,zz9"
                rel_numconta                      FORMAT "zzzz,zzz,9"
                aux_tpdocged                      FORMAT "zz9"
                WITH FRAME f_pro_dados.

        IF  tt-proposta_bordero.tpcobran = "SEM REGISTRO" THEN
            ASSIGN rel_prtitpro = ""
                   rel_prtitcar = "".

        DISPLAY STREAM str_1
                tt-proposta_bordero.vlsmdtri tt-proposta_bordero.vlcaptal tt-proposta_bordero.vlprepla
                tt-proposta_bordero.vlsalari tt-proposta_bordero.vlsalcon tt-proposta_bordero.vloutras
                tt-proposta_bordero.vllimcre tt-proposta_bordero.vltotccr tt-proposta_bordero.vlaplica 
                tt-proposta_bordero.vllimpro tt-proposta_bordero.vllimchq tt-proposta_bordero.qtdbolet     
                tt-proposta_bordero.vlmedbol WHEN tt-proposta_bordero.vlmedbol <> ?
                tt-proposta_bordero.vlmeddsc WHEN tt-proposta_bordero.vlmeddsc <> ?
                tt-proposta_bordero.nrmespsq tt-proposta_bordero.qttitsac
                tt-proposta_bordero.perceden tt-proposta_bordero.dsdeben1 tt-proposta_bordero.dsdeben2
                tt-proposta_bordero.vlfatura tt-proposta_bordero.vltottit
                tt-proposta_bordero.qttottit tt-proposta_bordero.tpcobran
                tt-proposta_bordero.prtitpro WHEN tt-proposta_bordero.tpcobran <> "SEM REGISTRO"
                tt-proposta_bordero.prtitcar WHEN tt-proposta_bordero.tpcobran <> "SEM REGISTRO"
                rel_prtitpro                 rel_prtitcar
                WITH FRAME f_pro_rec.
        
        IF  CAN-FIND (FIRST tt-emprsts WHERE (tt-emprsts.vlsdeved > 0)) THEN
            DO:
                DISPLAY STREAM str_1  tt-proposta_bordero.dtcalcul 
                                      tt-proposta_bordero.vlslddsc
                                      tt-proposta_bordero.qtdscsld
                                      tt-proposta_bordero.vlmaxdsc
                                      tt-proposta_bordero.valormed
                                      WITH FRAME f_pro_ed1.
        
                FOR EACH tt-emprsts WHERE (tt-emprsts.vlsdeved > 0) NO-LOCK:

                    DISPLAY STREAM str_1
                           tt-emprsts.nrctremp  tt-emprsts.vlsdeved  tt-emprsts.dspreapg
                           tt-emprsts.vlpreemp  tt-emprsts.dslcremp
                           tt-emprsts.dsfinemp 
                           WITH FRAME f_dividas.
      
                    DOWN STREAM str_1 WITH FRAME f_dividas.
      
                END.  /*  Fim do FOR EACH - Leitura da divida anterior  */
      
                DISPLAY STREAM str_1
                       tt-proposta_bordero.vlsdeved  tt-proposta_bordero.vlpreemp
                       WITH FRAME f_tot_div.
            END.
        ELSE
            VIEW STREAM str_1 FRAME f_sem_divida.
        
        VIEW STREAM str_1 FRAME f_autorizo.
        
        DISPLAY STREAM str_1 tt-proposta_bordero.dsobser1
                             tt-proposta_bordero.dsobser2
                             tt-proposta_bordero.dsobser3 
                             tt-proposta_bordero.dsobser4
                             WITH FRAME f_observac.
                        
        DOWN STREAM str_1 WITH FRAME f_observac.

        IF  LINE-COUNTER(str_1) + 12 > PAGE-SIZE(str_1)  THEN
            PAGE STREAM str_1.

        DISPLAY STREAM str_1 tt-proposta_bordero.nmprimtl
                             tt-proposta_bordero.nmoperad
                             tt-proposta_bordero.ddmvtolt
                             tt-proposta_bordero.dsmesref
                             tt-proposta_bordero.aamvtolt 
                             tt-proposta_bordero.nmcidade
                             rel_nmrescop[1]
                             rel_nmrescop[2] 
                             WITH FRAME f_aprovacao.

        VIEW STREAM str_1 FRAME f_config.

    END. /* COMPLETA e PROPOSTA */

    OUTPUT STREAM str_1 CLOSE.

    IF  par_idorigem = 5  THEN  /** Ayllos Web **/
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "".

            DO WHILE TRUE:

                RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
                    SET h-b1wgen0024.
            
                IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                    DO:
                        ASSIGN aux_dscritic = "Handle invalido para BO " +
                                              "b1wgen0024.".
                        LEAVE.
                    END.

                RUN gera-pdf-impressao IN h-b1wgen0024 (INPUT aux_nmarqimp,
                                                        INPUT aux_nmarqpdf).
                
                /** Copiar pdf para visualizacao no Ayllos WEB **/
                IF  par_idorigem = 5  THEN
                    DO:
                        IF  SEARCH(aux_nmarqpdf) = ?  THEN
                            DO:
                                ASSIGN aux_dscritic = "Nao foi possivel gerar" +
                                                      " a impressao.".
                                LEAVE.                      
                            END.
                            
                        UNIX SILENT VALUE ('sudo /usr/bin/su - scpuser -c ' +
                           '"scp ' + aux_nmarqpdf + ' scpuser@' + aux_srvintra +
                           ':/var/www/ayllos/documentos/' + crapcop.dsdircop +
                           '/temp/" 2>/dev/null').
                    END.
    
                LEAVE.

            END. /** Fim do DO WHILE TRUE **/

            IF  VALID-HANDLE(h-b1wgen0024)  THEN
                DELETE PROCEDURE h-b1wgen0024.
    
            IF  aux_dscritic <> ""  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.

                    IF  NOT AVAILABLE tt-erro  THEN
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagecxa,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,            /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
                                               
                    IF  par_flgerlog  THEN
                        RUN proc_gerar_log (INPUT par_cdcooper,
                                            INPUT par_cdopecxa,
                                            INPUT aux_dscritic,
                                            INPUT aux_dsorigem,
                                            INPUT aux_dstransa,
                                            INPUT FALSE,
                                            INPUT par_idseqttl,
                                            INPUT par_nmdatela,
                                            INPUT par_nrdconta,
                                           OUTPUT aux_nrdrowid). 
                        
                    UNIX SILENT VALUE ("rm " + aux_nmarquiv + "* 2>/dev/null").

                    RETURN "NOK".

                END.

            IF  par_idorigem = 5  THEN
                UNIX SILENT VALUE ("rm " + aux_nmarquiv + "* 2>/dev/null").
            ELSE
                UNIX SILENT VALUE ("rm " + aux_nmarqpdf + " 2>/dev/null").
        END.
                                                      
    ASSIGN par_nmarqimp = aux_nmarqimp
           par_nmarqpdf = ENTRY(NUM-ENTRIES(aux_nmarqpdf,"/"),aux_nmarqpdf,"/").

    IF  par_flgerlog  THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdopecxa,
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

/******************************************************************************/
/**           Procedure para gerar impressoes do limite de credito           **/
/******************************************************************************/
PROCEDURE gera-impressao-limite:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagecxa AS INTE  /** PAC Operador   **/   NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE  /** Nr. Caixa      **/   NO-UNDO.
    DEF  INPUT PARAM par_cdopecxa AS CHAR  /** Operador Caixa **/   NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idimpres AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrlim AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgemail AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nmarquiv AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmarqimp AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmarqpdf AS CHAR                                    NO-UNDO.
    DEF VAR rel_tpcobran AS CHAR                                    NO-UNDO.
    DEF VAR aux_tpcobran AS CHAR                                    NO-UNDO.
    DEF VAR rel_nrdconta AS INT                                     NO-UNDO.
    DEF VAR aux_nrdgrupo AS INT                                     NO-UNDO.
    DEF VAR aux_tpdocged AS INT                                     NO-UNDO.
    DEF VAR aux_gergrupo AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdrisgp AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdrisco AS CHAR                                    NO-UNDO.
    DEF VAR aux_vlendivi AS DEC                                     NO-UNDO.
    DEF VAR aux_nmdoarqv AS CHAR                                    NO-UNDO.
    DEF VAR aux_flgcriti AS LOG INIT FALSE                          NO-UNDO.
    DEF VAR aux_txcetmes AS DECI                                    NO-UNDO.
    DEF VAR aux_txcetano AS DECI                                    NO-UNDO.
    DEF VAR aux_dscetan1 AS CHAR                                    NO-UNDO.
    DEF VAR aux_dscetan2 AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrcpfcgc AS CHAR                                    NO-UNDO.

    DEF VAR h-b1wgen0024 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0043 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0138 AS HANDLE                                  NO-UNDO.
    DEF VAR aux_nrctrrat AS DECI                                    NO-UNDO.

    /** FORM's para proposta de limite de desconto de titulos **/
    FORM tt-proposta_limite.nmextcop FORMAT "x(50)"
         SKIP(1)
         "\033\016PROPOSTA DE LIMITE DE DESCONTO DE TITULOS\024"
        "PARA USO DA DIGITALIZACAO" AT 65
         SKIP(1)
         rel_nrdconta                FORMAT "zzzz,zzz,9" AT 65
         tt-proposta_limite.nrctrlim FORMAT "z,zzz,zz9"  AT 78
         aux_tpdocged                FORMAT "zz9"        AT 90
         SKIP(1)
         "\033\105\DADOS DO ASSOCIADO\033\106"
         SKIP(1)
         "Conta/dv:\033\016" tt-proposta_limite.nrdconta FORMAT "zzzz,zzz,9" "\024"
         "Matricula:"  AT 34 tt-proposta_limite.nrmatric FORMAT "zzz,zz9"
         "PA:"     AT 64 tt-proposta_limite.dsagenci FORMAT "x(25)"
         SKIP(1)       
         "Nome    :"         tt-proposta_limite.nmprimtl FORMAT "x(50)"
         "Adm COOP:"   AT 76 tt-proposta_limite.dtadmiss FORMAT "99/99/9999"
         SKIP          
         "CPF/CNPJ:"         tt-proposta_limite.nrcpfcgc FORMAT "x(18)" 
         SKIP(1)       
         "Empresa :"         tt-proposta_limite.nmempres FORMAT "x(35)"
         "Secao:"      AT 47 tt-proposta_limite.nmdsecao FORMAT "x(20)"
         "Adm empr:"   AT 76 tt-proposta_limite.dtadmemp FORMAT "99/99/9999"
         SKIP(1)
         "Fone/Ramal:" AT 42 tt-proposta_limite.telefone FORMAT "x(20)"
         SKIP(1)
         "Tipo de Conta:"           tt-proposta_limite.dstipcta FORMAT "x(25)"
         "Situacao da Conta:" AT 67 tt-proposta_limite.dssitdct FORMAT "x(10)"
         SKIP(1)
         "Ramo de Atividade:"       tt-proposta_limite.dsramati FORMAT "x(40)"
         SKIP(1)
         WITH NO-BOX NO-LABELS WIDTH 96 FRAME f_pro_dados.

    FORM "\033\105RECIPROCIDADE\033\106"
         "Saldo Medio do Trimestre:" AT 20 tt-proposta_limite.vlsmdtri FORMAT "zzz,zzz,zz9.99"
         "Capital:"                  AT 77 tt-proposta_limite.vlcaptal FORMAT "zzz,zzz,zz9.99-"
         SKIP(1)
         "Plano:"                          tt-proposta_limite.vlprepla FORMAT "zzz,zzz,zz9.99"
         "Aplicacoes:"               AT 70 tt-proposta_limite.vlaplica FORMAT "zzz,zzz,zz9.99"
         SKIP(1)
         "\033\105RENDA MENSAL\033\106"
         "Salario:"                  AT 31 tt-proposta_limite.vlsalari FORMAT "zzz,zzz,zz9.99"
         "Salario do Conjuge:"       AT 66 tt-proposta_limite.vlsalcon FORMAT "zzz,zzz,zz9.99" 
         SKIP
         "Faturamento Mensal:"       AT 16 tt-proposta_limite.vlfatura FORMAT "zzz,zzz,zz9.99"
         "Outras:"                   AT 74 tt-proposta_limite.vloutras FORMAT "zzz,zzz,zz9.99"
         SKIP(1)
         "\033\105LIMITES\033\106"
         "Cheque Especial:"          AT 20 tt-proposta_limite.vllimcre FORMAT "zzz,zzz,zz9.99"
         "Cartoes de Credito:"       AT 66 tt-proposta_limite.vltotccr FORMAT "zzz,zzz,zz9.99"
         SKIP
         "Desconto de Cheques:"      AT 12 tt-proposta_limite.vllimchq FORMAT "zzz,zzz,zz9.99"
         SKIP(1)
         "\033\105BENS:\033\106"
         tt-proposta_limite.dsdeben1 AT 13 FORMAT "x(60)" SKIP
         tt-proposta_limite.dsdeben2 AT 09 FORMAT "x(60)"
         SKIP(1)
         "\033\105TIPO DE COBRANCA:\033\106" AT 01 rel_tpcobran FORMAT "X(25)"
         SKIP(1)
         "\033\105LIMITE PROPOSTO\033\106"
         SKIP
         "    Contrato           Valor   Linha de desconto"
         "Valor Medio dos Titulos" AT 64
         SKIP(1)
         WITH NO-BOX NO-LABELS WIDTH 130 FRAME f_pro_rec.

    FORM tt-proposta_limite.nrctrlim FORMAT "z,zzz,zz9" AT 4
         tt-proposta_limite.vllimpro FORMAT "zzzz,zzz,zz9.99" " "
         tt-proposta_limite.dsdlinha FORMAT "x(40)"   
         tt-proposta_limite.vlmedtit FORMAT "zzz,zzz,zz9.99"
         WITH NO-BOX NO-LABELS WIDTH 130 DOWN FRAME f_lim_pro.

    FORM SKIP(2)
         "\033\105ENDIVIDAMENTO NA COOPERATIVA DE CREDITO EM"
         tt-proposta_limite.dtcalcul FORMAT "99/99/9999" "\033\106"     
         SKIP(1)
         " Contrato  Saldo Devedor Prestacoes"
         "Linha de Credito  Finalidade" AT 51
         SKIP(1)
         WITH NO-BOX NO-LABELS WIDTH 96 FRAME f_pro_ed1.

    FORM tt-emprsts.nrctremp FORMAT "zz,zzz,zz9"     AT 01
         tt-emprsts.vlsdeved FORMAT "zzz,zzz,zz9.99" AT 12
         tt-emprsts.dspreapg FORMAT "x(11)"          AT 27
         tt-emprsts.vlpreemp FORMAT "zzzz,zz9.99"    AT 39
         "\033\017"
         tt-emprsts.dslcremp FORMAT "x(30)"
         tt-emprsts.dsfinemp FORMAT "x(28)"
         "\022\033\115"
         WITH NO-BOX NO-LABELS DOWN WIDTH 120 FRAME f_dividas.

    FORM "--------------            ------------" AT 11
         SKIP
         tt-proposta_limite.vlsdeved AT 11 FORMAT "zzz,zzz,zz9.99"
         tt-proposta_limite.vlpreemp AT 37 FORMAT "zzzzz,zz9.99"
         SKIP(1)
         WITH NO-BOX NO-LABELS WIDTH 96 FRAME f_tot_div.

    FORM SKIP(1)
         "\033\105SEM ENDIVIDAMENTO NA COOPERATIVA DE CREDITO\033\106" SKIP(2)
         WITH NO-BOX WIDTH 96 FRAME f_sem_divida.

    FORM SKIP
         "\033\105TOTAL OP.CREDITO:\033\106"
         tt-proposta_limite.vlutiliz FORMAT "zzz,zzz,zz9.99"
         SKIP(1)
         "AUTORIZO A CONSULTA DE MINHAS INFORMACOES CADASTRAIS"
         "NOS SERVICOS DE PROTECAO AO CREDITO" AT 54 
         "(SPC, SERASA, CADIN, ...) ALEM DO CADASTRO DA CENTRAL"
         "DE RISCO DO BANCO CENTRAL DO BRASIL." AT 55
         SKIP(2)
         "\033\105OBSERVACOES:\033\106"
         SKIP(1)
         WITH NO-BOX NO-LABELS WIDTH 96 FRAME f_autorizo.

    FORM tt-proposta_limite.dsobser1 AT 01 FORMAT "x(94)"
         SKIP
         tt-proposta_limite.dsobser2 AT 01 FORMAT "x(94)"
         SKIP
         tt-proposta_limite.dsobser3 AT 01 FORMAT "x(94)"
         SKIP
         tt-proposta_limite.dsobser4 AT 01 FORMAT "x(94)"
         WITH NO-BOX NO-LABELS WIDTH 120 DOWN FRAME f_observac.

    FORM SKIP(1)
         "CONSULTADO  SPC  EM ____/____/________"
         SKIP(1)
         "CENTRAL DE RISCO EM ____/____/________"
         "SITUACAO: _______________ VISTO: _______________" AT 45
         SKIP(1)
         "\033\105A P R O V A C A O\033\106"
         SKIP(3)
         "___________________________________________" AT 04
         "______________________________________"      AT 55 SKIP
         tt-proposta_limite.nmprimtl AT 04 FORMAT "x(50)"
         "Operador:" AT 55 tt-proposta_limite.nmoperad FORMAT "x(30)"
         SKIP(3)
         "___________________________________________" AT 04
         tt-proposta_limite.nmcidade FORMAT "x(15)"  "," 
         tt-proposta_limite.ddmvtolt FORMAT "99" "de" 
         tt-proposta_limite.dsmesref FORMAT "x(9)" "de"
         tt-proposta_limite.aamvtolt FORMAT "9999" SKIP
         tt-proposta_limite.nmresco1 FORMAT "x(40)" AT 04 SKIP
         tt-proposta_limite.nmresco2 FORMAT "x(40)" AT 04
         WITH NO-BOX NO-LABELS WIDTH 96 FRAME f_aprovacao.

    FORM SKIP(2)
         "Risco da Proposta:"                                    AT 01
         SKIP(1)
         tt-ratings.dsdopera LABEL "Operacao" FORMAT "x(15)"     AT 01
         tt-ratings.nrctrrat LABEL "Contrato" FORMAT "z,zzz,zz9" AT 26
         tt-ratings.indrisco LABEL "Risco"    FORMAT "x(2)"      AT 49
         tt-ratings.nrnotrat LABEL "Nota"     FORMAT "zz9.99"    AT 61
         tt-ratings.dsdrisco NO-LABEL         FORMAT "x(20)"     AT 76
         WITH SIDE-LABEL WIDTH 120 FRAME f_rating_atual.
    
    FORM "Historico dos Ratings" AT 01
         WITH FRAME f_historico_rating_1.   
                                                                                   
    FORM tt-ratings.dsdopera LABEL "Operacao"       FORMAT "x(18)"   AT 01       
         tt-ratings.nrctrrat LABEL "Contrato"       FORMAT "z,zzz,zz9"        
         tt-ratings.indrisco LABEL "Risco"          FORMAT "x(2)"           
         tt-ratings.nrnotrat LABEL "Nota"           FORMAT "zz9.99"         
         tt-ratings.vloperac LABEL "Valor Operacao" FORMAT "zzz,zzz,zz9.99"   
         tt-ratings.dsditrat LABEL "Situacao"       FORMAT "x(15)"
         WITH DOWN WIDTH 120 FRAME f_historico_rating_2.

    /** FORM's para contrato de limite de desconto de titulos **/
    FORM "\022\024\033\115\0330\033x0" WITH NO-BOX NO-LABELS FRAME f_config.
    
    FORM "PARA USO DA DIGITALIZACAO"                                  AT   74
         SKIP         
         "\033\016CONTRATO DE DESCONTO DE TITULOS\024\033\106"  AT 4
         "\033\105No:" tt-contrato_limite.nrctrlim FORMAT "z,zzz,zz9" "\033\106"
         tt-contrato_limite.nrdconta     NO-LABEL FORMAT "zzzz,zzz,9" AT   59
         aux_nrctrrat                    NO-LABEL FORMAT "z,zzz,zz9"  AT   74
         aux_tpdocged                    NO-LABEL FORMAT "zz9"        AT   86
         SKIP(1)
         "\033\016FOLHA DE ROSTO\024\033\106" AT 29
         SKIP(1)
         WITH COLUMN 10 NO-BOX NO-LABELS WIDTH 137 FRAME f_cooperativa.

    FORM "\033\1051. DA IDENTIFICACAO:\033\106"
         SKIP(1)
         "\033\1051.1 COOPERATIVA:\033\106"
         tt-contrato_limite.nmextcop FORMAT "x(50)" 
         "    -      PA:" tt-contrato_limite.cdagenci FORMAT "999"
         SKIP 
         tt-contrato_limite.dslinha1 FORMAT "x(69)" AT 18 SKIP
         tt-contrato_limite.dslinha2 FORMAT "x(69)" AT 18 SKIP
         tt-contrato_limite.dslinha3 FORMAT "x(69)" AT 18 SKIP
         tt-contrato_limite.dslinha4 FORMAT "x(69)" AT 18 SKIP     
         "\033\1051.2 COOPERADO(A):\033\106"
         tt-contrato_limite.nmprimt1 FORMAT "x(39)" 
         ", CONTA CORRENTE:"
         tt-contrato_limite.nrdconta FORMAT "zzzz,zzz,9"
         SKIP
         "CPF/CNPJ:" AT 19 tt-contrato_limite.nrcpfcgc FORMAT "x(18)" 
         tt-contrato_limite.txnrdcid FORMAT "x(25)" AT 55
         SKIP(1)
         "\033\1052. DO VALOR DO LIMITE DE DESCONTO:\033\106"
         SKIP(1)
         "2.1. Valor:" tt-contrato_limite.dsdmoeda FORMAT "x(4)"
         tt-contrato_limite.vllimite FORMAT "zz,zzz,zz9.99"
         tt-contrato_limite.dslimit1 FORMAT "x(55)"
         SKIP
         tt-contrato_limite.dslimit2 AT 13 FORMAT "x(74)"
         SKIP(1)
         "\033\1053. DA LINHA DE DESCONTO DE TITULOS:\033\106"
         SKIP(1)
         "3.1. Linha de Desconto:"
         tt-contrato_limite.dsdlinha FORMAT "x(35)" 
         SKIP(1)
         "\033\1054. DO PRAZO DE VIGENCIA DO CONTRATO:\033\106"
         SKIP(1)
         "4.1. Prazo de vigencia do contrato:" tt-contrato_limite.qtdiavig 
         tt-contrato_limite.txqtdvi1 FORMAT "x(36)"
         SKIP(1)
         "\033\1055. DOS ENCARGOS FINANCEIROS:\033\106"
         SKIP(1)
         "5.1. Juros de Mora:\033\105" tt-contrato_limite.dsjurmo1 FORMAT "x(66)" "\033\106"
         SKIP
         "\033\105" tt-contrato_limite.dsjurmo2 FORMAT "x(66)" AT 8 "\033\106"
         SKIP(1)
         "5.2. Multa por inadimplencia:"
         "\033\105" tt-contrato_limite.txdmulta FORMAT "x(11)%"  
         tt-contrato_limite.txmulex1 FORMAT "x(40)" "\033\106"
         SKIP
         "\033\105" tt-contrato_limite.txmulex2 FORMAT "x(50)" AT 31 "\033\106"
         SKIP
         "5.3. Custo Efetivo Total (CET) da operacao:\033\105" aux_dscetan1 FORMAT "x(80)"
         SKIP 
         "    " aux_dscetan2 FORMAT "x(80)" 
         SKIP 
         "     conforme planilha demonstrativa de calculo."
         SKIP(1)
         "5.4. Os encargos  de desconto  serao apurados  na forma do estabelecimento  no  item 4"     
         SKIP
         "     (quatro) das CONDICOES GERAIS."
         SKIP(1)
         "\033\1056. DA DECLARACAO INERENTE A FOLHA DE ROSTO:\033\106"
         SKIP(1)
         "   O(A) COOPERADO(A)  declara  ter  ciencia  dos  encargos  e  despesas  incluidos  na"
         SKIP
         "   operacao que integram o CET, expresso na forma  de taxa percentual  anual  indicada"
         SKIP
         "   no item 5.3.  da  presente Folha de Rosto e  item 4.1. da planilha demonstrativa de" 
         SKIP
         "   calculo, recebida no momento da contratacao."
         SKIP(1)
         "   Declaram as partes, abaixo assinadas, que a presente Folha de Rosto"
         "e' parte  inte-" SKIP
         "   grante das CONDICOES GERAIS do Contrato de  Desconto  de  Titulos"
         " cujas  condicoes" SKIP
         "   aceitam, outorgam e prometem cumprir."
         SKIP(1)
         tt-contrato_limite.nmcidade FORMAT "x(40)"
         WITH COLUMN 10 NO-BOX NO-LABELS WIDTH 137 FRAME f_introducao.

    FORM SKIP(3)
         "----------------------------------------"
         "--------------------------------" AT 54 
         SKIP
         tt-contrato_limite.nmprimt2 FORMAT "x(50)"
         tt-contrato_limite.nmresco1 FORMAT "x(32)" AT 52
         tt-contrato_limite.nmresco2 FORMAT "x(32)" AT 52
         SKIP(2)
         "----------------------------------------"
         "----------------------------------------" AT 46
         SKIP
         "Fiador 1:"
         "Conjuge Fiador 1:" AT 46
         SKIP
         tt-contrato_limite.nmdaval1 FORMAT "x(40)"
         tt-contrato_limite.nmdcjav1 FORMAT "x(40)" AT 46
          SKIP
         tt-contrato_limite.dscpfav1 FORMAT "x(40)"
         tt-contrato_limite.dscfcav1 FORMAT "x(40)" AT 46
         SKIP(2)
         "----------------------------------------"
         "----------------------------------------" AT 46
         SKIP
         "Fiador 2:"
         "Conjuge Fiador 2:" AT 46
         SKIP
         tt-contrato_limite.nmdaval2 FORMAT "x(40)"
         tt-contrato_limite.nmdcjav2 FORMAT "x(40)" AT 46
         SKIP
         tt-contrato_limite.dscpfav2 FORMAT "x(40)"
         tt-contrato_limite.dscfcav2 FORMAT "x(40)" AT 46
         SKIP(2)
         "----------------------------------------"
         "----------------------------------------" AT 46
         SKIP
         "TESTEMUNHA: ____________________________"
         "TESTEMUNHA: ____________________________" AT 46
         SKIP
         "CPF:____________________________________"
         "CPF:____________________________________" AT 46
         SKIP     
         "CI:_____________________________________"
         "CI:_____________________________________" AT 46
         SKIP(3)
         "----------------------------------------" AT 46
         SKIP
         "Operador:" AT 46 "\017" tt-contrato_limite.nmoperad FORMAT "x(40)" "\022"
         WITH COLUMN 10 NO-BOX NO-LABELS WIDTH 137 FRAME f_final.

    FORM SKIP(1)
         "--> \033\105PARA USO DA DIGITACAO\033\106"
         "<----------------------------------------------------------\033\120"
         SKIP(1)
         "      CONTA/DV  CONTRATO      PRESTACAO     1o. FIADOR     2o. FIADOR"
         SKIP
         "\033\105"
         SKIP
         tt-contrato_limite.nrdconta FORMAT "zzzz,zzz,9"  AT 05
         tt-contrato_limite.nrctrlim FORMAT "z,zzz,zz9"
         tt-contrato_limite.vllimite FORMAT "zzz,zzz,zz9.99"
         " [___________]  [___________]\033\106" 
         WITH COLUMN 10 NO-BOX NO-LABELS WIDTH 137 FRAME f_uso_digitacao.

    /** FORM's para Nota Promissoria do limite de desconto de titulos **/
    FORM SKIP(1)
         "\022\024\033\120" /* reseta impressora */
         "\0330\033x0\033\017"
         "\033\016    NOTA PROMISSORIA VINCULADA"
         "\0332\033x0"
         SKIP
         "\0330\033x0\033\017"
         "\033\016     AO CONTRATO DE DESCONTO DE"
         "\022\024\033\120" /* reseta impressora */
         "\0332\033x0"
         "     Vencimento:" 
         tt-dados_nota_pro.ddmvtolt FORMAT "99"   "de"
         tt-dados_nota_pro.dsmesref FORMAT "x(9)" "de"
         tt-dados_nota_pro.aamvtolt FORMAT "9999"
         SKIP
         "\0330\033x0\033\017"
         "\033\016     TITULOS"
         "\022\024\033\120" /* reseta impressora */
         SKIP(1)
         "NUMERO" AT 07 "\033\016" tt-dados_nota_pro.dsctremp FORMAT "x(13)" "\024"
         tt-dados_nota_pro.dsdmoeda FORMAT "x(5)" "\033\016"
         tt-dados_nota_pro.vlpreemp FORMAT "zzz,zzz,zz9.99" "\033\016"
         SKIP
         "Ao(s)" AT 07 tt-dados_nota_pro.dsmvtol1 FORMAT "x(68)" SKIP
         tt-dados_nota_pro.dsmvtol2 AT 07 FORMAT "x(44)" "pagarei por esta unica via de" SKIP
         "\033\016N O T A  P R O M I S S O R I A\024" AT 07 "a" 
         tt-dados_nota_pro.nmrescop FORMAT "x(11)" SKIP
         tt-dados_nota_pro.nmextcop FORMAT "x(50)" AT 07 
         tt-dados_nota_pro.nrdocnpj FORMAT "x(23)" AT 58
         "ou a sua ordem a quantia de" AT 07
         tt-dados_nota_pro.dspremp1 AT 35 FORMAT "x(46)" SKIP
         tt-dados_nota_pro.dspremp2 AT 07 FORMAT "x(74)" SKIP
         "em moeda corrente deste pais." AT 07 SKIP(1)
         tt-dados_nota_pro.nmcidpac AT 07 FORMAT "x(33)"
         tt-dados_nota_pro.dsemsnot AT 44 FORMAT "x(37)"
         SKIP(1)
         tt-dados_nota_pro.nmprimtl AT 07 FORMAT "x(50)"
         SKIP
         tt-dados_nota_pro.dscpfcgc AT 07 FORMAT "x(40)" 
         "______________________________" AT 50
         SKIP
         "Conta/dv:"  AT 07 tt-dados_nota_pro.nrdconta FORMAT "zzzz,zzz,9" 
         "Assinatura" AT 50
         SKIP
         "Endereco:"  AT 07 SKIP
         tt-dados_nota_pro.dsendco1 AT 07 FORMAT "x(73)" SKIP
         tt-dados_nota_pro.dsendco2 AT 07 FORMAT "x(73)" SKIP 
         tt-dados_nota_pro.dsendco3 AT 07 FORMAT "x(73)" SKIP(1)
         WITH NO-BOX NO-LABELS DOWN WIDTH 137 FRAME f_notapromissoria.

    FORM tt-dados_nota_pro.dsqtdava AT 07 FORMAT "x(10)" 
         "Conjuge:"     AT 47 SKIP
         "\022\033\115" AT 06
         WITH NO-BOX NO-LABELS DOWN WIDTH 137 FRAME f_cab_promis_aval.

    FORM SKIP(2)
         "----------------------------------------" AT 08
         "----------------------------------------" AT 56
         tt-dados-avais.nmdavali AT 08 FORMAT "x(40)"
         tt-dados-avais.nmconjug AT 56 FORMAT "x(40)"
         SKIP
         aux_nrcpfcgc            AT 08 FORMAT "x(40)"
         tt-dados-avais.nrdoccjg AT 56 FORMAT "x(40)"
         SKIP                             
         tt-dados-avais.dsendre1 AT 08 FORMAT "x(40)"
         SKIP
         tt-dados-avais.dsendre2 AT 08 FORMAT "x(40)"
         SKIP
         tt-dados-avais.dsendre3 AT 08 FORMAT "x(40)"
         SKIP(3)
         WITH NO-BOX NO-LABELS DOWN WIDTH 137 FRAME f_promis_aval.

    FORM SKIP(5)
         WITH NO-BOX WIDTH 137 FRAME f_linhas.

    FORM "Grupo Economico:" AT 01
        SKIP(1)
        WITH FRAME f_grupo_1.
        
   FORM tt-grupo.cdagenci COLUMN-LABEL "PA"
        tt-grupo.nrctasoc COLUMN-LABEL "Conta"
        tt-grupo.vlendivi COLUMN-LABEL "Endividamento" FORMAT "zzz,zzz,zz9.99"
        tt-grupo.dsdrisco COLUMN-LABEL "Risco"
        WITH DOWN WIDTH 120 NO-BOX FRAME f_grupo.

   FORM SKIP(1) 
        aux_dsdrisco LABEL "Risco do Grupo"
        SKIP
        aux_vlendivi LABEL "Endividamento do Grupo"
        WITH NO-LABEL SIDE-LABEL WIDTH 120 NO-BOX FRAME f_grupo_2.


    EMPTY TEMP-TABLE tt-erro.

    IF  par_flgerlog  THEN
        DO:
            ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,",")).

            IF  par_idimpres = 1  THEN
                aux_dstransa = "Gerar impressao da proposta e contrato do " +
                               "limite de desconto de titulos".
            ELSE
            IF  par_idimpres = 2  THEN
                aux_dstransa = "Gerar impressao do contrato do limite de " +
                               "desconto de titulos".
            ELSE
            IF  par_idimpres = 3  THEN
                aux_dstransa = "Gerar impressao da proposta do limite de " +
                               "desconto de titulos".
            ELSE
            IF  par_idimpres = 4  THEN
                aux_dstransa = "Gerar impressao da nota promissoria do " +
                               "limite de desconto de titulos".
            ELSE
            IF  par_idimpres = 9  THEN
                aux_dstransa = "Gerar impressao de demonstracao do cet".
        END.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapcop  THEN
        DO:
            ASSIGN aux_cdcritic = 651
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagecxa,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                       
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdopecxa,
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

    RUN sistema/generico/procedures/b1wgen0030.p PERSISTENT SET h-b1wgen0030.

    IF  NOT VALID-HANDLE(h-b1wgen0030)  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO b1wgen0030.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagecxa,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            
            RETURN "NOK".
        END.

    RUN busca_dados_impressao_dsctit IN h-b1wgen0030 (INPUT par_cdcooper,
                                                      INPUT par_cdagecxa,
                                                      INPUT par_nrdcaixa,
                                                      INPUT par_cdopecxa,
                                                      INPUT par_nmdatela,
                                                      INPUT par_idorigem,
                                                      INPUT par_nrdconta,
                                                      INPUT par_idseqttl,    
                                                      INPUT par_dtmvtolt,
                                                      INPUT par_dtmvtopr,
                                                      INPUT par_inproces,
                                                      INPUT par_idimpres,
                                                      INPUT par_nrctrlim,
                                                      INPUT 0,  /** Bordero **/
                                                      INPUT FALSE,
                                                      INPUT 1,  /** Limite  **/
                                                     OUTPUT TABLE tt-erro,
                                                     OUTPUT TABLE tt-emprsts,
                                                     OUTPUT TABLE tt-proposta_limite,
                                                     OUTPUT TABLE tt-contrato_limite,        
                                                     OUTPUT TABLE tt-dados-avais,
                                                     OUTPUT TABLE tt-dados_nota_pro,
                                                     OUTPUT TABLE tt-proposta_bordero,
                                                     OUTPUT TABLE tt-dados_tits_bordero,
                                                     OUTPUT TABLE tt-tits_do_bordero,
                                                     OUTPUT TABLE tt-dsctit_bordero_restricoes,
                                                     OUTPUT TABLE tt-sacado_nao_pagou).

    DELETE PROCEDURE h-b1wgen0030.

    IF  RETURN-VALUE = "NOK" THEN
        RETURN "NOK".

    /* Se nao for impressao do cet gera arquivo normal */
    IF  par_idimpres <> 9 THEN
        DO: 

            ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + "/rl/" + 
                                  par_dsiduser.
            
            UNIX SILENT VALUE("rm " + aux_nmarquiv + "* 2>/dev/null").
        
            ASSIGN aux_nmarquiv = aux_nmarquiv + STRING(TIME)
                   aux_nmarqimp = aux_nmarquiv + ".ex"
                   aux_nmarqpdf = aux_nmarquiv + ".pdf".
        
            FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND         
                               craptab.nmsistem = "CRED"         AND         
                               craptab.tptabela = "GENERI"       AND         
                               craptab.cdempres = 00             AND         
                               craptab.cdacesso = "DIGITALIZA"   AND
                               craptab.tpregist = 3    /* Limite de Desc. de Tit. (GED) */
                               NO-LOCK NO-ERROR NO-WAIT.
                
            IF  AVAIL craptab THEN
                ASSIGN aux_tpdocged = INT(ENTRY(3,craptab.dstextab,";")).
        
            OUTPUT STREAM str_dsctit TO VALUE(aux_nmarqimp) APPEND PAGED PAGE-SIZE 87.
        END.
    
    /* Contrato do CET */
    IF  par_idimpres = 9 THEN
        DO:
            FIND FIRST tt-contrato_limite NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-contrato_limite THEN
                ASSIGN aux_flgcriti = TRUE.
                
            FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                               crapass.nrdconta = par_nrdconta 
                               NO-LOCK NO-ERROR.

            IF  NOT AVAIL crapass THEN
                ASSIGN aux_flgcriti = TRUE.

            FIND FIRST crawlim WHERE crawlim.cdcooper = par_cdcooper AND
                                     crawlim.nrdconta = par_nrdconta AND
                                     crawlim.tpctrlim = 3            AND
                                     crawlim.nrctrlim = par_nrctrlim 
                                     NO-LOCK NO-ERROR.
         
            IF  NOT AVAILABLE crawlim   THEN 
                ASSIGN aux_flgcriti = TRUE.

           FIND crapldc WHERE crapldc.cdcooper = par_cdcooper     AND
                              crapldc.cddlinha = crawlim.cddlinha AND
                              crapldc.tpdescto = 3
                              NO-LOCK NO-ERROR.   
        
            IF  NOT AVAIL crapldc THEN
                ASSIGN aux_flgcriti = TRUE.

            IF  aux_flgcriti THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Nao foi possivel gerar a impressao.".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagecxa,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                                               
                    IF  par_flgerlog  THEN
                        RUN proc_gerar_log (INPUT par_cdcooper,
                                            INPUT par_cdopecxa,
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

            /* Chamar rorina de impressao do contrato do cet */
            RUN imprime_cet( INPUT par_cdcooper,
                             INPUT par_dtmvtolt,
                             INPUT "ATENDA",
                             INPUT INT(tt-contrato_limite.nrdconta),
                             INPUT INT(crapass.inpessoa),
                             INPUT 1, /* p-cdusolcr */
                             INPUT INT(crawlim.cddlinha),
                             INPUT 3, /*1-Chq Esp./ 2-Desc Chq./ 3-Desc Tit*/
                             INPUT INT(tt-contrato_limite.nrctrlim),
                             INPUT (IF crawlim.dtinivig <> ? THEN
                                       crawlim.dtinivig
                                   ELSE par_dtmvtolt),
                             INPUT INT(tt-contrato_limite.qtdiavig),
                             INPUT DEC(tt-contrato_limite.vllimite),
                             INPUT DEC(crapldc.txmensal),
                            OUTPUT aux_nmdoarqv, 
                            OUTPUT aux_dscritic ).
            
            IF  RETURN-VALUE <> "OK" THEN
                DO:
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagecxa,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                                               
                    IF  par_flgerlog  THEN
                        RUN proc_gerar_log (INPUT par_cdcooper,
                                            INPUT par_cdopecxa,
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

        END.
    ELSE
    IF  par_idimpres = 3  THEN  /** PROPOSTA **/
        DO:               
            FIND FIRST tt-proposta_limite NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-proposta_limite  THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Nao foi possivel gerar a impressao.".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagecxa,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                                               
                    IF  par_flgerlog  THEN
                        RUN proc_gerar_log (INPUT par_cdcooper,
                                            INPUT par_cdopecxa,
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

            RUN sistema/generico/procedures/b1wgen0043.p PERSISTENT 
                SET h-b1wgen0043.
    
            IF  NOT VALID-HANDLE(h-b1wgen0043)  THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Handle invalido para BO b1wgen0043.".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagecxa,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                                               
                    IF  par_flgerlog  THEN
                        RUN proc_gerar_log (INPUT par_cdcooper,
                                            INPUT par_cdopecxa,
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

            RUN ratings-impressao IN h-b1wgen0043 (INPUT par_cdcooper,
                                                   INPUT 0, /** Todos PACS **/
                                                   INPUT par_cdopecxa,
                                                   INPUT par_idorigem, 
                                                   INPUT par_dtmvtolt,
                                                   INPUT par_dtmvtopr,
                                                   INPUT par_nrdconta,
                                                   INPUT par_nrctrlim,
                                                   INPUT 3, 
                                                   INPUT par_inproces,
                                                  OUTPUT TABLE tt-ratings).
  
            DELETE PROCEDURE h-b1wgen0043.

            RUN sistema/generico/procedures/b1wgen0030.p PERSISTENT SET h-b1wgen0030.

            IF  NOT VALID-HANDLE(h-b1wgen0030)  THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Handle invalido para BO b1wgen0030.".
           
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagecxa,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                    
                    RETURN "NOK".
                END.

            /* Adquire os Tipos de Cobrança do Cooperado */
            RUN busca_tipos_cobranca IN h-b1wgen0030 (INPUT par_cdcooper,
                                                      INPUT 0,
                                                      INPUT 0,
                                                      INPUT 0,
                                                      INPUT par_dtmvtolt,
                                                      INPUT 1,
                                                      INPUT tt-proposta_limite.nrdconta,
                                                      OUTPUT aux_tpcobran).

            DELETE PROCEDURE h-b1wgen0030.

            IF  RETURN-VALUE = "NOK" THEN
                RETURN "NOK".

            IF  aux_tpcobran = "T" THEN
                DO:
                   ASSIGN rel_tpcobran = "REGISTRADA E SEM REGISTRO".
                END.     
            ELSE
                IF  aux_tpcobran = "S" THEN
                    ASSIGN rel_tpcobran = "SEM REGISTRO".
            ELSE    
                IF  aux_tpcobran = "R" THEN
                    ASSIGN rel_tpcobran = "REGISTRADA".

            FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                               crapass.nrdconta = par_nrdconta  
                               NO-LOCK NO-ERROR.

            ASSIGN rel_nrdconta = tt-proposta_limite.nrdconta.

            PAGE STREAM str_dsctit.

            PUT STREAM str_dsctit CONTROL "\0330\033x0\022\033\115" NULL.
        
            DISPLAY STREAM str_dsctit
                tt-proposta_limite.nrdconta  tt-proposta_limite.nrmatric
                tt-proposta_limite.dsagenci  tt-proposta_limite.nmprimtl
                tt-proposta_limite.dtadmemp  tt-proposta_limite.nmempres
                tt-proposta_limite.nmdsecao  tt-proposta_limite.telefone
                tt-proposta_limite.nrcpfcgc  tt-proposta_limite.dstipcta
                tt-proposta_limite.dssitdct  tt-proposta_limite.dtadmiss
                tt-proposta_limite.nmextcop  tt-proposta_limite.dsramati
                tt-proposta_limite.nrctrlim  FORMAT "z,zzz,zz9"  
                aux_tpdocged                 FORMAT "zz9"
                rel_nrdconta                 FORMAT "zzzz,zzz,9"
                WITH FRAME f_pro_dados.
            
            DISPLAY STREAM str_dsctit
                tt-proposta_limite.vlsmdtri  tt-proposta_limite.vlcaptal
                tt-proposta_limite.vlprepla  tt-proposta_limite.vlsalari
                tt-proposta_limite.vlsalcon  tt-proposta_limite.vloutras
                tt-proposta_limite.vllimcre  tt-proposta_limite.vltotccr
                tt-proposta_limite.vlaplica  tt-proposta_limite.dsdeben1
                tt-proposta_limite.dsdeben2  tt-proposta_limite.vlfatura
                rel_tpcobran
                WITH FRAME f_pro_rec.
        
            DISPLAY STREAM str_dsctit 
                tt-proposta_limite.nrctrlim  tt-proposta_limite.vllimpro
                tt-proposta_limite.dsdlinha  tt-proposta_limite.vlmedtit
                WITH FRAME f_lim_pro.
        
            DOWN STREAM str_dsctit WITH FRAME f_lim_pro.
        
            IF  CAN-FIND(FIRST tt-emprsts NO-LOCK)  THEN
                DO:
                    DISPLAY STREAM str_dsctit tt-proposta_limite.dtcalcul 
                                              WITH FRAME f_pro_ed1.
        
                    FOR EACH tt-emprsts WHERE tt-emprsts.vlsdeved > 0 NO-LOCK:
        
                        DISPLAY STREAM str_dsctit
                                tt-emprsts.nrctremp  tt-emprsts.vlsdeved
                                tt-emprsts.dspreapg  tt-emprsts.vlpreemp
                                tt-emprsts.dslcremp  tt-emprsts.dsfinemp
                                WITH FRAME f_dividas.
        
                        DOWN STREAM str_dsctit WITH FRAME f_dividas.
        
                    END. /** Fim do FOR EACH tt-emprsts **/
        
                    DISPLAY STREAM str_dsctit tt-proposta_limite.vlsdeved  
                                              tt-proposta_limite.vlpreemp 
                                              WITH FRAME f_tot_div.
                END.
            ELSE
                VIEW STREAM str_dsctit FRAME f_sem_divida.
        
            DISPLAY STREAM str_dsctit tt-proposta_limite.vlutiliz
                                      WITH FRAME f_autorizo.
        
            DISPLAY STREAM str_dsctit 
                tt-proposta_limite.dsobser1  tt-proposta_limite.dsobser2
                tt-proposta_limite.dsobser3  tt-proposta_limite.dsobser4
                WITH FRAME f_observac.
                            
            DOWN STREAM str_dsctit WITH FRAME f_observac.        
         
            DISPLAY STREAM str_dsctit 
                tt-proposta_limite.nmprimtl  tt-proposta_limite.nmoperad
                tt-proposta_limite.nmcidade  tt-proposta_limite.ddmvtolt
                tt-proposta_limite.dsmesref  tt-proposta_limite.aamvtolt
                tt-proposta_limite.nmresco1  tt-proposta_limite.nmresco2
                WITH FRAME f_aprovacao.

            PAGE STREAM str_dsctit.

            VIEW STREAM str_dsctit FRAME f_config.

            
            /** Rating da proposta atual **/
            FIND tt-ratings WHERE 
                 tt-ratings.tpctrrat = 2                               AND
                 tt-ratings.nrctrrat = tt-proposta_limite.nrctrlim
                 NO-LOCK NO-ERROR.
        
            IF  AVAIL tt-ratings   THEN
                DISPLAY STREAM str_dsctit 
                    tt-ratings.dsdopera  tt-ratings.nrctrrat
                    tt-ratings.indrisco  tt-ratings.nrnotrat
                    tt-ratings.dsdrisco  WITH FRAME f_rating_atual. 
                
            IF  CAN-FIND(FIRST tt-ratings WHERE NOT 
                   (tt-ratings.tpctrrat = 2  AND
                    tt-ratings.nrctrrat = tt-proposta_limite.nrctrlim)) THEN
                VIEW STREAM str_dsctit FRAME f_historico_rating_1.

            /** Todos os outros ratings de operacoes ainda em aberto **/
            FOR EACH tt-ratings WHERE 
                NOT (tt-ratings.tpctrrat = 2                 AND
                     tt-ratings.nrctrrat = crawlim.nrctrlim) NO-LOCK
                     BY tt-ratings.insitrat DESC
                        BY tt-ratings.nrnotrat DESC:
        
                DISPLAY STREAM str_dsctit 
                    tt-ratings.dsdopera  tt-ratings.nrctrrat
                    tt-ratings.indrisco  tt-ratings.nrnotrat
                    tt-ratings.vloperac  tt-ratings.dsditrat
                    WITH FRAME f_historico_rating_2.
        
                DOWN WITH FRAME f_historico_rating_2.
        
            END. /** Fim do FOR EACH tt-ratings **/

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
                  RUN calc_endivid_grupo IN h-b1wgen0138
                                            (INPUT par_cdcooper,
                                             INPUT par_cdagecxa,
                                             INPUT par_nrdcaixa,
                                             INPUT par_cdopecxa,
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
                     DELETE OBJECT(h-b1wgen0138).

                  IF RETURN-VALUE <> "OK" THEN
                     RETURN "NOK".
                    
                  IF TEMP-TABLE tt-grupo:HAS-RECORDS THEN
                     DO:
                        VIEW STREAM str_dsctit FRAME f_grupo_1.

                        FOR EACH tt-grupo
                                 NO-LOCK BY tt-grupo.cdagenci
                                          BY tt-grupo.nrdconta:

                            DISP STREAM str_dsctit tt-grupo.cdagenci
                                                   tt-grupo.nrctasoc
                                                   tt-grupo.vlendivi
                                                   tt-grupo.dsdrisco
                                                   WITH FRAME f_grupo.

                            DOWN WITH FRAME f_grupo.
                            
                        END.

                        DISP STREAM str_dsctit aux_dsdrisco 
                                               aux_vlendivi
                                               WITH FRAME f_grupo_2.


                     END.


               END.


            IF VALID-HANDLE(h-b1wgen0138) THEN
               DELETE OBJECT h-b1wgen0138.

        END.

    IF  par_idimpres = 1  OR    /** COMPLETA **/
        par_idimpres = 2  THEN  /** CONTRATO **/
        DO:
            FIND FIRST tt-contrato_limite NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-contrato_limite  THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Nao foi possivel gerar a impressao.".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagecxa,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                                               
                    IF  par_flgerlog  THEN
                        RUN proc_gerar_log (INPUT par_cdcooper,
                                            INPUT par_cdopecxa,
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

            FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                               crapass.nrdconta = par_nrdconta 
                               NO-LOCK NO-ERROR.

            IF  NOT AVAIL crapass THEN
                ASSIGN aux_flgcriti = TRUE.

            FIND FIRST craplim WHERE craplim.cdcooper = par_cdcooper AND
                                     craplim.nrdconta = par_nrdconta AND
                                     craplim.tpctrlim = 3            AND
                                     craplim.nrctrlim = par_nrctrlim 
                                     NO-LOCK NO-ERROR.
         
            IF  NOT AVAILABLE craplim   THEN 
                ASSIGN aux_flgcriti = TRUE.

           FIND crapldc WHERE crapldc.cdcooper = par_cdcooper     AND
                              crapldc.cddlinha = craplim.cddlinha AND
                              crapldc.tpdescto = 3
                              NO-LOCK NO-ERROR.   
        
            IF  NOT AVAIL crapldc THEN
                ASSIGN aux_flgcriti = TRUE.

            IF  aux_flgcriti THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Nao foi possivel gerar a impressao.".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagecxa,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                                               
                    IF  par_flgerlog  THEN
                        RUN proc_gerar_log (INPUT par_cdcooper,
                                            INPUT par_cdopecxa,
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

            /* Chamar rorina para calcular o contrato do cet */
            RUN calcula_cet_limites( INPUT par_cdcooper,
                                     INPUT par_dtmvtolt,
                                     INPUT "ATENDA",
                                     INPUT INT(tt-contrato_limite.nrdconta),
                                     INPUT INT(crapass.inpessoa),
                                     INPUT 1, /* p-cdusolcr */
                                     INPUT INT(craplim.cddlinha),
                                     INPUT 3, /*1-Chq Esp./ 2-Desc Chq./ 3-Desc Tit*/
                                     INPUT INT(tt-contrato_limite.nrctrlim),
                                     INPUT (IF craplim.dtinivig <> ? THEN
                                               craplim.dtinivig
                                           ELSE par_dtmvtolt),
                                     INPUT INT(tt-contrato_limite.qtdiavig),
                                     INPUT DEC(tt-contrato_limite.vllimite),
                                     INPUT DEC(crapldc.txmensal),
                                    OUTPUT aux_txcetano, 
                                    OUTPUT aux_txcetmes, 
                                    OUTPUT aux_dscritic ).
            
            IF  RETURN-VALUE <> "OK" THEN
                DO:
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagecxa,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                                               
                    IF  par_flgerlog  THEN
                        RUN proc_gerar_log (INPUT par_cdcooper,
                                            INPUT par_cdopecxa,
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

            RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT
                SET h-b1wgen9999.

            /*  calculo do cet por extenso ................................ */
            RUN valor-extenso IN h-b1wgen9999 
                             (INPUT aux_txcetano, 
                              INPUT 29, 
                              INPUT 80, 
                              INPUT "P",
                              OUTPUT aux_dscetan1, 
                              OUTPUT aux_dscetan2).

            ASSIGN aux_dscetan1 = STRING(aux_txcetano,"zz9.99") + 
                                  " % (" + LC(aux_dscetan1).

            IF   LENGTH(TRIM(aux_dscetan2)) = 0   THEN
                 ASSIGN aux_dscetan1 = aux_dscetan1 + ")" 
                        aux_dscetan2 = "ao ano; (" +
                                       STRING(aux_txcetmes,"zz9.99") +
                                       " % ao mes), ".
            ELSE
                 ASSIGN aux_dscetan1 = aux_dscetan1 
                        aux_dscetan2 = TRIM(LC(aux_dscetan2)) + ") ao ano; (" +
                                       STRING(aux_txcetmes,"zz9.99") +
                                       " % ao mes), ".

            PAGE STREAM str_dsctit.

            VIEW STREAM str_dsctit FRAME f_config.
            ASSIGN aux_nrctrrat =  tt-contrato_limite.nrctrlim.
            DISPLAY STREAM str_dsctit tt-contrato_limite.nrctrlim 
                                      tt-contrato_limite.nrdconta 
                                      aux_nrctrrat        
                                      aux_tpdocged                
                                      WITH FRAME f_cooperativa.

            DISPLAY STREAM str_dsctit
                tt-contrato_limite.nmextcop  tt-contrato_limite.cdagenci
                tt-contrato_limite.dslinha1  tt-contrato_limite.dslinha2
                tt-contrato_limite.dslinha3  tt-contrato_limite.dslinha4
                tt-contrato_limite.nmprimt1  tt-contrato_limite.nrdconta
                tt-contrato_limite.nrcpfcgc  tt-contrato_limite.txnrdcid
                tt-contrato_limite.dsdmoeda  tt-contrato_limite.vllimite
                tt-contrato_limite.dslimit1  tt-contrato_limite.dslimit2
                tt-contrato_limite.dsdlinha  tt-contrato_limite.qtdiavig
                tt-contrato_limite.txqtdvi1  tt-contrato_limite.dsjurmo1
                tt-contrato_limite.dsjurmo2  tt-contrato_limite.txdmulta
                tt-contrato_limite.txmulex1  tt-contrato_limite.txmulex2
                tt-contrato_limite.nmcidade  aux_dscetan1 aux_dscetan2 
                WITH FRAME f_introducao.
        
            DISPLAY STREAM str_dsctit
                tt-contrato_limite.nmprimt2  tt-contrato_limite.nmresco1
                tt-contrato_limite.nmresco2  tt-contrato_limite.nmdaval1
                tt-contrato_limite.nmdcjav1  tt-contrato_limite.dscpfav1
                tt-contrato_limite.dscfcav1  tt-contrato_limite.nmdaval2
                tt-contrato_limite.nmdcjav2  tt-contrato_limite.dscpfav2
                tt-contrato_limite.dscfcav2  tt-contrato_limite.nmoperad
                WITH FRAME f_final.

            IF  LINE-COUNTER(str_dsctit) >= PAGE-SIZE(str_dsctit) - 7  THEN
                PAGE STREAM str_dsctit.

            DISPLAY STREAM str_dsctit
                tt-contrato_limite.nrdconta  tt-contrato_limite.nrctrlim
                tt-contrato_limite.vllimite 
                WITH FRAME f_uso_digitacao.

            /***  GERAR IMPRESSAO DO CONTRATO DO CET ***/
            FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                               crapass.nrdconta = par_nrdconta 
                               NO-LOCK NO-ERROR.

            IF  NOT AVAIL crapass THEN
                RETURN "NOK".

            FIND FIRST craplim WHERE craplim.cdcooper = par_cdcooper AND
                                     craplim.nrdconta = par_nrdconta AND
                                     craplim.tpctrlim = 3            AND
                                     craplim.nrctrlim = par_nrctrlim 
                                     NO-LOCK NO-ERROR.
         
            IF  NOT AVAILABLE craplim   THEN 
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Registro de limites nao encontrado.".
        
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagecxa,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                    RETURN "NOK".
                END.

           FIND crapldc WHERE crapldc.cdcooper = par_cdcooper     AND
                              crapldc.cddlinha = craplim.cddlinha AND
                              crapldc.tpdescto = 3
                              NO-LOCK NO-ERROR.   
        
            IF  NOT AVAIL crapldc THEN
                RETURN "NOK".

            /* Chamar rorina de impressao do contrato do cet */
            RUN imprime_cet( INPUT par_cdcooper,
                             INPUT par_dtmvtolt,
                             INPUT "ATENDA",
                             INPUT INT(tt-contrato_limite.nrdconta),
                             INPUT INT(crapass.inpessoa),
                             INPUT 1, /* p-cdusolcr */
                             INPUT INT(craplim.cddlinha),
                             INPUT 3, /*1-Chq Esp./ 2-Desc Chq./ 3-Desc Tit*/
                             INPUT INT(tt-contrato_limite.nrctrlim),
                             INPUT (IF craplim.dtinivig <> ? THEN
                                       craplim.dtinivig
                                   ELSE par_dtmvtolt),
                             INPUT INT(tt-contrato_limite.qtdiavig),
                             INPUT DEC(tt-contrato_limite.vllimite),
                             INPUT DEC(crapldc.txmensal),
                            OUTPUT aux_nmdoarqv, 
                            OUTPUT aux_dscritic).
            
            IF  RETURN-VALUE <> "OK" THEN
                DO:
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagecxa,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                                               
                    IF  par_flgerlog  THEN
                        RUN proc_gerar_log (INPUT par_cdcooper,
                                            INPUT par_cdopecxa,
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
        END.

    IF  par_idimpres = 1  OR    /** COMPLETA    **/
        par_idimpres = 4  THEN  /** PROMISSORIA **/
        DO:
            FIND FIRST tt-dados_nota_pro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-dados_nota_pro  THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Nao foi possivel gerar a impressao.".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagecxa,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                                               
                    IF  par_flgerlog  THEN
                        RUN proc_gerar_log (INPUT par_cdcooper,
                                            INPUT par_cdopecxa,
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

            PAGE STREAM str_dsctit.
        
            PUT STREAM str_dsctit CONTROL "\0330\033x0\033\022\033\120" NULL.

            DISPLAY STREAM str_dsctit
                tt-dados_nota_pro.nmrescop  tt-dados_nota_pro.nmextcop
                tt-dados_nota_pro.nrdocnpj  tt-dados_nota_pro.ddmvtolt
                tt-dados_nota_pro.dsmesref  tt-dados_nota_pro.aamvtolt
                tt-dados_nota_pro.dsctremp  tt-dados_nota_pro.dsdmoeda
                tt-dados_nota_pro.vlpreemp  tt-dados_nota_pro.dsmvtol1
                tt-dados_nota_pro.dsmvtol2  tt-dados_nota_pro.dspremp1
                tt-dados_nota_pro.dspremp2  tt-dados_nota_pro.nmprimtl
                tt-dados_nota_pro.dscpfcgc  tt-dados_nota_pro.nrdconta
                tt-dados_nota_pro.dsendco1  tt-dados_nota_pro.dsendco2
                tt-dados_nota_pro.dsendco3  tt-dados_nota_pro.nmcidpac
                tt-dados_nota_pro.dsemsnot
                WITH FRAME f_notapromissoria.
         
            DOWN STREAM str_dsctit WITH FRAME f_notapromissoria.
                         
            IF  CAN-FIND(FIRST tt-dados-avais NO-LOCK)  THEN
                DISPLAY STREAM str_dsctit tt-dados_nota_pro.dsqtdava
                               WITH FRAME f_cab_promis_aval.

            FOR EACH tt-dados-avais NO-LOCK BY tt-dados-avais.idavalis:

                ASSIGN aux_nrcpfcgc = IF tt-dados-avais.nrcpfcgc > 0 THEN
                                          "C.P.F. " + 
                                          STRING(STRING(tt-dados-avais.nrcpfcgc,
                                          "99999999999"),"xxx.xxx.xxx-xx")
                                      ELSE
                                          FILL("_",40).

                DISPLAY STREAM str_dsctit
                    tt-dados-avais.nmdavali  tt-dados-avais.nmconjug  
                    aux_nrcpfcgc             tt-dados-avais.nrdoccjg
                    tt-dados-avais.dsendre1  tt-dados-avais.dsendre2
                    tt-dados-avais.dsendre3
                    WITH FRAME f_promis_aval.
                     
                DOWN STREAM str_dsctit WITH FRAME f_promis_aval.

            END. /** Fim do FOR EACH tt-dados-avais **/
                      
            VIEW STREAM str_dsctit FRAME f_linhas.
        END.
    
    IF  par_idimpres <> 9 THEN
        DO: 
            OUTPUT STREAM str_dsctit CLOSE.

            RUN junta_arquivos(INPUT crapcop.dsdircop,
                               INPUT aux_nmarquiv + ".ex", /*contratos */
                               INPUT "/usr/coop/" + crapcop.dsdircop + "/rl/"
                                     + aux_nmdoarqv + ".ex", /* cet */
                               INPUT par_dsiduser,
                              OUTPUT aux_nmarqimp,
                              OUTPUT aux_nmarqpdf).
        END.

    IF  par_flgemail      OR    /** Enviar proposta via e-mail **/
        par_idorigem = 5  THEN  /** Ayllos Web **/
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "".

            DO WHILE TRUE:

                RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
                    SET h-b1wgen0024.
            
                IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                    DO:
                        ASSIGN aux_dscritic = "Handle invalido para BO " +
                                              "b1wgen0024.".
                        LEAVE.
                    END.

                RUN gera-pdf-impressao IN h-b1wgen0024 (INPUT aux_nmarqimp,
                                                        INPUT aux_nmarqpdf).
    
                /** Copiar pdf para visualizacao no Ayllos WEB **/
                IF  par_idorigem = 5  THEN
                    DO:
                        IF  SEARCH(aux_nmarqpdf) = ?  THEN
                            DO:
                                ASSIGN aux_dscritic = "Nao foi possivel gerar" +
                                                      " a impressao.".
                                LEAVE.                      
                            END.
                            
                        UNIX SILENT VALUE ('sudo /usr/bin/su - scpuser -c ' +
                           '"scp ' + aux_nmarqpdf + ' scpuser@' + aux_srvintra +
                           ':/var/www/ayllos/documentos/' + crapcop.dsdircop +
                           '/temp/" 2>/dev/null').
                    END.
    
                /** Enviar proposta para o PAC Sede via e-mail **/
                IF  par_flgemail  THEN
                    DO:
                        RUN executa-envio-email IN h-b1wgen0024 
                                               (INPUT par_cdcooper, 
                                                INPUT par_cdagecxa, 
                                                INPUT par_nrdcaixa, 
                                                INPUT par_cdopecxa, 
                                                INPUT par_nmdatela, 
                                                INPUT par_idorigem, 
                                                INPUT par_dtmvtolt, 
                                                INPUT 519, 
                                                INPUT aux_nmarqimp, 
                                                INPUT aux_nmarqpdf,
                                                INPUT par_nrdconta, 
                                                INPUT 3, 
                                                INPUT par_nrctrlim, 
                                               OUTPUT TABLE tt-erro).
    
                        IF  RETURN-VALUE = "NOK"  THEN
                            DO:
                                FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
                                IF  AVAILABLE tt-erro  THEN
                                    ASSIGN aux_dscritic = tt-erro.dscritic.
                                ELSE
                                    ASSIGN aux_dscritic = "Nao foi possivel " +
                                                          "gerar a impressao.".
    
                                LEAVE.
                            END.
                    END.

                LEAVE.

            END. /** Fim do DO WHILE TRUE **/

            IF  VALID-HANDLE(h-b1wgen0024)  THEN
                DELETE PROCEDURE h-b1wgen0024.
    
            IF  aux_dscritic <> ""  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.

                    IF  NOT AVAILABLE tt-erro  THEN
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagecxa,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,            /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
                                               
                    IF  par_flgerlog  THEN
                        RUN proc_gerar_log (INPUT par_cdcooper,
                                            INPUT par_cdopecxa,
                                            INPUT aux_dscritic,
                                            INPUT aux_dsorigem,
                                            INPUT aux_dstransa,
                                            INPUT FALSE,
                                            INPUT par_idseqttl,
                                            INPUT par_nmdatela,
                                            INPUT par_nrdconta,
                                           OUTPUT aux_nrdrowid). 
                        
                    IF  aux_nmarquiv <> "" THEN
                        UNIX SILENT VALUE ("rm " + aux_nmarquiv + " 2>/dev/null").

                    RETURN "NOK".
                END.

            IF  par_idorigem = 5  THEN
                DO:
                    IF  aux_nmarquiv <> "" THEN
                        UNIX SILENT VALUE ("rm " + aux_nmarquiv + " 2>/dev/null").

                    /* Remover arquivo gerado do cet */
                    IF  aux_nmdoarqv <> "" THEN
                        UNIX SILENT VALUE ("rm " + "/usr/coop/" + crapcop.dsdircop + "/rl/" + 
                                           TRIM(aux_nmdoarqv) + " 2>/dev/null").
                END.
            ELSE
                UNIX SILENT VALUE ("rm " + aux_nmarqpdf + " 2>/dev/null").
        END.                                                                      
                                                      
    ASSIGN par_nmarqimp = aux_nmarqimp
           par_nmarqpdf = ENTRY(NUM-ENTRIES(aux_nmarqpdf,"/"),aux_nmarqpdf,"/").

    IF  par_flgerlog  THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdopecxa,
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

PROCEDURE imprime_cet:
    
    DEF INPUT PARAM p-cdcooper AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-dtmvtolt AS DATE                                 NO-UNDO.
    DEF INPUT PARAM p-cdprogra AS CHAR                                 NO-UNDO.
    DEF INPUT PARAM p-nrdconta AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-inpessoa AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-cdusolcr AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-cdlcremp AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-tpctrlim AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-nrctrlim AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-dtinivig AS DATE                                 NO-UNDO.
    DEF INPUT PARAM p-qtdiavig AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-vlemprst AS DECI                                 NO-UNDO.
    DEF INPUT PARAM p-txmensal AS DECI                                 NO-UNDO.

    DEF OUTPUT PARAM par_nmdoarqv AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                              NO-UNDO.

    DEF VAR aux_dscritic AS CHAR NO-UNDO.
    DEF VAR aux_cdcritic AS INTE NO-UNDO.    

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_imprime_limites_cet 
        aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT p-cdcooper, /* Cooperativa */
                          INPUT p-dtmvtolt, /* Data Movimento */
                          INPUT p-cdprogra, /* Programa chamador */
                          INPUT p-nrdconta, /* Conta/dv          */
                          INPUT p-inpessoa, /* Indicativo de pessoa */
                          INPUT p-cdusolcr, /* Codigo de uso da linha de credito */
                          INPUT p-cdlcremp, /* Linha de credio */
                          INPUT p-tpctrlim, /* Tipo da operacao  */
                          INPUT p-nrctrlim, /* Contrato          */
                          INPUT p-dtinivig, /* Data liberacao  */
                          INPUT p-qtdiavig, /* Dias de vigencia */                                     
                          INPUT p-vlemprst, /* Valor emprestado */
                          INPUT p-txmensal, /* Taxa mensal/crapldc.txmensal */
						  INPUT 0,          /* 0 - false pr_flretxml*/
                         OUTPUT "",
                         OUTPUT "", 
                         OUTPUT 0,
                         OUTPUT "").                                  

    CLOSE STORED-PROC pc_imprime_limites_cet 
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           par_nmdoarqv = ""
           par_nmdoarqv = pc_imprime_limites_cet.pr_nmarqimp
                          WHEN pc_imprime_limites_cet.pr_nmarqimp <> ? 
           aux_cdcritic = pc_imprime_limites_cet.pr_cdcritic 
                          WHEN pc_imprime_limites_cet.pr_cdcritic <> ?
           aux_dscritic = pc_imprime_limites_cet.pr_dscritic 
                          WHEN pc_imprime_limites_cet.pr_dscritic <> ?.
        
    IF  aux_cdcritic <> 0   OR
        aux_dscritic <> ""  THEN
        DO:                                    
            ASSIGN par_dscritic = aux_dscritic.

            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE junta_arquivos:

    DEF  INPUT PARAM par_dsdircop AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nmarqimp AS CHAR FORMAT "x(70)"               NO-UNDO.
    DEF  INPUT PARAM par_nmarqcet AS CHAR FORMAT "x(70)"               NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR FORMAT "x(70)"               NO-UNDO.

    DEF OUTPUT PARAM par_nmarquiv AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                              NO-UNDO.

    DEF VAR aux_dsarqimp AS CHAR                                       NO-UNDO.
    DEF VAR aux_setlinha AS CHAR                                       NO-UNDO.
    DEF VAR aux_time     AS CHAR                                       NO-UNDO.

    ASSIGN aux_time = STRING(TIME) + TRIM(par_dsiduser)
           par_nmarquiv = "/usr/coop/" + par_dsdircop + "/rl/" + aux_time + ".ex"
           par_nmarqpdf = "/usr/coop/" + par_dsdircop + "/rl/" + aux_time + ".pdf".

    OUTPUT STREAM str_4 TO VALUE(par_nmarquiv) APPEND PAGED PAGE-SIZE 140.

    /* para contrato e completa */
    INPUT STREAM str_2
          THROUGH VALUE( "ls " + par_nmarqimp + " 2> /dev/null") NO-ECHO.

    DO  WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

         SET STREAM str_2 par_nmarqimp.

         INPUT STREAM str_3 FROM VALUE(par_nmarqimp) NO-ECHO.

         DO  WHILE TRUE TRANSACTION ON ENDKEY UNDO, LEAVE:

             IMPORT STREAM str_3 UNFORMATTED aux_setlinha.
             
             PUT STREAM str_4 aux_setlinha FORMAT "x(110)" SKIP.
         END.    

         INPUT STREAM str_3 CLOSE.
         
    END.

    INPUT STREAM str_2 CLOSE.
    
    PAGE STREAM str_4.            
    PUT STREAM str_4 CHR(2).  /* inicio do texto chr(2)*/

    /* para o cet */
    INPUT STREAM str_2
          THROUGH VALUE( "ls " + par_nmarqcet + " 2> /dev/null") NO-ECHO.

    DO  WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

         SET STREAM str_2 par_nmarqcet.

         INPUT STREAM str_3 FROM VALUE(par_nmarqcet) NO-ECHO.

         DO  WHILE TRUE TRANSACTION ON ENDKEY UNDO, LEAVE:

             IMPORT STREAM str_3 UNFORMATTED aux_setlinha.

             PUT STREAM str_4 aux_setlinha FORMAT "x(80)" SKIP.
             
         END.

         INPUT STREAM str_3 CLOSE.
    END.

    INPUT STREAM str_2 CLOSE.

    OUTPUT STREAM str_4 CLOSE.
END.

PROCEDURE calcula_cet_limites:
    
    DEF INPUT PARAM p-cdcooper AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-dtmvtolt AS DATE                                 NO-UNDO.
    DEF INPUT PARAM p-cdprogra AS CHAR                                 NO-UNDO.
    DEF INPUT PARAM p-nrdconta AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-inpessoa AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-cdusolcr AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-cdlcremp AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-tpctrlim AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-nrctrlim AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-dtinivig AS DATE                                 NO-UNDO.
    DEF INPUT PARAM p-qtdiavig AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-vlemprst AS DECI                                 NO-UNDO.
    DEF INPUT PARAM p-txmensal AS DECI                                 NO-UNDO.

    DEF OUTPUT PARAM par_txcetano AS DECI                              NO-UNDO.
    DEF OUTPUT PARAM par_txcetmes AS DECI                              NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                              NO-UNDO.

    DEF VAR aux_dscritic AS CHAR NO-UNDO.
    DEF VAR aux_cdcritic AS INTE NO-UNDO.    

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_calculo_cet_limites
        aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT p-cdcooper, /* Cooperativa */
                          INPUT p-dtmvtolt, /* Data Movimento */
                          INPUT p-cdprogra, /* Programa chamador */
                          INPUT p-nrdconta, /* Conta/dv          */
                          INPUT p-inpessoa, /* Indicativo de pessoa */
                          INPUT p-cdusolcr, /* Codigo de uso da linha de credito */
                          INPUT p-cdlcremp, /* Linha de credio */
                          INPUT p-tpctrlim, /* Tipo da operacao  */
                          INPUT p-nrctrlim, /* Contrato          */
                          INPUT p-dtinivig, /* Data liberacao  */
                          INPUT p-qtdiavig, /* Dias de vigencia */                                     
                          INPUT p-vlemprst, /* Valor emprestado */
                          INPUT p-txmensal, /* Taxa mensal/crapldc.txmensal */
                         OUTPUT 0, 
                         OUTPUT 0, 
                         OUTPUT 0,
                         OUTPUT "").

    CLOSE STORED-PROC pc_calculo_cet_limites
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           par_txcetano = 0
           par_txcetmes = 0
           par_txcetano = pc_calculo_cet_limites.pr_txcetano
                          WHEN pc_calculo_cet_limites.pr_txcetano <> ? 
           par_txcetmes = pc_calculo_cet_limites.pr_txcetmes
                          WHEN pc_calculo_cet_limites.pr_txcetmes <> ? 
           aux_cdcritic = pc_calculo_cet_limites.pr_cdcritic 
                          WHEN pc_calculo_cet_limites.pr_cdcritic <> ?
           aux_dscritic = pc_calculo_cet_limites.pr_dscritic 
                          WHEN pc_calculo_cet_limites.pr_dscritic <> ?.
        
    IF  aux_cdcritic <> 0   OR
        aux_dscritic <> ""  THEN
        DO:                                    
            ASSIGN par_dscritic = aux_dscritic.

            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.
/* .......................................................................... */





