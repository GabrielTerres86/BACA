/* .............................................................................

   Programa: Includes/var_deschq_m.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Marco/2003.                         Ultima atualizacao: 25/08/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Criacao das variaveis para impressao da PROPOSTA 
               DE LIMITE DE DESCONTO DE CHEQUES.

   Alteracoes: 06/11/2009 - Impressao do Rating (Gabriel)

               25/08/2014 - Incluir tel_impricet no frame de impressao 
                            (Lucas Ranghetti/Gielow - Projeto CET) 
............................................................................. */

DEF {1} SHARED VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir"
                                                                     NO-UNDO.
DEF {1} SHARED VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar"
                                                                     NO-UNDO.

DEF {1} SHARED VAR tel_contrato AS CHAR    FORMAT "x(8)" INIT "Contrato"
                                                                     NO-UNDO.

DEF {1} SHARED VAR tel_dsrating AS CHAR    FORMAT "x(6)" INIT "Rating" 
                                                                     NO-UNDO.

DEF {1} SHARED VAR tel_proposta AS CHAR    FORMAT "x(8)" INIT "Proposta"
                                                                     NO-UNDO.
DEF {1} SHARED VAR tel_notaprom AS CHAR    FORMAT "x(16)"
                                           INIT "Nota Promissoria"   NO-UNDO.

DEF {1} SHARED VAR tel_primeira AS CHAR    FORMAT "x(15)"
                                           INIT "Primeira Pagina"    NO-UNDO.

DEF {1} SHARED VAR tel_segundap AS CHAR    FORMAT "x(14)"
                                           INIT "Segunda Pagina"     NO-UNDO.

DEF {1} SHARED VAR tel_completa AS CHAR    FORMAT "x(8)"
                                           INIT "Completa"           NO-UNDO.
DEF {1} SHARED VAR tel_impricet AS CHAR FORMAT "x(3)"  INIT "CET"    NO-UNDO.

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

FORM "Aguarde... Imprimindo contrato e/ou proposta e/ou nota promissoria!"
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.

FORM "Aguarde... Imprimindo CET!"
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde_cet.

FORM SKIP(1)
     "ATENCAO!   Ligue a impressora e posicione o papel!" AT 3
     SKIP(1)
     tel_dsimprim AT 14
     tel_dscancel AT 29
     SKIP(1)
     WITH ROW 14 COLUMN 14 OVERLAY NO-LABELS WIDTH 56 FRAME f_atencao.

FORM SKIP(1)
     tel_completa " " tel_contrato " "
     tel_impricet " " tel_proposta " " 
     tel_notaprom " " tel_dsrating ""
     tel_dscancel 
     SKIP(1)
     WITH ROW 13  COLUMN 3 NO-LABELS OVERLAY FRAME f_imprime.

/* .......................................................................... */
