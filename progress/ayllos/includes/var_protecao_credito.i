/* .....................................................,,....................

   Programa: includes/var_protecao_credito.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Jonata(RKAM)
   Data    : Agosto/2014.                  Ultima atualizacao: 

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Definicao das variaveis da rotina de protecao de credito da 
               tela Contas.
               Projeto Automatização de Consultas em Propostas
               de Crédito (Jonata-RKAM).

   Alteracoes: 
   
........................................................................... */ 

DEF STREAM str_1.

DEF VAR tel_dtcnsspc AS DATE                                            NO-UNDO.
DEF VAR tel_dtdsdspc AS DATE                                            NO-UNDO.
DEF VAR tel_dsinacop AS CHAR                                            NO-UNDO.
DEF VAR tel_dsinaout AS CHAR                                            NO-UNDO.
DEF VAR tel_btndetal AS CHAR INIT "Detalhar"                            NO-UNDO.
DEF VAR tel_btnalter AS CHAR INIT "Alterar"                             NO-UNDO.
DEF VAR tel_dtdscore LIKE crapass.dtdscore                              NO-UNDO.
DEF VAR tel_dsdscore LIKE crapass.dsdscore                              NO-UNDO.


/* Variaveis auxiliares */
DEF VAR aux_dscritic AS CHAR                                            NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                            NO-UNDO.
DEF VAR aux_nrsequen AS INTE                                            NO-UNDO.
DEF VAR aux_nrconbir AS INTE                                            NO-UNDO.
DEF VAR aux_nrseqdet AS INTE                                            NO-UNDO.
DEF VAR aux_cdbircon AS INTE                                            NO-UNDO.
DEF VAR aux_dsbircon AS CHAR                                            NO-UNDO.
DEF VAR aux_cdmodbir AS INTE                                            NO-UNDO.
DEF VAR aux_dssituac AS CHAR                                            NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                            NO-UNDO.
DEF VAR aux_inadimpl AS INTE                                            NO-UNDO.
DEF VAR aux_flgcreca AS LOGI                                            NO-UNDO.
DEF VAR aux_dsmodbir AS CHAR                                            NO-UNDO.

/* Variaveis para impressao */
DEF VAR tel_dsimprim AS CHAR  FORMAT "x(8)" INIT "Imprimir"      NO-UNDO.
DEF VAR tel_dscancel AS CHAR  FORMAT "x(8)" INIT "Cancelar"      NO-UNDO.
DEF VAR aux_nmendter AS CHAR                                     NO-UNDO.
DEF VAR aux_flgescra AS LOGI                                     NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                     NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                     NO-UNDO.
DEF VAR par_flgrodar AS LOGI                                     NO-UNDO.
DEF VAR par_flgfirst AS LOGI                                     NO-UNDO.
DEF VAR par_flgcance AS LOGI                                     NO-UNDO.

DEF VAR h-b1wgen0074 AS HANDLE                                          NO-UNDO.
DEF VAR h-b1wgen0191 AS HANDLE                                          NO-UNDO.
 

FORM SKIP(9) 
     WITH ROW 10 OVERLAY SIDE-LABELS TITLE " ORGAOS DE PROTECAO AO CREDITO "        
          CENTERED WIDTH 78 FRAME f_moldura.
     
FORM tel_dtcnsspc AT 01 LABEL "Consulta Serasa(outras inst.)" FORMAT "99/99/9999"
                  HELP "Informe a data da consulta no SPC" 

     
    tel_dtdsdspc  AT 45 LABEL "SPC p/COOP"                    FORMAT "99/99/9999"
                  HELP "Informe a data da inclusao no SPC pela cooperativa"    
     SKIP(1)                   
     tel_dsinacop AT 13 LABEL "Esta no SPC(coop)"             FORMAT "!(1)"
                  HELP "Informe (S)SIM ou (N)NAO"
    
     tel_dsinaout AT 35 LABEL "Esta no Serasa(outras inst.)"  FORMAT "x(12)"
                  HELP "Informe (S)SIM ou (N)NAO"     
     SKIP(1)
     tel_dtdscore AT 07 LABEL "Consulta Boa Vista"     FORMAT "99/99/9999"
     tel_dsdscore AT 40 LABEL "Score"     FORMAT "x(30)"
     
     WITH NO-BOX ROW 12 OVERLAY SIDE-LABELS 
          CENTERED WIDTH 76 FRAME f_protecao_serasa.

FORM tel_dtcnsspc AT 07 LABEL "Consulta SPC"                  FORMAT "99/99/9999"
                  HELP "Informe a data da consulta no SPC" 

     tel_dtdsdspc AT 33 LABEL "SPC p/COOP"                    FORMAT "99/99/9999"
                  HELP "Informe a data da inclusao no SPC pela cooperativa"    
     SKIP(1)                   
     tel_dsinacop AT 07 LABEL "Esta no SPC(coop)"             FORMAT "!(1)"
                  HELP "Informe (S)SIM ou (N)NAO"
    
     tel_dsinaout AT 33 LABEL "Esta no SPC(outras inst.)"     FORMAT "x(12)"
                  HELP "Informe (S)SIM ou (N)NAO"
     SKIP(1)
     tel_dtdscore AT 07 LABEL "Consulta Boa Vista"     FORMAT "99/99/9999"
     tel_dsdscore AT 40 LABEL "Score"     FORMAT "x(30)"
     
     WITH NO-BOX ROW 12 OVERLAY SIDE-LABELS 
          CENTERED WIDTH 76 FRAME f_protecao_spc.

FORM tel_btnalter AT 27 NO-LABEL                              FORMAT "x(7)"
                  HELP "Pressione <ENTER> para alterar ou <F4> para sair"
     tel_btndetal AT 38 NO-LABEL                              FORMAT "x(8)"
                  HELP "Pressione <ENTER> para os detalhes ou <F4> para sair"
     WITH NO-BOX ROW 19 OVERLAY SIDE-LABELS
          CENTERED WIDTH 76 FRAME f_botoes.

/* ....................................................................... */  
