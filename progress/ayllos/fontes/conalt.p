/* .............................................................................

   Programa: Fontes/conalt.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Fevereiro/93.                   Ultima atualizacao: 03/01/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela CONALT.

   Alteracoes: 26/03/98 - Tratamento para milenio e troca para V8 (Margarete).
        
               08/09/2004 - Tratar conta integracao (Margarete).
               
               04/10/2005 - Alterado para ler tbm codigo da cooperativa na
                            tabela crapact (Diego).
               
               03/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
              
               04/08/2009 - Alteracao do fonte para uso de BO - GATI - Peixoto
               
               05/08/2009 - Implementacao da tela para consulta 
                            de transferencia entre pacs - GATI - Peixoto
                            
               13/07/2011 - Utilizar a BO de forma generica (Guilherme).
               
               10/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               26/12/2013 - Alterado FORMAT dos campos "PA Origem", "PA Destino"
                            , "PA Atu.", "PA Ori." e "PA Des." para "999".
                            (Reinert)
                            
               03/01/2014 - Trocar Agencia por PA. (Reinert)                                                        
............................................................................. */

{ includes/var_online.i }
{ sistema/generico/includes/b1wgen0018tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }

DEFINE STREAM str_1. /* Relatorio  */   

DEFINE VARIABLE h_b1wgen0018 AS HANDLE                                NO-UNDO.
DEFINE VARIABLE tel_nrdconta AS INT      FORMAT "zzz,zzz,9"           NO-UNDO.
DEFINE VARIABLE aux_contador AS INT      FORMAT "99"                  NO-UNDO.
DEFINE VARIABLE aux_regexist AS LOGICAL                               NO-UNDO.
DEFINE VARIABLE aux_flgretor AS LOGICAL                               NO-UNDO.
DEFINE VARIABLE aux_cddopcao AS CHAR                                  NO-UNDO.

DEFINE VARIABLE tel_nrpacori AS INT      FORMAT "99"                  NO-UNDO.
DEFINE VARIABLE tel_nrpacdes AS INT      FORMAT "99"                  NO-UNDO.
DEFINE VARIABLE tel_dtperini AS DATE     FORMAT "99/99/9999"          NO-UNDO.
DEFINE VARIABLE tel_dtperfim AS DATE     FORMAT "99/99/9999"          NO-UNDO.
DEFINE VARIABLE par_cabectra AS CHAR     FORMAT "x(50)"               NO-UNDO.
DEFINE VARIABLE aux_iddopcao AS INTE                                  NO-UNDO.

DEFINE VARIABLE aux_nmendter AS CHAR                                  NO-UNDO.
DEFINE VARIABLE par_flgrodar AS LOGICAL                               NO-UNDO.
DEFINE VARIABLE aux_flgescra AS LOGICAL                               NO-UNDO.
DEFINE VARIABLE aux_dscomand AS CHAR                                  NO-UNDO.
DEFINE VARIABLE aux_nmarqimp AS CHAR                                  NO-UNDO.
DEFINE VARIABLE par_flgfirst AS LOGICAL                               NO-UNDO.
DEFINE VARIABLE tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir" NO-UNDO.
DEFINE VARIABLE tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar" NO-UNDO.
DEFINE VARIABLE par_flgcance AS LOGICAL                               NO-UNDO.

DEFINE VARIABLE tab_dsdopcao AS CHAR EXTENT 2 INIT
     ["Impressao","Cancelar"] NO-UNDO.

DEFINE TEMP-TABLE tt-opcao                                            NO-UNDO
       FIELD opcao           AS CHAR
       FIELD labelopc        AS CHAR.
EMPTY TEMP-TABLE tt-opcao.       
CREATE tt-opcao.
ASSIGN tt-opcao.opcao    = "C"
       tt-opcao.labelopc = "Consulta alteracoes de tipo de conta.".
CREATE tt-opcao.
ASSIGN tt-opcao.opcao    = "T"
       tt-opcao.labelopc = "Consulta de transferencias entre PAs.".

DEF QUERY q_trans FOR tt-transfer.
DEF BROWSE b_trans QUERY q_trans
    DISPLAY tt-transfer.nrdconta  FORMAT "zzzz,zzz,9" COLUMN-LABEL "Conta/Dv"
            tt-transfer.nmprimtl  FORMAT "x(23)"      COLUMN-LABEL "Associado"
            tt-transfer.cdageatu  FORMAT "999"        COLUMN-LABEL "PA Atu."
            tt-transfer.dtaltera  FORMAT "99/99/9999" COLUMN-LABEL "Data Alt."
            tt-transfer.cdageori  FORMAT "999"        COLUMN-LABEL "PA Ori."
            tt-transfer.cdagedes  FORMAT "999"        COLUMN-LABEL "PA Des."
            WITH 6 DOWN NO-BOX.
FORM b_trans  HELP "Use as SETAS para navegar ou F4 para sair"
     WITH ROW 10 CENTERED TITLE COLOR NORMAL par_cabectra SCROLLBAR-VERTICAL
     FRAME f_dettra OVERLAY.

DEF QUERY q_cddopcao FOR tt-opcao.
DEF BROWSE  b_opcao  QUERY q_cddopcao 
    DISPLAY tt-opcao.opcao    FORMAT "9"          COLUMN-LABEL "Opcao" 
            tt-opcao.labelopc FORMAT "x(40)"      COLUMN-LABEL "Descricao"
            WITH 2 DOWN OVERLAY.         
FORM b_opcao  HELP "Use as SETAS para navegar ou F4 para sair"
     SKIP
     WITH NO-BOX ROW 7 COLUMN 2 OVERLAY CENTERED FRAME f_opcao_b.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM SKIP(1)
     glb_cddopcao AT 5 LABEL  "Opcao"
       HELP "Informe a opcao ou tecle <F7> para listar."
            VALIDATE(CAN-DO("C,T",glb_cddopcao),
                                "014 - Opcao errada.")
     WITH ROW 4 OVERLAY 8 DOWN SIDE-LABELS 
     WIDTH 80 TITLE glb_tldatela FRAME f_cddopcao.
 
FORM SKIP(1)
     tel_nrpacori                  AT 2  FORMAT "999"
                                   LABEL "PA Origem" AUTO-RETURN
     tel_nrpacdes                  AT 25 FORMAT "999"
                                   LABEL "PA Destino"
     SKIP(1)
     tel_dtperini                  AT 2  FORMAT "99/99/9999"
                                   LABEL "Periodo"
     tel_dtperfim                  AT 25 FORMAT "99/99/9999"
                                   NO-LABEL
     SKIP(1)
     WITH ROW 5 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_contra.

FORM SKIP(1)
     tel_nrdconta                  AT  2 FORMAT "zzzz,zzz,9" 
                                   LABEL "Conta/dv" AUTO-RETURN
                                   HELP "Informe o numero da conta."
     tt-detalhe-conta.dsagenci     AT 25 FORMAT "x(21)" 
                                   LABEL "PA"
     tt-detalhe-conta.nrmatric     AT 56 FORMAT "zzz,zz9" 
                                   LABEL "Matricula"
     SKIP (1)
     tt-detalhe-conta.dstipcta     AT  2 FORMAT "x(21)" 
                                   LABEL "Tipo de Conta"
     tt-detalhe-conta.dtabtcct     AT 48 FORMAT "99/99/9999" 
                                   LABEL "Abertura da Conta"
     SKIP
     tt-detalhe-conta.nrdctitg     AT  6 
                                   LABEL "Conta/ITG"   
     tt-detalhe-conta.dssititg     NO-LABEL
     tt-detalhe-conta.dtatipct     AT 44 FORMAT "99/99/9999" 
                                   LABEL "Ult.Alt.Tipo de Conta"
     SKIP(1)
     tt-detalhe-conta.nmprimtl     AT  2 FORMAT "x(40)" 
                                   LABEL "Titular(es)"
     SKIP
     tt-detalhe-conta.nmsegntl     AT 15 FORMAT "x(40)" 
                                   NO-LABEL
     SKIP (1)
     WITH ROW 5 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_conalt.

FORM tt-alt-tip-conta.literal1     AT  2  FORMAT "x(15)"
     tt-alt-tip-conta.dtalttct     AT 18  FORMAT "99/99/9999"
     tt-alt-tip-conta.literal2     AT 29  FORMAT "x(02)"  
     tt-alt-tip-conta.dstctant     AT 32
     tt-alt-tip-conta.literal3     AT 53  FORMAT "x(04)"  
     tt-alt-tip-conta.dstctatu     AT 58
     WITH ROW 14 COLUMN 2 OVERLAY 7 DOWN NO-LABEL NO-BOX FRAME f_lanctos.

FORM SPACE(18)
     tab_dsdopcao[1]            FORMAT "x(9)"
     SPACE(2)
     tab_dsdopcao[2]            FORMAT "x(8)"
     SPACE(12)
     WITH ROW 20 CENTERED NO-BOX NO-LABELS OVERLAY FRAME f_opcoes.

FORM SKIP
     tt-transfer.nrdconta       FORMAT "zzzz,zzz,9"
                                COLUMN-LABEL "Conta/DV"
     tt-transfer.nmprimtl       FORMAT "x(50)"      
                                COLUMN-LABEL "Associado"
     tt-transfer.cdageatu       FORMAT "999"
                                COLUMN-LABEL "PA Atual"
     tt-transfer.dtaltera       FORMAT "99/99/9999" 
                                COLUMN-LABEL "Data Alt."
     tt-transfer.cdageori       FORMAT "999"
                                COLUMN-LABEL "PA Origem"
     tt-transfer.cdagedes       FORMAT "999"
                                COLUMN-LABEL "PA Destino"
     WITH DOWN NO-BOX NO-ATTR-SPACE WIDTH 133 FRAME f_rel STREAM-IO.

FORM "Aguarde... Imprimindo relatorio!"
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.
     
FORM SKIP(1)
     "ATENCAO!   Ligue a impressora e posicione o papel!" AT 3
     SKIP(1)
     tel_dsimprim AT 14
     tel_dscancel AT 29
     SKIP(1)
     WITH ROW 14 COLUMN 14 OVERLAY NO-LABELS WIDTH 56
     TITLE glb_nmformul FRAME f_atencao.

ON RETURN OF b_opcao DO:
   ASSIGN glb_cddopcao = tt-opcao.opcao.
   DISPLAY glb_cddopcao WITH FRAME f_cddopcao.
   PAUSE 0.
   APPLY "END-ERROR".
END.

ON ANY-KEY OF b_trans IN FRAME f_dettra DO:

   IF   KEYFUNCTION(LASTKEY) = "RETURN"   OR 
        KEYFUNCTION(LASTKEY) = "GO"       THEN
        DO:
            IF  aux_iddopcao = 1   THEN
                DO:
                    MESSAGE "Enviando arquivo para a impressora...".
                    ASSIGN glb_nrdevias = 1
                           par_flgrodar = TRUE.
                    FIND FIRST crapass WHERE 
                         crapass.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
                    { includes/impressao.i } 
                    HIDE MESSAGE NO-PAUSE.
                    MESSAGE "Arquivo impresso.".
                END.
            
            IF  aux_iddopcao = 2 THEN
                APPLY KEYCODE("F4").
        END.
   ELSE
   IF   KEYFUNCTION(LASTKEY) = "CURSOR-RIGHT"   THEN
        DO:
            aux_iddopcao = aux_iddopcao + 1.
            IF   aux_iddopcao > 2   THEN
                 aux_iddopcao = 1.
                             
            CHOOSE FIELD tab_dsdopcao[aux_iddopcao] PAUSE 0 
                   WITH FRAME f_opcoes.
        END.
   ELSE
   IF   KEYFUNCTION(LASTKEY) = "CURSOR-LEFT"   THEN
        DO:
            aux_iddopcao = aux_iddopcao - 1.
            IF   aux_iddopcao < 1   THEN
                 aux_iddopcao = 2.
                     
            CHOOSE FIELD tab_dsdopcao[aux_iddopcao] PAUSE 0 
                   WITH FRAME f_opcoes.
        END.
END. /* ON ANY-KEY OF b_trans IN FRAME f_dettra */

VIEW FRAME f_moldura.

PAUSE (0).

ASSIGN glb_cddopcao = "C".

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
   OPEN QUERY q_cddopcao
        FOR EACH tt-opcao NO-LOCK.

   RUN fontes/inicia.p.

   DO   WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
        UPDATE glb_cddopcao WITH FRAME f_cddopcao
        EDITING:
            READKEY.
            IF   LASTKEY = KEYCODE("F7")  THEN
                 DO:
                     RUN proc_query.
                     HIDE FRAME f_opcao_b NO-PAUSE.
                     IF   KEYFUNCTION(LASTKEY) <> "END-ERROR"   THEN
                          APPLY "GO" TO glb_cddopcao IN FRAME f_cddopcao.
                 END.
            ELSE 
                 APPLY LASTKEY.
        END. /* FIM EDITING */
        
        IF   aux_cddopcao <> glb_cddopcao   THEN
             DO:
                 { includes/acesso.i}
                 aux_cddopcao = glb_cddopcao.
             END.

        LEAVE.
   END.
   
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "CONALT"   THEN
                 DO:
                     HIDE  FRAME f_moldura.
                     HIDE  FRAME f_contra.
                     HIDE  FRAME f_dettra.
                     HIDE  FRAME f_conalt.
                     HIDE  FRAME f_lanctos.
                     
                     RETURN.
                 END.
            NEXT.
        END.
   
   IF   glb_cddopcao = "C"   THEN /* Consulta Alteracoes da conta */
        DO:
            ASSIGN tel_nrdconta = 0.
            CLEAR FRAME f_conalt.
            DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

                HIDE FRAME f_cddopcao.
                HIDE FRAME f_opcoes.

                UPDATE tel_nrdconta WITH FRAME f_conalt.

                glb_nrcalcul = tel_nrdconta.
                RUN fontes/digfun.p.

                IF   NOT glb_stsnrcal   THEN
                     DO:
                         glb_cdcritic = 8.
                         RUN fontes/critic.p.
                         BELL.
                         MESSAGE glb_dscritic.
                         CLEAR FRAME f_conalt NO-PAUSE.
                         CLEAR FRAME f_lanctos ALL NO-PAUSE.
                         NEXT-PROMPT tel_nrdconta WITH FRAME f_conalt.
                         NEXT.
                     END.

                LEAVE.

            END.  /*  Fim do DO WHILE TRUE  */
            
            RUN sistema/generico/procedures/b1wgen0018.p 
                PERSISTENT SET h_b1wgen0018.
            RUN consulta_alteracoes_tp_conta IN h_b1wgen0018
                                                (INPUT glb_cdcooper,
                                                 INPUT tel_nrdconta,
                                                 INPUT  0,
                                                 INPUT  0,
                                                 OUTPUT TABLE tt-detalhe-conta,
                                                 OUTPUT TABLE tt-alt-tip-conta,
                                                 OUTPUT TABLE tt-erro).
            DELETE PROCEDURE h_b1wgen0018.

            ASSIGN aux_flgretor = FALSE
                   aux_regexist = FALSE
                   aux_contador = 0. 

            FIND FIRST tt-detalhe-conta NO-LOCK.
            IF   AVAIL tt-detalhe-conta   THEN
                 DO:
                     DISPLAY tt-detalhe-conta.dsagenci      
                             tt-detalhe-conta.nrmatric  
                             tt-detalhe-conta.dstipcta
                             tt-detalhe-conta.dtabtcct  
                             tt-detalhe-conta.dtatipct  
                             tt-detalhe-conta.nmprimtl
                             tt-detalhe-conta.nmsegntl  
                             tt-detalhe-conta.nrdctitg  
                             tt-detalhe-conta.dssititg
                             WITH FRAME f_conalt.
                 END.            

            CLEAR FRAME f_lanctos ALL NO-PAUSE.

            FOR EACH tt-alt-tip-conta NO-LOCK:
      
                 ASSIGN aux_regexist = TRUE
                        aux_contador = aux_contador + 1.

                 IF   aux_contador = 1   THEN
                      IF   aux_flgretor   THEN
                           DO:
                               PAUSE MESSAGE
                         "Tecle <Entra> para continuar ou <Fim> para encerrar".
                               CLEAR FRAME f_lanctos ALL NO-PAUSE.
                           END.
                      ELSE
                           aux_flgretor = TRUE.

                 PAUSE (0).

                 IF   aux_contador = 1   THEN
                      DISPLAY tt-alt-tip-conta.literal1  
                              tt-alt-tip-conta.dtalttct
                              tt-alt-tip-conta.literal2  
                              tt-alt-tip-conta.dstctant
                              tt-alt-tip-conta.literal3  
                              tt-alt-tip-conta.dstctatu
                              WITH FRAME f_lanctos.
                 ELSE
                      DISPLAY tt-alt-tip-conta.dtalttct  
                              tt-alt-tip-conta.dstctant  
                              tt-alt-tip-conta.dstctatu
                              WITH FRAME f_lanctos.

                 IF   aux_contador = 7   THEN
                      aux_contador = 0.
                 ELSE
                      DOWN WITH FRAME f_lanctos.

            END.  /*  Fim do FOR EACH   */

            IF   NOT aux_regexist   THEN
                 DO:
                     glb_cdcritic = 271.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                 END.

            PAUSE.

            HIDE FRAME f_conalt.
            CLEAR FRAME f_conalt.
            
        END. /* IF   glb_cddopcao = "C" */
   ELSE
   IF   glb_cddopcao = "T"   THEN /* Consulta Transf. entre PAs */
        DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                HIDE FRAME f_cddopcao.
                HIDE MESSAGE NO-PAUSE.

                UPDATE tel_nrpacori
                       tel_nrpacdes
                       tel_dtperini
                       tel_dtperfim
                       WITH FRAME f_contra.

                MESSAGE "Verificando transferencias...". 
                RUN sistema/generico/procedures/b1wgen0018.p 
                    PERSISTENT SET h_b1wgen0018.
                RUN consulta_transf_pacs IN h_b1wgen0018
                                            (INPUT glb_cdcooper,
                                             INPUT tel_nrpacori,
                                             INPUT tel_nrpacdes,
                                             INPUT tel_dtperini,
                                             INPUT tel_dtperfim,
                                             INPUT 0,
                                             INPUT 0,
                                             OUTPUT par_cabectra,
                                             OUTPUT TABLE tt-transfer,
                                             OUTPUT TABLE tt-erro).
                DELETE PROCEDURE h_b1wgen0018.

                IF   RETURN-VALUE = "NOK"   THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                    IF   AVAIL tt-erro   THEN
                    DO:
                        BELL.
                        HIDE MESSAGE NO-PAUSE.
                        MESSAGE tt-erro.dscritic.
                        PAUSE 2 NO-MESSAGE.
                        BELL.
                        glb_cdcritic = 0.
                        NEXT-PROMPT tel_nrpacori WITH FRAME f_contra.
                        NEXT.
                    END.
                END.
     
                LEAVE.

            END.  /*  Fim do DO WHILE TRUE  */

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                 LEAVE.

            HIDE MESSAGE NO-PAUSE.

            HIDE  FRAME f_conalt. 
            CLEAR FRAME f_conalt.
            HIDE  FRAME f_lanctos.
            CLEAR FRAME f_lanctos.
            
            CLOSE QUERY q_trans.
            
            IF  aux_iddopcao = 0  THEN
                aux_iddopcao = 1.  
            DISPLAY tab_dsdopcao WITH FRAME f_opcoes.
            CHOOSE FIELD tab_dsdopcao[aux_iddopcao] PAUSE 0 
                   WITH FRAME f_opcoes.
                    
            IF   CAN-FIND(FIRST tt-transfer)   THEN
                 DO:
                     ASSIGN aux_nmarqimp = "rl/conalt.lst".
                     
                     OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGE-SIZE 84.
                     
                     PUT STREAM str_1
                                par_cabectra 
                                SKIP
                                "Periodo: " tel_dtperini
                                " ate " tel_dtperfim 
                                SKIP(2).
                                
                     FOR EACH tt-transfer BY tt-transfer.dtaltera:
                     
                         DISPLAY STREAM str_1
                                        tt-transfer.nrdconta
                                        tt-transfer.nmprimtl
                                        tt-transfer.cdageatu
                                        tt-transfer.dtaltera
                                        tt-transfer.cdageori 
                                        tt-transfer.cdagedes 
                                        WITH FRAME f_rel.
                         DOWN STREAM str_1 WITH FRAME f_rel.  
                     END.
                     OUTPUT STREAM str_1 CLOSE.
                 END.  /* IF   CAN-FIND(FIRST tt-transfer) */
                 
            OPEN QUERY q_trans
                 FOR EACH tt-transfer NO-LOCK BY tt-transfer.dtaltera.
            
            b_trans:TITLE = par_cabectra.

            ENABLE b_trans WITH FRAME f_dettra.
            APPLY "ENTRY" TO b_trans IN FRAME f_dettra.
            
            IF   KEYFUNCTION(LASTKEY) = "CURSOR-UP"      OR
                 KEYFUNCTION(LASTKEY) = "CURSOR-DOWN"    OR
                 KEYFUNCTION(LASTKEY) = "HOME"           OR
                 KEYFUNCTION(LASTKEY) = "PAGE-UP"        OR
                 KEYFUNCTION(LASTKEY) = "PAGE-DOWN"      THEN
                 IF   CAN-FIND(FIRST tt-transfer)   THEN
                      APPLY KEYFUNCTION(LASTKEY) TO 
                                       b_trans IN FRAME f_dettra.
                                       
            DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                UPDATE b_trans WITH FRAME f_dettra.
                LEAVE.
            END.  /*  Fim do DO WHILE TRUE  */

        END. /* IF   glb_cddopcao = "T" */

   HIDE  FRAME f_contra.
   CLEAR FRAME f_contra.
   HIDE  FRAME f_dettra.
   CLEAR FRAME f_dettra.
   HIDE  FRAME f_conalt.
   CLEAR FRAME f_conalt.
   HIDE  FRAME f_lanctos.
   CLEAR FRAME f_lanctos.
   HIDE  FRAME f_opcoes.
   
END.  /*  Fim do DO WHILE TRUE  */

/* ......................................................................... */

PROCEDURE proc_query:
    /* Escolher o tipo de consulta - F7 do campo glb_cddopcao */
    DO   WHILE TRUE ON ENDKEY UNDO, LEAVE:
         UPDATE b_opcao WITH FRAME f_opcao_b.
         LEAVE.
    END.
END.

