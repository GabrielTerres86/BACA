/*.............................................................................

   Programa: Fontes/versol.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : HENRIQUE
   Data    : AGOSTO/2010                     Ultima Atualizacao: 02/03/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar quais cooperativas solicitaram o processo diario.
   
   Alteracoes: 02/03/2015 - Alterado tamanho do formulário f_versol para 68 
                           (Kelvin - 259786)        
  
..............................................................................*/

{ includes/var_online.i }
  
DEF TEMP-TABLE aux_versol NO-UNDO
    FIELD cdcooper LIKE crapcop.cdcooper COLUMN-LABEL "Cod."
    FIELD nmrescop LIKE crapcop.nmrescop COLUMN-LABEL "Cooperativa"
    FIELD dtmvtolt LIKE crapdat.dtmvtolt
    FIELD flproces AS LOGICAL FORMAT "Solicitado/Nao solicitado" COLUMN-LABEL "Status". 

DEF QUERY versol-q FOR aux_versol.

DEF BROWSE versol-b QUERY versol-q
    DISP aux_versol.cdcooper 
         aux_versol.nmrescop 
         aux_versol.dtmvtolt
         aux_versol.flproces
    WITH 09 DOWN NO-BOX.

FORM SPACE (1) 
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE " Consulta de Solicitacao de Processo " FRAME f_moldura.

VIEW FRAME f_moldura.

PAUSE(0).

FORM versol-b
    HELP "Tecle ENTER para atualizar e <F4> para sair"
    WITH  ROW 6 OVERLAY WIDTH 68 CENTERED FRAME f_versol.

DO WHILE TRUE:

    RUN fontes/inicia.p.
    
    EMPTY TEMP-TABLE aux_versol.

    FOR EACH crapdat NO-LOCK,
        EACH crapcop WHERE crapcop.cdcooper = crapdat.cdcooper.
        create aux_versol.
        assign aux_versol.cdcooper = crapcop.cdcooper
               aux_versol.nmrescop = crapcop.nmrescop
               aux_versol.dtmvtolt = crapdat.dtmvtolt.           
        IF crapdat.inproces = 1 THEN
           aux_versol.flproces = NO.
           ELSE
            aux_versol.flproces = YES.
    END. /* END for each */

    OPEN QUERY versol-q FOR EACH aux_versol.

    ENABLE versol-b WITH FRAME f_versol. 

    WAIT-FOR RETURN, END-ERROR OF versol-b.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN     /*   F4 OU FIM   */
            DO:
               RUN fontes/novatela.p.
               IF  CAPS(glb_nmdatela) <> "VERSOL"  THEN
                   DO:
                      HIDE FRAME f_versol.
                      HIDE FRAME f_moldura.
                      RETURN.
                   END.
            END.    
END. /* END WHILE TRUE */
/*............................................................................*/
