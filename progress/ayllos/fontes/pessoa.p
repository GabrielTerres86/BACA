/* .............................................................................

   Programa: Fontes/pessoa.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Fevereiro/95.                   Ultima atualizacao: 24/04/2017 

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela PESSOA.

   Alteracoes: 23/08/2000 - Tratar tipo de vinculo (Deborah).

               31/07/2002 - Incluir nova situacao da conta (Margarete).

               30/06/2004 - Incluido novos tipos de vinculo (Evandro).
               
               08/09/2004 - Tratar conta integracao (Margarete).

               07/06/2006 - Alimentado campo cdcooper da tabela crapass (David)
               
               26/07/2006 - Tratar inpessoa = 1 nao altera tipo pessoa, quando
                            inpessoa <> 1 apenas altera para tipo 2 ou 3 (David)

               26/01/2007 - Nao permitir transformar em conta administrativa,
                            contas que nao tenham o CNPJ igual ao da
                            COOPERATIVA (Evandro).
               
               22/03/2007 - Incluido comite cooperativa (Magui).
               
               12/01/2011 - Ajustada a posicao das colunas para acomodar o campo
                            nmprimtl (Kbase - Gilnei).

               16/03/2011 - Retirada critica da situacao da conta para 
                            alteracao do vinculo (Magui).
               
               26/10/2011 - Realizadas adaptações para registro de operações em
                            arquivo .log (Lucas).
                            
               29/05/2012 - Alterada a descrição do vinculo de "CO- Comite cooperativa"
                            para "CO - Conselho Outras Cooperativas" (Lucas).
                            
               24/04/2014 - Incluido as descrições do vinculo: "DI - Diretor de Cooperat" e
                            "DC - Diretor da Central" (Jaison).
                            
               06/12/2016 - Alterado campo dsdepart para cddepart.
                            PRJ341 - BANCENJUD (Odirlei-AMcom)
                            
			   27/01/2017 - Criacao do novo vinvulo (AC - Ass. Comercial de Chapeco). 
							SD 561203 - (Carlos Rafael Tanholi)

               24/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                crapass, crapttl, crapjur 
							(Adriano - P339).
                            
               02/05/2018 - Alteracao nos codigos da situacao de conta (cdsitdct).
                            PRJ366 (Lombardi).

               08/10/2018 - Adequacao de tela para novos cargos P484. Gabriel (Mouts).		   

............................................................................. */

{ sistema/generico/includes/var_oracle.i }
{ includes/var_online.i }

DEF        VAR tel_nrdconta AS INT     FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF        VAR tel_inpessoa AS INT     FORMAT "z"                    NO-UNDO.
DEF        VAR tel_dstipess AS CHAR    FORMAT "x(29)"                NO-UNDO.
DEF        VAR tel_tpvincul AS CHAR    FORMAT "x(02)"                NO-UNDO.
DEF        VAR tel_dsvincul AS CHAR    FORMAT "x(25)"                NO-UNDO.
DEF        VAR tel_dssititg AS CHAR    FORMAT "x(07)"                NO-UNDO.   
DEF        VAR tel_nmsegntl LIKE crapttl.nmextttl					 NO-UNDO.

DEF        VAR aux_anteslog AS CHAR    FORMAT "x(50)"                NO-UNDO.
DEF        VAR aux_depoilog AS CHAR    FORMAT "x(50)"                NO-UNDO.
DEF        VAR aux_stimeout AS INT                                   NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR    FORMAT "x(1)"                 NO-UNDO.
DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR aux_sigvincu AS CHAR   FORMAT "x(2)"  EXTENT 18  
           INIT ["  ","CA","CC","CF","CO","ET","FC","FO","FU","DI","DC","AC",
                 "CD","CL","CS","CM","DT","DS"]                      NO-UNDO.
DEF        VAR aux_desvincu AS CHAR   FORMAT "x(20)"  EXTENT 18
           INIT ["Cooperado","Conselho de Administ",
                 "Conselho da Central","Conselho Fiscal",
                 "Conselho Outras Cooperativas","Estagiario Terceiro",
                 "Funcion. da Central","Funcion. Outras Coop",
                 "Funcion. da Cooperat",
                 "Diretor de Cooperat","Diretor da Central",
                 "Ass. Comercial de Chapeco",
                 "Com. Cooperativo e Delegado",
                 "Com. Cooperativo Lider",
                 "Com. Cooperativo Secretario",
                 "Com. Cooperativo Membro",
                 "Delegado Titular",
                 "Delegado Suplente"]                                NO-UNDO.
DEF        VAR aux_i        AS INT                                   NO-UNDO.

DEF TEMP-TABLE w-vinculos
    FIELD sigla AS CHAR  FORMAT "x(2)"
    FIELD descr AS CHAR  FORMAT "x(20)".

DEF QUERY q-vinculos FOR w-vinculos.

DEF BROWSE b-vinculos QUERY q-vinculos
    DISPLAY w-vinculos.sigla
            w-vinculos.descr   
            WITH 8 DOWN NO-LABELS OVERLAY TITLE "Tipos de Vinculo".

DEF BUTTON btn-ok LABEL "OK".

FORM SKIP(3)
     glb_cddopcao     COLON 20 LABEL "Opcao" AUTO-RETURN
                            HELP "Informe a opcao desejada (A ou C)."
                            VALIDATE(CAN-DO("A,C",glb_cddopcao),
                                    "014 - Opcao errada.")
     SKIP(1)
     tel_nrdconta     COLON 20 LABEL "Conta/dv" AUTO-RETURN
                            HELP "Informe o numero da conta do associado "
     SKIP(1)
     crapass.nrdctitg COLON 20 LABEL "Conta/ITG"   
     tel_dssititg     NO-LABEL
     SKIP(1)
     crapass.nmprimtl COLON 20 LABEL "Titular(es)"
     SKIP
     tel_nmsegntl     COLON 20 NO-LABEL
     SKIP(1)
     tel_inpessoa     COLON 20 LABEL "Tipo de Pessoa"
                            HELP "2 - Juridica ou 3 - Cheque Administrativo."
                            VALIDATE(CAN-DO("2,3",tel_inpessoa),
                            "436 - Tipo de Pessoa errado.")

     tel_dstipess     AT 32 NO-LABEL
     SKIP(1) 
     /* Novos cargos somente poderao ser atribuidos pela Tela Pessoa Web */
     /* Regra serve para: CD, CL, CS, CM, DT e DS - P484*/
     tel_tpvincul     COLON 20 LABEL "Tipo de Vinculo"
                            HELP "Confirme o tipo de vinculo"
                            VALIDATE(CAN-DO("CA,,CF,CC,CO,FU,FC,FO,ET,DI,DC,AC",
                            tel_tpvincul),"513 - Tipo errado ou nao permitido.")
     tel_dsvincul           
     SKIP(1)
     WITH ROW 4 SIDE-LABELS NO-LABELS TITLE glb_tldatela OVERLAY
                                      WIDTH 80 FRAME f_pessoa.

FORM 
     b-vinculos
     HELP "Escolha o tipo de vinculo - Use <ENTER> para confirmar"
     SKIP
     btn-ok        
     HELP "Tecle <ENTER> para confirmar"
     WITH ROW 12 COLUMN 51 WIDTH 29 OVERLAY NO-BOX FRAME f_vinculos.

ON ENTRY OF tel_tpvincul
   DO:
       PAUSE(0).
       ENABLE b-vinculos btn-ok WITH FRAME f_vinculos.
       APPLY "NEXT-FRAME" TO SELF.
       WAIT-FOR CHOOSE OF btn-ok.
   END.
   
ON RETURN OF b-vinculos
   DO:
       APPLY "CHOOSE" TO btn-ok.
       RETURN NO-APPLY.
  END.
  
ON CHOOSE OF btn-ok
   DO:
       tel_tpvincul = w-vinculos.sigla.
       tel_dsvincul = "- " + w-vinculos.descr.
       DISPLAY tel_tpvincul tel_dsvincul FORMAT "x(32)" WITH FRAME f_pessoa.
   END.


ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0.

DO aux_i = 1 TO 18:
   CREATE w-vinculos.
   ASSIGN w-vinculos.sigla = aux_sigvincu[aux_i]
          w-vinculos.descr = aux_desvincu[aux_i].
END.

/* Nao apresentar cargos novos na Tela Pessoa nao convetida - P484*/
OPEN QUERY q-vinculos FOR EACH w-vinculos WHERE NOT CAN-DO("CD,CL,CS,CM,DT,DS",w-vinculos.sigla).

DO WHILE TRUE:

   RUN fontes/inicia.p.

   NEXT-PROMPT tel_nrdconta WITH FRAME f_pessoa.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE glb_cddopcao tel_nrdconta WITH FRAME f_pessoa

      EDITING:

         aux_stimeout = 0.

         DO WHILE TRUE:

            READKEY PAUSE 1.

            IF   LASTKEY = -1   THEN
                 DO:
                     aux_stimeout = aux_stimeout + 1.

                     IF   aux_stimeout > glb_stimeout   THEN
                          QUIT.

                     NEXT.
                 END.

            APPLY LASTKEY.

            LEAVE.

         END.  /*  Fim do DO WHILE TRUE  */

      END.  /*  Fim do EDITING  */

      glb_nrcalcul = tel_nrdconta.
      RUN fontes/digfun.p.

      IF   NOT glb_stsnrcal THEN
           DO:
               glb_cdcritic = 8.
               RUN fontes/critic.p.
               BELL.
               CLEAR FRAME f_pessoa NO-PAUSE.
               MESSAGE glb_dscritic.
               NEXT-PROMPT tel_nrdconta WITH FRAME f_pessoa.
               glb_cdcritic = 0.
               NEXT.
           END.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   glb_nmdatela <> "PESSOA"   THEN
                 DO:
                     HIDE FRAME f_pessoa.
                     glb_cdcritic = 0.
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

  
   IF   glb_cddopcao = "A" THEN
        DO:
            IF glb_cddepart <> 6 THEN /* CONTABILIDADE */
                DO:
                   MESSAGE "Apenas CONSULTA esta liberada para esta tela.".
                   NEXT.
                END.

           TRANS_1:

           DO TRANSACTION ON ENDKEY UNDO TRANS_1, LEAVE:

              DO  aux_contador = 1 TO 10:

                  FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                                     crapass.nrdconta = tel_nrdconta
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                  IF   NOT AVAILABLE crapass   THEN
                       IF   LOCKED crapass   THEN
                       DO:
                            glb_cdcritic = 72.
                            PAUSE 1 NO-MESSAGE.
                            CLEAR FRAME f_pessoa.
                            NEXT.
                       END.
                  ELSE
                       DO:
                            glb_cdcritic = 9.
                            CLEAR FRAME f_pessoa.
                            LEAVE.
                       END.
                  ELSE
                       IF   crapass.dtelimin <> ? THEN
                       DO:
                            glb_cdcritic = 410.
                            CLEAR FRAME f_pessoa.
                            LEAVE.
                       END.
                  /*** Magui, tarefa 38.488
                  ELSE
                       IF   crapass.cdsitdct <> 1    AND
                            TRIM(tel_tpvincul) <> "" THEN
                       DO:
                            glb_cdcritic = 64.
                            CLEAR FRAME f_pessoa.
                            LEAVE.
                       END.
                       ***/
                  ELSE
                       DO:
                            ASSIGN tel_inpessoa = crapass.inpessoa
                                   tel_tpvincul = crapass.tpvincul
                                   aux_contador = 0
                                   tel_dstipess = IF   crapass.inpessoa = 1 THEN
                                                       "- Pessoa Fisica"    ELSE
                                                  IF   crapass.inpessoa = 2 THEN
                                                       "- Pessoa Juridica"  ELSE
                                                  IF   crapass.inpessoa = 3 THEN
                                                       "- Cheque Administrativo"
                                                  ELSE " ".
                                                  
                            { includes/sititg.i }
                            
                            FIND w-vinculos WHERE 
                                 w-vinculos.sigla = crapass.tpvincul.
                                 tel_dsvincul = "- " + w-vinculos.descr.
                            LEAVE.
                       END.

              END.  /*  Fim do DO .. TO  */

              IF   aux_contador <> 0   THEN
              DO:
                   RUN fontes/critic.p.
                   BELL.
                   MESSAGE glb_dscritic.
                   NEXT-PROMPT tel_nrdconta WITH FRAME f_pessoa.
                   glb_cdcritic = 0.
                   NEXT.
              END.

			  IF crapass.inpessoa = 1 THEN
			     DO:
				    FOR FIRST crapttl FIELDS(nmextttl)
									  WHERE crapttl.cdcooper = crapass.cdcooper AND
									        crapttl.nrdconta = crapass.nrdconta AND
											crapttl.idseqttl = 2
											NO-LOCK:

				       ASSIGN tel_nmsegntl = crapttl.nmextttl.

					END.

				 END.

              DISPLAY    crapass.nmprimtl    tel_nmsegntl
                         tel_inpessoa        tel_dstipess  tel_tpvincul
                         tel_dsvincul        crapass.nrdctitg
                         tel_dssititg
                         WITH FRAME f_pessoa.
                
              /* Armazena valores na variável ANTES das alterações
               para gravar no LOG */
              ASSIGN aux_anteslog =  (tel_tpvincul + " " + tel_dsvincul).
              
                
            DO WHILE TRUE:

                 IF   tel_inpessoa = 1 THEN
                      DO:
                         UPDATE tel_tpvincul WITH FRAME f_pessoa.
                      END.
                 ELSE
                      DO:
                         /* Verifica se o CNPJ eh igual ao da COOPERATIVA para
                            poder transformar em conta administrativa */
                         FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper
                                            NO-LOCK NO-ERROR.
                                            
                         IF   crapcop.nrdocnpj = crapass.nrcpfcgc   THEN
                              UPDATE tel_inpessoa tel_tpvincul 
                                     WITH FRAME f_pessoa.
                         ELSE
                              UPDATE tel_tpvincul WITH FRAME f_pessoa.
                      END.   

                 /* Inicio - Alteracoes devido ao Projeto 484 - Inicio */

                 { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                 RUN STORED-PROCEDURE pc_pessoa_progress 
                      aux_handproc = PROC-HANDLE NO-ERROR(INPUT crapass.cdcooper,
                                                          INPUT crapass.nrdconta,   
                                                          INPUT tel_tpvincul,
                                                          INPUT glb_cdoperad,
                                                         OUTPUT 0, 
                                                         OUTPUT "").
				
                 /* Fechar o procedimento para buscarmos o resultado */ 
                 CLOSE STORED-PROC pc_pessoa_progress
                      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
				
                 { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
				
                 /* Busca possíveis erros */ 
                 ASSIGN  glb_cdcritic = 0
                         glb_dscritic = ""
                         glb_cdcritic = pc_pessoa_progress.pr_cdcritic WHEN pc_pessoa_progress.pr_cdcritic <> ?
                         glb_dscritic = pc_pessoa_progress.pr_dscritic WHEN pc_pessoa_progress.pr_dscritic <> ?.

                 IF glb_cdcritic <> 0   OR
                    glb_dscritic <> ""  THEN
                      DO:
                           IF glb_dscritic = "" THEN
                                DO:
                                     FIND crapcri WHERE crapcri.cdcritic = glb_cdcritic
                                                        NO-LOCK NO-ERROR.
				
                                     IF AVAIL crapcri THEN
                                          ASSIGN glb_dscritic = crapcri.dscritic.
				
                                END.

                           MESSAGE glb_dscritic.
                           RETURN "NOK".
										
                      END.
					 
                 /* Fim - Alteracoes devido ao Projeto 484 - Fim */

                 ASSIGN crapass.inpessoa = tel_inpessoa
                        crapass.tpvincul = CAPS(tel_tpvincul).

                  /* Armazena valores na variável DEPOIS das alterações
                   para gravar no LOG */
                     ASSIGN aux_depoilog = (tel_tpvincul + " " + tel_dsvincul).

                      /* Grava valores no arquivo .log */
                      UNIX SILENT VALUE("echo "                                         +
                         STRING(glb_dtmvtolt,"99/99/9999") + "  "          +
                         STRING(TIME,"HH:MM:SS") + "' --> '"        + 
                         "Operador: " + glb_cdoperad + "-" + glb_nmoperad + 
                          " - Mudou o Tipo de Vinculo da conta/dv "   +
                          STRING(tel_nrdconta,"zzzz,zzz,9") + " de " +
                         aux_anteslog + " para " + aux_depoilog + "." + 
                         " >> log/pessoa.log").


                 tel_dstipess =   IF   crapass.inpessoa = 2 THEN
                                       "- Pessoa Juridica"  ELSE
                                  IF   crapass.inpessoa = 3 THEN
                                       "- Cheque Administrativo"
                                  ELSE " ".
                 
                 DISPLAY tel_dsvincul tel_dstipess  WITH FRAME f_pessoa.

                 IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                      UNDO, LEAVE.

                 LEAVE.

              END.   /* Fim do DO WHILE */

           END. /* Fim da transacao */

           IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
           NEXT.

        END. /* FIM do DO */

   ELSE

   IF   glb_cddopcao = "C" THEN
        DO:

            FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                               crapass.nrdconta = tel_nrdconta NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE crapass   THEN
                 DO:
                     glb_cdcritic = 9.
                     CLEAR FRAME f_pessoa.
                 END.

            IF   glb_cdcritic <> 0   THEN
                 DO:
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.
                    NEXT-PROMPT tel_nrdconta WITH FRAME f_pessoa.
                    glb_cdcritic = 0.
                    NEXT.
                END.

            { includes/sititg.i }
            
            ASSIGN tel_inpessoa = crapass.inpessoa
                   tel_tpvincul = crapass.tpvincul
                   tel_dstipess = IF   crapass.inpessoa = 1 THEN
                                       "- Pessoa Fisica"    ELSE
                                  IF   crapass.inpessoa = 2 THEN
                                       "- Pessoa Juridica"  ELSE
                                  IF   crapass.inpessoa = 3 THEN
                                       "- Cheque Administrativo"
                                  ELSE " ".

                   FIND w-vinculos WHERE w-vinculos.sigla = crapass.tpvincul.
           
                        tel_dsvincul = "- " + w-vinculos.descr.
                   
			IF crapass.inpessoa = 1 THEN
			   DO:
			      FOR FIRST crapttl FIELDS(nmextttl)
					   			    WHERE crapttl.cdcooper = crapass.cdcooper AND
									      crapttl.nrdconta = crapass.nrdconta AND
									      crapttl.idseqttl = 2
									      NO-LOCK:

				     ASSIGN tel_nmsegntl = crapttl.nmextttl.

			      END.

			   END.
				        
            DISPLAY crapass.nmprimtl tel_nmsegntl
                    tel_inpessoa     tel_dstipess       tel_tpvincul
                    tel_dsvincul     crapass.nrdctitg   tel_dssititg
                    WITH FRAME f_pessoa.

        END.

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */
