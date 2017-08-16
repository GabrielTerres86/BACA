/* ............................................................................
   Programa: fontes/dsbitg.p         
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Fernando
   Data    : Fevereiro/2009                     Ultima alteracao: 18/04/2017

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Desbloqueio conta ITG.

   Alteracao : 15/07/2009 - Alteracao CDOPERAD (Kbase).
                          - Adicionar opcoes "R" e "x" (GATI).
                          - Refeitas as opcoes "X" e "R" (Guilherme).
                          
               30/07/2010 - Acertado para atualizar sequencial quando for gerado
                            arquivo (Elton).           
                            
               04/11/2010 - Adicionar opcao "T" - Reenvio de informacoes dos 
                            titulares para o Banco do Brasil. Arquivo: COO405
                            (Joao - RKAM)
                            
               02/12/2010 - Ao finalizar operação (F8) gravar na DSBITG.LOG
                            cada registro informado (Isara - RKAM).
                            
               22/02/2011 - Corrigido controle de bloqueio do COO405 (Irlan).
               
               01/03/2011 - Inclusão das opções "W" e "Z" (Isara - RKAM).
               
               20/05/2011 - Corrigir gravação de dados na opção "W"
                            (Isara - RKAM / Irlan).
                            
               24/05/2011 - Substituido campo crapttl.nranores por 
                           crapenc.dtinires. (Fabricio)
                           
               22/06/2011 - Atribuido ao conteudo da variavel aux_dsdlinha,
                            espacos em branco ate a posicao 150, na procedure
                            proc_criarq_COO410. (Fabricio)
                           
               01/11/2011 - Corrigido erro da opção "Z" para nao desfazer a 
                            alteracao do sequencial. (Lucas)
                            
              09/12/2011 - Alterações para realizar procedimento de Encerramento 
                           da Conta ITG que não possua conta/dv (Lucas)  
                           
              01/06/2012 - Realizado manutenção na opção "R" (David Kruger). 
              
              27/07/2012 - Ajustes para Oracle (Evandro).           
              
              18/12/2012 - Correcao na opção "R" para nao sobrescrever
                           informacoes previamente cadastradas e incluso na
                           opcao "I" o gravacao de registros na CRAPALT. (Daniel).
                           
              05/02/2013 - Correcao descritivo "reenvio exclusao conta-itg", 
                           retirado acentuacao. (Daniel).                       
                           
              17/10/2013 - Substituido campo incasprp da crapttl para crapenc e
                           fixado como quitado o imovel da cooperativa. (Reinert)
                           
              05/12/2013 - Inclusao de VALIDATE crapalt e b-crapalt (Carlos)
              
              23/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)
              
              08/09/2015 - Liberado acesso a tela para departamento SUPORTE. 
                           SD 318079 (Kelvin)
                           
              01/12/2016 - Alterado campo dsdepart para cddepart.
                           PRJ341 - BANCENJUD (Odirlei-AMcom)
                           
			  18/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			               crapass, crapttl, crapjur 
						  (Adriano - P339).

              19/07/2017 - Alteraçao CDOEDTTL pelo campo IDORGEXP.
                           PRJ339 - CRM (Odirlei-AMcom)  
                           
..............................................................................*/

{ includes/var_online.i }

DEFINE STREAM str_1.
DEFINE STREAM str_2.

DEFINE VARIABLE tel_nrdctitg   LIKE crapass.nrdctitg                    NO-UNDO.
DEFINE VARIABLE tel_nrdconta   LIKE crapass.nrdconta                    NO-UNDO.
DEFINE VARIABLE tel_nrcrcard   LIKE crawcrd.nrcrcard                    NO-UNDO.
DEFINE VARIABLE aux_qtrgtab    AS INT                                   NO-UNDO.
DEFINE VARIABLE aux_nrcpfcgc   LIKE crapass.nrcpfcgc                    NO-UNDO.
DEFINE VARIABLE aux_nrcpfcgc2  LIKE crapass.nrcpfcgc                    NO-UNDO.
DEFINE VARIABLE aux_confirma   AS LOG                  FORMAT "S/N"     NO-UNDO.
DEFINE VARIABLE aux_nrtextab   AS INT                                   NO-UNDO.
DEFINE VARIABLE aux_nmarqimp   AS CHAR                 FORMAT "x(50)"   NO-UNDO.
DEFINE VARIABLE aux_dsdlinha   AS CHAR                 FORMAT "x(70)"   NO-UNDO.
DEFINE VARIABLE tel_idseqttl   LIKE crapttl.idseqttl                    NO-UNDO.
DEFINE VARIABLE tel_cddoptit   AS CHAR                 FORMAT "!"       NO-UNDO.

DEFINE VARIABLE aux_contador   AS INTE                                  NO-UNDO.
DEFINE VARIABLE aux_dscritic   AS CHAR                                  NO-UNDO.
DEFINE VARIABLE aux_flgalter   AS LOGI                                  NO-UNDO.
DEFINE VARIABLE aux_nrregist   AS INT                                   NO-UNDO.
DEFINE VARIABLE aux_nrtotcli   AS INT                                   NO-UNDO.
DEFINE VARIABLE aux_nrcctitg   AS CHAR                                  NO-UNDO.
DEFINE VARIABLE aux_nrcpftit   LIKE crawcrd.nrcpftit                    NO-UNDO.
DEFINE VARIABLE aux_criarlog   AS LOG                                   NO-UNDO.
DEFINE VARIABLE aux_flggrava   AS LOG                                   NO-UNDO.
DEFINE VARIABLE aux_cont       AS INTE                                  NO-UNDO. 

DEFINE VARIABLE tmp_dsaltera   AS CHARACTER                             NO-UNDO.
DEFINE VARIABLE tmp_nrdrowid   AS ROWID                                 NO-UNDO.

DEF    VAR aux_dadosusr AS CHAR                                         NO-UNDO.
DEF    VAR par_loginusr AS CHAR                                         NO-UNDO.
DEF    VAR par_nmusuari AS CHAR                                         NO-UNDO.
DEF    VAR par_dsdevice AS CHAR                                         NO-UNDO.
DEF    VAR par_dtconnec AS CHAR                                         NO-UNDO.
DEF    VAR par_numipusr AS CHAR                                         NO-UNDO.
DEF    VAR h-b1wgen9999 AS HANDLE                                       NO-UNDO.
DEF    VAR h-b1wgen0052b AS HANDLE                                      NO-UNDO.


DEFINE NEW SHARED VARIABLE shr_inpessoa      AS INT                     NO-UNDO.

DEFINE TEMP-TABLE w_ctitg                                               NO-UNDO
       FIELD  nrdctitg   LIKE  crapass.nrdctitg
       FIELD  nrcpfcgc   LIKE  crapass.nrcpfcgc
       FIELD  nrcpfcgc2  LIKE  crapass.nrcpfcgc
       FIELD  nrdconta   LIKE  crapass.nrdconta
       FIELD  cddopcao   AS CHAR
       FIELD  idseqttl   LIKE  crapttl.idseqttl
       FIELD  cddoptit   AS CHAR FORMAT "!" /* Opcao p/ Titular */
       FIELD  nrcrcard   LIKE crawcrd.nrcrcard
       FIELD  nrcctitg   AS CHAR.

DEFINE BUFFER w_ctitgb FOR w_ctitg.
DEFINE BUFFER b-crapalt FOR crapalt.

FORM SPACE (1)
     WITH ROW 4 DOWN WIDTH 80 WITH TITLE glb_tldatela FRAME f_moldura.

FORM SKIP
     SKIP(1)
     glb_cddopcao LABEL "Opcao"  FORMAT "!(1)" AUTO-RETURN   AT 04
     HELP "Informe I-Inc./E-Elim./X-Ativ.ITG/R-Reenv./T-Tit./W-Reat./Z-Encer."
                VALIDATE(CAN-DO("I,E,X,R,T,W,Z",glb_cddopcao),
                                    "014 - Opcao errada.")
     SKIP(1)
     WITH ROW 05 CENTERED OVERLAY NO-LABELS SIDE-LABELS WIDTH 75
     NO-BOX FRAME f_opcao.
     
FORM SKIP     
     "Conta ITG"                                             AT 07
     "CPF primeiro titular"                                  AT 22
     "CPF segundo titular"                                   AT 48
     SKIP(1)
     tel_nrdctitg    FORMAT "x.xxx.xxx-x"                    AT 07
                     HELP "Informe a conta ITG ou <F8> para finalizar."
     aux_nrcpfcgc                                            AT 24
     aux_nrcpfcgc2                                           AT 50
     WITH ROW 08 CENTERED OVERLAY NO-LABELS SIDE-LABELS WIDTH 75 
     NO-BOX FRAME f_dsbitg.
    
FORM SKIP
     w_ctitg.nrdctitg                                        AT 07
     w_ctitg.nrcpfcgc                                        AT 24
     w_ctitg.nrcpfcgc2                                       AT 50
     WITH ROW 12 CENTERED OVERLAY 8 DOWN SIDE-LABELS NO-LABELS WIDTH 75  
     NO-BOX FRAME f_list.

FORM SKIP
     w_ctitg.nrdctitg                                        AT 23
     WITH ROW 12 CENTERED OVERLAY 8 DOWN SIDE-LABELS NO-LABELS WIDTH 75  
     NO-BOX FRAME f_list2.

VIEW FRAME f_moldura.

FORM SKIP 
     "Conta"                                                 AT 07
     "Conta ITG"                                             AT 24
     SKIP(1)
     tel_nrdconta    HELP "Informe a conta/dv do associado"  AT 07
     tel_nrdctitg    FORMAT "x.xxx.xxx-x"                    AT 23
                     HELP "Informe a conta ITG do associado"
                     
     WITH ROW 08 CENTERED OVERLAY NO-LABELS SIDE-LABELS WIDTH 75 
     NO-BOX FRAME f_dsbitg2.

FORM SKIP
     w_ctitg.cddoptit                                        AT 07
     w_ctitg.nrdconta                                        AT 17
     w_ctitg.nrdctitg                                        AT 33
     w_ctitg.idseqttl                                        AT 49
     w_ctitg.nrcpfcgc                                        AT 57
     WITH ROW 12 CENTERED OVERLAY 8 DOWN SIDE-LABELS NO-LABELS WIDTH 75  
     NO-BOX FRAME f_list_tit.

VIEW FRAME f_moldura.

FORM SKIP
     "Opçao"                                                 AT 07
     "Conta"                                                 AT 20
     "Conta ITG"                                             AT 34
     "Titular"                                               AT 49
     "CPF"                                                   AT 62
     SKIP(1)
     tel_cddoptit    AUTO-RETURN                             AT 07
                     HELP "I-Inclui/E-Elimina ou <F8> P/ Finalizar"
     tel_nrdconta    HELP "Informe a conta/dv do associado"  AT 17
     tel_nrdctitg    FORMAT "x.xxx.xxx-x"                    AT 33
                     HELP "Informe a conta ITG do associado"
     tel_idseqttl    HELP "Informe a sequencia do titular"   AT 49
     aux_nrcpfcgc                                            AT 57
     WITH ROW 08 CENTERED OVERLAY NO-LABELS SIDE-LABELS WIDTH 75 
     NO-BOX FRAME f_dsbitg3.

FORM SKIP
     w_ctitg.nrdconta                                        AT 07
     w_ctitg.nrdctitg                                        AT 18
     w_ctitg.nrcpfcgc                                        AT 30
     w_ctitg.nrcrcard                                        AT 45
     WITH ROW 12 CENTERED OVERLAY 8 DOWN SIDE-LABELS NO-LABELS WIDTH 75  
     NO-BOX FRAME f_list_tit2.

VIEW FRAME f_moldura.

FORM SKIP
     "Conta"                                                 AT 07
     "Conta ITG"                                             AT 18
     "CPF"                                                   AT 30
     "Cartao"                                                AT 45
     SKIP(1)
     tel_nrdconta    HELP "Informe a conta/dv do associado"  AT 07
     tel_nrdctitg    FORMAT "x.xxx.xxx-x"                    AT 18
                     HELP "Informe a conta ITG do associado"
     aux_nrcpfcgc                                            AT 30
     tel_nrcrcard                                            AT 45
     WITH ROW 08 CENTERED OVERLAY NO-LABELS SIDE-LABELS WIDTH 75 
     NO-BOX FRAME f_dsbitg4.

FORM SKIP
     w_ctitg.nrdconta                                        AT 07
     w_ctitg.nrdctitg                                        AT 20
     w_ctitg.nrcrcard                                        AT 33
     WITH ROW 12 CENTERED OVERLAY 8 DOWN SIDE-LABELS NO-LABELS WIDTH 75  
     NO-BOX FRAME f_list_tit3.

VIEW FRAME f_moldura.

FORM SKIP
     "Conta"                                                 AT 07
     "Conta ITG"                                             AT 20
     "Cartao"                                                AT 33
     SKIP(1)
     tel_nrdconta    HELP "Informe a conta/dv do associado"  AT 07
     tel_nrdctitg    FORMAT "x.xxx.xxx-x"                    AT 20
                     HELP "Informe a conta ITG do associado"
     tel_nrcrcard                                            AT 33
     WITH ROW 08 CENTERED OVERLAY NO-LABELS SIDE-LABELS WIDTH 75 
     NO-BOX FRAME f_dsbitg5.
   
PAUSE(0).

ASSIGN glb_cdcritic = 0.

RUN fontes/inicia.p.

do-opcao:
DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

    glb_cddopcao = "I".
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:  
        UPDATE glb_cddopcao WITH FRAME f_opcao.
        
        IF glb_cddepart <> 20 AND  /* TI      */
           glb_cddepart <>  2 AND  /* CARTOES */
           glb_cddepart <> 18 THEN /* SUPORTE */
        DO:
            glb_cdcritic = 36.
            RUN fontes/critic.p.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            PAUSE 2 NO-MESSAGE.
            NEXT.
        END.
        
        LEAVE.
    END. /* FIM - DO WHILE TRUE ON ENDKEY UNDO, LEAVE */
    
    /*   F4 OU FIM   */
    IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN    
    DO:
        ASSIGN aux_confirma = NO.
           
        FIND FIRST w_ctitg NO-LOCK WHERE w_ctitg.cddopcao <> "W" NO-ERROR.
        IF AVAIL w_ctitg THEN
        DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                ASSIGN aux_confirma = NO.
                MESSAGE "Atencao! Saindo da tela"
                        "sem efetivar a operacao da opcao: " +
                        QUOTER(w_ctitg.cddopcao) + ".".
                MESSAGE COLOR NORMAL "Deseja sair? (S/N)"
                        UPDATE aux_confirma AUTO-RETURN.
                LEAVE.
            END. /* FIM - DO WHILE TRUE ON ENDKEY UNDO, LEAVE */
                  
            IF KEYFUNCTION(LASTKEY) = "END-ERROR" OR
               aux_confirma         = NO          THEN
                NEXT.
            ELSE 
            DO:
                EMPTY TEMP-TABLE w_ctitg.
                ASSIGN aux_qtrgtab = 0.
                CLEAR FRAME f_list      ALL NO-PAUSE.
                CLEAR FRAME f_list_tit  ALL NO-PAUSE.
                CLEAR FRAME f_list_tit2 ALL NO-PAUSE.
                CLEAR FRAME f_list_tit3 ALL NO-PAUSE.
            END.
        END.
        
        RUN fontes/novatela.p.
        
        IF glb_nmdatela <> "DSBITG" THEN
        DO:
            HIDE FRAME f_dsbitg    NO-PAUSE.
            HIDE FRAME f_dsbitg2   NO-PAUSE.
            HIDE FRAME f_dsbitg3   NO-PAUSE.
            HIDE FRAME f_dsbitg4   NO-PAUSE.
            HIDE FRAME f_dsbitg5   NO-PAUSE.
            HIDE FRAME f_list      NO-PAUSE.
            HIDE FRAME f_list2      NO-PAUSE.
            HIDE FRAME f_list_tit  NO-PAUSE.
            HIDE FRAME f_list_tit2 NO-PAUSE.
            HIDE FRAME f_list_tit3 NO-PAUSE.
            HIDE FRAME f_moldura.
            RETURN.
        END.
        ELSE
            NEXT.
    END.
    
    FIND craptab NO-LOCK 
   WHERE craptab.cdcooper = glb_cdcooper   
     AND craptab.nmsistem = "CRED"         
     AND craptab.tptabela = "GENERI"       
     AND craptab.cdempres = 0              
     AND craptab.cdacesso = "NRARQMVITG"   
     AND craptab.tpregist = 409 NO-ERROR.
    IF NOT AVAILABLE craptab THEN
    DO:
        glb_cdcritic = 393.
        RUN fontes/critic.p.
        MESSAGE glb_cdcritic.
        PAUSE 2 NO-MESSAGE.
        NEXT.
    END.
    
    FIND crapcop 
   WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
    IF NOT AVAILABLE crapcop THEN
    DO:
        glb_cdcritic = 651.
        RUN fontes/critic.p.
        MESSAGE glb_dscritic.
        glb_cdcritic = 0.
        PAUSE 2 NO-MESSAGE.
        NEXT.
    END.
     
    IF INT(SUBSTR(craptab.dstextab,07,01)) = 1  AND glb_cddopcao <> "T" THEN
    DO:
        MESSAGE "Programa bloqueado para enviar arquivos.".
        PAUSE 2 NO-MESSAGE.
        NEXT.
    END.
    
        IF glb_cddopcao = "I" THEN
    DO:
        ASSIGN aux_confirma = NO.
       
        FIND FIRST w_ctitg 
             WHERE w_ctitg.cddopcao <> "I" NO-LOCK NO-ERROR.
        IF AVAIL w_ctitg THEN
        DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                ASSIGN aux_confirma = NO.
                MESSAGE "Atencao! Saindo da opcao "
                        QUOTER(w_ctitg.cddopcao)
                        " sem efetivar a operacao.".
                MESSAGE COLOR NORMAL "Deseja continuar? (S/N)"
                        UPDATE aux_confirma AUTO-RETURN.
                LEAVE.
            END. /* FIM - DO WHILE TRUE ON ENDKEY UNDO, LEAVE */
       
            IF KEYFUNCTION(LASTKEY) = "END-ERROR" OR
               aux_confirma         = NO          THEN
                NEXT.
            ELSE 
            DO:
                EMPTY TEMP-TABLE w_ctitg.
                ASSIGN aux_qtrgtab = 0.
                CLEAR FRAME f_list      ALL NO-PAUSE.
                CLEAR FRAME f_list_tit  ALL NO-PAUSE.
                CLEAR FRAME f_list_tit2 ALL NO-PAUSE.
                CLEAR FRAME f_list_tit3 ALL NO-PAUSE.
            END.
        END.
    
        ASSIGN tel_nrdctitg:HELP IN FRAME f_dsbitg = 
                     "Informe a conta ITG ou tecle <F8> para finalizar."
               tel_nrdctitg = "".
    
        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            IF glb_cdcritic > 0 THEN
            DO:
                RUN fontes/critic.p.
                MESSAGE glb_dscritic.
                glb_cdcritic = 0.
                PAUSE 2 NO-MESSAGE.
            END.
            
            ASSIGN aux_flgalter = FALSE.
    
            UPDATE tel_nrdctitg WITH FRAME f_dsbitg
            EDITING:
                READKEY.
    
                IF LASTKEY = KEYCODE("F8") THEN
                DO:
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        ASSIGN aux_confirma = FALSE
                               glb_cdcritic = 78.
                        RUN fontes/critic.p.
                        HIDE MESSAGE NO-PAUSE.
                        glb_cdcritic = 0.
                        MESSAGE glb_dscritic UPDATE aux_confirma.
                        LEAVE.
                    END. /* FIM - DO WHILE TRUE ON ENDKEY UNDO, LEAVE */
                
                    IF KEYFUNCTION(LASTKEY) = "END-ERROR" OR
                       NOT aux_confirma                   THEN
                    DO:
                        glb_cdcritic = 79.
                        NEXT.
                    END.
    
                    RUN proc_criarq.
    
                    /** Necessario para nao desfazer a 
                        alteracao do sequencial **/ 
                    ASSIGN aux_flgalter = TRUE. 
                    LEAVE. 
                END.                
                ELSE
                    APPLY LASTKEY.
            END. /*** Fim do EDITING ***/             
           
            IF aux_flgalter = TRUE THEN
                NEXT.

            DO WHILE LENGTH(tel_nrdctitg) < 8:
                tel_nrdctitg = "0" + tel_nrdctitg.
            END.
            
            DISPLAY tel_nrdctitg WITH FRAME f_dsbitg.
            
            RUN proc_validaitg.
            
            IF glb_cdcritic > 0 THEN
                NEXT.
            
            IF aux_qtrgtab = 8 THEN
            DO:
                HIDE MESSAGE NO-PAUSE.
                MESSAGE "Nao podem ser inseridas mais de 8 contas.".
                PAUSE 2 NO-MESSAGE.
                NEXT.
            END.
            
            IF CAN-FIND(w_ctitg WHERE 
                        w_ctitg.nrdctitg = tel_nrdctitg) THEN
            DO:
                MESSAGE "Conta ITG ja foi adicionada.".
                PAUSE 2 NO-MESSAGE.
                NEXT.
            END.
            
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                UPDATE aux_nrcpfcgc  
                       aux_nrcpfcgc2 WITH FRAME f_dsbitg.
                
                RUN proc_nrcpfcgc (INPUT aux_nrcpfcgc).
                
                IF RETURN-VALUE = "NOK" THEN
                    NEXT.
                
                IF aux_nrcpfcgc2 <> 0 THEN
                DO:
                    RUN proc_nrcpfcgc (INPUT aux_nrcpfcgc2).
                
                    IF RETURN-VALUE = "NOK" THEN
                    DO:
                        NEXT-PROMPT aux_nrcpfcgc2 
                        WITH FRAME f_dsbitg.
                        NEXT.
                    END.
                END.
            
                LEAVE.  
            END. /* FIM - DO WHILE TRUE ON ENDKEY UNDO, LEAVE */
                  
            IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
            DO:
                ASSIGN  aux_nrcpfcgc  = 0
                        aux_nrcpfcgc2 = 0.
                DISPLAY aux_nrcpfcgc  
                        aux_nrcpfcgc2 WITH FRAME f_dsbitg.
                NEXT.             
            END.
            
            CREATE w_ctitg.
            ASSIGN w_ctitg.nrdctitg  = tel_nrdctitg
                   w_ctitg.nrcpfcgc  = aux_nrcpfcgc
                   w_ctitg.nrcpfcgc2 = aux_nrcpfcgc2
                   w_ctitg.cddopcao  = glb_cddopcao
                   aux_qtrgtab       = aux_qtrgtab + 1.
             
            DISPLAY w_ctitg.nrdctitg  AT 07 
                    w_ctitg.nrcpfcgc  AT 24
                    w_ctitg.nrcpfcgc2 At 50 
                    WITH FRAME f_list.
            
            DOWN WITH FRAME f_list.
            
            ASSIGN tel_nrdctitg  = ""
                   aux_nrcpfcgc  = 0
                   aux_nrcpfcgc2 = 0.
            
            DISPLAY  tel_nrdctitg  " "@ aux_nrcpfcgc
                     " "@  aux_nrcpfcgc2  
                     WITH FRAME f_dsbitg.
            
        END. /* FIM - DO WHILE TRUE ON ENDKEY UNDO, LEAVE */
    END. /* glb_cddopcao = "I" */
    ELSE
    IF glb_cddopcao = "E" THEN
    DO:
        ASSIGN tel_nrdctitg:HELP IN FRAME f_dsbitg = "Informe a conta ITG."
               tel_nrdctitg = "".
        
        FIND FIRST w_ctitg 
             WHERE w_ctitg.cddopcao = "I" NO-LOCK NO-ERROR.
        IF AVAIL w_ctitg THEN
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                UPDATE tel_nrdctitg WITH FRAME f_dsbitg.
       
                DO WHILE LENGTH(tel_nrdctitg) < 8:
                    tel_nrdctitg = "0" + tel_nrdctitg.
                END.
                                  
                DISPLAY tel_nrdctitg WITH FRAME f_dsbitg.
                             
                RUN proc_validaitg.

                IF glb_cdcritic > 0 THEN
                DO:
                    RUN fontes/critic.p.
                    MESSAGE glb_dscritic.
                    glb_cdcritic = 0.
                    PAUSE 2 NO-MESSAGE.
                    NEXT.
                END.
                
                FIND w_ctitg EXCLUSIVE-LOCK 
               WHERE w_ctitg.nrdctitg = tel_nrdctitg  
                 AND w_ctitg.cddopcao = "I" NO-ERROR.
                IF NOT AVAILABLE w_ctitg THEN
                DO:
                    MESSAGE "Conta ITG nao incluida.".
                    PAUSE 2 NO-MESSAGE.
                    NEXT.
                END.
             
                DELETE w_ctitg.
                aux_qtrgtab = aux_qtrgtab - 1.
                CLEAR FRAME f_list ALL NO-PAUSE.
         
                FOR EACH w_ctitg 
                   WHERE w_ctitg.cddopcao = "I" NO-LOCK:

                    DISPLAY  w_ctitg.nrdctitg   
                             w_ctitg.nrcpfcgc
                             w_ctitg.nrcpfcgc2  
                             WITH FRAME f_list.
                    DOWN WITH FRAME f_list.         
                END.
            END. /* FIM - DO WHILE TRUE ON ENDKEY UNDO, LEAVE */
    END. /* glb_cddopcao = "E" */
    ELSE  
    IF glb_cddopcao = "X" THEN
    DO:
        ASSIGN aux_confirma = NO.
           
        FIND FIRST w_ctitg NO-LOCK NO-ERROR.
        IF AVAIL w_ctitg THEN
        DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                ASSIGN aux_confirma = NO.
                MESSAGE "Atencao! Saindo da opcao "
                        QUOTER(w_ctitg.cddopcao)
                        " sem efetivar a operacao.".
                MESSAGE COLOR NORMAL "Deseja continuar? (S/N)"
                        UPDATE aux_confirma AUTO-RETURN.
                LEAVE.
            END. /* FIM - DO WHILE TRUE ON ENDKEY UNDO, LEAVE */
                  
            IF KEYFUNCTION(LASTKEY) = "END-ERROR" OR
               aux_confirma         = NO          THEN
                NEXT.
            ELSE 
            DO:
                EMPTY TEMP-TABLE w_ctitg.
                ASSIGN aux_qtrgtab = 0.
                CLEAR FRAME f_list      ALL NO-PAUSE.
                CLEAR FRAME f_list_tit  ALL NO-PAUSE.
                CLEAR FRAME f_list_tit2 ALL NO-PAUSE.
                CLEAR FRAME f_list_tit3 ALL NO-PAUSE.
            END.
        END.
        
        DO WHILE TRUE:
            ASSIGN tel_nrdconta = 0 
                   tel_nrdctitg = "".

            DISPLAY tel_nrdconta 
                    tel_nrdctitg WITH FRAME f_dsbitg2.       

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
                UPDATE tel_nrdconta WITH FRAME f_dsbitg2.
                     
                FIND crapass NO-LOCK 
               WHERE crapass.cdcooper = glb_cdcooper 
                 AND crapass.nrdconta = tel_nrdconta NO-ERROR.
                IF AVAIL crapass         AND 
                   crapass.nrdctitg = "" AND
                  (crapass.flgctitg = 0  OR
                   crapass.flgctitg = 1  OR 
                   crapass.flgctitg = 4) THEN
                DO: 
                END. 
                ELSE 
                DO:
                    HIDE MESSAGE NO-PAUSE.
                    IF  AVAIL crapass   THEN
                    MESSAGE "Operacao nao disponivel para esta conta.".
                    ELSE
                    MESSAGE "Conta/dv inexsistente.".
                    tel_nrdconta = 0.
                    DISPLAY tel_nrdconta WITH FRAME f_dsbitg2.
                    NEXT.
                END.
                
                LEAVE.
            END. /* FIM - DO WHILE TRUE ON ENDKEY UNDO, LEAVE */
        
            IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
            DO:
                tel_nrdconta = 0.
                DISPLAY tel_nrdconta WITH FRAME f_dsbitg2.
                LEAVE.             
            END.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                UPDATE tel_nrdctitg WITH FRAME f_dsbitg2.       
        
                DO WHILE LENGTH(tel_nrdctitg) < 8:
                    tel_nrdctitg = "0" + tel_nrdctitg.
                END.
                
                IF tel_nrdctitg = "00000000"  OR
                   tel_nrdctitg = ""          THEN
                DO:
                    MESSAGE "Informe a conta ITG.".
                    NEXT-PROMPT tel_nrdctitg WITH FRAME f_dsbitg2.
                    NEXT.
                END.
                ELSE
                DO:
                    FIND crapass NO-LOCK
                   WHERE crapass.cdcooper = glb_cdcooper 
                     AND crapass.nrdctitg = tel_nrdctitg NO-ERROR.  
                    IF AVAIL crapass THEN
                    DO:
                        MESSAGE "Conta ITG registrada para " +
                                "conta/dv: " +
                                STRING(crapass.nrdconta,
                                       "zzzz,zz9,9") + ".".
                        NEXT.
                    END.
                END.

                LEAVE.
            END. /* FIM - DO WHILE TRUE ON ENDKEY UNDO, LEAVE */
    
            IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
            DO:
                tel_nrdctitg = "".
                NEXT-PROMPT tel_nrdctitg WITH FRAME f_dsbitg2.
                NEXT.
            END.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                ASSIGN  aux_confirma = FALSE
                        glb_cdcritic = 78.
                RUN fontes/critic.p.
                HIDE MESSAGE NO-PAUSE.
                glb_cdcritic = 0.
                MESSAGE glb_dscritic UPDATE aux_confirma.
                LEAVE.
            END. /* FIM - DO WHILE TRUE ON ENDKEY UNDO, LEAVE */
                    
            IF KEYFUNCTION(LASTKEY) = "END-ERROR" OR
               NOT aux_confirma                   THEN
            DO:
                MESSAGE "Operacao nao efetuada.".
                NEXT.
            END.
                 
            DO aux_contador = 1 TO 10: 

                FIND FIRST crapass EXCLUSIVE-LOCK 
                     WHERE crapass.cdcooper = glb_cdcooper 
                       AND crapass.nrdconta = tel_nrdconta NO-ERROR NO-WAIT.
                IF AVAIL crapass         AND
                   crapass.nrdctitg = "" AND
                  (crapass.flgctitg = 1  OR 
                   crapass.flgctitg = 4) THEN
                DO:
                    ASSIGN crapass.nrdctitg = tel_nrdctitg
                           crapass.flgctitg = 2
                           crapass.dtabcitg = glb_dtmvtolt.
            
                    UNIX SILENT VALUE("echo " +
                                     STRING(TODAY,"99/99/9999") + " " +
                                     STRING(TIME,"HH:MM:SS") + 
                                     "' --> '"  +
                                     " Operador " + glb_cdoperad +
                                     " Ativou a conta ITG " + 
                                     STRING(crapass.nrdctitg) + 
                                     " da conta/dv " +
                                     STRING(crapass.nrdconta,
                                            "zzzz,zz9,9") +
                                     " >> log/dsbitg.log").  
                END.
                ELSE
                DO:
                    IF LOCKED crapass THEN
                    DO:
                        aux_dscritic = "Registro de associado " +
                                       "esta em uso no momento." +
                                       " Tente novamente.".
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
                    ELSE
                    DO:
                        aux_dscritic = "Registro de associado " +
                                       "nao encontrado.".
                        PAUSE 1 NO-MESSAGE.
                        LEAVE.
                    END.
                END.
            
                ASSIGN aux_dscritic = "".
                LEAVE.
            END.
            
            IF aux_dscritic <> "" THEN
            DO:
                MESSAGE aux_dscritic.
                NEXT.
            END.         
            
            FOR EACH crapeca EXCLUSIVE-LOCK
               WHERE crapeca.cdcooper = glb_cdcooper 
                 AND crapeca.nrdconta = tel_nrdconta:
                                   
                DELETE crapeca.
            END.
            
            ASSIGN tel_nrdconta = 0
                   tel_nrdctitg = "".
             
            DISPLAY tel_nrdconta  "" @ tel_nrdctitg
                    WITH FRAME f_dsbitg2.
            
            MESSAGE "Operacao concluida.".

            LEAVE.
        END. /* FIM - DO WHILE TRUE */
    END. /* glb_cddopcao = "E" */
    ELSE
    IF glb_cddopcao = "R"  THEN 
    DO:
        ASSIGN aux_confirma = NO.
        FIND FIRST w_ctitg NO-LOCK NO-ERROR.
        
        IF AVAIL w_ctitg THEN
        DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                ASSIGN aux_confirma = NO.
                MESSAGE "Atencao! Saindo da opcao "
                        QUOTER(w_ctitg.cddopcao)
                        " sem efetivar a operacao.".
                MESSAGE COLOR NORMAL "Deseja continuar? (S/N)"
                        UPDATE aux_confirma AUTO-RETURN.
                LEAVE.
            END. /* FIM - DO WHILE TRUE ON ENDKEY UNDO, LEAVE */
                   
            IF KEYFUNCTION(LASTKEY) = "END-ERROR" OR
               aux_confirma         = NO          THEN
                NEXT.
            ELSE 
            DO:
                EMPTY TEMP-TABLE w_ctitg.
                ASSIGN aux_qtrgtab = 0.
                CLEAR FRAME f_list      ALL NO-PAUSE.
                CLEAR FRAME f_list2     ALL NO-PAUSE.
                CLEAR FRAME f_list_tit  ALL NO-PAUSE.
                CLEAR FRAME f_list_tit2 ALL NO-PAUSE.
                CLEAR FRAME f_list_tit3 ALL NO-PAUSE.
            END.
        END.
       
        DO WHILE TRUE ON ENDKEY UNDO, LEAVE :
            
            ASSIGN tel_nrdconta = 0 
                   tel_nrdctitg = ""
                   aux_flgalter = FALSE.
    
            DISPLAY tel_nrdconta 
                    tel_nrdctitg WITH FRAME f_dsbitg2.
 
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                UPDATE tel_nrdconta WITH FRAME f_dsbitg2.

                IF tel_nrdconta <> 0 THEN
                 DO:
                    ASSIGN tel_nrdctitg:HELP IN FRAME f_dsbitg2 = 
                    "Informe a conta ITG do associado"

                    tel_nrdctitg = "".
                    FIND crapass NO-LOCK 
                            WHERE crapass.cdcooper = glb_cdcooper AND
                                  crapass.nrdconta = tel_nrdconta NO-ERROR.

                    IF NOT AVAIL crapass THEN   
                        DO:
                           HIDE MESSAGE NO-PAUSE.
                           MESSAGE "Conta/dv inexistente.".
                           DISPLAY tel_nrdconta WITH FRAME f_dsbitg2.
                           NEXT.
                        END.
                 END.
                 LEAVE.
            END. /*FIM - DO WHILE TRUE ON ENDKEY UNDO, LEAVE */

            IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
            DO:
                tel_nrdconta = 0.
                DISPLAY tel_nrdconta WITH FRAME f_dsbitg2.
                LEAVE.
            END.

            DO WHILE tel_nrdconta = 0:
              /* Executa a PROCEDURE para o Encerramento conta ITG que não possui conta/dv
                 e, no processo, gera o arquivo COO409 */
                 RUN encerra_conta_itg.
                 
                 IF aux_confirma OR aux_flgalter THEN
                    DO:
                        EMPTY TEMP-TABLE w_ctitg.
                        ASSIGN aux_qtrgtab = 0.
                        CLEAR FRAME f_list2 ALL NO-PAUSE.
                        LEAVE.
                    END.
            
                 FIND FIRST w_ctitg NO-LOCK NO-ERROR.
                 IF AVAIL w_ctitg THEN
                     DO:
                         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                             ASSIGN aux_confirma = NO.
                             MESSAGE "Atencao! Saindo da opcao "
                             QUOTER(w_ctitg.cddopcao)
                              " sem efetivar a operacao.".
                             MESSAGE COLOR NORMAL "Deseja continuar? (S/N)"
                             UPDATE aux_confirma AUTO-RETURN.
                             LEAVE.
                         END. /* FIM - DO WHILE TRUE ON ENDKEY UNDO, LEAVE */
                   
                         IF KEYFUNCTION(LASTKEY) = "END-ERROR" OR
                         aux_confirma         = NO          THEN
                         DO:
                             EMPTY TEMP-TABLE w_ctitg.
                             ASSIGN aux_qtrgtab = 0.
                             CLEAR FRAME f_list2 ALL NO-PAUSE.
                             LEAVE.
                         END.
                     END.
                     ELSE 
                         LEAVE.  
            END.

            IF tel_nrdconta <> 0 THEN DO:
                            
                 ASSIGN aux_qtrgtab = 0.
                 EMPTY TEMP-TABLE w_ctitg.
                 CLEAR FRAME f_list2      ALL NO-PAUSE.           

                 IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                 DO:
                     tel_nrdconta = 0.
                     DISPLAY tel_nrdconta WITH FRAME f_dsbitg2.
                     LEAVE.
                 END.
    
                 DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
                     UPDATE tel_nrdctitg WITH FRAME f_dsbitg2.       
                     DO WHILE LENGTH(tel_nrdctitg) < 8:
                         tel_nrdctitg = "0" + tel_nrdctitg.
                     END.                    
                     
                     IF tel_nrdctitg = "00000000"  OR
                        tel_nrdctitg = ""          THEN
                     DO:
                         MESSAGE "Informe a conta ITG.".
                         NEXT-PROMPT tel_nrdctitg WITH FRAME f_dsbitg2.
                         NEXT.
                     END.
                     ELSE
                     DO:
                         FIND crapass NO-LOCK 
                                WHERE crapass.cdcooper = glb_cdcooper AND
                                      crapass.nrdctitg = tel_nrdctitg NO-ERROR.
                         IF NOT AVAIL crapass THEN
                         DO:
                             MESSAGE "Conta ITG inexistente.".
                             NEXT.
                         END.
                         ELSE
                             IF tel_nrdconta <> crapass.nrdconta THEN
                             DO:
                                 MESSAGE "Conta ITG registrada para " +
                                         "conta/dv: " +
                                         STRING(crapass.nrdconta,
                                                "zzzz,zz9,9") + ".".
                                 NEXT.
                             END.
                     END.
                 LEAVE.
                 END. /* FIM - DO WHILE TRUE ON ENDKEY UNDO, LEAVE */
    
            IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
            DO:
                tel_nrdctitg = "".
                NEXT-PROMPT tel_nrdctitg WITH FRAME f_dsbitg2.
                NEXT.
            END.
    
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                ASSIGN  aux_confirma = FALSE
                        glb_cdcritic = 78.
                RUN fontes/critic.p.
                HIDE MESSAGE NO-PAUSE.
                glb_cdcritic = 0.
                MESSAGE glb_dscritic UPDATE aux_confirma.
                LEAVE.
            END. /* FIM - DO WHILE TRUE ON ENDKEY UNDO, LEAVE */
                    
            IF KEYFUNCTION(LASTKEY) = "END-ERROR" OR
               NOT aux_confirma                   THEN
            DO:
                MESSAGE "Operacao nao efetuada.".
                NEXT.
            END.
                 
            ASSIGN aux_flgalter = FALSE. 

            tmp_nrdrowid = ?.

            FOR EACH crapalt WHERE crapalt.cdcooper = glb_cdcooper  AND
                                   crapalt.nrdconta = tel_nrdconta  NO-LOCK.

                    tmp_dsaltera = crapalt.dsaltera.

                    IF  tmp_dsaltera MATCHES "*exclusao conta-itg*"  THEN
                        DO:
                            tmp_nrdrowid = ROWID(crapalt).
                            LEAVE.
                        END.

            END.

            IF  tmp_nrdrowid <> ?  THEN
                FIND crapalt WHERE ROWID(crapalt) = tmp_nrdrowid NO-LOCK NO-ERROR.

            /*
            FIND LAST crapalt WHERE crapalt.cdcooper = glb_cdcooper  AND
                                    crapalt.nrdconta = tel_nrdconta  AND
                                    crapalt.dsaltera MATCHES "*exclusao conta-itg*" 
                                    NO-LOCK NO-ERROR. */
                                    
            IF AVAIL crapalt THEN  
                DO:
                    DO aux_cont = 1 TO 10.   
                
                       FIND b-crapalt WHERE 
                            b-crapalt.cdcooper = crapalt.cdcooper  AND
                            b-crapalt.nrdconta = crapalt.nrdconta  AND
                            b-crapalt.dtaltera = crapalt.dtaltera 
                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                    
                       IF  NOT AVAILABLE b-crapalt THEN
                           IF LOCKED b-crapalt THEN
                              DO:
                                    RUN sistema/generico/procedures/b1wgen9999.p
                                    PERSISTENT SET h-b1wgen9999.
                                    
                                    RUN acha-lock IN h-b1wgen9999 (INPUT RECID(b-crapalt),
                                    					 INPUT "banco",
                                    					 INPUT "b-crapalt",
                                    					 OUTPUT par_loginusr,
                                    					 OUTPUT par_nmusuari,
                                    					 OUTPUT par_dsdevice,
                                    					 OUTPUT par_dtconnec,
                                    					 OUTPUT par_numipusr).
                                    
                                    DELETE PROCEDURE h-b1wgen9999.
                                    
                                    ASSIGN aux_dadosusr = 
                                    "077 - Tabela sendo alterada p/ outro terminal.".
                                    
                                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                    MESSAGE aux_dadosusr.
                                    PAUSE 3 NO-MESSAGE.
                                    LEAVE.
                                    END.
                                    
                                    ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                                    			  " - " + par_nmusuari + ".".
                                    
                                    HIDE MESSAGE NO-PAUSE.
                                    
                                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                    MESSAGE aux_dadosusr.
                                    PAUSE 5 NO-MESSAGE.
                                    LEAVE.
                                    END.
                                                                      
                                    NEXT.
                              END.
                           ELSE
                             DO:
                                glb_cdcritic = 55.
                                LEAVE.
                             END.
                       glb_cdcritic = 0.
                       LEAVE.

                    END.
                
                    IF   glb_cdcritic > 0 THEN
                         LEAVE.
                        
                    FIND b-crapalt WHERE 
                    b-crapalt.cdcooper = crapalt.cdcooper  AND
                    b-crapalt.nrdconta = crapalt.nrdconta  AND
                    b-crapalt.dtaltera = glb_dtmvtolt 
                    EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF AVAILABLE b-crapalt THEN
                        DO:
                            ASSIGN b-crapalt.flgctitg = 4
                                   b-crapalt.dsaltera = b-crapalt.dsaltera + 
                                                        "reenvio exclusao conta-itg(" + 
                                                        STRING(crapass.nrdctitg) + ")" + 
                                                        "- ope." + glb_cdoperad + ","
                                   aux_flgalter     = TRUE.
                        END.
                    ELSE
                        DO:
                            CREATE b-crapalt.
                            ASSIGN b-crapalt.nrdconta = crapalt.nrdconta
                                   b-crapalt.dtaltera = glb_dtmvtolt
                                   b-crapalt.cdcooper = glb_cdcooper
                                   b-crapalt.flgctitg = 4
                                   b-crapalt.cdoperad = glb_cdoperad 
                                   b-crapalt.tpaltera = 2 
                                   b-crapalt.dsaltera = "reenvio exclusao conta-itg(" + 
                                                        STRING(crapass.nrdctitg) + ")" + 
                                                        "- ope." + glb_cdoperad + ","
                                   aux_flgalter     = TRUE.

                            VALIDATE b-crapalt.

                        END.
                        
                    UNIX SILENT VALUE("echo " +
                                      STRING(TODAY,"99/99/9999") + " " +
                                      STRING(TIME,"HH:MM:SS") + "' --> '"  +
                                      " Operador " + glb_cdoperad +
                                      " Alterou a conta/dv " + 
                                      STRING(crapalt.nrdconta) +
                                      " conta ITG " +
                                      STRING(crapass.nrdctitg) +
                                      " - Reenviar para BB." +
                                      " >> log/dsbitg.log").
            
                END. 

            IF   glb_cdcritic > 0 THEN
                 DO:  
                     RUN fontes/critic.p.
                     MESSAGE glb_dscritic.
                     glb_cdcritic = 0.
                     PAUSE 2 NO-MESSAGE.
                     LEAVE.
                 END.
            
            ASSIGN tel_nrdconta = 0
                   tel_nrdctitg = "".
     
            DISPLAY tel_nrdconta  "" @ tel_nrdctitg
                    WITH FRAME f_dsbitg2.
     
            IF aux_flgalter THEN
                DO:
                    FOR EACH crapeca EXCLUSIVE-LOCK
                       WHERE crapeca.cdcooper = glb_cdcooper 
                         AND crapeca.nrdconta = tel_nrdconta:
                                   
                        DELETE crapeca.
                    END.
               
                    MESSAGE "Operacao concluida.".
                END.
            ELSE
                MESSAGE "Sem registro de encerramento de conta ITG para " +
                        "reenviar.".
                LEAVE.
       
            END. /* FIM - DO WHILE TRUE */ 
        END.
    END. /* glb_cddopcao = "R" */

    ELSE
    IF glb_cddopcao = "T" THEN 
    DO:
        ASSIGN aux_confirma = NO.
    
        FIND FIRST w_ctitg 
             WHERE w_ctitg.cddopcao <> "T" NO-LOCK NO-ERROR.
        IF AVAIL w_ctitg THEN
        DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                ASSIGN aux_confirma = NO.
                MESSAGE "Atencao! Saindo da opcao "
                        QUOTER(w_ctitg.cddopcao)
                        " sem efetivar a operacao.".
                MESSAGE COLOR NORMAL "Deseja continuar? (S/N)"
                        UPDATE aux_confirma AUTO-RETURN.
                LEAVE.
            END. /* FIM - DO WHILE TRUE ON ENDKEY UNDO, LEAVE */
    
            IF KEYFUNCTION(LASTKEY) = "END-ERROR" OR
               aux_confirma         = NO          THEN
                NEXT.
            ELSE 
            DO:
                EMPTY TEMP-TABLE w_ctitg.
                ASSIGN aux_qtrgtab = 0.
                CLEAR FRAME f_list      ALL NO-PAUSE.
                CLEAR FRAME f_list_tit  ALL NO-PAUSE.
                CLEAR FRAME f_list_tit2 ALL NO-PAUSE.
                CLEAR FRAME f_list_tit3 ALL NO-PAUSE.
            END.
        END.
    
        Princ: 
        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
            ASSIGN tel_cddoptit = ""
                   tel_nrdconta = 0 
                   tel_nrdctitg = ""
                   tel_idseqttl = 0
                   aux_nrcpfcgc = 0.
    
            DISPLAY tel_cddoptit 
                    tel_nrdconta 
                    tel_nrdctitg 
                    tel_idseqttl 
                    aux_nrcpfcgc 
                    WITH FRAME f_dsbitg3.
    
            OpTit: 
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
                UPDATE tel_cddoptit WITH FRAME f_dsbitg3
                EDITING:
                    READKEY.
    
                    IF LASTKEY = KEYCODE("F8") THEN
                    DO:
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                            ASSIGN aux_confirma = FALSE
                                   glb_cdcritic = 78.
                            RUN fontes/critic.p.
                            HIDE MESSAGE NO-PAUSE.
                            glb_cdcritic = 0.
                            MESSAGE glb_dscritic UPDATE aux_confirma.
                            LEAVE.
                        END. /* FIM - DO WHILE TRUE ON ENDKEY UNDO, LEAVE */
    
                        IF KEYFUNCTION(LASTKEY) = "END-ERROR" OR
                           NOT aux_confirma                   THEN
                        DO:
                            glb_cdcritic = 79.
                            NEXT.
                        END.
    
                        RUN Proc_Criarq_COO405.
    
                        /** Necessario para nao desfazer a 
                            alteracao do sequencial **/ 
                        ASSIGN aux_flgalter = TRUE. 
                        LEAVE. 
                    END.                
                    ELSE
                        APPLY LASTKEY.
                END. /*** Fim do EDITING ***/             
    
                IF aux_flgalter = TRUE THEN
                DO:
                    ASSIGN aux_flgalter = FALSE.
                    NEXT OpTit.
                END.
    
                IF NOT(CAN-DO("I,E",tel_cddoptit)) THEN
                DO:
                    MESSAGE "Opcao errada. ".
                    NEXT-PROMPT tel_cddoptit WITH FRAME f_dsbitg3.
                    NEXT.
                END.
    
                IF aux_qtrgtab = 8 THEN
                DO:
                    HIDE MESSAGE NO-PAUSE.
                    MESSAGE "Nao podem ser inseridas mais de 8 contas.".
                    PAUSE 2 NO-MESSAGE.
                    NEXT.
                END.
    
                LEAVE.
            END. /* FIM - DO WHILE TRUE ON ENDKEY UNDO, LEAVE */
    
            IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
            DO:
                ASSIGN tel_cddoptit = "".
                DISPLAY tel_cddoptit WITH FRAME f_dsbitg3.
                LEAVE.
            END.
    
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
                UPDATE tel_nrdconta WITH FRAME f_dsbitg3.
    
                FIND crapass NO-LOCK 
               WHERE crapass.cdcooper = glb_cdcooper 
                 AND crapass.nrdconta = tel_nrdconta NO-ERROR.
                IF NOT AVAIL crapass THEN
                DO:
                    HIDE MESSAGE NO-PAUSE.
                    MESSAGE "Conta/dv inexistente.".
                    tel_nrdconta = 0.
                    DISPLAY tel_nrdconta WITH FRAME f_dsbitg3.
                    NEXT.
                END.
    
                /* Pessoa FISICA */
                IF crapass.inpessoa <> 1 THEN
                DO:
                    HIDE MESSAGE NO-PAUSE.
                    MESSAGE "Operacao permitida somente para " + 
                            "Pessoas Físicas!".
                    tel_nrdconta = 0.
                    DISPLAY tel_nrdconta WITH FRAME f_dsbitg3.
                    NEXT.
                END.
    
                LEAVE.
            END. /* FIM - DO WHILE TRUE ON ENDKEY UNDO, LEAVE */
    
            IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
            DO:
                ASSIGN tel_nrdconta = 0.
                NEXT-PROMPT tel_nrdconta WITH FRAME f_dsbitg3.
                NEXT.             
            END.
    
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
                UPDATE tel_nrdctitg WITH FRAME f_dsbitg3.
    
                DO WHILE LENGTH(tel_nrdctitg) < 8:
                    tel_nrdctitg = "0" + tel_nrdctitg.
                END.
    
                DISPLAY tel_nrdctitg WITH FRAME f_dsbitg3.
    
                IF tel_nrdctitg = "00000000"  OR
                   tel_nrdctitg = ""          THEN
                DO:
                    MESSAGE "Informe a conta ITG.".
                    NEXT-PROMPT tel_nrdctitg WITH FRAME f_dsbitg3.
                    NEXT.
                END.
                ELSE
                DO:
                    FIND crapass NO-LOCK 
                   WHERE crapass.cdcooper = glb_cdcooper  
                     AND crapass.nrdctitg = tel_nrdctitg NO-ERROR.
                    IF NOT AVAIL crapass THEN
                    DO:
                        MESSAGE "Conta ITG inexistente.".
                        NEXT.
                    END.
                    ELSE
                        IF tel_nrdconta <> crapass.nrdconta THEN
                        DO:
                            MESSAGE "Conta ITG registrada para " +
                                    "conta/dv: " +
                                    STRING(crapass.nrdconta,
                                           "zzzz,zz9,9") + ".".
                            NEXT.
                        END.
                END.

                LEAVE.
            END. /* FIM - DO WHILE TRUE ON ENDKEY UNDO, LEAVE */
    
            IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
            DO:
                tel_nrdctitg = "".
                NEXT-PROMPT tel_nrdctitg WITH FRAME f_dsbitg3.
                NEXT.
            END.
    
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
                UPDATE tel_idseqttl WITH FRAME f_dsbitg3.
    
                IF tel_idseqttl = 0 THEN
                DO:
                    MESSAGE "Informe a sequencia do Titular.".
                    NEXT-PROMPT tel_nrdctitg WITH FRAME f_dsbitg3.
                    NEXT.
                END.
    
                IF tel_idseqttl = 1 THEN
                DO:
                    MESSAGE "Nao pode incluir e/ou eliminar o primeiro Titular.".
                    NEXT-PROMPT tel_idseqttl WITH FRAME f_dsbitg3.
                    NEXT.
                END.
    
                FIND crapttl NO-LOCK 
               WHERE crapttl.cdcooper = glb_cdcooper  
                 AND crapttl.nrdconta = tel_nrdconta  
                 AND crapttl.idseqttl = tel_idseqttl NO-ERROR.
                IF (NOT AVAIL crapttl    AND 
                    tel_cddoptit <> "E") THEN
                DO:
                    HIDE MESSAGE NO-PAUSE.
                    
                    MESSAGE "Titular da Conta inexistente.".
    
                    ASSIGN tel_idseqttl = 0
                           aux_nrcpfcgc = 0. 
    
                    DISPLAY tel_idseqttl WITH FRAME f_dsbitg3.
                    NEXT.
                END.
    
                IF AVAIL crapttl         AND
                   crapttl.indnivel <> 4 THEN /* cad. completo */
                DO:
                    HIDE MESSAGE NO-PAUSE.
                    MESSAGE "Cadastro do Titular esta incompleto.".
                    ASSIGN tel_idseqttl = 0
                           aux_nrcpfcgc = 0. 
                    DISPLAY tel_idseqttl WITH FRAME f_dsbitg3.
                    NEXT.
                END.
    
                FIND FIRST w_ctitgb NO-LOCK  
                     WHERE w_ctitgb.nrdconta = tel_nrdconta  
                       AND w_ctitgb.nrdctitg = tel_nrdctitg  
                       AND w_ctitgb.idseqttl = tel_idseqttl  
                       AND w_ctitgb.cddoptit = tel_cddoptit NO-ERROR.
                IF AVAIL w_ctitgb THEN
                DO:
                    MESSAGE "Opcao/Conta/Conta ITG ja foram " + 
                            "informadas para esse Titular.".
                    NEXT-PROMPT tel_nrdconta WITH FRAME f_dsbitg3.
                    NEXT.
                END.
    
                LEAVE.
            END. /* FIM - DO WHILE TRUE ON ENDKEY UNDO, LEAVE */
    
            IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
            DO:
                ASSIGN tel_idseqttl = 0.
                NEXT-PROMPT tel_idseqttl WITH FRAME f_dsbitg3.
                NEXT.             
            END.
    
            IF tel_cddoptit <> "E" THEN
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
                    UPDATE aux_nrcpfcgc WITH FRAME f_dsbitg3.
                    
                    IF aux_nrcpfcgc = 0 THEN
                    DO:
                        MESSAGE "Informe o CPF do Titular.".
                        NEXT-PROMPT aux_nrcpfcgc WITH FRAME f_dsbitg3.
                        NEXT.
                    END.
                    
                    IF aux_nrcpfcgc <> crapttl.nrcpfcgc THEN
                    DO:
                        MESSAGE "CPF informado nao pertence " + 
                                "a esse Titular.".
                        NEXT-PROMPT aux_nrcpfcgc WITH FRAME f_dsbitg3.
                        NEXT.
                    END.
                    
                    DISPLAY STRING(STRING(aux_nrcpfcgc,"99999999999"),
                                   "999.999.999-99") FORMAT "X(14)" @
                                    aux_nrcpfcgc WITH FRAME f_dsbitg3.
                    
                    RUN proc_nrcpfcgc (INPUT aux_nrcpfcgc).
                    
                    IF RETURN-VALUE = "NOK" THEN
                        NEXT.
                    
                    LEAVE.
                END. /* FIM - DO WHILE TRUE ON ENDKEY UNDO, LEAVE */
    
            IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
            DO:
                ASSIGN aux_nrcpfcgc = 0.
                NEXT-PROMPT aux_nrcpfcgc WITH FRAME f_dsbitg3.
                NEXT.             
            END.
            
            CREATE w_ctitg.
            ASSIGN w_ctitg.nrdconta  = tel_nrdconta
                   w_ctitg.nrdctitg  = tel_nrdctitg
                   w_ctitg.nrcpfcgc  = aux_nrcpfcgc
                   w_ctitg.cddopcao  = glb_cddopcao
                   w_ctitg.cddoptit  = tel_cddoptit
                   w_ctitg.idseqttl  = tel_idseqttl
                   aux_qtrgtab       = aux_qtrgtab + 1.
    
            DISPLAY w_ctitg.cddoptit
                    w_ctitg.nrdconta
                    w_ctitg.nrdctitg 
                    w_ctitg.idseqttl
                    STRING(STRING(w_ctitg.nrcpfcgc,"99999999999"),
                                  "999.999.999-99") FORMAT "X(14)" @
                                  w_ctitg.nrcpfcgc
                    WITH FRAME f_list_tit.
    
            DOWN WITH FRAME f_list_tit.
    
            ASSIGN tel_cddoptit = ""
                   tel_nrdconta = 0
                   tel_nrdctitg = ""
                   tel_idseqttl = 0
                   aux_nrcpfcgc = 0.
    
            DISPLAY tel_cddoptit 
                    tel_nrdconta  
                    tel_nrdctitg 
                    tel_idseqttl
                    "" @ aux_nrcpfcgc
                    WITH FRAME f_dsbitg3.
        END. /* FIM - DO WHILE TRUE ON ENDKEY UNDO, LEAVE */
    END. /* glb_cddopcao = "T" */
    ELSE
    IF glb_cddopcao = "Z" THEN
    DO:
        ASSIGN aux_confirma = NO.
        
        /* Verifica se o usuário está saindo da tela sem confirmar 
           as alterações realizadas */
        FIND FIRST w_ctitg 
             WHERE w_ctitg.cddopcao <> "Z" NO-LOCK NO-ERROR.
        IF AVAIL w_ctitg THEN
        DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                ASSIGN aux_confirma = NO.
                MESSAGE "Atencao! Saindo da opcao "
                        QUOTER(w_ctitg.cddopcao)
                        " sem efetivar a operacao.".
                MESSAGE COLOR NORMAL "Deseja continuar? (S/N)"
                        UPDATE aux_confirma AUTO-RETURN.
                LEAVE.
            END. /* FIM - DO WHILE TRUE ON ENDKEY UNDO, LEAVE */
        
            IF KEYFUNCTION(LASTKEY) = "END-ERROR" OR
               aux_confirma         = NO          THEN
                NEXT.
            ELSE 
            DO:
                EMPTY TEMP-TABLE w_ctitg.
                ASSIGN aux_qtrgtab = 0.
                CLEAR FRAME f_list      ALL NO-PAUSE.
                CLEAR FRAME f_list_tit  ALL NO-PAUSE.
                CLEAR FRAME f_list_tit2 ALL NO-PAUSE.
                CLEAR FRAME f_list_tit3 ALL NO-PAUSE.
            END.
        END.
        /**************************** FIM ****************************/
        
        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            IF glb_cdcritic > 0 THEN
            DO:
                RUN fontes/critic.p.
                MESSAGE glb_dscritic.
                glb_cdcritic = 0.
                PAUSE 2 NO-MESSAGE.
            END.
            
            ASSIGN aux_flgalter = FALSE.

            /************** Número da Conta **************/
            ASSIGN tel_nrdconta:HELP IN FRAME f_dsbitg4 = 
                         "Informe a conta ITG ou tecle <F8> para finalizar."
                   tel_nrdconta = 0.
                
            UPDATE tel_nrdconta WITH FRAME f_dsbitg4
            EDITING:                                                            
                READKEY.
            
                /* Efetiva as alterações realizadas */
                IF LASTKEY = KEYCODE("F8") THEN
                DO:
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        ASSIGN aux_confirma = FALSE
                               glb_cdcritic = 78.
                        RUN fontes/critic.p.
                        HIDE MESSAGE NO-PAUSE.
                        glb_cdcritic = 0.
                        MESSAGE glb_dscritic UPDATE aux_confirma.
                        LEAVE.
                    END. /* FIM - DO WHILE TRUE ON ENDKEY UNDO, LEAVE */
                
                    IF KEYFUNCTION(LASTKEY) = "END-ERROR" OR
                       NOT aux_confirma                   THEN
                    DO:
                        glb_cdcritic = 79.
                        NEXT.
                    END.
                    
                    /* Criar arquivo COO410 */
                    RUN proc_criarq_COO410.
                                           
                    /** Necessario para nao desfazer a 
                        alteracao do sequencial **/ 
                    ASSIGN aux_flgalter = TRUE. 

                    /* Sai do Bloco do-opcao para nao desfazer a 
                        alteracao do sequencial  */
                     LEAVE do-opcao.

                END.
                ELSE
                    APPLY LASTKEY.
            END. 
            
            /*** Fim do EDITING ***/
            /************** Número da Conta - FIM **************/

            IF aux_flgalter THEN
                NEXT.

            DO WHILE LENGTH(tel_nrdctitg) < 8:
                tel_nrdctitg = "0" + tel_nrdctitg.
            END.

            /************** Valida Número da Conta **************/
            IF NOT CAN-FIND (FIRST crapass NO-LOCK
                             WHERE crapass.cdcooper = glb_cdcooper  
                               AND crapass.nrdconta = tel_nrdconta) THEN
            DO:
                MESSAGE "Conta invalida.".
                PAUSE 2 NO-MESSAGE.
                NEXT.
            END.
            /*********** Valida Número da Conta - FIM ***********/
            
            /******************** Conta ITG ********************/
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                
                UPDATE tel_nrdctitg WITH FRAME f_dsbitg4.   
                
                /* Valida Conta ITG */
                IF NOT CAN-FIND (FIRST crapass 
                                 WHERE crapass.cdcooper = glb_cdcooper  
                                   AND crapass.nrdconta = tel_nrdconta 
                                   AND crapass.nrdctitg = tel_nrdctitg) THEN
                DO:
                    MESSAGE "Conta ITG invalida para esta conta.".
                    PAUSE 2 NO-MESSAGE.
                    NEXT.
                END.
                
                LEAVE.  
            END. /* FIM - DO WHILE TRUE ON ENDKEY UNDO, LEAVE */

            IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
            DO:
                ASSIGN  tel_nrdctitg = "".
                DISPLAY tel_nrdctitg WITH FRAME f_dsbitg4.   
                NEXT.             
            END.
            /***************** Conta ITG - FIM *****************/

            IF glb_cdcritic > 0 THEN
                NEXT.
            
            IF aux_qtrgtab = 8 THEN
            DO:
                HIDE MESSAGE NO-PAUSE.
                MESSAGE "Nao podem ser inseridas mais de 8 contas.".
                PAUSE 2 NO-MESSAGE.
                NEXT.
            END.
            
            IF CAN-FIND(w_ctitg WHERE 
                        w_ctitg.nrdctitg = tel_nrdctitg) THEN
            DO:
                MESSAGE "Conta ITG ja foi adicionada.".
                PAUSE 2 NO-MESSAGE.
                NEXT.
            END.
            
            /*************** CPF ***************/
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                
                UPDATE aux_nrcpfcgc WITH FRAME f_dsbitg4.   
                
                /* Valida CPF */
                RUN proc_nrcpfcgc (INPUT aux_nrcpfcgc).  
                
                IF RETURN-VALUE = "NOK" THEN 
                    NEXT.
                
                LEAVE.  
            END. /* FIM - DO WHILE TRUE ON ENDKEY UNDO, LEAVE */
                  
            IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
            DO:
                ASSIGN  aux_nrcpfcgc = 0.
                DISPLAY aux_nrcpfcgc WITH FRAME f_dsbitg4.   
                NEXT.             
            END.
            /*************** CPF - FIM ***************/
            
            /*********** Número do Cartão ***********/
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                 
                UPDATE tel_nrcrcard WITH FRAME f_dsbitg4.   
                
                /* Valida Número do Cartão */
                RUN proc_nrcrcard (INPUT  tel_nrdconta,    
                                   INPUT  aux_nrcpfcgc,    
                                   INPUT  tel_nrcrcard,
                                   OUTPUT aux_nrcctitg,
                                   OUTPUT aux_nrcpftit).

                IF RETURN-VALUE = "NOK" THEN
                DO:
                    MESSAGE "Cartao inexistente para o CPF ou Cartao nao encerrado.".
                    PAUSE 2 NO-MESSAGE.
                    NEXT.
                END.

                LEAVE.
            END. /* FIM - DO WHILE TRUE ON ENDKEY UNDO, LEAVE */
                  
            IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
            DO:
                ASSIGN  tel_nrcrcard = 0.
                DISPLAY tel_nrcrcard WITH FRAME f_dsbitg4.   
                NEXT.             
            END.
            /*********** Número do Cartão - FIM ***********/
            
            CREATE w_ctitg.
            ASSIGN w_ctitg.nrdconta  = tel_nrdconta         
                   w_ctitg.nrdctitg  = tel_nrdctitg
                   w_ctitg.nrcctitg  = aux_nrcctitg
                   w_ctitg.nrcpfcgc  = aux_nrcpftit      
                   w_ctitg.nrcrcard  = tel_nrcrcard
                   w_ctitg.cddopcao  = glb_cddopcao
                   aux_qtrgtab       = aux_qtrgtab + 1.

            DISPLAY w_ctitg.nrdconta 
                    w_ctitg.nrdctitg 
                    w_ctitg.nrcpfcgc 
                    w_ctitg.nrcrcard
                    WITH FRAME f_list_tit2.
            
            DOWN WITH FRAME f_list_tit2.
            
            ASSIGN tel_nrdconta  = 0
                   tel_nrdctitg  = ""
                   aux_nrcpfcgc  = 0
                   tel_nrcrcard  = 0.
            
            DISPLAY tel_nrdconta
                    tel_nrdctitg  
                    " "@ aux_nrcpfcgc 
                    tel_nrcrcard WITH FRAME f_dsbitg4.

        END. /* FIM - DO WHILE TRUE ON ENDKEY UNDO, LEAVE */

    END. /* glb_cddopcao = "Z" */

    ELSE
    IF glb_cddopcao = "W" THEN
    DO: 
        ASSIGN aux_confirma = NO.

        FOR EACH w_ctitg EXCLUSIVE-LOCK WHERE w_ctitg.cddopcao = "W":
            DELETE w_ctitg.
        END.
        CLEAR FRAME f_list      ALL NO-PAUSE.
        CLEAR FRAME f_list_tit  ALL NO-PAUSE.
        CLEAR FRAME f_list_tit2 ALL NO-PAUSE.
        CLEAR FRAME f_list_tit3 ALL NO-PAUSE.


        /* Verifica se o usuário está saindo da tela sem confirmar 
           as alterações realizadas */
        FIND FIRST w_ctitg 
             WHERE w_ctitg.cddopcao <> "W" NO-LOCK NO-ERROR.
        IF AVAIL w_ctitg THEN
        DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                ASSIGN aux_confirma = NO.
                MESSAGE "Atencao! Saindo da opcao "
                        QUOTER(w_ctitg.cddopcao)
                        " sem efetivar a operacao.".
                MESSAGE COLOR NORMAL "Deseja continuar? (S/N)"
                        UPDATE aux_confirma AUTO-RETURN.
                LEAVE.
            END. /* FIM - DO WHILE TRUE ON ENDKEY UNDO, LEAVE */
        
            IF KEYFUNCTION(LASTKEY) = "END-ERROR" OR
               aux_confirma         = NO          THEN
               DO:
                    NEXT.
               END.
            ELSE 
            DO:
                EMPTY TEMP-TABLE w_ctitg.
                ASSIGN aux_qtrgtab = 0.
                CLEAR FRAME f_list      ALL NO-PAUSE.
                CLEAR FRAME f_list_tit  ALL NO-PAUSE.
                CLEAR FRAME f_list_tit2 ALL NO-PAUSE.
                CLEAR FRAME f_list_tit3 ALL NO-PAUSE.
            END.
        END.
        /**************************** FIM ****************************/
        
        DO WHILE TRUE:
            aux_flggrava = FALSE.
            IF glb_cdcritic > 0 THEN
            DO:
                RUN fontes/critic.p.
                MESSAGE glb_dscritic.
                glb_cdcritic = 0.
                PAUSE 2 NO-MESSAGE.
            END.

            ASSIGN aux_flgalter = FALSE.
        
            /************* Número da Conta *************/
            ASSIGN tel_nrdconta:HELP IN FRAME f_dsbitg5 = 
                         "Informe a conta ITG ou tecle <F8> para finalizar."
                   tel_nrdconta = 0.
        
            UPDATE tel_nrdconta WITH FRAME f_dsbitg5
            do-trans:
            EDITING: 
                
                READKEY.
                
                IF LASTKEY = KEYCODE("F8") THEN
                DO:
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        ASSIGN aux_confirma = FALSE
                               glb_cdcritic = 78.
                        RUN fontes/critic.p.
                        HIDE MESSAGE NO-PAUSE.
                        glb_cdcritic = 0.
                        
                        MESSAGE glb_dscritic UPDATE aux_confirma.
                        LEAVE.
                    END. /* FIM - DO WHILE TRUE ON ENDKEY UNDO, LEAVE */
                
                    IF KEYFUNCTION(LASTKEY) = "END-ERROR" OR
                       NOT aux_confirma                   THEN
                    DO:
                        glb_cdcritic = 79.
                        NEXT.
                    END.
            
                    /** Necessario para nao desfazer a 
                        alteracao do sequencial **/ 
                    ASSIGN aux_flgalter = TRUE.
                    
                    aux_flggrava = TRUE.
                    
                    LEAVE do-trans.

                END.                
                ELSE
                    APPLY LASTKEY.
                    
            END. /*** Fim do EDITING - Conta ITG ***/  

            /**************************************************************/
            IF  aux_flggrava THEN
            DO:
                FOR EACH w_ctitg NO-LOCK:
            
                        ASSIGN aux_criarlog = NO.
                    
                        FOR FIRST crapass NO-LOCK
                            WHERE crapass.cdcooper = glb_cdcooper
                              AND crapass.nrdconta = w_ctitg.nrdconta
                              AND crapass.nrdctitg = w_ctitg.nrdctitg,
                            FIRST crawcrd 
                            FIELDS(flgctitg dtsolici cdmotivo dtcancel insitcrd) 
                            EXCLUSIVE-LOCK
                            WHERE crawcrd.cdcooper = crapass.cdcooper
                              AND crawcrd.nrdconta = crapass.nrdconta
                              AND crawcrd.nrcrcard = w_ctitg.nrcrcard:
                    
                            ASSIGN crawcrd.flgctitg = 0
                                   crawcrd.dtsolici = glb_dtmvtolt
                                   crawcrd.cdmotivo = 0
                                   crawcrd.dtcancel = ?
                                   crawcrd.insitcrd = 4
                                   aux_criarlog     = YES.
                        END.
                    
                        FOR FIRST crapcrd FIELDS(dtcancel cdmotivo) EXCLUSIVE-LOCK 
                            WHERE crapcrd.cdcooper = glb_cdcooper
                              AND crapcrd.nrdconta = w_ctitg.nrdconta
                              AND crapcrd.nrcrcard = w_ctitg.nrcrcard:
                    
                            ASSIGN crapcrd.dtcancel = ?
                                   crapcrd.cdmotivo = 0.
                        END.
                    
                        /*************************** CRIAR LOG *************************/  
                        IF aux_criarlog THEN
                            UNIX SILENT VALUE("echo "                                        + 
                                              STRING(glb_dtmvtolt,"99/99/9999") + " "        +
                                              STRING(TIME,"HH:MM:SS") + "' --> '"            +
                                              " Operador " + glb_cdoperad                    + 
                                              " solicitou reativacao do cartao "             +
                                              STRING(w_ctitg.nrcrcard,"9999,9999,9999,9999") +
                                              " [Conta: "                                    +
                                              STRING(w_ctitg.nrdconta,"zzzz,zz9,9")          +
                                              " Conta ITG: "                                 + 
                                              STRING(w_ctitg.nrdctitg,"x.xxx.xxx-x") + "]"   +
                                              " >> log/dsbitg.log").
                        /************************ CRIAR LOG - FIM **********************/
                END.
                
                RELEASE crawcrd NO-ERROR.
                RELEASE crapcrd NO-ERROR.
                
                /* Limpar a tela após efetivar as alterações */
                EMPTY TEMP-TABLE w_ctitg.
                ASSIGN aux_qtrgtab = 0.
                
                MESSAGE "Operacao efetuada com sucesso.".
                PAUSE 2 NO-MESSAGE.
                
                CLEAR FRAME f_list_tit  ALL NO-PAUSE.
                CLEAR FRAME f_list_tit2 ALL NO-PAUSE.
                CLEAR FRAME f_list_tit3 ALL NO-PAUSE.
                /************** FIM **************/
                 
                aux_flggrava = FALSE.
                LEAVE do-opcao.
            END.
            /**************************************************************/

            IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
            DO:
                tel_nrdconta = 0.
                DISPLAY tel_nrdconta WITH FRAME f_dsbitg5.
                LEAVE.             
            END.

            /************* FIM - Número da Conta *************/
        
            /* Valida Número da Conta */
            IF NOT CAN-FIND (FIRST crapass
                             WHERE crapass.cdcooper = glb_cdcooper  
                               AND crapass.nrdconta = tel_nrdconta) THEN
            DO:
                MESSAGE "Conta invalida.".
                PAUSE 2 NO-MESSAGE.
                NEXT.
            END.
            
            IF aux_flgalter = TRUE THEN
                NEXT.
            
            DO WHILE LENGTH(tel_nrdctitg) < 8:
                tel_nrdctitg = "0" + tel_nrdctitg.
            END.
        
            /********* Conta ITG *********/
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                 
                UPDATE tel_nrdctitg WITH FRAME f_dsbitg5. 
        
                /* Valida Conta ITG */
                IF NOT CAN-FIND (FIRST crapass  
                                 WHERE crapass.cdcooper = glb_cdcooper  
                                   AND crapass.nrdconta = tel_nrdconta
                                   AND crapass.nrdctitg = tel_nrdctitg) THEN
                DO: 
                    MESSAGE "Conta ITG invalida para esta conta.".
                    PAUSE 2 NO-MESSAGE.
                    NEXT.
                END.
        
                IF CAN-FIND (FIRST crapass  
                             WHERE crapass.cdcooper = glb_cdcooper  
                               AND crapass.nrdconta = tel_nrdconta
                               AND crapass.nrdctitg = tel_nrdctitg
                               AND crapass.flgctitg = 3) THEN
                DO: 
                    MESSAGE "Conta ITG inativa.".
                    PAUSE 2 NO-MESSAGE.
                    NEXT.
                END.
        
                LEAVE.  
            END. /* FIM - DO WHILE TRUE ON ENDKEY UNDO, LEAVE */
        
            IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
            DO:
                tel_nrdctitg = "".
                DISPLAY tel_nrdctitg WITH FRAME f_dsbitg5.
                LEAVE.             
            END.
            /********* FIM - Conta ITG *********/
            
            IF glb_cdcritic > 0 THEN
                NEXT.
            
            IF aux_qtrgtab = 8 THEN
            DO:
                HIDE MESSAGE NO-PAUSE.
                MESSAGE "Nao podem ser inseridas mais de 8 contas.".
                PAUSE 2 NO-MESSAGE.
                NEXT.
            END.
            
            IF CAN-FIND(w_ctitg WHERE 
                        w_ctitg.nrdctitg = tel_nrdctitg) THEN
            DO:
                MESSAGE "Conta ITG ja foi adicionada.".
                PAUSE 2 NO-MESSAGE.
                NEXT.
            END.
            
            /*********** Número do Cartão ***********/
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                 
                UPDATE tel_nrcrcard WITH FRAME f_dsbitg5. 
        
                /* Valida Número do Cartão */
                IF NOT CAN-FIND (FIRST crawcrd
                                 WHERE crawcrd.cdcooper  = glb_cdcooper
                                   AND crawcrd.nrcrcard  = tel_nrcrcard
                                   AND crawcrd.insitcrd  = 6) THEN
                DO:
                    MESSAGE "Cartao inexistente ou nao encerrado.".
                    PAUSE 2 NO-MESSAGE.
                    NEXT.
                END.
                
                LEAVE.  
            END. /* FIM - DO WHILE TRUE ON ENDKEY UNDO, LEAVE */
                  
            IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
            DO:
                ASSIGN  tel_nrcrcard = 0.
                DISPLAY tel_nrcrcard WITH FRAME f_dsbitg5.   
                NEXT.             
            END.
            /*********** FIM - Número do Cartão ***********/
            
            CREATE w_ctitg.
            ASSIGN w_ctitg.nrdconta  = tel_nrdconta
                   w_ctitg.nrdctitg  = tel_nrdctitg
                   w_ctitg.nrcrcard  = tel_nrcrcard
                   w_ctitg.cddopcao  = glb_cddopcao
                   aux_qtrgtab       = aux_qtrgtab + 1.
        
            DISPLAY w_ctitg.nrdconta
                    w_ctitg.nrdctitg 
                    w_ctitg.nrcrcard
                    WITH FRAME f_list_tit3.
            
            DOWN WITH FRAME f_list_tit3.
            
            ASSIGN tel_nrdconta  = 0
                   tel_nrdctitg  = ""
                   tel_nrcrcard  = 0.
            
            DISPLAY  tel_nrdconta
                     tel_nrdctitg  
                     tel_nrcrcard WITH FRAME f_dsbitg5.
        
        END. /* FIM - DO WHILE TRUE ON ENDKEY UNDO, LEAVE */       
    
    END. /* glb_cddopcao = "W" */                                

END. /* FIM - DO WHILE TRUE ON ENDKEY UNDO, LEAVE */

/********************************PROCEDURES***********************************/
PROCEDURE proc_criarq.

    DEFINE VARIABLE  aux_nrcpfcgc2      AS CHAR     NO-UNDO.
    DEFINE VARIABLE  aux_nrregist       AS INT      NO-UNDO.
    
    FIND FIRST w_ctitg NO-LOCK NO-ERROR.
    IF   NOT AVAILABLE w_ctitg   THEN
         RETURN.
    
    ASSIGN aux_nrtextab = INTEGER(SUBSTRING(craptab.dstextab,1,5))
           aux_nmarqimp = "coo409" +
                          STRING(DAY(glb_dtmvtolt),"99")   +
                          STRING(MONTH(glb_dtmvtolt),"99") +
                          STRING(aux_nrtextab,"99999")     + ".rem".
           OUTPUT STREAM str_1 TO VALUE("arq/" + aux_nmarqimp).
    
    /* header */
    ASSIGN aux_dsdlinha = "0000000"             +
           STRING(crapcop.cdageitg,"9999")      +
           STRING(crapcop.nrctaitg,"99999999")  +
           "COO409  "                           +
           STRING(aux_nrtextab,"99999")         +
           STRING(glb_dtmvtolt,"99999999")      +
           STRING(crapcop.cdcnvitg,"999999999") +
           FILL(" ", 21).
    
    PUT STREAM str_1 aux_dsdlinha SKIP.
    
    FOR EACH w_ctitg NO-LOCK:
    
        IF  w_ctitg.nrcpfcgc2 = 0   THEN
            aux_nrcpfcgc2 = "00000000000".
        ELSE
            aux_nrcpfcgc2 = STRING(w_ctitg.nrcpfcgc2,"99999999999").
          
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(w_ctitg.nrdctitg,1,7),"x(7)") +
                              STRING(SUBSTRING(w_ctitg.nrdctitg,8,1),"x(1)")
               aux_dsdlinha = aux_dsdlinha                                   +
                              "2"                                            +                        
                              STRING(w_ctitg.nrcpfcgc, "99999999999999")     +
                              aux_nrcpfcgc2                                  +
                              "0124"                                         +
                              "        ".
    
        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.

        /*** Registra ocorrencia na crapalt ***/
        FIND crapass WHERE
             crapass.cdcooper = glb_cdcooper AND
             crapass.nrdctitg = w_ctitg.nrdctitg
             NO-LOCK NO-ERROR NO-WAIT.
                                      
                   IF AVAILABLE crapass THEN
                        DO:

                            FIND crapalt WHERE 
                                 crapalt.cdcooper = glb_cdcooper      AND
                                 crapalt.nrdconta = crapass.nrdconta  AND
                                 crapalt.dtaltera = glb_dtmvtolt 
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                    
                                IF AVAILABLE crapalt THEN
                                    DO:

                                        ASSIGN crapalt.flgctitg = 4
                                               crapalt.dsaltera = crapalt.dsaltera + "reativacao conta-itg(" + STRING(w_ctitg.nrdctitg) + ")" + "- ope." + glb_cdoperad + ",".
                                    END.
                                ELSE
                                    DO:

                                        CREATE crapalt.
                                        ASSIGN crapalt.nrdconta = crapass.nrdconta
                                               crapalt.dtaltera = glb_dtmvtolt
                                               crapalt.cdcooper = glb_cdcooper
                                               crapalt.flgctitg = 4
                                               crapalt.cdoperad = glb_cdoperad 
                                               crapalt.tpaltera = 2 
                                               crapalt.dsaltera = "reativacao conta-itg(" + STRING(w_ctitg.nrdctitg) + ")" + "- ope." + glb_cdoperad + ",".
                                        
                                        VALIDATE crapalt.

                                    END.
                        END.
    
        /*** Cria log das alteracoes ***/                                    
        UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " "    +
                         STRING(TIME,"HH:MM:SS") + "' --> '"                   +
                         " Operador " + glb_cdoperad + " reativou a "          +
                         "Conta ITG " + STRING(w_ctitg.nrdctitg,"x.xxx.xxx-x") +
                         " CPF primeiro titular - "                            +
                         STRING(w_ctitg.nrcpfcgc,"zzz99999999999")             +
                         " CPF segundo titular - "                             +
                         STRING(w_ctitg.nrcpfcgc2)                             +
                         " >> log/dsbitg.log").
    
    END.
          
    ASSIGN aux_nrregist = aux_nrregist + 2
           aux_dsdlinha = "9999999" + STRING(aux_nrregist,"999999999").
    
    PUT STREAM str_1 aux_dsdlinha SKIP.
    
    OUTPUT STREAM str_1 CLOSE.
    
    UNIX SILENT VALUE("ux2dos < arq/" + aux_nmarqimp  +
                     ' | tr -d "\032"'                +
                     " > /micros/" + crapcop.dsdircop +
                     "/compel/" + aux_nmarqimp + " 2>/dev/null").
    
    UNIX SILENT VALUE("mv arq/" + aux_nmarqimp + " salvar 2>/dev/null").
    
    /* Atualizacao da craptab */
    FIND CURRENT craptab EXCLUSIVE-LOCK.
    
    ASSIGN SUBSTRING(craptab.dstextab,1,5) = STRING(aux_nrtextab + 1,"99999").
    
    EMPTY TEMP-TABLE w_ctitg.
    ASSIGN aux_qtrgtab = 0.
    
    MESSAGE "Arquivo gerado com sucesso.".
    PAUSE 2 NO-MESSAGE.
    
    CLEAR FRAME f_list    ALL NO-PAUSE.
    CLEAR FRAME f_dsbitg3 ALL NO-PAUSE.
    
END PROCEDURE. 
 
/*****************************************************************************/

PROCEDURE Proc_Criarq_COO405:

  /* Atualizacao da craptab */
    FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                       craptab.nmsistem = "CRED"         AND
                       craptab.tptabela = "GENERI"       AND
                       craptab.cdempres = 0              AND
                       craptab.cdacesso = "NRARQMVITG"   AND
                       craptab.tpregist = 405            
                       EXCLUSIVE-LOCK NO-ERROR.
    IF   NOT AVAIL craptab   THEN
    DO:
        IF   LOCKED craptab   THEN
        DO:
            MESSAGE "Registro de Tabelas em uso por outro usuario!"
                    " Tente novamente."
                VIEW-AS ALERT-BOX WARNING BUTTONS OK.
    
            RETURN.
        END.
        ELSE 
        DO:
            glb_cdcritic = 393.
            RUN fontes/critic.p.
            MESSAGE glb_dscritic
                VIEW-AS ALERT-BOX INFO BUTTONS OK.
    
            RETURN.
        END.
    END.
    
    IF   INT(SUBSTR(craptab.dstextab,07,01)) = 1 THEN
    DO:
        MESSAGE "COO405 - " glb_cdprogra SKIP
                "PROGRAMA BLOQUEADO PARA ENVIAR ARQUIVOS"
            VIEW-AS ALERT-BOX ERROR BUTTONS OK.
        RETURN.
    END.
    
    /*************************** ABRE ARQUIVO ***************************/
    ASSIGN aux_nrtextab = INTEGER(SUBSTRING(craptab.dstextab,1,5))
           aux_nmarqimp = "coo405"                         +
                          STRING(DAY(glb_dtmvtolt),"99")   +
                          STRING(MONTH(glb_dtmvtolt),"99") +
                          STRING(aux_nrtextab,"99999") + ".rem"
           aux_nrregist = 0
           aux_nrtotcli = 0.
    
    OUTPUT STREAM str_1 TO VALUE("arq/" + aux_nmarqimp).
    
    /* header */
    ASSIGN aux_dsdlinha = "0000000"                            +
                          STRING(crapcop.cdageitg,"9999")      + 
                          STRING(crapcop.nrctaitg,"99999999")  + 
                          "COO405  "                           + 
                          STRING(aux_nrtextab,"99999")         +
                          STRING(glb_dtmvtolt,"99999999")      +
                          STRING(crapcop.cdcnvitg,"999999999") + 
                          STRING(crapcop.cdmasitg,"99999")     +
                          FILL(" ",96).
    
    PUT STREAM str_1 UNFORMATTED aux_dsdlinha SKIP.
    /************************* ABRE ARQUIVO - FIM ***********************/
    
    RUN Exporta_Registros.
    
    /************************** FECHA ARQUIVO ***************************/
    /* trailer */
                          /* total de registros + header + trailer */
    ASSIGN aux_nrregist = aux_nrregist + 2
           aux_dsdlinha = "9999999"                        +
                          "        "                       + 
                          STRING(aux_nrtotcli,"99999")     +
                          STRING(aux_nrregist,"999999999") + 
                          FILL(" ",121).
                          /* o restante sao brancos */
    
    PUT STREAM str_1 UNFORMATTED aux_dsdlinha.
    
    OUTPUT STREAM str_1 CLOSE.
    
    IF   RETURN-VALUE = "NOK"   THEN
    DO: 
        MESSAGE "Problemas ao gerar arquivo. " +
                "Favor revisar cadastro. ".
        RETURN.
    END.
    /************************ FECHA ARQUIVO - FIM ***********************/
    
    /********************************************************************/
    
    /* verifica se o arquivo gerado nao tem registros "detalhe" */
    IF   aux_nrregist <= 2   THEN
    DO:
        UNIX SILENT VALUE("rm arq/" + aux_nmarqimp + " 2>/dev/null").
        LEAVE.        
    END.
    
    ASSIGN glb_cdcritic = 847.
    RUN fontes/critic.p.
    
    /* copia o arquivo para diretorio "compel" para poder ser enviado ao BB */
    UNIX SILENT VALUE("ux2dos < arq/" + aux_nmarqimp   +  
                      ' | tr -d "\032"'                +  
                      " > /micros/" + crapcop.dsdircop +
                      "/compel/" + aux_nmarqimp + " 2>/dev/null").  
    
    UNIX SILENT VALUE("mv arq/" + aux_nmarqimp + " salvar 2>/dev/null").
    /********************************************************************/
    
    ASSIGN SUBSTRING(craptab.dstextab,1,5) = STRING(aux_nrtextab + 1,"99999").
    
    EMPTY TEMP-TABLE w_ctitg.
    ASSIGN aux_qtrgtab = 0.
    
    MESSAGE "Arquivo gerado com sucesso.".
    PAUSE 2 NO-MESSAGE.
    
    CLEAR FRAME f_list_tit  ALL NO-PAUSE.
    CLEAR FRAME f_list_tit2 ALL NO-PAUSE.
    CLEAR FRAME f_list_tit3 ALL NO-PAUSE.

END PROCEDURE.
/*****************************************************************************/
 
PROCEDURE proc_nrcpfcgc:

    DEF  INPUT PARAMETER  par_nrcpfcgc   AS DECIMAL   NO-UNDO.
    
    glb_nrcalcul = par_nrcpfcgc.
    
    RUN fontes/cpfcgc.p.
    
    IF  NOT glb_stsnrcal   THEN
    DO:
        glb_cdcritic = 27.
        RUN fontes/critic.p.
        MESSAGE glb_dscritic.
        glb_cdcritic = 0.
        PAUSE 2 NO-MESSAGE.
        RETURN "NOK".  
    END.
    
    RETURN.
    
END PROCEDURE.
/*****************************************************************************/

PROCEDURE proc_validaitg:

    FIND crapass  WHERE  crapass.cdcooper = glb_cdcooper  AND
                         crapass.nrdctitg = tel_nrdctitg
                         USE-INDEX crapass7 NO-LOCK NO-ERROR.
                                       
    IF NOT AVAILABLE crapass   THEN
    DO:
        glb_cdcritic = 09.
        RETURN.
    END.
       
    glb_nrcalcul = crapass.nrdconta.
    RUN fontes/digfun.p.
                                            
    IF   NOT glb_stsnrcal   THEN
    DO:
        glb_cdcritic = 8.
        RETURN.
    END.
    
END PROCEDURE.
/*****************************************************************************/

/*****************************************************************************/
PROCEDURE Exporta_Registros:

    DEF     VAR aux_usatalao AS LOGICAL                                NO-UNDO.
    DEF     VAR aux_dtabtcct AS DATE      FORMAT "99/99/9999"          NO-UNDO.
    DEF     VAR aux_dtabtcc2 AS DATE      FORMAT "99/99/9999"          NO-UNDO.
    DEF     VAR aux_cddocttl AS INT       FORMAT "99"                  NO-UNDO.
    DEF     VAR aux_dstelefo AS CHAR                                   NO-UNDO.
    DEF     VAR aux_cdsexotl AS CHAR                                   NO-UNDO.
    DEF     VAR aux_dtinires AS CHAR                                   NO-UNDO.
    DEF     VAR aux_cdoedttl AS CHAR                                   NO-UNDO.
    
    DEF BUFFER crabttl FOR crapttl.
    DEF BUFFER crabass FOR crapass.
    
    ASSIGN aux_dstelefo = REPLACE(SUBSTRING(crapcop.nrtelvoz,6,9),"-","").
                                               /* Telefone Cooperativa */
    
    FOR EACH w_ctitg NO-LOCK ON ERROR UNDO, LEAVE:
    
        FIND crapass WHERE crapass.cdcooper = glb_cdcooper      AND
                           crapass.nrdconta = w_ctitg.nrdconta  NO-LOCK NO-ERROR.
        IF  NOT AVAILABLE crapass   THEN
            NEXT.
    
        IF   w_ctitg.cddoptit <> "E"   THEN
        DO:
            FIND crapttl WHERE crapttl.cdcooper = glb_cdcooper      AND
                               crapttl.nrdconta = w_ctitg.nrdconta  AND
                               crapttl.idseqttl = w_ctitg.idseqttl
                               NO-LOCK NO-ERROR.
            IF  NOT AVAILABLE crapttl   THEN
                NEXT.
        END.
    
        ASSIGN aux_dtabtcc2 = ?.
    
        /* Data de abertura de conta mais antiga no SFN */
        FOR EACH crapsfn WHERE  crapsfn.cdcooper = glb_cdcooper     AND
                                crapsfn.nrcpfcgc = crapass.nrcpfcgc AND
                                crapsfn.tpregist = 1                NO-LOCK
                                    BY crapsfn.dtabtcct DESCENDING:
    
            ASSIGN aux_dtabtcc2 = crapsfn.dtabtcct. 
    
        END.
    
        IF  crapass.dtabtcct <> ?   AND 
            crapass.dtabtcct <  crapass.dtadmiss   THEN
            ASSIGN aux_dtabtcct = crapass.dtabtcct. 
        ELSE
            ASSIGN aux_dtabtcct = crapass.dtadmiss.
    
        IF  aux_dtabtcc2 <> ?   AND 
            aux_dtabtcc2 <  aux_dtabtcct   THEN
            ASSIGN aux_dtabtcct = aux_dtabtcc2.
    
        IF  aux_dtabtcct = ?   THEN
            RETURN "NOK".
    
        /* registro tipo 1 */
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_nrtotcli = aux_nrtotcli + 1
               aux_usatalao = IF crapass.cdsitdct = 1  THEN YES
                                                       ELSE NO
               aux_dsdlinha = STRING(SUBSTRING(crapass.nrdctitg,1,7),"x(7)") +
                              STRING(SUBSTRING(crapass.nrdctitg,8,1),"x(1)").
                              
        IF  w_ctitg.cddoptit = "I"   THEN
            ASSIGN aux_dsdlinha = aux_dsdlinha + "3".
        ELSE
            ASSIGN aux_dsdlinha = aux_dsdlinha + "5".
    
        ASSIGN aux_dsdlinha = aux_dsdlinha +
                              "0" +
                              STRING(aux_usatalao,"S/N") +
                              STRING(aux_dtabtcct,"99999999") +
                              STRING(w_ctitg.idseqttl,"9") +
                              STRING(w_ctitg.nrdconta,"99999999") +
                              "         " +
                              "0000". /* Cod. modalidade */
                              /* o restante sao brancos */
                                           
        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(143)" SKIP.
        
        /* Na exclusao precisa somente do tipo 1 */
        IF   w_ctitg.cddoptit = "I"   THEN
        DO:
                   /* sexo */
            ASSIGN aux_cdsexotl = IF   crapttl.cdsexotl = 1  THEN "M" 
                                                             ELSE "F"
            
                   /* Codigo do documento */
                   aux_cddocttl = IF   crapttl.tpdocttl = "CI"   THEN
                                       20
                                  ELSE
                                  IF   crapttl.tpdocttl = "CH"   THEN
                                       31
                                  ELSE
                                       21
    
                   /* tempo de residencia */
                   aux_dtinires = STRING(MONTH(crapenc.dtinires), "99") +
                                  STRING(YEAR(crapenc.dtinires), "9999").
    
            IF  crapttl.dtnasttl = ?   THEN
                RETURN "NOK".
    
            IF  aux_dtinires = ?   THEN
                RETURN "NOK".
    
            /* registro tipo 2 */
            ASSIGN aux_nrregist = aux_nrregist + 1
                   aux_dsdlinha = STRING(SUBSTRING(crapass.nrdctitg,1,7),
                                                   "x(7)") +
                                  STRING(SUBSTRING(crapass.nrdctitg,8,1),
                                                   "x(1)") +
                                  STRING(w_ctitg.nrcpfcgc,"99999999999999")+
                                  STRING(crapttl.inpessoa,"9")          +
                                  STRING(crapttl.dtnasttl,"99999999")   +
                                  STRING(crapttl.nmextttl,"x(50)")      +
                                  STRING(crapttl.nmtalttl,"x(25)").
                                  /* o restante sao brancos */
                                       
            PUT STREAM str_1  aux_nrregist FORMAT "99999" "02".
            PUT STREAM str_1  aux_dsdlinha FORMAT "x(143)" SKIP.
    
            IF  crapttl.dtemdttl = ?   THEN
                RETURN "NOK".
            
            /* Retornar orgao expedidor */
            IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
                RUN sistema/generico/procedures/b1wgen0052b.p 
                    PERSISTENT SET h-b1wgen0052b.

            ASSIGN aux_cdoedttl = "".
            RUN busca_org_expedidor IN h-b1wgen0052b 
                               ( INPUT crapttl.idorgexp,
                                OUTPUT aux_cdoedttl,
                                OUTPUT glb_cdcritic, 
                                OUTPUT glb_dscritic).

            DELETE PROCEDURE h-b1wgen0052b.   

            IF  RETURN-VALUE = "NOK" THEN
            DO:
                ASSIGN aux_cdoedttl = 'NAO CADAST'.
            END.            
            
            
            /* registro tipo 3 */                
            ASSIGN aux_nrregist = aux_nrregist + 1
                   aux_dsdlinha = STRING(SUBSTRING(crapass.nrdctitg,1,7),
                                                           "x(7)")    +
                                  STRING(SUBSTRING(crapass.nrdctitg,8,1),
                                                           "x(1)")    +
                                  STRING(aux_cdsexotl,"x(1)")         +
                                  STRING(crapttl.tpnacion,"99")       + 
                                  STRING(crapttl.dsnatura,"x(25)")    + 
                                  STRING(aux_cddocttl,"99")           +
                                  STRING(crapttl.nrdocttl,"x(20)")    + 
                                  STRING(aux_cdoedttl,"x(15)")        +
                                  STRING(crapttl.dtemdttl,"99999999") +
                                  STRING(crapttl.cdestcvl,"99")       +
                                  "01" +
                                  STRING(crapttl.cdfrmttl,"999")      +
                                  STRING(crapttl.grescola,"999")      +
                                  STRING(crapttl.cdnatopc,"999")      +
                                  STRING(crapttl.cdocpttl,"999")      +
                                  "000000000000100"                   +
                                  STRING(MONTH(glb_dtmvtolt),"99")    +
                                  STRING(YEAR(glb_dtmvtolt),"9999").
                                      
            PUT STREAM str_1  aux_nrregist FORMAT "99999" "03".
            PUT STREAM str_1  aux_dsdlinha FORMAT "x(143)" SKIP.
    
            /* registro tipo 4 */
            ASSIGN aux_nrregist = aux_nrregist + 1
                   aux_dsdlinha = STRING(SUBSTRING(crapass.nrdctitg,1,7),
                                                   "x(7)") +
                                  STRING(SUBSTRING(crapass.nrdctitg,8,1),
                                                   "x(1)") +
                                  STRING(crapttl.nmmaettl,"x(50)")    +
                                  STRING(crapttl.nmpaittl,"x(50)").
                                  /* o restante sao brancos */ 
    
            PUT STREAM str_1  aux_nrregist FORMAT "99999" "04".
            PUT STREAM str_1  aux_dsdlinha FORMAT "x(143)" SKIP.
    
            /* Busca o conjuge */
            FIND crapcje WHERE crapcje.cdcooper = crapttl.cdcooper   AND 
                               crapcje.nrdconta = crapttl.nrdconta   AND 
                               crapcje.idseqttl = crapttl.idseqttl
                               NO-LOCK NO-ERROR.
            IF   AVAILABLE crapcje   THEN
            DO:
    
                /* registro tipo 5 */
                ASSIGN aux_nrregist = aux_nrregist + 1
                       aux_dsdlinha = STRING(SUBSTRING(crapass.nrdctitg,
                                             1,7),"x(7)") +
                                      STRING(SUBSTRING(crapass.nrdctitg,
                                             8,1),"x(1)").
                
                /* Verifica se o conjuge eh associado */
                FIND FIRST crabttl WHERE crabttl.cdcooper = 
                                           crapcje.cdcooper   AND
                                         crabttl.nrdconta =
                                           crapcje.nrctacje
                                           NO-LOCK NO-ERROR.
                IF  AVAILABLE crabttl   THEN
                    ASSIGN aux_dsdlinha = aux_dsdlinha +
                           STRING(crabttl.nrcpfcgc,"99999999999") +
                           STRING(crabttl.dtnasttl,"99999999")    +
                           STRING(crabttl.nmextttl,"x(50)").
                           /* o restante sao brancos */ 
                ELSE
                    ASSIGN aux_dsdlinha = aux_dsdlinha +
                           STRING(crapcje.nrcpfcjg,"99999999999") +
                           STRING(crapcje.dtnasccj,"99999999")    +
                           STRING(crapcje.nmconjug,"x(50)").
                
                IF  aux_dsdlinha = ?   THEN
                    RETURN "NOK".
                
                PUT STREAM str_1  aux_nrregist FORMAT "99999" "05".
                PUT STREAM str_1  aux_dsdlinha FORMAT "x(143)" SKIP.
                
            END.
    
            /* registro tipo 6 */
            ASSIGN glb_nrcalcul = crapttl.nrcpfemp.
    
            RUN fontes/cpfcgc.p.
    
            ASSIGN aux_nrregist = aux_nrregist + 1
                   aux_dsdlinha = STRING(SUBSTRING(crapass.nrdctitg,1,7),
                                                   "x(7)") +
                                  STRING(SUBSTRING(crapass.nrdctitg,8,1),
                                                   "x(1)") +
                                  STRING(crapttl.tpcttrab,"9") +
                                  STRING(shr_inpessoa,"9")     +
                                  STRING(crapttl.nrcpfemp,"99999999999999").
    
            IF  crapttl.dtadmemp <> ?   THEN
                aux_dsdlinha = aux_dsdlinha + 
                               STRING(MONTH(crapttl.dtadmemp),"99")  +
                               STRING(YEAR(crapttl.dtadmemp),"9999").
            ELSE
                aux_dsdlinha = aux_dsdlinha + "      ".
    
            ASSIGN aux_dsdlinha = aux_dsdlinha +
                           STRING(crapttl.nmextemp,"x(50)") +
                           STRING(crapttl.dsproftl,"x(50)") +
                           STRING(crapttl.cdnvlcgo,"9").
                           /* o restante sao brancos */ 
    
            PUT STREAM str_1  aux_nrregist FORMAT "99999" "06".
            PUT STREAM str_1  aux_dsdlinha FORMAT "x(143)" SKIP.
    
            /* registro tipo 7 */
            ASSIGN aux_nrregist = aux_nrregist + 1.
    
            FIND FIRST crawcrd WHERE crawcrd.cdcooper = glb_cdcooper     AND
                                     crawcrd.nrdconta = crapass.nrdconta AND
                                    (crawcrd.cdadmcrd >= 83 AND
                                     crawcrd.cdadmcrd <= 88)
                                    NO-LOCK NO-ERROR.
            IF   AVAILABLE crawcrd  THEN
            DO:
                FIND crapenc WHERE 
                     crapenc.cdcooper = glb_cdcooper      AND
                     crapenc.nrdconta = crapass.nrdconta  AND
                     crapenc.idseqttl = 1                 AND
                     crapenc.cdseqinc = 1 NO-LOCK NO-ERROR.
    
                ASSIGN aux_dsdlinha = 
                       STRING(SUBSTRING(crapass.nrdctitg,1,7),
                                        "x(7)") +
                       STRING(SUBSTRING(crapass.nrdctitg,8,1),
                                        "x(1)") +
                       STRING((SUBSTRING(crapenc.dsendere,1,27)  +
                                        "  "                     +
                       TRIM(STRING(crapenc.nrendere,"zzzzzz"))),
                                        "x(35)")                 +
                       STRING(crapenc.nmbairro,"x(30)")          +
                       STRING(crapenc.nrcepend,"99999999")       +
                       SUBSTRING(crapcop.nrtelvoz,2,2)           +
                       STRING(aux_dstelefo,"x(9)")               +
                       STRING(crapenc.nrcxapst,"999999999")      +
                       STRING(crapenc.incasprp,"99")             +
                       STRING(aux_dtinires,"x(6)").
                       /* o restante sao brancos */
            END.
            ELSE
                /* Endereco da Cooperativa */
                ASSIGN aux_dsdlinha = 
                                 STRING(SUBSTRING(crapass.nrdctitg,1,7),
                                                  "x(7)") +
                                 STRING(SUBSTRING(crapass.nrdctitg,8,1),
                                                  "x(1)") +
                                 STRING((crapcop.dsendcop + ", "      +
                                 STRING(crapcop.nrendcop)),"x(35)")   +
                                 STRING(crapcop.nmbairro,"x(30)")     +
                                 STRING(crapcop.nrcepend,"99999999")  +
                                 SUBSTRING(crapcop.nrtelvoz,2,2)      +
                                 STRING(aux_dstelefo,"x(9)")          +
                                 STRING(crapcop.nrcxapst,"999999999") +
                                 "01"                                 +
                                 STRING(aux_dtinires,"x(6)").
                                 /* o restante sao brancos */ 
    
            IF  aux_dsdlinha = ?   THEN
                RETURN "NOK".
    
            PUT STREAM str_1  aux_nrregist FORMAT "99999" "07".
            PUT STREAM str_1  aux_dsdlinha FORMAT "x(143)" SKIP.
    
            /* registro tipo 8 */
            ASSIGN aux_nrregist = aux_nrregist + 1
                   aux_dsdlinha = STRING(SUBSTRING(crapass.nrdctitg,1,7),
                                                   "x(7)") +
                                  STRING(SUBSTRING(crapass.nrdctitg,8,1),
                                                   "x(1)") +
                                  STRING(w_ctitg.idseqttl,"9")    +
                                  SUBSTRING(crapcop.nrtelvoz,2,2) +
                                  STRING(aux_dstelefo,"x(9)").
                                  /* o restante sao brancos */ 
    
            IF  aux_dsdlinha = ?   THEN
                RETURN "NOK".
    
            PUT STREAM str_1  aux_nrregist FORMAT "99999" "08".
            PUT STREAM str_1  aux_dsdlinha FORMAT "x(143)" SKIP.
    
        END. /* Fim INCLUSAO */
    
        /* Para cada registro informado gravar na DSBITG.LOG ao finalizar a operação (F8) */
        IF w_ctitg.cddoptit = "I" THEN
            UNIX SILENT VALUE("echo " + 
                            STRING(glb_dtmvtolt,"99/99/9999") + " "               +
                            STRING(TIME,"HH:MM:SS") + "' --> '"                   +
                                        " Operador " + glb_cdoperad + " incluiu o titular "   +
                                        STRING(w_ctitg.idseqttl) + " [CPF: "                  + 
                            STRING(w_ctitg.nrcpfcgc) + "]"                        +
                            " na Conta ITG: "                                     + 
                            STRING(w_ctitg.nrdctitg,"x.xxx.xxx-x")                +
                            " Conta: " + STRING(w_ctitg.nrdconta,"zzzz,zzz,9")         + 
                            " >> log/dsbitg.log").
        ELSE
            UNIX SILENT VALUE("echo " + 
                            STRING(glb_dtmvtolt,"99/99/9999") + " "               +
                            STRING(TIME,"HH:MM:SS") + "' --> '"                   +
                                        " Operador " + glb_cdoperad + " excluiu o titular "   +
                                        STRING(w_ctitg.idseqttl)                              + 
                            " da Conta ITG: "                                     + 
                            STRING(w_ctitg.nrdctitg,"x.xxx.xxx-x")                +
                            " Conta: " + STRING(w_ctitg.nrdconta,"zzzz,zzz,9")         + 
                            " >> log/dsbitg.log").
        /* FIM */
        
        /* atualiza a data de envio da crapass */
        DO WHILE TRUE:
        
            FIND crabass WHERE crabass.cdcooper = glb_cdcooper  AND
                               crabass.nrdconta = crapass.nrdconta 
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
            
            IF   NOT AVAILABLE crabass   THEN
                 DO:
                     IF   LOCKED crabass    THEN
                          DO:
                              glb_cdcritic = 72.
                              PAUSE 1 NO-MESSAGE.
                              NEXT.
                          END.
                 END.
            ELSE
                 glb_cdcritic = 0.
            
            LEAVE.
        END.  /*  Fim do DO .. TO  */
        
        IF glb_cdcritic > 0 THEN
            UNDO, RETURN.
        
         ASSIGN crabass.dtectitg = glb_dtmvtolt.
    
    END. /* FOR EACH w_ctitg */
    
    RELEASE crabass NO-ERROR.
    
    RETURN.

END PROCEDURE.

PROCEDURE proc_nrcrcard:

    DEF INPUT  PARAM par_tel_nrdconta LIKE crawcrd.nrdconta.
    DEF INPUT  PARAM par_aux_nrcpfcgc LIKE crapass.nrcpfcgc.
    DEF INPUT  PARAM par_tel_nrcrcard LIKE crawcrd.nrcrcard.
    DEF OUTPUT PARAM par_nrcctitg     AS CHAR.
    DEF OUTPUT PARAM par_nrcpftit     LIKE crawcrd.nrcpftit.

    FIND FIRST crawcrd NO-LOCK 
         WHERE crawcrd.cdcooper = glb_cdcooper
           AND crawcrd.nrdconta = par_tel_nrdconta 
           AND crawcrd.nrcpftit = par_aux_nrcpfcgc 
           AND crawcrd.nrcrcard = par_tel_nrcrcard
           AND crawcrd.insitcrd = 6 NO-ERROR.
    IF NOT AVAIL crawcrd THEN
        RETURN "NOK".
    ELSE
        ASSIGN par_nrcctitg = string(crawcrd.nrcctitg,"999999999")
               par_nrcpftit = crawcrd.nrcpftit.

    RETURN.
    
END PROCEDURE.

PROCEDURE proc_criarq_COO410:
    
    /* Atualizacao da craptab */
    FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                       craptab.nmsistem = "CRED"         AND
                       craptab.tptabela = "GENERI"       AND
                       craptab.cdempres = 0              AND
                       craptab.cdacesso = "NRARQMVITG"   AND
                       craptab.tpregist = 410            
                       EXCLUSIVE-LOCK NO-ERROR.
    IF  NOT AVAIL craptab   THEN
    DO:
        IF  LOCKED craptab   THEN
        DO:
            MESSAGE "Registro de Tabelas em uso por outro usuario!"
                    " Tente novamente."
                VIEW-AS ALERT-BOX WARNING BUTTONS OK.
    
            RETURN.
        END.
        ELSE 
        DO:
            glb_cdcritic = 393.
            RUN fontes/critic.p.
            MESSAGE glb_dscritic
                VIEW-AS ALERT-BOX INFO BUTTONS OK.
    
            RETURN.
        END.
    END.
    
    IF  INT(SUBSTR(craptab.dstextab,07,01)) = 1 THEN
    DO:
        MESSAGE "COO410 - " glb_cdprogra SKIP
                "PROGRAMA BLOQUEADO PARA ENVIAR ARQUIVOS"
            VIEW-AS ALERT-BOX ERROR BUTTONS OK.
        RETURN.
    END.
    
    /*************************** ABRE ARQUIVO ***************************/
    ASSIGN aux_nrtextab = INTEGER(SUBSTRING(craptab.dstextab,1,5))
           aux_nmarqimp = "coo410" +
                          STRING(DAY(glb_dtmvtolt),"99") +
                          STRING(MONTH(glb_dtmvtolt),"99") +
                          STRING(aux_nrtextab,"99999") + ".rem"
           aux_nrregist = 0
           aux_nrtotcli = 0.
    
    OUTPUT STREAM str_1 TO VALUE("arq/" + aux_nmarqimp).
    
    /* header */
    ASSIGN aux_dsdlinha = "0000000"                            +
                          STRING(crapcop.cdageitg,"9999")      + 
                          STRING(crapcop.nrctaitg,"99999999")  + 
                          "COO410  "                           + 
                          STRING(aux_nrtextab,"99999")         +
                          STRING(glb_dtmvtolt,"99999999")      +
                          STRING(crapcop.cdcnvitg,"999999999") + 
                          STRING(crapcop.cdmasitg,"99999").

    ASSIGN aux_dsdlinha = aux_dsdlinha + FILL(" ", 150 - LENGTH(aux_dsdlinha)).
    
    PUT STREAM str_1 UNFORMATTED aux_dsdlinha SKIP.
    /************************* ABRE ARQUIVO - FIM ***********************/

    /************************* REGISTRO TIPO 16 ************************/
    FOR EACH w_ctitg:
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(aux_nrregist,"99999")           +           
                              "16"                                   +           
                              w_ctitg.nrcctitg                       +                     
                              STRING(w_ctitg.nrcpfcgc,"99999999999") +              
                              "                 "                    +
                              "1"                                    +
                              "3".

        ASSIGN aux_dsdlinha = aux_dsdlinha + 
                                        FILL(" ", 150 - LENGTH(aux_dsdlinha)).
                              
        PUT STREAM str_1 UNFORMATTED aux_dsdlinha SKIP.  

        /***************************** CRIAR LOG *****************************/                               
        UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " "      +
                          STRING(TIME,"HH:MM:SS") + "' --> '"                    +
                          " Operador " + glb_cdoperad                            + 
                          " solicitou encerramento do cartao "                   +
                          STRING(w_ctitg.nrcrcard,"9999,9999,9999,9999")         +
                          " [Conta: "                                            +
                          STRING(w_ctitg.nrdconta,"zzzz,zz9,9")                  +
                          " Conta ITG: "                                         +
                          STRING(w_ctitg.nrdctitg,"x.xxx.xxx-x")                 +
                          " CPF: " + string(w_ctitg.nrcpfcgc) + "]"              +
                          " >> log/dsbitg.log").
        /************************** CRIAR LOG - FIM **************************/

    END.
    /************************ REGISTRO TIPO 16 - FIM **********************/
     
    /************************** FECHA ARQUIVO ***************************/
    /* trailer */
    /* total de registros + header + trailer */
    ASSIGN aux_nrregist = aux_nrregist + 2
           aux_dsdlinha = "9999999"    +
                          "00000"      + 
                          STRING(aux_nrregist,"999999999").
                          
    ASSIGN aux_dsdlinha = aux_dsdlinha + FILL(" ", 150 - LENGTH(aux_dsdlinha)).
    
    PUT STREAM str_1 UNFORMATTED aux_dsdlinha.
    
    OUTPUT STREAM str_1 CLOSE.
    
    IF  RETURN-VALUE = "NOK"   THEN
    DO: 
        MESSAGE "Problemas ao gerar arquivo. " +
                "Favor revisar cadastro. ".
        RETURN.
    END.
    /************************ FECHA ARQUIVO - FIM ***********************/
    
    /********************************************************************/
    
    /* verifica se o arquivo gerado nao tem registros "detalhe" */
    IF  aux_nrregist <= 2   THEN
    DO:
        UNIX SILENT VALUE("rm arq/" + aux_nmarqimp + " 2>/dev/null").
        LEAVE.        
    END.
    
    ASSIGN glb_cdcritic = 847.
    RUN fontes/critic.p.
    
    /* copia o arquivo para diretorio "compel" para poder ser enviado ao BB */
    UNIX SILENT VALUE("ux2dos < arq/" + aux_nmarqimp +  
                      ' | tr -d "\032"' +  
                      " > /micros/" + crapcop.dsdircop +
                      "/compel/" + aux_nmarqimp + " 2>/dev/null").  
    
    UNIX SILENT VALUE("mv arq/" + aux_nmarqimp + " salvar 2>/dev/null").
    /********************************************************************/
    
    ASSIGN SUBSTRING(craptab.dstextab,1,5) = STRING(aux_nrtextab + 1,"99999").
    
    /* Limpar a tela após efetivar as alterações */
    EMPTY TEMP-TABLE w_ctitg.
    ASSIGN aux_qtrgtab = 0.
    
    MESSAGE "Arquivo gerado com sucesso.".
    PAUSE 2 NO-MESSAGE.
    
    CLEAR FRAME f_list_tit  ALL NO-PAUSE.
    CLEAR FRAME f_list_tit2 ALL NO-PAUSE.
    CLEAR FRAME f_list_tit3 ALL NO-PAUSE.
    /************** FIM **************/

END PROCEDURE.

/*****************************************************************************/
/* Cria o arquivo COO409 [com CPF's nulos]. */
PROCEDURE proc_criarq_COO409:
        
    DEFINE VARIABLE  aux_nrcpfcgc2      AS CHAR     NO-UNDO.
    DEFINE VARIABLE  aux_nrregist       AS INT      NO-UNDO.
 
    FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                       craptab.nmsistem = "CRED"         AND
                       craptab.tptabela = "GENERI"       AND
                       craptab.cdempres = 0              AND
                       craptab.cdacesso = "NRARQMVITG"   AND
                       craptab.tpregist = 409            
                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

    IF  NOT AVAIL craptab   THEN
    DO:
        IF  LOCKED craptab   THEN
        DO:
            MESSAGE "Registro de Tabelas em uso por outro usuario!"
                    " Tente novamente."
                VIEW-AS ALERT-BOX WARNING BUTTONS OK.
    
            RETURN.
        END.
        ELSE 
        DO:
            glb_cdcritic = 393.
            RUN fontes/critic.p.
            MESSAGE glb_dscritic
                VIEW-AS ALERT-BOX INFO BUTTONS OK.
    
            RETURN.
        END.
    END.

    IF  INT(SUBSTR(craptab.dstextab,07,01)) = 1 THEN
    DO:
        MESSAGE "COO409 - " glb_cdprogra SKIP
                "PROGRAMA BLOQUEADO PARA ENVIAR ARQUIVOS"
            VIEW-AS ALERT-BOX ERROR BUTTONS OK.
        RETURN.
    END.

/* HEADER */

    ASSIGN aux_nrtextab = INTEGER(SUBSTRING(craptab.dstextab,1,5))
           aux_nmarqimp = "coo409" +
                         STRING(DAY(glb_dtmvtolt),"99") +
                         STRING(MONTH(glb_dtmvtolt),"99") +
                         STRING(aux_nrtextab,"99999") + ".rem"
        aux_nrregist = 0.

   OUTPUT STREAM str_2 TO VALUE("arq/" + aux_nmarqimp).

   ASSIGN aux_dsdlinha = "0000000"  +
                         STRING(crapcop.cdageitg,"9999") + 
                         STRING(crapcop.nrctaitg,"99999999") + 
                         "COO409  " + 
                         STRING(aux_nrtextab,"99999")  +
                         STRING(glb_dtmvtolt,"99999999")  +
                         STRING(crapcop.cdcnvitg,"999999999") + 
                         FILL(" ", 21).
                      
   PUT STREAM str_2 aux_dsdlinha SKIP.

/* CONTEÚDO */

    FOR EACH w_ctitg NO-LOCK:
    
        ASSIGN aux_nrcpfcgc2 = "00000000000"
               aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(w_ctitg.nrdctitg,1,7),"x(7)") +
                              STRING(SUBSTRING(w_ctitg.nrdctitg,8,1),"x(1)")
               aux_dsdlinha = aux_dsdlinha                                   +
                              "1"                                            +                        
                              STRING(w_ctitg.nrcpfcgc, "99999999999999")     +
                              aux_nrcpfcgc2                                  +
                              "0124"                                         +
                              "        ".
    
        PUT STREAM str_2  aux_nrregist FORMAT "99999" "01"
                   aux_dsdlinha FORMAT "x(63)" SKIP.
    
        /*** Cria log das alteracoes ***/                                 
        UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " "    +
                         STRING(TIME,"HH:MM:SS") + "' --> '"                   +
                         " Operador " + glb_cdoperad + " solicitou o "         +
                          "encerramento da "                                   +
                         "Conta ITG " + STRING(w_ctitg.nrdctitg,"x.xxx.xxx-x") +
                         " >> log/dsbitg.log").
    
    END.

  /* TRAILER */

   /* total de registros + header + trailer */
   ASSIGN aux_nrregist = aux_nrregist + 2
          aux_dsdlinha = "9999999" + STRING(aux_nrregist,"999999999").
                         
   PUT STREAM str_2 aux_dsdlinha SKIP.

   OUTPUT STREAM str_2 CLOSE.
   
   IF   aux_nrregist <= 2   THEN
        DO:
            UNIX SILENT VALUE("rm arq/" + aux_nmarqimp + " 2>/dev/null").
            LEAVE.        
        END.

   /* copia o arquivo para diretorio "compel" para poder ser enviado ao BB */
   UNIX SILENT VALUE("ux2dos < arq/" + aux_nmarqimp +  
                     ' | tr -d "\032"' +  
                     " > /micros/" + crapcop.dsdircop +
                     "/compel/" + aux_nmarqimp + " 2>/dev/null").  
            
   UNIX SILENT VALUE("mv arq/" + aux_nmarqimp + " salvar 2>/dev/null").

   /* Atualizacao da craptab */
   ASSIGN SUBSTRING(craptab.dstextab,1,5) =
      STRING(int(SUBSTRING(craptab.dstextab,1,5)) + 1,"99999").

   FIND CURRENT craptab NO-LOCK NO-ERROR.
   RELEASE craptab.

   MESSAGE "Arquivo gerado com sucesso.".
   PAUSE 2 NO-MESSAGE.
   
END PROCEDURE.

/*****************************************************************************/

PROCEDURE encerra_conta_itg:
        
    ASSIGN aux_confirma = NO
           tel_nrdctitg:HELP IN FRAME f_dsbitg2 = 
           "Informe a conta ITG ou tecle <F8> para finalizar."
           tel_nrdctitg = "".

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
         IF glb_cdcritic > 0 THEN
         DO:
             RUN fontes/critic.p.
             MESSAGE glb_dscritic.
             glb_cdcritic = 0.
             PAUSE 2 NO-MESSAGE.
         END.
  
         UPDATE tel_nrdctitg WITH FRAME f_dsbitg2
         EDITING :
             READKEY.
        
             IF LASTKEY = KEYCODE("F8") THEN
             DO:
                 DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                     ASSIGN aux_confirma = FALSE
                            glb_cdcritic = 78.
                     RUN fontes/critic.p.
                     HIDE MESSAGE NO-PAUSE.
                     glb_cdcritic = 0.
                     MESSAGE glb_dscritic UPDATE aux_confirma.
                     LEAVE.
                 END. /* FIM - DO WHILE TRUE ON ENDKEY UNDO, LEAVE */
             
                 IF KEYFUNCTION(LASTKEY) = "END-ERROR" OR
                    NOT aux_confirma                   THEN
                 DO:
                     glb_cdcritic = 79.
                     NEXT.
                 END.
                  /* Chama a procedure que gera o arquivo COO409 [com CPFs nulos] */
                  RUN proc_criarq_COO409.
                  aux_flgalter = TRUE.
                  LEAVE.
             END.      
             ELSE
                 APPLY LASTKEY.
         END. /*** Fim do EDITING ***/ 

         IF aux_flgalter THEN
            LEAVE.
             
         DO WHILE LENGTH(tel_nrdctitg) < 8:
            tel_nrdctitg = "0" + tel_nrdctitg.
         END.
        /* Não permite que a número da conta ITG seja zero */
         IF CAN-DO("00000000",tel_nrdctitg) THEN DO:
             MESSAGE "Conta ITG invalida.".
             NEXT.
         END.
         ELSE DO:   

            FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                               crapass.nrdctitg = tel_nrdctitg NO-LOCK NO-ERROR.
            IF AVAIL crapass THEN DO:
                MESSAGE "ERRO: Conta ITG vinculada a Conta/dv " + STRING (crapass.nrdconta,"zzzz,zz9,9") + ".".
                NEXT.
            END.
         END.
                
         DISPLAY tel_nrdctitg WITH FRAME f_dsbitg2.
         
         IF glb_cdcritic > 0 THEN
             NEXT.
         
         IF aux_qtrgtab = 8 THEN
         DO:
             HIDE MESSAGE NO-PAUSE.
             MESSAGE "Nao podem ser inseridas mais de 8 contas.".
             PAUSE 2 NO-MESSAGE.
             NEXT.
         END.
         
         IF CAN-FIND(w_ctitg WHERE 
                     w_ctitg.nrdctitg = tel_nrdctitg) THEN
         DO:
             MESSAGE "Conta ITG ja foi adicionada.".
             PAUSE 2 NO-MESSAGE.
             NEXT.
         END.
                     
         CREATE w_ctitg.
         ASSIGN w_ctitg.nrdctitg  = tel_nrdctitg
                w_ctitg.nrcpfcgc  = 0
                w_ctitg.nrcpfcgc2 = 0
                w_ctitg.cddopcao  = glb_cddopcao
                aux_qtrgtab       = aux_qtrgtab + 1.
          
         DISPLAY w_ctitg.nrdctitg
                 WITH FRAME f_list2.
         
         DOWN WITH FRAME f_list2.
         
         ASSIGN tel_nrdctitg  = "".
      
    END. /* FIM - DO WHILE TRUE ON ENDKEY UNDO, LEAVE */

    RETURN "OK".

END PROCEDURE.

/*****************************************************************************/
