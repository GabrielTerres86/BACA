/* .............................................................................

   Programa: Includes/var_bordero_m.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Abril/2003.                         Ultima atualizacao: 06/10/2008

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Criacao das variaveis para impressao da PROPOSTA 
               DE BORDERO DE DESCONTO DE CHEQUES E TITULOS.

   Alteracoes: 06/10/2008 - Incluido tratamento para Desconto de Titulos
                            (Diego).

............................................................................. */

DEF {1} SHARED VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir"
                                                                     NO-UNDO.
DEF {1} SHARED VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar"
                                                                     NO-UNDO.

DEF {1} SHARED VAR tel_contrato AS CHAR    FORMAT "x(7)"             NO-UNDO.

DEF {1} SHARED VAR tel_proposta AS CHAR    FORMAT "x(8)" INIT "Proposta"
                                                                     NO-UNDO.

DEF {1} SHARED VAR tel_primeira AS CHAR    FORMAT "x(15)"
                                           INIT "Primeira Pagina"    NO-UNDO.

DEF {1} SHARED VAR tel_segundap AS CHAR    FORMAT "x(14)"
                                           INIT "Segunda Pagina"     NO-UNDO.

DEF {1} SHARED VAR tel_completa AS CHAR    FORMAT "x(8)"
                                           INIT "Completa"           NO-UNDO.

DEF {1} SHARED VAR par_flgrodar AS LOGICAL INIT TRUE                    NO-UNDO.
DEF {1} SHARED VAR par_flgfirst AS LOGICAL INIT TRUE                    NO-UNDO.
DEF {1} SHARED VAR par_flgcance AS LOGICAL                              NO-UNDO.

DEF {1} SHARED VAR aux_nmendter AS CHAR    FORMAT "x(20)"               NO-UNDO.
DEF {1} SHARED VAR aux_nmarqimp AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR aux_nmarqtmp AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR aux_dscomand AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR aux_dsbranco AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR aux_dsextens AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR aux_dsliquid AS CHAR                                 NO-UNDO.

DEF {1} SHARED VAR aux_flgimppr AS LOGICAL                              NO-UNDO.
DEF {1} SHARED VAR aux_flgimpnp AS LOGICAL                              NO-UNDO.
DEF {1} SHARED VAR aux_flgimpct AS LOGICAL                              NO-UNDO.
DEF {1} SHARED VAR aux_flgentra AS LOGICAL                              NO-UNDO.

/*  Outros .................................................................. */

FORM "Aguarde... Imprimindo cheques e/ou proposta!"
     WITH ROW 14 NO-LABEL CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde_cheques.
     
FORM "Aguarde... Imprimindo titulos e/ou proposta!"
     WITH ROW 14 NO-LABEL CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde_titulos.
          
FORM SKIP(1)
     "ATENCAO!   Ligue a impressora e posicione o papel!" AT 3
     SKIP(1)
     tel_dsimprim AT 14
     tel_dscancel AT 29
     SKIP(1)
     WITH ROW 14 COLUMN 14 OVERLAY NO-LABELS WIDTH 56 FRAME f_atencao.

FORM SKIP(1) " "
     tel_completa "  " tel_contrato "  " tel_proposta "  "
     tel_dscancel
     " " SKIP(1)
     WITH ROW 13 NO-LABELS CENTERED OVERLAY FRAME f_imprime.

/* .......................................................................... */

