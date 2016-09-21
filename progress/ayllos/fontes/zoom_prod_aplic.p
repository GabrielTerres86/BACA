/*.............................................................................

   Programa: fontes/zoom_prod_aplic.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Jean Michel
   Data    : 13/10/2014                         Ultima alteracao:   /  /

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Zoom para seleção de produtos de aplicações da tela de BLQRGT
               referente ao campo tipo, a listagem contem produtos novos e
               antigos.
   
   Alteracoes: 
   
 ........................................................................... */

    { sistema/generico/includes/b1wgen0148tt.i }
    { sistema/generico/includes/var_internet.i }
    
    DEF  INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE NO-UNDO.
    
    DEF OUTPUT PARAM par_cdprodut AS INTE NO-UNDO.
    DEF OUTPUT PARAM par_nmprodut AS CHAR NO-UNDO.
    DEF OUTPUT PARAM par_idtipapl AS CHAR NO-UNDO.
    
    DEF VAR h-b1wgen0148 AS HANDLE       NO-UNDO.
    
    DEF QUERY  q_crapcpc FOR tt-crapcpc.
    
    DEF BROWSE b_crapcpc QUERY q_crapcpc
          DISP tt-crapcpc.nmprodut COLUMN-LABEL "Nome" FORMAT "x(50)"
               WITH CENTERED WIDTH 50 7 DOWN OVERLAY TITLE " Aplicacao ".
    
    FORM b_crapcpc HELP "Pressione ENTER para selecionar ou F4 para sair."
              WITH NO-BOX CENTERED OVERLAY ROW 10 FRAME f_crapcpc.
    
    EMPTY TEMP-TABLE tt-crapcpc.
    
    /* Consulta os produtos de aplicacoes cadastradas */
    
    RUN sistema/generico/procedures/b1wgen0148.p 
        PERSISTENT SET h-b1wgen0148.
    
    RUN carrega-apl-blqrgt IN h-b1wgen0148(INPUT par_cdcooper,
                                          OUTPUT TABLE tt-crapcpc).
    
    DELETE PROCEDURE h-b1wgen0148.
    
    /* Fim consulta os produtos de aplicacoes cadastradas */
    
    ON  END-ERROR OF b_crapcpc
        DO:
            HIDE FRAME f_crapcpc.
        END.
    
    ON RETURN OF b_crapcpc
      DO:
          IF AVAIL tt-crapcpc THEN
            DO:
              ASSIGN par_cdprodut = INTEGER(tt-crapcpc.cdprodut)
                     par_nmprodut = tt-crapcpc.nmprodut
                     par_idtipapl = tt-crapcpc.idtipapl.
              CLOSE QUERY q_crapcpc.
    
              APPLY "END-ERROR" TO b_crapcpc.
            END.
      END.
       
    OPEN QUERY q_crapcpc FOR EACH tt-crapcpc NO-LOCK.
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE :
        UPDATE b_crapcpc WITH FRAME f_crapcpc.
        LEAVE.
    END.
    
    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        DO:
            HIDE FRAME f_crapcpc NO-PAUSE.
    
            CLOSE QUERY q_crapcpc.
        END.

/* ......................................................................... */
