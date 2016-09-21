/* ............................................................................

    Programa: Fontes/CADCEB.p
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : David
    Data    : Julho/2006                      Ultima atualizacao: 05/07/2013

    Dados referentes ao programa:

    Frequencia: Diario (On-Line).
    Objetivo  : Mostrar Tela CADCEB.
                Cadastro Emissao de Bloqueto.

    Alteracoes: 28/08/2006 - Alteracao no Help dos campos da tela (Elton).
    
                27/10/2006 - Alterar forma de gerar o codigo nrcnvceb (David).

                31/10/2006 - Verifica se conta ja possui convenio ativo (David).

                22/05/2009 - Alteracao CDOPERAD (Kbase).
                
                18/04/2012 - Remoção de Opção A - I da tela (Lucas Ranghetti)
                
                05/07/2013 - Criadas as opções de filtro por convênio e CEB.
                             (Carlos)
............................................................................ */

{ includes/var_online.i }

DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_confirma AS CHAR    FORMAT "!(1)"                          NO-UNDO.
DEF VAR aux_contador AS INT                                            NO-UNDO.
DEF VAR aux_flgconta AS LOG                                            NO-UNDO.

DEF VAR tel_nrdconta AS INT                                            NO-UNDO.
DEF VAR tel_nrconven AS INT                                            NO-UNDO.
DEF VAR tel_nrcnvceb AS INT                                            NO-UNDO.
DEF VAR tel_dtcadast AS DATE                                           NO-UNDO.
DEF VAR tel_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR tel_nmoperad AS CHAR                                           NO-UNDO.

DEF VAR tel_flsitceb AS LOGICAL                                        NO-UNDO.

DEF BUFFER crabceb FOR crapceb.

DEF TEMP-TABLE cratceb
    FIELD nrdconta LIKE crapceb.nrdconta
    FIELD nrconven LIKE crapceb.nrconven
    FIELD nrcnvceb LIKE crapceb.nrcnvceb
    FIELD dtcadast LIKE crapceb.dtcadast
    FIELD cdoperad LIKE crapceb.cdoperad
    FIELD dssitceb AS CHAR FORMAT "x(7)"
    INDEX cratceb1 AS PRIMARY UNIQUE nrdconta nrconven nrcnvceb.
 
DEF QUERY q_cratceb FOR cratceb.
DEF QUERY q_crapcco FOR crapcco.
   
DEF BROWSE b_cratceb QUERY q_cratceb
    DISPLAY cratceb.nrdconta COLUMN-LABEL "Conta/dv"
            cratceb.nrconven COLUMN-LABEL "Convenio BB"
            cratceb.nrcnvceb COLUMN-LABEL "Codigo Identificacao"
            cratceb.dssitceb COLUMN-LABEL "Situacao Convenio"
            WITH 7 DOWN CENTERED NO-BOX OVERLAY.

DEF BROWSE b_crapcco QUERY q_crapcco
    DISPLAY crapcco.nrconven NO-LABEL
            WITH 5 DOWN NO-BOX OVERLAY.

/*****************************************************************************/
   
FORM
    b_cratceb AT 2
    HELP "Use as setas para navegar ou <END>/<F4> para sair."
    
    WITH ROW 9 NO-BOX CENTERED WIDTH 70 OVERLAY FRAME f_cratceb.
    
FORM 
    WITH NO-LABEL TITLE COLOR MESSAGE glb_tldatela
    ROW 4 COLUMN 1 OVERLAY SIZE 80 BY 18 FRAME f_moldura.
   
FORM
    glb_cddopcao LABEL "Opcao" AT 10 AUTO-RETURN
           VALIDATE (CAN-DO("C",glb_cddopcao),"014 - Opcao Errada")
    WITH NO-BOX NO-LABEL SIDE-LABEL ROW 7 COLUMN 2 OVERLAY WIDTH 78
    FRAME f_opcao.
 
FORM
    "Conta/dv:"        AT 30
    
    tel_nrdconta       FORMAT "zzzz,zzz,9" AUTO-RETURN
                       HELP "Informe o numero da conta."

    SKIP(1)
    
    "Convenio BB:"     AT 27

    tel_nrconven       AT 40 FORMAT "zz,zzz,zz9" AUTO-RETURN
                       HELP "Informe o numero do convenio ou pressione <F7> 
                             para listar."
    SKIP(1)
    
    "Codigo de Identificacao:" AT 15

    tel_nrcnvceb       AT 40 FORMAT "z,zz9"     /*  AUTO-RETURN */
                       HELP "Informe o codigo de identificacao."
                 
    WITH NO-BOX NO-LABEL SIDE-LABEL ROW 10 COLUMN 2 OVERLAY WIDTH 78
    FRAME f_dados.

FORM b_crapcco  HELP "Use as SETAS para navegar ou F4 para sair"
    SKIP
    WITH ROW 7 COLUMN 2 OVERLAY CENTERED TITLE "Convenio BB" FRAME f_crapcco_b.

FORM 
    "Convenio Ativo:" AT 24
    
    tel_flsitceb FORMAT "SIM/NAO" AUTO-RETURN
                 HELP "Informe 'S' para ativar ou 'N' para inativar."

    WITH NO-BOX NO-LABEL SIDE-LABEL ROW 16 COLUMN 2 OVERLAY WIDTH 78
    FRAME f_situacao.
                 
FORM
    tel_dtcadast AT  6 LABEL "Ult. Alt." FORMAT "99/99/9999"
    
    tel_cdoperad AT 33 LABEL "Op."       FORMAT "x(10)"
    
    "-"
    
    tel_nmoperad                              FORMAT "x(20)"  
    
    WITH ROW 19 COLUMN 2 NO-LABEL SIDE-LABEL OVERLAY NO-BOX FRAME f_informacoes.

/*****************************************************************************/

ON RETURN OF b_crapcco
    DO:   
        ASSIGN tel_nrconven = crapcco.nrconven. 
       
        DISPLAY tel_nrconven WITH FRAME f_dados.
        
        APPLY "GO".
        
        HIDE FRAME f_crapcco_b NO-PAUSE.
    END.        

ON VALUE-CHANGED, ENTRY OF b_cratceb 
    DO:
        FIND crapope WHERE crapope.cdcooper = glb_cdcooper     AND
                           crapope.cdoperad = cratceb.cdoperad
                           NO-LOCK NO-ERROR.
                           
        IF  AVAILABLE crapope  THEN
            DO:
                ASSIGN tel_dtcadast = cratceb.dtcadast
                       tel_cdoperad = cratceb.cdoperad
                       tel_nmoperad = crapope.nmoperad.
               
                DISPLAY tel_dtcadast tel_cdoperad tel_nmoperad
                WITH FRAME f_informacoes.
            END.
    END.

/****************************************************************************/

VIEW FRAME f_moldura.

PAUSE(0).

RUN fontes/inicia.p.

ASSIGN glb_cdcritic = 0.

DO WHILE TRUE:

    HIDE FRAME f_dados       NO-PAUSE.
    HIDE FRAME f_conta       NO-PAUSE.
    HIDE FRAME f_situacao    NO-PAUSE.
    HIDE FRAME f_informacoes NO-PAUSE.

    IF  glb_cdcritic > 0  THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            ASSIGN glb_cdcritic = 0.
        END.
        
    ASSIGN glb_cddopcao = "C"
           tel_nrdconta = 0
           tel_nrconven = 0
           tel_nrcnvceb = 0
           tel_cdoperad = ""
           tel_dtcadast = ?
           tel_nmoperad = "".
           
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        UPDATE glb_cddopcao WITH FRAME f_opcao.
        LEAVE.
    END.
    
    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        DO:
            RUN fontes/novatela.p.
             
            IF  CAPS(glb_nmdatela) <> "CADCEB"  THEN
                DO:
                    HIDE FRAME f_moldura  NO-PAUSE.
                    HIDE FRAME f_opcao    NO-PAUSE.
                    RETURN.
                END.
            ELSE
                NEXT. 
        END.

    IF  aux_cddopcao <> INPUT glb_cddopcao  THEN
        DO:
            { includes/acesso.i }
            ASSIGN aux_cddopcao = INPUT glb_cddopcao.
        END.
                                                       
       
    DISPLAY tel_dtcadast tel_cdoperad tel_nmoperad 
        WITH FRAME f_informacoes.

        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
            IF  glb_cdcritic > 0  THEN
                DO:
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.
                    ASSIGN glb_cdcritic = 0.
                END.

            UPDATE tel_nrdconta tel_nrconven tel_nrcnvceb WITH FRAME f_dados
            
            EDITING:
                READKEY.
                IF  LASTKEY     = KEYCODE("F7") AND 
                    FRAME-FIELD = "tel_nrconven" THEN
                    DO:
                        RUN proc_query.

                        HIDE FRAME f_crapcco_b.

                        IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                            NEXT.

                    END.
                
                APPLY LASTKEY.

            END. /* Fim do EDITING */
            
            RUN p_carrega_cratceb.
            
            IF  glb_cdcritic > 0  THEN
                NEXT.
                      
            OPEN QUERY q_cratceb FOR EACH cratceb USE-INDEX cratceb1
                                 BY cratceb.nrconven
                                 BY cratceb.nrcnvceb.
                                     
            SET b_cratceb WITH FRAME f_cratceb.
        
        END. /* Fim do DO WHILE */        
    
END. /* Fim do DO WHILE */

/*****************************************************************************/

PROCEDURE p_carrega_cratceb.

    EMPTY TEMP-TABLE cratceb.

    IF  tel_nrdconta <> 0  THEN
    DO:
        FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                           crapass.nrdconta = tel_nrdconta
                           NO-LOCK NO-ERROR.
                       
        IF  NOT AVAILABLE crapass  THEN
            DO:
               ASSIGN glb_cdcritic = 9.
               LEAVE.
            END.
    END.
                                          
    FOR EACH crapceb WHERE 
            crapceb.cdcooper = glb_cdcooper AND 
            (   (tel_nrdconta <> 0 AND crapceb.nrdconta = tel_nrdconta) OR 
                (tel_nrdconta = 0)
            )   AND
            (   (tel_nrconven <> 0 AND crapceb.nrconven = tel_nrconven) OR 
                (tel_nrconven = 0)
            )   AND
            (   (tel_nrcnvceb <> 0 AND crapceb.nrcnvceb = tel_nrcnvceb) OR 
                (tel_nrcnvceb = 0)
            )
        NO-LOCK:

        CREATE cratceb.

        ASSIGN cratceb.nrdconta = crapceb.nrdconta
               cratceb.nrconven = crapceb.nrconven
               cratceb.nrcnvceb = crapceb.nrcnvceb
               cratceb.dtcadast = crapceb.dtcadast
               cratceb.cdoperad = crapceb.cdoperad
               cratceb.dssitceb = IF  crapceb.insitceb = 1  THEN
                                      "ATIVO"
                                  ELSE
                                      "INATIVO".

    END.
   
END PROCEDURE.

PROCEDURE proc_query:

    OPEN QUERY q_crapcco FOR EACH crapcco WHERE 
                                  crapcco.cdcooper = glb_cdcooper AND
                                  crapcco.flgutceb = TRUE
                                  NO-LOCK
                                  BY crapcco.nrconven.
  
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
       UPDATE b_crapcco WITH FRAME f_crapcco_b.
       LEAVE.
    END.

END.


/* ......................................................................... */
