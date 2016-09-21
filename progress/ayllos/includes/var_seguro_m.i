/* .............................................................................

   Programa: Includes/var_seguro_m.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Junho/97.                           Ultima atualizacao: 29/08/2011

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Criacao das variaveis para impressao da PROPOSTA DE SEGURO.

   Alteracoes: 31/01/2000 - Assinatura do conjuge na proposta de seguro de 
                            vida (Deborah).

               21/09/2001 - Seguro Residencial (Ze Eduardo).

               30/07/2004 - Incluir observacao sobre o cancelamento do seguro
                            (Edson).

               04/08/2004 - Quebrava pagina errada (Margarete).

               24/03/2005 - Tratamento para tipo de seguro 11 - CASA (Evandro).

               11/04/2005 - Imprimir autorizacao de consulta ao SPC (Edson).
               
               05/05/2005 - Arrumada quebra de pagina para autorizacao de seguro
                            para automovel (Diego).
                            
               01/12/2005 - Colocar a quantidade de parcelas no seguro tipo
                            CASA (Evandro).

               01/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando. 
               
               05/04/2010 - Retirar frame f_digit_casa (Gabriel).
               
               12/11/2010 - Incluida a palavra "CADIN" na proposta de seguro
                            (Vitor).
                            
               29/08/2011 - Alterada impressao do contrato para seguros
                            do tipo 11, casa, para um novo
                            layout (Gati - Oliver)
               
............................................................................. */

DEF {1} SHARED VAR tel_dsimprim AS CHAR FORMAT "x(8)" INIT "Imprimir"  NO-UNDO.
DEF {1} SHARED VAR tel_dscancel AS CHAR FORMAT "x(8)" INIT "Cancelar"  NO-UNDO.

DEF {1} SHARED VAR rel_nrdconta AS INT  EXTENT 2                       NO-UNDO.
DEF {1} SHARED VAR rel_dstipseg AS CHAR                                NO-UNDO.
DEF {1} SHARED VAR rel_dsseguro AS CHAR                                NO-UNDO.
DEF {1} SHARED VAR rel_dssubsti AS CHAR                                NO-UNDO.
DEF {1} SHARED VAR rel_nmprimtl AS CHAR                                NO-UNDO.
DEF {1} SHARED VAR rel_nrctrseg AS INT                                 NO-UNDO.
DEF {1} SHARED VAR rel_cdcalcul AS INT                                 NO-UNDO.
DEF {1} SHARED VAR rel_tpplaseg AS INT                                 NO-UNDO.
DEF {1} SHARED VAR rel_ddvencto AS INT                                 NO-UNDO.
DEF {1} SHARED VAR rel_vlpreseg AS DECI                                NO-UNDO.
DEF {1} SHARED VAR rel_dsparcel AS CHAR                                NO-UNDO.
DEF {1} SHARED VAR rel_dsbemseg AS CHAR EXTENT 5                       NO-UNDO.
DEF {1} SHARED VAR rel_dsmvtolt AS CHAR                                NO-UNDO.
DEF {1} SHARED VAR rel_nmdsegur AS CHAR                                NO-UNDO.
DEF {1} SHARED VAR rel_nrcpfcgc AS CHAR FORMAT "x(018)"                NO-UNDO.
DEF {1} SHARED VAR rel_tracoseg AS CHAR                                NO-UNDO. 
DEF {1} SHARED VAR rel_dtinivig AS DATE                                NO-UNDO.
DEF {1} SHARED VAR rel_dtfimvig AS DATE                                NO-UNDO.
DEF {1} SHARED VAR rel_nrdocttl LIKE crapttl.nrdocttl                  NO-UNDO.
DEF {1} SHARED VAR rel_dsmorada LIKE craptsg.dsmorada                  NO-UNDO.
DEF {1} SHARED VAR rel_dsocupac LIKE craptsg.dsocupac                  NO-UNDO.

DEF {1} SHARED VAR par_flgrodar AS LOGI INIT TRUE                      NO-UNDO.
DEF {1} SHARED VAR par_flgfirst AS LOGI INIT TRUE                      NO-UNDO.
DEF {1} SHARED VAR par_flgcance AS LOGI                                NO-UNDO.

DEF {1} SHARED VAR aux_flgescra AS LOGI                                NO-UNDO.
DEF {1} SHARED VAR aux_flgproep AS LOGI                                NO-UNDO.

DEF {1} SHARED VAR aux_nmendter AS CHAR FORMAT "x(20)"                 NO-UNDO.
DEF {1} SHARED VAR aux_nmarqimp AS CHAR                                NO-UNDO.
DEF {1} SHARED VAR aux_nmarqtmp AS CHAR                                NO-UNDO.
DEF {1} SHARED VAR aux_dscomand AS CHAR                                NO-UNDO.
DEF {1} SHARED VAR aux_dsbranco AS CHAR                                NO-UNDO.
DEF {1} SHARED VAR aux_dsextens AS CHAR                                NO-UNDO.
DEF {1} SHARED VAR aux_dsliquid AS CHAR                                NO-UNDO.

DEF {1} SHARED VAR aux_flgimppr AS LOGI                                NO-UNDO.
DEF {1} SHARED VAR aux_flgimpnp AS LOGI                                NO-UNDO.
DEF {1} SHARED VAR aux_flgimpct AS LOGI                                NO-UNDO.
DEF {1} SHARED VAR aux_flgentra AS LOGI                                NO-UNDO.

DEF {1} SHARED VAR aux_dsmesref AS CHAR                                NO-UNDO.
DEF {1} SHARED VAR aux_nmoperad AS CHAR                                NO-UNDO.

DEF {1} SHARED VAR aux_contapag AS INT                                 NO-UNDO.
DEF {1} SHARED VAR aux_contames AS INT                                 NO-UNDO.
DEF {1} SHARED VAR aux_nrlinhas AS INT                                 NO-UNDO.
DEF {1} SHARED VAR aux_nrpagina AS INT                                 NO-UNDO.
DEF {1} SHARED VAR aux_dsendres AS CHAR                                NO-UNDO.

FORM "Imprimindo Proposta Seguro"
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.

FORM SKIP(1)
     "ATENCAO!   Ligue a impressora e posicione o papel!" AT 3
     SKIP(1)
     tel_dsimprim AT 14
     tel_dscancel AT 29
     SKIP(1)
     WITH ROW 14 COLUMN 14 OVERLAY NO-LABELS WIDTH 56
          TITLE glb_nmformul FRAME f_atencao.

/* .......................................................................... */
