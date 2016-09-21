/*..............................................................................

   Programa: Fontes/impchq.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Daniel Zimmermann
   Data    : Abril/2014                     Ultima Atualizacao: 26/06/2014

   Dados referentes ao programa:

   Frequencia : Diario (on-line)
   Objetivo   : Mostrar a tela impchq.
   
   Alteracoes : 02/06/2014 - Individualizando a forma de impressao dos
                             relatorios e questionando sobre a imprimi-los
                             (Andre Santos - SUPERO)
                             
                26/06/2014 - Ajuste para pegar a extensao do arquivo crrl433
                             como .lst em vez de .txt. 
                             (Jorge/Rosangela) Emergencial - SD 171644
..............................................................................*/



{  includes/var_online.i }

DEF   VAR tel_nmimpchq AS CHAR                FORMAT "x(20)"           NO-UNDO.
DEF   VAR tel_nmimprel AS CHAR                FORMAT "x(20)"           NO-UNDO.
DEF   VAR tel_nrpedido AS INTE                FORMAT "ZZZZZZ"          NO-UNDO.


DEF   VAR aux_cddopcao AS CHAR                                         NO-UNDO.
DEF   VAR aux_confirma AS LOGICAL FORMAT "S/N" INITIAL YES             NO-UNDO.
DEF   VAR aux_confirm1 AS LOGICAL FORMAT "S/N" INITIAL YES             NO-UNDO.
DEF   VAR aux_confirm2 AS LOGICAL FORMAT "S/N" INITIAL YES             NO-UNDO.
DEF   VAR aux_dtsolped AS DATE                                         NO-UNDO. 
DEF   VAR aux_caminho  AS CHAR                                         NO-UNDO. 
DEF   VAR aux_cdcooper AS INTE                                         NO-UNDO. 
DEF   VAR aux_dtmvtolt AS DATE                                         NO-UNDO.


FORM WITH ROW 4 COLUMN 1 OVERLAY SIZE 80 BY 18 TITLE glb_tldatela 
     FRAME f_moldura.

FORM SKIP(2)
    glb_cddopcao AT 30 LABEL "Opcao" AUTO-RETURN
         HELP "Informe a opcao desejada (A,I)."
         VALIDATE (CAN-DO("A,I",glb_cddopcao), "014 - Opcao errada.")
     WITH ROW 6 COLUMN 3 OVERLAY SIDE-LABELS NO-BOX FRAME f_opcao.

FORM SKIP(2)
     tel_nmimpchq  AT 03 LABEL "   Nome da Impressora para Cheques"   
         HELP "Informe o Nome da Impressora para Cheques."
     
     SKIP(1)
     tel_nmimprel  AT 03 LABEL "Nome da Impressora para Relatorios"
         HELP "Informe Nome da Impressora para Relatorios."  
        
     WITH ROW 9 WIDTH 78 SIDE-LABELS OVERLAY CENTERED NO-BOX FRAME f_opcaoa.

FORM SKIP(2)
     tel_nrpedido  AT 19 LABEL "Numero do pedido"   
         HELP "Informe o Numero do pedido."
     
     WITH ROW 9 WIDTH 78 SIDE-LABELS OVERLAY CENTERED NO-BOX FRAME f_opcaoi.


VIEW FRAME f_moldura.

PAUSE 0.

ASSIGN glb_cddopcao = "A"
       glb_cdcritic =  0.
             
DO WHILE TRUE:           

   RUN fontes/inicia.p.
        
   CLEAR FRAME f_opcaoa NO-PAUSE.
   CLEAR FRAME f_opcaoi NO-PAUSE.
   
   HIDE FRAME f_opcaoa NO-PAUSE.
   HIDE FRAME f_opcaoi NO-PAUSE.
      
   IF   glb_cdcritic > 0   THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
        END.
                     
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      
      UPDATE glb_cddopcao WITH FRAME f_opcao.
      LEAVE.
   
   END.
   
   IF   KEYFUNCTION (LASTKEY) = "END-ERROR"   THEN      /* F4 ou Fim  */
        DO:          
            RUN fontes/novatela.p.
            
            IF   CAPS(glb_nmdatela) <> "IMPCHQ"   THEN
                 DO:
                     HIDE FRAME f_opcao.
                     RETURN.
                 END.
            ELSE 
                 NEXT.
        END.                                  
                                             
   IF   aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.    
   
   IF   glb_cddopcao =  "A"   THEN
       DO:

            CLEAR FRAME f_opcaoa.

            ASSIGN tel_nmimpchq = ""
                   tel_nmimprel = "".

            FOR EACH craptab WHERE craptab.cdcooper = glb_cdcooper      AND
                                   craptab.nmsistem = "CRED"            AND
                                   craptab.tptabela = "GENERI"          AND
                                   craptab.cdempres = 0                 AND
                                   craptab.cdacesso = "IMPCHQ"
                                   NO-LOCK:
                
                IF  craptab.tpregist = 1 THEN /* CHEQUES */
                    ASSIGN tel_nmimpchq = STRING(craptab.dstextab).
                ELSE
                IF  craptab.tpregist = 2 THEN /* RELATORIO */
                    ASSIGN tel_nmimprel = STRING(craptab.dstextab).
                ELSE
                    ASSIGN tel_nmimpchq = ""
                           tel_nmimprel = "".

            END.

            DISPLAY tel_nmimpchq tel_nmimprel WITH FRAME f_opcaoa.
                
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               UPDATE  tel_nmimpchq tel_nmimprel WITH FRAME f_opcaoa.

               IF   TRIM(tel_nmimpchq) = "" THEN 
                    DO:
                        MESSAGE "000 - Nome da Impressora para Cheques nao Informado.".
                        PAUSE 3 NO-MESSAGE.
                        NEXT.
                    END.

               IF   TRIM(tel_nmimprel) = "" THEN 
                    DO:
                        MESSAGE "000 - Nome da Impressora para Relatorios nao Informado.".
                        PAUSE 3 NO-MESSAGE.
                        NEXT.
                    END.
            
               LEAVE.
            
            END.   

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                 NEXT.
            
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
               aux_confirma = NO.
               MESSAGE "Confirma Alteracao? (S/N):"
               UPDATE aux_confirma.
               LEAVE.
            END.

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                 NOT aux_confirma                     THEN
                 DO:
                     glb_cdcritic = 79.  
                     NEXT.
                 END.
           
            DO TRANSACTION:

                FIND craptab WHERE craptab.cdcooper = glb_cdcooper      AND
                                   craptab.nmsistem = "CRED"            AND
                                   craptab.tptabela = "GENERI"          AND
                                   craptab.cdempres = 0                 AND
                                   craptab.cdacesso = "IMPCHQ"          AND
                                   craptab.tpregist = 1  /* 1 - Cheques e 2 - Relatorio */
                                   EXCLUSIVE-LOCK NO-ERROR. 

                IF AVAIL(craptab) THEN
                    ASSIGN craptab.dstextab = tel_nmimpchq.
                ELSE DO:
                    CREATE craptab.
                    ASSIGN craptab.cdcooper = glb_cdcooper 
                           craptab.nmsistem = "CRED"       
                           craptab.tptabela = "GENERI"     
                           craptab.cdempres = 0            
                           craptab.cdacesso = "IMPCHQ"     
                           craptab.tpregist = 1  /* 1 - Cheques */
                           craptab.dstextab = tel_nmimpchq.
                END.

                
                FIND craptab WHERE craptab.cdcooper = glb_cdcooper      AND
                                   craptab.nmsistem = "CRED"            AND
                                   craptab.tptabela = "GENERI"          AND
                                   craptab.cdempres = 0                 AND
                                   craptab.cdacesso = "IMPCHQ"          AND
                                   craptab.tpregist = 2  /* 1 - Cheques e 2 - Relatorio */
                                   EXCLUSIVE-LOCK NO-ERROR. 

                IF AVAIL(craptab) THEN
                   ASSIGN craptab.dstextab = tel_nmimprel.
                ELSE DO:
                   CREATE craptab.
                   ASSIGN craptab.cdcooper = glb_cdcooper 
                          craptab.nmsistem = "CRED"       
                          craptab.tptabela = "GENERI"     
                          craptab.cdempres = 0            
                          craptab.cdacesso = "IMPCHQ"     
                          craptab.tpregist = 2  /* 2 - Relatorio */
                          craptab.dstextab = tel_nmimprel.
                END.

            END.
                   
        END.    /*  Fim da opcao "A"  */
    ELSE    
    IF  glb_cddopcao = "I"   THEN DO: 
            
        CLEAR FRAME f_opcaoi.

        ASSIGN tel_nrpedido = 0.

        DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

            UPDATE tel_nrpedido
                   WITH FRAME f_opcaoi.

            LEAVE.
        END.   

        IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
            NEXT.

        DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
            /* Solicita confirmacao de impressao CHEQUES*/ 
            aux_confirm1 = NO.
            MESSAGE "Confirma impressao de CHEQUES? (S/N):"
            UPDATE aux_confirm1.
            LEAVE.
            
        END.

        DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
            /* Solicita confirmacao de impressao CHEQUES*/ 
            aux_confirm2 = NO.
            MESSAGE "Confirma impressão do Relatorio? (S/N):"
            UPDATE aux_confirm2.
            LEAVE.
            
        END.

        /* Nenhuma opcao selecionada */
        IF KEYFUNCTION(LASTKEY) = "END-ERROR"          OR 
           NOT  aux_confirm1  AND NOT  aux_confirm2  THEN DO:
           glb_cdcritic = 79.  
           NEXT.

        END.
        ELSE DO:

            IF  aux_confirm1 AND aux_confirm2 THEN DO:
                RUN p_busca_dados_impres.
                
                IF  RETURN-VALUE <> "NOK" THEN
                    NEXT.

                /* lp -d IMPRESSORA_CHEQUE -oMTfcheque crrl434_44268.lst */
                UNIX SILENT VALUE ("lp -d " + tel_nmimpchq +  " -oMTfcheque "
                                  + aux_caminho + "crrl434_"
                                  + TRIM(STRING(tel_nrpedido))
                                  + ".txt 1>/dev/null 2>/dev/null").

                /* lp -d IMPRESSORA_RELATORIO -n 1 -oMTf132col crrl433_44268.lst */
                UNIX SILENT VALUE ("lp -d " + tel_nmimprel +  " -n 1 -oMTf132col "
                                  + aux_caminho + "crrl433_"
                                  + TRIM(STRING(tel_nrpedido))
                                  + ".lst 1>/dev/null 2>/dev/null").

                MESSAGE "Pedidos impressos em: " + TRIM(tel_nmimpchq) + " e " + TRIM(tel_nmimprel).

            END.
            ELSE
            IF  aux_confirm1 THEN DO: /* Executa comandos de impressoao de CHEQUE */
                RUN p_busca_dados_impres.
                
                IF  RETURN-VALUE <> "NOK" THEN
                    NEXT.

                /* lp -d IMPRESSORA_CHEQUE -oMTfcheque crrl434_44268.lst */
                UNIX SILENT VALUE ("lp -d " + tel_nmimpchq +  " -oMTfcheque "
                                  + aux_caminho + "crrl434_"
                                  + TRIM(STRING(tel_nrpedido))
                                  + ".txt 1>/dev/null 2>/dev/null").
                
                MESSAGE "Pedidos impressos em: " + TRIM(tel_nmimpchq).

            END.
            ELSE
            IF  aux_confirm2 THEN DO: /* Executa comandos de impressoao de RELATORIO */
                RUN p_busca_dados_impres.

                IF  RETURN-VALUE <> "NOK" THEN
                    NEXT.

                /* lp -d IMPRESSORA_RELATORIO -n 1 -oMTf132col crrl433_44268.lst */
                UNIX SILENT VALUE ("lp -d " + tel_nmimprel +  " -n 1 -oMTf132col "
                                  + aux_caminho + "crrl433_"
                                  + TRIM(STRING(tel_nrpedido))
                                  + ".lst 1>/dev/null 2>/dev/null").
                    
                MESSAGE "Pedidos impressos em: " + TRIM(tel_nmimprel).

            END.
        END.
    END.  /*  Fim da opcao "I"  */

END.   /*  Fim do DO WHILE TRUE  */


PROCEDURE p_busca_dados_impres:

    ASSIGN aux_dtsolped = ?
           aux_caminho  = "".

    /* Identificar de qual cooperativa */
    FOR EACH crapcop WHERE crapcop.cdcooper <> 3 NO-LOCK:
            
        FIND crapped WHERE crapped.cdcooper = crapcop.cdcooper
                       AND crapped.nrpedido = tel_nrpedido
                       NO-LOCK NO-ERROR.
            
        IF  AVAILABLE crapped THEN DO:
            ASSIGN aux_dtsolped = crapped.dtsolped
                   aux_cdcooper = crapped.cdcooper.
                     
            LEAVE.
                
        END.
    END.

    IF  aux_dtsolped <> ? THEN DO:
        FOR FIRST crapcop FIELDS(crapcop.dsdircop) 
            WHERE crapcop.cdcooper = crapped.cdcooper NO-LOCK:
        END.

        IF  MONTH(aux_dtsolped) = MONTH(glb_dtmvtolt) AND
            YEAR(aux_dtsolped)  = YEAR(glb_dtmvtolt)  THEN

            aux_caminho = "/usr/coop/" + TRIM(crapcop.dsdircop)
                                       +  "/salvar/".
        ELSE DO:

            ASSIGN aux_dtmvtolt = glb_dtmvtolt
                   aux_dtmvtolt = ADD-INTERVAL(aux_dtmvtolt,-1,'months').

            IF  MONTH(aux_dtsolped) = MONTH(aux_dtmvtolt) AND
                YEAR(aux_dtsolped)  = YEAR(aux_dtmvtolt)  THEN

                aux_caminho = "/usr/coop/win12/" + TRIM(crapcop.dsdircop)
                                                 + "/salvar/".
        END.                    
    END.

    IF  aux_caminho = "" THEN DO:
        MESSAGE "000 - Pedido nao Localizado!".
        PAUSE 3 NO-MESSAGE.
        RETURN.
    END.

    RUN p_verifica_impressora.

    IF  RETURN-VALUE <> "NOK" THEN
        RETURN "NOK".

    RETURN "OK".

END PROCEDURE.

PROCEDURE p_verifica_impressora:

    /* Verifica se a impressora de CHEQUE esta cadastra */
    IF  aux_confirm1 THEN DO:

        /* Busco nome da impressora de cheque  */
        FIND FIRST craptab WHERE craptab.cdcooper = glb_cdcooper
                             AND craptab.nmsistem = "CRED"
                             AND craptab.tptabela = "GENERI"
                             AND craptab.cdempres = 0
                             AND craptab.cdacesso = "IMPCHQ"
                             AND craptab.tpregist = 1  /* 1 - Cheques */
                             NO-LOCK NO-ERROR. 
    
        IF  NOT AVAIL craptab THEN DO:
            MESSAGE "000 - Impressora para Cheques nao Cadastra. Use opcao A para Cadastrar!".
            PAUSE 3 NO-MESSAGE.
            RETURN "NOK".
        END.

        ASSIGN tel_nmimpchq = craptab.dstextab.

    END.

    IF  aux_confirm2 THEN DO:

        /* Busco nome da impressora de relatorio */
        FIND FIRST craptab WHERE craptab.cdcooper = glb_cdcooper
                             AND craptab.nmsistem = "CRED"
                             AND craptab.tptabela = "GENERI"
                             AND craptab.cdempres = 0
                             AND craptab.cdacesso = "IMPCHQ"
                             AND craptab.tpregist = 2  /* 1 - Cheques e 2 - Relatorio */
                             NO-LOCK NO-ERROR. 
    
        IF  NOT AVAIL craptab THEN DO:
            MESSAGE "000 - Impressora para Relatorios nao Cadastra. Use opcao A para Cadastrar!".
            PAUSE 3 NO-MESSAGE.
            RETURN "NOK".
        END.
            
        ASSIGN tel_nmimprel = craptab.dstextab.

    END.

    RETURN "OK".

END PROCEDURE.
/*............................................................................*/
