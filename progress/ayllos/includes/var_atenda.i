/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | includes/var_atenda.i           | FORM0001                          |
  +---------------------------------+-----------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/












/* .............................................................................

   Programa: Includes/var_atenda.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Marco/95.                       Ultima atualizacao: 11/10/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Criar as variaveis e form da tela ATENDA.

   Alteracoes: 10/03/95 - Altera layout do frame f_capital (Edson).

               22/03/95 - Alterado para nao mostrar o capital em moeda fixa
                          (Deborah).

               17/04/95 - Alterado para alterar o layout incluindo funcao ,
                          ramal e fator salarial (Odair).

               27/04/95 - Alterado para criar frame f_data e a variavel
                          aux_dtpesqui para pedir a data de referencia na tela
                          extrato de deposito a vista (Odair).

               12/05/95 - Alterado para criar campos utilizados na data de
                          calculo dos emprestimos (Edson).

               09/10/95 - Alterado para colocar a data de admissao na empresa
                          (Deborah).

               14/11/95 - Alterado para criar frame f_proposta para emissao
                          do contrato de emprestimo (Edson).

               17/01/96 - Alterado para incluir o CPF (Odair).

               15/03/96 - Alterado para incluir rotina da poupanca programada
                          (Edson).

               21/08/96 - Alterado para incluir o campo do limite do cartao
                          Credicard (Edson).

               06/12/96 - Alterar o frame capital para exibir informacoes
                          sobre o desconto do capital (folha/conta) (Odair).

               18/12/96 - Alterado para incluir terceira coluna para informa-
                          cao de saldos (Edson).

               07/01/97 - Alterado para tratar automacao dos planos de capital
                          (Edson).

               16/01/97 - Alterado para tratar a CPMF (Edson).

               24/01/97 - Tratar historico 191 (Odair).

               03/09/97 - Alterado para tratar FOLHA (Odair).

               16/10/97 - Alterado para aumentar o formato do campo
                          crawext.dshistor para 25 posicoes (Edson).

               14/01/98 - Alterado para permitir consulta das informacoes
                          complementares dos emprestimos (Edson).

               05/03/98 - Alterado para criar o campo aux_qtprecal e modificar
                          do tipo de dado do campo aux_qtpreapg de int para dec
                          (Edson).

               15/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               29/04/98 - Incluido a quantidade de taloes retirados no mes
                          (Deborah).
                          
               24/08/98 - Mostrar fone se for 9999 (Odair)           

               14/01/99 - Tratar cartao magnetico de C/C (Edson).

               22/01/99 - Tratar historico 313 (Odair).

               26/01/99 - Mostar a base de calculo do IOF sobre c/c (Deborah).
               
               02/03/99 - Tratar campo para a opcao LAUOMT (Deborah).
               
               14/04/99 - Tratar limite de credito (Odair)

               17/03/2000 - Mostrar segundo titular, quantidade de dias em CL
                            e quant. de dias em estouro (Odair).

               21/07/2000 - Tratar historico 358 (Deborah).

               15/01/2001 - Substituir CCOH por COOP (Margarete/Planner).

               08/03/2001 - Novas variaveis para controle das prestacoes em 
                            atraso e meses decorridos (Deborah).

               25/06/2001 - Variaveis do prejuizo (Margarete).
               
               30/06/2001 - Mostrar a quantidade de cheques devolvidos.
                            (Ze Eduardo). 

               20/08/2001 - Tratar onze posicoes no numero do documento (Edson).

               03/01/2002 - Mostrar os valor pagos da CPMF (Edson).

               05/04/2002 - Tratamento do resgate on_line RDCA30 (Margarete).

               24/04/2002 - Tratar impressao dos cheques depositados (Edson).
               
               07/05/2002 - Novos campos na consulta do prejuizo (Margarete).
               
               28/08/2002 - Campos para tratar opcao INTERNET (Margarete).

               10/03/2003 - Tratar desconto de cheques (Edson).

               14/10/2003 - Corrigir critica 691 (Margarete).

               28/04/2004 - Tratar parcelamento do capital inicial (Edson).
               
               03/09/2004 - Tratar conta integracao (Margarete).

               06/09/2004 - Demonstrar saldo Conta Investimento(Mirtes). 
 
               16/12/2004 - Ajuste (Remodelagem) Tela ATENDA(Mirtes).

               28/01/2005 - Modificados os termos "Agencia" ou "Ag" por "PAC"
                            (Evandro).

               11/03/2005 - Tratar opcao SALDOS ANTERIORES na rotina DEPOSITO
                            A VISTA (Edson).

               18/03/2005 - Nova tabela crawepr_salvo(Para acerto rotina 
                            testa_fiador(Mirtes).

               22/06/2005 - Criadas variaveis para rotina Saldos               
                            Anteriores referente opcao DEP.VISTA (Diego).

               18/08/2005 - Acrescentado campo aux_dtafinal a FRAME f_mesref   
                            (Diego).

               04/10/2005 - Alterado o termo Tal.ret para Fls.ret (Edson).
               
               14/12/2005 - Criada opcao "URA" (Diego).
               
               06/02/2006 - Incluida a opcao de CONVENIOS (Evandro).
               
               02/03/2006 - Incluir a includes var_workepr.i (Ze).

               09/05/2006 - Tirado item DEVOLUCOES, CTR ORDENS,
                            CRED.LIQ, ESTOUROS (Magui).
                            
               13/06/2006 - Criada variavel aux_dtabtcct e acrescentada na
                            frame f_atenda (David).

               20/06/2006 - Acrescentada na frame f_atenda os campos
                            tel_qtdevolu e tel_qtddtdev (David).

               26/06/2006 - Apresentacao na frame f_atenda da variavel
                            tel_qtddsdev (David).

               03/11/2006 - Incluida a variavel "tel_nrdctitg" (David).
               
               04/12/2006 - Substituir Ocupacao por Funcao (Ze).
               
               02/02/2007 - Exclusao dos campos tel_vlbasiof, tel_vlcmecot,
                            tel_vlmoefix (Diego).

               06/02/2007 - Alterado formato dos campos aux_dtpesqui e
                            aux_dtafinal para "99/99/9999" (Elton).
                            
               09/02/2007 - Incluido campo tel_vlmoefix (Diego).
               
               29/10/2007 - Incluidas variaveis aux_tel_cdagenci,
                            aux_tel_cdbccxlt e aux_tel_nrdolote, utilizadas no
                            FRAME f_capital (Diego).
                            
               02/01/2008 - Aumentado digitos do campo Fls.Ret (Guilherme).

               20/02/2008 - Alterado cdturnos a partir da crapttl (Gabriel).
               
               31/10/2008 - Adaptacoes para chamada de BO's(Sidnei - Precise).
               
               13/01/2009 - Alteracao cdempres (Diego).
               
               05/03/2009 - Inclusao da FRAME f_extratos_cash (Fernando).
 
               22/05/2009 - Incluir item RELACIONAMENTO (Gabriel).

               23/09/2009 - Incluir variaveis para rotina DEP.VISTA (David).
               
               08/09/2010 - Retirar variaveis referente a utilizacao do fonte
                            depvista.p para rotina DEP.VISTA (David).
               
               07/12/2010 - Retirar campo 'Ft.Salarial' (Gabriel).        
               
               13/01/2011 - Incluir browse com os telefones do cooperado
                            (Gabriel)                                                
                
               18/07/2013 - Retirado opcao "Tarifar?", tratamento sera feito automaticamente.
                            Projeto Tarifas (Daniel). 
                            
               26/08/2013 - Substituir campo crapass.dsnatura pelo campo
                            tel_dsnatura (David).             
               
               01/10/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               11/10/2013 - Aumento do numero de opcoes (tel_dsdopcao) de 21 
                            para 22 (Carlos).
                            
               18/10/2013 - Ajustes de espacamento entre as informacoes "Plano",
                            "Fls.ret.", e "Devolucoes" (Carlos).
............................................................................. */

{ includes/var_workepr.i {1} }

DEF {1} SHARED TEMP-TABLE crawext                                      NO-UNDO
               FIELD dtmvtolt AS DATE    FORMAT "99/99/9999"
               FIELD dshistor AS CHAR    FORMAT "x(25)"
               FIELD nrdocmto AS CHAR    FORMAT "x(11)"
               FIELD indebcre AS CHAR    FORMAT " x "
               FIELD vllanmto AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-".

DEF {1} SHARED VAR tel_nrdconta AS INT     FORMAT "zzzz,zzz,9"          NO-UNDO.
DEF {1} SHARED VAR tel_nrdctitg AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR tel_nmtitula AS CHAR                                 NO-UNDO.

DEF {1} SHARED VAR tel_qtddsdev AS INT                                  NO-UNDO.
DEF {1} SHARED VAR tel_qtddtdev AS INT                                  NO-UNDO.

DEF {1} SHARED VAR tel_nrcpfcgc AS CHAR    FORMAT "x(18)"               NO-UNDO.

DEF {1} SHARED VAR tel_dsnatura AS CHAR    FORMAT "x(20)"               NO-UNDO.

DEF {1} SHARED VAR tel_flgcdura AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR tel_vldcotas AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF {1} SHARED VAR tel_vlcmicot AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.

DEF {1} SHARED VAR tel_vlipmfpg AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF {1} SHARED VAR tel_vlsmnmes AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF {1} SHARED VAR tel_vlsmnesp AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF {1} SHARED VAR tel_vlsmnblq AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.

DEF {1} SHARED VAR tel_vlmoefix AS DECIMAL FORMAT "zzzzz,zz9.99999999"  NO-UNDO.
DEF {1} SHARED VAR tel_vlcaptal AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF {1} SHARED VAR tel_qtcotmfx AS DECIMAL FORMAT "z,zzz,zzz,zz9.9999-" NO-UNDO.

DEF {1} SHARED VAR tel_nrctrpla AS INT     FORMAT "zzz,zzz"             NO-UNDO.
DEF {1} SHARED VAR tel_qtprepag AS INT     FORMAT "zzz"                 NO-UNDO.
DEF {1} SHARED VAR tel_qttalret AS INT     FORMAT "zzz,zz9"             NO-UNDO.
DEF {1} SHARED VAR tel_qtdevolu AS INT     FORMAT "zzzzz9"              NO-UNDO.
DEF {1} SHARED VAR tel_nrramfon AS CHAR    FORMAT "x(20)"               NO-UNDO.

DEF {1} SHARED VAR tel_vlprepla AS DECIMAL FORMAT "zzz,zzz,zz9.99"      NO-UNDO.
DEF {1} SHARED VAR tel_vledvmto AS DECIMAL FORMAT "zzz,zzz,zz9.99"      NO-UNDO.

DEF {1} SHARED VAR tel_dtinipla AS DATE    FORMAT "99/99/9999"          NO-UNDO.
DEF {1} SHARED VAR tel_dtaltera AS DATE    FORMAT "99/99/9999"          NO-UNDO.
DEF {1} SHARED VAR tel_dtcalcul AS DATE    FORMAT "99/99/9999"          NO-UNDO.

DEF {1} SHARED VAR tel_dsplacap AS CHAR    FORMAT "x(24)"               NO-UNDO.
DEF {1} SHARED VAR tel_dsmoefix AS CHAR    FORMAT "x(20)" INIT "UFIR"   NO-UNDO.
DEF {1} SHARED VAR tel_dslimcre AS CHAR    FORMAT "x(4)"                NO-UNDO.
DEF {1} SHARED VAR tel_dstipcta AS CHAR    FORMAT "x(21)"               NO-UNDO.
DEF {1} SHARED VAR tel_dssitdct AS CHAR    FORMAT "x(29)"               NO-UNDO.
DEF {1} SHARED VAR aux_tel_cdagenci AS CHAR                             NO-UNDO.
DEF {1} SHARED VAR aux_tel_cdbccxlt AS CHAR                             NO-UNDO.
DEF {1} SHARED VAR aux_tel_nrdolote AS CHAR                             NO-UNDO.
DEF {1} SHARED VAR tel_dspagcap AS CHAR    FORMAT "x(20)"               NO-UNDO.
DEF {1} SHARED VAR tel_dsdopcao AS CHAR    FORMAT "x(27)" EXTENT 22     NO-UNDO.
DEF {1} SHARED VAR tel_flgexoco AS CHAR    FORMAT "x(3)"                NO-UNDO.
DEF {1} SHARED VAR tel_cancelar AS CHAR    FORMAT "x(8)"
                                           INIT "Cancelar"              NO-UNDO.
DEF {1} SHARED VAR tel_reativar AS CHAR    FORMAT "x(8)"
                                           INIT "Reativar"              NO-UNDO.

DEF {1} SHARED VAR tel_imprplan AS CHAR    FORMAT "x(13)"
                                           INIT "Imprime Plano"         NO-UNDO.

DEF {1} SHARED VAR tel_dsparcap AS CHAR    FORMAT "x(18)" 
                                           INIT "Subscricao Inicial"    NO-UNDO.

DEF {1} SHARED VAR tel_dsplanos AS CHAR    FORMAT "x(16)" 
                                           INIT "Plano de Capital"      NO-UNDO.
DEF {1} SHARED VAR tel_dsmesant AS CHAR    FORMAT "x(9)"                NO-UNDO.
DEF {1} SHARED VAR tel_dsmesatu AS CHAR    FORMAT "x(9)"                NO-UNDO.
DEF {1} SHARED VAR tel_vlsmdtri AS DECIMAL FORMAT "zzz,zzz,zz9.99-"     NO-UNDO.
DEF {1} SHARED VAR tel_vlsmdsem AS DECIMAL FORMAT "zzz,zzz,zz9.99-"     NO-UNDO.
DEF {1} SHARED VAR tel_vlsaqmax AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF {1} SHARED VAR tel_vlacerto AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF {1} SHARED VAR tel_vlsddisp AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF {1} SHARED VAR tel_vlsdbloq AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF {1} SHARED VAR tel_vlsdblpr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF {1} SHARED VAR tel_vlsdblfp AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF {1} SHARED VAR tel_vlsdchsl AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF {1} SHARED VAR tel_vlstotal AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF {1} SHARED VAR tel_vlsmdpos AS DECIMAL FORMAT "zzz,zzz,zz9.99"
                                           EXTENT 7                     NO-UNDO.
DEF {1} SHARED VAR tel_nmmesano AS CHAR    FORMAT "x(9)" EXTENT 7       NO-UNDO.
DEF {1} SHARED VAR tel_vlbscpmf AS DECIMAL EXTENT 2                 NO-UNDO.
DEF {1} SHARED VAR tel_vlpgcpmf AS DECIMAL EXTENT 2                 NO-UNDO.
DEF {1} SHARED VAR tel_dsexcpmf AS INT     EXTENT 2                 NO-UNDO.
DEF {1} SHARED VAR tel_dssititg AS CHAR    FORMAT "x(07)"           NO-UNDO.   
DEF {1} SHARED VAR tel_dsnatopc AS CHAR    FORMAT "x(20)"           NO-UNDO.
DEF {1} SHARED VAR pro_vlemprst AS DECIMAL FORMAT "zzz,zzz,zz9.99"  NO-UNDO.
DEF {1} SHARED VAR pro_qtpreemp AS INT     FORMAT "zz9"             NO-UNDO.
DEF {1} SHARED VAR pro_vlpreemp AS DECIMAL FORMAT "zzz,zzz,zz9.99"  NO-UNDO.
DEF {1} SHARED VAR pro_cdlcremp as INT     FORMAT "zz9"             NO-UNDO.
DEF {1} SHARED VAR pro_vlcresti AS DECIMAL FORMAT "zzz,zzz,zz9.99"  NO-UNDO.
DEF {1} SHARED VAR pro_cdfinemp AS INT     FORMAT "zz9"             NO-UNDO.
DEF {1} SHARED VAR pro_dtlibera AS DATE    FORMAT "99/99/9999"      NO-UNDO.
DEF {1} SHARED VAR pro_dsobserv AS CHAR    FORMAT "x(30)"           NO-UNDO.
DEF {1} SHARED VAR aux_vltotapl AS DECIMAL                             NO-UNDO.
DEF {1} SHARED VAR aux_vltotrda AS DECIMAL                             NO-UNDO.
DEF {1} SHARED VAR aux_vltotrpp AS DECIMAL                             NO-UNDO.
DEF {1} SHARED VAR aux_vltotseg AS DECIMAL                             NO-UNDO.
DEF {1} SHARED VAR aux_vldsctit AS DECIMAL                             NO-UNDO.
DEF {1} SHARED VAR aux_vltotdsc AS DECIMAL                             NO-UNDO.
DEF {1} SHARED VAR aux_vldscchq AS DECIMAL                             NO-UNDO.
DEF {1} SHARED VAR aux_vltotccr AS DECIMAL                             NO-UNDO.
DEF {1} SHARED VAR aux_vldfolha AS DECIMAL                             NO-UNDO.
DEF {1} SHARED VAR aux_vllautom AS DECIMAL                             NO-UNDO.
DEF {1} SHARED VAR aux_vllimcre AS DECIMAL                             NO-UNDO.
DEF {1} SHARED VAR aux_qtctrord AS INT                                 NO-UNDO.
DEF {1} SHARED VAR aux_qtsegass AS INT                                 NO-UNDO.
DEF {1} SHARED VAR aux_qtdscchq AS INT                                 NO-UNDO.
DEF {1} SHARED VAR aux_qtdsctit AS INT                                 NO-UNDO.
DEF {1} SHARED VAR aux_qttotdsc AS INT                                 NO-UNDO.
DEF {1} SHARED VAR aux_cdempres AS INT                                 NO-UNDO.
DEF {1} SHARED VAR aux_tplimcre AS INT                                 NO-UNDO.
DEF {1} SHARED VAR aux_nrultdia AS INT                                 NO-UNDO.
DEF {1} SHARED VAR aux_nrmesref AS INT                                 NO-UNDO.
DEF {1} SHARED VAR aux_nrmesant AS INT                                 NO-UNDO.
DEF {1} SHARED VAR ate_vlpreapg AS DECIMAL DECIMALS 4                  NO-UNDO.
DEF {1} SHARED VAR ate_qtmesdec LIKE crapepr.qtmesdec                  NO-UNDO.
DEF {1} SHARED VAR aux_insaqmax AS DECIMAL                             NO-UNDO.
DEF {1} SHARED VAR aux_txdoipmf AS DECIMAL                             NO-UNDO.
DEF {1} SHARED VAR aux_vlipmfap AS DECIMAL                             NO-UNDO.
DEF {1} SHARED VAR aux_nrmesano AS INT                                 NO-UNDO.
DEF {1} SHARED VAR aux_contador AS INT                                 NO-UNDO.
DEF {1} SHARED VAR aux_nrindice AS INT                                 NO-UNDO.
DEF {1} SHARED VAR aux_inmesano AS INT                                 NO-UNDO.
DEF {1} SHARED VAR aux_qtcarmag AS INT                                 NO-UNDO.
DEF {1} SHARED VAR aux_stimeout AS INT                                 NO-UNDO.
DEF {1} SHARED VAR aux_flgerros AS LOGICAL                             NO-UNDO.
DEF {1} SHARED VAR aux_flgcance AS LOGICAL                             NO-UNDO.
DEF {1} SHARED VAR aux_flgpagto AS LOGICAL                             NO-UNDO.
DEF {1} SHARED VAR aux_flgtarif AS LOGICAL FORMAT "Sim/Nao"            NO-UNDO.
DEF {1} SHARED VAR aux_flgrlchq AS LOGICAL FORMAT "Sim/Nao"            NO-UNDO.
DEF {1} SHARED VAR aux_cddopcao AS CHAR                                NO-UNDO.
DEF {1} SHARED VAR aux_nranoatu AS CHAR                                NO-UNDO.
DEF {1} SHARED VAR aux_nranoant AS CHAR                                NO-UNDO.
DEF {1} SHARED VAR aux_flgexlrg AS LOGICAL                             NO-UNDO. 
DEF {1} SHARED VAR aux_nmmesano AS CHAR    EXTENT 12
                       INIT ["JANEIRO","FEVEREIRO","MARCO",
                             "ABRIL","MAIO","JUNHO",
                             "JULHO","AGOSTO","SETEMBRO",
                             "OUTUBRO","NOVEMBRO","DEZEMBRO"]      NO-UNDO.

DEF {1} SHARED VAR aux_qtcotmfx AS DECIMAL                             NO-UNDO.
DEF {1} SHARED VAR aux_vldcotas AS DECIMAL                             NO-UNDO.
DEF {1} SHARED VAR aux_vlcmecot AS DECIMAL                             NO-UNDO.
DEF {1} SHARED VAR aux_vlcmicot AS DECIMAL                             NO-UNDO.
DEF {1} SHARED VAR aux_vlcmmcot AS DECIMAL                             NO-UNDO.
DEF {1} SHARED VAR aux_vllanmfx AS DECIMAL                             NO-UNDO.
DEF {1} SHARED VAR aux_dtrefcot AS DATE                                NO-UNDO.
DEF {1} SHARED VAR aux_nrdconta AS INT                                 NO-UNDO.
DEF {1} SHARED VAR aux_flgdodia AS LOGICAL INIT TRUE  /* MFX do dia */ NO-UNDO.
DEF {1} SHARED VAR aux_lshistor AS CHAR                                NO-UNDO.
DEF {1} SHARED VAR aux_dtpesqui  AS DATE FORMAT "99/99/9999"         NO-UNDO.
DEF {1} SHARED VAR aux_dtafinal  AS DATE FORMAT "99/99/9999"         NO-UNDO.
DEF {1} SHARED VAR aux_inhabweb  AS CHAR FORMAT "x(13)"              NO-UNDO.
DEF {1} SHARED FRAME f_moldura.
DEF {1} SHARED FRAME f_atenda.
DEF {1} SHARED VAR aux_saldo_ci LIKE crapsld.vlsddisp                 NO-UNDO.
DEF {1} SHARED VAR aux_nivrisco    AS CHAR   FORMAT "x(02)"           NO-UNDO.
DEF {1} SHARED VAR aux_vlr_arrasto AS DECIMAL                         NO-UNDO.
DEF {1} SHARED VAR aux_dsdrisco    AS CHAR   FORMAT "x(02)" EXTENT 20 NO-UNDO.
DEF {1} SHARED VAR aux_messalarial AS INTE        NO-UNDO.
DEF {1} SHARED VAR aux_anosalarial AS INTE        NO-UNDO.
DEF {1} SHARED VAR aux_qtconven    AS INT                             NO-UNDO.
DEF {1} SHARED VAR aux_dtabtcct    AS CHAR                            NO-UNDO.
DEF {1} SHARED VAR aux_dsrelext    AS CHAR FORMAT "x(17)"             NO-UNDO.
DEF {1} SHARED VAR aux_flgbloqt    AS LOGI                            NO-UNDO.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM tel_nrdconta     AT  2 LABEL "Conta/dv" AUTO-RETURN
                      HELP "Informe o numero da conta ou <F7> para pesquisar"
     crapass.nrmatric AT 25 LABEL "Matricula"
     crapass.cdagenci AT 45 LABEL "PA"
     crapass.dtadmiss AT 55 LABEL "Admis.COOP." FORMAT "99/99/9999"
     SKIP
     tel_nrdctitg     AT  2 LABEL "Conta/ITG"   FORMAT "x.xxx.xxx-x"
     tel_dssititg     NO-LABEL
     crapass.nrctainv AT 36 LABEL "Inv."
     crapass.dtadmemp AT 55 LABEL "Admis.empr." FORMAT "99/99/9999"
     tel_nmtitula     AT  2 LABEL "Nome"        FORMAT "x(45)"
     tel_dtaltera     AT 55 LABEL "Recadastmto" FORMAT "99/99/9999"
     SKIP
     tel_dsnatopc     AT  2 LABEL "Ocup"        FORMAT "x(20)"
     tel_nrramfon     AT 30 LABEL "Tel."        FORMAT "x(20)"
     crapass.dtdemiss AT 58 LABEL "Demissao"    FORMAT "99/99/9999"
     SKIP
     tel_dsnatura     AT  2 LABEL "Nat."     
     tel_nrcpfcgc     AT 30 LABEL "CPF."
     crapass.cdsecext AT 55 LABEL "Secao"
     crapass.indnivel AT 70 LABEL "Nivel"
     SKIP
     tel_dstipcta     AT  2 LABEL "Tipo"
     tel_dssitdct     AT 30 LABEL "Sit."        FORMAT "x(18)"
     aux_cdempres     AT 55 LABEL "Emp"         FORMAT "zzzz9"
     crapttl.cdturnos AT 66 LABEL "Tu"
     crapass.cdtipsfx AT 73 LABEL "TF"          FORMAT "9"
     SKIP

     "Plano:"         AT  29
     tel_vlprepla     AT  36 NO-LABEL            FORMAT "z,zz9.99"

     "Fls.ret.:"      AT 46
     tel_qttalret     AT 56 NO-LABEL           FORMAT "zzz9"
     tel_qtdevolu     AT 62 LABEL "Devolucoes" FORMAT "zzz9"
     SKIP     
     tel_dsdopcao[01] AT  1 NO-LABEL
     tel_dsdopcao[09] AT 29 NO-LABEL           FORMAT "x(26)"
     "CL/Estouro:"    AT 55
     tel_qtddsdev     AT 66 NO-LABEL           FORMAT "zzz9"
      "/"              AT 70
     tel_qtddtdev     AT 71 NO-LABEL           FORMAT "zzz9"
     "dd"             AT 76
     SKIP
     tel_dsdopcao[02] AT  1 NO-LABEL
     tel_dsdopcao[10] AT 29 NO-LABEL           FORMAT "x(26)"
     aux_dtabtcct     AT 57 LABEL "Data SFN"   FORMAT " 99/99/9999"
     SKIP
     tel_dsdopcao[03] AT  1 NO-LABEL
     tel_dsdopcao[11] AT 29 NO-LABEL           FORMAT "x(26)"
     tel_dsdopcao[17] AT 55 NO-LABEL           FORMAT "x(23)"   
     SKIP
     tel_dsdopcao[04] AT  1 NO-LABEL
     tel_dsdopcao[12] AT 29 NO-LABEL           FORMAT "x(26)"
     tel_dsdopcao[18] AT 55 NO-LABEL           FORMAT "x(23)"
     SKIP
     tel_dsdopcao[05] AT  1 NO-LABEL
     tel_dsdopcao[13] AT 29 NO-LABEL           FORMAT "x(26)"
     tel_dsdopcao[19] AT 57 NO-LABEL           FORMAT "x(21)"
     SKIP
     tel_dsdopcao[06] AT  1 NO-LABEL
     tel_dsdopcao[14] AT 29 NO-LABEL           FORMAT "x(26)"
     tel_dsdopcao[20] AT 57 NO-LABEL           FORMAT "x(21)"
     SKIP
     tel_dsdopcao[07] AT  1 NO-LABEL
     tel_dsdopcao[15] AT 29 NO-LABEL           FORMAT "x(26)"
     tel_dsdopcao[21] AT 57 NO-LABEL           FORMAT "x(21)"
     SKIP
     tel_dsdopcao[08] AT  1 NO-LABEL
     tel_dsdopcao[16] AT 29 NO-LABEL           FORMAT "x(26)"
     tel_dsdopcao[22] AT 56 NO-LABEL           FORMAT "x(22)"
     
     WITH ROW 6 COLUMN 2 NO-BOX OVERLAY SIDE-LABELS FRAME f_atenda.

FORM pro_vlemprst AT  2 LABEL "Valor"
     pro_qtpreemp AT 26 LABEL "Qtd.Prest."
     pro_vlpreemp AT 43 LABEL "Valor da Prestacao"
     SKIP(1)
     pro_cdlcremp AT  2 LABEL "Linha de Credito"
     pro_vlcresti AT 45 LABEL "Credito Estimado"
     pro_cdfinemp AT  8 LABEL "Finalidade"
     SKIP(1)
     "Liquidacoes:" AT 2
     SKIP(3)
     pro_dtlibera AT  2 LABEL "Liberar o valor em"
     pro_dsobserv AT 32 LABEL "Observacoes"
     WITH ROW 10 COLUMN 2 SIDE-LABELS OVERLAY TITLE " Proposta de Emprestimo "
          WIDTH 78 FRAME f_proposta.

FORM aux_dtpesqui  LABEL "Entre com a Data Inicial"  AUTO-RETURN
                   HELP  "Informe a Data Inicial ou Enter para o Mes Corrente"
                   WITH  ROW 13 CENTERED OVERLAY SIDE-LABELS FRAME f_data.
                   
FORM aux_dtpesqui LABEL "Periodo"
        HELP "Informe a Data Inicial ou Enter para o Mes Corrente"
     "a"
     aux_dtafinal  
        HELP "Informe a Data Final ou Enter para o Mes Corrente"
     "Listar?"    AT 36
     aux_dsrelext  
        HELP "Informe 'SOMENTE EXTRATO','CHEQUES','DEP.IDENTIFICADOS','TODOS'"
     WITH NO-BOX NO-LABEL ROW 20 COLUMN 4 OVERLAY SIDE-LABELS FRAME f_mesref.
               
aux_insaqmax = glb_cfrvipmf.
                 
/* .......................................................................... */



