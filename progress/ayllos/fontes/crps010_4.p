/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps010_4.p              | pc_crps010.pc_crps010_4           |
  +---------------------------------+-----------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/



/* ..........................................................................

   Programa: Fontes/crps010_4.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Julho/2005.                       Ultima atualizacao: 04/11/2013
  
   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Gerar relatorio 426.

   Alteracoes: 20/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               14/02/2006 - Unificacao dos bancos - SQLWorks - Eder
               
               13/09/2013 - Substituida impressao de telefones da ass pela
                            tfc. (Reinert)
              
               07/10/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               28/10/2013 - Alterado totalizador de 99 para 999. (Reinert)
               
               04/11/2013 - Alterado find da craptfc pelo for first. (Reinert)
               
............................................................................ */

DEF STREAM str_5.

{ includes/var_batch.i }

DEF    VAR aux_nmarqimp AS CHAR                                      NO-UNDO.

/* variaveis para o includes/cabrel132_5.i */
DEF    VAR rel_nmempres AS CHAR    FORMAT "x(15)"                    NO-UNDO.
DEF    VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5           NO-UNDO.
DEF    VAR rel_nrmodulo AS INT     FORMAT "9"                        NO-UNDO.
DEF    VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                                   INIT ["DEP. A VISTA   ",
                                         "CAPITAL        ",
                                         "EMPRESTIMOS    ",
                                         "DIGITACAO      ",
                                         "GENERICO       "]          NO-UNDO.
DEF    VAR rel_nrtelres AS CHAR                                      NO-UNDO.
DEF    VAR rel_nrtelcom AS CHAR                                      NO-UNDO.

DEF SHARED TEMP-TABLE w_duplicados
           FIELD cdagenci LIKE crapass.cdagenci
           FIELD nrdconta LIKE crapass.nrdconta
           INDEX w_duplicados1 AS PRIMARY cdagenci nrdconta.

DEF BUFFER crabass FOR crapass.

FORM w_duplicados.cdagenci           LABEL "PA"
     w_duplicados.nrdconta           LABEL "CONTA/DV"
     crapass.nmprimtl                LABEL "NOME"               FORMAT "x(18)"
     rel_nrtelres                    LABEL "FONE RESIDENCIAL"   FORMAT "x(12)"
     rel_nrtelcom                    LABEL "FONE COMERCIAL"     FORMAT "x(12)"
     crapcot.vldcotas                LABEL "CAPITAL"            FORMAT "zzz,zzz,zz9.99"
     crabass.nrmatric                LABEL "MATRICULA"
     craptrf.nrdconta                LABEL "CONTA(ORIG)"
     crabass.nmprimtl                LABEL "NOME"               FORMAT "x(19)"
     WITH DOWN NO-BOX NO-LABELS CENTERED WIDTH 132 FRAME f_duplicados.

FORM SKIP(2)
     "************************************************************"      AT  28
     "******************************"                                    AT  88
     SKIP
     "**"                                                                AT  28
     "**"                                                                AT 116
     "**      ANALISAR OS DADOS ACIMA E ASSOCIAR OS TITULARES QUE AINDA" AT  28
     "NAO FOREM SOCIOS.     **"
     "**"                                                                AT  28
     "**"                                                                AT 116
     "************************************************************"      AT  28
     "******************************"                                    AT  88
     WITH NO-BOX CENTERED WIDTH 132 FRAME f_instrucao.


FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop   THEN
     RETURN.  /* Retorna para o crps010.p */

ASSIGN glb_cdempres = 11.

/* Monta o cabecalho */
{ includes/cabrel132_5.i }

FOR EACH w_duplicados BREAK BY w_duplicados.cdagenci
                               BY w_duplicados.nrdconta:
   
    glb_cdcritic = 0.
    
    IF   FIRST-OF(w_duplicados.cdagenci)   THEN
         DO:
             OUTPUT STREAM str_5 TO VALUE("rl/crrl426_" +
                    STRING(w_duplicados.cdagenci,"999") + ".lst") PAGE-SIZE 84.

             VIEW STREAM str_5 FRAME f_cabrel132_5.
         END.
         
    FIND crapass WHERE crapass.cdcooper = glb_cdcooper           AND
                       crapass.nrdconta = w_duplicados.nrdconta   
                       NO-LOCK NO-ERROR.
                       
    IF   NOT AVAILABLE crapass   THEN
         glb_cdcritic = 9.
         
    FIND crapcot WHERE crapcot.cdcooper = glb_cdcooper      AND
                       crapcot.nrdconta = crapass.nrdconta  NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE crapcot   THEN
         glb_cdcritic = 169.

    /* busca a conta de origem */
    FIND craptrf WHERE craptrf.cdcooper = glb_cdcooper      AND
                       craptrf.nrsconta = crapass.nrdconta  NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE craptrf   THEN
         glb_cdcritic = 124.
         
    /* busca o nome do associado de origem */
    FIND crabass WHERE crabass.cdcooper = glb_cdcooper      AND
                       crabass.nrdconta = craptrf.nrdconta  NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE crabass   THEN
         glb_cdcritic = 9.

    /* exibe se nao for o mesmo titular nas duas contas (ORIGEM e DUPLICACA) */
    IF   glb_cdcritic     = 0                  AND
         crapass.nmprimtl = crabass.nmprimtl   THEN
         glb_cdcritic = 123.

    /* para garantir a intrucao com pelo menos uma conta na mesma pagina */
    IF   LINE-COUNTER(str_5) > (PAGE-SIZE(str_5) - 8 )   THEN
         PAGE STREAM str_5.

    FOR FIRST craptfc FIELDS(nrdddtfc nrtelefo)
                      WHERE craptfc.cdcooper = crapass.cdcooper AND
                            craptfc.nrdconta = crapass.nrdconta AND
                            craptfc.tptelefo = 1
                 NO-LOCK: END.

    IF AVAIL craptfc THEN
       ASSIGN rel_nrtelres = STRING(craptfc.nrdddtfc) +
                             STRING(craptfc.nrtelefo).
    ELSE
       ASSIGN rel_nrtelres = "".

    FOR FIRST craptfc FIELDS(nrdddtfc nrtelefo)
                      WHERE craptfc.cdcooper = crapass.cdcooper AND
                            craptfc.nrdconta = crapass.nrdconta AND
                            craptfc.tptelefo = 3
                 NO-LOCK: END.

    IF AVAIL craptfc THEN
       ASSIGN rel_nrtelcom = STRING(craptfc.nrdddtfc) +
                             STRING(craptfc.nrtelefo).
    ELSE
       ASSIGN rel_nrtelcom = "".

    IF   glb_cdcritic = 0   THEN
         DO:
            DISPLAY STREAM str_5
                    w_duplicados.cdagenci
                    w_duplicados.nrdconta
                    crapass.nmprimtl
                    rel_nrtelres
                    rel_nrtelcom
                    crapcot.vldcotas
                    crabass.nrmatric
                    craptrf.nrdconta
                    crabass.nmprimtl
                    WITH FRAME f_duplicados.
            
            DOWN STREAM str_5 WITH FRAME f_duplicados.
         END.
         
    IF   LAST-OF(w_duplicados.cdagenci)   THEN
         DO:
             VIEW STREAM str_5 FRAME f_instrucao.

             OUTPUT STREAM str_5 CLOSE.
         END.

END.

/* .......................................................................... */
