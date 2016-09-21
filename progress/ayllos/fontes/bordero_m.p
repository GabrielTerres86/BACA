/* .............................................................................

   Programa: Fontes/bordero_m.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Abril/2003.                     Ultima atualizacao: 15/10/2015
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Fazer o tratamento para impressao da proposta e cheques do  
               bordero de desconto de cheques.

   Alteracoes: 21/10/2003 - Inclusao do Valor do desconto proposto e do saldo
                            do desconto na proposta de desconto de cheques.
                            E Inclusao do nome da cooperativa para carimbo
                            no bordero de desconto. (Julio).
                            
               11/11/2003 - Tratamento para calculo do valor da media de
                            cheques descontados "DIVISAO POR ZERO". (Julio).
                            
               09/12/2003 - Buscar nome da cidade no crapcop (Junior).

               29/09/2004 - Ajuste na impressao da observacao (Edson).
               
               10/11/2004 - Incluir Limite de Desconto de Cheques (Ze).
               
               20/01/2005 - Melhorar a leituro do crapcdb utilizando indices
                            mais otimizados (Edson).

               20/09/2005 - Alterado para fazer leitura tbm do codigo da 
                            cooperativa na tabela crapabc, e modificado
                            FIND FIRST para FIND na tabela crapcop.cdcooper = 
                            glb_cdcooper (Diego).

               26/01/2006 - Unificacao de Bancos - SQLWorks - Luciane. 

               05/10/2006 - Incluido Pac do titular da conta na identificacao
                            do cooperado (Elton). 

               02/04/2007 - Efetuado acertos totais saldo 
                            devedor e parcela emprestimo(Mirtes)
                            
               29/06/2007 - Adicionado Testemunhas (Guilherme).
               
               25/10/2007 - Alterado para usar crapttl.nmdsecao para secao
                            inves de nmdsecao(crapass) (Guilherme).

               09/05/2008 - Ajustar dspreapg para 11 posicoes (Magui).
               
               01/09/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.
               
               12/11/2010 - Incluida a palavra "CADIN" na proposta de
                            Limite de descontos de cheques (Vitor).
                            
               07/02/2011 - Substituida temp-table workepr por
                            tt-dados-epr. (Gabriel/DB1)
                            
               16/02/2011 - Ajuste devid alteracao do campo nome (Henrique)
               
               21/07/2011 - Nao gerar a proposta quando a impressao for completa 
                           (Isara - RKAM)
                           
               19/03/2012 - Adicionada área para uso da Digitalizaçao (Lucas).
               
               27/04/2012 - Incluído item para digitalizaçao na impressao de 
                            bordero de desconto de cheques e termo de 
                            contrato (Guilherme Maba).
                            
               21/06/2012 - Adicionado área para uso da Digitalizaçao no documento
                            de analise de desconto de cheque (Lucas).
                            
               06/05/2013 - Adicionado Tp. de Docmto GED na área de uso da 
                            Digitalizaçao (Lucas).
               
               31/07/2013 - Alterado para pegar o telefone da tabela 
                            craptfc ao invés da crapass (James).
               
               01/10/2013 - Nova forma de chamar as agencias, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               24/04/2014 - Adicionado param. de paginacao em procedure
                            obtem-dados-emprestimos em BO 0002.(Jorge)   
                            
               29/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Andrino-RKAM)
               
               22/01/2015 - Alterado o formato do campo nrctremp para 8 
                            caracters (Kelvin - 233714)
                            
               12/08/2015 - Projeto Reformulacao cadastral
                            Eliminado o campo nmdsecao (Tiago Castro - RKAM).
                            
               15/10/2015 - Ajuste em proc. p_cheque, adicionado condicao de WHERE
                            em "FIND FIRST crapcec", igual ao que tem na 
                            b1wgen0009 em proc. busca_cheques_bordero.
                            (Jorge/Gielow) - SD 336898
                            
............................................................................. */

DEF INPUT PARAM par_recid    AS RECID.
DEF INPUT PARAM par_insitbdc AS INT.

{ sistema/generico/includes/b1wgen0002tt.i }
{ includes/var_online.i }
{ includes/var_atenda.i }
{ includes/var_bordero_m.i "NEW" }

DEF STREAM str_1.

/** Utilizados para o tratamento da geracao de nota promissoria **/

DEF BUFFER crabass FOR crapass.

DEF TEMP-TABLE tt-erro LIKE craperr.

DEF        VAR tot_vlsdeved AS DECIMAL                               NO-UNDO.
DEF        VAR tot_vlpreemp AS DECIMAL                               NO-UNDO.

DEF        VAR rel_dslimite AS CHAR    EXTENT 2                      NO-UNDO.
DEF        VAR rel_dsdlinha AS CHAR                                  NO-UNDO.
DEF        VAR rel_dsjurmor AS CHAR    EXTENT 2                      NO-UNDO.
DEF        VAR rel_txdmulta AS DECIMAL DECIMALS 7                    NO-UNDO.
DEF        VAR rel_nmcidade AS CHAR                                  NO-UNDO.
DEF        VAR rel_nmextcop AS CHAR                                  NO-UNDO.

DEF        VAR rel_nrctrlim AS INT                                   NO-UNDO.
DEF        VAR rel_vllimpro AS DECIMAL                               NO-UNDO.
DEF        VAR rel_vllimdsc AS DECIMAL                               NO-UNDO.

DEF        VAR rel_vlsalari AS DECIMAL                               NO-UNDO.
DEF        VAR rel_vlsalcon AS DECIMAL                               NO-UNDO.
DEF        VAR rel_vloutras AS DECIMAL                               NO-UNDO.
DEF        VAR rel_txjurmor AS DECIMAL DECIMALS 7                    NO-UNDO.

DEF        VAR rel_vlaplica AS DECIMAL                               NO-UNDO.
DEF        VAR rel_vlprepla AS DECIMAL                               NO-UNDO.
DEF        VAR rel_vlcaptal AS DECIMAL                               NO-UNDO.
DEF        VAR rel_vlsmdtri AS DECIMAL                               NO-UNDO.
DEF        VAR rel_dsdebens AS CHAR    EXTENT 2                      NO-UNDO.
DEF        VAR rel_dsobserv AS CHAR    EXTENT 4                      NO-UNDO.
DEF        VAR rel_dspreapg AS CHAR                                  NO-UNDO.
DEF        VAR rel_dstipcta AS CHAR                                  NO-UNDO.
DEF        VAR rel_telefone AS CHAR                                  NO-UNDO.
DEF        VAR rel_nmempres AS CHAR                                  NO-UNDO.
DEF        VAR rel_dsagenci AS CHAR                                  NO-UNDO.
DEF        VAR rel_dsqtdava AS CHAR                                  NO-UNDO.
DEF        VAR rel_ddmvtolt AS INT                                   NO-UNDO.
DEF        VAR rel_dsmesref AS CHAR                                  NO-UNDO.
DEF        VAR rel_aamvtolt AS INT                                   NO-UNDO.
DEF        VAR rel_dsctremp AS CHAR                                  NO-UNDO.
DEF        VAR rel_dsdmoeda AS CHAR    EXTENT 2 INIT "R$"            NO-UNDO.
DEF        VAR rel_dsmvtolt AS CHAR    EXTENT 2                      NO-UNDO.
DEF        VAR rel_dspreemp AS CHAR    EXTENT 2                      NO-UNDO.
DEF        VAR rel_nmprimtl AS CHAR    EXTENT 2                      NO-UNDO.
DEF        VAR rel_dscpfcgc AS CHAR                                  NO-UNDO.
DEF        VAR rel_dscpfav1 AS CHAR                                  NO-UNDO.
DEF        VAR rel_dscpfav2 AS CHAR                                  NO-UNDO.
DEF        VAR rel_nrdconta AS INT                                   NO-UNDO.
DEF        VAR rel_dsendcor AS CHAR    EXTENT 2                      NO-UNDO.
DEF        VAR rel_nmdaval1 AS CHAR                                  NO-UNDO.
DEF        VAR rel_nmdaval2 AS CHAR                                  NO-UNDO.
DEF        VAR rel_nmdcjav1 AS CHAR                                  NO-UNDO.
DEF        VAR rel_nmdcjav2 AS CHAR                                  NO-UNDO.
DEF        VAR rel_dscfcav1 AS CHAR                                  NO-UNDO.
DEF        VAR rel_dscfcav2 AS CHAR                                  NO-UNDO.
DEF        VAR rel_dsendav1 AS CHAR    EXTENT 2                      NO-UNDO.
DEF        VAR rel_dsendav2 AS CHAR    EXTENT 2                      NO-UNDO.

DEF        VAR aux_dsobsvar AS CHAR                                  NO-UNDO.
DEF        VAR aux_dsemsnot AS CHAR                                  NO-UNDO.
DEF        VAR aux_nrcpfava AS CHAR    FORMAT "x(23)"                NO-UNDO.
DEF        VAR aux_dsmesref AS CHAR                                  NO-UNDO.
DEF        VAR aux_dtvencto AS DATE                                  NO-UNDO.
DEF        VAR aux_nmcidpac AS CHAR                                  NO-UNDO.
DEF        VAR aux_vlpreemp AS DECIMAL                               NO-UNDO.

DEF        VAR aux_dsdtraco AS CHAR                                  NO-UNDO.
DEF        VAR aux_cabobser AS CHAR                                  NO-UNDO.
DEF        VAR aux_dsobserv LIKE crapprp.dsobserv                    NO-UNDO.
DEF        VAR aux_qtobserv AS INTE                                  NO-UNDO.
DEF        VAR aux_ocobserv AS INTE                                  NO-UNDO.

DEF        VAR rel_vlmaichq AS DECIMAL                               NO-UNDO.
DEF        VAR rel_vlmedchq AS DECIMAL                               NO-UNDO.
DEF        VAR rel_vltotchq AS DECIMAL                               NO-UNDO.
DEF        VAR rel_vltotliq AS DECIMAL                               NO-UNDO.
DEF        VAR rel_qttotchq AS INT                                   NO-UNDO.
DEF        VAR rel_qtrestri AS INT                                   NO-UNDO.

DEF        VAR aux_flgescra AS LOGICAL                               NO-UNDO.

DEF        VAR rel_dsempres AS CHAR                                  NO-UNDO.
DEF        VAR rel_dsendres AS CHAR                                  NO-UNDO.
DEF        VAR rel_nrdofone AS CHAR                                  NO-UNDO.
DEF        VAR rel_nrcpfcgc AS CHAR                                  NO-UNDO.
DEF        VAR rel_dslimpro AS CHAR                                  NO-UNDO.
DEF        VAR rel_dssitlli AS CHAR                                  NO-UNDO.
DEF        VAR rel_dsmotivo AS CHAR                                  NO-UNDO.
DEF        VAR rel_nrdocnpj AS CHAR                                  NO-UNDO.

DEF        VAR aux_nmresage AS CHAR                                  NO-UNDO.

DEF        VAR lim_vlaplica AS DECI                                  NO-UNDO.
DEF        VAR lim_nmoperad AS CHAR                                  NO-UNDO.
DEF        VAR lim_dsempres AS CHAR                                  NO-UNDO.

DEF        VAR rel_nmcheque AS CHAR                                  NO-UNDO.

DEF        VAR rel_qtdprazo AS INT                                   NO-UNDO.
DEF        VAR rel_numconta AS INT                                   NO-UNDO.
DEF        VAR rel_txdanual AS DECIMAL DECIMALS 6                    NO-UNDO.
DEF        VAR rel_txmensal AS DECIMAL DECIMALS 6                    NO-UNDO.
DEF        VAR rel_txdiaria AS DECIMAL DECIMALS 7                    NO-UNDO.

DEF        VAR rel_vlslddsc AS DECIMAL                               NO-UNDO.
DEF        VAR rel_vlmeddsc AS DECIMAL                               NO-UNDO.
DEF        VAR rel_vlmaxdsc AS DECIMAL                               NO-UNDO.
DEF        VAR rel_qtdscsld AS INTEGER                               NO-UNDO.

DEF        VAR rel_nmrescop AS CHAR    EXTENT 2                      NO-UNDO.
DEF        VAR aux_qtpalavr AS INTE                                  NO-UNDO.
DEF        VAR aux_contapal AS INTE                                  NO-UNDO.
DEF        VAR aux_tpdocged AS INTE                                  NO-UNDO.
DEF        VAR aux_qtregist AS INTE                                  NO-UNDO.

DEF        VAR h-b1wgen0002 AS HANDLE                                NO-UNDO.


/*  Configuracao da impressora .............................................. */

FORM "\022\024\033\120\033\017\0330\033x0" WITH NO-BOX NO-LABELS FRAME f_config.

FORM rel_nmextcop FORMAT "x(70)"
     SKIP(1)
     WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_coop.

/*  Cabecalhos .............................................................. */

FORM "BORDERO DE DESCONTO DE CHEQUES E TERMO DE CUSTODIA"
     "PARA USO DA DIGITALIZACAO"                            AT  87
     SKIP(1)
     crapass.nrdconta                   FORMAT "zzzz,zzz,9" AT  86
     crapbdc.nrborder                   FORMAT "z,zzz,zz9"  AT 103
     aux_tpdocged                       FORMAT "zz9"        AT 117
     SKIP(1)
     WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_cab_bordero.

FORM "DEMONSTRATIVO PARA ANALISE DE DESCONTO DE CHEQUES"
     "PARA USO DA DIGITALIZACAO"              AT 88
     SKIP(1)
     crapass.nrdconta     NO-LABEL FORMAT "zzzz,zzz,9" AT 87
     crapbdc.nrborder     NO-LABEL FORMAT "z,zzz,zz9"  AT 104
     aux_tpdocged         NO-LABEL FORMAT "zz9"        AT 118
     SKIP(1)
     WITH NO-BOX WIDTH 132 FRAME f_cab_analise.

/*  Cheques descontados ..................................................... */

FORM crapass.nrdconta AT  1 LABEL "Conta/dv" "-" crapass.nmprimtl 
     "PA:" crapass.cdagenci
     SKIP(1)
     crapbdc.nrborder AT  1 LABEL "Bordero"
     craplim.nrctrlim AT 23 LABEL "Contrato"
     craplim.vllimite AT 45 LABEL "Limite"
     "Taxa aplicada:" AT 69
     rel_txdanual     AT 84 NO-LABEL FORMAT "z9.999999" "% aa,"
     rel_txmensal           NO-LABEL FORMAT "z9.999999" "% am,"
     rel_txdiaria           NO-LABEL FORMAT "9.9999999" "% ad"
     SKIP(1)
     "CHEQUES ENTREGUES PARA DESCONTO E CUSTODIA:"
     SKIP(1)
     "Bom Para   Cmp Bco  Ag.        Conta  Cheque" AT  1
     "Valor  Valor Liquido Prz Emitente"            AT 55
     SKIP(1)
     WITH NO-BOX NO-LABELS SIDE-LABELS WIDTH 132 FRAME f_identifica.

DEF FRAME f_cheques
    crapcdb.dtlibera AT   1 FORMAT "99/99/9999"
    crapcdb.cdcmpchq AT  12 FORMAT "999"
    crapcdb.cdbanchq AT  16 FORMAT "999"
    crapcdb.cdagechq AT  20 FORMAT "9999"
    crapcdb.nrctachq AT  24 FORMAT "zzzzzzz,zzz,9"
    crapcdb.nrcheque AT  38 FORMAT "zzz,zz9"
    crapcdb.vlcheque AT  46 FORMAT "zzz,zzz,zz9.99"
    crapcdb.vlliquid AT  61 FORMAT "zzz,zzz,zz9.99-"
    rel_qtdprazo     AT  76 FORMAT "zz9"
    rel_nmcheque     AT  80 FORMAT "x(32)"
    rel_dscpfcgc     AT 113 FORMAT "x(19)"
    WITH NO-BOX WIDTH 132 NO-LABELS DOWN.

DEF FRAME f_total
    SKIP(2)
    "TOTAL ==>"      AT  1
    rel_qttotchq     AT 12 FORMAT "z,zz9" "CHEQUES"
    rel_qtrestri     AT 27 FORMAT "z,zz9" "RESTRICOES"
    rel_vltotchq     AT 46 FORMAT "zzz,zzz,zz9.99"
    rel_vltotliq     AT 61 FORMAT "zzz,zzz,zz9.99-" 
    " CHQ. MAIOR:"
    rel_vlmaichq           FORMAT "zzz,zzz,zz9.99"
    " VLR. MEDIO:"
    rel_vlmedchq           FORMAT "zz,zzz,zz9.99"     
    SKIP(1)
    WITH NO-BOX NO-LABELS WIDTH 132.

/*  Restricoes .............................................................. */

FORM "===>"
     crapabc.dsrestri FORMAT "x(60)"
     "Obs.:"          AT 80
     crapabc.dsobserv FORMAT "x(40)"
     WITH NO-BOX NO-LABELS DOWN WIDTH 132 FRAME f_restricoes.

FORM aux_dsdtraco FORMAT "x(132)"
     WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_traco.

FORM SKIP(3)
     rel_nmcidade AT 1 "," rel_ddmvtolt FORMAT "99" "de" 
     rel_dsmesref FORMAT "x(9)"
     "de" rel_aamvtolt FORMAT "9999" SKIP(5)
     "___________________________________________" AT  1 
     "___________________________________________" AT 90 SKIP
     crapass.nmprimtl AT  1 FORMAT "x(50)"
     "Operador:"      AT 90 glb_nmoperad FORMAT "x(32)" SKIP(5)
     "___________________________________________" AT 1 SKIP  
     rel_nmrescop[1] FORMAT "x(40)" AT 1 SKIP
     rel_nmrescop[2] FORMAT "x(40)" AT 1
     SKIP(5)
     "___________________________________________" AT 1
     "___________________________________________" AT 90 SKIP
     "Testemunha" AT 1  
     "Testemunha" AT 90
     WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_final.

/*  Proposta de Limite de descontos de cheques .............................. */

FORM crapcop.nmextcop FORMAT "x(50)"
     SKIP(1)
     "\033\016PROPOSTA DE DESCONTO DE CHEQUES\024"
     "PARA USO DA DIGITALIZACAO" AT 65
     SKIP(1)
     rel_numconta     FORMAT "zzzz,zzz,9" AT 65
     crapbdc.nrborder FORMAT "z,zzz,zz9"  AT 78
     aux_tpdocged     FORMAT "zz9"        AT 90
     SKIP(1)
     "\033\105\DADOS DO ASSOCIADO\033\106"
     SKIP(1)
     "Conta/dv:\033\016" rel_nrdconta FORMAT "zzzz,zzz,9" "\024"
     "Matricula:" AT 27 crapass.nrmatric FORMAT "zzz,zz9"
     "PA:"        AT 54 rel_dsagenci FORMAT "x(25)"
     SKIP(1)
     "Nome    :" rel_nmprimtl[1] FORMAT "x(50)"
     "Adm COOP:" AT 76 crapass.dtadmiss FORMAT "99/99/9999"
     SKIP(1)
     "Empresa :" rel_nmempres FORMAT "x(35)"
     "Adm empr:" AT 76 crapass.dtadmemp FORMAT "99/99/9999"
     SKIP(1)
     "Fone/Ramal:" AT 42 rel_telefone FORMAT "x(20)"
     SKIP(1)
     "Tipo de Conta:" rel_dstipcta FORMAT "x(25)"
     "Situacao da Conta:" AT 67 crapass.cdsitdct FORMAT "zz9"
     SKIP(1)
     "Ramo de Atividade:" crapprp.dsramati                  
     SKIP(2)
     WITH NO-BOX NO-LABELS WIDTH 96 FRAME f_pro_dados.

FORM "\033\105RECIPROCIDADE\033\106"
     "Saldo Medio do Trimestre:" AT 20 rel_vlsmdtri FORMAT "zzz,zzz,zz9.99"
     "Capital:"                  AT 77 rel_vlcaptal FORMAT "zzz,zzz,zz9.99-"
     SKIP(1)
     "Plano:"                          rel_vlprepla FORMAT "zzz,zzz,zz9.99"
     "Aplicacoes:"               AT 70 rel_vlaplica FORMAT "zzz,zzz,zz9.99"
     SKIP(2)
     "\033\105RENDA MENSAL\033\106"
     "Salario:"                  AT 31 rel_vlsalari FORMAT "zzz,zzz,zz9.99"
     "Salario do Conjuge:"       AT 66 rel_vlsalcon FORMAT "zzz,zzz,zz9.99" 
     SKIP(1)
     "Faturamento Mensal:"       AT 16 crapprp.vlfatura
     "Outras:"                   AT 74 rel_vloutras FORMAT "zzz,zzz,zz9.99"
     SKIP(2)
     "\033\105LIMITES\033\106"
     "Cheque Especial:"      AT 16 crapass.vllimcre FORMAT "zzz,zzz,zzz,zz9.99"
     "Cartoes de Credito:"   AT 66 aux_vltotccr     FORMAT "zzz,zzz,zz9.99"
     SKIP
     "Desconto de Cheques:"  AT 12 rel_vllimdsc     FORMAT "zzz,zzz,zz9.99"
     SKIP(2)
     "\033\105BENS:\033\106"
     rel_dsdebens[1] AT 12 FORMAT "x(85)" SKIP
     rel_dsdebens[2] AT 08 FORMAT "x(85)" SKIP
     SKIP(1)
     "\033\105DESCONTO PROPOSTO:\033\106"
     " \033\016" rel_vltotchq FORMAT "zzz,zzz,zz9.99" 
     "\024" "(\033\016" rel_qttotchq FORMAT "zz,zz9" "\024" "Cheques )"
      /*
     "\033\105LIMITE PROPOSTO\033\106"
     SKIP(1)
     "    Contrato           Valor   Linha de desconto"
     "Valor Medio do Cheque" AT 66
     SKIP(1)   */
     WITH NO-BOX NO-LABELS WIDTH 130 FRAME f_pro_rec.
     
FORM rel_nrctrlim FORMAT "z,zzz,zz9" AT 4
     rel_vllimpro FORMAT "zzzz,zzz,zz9.99" " "
     rel_dsdlinha FORMAT "x(40)"   
     crapprp.vlmedchq 
     WITH NO-BOX NO-LABELS WIDTH 130 DOWN FRAME f_lim_pro.
       
FORM SKIP(1)
     "\033\105SEM ENDIVIDAMENTO NA COOPERATIVA DE CREDITO\033\106" SKIP(2)
     WITH NO-BOX WIDTH 96 FRAME f_sem_divida.

FORM SKIP(2)
     "\033\105ENDIVIDAMENTO NA COOPERATIVA DE CREDITO EM"
     tel_dtcalcul FORMAT "99/99/9999" "\033\106"     
     SKIP(1)
     "Saldo do Desconto:" 
     rel_vlslddsc FORMAT "zzz,zzz,zz9.99"
     rel_qtdscsld FORMAT "zz,zz9"
     "Cheques"           
     "Maior Cheque:" AT 60      
     rel_vlmaxdsc FORMAT "zzz,zzz,zz9.99"      
     SKIP
     "Valor Medio:"  AT 61
     rel_vlmeddsc FORMAT "zzz,zzz,zz9.99" 
     SKIP(1)
     " Contrato  Saldo Devedor Prestacoes"
     "Linha de Credito  Finalidade" AT 51
     SKIP(1)
     WITH NO-BOX NO-LABELS WIDTH 96 FRAME f_pro_ed1.
                                                                  
FORM tt-dados-epr.nrctremp AT  1 FORMAT "zz,zzz,zz9"
     tt-dados-epr.vlsdeved AT 12 FORMAT "zzz,zzz,zz9.99"
     rel_dspreapg          AT 27 FORMAT "x(11)"
     tt-dados-epr.vlpreemp AT 39 FORMAT "zzzz,zz9.99"
     "\033\017"
     tt-dados-epr.dslcremp FORMAT "x(30)"
     tt-dados-epr.dsfinemp FORMAT "x(28)"
     "\022\033\115"
     WITH NO-BOX NO-LABELS DOWN WIDTH 120 FRAME f_dividas.

FORM "--------------            ------------" AT 11
     SKIP
     tot_vlsdeved     AT 11 FORMAT "zzz,zzz,zz9.99"
     tot_vlpreemp     AT 37 FORMAT "zzzzz,zz9.99"
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

FORM rel_dsobserv[1]   AT 1 FORMAT "x(94)"
     SKIP
     rel_dsobserv[2]   AT 1 FORMAT "x(94)"
     SKIP
     rel_dsobserv[3]   AT 1 FORMAT "x(94)"
     SKIP
     rel_dsobserv[4]   AT 1 FORMAT "x(94)"
     WITH NO-BOX NO-LABELS WIDTH 120 DOWN FRAME f_observac.

FORM 
     "\033\105A P R O V A C A O\033\106"
     SKIP(2)
     "___________________________________________" AT  4
     "______________________________________" AT 55 SKIP
     rel_nmprimtl[1] AT 4 FORMAT "x(50)"
     "Operador:" AT 55 glb_nmoperad FORMAT "x(30)"
     SKIP(3)
     "___________________________________________" AT  4
     rel_nmcidade "," AT 60 rel_ddmvtolt FORMAT "99" "de" 
     rel_dsmesref FORMAT "x(9)"
     "de" rel_aamvtolt FORMAT "9999" SKIP
     rel_nmrescop[1] FORMAT "x(40)" AT 4 SKIP
     rel_nmrescop[2] FORMAT "x(40)" AT 4
     SKIP(4)
     "___________________________________________" AT 4
     "___________________________________________" AT 50 SKIP
     "Testemunha" AT 4
     "Testemunha" AT 50 SKIP
     WITH NO-BOX NO-LABELS WIDTH 96 FRAME f_aprovacao.

FORM SKIP(5)
     WITH NO-BOX WIDTH 137 FRAME f_linhas.

ASSIGN aux_dsmesref = "Janeiro,Fevereiro,Marco,Abril,Maio,Junho," +
                      "Julho,Agosto,Setembro,Outubro,Novembro,Dezembro"

       aux_dsdtraco = FILL("-",132).     

IF   tel_dtcalcul = ?   THEN
     tel_dtcalcul = glb_dtmvtolt.

/*  Busca dados da cooperativa  */

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         RETURN.
     END.
 
ASSIGN rel_nmcidade = TRIM(crapcop.nmcidade).

RUN p_divinome.

/* .......................................................................... */

FIND crapbdc WHERE RECID(crapbdc) = par_recid NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapbdc   THEN
     RETURN.

IF   par_insitbdc = 0   THEN
     par_insitbdc = crapbdc.insitbdc.
               /*
IF   crapbdc.dtlibbdc <> ?   THEN
     IF   crapbdc.dtlibbdc < glb_dtmvtolt   THEN
          IF   glb_cdoperad <> "1"   THEN
               IF   glb_cdcooper = 1   AND
                    CAN-DO("35,79,108",glb_cdoperad)   THEN .
               ELSE
                    RETURN.
                 */

/*  Verifica se ha contrato de limite de desconto ativo  */
      
FIND FIRST craplim WHERE craplim.cdcooper = glb_cdcooper       AND
                         craplim.nrdconta = crapbdc.nrdconta   AND
                         craplim.tpctrlim = 2                  AND
                         craplim.insitlim = 2                  NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craplim   THEN
     DO:
         glb_cdcritic = 90.
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         RETURN.
     END.

FIND crapprp WHERE crapprp.cdcooper = glb_cdcooper      AND
                   crapprp.nrdconta = craplim.nrdconta  AND
                   crapprp.nrctrato = craplim.nrctrlim  AND
                   crapprp.tpctrato = 2                 NO-LOCK NO-ERROR.
        
IF   NOT AVAILABLE crapprp THEN
     DO:
         glb_cdcritic = 484.
         RUN  fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         glb_cdcritic = 0.
         RETURN.
     END.

/***** Dados do associado *******/

FIND crapass WHERE crapass.cdcooper = glb_cdcooper      AND  
                   crapass.nrdconta = craplim.nrdconta  NO-LOCK NO-ERROR.

IF  AVAILABLE crapass  THEN
    DO:
        IF   crapass.inpessoa = 1   THEN 
             DO:
                 FIND crapttl WHERE crapttl.cdcooper = glb_cdcooper       AND
                                    crapttl.nrdconta = crapass.nrdconta   AND
                                    crapttl.idseqttl = 1 NO-LOCK NO-ERROR.

                 IF   AVAIL crapttl  THEN 
                      ASSIGN aux_cdempres = crapttl.cdempres.
                      
                 ASSIGN rel_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999")
                        rel_nrcpfcgc = STRING(rel_nrcpfcgc,
                                              "    xxx.xxx.xxx-xx").
             END.
        ELSE
             DO:
                 FIND crapjur WHERE crapjur.cdcooper = glb_cdcooper  AND
                                    crapjur.nrdconta = crapass.nrdconta
                                    NO-LOCK NO-ERROR.

                 IF   AVAIL crapjur  THEN
                      ASSIGN aux_cdempres = crapjur.cdempres.
                      
                 ASSIGN rel_nrcpfcgc = STRING(crapass.nrcpfcgc,
                                              "99999999999999")
                        rel_nrcpfcgc = STRING(rel_nrcpfcgc,
                                              "xx.xxx.xxx/xxxx-xx").
                                              
             END.
    END.
ELSE
     DO:
         ASSIGN glb_cdcritic = 009.
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         RETURN.
     END.

/*FIND crapemp OF crapass NO-LOCK NO-ERROR.*/

FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper      AND
                   crapemp.cdempres = aux_cdempres   NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapemp   THEN
     rel_nmempres = STRING(aux_cdempres,"99999") + " - NAO CADASTRADA.".     
ELSE
     rel_nmempres = STRING(aux_cdempres,"99999") + " - " + crapemp.nmresemp. 

FIND FIRST craptfc WHERE craptfc.cdcooper = glb_cdcooper     AND
                         craptfc.nrdconta = crapass.nrdconta AND
                         craptfc.idseqttl = 1                NO-LOCK NO-ERROR.
IF AVAIL craptfc THEN
   DO:
       IF craptfc.nrtelefo <> 9999 AND craptfc.nrtelefo <> 0 THEN
          DO:
              IF craptfc.nrdddtfc <> 0 THEN
                 ASSIGN rel_telefone = "(" + STRING(craptfc.nrdddtfc) + ") ".
                  
              ASSIGN rel_telefone = rel_telefone + STRING(craptfc.nrtelefo).
          END.
       ELSE
          ASSIGN rel_telefone = STRING(craptfc.nrdramal,"9,999").
   END.
ELSE
   ASSIGN rel_telefone = "".

ASSIGN rel_nmprimtl = crapass.nmprimtl
       rel_nrdconta = crapass.nrdconta
       rel_nrcpfcgc = TRIM(rel_nrcpfcgc)

       rel_txdiaria = ROUND((EXP(1 + (crapbdc.txmensal / 100),
                                         1 / 30) - 1) * 100,7)
                                         
       rel_txdanual = ROUND((EXP(1 + (crapbdc.txmensal / 100),
                                         12) - 1) * 100,6)
                                         
       rel_txmensal = crapbdc.txmensal

       rel_ddmvtolt = DAY(glb_dtmvtolt)
       rel_aamvtolt = YEAR(glb_dtmvtolt)
       rel_dsmesref = ENTRY(MONTH(glb_dtmvtolt),aux_dsmesref)
       
       rel_nmextcop = TRIM(crapcop.nmextcop).
                                                         
/* .......................................................................... */

/**** Verificacao do saldo atual do desconto de cheques ****/

ASSIGN rel_vlslddsc = 0
       rel_qtdscsld = 0
       rel_vlmaxdsc = 0.
       
FOR EACH crapcdb WHERE crapcdb.cdcooper = glb_cdcooper  AND
                       crapcdb.nrdconta = tel_nrdconta  AND
                       crapcdb.dtlibera > glb_dtmvtolt  AND
                       crapcdb.insitchq = 2             NO-LOCK
                       USE-INDEX crapcdb2:

    ASSIGN rel_vlslddsc = rel_vlslddsc + crapcdb.vlcheque
           rel_qtdscsld = rel_qtdscsld + 1
           rel_vlmaxdsc = IF crapcdb.vlcheque > rel_vlmaxdsc THEN
                             crapcdb.vlcheque
                          ELSE
                             rel_vlmaxdsc.
                 
END.  /*  Fim do FOR EACH crapcdb  */

IF   (rel_vlslddsc = 0) OR (rel_qtdscsld = 0)   THEN
     rel_vlmeddsc = 0. 
ELSE
     rel_vlmeddsc = ROUND(rel_vlslddsc / rel_qtdscsld, 2).

/* .......................................................................... */

INPUT THROUGH basename `tty` NO-ECHO.

SET aux_nmendter WITH FRAME f_terminal.

INPUT CLOSE.

aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                      aux_nmendter.

UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").

ASSIGN par_flgrodar = TRUE
       aux_nmarqimp = "rl/" + aux_nmendter + STRING(TIME) + ".ex".

FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND         
                   craptab.nmsistem = "CRED"         AND         
                   craptab.tptabela = "GENERI"       AND         
                   craptab.cdempres = 00             AND         
                   craptab.cdacesso = "DIGITALIZA"   AND
                   craptab.tpregist = 2    /* Contrato Desc. Cheque. (GED) */
                   NO-LOCK NO-ERROR NO-WAIT.
        
IF  AVAIL craptab THEN
    ASSIGN aux_tpdocged = INT(ENTRY(3,craptab.dstextab,";")).

OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) APPEND PAGED PAGE-SIZE 80.
ASSIGN tel_contrato = "Cheques".

DISPLAY tel_completa  tel_contrato  tel_proposta  tel_dscancel
        WITH FRAME f_imprime.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   CHOOSE FIELD tel_completa tel_contrato tel_proposta  tel_dscancel
                WITH FRAME f_imprime.

   IF   FRAME-VALUE = tel_completa   THEN
        DO:
            IF   glb_cdcooper = 1   AND
                 glb_nmdafila = "FINANCEIRO"   THEN
                 DO:
                     MESSAGE "Imprima a Proposta na impressora CAIXAS e".
                     MESSAGE "os cheques na impressora FINANCEIRO.".
                     NEXT.
                 END.
                 
            RUN p_cheques(INPUT FALSE).
            VIEW STREAM str_1 FRAME f_config.
            RUN p_cheques(INPUT TRUE).
        END.
   ELSE
   IF   FRAME-VALUE = tel_contrato   THEN
        DO:
            RUN p_cheques(INPUT TRUE).
        END.
   ELSE
   IF   FRAME-VALUE = tel_proposta   THEN
        DO:
            IF   glb_cdcooper = 1   AND
                 glb_nmdafila = "FINANCEIRO"   THEN
                 DO:
                     MESSAGE "A proposta NAO pode ser impressa"
                             "nesta impressora.".
                     NEXT.
                 END.
            
            RUN p_cheques(INPUT FALSE).
            RUN p_proposta.
        END.
   ELSE
   IF   FRAME-VALUE = tel_dscancel   THEN
        DO:
            HIDE FRAME f_imprime NO-PAUSE.
            HIDE MESSAGE NO-PAUSE.
            RETURN.
        END.

   LEAVE.
         
END.  /*  Fim do DO WHILE TRUE  */

IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN   /*   F4 OU FIM   */
     DO:
         HIDE FRAME f_imprime NO-PAUSE.
         HIDE MESSAGE NO-PAUSE.
         RETURN.
     END.

OUTPUT STREAM str_1 CLOSE.

VIEW FRAME f_aguarde_cheques.
PAUSE 3 NO-MESSAGE.
HIDE FRAME f_aguarde_cheques NO-PAUSE.

{ includes/impressao.i }

/* .......................................................................... */

PROCEDURE p_cheques:

    DEF INPUT PARAMETER par_imprimir   AS LOGICAL                     NO-UNDO.

    DO aux_contador = 1 TO 1:

       IF   par_imprimir   THEN
            DO:
                PAGE STREAM str_1.
       
                DISPLAY STREAM str_1 rel_nmextcop WITH FRAME f_coop.

                IF   par_insitbdc = 2   THEN         /*  Em analise  */
                    DISPLAY STREAM str_1 
                                   crapass.nrdconta NO-LABEL
                                   crapbdc.nrborder NO-LABEL
                                   aux_tpdocged
                                   NO-LABEL WITH FRAME f_cab_analise.
                ELSE
                     DISPLAY STREAM str_1 
                                    crapass.nrdconta
                                    crapbdc.nrborder
                                    aux_tpdocged
                                    WITH FRAME f_cab_bordero.

                DISPLAY STREAM str_1
                        crapass.nrdconta  crapass.nmprimtl 
                        crapass.cdagenci
                        crapbdc.nrborder  craplim.nrctrlim
                        craplim.vllimite  rel_txdanual 
                        rel_txmensal      rel_txdiaria        
                        WITH FRAME f_identifica.

            END.
             
       ASSIGN rel_vltotchq = 0
              rel_vltotliq = 0
              rel_qttotchq = 0
              rel_qtrestri = 0.
 
/*     FOR EACH crapcdb WHERE crapcdb.cdcooper = glb_cdcooper       AND
                              crapcdb.dtmvtolt = crapbdc.dtmvtolt   AND
                              crapcdb.cdagenci = crapbdc.cdagenci   AND
                              crapcdb.cdbccxlt = crapbdc.cdbccxlt   AND
                              crapcdb.nrdolote = crapbdc.nrdolote   NO-LOCK
                              USE-INDEX crapcdb4:
*/  
       FOR EACH crapcdb WHERE crapcdb.cdcooper = glb_cdcooper       AND
                              crapcdb.nrborder = crapbdc.nrborder   AND
                              crapcdb.nrdconta = crapbdc.nrdconta   NO-LOCK 
                              USE-INDEX crapcdb7
                                      BY crapcdb.dtlibera 
                                         BY crapcdb.cdbanchq
                                            BY crapcdb.cdagechq
                                               BY crapcdb.nrctachq 
                                                  BY crapcdb.nrcheque:

           ASSIGN rel_vltotchq = rel_vltotchq + crapcdb.vlcheque
                  rel_qttotchq = rel_qttotchq + 1.
 
           IF   NOT par_imprimir   THEN
                NEXT.
                
           FIND FIRST crapcec WHERE crapcec.cdcooper = glb_cdcooper     AND
                                    crapcec.cdcmpchq = crapcdb.cdcmpchq AND 
                                    crapcec.cdbanchq = crapcdb.cdbanchq AND
                                    crapcec.cdagechq = crapcdb.cdagechq AND
                                    crapcec.nrctachq = crapcdb.nrctachq AND
                                    crapcec.nrcpfcgc = crapcdb.nrcpfcgc 
                                    NO-LOCK NO-ERROR.
           
           IF   NOT AVAILABLE crapcec   THEN
                ASSIGN rel_dscpfcgc = "NAO CADASTRADO"
                       rel_nmcheque = "NAO CADASTRADO".
           ELSE
                RUN p_monta_cpfcgc.

           IF   crapcdb.vlcheque > rel_vlmaichq   THEN
                rel_vlmaichq = crapcdb.vlcheque.
   
           ASSIGN rel_vltotliq = rel_vltotliq + crapcdb.vlliquid
                  rel_qtdprazo = IF crapbdc.dtlibbdc = ?   
                                    THEN crapcdb.dtlibera - glb_dtmvtolt
                                    ELSE crapcdb.dtlibera - crapbdc.dtlibbdc.
       
           DISPLAY STREAM str_1
                   crapcdb.dtlibera  crapcdb.cdcmpchq  crapcdb.cdbanchq
                   crapcdb.cdagechq  crapcdb.nrctachq  crapcdb.nrcheque
                   crapcdb.vlcheque  crapcdb.vlliquid  rel_qtdprazo
                   rel_nmcheque      rel_dscpfcgc
                   WITH FRAME f_cheques.
                
           DOWN STREAM str_1 WITH FRAME f_cheques.

           IF   LINE-COUNTER(str_1) >  PAGE-SIZE(str_1)   THEN
                DO:
                    PAGE STREAM str_1.
                    
                    DISPLAY STREAM str_1 rel_nmextcop WITH FRAME f_coop.

                    IF   par_insitbdc = 2   THEN     /*  Em analise  */
                         DISPLAY STREAM str_1 
                                        crapass.nrdconta 
                                        crapbdc.nrborder 
                                        aux_tpdocged
                                        WITH FRAME f_cab_analise.
                    ELSE
                         DISPLAY STREAM str_1
                                        crapass.nrdconta
                                        crapbdc.nrborder
                                        aux_tpdocged
                                        WITH FRAME f_cab_bordero.

                    DISPLAY STREAM str_1
                            crapass.nrdconta  crapass.nmprimtl 
                            crapass.cdagenci
                            crapbdc.nrborder  craplim.nrctrlim
                            craplim.vllimite  rel_txdanual 
                            rel_txmensal      rel_txdiaria        
                            WITH FRAME f_identifica.
                END.
                /*
           IF   aux_contador <> 1   THEN       /* 1 = VIA DO ASSOCIADO  */
             */ DO:     
                    /*  Leitura das restricoes para o cheque  */

                    FOR EACH crapabc WHERE
                             crapabc.cdcooper = glb_cdcooper       AND
                             crapabc.nrborder = crapbdc.nrborder   AND
                             crapabc.cdagechq = crapcdb.cdagechq   AND
                             crapabc.cdbanchq = crapcdb.cdbanchq   AND
                             crapabc.cdcmpchq = crapcdb.cdcmpchq   AND
                             crapabc.nrctachq = crapcdb.nrctachq   AND
                             crapabc.nrcheque = crapcdb.nrcheque   NO-LOCK:

                        DISPLAY STREAM str_1 
                                crapabc.dsrestri crapabc.dsobserv
                                WITH FRAME f_restricoes.

                        DOWN STREAM str_1 WITH FRAME f_restricoes.

                        rel_qtrestri = rel_qtrestri + 1.
                        
                        IF   LINE-COUNTER(str_1) >  PAGE-SIZE(str_1)   THEN
                             DO:
                                 PAGE STREAM str_1.
                    
                                 DISPLAY STREAM str_1 rel_nmextcop 
                                                WITH FRAME f_coop.

                                 IF   par_insitbdc = 2   THEN /*  Em analise  */
                                      DISPLAY STREAM str_1 
                                                     crapass.nrdconta 
                                                     crapbdc.nrborder 
                                                     aux_tpdocged 
                                                     WITH FRAME f_cab_analise.
                                 ELSE
                                      DISPLAY STREAM str_1 
                                                     crapass.nrdconta
                                                     crapbdc.nrborder
                                                     aux_tpdocged
                                                     WITH FRAME f_cab_bordero.

                                 DISPLAY STREAM str_1
                                         crapass.nrdconta  crapass.nmprimtl
                                         crapass.cdagenci
                                         crapbdc.nrborder  craplim.nrctrlim
                                         craplim.vllimite  rel_txdanual 
                                         rel_txmensal      rel_txdiaria        
                                         WITH FRAME f_identifica.
                             END.
        
                    END.  /*  Fim do FOR EACH -- Leitura das restricoes  */
                END.
           
           DISPLAY STREAM str_1 aux_dsdtraco WITH FRAME f_traco.  

           IF   LINE-COUNTER(str_1) >  PAGE-SIZE(str_1)   THEN
                DO:
                    PAGE STREAM str_1.
                    
                    DISPLAY STREAM str_1 rel_nmextcop WITH FRAME f_coop.

                    IF   par_insitbdc = 2   THEN     /*  Em analise  */
                         DISPLAY STREAM str_1 
                                        crapass.nrdconta 
                                        crapbdc.nrborder 
                                        aux_tpdocged
                                        WITH FRAME f_cab_analise.
                    ELSE
                         DISPLAY STREAM str_1
                                     crapass.nrdconta
                                     crapbdc.nrborder
                                     aux_tpdocged
                                     WITH FRAME f_cab_bordero.

                    DISPLAY STREAM str_1
                            crapass.nrdconta  crapass.nmprimtl
                            crapass.cdagenci
                            crapbdc.nrborder  craplim.nrctrlim
                            craplim.vllimite  rel_txdanual 
                            rel_txmensal      rel_txdiaria        
                            WITH FRAME f_identifica.
                END.
           
       END.  /*  Fim do FOR EACH  */                       

       IF   NOT par_imprimir   THEN
            NEXT.
            
       /*  Restricoes GERAIS ................................................ */
       
       FOR EACH crapabc WHERE crapabc.cdcooper = glb_cdcooper       AND
                              crapabc.nrborder = crapbdc.nrborder   AND
                              crapabc.cdcmpchq = 888                AND
                              crapabc.cdagechq = 8888               AND
                              crapabc.cdbanchq = 888                AND
                              crapabc.nrctachq = 8888888888         AND
                              crapabc.nrcheque = 888888             NO-LOCK:

           DISPLAY STREAM str_1 crapabc.dsrestri crapabc.dsobserv
                                WITH FRAME f_restricoes.

           DOWN STREAM str_1 WITH FRAME f_restricoes.

           rel_qtrestri = rel_qtrestri + 1.

           IF   LINE-COUNTER(str_1) >  PAGE-SIZE(str_1)   THEN
                DO:
                    PAGE STREAM str_1.
                  
                    DISPLAY STREAM str_1 rel_nmextcop WITH FRAME f_coop.

                    IF   par_insitbdc = 2   THEN /*  Em analise  */
                         DISPLAY STREAM str_1 
                                        crapass.nrdconta 
                                        crapbdc.nrborder 
                                        aux_tpdocged
                                        WITH FRAME f_cab_analise.
                    ELSE
                         DISPLAY STREAM str_1
                                        crapass.nrdconta
                                        crapbdc.nrborder
                                        aux_tpdocged
                                        WITH FRAME f_cab_bordero.

                    DISPLAY STREAM str_1
                            crapass.nrdconta  crapass.nmprimtl 
                            crapass.cdagenci
                            crapbdc.nrborder  craplim.nrctrlim
                            craplim.vllimite  rel_txdanual 
                            rel_txmensal      rel_txdiaria        
                            WITH FRAME f_identifica.
                END.
        
       END.  /*  Fim do FOR EACH -- Leitura das restricoes GERAIS  */

       rel_vlmedchq = ROUND(rel_vltotchq / rel_qttotchq,2).

       IF   LINE-COUNTER(str_1) >  PAGE-SIZE(str_1) - 2   THEN
            DO:
                PAGE STREAM str_1.
                  
                DISPLAY STREAM str_1 rel_nmextcop WITH FRAME f_coop.

                IF   par_insitbdc = 2   THEN /*  Em analise  */
                     DISPLAY STREAM str_1 
                                    crapass.nrdconta 
                                    crapbdc.nrborder 
                                    aux_tpdocged
                                    WITH FRAME f_cab_analise.
                ELSE
                     DISPLAY STREAM str_1
                                    crapass.nrdconta
                                    crapbdc.nrborder
                                    aux_tpdocged
                                    WITH FRAME f_cab_bordero.

                DISPLAY STREAM str_1
                        crapass.nrdconta  crapass.nmprimtl  
                        crapass.cdagenci
                        crapbdc.nrborder  craplim.nrctrlim
                        craplim.vllimite  rel_txdanual 
                        rel_txmensal      rel_txdiaria        
                        WITH FRAME f_identifica.
            END.
       
       DISPLAY STREAM str_1 
               rel_qttotchq  rel_qtrestri  rel_vltotchq  rel_vltotliq 
               rel_vlmedchq  rel_vlmaichq
               WITH FRAME f_total.

       IF   LINE-COUNTER(str_1) >  PAGE-SIZE(str_1) - 17   THEN
            DO:
                PAGE STREAM str_1.
                 
                DISPLAY STREAM str_1 rel_nmextcop WITH FRAME f_coop.

                IF   par_insitbdc = 2   THEN /*  Em analise  */
                     DISPLAY STREAM str_1 
                                   crapass.nrdconta 
                                   crapbdc.nrborder 
                                   aux_tpdocged
                                   WITH FRAME f_cab_analise.
                ELSE
                     DISPLAY STREAM str_1
                                    crapass.nrdconta
                                    crapbdc.nrborder
                                    aux_tpdocged
                                    WITH FRAME f_cab_bordero.

                DISPLAY STREAM str_1
                        crapass.nrdconta  crapass.nmprimtl
                        crapass.cdagenci
                        crapbdc.nrborder  craplim.nrctrlim
                        craplim.vllimite  rel_txdanual 
                        rel_txmensal      rel_txdiaria        
                        WITH FRAME f_identifica.
            END.
       
       DISPLAY STREAM str_1 glb_nmoperad  rel_ddmvtolt
                            rel_dsmesref  rel_aamvtolt 
                            crapass.nmprimtl
                            rel_nmrescop[1]
                            rel_nmrescop[2]
                            rel_nmcidade
                            WITH FRAME f_final.

    END.  /*  Fim do DO .. TO  */

END PROCEDURE.

PROCEDURE p_proposta:

    /*  Emissao da Proposta de limite de desconto de cheques .............. */
     
    PAGE STREAM str_1.

    PUT STREAM str_1 CONTROL "\0330\033x0\022\033\115" NULL.

    FIND FIRST craptfc WHERE craptfc.cdcooper = glb_cdcooper     AND
                             craptfc.nrdconta = crapass.nrdconta AND
                             craptfc.idseqttl = 1                
                             NO-LOCK NO-ERROR.
    IF AVAIL craptfc THEN
       DO:
           IF craptfc.nrtelefo <> 9999 AND craptfc.nrtelefo <> 0 THEN
              DO:
                  IF craptfc.nrdddtfc <> 0 THEN
                     ASSIGN rel_telefone = "(" + STRING(craptfc.nrdddtfc) + ") ".
                  
                  ASSIGN rel_telefone = rel_telefone + STRING(craptfc.nrtelefo).
              END.
           ELSE
              ASSIGN rel_telefone = STRING(craptfc.nrdramal,"9,999").
              
       END.
    ELSE
       ASSIGN rel_telefone = "".

    ASSIGN rel_dstipcta    = tel_dstipcta
           rel_vlsmdtri    = tel_vlsmdtri
           rel_vlcaptal    = tel_vlcaptal
           rel_vlprepla    = tel_vlprepla
           rel_dsdebens[1] = ""
           rel_dsdebens[2] = ""
           rel_vlsalari    = crapprp.vlsalari
           rel_vlsalcon    = crapprp.vlsalcon
           rel_vloutras    = crapprp.vloutras
     
           rel_nrctrlim    = craplim.nrctrlim
           rel_vllimpro    = craplim.vllimite

           rel_vlaplica    = aux_vltotrda + aux_vltotapl + aux_vltotrpp.

 /* FIND crapage OF crapass NO-LOCK NO-ERROR. */
 
    FIND crapage WHERE crapage.cdcooper = glb_cdcooper      AND
                       crapage.cdagenci = crapass.cdagenci  NO-LOCK NO-ERROR. 
    
    IF   NOT AVAILABLE crapage   THEN
         rel_dsagenci = STRING(crapass.cdagenci,"999") + " - NAO CADASTRADO".
    ELSE     
         rel_dsagenci = STRING(crapage.cdagenci,"999") + " - " +
                        crapage.nmresage.
         
    /* Totaliza os limites de cartao de credito */

    RUN fontes/sldccr.p (INPUT FALSE).

    /*  Verifica se ha contrato de limite de desconto ativo  */
      
    FIND FIRST craplim WHERE craplim.cdcooper = glb_cdcooper       AND
                             craplim.nrdconta = crapass.nrdconta   AND
                             craplim.tpctrlim = 2                  AND
                             craplim.insitlim = 2
                             NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE craplim THEN
         rel_vllimdsc = 0.
    ELSE rel_vllimdsc = craplim.vllimite.    

    ASSIGN rel_numconta = rel_nrdconta.

    IF   AVAILABLE crapttl   THEN
         DISPLAY STREAM str_1
                 rel_nrdconta     crapass.nrmatric  rel_dsagenci
                 rel_nmprimtl[1]  crapass.dtadmemp  rel_nmempres
                 rel_telefone
                 rel_dstipcta     crapass.cdsitdct  crapass.dtadmiss
                 crapbdc.nrborder FORMAT "z,zzz,zz9"
                 rel_numconta     FORMAT "zzzz,zzz,9"
                 aux_tpdocged     FORMAT "zz9"
                 WITH FRAME f_pro_dados.
    ELSE
         DISPLAY STREAM str_1
                 rel_nrdconta           crapass.nrmatric  rel_dsagenci
                 rel_nmprimtl[1]        crapass.dtadmemp  rel_nmempres
                 rel_telefone
                 rel_dstipcta           crapass.cdsitdct  crapass.dtadmiss
                 crapcop.nmextcop       crapprp.dsramati  crapass.cdagenci
                 crapbdc.nrborder       FORMAT "z,zzz,zz9"
                 rel_numconta           FORMAT "zzzz,zzz,9"
                 aux_tpdocged           FORMAT "zz9"
                 WITH FRAME f_pro_dados.

    DISPLAY STREAM str_1
            rel_vlsmdtri      rel_vlcaptal     rel_vlprepla
            rel_vlsalari      rel_vlsalcon     rel_vloutras
            crapass.vllimcre  aux_vltotccr     rel_vlaplica 
            rel_vllimdsc      rel_dsdebens[1]  rel_dsdebens[2]  
            crapprp.vlfatura  rel_vltotchq     rel_qttotchq
            WITH FRAME f_pro_rec.
                         /*
    DISPLAY STREAM str_1 
            rel_nrctrlim  rel_vllimpro  rel_dsdlinha  crapprp.vlmedchq
            WITH FRAME f_lim_pro.

    DOWN STREAM str_1 WITH FRAME f_lim_pro.
                         */
    IF   aux_vltotemp > 0   THEN
         DO:
             DISPLAY STREAM str_1 tel_dtcalcul 
                                  rel_vlslddsc
                                  rel_qtdscsld
                                  rel_vlmaxdsc
                                  rel_vlmeddsc
                                  WITH FRAME f_pro_ed1.

             ASSIGN tot_vlsdeved = 0
                    tot_vlpreemp = 0. 

             /* busca informacoes de emprestimo e prestacoes (para nao 
             utilizar mais a include "gera workepr.i") - (Gabriel/DB1) */
            
             IF  NOT VALID-HANDLE(h-b1wgen0002)  THEN
                 RUN sistema/generico/procedures/b1wgen0002.p
                    PERSISTENT SET h-b1wgen0002.
             
             RUN obtem-dados-emprestimos IN h-b1wgen0002
                 ( INPUT glb_cdcooper,
                   INPUT 0,  /** agencia **/
                   INPUT 0,  /** caixa **/
                   INPUT glb_cdoperad,
                   INPUT "proepr.p",
                   INPUT 1,  /** origem **/
                   INPUT tel_nrdconta,
                   INPUT 1,  /** idseqttl **/
                   INPUT glb_dtmvtolt,
                   INPUT glb_dtmvtopr,
                   INPUT ?,
                   INPUT 0, /** Contrato **/
                   INPUT "bordero_m.p",
                   INPUT glb_inproces,
                   INPUT FALSE, /** Log **/
                   INPUT TRUE,
                   INPUT 0, /** nriniseq **/
                   INPUT 0, /** nrregist **/
                  OUTPUT aux_qtregist,
                  OUTPUT TABLE tt-erro,
                  OUTPUT TABLE tt-dados-epr ).

              IF  VALID-HANDLE(h-b1wgen0002) THEN
                  DELETE OBJECT h-b1wgen0002.
             
              IF  RETURN-VALUE = "NOK"  THEN
                  DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
             
                    IF  AVAILABLE tt-erro  THEN
                        ASSIGN glb_dscritic = tt-erro.dscritic.
                    ELSE
                        ASSIGN glb_dscritic = "Erro no carregamento"
                                              + " de emprestimos.".
                    
                        MESSAGE  glb_dscritic.
                  END.

             FOR EACH tt-dados-epr WHERE (tt-dados-epr.vlsdeved > 0) NO-LOCK:

                 ASSIGN tot_vlsdeved = tot_vlsdeved + tt-dados-epr.vlsdeved
                        tot_vlpreemp = tot_vlpreemp + tt-dados-epr.vlpreemp
                        rel_dspreapg = SUBSTR(tt-dados-epr.dspreapg,5,11).

                 DISPLAY STREAM str_1
                         tt-dados-epr.nrctremp  tt-dados-epr.vlsdeved  rel_dspreapg
                         tt-dados-epr.vlpreemp  tt-dados-epr.dslcremp
                         tt-dados-epr.dsfinemp 
                         WITH FRAME f_dividas.

                 DOWN STREAM str_1 WITH FRAME f_dividas.

             END.  /*  Fim do FOR EACH - Leitura da divida anterior  */

             DISPLAY STREAM str_1
                     tot_vlsdeved  tot_vlpreemp WITH FRAME f_tot_div.
         END.
    ELSE
         VIEW STREAM str_1 FRAME f_sem_divida.

    VIEW STREAM str_1 FRAME f_autorizo.

    aux_dsobserv = "".
    
    DO aux_ocobserv = 1 to 3:

       IF   crapprp.dsobserv[aux_ocobserv] <> ""   THEN 
            aux_dsobsvar = aux_dsobsvar + crapprp.dsobserv[aux_ocobserv].

    END.   /*  Fim do DO .. TO  */

    RUN fontes/quebra_str.p (INPUT aux_dsobsvar, 
                             INPUT 94, 
                             INPUT 94,
                             INPUT 94,
                             INPUT 94,        
                             OUTPUT rel_dsobserv[1], 
                             OUTPUT rel_dsobserv[2],
                             OUTPUT rel_dsobserv[3],
                             OUTPUT rel_dsobserv[4]).

    DISPLAY STREAM str_1 rel_dsobserv[1] rel_dsobserv[2]
                         rel_dsobserv[3] rel_dsobserv[4]
                         WITH FRAME f_observac.
                    
    DOWN STREAM str_1 WITH FRAME f_observac.        

    DISPLAY STREAM str_1 rel_nmprimtl[1]  glb_nmoperad  rel_ddmvtolt
                         rel_dsmesref     rel_aamvtolt  rel_nmrescop
                         rel_nmcidade
                         WITH FRAME f_aprovacao.
    
END PROCEDURE.

PROCEDURE p_divinome:

  /******* Divide o campo crapcop.nmextcop em duas Strings *******/
  
  ASSIGN aux_qtpalavr = NUM-ENTRIES(TRIM(crapcop.nmextcop)," ") / 2
                        rel_nmrescop = "".

  DO aux_contapal = 1 TO NUM-ENTRIES(TRIM(crapcop.nmextcop)," "):

     IF   aux_contapal <= aux_qtpalavr   THEN
          rel_nmrescop[1] = rel_nmrescop[1] +   
                      (IF TRIM(rel_nmrescop[1]) = "" THEN "" ELSE " ") +
                            ENTRY(aux_contapal,crapcop.nmextcop," ").
     ELSE
          rel_nmrescop[2] = rel_nmrescop[2] +
                      (IF TRIM(rel_nmrescop[2]) = "" THEN "" ELSE " ") +
                            ENTRY(aux_contapal,crapcop.nmextcop," ").
  END.  /*  Fim DO .. TO  */ 
           
  ASSIGN rel_nmrescop[1] = 
           FILL(" ",20 - INT(LENGTH(rel_nmrescop[1]) / 2)) + rel_nmrescop[1]
         rel_nmrescop[2] = FILL(" ",20 - INT(LENGTH(rel_nmrescop[2]) / 2)) +
                           rel_nmrescop[2].

END PROCEDURE.

PROCEDURE p_monta_cpfcgc:

    ASSIGN glb_nrcalcul = crapcec.nrcpfcgc
           rel_nmcheque = 
               (IF crapcec.nrdconta > 0
                   THEN "(" + TRIM(STRING(crapcec.nrdconta,"zzzz,zzz,9")) + ") "
                   ELSE "") + TRIM(crapcec.nmcheque).
         
    IF   LENGTH(STRING(crapcec.nrcpfcgc)) > 11   THEN
         DO:
             ASSIGN rel_dscpfcgc = STRING(crapcec.nrcpfcgc,"99999999999999")
                    rel_dscpfcgc = STRING(rel_dscpfcgc,"xx.xxx.xxx/xxxx-xx").

             RETURN.
         END.
    
    RUN fontes/cpffun.p.
           
    IF   glb_stsnrcal   THEN
         ASSIGN rel_dscpfcgc = STRING(crapcec.nrcpfcgc,"99999999999")
                rel_dscpfcgc = STRING(rel_dscpfcgc,"xxx.xxx.xxx-xx").
    ELSE
         ASSIGN rel_dscpfcgc = STRING(crapcec.nrcpfcgc,"99999999999999")
                rel_dscpfcgc = STRING(rel_dscpfcgc,"xx.xxx.xxx/xxxx-xx").
                     
END PROCEDURE.

/* .......................................................................... */



