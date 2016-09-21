/* ..........................................................................

   Programa: Includes/var_anota.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete/Edson  
   Data    : Dezembro/2001                       Ultima atualizacao: 08/03/2006

   Dados referentes ao programa:

   Frequencia: Diario (On-line)
   Objetivo  : Criar as variaveis compartilhadas para o on_line.

   Alteracoes: 08/03/2006 - Incluido o nome da tabela antes do uso dos campos
                            'dtmvtolt' e 'flgprior' (Evandro).
                            
               22/02/2011 - Adaptação para uso de BO (Jose Luis, DB1)           
                            
............................................................................. */

{ sistema/generico/includes/b1wgen0085tt.i &TT-LOG=SIM }

DEF {1} SHARED VAR aux_nrseqdig AS INT                                NO-UNDO.
DEF {1} SHARED VAR aux_tipconsu AS LOGI FORMAT "Visualizar/Imprimir"  NO-UNDO.
DEF {1} SHARED VAR aux_nmarqimp AS CHAR                               NO-UNDO.

DEF {1} SHARED VAR tel_nrdconta AS INT  FORMAT "zzzz,zzz,9"           NO-UNDO.

DEF {1} SHARED VAR tel_nmprimtl AS CHAR FORMAT "x(40)"                NO-UNDO.

DEF {1} SHARED VAR tel_flgprior AS LOGI                               NO-UNDO.

DEF {1} SHARED VAR tel_visualiz AS CHAR FORMAT "x(10)" 
                                        INIT "Visualizar"             NO-UNDO.
DEF {1} SHARED VAR tel_imprimir AS CHAR FORMAT "x(08)" 
                                        INIT "Imprimir"               NO-UNDO.
                                                                       
DEF {1} SHARED VAR tel_dsobserv AS CHAR  VIEW-AS EDITOR 
                                         INNER-CHARS 76 INNER-LINES 8
                                         LARGE PFCOLOR 0              NO-UNDO.

DEF {1} SHARED VAR aux_recidobs AS RECID                              NO-UNDO.

DEF            VAR aux_cddopcao AS CHAR                               NO-UNDO.
DEF            VAR aux_flgretor AS LOG                                NO-UNDO.

DEF            VAR aux_confirma AS CHAR FORMAT "!"                    NO-UNDO.

DEF            VAR aux_flgfirst AS LOGI                               NO-UNDO.

DEF BUFFER crabobs FOR crapobs.

FORM SPACE(1) WITH ROW 4 COLUMN 1 OVERLAY 16 DOWN WIDTH 80
                      TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT  2 LABEL "Opcao" AUTO-RETURN
                        HELP "Informe a opcao desejada (A, C, E ou I)"
                        VALIDATE (glb_cddopcao = "A" OR 
                                  glb_cddopcao = "C" OR
                                  glb_cddopcao = "E" OR
                                  glb_cddopcao = "I","014 - Opcao errada.")

     tel_nrdconta AT 13 LABEL "Conta/dv"
     tel_nmprimtl AT 35 NO-LABEL 
     WITH ROW 6 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_opcao.

/* variaveis para mostrar a consulta */          

DEF QUERY  anota-q FOR tt-crapobs.

DEF BROWSE anota-b QUERY anota-q
      DISP ENTRY(1,tt-crapobs.nmoperad) COLUMN-LABEL "Operador" FORMAT "x(15)"
           tt-crapobs.flgprior          COLUMN-LABEL "Pri"
           tt-crapobs.dtmvtolt          COLUMN-LABEL "Data"
           STRING(hrtransa,"HH:MM:SS")  COLUMN-LABEL "Hora"
           SUBSTRING(dsobserv,1,30)     COLUMN-LABEL "Texto" FORMAT "x(30)"
           WITH 9 DOWN OVERLAY.

DEF BUTTON btn-visualiz LABEL "Visualizar".
DEF BUTTON btn-imprimir LABEL "Imprimir Anotacao".
DEF BUTTON btn-sair     LABEL "Sair".
DEF BUTTON btn-salvar   LABEL "Salvar".
DEF BUTTON btn-incluir  LABEL "Incluir".
    
DEF FRAME f_anotacoes
          anota-b HELP "Use <TAB> para navegar" SKIP 
          SPACE(10)
          btn-visualiz HELP "Use <TAB> para navegar" 
          SPACE(3)
          btn-imprimir HELP "Use <TAB> para navegar"
          SPACE(3)
          btn-incluir  HELP "Use <TAB> para navegar"
          SPACE(3)
          btn-sair HELP "Use <TAB> para navegar"
          WITH NO-BOX CENTERED OVERLAY ROW 7.

DEFINE FRAME f_observacao
       tel_flgprior  LABEL "Prioritaria? (S/N)" FORMAT "SIM/NAO"
                     HELP "Entre com S ou N para a prioridade."
       SKIP(1)
       tel_dsobserv  HELP "Use <TAB> para sair" NO-LABEL
       SKIP
       btn-salvar HELP "Tecle <Enter> para confirmar a anotacao." AT 37
       WITH ROW 8 CENTERED SIDE-LABELS OVERLAY TITLE  " Texto ".

/* variaveis para a opcao visualizar */

DEF BUTTON btn-ok     LABEL "Sair".

DEF VAR edi_anota   AS CHAR VIEW-AS EDITOR SIZE 76 BY 15 PFCOLOR 0.     

DEF FRAME fra_anota 
    edi_anota  HELP "Pressione <F4> ou <END> para finalizar" 
    WITH SIZE 76 BY 15 ROW 6 COLUMN 3 USE-TEXT NO-BOX NO-LABELS OVERLAY.

/* .......................................................................... */
