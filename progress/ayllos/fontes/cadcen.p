/* .............................................................................

   Programa: Fontes/cadcen.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Diego   
   Data    : Maio/2008                     Ultima Atualizacao: 22/09/2014.

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Permitir Cadastro de Contas Centralizadoras.

   ALTERACAO : 21/08/2008 - Incluir campo Integra no Hist. de Transf. (Ze).
               
               23/01/2009 - Incluir campo Tipo Conta (Sidnei - PreciseIT) e 
                            atualizar a tabela craptab (para opcao I)
                            
               07/05/2009 - Incluido evento <ENTER> no browse b_contas
                            (Fernando).
                            
               12/05/2009 - Nao alterar campo "Tipo Conta" quando banco = 1
                            (Fernando).
                    
               16/04/2012 - Fonte substituido por cadcenp.p (Tiago). 
               
               01/06/2012 - Adaptação de Fontes - Argumentos (Lucas R.)            
               
               02/07/2012 - 'gncoper' substituido por 'crapcop' (Tiago).
               
               12/07/2012 - Eliminar a cadceni.p - eliminar contaconve (Ze).
               
               23/10/2013 - SD 100275 - Melhoria: Permitir alterar a Conta
                            na gnctacen. Incluido tratamento na inclusao, 
                            alteração e exclusao do registro craptab quando
                            Tipo de conta = 4(conta ITG) (Carlos).
                            
               18/12/2013 - Inclusao de VALIDATE gnctace e craptab (Carlos)
               
               22/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)
                            
............................................................................. */
{ includes/var_online.i }

DEF   VAR tel_cdcooper   AS INT      FORMAT "z9"                     NO-UNDO.
DEF   VAR tel_nmrescop   AS CHAR     FORMAT "x(11)"                  NO-UNDO.
DEF   VAR tel_cddbanco   AS INT      FORMAT "zz9"                    NO-UNDO.
DEF   VAR tel_nmresbcc   AS CHAR     FORMAT "x(15)"                  NO-UNDO.
DEF   VAR tel_nrdconta   AS DEC      FORMAT "zz,zzz,zzz,zzz,9"       NO-UNDO.
DEF   VAR tel_cdageban   AS INT      FORMAT "zzzz,9"                 NO-UNDO.
DEF   VAR tel_dsfinali   AS CHAR     FORMAT "x(40)"                  NO-UNDO.
DEF   VAR tel_flgintce   AS LOGICAL  FORMAT "SIM/NAO"                NO-UNDO.
DEF   VAR tel_flgintrf   AS LOGICAL  FORMAT "SIM/NAO"                NO-UNDO.
DEF   VAR tel_tpregist   AS INT      FORMAT "zz9"                    NO-UNDO.

DEF   VAR aux_cddopcao   AS CHAR                                     NO-UNDO.
DEF   VAR aux_confirma   AS CHAR     FORMAT "!"                      NO-UNDO.

DEF   VAR aux_dadosusr AS CHAR                                       NO-UNDO.
DEF   VAR par_loginusr AS CHAR                                       NO-UNDO.
DEF   VAR par_nmusuari AS CHAR                                       NO-UNDO.
DEF   VAR par_dsdevice AS CHAR                                       NO-UNDO.
DEF   VAR par_dtconnec AS CHAR                                       NO-UNDO.
DEF   VAR par_numipusr AS CHAR                                       NO-UNDO.
DEF   VAR h-b1wgen9999 AS HANDLE                                     NO-UNDO.

/* Vars p/ armazenar conta e tipo do registro a ser alterado ou incluido nas
   tabelas gnctace e craptab */
DEF VAR bkp_nrctacen LIKE gnctace.nrctacen  NO-UNDO.
DEF VAR bkp_tpregist LIKE gnctace.tpregist  NO-UNDO.

DEF VAR aux_contador AS INTE                NO-UNDO.
DEF VAR flg_findtab  AS LOGICAL             NO-UNDO.

DEF BUFFER b-gnctace FOR gnctace.
DEF BUFFER b-craptab FOR craptab.

FORM WITH NO-LABEL TITLE COLOR MESSAGE glb_tldatela          
     ROW 4 COLUMN 1 SIZE 80 BY 18 OVERLAY WITH FRAME f_moldura.
                       
FORM SKIP
     glb_cddopcao  AT  2  LABEL "Opcao"
                          HELP "Informe a opcao desejada (A,C,E,I)."
                          VALIDATE(CAN-DO("A,C,E,I", glb_cddopcao),
                                         "014 - Opcao errada")
     WITH ROW 6 COLUMN 2 OVERLAY SIDE-LABELS NO-LABEL NO-BOX FRAME f_opcao.
     
FORM SKIP
     tel_cdcooper  AT 17  LABEL "Cooperativa"
                          HELP "Informe o codigo da Cooperativa"
                          VALIDATE(CAN-FIND (crapcop WHERE
                                             crapcop.cdcooper = tel_cdcooper), 
                                   "893 - Codigo nao cadastrado")
     tel_nmrescop
     SKIP(1)
     tel_cddbanco  AT 23  LABEL "Banco"
                          HELP "Informe o codigo do Banco"
                          VALIDATE(CAN-FIND (crapban WHERE
                                             crapban.cdbccxlt = tel_cddbanco), 
                                   "893 - Codigo nao cadastrado")
     tel_nmresbcc
     SKIP(1)
     tel_cdageban  AT 21  LABEL "Agencia"
                          HELP "Informe o Codigo da Agencia" 
     SKIP(1)
     tel_nrdconta  AT 20  LABEL "Conta/dv"
                          HELP "Informe o numero da Conta Centralizadora"     
     SKIP(1)
     tel_tpregist  AT  18 LABEL "Tipo Conta"
         HELP "(0-Geral/1-Tal.Normal/2-Tal.Transf/3-Cheque Salario/4-Cta.Itg.)"
     
     SKIP(1)
     tel_dsfinali  AT 18  LABEL "Finalidade"
                          HELP "Informe a Finalidade"
     SKIP(1)
     tel_flgintce  AT  4  LABEL "Integra na Centralizacao"
                      HELP "Informe se devera Integrar Conta na Centralizacao"
     SKIP(1)
     tel_flgintrf  AT  1  LABEL "Integra no Hist. de Transf."
                      HELP "Informe se devera Integrar no hist. Transferencia"

     WITH ROW 6 COLUMN 11 OVERLAY SIDE-LABELS NO-LABEL NO-BOX FRAME f_cad_conta.

     
DEF QUERY q_contas FOR gnctace, crapcop.

DEF BROWSE b_contas  QUERY q_contas
    DISPLAY crapcop.nmrescop  COLUMN-LABEL "Cooperativa"
            gnctace.cddbanco  COLUMN-LABEL "Banco"         FORMAT "z,zz9"
            gnctace.nrctacen  COLUMN-LABEL "Conta"    FORMAT "zz,zzz,zzz,zzz,9"
            gnctace.dsfinali  COLUMN-LABEL "Finalidade"    FORMAT "x(23)"
            gnctace.flgintce  COLUMN-LABEL "Centralizacao"
            WITH 8 DOWN WIDTH 78 OVERLAY.
               
FORM SKIP(1)
     b_contas 
     HELP "Pressione <ENTER> para maiores detalhes ou <F4> para sair." 
     SKIP
     WITH NO-BOX ROW 8 COLUMN 2 OVERLAY FRAME f_contas.     

ON RETURN OF b_contas
   DO:
      APPLY "GO".
   END.

VIEW FRAME f_moldura. 
PAUSE(0).                           

ASSIGN glb_cddopcao = "C".

RUN fontes/inicia.p.
                             
DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   /* Demais cooperativas so efetuam consulta */
   IF   glb_cdcooper <> 3 THEN
        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

           DISPLAY glb_cddopcao WITH FRAME f_opcao.
            
           /* Mostra somente dados da propria Cooperativa */ 
           OPEN QUERY q_contas 
                FOR EACH gnctace WHERE gnctace.cdcooper = glb_cdcooper
                         NO-LOCK,
                    FIRST crapcop WHERE crapcop.cdcooper = gnctace.cdcooper
                          NO-LOCK.
            
           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
              UPDATE b_contas WITH FRAME f_contas.
              LEAVE.
           END.

           IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                DO:
                   HIDE FRAME f_contas NO-PAUSE.
                   LEAVE.
                END.

           IF   AVAILABLE gnctace   THEN
                DO:
                   HIDE FRAME f_contas.
                             
                   FIND crapban WHERE crapban.cdbccxlt = gnctace.cddbanco 
                                      NO-LOCK NO-ERROR.

                   ASSIGN tel_cdageban = gnctace.cdageban
                          tel_cdcooper = gnctace.cdcooper
                          tel_cddbanco = gnctace.cddbanco
                          tel_dsfinali = gnctace.dsfinali
                          tel_flgintce = gnctace.flgintce
                          tel_flgintrf = gnctace.flgintrf
                          tel_tpregist = gnctace.tpregist
                          tel_nrdconta = gnctace.nrctacen
                          tel_nmresbcc = crapban.nmresbcc.
                   
                   DISPLAY tel_cdageban tel_cdcooper tel_cddbanco
                           tel_dsfinali tel_flgintce tel_nrdconta
                           tel_flgintrf tel_nmresbcc tel_tpregist
                           WITH FRAME f_cad_conta.
                   
                   MESSAGE "Pressione <ENTER> para continuar.".
                   PAUSE NO-MESSAGE.

                   HIDE MESSAGE.
                   HIDE FRAME f_cad_conta NO-PAUSE.

                   NEXT.
                END.    
        END. /*** Fim DO WHILE TRUE ***/
   ELSE
        DO: 
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
              
               UPDATE  glb_cddopcao WITH FRAME f_opcao.
               LEAVE.
            END.
        END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "CADCEN"   THEN
                 DO:
                     HIDE FRAME f_moldura.
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
   
   
   ASSIGN tel_cdcooper = 0
          tel_nmrescop = ""
          tel_cddbanco = 0
          tel_nmresbcc = ""
          tel_cdageban = 0
          tel_nrdconta = 0
          tel_dsfinali = ""
          tel_flgintce = FALSE
          tel_flgintrf = FALSE
          tel_tpregist = 0.
          
   
   DISPLAY tel_cdcooper tel_nmrescop tel_cddbanco tel_nmresbcc tel_cdageban 
           tel_nrdconta tel_dsfinali tel_flgintce tel_flgintrf tel_tpregist
           WITH FRAME f_cad_conta.
   
   PAUSE 0.
     
   DISPLAY glb_cddopcao WITH FRAME f_opcao.

   IF   glb_cddopcao = "A"  THEN
        DO:
            UPDATE tel_cdcooper WITH FRAME f_cad_conta.
            
            FIND crapcop WHERE crapcop.cdcooper = tel_cdcooper 
                 NO-LOCK NO-ERROR.
            
            ASSIGN tel_nmrescop = crapcop.nmrescop.
            DISPLAY tel_nmrescop WITH FRAME f_cad_conta.
   
            UPDATE tel_cddbanco WITH FRAME f_cad_conta.
            
            FIND crapban WHERE crapban.cdbccxlt = tel_cddbanco 
                 NO-LOCK NO-ERROR.
            
            ASSIGN tel_nmresbcc = crapban.nmresbcc.
            DISPLAY tel_nmresbcc WITH FRAME f_cad_conta.
             
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               UPDATE tel_cdageban WITH FRAME f_cad_conta.
     
               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                    LEAVE.

               glb_nrcalcul = 
                    INT(SUBSTR(STRING(tel_cdageban,"99999"),1,4)) * 10.
      
               RUN fontes/digfun.p.
      
               IF   glb_nrcalcul <> tel_cdageban THEN
                    DO:
                        glb_cdcritic = 8.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        NEXT.
                    END.

               LEAVE.
       
            END.
            
            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                 NEXT.
                         
            UPDATE tel_nrdconta tel_tpregist  WITH FRAME f_cad_conta.

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                 NEXT.
            
            FIND gnctace WHERE gnctace.cdcooper = tel_cdcooper  AND
                               gnctace.cddbanco = tel_cddbanco  AND
                               gnctace.cdageban = tel_cdageban  AND
                               gnctace.nrctacen = tel_nrdconta  AND
                               gnctace.tpregist = tel_tpregist 
                               NO-LOCK NO-ERROR.

            IF   AVAIL gnctace  THEN
                 DO:
                     ASSIGN bkp_nrctacen = gnctace.nrctacen
                            bkp_tpregist = gnctace.tpregist.

                     ASSIGN tel_dsfinali = gnctace.dsfinali
                            tel_flgintce = gnctace.flgintce
                            tel_flgintrf = gnctace.flgintrf.

                     UPDATE tel_nrdconta
                            tel_tpregist
                            tel_dsfinali
                            tel_flgintce 
                            tel_flgintrf
                            WITH FRAME f_cad_conta.

                     RUN Confirma.
                     IF   aux_confirma = "S"  THEN
                         
                         DO TRANSACTION:
                             /* Se alterou conta ou tipo e encontrou um reg
                                com os novos dados... */
                             IF  (tel_nrdconta <> bkp_nrctacen OR 
                                  tel_tpregist <> bkp_tpregist)   AND 
                                  CAN-FIND(gnctace WHERE 
                                  gnctace.cdcooper = tel_cdcooper  AND
                                  gnctace.cddbanco = tel_cddbanco  AND
                                  gnctace.cdageban = tel_cdageban  AND
                                  gnctace.nrctacen = tel_nrdconta  AND
                                  gnctace.tpregist = tel_tpregist) THEN
                             DO:
                                 MESSAGE "Conta ja existe.".
                                 PAUSE NO-MESSAGE.
                                 NEXT.
                             END.
                             
                             RUN atualiza_gnctace (INPUT tel_cdcooper,
                                                   INPUT tel_cddbanco,
                                                   INPUT tel_cdageban,
                                                   INPUT bkp_nrctacen,
                                                   INPUT bkp_tpregist,
                                                   INPUT tel_dsfinali,
                                                   INPUT tel_flgintce,
                                                   INPUT tel_flgintrf,
                                                   INPUT tel_nrdconta,
                                                   INPUT tel_tpregist).

                             /* Alterar o nrdconta(cdacesso) na craptab ou
                             criar a craptab */
                             IF  (tel_nrdconta <> bkp_nrctacen  OR
                                  tel_tpregist <> bkp_tpregist) AND
                                 tel_tpregist = 4  THEN
                             DO:
                                 DO aux_contador = 1 TO 10:
                                 
                                     /* Busca registro ATUAL craptab a ser
                                        alterado */ 
                                     FIND b-craptab WHERE 
                                          b-craptab.cdcooper = tel_cdcooper         AND
                                          b-craptab.nmsistem = "CRED"               AND
                                          b-craptab.tptabela = "CONTAB"             AND
                                          b-craptab.cdempres = 11                   AND
                                          b-craptab.cdacesso = STRING(bkp_nrctacen) AND
                                          b-craptab.tpregist = 1
                                          /* tpr 1 craptab corresponde ao tpr 4 gnctace*/
                                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                                     IF   NOT AVAIL b-craptab   THEN
                                          IF   LOCKED b-craptab THEN
                                               DO:
                                                    RUN sistema/generico/procedures/b1wgen9999.p
                                                    PERSISTENT SET h-b1wgen9999.
                                                    
                                                    RUN acha-lock IN h-b1wgen9999 (INPUT RECID(b-craptab),
                                                                         INPUT "banco",
                                                                         INPUT "b-craptab",
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

                                     glb_cdcritic = 0.
                                     LEAVE.
                                 END.
                               
                                 IF  glb_cdcritic <> 0  THEN
                                     DO:
                                        RUN mostra_erro.
                                        UNDO. /* Desfaz TRANSACAO */ 
                                     END.

                                 /* Verifica se ja existe craptab com a NOVA 
                                    conta */ 
                                 flg_findtab = CAN-FIND(craptab WHERE 
                                     craptab.cdcooper = tel_cdcooper         AND
                                     craptab.nmsistem = "CRED"               AND
                                     craptab.tptabela = "CONTAB"             AND
                                     craptab.cdempres = 11                   AND
                                     craptab.cdacesso = STRING(tel_nrdconta) AND
                                     craptab.tpregist = 1).

                                 IF  NOT flg_findtab  THEN
                                     DO: 
                                         IF  AVAIL b-craptab THEN
                                             /* Atualiza nova conta */
                                             ASSIGN b-craptab.cdacesso = 
                                                          STRING(tel_nrdconta).
                                         ELSE
                                             DO:
                                                 CREATE craptab.
                                                 ASSIGN 
                                                 craptab.cdcooper = tel_cdcooper
                                                 craptab.nmsistem = "CRED"
                                                 craptab.tptabela = "CONTAB"
                                                 craptab.cdempres = 11
                                                 craptab.cdacesso = 
                                                         STRING(tel_nrdconta)
                                                 craptab.tpregist = 1
                                                 craptab.dstextab = "1179".
                                                 VALIDATE craptab.
                                             END.
                                     END.
                             END.

                         END. /* TRANSACTION */
                 END. /* avail gnctace */
            ELSE
                 DO:
                     glb_cdcritic = 564.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     glb_cdcritic = 0.
                     NEXT.
                 END.
                 
        END.
   ELSE
   IF   glb_cddopcao = "C"  THEN
        DO WHILE TRUE ON ENDKEY UNDO, LEAVE: 

           HIDE FRAME f_cad_conta NO-PAUSE.
           
           OPEN QUERY q_contas 
                FOR EACH gnctace NO-LOCK,
                    FIRST crapcop WHERE crapcop.cdcooper = gnctace.cdcooper
                          NO-LOCK.
            
           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
              UPDATE b_contas WITH FRAME f_contas.
              LEAVE.
           END.

           IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                DO:
                   HIDE FRAME f_contas NO-PAUSE.
                   LEAVE.
                END.

           IF   AVAILABLE gnctace   THEN
                DO:
                   HIDE FRAME f_contas.

                   FIND crapban WHERE crapban.cdbccxlt = gnctace.cddbanco
                                      NO-LOCK NO-ERROR.
                   
                   ASSIGN tel_cdageban = gnctace.cdageban
                          tel_cdcooper = gnctace.cdcooper
                          tel_cddbanco = gnctace.cddbanco
                          tel_dsfinali = gnctace.dsfinali
                          tel_flgintce = gnctace.flgintce
                          tel_flgintrf = gnctace.flgintrf
                          tel_tpregist = gnctace.tpregist
                          tel_nrdconta = gnctace.nrctacen
                          tel_nmresbcc = crapban.nmresbcc.

                   DISPLAY tel_cdageban tel_cdcooper tel_cddbanco
                           tel_dsfinali tel_flgintce tel_nrdconta
                           tel_flgintrf tel_nmresbcc tel_tpregist
                           WITH FRAME f_cad_conta.
                
                   MESSAGE "Pressione <ENTER> para continuar.".
                   PAUSE NO-MESSAGE.
                   
                   HIDE MESSAGE.
                   HIDE FRAME f_cad_conta NO-PAUSE.
                   
                   NEXT.
                END.           
           
        END. /*** Fim do DO WHILE TRUE ***/
   ELSE
   IF   glb_cddopcao = "E"  THEN
        DO:
            UPDATE tel_cdcooper WITH FRAME f_cad_conta.
            
            FIND crapcop WHERE crapcop.cdcooper = tel_cdcooper 
                 NO-LOCK NO-ERROR.
            
            ASSIGN tel_nmrescop = crapcop.nmrescop.
            DISPLAY tel_nmrescop WITH FRAME f_cad_conta.
   
            UPDATE tel_cddbanco WITH FRAME f_cad_conta.
            
            FIND crapban WHERE crapban.cdbccxlt = tel_cddbanco 
                 NO-LOCK NO-ERROR.
            
            ASSIGN tel_nmresbcc = crapban.nmresbcc.
            DISPLAY tel_nmresbcc WITH FRAME f_cad_conta.
                 
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               UPDATE tel_cdageban WITH FRAME f_cad_conta.
     
               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                    LEAVE.

               glb_nrcalcul = 
                    INT(SUBSTR(STRING(tel_cdageban,"99999"),1,4)) * 10.
      
               RUN fontes/digfun.p.
      
               IF   glb_nrcalcul <> tel_cdageban THEN
                    DO:
                        glb_cdcritic = 8.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        NEXT.
                    END.

               LEAVE.

            END.
            
            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                 NEXT.
            
            UPDATE tel_nrdconta tel_tpregist WITH FRAME f_cad_conta.

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                 NEXT.
            
            FIND gnctace WHERE gnctace.cdcooper = tel_cdcooper  AND
                               gnctace.cddbanco = tel_cddbanco  AND
                               gnctace.cdageban = tel_cdageban  AND
                               gnctace.nrctacen = tel_nrdconta  AND
                               gnctace.tpregist = tel_tpregist
                               NO-LOCK NO-ERROR.
                               
            IF   AVAIL gnctace  THEN
                 DO:
                     ASSIGN tel_dsfinali = gnctace.dsfinali
                            tel_flgintce = gnctace.flgintce
                            tel_flgintrf = gnctace.flgintrf.
                            
                     DISPLAY tel_dsfinali tel_flgintce 
                             tel_flgintrf WITH FRAME f_cad_conta.
                     
                     RUN Confirma.
                     IF  aux_confirma = "S"  THEN

                         DO TRANSACTION:

                             DO  aux_contador = 1 TO 10:
                                 FIND b-gnctace WHERE 
                                      b-gnctace.cdcooper = tel_cdcooper AND
                                      b-gnctace.cddbanco = tel_cddbanco AND
                                      b-gnctace.cdageban = tel_cdageban AND
                                      b-gnctace.nrctacen = tel_nrdconta AND
                                      b-gnctace.tpregist = tel_tpregist
                                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                                 IF  NOT AVAIL b-gnctace AND
                                        LOCKED b-gnctace THEN
                                 DO:
                                    RUN sistema/generico/procedures/b1wgen9999.p
                                    PERSISTENT SET h-b1wgen9999.
                                    
                                    RUN acha-lock IN h-b1wgen9999 (INPUT RECID(b-gnctace),
                                                         INPUT "banco",
                                                         INPUT "b-gnctace",
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

                                 glb_cdcritic = 0.
                                 LEAVE.
                             END.

                             IF  glb_cdcritic <> 0  THEN
                                 DO:
                                     RUN mostra_erro.
                                     NEXT.
                                 END.
                             ELSE
                                 DO:
                                     /* Se existir tab, excluir */
                                     IF  tel_tpregist = 4 AND
                                         CAN-FIND(craptab WHERE 
                                         craptab.cdcooper = tel_cdcooper         AND
                                         craptab.nmsistem = "CRED"               AND
                                         craptab.tptabela = "CONTAB"             AND
                                         craptab.cdempres = 11                   AND
                                         craptab.cdacesso = STRING(tel_nrdconta) AND
                                         craptab.tpregist = 1) THEN
                                     DO:
                                         DO  aux_contador = 1 TO 10:
                                             FIND b-craptab WHERE 
                                                  b-craptab.cdcooper = tel_cdcooper         AND
                                                  b-craptab.nmsistem = "CRED"               AND
                                                  b-craptab.tptabela = "CONTAB"             AND
                                                  b-craptab.cdempres = 11                   AND
                                                  b-craptab.cdacesso = STRING(tel_nrdconta) AND
                                                  b-craptab.tpregist = 1
                                                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        
                                             IF  NOT AVAIL b-craptab   THEN
                                                 IF  LOCKED b-craptab THEN
                                                     DO:
                                                            RUN sistema/generico/procedures/b1wgen9999.p
                                                            PERSISTENT SET h-b1wgen9999.
                                                            
                                                            RUN acha-lock IN h-b1wgen9999 (INPUT RECID(b-craptab),
                                                            					 INPUT "banco",
                                                            					 INPUT "b-craptab",
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
        
                                             glb_cdcritic = 0.
                                             LEAVE.
                                         END.

                                         IF  glb_cdcritic <> 0  THEN
                                             DO:
                                                 RUN mostra_erro.
                                                 UNDO. /* Desfaz TRANSACAO */ 
                                             END.

                                         IF  AVAIL b-craptab THEN
                                             DELETE b-craptab.
                                     END.

                                     DELETE b-gnctace.
                                     LEAVE. 
                                 END.
                         END. /* transaction */
                 END. /* avail gnctace */
            ELSE
                 DO:
                     glb_cdcritic = 564.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     glb_cdcritic = 0.
                     NEXT.
                 END.
                 
        END.
   ELSE
   IF   glb_cddopcao = "I"  THEN
        DO:
            UPDATE tel_cdcooper WITH FRAME f_cad_conta.
            
            FIND crapcop WHERE crapcop.cdcooper = tel_cdcooper 
                 NO-LOCK NO-ERROR.
            
            ASSIGN tel_nmrescop = crapcop.nmrescop.
            DISPLAY tel_nmrescop WITH FRAME f_cad_conta.
   
            UPDATE tel_cddbanco WITH FRAME f_cad_conta.
            
            FIND crapban WHERE crapban.cdbccxlt = tel_cddbanco 
                 NO-LOCK NO-ERROR.
            
            ASSIGN tel_nmresbcc = crapban.nmresbcc.
            DISPLAY tel_nmresbcc WITH FRAME f_cad_conta.
                 
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               UPDATE tel_cdageban WITH FRAME f_cad_conta.
     
               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                    LEAVE.

               glb_nrcalcul = 
                    INT(SUBSTR(STRING(tel_cdageban,"99999"),1,4)) * 10.
      
               RUN fontes/digfun.p.
      
               IF   glb_nrcalcul <> tel_cdageban THEN
                    DO:
                        glb_cdcritic = 8.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        NEXT.
                    END.

               LEAVE.
       
            END.
               
            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                 NEXT.
            
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
               UPDATE tel_nrdconta  tel_tpregist WITH FRAME f_cad_conta.

               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                    LEAVE.
            
               IF   tel_cddbanco = 1 THEN
                    DO:
                        FIND gnctace WHERE gnctace.cddbanco = tel_cddbanco  AND
                                           gnctace.nrctacen = tel_nrdconta 
                                           NO-LOCK NO-ERROR.
                               
                        IF   AVAIL gnctace  THEN
                             DO:
                                 glb_cdcritic = 330.
                                 RUN fontes/critic.p.
                                 BELL.
                                 MESSAGE glb_dscritic.
                                 glb_cdcritic = 0.
                                 NEXT.
                             END. 
                    END.
               
               LEAVE.
       
            END.            
            
            UPDATE tel_dsfinali tel_flgintce tel_flgintrf 
                   WITH FRAME f_cad_conta.

            RUN Confirma.
            IF   aux_confirma = "S"  THEN
                 DO TRANSACTION:
                     FIND gnctace WHERE gnctace.cdcooper = tel_cdcooper  AND
                                        gnctace.cddbanco = tel_cddbanco  AND
                                        gnctace.cdageban = tel_cdageban  AND
                                        gnctace.nrctacen = tel_nrdconta  AND
                                        gnctace.tpregist = tel_tpregist
                                        NO-LOCK NO-ERROR.

                     IF   NOT AVAIL gnctace  THEN
                          DO:
                              CREATE gnctace.
                              ASSIGN gnctace.cdageban = tel_cdageban
                                     gnctace.cdcooper = tel_cdcooper
                                     gnctace.cddbanco = tel_cddbanco
                                     gnctace.dsfinali = tel_dsfinali
                                     gnctace.flgintce = tel_flgintce
                                     gnctace.flgintrf = tel_flgintrf
                                     gnctace.nrctacen = tel_nrdconta
                                     gnctace.tpregist = tel_tpregist.
                              VALIDATE gnctace.

                              IF  tel_tpregist = 4 AND
                                  NOT CAN-FIND(craptab WHERE 
                                      craptab.cdcooper = tel_cdcooper         AND
                                      craptab.nmsistem = "CRED"               AND
                                      craptab.tptabela = "CONTAB"             AND
                                      craptab.cdempres = 11                   AND
                                      craptab.cdacesso = STRING(tel_nrdconta) AND
                                      craptab.tpregist = 1) THEN
                              DO:
                                  CREATE craptab.
                                  ASSIGN craptab.cdcooper = tel_cdcooper
                                         craptab.nmsistem = "CRED"
                                         craptab.tptabela = "CONTAB"
                                         craptab.cdempres = 11
                                         craptab.cdacesso = STRING(tel_nrdconta)
                                         craptab.tpregist = 1
                                         craptab.dstextab = "1179".
                                  VALIDATE craptab.
                              END.
                          END.
                     ELSE
                          DO:
                              glb_cdcritic = 330.
                              RUN fontes/critic.p.
                              BELL.
                              MESSAGE glb_dscritic.
                              glb_cdcritic = 0.
                              NEXT.
                          END.
                 END.
        END.       
        
END. /* Do While */

PROCEDURE confirma.

   /* Confirma */
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      ASSIGN aux_confirma = "N"
             glb_cdcritic = 78.
      RUN fontes/critic.p.
      glb_cdcritic = 0.
      BELL.
      MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
      LEAVE.
   END.  /*  Fim do DO WHILE TRUE  */
           
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR   aux_confirma <> "S" THEN
        DO:
            glb_cdcritic = 79.
            RUN fontes/critic.p.
            glb_cdcritic = 0.
            BELL.
            MESSAGE glb_dscritic.
            PAUSE 2 NO-MESSAGE.
        END. /* Mensagem de confirmacao */

END PROCEDURE.


PROCEDURE atualiza_gnctace.

    DEF INPUT  PARAM par_cdcooper   AS INT     NO-UNDO.
    DEF INPUT  PARAM par_cddbanco   AS INT     NO-UNDO.
    DEF INPUT  PARAM par_cdageban   AS INT     NO-UNDO.
    DEF INPUT  PARAM par_nrctacen   AS INT     NO-UNDO.
    DEF INPUT  PARAM par_tpregist   AS INT     NO-UNDO.    
    DEF INPUT  PARAM par_dsfinali   AS CHAR    NO-UNDO.
    DEF INPUT  PARAM par_flgintce   AS LOGICAL NO-UNDO.
    DEF INPUT  PARAM par_flgintrf   AS LOGICAL NO-UNDO.
    DEF INPUT  PARAM new_nrctacen   AS INT     NO-UNDO.
    DEF INPUT  PARAM new_tpregist   AS INT     NO-UNDO.    

    DO  aux_contador = 1 TO 10:

        FIND b-gnctace WHERE 
             b-gnctace.cdcooper = par_cdcooper  AND
             b-gnctace.cddbanco = par_cddbanco  AND
             b-gnctace.cdageban = par_cdageban  AND
             b-gnctace.nrctacen = par_nrctacen  AND
             b-gnctace.tpregist = par_tpregist
             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF  NOT AVAIL b-gnctace THEN
            IF  LOCKED b-gnctace THEN
            DO:
                RUN sistema/generico/procedures/b1wgen9999.p
                PERSISTENT SET h-b1wgen9999.
                
                RUN acha-lock IN h-b1wgen9999 (INPUT RECID(b-gnctace),
                                     INPUT "banco",
                                     INPUT "b-gnctace",
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

        glb_cdcritic = 0.
        LEAVE.
    END.

    IF  glb_cdcritic = 0  THEN
        ASSIGN b-gnctace.nrctacen = new_nrctacen
               b-gnctace.dsfinali = par_dsfinali
               b-gnctace.flgintce = par_flgintce
               b-gnctace.flgintrf = par_flgintrf
               b-gnctace.tpregist = new_tpregist.
    ELSE
        DO:
            RUN mostra_erro.
            NEXT.
        END.


END PROCEDURE.

PROCEDURE mostra_erro.
    RUN fontes/critic.p.
    MESSAGE glb_dscritic.
    PAUSE 3 NO-MESSAGE.
    HIDE MESSAGE.
END.

/* .......................................................................... */
