/* ..........................................................................

   Programa: Fontes/impcps.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Fabricio
   Data    : Junho/2011                        Ultima atualizacao: 06/12/2013
                                                                          
   Dados referentes ao programa:

   Frequencia: Tela.
   Objetivo  : Mostra a tela IMPCPS.
               Importacao comprovante salarial.
               
   Alteracoes: 17/06/2011 - Removido browse com a listagem dos comprovantes a 
                            serem importados, encontrados em 
                            /micros/'cooperativa', e, criado campo para 
                            digitacao do nome do arquivo a ser importado.
                            Portanto, a importacao atraves desta tela, acontece
                            para um unico arquivo por vez; enquanto 
                            anteriormente, importava todos os arquivos 
                            encontrados no diretorio. (Fabricio)

               06/12/2013 - Inclusao de VALIDATE crapsol (Carlos)

............................................................................. */

{ includes/var_online.i }

DEF STREAM str_1.

DEF VAR aux_imporarq AS CHAR FORMAT "!(1)"  INIT "N"         NO-UNDO.
DEF VAR aux_diretori AS CHAR                                 NO-UNDO.

DEF VAR tel_cddopcao AS CHAR FORMAT "x(01)" INIT "I"         NO-UNDO.
DEF VAR tel_diretdef AS CHAR FORMAT "x(20)"                  NO-UNDO.
DEF VAR tel_nomearqu AS CHAR FORMAT "x(25)"                  NO-UNDO.

FORM SKIP(1) 
     tel_cddopcao AT 03 LABEL "Opcao" AUTO-RETURN
        VALIDATE(tel_cddopcao = "I", "014 - Opcao errada.")
        HELP "Informe a opcao (I)."
     SKIP(2)
     tel_diretdef AT 03 LABEL "Diretorio"
     tel_nomearqu NO-LABEL
     HELP "Informe o nome do arquivo que deseja integrar."
     WITH DOWN ROW 4 COLUMN 1 SIDE-LABELS OVERLAY 
     TITLE "Importacao Comprovante Salarial" WIDTH 80 FRAME f_arquivos.

ASSIGN glb_cddopcao = "I".

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

ASSIGN tel_diretdef = "/micros/" + crapcop.dsdircop + "/".

DO WHILE TRUE:

    RUN fontes/inicia.p.

    DISP tel_cddopcao
         tel_diretdef
         tel_nomearqu
         WITH FRAME f_arquivos.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        UPDATE tel_cddopcao WITH FRAME f_arquivos.

        { includes/acesso.i }

        UPDATE tel_nomearqu WITH FRAME f_arquivos.

        ASSIGN aux_diretori = TRIM(tel_diretdef) + TRIM(tel_nomearqu).

        IF SEARCH(aux_diretori) = ? THEN
        DO:
            glb_cdcritic = 182.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            PAUSE 5 NO-MESSAGE.

            NEXT.
        END.

        LEAVE.
    END.

    IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN /* F4 OU FIM */
    DO:
        RUN fontes/novatela.p.

        IF CAPS(glb_nmdatela) <> "IMPCPS" THEN
        DO:
            HIDE FRAME f_arquivos.
            RETURN.
        END.
        ELSE
            NEXT.
    END.

    DO WHILE TRUE:
        MESSAGE "Confirma importacao dos comprovantes?"
        UPDATE aux_imporarq.
                
        IF aux_imporarq = "S" OR aux_imporarq = "N" THEN
            LEAVE.

    END.

    IF aux_imporarq = "S" THEN
    DO:
        IF CAN-FIND(crapsol WHERE crapsol.cdcooper = glb_cdcooper AND
                                  crapsol.nrsolici = 107)         THEN
        DO:
            MESSAGE "Importacao sendo realizada em outro terminal..."
                    "Tente mais tarde...".
            PAUSE 2 NO-MESSAGE.
            NEXT.
        END.

        INPUT STREAM str_1 THROUGH VALUE( "ls " + aux_diretori 
                                                    + " 2> /dev/null") NO-ECHO.

        SET STREAM str_1 aux_diretori FORMAT "x(60)".

        DO TRANSACTION:
            /* Cria a solicitacao para rodar o programa */
            CREATE crapsol.
            ASSIGN crapsol.nrsolici = 107
                   crapsol.dtrefere = glb_dtmvtolt
                   crapsol.nrseqsol = 01
                   crapsol.cdempres = 11
                   crapsol.dsparame = " "
                   crapsol.insitsol = 1                    
                   crapsol.nrdevias = 1
                   crapsol.cdcooper = glb_cdcooper.

            VALIDATE crapsol.

        END.

        MESSAGE "Aguarde... Importando comprovantes...".
                
        RUN fontes/crps600.p(INPUT aux_diretori).                   

        DO TRANSACTION:
            FIND crapsol WHERE crapsol.cdcooper = glb_cdcooper
                           AND crapsol.nrsolici = 107
                           AND crapsol.dtrefere = glb_dtmvtolt
                           AND crapsol.nrseqsol = 01 EXCLUSIVE-LOCK NO-ERROR.

            IF AVAIL crapsol THEN
                DELETE crapsol.            
        END.
            
        HIDE MESSAGE NO-PAUSE.

        MESSAGE "Importacao realizada com sucesso!".

    END.

END.
