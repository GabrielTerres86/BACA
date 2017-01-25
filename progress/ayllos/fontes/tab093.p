/* ...........................................................................

   Programa: Fontes/tab093.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lucas/Guilherme
   Data    : Março/2012.                     Ultima atualizacao: 07/12/2016

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Parametrização para vlr. de docs a serem digitalizados.

   Alteracoes: 07/05/2012 - Retirada opção B(Batimento) da tela, rotina 
                            transferida para tela PRCGED (Guilherme Maba).

               28/06/2012 - Liberar departamento SUPORTE (Guilherme).

               22/08/2013 - Inclusão do campo "Cadastro liberado?" e ajuste para
                            salvar emails (Jean Michel).  

               09/10/2013 - Inclusão do campo "Valor de Fluxo" (Jean Michel). 

               13/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( Andre Euzebio / SUPERO)
                            
               14/01/2013 - Alterado o format do campo nmoperac e alterado
                            a opção de alteração p/ poder ser feito a mudança
                            do nome da operação. (Jean Michel)
                            
               19/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)

               01/10/2014 - Unificar documento de identidade e CPF. Chamado
                            146840 (Jonata-RKAM). 
                            
               19/11/2015 - Alterado para que ao inserir um novo registro seja 
                            feito para todas as cooperativas sem levar em consideracao
                            a cooper que o operador esta logado e tambem foi adicionado
                            um novo departamento para poder acessar essas funcoes "COMPE"
                            conforme solicitado no chamado 322804 (Kelvin).                                                        
               
               25/03/2016 - Ajustes de permissao conforme solicitado no chamado 358761 (Kelvin).    
                            
               20/09/2016 - Adicionar filtro de data para o 620_termos (Lucas Ranghetti #480384/#469603)     
                            
               07/12/2016 - Alterado campo dsdepart para cddepart.
                            PRJ341 - BANCENJUD (Odirlei-AMcom)
                            
..............................................................................*/

{ includes/var_online.i }
{ sistema/generico/includes/b1wgen0137tt.i }
{ sistema/generico/includes/var_internet.i }

DEF  VAR aux_cddopcao  AS CHAR                                          NO-UNDO.
DEF  VAR aux_nmoperac  AS CHAR                                          NO-UNDO.
DEF  VAR aux_tpregist  AS INT                                           NO-UNDO.
DEF  VAR aux           AS INT                                           NO-UNDO.
DEF  VAR aux_confirma  AS CHAR     FORMAT "!"                           NO-UNDO.
DEF  VAR flg_envemail  AS LOGICAL  FORMAT "S/N"                         NO-UNDO.
DEF  VAR flg_digitlib  AS LOGICAL  FORMAT "S/N"                         NO-UNDO.
DEF  VAR tel_vldparam  AS DECIMAL  FORMAT "zzz,zzz,zz9.99"              NO-UNDO.
DEF  VAR tel_vlrfluxo  AS DECIMAL  FORMAT "zzz,zzz,zz9.99"              NO-UNDO.
DEF  VAR aux_msgdolog  AS CHAR                                          NO-UNDO.
DEF  VAR aux_logalter  AS CHAR                                          NO-UNDO.
DEF  VAR tel_dsdemail  AS CHAR     FORMAT "x(40)" EXTENT 6              NO-UNDO.
DEF  VAR tel_dstextab  AS CHAR     FORMAT "x(40)" EXTENT 3              NO-UNDO.
DEF  VAR aux_endemail  AS CHAR     FORMAT "x(50)"                       NO-UNDO.
DEF  VAR aux_posemail  AS INT      INIT 1                               NO-UNDO.
DEF  VAR aux_contador  AS INT                                           NO-UNDO.
DEF  VAR aux_tpdocmto  AS INT                                           NO-UNDO.
DEF  VAR aux_codsmart  AS INT                                           NO-UNDO.
/*DEF  VAR aux_dtvalida  AS DATE                                          NO-UNDO.*/
DEF  VAR aux_dtcadast  AS DATE                                          NO-UNDO.
DEF  VAR aux_dtcredit  AS DATE                                          NO-UNDO.
DEF  VAR aux_dttermos  AS DATE                                          NO-UNDO.
DEF  VAR aux_dscritic  AS CHAR                                          NO-UNDO.
DEF  VAR aux_nmcooper  AS CHAR                                          NO-UNDO.

DEF  VAR tel_cdcooper  AS CHAR        FORMAT "x(12)" VIEW-AS COMBO-BOX   
    INNER-LINES 11  NO-UNDO.

DEF        VAR aux_dadosusr AS CHAR                                  NO-UNDO.
DEF        VAR par_loginusr AS CHAR                                  NO-UNDO.
DEF        VAR par_nmusuari AS CHAR                                  NO-UNDO.
DEF        VAR par_dsdevice AS CHAR                                  NO-UNDO.
DEF        VAR par_dtconnec AS CHAR                                  NO-UNDO.
DEF        VAR par_numipusr AS CHAR                                  NO-UNDO.
DEF        VAR h-b1wgen9999 AS HANDLE                                NO-UNDO.


DEF BUFFER b-tt-documentos FOR tt-documentos.

DEF  QUERY q_documentos FOR tt-documentos.

DEF  BROWSE b_documentos QUERY q_documentos
     DISP STRING(tt-documentos.idseqite) + " - " + tt-documentos.nmoperac LABEL "" FORMAT "x(40)"
     WITH 6 DOWN WIDTH 45 OVERLAY TITLE " Documentos Disponiveis ".

DEF  FRAME f_documentos
           b_documentos
     HELP "Pressione <ENTER> p/ detalhes "
     WITH NO-BOX CENTERED OVERLAY ROW 8.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM SKIP(1)
      glb_cddopcao AT 5 LABEL "Opcao" AUTO-RETURN
                        HELP "Entre com a opcao desejada (C, A, I ou M)"
                        VALIDATE(CAN-DO("C,A,I,M",glb_cddopcao),
                                  "014 - Opcao errada.")
     SKIP(2)
     WITH ROW 5 COLUMN 2 OVERLAY SIDE-LABELS NO-LABEL NO-BOX FRAME f_tab093.

FORM SKIP(1)
     aux_tpregist AT 10 LABEL "Codigo" FORMAT "zz9"
                    HELP "Informe o codigo ou F7 para listar."
     SKIP(1)
     tt-documentos.nmoperac AT 3 FORMAT "x(40)" NO-LABEL   
     ":" AT 44
     tt-documentos.vldparam AT 46 NO-LABEL
                        HELP "Informe o valor a ser registrado."
                        VALIDATE(NOT CAN-DO("", tt-documentos.vldparam),
                                   "Insira um Valor.")
     SKIP
     tt-documentos.tpdocmto AT 16 LABEL "Tipo documento no Smartshare"
                        HELP "Informe o tipo de docmto cadastrado no Smartshare."
                        FORMAT "zzz9"
     SKIP
     tt-documentos.vlrfluxo AT 30 LABEL "Valor do Fluxo"
                        HELP "Informe o valor do fluxo."
                        VALIDATE(NOT CAN-DO("", tt-documentos.vlrfluxo),
                                   "Insira um Valor.")
                       
     SKIP(1)
     WITH SIDE-LABELS NO-BOX ROW 8 COLUMN 5 OVERLAY FRAME f_opcao_c.

FORM SKIP(1)
     aux_tpregist LABEL "Codigo" AT 13 FORMAT "zz9"
                        HELP "Informe um Codigo (0 para TODOS)."

     SKIP(1)
     aux_nmoperac LABEL "Descricao" AT 10 FORMAT "x(40)"
                        HELP "Informe uma Descricao."
                        VALIDATE(NOT CAN-DO("", aux_nmoperac),
                                   "Insira uma Descricao.")

     SKIP(1)
     tel_vldparam LABEL "Valor"     AT 14 
                        HELP "Informe o valor a ser registrado."
                        VALIDATE(NOT CAN-DO("", tel_vldparam),
                                   "Insira um Valor.")
     SKIP(1)
     aux_tpdocmto LABEL "Tipo de Documento"     AT 2
                  FORMAT "zzz9"
                  HELP "Informe o tipo de docmto cadastrado no Smartshare."
     SKIP(1)
     tel_vlrfluxo LABEL "Valor do Fluxo"     AT 5 
                        HELP "Informe o valor DO fluxo."
                        VALIDATE(NOT CAN-DO("", tel_vlrfluxo),
                                   "Insira um Valor.")
     SKIP(1)
     WITH ROW 8 COLUMN 5 OVERLAY SIDE-LABEL NO-BOX FRAME f_opcao_i.


FORM SKIP(1)
     aux_codsmart LABEL "Codigo da coop. no Smartshare" AT 4 FORMAT "zzz9"
                  HELP "Informe o codigo da cooperativa cadastrado no Smartshare"
     SKIP
     aux_dtcadast LABEL "Data Validacao de Cadastro" AT 7 FORMAT "99/99/9999"
                  HELP "Informe a data inicial para validar documentos digitalizados"
     SKIP
     aux_dtcredit LABEL "Data Validacao de Credito" AT 8 FORMAT "99/99/9999"
                  HELP "Informe a data inicial para validar documentos digitalizados"
     SKIP
     aux_dttermos LABEL "Data Validacao de Termos" AT 9 FORMAT "99/99/9999"
                  HELP "Informe a data inicial para validar documentos digitalizados"
     SKIP
     flg_digitlib LABEL "Cadastro liberado?" AT 15
     SKIP
     flg_envemail LABEL "Enviar relat. por email?" AT 9 
     SKIP                                                     
     tel_dsdemail[1] AT 15 LABEL " Emails para envio"
     HELP "Informe e-mails para envio."
     tel_dsdemail[2] AT 35 NO-LABEL 
     HELP "Informe e-mails para envio."
     tel_dsdemail[3] AT 35 NO-LABEL 
     HELP "Informe e-mails para envio."
     tel_dsdemail[4] AT 35 NO-LABEL 
     HELP "Informe e-mails para envio."
     tel_dsdemail[5] AT 35 NO-LABEL 
     HELP "Informe e-mails para envio."
     tel_dsdemail[6] AT 35 NO-LABEL 
     HELP "Informe e-mails para envio."
     SKIP(1)
     WITH ROW 7 COLUMN 5 OVERLAY SIDE-LABEL NO-BOX FRAME f_opcao_m.

FORM tel_cdcooper AT 07 LABEL "Cooperativa"
                        HELP "Selecione a Cooperativa"
     WITH ROW 6 COLUMN 12 SIDE-LABELS OVERLAY NO-BOX FRAME f_opcao_b.

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
   
VIEW FRAME f_moldura. 
PAUSE(0).

RUN fontes/inicia.p. 

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0.

ON RETURN OF tel_cdcooper DO:

  ASSIGN tel_cdcooper = tel_cdcooper:SCREEN-VALUE
         aux_contador = 0.

  APPLY "GO".

END.

lab:
DO WHILE TRUE:
        
    EMPTY TEMP-TABLE tt-documentos.
    IF  glb_cdcritic > 0   THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
        END. 
 
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
         
        UPDATE glb_cddopcao WITH FRAME f_tab093.
        
        IF  glb_cddepart <> 20   AND  /* TI       */
            glb_cddepart <>  7   AND  /* CONTROLE */
            glb_cddepart <>  4   AND  /* COMPE    */
            glb_cddopcao <> "C"  AND
            glb_cddopcao <> "M"  THEN
            DO:
                glb_cdcritic = 36.
                RUN fontes/critic.p.
                MESSAGE glb_dscritic.
                PAUSE 2 NO-MESSAGE.
                glb_cdcritic = 0.
                NEXT.
            END.
        LEAVE.
    END. 
                              
    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO: 
            RUN fontes/novatela.p.
            IF  CAPS(glb_nmdatela) <> "TAB093"   THEN
                DO: 
                    HIDE FRAME f_tab093.
                    RETURN.
                END.
             ELSE
                NEXT.
         END.
            
    IF   aux_cddopcao <> glb_cddopcao THEN
         DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
         END.

    ASSIGN aux_msgdolog = "".

    HIDE FRAME f_opcao_c NO-PAUSE.
    HIDE FRAME f_opcao_i NO-PAUSE.
    HIDE FRAME f_opcao_b NO-PAUSE.
    HIDE FRAME f_opcao_m NO-PAUSE.
    CLEAR FRAME f_opcao_c NO-PAUSE.
    CLEAR FRAME f_opcao_i NO-PAUSE.
    CLEAR FRAME f_opcao_b NO-PAUSE.
    CLEAR FRAME f_opcao_m NO-PAUSE.

    /* Alimenta a tabela de opcoes */
    FOR EACH craptab WHERE craptab.cdcooper = glb_cdcooper  AND         
                           craptab.nmsistem = "CRED"        AND         
                           craptab.tptabela = "GENERI"      AND         
                           craptab.cdempres = 00            AND         
                           craptab.cdacesso = "DIGITALIZA"
                           NO-LOCK:

        /* Desconsiderar o CPF */
        IF   craptab.tpregist = 6   THEN
             NEXT.

        /* Se forem alterados estes substring aqui tambem alterar na b1wgen0137 */
        CREATE tt-documentos.
        ASSIGN tt-documentos.nmoperac = ENTRY(1,craptab.dstextab,";")
               tt-documentos.vldparam = DECI(ENTRY(2,craptab.dstextab,";"))
               tt-documentos.tpdocmto = INTE(ENTRY(3,craptab.dstextab,";"))
               tt-documentos.idseqite = craptab.tpregist
               tt-documentos.vlrfluxo = DECI(ENTRY(4,craptab.dstextab,";")).
        
    END.

    IF  glb_cddopcao = "C"   THEN
        DO:
            ASSIGN aux_tpregist = 0.

            UPDATE aux_tpregist WITH FRAME f_opcao_c
                EDITING:
                    READKEY.
                                                                
                    IF  LASTKEY = KEYCODE("F7") THEN              
                        DO:
                            OPEN QUERY q_documentos FOR EACH tt-documentos NO-LOCK
                                                           BY tt-documentos.idseqite.
                    
                            ON RETURN OF b_documentos 
                                DO: 
                                    
                                  /* Armazena informação da opção escolhida */
                                    HIDE FRAME f_documentos.
                    
                                    ASSIGN aux_tpregist = tt-documentos.idseqite.
                    
                                    FIND tt-documentos WHERE 
                                         tt-documentos.idseqite = aux_tpregist NO-LOCK NO-ERROR.
                                    
                                    DISP aux_tpregist tt-documentos.nmoperac 
                                                      tt-documentos.vldparam 
                                                      tt-documentos.tpdocmto
                                                      tt-documentos.vlrfluxo
                                                      WITH FRAME f_opcao_c.
                    
                                    APPLY "GO".
                                   
                                END.
                                 
                            UPDATE b_documentos WITH FRAME f_documentos.
                            HIDE FRAME f_opcao_c.
                            NEXT lab.
                            
                        END.
                    ELSE
                        APPLY LASTKEY.
                END.

                FIND tt-documentos WHERE tt-documentos.idseqite = aux_tpregist NO-LOCK NO-ERROR.

                IF  NOT AVAIL tt-documentos THEN
                    DO:
                        MESSAGE "Registro inexistente.". 
                        HIDE FRAME f_opcao_c.
                        NEXT lab.
                    END.
                    
                DISP aux_tpregist 
                     tt-documentos.nmoperac 
                     tt-documentos.vldparam
                     tt-documentos.tpdocmto
                     tt-documentos.vlrfluxo
                     WITH FRAME f_opcao_c.
                HIDE FRAME f_opcao_c.
                NEXT lab.
        END.
    ELSE
    IF  glb_cddopcao = "A"   THEN
        DO: 
            ASSIGN aux_tpregist = 0.
           
            UPDATE aux_tpregist WITH FRAME f_opcao_c
                EDITING:
                    READKEY.
           
                    IF  LASTKEY = KEYCODE("F7") THEN              
                        DO:
                            OPEN QUERY q_documentos FOR EACH tt-documentos NO-LOCK
                                                          BY tt-documentos.idseqite.
                                                            
                            ON RETURN OF b_documentos 
                                DO:    
                          
                                  /* Armazena informação da opção escolhida */
                                  HIDE FRAME f_documentos.

                                  ASSIGN aux_tpregist = tt-documentos.idseqite.

                                  DISP aux_tpregist WITH FRAME f_opcao_c.

                                  APPLY "GO".

                                END.

                            UPDATE b_documentos WITH FRAME f_documentos.
                           
                        END.
                    ELSE
                        APPLY LASTKEY.
                END.

                FIND tt-documentos WHERE tt-documentos.idseqite = aux_tpregist NO-LOCK NO-ERROR.

                IF NOT AVAIL tt-documentos THEN
                    DO:
                        MESSAGE "Registro Inexistente.". 
                        HIDE FRAME f_opcao_c.
                        NEXT lab.
                    END.

                DISP aux_tpregist tt-documentos.nmoperac tt-documentos.tpdocmto tt-documentos.vlrfluxo WITH FRAME f_opcao_c.

                IF  aux_tpregist = 0  THEN 
                    MESSAGE "Atencao! Esse valor sera aplicado a todos os registros.".

                /* Monta parte da Mensagem de log. */
                ASSIGN aux_msgdolog = "Alterou o valor " + STRING(tt-documentos.idseqite) + " - "
                                                         + TRIM(STRING(tt-documentos.nmoperac)) +  ", " 
                                                         + TRIM(STRING(tt-documentos.vldparam, "zzz,zzz,zz9.99")) + ", "
                                                         + STRING(tt-documentos.tpdocmto, "zzz9") + ", "
                                                         + TRIM(STRING(tt-documentos.vlrfluxo, "zzz,zzz,zz9.99"))
                                                         + " PARA ".
                       aux_tpdocmto = tt-documentos.tpdocmto.

                DO WHILE TRUE:
                
                    UPDATE tt-documentos.nmoperac
                           tt-documentos.vldparam 
                           tt-documentos.tpdocmto
                           tt-documentos.vlrfluxo WHEN aux_tpregist <> 0 
                           WITH FRAME f_opcao_c.
                    
                    FOR EACH b-tt-documentos NO-LOCK:
                        IF  tt-documentos.tpdocmto =  b-tt-documentos.tpdocmto  AND
                            aux_tpregist           <> b-tt-documentos.idseqite  AND
                            tt-documentos.tpdocmto <> 0                         THEN
                        DO:
                            ASSIGN aux_dscritic = "Tipo documento cadastrado para o codigo: " + TRIM(STRING(b-tt-documentos.idseqite)) + ".".
                            LEAVE.
                        END.
                    END.
                    IF  aux_dscritic <> ""  THEN
                    DO: 
                        MESSAGE aux_dscritic.
                        ASSIGN aux_dscritic = "".
                        NEXT.
                    END.

                    LEAVE.
                END.

                IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
                DO:
                    HIDE FRAME f_opcao_c.
                    NEXT lab.
                END.

                ASSIGN aux_confirma = "N".
                RUN fontes/confirma.p (INPUT  "",
                                       OUTPUT aux_confirma).
            
                IF  aux_confirma = "S" THEN 
                    DO:
                        ASSIGN aux_msgdolog = aux_msgdolog + TRIM(CAPS(STRING(tt-documentos.nmoperac))) +  ", " 
                                                         + TRIM(STRING(tt-documentos.vldparam, "zzz,zzz,zz9.99")) + ", "
                                                         + STRING(tt-documentos.tpdocmto, "zzz9") + ", "
                                                         + TRIM(STRING(tt-documentos.vlrfluxo, "zzz,zzz,zz9.99"))
                                                         + " atraves da coop. " + UPPER(glb_nmrescop)
                                                         + ".".

                        FOR EACH crapcop NO-LOCK:                            

                            IF  aux_tpregist <> 0 THEN 
                                DO:   
                                    FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND         
                                                       craptab.nmsistem = "CRED"            AND         
                                                       craptab.tptabela = "GENERI"          AND         
                                                       craptab.cdempres = 00                AND         
                                                       craptab.cdacesso = "DIGITALIZA"      AND
                                                       craptab.tpregist = tt-documentos.idseqite
                                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                      
                                    IF NOT AVAILABLE craptab THEN
                                        IF LOCKED craptab THEN
                                            DO:    
                                                  RUN sistema/generico/procedures/b1wgen9999.p
        			                              PERSISTENT SET h-b1wgen9999.
                           
                                            	  RUN acha-lock IN h-b1wgen9999 (INPUT RECID(craptab),
                                            									 INPUT "banco",
                                            									 INPUT "craptab",
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
                                            
                                            		glb_cdcritic = 0.
                                            		NEXT.
                                            END.
                                    ELSE 
                                        DO:
                                            glb_cdcritic = 55.
                                            NEXT.                       
                                        END.
                           
                                    ASSIGN ENTRY(1,craptab.dstextab,";") = TRIM(CAPS(STRING(tt-documentos.nmoperac)))
                                           ENTRY(2,craptab.dstextab,";") = TRIM(STRING(tt-documentos.vldparam,"zzz,zzz,zz9.99"))
                                           ENTRY(3,craptab.dstextab,";") = TRIM(STRING(tt-documentos.tpdocmto,"zzz9"))
                                           ENTRY(4,craptab.dstextab,";") = TRIM(STRING(tt-documentos.vlrfluxo,"zzz,zzz,zz9.99")).
                                END.
                            ELSE
                                DO:
                                    FOR EACH craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND         
                                                           craptab.nmsistem = "CRED"            AND         
                                                           craptab.tptabela = "GENERI"          AND         
                                                           craptab.cdempres = 00                AND         
                                                           craptab.cdacesso = "DIGITALIZA"  
                                                           EXCLUSIVE-LOCK:
                           
                                        ASSIGN ENTRY(1,craptab.dstextab,";") = TRIM(CAPS(STRING(tt-documentos.nmoperac)))
                                               ENTRY(2,craptab.dstextab,";") = TRIM(STRING(tt-documentos.vldparam,"zzz,zzz,zz9.99"))
                                               ENTRY(3,craptab.dstextab,";") = TRIM(STRING(tt-documentos.tpdocmto,"zzz9"))
                                               ENTRY(4,craptab.dstextab,";") = TRIM(STRING(tt-documentos.vlrfluxo,"zzz,zzz,zz9.99")). 
                                    END.
                                END.
                           
                            UNIX SILENT VALUE 
                                       ("echo "      +   STRING(glb_dtmvtolt,"99/99/9999")     +
                                        " - "        +   STRING(TIME,"HH:MM:SS")               +
                                        " Operador: "  + glb_cdoperad + " --- "                +
                                                       aux_msgdolog                            +
                                        " >> /usr/coop/" + TRIM(crapcop.dsdircop)              +
                                        "/log/tab093.log").
                            
                        END. /*FOR EACH COOPER*/

                        HIDE FRAME f_opcao_c.
                        LEAVE lab.
                    END.
                    ELSE 
                        DO:
                            HIDE FRAME f_opcao_c NO-PAUSE.
                            NEXT lab.
                        END. 
        
        END.
    ELSE
    /* Opcao I */
    IF  glb_cddopcao = "I"   THEN
        DO: 
            ASSIGN aux_nmoperac = ""
                   aux_tpdocmto = 0
                   tel_vldparam = 0
                   tel_vlrfluxo = 0.
             
            FIND LAST tt-documentos NO-LOCK NO-ERROR.
             
            IF  AVAIL tt-documentos THEN
                ASSIGN aux_tpregist = tt-documentos.idseqite + 1
                       aux_confirma = "N".
            ELSE
                ASSIGN aux_tpregist = 1
                       aux_confirma = "N".
            /* Como a equipe do DigiDOC passara a realizar os cadastros,
               nao sera permitido alterar o idseqite para nao baguncar
               o cadastro ja existente - Fabricio (322804)
            UPDATE aux_tpregist WITH FRAME f_opcao_i.

            IF aux_tpregist = 0 THEN
                DO:
                    ASSIGN aux_nmoperac = "TODOS".
                    MESSAGE "Atencao! Esse valor sera aplicado a todos os registros.".
                    DISP aux_nmoperac WITH FRAME f_opcao_i.
                    UPDATE tel_vldparam tel_vlrfluxo WITH FRAME f_opcao_i.
                    
                END.
            ELSE */
            DISP aux_tpregist WITH FRAME f_opcao_i.

            UPDATE aux_nmoperac tel_vldparam aux_tpdocmto tel_vlrfluxo WITH FRAME f_opcao_i.
             
            FOR EACH tt-documentos NO-LOCK:

                IF  aux_tpregist = tt-documentos.idseqite THEN
                    DO:
                        MESSAGE "Registro ja existente na Tabela.".
                        HIDE FRAME f_opcao_i.
                        NEXT lab.
                    END.
                ELSE 
                IF  aux_tpdocmto = tt-documentos.tpdocmto AND 
                    aux_tpdocmto <> 0                     THEN
                    DO:
                        MESSAGE "Tipo documento cadastrado para o codigo: " + TRIM(STRING(tt-documentos.idseqite)) + ".".
                        HIDE FRAME f_opcao_i.
                        NEXT lab.
                    END.

            END.

            RUN fontes/confirma.p (INPUT  "",
                                   OUTPUT aux_confirma).
             
            IF  aux_confirma = "S" THEN 
                DO:
                    FIND LAST craptab WHERE craptab.cdcooper = glb_cdcooper  AND         
                                            craptab.nmsistem = "CRED"        AND         
                                            craptab.tptabela = "GENERI"      AND         
                                            craptab.cdempres = 00            AND         
                                            craptab.cdacesso = "DIGITALIZA"                                    
                                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
            
                    IF NOT AVAILABLE craptab THEN
                        IF LOCKED craptab THEN
                            DO: 
                              RUN sistema/generico/procedures/b1wgen9999.p
                              PERSISTENT SET h-b1wgen9999.

                              RUN acha-lock IN h-b1wgen9999 (INPUT RECID(craptab),
                                                             INPUT "banco",
                                                             INPUT "craptab",
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
                        
                                glb_cdcritic = 0.
                                NEXT.
                            END.
                    ELSE 
                        DO:
                            glb_cdcritic = 55.
                            NEXT.                       
                        END.

                    FOR EACH crapcop NO-LOCK:
                        CREATE craptab.
                        ASSIGN craptab.cdcooper = crapcop.cdcooper
                               craptab.nmsistem = "CRED"
                               craptab.tptabela = "GENERI"
                               craptab.cdempres = 00 
                               craptab.cdacesso = "DIGITALIZA"
                               craptab.tpregist = aux_tpregist
                               craptab.dstextab = CAPS(aux_nmoperac) + ";" +
                                                  TRIM(STRING(tel_vldparam,"zzz,zzz,zz9.99")) + ";" +
                                                  TRIM(STRING(aux_tpdocmto,"zzz9")) + ";" +
                                                  TRIM(STRING(tel_vlrfluxo,"zzz,zzz,zz9.99")).
                        VALIDATE craptab.
                    
                        IF aux_tpregist = 0 THEN 
                            DO:
                                FOR EACH craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND         
                                                       craptab.nmsistem = "CRED"        AND         
                                                       craptab.tptabela = "GENERI"      AND         
                                                       craptab.cdempres = 00            AND         
                                                       craptab.cdacesso = "DIGITALIZA"  
                                                       EXCLUSIVE-LOCK:
                          
                                    ASSIGN ENTRY(2,craptab.dstextab,";") = TRIM(STRING(tel_vldparam,"zzz,zzz,zz9.99")). 
                                END.
                            END.                    

                        /* Monta e grava a Mensagem de log. */
                        ASSIGN aux_msgdolog = "Criou o registro " + STRING(aux_tpregist) + " - "
                                          + CAPS(STRING(aux_nmoperac)) + " com valor de " + TRIM(STRING(tel_vldparam, "zzz,zzz,zz9.99")) + 
                                          ", Tipo Docmto: " + TRIM(STRING(aux_tpdocmto,"zzz9")) + " atraves da coop. " +
                                          UPPER(glb_nmrescop) + ".".
                    
                        UNIX SILENT VALUE 
                                   ("echo "      +   STRING(glb_dtmvtolt,"99/99/9999")     +
                                    " - "        +   STRING(TIME,"HH:MM:SS")               +
                                    " Operador: "  + glb_cdoperad + " --- "                +
                                                   aux_msgdolog                            +
                                    " >> /usr/coop/" + TRIM(crapcop.dsdircop)              +
                                    "/log/tab093.log").

                    END.

                    LEAVE lab.
                END.
             ELSE 
                DO:
                    HIDE FRAME f_opcao_i.
                    NEXT lab.
                END.                     
        END.
    ELSE
    /* opcao M */
    IF  glb_cddopcao = "M"  THEN
        DO:
            FIND craptab WHERE  craptab.cdcooper = glb_cdcooper    AND
                                craptab.nmsistem = "CRED"          AND
                                craptab.tptabela = "GENERI"        AND
                                craptab.cdempres = 00              AND
                                craptab.cdacesso = "DIGITEMAIL"    AND
                                craptab.tpregist = 0  NO-LOCK NO-ERROR.

            IF  AVAIL craptab  THEN
                ASSIGN flg_envemail    = LOGICAL(SUBSTRING(craptab.dstextab,1,1), "S/N")
                       tel_dstextab[1] = ENTRY(1,craptab.dstextab,";")
                       tel_dstextab[2] = ENTRY(2,craptab.dstextab,";")
                       tel_dstextab[3] = ENTRY(3,craptab.dstextab,";").

             /* separa os emails da tabela para exibição por linha */
            DO aux_contador = 1 TO NUM-ENTRIES(craptab.dstextab,",").
               tel_dsdemail[aux_contador] = STRING(ENTRY(aux_contador,tel_dstextab[3],",")).
            END.

            ASSIGN aux_codsmart = 0
                   aux_dtcredit = ?
                   aux_dtcadast = ?
                   aux_dttermos = ?.

            /* Quando alterar esta tab, tambem alterar a b1wgen0137 */
            FIND craptab WHERE craptab.cdcooper = glb_cdcooper    AND
                               craptab.nmsistem = "CRED"          AND
                               craptab.tptabela = "GENERI"        AND
                               craptab.cdempres = 00              AND
                               craptab.cdacesso = "DIGITACOOP"    AND
                               craptab.tpregist = 0  NO-LOCK NO-ERROR.

            IF  AVAIL craptab  THEN
                ASSIGN aux_codsmart = INTE(ENTRY(1,craptab.dstextab,";"))
                       aux_dtcadast = DATE(ENTRY(2,craptab.dstextab,";"))
                       aux_dtcredit = DATE(ENTRY(3,craptab.dstextab,";"))
                       aux_dttermos = DATE(ENTRY(4,craptab.dstextab,";")).

            /*LIBERADO*/           
            FIND craptab WHERE  craptab.cdcooper = glb_cdcooper    AND
                                craptab.nmsistem = "CRED"          AND
                                craptab.tptabela = "GENERI"        AND
                                craptab.cdempres = 00              AND
                                craptab.cdacesso = "DIGITALIBE"    AND
                                craptab.tpregist = 1  NO-LOCK NO-ERROR.

            IF  AVAIL craptab  THEN
                ASSIGN flg_digitlib = LOGICAL(ENTRY(1,craptab.dstextab,";"),"S/N").
                       
            /*LIBERADO*/ 
            DISPLAY tel_dsdemail 
                    aux_codsmart 
                    aux_dtcadast
                    aux_dtcredit
                    aux_dttermos
                    flg_digitlib
                    WITH FRAME f_opcao_m.
           
            UPDATE aux_codsmart 
                   aux_dtcadast
                   aux_dtcredit
                   aux_dttermos
                   flg_digitlib
                   flg_envemail 
                   WITH FRAME f_opcao_m.

            
            /* Se escolhido não enviar emails, grava na craptab e finaliza */
            IF flg_envemail = NO THEN 
                DO: 
                    ASSIGN aux_confirma = "N".
                    RUN fontes/confirma.p (INPUT  "",
                                           OUTPUT aux_confirma).
                   
                    IF aux_confirma = "S" THEN 
                        DO:
                            
                            FIND craptab WHERE  craptab.cdcooper = glb_cdcooper    AND
                                                craptab.nmsistem = "CRED"          AND
                                                craptab.tptabela = "GENERI"        AND
                                                craptab.cdempres = 00              AND
                                                craptab.cdacesso = "DIGITALIBE"    AND
                                                craptab.tpregist = 1  EXCLUSIVE-LOCK NO-ERROR.
                            
                            IF flg_digitlib THEN
                                ASSIGN craptab.dstextab = "S;".
                            ELSE
                                ASSIGN craptab.dstextab = "N;".
                                

                            IF  ENTRY(1,craptab.dstextab,";") <> STRING(aux_codsmart) THEN
                            DO:
                                /* Mensagem do LOG */
                                ASSIGN aux_msgdolog = "Alterou o codigo Smartshare de " + ENTRY(1,craptab.dstextab,";") 
                                                  + " para " + STRING(aux_codsmart).
                                FIND craptab WHERE  craptab.cdcooper = glb_cdcooper    AND
                                                    craptab.nmsistem = "CRED"          AND
                                                    craptab.tptabela = "GENERI"        AND
                                                    craptab.cdempres = 00              AND
                                                    craptab.cdacesso = "DIGITACOOP"    AND
                                                    craptab.tpregist = 0  EXCLUSIVE-LOCK NO-ERROR.
    
                                IF  AVAIL craptab  THEN 
                                DO:
                                    ASSIGN ENTRY(1,craptab.dstextab,";") = STRING(aux_codsmart). 

                                    /* Grava o LOG */
                                    UNIX SILENT VALUE 
                                      ("echo "          + STRING(glb_dtmvtolt,"99/99/9999")  +
                                       " - "            + STRING(TIME,"HH:MM:SS")            +
                                       " Operador: "    + glb_cdoperad + " --- "             +
                                        aux_msgdolog                                         +
                                       " >> /usr/coop/" + TRIM(crapcop.dsdircop)             +
                                       "/log/tab093.log").

                                END.
                            END.

                            /* Alteração data de cadastro */
                            IF STRING(DATE(ENTRY(2,craptab.dstextab,";"))) <> STRING(aux_dtcadast) THEN
                                DO:
                                    /* Mensagem do LOG */
                                    ASSIGN aux_msgdolog = "Alterou a data validacao de " + ENTRY(2,craptab.dstextab,";")
                                                      + " para " + STRING(aux_dtcadast,"99/99/9999").
    
                                    FIND craptab WHERE  craptab.cdcooper = glb_cdcooper    AND
                                                        craptab.nmsistem = "CRED"          AND
                                                        craptab.tptabela = "GENERI"        AND
                                                        craptab.cdempres = 00              AND
                                                        craptab.cdacesso = "DIGITACOOP"    AND
                                                        craptab.tpregist = 0  EXCLUSIVE-LOCK NO-ERROR.
        
                                    IF  AVAIL craptab  THEN 
                                    DO:
                                        ASSIGN ENTRY(2,craptab.dstextab,";") = STRING(aux_dtcadast,"99/99/9999"). 
    
                                        /* Grava o LOG */
                                        UNIX SILENT VALUE 
                                          ("echo "          + STRING(glb_dtmvtolt,"99/99/9999")  +
                                           " - "            + STRING(TIME,"HH:MM:SS")            +
                                           " Operador: "    + glb_cdoperad + " --- "             +
                                            aux_msgdolog                                         +
                                           " >> /usr/coop/" + TRIM(crapcop.dsdircop)             +
                                           "/log/tab093.log").
    
                                    END.
                                END.

                            /* Alteração data de credito */
                            IF  STRING(DATE(ENTRY(3,craptab.dstextab,";"))) <> STRING(aux_dtcredit) THEN
                                DO:
                                    /* Mensagem do LOG */
                                    ASSIGN aux_msgdolog = "Alterou a data validacao de " + ENTRY(3,craptab.dstextab,";")
                                                      + " para " + STRING(aux_dtcredit,"99/99/9999").
    
                                    FIND craptab WHERE  craptab.cdcooper = glb_cdcooper    AND
                                                        craptab.nmsistem = "CRED"          AND
                                                        craptab.tptabela = "GENERI"        AND
                                                        craptab.cdempres = 00              AND
                                                        craptab.cdacesso = "DIGITACOOP"    AND
                                                        craptab.tpregist = 0  EXCLUSIVE-LOCK NO-ERROR.
        
                                    IF  AVAIL craptab  THEN 
                                    DO:
                                        ASSIGN ENTRY(3,craptab.dstextab,";") = STRING(aux_dtcredit,"99/99/9999"). 
    
                                        /* Grava o LOG */
                                        UNIX SILENT VALUE 
                                          ("echo "          + STRING(glb_dtmvtolt,"99/99/9999")  +
                                           " - "            + STRING(TIME,"HH:MM:SS")            +
                                           " Operador: "    + glb_cdoperad + " --- "             +
                                            aux_msgdolog                                         +
                                           " >> /usr/coop/" + TRIM(crapcop.dsdircop)             +
                                           "/log/tab093.log").
    
                                    END.
                                END.

                            /* Alteração data de termos */
                            IF  STRING(DATE(ENTRY(4,craptab.dstextab,";"))) <> STRING(aux_dttermos) THEN
                                DO:
                                    /* Mensagem do LOG */
                                    ASSIGN aux_msgdolog = "Alterou a data validacao de " + ENTRY(4,craptab.dstextab,";")
                                                      + " para " + STRING(aux_dttermos,"99/99/9999").
    
                                    FIND craptab WHERE  craptab.cdcooper = glb_cdcooper    AND
                                                        craptab.nmsistem = "CRED"          AND
                                                        craptab.tptabela = "GENERI"        AND
                                                        craptab.cdempres = 00              AND
                                                        craptab.cdacesso = "DIGITACOOP"    AND
                                                        craptab.tpregist = 0  EXCLUSIVE-LOCK NO-ERROR.
        
                                    IF  AVAIL craptab  THEN 
                                    DO:
                                        ASSIGN ENTRY(4,craptab.dstextab,";") = STRING(aux_dttermos,"99/99/9999"). 
    
                                        /* Grava o LOG */
                                        UNIX SILENT VALUE 
                                          ("echo "          + STRING(glb_dtmvtolt,"99/99/9999")  +
                                           " - "            + STRING(TIME,"HH:MM:SS")            +
                                           " Operador: "    + glb_cdoperad + " --- "             +
                                            aux_msgdolog                                         +
                                           " >> /usr/coop/" + TRIM(crapcop.dsdircop)             +
                                           "/log/tab093.log").
    
                                    END.
                                END.

                            /* Executa somente se os valores forem alterados */
                            IF LOGICAL(tel_dstextab[1], "S/N") <> flg_envemail THEN
                                DO:

                                    /* Mensagem do LOG */
                                    ASSIGN aux_msgdolog = "Alterou o parametro de envio de email de " + STRING(tel_dstextab[1])
                                                      + " para " + STRING(flg_envemail, "S/N").

                                    FIND craptab WHERE  craptab.cdcooper = glb_cdcooper    AND
                                                        craptab.nmsistem = "CRED"          AND
                                                        craptab.tptabela = "GENERI"        AND
                                                        craptab.cdempres = 00              AND
                                                        craptab.cdacesso = "DIGITEMAIL"    AND
                                                        craptab.tpregist = 0  EXCLUSIVE-LOCK NO-ERROR.
                               
                                    IF  AVAIL craptab  THEN
                                        ASSIGN craptab.dstextab = STRING(STRING(flg_envemail, "S/N") + 
                                                                  ";" + tel_dstextab[2] + ";" + tel_dstextab[3]). 

                                    /* Grava o LOG */
                                    UNIX SILENT VALUE 
                                      ("echo "          + STRING(glb_dtmvtolt,"99/99/9999")  +
                                       " - "            + STRING(TIME,"HH:MM:SS")            +
                                       " Operador: "    + glb_cdoperad + " --- "             +
                                        aux_msgdolog                                         +
                                       " >> /usr/coop/" + TRIM(crapcop.dsdircop)             +
                                       "/log/tab093.log").

                                END.

                        END.
                LEAVE.
                END.
               
            UPDATE tel_dsdemail WITH FRAME f_opcao_m.
           
            ASSIGN aux_confirma = "N".
            RUN fontes/confirma.p (INPUT  "",
                                   OUTPUT aux_confirma).
           
            IF aux_confirma = "S" THEN 
                DO:
                    
                    FIND craptab WHERE  craptab.cdcooper = glb_cdcooper    AND
                                        craptab.nmsistem = "CRED"          AND
                                        craptab.tptabela = "GENERI"        AND
                                        craptab.cdempres = 00              AND
                                        craptab.cdacesso = "DIGITALIBE"    AND
                                        craptab.tpregist = 1  EXCLUSIVE-LOCK NO-ERROR.
                    
                    IF flg_digitlib THEN
                        ASSIGN craptab.dstextab = "S;".
                    ELSE
                        ASSIGN craptab.dstextab = "N;".
                    
                    /* Continua mensagem do LOG */
                    ASSIGN aux_logalter = tel_dstextab[3]
                           tel_dstextab[3] = ""
                           aux = 1.
                    /* Organiza e aloca os emails no array */
                    DO aux_contador = 1 TO 6:
                                                 
                        IF tel_dsdemail[aux_contador] <> "" AND aux_contador = 1 THEN 
                            ASSIGN tel_dstextab[3] = STRING(tel_dsdemail[aux_contador]).
                        ELSE IF tel_dsdemail[aux_contador] <> "" THEN
                            DO:
                                IF tel_dsdemail[aux] = "" AND aux = 1 THEN 
                                    ASSIGN tel_dstextab[3] = STRING(tel_dsdemail[aux_contador])
                                           aux = aux + 1.
                                ELSE
                                    ASSIGN tel_dstextab[3] = tel_dstextab[3] + "," + STRING(tel_dsdemail[aux_contador]).
                            END.
                    END.

                    IF  ENTRY(1,craptab.dstextab,";") <> STRING(aux_codsmart) THEN
                    DO:
                        /* Mensagem do LOG */
                        ASSIGN aux_msgdolog = "Alterou o codigo Smartshare de " + ENTRY(1,craptab.dstextab,";") 
                                          + " para " + STRING(aux_codsmart).
                        FIND craptab WHERE  craptab.cdcooper = glb_cdcooper    AND
                                            craptab.nmsistem = "CRED"          AND
                                            craptab.tptabela = "GENERI"        AND
                                            craptab.cdempres = 00              AND
                                            craptab.cdacesso = "DIGITACOOP"    AND
                                            craptab.tpregist = 0  EXCLUSIVE-LOCK NO-ERROR.

                        IF  AVAIL craptab  THEN 
                        DO:
                            ASSIGN ENTRY(1,craptab.dstextab,";") = STRING(aux_codsmart). 

                            /* Grava o LOG */
                            UNIX SILENT VALUE 
                              ("echo "          + STRING(glb_dtmvtolt,"99/99/9999")  +
                               " - "            + STRING(TIME,"HH:MM:SS")            +
                               " Operador: "    + glb_cdoperad + " --- "             +
                                aux_msgdolog                                         +
                               " >> /usr/coop/" + TRIM(crapcop.dsdircop)             +
                               "/log/tab093.log").

                        END.
                    END.
                    
                    /* Verifica alteração da data de cadastro */
                    IF  STRING(DATE(ENTRY(2,craptab.dstextab,";"))) <> STRING(aux_dtcadast) THEN
                    DO:
                        /* Mensagem do LOG */
                        ASSIGN aux_msgdolog = "Alterou a data validacao de cadastro de" + ENTRY(2,craptab.dstextab,";")
                                          + " para " + STRING(aux_dtcadast,"99/99/9999").

                        FIND craptab WHERE  craptab.cdcooper = glb_cdcooper    AND
                                            craptab.nmsistem = "CRED"          AND
                                            craptab.tptabela = "GENERI"        AND
                                            craptab.cdempres = 00              AND
                                            craptab.cdacesso = "DIGITACOOP"    AND
                                            craptab.tpregist = 0  EXCLUSIVE-LOCK NO-ERROR.

                        IF  AVAIL craptab  THEN 
                        DO:
                            ASSIGN ENTRY(2,craptab.dstextab,";") = STRING(aux_dtcadast,"99/99/9999"). 

                            /* Grava o LOG */
                            UNIX SILENT VALUE 
                              ("echo "          + STRING(glb_dtmvtolt,"99/99/9999")  +
                               " - "            + STRING(TIME,"HH:MM:SS")            +
                               " Operador: "    + glb_cdoperad + " --- "             +
                                aux_msgdolog                                         +
                               " >> /usr/coop/" + TRIM(crapcop.dsdircop)             +
                               "/log/tab093.log").

                        END.
                    END.

                    /* Verifica alteração da data de credito */
                    IF  STRING(DATE(ENTRY(3,craptab.dstextab,";"))) <> STRING(aux_dtcredit) THEN
                    DO:
                        /* Mensagem do LOG */
                        ASSIGN aux_msgdolog = "Alterou a data validacao de credito de " + ENTRY(3,craptab.dstextab,";")
                                          + " para " + STRING(aux_dtcredit,"99/99/9999").

                        FIND craptab WHERE  craptab.cdcooper = glb_cdcooper    AND
                                            craptab.nmsistem = "CRED"          AND
                                            craptab.tptabela = "GENERI"        AND
                                            craptab.cdempres = 00              AND
                                            craptab.cdacesso = "DIGITACOOP"    AND
                                            craptab.tpregist = 0  EXCLUSIVE-LOCK NO-ERROR.

                        IF  AVAIL craptab  THEN 
                        DO:
                            ASSIGN ENTRY(3,craptab.dstextab,";") = STRING(aux_dtcredit,"99/99/9999"). 

                            /* Grava o LOG */
                            UNIX SILENT VALUE 
                              ("echo "          + STRING(glb_dtmvtolt,"99/99/9999")  +
                               " - "            + STRING(TIME,"HH:MM:SS")            +
                               " Operador: "    + glb_cdoperad + " --- "             +
                                aux_msgdolog                                         +
                               " >> /usr/coop/" + TRIM(crapcop.dsdircop)             +
                               "/log/tab093.log").

                        END.
                    END.

                    /* Alteração data de termos */
                    IF  STRING(DATE(ENTRY(4,craptab.dstextab,";"))) <> STRING(aux_dttermos) THEN
                        DO:
                            /* Mensagem do LOG */
                            ASSIGN aux_msgdolog = "Alterou a data validacao de termos de " + ENTRY(4,craptab.dstextab,";")
                                              + " para " + STRING(aux_dttermos,"99/99/9999").

                            FIND craptab WHERE  craptab.cdcooper = glb_cdcooper    AND
                                                craptab.nmsistem = "CRED"          AND
                                                craptab.tptabela = "GENERI"        AND
                                                craptab.cdempres = 00              AND
                                                craptab.cdacesso = "DIGITACOOP"    AND
                                                craptab.tpregist = 0  EXCLUSIVE-LOCK NO-ERROR.

                            IF  AVAIL craptab  THEN 
                            DO:
                                ASSIGN ENTRY(4,craptab.dstextab,";") = STRING(aux_dttermos,"99/99/9999"). 

                                /* Grava o LOG */
                                UNIX SILENT VALUE 
                                  ("echo "          + STRING(glb_dtmvtolt,"99/99/9999")  +
                                   " - "            + STRING(TIME,"HH:MM:SS")            +
                                   " Operador: "    + glb_cdoperad + " --- "             +
                                    aux_msgdolog                                         +
                                   " >> /usr/coop/" + TRIM(crapcop.dsdircop)             +
                                   "/log/tab093.log").

                            END.
                        END.                    
                    
                    /* Executa somente em caso de alterações */
                    IF aux_logalter <> tel_dstextab[3] OR LOGICAL(tel_dstextab[1], "S/N") <> flg_envemail THEN
                        DO:

                            /* Mensagem do log */
                            IF LOGICAL(tel_dstextab[1], "S/N") <> flg_envemail THEN
                                ASSIGN aux_msgdolog = "Alterou o parametro de envio de email de " + STRING(tel_dstextab[1])
                                                       + " para " + STRING(flg_envemail, "S/N") + ".".
                            
                            IF aux_logalter <> tel_dstextab[3] THEN
                                ASSIGN aux_msgdolog = aux_msgdolog + " Alterou os emails " + aux_logalter
                                                      + " para " + tel_dstextab[3] + ".".
                                                       
                            FIND craptab WHERE  craptab.cdcooper = glb_cdcooper    AND
                                                craptab.nmsistem = "CRED"          AND
                                                craptab.tptabela = "GENERI"        AND
                                                craptab.cdempres = 00              AND
                                                craptab.cdacesso = "DIGITEMAIL"    AND
                                                craptab.tpregist = 0  EXCLUSIVE-LOCK NO-ERROR.
                                              
                            ASSIGN craptab.dstextab = STRING(STRING(flg_envemail, "S/N") + ";" + tel_dstextab[2] + ";" + tel_dstextab[3]). 
                            
                            /* Grava o LOG */
                            UNIX SILENT VALUE 
                                      ("echo "          + STRING(glb_dtmvtolt,"99/99/9999")  +
                                       " - "            + STRING(TIME,"HH:MM:SS")            +
                                       " Operador: "    + glb_cdoperad + " --- "             +
                                        aux_msgdolog                                         +
                                       " >> /usr/coop/" + TRIM(crapcop.dsdircop)             +
                                       "/log/tab093.log").
                        END.
                END.
        END. /* Opcao M */
     /*ELSE retirado opcao "B" */

    LEAVE.

END.

/* .............................................................................. */
