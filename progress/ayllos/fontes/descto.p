/* ............................................................................

   Programa: Fontes/descto.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Outubro/2003.                       Ultima atualizacao: 03/01/2012

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela descto - desconto de cheques.

   Alteracoes: 08/03/2004 - Demonstrar Valores Maiores/Menores(Mirtes)

               07/10/2004 - Imprimir relatorios de pesquisa de cheques (Edson).
               
               26/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               26/01/2006 - Unificacao dos Bancos - SQLWorks - Andre

               07/07/2006 - Implementado consulta por CPF na opcao "C" (David).
               
               20/08/2008 - Nao considerar cheques redescontados como cheques
                            resgatados (Evandro).
                            
               04/03/2009 - Incluido o numero do bordero e o numero do contrato
                            na exibicao dos campos (Evandro).
                            
               15/07/2009 - Alteracao CDOPERAD (Diego).
               
               29/10/2009 - Inclusao de opcao de imprimir de um PAC especifico 
                            - parametro;
                            Estruturacao do programa em BO (GATI - Eder)
                            
               27/10/2010 - Inclusao da opcao A para que possa ser alterado
                            cpf/cgc e o nome do emitente do cheque (Adriano). 
                                                        
               09/12/2010 - Inclusao dos campos Data inicial e final na 
                            consulta (GATI - Sandro)
                            
               08/07/2011 - Incluido glb_cdoperad na passagem de parametros
                            da procedure alterar_cheques_descontados
                            (Adriano).
                            
               03/01/2012 - Reestruturação BO para desenvolvimento web
                            (Gabriel Capoia - DB1).
               
               12/11/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (Guilherme Gielow)
                            
               25/02/2015 - Revitalizacao desta tela (Carlos Rafael Tanholi)             
                                        
............................................................................ */

{ sistema/generico/includes/b1wgen0018tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }

DEF BUFFER crabass FOR crapass.

DEF        VAR tel_nrdconta AS INTE     FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF        VAR tel_nrcpfcgc AS DECI     FORMAT "zzzzzzzzzzzzz9"       NO-UNDO.
DEF        VAR aux_nmdcampo AS CHAR                                   NO-UNDO.
DEF        VAR aux_nrdconta AS INTE                                   NO-UNDO.
DEF        VAR aux_qtregist AS INTE                                   NO-UNDO.

DEF        VAR tel_nmprimtl AS CHAR    FORMAT "x(40)"                 NO-UNDO.

DEF        VAR tel_dtlibera AS DATE    FORMAT "99/99/9999"            NO-UNDO.
DEF        VAR tel_dtlibini AS DATE    FORMAT "99/99/9999"            NO-UNDO.
DEF        VAR tel_dtlibfim AS DATE    FORMAT "99/99/9999"            NO-UNDO.
DEF        VAR tel_dtmvtolt AS DATE    FORMAT "99/99/9999"            NO-UNDO.
DEF        VAR tel_dtiniper AS DATE    FORMAT "99/99/9999"            NO-UNDO.
DEF        VAR tel_dtfimper AS DATE    FORMAT "99/99/9999"            NO-UNDO.
  
DEF        VAR tel_cdbanchq AS INTE                                   NO-UNDO.
DEF        VAR tel_cdagenci AS INTE    FORMAT "zz9"                   NO-UNDO.
DEF        VAR tel_cdagechq AS INTE                                   NO-UNDO.
DEF        VAR tel_nrctachq AS DECI                                   NO-UNDO.
DEF        VAR tel_nrcheque AS INTE                                   NO-UNDO.
DEF        VAR tel_vlcheque AS DECI                                   NO-UNDO.
DEF        VAR tel_vldescto AS DECI                                   NO-UNDO.
DEF        VAR tel_cdcmpchq AS INTE    FORMAT "z,zz9"                 NO-UNDO.
DEF        VAR tel_nrborder AS INTE    FORMAT "z,zzz,zz9"             NO-UNDO.
DEF        VAR tel_nmcheque AS CHAR    FORMAT "x(40)"                 NO-UNDO.

DEF        VAR tel_dsdopcao AS CHAR    EXTENT 3                              
               INIT ["Cooper","Demais Associados","Total Geral"]      NO-UNDO.

DEF        VAR tel_dsdvalor AS CHAR    EXTENT 3                              
               INIT ["Qualquer Valor","Inferiores","Superiores"]      NO-UNDO.

DEF        VAR tel_dschqcop AS CHAR    EXTENT 3                              
               INIT ["Qualquer Cheque","Outros Bancos","Cooperativa"] NO-UNDO.

DEF        VAR aux_contador AS INTE     FORMAT "99"                   NO-UNDO.
DEF        VAR aux_tpdsaldo AS INTE                                   NO-UNDO.
DEF        VAR aux_tpdconta AS INTE                                   NO-UNDO.
DEF        VAR aux_tpdvalor AS INTE                                   NO-UNDO.
DEF        VAR aux_tpchqcop AS INTE                                   NO-UNDO.
DEF        VAR aux_flgretor AS LOGI                                   NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                   NO-UNDO.
DEF        VAR aux_confirma AS CHAR    FORMAT "!"                     NO-UNDO.
DEF        VAR aux_nmcheque AS CHAR    FORMAT "x(40)"                 NO-UNDO.
DEF        VAR aux_nrcpfcgc AS DECI    FORMAT "zzzzzzzzzzzzz9"        NO-UNDO.
DEF        VAR aux_situacao AS CHAR                                   NO-UNDO.

DEF        VAR h_b1wgen0018 AS HANDLE                                 NO-UNDO.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT  2 LABEL "Opcao" AUTO-RETURN
     HELP
"Cons,Fecham,iMpres,Pesq,Quem,Rel.lotes,Saldo,T=pesquisa,cOnferencia"
                        VALIDATE(CAN-DO("A,C,F,M,O,P,Q,R,S,T",glb_cddopcao),
                                 "014 - Opcao errada.")
     WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_descto.

FORM tel_nrdconta AT 1  LABEL "Conta/dv" AUTO-RETURN
                        HELP "Informe o numero da conta do associado"
     tel_nmprimtl AT 25 NO-LABEL
     WITH ROW 6 COLUMN 15 SIDE-LABELS OVERLAY NO-BOX FRAME f_conta.
     
FORM tel_nrdconta AT 1  LABEL "Conta/dv" AUTO-RETURN
                        HELP "Informe o numero da conta do associado."
     WITH ROW 6 COLUMN 15 SIDE-LABELS OVERLAY NO-BOX FRAME f_favorecido. 

FORM tel_nrcpfcgc AT 1  LABEL "CPF/CNPJ"  AUTO-RETURN
                        HELP "Informe o numero do CPF/CNPJ."
     WITH ROW 6 COLUMN 39 SIDE-LABELS OVERLAY NO-BOX FRAME f_cpf/cgc.          

FORM tel_nmprimtl AT 1  LABEL "Titular"
     WITH ROW 7 COLUMN 15 SIDE-LABELS OVERLAY NO-BOX FRAME f_titular.

FORM tel_dtlibini AT 1  LABEL "Data Inicial" 
                        HELP "Informe a data inicial de liberacao."
     tel_dtlibfim AT 36 LABEL "Data Final"
                        HELP "Informe a data final de liberacao."
     WITH ROW 8 COLUMN 15 SIDE-LABELS OVERLAY NO-BOX FRAME f_periodo.
    
FORM tel_nrdconta AT 1  LABEL "Conta    "        FORMAT "zzz,zzz,zzz,9"
                        HELP  "Informe a conta do associado."
     tel_nrborder AT 36 LABEL "Bordero"          FORMAT "z,zzz,zz9"
                        HELP  "Informe o numero do bordero."    
     SKIP(1)
     "Dados do cheque"
     SKIP(1)
     tel_cdcmpchq AT 1  LABEL "Comp     "         FORMAT "z,zz9"
                        HELP  "Informe Comp do cheque."
     tel_cdbanchq AT 36 LABEL "Banco  "           FORMAT "zz9"
                        HELP  "Informe Banco do cheque."
     SKIP
     tel_cdagechq AT 1  LABEL "Agencia  "         FORMAT "zzz9"
                        HELP  "Informe Agencia do cheque."
                                                
     tel_nrctachq AT 36 LABEL "Conta  "           FORMAT "zzz,zzz,zzz,9"
                        HELP  "Informe Conta do cheque."
     SKIP
     tel_nrcheque AT 1  LABEL "Nro Cheque"  FORMAT "zzz,zz9"
                        HELP  "Informe Nro do cheque."
     SKIP(1)
     aux_nrcpfcgc AT 1  LABEL "CPF/CNPJ"          FORMAT "zzzzzzzzzzzzz9"
                        HELP  "Informe o CPF/CNPJ."
     SKIP(1)
     aux_nmcheque AT 1  LABEL "Nome"              FORMAT "x(40)"
                        HELP  "Informe o nome."
     WITH ROW 6 COLUMN 15 SIDE-LABELS OVERLAY NO-BOX FRAME f_alterar.
     
FORM "Listar Contas  --> "
     tel_dsdopcao[1] FORMAT "x(6)"
     tel_dsdopcao[2] FORMAT "x(17)"
     tel_dsdopcao[3] FORMAT "x(11)"
     WITH ROW 6 COLUMN 15 NO-LABELS OVERLAY NO-BOX FRAME f_lst_contas.

FORM "Listar Cheques --> "
     tel_dsdvalor[1] FORMAT "x(14)"
     tel_dsdvalor[2] FORMAT "x(10)"
     tel_dsdvalor[3] FORMAT "x(10)"
     WITH ROW 8 COLUMN 15 NO-LABELS OVERLAY NO-BOX FRAME f_lst_valores.

FORM "Listar Cheques --> "
     tel_dschqcop[1] FORMAT "x(15)"
     tel_dschqcop[2] FORMAT "x(13)"
     tel_dschqcop[3] FORMAT "x(11)"
     WITH ROW 10 COLUMN 15 NO-LABELS OVERLAY NO-BOX FRAME f_lst_bancos.

FORM "Listar o Periodo de" 
     tel_dtiniper FORMAT "99/99/9999" "ate"  
     tel_dtfimper FORMAT "99/99/9999"
     WITH ROW 12 COLUMN 15 NO-LABELS OVERLAY NO-BOX FRAME f_lst_periodo.

FORM "Liberar  Bco  Ag."        AT  1
     "Conta Cheque"             AT 27
     "Valor Resg/Dev Operador"  AT 45
     "Conta/dv"                 AT 71
     WITH ROW 9 COLUMN 2 NO-LABELS OVERLAY NO-BOX FRAME f_label.

FORM tt-crapcdb.dtlibera AT  1 FORMAT "99/99/99"
     tt-crapcdb.cdbanchq AT 10 FORMAT "zz9"
     tt-crapcdb.cdagechq AT 14 FORMAT "zzz9"
     tt-crapcdb.nrctachq AT 19 FORMAT "zzz,zzz,zzz,9"             
     tt-crapcdb.nrcheque AT 33 FORMAT "zzzzz9"
     tt-crapcdb.vlcheque AT 40 FORMAT "zzz,zz9.99"
     tt-crapcdb.dtdevolu AT 51 FORMAT "99/99/99"
     tt-crapcdb.situacao AT 59 FORMAT "x(1)"
     tt-crapcdb.cdopedev AT 61 FORMAT "x(9)"
     tt-crapcdb.nrdconta AT 71 FORMAT "zzzzzzz9"
     WITH ROW 10 COLUMN 2 OVERLAY 11 DOWN NO-LABEL NO-BOX FRAME f_lanctos.

DEF QUERY  q_opcao_c  FOR tt-crapcdb.
DEF BROWSE b_opcao_c  QUERY q_opcao_c
    DISPLAY tt-crapcdb.dtlibera LABEL "Liberar"  FORMAT "99/99/99"     
            tt-crapcdb.cdbanchq LABEL "Bco"      FORMAT "zz9"          
            tt-crapcdb.cdagechq LABEL "Ag."      FORMAT "zzz9"         
            tt-crapcdb.nrctachq LABEL "Conta"    FORMAT "zzzzzzzzz9"
            tt-crapcdb.nrcheque LABEL "Cheque"   FORMAT "zzzzz9"       
            tt-crapcdb.vlcheque LABEL "Valor"    FORMAT "zzz,zz9.99"   
            tt-crapcdb.dtdevolu LABEL "Resg/Dev" FORMAT "99/99/99"     
            tt-crapcdb.situacao LABEL ""         FORMAT "x(1)"         
            tt-crapcdb.cdopedev LABEL "Operador" FORMAT "x(9)"         
            tt-crapcdb.nrdconta LABEL "Conta/dv" FORMAT "zzzzzzz9"
            WITH 9 DOWN WIDTH 78 NO-LABELS NO-BOX OVERLAY.

FORM SKIP(1)
    b_opcao_c  HELP "Use as SETAS para navegar ou F4 para sair"
    SKIP
    WITH ROW 9 COLUMN 2 OVERLAY NO-LABEL NO-BOX FRAME f_opcao_c.

FORM tel_cdbanchq AT  2 LABEL "Banco"            FORMAT "zz9"
                        HELP "Informe o numero do banco impresso no cheque."
     tel_cdagechq AT 14 LABEL "Agencia"          FORMAT "zzz9"
                        HELP "Informe o numero da agencia impresso no cheque."
     tel_nrctachq AT 29 LABEL "Conta"            FORMAT "zzz,zzz,zzz,9"
                        HELP "Informe o numero da conta impresso no cheque."
     tel_nrcheque AT 51 LABEL "Numero do Cheque" FORMAT "zzz,zz9"
                        HELP "Informe o numero do cheque impresso no cheque."
     SKIP(1)
     tt-crapcdb.dspesqui AT  2 LABEL "Pesquisa"  FORMAT "x(31)"
     tt-crapcdb.dssitchq AT 44 LABEL "Situacao"  FORMAT "x(22)"
     SKIP(1)
     "Comp  Bco  Agencia  C1" AT  4
     "Conta  C2   Cheque  C3" AT 37
     "Valor"                  AT 70
     SKIP(1)
     tt-crapcdb.cdcmpchq      AT 03 NO-LABEL
     tt-crapcdb.cdbanchq      AT 08 NO-LABEL
     tt-crapcdb.cdagechq      AT 17 NO-LABEL
     tt-crapcdb.nrddigc1      AT 25 NO-LABEL
     tt-crapcdb.nrctachq      AT 26 NO-LABEL
     tt-crapcdb.nrddigc2      AT 45 NO-LABEL
     tt-crapcdb.nrcheque      AT 48 NO-LABEL
     tt-crapcdb.nrddigc3      AT 58 NO-LABEL
     tt-crapcdb.vlcheque      AT 61 NO-LABEL
     SKIP(1)
     tt-crapcdb.dsdocmc7      AT  5    LABEL "CMC-7"
     SKIP                         
     tt-crapcdb.nrborder      AT  3    LABEL "Bordero"
     tt-crapcdb.nrctrlim      AT 37    LABEL "Contrato"
     SKIP                         
     tt-crapcdb.dtlibera      AT  2    LABEL "Liberar para"
     tt-crapcdb.dsobserv      AT 30 NO-LABEL FORMAT "x(47)"
     SKIP
     tt-crapcdb.nmopedev      AT 30 NO-LABEL FORMAT "x(40)"
     WITH ROW 8 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_pesquisa.

FORM tel_dtlibera           AT 21    LABEL "Liberacao para"
     SKIP(1)
     "Qtd.           Valor" AT 41
     SKIP(1)
     tt-fechamento.qtcheque AT 18    LABEL "Cheques Recebidos"
     tt-fechamento.vlcheque AT 47 NO-LABEL
     tt-fechamento.qtchqdev AT 17    LABEL "Cheques Resgatados"
     tt-fechamento.vlchqdev AT 47 NO-LABEL
     SKIP(1)
     tt-fechamento.dschqcop AT 16 NO-LABEL
     tt-fechamento.qtchqcop AT 37 NO-LABEL
     tt-fechamento.vlchqcop AT 47 NO-LABEL
     tt-fechamento.qtchqban AT 11    LABEL "Cheques de Outros Bancos"
     tt-fechamento.vlchqban AT 47 NO-LABEL
     tt-fechamento.qtdmenor AT 11    LABEL "                   Menor"
     tt-fechamento.vlrmenor AT 47 NO-LABEL
     tt-fechamento.qtdmaior AT 11    LABEL "                   Maior"
     tt-fechamento.vlrmaior AT 47 NO-LABEL
     tt-fechamento.qtcredit AT 20    LABEL "Valor a LIBERAR"
     tt-fechamento.vlcredit AT 47 NO-LABEL
     WITH ROW 8 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_fechamento.

FORM tel_dtlibera AT 21 LABEL "Saldo Contabil em"
     SKIP(1)
     "Qtd.           Valor"   AT 41
     SKIP(1)
     tt-saldo.qtsldant        AT 21    LABEL "Saldo Anterior"
     tt-saldo.vlsldant        AT 47 NO-LABEL
     tt-saldo.qtcheque        AT 18    LABEL "Cheques Recebidos"
     tt-saldo.vlcheque        AT 47 NO-LABEL
     tt-saldo.qtlibera        AT 19    LABEL "Liberados no dia"
     tt-saldo.vllibera        AT 47 NO-LABEL
     tt-saldo.qtchqdev        AT 17    LABEL "Cheques Resgatados"
     tt-saldo.vlchqdev        AT 47 NO-LABEL
     SKIP(1)
     tt-saldo.qtcredit        AT 24    LABEL "SALDO ATUAL"
     tt-saldo.vlcredit        AT 47 NO-LABEL
     SKIP(1)
     tt-saldo.dschqcop        AT 16 NO-LABEL
     tt-saldo.qtchqcop        AT 37 NO-LABEL
     tt-saldo.vlchqcop        AT 47 NO-LABEL
     tt-saldo.qtchqban        AT 11    LABEL "Cheques de Outros Bancos"
     tt-saldo.vlchqban        AT 47 NO-LABEL
     WITH ROW 8 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_contabilidade.

FORM tel_dtmvtolt AT 1 LABEL "Listar os lotes do dia"
     tel_cdagenci      LABEL "   PA "
     WITH ROW 6 COLUMN 15 SIDE-LABELS OVERLAY NO-BOX FRAME f_movto.

FORM tel_dtiniper AT 1 LABEL "De" 
     tel_dtfimper      LABEL "Ate"
     tel_nrdconta      LABEL "Conta/DV"
     tel_cdagenci      LABEL "PA" 
     HELP "Informe um PA especifico ou 0 para considerar todos"
     WITH ROW 6 COLUMN 15 SIDE-LABELS OVERLAY NO-BOX FRAME f_conferencia.

FORM "Documento a pesquisar:"
     tel_cdbanchq LABEL "Banco"   FORMAT "zz9"
     tel_nrcheque LABEL "Cheque"  FORMAT "zzz,zz9"
     tel_vlcheque LABEL "Valor"   FORMAT "zzz,zzz,zz9.99"
     WITH ROW 8 COLUMN 3 SIDE-LABELS OVERLAY NO-BOX FRAME f_seltodos.

FORM tt-lancamentos.dtlibera  COLUMN-LABEL "Liberacao" FORMAT "99/99/9999"
     tt-lancamentos.pesquisa  COLUMN-LABEL "Pesquisa"  FORMAT "x(25)"
     tt-lancamentos.cdbanchq  COLUMN-LABEL "Bco"       FORMAT "zz9"
     tt-lancamentos.cdagechq  COLUMN-LABEL "Ag."       FORMAT "zzz9"
     tt-lancamentos.nrctachq  COLUMN-LABEL "Conta"     FORMAT "zzzzzzzzz,9"
     tt-lancamentos.nrcheque  COLUMN-LABEL "Cheque"    FORMAT "zzz,zz9"
     tt-lancamentos.vlcheque  COLUMN-LABEL "Valor"     FORMAT "zzz,zz9.99"
     WITH ROW 10 COLUMN 3 OVERLAY 9 DOWN NO-BOX FRAME f_todos.

DEF QUERY q_opcao_t FOR tt-lancamentos.
DEF BROWSE b_opcao_t QUERY q_opcao_t
    DISPLAY tt-lancamentos.dtlibera LABEL "Liberacao" FORMAT "99/99/9999"
            tt-lancamentos.pesquisa LABEL "Pesquisa"  FORMAT "x(25)"
            tt-lancamentos.cdbanchq LABEL "Bco"       FORMAT "zz9"
            tt-lancamentos.cdagechq LABEL "Ag."       FORMAT "zzz9"
            tt-lancamentos.nrctachq LABEL "Conta"     FORMAT "zzzzzzzzz,9"
            tt-lancamentos.nrcheque LABEL "Cheque"    FORMAT "zzz,zz9"
            tt-lancamentos.vlcheque LABEL "Valor"     FORMAT "zzz,zz9.99"
            WITH 10 DOWN WIDTH 78 NO-LABELS NO-BOX OVERLAY.

FORM SKIP(1)
    b_opcao_t  HELP "Use as SETAS para navegar ou F4 para sair"
    SKIP
    WITH ROW 8 COLUMN 2 OVERLAY NO-LABEL NO-BOX FRAME f_opcao_t.

FORM tt-crapcdb.dtmvtolt AT 2 COLUMN-LABEL "Desctdo em"  FORMAT "99/99/9999"
     tt-crapcdb.dtlibera      COLUMN-LABEL "Liberar em"  FORMAT "99/99/9999"
     tt-crapcdb.nrdconta      COLUMN-LABEL "Desctdo por" FORMAT "zzzz,zzz,9"
     tt-crapcdb.nmprimtl      COLUMN-LABEL " "           FORMAT "x(21)"
     tt-crapcdb.nrcheque      COLUMN-LABEL "Cheque"      FORMAT "zzz,zz9"
     tt-crapcdb.vlcheque      COLUMN-LABEL "Valor"       FORMAT "z,zzz,zz9.99"
     WITH ROW 8 COLUMN 2 OVERLAY 11 DOWN NO-BOX FRAME f_quem_descontou.

DEF QUERY  q_opcao_q  FOR tt-crapcdb.
DEF BROWSE b_opcao_q  QUERY q_opcao_q
    DISPLAY tt-crapcdb.dtmvtolt LABEL "Desctdo em"  FORMAT "99/99/9999"
            tt-crapcdb.dtlibera LABEL "Liberar em"  FORMAT "99/99/9999"
            tt-crapcdb.nrdconta LABEL "Desctdo por" FORMAT "zzzz,zzz,9"
            tt-crapcdb.nmprimtl LABEL " "           FORMAT "x(21)"
            tt-crapcdb.nrcheque LABEL "Cheque"      FORMAT "zzz,zz9"
            tt-crapcdb.vlcheque LABEL "Valor"       FORMAT "z,zzz,zz9.99"
            WITH 9 DOWN WIDTH 78 NO-LABELS NO-BOX OVERLAY.

FORM SKIP(1)
    b_opcao_q  HELP "Use as SETAS para navegar ou F4 para sair"
    SKIP
    "------------------------------------------------------------------" AT 02
    SPACE(0)
    "-----------"
    SKIP
    tel_vldescto AT 2 LABEL "Total descontado" FORMAT "zzz,zzz,zz9.99"
    WITH ROW 7 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_opcao_q.

FORM "  A G U A R D E ...  " 
    WITH ROW 10 CENTERED OVERLAY FRAME f_aguarde.

VIEW FRAME f_moldura.

PAUSE (0).

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0
       tel_dtlibera = ?.

RUN fontes/inicia.p.

Inicio: DO WHILE TRUE:

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        UPDATE glb_cddopcao WITH FRAME f_descto.

        HIDE FRAME f_opcao. 
        HIDE FRAME f_movto.
        HIDE FRAME f_label.
        HIDE FRAME f_pesquisa.
        HIDE FRAME f_lanctos.
        HIDE FRAME f_fechamento.
        HIDE FRAME f_contabilidade.
        HIDE FRAME f_conta.
        HIDE FRAME f_favorecido.
        HIDE FRAME f_cpf/cgc.
        HIDE FRAME f_titular.
        HIDE FRAME f_seltodos.
        HIDE FRAME f_todos.
        HIDE FRAME f_quem_descontou.
        HIDE FRAME f_periodo.
        HIDE FRAME f_alterar.

        IF  glb_cddopcao <> "Q"   THEN
            DO:
                
                ASSIGN tel_nrdconta = 0
                       tel_nrcpfcgc = 0
                       tel_nmprimtl = ""
                       tel_dtlibini = ?
                       tel_dtlibfim = ?.

                CLEAR FRAME f_conta      NO-PAUSE.
                CLEAR FRAME f_favorecido NO-PAUSE.
                CLEAR FRAME f_cpf/cgc    NO-PAUSE.
                CLEAR FRAME f_titular    NO-PAUSE.
                CLEAR FRAME f_periodo    NO-PAUSE.
            END.

        IF  NOT CAN-DO("R,S,O,C,A",glb_cddopcao)  THEN
            DO:
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    UPDATE tel_nrdconta WITH FRAME f_conta
                    EDITING:
                        READKEY PAUSE 1.
                   
                        IF  LASTKEY = KEYCODE("F7") THEN
                            DO:
                                RUN fontes/zoom_associados.p 
                                    ( INPUT  glb_cdcooper,
                                      OUTPUT aux_nrdconta).

                                IF  aux_nrdconta > 0   THEN
                                    DO:
                                        ASSIGN tel_nrdconta = aux_nrdconta.
                                        DISPLAY tel_nrdconta WITH FRAME f_conta.
                                        PAUSE 0.
                                    END.
                            END.

                        APPLY LASTKEY.

                    END. /* fim do EDITING */
                            

                    RUN conecta_handle.
                    
                    RUN busca_informacoes_associado IN h_b1wgen0018
                                                  ( INPUT glb_cdcooper,
                                                    INPUT 0,
                                                    INPUT 0,
                                                    INPUT tel_nrdconta,
                                                    INPUT 0,
                                                   OUTPUT TABLE tt-erro,
                                                   OUTPUT TABLE tt-crapass).

                    IF  VALID-HANDLE(h_b1wgen0018) THEN
                        DELETE PROCEDURE h_b1wgen0018.

                    IF  RETURN-VALUE <> "OK" THEN
                        DO:
                            FIND FIRST tt-erro NO-ERROR.

                            IF  AVAIL tt-erro THEN
                                DO:
                                    BELL.
                                    MESSAGE tt-erro.dscritic.
                                    NEXT.
                                END.
                        END.

                    FIND tt-crapass NO-ERROR.

                    IF  AVAIL tt-crapass THEN
                        ASSIGN tel_nmprimtl = tt-crapass.nmprimtl.

                    LEAVE.

                END. /* Fim do DO WHILE */

                IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                    DO:
                        HIDE FRAME f_conta.
                        NEXT.
                    END.

                DISPLAY tel_nmprimtl WITH FRAME f_conta.

                ASSIGN aux_tpdsaldo = 0.

            END. /* IF  NOT CAN-DO("R,S,O,C",glb_cddopcao) THEN */

        LEAVE.

    END.  /*  Fim do DO WHILE TRUE  */

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF  glb_nmdatela <> "descto"   THEN
                DO:
                    IF  VALID-HANDLE(h_b1wgen0018) THEN
                        DELETE PROCEDURE h_b1wgen0018.

                    HIDE FRAME f_descto.
                    HIDE FRAME f_conta.
                    HIDE FRAME f_favorecido.
                    HIDE FRAME f_cpg/cgc.
                    HIDE FRAME f_titular.
                    HIDE FRAME f_periodo.
                    HIDE FRAME f_opcao.
                    HIDE FRAME f_label.
                    HIDE FRAME f_pesquisa.
                    HIDE FRAME f_lanctos.
                    HIDE FRAME f_moldura.
                    HIDE FRAME f_fechamento.
                    HIDE FRAME f_contabilidade.
                    HIDE FRAME f_seltodos.
                    HIDE FRAME f_todos.
                    HIDE FRAME f_quem_descontou.
                    HIDE FRAME f_alterar.
                    RETURN.
                END.
            ELSE
                NEXT.
        END.

    IF  aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i}
            ASSIGN aux_cddopcao = glb_cddopcao.
        END.

    /* Alterar CPF/CGC e o nome do titular do cheque */
    IF  glb_cddopcao = "A" THEN
        DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                
                RUN verifica_permissao.

                IF  RETURN-VALUE <> "OK" THEN
                    NEXT Inicio.
                
                UPDATE tel_nrdconta tel_nrborder
                       tel_cdcmpchq tel_cdbanchq 
                       tel_cdagechq tel_nrctachq 
                       tel_nrcheque WITH FRAME f_alterar
                EDITING:
                    READKEY PAUSE 1.
               
                    IF  LASTKEY = KEYCODE("F7") THEN
                        DO:
                            IF  FRAME-FIELD = "nrdconta" THEN
                                DO: 
                                    RUN fontes/zoom_associados.p 
                                        ( INPUT  glb_cdcooper,
                                          OUTPUT aux_nrdconta).
        
                                    IF  aux_nrdconta > 0   THEN
                                        DO:
                                            ASSIGN tel_nrdconta = aux_nrdconta.
                                            DISPLAY tel_nrdconta
                                                WITH FRAME f_alterar.
                                            PAUSE 0.
                                        END.
                                END.
                        END.

                    APPLY LASTKEY.

                END. /* fim do EDITING */

                RUN conecta_handle.

                RUN busca_alterar_cheques_descontados IN h_b1wgen0018
                                                    ( INPUT glb_cdcooper,
                                                      INPUT glb_cdagenci,
                                                      INPUT 0,
                                                      INPUT glb_dsdepart,
                                                      INPUT tel_nrdconta,
                                                      INPUT tel_nrborder,
                                                      INPUT tel_cdcmpchq,
                                                      INPUT tel_cdbanchq,
                                                      INPUT tel_cdagechq,
                                                      INPUT tel_nrctachq,
                                                      INPUT tel_nrcheque,
                                                     OUTPUT aux_nmdcampo,
                                                     OUTPUT TABLE tt-alterar,
                                                     OUTPUT TABLE tt-erro).

                IF  RETURN-VALUE <> "OK"   THEN
                    DO:
                        FIND FIRST tt-erro NO-ERROR.

                        IF  AVAIL tt-erro   THEN
                            DO:
                                BELL.
                                MESSAGE tt-erro.dscritic.
                                NEXT.
                            END.
                    END.

                FIND tt-alterar NO-ERROR.

                IF  AVAIL tt-alterar THEN
                    ASSIGN tel_nmcheque = tt-alterar.nmcheque
                           aux_nmcheque = tt-alterar.nmcheque
                           tel_nrcpfcgc = tt-alterar.nrcpfcgc
                           aux_nrcpfcgc = tt-alterar.nrcpfcgc. 

                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    DISPLAY aux_nrcpfcgc
                            aux_nmcheque WITH FRAME f_alterar.

                    UPDATE aux_nrcpfcgc
                           aux_nmcheque
                        WITH FRAME f_alterar
                    EDITING:
                        READKEY.
                        APPLY LASTKEY.
        
                        IF  GO-PENDING THEN
                            DO:
                                RUN valida_cheques_descontados.
        
                                IF  RETURN-VALUE <> "OK" THEN
                                    DO:
                                        {sistema/generico/includes/foco_campo.i
                                            &VAR-GERAL=SIM
                                            &NOME-FRAME="f_alterar"
                                            &NOME-CAMPO=aux_nmdcampo }
                                    END.
                            END.
        
                    END. /* Fim EDITING */

                    LEAVE.  

                END.  /*   Fim do DO WHILE TRUE    */  

                IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                    LEAVE.  
                
                DO WHILE TRUE ON ENDKEY  UNDO, LEAVE:

                    ASSIGN aux_confirma = "N".
                    MESSAGE "Confirmar alteracao (S/N)?" UPDATE aux_confirma.
                    LEAVE.

                END. /*  Fim do DO WHILE TRUE  */

                IF  KEYFUNCTION(LASTKEY) = "END-ERROR" OR
                    aux_confirma <> "S" THEN
                    DO:
                        HIDE FRAME f_alterar.
                        LEAVE.
                    END.
                ELSE
                    DO:
                        RUN conecta_handle.

                        RUN alterar_cheques_descontados IN h_b1wgen0018
                                                      ( INPUT glb_cdcooper,
                                                        INPUT glb_cdagenci,
                                                        INPUT 0,
                                                        INPUT glb_dsdepart,
                                                        INPUT tel_nrdconta,
                                                        INPUT tel_nrborder,
                                                        INPUT tel_cdcmpchq,
                                                        INPUT tel_cdbanchq,
                                                        INPUT tel_cdagechq,
                                                        INPUT tel_nrctachq,
                                                        INPUT tel_nrcheque,
                                                        INPUT tel_nmcheque,
                                                        INPUT tel_nrcpfcgc,
                                                        INPUT aux_nmcheque,
                                                        INPUT aux_nrcpfcgc,
                                                        INPUT glb_cdoperad,
                                                        INPUT glb_cddopcao,
                                                        INPUT TRUE,
                                                       OUTPUT aux_nmdcampo,
                                                       OUTPUT TABLE tt-erro).
                        
                        IF  VALID-HANDLE(h_b1wgen0018) THEN
                            DELETE PROCEDURE h_b1wgen0018.

                        IF  RETURN-VALUE <> "OK" THEN
                            DO:
                                FIND FIRST tt-erro NO-ERROR.

                                IF  AVAIL tt-erro   THEN
                                    DO:
                                        BELL.
                                        MESSAGE tt-erro.dscritic.
                                        NEXT.
                                    END.
                            END.

                        UNDO, LEAVE.

                    END.

            END.  /*  Fim do DO WHILE TRUE  */

            LEAVE.

        END. /* IF  glb_cddopcao = "A" */
    ELSE
    IF  glb_cddopcao = "C" THEN /* CONSULTA */
        DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                UPDATE tel_nrdconta WITH FRAME f_favorecido
                EDITING:
                    READKEY PAUSE 1.
               
                    IF  LASTKEY = KEYCODE("F7") THEN
                        DO:
                            RUN fontes/zoom_associados.p 
                                ( INPUT  glb_cdcooper,
                                  OUTPUT aux_nrdconta).

                            IF  aux_nrdconta > 0   THEN
                                DO:
                                    ASSIGN tel_nrdconta = aux_nrdconta.
                                    DISPLAY tel_nrdconta
                                         WITH FRAME f_favorecido.
                                    PAUSE 0.
                                END.
                        END.

                    APPLY LASTKEY.

                END. /* fim do EDITING */

                IF  tel_nrdconta = 0   THEN
                    DO:
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                            UPDATE tel_nrcpfcgc WITH FRAME f_cpf/cgc.
                            LEAVE.
                        END.

                        IF  KEYFUNCTION(LAST-KEY) = "END-ERROR"  THEN
                            DO:
                                HIDE FRAME f_cpf/cgc.
                                NEXT.
                            END.
                    END.

                RUN conecta_handle.
    
                RUN busca_informacoes_associado IN h_b1wgen0018
                                              ( INPUT glb_cdcooper,
                                                INPUT 0,
                                                INPUT 0,
                                                INPUT tel_nrdconta,
                                                INPUT tel_nrcpfcgc,
                                               OUTPUT TABLE tt-erro,
                                               OUTPUT TABLE tt-crapass).

                IF  RETURN-VALUE <> "OK" THEN
                    DO:
                        FIND FIRST tt-erro NO-ERROR.
                        
                        IF  AVAIL tt-erro   THEN
                            DO:
                                BELL.
                                 MESSAGE tt-erro.dscritic.
                                NEXT.
                            END.
                    END.

                FIND tt-crapass NO-ERROR.

                IF  AVAIL tt-crapass THEN
                    ASSIGN tel_nmprimtl = tt-crapass.nmprimtl.

                LEAVE.

            END.  /*  Fim do DO WHILE TRUE  */

            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    
                DO:
                    HIDE FRAME f_favorecido.
                    NEXT.
                END.

            DISPLAY tel_nmprimtl WITH FRAME f_titular.
               
            UPDATE tel_dtlibini tel_dtlibfim WITH FRAME f_periodo.

            ASSIGN aux_tpdsaldo = 0
                   aux_flgretor = FALSE
                   aux_contador = 0.
                                    
            CLEAR FRAME f_lanctos ALL NO-PAUSE.

            RUN conecta_handle.

            VIEW FRAME f_aguarde.

            RUN consulta_cheques_descontados IN h_b1wgen0018
                                           ( INPUT  glb_cdcooper,
                                             INPUT  0,
                                             INPUT  0,
                                             INPUT  tel_nrdconta,
                                             INPUT  tel_nrcpfcgc,
                                             INPUT  glb_dtmvtoan,
                                             INPUT  tel_dtlibini,
                                             INPUT  tel_dtlibfim,
                                            OUTPUT TABLE tt-erro,
                                            OUTPUT TABLE tt-crapcdb).
            HIDE FRAME f_aguarde NO-PAUSE.

            IF  RETURN-VALUE <> "OK" THEN
                DO:
                    FIND FIRST tt-erro NO-ERROR.

                    IF  AVAIL tt-erro   THEN
                        DO:
                            BELL.
                            MESSAGE tt-erro.dscritic.
                            NEXT.
                        END.
                END.

            OPEN QUERY q_opcao_c FOR EACH tt-crapcdb NO-LOCK.

            UPDATE b_opcao_c WITH FRAME f_opcao_c.
            
            IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                NEXT.
            
        END. /* IF  glb_cddopcao = "C" */
    ELSE
    IF  glb_cddopcao = "Q" THEN /* QUEM DESCONTOU */
        DO:
            ASSIGN aux_flgretor = FALSE
                   aux_contador = 0
                   tel_vldescto = 0.
           
            CLEAR FRAME f_quem_descontou ALL NO-PAUSE.

            RUN conecta_handle.

            RUN consulta_quem_descontou IN h_b1wgen0018
                                      ( INPUT glb_cdcooper,
                                        INPUT 0,
                                        INPUT 0,
                                        INPUT tel_nrdconta,
                                        INPUT glb_dtmvtolt,
                                       OUTPUT TABLE tt-erro,
                                       OUTPUT TABLE tt-crapcdb).

            IF  RETURN-VALUE <> "OK" THEN
                DO:
                    FIND FIRST tt-erro NO-ERROR.

                    IF  AVAIL tt-erro   THEN
                        DO:
                            BELL.
                            MESSAGE tt-erro.dscritic.
                            NEXT.
                        END.
                END.

            DISPLAY tel_vldescto WITH FRAME f_opcao_q.

            OPEN QUERY q_opcao_q FOR EACH tt-crapcdb NO-LOCK.

            UPDATE b_opcao_q WITH FRAME f_opcao_q.

            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN   
                NEXT.

        END. /* IF  glb_cddopcao = "Q" */
    ELSE
    IF  glb_cddopcao = "P"   THEN  /*  PESQUISA CHEQUE  */
        DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                UPDATE tel_cdbanchq tel_cdagechq tel_nrctachq tel_nrcheque 
                    WITH FRAME f_pesquisa.

                VIEW FRAME f_aguarde.

                RUN conecta_handle.

                RUN pesquisa_cheque_descontado IN h_b1wgen0018
                                             ( INPUT glb_cdcooper,
                                               INPUT 0,
                                               INPUT 0,
                                               INPUT tel_nrdconta,
                                               INPUT tel_cdbanchq,
                                               INPUT tel_cdagechq,
                                               INPUT tel_nrctachq,
                                               INPUT tel_nrcheque,
                                              OUTPUT TABLE tt-erro,
                                              OUTPUT TABLE tt-crapcdb).

                HIDE FRAME f_aguarde NO-PAUSE.

                IF  RETURN-VALUE <> "OK" THEN
                    DO:
                        FIND FIRST tt-erro NO-ERROR.

                        IF  AVAIL tt-erro   THEN
                            DO:
                                BELL.
                                MESSAGE tt-erro.dscritic.
                                NEXT.
                            END.
                    END.

                FOR EACH tt-crapcdb BREAK BY tt-crapcdb.nrdconta
                                          BY tt-crapcdb.cdbanchq 
                                          BY tt-crapcdb.cdagechq
                                          BY tt-crapcdb.nrctachq
                                          BY tt-crapcdb.nrcheque:

                    DISP tt-crapcdb.dspesqui   tt-crapcdb.dssitchq
                         tt-crapcdb.cdcmpchq   tt-crapcdb.cdbanchq
                         tt-crapcdb.cdagechq   tt-crapcdb.nrddigc1
                         tt-crapcdb.nrctachq   tt-crapcdb.nrddigc2
                         tt-crapcdb.nrcheque   tt-crapcdb.nrddigc3
                         tt-crapcdb.vlcheque   tt-crapcdb.dsdocmc7
                         tt-crapcdb.nrborder   tt-crapcdb.nrctrlim
                         tt-crapcdb.dtlibera   tt-crapcdb.dsobserv 
                         tt-crapcdb.nmopedev
                         WITH FRAME f_pesquisa.

                    IF  NOT LAST-OF(tt-crapcdb.nrcheque)   THEN
                        DO:
                            ASSIGN aux_confirma = "S".

                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                                MESSAGE COLOR NORMAL
                                       "Ha mais DOCUMENTOS a serem mostrados!"
                                       "Continuar (S/N)?" UPDATE aux_confirma.
                                          
                                LEAVE.

                            END.  /*  Fim do DO WHILE TRUE  */

                            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                                aux_confirma <> "S"                  THEN
                                LEAVE.
                        END.

                END.  /*  FOR EACH tt-crapcdb...  */
            END.  /*  Fim do DO WHILE TRUE  */
        END. /* IF   glb_cddopcao = "P" */
    ELSE
    IF  glb_cddopcao = "F" THEN /*  FECHAMENTO PARA A CONTA  */
        DO:
            ASSIGN tel_dtlibera = glb_dtmvtopr.
            
            CLEAR FRAME f_fechamento NO-PAUSE.
            
            DO WHILE TRUE:

                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    UPDATE tel_dtlibera 
                        HELP "Informe data especifica ou ? para saber o total"
                        WITH FRAME f_fechamento.
                    LEAVE.

                END.  /*  Fim do DO WHILE TRUE  */

                IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                    LEAVE.

                VIEW FRAME f_aguarde.
                
                RUN conecta_handle.

                RUN busca_fechamento_descto IN h_b1wgen0018
                                          ( INPUT glb_cdcooper,
                                            INPUT 0,
                                            INPUT 0,
                                            INPUT tel_dtlibera,
                                            INPUT tel_nrdconta,
                                            INPUT glb_dtmvtolt,
                                           OUTPUT TABLE tt-erro,
                                           OUTPUT TABLE tt-fechamento).

                HIDE FRAME f_aguarde NO-PAUSE.

                IF  RETURN-VALUE <> "OK" THEN
                    DO:
                        FIND FIRST tt-erro NO-ERROR.

                        IF  AVAIL tt-erro   THEN
                            DO:
                                BELL.
                                MESSAGE tt-erro.dscritic.
                                NEXT.
                            END.
                    END.

                FIND tt-fechamento NO-ERROR.


                IF  NOT AVAIL tt-fechamento THEN
                    NEXT.

                DISPLAY tel_dtlibera           tt-fechamento.dschqcop
                        tt-fechamento.qtcheque tt-fechamento.vlcheque
                        tt-fechamento.qtchqdev tt-fechamento.vlchqdev
                        tt-fechamento.qtchqcop tt-fechamento.vlchqcop
                        tt-fechamento.qtchqban tt-fechamento.vlchqban
                        tt-fechamento.qtcredit tt-fechamento.vlcredit
                        tt-fechamento.qtdmenor tt-fechamento.vlrmenor
                        tt-fechamento.qtdmaior tt-fechamento.vlrmaior
                        WITH FRAME f_fechamento.

            END.  /*  Fim do DO WHILE TRUE  */
        END. /* IF   glb_cddopcao = "F" */
    ELSE 
    IF  glb_cddopcao = "R" THEN /*  RELATORIO  */
        DO:
            ASSIGN tel_dtmvtolt = glb_dtmvtolt
                   tel_cdagenci = 0.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                UPDATE tel_dtmvtolt tel_cdagenci WITH FRAME f_movto.

                RUN fontes/descto_r2.p (INPUT tel_dtmvtolt,
                                        INPUT tel_cdagenci).

            END.  /*  Fim do DO WHILE TRUE  */
         
            HIDE FRAME f_movto.
        END. /* IF   glb_cddopcao = "R" */
    ELSE
    IF  glb_cddopcao = "S" THEN /*  SALDO EM DESCTO  */
        DO: 
            ASSIGN tel_dtlibera = glb_dtmvtolt.

            CLEAR FRAME f_contabilidade NO-PAUSE.

            DO WHILE TRUE:

                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    UPDATE tel_dtlibera WITH FRAME f_contabilidade.
                    LEAVE.
                END.  /*  Fim do DO WHILE TRUE  */

                IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                    LEAVE.

                IF  tel_dtlibera = ?   THEN
                    ASSIGN tel_dtlibera = glb_dtmvtolt.

                VIEW FRAME f_aguarde.

                RUN conecta_handle.

                RUN busca_saldo_descto IN h_b1wgen0018
                                     ( INPUT glb_cdcooper,
                                       INPUT 0,
                                       INPUT 0,
                                       /*INPUT glb_dtmvtolt,*/
                                       INPUT tel_dtlibera,
                                      OUTPUT TABLE tt-erro,
                                      OUTPUT TABLE tt-saldo).

                HIDE FRAME f_aguarde NO-PAUSE.

                IF  RETURN-VALUE = "NOK"   THEN
                    DO:
                        
                        FIND FIRST tt-erro NO-ERROR.

                        IF  AVAIL tt-erro THEN
                            DO:
                                BELL.
                                MESSAGE tt-erro.dscritic.
                                NEXT.
                            END.
                    END.

                FIND tt-saldo NO-ERROR.

                IF  NOT AVAIL tt-saldo   THEN
                    NEXT.

                DISP tel_dtlibera
                     tt-saldo.qtsldant   tt-saldo.vlsldant
                     tt-saldo.qtcheque   tt-saldo.vlcheque
                     tt-saldo.qtlibera   tt-saldo.vllibera
                     tt-saldo.qtchqdev   tt-saldo.vlchqdev
                     tt-saldo.qtcredit   tt-saldo.vlcredit
                     tt-saldo.dschqcop   
                     tt-saldo.qtchqcop   tt-saldo.vlchqcop
                     tt-saldo.qtchqban   tt-saldo.vlchqban
                     WITH FRAME f_contabilidade.

            END.  /*  Fim do DO WHILE TRUE  */

            HIDE  FRAME f_contabilidade NO-PAUSE.
            CLEAR FRAME f_contabilidade NO-PAUSE.
            
        END.  /* IF  glb_cddopcao = "S" */
    ELSE
    IF  glb_cddopcao = "T" THEN /*  PESQUISA TODOS OS LANCAMENTOS  */
        DO:
            VIEW FRAME f_seltodos.

            DO WHILE TRUE:

                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    UPDATE tel_cdbanchq tel_nrcheque
                           tel_vlcheque WITH FRAME f_seltodos.
                    LEAVE.
                END.  /*  Fim do DO WHILE TRUE  */

                IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                    LEAVE.

                CLEAR FRAME f_todos ALL.

                VIEW FRAME f_aguarde.

                RUN conecta_handle.

                RUN busca_todos_lancamentos_descto IN h_b1wgen0018
                                                 ( INPUT glb_cdcooper,
                                                   INPUT 0,
                                                   INPUT 0,
                                                   INPUT tel_nrdconta,
                                                   INPUT tel_cdbanchq,
                                                   INPUT tel_nrcheque,
                                                   INPUT tel_vlcheque,
                                                   INPUT glb_dtmvtoan,
                                                  OUTPUT TABLE tt-erro,
                                                  OUTPUT TABLE tt-lancamentos).
                
                HIDE FRAME f_aguarde NO-PAUSE.

                IF  RETURN-VALUE <> "OK" THEN
                    DO:
                        FIND FIRST tt-erro NO-ERROR.

                        IF  AVAIL tt-erro THEN
                            DO:
                                BELL.
                                MESSAGE tt-erro.dscritic.
                                NEXT.
                            END.
                    END.

                OPEN QUERY q_opcao_t FOR EACH tt-lancamentos NO-LOCK.

                UPDATE b_opcao_t WITH FRAME f_opcao_t.

                IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                    NEXT.

            END. /* do DO WIHILE TRUE */

        END.  /* IF   glb_cddopcao = "T" */
    ELSE
    IF  glb_cddopcao = "M" THEN  /*  IMPRIME CHEQUES DESCONTADOS  */
        DO:
            BELL.

            IF  tel_nrdconta > 0   THEN
                DO:
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                        aux_confirma = "N".

                        MESSAGE COLOR NORMAL 
                                "Imprimir os cheques RESGATADOS (S/N)?"
                                UPDATE aux_confirma.

                        LEAVE.
                    END.  /*  Fim do DO WHILE TRUE  */

                    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                        DO:
                            glb_cdcritic = 79.
                            RUN fontes/critic.p.
                            BELL.
                            MESSAGE glb_dscritic.
                            glb_cdcritic = 0.
                            NEXT.
                        END.

                    RUN fontes/descto_m.p (INPUT tel_nrdconta, 
                                           INPUT aux_confirma = "S").
                END.
            ELSE
                DO:
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        
                        PAUSE 0.
                        
                        DISPLAY tel_dsdopcao WITH FRAME f_lst_contas.
                          
                        CHOOSE FIELD tel_dsdopcao HELP "Escolha uma opcao."
                                     WITH FRAME f_lst_contas.

                        HIDE MESSAGE NO-PAUSE.

                        ASSIGN aux_tpdconta = FRAME-INDEX.

                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                            
                            PAUSE 0.
                        
                            DISPLAY tel_dsdvalor WITH FRAME f_lst_valores.
                          
                            CHOOSE FIELD tel_dsdvalor HELP "Escolha uma opcao."
                                         WITH FRAME f_lst_valores.

                            HIDE MESSAGE NO-PAUSE.

                            ASSIGN aux_tpdvalor = FRAME-INDEX.

                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                                PAUSE 0.

                                DISPLAY tel_dschqcop WITH FRAME f_lst_bancos.

                                CHOOSE FIELD tel_dschqcop 
                                            HELP "Escolha uma opcao."
                                            WITH FRAME f_lst_bancos.
                                
                                HIDE MESSAGE NO-PAUSE.

                                ASSIGN aux_tpchqcop = FRAME-INDEX.
                                
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                                    UPDATE tel_dtiniper tel_dtfimper 
                                        WITH FRAME f_lst_periodo.

                                    IF  tel_dtiniper = ?   THEN
                                        DO:
                                            MESSAGE "013 - Data errada.".
                                            NEXT-PROMPT tel_dtiniper
                                                WITH FRAME f_lst_periodo.
                                            NEXT.
                                        END.

                                    IF  tel_dtfimper = ?   THEN
                                        DO:
                                            MESSAGE "013 - Data errada.".
                                            NEXT-PROMPT tel_dtfimper
                                                WITH FRAME f_lst_periodo.
                                            NEXT.
                                        END.

                                    IF  tel_dtfimper < tel_dtiniper   THEN
                                        DO:
                                            MESSAGE "013 - Data errada.".
                                            NEXT-PROMPT tel_dtiniper
                                                WITH FRAME f_lst_periodo.
                                            NEXT.
                                        END. 
                                    
                                    LEAVE.

                                END.  /*  Fim do DO WHILE TRUE  */

                                IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                                    DO:
                                        HIDE FRAME f_lst_periodo.
                                        NEXT.
                                    END.
                                LEAVE.
                            
                            END.  /*  Fim do DO WHILE TRUE  */
                           
                            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                                DO:
                                    HIDE FRAME f_lst_bancos.
                                    NEXT.
                                END.

                            LEAVE.

                        END.  /*  Fim do DO WHILE TRUE  */
                        
                        IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                            DO:
                                HIDE FRAME f_lst_valores.
                                NEXT.
                            END.
                         
                        RUN fontes/descto_r1.p 
                                   (INPUT tel_dtiniper, 
                                    INPUT tel_dtfimper,
                                    INPUT aux_tpdconta, 
                                    INPUT aux_tpdvalor,
                                    INPUT aux_tpchqcop).
                        
                        LEAVE.

                    END.  /*  Fim do DO WHILE TRUE  */

                    HIDE FRAME f_lst_periodo NO-PAUSE.
                    HIDE FRAME f_lst_bancos  NO-PAUSE.
                    HIDE FRAME f_lst_valores NO-PAUSE.
                    HIDE FRAME f_lst_contas  NO-PAUSE.
                END. /* ELSE */
        END. /* IF   glb_cddopcao = "M" */
    ELSE 
    IF  glb_cddopcao = "O"   THEN  /* Conferencia */
        DO:
            ASSIGN tel_dtiniper = glb_dtmvtolt
                   tel_dtfimper = glb_dtmvtolt
                   tel_nrdconta = 0
                   tel_cdagenci = 0.
        
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                VIEW  FRAME f_conferencia.
                CLEAR FRAME f_conferencia NO-PAUSE.

                UPDATE tel_dtiniper WITH FRAME f_conferencia.

                ASSIGN tel_dtfimper = tel_dtiniper.

                DISPLAY tel_dtfimper WITH FRAME f_conferencia.

                UPDATE tel_dtfimper tel_nrdconta tel_cdagenci 
                    WITH FRAME f_conferencia
                EDITING:
                    READKEY PAUSE 1.
               
                    IF  LASTKEY = KEYCODE("F7") THEN
                        DO:
                            IF  FRAME-FIELD = "nrdconta" THEN
                                DO: 
                                    RUN fontes/zoom_associados.p 
                                        ( INPUT  glb_cdcooper,
                                          OUTPUT aux_nrdconta).
        
                                    IF  aux_nrdconta > 0   THEN
                                        DO:
                                            ASSIGN tel_nrdconta = aux_nrdconta.
                                            DISPLAY tel_nrdconta
                                                 WITH FRAME f_conferencia.
                                            PAUSE 0.
                                        END.
                                END.
                        END.

                    APPLY LASTKEY.

                END. /* fim do EDITING */

                RUN fontes/descto_o.p (INPUT tel_dtiniper,
                                       INPUT tel_dtfimper,
                                       INPUT tel_nrdconta,
                                       INPUT tel_cdagenci).

            END.  /*  Fim do DO WHILE TRUE  */

            HIDE FRAME f_conferencia.

        END. /* IF   glb_cddopcao = "O" */
        
END.  /*  Fim do DO WHILE TRUE  */

IF  VALID-HANDLE(h_b1wgen0018) THEN 
    DELETE PROCEDURE h_b1wgen0018.

PROCEDURE conecta_handle:

    IF  NOT VALID-HANDLE(h_b1wgen0018) THEN
        RUN sistema/generico/procedures/b1wgen0018.p 
            PERSISTENT SET h_b1wgen0018.

END PROCEDURE.

PROCEDURE valida_cheques_descontados:

    EMPTY TEMP-TABLE tt-erro.

    DO WITH FRAME f_alterar:
        ASSIGN aux_nrcpfcgc
               aux_nmcheque.

    END.

    RUN conecta_handle.
    
    RUN valida_cheques_descontados IN h_b1wgen0018
                                 ( INPUT glb_cdcooper,
                                   INPUT 0,
                                   INPUT 0,
                                   INPUT aux_nrcpfcgc,
                                   INPUT aux_nmcheque,
                                  OUTPUT aux_nmdcampo,
                                  OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.
                   
            RETURN "NOK".  
        END.
    
    RETURN "OK".

END PROCEDURE. /* valida_cheques_descontados */

PROCEDURE verifica_permissao:

    EMPTY TEMP-TABLE tt-erro.

    DO WITH FRAME f_alterar:
        ASSIGN aux_nrcpfcgc
               aux_nmcheque.

    END.

    RUN conecta_handle.
    
    RUN verifica_permissao IN h_b1wgen0018
                         ( INPUT glb_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT glb_dsdepart,
                           INPUT glb_cddopcao,
                          OUTPUT aux_nmdcampo,
                          OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.
                   
            RETURN "NOK".  
        END.
    
    RETURN "OK".

END PROCEDURE. /* verifica_permissao */
/* ......................................................................... */
