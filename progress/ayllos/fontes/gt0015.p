/* .............................................................................

   Programa: fontes/gt0015.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Outubro/2006                      Ultima Atualizacao:   /  /  

   Dados referentes ao programa:
   
   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela GT0015.
         
   Alteracoes: 

............................................................................. */

{ includes/var_online.i  }

DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_dscodigo AS CHAR                                           NO-UNDO.

DEF VAR tel_cdrelato AS INT                                            NO-UNDO.
DEF VAR tel_dsrelato AS CHAR                                           NO-UNDO.

DEF TEMP-TABLE tt-relatorios
    FIELD dscodigo AS CHAR FORMAT "x(14)"
    FIELD dsrelato LIKE craprel.nmrelato
    FIELD cdprogra LIKE crapprg.cdprogra
    FIELD nmdestin AS CHAR FORMAT "x(18)"
    FIELD nmformul LIKE craprel.nmformul
    FIELD dsimprel AS CHAR FORMAT "x(3)"
    FIELD dsgerpdf AS CHAR FORMAT "x(3)"
    FIELD tprelato AS CHAR FORMAT "x(9)"
    FIELD nrsolici AS INTE FORMAT "999".

DEF QUERY q_relatorios FOR tt-relatorios.

DEF BROWSE b_relatorios QUERY q_relatorios
    DISP tt-relatorios.dscodigo COLUMN-LABEL "CODIGO"    
         tt-relatorios.dsrelato COLUMN-LABEL "DESCRICAO" 
         tt-relatorios.nmdestin COLUMN-LABEL "DESTINO"   
    WITH 8 DOWN OVERLAY NO-BOX.
    
FORM 
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.
     
FORM  
     glb_cddopcao AT 3 LABEL "Opcao" 
                  HELP "Informe (C)odigo ou (D)escricao."
                  VALIDATE (CAN-DO("C,D",glb_cddopcao),"014 - Opcao errada.")
     WITH FRAME f_opcao NO-BOX SIDE-LABEL ROW 6 COLUMN 2 OVERLAY.
     
FORM
     tel_cdrelato LABEL "Codigo"    FORMAT "zzz"
                  HELP "Informe o codigo do relatorio ou 0 para todos."
     WITH FRAME f_codigo NO-BOX SIDE-LABEL ROW 6 COLUMN 15 OVERLAY.

FORM
     tel_dsrelato LABEL "Descricao" FORMAT "x(40)"
                  HELP "Informe a descricao do relatorio."
     WITH FRAME f_descricao NO-BOX SIDE-LABE ROW 6 COLUMN 15 OVERLAY.
     
FORM b_relatorios
     WITH OVERLAY NO-BOX ROW 8 COLUMN 2 FRAME f_relatorios.

FORM
    "Programa   :"   
    tt-relatorios.cdprogra
    "Formulario    :"       AT 30
    tt-relatorios.nmformul
    "Impresso:"             AT 62
    tt-relatorios.dsimprel
    SKIP
    "Solicitacao:" 
    tt-relatorios.nrsolici
    "Tipo Relatorio:"       AT 30
    tt-relatorios.tprelato
    "Gera PDF:"             AT 62
    tt-relatorios.dsgerpdf
    WITH OVERLAY NO-BOX NO-LABEL ROW 19 COLUMN 4 WIDTH 76 FRAME f_dados.

ON VALUE-CHANGED, ENTRY OF b_relatorios
    DO:
        IF  AVAILABLE tt-relatorios  THEN
            DISP tt-relatorios.cdprogra tt-relatorios.nrsolici
                 tt-relatorios.nmformul tt-relatorios.tprelato
                 tt-relatorios.dsimprel tt-relatorios.dsgerpdf
                 WITH FRAME f_dados.           
        ELSE
            MESSAGE "Nao foram encontrados registros referente a consulta.".
    END.
     
RUN fontes/inicia.p.
          
VIEW FRAME f_moldura.
PAUSE(0).

ASSIGN glb_cddopcao = "C".

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

    EMPTY TEMP-TABLE tt-relatorios.

    ASSIGN tel_cdrelato = 0
           tel_dsrelato = "".

    HIDE FRAME f_relatorios NO-PAUSE.
    HIDE FRAME f_dados      NO-PAUSE.
    HIDE FRAME f_descricao  NO-PAUSE.
    HIDE FRAME f_codigo     NO-PAUSE.
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        UPDATE glb_cddopcao WITH FRAME f_opcao.
        LEAVE.
    END.
    
    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        DO:            
            RUN fontes/novatela.p.
            
            IF  CAPS(glb_nmdatela) <> "GT0015"  THEN
                DO:
                    HIDE FRAME f_moldura    NO-PAUSE.
                    HIDE FRAME f_opcao      NO-PAUSE.
                    HIDE FRAME f_relatorios NO-PAUSE.
                    HIDE FRAME f_dados      NO-PAUSE.
                    HIDE FRAME f_descricao  NO-PAUSE.
                    HIDE FRAME f_codigo     NO-PAUSE.
                    LEAVE.
                END.
            ELSE
                NEXT.
        END.    

    IF  aux_cddopcao <> glb_cddopcao  THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

    IF  glb_cddopcao = "C"  THEN
        DO:
            UPDATE tel_cdrelato WITH FRAME f_codigo.
            
            MESSAGE "AGUARDE ...".
            
            IF  tel_cdrelato = 0  THEN
                RUN proc_carrega_todos.
            ELSE
                DO:
                    FIND craprel WHERE craprel.cdcooper = glb_cdcooper AND
                                       craprel.cdrelato = tel_cdrelato
                                       NO-LOCK NO-ERROR.
            
                    IF  AVAILABLE craprel  THEN
                        DO:
                            FOR EACH crapprg WHERE 
                                     crapprg.cdcooper    = glb_cdcooper     AND
                                     crapprg.nrsolici    < 900              AND
                                    (crapprg.cdrelato[1] = craprel.cdrelato OR
                                     crapprg.cdrelato[2] = craprel.cdrelato OR
                                     crapprg.cdrelato[3] = craprel.cdrelato OR
                                     crapprg.cdrelato[4] = craprel.cdrelato OR
                                     crapprg.cdrelato[5] = craprel.cdrelato)
                                     NO-LOCK:

                                IF  SUBSTR(crapprg.cdprogra,1,4) = "CRPS"  THEN
                                    aux_dscodigo = 
                                    STRING(craprel.cdrelato,"999") + "/" +
                                    SUBSTR(crapprg.cdprogra,5,3).
                                ELSE
                                    aux_dscodigo = 
                                    STRING(craprel.cdrelato,"999") + "/" +
                                    TRIM(crapprg.cdprogra).                     
                                                 
                                CREATE tt-relatorios.
                                ASSIGN tt-relatorios.dscodigo = 
                                                CAPS(aux_dscodigo)
                                       tt-relatorios.dsrelato =
                                                CAPS(TRIM(craprel.nmrelato))
                                       tt-relatorios.cdprogra =
                                                CAPS(TRIM(crapprg.cdprogra))
                                       tt-relatorios.nmdestin = 
                                                CAPS(TRIM(craprel.nmdestin))
                                       tt-relatorios.nmformul = 
                                                CAPS(TRIM(craprel.nmformul))
                                       tt-relatorios.dsimprel = 
                                                IF  craprel.inimprel = 1  THEN
                                                    "SIM"
                                                ELSE
                                                    "NAO"
                                       tt-relatorios.dsgerpdf = 
                                                IF  craprel.ingerpdf = 1  THEN
                                                    "SIM"
                                                ELSE
                                                    "NAO"
                                       tt-relatorios.tprelato = 
                                                IF  craprel.tprelato = 1  THEN
                                                    "NORMAL"
                                                ELSE
                                                    "GERENCIAL"
                                       tt-relatorios.nrsolici = 
                                                crapprg.nrsolici.
                                                    
                            END. /* Fim do FOR EACH */ 
                        END.
                END.
                                                   
            OPEN QUERY q_relatorios
            FOR EACH tt-relatorios BY tt-relatorios.dscodigo.
            
            PAUSE(0) NO-MESSAGE.
            
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                UPDATE b_relatorios WITH FRAME f_relatorios.
                LEAVE.
            END.
            
        END.
    ELSE
    IF  glb_cddopcao = "D"  THEN
        DO:
            UPDATE tel_dsrelato WITH FRAME f_descricao.
            
            MESSAGE "AGUARDE ...".
            
            IF  tel_dsrelato = ""  THEN
                RUN proc_carrega_todos.
            ELSE
                FOR EACH craprel WHERE 
                         craprel.cdcooper = glb_cdcooper AND
                         craprel.nmrelato MATCHES "*" + tel_dsrelato + "*"
                         NO-LOCK,
                    EACH crapprg WHERE 
                         crapprg.cdcooper    = glb_cdcooper      AND
                         crapprg.nrsolici    < 900               AND
                        (crapprg.cdrelato[1] = craprel.cdrelato  OR
                         crapprg.cdrelato[2] = craprel.cdrelato  OR
                         crapprg.cdrelato[3] = craprel.cdrelato  OR
                         crapprg.cdrelato[4] = craprel.cdrelato  OR
                         crapprg.cdrelato[5] = craprel.cdrelato) NO-LOCK:
                                  
                    IF  SUBSTR(crapprg.cdprogra,1,4) = "CRPS"  THEN
                        aux_dscodigo = STRING(craprel.cdrelato,"999") + "/" +
                                       SUBSTR(crapprg.cdprogra,5,3).                               ELSE
                        aux_dscodigo = STRING(craprel.cdrelato,"999") + "/" +
                                       TRIM(crapprg.cdprogra).                     
                                                
                    CREATE tt-relatorios.
                    ASSIGN tt-relatorios.dscodigo = CAPS(aux_dscodigo)
                           tt-relatorios.dsrelato = CAPS(TRIM(craprel.nmrelato))
                           tt-relatorios.cdprogra = CAPS(TRIM(crapprg.cdprogra))
                           tt-relatorios.nmdestin = CAPS(TRIM(craprel.nmdestin))
                           tt-relatorios.nmformul = CAPS(TRIM(craprel.nmformul))
                         tt-relatorios.dsimprel = IF  craprel.inimprel = 1  THEN
                                                      "SIM"
                                                  ELSE
                                                      "NAO"
                         tt-relatorios.dsgerpdf = IF  craprel.ingerpdf = 1  THEN
                                                      "SIM"
                                                  ELSE
                                                      "NAO"
                         tt-relatorios.tprelato = IF  craprel.tprelato = 1  THEN
                                                      "NORMAL"
                                                  ELSE
                                                      "GERENCIAL"
                           tt-relatorios.nrsolici = crapprg.nrsolici.
                                                      
                END. /* Fim do FOR EACH */ 
             
            OPEN QUERY q_relatorios
            FOR EACH tt-relatorios BY tt-relatorios.dscodigo.
            
            PAUSE(0) NO-MESSAGE.
            
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                UPDATE b_relatorios WITH FRAME f_relatorios.
                LEAVE.
            END.
            
        END.
     
         
END. /* Fim do DO WHILE */

PROCEDURE proc_carrega_todos.

    FOR EACH craprel WHERE craprel.cdcooper = glb_cdcooper NO-LOCK,
        EACH crapprg WHERE crapprg.cdcooper    = glb_cdcooper      AND
                           crapprg.nrsolici    < 900               AND
                          (crapprg.cdrelato[1] = craprel.cdrelato  OR
                           crapprg.cdrelato[2] = craprel.cdrelato  OR
                           crapprg.cdrelato[3] = craprel.cdrelato  OR
                           crapprg.cdrelato[4] = craprel.cdrelato  OR
                           crapprg.cdrelato[5] = craprel.cdrelato) NO-LOCK:
                                  
        IF  SUBSTR(crapprg.cdprogra,1,4) = "CRPS"  THEN
            aux_dscodigo = STRING(craprel.cdrelato,"999") + "/" +
                           SUBSTR(crapprg.cdprogra,5,3).             
        ELSE
            aux_dscodigo = STRING(craprel.cdrelato,"999") + "/" +
                           TRIM(crapprg.cdprogra).                     
                                                
        CREATE tt-relatorios.
        ASSIGN tt-relatorios.dscodigo = CAPS(aux_dscodigo)
               tt-relatorios.dsrelato = CAPS(TRIM(craprel.nmrelato))
               tt-relatorios.cdprogra = CAPS(TRIM(crapprg.cdprogra))
               tt-relatorios.nmdestin = CAPS(TRIM(craprel.nmdestin))
               tt-relatorios.nmformul = CAPS(TRIM(craprel.nmformul))
               tt-relatorios.dsimprel = IF  craprel.inimprel = 1  THEN
                                            "SIM"
                                        ELSE
                                            "NAO"
               tt-relatorios.dsgerpdf = IF  craprel.ingerpdf = 1  THEN
                                            "SIM"
                                        ELSE
                                            "NAO"
               tt-relatorios.tprelato = IF  craprel.tprelato = 1  THEN
                                            "NORMAL"
                                        ELSE
                                            "GERENCIAL"
               tt-relatorios.nrsolici = crapprg.nrsolici.
                                                    
    END. /* Fim do FOR EACH */ 

END PROCEDURE.
 
/* .......................................................................... */

