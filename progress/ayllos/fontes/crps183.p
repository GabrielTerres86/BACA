/* .............................................................................

   Programa: Fontes/crps183.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro   
   Data    : Julho/2005.                     Ultima atualizacao: 13/02/2015

   Dados referentes ao programa:

   Frequencia: Atende a solicitacao 86.
   Objetivo  : Gerar relatorios de erros(396) referentes a CONTA DE INTEGRACAO.

   Alteracoes: 20/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               26/09/2005 - Incluidas STREAM str_2 e str_3 (Diego).
               
               15/02/2006 - Unificacao dos bancos - SQLWorks - Eder

               09/05/2006 - Alteradas FRAMES p/ criticas referente contas nao
                            encontradas (Mirtes).

               17/08/2006 - Adicionado o campo dtretarq no relatorio (David).

               08/05/2009 - Alterada frame f_dados_resum para o ajuste no
                            relatorio crrl39699.lst (Gabriel).
                            
               06/10/2011 - Alterado devido relatorio crrl613 (Henrique).
               
               07/11/2011 - Retirar datas colocadas como teste (Gabriel).
               
               24/07/2012 - Incluido flag "flrel510" (David Kruger).
               
               04/11/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (Guilherme Gielow)
                            
               13/02/2015 - Ajustado format para evitar estouro PA (Daniel) 

............................................................................. */

{ includes/var_batch.i "NEW" }

DEF STREAM str_1.
DEF STREAM str_2.  /* Relatorio resumido PA'S */
DEF STREAM str_3.  /* Arquivo  e-mail */
DEF STREAM str_4.  /* Relatorio crrl613 */

DEF TEMP-TABLE w_resumo                                              NO-UNDO
    FIELD cdagenci  LIKE crapass.cdagenci
    FIELD toterros  AS INTEGER
    FIELD totaisok  AS INTEGER
    INDEX w_resumo1 cdagenci.

DEF TEMP-TABLE w-erros NO-UNDO
    FIELD cdagenci  AS INT     FORMAT "zz9"        
    FIELD tparquiv  LIKE crapeca.tparquiv 
    FIELD nrdconta  AS INT     FORMAT "zzzz,zzz,9" 
    FIELD nmprimtl  AS CHAR    FORMAT "x(40)"      
    FIELD dscritic  AS CHAR    FORMAT "x(65)"      
    FIELD cdtipcta  LIKE crapass.cdtipcta
    FIELD cdsitdct  LIKE crapass.cdsitdct
    FIELD dtretarq  LIKE crapeca.dtretarq
    INDEX w_erros1 cdagenci tparquiv.

DEF TEMP-TABLE tt-crapeca
    FIELD cdcooper LIKE crapeca.cdcooper
    FIELD cdagenci LIKE crapass.cdagenci
    FIELD nrdconta LIKE crapeca.nrdconta
    FIELD nrdctitg LIKE crapass.nrdctitg
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD nmresadm AS   CHAR
    FIELD flginteg AS   LOGICAL
    FIELD dscritic LIKE crapeca.dscritic.

DEF   VAR aux_nmarqimp   AS CHAR                                     NO-UNDO.
DEF   VAR aux_nmarqimp_2 AS CHAR                                     NO-UNDO.
DEF   VAR aux_nmarqimp_3 AS CHAR                                     NO-UNDO.
DEF   VAR aux_nmarqimp_4 AS CHAR                                     NO-UNDO.
DEF   VAR aux_nmarqenv   AS CHAR                                     NO-UNDO.
DEF   VAR rel_dsrelato   AS CHAR                                     NO-UNDO.
DEF   VAR aux_dsagenci   AS CHAR                                     NO-UNDO.
DEF   VAR aux_arq_excell AS CHAR                                     NO-UNDO.
DEF   VAR aux_nmresage   AS CHAR    FORMAT "x(24)"                   NO-UNDO.
DEF   VAR aux_nmresadm   AS CHAR    FORMAT "x(30)"                   NO-UNDO.
DEF   VAR tel_cddopcao   AS CHAR    FORMAT "!(1)"                    NO-UNDO.
DEF   VAR aux_totgeral   AS INTEGER                                  NO-UNDO.
DEF   VAR aux_geraltot   AS INTEGER                                  NO-UNDO.
DEF   VAR aux_flgexist   AS LOGICAL                                  NO-UNDO.

/*--- Variaveis para o cabecalho ---*/
DEF   VAR rel_nmempres   AS CHAR    FORMAT "x(15)"                   NO-UNDO.
DEF   VAR rel_nmrelato   AS CHAR    FORMAT "x(40)" EXTENT 5          NO-UNDO.
DEF   VAR rel_nrmodulo   AS INT     FORMAT "9"                       NO-UNDO.
DEF   VAR rel_nmmodulo   AS CHAR    FORMAT "x(15)" EXTENT 5
                                       INIT ["DEP. A VISTA   ",
                                             "CAPITAL        ",
                                             "EMPRESTIMOS    ",
                                             "DIGITACAO      ",
                                             "GENERICO       "]      NO-UNDO.
                                  
DEF   VAR tel_dstipcta   AS CHAR                                     NO-UNDO.
DEF   VAR tel_dssitdct   AS CHAR                                     NO-UNDO.


/* variaveis para impressao */
DEF   VAR aux_contador   AS INT                                      NO-UNDO.
DEF   VAR aux_nmendter   AS CHAR    FORMAT "x(20)"                   NO-UNDO.
DEF   VAR par_flgrodar   AS LOGICAL INIT TRUE                        NO-UNDO.
DEF   VAR aux_flgescra   AS LOGICAL                                  NO-UNDO.
DEF   VAR aux_dscomand   AS CHAR                                     NO-UNDO.
DEF   VAR par_flgfirst   AS LOGICAL INIT TRUE                        NO-UNDO.
DEF   VAR tel_dsimprim   AS CHAR    FORMAT "x(8)" INIT "Imprimir"    NO-UNDO.
DEF   VAR tel_dscancel   AS CHAR    FORMAT "x(8)" INIT "Cancelar"    NO-UNDO.
DEF   VAR par_flgcance   AS LOGICAL                                  NO-UNDO.

DEF   VAR aux_flrel510   AS LOG     INITIAL FALSE                    NO-UNDO.

FORM w-erros.cdagenci   FORMAT "zz9"        LABEL "PA"
     " - "
     aux_nmresage
     WITH NO-BOX NO-LABELS SIDE-LABELS FRAME  f_pac.


FORM SKIP(2)
     rel_dsrelato       FORMAT "x(132)"
     SKIP(1)
     "CONTA/DV"  AT  3
     "NOME"      AT 12
     "MOTIVO"    AT 53
     "DATA"      AT 119
     SKIP(1)
     WITH NO-BOX NO-LABELS SIDE-LABELS WIDTH 132 FRAME f_cab.
    

FORM SKIP(2)
     rel_dsrelato      FORMAT "x(132)"
     SKIP(1)
     "CONTA/DV"  AT  3
     "NOME"      AT 12
     "TIPO"      AT 43
     "SIT."      AT 48
     "MOTIVO"    AT 53
     "DATA"      AT 119
     SKIP(1)
     WITH NO-BOX NO-LABELS SIDE-LABELS WIDTH 132 FRAME f_cab_resum.
     
     
FORM SKIP(1)
     "TOTAIS POR PA"  AT 4
     SKIP(1)
     WITH NO-BOX NO-LABELS SIDE-LABELS WIDTH 132 FRAME f_cab_total.

FORM SKIP(1)
     aux_totgeral       FORMAT "zzz,zzz,zz9" LABEL "TOTAL GERAL" AT 16
     aux_geraltot       FORMAT "zzz,zzz,zz9" NO-LABEL            AT 56
     WITH NO-BOX NO-LABELS SIDE-LABELS WIDTH 132 FRAME f_totgeral.
   
FORM w-erros.nrdconta   FORMAT "zzzz,zzz,9" NO-LABEL
     w-erros.nmprimtl   FORMAT "x(40)"      NO-LABEL
     w-erros.dscritic   FORMAT "x(65)"      NO-LABEL
     w-erros.dtretarq   FORMAT "99/99/9999" NO-LABEL
     WITH NO-BOX NO-LABELS DOWN WIDTH 132 FRAME f_dados.

FORM w-erros.nrdconta   FORMAT "zzzz,zzz,9" 
     w-erros.nmprimtl   FORMAT "x(30)"      
     w-erros.cdtipcta   FORMAT "zz99"       
     w-erros.cdsitdct   FORMAT "zzz9"       
     w-erros.dscritic   FORMAT "x(65)"      
     w-erros.dtretarq   FORMAT "99/99/9999" 
     WITH NO-LABELS NO-BOX DOWN WIDTH 132 FRAME f_dados_resum.

FORM aux_dsagenci        FORMAT "x(21)"        LABEL "PA"
     w_resumo.toterros   FORMAT "zzz,zzz,zz9"  LABEL "CONTAS C/ CRITICAS"
     w_resumo.totaisok   FORMAT "zzz,zzz,zz9"  
                         LABEL "CONTAS A SEREM CADASTRADAS"
     WITH NO-BOX NO-LABELS DOWN WIDTH 132 FRAME f_resumo_total.

FORM SKIP
     "Cooperativa =>" crapcop.nmrescop
     SKIP(1)
     WITH NO-BOX NO-LABEL FRAME f_nmrescop.

FORM tt-crapeca.cdagenci COLUMN-LABEL "PA"
     tt-crapeca.nrdconta COLUMN-LABEL "Conta/DV"
     tt-crapeca.nrdctitg COLUMN-LABEL "Conta/ITG"
     tt-crapeca.nmprimtl COLUMN-LABEL "Nome do Titular" FORMAT "x(25)"
     tt-crapeca.nmresadm COLUMN-LABEL "Modalidade"      FORMAT "x(20)"
     tt-crapeca.dscritic COLUMN-LABEL "Critica"         FORMAT "x(50)"
     WITH WIDTH 132 DOWN NO-BOX FRAME f_crapeca.

ASSIGN glb_cdprogra = "crps183".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     DO:
         RUN fontes/fimprg.p.
         QUIT.
     END.

EMPTY TEMP-TABLE tt-crapeca.

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> log/proc_batch.log").
         RUN fontes/fimprg.p.
         QUIT.
     END.

EMPTY TEMP-TABLE w_resumo.
/* rotina de geracao do relatorio */
{ includes/crps428.i }

RUN fontes/fimprg.p.

/*...........................................................................*/

