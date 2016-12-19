/* .............................................................................

   Programa: fontes/impbol.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : GATI - Peixoto
   Data    : Julho/2009                        Ultima atualizacao: 02/12/2016 
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Importacao de arquivo de boletos.
   
   Alteracoes:  15/02/2011 - Critica para verificar cadastro na crapceb
                             (Gabriel).
                             
                30/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
   
                02/12/2014 - De acordo com a circula 3.656 do Banco Central, substituir nomenclaturas 
                             Cedente por Beneficiário e  Sacado por Pagador 
                             Chamado 229313 (Jean Reddiga - RKAM).    
                             
                24/03/2016 - Ajustes de permissao conforme solicitado no chamado 358761 (Kelvin).   
                
                02/12/2016 - Alterado campo dsdepart para cddepart.
                            PRJ341 - BANCENJUD (Odirlei-AMcom)
                           
............................................................................. */

{ includes/var_online.i } 

DEF STREAM str_1.

DEF VAR tel_dsdirpai AS CHAR FORMAT "x(20)"                            NO-UNDO.
DEF VAR tel_nmarqint AS CHAR FORMAT "x(44)"                            NO-UNDO.
DEF VAR tel_dsimprim AS CHAR FORMAT "x(8)" INIT "Imprimir"             NO-UNDO.
DEF VAR tel_dscancel AS CHAR FORMAT "x(8)" INIT "Cancelar"             NO-UNDO.

DEF VAR tel_vllanmto AS DECI FORMAT "zzz,zzz,zzz,zz9.99"               NO-UNDO.

DEF VAR tel_nrdconta AS INTE FORMAT "zzzz,zzz,9"                       NO-UNDO.
DEF VAR tel_nrcnvcob AS INTE FORMAT "zzzz,zz9"                         NO-UNDO.

DEF VAR tel_dtvencto AS DATE FORMAT "99/99/9999"                       NO-UNDO.

DEF VAR par_flgrodar AS LOGI INIT TRUE                                 NO-UNDO.
DEF VAR par_flgfirst AS LOGI                                           NO-UNDO.
DEF VAR par_flgcance AS LOGI                                           NO-UNDO.

DEF VAR aux_flgescra AS LOGI                                           NO-UNDO.

DEF VAR aux_contador AS INTE                                           NO-UNDO.
DEF VAR aux_qtrejeit AS INTE FORMAT "zzz,zzz,zz9"                      NO-UNDO.
DEF VAR aux_qtimport AS INTE FORMAT "zzz,zzz,zz9"                      NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_nrcnvcob AS INTE                                           NO-UNDO.
DEF VAR aux_nrcnvceb AS INTE                                           NO-UNDO.
DEF VAR aux_nrdocmto AS INTE                                           NO-UNDO.
    
DEF VAR aux_setlinha AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdsacad AS CHAR                                           NO-UNDO.
DEF VAR aux_nossonum AS CHAR                                           NO-UNDO.
DEF VAR aux_nmendter AS CHAR                                           NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqint AS CHAR FORMAT "x(44)"                            NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqdat AS CHAR                                           NO-UNDO.
DEF VAR aux_confirma AS CHAR FORMAT "!"                                NO-UNDO.

DEF VAR h-b1crapcob  AS HANDLE                                         NO-UNDO.

DEF TEMP-TABLE cratcob NO-UNDO LIKE crapcob.

DEF TEMP-TABLE tt-boleto NO-UNDO
    FIELD nmdsacad AS CHAR
    FIELD nossonum AS CHAR
    FIELD flgsuces AS LOGI
    FIELD dsmotivo AS CHAR.
    
DEF BUFFER bb-boleto FOR tt-boleto.    
    
DEF QUERY q_crapcco FOR crapcco.

DEF BROWSE b_crapcco QUERY q_crapcco 
    DISPLAY crapcco.nrconven COLUMN-LABEL "Convenio" 
            crapcco.nrdctabb COLUMN-LABEL "Conta Base"
            crapcco.cddbanco COLUMN-LABEL "Banco"
            WITH 6 DOWN OVERLAY NO-BOX.         

FORM SKIP(1)
     b_crapcco HELP "Use as SETAS para navegar ou F4 para sair" SKIP
     WITH ROW 7 COL 45 OVERLAY TITLE " Convenios " FRAME f_crapcco_b.

FORM SKIP(3)
     tel_nrdconta AT  5 LABEL "Conta"    
                  HELP "Entre com o numero da conta."
     tel_nrcnvcob AT 35 LABEL "Convenio" 
                  HELP "Informe o numero do convenio ou <F7> para listar."
     SKIP(1)
     tel_vllanmto AT  5 LABEL "Valor" 
                  HELP "Entre com o valor."
     tel_dtvencto AT 33 LABEL "Vencimento"
                  HELP "Entre com o vencimento."
     SKIP(1)
     tel_dsdirpai AT  3 LABEL "Arquivo"
     tel_nmarqint NO-LABEL 
                  HELP "Entre com o nome do arquivo"
     SKIP(4)
     WITH ROW 4 COLUMN 1 WIDTH 80 OVERLAY DOWN SIDE-LABELS 
          TITLE glb_tldatela FRAME f_impbol.
                             
FORM tt-boleto.nmdsacad FORMAT "x(45)" COLUMN-LABEL "Nome do Pagador"
     tt-boleto.nossonum FORMAT "x(17)" COLUMN-LABEL "Nosso Numero"
     WITH DOWN NO-BOX NO-ATTR-SPACE WIDTH 132 FRAME f_importados.
     
FORM tt-boleto.nmdsacad FORMAT "x(45)" COLUMN-LABEL "Nome do Pagador"
     tt-boleto.nossonum FORMAT "x(17)" COLUMN-LABEL "Nosso Numero"
     tt-boleto.dsmotivo FORMAT "x(50)" COLUMN-LABEL "Motivo" 
     WITH DOWN NO-BOX NO-ATTR-SPACE WIDTH 132 FRAME f_rejeitados.

FORM HEADER
     "IMPORTACAO DE ARQUIVOS DE BOLETOS"
     SKIP
     "ARQUIVO:"          
     aux_nmarqint        
     SKIP
     "CONTA:"            AT 01
     tel_nrdconta        AT 16
     "CONVENIO:"         AT 32
     tel_nrcnvcob        AT 45
     SKIP
     "VALOR:"            AT 01 
     tel_vllanmto        AT 08
     "VENCIMENTO:"       AT 30
     tel_dtvencto        AT 43
     SKIP(2)
     "IMPORTADOS: "      AT 01
     aux_qtimport        AT 14  
     SKIP
     "REJEITADOS: "      AT 01
     aux_qtrejeit        AT 14  
     SKIP(2)
     WITH NO-BOX PAGE-TOP SIDE-LABELS FRAME f_cab.

ON RETURN OF b_crapcco DO:

    ASSIGN tel_nrcnvcob = crapcco.nrconven.
    
    DISPLAY tel_nrcnvcob WITH FRAME f_impbol.
    
    APPLY "GO".
    
END.

VIEW FRAME f_impbol.

PAUSE(0). 

RUN fontes/inicia.p.

ASSIGN glb_cddopcao = "L"
       glb_cdcritic = 0.

FIND FIRST crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF  NOT AVAILABLE crapcop  THEN
    DO:
        ASSIGN glb_cdcritic = 651.
        RUN fontes/critic.p.
        ASSIGN glb_cdcritic = 0
               glb_nmdatela = "MENU00".
        BELL.
        MESSAGE glb_dscritic.
        PAUSE 3 NO-MESSAGE.
        HIDE FRAME f_impbol NO-PAUSE.
        RETURN.
    END.
IF  glb_cddepart <> 20  AND  /* TI       */
    glb_cddepart <> 14  THEN /* PRODUTOS */
    DO:
        ASSIGN glb_cdcritic = 36.
        RUN fontes/critic.p.
        ASSIGN glb_cdcritic = 0
               glb_nmdatela = "MENU00".
        BELL.
        MESSAGE glb_dscritic.
        PAUSE 3 NO-MESSAGE.
        HIDE FRAME f_impbol NO-PAUSE.
        RETURN.
    END.
                            
ASSIGN tel_dsdirpai = "/micros/" + crapcop.dsdircop + "/".

DO WHILE TRUE:

    EMPTY TEMP-TABLE tt-boleto.
    EMPTY TEMP-TABLE cratcob.
    
    DISPLAY tel_nrdconta tel_nrcnvcob tel_vllanmto tel_dtvencto 
            tel_dsdirpai tel_nmarqint WITH FRAME f_impbol.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
        UPDATE tel_nrdconta tel_nrcnvcob WITH FRAME f_impbol
        
        EDITING:
            
            READKEY.
       
            IF  FRAME-FIELD = "tel_nrcnvcob"  THEN
                DO:
                    IF  LASTKEY = KEYCODE("F7")  THEN
                        DO:
                            RUN proc_query.
                            HIDE FRAME f_crapcco_b.
                        END.
                    ELSE
                        APPLY LASTKEY.
                END.
            ELSE 
                APPLY LASTKEY.
             
        END.
        
        FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                           crapass.nrdconta = tel_nrdconta NO-LOCK NO-ERROR.
        
        IF  NOT AVAILABLE crapass  THEN
            DO:
                ASSIGN glb_cdcritic = 9.
                RUN fontes/critic.p.
                ASSIGN glb_cdcritic = 0.
                BELL.
                MESSAGE glb_dscritic.
                NEXT-PROMPT tel_nrdconta WITH FRAME f_impbol.
                NEXT.
            END.
        
        FIND crapcco WHERE crapcco.cdcooper = glb_cdcooper AND
                           crapcco.nrconven = tel_nrcnvcob NO-LOCK NO-ERROR.
                           
        IF  NOT AVAILABLE crapcco  THEN
            DO:
                ASSIGN glb_cdcritic = 563.
                RUN fontes/critic.p.
                ASSIGN glb_cdcritic = 0.
                BELL.
                MESSAGE glb_dscritic.
                NEXT-PROMPT tel_nrcnvcob WITH FRAME f_impbol.
                NEXT.
            END.

        FIND crapceb WHERE crapceb.cdcooper = crapcco.cdcooper AND
                           crapceb.nrdconta = tel_nrdconta     AND
                           crapceb.nrconven = crapcco.nrconven 
                           NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE crapceb  THEN
            DO:
                MESSAGE "Cooperado nao possui cadastro de cobranca. Verifique tela ATENDA.".
                NEXT.
            END.               
        
        IF  crapceb.insitceb <> 1  THEN
            DO:
                MESSAGE "Cadastro de cobranca inativo. Verifique tela ATENDA.".
                NEXT.
            END.

        LEAVE.
        
    END. /** Fim do DO WHILE TRUE **/      

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN    
        DO: 
            RUN fontes/novatela.p.
            
            IF  CAPS(glb_nmdatela) <> "IMPBOL"  THEN
                DO:
                    HIDE FRAME f_impbol.
                    RETURN.               
                END.
            ELSE
                NEXT.
        END.
        
    { includes/acesso.i }
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
        UPDATE tel_vllanmto tel_dtvencto tel_nmarqint WITH FRAME f_impbol.

        IF  tel_vllanmto = 0  THEN 
            DO:
                ASSIGN glb_cdcritic = 269.
                RUN fontes/critic.p.
                ASSIGN glb_cdcritic = 0.
                BELL.
                MESSAGE glb_dscritic.
                NEXT-PROMPT tel_vllanmto WITH FRAME f_impbol.     
                NEXT.
            END.
   
        IF  tel_dtvencto = ?  THEN 
            DO:
                ASSIGN glb_cdcritic = 13.
                RUN fontes/critic.p.
                ASSIGN glb_cdcritic = 0.
                BELL.
                MESSAGE glb_dscritic.
                NEXT-PROMPT tel_dtvencto WITH FRAME f_impbol.           
                NEXT.
            END.
            
        IF  tel_dtvencto < glb_dtmvtolt  THEN
            DO:
                BELL.
                MESSAGE "Vencimento menor que a data corrente.".
                NEXT-PROMPT tel_dtvencto WITH FRAME f_impbol.
                NEXT.
            END.    
   
        IF  SEARCH(tel_dsdirpai + tel_nmarqint) = ?  THEN 
            DO:
                ASSIGN glb_cdcritic = 182.
                RUN fontes/critic.p.
                ASSIGN glb_cdcritic = 0.
                BELL.
                MESSAGE glb_dscritic.
                NEXT-PROMPT tel_nmarqint WITH FRAME f_impbol.
                NEXT.
            END.
            
        IF  tel_dtvencto > (glb_dtmvtolt + 365)  THEN
            DO:
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    
                    ASSIGN aux_confirma = "N".
                    MESSAGE COLOR NORMAL 
                            "O vencimento supera em mais de um ano a data " +
                            "atual. Confirma (S/N)?" 
                            UPDATE aux_confirma.
                    LEAVE.
                    
                END.            

                IF  aux_confirma <> "S"                 OR
                    KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                    DO:
                        NEXT-PROMPT tel_dtvencto WITH FRAME f_impbol.
                        NEXT.
                    END.    
            END.    
            
        LEAVE.
                 
    END. /** Fim do DO WHILE TRUE **/
    
    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        NEXT.
     
    ASSIGN aux_nmarqint = tel_dsdirpai + tel_nmarqint
           aux_nmarqdat = STRING(DAY(glb_dtmvtolt),"99") +
                          STRING(MONTH(glb_dtmvtolt),"99") +
                          STRING(YEAR(glb_dtmvtolt),"9999") +
                          "_" + STRING(TIME) + "_" + glb_cdoperad + "_" +
                          SUBSTR(aux_nmarqint,R-INDEX(aux_nmarqint,"/") + 1). 

    UNIX SILENT VALUE("cp " + aux_nmarqint + " " + aux_nmarqint + "_ux" ).
    
    UNIX SILENT VALUE("rm " + aux_nmarqint).
    
    UNIX SILENT VALUE("dos2ux " + aux_nmarqint + "_ux" + " > " + aux_nmarqint).
    
    UNIX SILENT VALUE("rm " + aux_nmarqint + "_ux").
                  
    RUN pi-executa.

    IF  RETURN-VALUE = "NOK"  THEN
        NEXT.
                   
    IF  CAN-FIND(FIRST tt-boleto WHERE tt-boleto.flgsuces = TRUE)  THEN 
        UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999") + " " +
                          STRING(TIME,"HH:MM:SS") + "' --> '"  +
                          " Operador " + glb_cdoperad +
                          " importou boletos para a conta " +
                          STRING(tel_nrdconta,"zzzz,zzz,9") +
                          ", Convenio " + STRING(tel_nrcnvcob,"zzzz,zz9") +
                          ", Valor " + 
                          STRING(tel_vllanmto,"zzz,zzz,zzz,zz9.99") +
                          " e Vencimento " +
                          STRING(tel_dtvencto,"99/99/9999") +
                          " do arquivo " + aux_nmarqdat +
                          " >> log/impbol.log").          
    ELSE
        UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999") + " " +
                          STRING(TIME,"HH:MM:SS") + "' --> '"  +
                          " Operador " + glb_cdoperad +
                          " nao conseguiu importar boletos para a conta " +
                          STRING(tel_nrdconta,"zzzz,zzz,9") +
                          ", Convenio " + STRING(tel_nrcnvcob,"zzzz,zz9") +
                          ", Valor " +
                          STRING(tel_vllanmto,"zzz,zzz,zzz,zz9.99") +
                          " e Vencimento " +
                          STRING(tel_dtvencto,"99/99/9999") +
                          " do arquivo " + aux_nmarqdat +
                          " >> log/impbol.log").
                          
    UNIX SILENT VALUE("cp " + aux_nmarqint + " salvar/" + aux_nmarqdat).
        
    UNIX SILENT VALUE("rm " + aux_nmarqint + " 2> /dev/null").            

    ASSIGN glb_nrdevias = 1
           tel_nrdconta = 0
           tel_nrcnvcob = 0
           tel_dtvencto = ?
           tel_vllanmto = 0
           tel_nmarqint = "".
        
    { includes/impressao.i } 
   
END.

/* .......................................................................... */

PROCEDURE pi-executa:

    MESSAGE "Aguarde, importando boletos ...".

    INPUT STREAM str_1 FROM VALUE(aux_nmarqint) NO-ECHO.

    DO WHILE TRUE ON ERROR UNDO, RETURN ON ENDKEY UNDO, LEAVE:
        
        IMPORT STREAM str_1 UNFORMATTED aux_setlinha.
        
        IF  aux_setlinha = ""  THEN 
            NEXT.

        IF  NUM-ENTRIES(aux_setlinha,";") <> 2  THEN
            DO:
                HIDE MESSAGE NO-PAUSE.
                BELL.
                MESSAGE "Formato do arquivo nao e valido.".
                RETURN "NOK".
            END.    

        ASSIGN aux_nmdsacad = TRIM(CAPS(ENTRY(1,aux_setlinha,";")))
               aux_nossonum = TRIM(ENTRY(2,aux_setlinha,";")).
               
        DECI(aux_nossonum) NO-ERROR.
               
        IF  aux_nmdsacad = "" OR ERROR-STATUS:ERROR  THEN
            DO:
                HIDE MESSAGE NO-PAUSE.
                BELL.
                MESSAGE "Formato do arquivo nao e valido.".
                RETURN "NOK".
            END.

        CREATE tt-boleto.
        ASSIGN tt-boleto.nmdsacad = aux_nmdsacad
               tt-boleto.nossonum = aux_nossonum
               tt-boleto.flgsuces = FALSE.
               
    END. /** Fim do DO WHILE TRUE **/
                   
    INPUT STREAM str_1 CLOSE.
    
    ASSIGN aux_qtrejeit = 0
           aux_qtimport = 0.
           
    FOR EACH tt-boleto EXCLUSIVE-LOCK:               
               
        IF  crapcco.flgutceb  THEN
            DO:
                ASSIGN aux_nrcnvcob = INTE(SUBSTR(tt-boleto.nossonum,1,7))
                       aux_nrcnvceb = INTE(SUBSTR(tt-boleto.nossonum,8,4))
                       aux_nrdocmto = INTE(SUBSTR(tt-boleto.nossonum,12)).
                
                IF  aux_nrcnvcob <> tel_nrcnvcob  THEN
                    DO:   
                        ASSIGN aux_qtrejeit       = aux_qtrejeit + 1.
                               tt-boleto.dsmotivo = "Convenio de cobranca " + 
                                                    "invalido (" +
                                                    TRIM(STRING(aux_nrcnvcob,
                                                         "zzz,zzz,zz9")) + ")".
                        NEXT.                          
                    END.
                
                FIND crapceb WHERE crapceb.cdcooper = glb_cdcooper AND
                                   crapceb.nrdconta = tel_nrdconta AND
                                   crapceb.nrconven = tel_nrcnvcob AND
                                   crapceb.nrcnvceb = aux_nrcnvceb
                                   NO-LOCK NO-ERROR.
                                   
                IF  NOT AVAILABLE crapceb  THEN
                    DO:
                        ASSIGN aux_qtrejeit       = aux_qtrejeit + 1.
                               tt-boleto.dsmotivo = "Convenio CEB nao " +
                                                    "cadastrado (" +
                                                    STRING(aux_nrcnvceb,
                                                           "9999") + ")".
                        NEXT.                          
                    END.
            END.    
        ELSE    
            DO:
                ASSIGN aux_nrdconta = INTE(SUBSTR(tt-boleto.nossonum,1,8))
                       aux_nrdocmto = INTE(SUBSTR(tt-boleto.nossonum,9)).
                       
                IF  aux_nrdconta <> tel_nrdconta  THEN
                    DO:
                        ASSIGN aux_qtrejeit       = aux_qtrejeit + 1.
                               tt-boleto.dsmotivo = "Conta/dv invalida (" +
                                                    TRIM(STRING(aux_nrdconta,
                                                         "zzzz,zzz,9")) + ")".
                        NEXT.                          
                    END.
            END.                    

        ASSIGN aux_contador = 0.
        
        FOR EACH bb-boleto WHERE bb-boleto.nossonum = tt-boleto.nossonum
                                 NO-LOCK:
        
            ASSIGN aux_contador = aux_contador + 1.
            
        END.
                                            
        IF  aux_contador > 1  THEN
            DO:
                ASSIGN aux_qtrejeit       = aux_qtrejeit + 1.
                       tt-boleto.dsmotivo = "Nosso numero duplicado".
                NEXT.
            END.
            
        IF  CAN-FIND(FIRST crapcob WHERE
                           crapcob.cdcooper = glb_cdcooper     AND
                           crapcob.cdbandoc = 1                AND
                           crapcob.nrdctabb = crapcco.nrdctabb AND
                           crapcob.nrcnvcob = tel_nrcnvcob     AND
                           crapcob.nrdocmto = aux_nrdocmto     AND
                           crapcob.nrdconta = tel_nrdconta     NO-LOCK)  THEN
            DO:    
                ASSIGN aux_qtrejeit       = aux_qtrejeit + 1.
                       tt-boleto.dsmotivo = "Boleto de cobranca ja cadastrado" +
                                            " (" + 
                                            TRIM(STRING(aux_nrdocmto,
                                                        "zzz,zzz,zz9")) + ")".
                NEXT.
            END.
            
        CREATE cratcob.
        ASSIGN cratcob.cdcooper   = glb_cdcooper
               cratcob.dtmvtolt   = glb_dtmvtolt
               cratcob.incobran   = 0
               cratcob.nrdconta   = tel_nrdconta
               cratcob.nrdctabb   = crapcco.nrdctabb
               cratcob.cdbandoc   = 1
               cratcob.nrdocmto   = aux_nrdocmto
               cratcob.nrcnvcob   = tel_nrcnvcob     
               cratcob.dtretcob   = glb_dtmvtolt
               cratcob.dsdoccop   = STRING(aux_nrdocmto,"zzz,zzz,zzz")
               cratcob.vltitulo   = tel_vllanmto
               cratcob.dtvencto   = tel_dtvencto
               cratcob.cdcartei   = 18
               cratcob.cddespec   = 99
               cratcob.nmdsacad   = tt-boleto.nmdsacad
               cratcob.cdimpcob   = 2
               cratcob.flgimpre   = TRUE
               tt-boleto.flgsuces = TRUE
               aux_qtimport       = aux_qtimport + 1.

    END. /** Fim do FOR EACH tt-boleto **/

    DO TRANSACTION ON ERROR UNDO, RETURN "NOK":
    
        RUN sistema/generico/procedures/b1crapcob.p PERSISTENT SET h-b1crapcob.
        
        IF  VALID-HANDLE(h-b1crapcob)  THEN
            DO:
                RUN inclui-registro IN h-b1crapcob (INPUT TABLE cratcob,
                                                   OUTPUT aux_dscritic).
                DELETE PROCEDURE h-b1crapcob.

                IF  aux_dscritic <> ""  THEN
                    DO:
                        HIDE MESSAGE NO-PAUSE.
                        BELL.
                        MESSAGE aux_dscritic.
                        UNDO, RETURN "NOK".
                    END.
            END.
    
    END. /** Fim do DO TRANSACTION **/ 
                         
    HIDE MESSAGE NO-PAUSE.
                          
    MESSAGE "Aguarde, gerando relatorio de importacao ...".

    INPUT THROUGH basename `tty` NO-ECHO.
    
    SET aux_nmendter WITH FRAME f_terminal.
    
    INPUT CLOSE.
    
    aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                          aux_nmendter.
    
    ASSIGN aux_nmarqimp = "rl/" + aux_nmendter + STRING(TIME) + ".ex".
    
    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGE-SIZE 84.
    
    VIEW STREAM str_1 FRAME f_cab.

    IF  CAN-FIND(FIRST tt-boleto WHERE tt-boleto.flgsuces = TRUE)  THEN
        PUT STREAM str_1 UNFORMATTED "IMPORTADOS" AT 28 
                                     SKIP
                                     FILL("-",63) AT 01. 
                                     
    FOR EACH tt-boleto WHERE tt-boleto.flgsuces = TRUE NO-LOCK
                             BREAK BY tt-boleto.nmdsacad:

        DISPLAY STREAM str_1 tt-boleto.nmdsacad
                             tt-boleto.nossonum
                             WITH FRAME f_importados.
                             
        DOWN STREAM str_1 WITH FRAME f_importados. 

        IF  LINE-COUNTER(str_1) > PAGE-SIZE(str_1)  THEN
            DO:
                PAGE STREAM str_1.

                PUT STREAM str_1 UNFORMATTED "IMPORTADOS" AT 28
                                             SKIP
                                             FILL("-",63) AT 01.
            END.
         
    END. /** Fim do FOR EACH tt-boleto **/

    IF  CAN-FIND(FIRST tt-boleto WHERE tt-boleto.flgsuces = FALSE)  THEN
        DO:
            IF  CAN-FIND(FIRST tt-boleto WHERE tt-boleto.flgsuces = TRUE)  THEN
                PUT STREAM str_1 SKIP(2).

             PUT STREAM str_1 UNFORMATTED "REJEITADOS"  AT 53
                                          SKIP
                                          FILL("-",114) AT 01.
        END.
            
    FOR EACH tt-boleto WHERE tt-boleto.flgsuces = FALSE NO-LOCK
                             BREAK BY tt-boleto.nmdsacad:
                             
        DISPLAY STREAM str_1 tt-boleto.nmdsacad
                             tt-boleto.nossonum
                             tt-boleto.dsmotivo
                             WITH FRAME f_rejeitados.
                             
        DOWN STREAM str_1 WITH FRAME f_rejeitados.
               
         IF  LINE-COUNTER(str_1) > PAGE-SIZE(str_1)  THEN
             DO:
                 PAGE STREAM str_1.
                                            
                 PUT STREAM str_1 UNFORMATTED "REJEITADOS"  AT 53
                                              SKIP
                                              FILL("-",114) AT 01.
             END.
                      
    END. /** Fim do FOR EACH tt-boleto **/
    
    OUTPUT STREAM str_1 CLOSE.

    HIDE MESSAGE NO-PAUSE.
     
    IF  NOT CAN-FIND(FIRST tt-boleto WHERE tt-boleto.flgsuces = FALSE)  AND
        CAN-FIND(FIRST tt-boleto WHERE tt-boleto.flgsuces = TRUE)       THEN
        MESSAGE "Operacao efetuada com sucesso!".
    ELSE
        MESSAGE "Houveram erros, verifique o relatorio!".
            
    RETURN "OK".
    
END PROCEDURE.

PROCEDURE proc_query:

    OPEN QUERY q_crapcco 
         FOR EACH crapcco WHERE crapcco.cdcooper = glb_cdcooper             AND
                                crapcco.dsorgarq = "IMPRESSO PELO SOFTWARE" AND
                                crapcco.flgativo = TRUE
                                NO-LOCK BY crapcco.nmdbanco.
  
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
        UPDATE b_crapcco WITH FRAME f_crapcco_b.
        LEAVE.
    
    END.

END PROCEDURE.

/*............................................................................*/
