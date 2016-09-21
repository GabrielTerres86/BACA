/* ...........................................................................

   Programa: Fontes/custod.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Abril/2000.                        Ultima atualizacao: 04/06/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela CUSTOD - Custodia de cheques.

   Alteracoes: 08/09/2000 - Listar cheques que fazem parte fechamento.     
                                                     (Margarete/Planner)
   
               12/09/2000 - Incluir opcao T-consulta todos documentos. 
                                                     (Margarete/Planner)
                                                     
               06/11/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner).

               11/07/2001 - Alterado para adaptar o nome de campo (Edson).

               23/04/2002 - Ajuste nos helps de campo (Deborah).

               22/05/2002 - Permitir qualquer dia para custodia(Margarete).

               19/05/2003 - Incluir opcao O, conferencia (Margarete). 

               30/10/2003 - Inclusao de cheques descontados nas opcoes "F", 
                            "S", "P" e "C" 
                            Inclusao da opcao "D", descontar cheques em 
                            custodia (Julio).

               08/03/2004 - Demonstrar Valores Maiores/Menores(Mirtes)

               17/03/2004 - Permitir descontar cheques com liberacao nos
                            finais de semana e/ou feriados(Edson/Mirtes)

               01/07/2005 - Alimentado campo cdcooper das tabelas craplot,
                            crapbdc, crapcdb e crapcec (Diego).

               12/08/2005 - No desconto do cheque, mudar a data de liberacao
                            quando esta cai em um fim de semana e/ou feriado 
                            e o proximo dia util for no mes seguinte (Edson).
                            
               23/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               25/10/2005 - Alterado para mostrar relatorio detalhado se 
                            a flag for verdadeira (Diego). 
                            
               25/01/2006 - Unificacao dos Bancos - SQLWorks - Andre

               13/02/2006 - Inclusao do parametro glb_cdcooper para a
                            chamada do programa pedesenha.p - SQLWorks -
                            Fernando.
               
               24/08/2006 - Alterado os helps dos campos (Elton).
               
               03/01/2008 - Permitir que operador "Gerente" realize a opcao
                            "D" (Diego).
                            
               08/05/2008 - Para liberar a opcao D, permitir senha de
                            supervisor (coordenador) ou gerente (Evandro).
                            
               16/09/2008 - Alterada chave de acesso a tabela crapldc 
                            (Gabriel).
                            
               11/05/2009 - Alteracao CDOPERAD (Kbase).
                            
               21/05/2009 - Incluido novo campo "Saida" no frame f_movto e 
                            passado o mesmo como parametro para o 
                            fontes/custod_r.p (Fernando).
                            
               14/07/2009 - Alteracao CDOPERAD (Diego).
               
               24/11/2009 - Opcao de imprimir por periodo na opcao "R"; 
                            Inclusao da opcao de consulta de saldo por 
                            Conta/dv (Opcao "S");
                            Estruturacao do programa em BO - (GATI - Eder)
                            
               11/03/2010 - Passar por parametro operador que esta liberando
                            cheques na procedure desconta_cheques_em_custodia.
                            Estava passando o codigo do operador que liberou
                            a operacao (coordenador) (David).

               23/06/2010 - Alexandre - Kbase
                            Inclusco opcao I - Importacao
                          - Dividir a importacao em dois passos:
                            1- validar
                            2- integrar (Guilherme)
                            
               17/08/2010 - Inclusao de novo campo para filtrar o tipo de 
                            listagem de cheques na opcao "C" (Vitor).
                            
               15/09/2010 - Substituido crapcop.nmrescop por crapcop.dsdircop na
                            leitura e gravacao dos arquivos (Elton).

               29/11/2010 - Ajuste do numero de lote na importacao do arquivo
                            de cheques (Henrique).
                                                        
               09/12/2010 - InclusÆo dos campos Data inicial e final na 
                            consulta (GATI - Sandro)
                                                        
               25/04/2011 - Alterado a validacao do cdbccxlt atraves do crapban 
                            para crapbcl (Adriano). 
                            
               04/06/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).                                         
                                                        
               26/02/2015 - Revitalizacao desta tela (Carlos Rafael Tanholi)                                                        
                                                        
............................................................................. */

{ sistema/generico/includes/b1wgen0018tt.i }
{ sistema/generico/includes/b1wgen0076tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }

DEF TEMP-TABLE crawcst                                               NO-UNDO
    FIELD dtmvtolt LIKE crapcst.dtmvtolt
    FIELD cdagenci LIKE crapcst.cdagenci
    FIELD cdbccxlt LIKE crapcst.cdbccxlt
    FIELD nrdolote LIKE crapcst.nrdolote
    FIELD nrqtdchq AS INTEGER  LABEL "QTD.CHQ"
    FIELD vlchqlot AS DECIMAL  FORMAT "zzz,zzz,zz9.99" LABEL "VALOR CHQ"
    INDEX crawcst1 dtmvtolt cdagenci cdbccxlt nrdolote.

DEF BUFFER crabass FOR crapass.
DEF BUFFER bf-crawlot FOR crawlot.

/******************************** VARIAVEIS ********************************/
DEF        VAR tel_nrdconta AS INTE     FORMAT "zzzz,zzz,9"          NO-UNDO.
DEF        VAR tel_dtlibini AS DATE     FORMAT "99/99/9999"          NO-UNDO.
DEF        VAR tel_dtlibfim AS DATE     FORMAT "99/99/9999"          NO-UNDO.
DEF        VAR tel_nmprimtl AS CHAR     FORMAT "x(40)"               NO-UNDO.
DEF        VAR tel_dtlibera AS DATE     FORMAT "99/99/9999"          NO-UNDO.
DEF        VAR tel_dtmvtini AS DATE     FORMAT "99/99/9999"          NO-UNDO.
DEF        VAR tel_dtmvtfim AS DATE     FORMAT "99/99/9999"          NO-UNDO.
DEF        VAR tel_dtiniper AS DATE     FORMAT "99/99/9999"          NO-UNDO.
DEF        VAR tel_dtfimper AS DATE     FORMAT "99/99/9999"          NO-UNDO.
DEF        VAR tel_flgrelat AS LOGI     FORMAT "Sim/Nao"             NO-UNDO. 

DEF        VAR tel_cdbanchq AS INTE                                  NO-UNDO.
DEF        VAR tel_cdagenci AS INTE     FORMAT "zz9"                 NO-UNDO.
DEF        VAR tel_cdagechq AS INTE                                  NO-UNDO.
DEF        VAR tel_nrctachq AS DECI                                  NO-UNDO.
DEF        VAR tel_nrcheque AS INTE                                  NO-UNDO.
DEF        VAR tel_vlcheque AS DECI                                  NO-UNDO.

/*
DEF        VAR tel_dspesqui AS CHAR                                  NO-UNDO.
DEF        VAR tel_dssitchq AS CHAR                                  NO-UNDO.
DEF        VAR tel_dsobserv AS CHAR                                  NO-UNDO.
DEF        VAR tel_nmopedev AS CHAR                                  NO-UNDO.
DEF        VAR tel_tpdevolu AS CHAR                                  NO-UNDO.
*/

DEF        VAR tel_dsdopcao AS CHAR     EXTENT 4                              
        INIT ["Cooper","Demais Associados","Conta/dv","Total Geral"] NO-UNDO.

DEF        VAR tab_qtrenova AS INTE                                  NO-UNDO.
DEF        VAR tab_qtprzmin AS INTE                                  NO-UNDO.
DEF        VAR tab_qtprzmax AS INTE                                  NO-UNDO.

/*
DEF        VAR res_qtchqcop AS INTE     FORMAT "zzz,zz9"             NO-UNDO.
DEF        VAR res_qtchqban AS INTE     FORMAT "zzz,zz9"             NO-UNDO.
DEF        VAR res_qtchqdev AS INTE     FORMAT "zzz,zz9-"            NO-UNDO.
DEF        VAR res_qtcheque AS INTE     FORMAT "zzz,zz9"             NO-UNDO.
DEF        VAR res_qtcredit AS INTE     FORMAT "zzz,zz9-"            NO-UNDO.
DEF        VAR res_qtsldant AS INTE     FORMAT "zzz,zz9-"            NO-UNDO.
DEF        VAR res_qtlibera AS INTE     FORMAT "zzz,zz9-"            NO-UNDO.
DEF        VAR res_qtchqdsc AS INTE     FORMAT "zzz,zz9-"            NO-UNDO.

DEF        VAR res_vlchqcop AS DECI     FORMAT "zzz,zzz,zz9.99"      NO-UNDO.
DEF        VAR res_vlchqban AS DECI     FORMAT "zzz,zzz,zz9.99"      NO-UNDO.
DEF        VAR res_vlchqdev AS DECI     FORMAT "zzz,zzz,zz9.99-"     NO-UNDO.
DEF        VAR res_vlcheque AS DECI     FORMAT "zzz,zzz,zz9.99"      NO-UNDO.
DEF        VAR res_vlcredit AS DECI     FORMAT "zzz,zzz,zz9.99-"     NO-UNDO.
DEF        VAR res_vlsldant AS DECI     FORMAT "zzz,zzz,zz9.99-"     NO-UNDO.
DEF        VAR res_vllibera AS DECI     FORMAT "zzz,zzz,zz9.99-"     NO-UNDO.
DEF        VAR res_vlchqdsc AS DECI     FORMAT "zzz,zzz,zz9.99-"     NO-UNDO.
*/


/*
DEF        VAR res_dschqcop AS CHAR     FORMAT "x(20)"               NO-UNDO.
*/

DEF        VAR aux_contador AS INTE     FORMAT "99"                  NO-UNDO.
DEF        VAR aux_tpdsaldo AS INTE                                  NO-UNDO.
DEF        VAR aux_stimeout AS INTE                                  NO-UNDO.

DEF        VAR aux_regexist AS LOGI                                  NO-UNDO.
DEF        VAR aux_flgretor AS LOGI                                  NO-UNDO.

DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_lsborder AS CHAR                                  NO-UNDO.

DEF        VAR aux_dssitchq AS CHAR                                  NO-UNDO.
DEF        VAR aux_confirma AS CHAR     FORMAT "!"                   NO-UNDO.
/*
DEF        VAR aux_pesquisa AS CHAR     FORMAT "x(25)"               NO-UNDO.
*/

DEF        VAR aux_dtliber1 AS DATE     FORMAT "99/99/9999"          NO-UNDO.
DEF        VAR aux_dtliber2 AS DATE     FORMAT "99/99/9999"          NO-UNDO.
DEF        VAR aux_dtmvtoan AS DATE                                  NO-UNDO.

DEF        VAR aux_qtcheque AS INTE                                  NO-UNDO.
DEF        VAR aux_ttcheque AS INTE                                  NO-UNDO.
DEF        VAR aux_somvalor AS DECI                                  NO-UNDO.
DEF        VAR aux_somalote AS DECI                                  NO-UNDO.
DEF        VAR aux_nrdlinha AS INTE                                  NO-UNDO.

DEF        VAR aux_qtmenor  AS INTE     FORMAT "zzz,zz9"             NO-UNDO.
DEF        VAR aux_qtmaior  AS INTE     FORMAT "zzz,zz9"             NO-UNDO.
DEF        VAR aux_vlmenor  AS DECI     FORMAT "zzz,zzz,zz9.99-"     NO-UNDO.
DEF        VAR aux_vlmaior  AS DECI     FORMAT "zzz,zzz,zz9.99-"     NO-UNDO.

DEF        VAR aut_flgsenha AS LOGI                                  NO-UNDO.
DEF        VAR aut_cdoperad AS CHAR                                  NO-UNDO.

DEF        VAR tel_nmdopcao AS LOGI     FORMAT "ARQUIVO/IMPRESSAO"   NO-UNDO.
DEF        VAR h_b1wgen0018 AS HANDLE                                NO-UNDO.

DEF        VAR pro_dtmvtolt AS DATE     FORMAT "99/99/9999"          NO-UNDO.
DEF        VAR pro_cdagenci AS INTE     FORMAT "zz9"                 NO-UNDO.
DEF        VAR pro_nrdolote AS INTE     FORMAT "zzz,zz9"             NO-UNDO.
/*
DEF        VAR pro_vldasoma AS DECIMAL  FORMAT "zzz,zzz,zz9.99"      NO-UNDO.
DEF        VAR pro_qtcheque AS INT      FORMAT "zzz,zz9"             NO-UNDO.
*/
DEF        VAR pro_dsdolote AS CHAR     FORMAT "x(50)"               NO-UNDO.

DEF        VAR tel_tpcheque AS INTE     FORMAT "z"                   NO-UNDO.

DEF        VAR tel_cdoperad AS CHAR                                  NO-UNDO.
DEF        VAR tel_nrdsenha AS CHAR                                  NO-UNDO.
DEF        VAR tel_nvoperad AS CHAR     EXTENT 3 INITIAL
                                                ["   Operador",
                                                 "Coordenador",
                                                 "    Gerente"]      NO-UNDO.
DEF        VAR aux_nvoperad AS INTE                                  NO-UNDO.

/*Kbase*/
DEF        VAR h_b1wgen0076  AS HANDLE                                NO-UNDO.
DEF        VAR h-b1wgen0001  AS HANDLE                                NO-UNDO.

DEF STREAM str_2.

DEF        VAR tel_nmarqint  AS CHAR    FORMAT "x(48)"                NO-UNDO.
DEF        VAR tel_cdbccxlt  AS INT     FORMAT "zz9"     INIT 600     NO-UNDO.
DEF        VAR tel_nrdolote  AS INT     FORMAT "zzz,zz9"              NO-UNDO.
DEF        VAR tel_nrcustod  AS INT     FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF        VAR tel_nmcustod  AS CHAR    FORMAT "x(34)"                NO-UNDO.
DEF        VAR tel_dsdopcao1 AS LOGICAL FORMAT "Arquivo/Tela"         NO-UNDO.
DEF        VAR tel_diretori  AS CHAR    FORMAT "x(30)"                NO-UNDO.
DEF        VAR tel_dir1      AS CHAR    FORMAT "x(20)"                NO-UNDO.
DEF        VAR aux_nmarqimp  AS CHAR                                  NO-UNDO.
/*Kbase*/

DEF   BUTTON   btn_transchq LABEL " Transferir para Desconto ".
DEF   QUERY    que_tempcust FOR crawlot.

DEF   BROWSE   bro_listlote QUERY que_tempcust
               DISPLAY crawlot.dtmvtolt LABEL "Data"
                       crawlot.cdagenci LABEL "PA"
                       crawlot.nrdolote LABEL "Lote"
                       crawlot.qtchqtot LABEL "Qtd.Chqs."
                       crawlot.vlchqtot LABEL "Total"
                       WITH NO-LABELS 5 DOWN 
                       TITLE " Lotes De Cheques Para Desconto ".

/*********************************** FORMS **********************************/
DEF FRAME f_browse bro_listlote  
                   btn_transchq AT 15
                   WITH ROW 11 CENTERED NO-LABELS OVERLAY NO-BOX.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT  2 LABEL "Opcao" AUTO-RETURN
     HELP "Cons,Fecham,iMpres,Pesq,Rel.lote,Saldo,T=pesq,cOnfer,Desc.chq,I"
                        VALIDATE(CAN-DO("C,F,M,O,P,R,S,T,D,I",glb_cddopcao),
                                 "014 - Opcao errada.")
     WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_custod.

FORM tel_nrdconta AT 1 LABEL "Conta/dv" AUTO-RETURN
                       HELP "Informe o numero da conta do cooperado."

     tel_nmprimtl AT 22 NO-LABEL
     WITH ROW 6 COLUMN 15 SIDE-LABELS OVERLAY NO-BOX FRAME f_favorecido.

FORM tel_tpcheque AT 1 LABEL "Tipo" 
     VALIDATE(CAN-DO("1,2,3,4",tel_tpcheque),"014 - Opcao errada.")
HELP "Tipo de cheque: 1-Resgatado/2-Descontado/3-Custodiado/4-Todos"
    WITH ROW 7 COLUMN 15 SIDE-LABELS OVERLAY NO-BOX FRAME f_tpcheque.

FORM tel_dtlibini AT 1  LABEL "Data Inicial" 
                        HELP "Informe a data inicial de liberacao."
     tel_dtlibfim AT 28 LABEL "Data Final"
                        HELP "Informe a data final de liberacao."
     WITH ROW 7 COLUMN 25 SIDE-LABELS OVERLAY NO-BOX FRAME f_periodo.

FORM tel_dtlibini AT 1  LABEL "Data Inicial" 
                        HELP "Informe a data inicial de liberacao."
     tel_dtlibfim AT 28 LABEL "Data Final"
                        HELP "Informe a data final de liberacao."
     WITH ROW 7 COLUMN 15 SIDE-LABELS OVERLAY NO-BOX FRAME f_periodo_m.


/*Kbase*/
FORM tel_cdagenci AT 15 LABEL "PA" AUTO-RETURN
        HELP "Entre com o codigo do PA."
        VALIDATE(CAN-FIND(crapage WHERE 
                          crapage.cdcooper = glb_cdcooper   AND
                          crapage.cdagenci = tel_cdagenci), 
                          "015 - PA nao cadastrado.")
                                             
     tel_cdbccxlt AT 25 LABEL "Banco/Caixa" AUTO-RETURN
        HELP "Entre com o codigo do Banco/Caixa."
        VALIDATE(CAN-FIND(crapbcl WHERE 
                          crapbcl.cdbccxlt = tel_cdbccxlt), 
                          "057 - Banco nao cadastrado.")
    
     tel_nrdolote AT 42 LABEL "Lote" AUTO-RETURN
        HELP "Entre com o numero do lote."
        VALIDATE(NOT CAN-FIND(craplot WHERE
                              craplot.cdcooper = glb_cdcooper   AND
                              craplot.dtmvtolt = glb_dtmvtolt   AND
                              craplot.cdagenci = tel_cdagenci   AND
                              craplot.cdbccxlt = tel_cdbccxlt   AND
                              craplot.nrdolote = tel_nrdolote),
                 "058 - Numero do lote errado.")
     
     tel_nrcustod AT  5 LABEL "Custodia para"   
        HELP "Entre com a conta do associado."
        VALIDATE(tel_nrcustod > 0, "127 - Conta errada.")
        
     tel_nmcustod AT 32 NO-LABEL
     WITH ROW 6 COLUMN 15 SIDE-LABELS OVERLAY NO-BOX FRAME f_lancst.

FORM SKIP(1)
     tel_dsdopcao1 AT 1  LABEL "Visualizar criticas"
     tel_dir1      AT 1  LABEL "Destino"
     tel_diretori  AT 31 NO-LABEL 
     WITH WIDTH 70 COLUMN 7 ROW 16 NO-BOX OVERLAY SIDE-LABELS FRAME f_opcao1.
/*Kbase*/

FORM "Saldos --> "
     tel_dsdopcao[1] AT 12 FORMAT "X(6)"
     tel_dsdopcao[2] AT 21 FORMAT "X(17)"
     tel_dsdopcao[3] AT 41 FORMAT "X(8)"
     tel_dsdopcao[4] AT 52 FORMAT "X(11)"
     WITH ROW 6 COLUMN 15 NO-LABELS OVERLAY NO-BOX FRAME f_opcao.

FORM "Liberar  Bco  Ag."                AT  1
     "Conta  Cheque"                    AT 27
     "Valor  Data    Tp.Chq. Operador"  AT 46
     WITH ROW 8 COLUMN 2 NO-LABELS OVERLAY NO-BOX FRAME f_label.

FORM tt-crapcst.dtlibera AT  1 FORMAT "99/99/99"
     tt-crapcst.cdbanchq AT 10 FORMAT "zz9"
     tt-crapcst.cdagechq AT 14 FORMAT "zzz9"
     tt-crapcst.nrctachq AT 19 FORMAT "zzz,zzz,zzz,9"             
     tt-crapcst.nrcheque AT 33 FORMAT "zzz,zz9"
     tt-crapcst.vlcheque AT 41 FORMAT "zzz,zz9.99"
     tt-crapcst.dtdevolu AT 52 FORMAT "99/99/99"
     tt-crapcst.tpdevolu AT 61 FORMAT "x(6)"
     tt-crapcst.cdopedev AT 69 FORMAT "x(10)"
     WITH ROW 10 COLUMN 2 OVERLAY 11 DOWN NO-LABEL NO-BOX FRAME f_lanctos.

FORM tel_cdbanchq AT  2 LABEL "Banco"            FORMAT "zz9"
                        HELP "Informe o numero do banco impresso no cheque."
     tel_cdagechq AT 14 LABEL "Agencia"          FORMAT "zzz9"
                        HELP "Informe o numero da agencia impresso no cheque."
     tel_nrctachq AT 29 LABEL "Conta"            FORMAT "zzz,zzz,zzz,9"
                        HELP "Informe o numero da conta impresso no cheque."
     tel_nrcheque AT 51 LABEL "Numero do Cheque" FORMAT "zzz,zz9"
                        HELP "Informe o numero do cheque."
     SKIP(1)
     tt-crapcst.dspesqui AT  2 LABEL "Pesquisa" FORMAT "x(31)"
     tt-crapcst.dssitchq AT 44 LABEL "Situacao" FORMAT "x(22)"
     SKIP(1)
     "Comp  Bco  Agencia  C1" AT  4
     "Conta  C2   Cheque  C3" AT 37
     "Valor"                  AT 70
     SKIP(1)
     tt-crapcst.cdcmpchq AT 03 NO-LABEL
     tt-crapcst.cdbanchq AT 08 NO-LABEL
     tt-crapcst.cdagechq AT 17 NO-LABEL
     tt-crapcst.nrddigc1 AT 25 NO-LABEL
     tt-crapcst.nrctachq AT 26 NO-LABEL
     tt-crapcst.nrddigc2 AT 45 NO-LABEL
     tt-crapcst.nrcheque AT 48 NO-LABEL
     tt-crapcst.nrddigc3 AT 58 NO-LABEL
     tt-crapcst.vlcheque AT 61 NO-LABEL
     SKIP(1)
     tt-crapcst.dsdocmc7 AT  5 LABEL "CMC-7"
     SKIP(1)
     tt-crapcst.dtlibera AT  2 LABEL "Liberar para"
     tt-crapcst.dsobserv AT 30 NO-LABEL FORMAT "x(40)"
     SKIP
     tt-crapcst.nmopedev AT 30 NO-LABEL FORMAT "x(40)"
     WITH ROW 8 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_pesquisa.

FORM tel_dtlibera           AT 21 LABEL "Liberacao para"
     SKIP(1)
     "Qtd.           Valor" AT 41
     SKIP(1)
     tt-fechamento.qtcheque AT 18 LABEL "Cheques Recebidos"
     tt-fechamento.vlcheque AT 47 NO-LABEL
     tt-fechamento.qtchqdev AT 17 LABEL "Cheques Resgatados"
     tt-fechamento.vlchqdev AT 47 NO-LABEL
     tt-fechamento.qtchqdsc AT 16 LABEL "Cheques Descontados"
     tt-fechamento.vlchqdsc AT 47 NO-LABEL
     SKIP(1)
     tt-fechamento.dschqcop AT 16 NO-LABEL
     tt-fechamento.qtchqcop AT 37 NO-LABEL
     tt-fechamento.vlchqcop AT 47 NO-LABEL
     tt-fechamento.qtchqban AT 11 LABEL "Cheques de Outros Bancos"
     tt-fechamento.vlchqban AT 47 NO-LABEL
     tt-fechamento.qtdmenor AT 11 LABEL "                   Menor"
     tt-fechamento.vlrmenor AT 47 NO-LABEL
     tt-fechamento.qtdmaior AT 11 LABEL "                   Maior"
     tt-fechamento.vlrmaior AT 47 NO-LABEL
     /*
     SKIP(1)
     */
     tt-fechamento.qtcredit AT 20 LABEL "Valor a LIBERAR"
     tt-fechamento.vlcredit AT 47 NO-LABEL
     WITH ROW 8 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_fechamento.
     
FORM SKIP
     tel_dtlibera AT 05 LABEL "Liberacao para"
     SKIP(1)
     WITH ROW 8 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_desconto.   

FORM tel_nrdconta AT 14 LABEL "Conta/dv" AUTO-RETURN
                       HELP "Informe o numero da conta do cooperado."

     tel_nmprimtl AT 35 NO-LABEL
     SKIP(1)
     tel_dtlibera AT 21 LABEL "Saldo Contabil em"
     HELP "Informe a data."
     SKIP(1)
     "Qtd.           Valor" AT 41
     SKIP
     tt-saldo.qtsldant AT 21 LABEL "Saldo Anterior"
     tt-saldo.vlsldant AT 47 NO-LABEL
     tt-saldo.qtcheque AT 18 LABEL "Cheques Recebidos"
     tt-saldo.vlcheque AT 47 NO-LABEL
     tt-saldo.qtlibera AT 19 LABEL "Liberados no dia"
     tt-saldo.vllibera AT 47 NO-LABEL
     tt-saldo.qtchqdev AT 17 LABEL "Cheques Resgatados"
     tt-saldo.vlchqdev AT 47 NO-LABEL
     tt-saldo.qtchqdsc AT 16 LABEL "Cheques Descontados"
     tt-saldo.vlchqdsc AT 47 NO-LABEL
     tt-saldo.qtcredit AT 24 LABEL "SALDO ATUAL"
     tt-saldo.vlcredit AT 47 NO-LABEL
     tt-saldo.dschqcop AT 16 NO-LABEL
     tt-saldo.qtchqcop AT 37 NO-LABEL
     tt-saldo.vlchqcop AT 47 NO-LABEL
     tt-saldo.qtchqban AT 11 LABEL "Cheques de Outros Bancos"
     tt-saldo.vlchqban AT 47 NO-LABEL
     WITH ROW 8 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_contabilidade.

FORM tel_dtmvtini AT 1 LABEL "Periodo Lotes"
                       HELP "Informe a data ou F4 para sair."
     tel_dtmvtfim      NO-LABEL
     tel_cdagenci      LABEL "   PA"
                       HELP "Informe o PA ou F4 para sair." 
     SKIP(1)
     tel_flgrelat      LABEL "  Detalhado"    AT 12
                       HELP "Informe (S)Sim ou (N)Nao."
     tel_nmdopcao      LABEL "Saida"          AT 37
                       HELP "(A)rquivo ou (I)mpressao."
     WITH ROW 6 COLUMN 15 SIDE-LABELS OVERLAY NO-BOX FRAME f_movto.

FORM tel_dtiniper AT 1 LABEL "De"  
           HELP "Informe a data inicial."
     tel_dtfimper      LABEL "Ate" 
           HELP "Informe a data final."
     tel_nrdconta      LABEL "Conta/DV"
     tel_cdagenci      LABEL "PA" 
           HELP "Informe um PA especifico ou 0 para considerar todos"
     WITH ROW 6 COLUMN 15 SIDE-LABELS OVERLAY NO-BOX FRAME f_conferencia.

FORM "Documento a pesquisar:"
     tel_cdbanchq LABEL "Banco"   FORMAT "zz9"
     HELP "Informe o numero do banco."
     tel_nrcheque LABEL "Cheque"  FORMAT "zzz,zz9"
     HELP "Informe o numero do cheque."
     tel_vlcheque LABEL "Valor"   FORMAT "zzz,zzz,zz9.99"
     HELP "Informe o valor do cheque."
     WITH ROW 8 COLUMN 3 SIDE-LABELS OVERLAY NO-BOX FRAME f_seltodos.
 
FORM tt-lancamentos.dtlibera  COLUMN-LABEL "Liberacao" FORMAT "99/99/9999"
     tt-lancamentos.pesquisa  COLUMN-LABEL "Pesquisa"  FORMAT "x(25)"
     tt-lancamentos.cdbanchq  COLUMN-LABEL "Bco"       FORMAT "zz9"
     tt-lancamentos.cdagechq  COLUMN-LABEL "Ag."       FORMAT "zzz9"
     tt-lancamentos.nrctachq  COLUMN-LABEL "Conta"     FORMAT "zzzzzzzzz,9"
     tt-lancamentos.nrcheque  COLUMN-LABEL "Cheque"    FORMAT "zzz,zz9"
     tt-lancamentos.vlcheque  COLUMN-LABEL "Valor"     FORMAT "zzz,zz9.99"
     WITH ROW 10 COLUMN 3 OVERLAY 9 DOWN NO-BOX FRAME f_todos.

FORM "Protocolo ==>" 
     pro_dtmvtolt FORMAT "99/99/9999" LABEL "Data" " "
     pro_cdagenci FORMAT "zz9"        LABEL "PA"
     "  Bco/Cxa: 600  "
     pro_nrdolote FORMAT "zzz,zz9"    LABEL "Lote"
     SKIP(2)
     pro_dsdolote FORMAT "x(75)" NO-LABEL
     WITH ROW 11 COLUMN 3 OVERLAY SIDE-LABELS NO-BOX FRAME f_lote.

FORM "  A G U A R D E ...  " 
     WITH ROW 10 CENTERED OVERLAY FRAME f_aguarde.

DEFINE FRAME f_moldura_senha WITH ROW 8 SIZE 30 BY 6 
     OVERLAY CENTERED TITLE " Digite a Senha ".

FORM SKIP(1)
     tel_nvoperad[aux_nvoperad]  FORMAT "x(11)" NO-LABEL AT 4 ":" 
     tel_cdoperad  FORMAT "x(10)"  NO-LABEL SKIP
     "Senha :"    AT 10
     tel_nrdsenha FORMAT "x(10)" BLANK NO-LABEL SKIP(1)
     WITH NO-BOX ROW 9 SIZE 28 BY 3 CENTERED OVERLAY FRAME f_senha.

/********************************* EVENTOS *********************************/
ON RETURN OF bro_listlote IN FRAME f_browse DO:

   IF   NOT AVAILABLE crawlot   THEN
        RETURN NO-APPLY.
        
   HIDE MESSAGE NO-PAUSE.
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      aux_confirma = "N".

      BELL.
      MESSAGE COLOR NORMAL "Confirma a exclusao do protocolo (S/N)?" 
                           UPDATE aux_confirma.
      LEAVE.

   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
        aux_confirma <> "S" THEN
        DO:
            BELL.
            MESSAGE "Protocolo NAO excluido!".
            RETURN NO-APPLY.
        END.
   
   HIDE MESSAGE NO-PAUSE.

   DELETE crawcst.

   FOR EACH bf-crawlot:
       ACCUM bf-crawlot.qtchqtot (TOTAL).
       ACCUM bf-crawlot.vlchqtot (TOTAL).
   END.
   
   MESSAGE "Foram selecionados" 
           TRIM(STRING((ACCUM TOTAL bf-crawlot.qtchqtot),"zz,zz9")) 
           "cheques, totalizando o valor de R$ " + 
           TRIM(STRING((ACCUM TOTAL bf-crawlot.vlchqtot), "zzz,zzz,zz9.99")).

   OPEN QUERY que_tempcust FOR EACH crawlot.
    
   APPLY "ENTRY" TO btn_transchq IN FRAME f_browse.

   RETURN NO-APPLY.
END. /* ON RETURN OF bro_listlote */

ON CHOOSE OF btn_transchq IN FRAME f_browse DO:

    FOR EACH crawlot:
        ACCUM crawlot.vlchqtot (TOTAL).
    END.

    IF   (ACCUM TOTAL crawlot.vlchqtot) > 0   THEN
         DO:
             MESSAGE "ATENCAO! Esta operacao NAO tem volta!"
                     VIEW-AS ALERT-BOX.

             /***** Confirmar senha do operador *****/
             VIEW FRAME f_moldura_senha.

             PAUSE(0).

             ASSIGN aux_nvoperad = 2.
             DISP tel_nvoperad[aux_nvoperad] WITH FRAME f_senha.

             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                 UPDATE tel_cdoperad tel_nrdsenha WITH FRAME f_senha.

                 RUN sistema/generico/procedures/b1wgen0018.p 
                     PERSISTENT SET h_b1wgen0018.
                 RUN valida_operador_desconto IN h_b1wgen0018
                                                  (INPUT  glb_cdcooper,
                                                   INPUT  0,
                                                   INPUT  0,
                                                   INPUT  tel_cdoperad,
                                                   INPUT  tel_nrdsenha,
                                                   INPUT  aux_nvoperad,
                                                   INPUT  glb_dtmvtolt,
                                                   INPUT  tel_nrdconta,
                                                   INPUT  TABLE crawlot,
                                                   OUTPUT TABLE tt-erro).
                 DELETE PROCEDURE h_b1wgen0018.
                 
                 IF   RETURN-VALUE = "NOK"   THEN
                      DO:
                          FIND FIRST tt-erro NO-ERROR.
                          IF   AVAIL tt-erro   THEN
                               DO:
                                   BELL.
                                   MESSAGE tt-erro.dscritic VIEW-AS ALERT-BOX.
                                   NEXT.
                               END.
                      END.
                 ELSE
                      LEAVE.
             END. /* DO WHILE TRUE... */
        
             HIDE FRAME f_moldura_senha.
             HIDE FRAME f_senha.

             IF   KEYFUNCTION(LASTKEY) <> "END-ERROR"   THEN
                  DO:
                      VIEW FRAME f_aguarde.
                      RUN sistema/generico/procedures/b1wgen0018.p 
                          PERSISTENT SET h_b1wgen0018.
                      RUN desconta_cheques_em_custodia IN h_b1wgen0018
                                              (INPUT  glb_cdcooper,
                                               INPUT  0,
                                               INPUT  0,
                                               INPUT  tel_nrdconta,
                                               INPUT  glb_dtmvtolt,
                                               INPUT  tel_dtlibera,
                                               INPUT  glb_cdoperad,
                                               INPUT  TABLE crawlot,
                                               OUTPUT TABLE tt-crapbdc,
                                               OUTPUT TABLE tt-erro).
                      DELETE PROCEDURE h_b1wgen0018.
                      HIDE FRAME f_aguarde NO-PAUSE.
                      
                      IF   RETURN-VALUE = "NOK"   THEN
                           DO:
                               FIND FIRST tt-erro NO-ERROR.
                               IF   AVAIL tt-erro   THEN
                                    DO:
                                        BELL.
                                        MESSAGE tt-erro.dscritic.
                                        RETURN NO-APPLY.
                                    END.
                           END.
                      
                      RUN fontes/custod_r2.p (INPUT TABLE tt-crapbdc).
                      IF   RETURN-VALUE = "NOK"   THEN
                           RETURN NO-APPLY.
                           
                      MESSAGE "Operacao realizada com sucesso!"
                               VIEW-AS ALERT-BOX. 
                                 
                      CLEAR FRAME f_browse ALL NO-PAUSE.
                  END.
         END.  /* IF   (ACCUM TOTAL crawlot.vlchqtot) > 0 */        
    ELSE
         MESSAGE "Nao existem lotes selecionados para esta operacao !"
                 VIEW-AS ALERT-BOX.
                           
    APPLY "ENDKEY" TO FRAME f_browse.
    RETURN NO-APPLY.
END. /* ON CHOOSE OF btn_transchq */

/********************************* INICIO *********************************/
VIEW FRAME f_moldura.

PAUSE (0).

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0
       tel_dtlibera = ?.

DO WHILE TRUE:                                    
  
   RUN fontes/inicia.p.
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               CLEAR FRAME f_custod NO-PAUSE.
               CLEAR FRAME f_lanctos ALL NO-PAUSE.
               CLEAR FRAME f_todos   ALL NO-PAUSE.
               glb_cdcritic = 0.
           END.
           
      UPDATE glb_cddopcao WITH FRAME f_custod.

      IF glb_cddopcao = "I" THEN
      DO:
        MESSAGE " Opcao temporariamente insdiponivel. " VIEW-AS ALERT-BOX 
                                                        TITLE " Aviso ".
        NEXT.
      END.
        

      HIDE FRAME f_opcao.
      HIDE FRAME f_movto.
      HIDE FRAME f_label.
      HIDE FRAME f_pesquisa.
      HIDE FRAME f_lanctos.
      HIDE FRAME f_fechamento.
      HIDE FRAME f_desconto.
      HIDE FRAME f_contabilidade.
      HIDE FRAME f_favorecido.
      HIDE FRAME f_seltodos.
      HIDE FRAME f_todos.
      HIDE FRAME f_browse.
      HIDE FRAME f_lancst.
      HIDE FRAME f_tpcheque.
      HIDE FRAME f_periodo.
      HIDE FRAME f_periodo_m.
      
      tel_nrdconta = 0.
      
      CLEAR FRAME f_favorecido NO-PAUSE.

      IF   NOT CAN-DO("R,S,O,I",glb_cddopcao)   THEN
           DO:
               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
               
                  IF   glb_cdcritic > 0   THEN
                       DO:
                           RUN fontes/critic.p.
                           BELL.
                           MESSAGE glb_dscritic.
                           CLEAR FRAME f_favorecido  NO-PAUSE.
                           CLEAR FRAME f_lanctos ALL NO-PAUSE.
                           CLEAR FRAME f_todos   ALL NO-PAUSE.
                           glb_cdcritic = 0.
                       END.

                  UPDATE tel_nrdconta WITH FRAME f_favorecido.
               
                  IF   tel_nrdconta = 0   THEN
                       DO:
                           ASSIGN tel_nmprimtl = 
                                      "FECHAMENTO ASSOCIADOS EXCETO COOPER".
                           LEAVE.
                       END.

                  RUN sistema/generico/procedures/b1wgen0018.p 
                      PERSISTENT SET h_b1wgen0018.
                  RUN busca_informacoes_associado IN h_b1wgen0018
                                                   (INPUT  glb_cdcooper,
                                                    INPUT  0,
                                                    INPUT  0,
                                                    INPUT  tel_nrdconta,
                                                    INPUT  0,
                                                    OUTPUT TABLE tt-erro,
                                                    OUTPUT TABLE tt-crapass).
                  DELETE PROCEDURE h_b1wgen0018.
                  
                  IF   RETURN-VALUE = "NOK"   THEN
                       DO:
                           FIND FIRST tt-erro NO-ERROR.
                           IF   AVAIL tt-erro   THEN
                                DO:
                                    BELL.
                                    MESSAGE tt-erro.dscritic.
                                    NEXT.
                                END.
                       END.

                  FIND tt-crapass NO-ERROR.
                  IF AVAIL tt-crapass THEN
                      ASSIGN tel_nmprimtl = tt-crapass.nmprimtl.
                  
                  LEAVE.
                                      
               END.  /*  Fim do DO WHILE TRUE  */

               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                    DO:
                        HIDE FRAME f_favorecido.
                        NEXT.
                    END.

               DISPLAY tel_nmprimtl WITH FRAME f_favorecido.
 
               aux_tpdsaldo = 0.
           END.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   glb_nmdatela <> "CUSTOD"   THEN
                 DO:
                     HIDE FRAME f_custod.
                     HIDE FRAME f_favorecido.
                     HIDE FRAME f_opcao.
                     HIDE FRAME f_label.
                     HIDE FRAME f_pesquisa.
                     HIDE FRAME f_lanctos.
                     HIDE FRAME f_moldura.
                     HIDE FRAME f_fechamento.
                     HIDE FRAME f_desconto.
                     HIDE FRAME f_contabilidade.
                     HIDE FRAME f_seltodos.
                     HIDE FRAME f_todos.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i}
            aux_cddopcao = glb_cddopcao.
        END.

   IF   glb_cddopcao = "C"   THEN  /*  CONSULTA  */
        DO:
      
            ASSIGN aux_regexist = FALSE
                   aux_flgretor = FALSE
                   aux_contador = 0
                   tel_dtlibini = ?
                   tel_dtlibfim = ?.

            CLEAR FRAME f_periodo ALL NO-PAUSE.

            DISP   tel_tpcheque WITH FRAME f_tpcheque.
            UPDATE tel_tpcheque WITH FRAME f_tpcheque.

            UPDATE tel_dtlibini tel_dtlibfim WITH FRAME f_periodo.

            VIEW FRAME f_label.
                                    
            CLEAR FRAME f_lanctos ALL NO-PAUSE.

            tel_dtlibera = 1/1/1900.

            RUN sistema/generico/procedures/b1wgen0018.p 
                PERSISTENT SET h_b1wgen0018.
            RUN consulta_cheques_custodia IN h_b1wgen0018
                                             (INPUT  glb_cdcooper,
                                              INPUT  0,
                                              INPUT  0,
                                              INPUT  tel_nrdconta,
                                              INPUT  tel_tpcheque,
                                              INPUT  glb_dtmvtoan,
                                              INPUT  tel_dtlibini,
                                              INPUT  tel_dtlibfim,
                                              OUTPUT TABLE tt-erro,
                                              OUTPUT TABLE tt-crapcst).
            DELETE PROCEDURE h_b1wgen0018.
            
            IF   RETURN-VALUE = "NOK"   THEN
                 DO:
                     FIND FIRST tt-erro NO-ERROR.
                     IF   AVAIL tt-erro   THEN
                          DO:
                              BELL.
                              MESSAGE tt-erro.dscritic.
                              NEXT.
                          END.
                 END.
             
            FOR EACH tt-crapcst USE-INDEX crapcst2:
                
                ASSIGN aux_contador = aux_contador + 1.
            
                IF   aux_contador = 1   THEN
                     IF   aux_flgretor   THEN
                          DO:
                              PAUSE MESSAGE
                  "Tecle <Entra> para continuar ou <Fim> para encerrar".
                              CLEAR FRAME f_lanctos ALL NO-PAUSE.
                          END.
                     ELSE
                          aux_flgretor = TRUE.
                                              
                DISPLAY tt-crapcst.dtlibera   tt-crapcst.cdbanchq  
                        tt-crapcst.cdagechq   tt-crapcst.nrctachq  
                        tt-crapcst.nrcheque   tt-crapcst.vlcheque
                        tt-crapcst.dtdevolu   tt-crapcst.tpdevolu
                        tt-crapcst.cdopedev
                        WITH FRAME f_lanctos.
            
                IF   aux_contador = 11   THEN
                     aux_contador = 0.
                ELSE
                     DOWN WITH FRAME f_lanctos.
            
            END.  /*  Fim do FOR EACH  */

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN   
                 NEXT.

        END. /* IF   glb_cddopcao = "C" */
   ELSE
   IF   glb_cddopcao = "P"   THEN   /*  PESQUISA CHEQUE  */
        DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
               UPDATE tel_cdbanchq tel_cdagechq tel_nrctachq tel_nrcheque 
                      WITH FRAME f_pesquisa.

               VIEW FRAME f_aguarde.
                 
               RUN sistema/generico/procedures/b1wgen0018.p 
                   PERSISTENT SET h_b1wgen0018.
               RUN pesquisa_cheque_custodia IN h_b1wgen0018
                                                (INPUT  glb_cdcooper,
                                                 INPUT  0,
                                                 INPUT  0,
                                                 INPUT  tel_nrdconta,
                                                 INPUT  tel_cdbanchq,
                                                 INPUT  tel_cdagechq,
                                                 INPUT  tel_nrctachq,
                                                 INPUT  tel_nrcheque,
                                                 OUTPUT TABLE tt-erro,
                                                 OUTPUT TABLE tt-crapcst).
               DELETE PROCEDURE h_b1wgen0018.

               HIDE FRAME f_aguarde NO-PAUSE.
               
               IF   RETURN-VALUE = "NOK"   THEN
                    DO:
                        FIND FIRST tt-erro NO-ERROR.
                        IF   AVAIL tt-erro   THEN
                             DO:
                                 BELL.
                                 MESSAGE tt-erro.dscritic.
                                 NEXT.
                             END.
                    END.
                      
               FOR EACH tt-crapcst BREAK BY tt-crapcst.nrdconta
                                         BY tt-crapcst.cdbanchq 
                                         BY tt-crapcst.cdagechq
                                         BY tt-crapcst.nrctachq
                                         BY tt-crapcst.nrcheque:

                   DISPLAY tt-crapcst.dspesqui   tt-crapcst.dssitchq
                           tt-crapcst.cdcmpchq   tt-crapcst.cdbanchq
                           tt-crapcst.cdagechq   tt-crapcst.nrddigc1
                           tt-crapcst.nrctachq   tt-crapcst.nrddigc2
                           tt-crapcst.nrcheque   tt-crapcst.nrddigc3
                           tt-crapcst.vlcheque   tt-crapcst.dsdocmc7  
                           tt-crapcst.dtlibera   tt-crapcst.dsobserv 
                           tt-crapcst.nmopedev
                           WITH FRAME f_pesquisa.

                    IF   NOT LAST-OF(tt-crapcst.nrcheque)   THEN
                         DO:
                             aux_confirma = "S".
                             
                             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                             
                                MESSAGE COLOR NORMAL
                                        "Ha mais DOCUMENTOS a serem mostrados!"
                                        "Continuar (S/N)?" UPDATE aux_confirma.
                                        
                                LEAVE.
                             
                             END.  /*  Fim do DO WHILE TRUE  */
                  
                             IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                                  aux_confirma <> "S"                  THEN
                                  LEAVE.
                         END.

               END.  /*  Fim do FOR EACH  */
            END.  /*  Fim do DO WHILE TRUE  */
        END. /* IF   glb_cddopcao = "P" */
   ELSE
   IF   glb_cddopcao = "F"   THEN   /*  FECHAMENTO PARA A CONTA  */
        DO:
            tel_dtlibera = glb_dtmvtopr.
            
            CLEAR FRAME f_fechamento NO-PAUSE.
            
            DO WHILE TRUE:
            
               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
             
                  UPDATE tel_dtlibera 
                         HELP "Informe data especifica ou ? para saber o total"
                         WITH FRAME f_fechamento.
               
                  LEAVE.
            
               END.  /*  Fim do DO WHILE TRUE  */

               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                    LEAVE.

               VIEW FRAME f_aguarde.
                
                RUN sistema/generico/procedures/b1wgen0018.p 
                    PERSISTENT SET h_b1wgen0018.
                RUN busca_fechamento_custodia IN h_b1wgen0018
                                          (INPUT  glb_cdcooper,
                                           INPUT  0,
                                           INPUT  0,
                                           INPUT  tel_dtlibera,
                                           INPUT  tel_nrdconta,
                                           INPUT  glb_dtmvtolt,
                                           OUTPUT TABLE tt-erro,
                                           OUTPUT TABLE tt-fechamento).
                DELETE PROCEDURE h_b1wgen0018.
                
                HIDE FRAME f_aguarde NO-PAUSE.
                
                IF   RETURN-VALUE = "NOK"   THEN
                     DO:
                         FIND FIRST tt-erro NO-ERROR.
                         IF   AVAIL tt-erro   THEN
                              DO:
                                  BELL.
                                  MESSAGE tt-erro.dscritic.
                                  NEXT.
                              END.
                     END.

                FIND tt-fechamento NO-ERROR.
                IF   NOT AVAIL tt-fechamento   THEN
                     NEXT.
                
                DISPLAY tel_dtlibera             tt-fechamento.dschqcop
                        tt-fechamento.qtcheque   tt-fechamento.vlcheque
                        tt-fechamento.qtchqdev   tt-fechamento.vlchqdev
                        tt-fechamento.qtchqdsc   tt-fechamento.vlchqdsc
                        tt-fechamento.qtchqcop   tt-fechamento.vlchqcop
                        tt-fechamento.qtchqban   tt-fechamento.vlchqban
                        tt-fechamento.qtcredit   tt-fechamento.vlcredit
                        tt-fechamento.qtdmenor   tt-fechamento.vlrmenor
                        tt-fechamento.qtdmaior   tt-fechamento.vlrmaior
                        WITH FRAME f_fechamento.
               
                IF    tel_nrdconta = 85448  THEN 
                      DO:
                          ASSIGN aux_confirma = "N".
                          DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                         
                             MESSAGE COLOR NORMAL
                          "Deseja listar os LOTES referentes a pesquisa(S/N) ?"
                                    UPDATE aux_confirma.
     
                             LEAVE.
                         
                          END. /* fim do DO WHILE */
                            
                          IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                               aux_confirma <> "S"                  THEN
                               NEXT.
 
                          IF   aux_confirma = "S"  THEN
                               RUN fontes/custod_r1.p (INPUT tel_dtlibera).
                              
                      END. /* Fim do if tel_nrdconta */
               
            END.  /*  Fim do DO WHILE TRUE  */
        END. /* IF   glb_cddopcao = "F" */
   ELSE 
   IF   glb_cddopcao = "R"   THEN   /*  RELATORIO  */
        DO:
            ASSIGN tel_dtmvtfim = glb_dtmvtolt
                   tel_dtmvtini = DATE(MONTH(tel_dtmvtfim),
                                       01,
                                       YEAR(tel_dtmvtfim))
                   tel_cdagenci = 0
                   tel_flgrelat = NO
                   tel_nmdopcao = TRUE.
        
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
               UPDATE tel_dtmvtini tel_dtmvtfim tel_cdagenci 
                      tel_flgrelat tel_nmdopcao 
                      WITH FRAME f_movto.
                      
               RUN fontes/custod_r.p (INPUT tel_dtmvtini,
                                      INPUT tel_dtmvtfim,
                                      INPUT tel_cdagenci,
                                      INPUT tel_flgrelat,
                                      INPUT tel_nmdopcao).
            
            END.  /*  Fim do DO WHILE TRUE  */
         
            HIDE FRAME f_movto.
        END. /* IF   glb_cddopcao = "R" */
   ELSE
   IF   glb_cddopcao = "S"   THEN   /*  SALDO EM CUSTODIA  */
        DO WHILE TRUE:

           DO   WHILE TRUE ON ENDKEY UNDO, LEAVE:
                 
                DISPLAY tel_dsdopcao WITH FRAME f_opcao.
                            
                CHOOSE FIELD tel_dsdopcao HELP "Escolha uma opcao."
                       PAUSE 60 WITH FRAME f_opcao.
                
                IF   LASTKEY = -1   THEN
                     DO:
                         aux_tpdsaldo = 3.
                         LEAVE.
                     END.
                        
                HIDE MESSAGE NO-PAUSE.
                
                ASSIGN aux_tpdsaldo = FRAME-INDEX.
                
                LEAVE.
               
           END.  /*  Fim do DO WHILE TRUE  */

           IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    
                LEAVE.
         
           ASSIGN tel_dtlibera = glb_dtmvtolt
                  tel_nrdconta = 0.

           CLEAR FRAME f_contabilidade NO-PAUSE.
           HIDE tel_nrdconta IN FRAME f_contabilidade NO-PAUSE.

           DO WHILE TRUE:
            
              DO WHILE TRUE ON ENDKEY UNDO, LEAVE :
              
                 IF   aux_tpdsaldo = 3 /* Conta/dv */  THEN
                      DO:
                          UPDATE tel_nrdconta WITH FRAME f_contabilidade.
                 
                          IF   tel_nrdconta = 0   THEN
                               DO:
                                   ASSIGN glb_cdcritic = 577.
                                   RUN fontes/critic.p.
                                   BELL.
                                   MESSAGE glb_dscritic.
                                   NEXT.
                               END.

                          RUN sistema/generico/procedures/b1wgen0018.p 
                              PERSISTENT SET h_b1wgen0018.
                          RUN busca_informacoes_associado IN h_b1wgen0018
                                                     (INPUT  glb_cdcooper,
                                                      INPUT  0,
                                                      INPUT  0,
                                                      INPUT  tel_nrdconta,
                                                      INPUT  0,
                                                      OUTPUT TABLE tt-erro,
                                                      OUTPUT TABLE tt-crapass).
                          DELETE PROCEDURE h_b1wgen0018.
                          
                          IF   RETURN-VALUE = "NOK"   THEN
                               DO:
                                   FIND FIRST tt-erro NO-ERROR.
                                   IF   AVAIL tt-erro   THEN
                                        DO:
                                            BELL.
                                            MESSAGE tt-erro.dscritic.
                                            NEXT.
                                        END.
                               END.
        
                          FIND tt-crapass NO-ERROR.
                          IF AVAIL tt-crapass THEN
                              ASSIGN tel_nmprimtl = tt-crapass.nmprimtl.
                          
                          DISP tel_nmprimtl WITH FRAME f_contabilidade.
                      END. /* IF   aux_tpdsaldo = 3 */
                      
                 DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:     
                      
                     UPDATE tel_dtlibera WITH FRAME f_contabilidade.
                 
                     IF   tel_dtlibera > glb_dtmvtolt   THEN
                          DO:
                              glb_cdcritic = 13.
                              RUN fontes/critic.p.
                              BELL.
                              MESSAGE glb_dscritic.
                              CLEAR FRAME f_contabilidade NO-PAUSE.
                              glb_cdcritic = 0.
                              NEXT.
                          END.
                     LEAVE.
                 END.
                 
                 IF   KEYFUNCTION(LASTKEY) = "END-ERROR"        AND
                      aux_tpdsaldo         = 3 /* Conta/dv */   THEN
                      NEXT.
                 
                 LEAVE.
            
              END.  /*  Fim do DO WHILE TRUE  */
              
              IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                   LEAVE.
                 
              IF   tel_dtlibera = ?   THEN
                   tel_dtlibera = glb_dtmvtolt.
               
              VIEW FRAME f_aguarde.

              RUN sistema/generico/procedures/b1wgen0018.p 
                   PERSISTENT SET h_b1wgen0018.
              RUN busca_saldo_custodia IN h_b1wgen0018
                                            (INPUT  glb_cdcooper,
                                             INPUT  0,
                                             INPUT  0,
                                             INPUT  aux_tpdsaldo,
                                             INPUT  tel_nrdconta,
                                             INPUT  tel_dtlibera,
                                             OUTPUT TABLE tt-erro,
                                             OUTPUT TABLE tt-saldo).
              DELETE PROCEDURE h_b1wgen0018.

              HIDE FRAME f_aguarde NO-PAUSE.

              IF   RETURN-VALUE = "NOK"   THEN
                   DO:
                       FIND FIRST tt-erro NO-ERROR.
                       IF   AVAIL tt-erro   THEN
                            DO:
                                BELL.
                                MESSAGE tt-erro.dscritic.
                                NEXT.
                            END.
                   END.

              FIND tt-saldo NO-ERROR.
              IF   NOT AVAIL tt-saldo   THEN
                   NEXT.

              DISPLAY tel_dtlibera
                      tt-saldo.qtsldant   tt-saldo.vlsldant
                      tt-saldo.qtcheque   tt-saldo.vlcheque
                      tt-saldo.qtlibera   tt-saldo.vllibera
                      tt-saldo.qtchqdev   tt-saldo.vlchqdev
                      tt-saldo.qtchqdsc   tt-saldo.vlchqdsc
                      tt-saldo.qtcredit   tt-saldo.vlcredit
                      tt-saldo.dschqcop   
                      tt-saldo.qtchqcop   tt-saldo.vlchqcop
                      tt-saldo.qtchqban   tt-saldo.vlchqban
                      WITH FRAME f_contabilidade.
              
           END.  /*  Fim do DO WHILE TRUE  */
        
           HIDE  FRAME f_contabilidade NO-PAUSE.
           CLEAR FRAME f_contabilidade NO-PAUSE.

        END.  /*  Fim do DO WHILE TRUE (IF   glb_cddopcao = "S") */
   ELSE
   IF   glb_cddopcao = "T"   THEN   /*  PESQUISA TODOS OS LANCAMENTOS  */
        DO:
            VIEW FRAME f_seltodos.
                                    
            DO WHILE TRUE:
            
               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
             
                  UPDATE tel_cdbanchq tel_nrcheque tel_vlcheque
                         WITH FRAME f_seltodos.

                  LEAVE.
            
               END.  /*  Fim do DO WHILE TRUE  */

               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                    LEAVE.
            
               CLEAR FRAME f_todos ALL.
               VIEW FRAME f_aguarde.

               RUN sistema/generico/procedures/b1wgen0018.p 
                   PERSISTENT SET h_b1wgen0018.
               RUN busca_todos_lancamentos_custodia IN h_b1wgen0018
                               (INPUT  glb_cdcooper,
                                INPUT  0,
                                INPUT  0,
                                INPUT  tel_nrdconta,
                                INPUT  tel_cdbanchq,
                                INPUT  tel_nrcheque,
                                INPUT  tel_vlcheque,
                                INPUT  glb_dtmvtoan,
                                OUTPUT TABLE tt-erro,
                                OUTPUT TABLE tt-lancamentos).
               DELETE PROCEDURE h_b1wgen0018.
    
               HIDE FRAME f_aguarde NO-PAUSE.

               IF   RETURN-VALUE = "NOK"   THEN
                    DO:
                        FIND FIRST tt-erro NO-ERROR.
                        IF   AVAIL tt-erro   THEN
                             DO:
                                 BELL.
                                 MESSAGE tt-erro.dscritic.
                                 NEXT.
                             END.
                    END.

               ASSIGN aux_flgretor = FALSE
                      aux_contador = 0.

               FOR EACH tt-lancamentos:
               
                   ASSIGN aux_contador = aux_contador + 1.

                   IF   aux_contador = 1   THEN
                        IF   aux_flgretor   THEN
                             DO:
                                 PAUSE MESSAGE
                         "Tecle <Entra> para continuar ou <Fim> para encerrar".
                                 CLEAR FRAME f_todos ALL NO-PAUSE.
                             END.
                        ELSE
                          aux_flgretor = TRUE.

                   DISPLAY tt-lancamentos.dtlibera 
                           tt-lancamentos.pesquisa
                           tt-lancamentos.cdbanchq
                           tt-lancamentos.cdagechq 
                           tt-lancamentos.nrctachq 
                           tt-lancamentos.nrcheque 
                           tt-lancamentos.vlcheque
                           WITH FRAME f_todos.

                   IF   aux_contador = 9   THEN
                        aux_contador = 0.
                   ELSE
                        DOWN WITH FRAME f_todos.

               END.  /*  Fim do FOR EACH  */
                                               
               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN   
                    NEXT.

            END. /* do DO WIHILE TRUE */
                    
        END. /* IF   glb_cddopcao = "T" */
   ELSE
   IF   glb_cddopcao = "M"   THEN   /*  IMPRIME CHEQUES EM CUSTODIA  */
        DO:
            BELL.

            ASSIGN tel_dtlibini = ?
                   tel_dtlibfim = ?.

            CLEAR FRAME f_periodo_m ALL NO-PAUSE.

            UPDATE tel_dtlibini tel_dtlibfim WITH FRAME f_periodo_m.

            DO   WHILE TRUE ON ENDKEY UNDO, LEAVE:
                 
                 aux_confirma = "N".
                 
                 MESSAGE COLOR NORMAL "Imprimir os cheques RESGATADOS E " +
                                      "DESCONTADOS (S/N)?"
                                      UPDATE aux_confirma.
                 
                 LEAVE.

            END.  /*  Fim do DO WHILE TRUE  */

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                 DO:
                     glb_cdcritic = 79.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     glb_cdcritic = 0.
                     NEXT.
                 END.
               
            RUN fontes/custod_m.p ( INPUT tel_nrdconta, 
                                    INPUT aux_confirma = "S",
                                    INPUT tel_dtlibini,
                                    INPUT tel_dtlibfim,
                                   OUTPUT TABLE tt-erro).

            IF   RETURN-VALUE = "NOK"   THEN
                 DO:
                     FIND FIRST tt-erro NO-ERROR.
                     IF   AVAIL tt-erro   THEN
                          DO:
                              BELL.
                              MESSAGE tt-erro.dscritic.
                              NEXT.
                          END.
                 END.

        END.
   ELSE 
   IF   glb_cddopcao = "O"   THEN  /*  Conferencia  */
        DO:
            ASSIGN tel_dtiniper = glb_dtmvtolt
                   tel_dtfimper = glb_dtmvtolt
                   tel_nrdconta = 0
                   tel_cdagenci = 0.
        
            DO   WHILE TRUE ON ENDKEY UNDO, LEAVE:
                 
                 VIEW  FRAME f_conferencia.
                 CLEAR FRAME f_conferencia NO-PAUSE.
                 
                 UPDATE tel_dtiniper WITH FRAME f_conferencia.
                 
                 ASSIGN tel_dtfimper = tel_dtiniper.
                 
                 DISPLAY tel_dtfimper WITH FRAME f_conferencia.
                 
                 UPDATE tel_dtfimper tel_nrdconta tel_cdagenci
                        WITH FRAME f_conferencia. 
                 
                 RUN fontes/custod_o.p (INPUT tel_dtiniper,
                                        INPUT tel_dtfimper,
                                        INPUT tel_nrdconta,
                                        INPUT tel_cdagenci).
            
            END.  /*  Fim do DO WHILE TRUE  */
         
            HIDE FRAME f_conferencia.

        END. /* IF   glb_cddopcao = "O" */
   ELSE
   IF   glb_cddopcao = "D"   THEN
        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

            VIEW FRAME f_aguarde.

            /***** Valida parametros de limites de desconto *****/
            RUN sistema/generico/procedures/b1wgen0018.p 
                PERSISTENT SET h_b1wgen0018.
            RUN valida_limites_desconto IN h_b1wgen0018
                            (INPUT  glb_cdcooper,
                             INPUT  0,
                             INPUT  0,
                             INPUT  tel_nrdconta,
                             INPUT  glb_dtmvtolt,
                             OUTPUT tel_dtlibera,
                             OUTPUT TABLE tt-erro).
            DELETE PROCEDURE h_b1wgen0018.
    
            HIDE FRAME f_aguarde NO-PAUSE.

            IF   RETURN-VALUE = "NOK"   THEN
                 DO:
                     FIND FIRST tt-erro NO-ERROR.
                     IF   AVAIL tt-erro   THEN
                          DO:
                              BELL.
                              MESSAGE tt-erro.dscritic.
                              LEAVE.
                          END.
                 END.

            CLEAR FRAME f_desconto ALL NO-PAUSE.

            /***** Informa e valida dados de desconto *****/
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
               UPDATE tel_dtlibera WITH FRAME f_desconto.
               
               RUN sistema/generico/procedures/b1wgen0018.p 
                   PERSISTENT SET h_b1wgen0018.
               RUN valida_dados_desconto IN h_b1wgen0018
                               (INPUT  glb_cdcooper,
                                INPUT  0,
                                INPUT  0,
                                INPUT  tel_nrdconta,
                                INPUT  glb_dtmvtolt,
                                INPUT  tel_dtlibera,
                                OUTPUT TABLE tt-erro).
               DELETE PROCEDURE h_b1wgen0018.
        
               HIDE FRAME f_aguarde NO-PAUSE.
               
               IF   RETURN-VALUE = "NOK"   THEN
                    DO:
                        FOR EACH tt-erro BY tt-erro.nrsequen:
                            BELL.
                            MESSAGE tt-erro.dscritic.
                        END.
                        NEXT.
                    END.
               
               LEAVE.

            END.  /*  Fim do DO WHILE TRUE  */
            
            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                 LEAVE.

            /***** Informa e valida lotes (protocolos) *****/
            EMPTY TEMP-TABLE crawlot.
            ASSIGN pro_dsdolote = "".

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                             
               DISPLAY pro_dsdolote WITH FRAME f_lote.
               
               UPDATE pro_dtmvtolt pro_cdagenci pro_nrdolote WITH FRAME f_lote.
        
               VIEW FRAME f_aguarde.
        
               RUN sistema/generico/procedures/b1wgen0018.p 
                   PERSISTENT SET h_b1wgen0018.
               RUN valida_lote_desconto IN h_b1wgen0018
                               (INPUT        glb_cdcooper,
                                INPUT        0,
                                INPUT        0,
                                INPUT        pro_dtmvtolt,
                                INPUT        pro_cdagenci,
                                INPUT        pro_nrdolote,
                                INPUT        tel_nrdconta,
                                INPUT        tel_dtlibera,
                                INPUT-OUTPUT TABLE crawlot,
                                OUTPUT       TABLE tt-erro,
                                OUTPUT       pro_dsdolote).
               DELETE PROCEDURE h_b1wgen0018.
        
               HIDE FRAME f_aguarde NO-PAUSE.
        
               IF   RETURN-VALUE = "NOK"   THEN
                    DO:
                        FOR EACH tt-erro BY tt-erro.nrsequen:
                            BELL.
                            MESSAGE tt-erro.dscritic.
                        END.
                        NEXT.
                    END.
                                               
               HIDE MESSAGE NO-PAUSE.
               DISP pro_dsdolote WITH FRAME f_lote.
           
            END.  /*  Fim do DO WHILE TRUE  */
            HIDE FRAME f_lote NO-PAUSE.

            IF NOT CAN-FIND(FIRST crawlot) THEN
                NEXT.

            /***** Confirma lotes para passar para desconto *****/
            OPEN QUERY que_tempcust FOR EACH crawlot.
            ENABLE ALL WITH FRAME f_browse.

            FOR EACH bf-crawlot:
                ACCUM bf-crawlot.qtchqtot (TOTAL).
                ACCUM bf-crawlot.vlchqtot (TOTAL).
            END.
            
            MESSAGE 
                "Foram selecionados" 
                TRIM(STRING((ACCUM TOTAL bf-crawlot.qtchqtot),"zz,zz9")) 
                "cheques, totalizando o valor de R$ " + 
                TRIM(STRING((ACCUM TOTAL bf-crawlot.vlchqtot), 
                            "zzz,zzz,zz9.99")).

            APPLY "ENTRY" TO btn_transchq IN FRAME f_browse.
            WAIT-FOR ENDKEY, DEFAULT-ACTION OF DEFAULT-WINDOW.

            HIDE FRAME f_browse NO-PAUSE.
            HIDE MESSAGE NO-PAUSE.

            NEXT.
        
        END.  /*  Fim do DO WHILE TRUE  (IF   glb_cddopcao = "D"   THEN ) */
   /*kBASE*/
   ELSE
   IF glb_cddopcao = "I" THEN /*Inclusao*/
        DO:
            UPDATE tel_cdagenci WITH FRAME f_lancst.
            DISP tel_cdbccxlt WITH FRAME f_lancst.
            UPDATE tel_nrdolote WITH FRAME f_lancst.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
                IF   glb_cdcritic > 0 THEN
                DO:
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.
                    glb_cdcritic = 0.
                END.

                ASSIGN tel_nmcustod = "".
                DISPLAY tel_nmcustod WITH FRAME f_lancst.

                UPDATE tel_nrcustod WITH FRAME f_lancst.

                glb_nrcalcul = tel_nrcustod.
                
                RUN fontes/digfun.p.
                
                IF   NOT glb_stsnrcal   THEN
                DO:
                    glb_cdcritic = 8.
                    tel_nmcustod = "".
                    DISPLAY tel_nmcustod WITH FRAME f_lancst.
                    NEXT-PROMPT tel_nrcustod WITH FRAME f_lancst.
                    NEXT.
                END.
                
                /*  Verifica se o associado esta cadastrado  */
                              
                FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND 
                                   crapass.nrdconta = tel_nrcustod 
                                   NO-LOCK NO-ERROR.
                
                IF   NOT AVAILABLE crapass   THEN
                DO:
                    glb_cdcritic = 9.
                    tel_nmcustod = "".
                    DISPLAY tel_nmcustod WITH FRAME f_lancst.
                    NEXT-PROMPT tel_nrcustod WITH FRAME f_lancst.
                    NEXT.  
                END.

                IF   crapass.dtelimin <> ? THEN
                DO:
                    glb_cdcritic = 410.
                    NEXT-PROMPT tel_nrcustod WITH FRAME f_lancst.
                    NEXT.
                END.
                
                IF   CAN-DO("5,6,7,8",STRING(crapass.cdsitdtl))   THEN
                DO:
                    glb_cdcritic = 695.
                    NEXT-PROMPT tel_nrcustod WITH FRAME f_lancst.
                    NEXT.
                END.

                IF   CAN-DO("2,4,6,8",STRING(crapass.cdsitdtl))   THEN
                DO:
                    FIND FIRST craptrf WHERE
                               craptrf.cdcooper = glb_cdcooper     AND 
                               craptrf.nrdconta = crapass.nrdconta AND
                               craptrf.tptransa = 1 USE-INDEX craptrf1
                               NO-LOCK NO-ERROR.
                             
                    IF   NOT AVAILABLE craptrf THEN
                    DO:
                        glb_cdcritic = 95.
                        NEXT-PROMPT tel_nrcustod WITH FRAME f_lancst.
                        NEXT.
                    END.
                    ELSE
                    DO:
                        glb_cdcritic = 156.
                        RUN fontes/critic.p.
                        MESSAGE glb_dscritic 
                                STRING(tel_nrcustod,"zzzz,zzz,9")
                                "para o numero" 
                                 STRING(craptrf.nrsconta,"zzzz,zzz,9").

                        ASSIGN tel_nrcustod = craptrf.nrsconta
                               glb_cdcritic = 0.
                        
                        DISPLAY tel_nrcustod WITH FRAME f_lancst.
                        
                        NEXT.
                    END.
                END.

                RUN sistema/generico/procedures/b1wgen0001.p
                    PERSISTENT SET h-b1wgen0001.
               
                IF   VALID-HANDLE(h-b1wgen0001)   THEN
                DO:
                    RUN ver_capital IN h-b1wgen0001(INPUT  glb_cdcooper,
                                                    INPUT  tel_nrcustod,
                                                    INPUT  0, /* cod-agencia */
                                                    INPUT  0, /* nro-caixa   */
                                                    0,        /* vllanmto */
                                                    INPUT  glb_dtmvtolt,
                                                    INPUT  "custod",
                                                    INPUT  1, /* AYLLOS */
                                                    OUTPUT TABLE tt-erro).
                    /* Verifica se houve erro */
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                    
                    IF   AVAILABLE tt-erro   THEN
                    DO:
                        ASSIGN glb_cdcritic = tt-erro.cdcritic
                               glb_dscricpl = tt-erro.dscritic.
                    END.
                    DELETE PROCEDURE h-b1wgen0001.
                END.
                /************************************/
                
                IF   glb_cdcritic > 0      OR
                     glb_dscricpl <> ""    THEN   
                DO:
                    NEXT-PROMPT tel_nrcustod WITH FRAME f_lancst.
                    NEXT.
                END.

                /*  Verifica se a conta foi ou sera transferida ...  */
                FIND FIRST craptrf WHERE craptrf.cdcooper = glb_cdcooper   AND 
                                         craptrf.nrdconta = tel_nrcustod   AND
                                         craptrf.tptransa = 1 NO-LOCK NO-ERROR.
                                                                          
                IF   AVAILABLE craptrf   THEN
                DO:
                    IF   craptrf.insittrs = 1   THEN
                        MESSAGE "Conta transferida para" 
                                TRIM(STRING(craptrf.nrsconta,"zzzz,zzz,9")).
                    ELSE
                        MESSAGE "Conta a ser transferida para"
                                TRIM(STRING(craptrf.nrsconta,"zzzz,zzz,9")).
                    
                    glb_cdcritic = 999.
                    NEXT.
                END.

                LEAVE.

            END.

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
            DO:
                HIDE FRAME f_lancst.
                NEXT.   
            END.

            ASSIGN tel_nmcustod = crapass.nmprimtl.
            DISPLAY tel_nmcustod WITH FRAME f_lancst.

            RUN opcao_i.
            HIDE FRAME f_lancst.
            NEXT.
        END.
   /*kBASE*/     
END.  /*  Fim do DO WHILE TRUE  */
  
/* .......................................................................... */

PROCEDURE opcao_i :

    DEF VAR aux_confirma AS CHARACTER FORMAT "!(1)"                  NO-UNDO.
    DEF VAR tel_dir      AS CHARACTER FORMAT "x(20)"                 NO-UNDO.
    DEF VAR tel_arquivo  AS CHARACTER                                NO-UNDO.
    DEF VAR aux_dscritic AS CHARACTER                                NO-UNDO.
    DEF VAR i-tot-lanc   AS INTEGER                                  NO-UNDO.
    DEF VAR d-val-lanc   AS DECIMAL                                  NO-UNDO.
    
    FORM SKIP(1)
         "Nome do arquivo a ser integrado:" AT 5
         SKIP(1)
         tel_dir        AT 5   NO-LABEL
         tel_nmarqint   AT 25  NO-LABEL
         HELP "Informe o arquivo p/integ. as inform. dos cheques custodiados."
         VALIDATE(INPUT tel_nmarqint <> "","375 - O campo deve ser preenchido.")
         SKIP(5)
         WITH WIDTH 78 OVERLAY ROW 10 CENTERED SIDE-LABELS
         TITLE " Integracao de Arquivo " FRAME f_integra_arq.
         
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
        FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.           
        
        ASSIGN tel_dir = "/micros/" + crapcop.dsdircop + "/".
          
        ASSIGN tel_nmarqint = " ".
        
        DISP tel_dir WITH FRAME f_integra_arq.
        UPDATE tel_nmarqint WITH FRAME f_integra_arq.
        
        ASSIGN tel_arquivo  = tel_dir + tel_nmarqint
               tel_nmarqint = tel_arquivo.
        
        /*valida arquivo*/                 
        IF   SEARCH(tel_nmarqint) = ?   THEN
        DO:
            glb_cdcritic = 182.
            RUN fontes/critic.p.
            glb_cdcritic = 0.
            BELL.
            MESSAGE glb_dscritic.
            PAUSE 2 NO-MESSAGE.
            NEXT.
        END.
                         
        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            aux_confirma = "N".
            glb_cdcritic = 78.
            RUN fontes/critic.p.
            BELL.                                           
            MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
            glb_cdcritic = 0.
            LEAVE.
        END.
               
        IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR   aux_confirma <> "S" THEN
             DO:
                 glb_cdcritic = 79.
                 RUN fontes/critic.p.
                 glb_cdcritic = 0.
                 BELL.
                 MESSAGE glb_dscritic.
                 PAUSE 2 NO-MESSAGE.
                 NEXT.
             END. /* Mensagem de confirmacao */

        RUN sistema/generico/procedures/b1wgen0076.p 
            PERSISTENT SET h_b1wgen0076.

        IF  VALID-HANDLE(h_b1wgen0076)  THEN
            DO:
                ASSIGN aux_dscritic = "".
                
                RUN ler_arquivo IN h_b1wgen0076 (INPUT  glb_cdcooper,
                                                 INPUT  glb_dtmvtolt,
                                                 INPUT  glb_cdoperad,
                                                 INPUT  tel_nmarqint,
                                                 INPUT  tel_cdagenci,
                                                 INPUT  tel_cdbccxlt,
                                                 INPUT  tel_nrdolote,
                                                 INPUT  tel_nrcustod,
                                                OUTPUT  aux_dscritic,
                                                OUTPUT  TABLE tt-msg-confirma,
                                                OUTPUT  TABLE arq-lote,
                                                OUTPUT  TABLE tt-retorno,
                                                OUTPUT  TABLE tt-erros-arq).
                
                IF   RETURN-VALUE <> "OK" THEN
                     DO:
                         DELETE PROCEDURE h_b1wgen0076.  
                         
                         BELL.
                         IF   aux_dscritic <> ""  THEN
                              MESSAGE aux_dscritic.
                         ELSE
                              MESSAGE "Operacao nao realizada.".
                         NEXT.
                     END.
            END.
        ELSE
            DO:
                BELL.
                MESSAGE "Handle invalido para h_b1wgen0076.".
                PAUSE 3 NO-MESSAGE.
                NEXT.
            END.

        FIND FIRST tt-erros-arq WHERE tt-erros-arq.flgderro NO-LOCK NO-ERROR.

        IF  AVAIL tt-erros-arq  THEN
        DO:
            FIND FIRST tt-msg-confirma NO-LOCK NO-ERROR.
            
            IF  AVAIL tt-msg-confirma  THEN
                glb_dscritic = tt-msg-confirma.dsmensag.
            ELSE
                glb_dscritic = "Arquivo possui restricao. " +
                               "Deseja continuar?".
            
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                aux_confirma = "N".
                BELL.                                           
                MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                LEAVE.
            END.
                   
            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   OR   aux_confirma <> "S"  THEN
            DO:
                ASSIGN tel_diretori = ""
                       tel_dir1     = "".
                
                DISP tel_dir1 tel_diretori WITH FRAME f_opcao1.
                
                MESSAGE "Arquivo nao processado. Informe (T)ela ou (A)rquivo.".
                
                UPDATE tel_dsdopcao1 WITH FRAME f_opcao1.
                
                IF   tel_dsdopcao1  THEN  /* Arquivo  */
                DO:
                    FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper 
                                 NO-LOCK NO-ERROR.
                
                    ASSIGN tel_dir1 = "/micros/" + crapcop.dsdircop + "/".
                
                    DISP tel_dir1 tel_diretori WITH FRAME f_opcao1.
                
                    UPDATE tel_diretori WITH FRAME f_opcao1.
                
                    ASSIGN tel_dir1     = tel_dir1 + tel_diretori
                           tel_diretori = tel_dir1.
                END.
                
                HIDE FRAME f_integra_arq.
                
                IF   tel_dsdopcao1 = TRUE  THEN  /* Arquivo */
                     RUN p_erros (INPUT FALSE).
                ELSE                            /* Tela */
                     RUN p_erros (INPUT TRUE).
            
           END. 
           
           NEXT.
        
        END.    
        
        HIDE MESSAGE NO-PAUSE.
        MESSAGE "Aguarde integrando o arquivo ...".
        
        FOR EACH arq-lote NO-LOCK:
            
            ASSIGN i-tot-lanc = arq-lote.qtd-cheques
                   d-val-lanc = arq-lote.val-cheques.        
        
            /* Integrar o arquivo */
            FOR EACH tt-retorno NO-LOCK BREAK BY tt-retorno.dtlibera:
            
                RUN integra-arquivo IN h_b1wgen0076 
                                   (INPUT glb_cdcooper, 
                                    INPUT glb_dtmvtolt, 
                                    INPUT glb_cdoperad, 
                                    INPUT tel_nmarqint,
                                    INPUT tel_cdagenci, 
                                    INPUT tel_cdbccxlt, 
                                    INPUT tt-retorno.nrdolote, 
                                    INPUT i-tot-lanc,
                                    INPUT d-val-lanc,
                                    INPUT tt-retorno.cdagechq, 
                                    INPUT tt-retorno.cdbanchq, 
                                    INPUT tt-retorno.cdcmpchq, 
                                    INPUT tt-retorno.dsdocmc7, 
                                    INPUT tt-retorno.dtlibera, 
                                    INPUT tt-retorno.nrctachq, 
                                    INPUT tt-retorno.nrdconta, 
                                    INPUT tt-retorno.nrddigc1, 
                                    INPUT tt-retorno.nrddigc2, 
                                    INPUT tt-retorno.nrddigc3, 
                                    INPUT tt-retorno.nrcheque, 
                                    INPUT tt-retorno.nrseqdig, 
                                    INPUT tt-retorno.vlcheque, 
                                    INPUT tt-retorno.corrente, 
                                    INPUT tt-retorno.inchqcop, 
                                    OUTPUT glb_dscritic).
            
                IF  RETURN-VALUE <> "OK"  THEN
                DO:
                    MESSAGE "Erro! " + glb_dscritic.
                    MESSAGE "CMC7: " + tt-retorno.dsdocmc7.
                END.
            END. /* Fim FOR EACH tt-retorno */
        END.     /* fim FOR EACH arq-lote */   
        
        MESSAGE "Arquivo processado com sucesso!".

        LEAVE.

    END.

    ASSIGN glb_cdcritic = 0.
    
    HIDE FRAME f_integra_arq.
    HIDE FRAME f_opcao1.
END.

PROCEDURE p_erros:
DEF INPUT PARAM par_operacao AS LOGICAL                           NO-UNDO.
   
DEF VAR aux_dslocali AS CHAR                                      NO-UNDO.
DEF VAR aux_nmendter AS CHAR                                      NO-UNDO.
DEF VAR c-dsdoerro   AS CHAR                                      NO-UNDO.

FORM "CRITICAS ARQUIVO DE CHEQUES CUSTODIADOS"
     SKIP(1)                                    
     WITH NO-BOX CENTERED FRAME f_titulo.

FORM "LOTE:" AT 12
     tt-erros-arq.nrdolote
     SKIP(1)
     WITH WIDTH 220 NO-BOX NO-LABEL FRAME f_critica_lote.

FORM "**"
     c-dsdoerro    FORMAT "x(200)"
     WITH WIDTH 220 NO-BOX NO-LABEL FRAME f_critica.

HIDE FRAME f_integra_arq.

INPUT THROUGH basename `tty` NO-ECHO.
SET aux_nmendter WITH FRAME f_terminal.
INPUT CLOSE.

aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                      aux_nmendter.
         
UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").
ASSIGN aux_nmarqimp = "rl/" + aux_nmendter + STRING(TIME) + ".ex".

OUTPUT STREAM str_2 TO VALUE(aux_nmarqimp).
         
DISPLAY STREAM str_2 WITH FRAME f_titulo.

FOR EACH tt-erros-arq NO-LOCK BREAK BY tt-erros-arq.nrdolote:

    IF  FIRST-OF(tt-erros-arq.nrdolote)  THEN
        DISPLAY STREAM str_2 tt-erros-arq.nrdolote WITH FRAME f_critica_lote.
    
    ASSIGN c-dsdoerro = tt-erros-arq.dsdoerro + " " +
                        IF tt-erros-arq.c-cmc7-ori <> "" THEN
                        "CMC7: " + tt-erros-arq.c-cmc7-ori
                        ELSE " ".
    
    DISPLAY STREAM str_2 c-dsdoerro
                         WITH FRAME f_critica.
    
    DOWN STREAM str_2 WITH FRAME f_critica.
END.

OUTPUT STREAM str_2 CLOSE.

IF   par_operacao  THEN
    RUN visualiza_erros.
ELSE
DO:
    UNIX SILENT VALUE("ux2dos " + aux_nmarqimp + " > " + tel_diretori).
    MESSAGE "Arquivo gerado com sucesso !" VIEW-AS ALERT-BOX.
END.
                    
HIDE FRAME f_opcao1.

END PROCEDURE.

PROCEDURE visualiza_erros.

DEF VAR edi_ficha   AS CHAR VIEW-AS EDITOR SIZE 230 BY 15 PFCOLOR 0.

DEF FRAME fra_ficha
    edi_ficha  HELP "Pressione <F4> ou <END> para finalizar"
    WITH SIZE 78 BY 15 ROW 6 COLUMN 2 USE-TEXT NO-BOX NO-LABELS OVERLAY.
        
PAUSE 0.
        
DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
    ENABLE edi_ficha WITH FRAME fra_ficha.
    DISPLAY edi_ficha WITH FRAME fra_ficha.
              
    ASSIGN edi_ficha:READ-ONLY IN FRAME fra_ficha = TRUE.
                 
    IF   edi_ficha:INSERT-FILE(aux_nmarqimp)   THEN
    DO:
        ASSIGN edi_ficha:CURSOR-LINE IN FRAME fra_ficha = 1.
        WAIT-FOR GO OF edi_ficha IN FRAME fra_ficha.
    END.
END.
                                        
HIDE MESSAGE NO-PAUSE.
                                        
ASSIGN edi_ficha:SCREEN-VALUE = "".
                                        
CLEAR FRAME fra_ficha ALL.
                                        
HIDE FRAME fra_ficha NO-PAUSE.

END PROCEDURE.
/*
PROCEDURE proc_query:
            
    OPEN QUERY que_tempcust FOR EACH crawcst.
           
    ENABLE ALL WITH FRAME f_browse.
                    
    ON RETURN OF bro_listlote DO:
                        
       IF   NOT AVAILABLE crawcst   THEN
            RETURN NO-APPLY.
            
       HIDE MESSAGE NO-PAUSE.
       
       DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

          aux_confirma = "N".

          BELL.
          MESSAGE COLOR NORMAL "Confirma a exclusao do protocolo (S/N)?" 
                               UPDATE aux_confirma.
          LEAVE.

       END.

       IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
            aux_confirma <> "S" THEN
            DO:
                BELL.
                MESSAGE "Protocolo NAO excluido!".
                RETURN NO-APPLY.
            END.
       
       ASSIGN aux_ttcheque = aux_ttcheque - crawcst.nrqtdchq                                 aux_somvalor = aux_somvalor - crawcst.vlchqlot.
       
       HIDE MESSAGE NO-PAUSE.
       
       MESSAGE "Foram selecionados" TRIM(STRING(aux_ttcheque,"zz,zz9")) 
               "cheques, totalizando o valor de R$ " + 
               TRIM(STRING(aux_somvalor, "zzz,zzz,zz9.99")).
                
       DELETE crawcst.

       OPEN QUERY que_tempcust FOR EACH crawcst.
        
       APPLY "ENTRY" TO btn_transchq IN FRAME f_browse.

       RETURN NO-APPLY.
                
    END.
                
    MESSAGE "Foram selecionados" TRIM(STRING(aux_ttcheque,"zz,zz9")) 
            "cheques, totalizando o valor de R$ " + 
             TRIM(STRING(aux_somvalor, "zzz,zzz,zz9.99")).
                 
    APPLY "ENTRY" TO btn_transchq IN FRAME f_browse.

    ON CHOOSE OF btn_transchq DO:
                    
       IF   aux_somvalor > 0   THEN
            DO:             

                MESSAGE "ATENCAO! Esta operacao NAO tem volta!"
                        VIEW-AS ALERT-BOX.
                          
                FIND crapope WHERE crapope.cdcooper = glb_cdcooper  AND
                                   crapope.cdoperad = glb_cdoperad
                                   NO-LOCK NO-ERROR.    
                                   
                RUN pedesenha (INPUT glb_cdcooper,
                               INPUT 2,
                               OUTPUT aut_flgsenha,
                               OUTPUT aut_cdoperad).
                                                                                
                IF   aut_flgsenha    THEN
                     DO:
                         UNIX SILENT VALUE("echo " + 
                                           STRING(glb_dtmvtolt,"99/99/9999") +
                                           " - " +
                                           STRING(TIME,"HH:MM:SS") +
                                           " - AUTORIZACAO DE DESCONTO" + 
                                           "' --> '" +
                                           " Operador: " + 
                                           STRING(aut_cdoperad,"x(10)") +
                                           " Conta: " + 
                                           STRING(tel_nrdconta,"zzzz,zzz,9") +
                                           " Qtd. Cheques: " +
                                           STRING(aux_ttcheque,"zz,zz9") +
                                           " Valor: " +
                                           STRING(aux_somvalor,
                                                  "zzz,zzz,zzz,zz9.99") +
                                           " >> log/custod.log").
                         
                         VIEW FRAME f_aguarde.
                         RUN proc_descontachq.
                         HIDE FRAME f_aguarde NO-PAUSE.
                                   
                         MESSAGE "Operacao realizada com sucesso!"
                                  VIEW-AS ALERT-BOX. 
                                    
                         CLEAR FRAME f_browse ALL NO-PAUSE.
                         aux_somvalor = 0.                 
                     END.
                                                                 
            END.          
       ELSE
            MESSAGE "Nao existem lotes selecionados para esta operacao !"
                    VIEW-AS ALERT-BOX.
                              
       APPLY "ENDKEY" TO FRAME f_browse.
       RETURN NO-APPLY.
           
    END.

    WAIT-FOR ENDKEY, DEFAULT-ACTION OF DEFAULT-WINDOW.

END PROCEDURE.
*/

/*
PROCEDURE proc_datas:

    aux_dtliber1 = tel_dtlibera.
    
    DO WHILE TRUE:
               
       aux_dtliber1 = aux_dtliber1 - 1.
       
       IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dtliber1)))   OR
            CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper AND
                                   crapfer.dtferiad = aux_dtliber1)   THEN
            NEXT.

       LEAVE.
               
    END.  /*  Fim do DO WHILE TRUE  */
               
    aux_dtliber2 = tel_dtlibera.
    
    DO WHILE TRUE:

       IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dtliber2)))   OR
            CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper AND
                                   crapfer.dtferiad = aux_dtliber2)   THEN
            DO:
                aux_dtliber2 = aux_dtliber2 + 1.
                NEXT.
            END.

       aux_dtliber2 = aux_dtliber2 + 1.
       
       LEAVE.
               
    END.  /*  Fim do DO WHILE TRUE  */

END PROCEDURE.

PROCEDURE proc_fechamento:
    
     ASSIGN aux_vlmenor = 0
            aux_qtmenor = 0
            aux_vlmaior = 0
            aux_qtmaior = 0.
     IF   tel_nrdconta > 0   THEN
         DO:
             IF   tel_dtlibera <> ?   THEN
                  FOR EACH crapcst WHERE crapcst.cdcooper = glb_cdcooper   AND
                                         crapcst.nrdconta = tel_nrdconta   AND
                                         crapcst.dtlibera > aux_dtliber1   AND
                                         crapcst.dtlibera < aux_dtliber2
                                         NO-LOCK USE-INDEX crapcst2:
                                  
                      IF   crapcst.dtdevolu <> ?   THEN
                           DO:
                               IF   crapcst.insitchq = 5   THEN
                                    ASSIGN res_qtchqdsc = res_qtchqdsc + 1
                                           res_vlchqdsc = res_vlchqdsc + 
                                                           crapcst.vlcheque.
                               ELSE
                                    ASSIGN res_qtchqdev = res_qtchqdev + 1
                                           res_vlchqdev = res_vlchqdev +
                                                          crapcst.vlcheque.
                                                          
                               NEXT.                         
                           END.
                     
                      IF   crapcst.inchqcop = 1   THEN
                           ASSIGN res_qtchqcop = res_qtchqcop + 1
                                  res_vlchqcop = res_vlchqcop +
                                                     crapcst.vlcheque.
                      ELSE
                           DO:
                               ASSIGN res_qtchqban = res_qtchqban + 1
                                      res_vlchqban = res_vlchqban + 
                                                     crapcst.vlcheque.

                               IF  crapcst.vlcheque < 300 THEN
                                   ASSIGN aux_vlmenor = aux_vlmenor + 
                                                        crapcst.vlcheque
                                          aux_qtmenor = aux_qtmenor + 1.
                               ELSE
                                   ASSIGN aux_vlmaior = aux_vlmaior + 
                                                        crapcst.vlcheque
                                          aux_qtmaior = aux_qtmaior + 1.
                           END.

                  END.  /*  Fim do FOR EACH -- Leitura do cheque custodia  */
             ELSE
                  FOR EACH crapcst WHERE crapcst.cdcooper = glb_cdcooper   AND
                                         crapcst.nrdconta = tel_nrdconta   AND
                                         crapcst.dtlibera > glb_dtmvtolt
                                         NO-LOCK USE-INDEX crapcst2:

                      IF   crapcst.dtdevolu <> ?   THEN
                           DO:
                               IF   crapcst.insitchq = 5   THEN
                                    ASSIGN res_qtchqdsc = res_qtchqdsc + 1
                                           res_vlchqdsc = res_vlchqdsc + 
                                                          crapcst.vlcheque.
                               ELSE
                                    ASSIGN res_qtchqdev = res_qtchqdev + 1
                                           res_vlchqdev = res_vlchqdev +
                                                          crapcst.vlcheque.
                               NEXT.
                           END.
                     
                      IF   crapcst.inchqcop = 1   THEN
                           ASSIGN res_qtchqcop = res_qtchqcop + 1
                                  res_vlchqcop = res_vlchqcop +
                                                     crapcst.vlcheque.
                      ELSE
                           DO:
                               ASSIGN res_qtchqban = res_qtchqban + 1
                                      res_vlchqban = res_vlchqban + 
                                                     crapcst.vlcheque.
           
                               IF  crapcst.vlcheque < 300 THEN
                                   ASSIGN aux_vlmenor = aux_vlmenor + 
                                                        crapcst.vlcheque
                                          aux_qtmenor = aux_qtmenor + 1.  
                               ELSE
                                   ASSIGN aux_vlmaior = aux_vlmaior + 
                                                        crapcst.vlcheque
                                          aux_qtmaior = aux_qtmaior + 1.
                           END.
 
              
                  END.  /*  Fim do FOR EACH -- Leitura do cheque custodia  */
         END.
    ELSE
         DO:
             IF   tel_dtlibera <> ?   THEN
                  FOR EACH crapcst WHERE crapcst.cdcooper  = glb_cdcooper  AND
                                         crapcst.nrdconta <> 85448         AND
                                         crapcst.dtlibera > aux_dtliber1   AND
                                         crapcst.dtlibera < aux_dtliber2
                                         NO-LOCK USE-INDEX crapcst3:
                                  
                      IF   crapcst.dtdevolu <> ?   THEN
                           DO:
                               IF   crapcst.insitchq = 5   THEN
                                    ASSIGN res_qtchqdsc = res_qtchqdsc + 1
                                           res_vlchqdsc = res_vlchqdsc + 
                                                          crapcst.vlcheque.
                               ELSE
                                    ASSIGN res_qtchqdev = res_qtchqdev + 1
                                           res_vlchqdev = res_vlchqdev +
                                                          crapcst.vlcheque.
                         
                               NEXT.
                           END.
                     
                      IF   crapcst.inchqcop = 1   THEN
                           ASSIGN res_qtchqcop = res_qtchqcop + 1
                                  res_vlchqcop = res_vlchqcop +
                                                     crapcst.vlcheque.
                      ELSE
                           DO:
                               ASSIGN res_qtchqban = res_qtchqban + 1
                                      res_vlchqban = res_vlchqban + 
                                                     crapcst.vlcheque.
 
                               IF  crapcst.vlcheque < 300 THEN
                                   ASSIGN aux_vlmenor = aux_vlmenor + 
                                                        crapcst.vlcheque
                                          aux_qtmenor = aux_qtmenor + 1. 
                               ELSE
                                   ASSIGN aux_vlmaior = aux_vlmaior + 
                                                        crapcst.vlcheque
                                          aux_qtmaior = aux_qtmaior + 1.
                           END.

                  END.  /*  Fim do FOR EACH -- Leitura do cheque custodia  */
             ELSE
                  FOR EACH crapcst WHERE crapcst.cdcooper = glb_cdcooper AND
                                         crapcst.nrdconta <> 85448       AND
                                         crapcst.dtlibera > glb_dtmvtolt
                                         NO-LOCK USE-INDEX crapcst3:

                      IF   crapcst.dtdevolu <> ?   THEN
                           DO:

                               IF   crapcst.insitchq = 5   THEN
                                    ASSIGN res_qtchqdsc = res_qtchqdsc + 1
                                           res_vlchqdsc = res_vlchqdsc + 
                                                          crapcst.vlcheque.
                               ELSE
                                    ASSIGN res_qtchqdev = res_qtchqdev + 1
                                           res_vlchqdev = res_vlchqdev +
                                                          crapcst.vlcheque.
                         
                               NEXT.
                           END.
                     
                      IF   crapcst.inchqcop = 1   THEN
                           ASSIGN res_qtchqcop = res_qtchqcop + 1
                                  res_vlchqcop = res_vlchqcop +
                                                     crapcst.vlcheque.
                      ELSE
                           DO:
                               ASSIGN res_qtchqban = res_qtchqban + 1
                                      res_vlchqban = res_vlchqban + 
                                                     crapcst.vlcheque.
                               
                               IF  crapcst.vlcheque < 300 THEN
                                   ASSIGN aux_vlmenor = aux_vlmenor + 
                                                        crapcst.vlcheque
                                          aux_qtmenor = aux_qtmenor + 1.   
                               ELSE
                                   ASSIGN aux_vlmaior = aux_vlmaior + 
                                                        crapcst.vlcheque
                                          aux_qtmaior = aux_qtmaior + 1.
                           END.
 
              
                  END.  /*  Fim do FOR EACH -- Leitura do cheque custodia  */
         END.

END PROCEDURE.
*/

/*
PROCEDURE proc_descontachq:

   DEF      VAR aux_novolote AS INT                     NO-UNDO.
   DEF      VAR aux_nrborder AS INT                     NO-UNDO.
   DEF      VAR aux_contalan AS INT                     NO-UNDO.
   DEF      VAR aux_contamsg AS INT                     NO-UNDO.
   DEF      VAR aux_contareg AS INT                     NO-UNDO.
   DEF      VAR aux_somalanc AS DECIMAL                 NO-UNDO.  
   
   ASSIGN aux_novolote = 10000
          aux_contalan = 0
          aux_somalanc = 0
          aux_contamsg = 0
          aux_contareg = 0
          aux_nrborder = 1
          aux_lsborder = "".
   
   DO WHILE TRUE TRANSACTION ON ERROR UNDO, LEAVE:

      FIND LAST craplot WHERE craplot.cdcooper  = glb_cdcooper      AND
                              craplot.dtmvtolt  = glb_dtmvtolt      AND
                              craplot.cdagenci  = crapass.cdagenci  AND
                              craplot.cdbccxlt  = 600               AND
                              craplot.nrdolote >= aux_novolote
                              NO-LOCK NO-ERROR.
                                                
      IF   AVAILABLE craplot   THEN
           aux_novolote = craplot.nrdolote + 1.
      ELSE
           aux_novolote = aux_novolote + 1.

      DO WHILE TRUE:
      
         FIND LAST crapbdc WHERE crapbdc.cdcooper = glb_cdcooper 
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
               
         IF   NOT AVAILABLE crapbdc   THEN
              IF   LOCKED crapbdc   THEN
                   DO:
                       PAUSE 2 NO-MESSAGE.
                       NEXT.
                   END.

         aux_nrborder = crapbdc.nrborder + 1. 
      
         LEAVE.
         
      END.  /*  Fim do DO WHILE TRUE  */
      
      FOR EACH crawcst WHILE aux_contalan < 400: 
      
          FOR EACH crapcst WHERE crapcst.cdcooper  = glb_cdcooper       AND
                                 crapcst.nrdconta  = tel_nrdconta       AND
 /*  Seleciona fim semana */     crapcst.dtliber   >  aux_dtmvtoan      AND
                                 crapcst.dtliber  <=  tel_dtlibera      AND
                                 crapcst.dtmvtolt  = crawcst.dtmvtolt   AND
                                 crapcst.cdagenci  = crawcst.cdagenci   AND
                                 crapcst.cdbccxlt  = crawcst.cdbccxlt   AND
                                 crapcst.nrdolote  = crawcst.nrdolote   AND
                                 crapcst.dtdevolu  = ?
                                 EXCLUSIVE-LOCK
                                 WHILE aux_contalan < 400:
                                 
              ASSIGN aux_contamsg = aux_contamsg + 1
                     aux_contareg = aux_contareg + 1.
              
              IF   aux_contamsg > 10   THEN
                   DO:
                       HIDE MESSAGE NO-PAUSE.
                       MESSAGE "Processando registro" aux_contareg "...".
                       aux_contamsg = 0.
                   END.
              
              IF   aux_contalan = 0   THEN
                   DO:
                       CREATE craplot.
                       ASSIGN craplot.dtmvtolt = glb_dtmvtolt
                              craplot.cdagenci = crapass.cdagenci
                              craplot.cdbccxlt = 700                  
                              craplot.nrdolote = aux_novolote
                              craplot.tplotmov = 26
                              craplot.cdoperad = glb_cdoperad
                              craplot.cdhistor = aux_nrborder
                              craplot.nrseqdig = 0
                              craplot.cdcooper = glb_cdcooper.

                       CREATE crapbdc.
                       ASSIGN crapbdc.nrborder = aux_nrborder
                              crapbdc.dtmvtolt = craplot.dtmvtolt
                              crapbdc.cdagenci = craplot.cdagenci
                              crapbdc.cdbccxlt = craplot.cdbccxlt
                              crapbdc.nrdolote = craplot.nrdolote
                              crapbdc.dtlibbdc = ?
                              crapbdc.cdoperad = glb_cdoperad
                              crapbdc.nrctrlim = craplim.nrctrlim
                              crapbdc.nrdconta = tel_nrdconta
                              crapbdc.cddlinha = craplim.cddlinha
                              crapbdc.txmensal = crapldc.txmensal
                              crapbdc.txdiaria = crapldc.txdiaria
                              crapbdc.txjurmor = crapldc.txjurmor
                              crapbdc.insitbdc = 1
                              crapbdc.inoribdc = 2
                              crapbdc.hrtransa = TIME
                              crapbdc.cdcooper = glb_cdcooper
                              
                              aux_lsborder = aux_lsborder +
                                             STRING(crapbdc.nrborder) + ",".
                                       
                   END.  /* fim IF aux_contalan ... */
                                        
              ASSIGN aux_contalan = aux_contalan + 1
                     aux_somalanc = aux_somalanc + crapcst.vlcheque.
 
              FIND crapcdb WHERE crapcdb.cdcooper = glb_cdcooper       AND
                                 crapcdb.cdcmpchq = crapcst.cdcmpchq   AND
                                 crapcdb.cdbanchq = crapcst.cdbanchq   AND
                                 crapcdb.cdagechq = crapcst.cdagechq   AND
                                 crapcdb.nrctachq = crapcst.nrctachq   AND
                                 crapcdb.nrcheque = crapcst.nrcheque   AND
                                 crapcdb.dtdevolu = ?
                                 EXCLUSIVE-LOCK NO-ERROR.
              
              IF   AVAILABLE crapcdb THEN
                   NEXT.

              aux_dtliber2 = crapcst.dtlibera.
    
              DO WHILE TRUE:

                 IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dtliber2)))   OR
                      CAN-FIND(crapfer WHERE 
                               crapfer.cdcooper = glb_cdcooper AND
                               crapfer.dtferiad = aux_dtliber2)   THEN
                      DO:
                          aux_dtliber2 = aux_dtliber2 + 1.
                          NEXT.
                      END.

                 LEAVE.
               
              END.  /*  Fim do DO WHILE TRUE  */
              
              CREATE crapcdb.
              ASSIGN crapcdb.cdagechq = crapcst.cdagechq
                     crapcdb.cdagenci = craplot.cdagenci
                     crapcdb.cdbanchq = crapcst.cdbanchq
                     crapcdb.cdbccxlt = 700
                     crapcdb.cdcmpchq = crapcst.cdcmpchq
                     crapcdb.cdoperad = glb_cdoperad
                     crapcdb.dsdocmc7 = crapcst.dsdocmc7

                     crapcdb.dtlibera = aux_dtliber2
                                           
                     crapcdb.dtmvtolt = craplot.dtmvtolt
                     crapcdb.insitchq = 0
                     crapcdb.nrctrlim = craplim.nrctrlim
                     crapcdb.nrborder = aux_nrborder
                     crapcdb.nrctachq = crapcst.nrctachq
                     crapcdb.nrdconta = tel_nrdconta
                     crapcdb.nrddigc1 = crapcst.nrddigc1
                     crapcdb.nrddigc2 = crapcst.nrddigc2
                     crapcdb.nrddigc3 = crapcst.nrddigc3
                     crapcdb.nrcheque = crapcst.nrcheque
                     crapcdb.nrdolote = craplot.nrdolote
                     crapcdb.nrseqdig = craplot.nrseqdig + 1
                     crapcdb.vlcheque = crapcst.vlcheque
                     crapcdb.inchqcop = crapcst.inchqcop
                     crapcdb.cdcooper = glb_cdcooper
                              
                     crapcst.dtdevolu = glb_dtmvtolt
                     crapcst.insitchq = 5
                     crapcst.nrborder = crapcdb.nrborder
                     crapcst.cdopedev = glb_cdoperad
                            
                     craplot.nrseqdig = craplot.nrseqdig + 1.
                             
              IF   crapcst.inchqcop = 1   THEN
                   DO WHILE TRUE:
                   
                       FIND craplau WHERE
                            craplau.cdcooper = glb_cdcooper     AND
                            craplau.dtmvtolt = crapcst.dtmvtolt AND
                            craplau.cdagenci = crapcst.cdagenci AND
                            craplau.cdbccxlt = crapcst.cdbccxlt AND
                            craplau.nrdolote = crapcst.nrdolote AND
                            craplau.nrdctabb = INT(crapcst.nrctachq) AND
                            craplau.nrdocmto = INT(STRING(crapcst.nrcheque) +
                                                   STRING(crapcst.nrddigc3))
                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                       
                       IF   NOT AVAILABLE craplau   THEN
                            IF   LOCKED craplau   THEN
                                 DO:
                                     PAUSE 2 NO-MESSAGE.
                                     NEXT.
                                 END.
                            ELSE
                                 DO:
                                      /*  DEFINIR  */
                                 
                                 END.
                       ELSE     
                            DO:
                                ASSIGN craplau.dtmvtolt = craplot.dtmvtolt
                                       craplau.cdagenci = craplot.cdagenci
                                       craplau.cdbccxlt = craplot.cdbccxlt
                                       craplau.nrdolote = craplot.nrdolote
                                       craplau.nrseqdig = craplot.nrseqdig
                                       craplau.cdhistor = 
                                          IF craplau.cdhistor = 21
                                             THEN 521
                                             ELSE IF craplau.cdhistor = 26
                                                     THEN 526
                                                     ELSE craplau.cdhistor.
                            END.
                       
                       FIND crabass WHERE crabass.cdcooper = glb_cdcooper  AND
                                          crabass.nrdconta = craplau.nrdconta
                                          NO-LOCK NO-ERROR.
 
                       IF   NOT AVAILABLE crabass   THEN
                            LEAVE.
                       
                       crapcdb.nrcpfcgc = crabass.nrcpfcgc.
                       
                       /*  Verifica o cadastro de emitentes de cheques  */
                       
                       FIND crapcec WHERE 
                            crapcec.cdcooper = glb_cdcooper       AND
                            crapcec.cdcmpchq = crapcdb.cdcmpchq   AND
                            crapcec.cdbanchq = crapcdb.cdbanchq   AND
                            crapcec.cdagechq = crapcdb.cdagechq   AND
                            crapcec.nrctachq = crapcdb.nrctachq   AND
                            crapcec.nrdconta = craplau.nrdconta
                            NO-LOCK NO-ERROR.
 
                       IF   NOT AVAILABLE crapcec   THEN
                            DO:
                                CREATE crapcec.
                                ASSIGN crapcec.cdagechq = crapcdb.cdagechq
                                       crapcec.cdbanchq = crapcdb.cdbanchq
                                       crapcec.cdcmpchq = crapcdb.cdcmpchq
                                       crapcec.nmcheque = crabass.nmprimtl
                                       crapcec.nrcpfcgc = crabass.nrcpfcgc
                                       crapcec.nrctachq = crapcdb.nrctachq
                                       crapcec.nrdconta = craplau.nrdconta
                                       crapcec.cdcooper = glb_cdcooper.
                            END.
                       
                       LEAVE.

                   END.  /*  Fim do DO WHILE TRUE  */
                                                
          END.  /* fim do FOR EACH crapcst... */

          IF   aux_contalan < 400   THEN
               DELETE crawcst.
               
      END.  /* fim do FOR EACH crawcst... */

      ASSIGN craplot.qtcompln = aux_contalan
             craplot.vlcompdb = aux_somalanc
             craplot.vlcompcr = aux_somalanc
             craplot.qtinfoln = aux_contalan
             craplot.vlinfodb = aux_somalanc
             craplot.vlinfocr = aux_somalanc.

      IF   aux_contalan = 400   THEN
           DO:
               ASSIGN aux_contalan = 0
                      aux_somalanc = 0.
           END.
      ELSE
           LEAVE.

   END. /* fim WHILE TRANSACTION... */
   
   RELEASE crapbdc.
   
   RUN fontes/custod_r2.p (aux_lsborder).
   
END PROCEDURE. /*** proc_descontachq ***/
*/

/*
PROCEDURE proc_pedelotes:

    DEF VAR pro_dtmvtolt AS DATE     FORMAT "99/99/9999"          NO-UNDO.
    DEF VAR pro_cdagenci AS INT      FORMAT "zz9"                 NO-UNDO.
    DEF VAR pro_nrdolote AS INT      FORMAT "zzz,zz9"             NO-UNDO.
    DEF VAR pro_vldasoma AS DECIMAL  FORMAT "zzz,zzz,zz9.99"      NO-UNDO.
    DEF VAR pro_qtcheque AS INT      FORMAT "zzz,zz9"             NO-UNDO.
    DEF VAR pro_dsdolote AS CHAR     FORMAT "x(50)"               NO-UNDO.
    
    FORM "Protocolo ==>" 
         pro_dtmvtolt FORMAT "99/99/9999" LABEL "Data" " "
         pro_cdagenci FORMAT "zz9"        LABEL "PA"
         "  Bco/Cxa: 600  "
         pro_nrdolote FORMAT "zzz,zz9"    LABEL "Lote"
         SKIP(2)
         pro_dsdolote FORMAT "x(75)" NO-LABEL
         WITH ROW 11 COLUMN 3 OVERLAY SIDE-LABELS NO-BOX FRAME f_lote.
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                     
       DISPLAY pro_dsdolote WITH FRAME f_lote.
       
       UPDATE pro_dtmvtolt pro_cdagenci pro_nrdolote WITH FRAME f_lote.

       VIEW FRAME f_aguarde.

       RUN sistema/generico/procedures/b1wgen0018.p 
           PERSISTENT SET h_b1wgen0018.
       RUN valida_lote_desconto IN h_b1wgen0018
                       (INPUT        glb_cdcooper,
                        INPUT        0,
                        INPUT        0,
                        INPUT        pro_dtmvtolt,
                        INPUT        pro_cdagenci,
                        INPUT        pro_nrdolote,
                        INPUT        tel_nrdconta,
                        INPUT        tel_dtlibera,
                        INPUT-OUTPUT TABLE crawlot,
                        OUTPUT       TABLE tt-erro,
                        OUTPUT       pro_dsdolote).
       DELETE PROCEDURE h_b1wgen0018.

       HIDE FRAME f_aguarde NO-PAUSE.

       IF   RETURN-VALUE = "NOK"   THEN
            DO:
                FOR EACH tt-erro BY tt-erro.nrsequen:
                    BELL.
                    MESSAGE tt-erro.dscritic.
                END.
                NEXT.
            END.
                                       
       HIDE MESSAGE NO-PAUSE.
   
    END.  /*  Fim do DO WHILE TRUE  */
    
    HIDE FRAME f_lote NO-PAUSE.
    
END PROCEDURE.  /*  proc_pedelotes  */
*/

/*
PROCEDURE pedesenha:
    DEFINE  INPUT PARAMETER par_cdcooper AS INTEGER                   NO-UNDO.
    DEFINE  INPUT PARAMETER par_nvoperad AS INTEGER                   NO-UNDO.
    DEFINE OUTPUT PARAMETER par_nsenhaok AS LOGICAL INIT FALSE        NO-UNDO.
    DEFINE OUTPUT PARAMETER par_cdoperad AS CHAR                      NO-UNDO.

    DEFINE    VAR tel_cdoperad AS CHAR                                NO-UNDO.
    DEFINE    VAR tel_nrdsenha AS CHAR                                NO-UNDO.
    DEFINE    VAR tel_nvoperad AS CHAR EXTENT 3 INITIAL
                                                    ["   Operador",
                                                     "Coordenador",
                                                     "    Gerente"]   NO-UNDO.
    
    DEFINE FRAME f_moldura WITH ROW 8 SIZE 30 BY 6 
                           OVERLAY CENTERED TITLE " Digite a Senha ".

    FORM  SKIP(1)
          tel_nvoperad[par_nvoperad]  FORMAT "x(11)" NO-LABEL AT 4 ":" 
          tel_cdoperad  FORMAT "x(10)"  NO-LABEL SKIP
          "Senha :"    AT 10
          tel_nrdsenha FORMAT "x(10)" BLANK NO-LABEL SKIP(1)
          WITH NO-BOX ROW 9 SIZE 28 BY 3 CENTERED OVERLAY FRAME f_senha.
                           
    VIEW FRAME f_moldura.

    PAUSE(0).

    DISP tel_nvoperad[par_nvoperad] WITH FRAME f_senha.

    DO WHILE NOT par_nsenhaok ON ENDKEY UNDO, LEAVE:

       UPDATE tel_cdoperad tel_nrdsenha WITH FRAME f_senha.
                                               
       FIND crapope WHERE crapope.cdcooper       = par_cdcooper         AND
                          crapope.cdoperad       = tel_cdoperad         AND
                          TRIM(crapope.cddsenha) = TRIM(tel_nrdsenha)
                          NO-LOCK NO-ERROR.
                                                                      
       IF   AVAILABLE crapope   THEN
            DO:
                IF   crapope.nvoperad >= par_nvoperad   THEN
                     DO:
                         ASSIGN par_nsenhaok = TRUE.
                                par_cdoperad = tel_cdoperad.
                         LEAVE.              
                     END.
                ELSE
                     DO:
                         MESSAGE "E' necessario que a senha digitada seja " +
                                 "de um " +
                                 TRIM(tel_nvoperad[par_nvoperad]) +
                                 "!"  VIEW-AS ALERT-BOX. 
                     END.
            END.
       ELSE
            MESSAGE "003 - Senha errada." VIEW-AS ALERT-BOX.
                                          
    END.

    HIDE FRAME f_moldura.
    HIDE FRAME f_senha.

END PROCEDURE.
*/

/* .......................................................................... */

 
