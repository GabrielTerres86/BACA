/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | includes/crps634.i              | pc_crps634_i                      |
  +---------------------------------+-----------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/









/* ..........................................................................

   Programa: Includes/crps634.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CECRED
   Autor   : Adriano      
   Data    : Dezembro/2012                     Ultima atualizacao: 07/07/2014

   Dados referentes ao programa:

   Frequencia: Diario(crps634)/Mensal(crps627).
   Objetivo  : Realiza a formacao do grupo economico.
               

   Alteracoes: 28/03/2013 - Incluido a passagem do parametro cdprogra na
                            chamada da procedure forma_grupo_economico
                            (Adriano).
               
               18/04/2013 - Ajustes realizados:
                             - Colocado no-undo nas temp-tables tt-erro,
                               tt-grupo-economico;
                             - Relatorio (crrl628): Invertido a ordem das 
                               colunas "PAC GRUPO", alterado o label da coluna
                               "Conta SOC" para "Conta/DV" e pulado uma linha 
                               ao final de cada grupo (Adriano).
                               
               09/08/2013 - Modificado o termo "PAC" para "PA" (Douglas).
               
               24/06/2014 - Exclusao da criacao da temp table tt-grupo-economico
                            sera utilizado a temp table tt-grupo na include b1wgen0138tt. 
                           (Chamado 130880) - (Tiago Castro - RKAM)
               
............................................................................. */
{ sistema/generico/includes/b1wgen0138tt.i }

DEF VAR h-b1wgen0138 AS HANDLE                                       NO-UNDO.
DEF VAR h-b1wgen0024 AS HANDLE                                       NO-UNDO.

DEF VAR rel_nmresemp AS CHAR    FORMAT "x(15)"                       NO-UNDO.
DEF VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5              NO-UNDO.
DEF VAR rel_nmempres AS CHAR                                         NO-UNDO.
DEF VAR rel_nrmodulo AS INT     FORMAT "9"                           NO-UNDO.
DEF VAR rel_nmmodulo AS CHAR    FORMAT "X(15)" EXTENT 5
                                INIT ["DEP. A VISTA   ",
                                      "CAPITAL        ",
                                      "EMPRESTIMOS    ",
                                      "DIGITACAO      ",
                                      "GENERICO       "]             NO-UNDO.

DEF VAR aux_nmarquiv AS CHAR                                         NO-UNDO.
DEF VAR aux_cdcooper AS CHAR                                         NO-UNDO.

DEF STREAM str_1.

DEF TEMP-TABLE tt-erro NO-UNDO LIKE craperr.


FORM "Grupo"                  AT 1
     "PA"                     AT 13   
     "Conta/DV"               AT 19
     "Risco"                  AT 28
     "Endividamento"          AT 34
     "Risco do Grupo"         AT 53
     "Endividamento do Grupo" AT 68
     SKIP
     "-----------"            
     "---"                    AT 13
     "----------"             AT 17
     "-----"                  AT 28
     "------------------"     AT 34
     "--------------"         AT 53
     "----------------------" AT 68
     WITH WIDTH 132 NO-BOX NO-LABEL FRAME f_label.

FORM tt-grupo.nrdgrupo 
     tt-grupo.cdagenci AT 13  
     tt-grupo.nrctasoc AT 17  
     tt-grupo.dsdrisco AT 28
     tt-grupo.vlendivi AT 38 FORMAT "zzz,zzz,zz9.99"
     tt-grupo.dsdrisgp AT 53
     tt-grupo.vlendigp AT 76 FORMAT "zzz,zzz,zz9.99"
     WITH DOWN WIDTH 262 NO-BOX NO-LABEL FRAME f_grupo_economico.

ASSIGN aux_nmarquiv = "rl/crrl628.lst".
       

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF NOT AVAILABLE crapcop THEN
   DO:
       ASSIGN glb_cdcritic = 651.
       RUN fontes/critic.p.
       UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                         " - " + glb_cdprogra + "' --> '"  +
                         glb_dscritic + " >> log/proc_batch.log").
       RETURN.

   END.

ASSIGN glb_dscritic = "".

IF NOT VALID-HANDLE(h-b1wgen0138) THEN
   RUN sistema/generico/procedures/b1wgen0138.p PERSISTENT SET h-b1wgen0138.

RUN forma_grupo_economico IN h-b1wgen0138(INPUT crapcop.cdcooper,
                                          INPUT glb_cdagenci,
                                          INPUT 0,
                                          INPUT glb_cdoperad,
                                          INPUT glb_dtmvtolt,
                                          INPUT glb_nmdatela,
                                          INPUT glb_cdprogra,
                                          INPUT 1,
                                          INPUT aux_persocio,
                                          INPUT FALSE,
                                          OUTPUT TABLE tt-grupo,
                                          OUTPUT TABLE tt-erro).

IF VALID-HANDLE(h-b1wgen0138) THEN
   DELETE OBJECT h-b1wgen0138.

IF RETURN-VALUE <> "OK" THEN
   DO:
      IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
         ASSIGN glb_dscritic = "Nao foi possivel realizar a formacao " + 
                               "do grupo economico para a "            +
                               crapcop.nmrescop.
      ELSE
         DO: 
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            ASSIGN glb_dscritic = tt-erro.dscritic.

         END.
                                                                 
      UNIX SILENT VALUE("echo "                                  +
                        " " + STRING(TIME,"HH:MM:SS")            +
                        " - " + glb_cdprogra + "' --> '"         +
                        glb_dscritic + " >> log/proc_batch.log").

      RETURN.
    
   END.


OUTPUT STREAM str_1 TO VALUE(aux_nmarquiv) PAGED PAGE-SIZE 84.

ASSIGN glb_cdrelato[1] = 628.

{ includes/cabrel132_1.i } 

VIEW STREAM str_1 FRAME f_cabrel132_1.

DISPLAY STREAM str_1 WITH FRAME f_mostra_cabecalho.

FOR EACH tt-grupo 
         WHERE tt-grupo.cdcooper = crapcop.cdcooper
               NO-LOCK BREAK BY tt-grupo.cdcooper
                              BY tt-grupo.nrdgrupo
                               BY ROWID(tt-grupo):

    IF FIRST-OF(tt-grupo.cdcooper) THEN
       VIEW STREAM str_1 FRAME f_label.


    IF LINE-COUNTER(str_1) > PAGE-SIZE(str_1) THEN
       DO:
          PAGE STREAM str_1.
          VIEW STREAM str_1 FRAME f_label.

       END.
           
    DISP STREAM str_1 tt-grupo.cdagenci   
                      tt-grupo.nrdgrupo  
                      tt-grupo.nrctasoc   
                      tt-grupo.dsdrisco   
                      tt-grupo.vlendivi   
                      tt-grupo.dsdrisgp   
                      tt-grupo.vlendigp   
                      WITH FRAME f_grupo_economico.
    
    DOWN STREAM str_1 WITH FRAME f_grupo_economico.
    
    IF LAST-OF(tt-grupo.nrdgrupo) THEN
       PUT STREAM str_1 SKIP(1).

END.

OUTPUT STREAM str_1 CLOSE.

IF NOT VALID-HANDLE(h-b1wgen0024) THEN
   RUN sistema/generico/procedures/b1wgen0024.p 
       PERSISTENT SET h-b1wgen0024.

RUN gera-arquivo-intranet IN h-b1wgen0024(INPUT crapcop.cdcooper,
                                          INPUT 0,
                                          INPUT glb_dtmvtolt,
                                          INPUT aux_nmarquiv,
                                          INPUT "132col",
                                          OUTPUT TABLE tt-erro).

IF VALID-HANDLE(h-b1wgen0024) THEN
   DELETE OBJECT h-b1wgen0024.
  
IF RETURN-VALUE <> "OK" THEN
   DO:
      IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
         ASSIGN glb_dscritic = "Nao foi possivel gerar o arquivo " + 
                               "para a intranet - "                + 
                               crapcop.nmrescop.
      ELSE
         DO: 
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            ASSIGN glb_dscritic = tt-erro.dscritic + " - " + 
                                  crapcop.nmrescop.

         END.

      UNIX SILENT VALUE("echo "                           +
                        " " + STRING(TIME,"HH:MM:SS")     +
                        " - " + glb_cdprogra + "' --> '" +
                        glb_dscritic + " >> log/proc_batch.log").

   END.

     
UNIX SILENT VALUE("echo "                                +
                  " " + STRING(TIME,"HH:MM:SS")          +
                  " - " + glb_cdprogra + "' --> '"       +
                  "Grupo Economico formado com sucesso." + 
                  " >> log/proc_batch.log").



/* .......................................................................... */







