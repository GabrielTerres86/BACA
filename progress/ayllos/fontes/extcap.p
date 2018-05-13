/* .............................................................................

   Programa: Fontes/extcap.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Setembro/92.                        Ultima atualizacao: 12/11/2013
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela EXTCAP.

   Alteracao : 16/03/95 - Alterado para incluir na tela tipo de emissao por real
                          ou por ufir.

               26/03/98 - Tratamento para milenio e troca para V8 (Margarete).

               08/11/00 - Alterar nrdolote p/6 posicoes (Margarete/Planner).
               
               31/01/2005 - Modificados os termos "Agencia" ou "Ag" por "PAC"
                            (Evandro).

               26/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando

               13/05/2008 - Ajuste comando FIND(craphis) utilizava FOR p/ acesso
                            (Sidnei - Precise)
                            
               14/02/2010 - Alterado para montar o extrato utilizando 
                            a BO 21 (Henrique).
               
               21/02/2011 - Ajuste no layout da tela (Henrique).
               
               25/08/2011 - Adaptado para uso de BO (Gabriel Capoia - DB1).
               
               03/06/2013 - Busca Saldo Bloqueio Judicial
                           (Andre Santos - SUPERO)
               
               12/11/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (Guilherme Gielow)
            
............................................................................. */

{ sistema/generico/includes/b1wgen0103tt.i }
{ sistema/generico/includes/var_internet.i }

{ includes/var_online.i }

DEF        VAR tel_nrdconta AS INT     FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF        VAR tel_nmprimtl AS CHAR    FORMAT "x(40)"                NO-UNDO.
DEF        VAR tel_dtmovmto AS INT     FORMAT "zzz9"                 NO-UNDO.
DEF        VAR tel_vlsldant AS CHAR    FORMAT "x(18)"                NO-UNDO.
DEF        VAR tel_vlsldtot AS CHAR    FORMAT "x(18)"                NO-UNDO.
DEF        VAR tel_vlblqjud LIKE crapblj.vlbloque                    NO-UNDO.

DEF        VAR aux_vlblqjud AS DECI                                  NO-UNDO.
DEF        VAR aux_vlresblq AS DECI                                  NO-UNDO.

DEF        VAR aux_vlsldtot AS DEC     FORMAT "z,zzz,zz9.9999-"      NO-UNDO.
DEF        VAR aux_nrdconta AS INT     FORMAT "zzz,zzz,9"            NO-UNDO.
DEF        VAR aux_contador AS INT     FORMAT "99"                   NO-UNDO.
DEF        VAR aux_regexist AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgretor AS LOGICAL                               NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.

DEF        VAR aux_vlsldant AS DECI                                  NO-UNDO.
DEF        VAR aux_qtregist AS INTE                                  NO-UNDO.

DEF        VAR h-b1wgen0103 AS HANDLE                                NO-UNDO.
DEF        VAR h-b1wgen0155 AS HANDLE                                NO-UNDO.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM tel_nrdconta AT  2 LABEL "Conta/dv" AUTO-RETURN
                        HELP "Informe o numero da conta ou <F7> para pesquisar"

     tel_nmprimtl AT 29 LABEL "Titular"
     SKIP(1)
     WITH ROW 6 COLUMN 2 OVERLAY NO-BOX SIDE-LABELS FRAME f_extcap.

FORM tel_dtmovmto AT 2  LABEL "A partir do ano" AUTO-RETURN
                        HELP "Entre com o ano desejado."
     tel_vlsldant AT 45 LABEL "Saldo Anterior"
     SKIP(1)
 "   Data    PA  Bcx    Lote Historico         Documento"
 "  Contrato        Valor"
    WITH ROW 8 COLUMN 2 OVERLAY NO-BOX SIDE-LABELS FRAME f_tipo.

FORM tt-ext_cotas.dtmvtolt AT  1  FORMAT "99/99/9999"   
     tt-ext_cotas.cdagenci AT 12  FORMAT "zz9"   
     tt-ext_cotas.cdbccxlt AT 16  FORMAT "zz9"   
     tt-ext_cotas.nrdolote AT 20  FORMAT "zzz,zz9"  
     tt-ext_cotas.dshistor AT 28  FORMAT "x(15)"  
     tt-ext_cotas.indebcre AT 44  FORMAT "x(1)"  
     tt-ext_cotas.nrdocmto AT 46  FORMAT "zzzzzz,zz9"  
     tt-ext_cotas.nrctrpla AT 57  FORMAT "zzz,zzz"  
     tt-ext_cotas.vllanmto AT 64  FORMAT "zzzz,zzz,zz9.99"    
     WITH ROW 11 COLUMN 2 OVERLAY 9 DOWN NO-LABEL NO-BOX FRAME f_lanctos.

FORM tel_vlblqjud AT 01 LABEL "Valor Bloq. Judicial"
     tel_vlsldtot AT 54 LABEL "Saldo"
     WITH ROW 20 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_saldo.

VIEW FRAME f_moldura.                              
PAUSE(0).                                          
                                                   
VIEW FRAME f_extcap.                               
PAUSE (0).                                         
                                                   
VIEW FRAME f_tipo.                                 
PAUSE(0).

RUN fontes/inicia.p.
                                                     
ASSIGN glb_cddopcao = "C"
       tel_dtmovmto = 0
       glb_cdcritic = 0.                             
                                                     
INICIO:                                              

DO WHILE TRUE:

    RUN conecta_handle.

    CLEAR FRAME f_extcap .
    CLEAR FRAME f_tipo.
    HIDE  FRAME f_saldo.
    CLEAR FRAME f_lanctos ALL NO-PAUSE.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        UPDATE tel_nrdconta WITH FRAME f_extcap
        EDITING:
            READKEY.
            IF  FRAME-FIELD = "tel_nrdconta"   AND
                LASTKEY = KEYCODE("F7")        THEN
                DO: 
                    RUN fontes/zoom_associados.p (INPUT  glb_cdcooper,
                                                  OUTPUT aux_nrdconta).
       
                    IF  aux_nrdconta > 0   THEN
                        DO:
                            ASSIGN tel_nrdconta = aux_nrdconta.
                            DISPLAY tel_nrdconta WITH FRAME f_extppr.
                            PAUSE 0.
                            APPLY "RETURN".
                        END.
                END.
            ELSE
                APPLY LASTKEY.

        END.  /*  Fim do EDITING  */

        RUN Busca_Dados.

        IF  RETURN-VALUE <> "OK" THEN
            NEXT.

        DO WHILE TRUE ON ENDKEY UNDO, NEXT INICIO:

            UPDATE tel_dtmovmto WITH FRAME f_tipo.

            LEAVE.

        END.

        LEAVE.

    END.  /*  Fim do DO WHILE TRUE  */

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
        DO:
            RUN fontes/novatela.p.
            IF  glb_nmdatela <> "EXTCAP" THEN
                DO:
                    IF  VALID-HANDLE(h-b1wgen0103) THEN
                        DELETE OBJECT h-b1wgen0103.

                    HIDE FRAME f_extcap.
                    HIDE FRAME f_tipo.
                    HIDE FRAME f_lanctos.
                    HIDE FRAME f_saldo.
                    HIDE FRAME f_moldura.
                    RETURN.
                END.
            ELSE
                NEXT.
        END.

    IF  aux_cddopcao <> glb_cddopcao THEN
        DO:
            { includes/acesso.i }
            ASSIGN aux_cddopcao = glb_cddopcao.
        END.

    /*  Inicio da consistencia da data de pesquisa do movimento  */
    IF  tel_dtmovmto = 0  THEN
        DO:
            ASSIGN tel_dtmovmto = YEAR(glb_dtmvtolt).
            DISPLAY tel_dtmovmto WITH FRAME f_tipo.
        END.
        
    RUN Busca_Extrato.

    CLEAR FRAME f_lanctos ALL NO-PAUSE.
    CLEAR FRAME f_saldo.

    ASSIGN aux_flgretor = FALSE
           aux_regexist = FALSE
           tel_dtmovmto = 0
           aux_contador = 0
           aux_vlblqjud = 0
           aux_vlresblq = 0.

    /*** Busca Saldo Bloqueado Judicial ***/
    RUN sistema/generico/procedures/b1wgen0155.p 
                   PERSISTENT SET h-b1wgen0155.

    RUN retorna-valor-blqjud IN h-b1wgen0155(INPUT glb_cdcooper,
                                             INPUT tel_nrdconta,
                                             INPUT 0, /* fixo - nrcpfcgc */
                                             INPUT 3, /* Bloq. Capital   */
                                             INPUT 4, /* 4 - CAPITAL     */
                                             INPUT glb_dtmvtolt,
                                             OUTPUT aux_vlblqjud,
                                             OUTPUT aux_vlresblq).

    DELETE PROCEDURE h-b1wgen0155.
    /*** Fim Busca Saldo Bloqueado Judicial ***/

    FOR EACH tt-ext_cotas NO-LOCK:

        ASSIGN aux_regexist = TRUE                
               aux_contador = aux_contador + 1.                      
        
        IF  aux_contador = 9  THEN                     
            DO:                                         
                ASSIGN aux_contador = 0                 
                       aux_flgretor = TRUE
                       tel_vlsldant = STRING(tt-ext_cotas.vlsldtot).
            END.

        DISPLAY tt-ext_cotas.dtmvtolt                                              
                tt-ext_cotas.cdagenci                                              
                tt-ext_cotas.cdbccxlt                                              
                tt-ext_cotas.nrdolote                                                   
                tt-ext_cotas.dshistor                                               
                tt-ext_cotas.indebcre                                               
                tt-ext_cotas.nrdocmto                                               
                tt-ext_cotas.nrctrpla                                               
                tt-ext_cotas.vllanmto                                              
                WITH FRAME f_lanctos.

        IF  aux_flgretor THEN
            IF  aux_contador = 1 THEN
                DO:
                    DISPLAY  tel_vlsldant  WITH FRAME f_tipo.
                    ASSIGN aux_flgretor = FALSE.
                END.

        DISPLAY aux_vlblqjud @ tel_vlblqjud
                tt-ext_cotas.vlsldtot @ tel_vlsldtot WITH FRAME f_saldo.

        IF  aux_contador < 9 THEN
            DOWN WITH FRAME f_lanctos.

    END. /* Fim do FOR EACH */

    PAUSE MESSAGE "Tecle qualquer tecla para continuar.".

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
        DO:
            CLEAR FRAME f_extcap .
            CLEAR FRAME f_tipo.
            HIDE  FRAME f_saldo.
            CLEAR FRAME f_lanctos ALL NO-PAUSE.
            NEXT-PROMPT tel_nrdconta WITH FRAME f_extcap.
        END.
      
    PAUSE(0).

END. /* Fim do DO */

RUN desconecta_handle.

/* .......................................................................... */

PROCEDURE Busca_Dados:

    EMPTY TEMP-TABLE tt-infoass.
    EMPTY TEMP-TABLE tt-erro.

    RUN conecta_handle.
    
    RUN Busca_Extcap IN h-b1wgen0103
        ( INPUT glb_cdcooper,
          INPUT 0,           
          INPUT 0,           
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT 1,           
          INPUT tel_nrdconta,
          INPUT YES,
         OUTPUT TABLE tt-infoass,
         OUTPUT TABLE tt-erro).
    
    FIND FIRST tt-infoass NO-ERROR.

    IF  AVAILABLE tt-infoass THEN
        ASSIGN tel_nrdconta = tt-infoass.nrdconta
               tel_nmprimtl = tt-infoass.nmprimtl.

    CLEAR FRAME f_extcap NO-PAUSE.

    DISPLAY tel_nrdconta tel_nmprimtl WITH FRAME f_extcap.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.
                   
            RETURN "NOK".  
        END.
    
    RETURN "OK".

END PROCEDURE. /* Busca_Dados */

PROCEDURE Busca_Extrato:

    EMPTY TEMP-TABLE tt-infoass.
    EMPTY TEMP-TABLE tt-erro.

    RUN conecta_handle.
    
    RUN Busca_Extrato_Cotas IN h-b1wgen0103
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT 1,
          INPUT glb_dtmvtolt,
          INPUT tel_nrdconta,
          INPUT tel_dtmovmto,
          INPUT 0,
          INPUT 0,
          INPUT TRUE, /* flgerlog */
         OUTPUT tel_vlsldant,
         OUTPUT aux_vlsldtot,
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-ext_cotas,
         OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.
                   
            RETURN "NOK".  
        END.

    DISPLAY  tel_vlsldant  WITH FRAME f_tipo.
    
    RETURN "OK".

END PROCEDURE. /* Busca_Extrato */

PROCEDURE conecta_handle:

    IF  NOT VALID-HANDLE(h-b1wgen0103) THEN
        RUN sistema/generico/procedures/b1wgen0103.p
            PERSISTENT SET h-b1wgen0103.

END PROCEDURE.

PROCEDURE desconecta_handle:

    IF  VALID-HANDLE(h-b1wgen0103) THEN
        DELETE OBJECT h-b1wgen0103.

END PROCEDURE.

/* .......................................................................... */
