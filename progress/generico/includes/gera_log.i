/*..............................................................................

   Programa: gera_log.i                   
   Autor   : David
   Data    : Novembro/2007                      Ultima atualizacao: 22/08/2011

   Dados referentes ao programa:

   Objetivo  : Include para geracao de log      

   Alteracoes: 19/04/2010 - Criar procedure proc_gerar_log_tab (Jose Luis/DB1)
   
               22/08/2011 - Alterar parametro cdoperad para CHAR na procedure
                            proc_gerar_log_tab (David).
 
..............................................................................*/


DEF VAR h-b1wgen0014 AS HANDLE                                         NO-UNDO.


PROCEDURE proc_gerar_log:
    
    DEF  INPUT PARAM par_cdcooper LIKE craplgm.cdcooper             NO-UNDO.
    DEF  INPUT PARAM par_cdoperad LIKE craplgm.cdoperad             NO-UNDO.
    DEF  INPUT PARAM par_dscritic LIKE craplgm.dscritic             NO-UNDO.
    DEF  INPUT PARAM par_dsorigem LIKE craplgm.dsorigem             NO-UNDO.
    DEF  INPUT PARAM par_dstransa LIKE craplgm.dstransa             NO-UNDO.
    DEF  INPUT PARAM par_flgtrans LIKE craplgm.flgtrans             NO-UNDO.
    DEF  INPUT PARAM par_idseqttl LIKE craplgm.idseqttl             NO-UNDO.
    DEF  INPUT PARAM par_nmdatela LIKE craplgm.nmdatela             NO-UNDO.
    DEF  INPUT PARAM par_nrdconta LIKE craplgm.nrdconta             NO-UNDO.
    DEF OUTPUT PARAM par_nrdrowid AS ROWID                          NO-UNDO.
    
    RUN sistema/generico/procedures/b1wgen0014.p PERSISTENT
        SET h-b1wgen0014.
        
    IF  VALID-HANDLE(h-b1wgen0014)  THEN
        DO:
            RUN gera_log IN h-b1wgen0014 (INPUT par_cdcooper,
                                          INPUT par_cdoperad,
                                          INPUT par_dscritic,
                                          INPUT par_dsorigem,
                                          INPUT par_dstransa,
                                          INPUT TODAY,
                                          INPUT par_flgtrans,
                                          INPUT TIME,
                                          INPUT par_idseqttl,
                                          INPUT par_nmdatela,
                                          INPUT par_nrdconta,
                                         OUTPUT par_nrdrowid).
            
            DELETE PROCEDURE h-b1wgen0014.
        END.
        
END PROCEDURE.


PROCEDURE proc_gerar_log_item:

    DEF  INPUT PARAM par_nrdrowid AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_nmdcampo LIKE craplgi.nmdcampo             NO-UNDO.
    DEF  INPUT PARAM par_dsdadant LIKE craplgi.dsdadant             NO-UNDO.
    DEF  INPUT PARAM par_dsdadatu LIKE craplgi.dsdadatu             NO-UNDO.

    RUN sistema/generico/procedures/b1wgen0014.p PERSISTENT
        SET h-b1wgen0014.
        
    IF  VALID-HANDLE(h-b1wgen0014)  THEN
        DO:
            RUN gera_log_item IN h-b1wgen0014 (INPUT par_nrdrowid,
                                               INPUT par_nmdcampo,
                                               INPUT par_dsdadant,
                                               INPUT par_dsdadatu).
            
            DELETE PROCEDURE h-b1wgen0014.
        END.
             
END PROCEDURE.

PROCEDURE proc_gerar_log_tab:
/*.............................................................................

    Programa  : gravalog.p
    Autor     : Jose Luis Marchezoni, DB1
    Data      : Abril/2010                  Ultima Atualizacao: 31/03/2010

    Dados referentes ao programa:

    Objetivo  : Gerar LOG de alteracao - generico p/ qualquer campo e tabela

    Obervacao : OPERACAO = Alteracao:
                Enviar p/parametro 2 temp-table's (LIKE) da tabela em questao
                h1 = gerar temp-table antes de efetivar as alteracoes
                h2 = temp-table como os dados alterados
                OPERACAO = Exclusao:
                create tt-tabela-ant. buffer-copy tabela to tt-tabela-ant.
                create tt-tabela-atl. nao usar buffer-copy, tab.deve ser vazia
                par_flgerite = NO, p/ nao gerar log dos itens.
                OPERACAO = Inclusao:
                create tt-tabela-ant. nao usar buffer-copy, tab.deve ser vazia
                create tt-tabela-atl. buffer-copy tabela to tt-tabela-atl.
                par_flgerite = NO, p/ nao gerar log dos itens.

    Alteracoes: 20/04/2010 - Contemplar array/extent (Jose Luis)

.............................................................................*/

DEFINE INPUT  PARAMETER par_cdcooper LIKE craplgm.cdcooper     NO-UNDO.
DEFINE INPUT  PARAMETER par_cdoperad LIKE craplgm.cdoperad     NO-UNDO.
DEFINE INPUT  PARAMETER par_dscritic LIKE craplgm.dscritic     NO-UNDO.
DEFINE INPUT  PARAMETER par_dsorigem LIKE craplgm.dsorigem     NO-UNDO.
DEFINE INPUT  PARAMETER par_dstransa LIKE craplgm.dstransa     NO-UNDO.
DEFINE INPUT  PARAMETER par_flgerlog AS LOGICAL                NO-UNDO.
DEFINE INPUT  PARAMETER par_idseqttl LIKE craplgm.idseqttl     NO-UNDO.
DEFINE INPUT  PARAMETER par_nmdatela LIKE craplgm.nmdatela     NO-UNDO.
DEFINE INPUT  PARAMETER par_nrdconta LIKE craplgm.nrdconta     NO-UNDO.
DEFINE INPUT  PARAMETER par_flgerite AS LOGICAL                NO-UNDO.
DEFINE INPUT  PARAMETER hBuffer1     AS HANDLE  /* old */      NO-UNDO. 
DEFINE INPUT  PARAMETER hBuffer2     AS HANDLE  /* new */      NO-UNDO. 

DEFINE VARIABLE aux_nrdrowid AS ROWID       NO-UNDO.
DEFINE VARIABLE aux_campo    AS INTEGER     NO-UNDO.
DEFINE VARIABLE aux_ext      AS INTEGER     NO-UNDO.
DEFINE VARIABLE aux_campoant AS CHARACTER   NO-UNDO.
DEFINE VARIABLE aux_campoatl AS CHARACTER   NO-UNDO.
DEFINE VARIABLE hQuery1      AS HANDLE      NO-UNDO.
DEFINE VARIABLE hQuery2      AS HANDLE      NO-UNDO.

&SCOPED-DEFINE FORM-CAMPO hBuffer2:BUFFER-FIELD(aux_campo):FORMAT

GRAVALOG: DO ON ERROR UNDO GRAVALOG, LEAVE GRAVALOG:
  /* gerar log principal */
  RUN proc_gerar_log 
      (INPUT par_cdcooper,
       INPUT par_cdoperad,
       INPUT par_dscritic,
       INPUT par_dsorigem,
       INPUT par_dstransa,
       INPUT par_flgerlog,
       INPUT par_idseqttl,
       INPUT par_nmdatela,
       INPUT par_nrdconta,
      OUTPUT aux_nrdrowid).

  /* percorrer todos os campos da tabela se indica geracao dos itens */
  IF  NOT par_flgerite THEN
      LEAVE GRAVALOG.

  CREATE QUERY hQuery1. 
  hQuery1:SET-BUFFERS(hBuffer1).
  hQuery1:GET-FIRST(NO-LOCK) NO-ERROR.
  /* não houve alteração, operacao de inclusao */
  IF  NOT hBuffer1:AVAILABLE THEN
      LEAVE GRAVALOG.

  CREATE QUERY hQuery2. 
  hQuery2:SET-BUFFERS(hBuffer2).
  hQuery2:GET-FIRST(NO-LOCK) NO-ERROR.
  IF  NOT hBuffer2:AVAILABLE THEN
      LEAVE GRAVALOG.

  /* verificar se houver efetiva alteração - anterior x atual */
  IF  hBuffer1:BUFFER-COMPARE(hBuffer2,"binary","","",YES) THEN
      LEAVE GRAVALOG.

  DO  aux_campo = 1 TO hBuffer2:NUM-FIELDS:

      /* verificar se o campo eh extent/array */
      IF  hBuffer1:BUFFER-FIELD(aux_campo):EXTENT > 0 THEN
          DO:
             /* comparar os valores dos campos  */
             DO aux_ext = 1 TO hBuffer1:BUFFER-FIELD(aux_campo):EXTENT:
                IF  hBuffer1:BUFFER-FIELD(aux_campo):BUFFER-VALUE[aux_ext] <>
                    hBuffer2:BUFFER-FIELD(aux_campo):BUFFER-VALUE[aux_ext] THEN
                    DO:
                       ASSIGN
                           aux_campoant = ""
                           aux_campoatl = "".

                       CASE hBuffer2:BUFFER-FIELD(aux_campo):DATA-TYPE:
                           WHEN "logical" THEN DO:
                               ASSIGN
                                   aux_campoant = STRING(LOGICAL(
                                      hBuffer1:BUFFER-FIELD
                                      (aux_campo):BUFFER-VALUE[aux_ext]),
                                                         {&FORM-CAMPO})
                                   aux_campoatl = STRING(LOGICAL(
                                      hBuffer2:BUFFER-FIELD
                                      (aux_campo):BUFFER-VALUE[aux_ext]),
                                                         {&FORM-CAMPO}).
                           END.
                           OTHERWISE DO:
                               ASSIGN
                                   aux_campoant = STRING(hBuffer1:BUFFER-FIELD
                                       (aux_campo):BUFFER-VALUE[aux_ext],
                                                         {&FORM-CAMPO})
                                   aux_campoatl = STRING(hBuffer2:BUFFER-FIELD
                                       (aux_campo):BUFFER-VALUE[aux_ext],
                                                         {&FORM-CAMPO}).
    
                               IF  hBuffer2:BUFFER-FIELD
                                   (aux_campo):DATA-TYPE = "date" 
                                   THEN 
                                   DO:
                                      IF  DATE(aux_campoant) = ? THEN
                                          ASSIGN aux_campoant = "".
    
                                      IF  DATE(aux_campoatl) = ? THEN
                                          ASSIGN aux_campoatl = "".
                                   END.
                           END.
                       END CASE.

                       /* gerar log dos itens */
                       RUN proc_gerar_log_item
                           ( INPUT aux_nrdrowid,
                             INPUT hBuffer2:BUFFER-FIELD(aux_campo):NAME +
                                   "[" + TRIM(STRING(aux_ext),">>9") + "] ",
                             INPUT TRIM(aux_campoant),
                             INPUT TRIM(aux_campoatl)).
                    END.
             END.
          END.
      ELSE 
      /* comparar os valores dos campos  */
      IF  hBuffer1:BUFFER-FIELD(aux_campo):BUFFER-VALUE <>
          hBuffer2:BUFFER-FIELD(aux_campo):BUFFER-VALUE THEN
          DO:
             CASE hBuffer2:BUFFER-FIELD(aux_campo):DATA-TYPE:
                 WHEN "logical" THEN DO:
                     ASSIGN
                         aux_campoant = STRING(LOGICAL
                                               (hBuffer1:BUFFER-FIELD
                                                (aux_campo):BUFFER-VALUE),
                                                {&FORM-CAMPO})
                         aux_campoatl = STRING(LOGICAL
                                               (hBuffer2:BUFFER-FIELD
                                                (aux_campo):BUFFER-VALUE),
                                                {&FORM-CAMPO}).
                 END.
                 OTHERWISE DO:
                     ASSIGN
                         aux_campoant = STRING(hBuffer1:BUFFER-FIELD
                                               (aux_campo):BUFFER-VALUE,
                                               {&FORM-CAMPO})
                         aux_campoatl = STRING(hBuffer2:BUFFER-FIELD
                                               (aux_campo):BUFFER-VALUE,
                                               {&FORM-CAMPO}).

                     IF  hBuffer2:BUFFER-FIELD(aux_campo):DATA-TYPE = "date" 
                         THEN 
                         DO:
                            IF  DATE(aux_campoant) = ? THEN
                                ASSIGN aux_campoant = "".

                            IF  DATE(aux_campoatl) = ? THEN
                                ASSIGN aux_campoatl = "".
                         END.
                 END.
             END CASE.

             /* gerar log dos itens */
             RUN proc_gerar_log_item
                 ( INPUT aux_nrdrowid,
                   INPUT hBuffer2:BUFFER-FIELD(aux_campo):NAME,
                   INPUT TRIM(aux_campoant),
                   INPUT TRIM(aux_campoatl)).
          END.
  END.

END.

END PROCEDURE.

/*...........................................................................*/
