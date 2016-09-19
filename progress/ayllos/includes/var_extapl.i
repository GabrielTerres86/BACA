/* ..........................................................................

   Programa: Includes/var_extapl.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Abril/2004                      Ultima atualizacao: 04/10/2007

   Dados referentes ao programa:

   Frequencia: Diario (On-line)
   Objetivo  : Criar as variaveis compartilhadas para o on_line.

   Alteracoes: 22/07/2005 - Alterada formato do numero da aplicacao (Margarete)
    
               06/02/2006 - Incluida a opcao NO-UNDO na TEMP-TABLE workapl -
                            SQLWorks - Fernando.
               
               21/05/2007 - Incluida variaveis de controle para aplicacoes RDC
                            PRE e POS (Elton).
                            
               04/10/2007 - Alterado frames e adicionada variavel para mostrar
                            data aplicacao (Guilherme).
                            
............................................................................. */

DEF {1} SHARED VAR tel_nrdconta LIKE craprda.nrdconta                   NO-UNDO.

DEF {1} SHARED VAR tel_nrsequen AS INT  FORMAT "zz9"                    NO-UNDO.
DEF {1} SHARED VAR tel_tpaplica AS INT  FORMAT "z9"                     NO-UNDO.
DEF {1} SHARED VAR tel_descapli AS CHAR FORMAT "x(06)"                  NO-UNDO.
DEF {1} SHARED VAR tel_nraplica LIKE craprpp.nrctrrpp                   NO-UNDO.
DEF {1} SHARED VAR tel_tpemiext LIKE craprda.tpemiext                   NO-UNDO.
DEF {1} SHARED VAR tel_dsemiext AS CHAR FORMAT "x(12)"                  NO-UNDO.
DEF {1} SHARED VAR tel_dtmvtolt LIKE craprda.dtmvtolt                   NO-UNDO.

DEF {1} SHARED VAR tel_altlacto AS CHAR FORMAT "x(07)" INIT "Alterar"   NO-UNDO.
DEF {1} SHARED VAR tel_conlacto AS CHAR FORMAT "x(09)" INIT "Consultar" NO-UNDO.
DEF {1} SHARED VAR tel_alttodas AS CHAR FORMAT "x(05)" INIT "Todas"     NO-UNDO.
                                   
DEF            VAR aux_cddopcao AS CHAR                                 NO-UNDO.
DEF            VAR aux_flgretor AS LOG                                  NO-UNDO.
DEF            VAR aux_confirma AS LOG  FORMAT "Sim/Nao"                NO-UNDO.
DEF            VAR aux_mensagem AS CHAR FORMAT "x(50)"                  NO-UNDO.
DEF            VAR aux_flgfecha AS LOG  FORMAT "S/N"                    NO-UNDO.
DEF            VAR aux_cancllan AS CHAR FORMAT "!"                      NO-UNDO.
DEF            VAR aux_tpemiext AS INTE FORMAT "9"                      NO-UNDO.
DEF            VAR aux_msgretor AS CHAR                                 NO-UNDO.
DEF            VAR aux_tpaplica AS INTE                                 NO-UNDO.
DEF            VAR aux_nraplica AS INTE                                 NO-UNDO.

DEF            VAR flg_tpemiext AS LOG                                  NO-UNDO.
DEF            VAR aux_tpextrat AS INT                                  NO-UNDO.
DEF            VAR aux_dsextrat AS CHAR                                 NO-UNDO.

DEF TEMP-TABLE workapl                                                  NO-UNDO
    FIELD nrsequen AS INTE
    FIELD tpaplica LIKE craprda.tpaplica
    FIELD descapli AS CHAR
    FIELD nraplica LIKE craprpp.nrctrrpp
    FIELD dtmvtolt LIKE craprda.dtmvtolt
    FIELD tpemiext LIKE craprda.tpemiext
    FIELD dsemiext AS CHAR FORMAT "x(12)"
    INDEX ch-workapl AS UNIQUE PRIMARY
          nrsequen
          tpaplica
          nraplica.

DEF BUTTON btn-alterar  LABEL "Alterar".
DEF BUTTON btn-sair1    LABEL "Sair".
DEF BUTTON btn-sair2    LABEL "Sair".    

FORM SPACE(1) WITH ROW 4 COLUMN 1 OVERLAY 16 DOWN WIDTH 80
                      TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT  2 LABEL "Opcao" AUTO-RETURN
                        HELP "Informe a opcao desejada (A ou C)"
                        VALIDATE (glb_cddopcao = "A" OR 
                                  glb_cddopcao = "C","014 - Opcao errada.")

     tel_nrdconta AT 17 LABEL "Conta/dv" AUTO-RETURN
                        HELP "Informe o numero da conta ou <F7> para pesquisar"
                                  
     WITH ROW 6 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_opcao.

FORM WITH ROW 7 OVERLAY 13 DOWN WIDTH 78 CENTERED
                TITLE " APLICACAOES DO ASSOCIADO " FRAME f_moldura_extra.

FORM WITH ROW 7 OVERLAY 13 DOWN WIDTH 78 CENTERED
                TITLE " APLICACOES DO ASSOCIADO " FRAME f_moldura_especial.
FORM "         Seq Aplicacao    Numero Data Aplic Tipo Impressao do Extrato    "
     SKIP(11)      
     SPACE(19)
     tel_altlacto AT 22 
     SPACE(3)
     tel_conlacto  
     SPACE(3)
     tel_alttodas     
     SPACE(15)
     WITH ROW 7 OVERLAY NO-LABELS CENTERED FRAME f_aplicacao.

FORM tel_nrsequen AT 3  LABEL "Sequencia"
                        HELP "Entre com a sequencia do lancamento." 
     SKIP(1)
     tel_descapli AT 3  LABEL "Aplicacao"
                        HELP "Entre com o tipo de aplicacao"
                        VALIDATE(tel_descapli <> "",
                                 "375 - O campo deve ser informado")
     SKIP(1)
     tel_nraplica AT 3  LABEL "Numero"
                        HELP "Entre com o numero da aplicacao."
     SKIP(1)
     tel_dtmvtolt AT 3 LABEL "Data Aplicacao"
     SKIP(1)
     tel_tpemiext AT 3  LABEL "Impressao Extrato"
         HELP "Modo impressao do extrato (1-Individual,2-Todos,3-Nao imp)."
         VALIDATE(CAN-DO("1,2,3",tel_tpemiext),
         "Impressao Extrato deve ser 1-Individual, 2-Todos ou 3-Nao imp.")
     tel_dsemiext NO-LABEL
     WITH ROW 7 OVERLAY NO-LABELS SIDE-LABELS CENTERED FRAME f_manutencao.

/* variaveis para mostrar os lancamentos a alterar */          
DEF QUERY  bworkapla-q FOR tt-extapl.
DEF BROWSE bworkapla-b QUERY bworkapla-q
      DISP tt-extapl.nrsequen                     COLUMN-LABEL "Seq"
           tt-extapl.descapli  FORMAT "x(06)"     COLUMN-LABEL "Aplicacao"
           tt-extapl.nraplica                     COLUMN-LABEL "Numero"
           tt-extapl.dtmvtolt                     COLUMN-LABEL "Data Aplic"
           tt-extapl.tpemiext                     COLUMN-LABEL "Tipo Impressao"
           tt-extapl.dsemiext                     COLUMN-LABEL "do Extrato"
           WITH 11 DOWN OVERLAY.    

DEF FRAME f_alterar
          bworkapla-b HELP "<TAB> para navegar e <ENTER> para selecao" SKIP 
          SPACE(1)
          btn-alterar HELP "<TAB> para navegar e <ENTER> para selecao" 
          SPACE(1)
          btn-sair1 HELP "<TAB> para navegar e <ENTER> para selecao"
          WITH NO-BOX CENTERED OVERLAY ROW 7.

/***************************************************/

/* tela para mostrar os lancamentos a consultar */
DEF QUERY  bworkaplc-q FOR tt-extapl.
DEF BROWSE bworkaplc-b QUERY bworkaplc-q
      DISP tt-extapl.nrsequen                     COLUMN-LABEL "Seq"
           tt-extapl.descapli  FORMAT "x(06)"     COLUMN-LABEL "Aplicacao"
           tt-extapl.nraplica                     COLUMN-LABEL "Numero"
           tt-extapl.dtmvtolt                     COLUMN-LABEL "Data Aplic"
           tt-extapl.tpemiext                     COLUMN-LABEL "Tipo Impressao"
           tt-extapl.dsemiext                     COLUMN-LABEL "do Extrato"
           WITH 11 DOWN OVERLAY.    

DEF FRAME f_consultar
          bworkaplc-b HELP "Use <TAB> para navegar" SKIP 
          WITH NO-BOX CENTERED OVERLAY ROW 7.
/***********************************************/

/* variaveis para mostrar a consulta da tela principal */          
 
DEF QUERY  blistafin-q FOR tt-extapl.
DEF BROWSE blistafin-b QUERY blistafin-q
     DISP tt-extapl.nrsequen                      COLUMN-LABEL "Seq"
          tt-extapl.descapli   FORMAT "x(06)"     COLUMN-LABEL "Aplicacao"
          tt-extapl.nraplica                      COLUMN-LABEL "Numero"
          tt-extapl.dtmvtolt                      COLUMN-LABEL "Data Aplic"
          tt-extapl.tpemiext                      COLUMN-LABEL "Tipo Impressao"
          tt-extapl.dsemiext                      COLUMN-LABEL "do Extrato"
          WITH 11 DOWN OVERLAY.    

DEF FRAME f_listafinc
          blistafin-b HELP "Use as SETAS para navegar e <F4> para sair" SKIP 
          WITH NO-BOX CENTERED OVERLAY ROW 7.
/**********************************************/

/* ......................................................................... */
