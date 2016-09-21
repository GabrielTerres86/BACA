/*** CUIDADO = QUANDO ALTERAR ESTE PROGRAMA, VERIFICAR SE ALTERACAO AFETA
               O PROGRAMA CRPS183 PORQUE ELE USA O INCLUDES/CRPS428.I
               ***/
/* .............................................................................

   Programa: Fontes/crps428.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro   
   Data    : Marco/2005.                     Ultima atualizacao: 16/08/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Gerar relatorios de erros(396) referentes a CONTA DE INTEGRACAO.

   Alteracoes: 23/09/2005 - Incluidas STREAM str_2 e str_3 (Diego).
    
               23/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               17/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
                
               02/05/2006 - Alteradas FRAMES p/ criticas referente contas nao
                            encontradas (Diego).

               17/08/2006 - Adicionado o campo dtretarq no relatorio (David).
               
               20/02/2009 - Incluido tipo de arquivo no rl/crrl39699.lst
                            (Gabriel).

               10/09/2009 - Arrumar frame f_cab_resum (Gabriel).  
               
               06/10/2011 - Alterado devido relatorio crrl613 (Henrique).

               28/06/2012 - Criado parametro indicando se o arquivo COO510 
                            foi processado (Tiago). 
                            
               04/09/2012 - Tratamento crapcop.nmrescop "x(20)" (Diego).
               
               16/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
               
............................................................................. */

DEF INPUT PARAM aux_flrel510 AS LOGICAL                 NO-UNDO.

{ includes/var_batch.i }  

DEF STREAM str_1.
DEF STREAM str_2.  /* Relatorio resumido PAC'S */
DEF STREAM str_3.  /* Arquivo  e-mail */
DEF STREAM str_4.  /* Relatorio crrl613 */

DEF TEMP-TABLE w_resumo NO-UNDO
    FIELD cdagenci LIKE crapass.cdagenci
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

DEF VAR aux_nmarqimp        AS CHAR                                  NO-UNDO.
DEF VAR aux_nmarqimp_2      AS CHAR                                  NO-UNDO.
DEF VAR aux_nmarqimp_3      AS CHAR                                  NO-UNDO.
DEF VAR aux_nmarqimp_4      AS CHAR                                  NO-UNDO.
DEF VAR aux_nmarqenv        AS CHAR                                  NO-UNDO.
DEF VAR rel_dsrelato        AS CHAR                                  NO-UNDO.
DEF VAR aux_dsagenci        AS CHAR                                  NO-UNDO.
DEF VAR aux_arq_excell      AS CHAR                                  NO-UNDO.
DEF VAR tel_cddopcao        AS CHAR    FORMAT "!(1)"                 NO-UNDO.
DEF VAR aux_nmresage        AS CHAR    FORMAT "x(24)"                NO-UNDO.
DEF VAR aux_nmresadm        AS CHAR    FORMAT "x(30)"                NO-UNDO.
DEF VAR aux_totgeral        AS INTEGER                               NO-UNDO.
DEF VAR aux_geraltot        AS INTEGER                               NO-UNDO.
DEF VAR aux_flgexist        AS LOGICAL                               NO-UNDO.

/*--- Variaveis para o cabecalho ---*/
DEF VAR rel_nmempres        AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF VAR rel_nmrelato        AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.
DEF VAR rel_nrmodulo        AS INT     FORMAT "9"                    NO-UNDO.
DEF VAR rel_nmmodulo        AS CHAR    FORMAT "x(15)" EXTENT 5
                            INIT ["DEP. A VISTA   ","CAPITAL        ",
                                  "EMPRESTIMOS    ","DIGITACAO      ",
                                  "GENERICO       "]                 NO-UNDO.

DEF VAR tel_dstipcta        AS CHAR                                  NO-UNDO.
DEF VAR tel_dssitdct        AS CHAR                                  NO-UNDO.

/* variaveis para impressao */
DEF VAR aux_contador AS INT                                          NO-UNDO.
DEF VAR aux_nmendter AS CHAR           FORMAT "x(20)"                NO-UNDO.
DEF VAR par_flgrodar AS LOGICAL        INIT TRUE                     NO-UNDO.
DEF VAR aux_flgescra AS LOGICAL                                      NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                         NO-UNDO.
DEF VAR par_flgfirst AS LOGICAL        INIT TRUE                     NO-UNDO.
DEF VAR tel_dsimprim AS CHAR           FORMAT "x(8)" INIT "Imprimir" NO-UNDO.
DEF VAR tel_dscancel AS CHAR           FORMAT "x(8)" INIT "Cancelar" NO-UNDO.
DEF VAR par_flgcance AS LOGICAL                                      NO-UNDO.


/* nome do arquivo de log */
DEFINE VARIABLE aux_nmarqlog AS CHAR                                 NO-UNDO.


FORM w-erros.cdagenci   FORMAT "zz9"        LABEL "PA"
     " - "
     aux_nmresage
     WITH NO-BOX NO-LABELS SIDE-LABELS FRAME f_pac.

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
     "CONTA/DV"  AT  7
     "NOME"      AT 16
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
     
FORM w-erros.cdagenci   FORMAT "zz9"        NO-LABEL
     w-erros.nrdconta   FORMAT "zzzz,zzz,9" NO-LABEL
     w-erros.nmprimtl   FORMAT "x(25)"      NO-LABEL
     w-erros.cdtipcta   FORMAT "zz99"       NO-LABEL
     w-erros.cdsitdct   FORMAT "zzz9"       NO-LABEL
     w-erros.tparquiv   FORMAT "zzzzz9"     NO-LABEL
     w-erros.dscritic   FORMAT "x(65)"      NO-LABEL
     w-erros.dtretarq   FORMAT "99/99/99"   NO-LABEL
     WITH NO-BOX NO-LABELS DOWN WIDTH 132 FRAME f_dados_resum.

FORM aux_dsagenci        FORMAT "x(20)"        LABEL "PA"
     w_resumo.toterros   FORMAT "zzz,zzz,zz9"  LABEL "CONTAS C/ CRITICAS"
     w_resumo.totaisok   FORMAT "zzz,zzz,zz9"  
                         LABEL "CONTAS A SEREM CADASTRADAS"
     WITH NO-BOX NO-LABELS DOWN WIDTH 132 FRAME f_resumo_total.

FORM SKIP
     "Cooperativa =>" crapcop.nmrescop FORMAT "X(20)"
     SKIP(1)
     WITH NO-BOX NO-LABEL FRAME f_nmrescop.

FORM tt-crapeca.cdagenci COLUMN-LABEL "PA"
     tt-crapeca.nrdconta COLUMN-LABEL "Conta/DV"
     tt-crapeca.nrdctitg COLUMN-LABEL "Conta/ITG"
     tt-crapeca.nmprimtl COLUMN-LABEL "Nome do Titular" FORMAT "x(25)"
     tt-crapeca.nmresadm COLUMN-LABEL "Modalidade"      FORMAT "x(20)"
     tt-crapeca.dscritic COLUMN-LABEL "Critica"         FORMAT "x(50)"
     WITH WIDTH 132 DOWN NO-BOX FRAME f_crapeca.

ASSIGN glb_cdprogra = "crps428"
       glb_flgbatch = FALSE
       aux_nmarqlog = "log/prcitg_" + STRING(YEAR(glb_dtmvtolt),"9999") + 
                      STRING(MONTH(glb_dtmvtolt),"99") + 
                      STRING(DAY(glb_dtmvtolt),"99") + ".log".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     QUIT.

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> " + aux_nmarqlog).
         QUIT.
     END.
        
EMPTY TEMP-TABLE w_resumo.
/* rotina de geracao do relatorio */
{ includes/crps428.i }

/* referente ao relatorio crrl396_99 */
IF   aux_flgexist = TRUE   THEN
     DO:                         
        MESSAGE "(T)erminal ou (I)mpressora: " UPDATE tel_cddopcao.

        HIDE MESSAGE NO-PAUSE.       
                          
        IF   tel_cddopcao = "I" THEN
             DO:
                 ASSIGN glb_nmarqimp = aux_nmarqimp
                        glb_cdrelato = 396
                        glb_nrdevias = 1.

                 /* somente para a includes/impressao.i */
                 FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper
                                          NO-LOCK NO-ERROR.
                                    
                 { includes/impressao.i }  
             END.    
        ELSE
        IF   tel_cddopcao = "T" THEN
             RUN fontes/visrel.p (INPUT aux_nmarqimp).
     END.
        
RUN fontes/fimprg.p.

/*...........................................................................*/
