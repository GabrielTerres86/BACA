/* .............................................................................

   Programa: includes/log_altera.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Julho/94.                       Ultima atualizacao: 24/04/2017

   Dados referentes ao programa:

   Frequencia: Sempre que for chamada.
   Objetivo  : Processar a rotina de log das alteracoes do cadastro do associa-
               do.

   Alteracoes: 15/09/94 - Alterado para nao criar registro no crapalt caso nao
                          tenha sido feita nenhuma alteracao (Edson).

               03/07/97 - Alterado para tratar alteracao do tipo de extrato
                          (Deborah).

               22/08/97 - Tratar cddsenha (Odair).

               14/10/98 - Tratar novos campos (Deborah).

               09/11/98 - Tratar bloqueio e prejuizo (Deborah).

               11/02/99 - Identificar o numero das agencias na troca de 
                          agencias (Deborah).

               13/04/1999 - Logar tipo de emissao dos avisos (Deborah)

               06/04/2000 - Logar 2 proponente (Odair)

               12/09/2000 - Log da tela Mantal (Margarete/Planner)

               24/08/2001 - Alterado para passar os dados do responsavel como
                            itens de recadastramento (Deborah).

               04/10/2001 - Incluir dtcnscpf e cdsitcpf (Margarete).
               
               15/10/2002 - Incluir inarqcbr e dsdemail (Junior).

               04/08/2003 - Tratar revisao cadastral (Deborah).

               05/08/2003 - Exclusao de "revisao cadastral" do crapalt.dsaltera
                            se estiver sendo feito recadastramento (Julio).

               20/08/2004 - Incluidas as variaveis para log, das telas
                            MANEXT e EMAIL e modificacao do conteudo da variavel
                            log_nmdcampo na condicao da variavel log_tpextcta
                            (Evandro).

               02/09/2004 - Tratar conta de integracao (Margarete).

               28/12/2004 - Incluido campo log_flgiddep (Evandro).
               
               18/05/2005 - Incluido o bloqueio da Conta Integracao (Evandro).

               08/06/2005 - Prever tipos de conta 17 e 18(Mirtes)

               06/07/2005 - Alimentado campo cdcooper da tabela crapalt
                            (Diego). 
                            
               27/10/2005 - Alterada mensagem do campo log_nmdcampo para
                            "spc coop" (Diego).
                            
               22/11/2005 - Atualizar o campo flgctitg quando alterar a
                            situacao do titular (Evandro).

               13/12/2005 - Incluido campo log_nrdctitg (Diego).

               18/01/2006 - Acerto na criacao da exclusao de conta integracao
                            (Evandro).
                            
               10/02/2006 - Unificacao dos bancos - SQLWorks - Eder            
                
               28/04/2006 - Incluidas variaveis usadas na nova tela MATRIC
                            (Evandro).
                            
               28/09/2006 - Retirada opcao blq/desblq conta integracao(Mirtes)
               
               10/10/2006 - Acerto na crapalt.flgctitg (Ze).

               11/01/2007 - Verificar se a conta ITG esta ativa para atender
                            tambem as contas do BANCOOB;
                          - Removida a parte de exclusao de conta ITG porque
                            agora esse tratamento eh feito em outra include
                            (Evandro).
               
               29/03/2007 - Alterado variaveis de endereco para serem
                            comparadas com valores da estrutura crapenc (Elton).

               05/11/2007 - Utilizar nmdsecao a partit da crapttl(Guilherme).
                          - Utilizar cdturnos a partir da crapttl(Gabriel).
                          
               01/09/2008 - Alteracao cdempres (Kbase IT).
               
               25/09/2009 - Retirado atribuicao de campo de grau 
                            de parentesco (cdgraupr) - Sidnei (Precise)
                            
               10/12/2009 - Retirado inhabmen da crapass pois foi para crapttl
                            (Guilherme)
               
               18/12/2009 - Eliminado campo crapass.cddsenha (Diego).
               
               11/03/2011 - Retirar campo dsdemail e inarqcbr da crapass
                           (Gabriel).
                           
               19/05/2011 - Substituicao do campo crapenc.nranores por 
                            crapenc.dtinires (data que o cooperado passou a
                            residir no endereco informado). Fabricio     
                            
               29/04/2013 - Alterado campo crapass.dsnatura por crapttl.dsnatura
                            (Lucas R.)
                            
               13/08/2013 - Removido campo crapass.dsnatstl pois foi para
                            crapttl. (Reinert) 
                            
               30/09/2013 - Removido campo crapass.nrfonres. 
                          - Alterada String de PAC para PA. (Reinert)
                          
               14/11/2013 - Alterado totalizador de PAs de 99 para 999.
                            (Reinert)

               16/05/2014 - Alterado campo crapass.vlsalari para 
                            crapttl.vlsalari (Douglas - Chamado 131253)
                            
               10/06/2014 - (Chamado 117414) - Troca do campo crapass.nmconjug 
                            por crapcje.nmconjug  (Tiago Castro - RKAM).
               
               12/08/2015 - Projeto Reformulacao cadastral
                            Eliminado o campo nmdsecao (Tiago Castro - RKAM).

			   24/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                crapass, crapttl, crapjur 
							(Adriano - P339).
							

.............................................................................*/ 

DEF VAR aux_nmconjug LIKE crapcje.nmconjug NO-UNDO.
DEF VAR aux_dtnasccj LIKE crapcje.dtnasccj NO-UNDO.
DEF VAR aux_dsendcom LIKE crapcje.dsendcom NO-UNDO.

ASSIGN log_nmdcampo = ""
       log_tpaltera = 0
       log_flgrecad = FALSE
       log_flgctitg = 3.
       
LOG:

DO WHILE TRUE ON ERROR UNDO LOG, LEAVE:

   IF   tel_dtaltera = ?   THEN
        DO:
            IF   CAN-DO("ACESSO,CONTA,MATRIC,DESEXT,ALTRAM",glb_nmdatela) THEN
                 LEAVE.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               log_confirma = "N".

               glb_cdcritic = 401.
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic UPDATE log_confirma.
               glb_cdcritic = 0.
               LEAVE.

            END.  /*  Fim do DO WHILE TRUE  */

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                 log_confirma <> "S"   THEN
                 LEAVE.
            ELSE
                 log_tpaltera = 1.
        END.
   ELSE
        log_tpaltera = 2.
        
   DO WHILE TRUE:

      FIND crapalt WHERE crapalt.cdcooper = glb_cdcooper        AND
                         crapalt.nrdconta = crapass.nrdconta    AND
                         crapalt.dtaltera = glb_dtmvtolt
                         USE-INDEX crapalt1 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

      IF   NOT AVAILABLE crapalt   THEN
           IF   LOCKED crapalt   THEN
                DO:
                    PAUSE 2 NO-MESSAGE.
                    NEXT.
                END.
           ELSE
                DO:
                    CREATE crapalt.
                    ASSIGN crapalt.nrdconta = crapass.nrdconta
                           crapalt.dtaltera = glb_dtmvtolt
                           crapalt.tpaltera = log_tpaltera
                           crapalt.dsaltera = ""
                           crapalt.cdcooper = glb_cdcooper.
                END.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   /* Se for conta integracao ativa, seta a flag para enviar ao BB */
   IF   crapass.nrdctitg <> ""   AND
        crapass.flgctitg =  2    THEN
        ASSIGN log_flgctitg = 0.

   /*  Dados para recadastramento (geram tipo de alteracao 1) */

   IF   crapass.nmprimtl <> log_nmprimtl   THEN
        DO:
            ASSIGN log_nmdcampo = "nome 1.ttl"
                   log_flgrecad = TRUE.

            IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                 ASSIGN crapalt.flgctitg = log_flgctitg
                        crapalt.dsaltera = 
                                crapalt.dsaltera + log_nmdcampo + ",".
        END.
        
   IF   crapass.nmpaiptl <> log_nmpaiptl   THEN
        DO:
            ASSIGN log_nmdcampo = "pai 1.ttl"
                   log_flgrecad = TRUE.

            IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                 ASSIGN crapalt.flgctitg = log_flgctitg
                        crapalt.dsaltera = 
                                crapalt.dsaltera + log_nmdcampo + ",".
        END.
   
   IF   crapass.nmmaeptl <> log_nmmaeptl   THEN
        DO:
            ASSIGN log_nmdcampo = "mae 1.ttl"
                   log_flgrecad = TRUE.

            IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                 ASSIGN crapalt.flgctitg = log_flgctitg
                        crapalt.dsaltera = 
                                crapalt.dsaltera + log_nmdcampo + ",".
        END.

   IF   crapass.dtnasctl <> log_dtnasctl   THEN
        DO:
            ASSIGN log_nmdcampo = "nascto 1.ttl"
                   log_flgrecad = TRUE.

            IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                 ASSIGN crapalt.flgctitg = log_flgctitg
                        crapalt.dsaltera =
                                crapalt.dsaltera + log_nmdcampo + ",".
        END.

   IF   crapass.nrcpfcgc <> log_nrcpfcgc   THEN
        DO:
            ASSIGN log_nmdcampo = "cpf 1.ttl"
                   log_flgrecad = TRUE.

            IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                 ASSIGN crapalt.flgctitg = log_flgctitg
                        crapalt.dsaltera = 
                                crapalt.dsaltera + log_nmdcampo + ",".
        END.

   IF   crapass.dtcnscpf <> log_dtcnscpf   THEN
        DO:
            ASSIGN log_nmdcampo = "consulta cpf 1.ttl"
                   log_flgrecad = TRUE.

            IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                 crapalt.dsaltera = crapalt.dsaltera + log_nmdcampo + ",".
        END.

   IF   crapass.cdsitcpf <> log_cdsitcpf   THEN
        DO:
            ASSIGN log_nmdcampo = "situacao cpf 1.ttl"
                   log_flgrecad = TRUE.

            IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                 crapalt.dsaltera = crapalt.dsaltera + log_nmdcampo + ",".
        END.

   IF   crapass.dsnacion <> log_dsnacion   THEN
        DO:
            ASSIGN log_nmdcampo = "nacion. 1.ttl"
                   log_flgrecad = TRUE.

            IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                 ASSIGN crapalt.flgctitg = log_flgctitg
                        crapalt.dsaltera = 
                                crapalt.dsaltera + log_nmdcampo + ",".
        END.

   IF   crapass.cdestcvl <> log_cdestcvl   THEN
        DO:
            ASSIGN log_nmdcampo = "est.civil 1.ttl"
                   log_flgrecad = TRUE.

            IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                 ASSIGN crapalt.flgctitg = log_flgctitg
                        crapalt.dsaltera = 
                                crapalt.dsaltera + log_nmdcampo + ",".
        END.

   IF   crapass.dsproftl <> log_dsproftl   THEN
        DO:
            ASSIGN log_nmdcampo = "funcao"
                   log_flgrecad = TRUE.

            IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                 ASSIGN crapalt.flgctitg = log_flgctitg
                        crapalt.dsaltera = 
                                crapalt.dsaltera + log_nmdcampo + ",".
        END.

   IF   crapass.tpdocptl <> log_tpdocptl   THEN
        DO:
            ASSIGN log_nmdcampo = "tipo doc. 1.ttl"
                   log_flgrecad = TRUE.

            IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                 ASSIGN crapalt.flgctitg = log_flgctitg
                        crapalt.dsaltera = 
                                crapalt.dsaltera + log_nmdcampo + ",".
        END.

   IF   crapass.nrdocptl <> log_nrdocptl   THEN
        DO:
            ASSIGN log_nmdcampo = "doc. 1.ttl"
                   log_flgrecad = TRUE.

            IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                 ASSIGN crapalt.flgctitg = log_flgctitg
                        crapalt.dsaltera = 
                                crapalt.dsaltera + log_nmdcampo + ",".
        END.

   IF   crapass.cdsexotl <> log_cdsexotl   THEN
        DO:
            ASSIGN log_nmdcampo = "sexo 1.ttl"
                   log_flgrecad = TRUE.

            IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                 ASSIGN crapalt.flgctitg = log_flgctitg
                        crapalt.dsaltera = 
                                crapalt.dsaltera + log_nmdcampo + ",".
        END.
   
   FIND crapcje WHERE crapcje.cdcooper = glb_cdcooper AND 
                              crapcje.nrdconta = crapass.nrdconta AND 
                              crapcje.idseqttl = 1 USE-INDEX crapcje1 NO-ERROR.
   IF AVAILABLE crapcje THEN
        ASSIGN aux_nmconjug = crapcje.nmconjug.
   IF   aux_nmconjug <> log_nmconjug   THEN
        DO:
            ASSIGN log_nmdcampo = "conjuge 1.ttl"
                   log_flgrecad = TRUE.

            IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                 ASSIGN crapalt.flgctitg = log_flgctitg
                        crapalt.dsaltera = 
                                crapalt.dsaltera + log_nmdcampo + ",".
        END.

   IF   crapass.nrdctitg <> log_nrdctitg   AND
        crapass.cdtipcta =  log_cdtipcta   THEN
        DO:
            ASSIGN log_nmdcampo = "exclusao conta-itg" + "(" + 
                                   STRING(log_nrdctitg) + ")" +
                                  "- ope." +  glb_cdoperad.
                   log_flgrecad = TRUE.

            IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                 ASSIGN crapalt.flgctitg = log_flgctitg
                        crapalt.dsaltera = 
                                crapalt.dsaltera + log_nmdcampo + ",".
        END.     

   /*  Dados para atualizacao (geram tipo de alteracao 2) */

   IF   crapass.cdagenci <> log_cdagenci   THEN
        DO:
            log_nmdcampo = "pa." + STRING(log_cdagenci,"999") + "-" +
                                   STRING(crapass.cdagenci,"999").

            IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                 crapalt.dsaltera = crapalt.dsaltera + log_nmdcampo + ",".
        END.

   IF   crapass.nrcadast <> log_nrcadast   THEN
        DO:
            log_nmdcampo = "cadastro 1.ttl".

            IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                 crapalt.dsaltera = crapalt.dsaltera + log_nmdcampo + ",".
        END.

   IF   crapass.dtdemiss <> log_dtdemiss   THEN
        DO:
            log_nmdcampo = "demissao".

            IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                 crapalt.dsaltera = crapalt.dsaltera + log_nmdcampo + ",".
        END.

   FIND crapcje WHERE crapcje.cdcooper = glb_cdcooper AND 
                              crapcje.nrdconta = tt-crapass.nrdconta AND 
                              crapcje.idseqttl = 1 USE-INDEX crapcje1 NO-ERROR.
   IF AVAILABLE crapcje THEN
      ASSIGN aux_dtnasccj = crapcje.dtnasccj
             aux_dsendcom = crapcje.dsendcom.
   IF   aux_dtnasccj <> log_dtnasccj   THEN
        DO:
            log_nmdcampo = "nascto conjuge".

            IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                 ASSIGN crapalt.flgctitg = log_flgctitg
                        crapalt.dsaltera = 
                                crapalt.dsaltera + log_nmdcampo + ",".
        END.
   IF   aux_dsendcom <> log_dsendcom   THEN
        DO:
            log_nmdcampo = "end.conjuge".

            IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                 crapalt.dsaltera = crapalt.dsaltera + log_nmdcampo + ",".
        END.

   IF   crapass.dtadmemp <> log_dtadmemp   THEN
        DO:
            log_nmdcampo = "adm.empr.".

            IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                 ASSIGN crapalt.flgctitg = log_flgctitg
                        crapalt.dsaltera = 
                                crapalt.dsaltera + log_nmdcampo + ",".
        END.

   IF   crapass.nrramemp <> log_nrramemp   THEN
        DO:
            log_nmdcampo = "ramal".

            IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                 crapalt.dsaltera = crapalt.dsaltera + log_nmdcampo + ",".
        END.

   IF   crapass.nrctacto <> log_nrctacto   THEN
        DO:
            log_nmdcampo = "ctato1".

            IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                 crapalt.dsaltera = crapalt.dsaltera + log_nmdcampo + ",".
        END.
        
   IF   crapass.nrctaprp <> log_nrctaprp   THEN
        DO:
            log_nmdcampo = "ctato2".

            IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                 crapalt.dsaltera = crapalt.dsaltera + log_nmdcampo + ",".
        END.
     

   IF   crapass.cdtipcta <> log_cdtipcta   THEN
        DO:
            log_nmdcampo = "tipo cta".

            IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                 crapalt.dsaltera = crapalt.dsaltera + log_nmdcampo + ",".
        END.

   IF   crapass.cdsitdct <> log_cdsitdct   THEN
        DO:
            log_nmdcampo = "sit.cta".

            IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                 crapalt.dsaltera = crapalt.dsaltera + log_nmdcampo + ",".
        END.

   IF   crapass.cdsecext <> log_cdsecext   THEN
        DO:
            log_nmdcampo = "dest.extrato".

            IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                 crapalt.dsaltera = crapalt.dsaltera + log_nmdcampo + ",".
        END.

   IF   crapass.dtcnsspc <> log_dtcnsspc   THEN
        DO:
            log_nmdcampo = "consulta spc".

            IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                 crapalt.dsaltera = crapalt.dsaltera + log_nmdcampo + ",".
        END.

   IF   crapass.dtdsdspc <> log_dtdsdspc   THEN
        DO:
            log_nmdcampo = "spc coop".

            IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                 crapalt.dsaltera = crapalt.dsaltera + log_nmdcampo + ",".
        END.

   IF   crapass.inadimpl <> log_inadimpl   THEN
        DO:
            log_nmdcampo = "spc".

            IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                 crapalt.dsaltera = crapalt.dsaltera + log_nmdcampo + ",".
        END.

   IF   crapass.inlbacen <> log_inlbacen   THEN
        DO:
            log_nmdcampo = "ccf".

            IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                 crapalt.dsaltera = crapalt.dsaltera + log_nmdcampo + ",".
        END.
        
   IF   crapass.flgiddep <> log_flgiddep   THEN
        DO:
            log_nmdcampo = "id.dep".

            IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                 crapalt.dsaltera = crapalt.dsaltera + log_nmdcampo + ",".
        END.
        
   IF   crapass.tpextcta <> log_tpextcta   THEN
        DO:
            log_nmdcampo = "recebimento de extrato".        

            IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                 crapalt.dsaltera = crapalt.dsaltera + log_nmdcampo + ",".
        END.
   
   IF   crapass.tpavsdeb <> log_tpavsdeb   THEN
        DO:
            log_nmdcampo = "tipo aviso deb.".

            IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                 crapalt.dsaltera = crapalt.dsaltera + log_nmdcampo + ",".
        END.

   /* campos 14/10/98 */

   IF   crapass.cdoedptl <> log_cdoedptl   THEN
        DO:
            log_nmdcampo = "org.ems.doc. 1.ttl".

            IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                 ASSIGN crapalt.flgctitg = log_flgctitg
                        crapalt.dsaltera = 
                                crapalt.dsaltera + log_nmdcampo + ",".
        END.
   
   IF   crapass.cdufdptl <> log_cdufdptl   THEN
        DO:
            log_nmdcampo = "uf.ems.doc. 1.ttl".

            IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                 ASSIGN crapalt.flgctitg = log_flgctitg
                        crapalt.dsaltera = 
                                crapalt.dsaltera + log_nmdcampo + ",".
        END.
   
   IF   crapass.dtemdptl <> log_dtemdptl   THEN
        DO:
            log_nmdcampo = "dt.ems.doc. 1.ttl".

            IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                 ASSIGN crapalt.flgctitg = log_flgctitg
                        crapalt.dsaltera = 
                                crapalt.dsaltera + log_nmdcampo + ",".
        END.

   IF   crapass.cdsitdtl <> log_cdsitdtl   THEN
        DO:
            log_nmdcampo = "sit.tit." + STRING(log_cdsitdtl,"9") + "-" +
                                        STRING(crapass.cdsitdtl,"9").

            IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                 ASSIGN crapalt.dsaltera = crapalt.dsaltera + log_nmdcampo +
                                           ","
                        crapalt.flgctitg = log_flgctitg.

            /*================Nao utilizado======================
            /* Bloqueio/Desbloqueio da Conta Integracao 
               (O Campo "blq/dblq" eh somente uma referencia para o programa
                que trata as alteracoes cadastrais da Conta Integracao) */
            IF   crapass.flgctitg  = 2    AND
                 crapass.nrdctitg <> ""   THEN
                 DO:
                    log_nmdcampo = "blq/dblq".
                     
                    IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                         ASSIGN crapalt.flgctitg = log_flgctitg
                                crapalt.dsaltera = crapalt.dsaltera +
                                                   log_nmdcampo + ",".
                 END.
            ======================================================*/


        END.
        
    IF   AVAILABLE crapttl   THEN
         DO:
             IF   crapttl.dsnatura <> log_dsnatura   THEN
                  DO:
                      ASSIGN log_nmdcampo = "natural. " +  
                                            STRING(crapttl.idseqttl,"9") +
                                            ".ttl"
                             log_flgrecad = TRUE.
                  
                      IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                           ASSIGN crapalt.flgctitg = log_flgctitg
                                  crapalt.dsaltera =
                                  crapalt.dsaltera + log_nmdcampo + ",".
                  END.

             
             IF   crapttl.cdturnos <> log_cdturnos   THEN
                  DO:
                      log_nmdcampo = "turno " +
                                     STRING(crapttl.idseqttl,"9") +
                                     ".ttl".
                  
                      IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                           ASSIGN crapalt.flgctitg = log_flgctitg
                                  crapalt.dsaltera = crapalt.dsaltera + 
                                                     log_nmdcampo + ",".
                  END.
             
             
             /* IF   crapttl.nmdsecao <> log_nmdsecao   THEN
                  DO:
                      log_nmdcampo = "secao " +
                                     STRING(crapttl.idseqttl,"9") +
                                     ".ttl".

                      IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                           ASSIGN crapalt.flgctitg = log_flgctitg
                                  crapalt.dsaltera = crapalt.dsaltera + 
                                                     log_nmdcampo + ",".
                  END. */
             
             
             IF   crapttl.tpnacion <> log_tpnacion   THEN
                  DO:
                      log_nmdcampo = "tipo nacion. " +
                                     STRING(crapttl.idseqttl,"9") +
                                     ".ttl".
                
                      IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                           ASSIGN crapalt.flgctitg = log_flgctitg
                                  crapalt.dsaltera = crapalt.dsaltera +
                                                     log_nmdcampo + ",".
                  END.
                  
             IF   crapttl.cdocpttl <> log_cdocpttl   THEN
                  DO:
                      log_nmdcampo = "ocupacao " + 
                                     STRING(crapttl.idseqttl,"9") +
                                     ".ttl".
                
                      IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                           ASSIGN crapalt.flgctitg = log_flgctitg
                                  crapalt.dsaltera = crapalt.dsaltera +
                                                     log_nmdcampo + ",".
                  END.
                  
             IF   crapttl.cdempres <> log_cdempres   THEN
                  DO:
                      log_nmdcampo = "empr." + STRING(log_cdempres,"99999") +
                                     "-" + STRING(crapttl.cdempres,"99999") +
                                     " 1.ttl".

                      IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                           crapalt.dsaltera = crapalt.dsaltera + log_nmdcampo +
                                              ",".
                  END.

             IF   crapass.vlsalari <> log_vlsalari   THEN
                  DO:
                      log_nmdcampo = "salario".
                      IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                          crapalt.dsaltera = crapalt.dsaltera + log_nmdcampo + ",".
                  END.

         END.
        
    IF   AVAILABLE crapenc   THEN
         DO:
             IF   crapenc.dsendere <> log_dsendere   THEN
                  DO:
                      ASSIGN log_nmdcampo = "endereco " +
                                            STRING(crapenc.idseqttl,"9") +
                                            ".ttl"
                             log_flgrecad = TRUE.

                      IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                           crapalt.dsaltera = crapalt.dsaltera + log_nmdcampo +
                                              ",".
                  END.

             IF   crapenc.nmbairro <> log_nmbairro   THEN
                  DO:
                      ASSIGN log_nmdcampo = "bairro " +
                                            STRING(crapenc.idseqttl,"9") +
                                            ".ttl"
                             log_flgrecad = TRUE.

                      IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                           crapalt.dsaltera = crapalt.dsaltera + log_nmdcampo +
                                              ",".
                  END.

             IF   crapenc.nmcidade <> log_nmcidade   THEN
                  DO:
                      ASSIGN log_nmdcampo = "cidade " +
                                            STRING(crapenc.idseqttl,"9") +
                                            ".ttl"
                             log_flgrecad = TRUE.

                      IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                           crapalt.dsaltera = crapalt.dsaltera + log_nmdcampo +
                                              ",".
                  END.

             IF   crapenc.cdufende <> log_cdufende   THEN
                  DO:
                      ASSIGN log_nmdcampo = "uf " +
                                            STRING(crapenc.idseqttl,"9") +
                                            ".ttl"
                             log_flgrecad = TRUE.

                      IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                           crapalt.dsaltera = crapalt.dsaltera + log_nmdcampo +
                                              ",".
                  END.

             IF   crapenc.nrcepend <> log_nrcepend   THEN
                  DO:
                      ASSIGN log_nmdcampo = "cep " + 
                                            STRING(crapenc.idseqttl,"9") +
                                            ".ttl"
                             log_flgrecad = TRUE.

                      IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                           crapalt.dsaltera = crapalt.dsaltera + log_nmdcampo +
                                              ",".
                  END.

             IF   crapenc.nrendere <> log_nrendere   THEN
                  DO:
                      log_nmdcampo = "nro.end. " +
                                     STRING(crapenc.idseqttl,"9") +
                                     ".ttl".
                
                      IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                           ASSIGN crapalt.flgctitg = log_flgctitg
                                  crapalt.dsaltera = crapalt.dsaltera +
                                                     log_nmdcampo + ",".
                  END.
                  
             IF   crapenc.complend <> log_complend   THEN
                  DO:
                      log_nmdcampo = "compl.end. " + 
                                     STRING(crapenc.idseqttl,"9") +
                                     ".ttl".
                                                            
                      IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                           ASSIGN crapalt.flgctitg = log_flgctitg
                                  crapalt.dsaltera = crapalt.dsaltera +
                                                     log_nmdcampo + ",".
                  END.
                  
             IF   crapenc.nrcxapst <> log_nrcxapst   THEN
                  DO:
                      log_nmdcampo = "caixa postal " +
                                     STRING(crapenc.idseqttl,"9") +
                                     ".ttl".
                
                      IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                           ASSIGN crapalt.flgctitg = log_flgctitg
                                  crapalt.dsaltera = crapalt.dsaltera +
                                                     log_nmdcampo + ",".
                  END.
                  
             IF   crapenc.incasprp <> log_incasprp   THEN
                  DO:
                      log_nmdcampo = "casa propria".

                      IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                           ASSIGN crapalt.flgctitg = log_flgctitg
                                  crapalt.dsaltera = 
                                          crapalt.dsaltera + log_nmdcampo + ",".
                  END.

             IF   crapenc.vlalugue <> log_vlalugue   THEN
                  DO:
                      log_nmdcampo = "aluguel".

                      IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                           crapalt.dsaltera = 
                                   crapalt.dsaltera + log_nmdcampo + ",".
                  END.

             IF   crapenc.dtinires <> log_dtinires   THEN
                  DO:
                      log_nmdcampo = "tempo resid.".

                      IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                           ASSIGN crapalt.flgctitg = log_flgctitg
                                  crapalt.dsaltera =
                                          crapalt.dsaltera + log_nmdcampo + ",".
                  END.
                  
         END.
               
    IF   AVAILABLE craptfc   THEN
         DO:
             IF   craptfc.nrdddtfc <> log_nrdddtfc   THEN
                  DO:
                      ASSIGN log_nmdcampo = "DDD".
                             log_flgrecad = TRUE.

                      IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                           crapalt.dsaltera = crapalt.dsaltera + log_nmdcampo +
                                              ",".
                  END.

             IF   craptfc.nrtelefo <> log_nrtelefo   THEN
                  DO:
                      ASSIGN log_nmdcampo = "telefone".
                             log_flgrecad = TRUE.

                      IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                           crapalt.dsaltera = crapalt.dsaltera + log_nmdcampo +
                                              ",".
                  END.
         END.
         
    IF   AVAILABLE crapjur   THEN
         DO:
             IF   crapjur.dtiniatv <> log_dtiniatv   THEN
                  DO:
                      log_nmdcampo = "ini.ativ.".
                
                      IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                           ASSIGN crapalt.flgctitg = log_flgctitg
                                  crapalt.dsaltera = crapalt.dsaltera +
                                                     log_nmdcampo + ",".
                  END.
                  
             IF   crapjur.natjurid <> log_natjurid   THEN
                  DO:
                      log_nmdcampo = "nat.jurid.".
                
                      IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                           ASSIGN crapalt.flgctitg = log_flgctitg
                                  crapalt.dsaltera = crapalt.dsaltera +
                                                     log_nmdcampo + ",".
                  END.
                  
             IF   crapjur.nmfansia <> log_nmfansia   THEN
                  DO:
                      log_nmdcampo = "nome fantasia".
                
                      IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                           ASSIGN crapalt.flgctitg = log_flgctitg
                                  crapalt.dsaltera = crapalt.dsaltera +
                                                     log_nmdcampo + ",".
                  END.

             IF   crapjur.nrinsest <> log_nrinsest   THEN
                  DO:
                      log_nmdcampo = "insc.estadual".
                
                      IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                           ASSIGN crapalt.flgctitg = log_flgctitg
                                  crapalt.dsaltera = crapalt.dsaltera +
                                                     log_nmdcampo + ",".
                  END.

             IF   crapjur.cdrmativ <> log_cdrmativ   THEN
                  DO:
                      log_nmdcampo = "ramo ativ.".
                
                      IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                           ASSIGN crapalt.flgctitg = log_flgctitg
                                  crapalt.dsaltera = crapalt.dsaltera +
                                                     log_nmdcampo + ",".
                  END.
         END.
         
/* log da tela MANEXT */
IF   AVAILABLE crapcex   AND   glb_nmdatela = "MANEXT"   THEN
     DO:
         IF   crapcex.cddemail <> log_cddemail   OR
              crapcex.cdperiod <> log_cdperiod   OR   
              crapcex.cdrefere <> log_cdrefere   OR
              crapcex.nmpessoa <> log_nmpessoa   OR
              crapcex.tpextrat <> log_tpextrat   THEN
                  DO:
                      log_nmdcampo = "tipo de extrato".

                      IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                           crapalt.dsaltera = crapalt.dsaltera + log_nmdcampo 
                                              + ",".
                  END.
     END.  /* fim log da tela MANEXT */

/* log da tela EMAIL */
IF   AVAILABLE crapcem   AND   glb_nmdatela = "EMAIL"   THEN
     DO:
         IF   crapcem.cddemail <> log_codemail   OR
              crapcem.dsdemail <> log_desemail   THEN
                  DO:
                      log_nmdcampo = "e-mail".

                      IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                           crapalt.dsaltera = crapalt.dsaltera + log_nmdcampo 
                                              + ",".
                  END.
     END. /* fim log da tela EMAIL */
     
/*
   IF   log_flgrecad AND CAN-DO(crapalt.dsaltera, "revisao cadastral")   THEN
        crapalt.dsaltera = REPLACE(crapalt.dsaltera, "revisao cadastral,", "").
*/  
   /****** Magui LOG DAS ALTERACOES FEITAS PELA TELA MANTAL *******/
   IF   log_cddopcao <> "" AND
        log_nrdctabb <> 0  AND
        log_nrdocmto <> 0  THEN
        DO:
            IF   log_cddopcao = "B"  THEN
                 ASSIGN log_desopcao = "canc.chq.  ".
            ELSE
                 ASSIGN log_desopcao = "libr.chq.  ".
                 
            ASSIGN log_nmdcampo = log_desopcao + 
                                  string(log_nrdocmto,"zzz,z99,9") +
                                  " cta base " +
                                  string(log_nrdctabb,"zzzz,zzz,9").
                                  
            IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN DO:
                 
                 /* corrigir o registro, pois este log exige que o 
                    tamanho dele seja 41 para mostrar correto na tela altera */ 
                 ASSIGN log_qtlinhas = LENGTH(crapalt.dsaltera) / 41
                        log_qtletras = log_qtlinhas * 41.
                 IF   log_qtletras < LENGTH(crapalt.dsaltera) THEN
                      ASSIGN log_qtlinhas = log_qtlinhas + 1
                             log_qtletras = log_qtlinhas * 41.
                 IF   log_qtletras <> 0 then 
                      ASSIGN substr(crapalt.dsaltera,log_qtletras,1) = ",". 
                 /********************************************************/
                 
                  crapalt.dsaltera = crapalt.dsaltera + log_nmdcampo + ",".
            END.
            
        END.
   /*******************/

   /*** Log da tela CADSPC ***/
   IF   glb_nmdatela = "CADSPC"   THEN
        DO:
            ASSIGN log_desopcao = "CADSPC="
                   log_nmdcampo = "".
            IF   log_dtvencto <> crapspc.dtvencto   THEN
                 ASSIGN log_nmdcampo = log_desopcao +
                                       " Vencto " +
                                       STRING(log_dtvencto,"99/99/9999") + ","
                        log_desopcao = "".    
                                   
            IF   log_vldivida <> crapspc.vldivida   THEN
                 ASSIGN log_nmdcampo = log_nmdcampo + log_desopcao +
                                       " Valor Divida " +
                                       STRING(log_vldivida,"zzz,zz9.99") + ","
                        log_desopcao = "". 
                                  
            IF   log_dtinclus <> crapspc.dtinclus   THEN
                 ASSIGN log_nmdcampo = log_nmdcampo + log_desopcao +
                                       " Data Inclusao " +
                                       STRING(log_dtinclus,"99/99/9999") + ","
                        log_desopcao = "".   
                                    
            IF   log_dtdbaixa <> crapspc.dtdbaixa   THEN
                 ASSIGN log_nmdcampo = log_nmdcampo + log_desopcao +
                                       " Data Baixa " +
                                       STRING(log_dtdbaixa,"99/99/9999") + ","
                        log_desopcao = "".     
                                  
            IF   log_dsoberv1 <> crapspc.dsoberva   THEN
                 ASSIGN log_nmdcampo = log_nmdcampo + log_desopcao +
                                       " Obser.Inclusao " + log_dsoberv1 + ","
                        log_desopcao = "".    
                                   
            IF   log_dsoberv2 <> crapspc.dsobsbxa   THEN
                 ASSIGN log_nmdcampo = log_nmdcampo + log_desopcao + 
                                       " Obser.Baixa " + log_dsoberv2 + ","
                        log_desopcao = "".                   
                  
            ASSIGN  crapalt.dsaltera = crapalt.dsaltera + log_nmdcampo.
              
        END.
                  
   /*************************/
   IF   CAN-DO("ALTRAM,DESEXT,ACESSO",glb_nmdatela)   THEN
        IF   crapalt.cdoperad = ""   THEN
             crapalt.cdoperad = glb_cdoperad.
        ELSE .
   ELSE
        crapalt.cdoperad = glb_cdoperad.

   IF   log_flgrecad    THEN
        DO:
           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

              log_confirma = "N".

              glb_cdcritic = 402.
              RUN fontes/critic.p.
              BELL.
              MESSAGE glb_dscritic UPDATE log_confirma.
              glb_cdcritic = 0.
              LEAVE.

           END.  /*  Fim do DO WHILE TRUE  */

           IF   KEYFUNCTION(LASTKEY) = "END-ERROR" OR log_confirma <> "S"   THEN
                . /* crapalt.tpaltera = 2. */
           ELSE
                ASSIGN crapalt.dsaltera = 
                         REPLACE(crapalt.dsaltera, "revisao cadastral,", "")
                       crapalt.tpaltera = 1.
        END.
   ELSE
   IF   crapalt.tpaltera = 2      AND   
        glb_nmdatela <> "MANTAL"  AND
        glb_nmdatela <> "CADSPC"  THEN
        DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               log_confirma = "N".

               glb_cdcritic = 764.
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic UPDATE log_confirma.
               glb_cdcritic = 0.
               LEAVE.

            END.  /*  Fim do DO WHILE TRUE  */

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                 log_confirma <> "S"   THEN
                 . /* crapalt.tpaltera = 2. */
            ELSE
                 DO:
                     IF   NOT CAN-DO(crapalt.dsaltera, "revisao cadastral") THEN
                          crapalt.dsaltera = crapalt.dsaltera +
                                             "revisao cadastral,".
                     crapalt.tpaltera = 1.
                 END.
        END.
         
   IF   NEW crapalt   THEN
        IF   crapalt.dsaltera = ""   AND   crapalt.tpaltera = 2   THEN
             UNDO LOG, LEAVE.

   
   LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */





