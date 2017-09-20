/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | generico/includes/b1wgenllog.i  | CYBE0001.pc_proc_alteracoes_log   |
  +---------------------------------+-----------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/





/* .............................................................................

   Programa: sistema/generico/includes/b1wgenllog.i (log_logcontas.i)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Abril/2006.                    Ultima atualizacao: 20/04/2017

   Dados referentes ao programa:

   Frequencia: Sempre que for chamada.
   Objetivo  : Processar a rotina de log das alteracoes feitas.

   Alteracoes: 19/10/2006 - Acerto na Exclusao da Conta de Integracao (Ze).
   
               05/01/2007 - Verificar se a conta ITG esta ativa para atender
                            tambem as contas do BANCOOB (Evandro).
                            
               11/01/2007 - Corrigida a atribuicao do operador que fez a
                            alteracao (Evandro).

               01/09/2008 - Alteracao cdempres (Kbase IT) - Eduardo Silva.
                          - Retirado tratamento do campo Rec.Arq.Cob 
                            e email (Gabriel)

               18/06/2009 - Ajustes  para os campos de rendimento e valor. 
                            Logar novo item BENS (Gabriel).
                            
               04/12/2009 - Logar campos do item "INF. ADICIONAL" da pessoa
                            fisica (Elton).        
                            
               16/12/2009 - Eliminado campo crapttl.cdgrpext (Diego).
               
               01/03/2010 - Adaptar p/ uso nas BO's (Jose Luis, DB1)
               
               11/03/2011 - Retirar campo dsdemail e inarqcbr da crapass
                            (Gabriel).
                            
               20/05/2011 - Substituicao do campo crapenc.nranores por 
                            crapenc.dtinires (data que o cooperado passou a
                            residir no endereco informado). Fabricio 
                            
               13/06/2011 - Incluir campo de 'Pessoa politicamente exposta'
                            (Gabriel). 
                            
               05/07/2011 - Incluidas as variaveis log_nrdoapto e log_cddbloco 
                            (Henrique).          
                            
               02/12/2011 - Incluido a variavel log_dsjusren (Adriano).             
               
               13/04/2012 - Incluir tratamento para tela CADSPC (DB1).
               
               16/04/2012 - Incluido tratamento para a tabela crapcrl - Resp.
                            Legal (AdriaNO).
                            
               29/04/2013 - Alterado campo crapass.dsnatura por crapttl.dsnatura.
                          - Incluirdo crapttl.cdufnatu <> log_cdufnatu.
                            (Lucas R)
                            
               20/08/2013 - Alterada posicao de verificacao dos campos dsnatura 
                            e cdufnatu para verificar somente se a crapttl
                            estiver disponivel. (Reinert)
                            
               30/09/2013 - Removido campo log_nrfonres.
                          - Alterada String de PAC para PA. (Reinert)                            
                          
               14/11/2013 - Alterado totalizador de PAs de 99 para 999.
                            (Reinert)                          
                            
               10/12/2013 - Incluir VALIDATE crapalt (Lucas R.)

               24/03/2014 - Melhoria nas mensagens de log do cadastro de bens 
                            (Carlos)
                            
               10/06/2014 - (Chamado 117414) - Troca do campo crapass.nmconjug por crapcje.nmconjug
                            (Tiago Castro - RKAM).
                            
               05/01/2015 - Incluido variavel log_flgrenli. (James)

               20/07/2015 - Estava gravando alterações no conjuge mesmo quando não havia 
                            nenhuma informação alterada. Identificado que isso acontecia quando
                            não vinha informações de cônjuge no LOG. Incluída validação para não
                            processar os campos do cônjuge se os mesmos não estiverem presentes no LOG.
                            Chamado 305924 (Heitor - RKAM)

			         27/10/2015 - Incluido verificacao de log do campo crapass.idastcjt,
                            Prj. Assinatura Conjunta, PRJ 131. (Jean Michel)

               29/02/2016 - Trocando o campo flpolexp para inpolexp conforme
                            solicitado no chamado 402159 (Kelvin).

               19/04/2017 - Alteraçao DSNACION pelo campo CDNACION.
                            PRJ339 - CRM (Odirlei-AMcom)  

			   20/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                crapass, crapttl, crapjur 
							(Adriano - P339).

               17/07/2017 - Alteraçao CDOEDTTL pelo campo IDORGEXP.
                            PRJ339 - CRM (Odirlei-AMcom)             

.............................................................................*/ 



ASSIGN log_nmdcampo = ""
       log_tpaltera = 2 /* Por default fica como 2 */
       log_flgctitg = 3
       log_flgrecad = FALSE.

LOG:

DO WHILE TRUE ON ERROR UNDO LOG, LEAVE:

   ASSIGN aux_flgnvalt = FALSE.

   ContadorAlt: DO aux_contador = 1 TO 10:

      FIND crapalt WHERE crapalt.cdcooper = log_cdcooper    AND
                         crapalt.nrdconta = log_nrdconta    AND
                         crapalt.dtaltera = log_dtmvtolt
                         USE-INDEX crapalt1 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

      IF  NOT AVAILABLE crapalt   THEN
          DO:
             IF  LOCKED(crapalt) THEN
                 DO:
                    IF  aux_contador = 10 THEN
                        DO:
                           ASSIGN aux_dscritic = "Registro sendo alterado em" +
                                                 " outro terminal (crapalt)".
                           LEAVE LOG.
                        END.
                    ELSE
                        DO:
                           PAUSE 1 NO-MESSAGE.
                           NEXT ContadorAlt.
                        END.
                 END.
             ELSE
                 DO:
                    CREATE crapalt.
                    ASSIGN crapalt.nrdconta = log_nrdconta
                           crapalt.dtaltera = log_dtmvtolt
                           crapalt.tpaltera = log_tpaltera
                           crapalt.dsaltera = ""
                           crapalt.cdcooper = log_cdcooper.

                    VALIDATE crapalt.

                    ASSIGN aux_flgnvalt = YES.
                 END.
          END.
      ELSE
          LEAVE ContadorAlt.

   END.  /*  Fim do DO WHILE TRUE  */

   /* Se for conta integracao ativa, seta a flag para enviar ao BB */
   IF   crapass.nrdctitg <> ""   AND
        crapass.flgctitg = 2     THEN  /* Ativa */
        ASSIGN log_flgctitg = 0.

   &IF DEFINED(TELA-MATRIC) <> 0 &THEN
   
       IF   crapass.nmprimtl <> log_nmprimtl   THEN
            DO:
                ASSIGN log_nmdcampo = "nome 1.ttl"
                       log_flgrecad = TRUE.

                IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                     ASSIGN crapalt.flgctitg = log_flgctitg
                            crapalt.dsaltera = crapalt.dsaltera + 
                                               log_nmdcampo + ",".
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
    
       IF   crapass.cdnacion <> log_cdnacion   THEN
            DO:
                ASSIGN log_nmdcampo = "nacion. 1.ttl"
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

       FIND  crapcje WHERE crapcje.cdcooper = par_cdcooper AND 
                           crapcje.nrdconta = crapass.nrdconta AND 
                           crapcje.idseqttl = 1 USE-INDEX crapcje1 NO-ERROR.
       IF AVAILABLE crapcje THEN                    
        ASSIGN aux_nmconjug1 = crapcje.nmconjug
               aux_dtnasccj = crapcje.dtnasccj
               aux_dsendcom = crapcje.dsendcom.
       
       IF   aux_nmconjug1 <> log_nmconjug   THEN
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
                                      "- ope." +  log_cdoperad.
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
    
       IF   crapass.idorgexp <> log_idorgexp_ass   THEN
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
                     ASSIGN crapalt.dsaltera = crapalt.dsaltera + log_nmdcampo 
                                               + ","
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

                 IF   crapttl.cdufnatu <> log_cdufnatu   THEN
                      DO:
                             ASSIGN log_nmdcampo = "uf naturalidade. " +
                                                   STRING(crapttl.idseqttl,"9") +
                                                   ".ttl"
                                    log_flgrecad = TRUE.
        
                             IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                                  ASSIGN crapalt.flgctitg = log_flgctitg
                                         crapalt.dsaltera =
                                                 crapalt.dsaltera + log_nmdcampo + ",".
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
                          log_nmdcampo = "empr." + STRING(log_cdempres,"99999")
                                         + "-" + STRING(crapttl.cdempres,
                                                        "99999") + " 1.ttl".
    
                          IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                               crapalt.dsaltera = crapalt.dsaltera + 
                                                  log_nmdcampo + ",".
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
                               crapalt.dsaltera = crapalt.dsaltera + 
                                                  log_nmdcampo + ",".
                      END.
    
                 IF   crapenc.nmbairro <> log_nmbairro   THEN
                      DO:
                          ASSIGN log_nmdcampo = "bairro " +
                                                STRING(crapenc.idseqttl,"9") +
                                                ".ttl"
                                 log_flgrecad = TRUE.
    
                          IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                               crapalt.dsaltera = crapalt.dsaltera + 
                                                  log_nmdcampo + ",".
                      END.
    
                 IF   crapenc.nmcidade <> log_nmcidade   THEN
                      DO:
                          ASSIGN log_nmdcampo = "cidade " +
                                                STRING(crapenc.idseqttl,"9") +
                                                ".ttl"
                                 log_flgrecad = TRUE.
    
                          IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                               crapalt.dsaltera = crapalt.dsaltera + 
                                                  log_nmdcampo + ",".
                      END.
    
                 IF   crapenc.cdufende <> log_cdufende   THEN
                      DO:
                          ASSIGN log_nmdcampo = "uf " +
                                                STRING(crapenc.idseqttl,"9") +
                                                ".ttl"
                                 log_flgrecad = TRUE.
    
                          IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                               crapalt.dsaltera = crapalt.dsaltera + 
                                                  log_nmdcampo + ",".
                      END.
    
                 IF   crapenc.nrcepend <> log_nrcepend   THEN
                      DO:
                          ASSIGN log_nmdcampo = "cep " + 
                                                STRING(crapenc.idseqttl,"9") +
                                                ".ttl"
                                 log_flgrecad = TRUE.
    
                          IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                               crapalt.dsaltera = crapalt.dsaltera + 
                                                  log_nmdcampo + ",".
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
                                      crapalt.dsaltera = crapalt.dsaltera + 
                                                         log_nmdcampo + ",".
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
                                      crapalt.dsaltera = crapalt.dsaltera + 
                                                         log_nmdcampo + ",".
                      END.
                      
             END.
             
        IF   AVAILABLE craptfc   THEN
             DO:
                 IF   craptfc.nrdddtfc <> log_nrdddtfc   THEN
                      DO:
                          ASSIGN log_nmdcampo = "DDD".
                                 log_flgrecad = TRUE.
    
                          IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                               crapalt.dsaltera = crapalt.dsaltera + 
                                                  log_nmdcampo + ",".
                      END.
    
                 IF   craptfc.nrtelefo <> log_nrtelefo   THEN
                      DO:
                          ASSIGN log_nmdcampo = "telefone".
                                 log_flgrecad = TRUE.
    
                          IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                               crapalt.dsaltera = crapalt.dsaltera + 
                                                  log_nmdcampo + ",".
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
   
   &ENDIF /* {&TELA-MATRIC} */
  
   &IF DEFINED(TELA-CONTAS) = 0 &THEN
   
       /* Verificacoes para o log dos dados genericos */        
       IF   AVAILABLE crapass   THEN
            DO:
               IF   crapass.cdagenci <> log_cdageass   THEN
                    DO:
                        ASSIGN log_nmdcampo = "PA " + STRING(log_cdageass) +
                                              "-" + STRING(crapass.cdagenci).
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
    
               /* Verificacoes para o log da tela: CONTAS -> CONTA CORRENTE */
    
               IF   crapass.cdtipcta <> log_cdtipcta   THEN
                    DO:
                        ASSIGN log_nmdcampo = "tipo cta".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
                    
               IF   crapass.cdsitdct <> log_cdsitdct   THEN
                    DO:
                        ASSIGN log_nmdcampo = "sit.cta".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
                    
               IF   crapass.flgiddep <> log_flgiddep   THEN
                    DO:
                        ASSIGN log_nmdcampo = "id.dep".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
                    
               IF   crapass.qtfoltal <> log_qtfoltal   THEN
                    DO:
                        ASSIGN log_nmdcampo = "folhas talao".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
                    
               IF   crapass.tpavsdeb <> log_tpavsdeb   THEN
                    DO:
                        ASSIGN log_nmdcampo = "aviso debito".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.     
                    
               IF   crapass.tpextcta <> log_tpextcta   THEN
                    DO:
                        ASSIGN log_nmdcampo = "tipo extrato".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
                         
               IF   crapass.cdsecext <> log_cdsecext   THEN
                    DO:
                        ASSIGN log_nmdcampo = "destino extrato" +
                                              STRING(log_cdsecext) + "-" +
                                              STRING(crapass.cdsecext).
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.          
                
               IF   crapass.dtcnsspc <> log_dtcnsspc   THEN
                    DO:
                        ASSIGN log_nmdcampo = "consulta spc".
                        
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)    THEN
                             RUN atualiza_crapalt.
                    END.   
                    
               IF   crapass.dtcnsscr <> log_dtcnsscr   THEN
                    DO:
                        ASSIGN log_nmdcampo = "consulta scr".
                        
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
               
               IF   crapass.dtdsdspc <> log_dtdsdspc   THEN
                    DO:
                        ASSIGN log_nmdcampo = "spc p/coop".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
    
               IF   (crapass.inadimpl = 0    AND
                     log_dsinadim     = "S") OR
                    (crapass.inadimpl = 1    AND
                     log_dsinadim     = "N") THEN           
                    DO:
                        ASSIGN log_nmdcampo = "esta no spc".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
                    
               IF   (crapass.inlbacen = 0 AND log_dslbacen = "S") OR
                    (crapass.inlbacen = 1 AND log_dslbacen = "N") THEN
                    DO:
                        ASSIGN log_nmdcampo = "esta no ccf".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.     
                    
               IF   crapass.flgrenli <> log_flgrenli   THEN
                    DO:
                       ASSIGN log_nmdcampo = "Renova Lim. Credito Aut.: ".

                       IF log_flgrenli THEN
                          ASSIGN log_nmdcampo = log_nmdcampo + "Sim".
                       ELSE
                          ASSIGN log_nmdcampo = log_nmdcampo + "Nao".

                       IF crapass.flgrenli THEN
                          ASSIGN log_nmdcampo = log_nmdcampo + " - Sim".
                       ELSE
                          ASSIGN log_nmdcampo = log_nmdcampo + " - Nao".

                       IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                            RUN atualiza_crapalt.
                    END.
                    
               /* ALTERACAO JEAN 27/10/2015 */
               IF crapass.idastcjt <> log_idastcjt   THEN
                 DO:
                   
                   ASSIGN log_nmdcampo = "exige ass.conj.".
    
                   IF NOT CAN-DO(crapalt.dsaltera,log_nmdcampo) THEN
                   DO:
                      RUN atualiza_crapalt.
                    END.
				 END.

            END. /* Fim da crapass */
            

       /* Verificacoes para o log da tela: CONTAS -> TELEFONES */
       IF   AVAILABLE craptfc   THEN
            DO:
               IF   log_cddopcao = "E"   THEN  /* Exclusao de telefone */
                    DO:
                        ASSIGN log_nmdcampo = "Exc.Telef." + 
                                              STRING(craptfc.nrtelefo) +
                                              " " + STRING(log_idseqttl) + ".ttl".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                                            
                        LEAVE.
                    END.        
            
               IF   craptfc.cdopetfn <> log_cdopetfn   THEN
                    DO:
                        log_nmdcampo = "Ope.Telef." + STRING(log_cdopetfn) +
                                       "-" + STRING(craptfc.cdopetfn) + 
                                       " " + STRING(log_idseqttl) + ".ttl".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
                    
               IF   craptfc.nrdddtfc <> log_nrdddtfc   THEN
                    DO:
                        log_nmdcampo = "DDD " + STRING(log_nrdddtfc) +
                                       "-" + STRING(craptfc.nrdddtfc) +
                                       " " + STRING(log_idseqttl) + ".ttl".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
                    
               IF   craptfc.nrtelefo <> log_nrtelefo   THEN
                    DO:
                        log_nmdcampo = "Telef." + STRING(log_nrtelefo) +
                                       "-" + STRING(craptfc.nrtelefo) +
                                       " " + STRING(log_idseqttl) + ".ttl".
                        log_flgrecad = TRUE.               
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
                    
               IF   craptfc.nrdramal <> log_nrdramal   THEN
                    DO:
                        log_nmdcampo = "Ramal " + STRING(log_nrdramal) +
                                       "-" + STRING(craptfc.nrdramal) +
                                       " " + STRING(log_idseqttl) + ".ttl".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
                    
               IF   craptfc.tptelefo <> log_tptelefo   THEN
                    DO:
                        log_nmdcampo = "Ident.Telef." + 
                                       STRING(log_tptelefo) +
                                       "-" + STRING(craptfc.tptelefo) +
                                       " " + STRING(log_idseqttl) + ".ttl".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
                    
               IF   craptfc.secpscto <> log_secpscto_tfc   THEN
                    DO:
                        log_nmdcampo = "Setor Telef." + 
                                       STRING(log_secpscto_tfc) +
                                       "-" + STRING(craptfc.secpscto) +
                                       " " + STRING(log_idseqttl) + ".ttl".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
                    
               IF   craptfc.nmpescto <> log_nmpescto_tfc   THEN
                    DO:
                        log_nmdcampo = "Contato Telef." + 
                                       STRING(log_nmpescto_tfc) +
                                       "-" + STRING(craptfc.nmpescto) +
                                       " " + STRING(log_idseqttl) + ".ttl".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
            END. /* Fim da craptfc */
    

       /* Verificacoes para o log da tela: CONTAS -> EMAILS */
       IF   AVAILABLE crapcem   THEN
            DO:
               IF   log_cddopcao = "E"   THEN  /* Exclusao de email */
                    DO:
                        log_nmdcampo = "Exc.Email " + 
                                       STRING(crapcem.dsdemail) +
                                       " " + STRING(log_idseqttl) + ".ttl".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                                            
                        LEAVE.
                    END.        
            
               IF   crapcem.dsdemail <> log_dsdemail   THEN
                    DO:
                        log_nmdcampo = "Email " + STRING(log_dsdemail) +
                                       "-" + STRING(crapcem.dsdemail) + 
                                       " " + STRING(log_idseqttl) + ".ttl".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
                    
               IF   crapcem.secpscto <> log_secpscto_cem   THEN
                    DO:
                        log_nmdcampo = "Setor Email " + 
                                       STRING(log_secpscto_cem) +
                                       "-" + STRING(crapcem.secpscto) + 
                                       " " + STRING(log_idseqttl) + ".ttl".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
                    
               IF   crapcem.nmpescto <> log_nmpescto_cem   THEN
                    DO:
                        log_nmdcampo = "Contato Email " +
                                       STRING(log_nmpescto_cem) +
                                       "-" + STRING(crapcem.nmpescto) + 
                                       " " + STRING(log_idseqttl) + ".ttl".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
            END. /* Fim da crapcem */
    

       /* Verificacoes para o log da tela: CONTAS -> ENDERECO */
       IF   AVAILABLE crapenc   THEN
            DO: 
                /* Exclusao somente do endereco cadastrado via InternetBank */
                IF   log_cddopcao = "E"  THEN
                     DO: 
                         ASSIGN log_nmdcampo = "exc.end." + 
                                               STRING(log_idseqttl) + ".ttl".
                          
                         IF   log_flencnet   THEN 
                              ASSIGN log_nmdcampo = log_nmdcampo + " NET".
    
                         IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                              RUN atualiza_crapalt.
                                            
                         LEAVE.
                     END.
    
                IF   crapenc.incasprp <> log_incasprp   THEN
                     DO:
                         ASSIGN log_nmdcampo = "imovel".
                         
                         IF   crapenc.tpendass = 9   THEN /* Comercial */
                              log_nmdcampo = log_nmdcampo + " com.".
                              
                         IF   crapass.inpessoa = 1   THEN
                              log_nmdcampo = log_nmdcampo + " " +
                                             STRING(log_idseqttl) + ".ttl".
    
                         IF   log_flencnet   THEN 
                              ASSIGN log_nmdcampo = log_nmdcampo + " NET".
                              
                         IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                              RUN atualiza_crapalt.
                     END.
    
                IF   crapenc.dtinires <> log_dtinires  THEN
                     DO:
                         ASSIGN log_nmdcampo = "tempo resid.".
    
                         IF   crapenc.tpendass = 9   THEN /* Comercial */
                              log_nmdcampo = log_nmdcampo + " com.".
    
                         IF   crapass.inpessoa = 1   THEN
                              log_nmdcampo = log_nmdcampo + " " +
                                             STRING(log_idseqttl) + ".ttl".
    
                         IF   log_flencnet   THEN 
                              ASSIGN log_nmdcampo = log_nmdcampo + " NET".
    
                         IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                              RUN atualiza_crapalt.
                     END.
                     
                IF   crapenc.vlalugue <> log_vlalugue   THEN
                     DO:
                         ASSIGN log_nmdcampo = "valor".
    
                         IF   crapenc.tpendass = 9   THEN /* Comercial */
                              log_nmdcampo = log_nmdcampo + " com.".
    
                         IF   crapass.inpessoa = 1   THEN
                              log_nmdcampo = log_nmdcampo + " " +
                                             STRING(log_idseqttl) + ".ttl".
    
                         IF   log_flencnet   THEN 
                              ASSIGN log_nmdcampo = log_nmdcampo + " NET".
    
                         IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                              RUN atualiza_crapalt.
                     END.
    
                IF   crapenc.nrcepend <> log_nrcepend   THEN
                     DO:
                         ASSIGN log_nmdcampo = "cep"
                                log_flgrecad = TRUE.
                                
                         IF   crapenc.tpendass = 9   THEN /* Comercial */
                              log_nmdcampo = log_nmdcampo + " com.".
    
                         IF   crapass.inpessoa = 1   THEN
                              log_nmdcampo = log_nmdcampo + " " +
                                             STRING(log_idseqttl) + ".ttl".
    
                         IF   log_flencnet   THEN 
                              ASSIGN log_nmdcampo = log_nmdcampo + " NET".
    
                         IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                              RUN atualiza_crapalt.
                     END.
                     
                IF   crapenc.dsendere <> log_dsendere   THEN
                     DO:
                         ASSIGN log_nmdcampo = "end.res."
                                log_flgrecad = TRUE.
    
                         IF   crapenc.tpendass = 9   THEN /* Comercial */
                              log_nmdcampo = log_nmdcampo + " com.".
    
                         IF   crapass.inpessoa = 1   THEN
                              log_nmdcampo = log_nmdcampo + " " +
                                             STRING(log_idseqttl) + ".ttl".
    
                         IF   log_flencnet   THEN 
                              ASSIGN log_nmdcampo = log_nmdcampo + " NET".
    
                         IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)    THEN
                              RUN atualiza_crapalt.
                     END.
                     
                IF   crapenc.nrendere <> log_nrendere   THEN
                     DO:
                         ASSIGN log_nmdcampo = "nr.end.".
    
                         IF   crapenc.tpendass = 9   THEN /* Comercial */
                              log_nmdcampo = log_nmdcampo + " com.".
    
                         IF   crapass.inpessoa = 1   THEN
                              log_nmdcampo = log_nmdcampo + " " +
                                             STRING(log_idseqttl) + ".ttl".
    
                         IF   log_flencnet   THEN 
                              ASSIGN log_nmdcampo = log_nmdcampo + " NET".
    
                         IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                              RUN atualiza_crapalt.
                     END.
                     
                IF   crapenc.complend <> log_complend   THEN
                     DO:
                         ASSIGN log_nmdcampo = "complem.".
    
                         IF   crapenc.tpendass = 9   THEN /* Comercial */
                              log_nmdcampo = log_nmdcampo + " com.".
    
                         IF   crapass.inpessoa = 1   THEN
                              log_nmdcampo = log_nmdcampo + " " +
                                             STRING(log_idseqttl) + ".ttl".
    
                         IF   log_flencnet   THEN 
                              ASSIGN log_nmdcampo = log_nmdcampo + " NET".
    
                         IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                              RUN atualiza_crapalt.
                     END.
                
                IF   crapenc.nrdoapto <> log_nrdoapto   THEN
                     DO:
                         ASSIGN log_nmdcampo = "apto.".
    
                         IF   crapenc.tpendass = 9   THEN /* Comercial */
                              log_nmdcampo = log_nmdcampo + " com.".
    
                         IF   crapass.inpessoa = 1   THEN
                              log_nmdcampo = log_nmdcampo + " " +
                                             STRING(log_idseqttl) + ".ttl".
    
                         IF   log_flencnet   THEN 
                              ASSIGN log_nmdcampo = log_nmdcampo + " NET".
    
                         IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                              RUN atualiza_crapalt.
                     END.

                IF   crapenc.cddbloco <> log_cddbloco   THEN
                     DO:
                         ASSIGN log_nmdcampo = "bloco.".
    
                         IF   crapenc.tpendass = 9   THEN /* Comercial */
                              log_nmdcampo = log_nmdcampo + " com.".
    
                         IF   crapass.inpessoa = 1   THEN
                              log_nmdcampo = log_nmdcampo + " " +
                                             STRING(log_idseqttl) + ".ttl".
    
                         IF   log_flencnet   THEN 
                              ASSIGN log_nmdcampo = log_nmdcampo + " NET".
    
                         IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                              RUN atualiza_crapalt.
                     END.

                IF   crapenc.nmbairro <> log_nmbairro   THEN
                     DO:
                         ASSIGN log_nmdcampo = "bairro"
                                log_flgrecad = TRUE.
                                
                         IF   crapenc.tpendass = 9   THEN /* Comercial */
                              log_nmdcampo = log_nmdcampo + " com.".
    
                         IF   crapass.inpessoa = 1   THEN
                              log_nmdcampo = log_nmdcampo + " " +
                                             STRING(log_idseqttl) + ".ttl".
    
                         IF   log_flencnet   THEN 
                              ASSIGN log_nmdcampo = log_nmdcampo + " NET".
    
                         IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                              RUN atualiza_crapalt.
                     END.
                     
                IF   crapenc.nmcidade <> log_nmcidade   THEN
                     DO:
                         ASSIGN log_nmdcampo = "cidade"
                                log_flgrecad = TRUE.
                                
                         IF   crapenc.tpendass = 9   THEN /* Comercial */
                              log_nmdcampo = log_nmdcampo + " com.".
    
                         IF   crapass.inpessoa = 1   THEN
                              log_nmdcampo = log_nmdcampo + " " +
                                             STRING(log_idseqttl) + ".ttl".
    
                         IF   log_flencnet   THEN 
                              ASSIGN log_nmdcampo = log_nmdcampo + " NET".
    
                         IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                              RUN atualiza_crapalt.
                     END.
                     
                IF   crapenc.cdufende <> log_cdufende   THEN
                     DO:
                         ASSIGN log_nmdcampo = "uf"
                                log_flgrecad = TRUE.
                                
                         IF   crapenc.tpendass = 9   THEN /* Comercial */
                              log_nmdcampo = log_nmdcampo + " com.".
    
                         IF   crapass.inpessoa = 1   THEN
                              log_nmdcampo = log_nmdcampo + " " +
                                             STRING(log_idseqttl) + ".ttl".
    
                         IF   log_flencnet   THEN 
                              ASSIGN log_nmdcampo = log_nmdcampo + " NET".
    
                         IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                              RUN atualiza_crapalt.
                     END.
                     
                IF   crapenc.nrcxapst <> log_nrcxapst   THEN
                     DO:
                         ASSIGN log_nmdcampo = "cxa.postal".
    
                         IF   crapenc.tpendass = 9   THEN /* Comercial */
                              log_nmdcampo = log_nmdcampo + " com.".
    
                         IF   crapass.inpessoa = 1   THEN
                              log_nmdcampo = log_nmdcampo + " " +
                                             STRING(log_idseqttl) + ".ttl".
    
                         IF   log_flencnet   THEN 
                              ASSIGN log_nmdcampo = log_nmdcampo + " NET".
    
                         IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                              RUN atualiza_crapalt.
                     END.     
    
                /* Se for atualizacao de endereco cadastrado no InternetBank,*/
                /* nao faz pergunta sobre recadastramento.                   */
                IF   log_flencnet   THEN
                     ASSIGN log_flgrecad = FALSE.
            END.
       

       /* Verificacoes para o log da tela: CONTAS -> IDENTIFICACAO (juridica)*/
       IF   AVAILABLE crapjur   THEN
            DO:
               IF   crapjur.nmfansia <> log_nmfansia   THEN
                    DO:
                        ASSIGN log_nmdcampo = "nome fantasia".
                               
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
                    
               IF   crapjur.natjurid <> log_natjurid   THEN
                    DO:
                        ASSIGN log_nmdcampo = "nat.jurid."
                               log_flgrecad = TRUE.
                               
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
                    
               IF   crapjur.qtfilial <> log_qtfilial   THEN
                    DO:
                        ASSIGN log_nmdcampo = "qtd.filiais".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
                    
               IF   crapjur.qtfuncio <> log_qtfuncio   THEN
                    DO:
                        ASSIGN log_nmdcampo = "qtd.funcionarios".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
                    
               IF   crapjur.dtiniatv <> log_dtiniatv   THEN
                    DO:
                        ASSIGN log_nmdcampo = "ini.ativ."
                               log_flgrecad = TRUE.
                               
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
                    
               IF   crapjur.cdseteco <> log_setecono   THEN
                    DO:
                        ASSIGN log_nmdcampo = "setor eco."
                               log_flgrecad = TRUE.
                                                   
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
               
               IF   crapjur.cdrmativ <> log_cdrmativ   THEN
                    DO:
                        ASSIGN log_nmdcampo = "ramo ativ."
                               log_flgrecad = TRUE.
                               
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
                    
               IF   crapjur.dsendweb <> log_dsendweb   THEN
                    DO:
                        ASSIGN log_nmdcampo = "site".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
                    
               IF   crapjur.nmtalttl <> log_nmtalttl_jur   THEN
                    DO:
                        ASSIGN log_nmdcampo = "nome talao".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
                    
                    
       /* Verificacoes para o log da tela: CONTAS -> REGISTRO (juridica) */
    
               IF   crapjur.nrinsest <> log_nrinsest   THEN
                    DO:
                        ASSIGN log_nmdcampo = "insc.estadual"
                               log_flgrecad = TRUE.
                               
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
                    
               IF   crapjur.vlfatano <> log_vlfatano   THEN
                    DO:
                        ASSIGN log_nmdcampo = "faturamento ano".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
               
               IF   crapjur.vlcaprea <> log_vlcaprea   THEN
                    DO:
                        ASSIGN log_nmdcampo = "capital realizado".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
                    
               IF   crapjur.dtregemp <> log_dtregemp   THEN
                    DO:
                        ASSIGN log_nmdcampo = "data registro"
                               log_flgrecad = TRUE.
                               
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
                    
               IF   crapjur.nrregemp <> log_nrregemp   THEN
                    DO:
                        ASSIGN log_nmdcampo = "nro.registro"
                               log_flgrecad = TRUE.
                               
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
                    
               IF   crapjur.orregemp <> log_orregemp   THEN
                    DO:
                        ASSIGN log_nmdcampo = "orgao registro"
                               log_flgrecad = TRUE.
                               
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
    
               IF   crapjur.dtinsnum <> log_dtinsnum   THEN
                    DO:
                        ASSIGN log_nmdcampo = "dt.insc.municip."
                               log_flgrecad = TRUE.
                               
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
    
               IF   crapjur.nrinsmun <> log_nrinsmun   THEN
                    DO:
                        ASSIGN log_nmdcampo = "nro.insc.municip."
                               log_flgrecad = TRUE.
                               
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
    
               IF   crapjur.flgrefis <> log_flgrefis   THEN
                    DO:
                        ASSIGN log_nmdcampo = "optante REFIS"
                               log_flgrecad = TRUE.
                               
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
    
               IF   crapjur.nrcdnire <> log_nrcdnire   THEN
                    DO:
                        ASSIGN log_nmdcampo = "NIRE"
                               log_flgrecad = TRUE.
                               
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
            END. /* Fim da crapjur */
           
            
       /* Verificacoes para o log da tela: CONTAS -> IDENTIFICACAO (fisica) */
       IF   AVAILABLE crapttl   THEN
            DO:
               IF   crapttl.dtcnscpf <> log_dtcnscpf   THEN
                    DO:
                        ASSIGN log_nmdcampo = "consulta cpf"
                               log_flgrecad = TRUE.
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
                    
               IF   crapttl.cdsitcpf <> log_cdsitcpf   THEN
                    DO:
    
                        ASSIGN log_nmdcampo = "situacao cpf"
                               log_flgrecad = TRUE.
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
                    
               IF   crapttl.tpdocttl <> log_tpdocttl   THEN
                    DO:
                        ASSIGN log_nmdcampo = "tipo doc.".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
               
               IF   crapttl.nrdocttl <> log_nrdocttl   THEN
                    DO:
                        ASSIGN log_nmdcampo = "doc.".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
               
               IF   crapttl.idorgexp <> log_idorgexp_ttl   THEN
                    DO:
                        ASSIGN log_nmdcampo = "org.ems.doc.".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
    
               IF   crapttl.cdufdttl <> log_cdufdttl   THEN
                    DO:
                        ASSIGN log_nmdcampo = "uf.ems.doc.".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
               
               IF   crapttl.dtemdttl <> log_dtemdttl   THEN
                    DO:
                        ASSIGN log_nmdcampo = "dt.ems.doc.".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
    
               IF   crapttl.dtnasttl <> log_dtnasttl   THEN
                    DO:
                        ASSIGN log_nmdcampo = "nascto".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
    
               IF   crapttl.cdsexotl <> log_cdsexotl   THEN
                    DO:
                        ASSIGN log_nmdcampo = "sexo".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
    
               IF   crapttl.tpnacion <> log_tpnacion   THEN
                    DO:
                        ASSIGN log_nmdcampo = "tipo nacion.".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
    
               IF   crapttl.cdnacion <> log_cdnacion   THEN
                    DO:
                        ASSIGN log_nmdcampo = "nacion.".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
                    
               IF   crapttl.dsnatura <> log_dsnatura   THEN
                    DO:
                        ASSIGN log_nmdcampo = "natural.".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.

               IF   crapttl.cdufnatu <> log_cdufnatu   THEN
                    DO:
                        ASSIGN log_nmdcampo = "uf natural.".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
                    
               IF   crapttl.inhabmen <> log_inhabmen   THEN
                    DO:
                        ASSIGN log_nmdcampo = "hab.menor".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
    
               IF   crapttl.dthabmen <> log_dthabmen   THEN
                    DO:
                        ASSIGN log_nmdcampo = "data hab.menor".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
    
               IF   crapttl.cdgraupr <> log_cdgraupr   THEN
                    DO:
                        ASSIGN log_nmdcampo = "parentesco".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
    
               IF   crapttl.cdestcvl <> log_cdestcvl   THEN
                    DO:
                        ASSIGN log_nmdcampo = "est.civil".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
               
               IF   crapttl.grescola <> log_grescola   THEN
                    DO:
                        ASSIGN log_nmdcampo = "escolaridade".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
               
               IF   crapttl.cdfrmttl <> log_cdfrmttl   THEN
                    DO:
                        ASSIGN log_nmdcampo = "formacao".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
    
               IF   crapttl.nmtalttl <> log_nmtalttl_ttl   THEN
                    DO:
                        ASSIGN log_nmdcampo = "nome talao".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
    
       /* Verificacoes para o log da tela: CONTAS -> COMERCIAL */
               IF   crapttl.cdnatopc <> log_cdnatopc_ttl   THEN
                    DO:
                        ASSIGN log_nmdcampo = "nat.ocupacao " +
                                              STRING(log_idseqttl) + ".ttl".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
    
               IF   crapttl.cdocpttl <> log_cdocpttl_tll   THEN
                    DO:
                        ASSIGN log_nmdcampo = "ocupacao " + 
                                              STRING(log_idseqttl) + ".ttl".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
    
               IF   crapttl.tpcttrab <> log_tpcttrab_ttl   THEN
                    DO:
                        ASSIGN log_nmdcampo = "tp.ctr.trab " + 
                                              STRING(log_idseqttl) + ".ttl".
                                              
                        IF    crapttl.tpcttrab = 3 THEN  /* Sem Vinculo */
                              log_flgrecad = FALSE.
                        ELSE
                              log_flgrecad = TRUE.
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
    
               IF   crapttl.cdempres <> log_cdempres       THEN
                    DO:
                        log_nmdcampo = "empr." + 
                                       STRING(log_cdempres,"99999") +
                                       "-" +
                                       STRING(crapttl.cdempres,"99999") + 
                                       " " +
                                       STRING(log_idseqttl) + ".ttl".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
    
               IF   crapttl.nmextemp <> log_nmextemp_ttl   THEN
                    DO:
                        ASSIGN log_nmdcampo = "nome empresa " +
                                              STRING(log_idseqttl) + ".ttl".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
    
               IF   crapttl.nrcpfemp <> log_nrcpfemp_ttl   THEN
                    DO:
                        ASSIGN log_nmdcampo = "cnpj empresa " + 
                                              STRING(log_idseqttl) + ".ttl".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
    
               IF   crapttl.dsproftl <> log_dsproftl_ttl   THEN
                    DO:
                        ASSIGN log_nmdcampo = "funcao " +
                                              STRING(log_idseqttl) + ".ttl".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
    
               IF   crapttl.cdnvlcgo <> log_cdnvlcgo_ttl   THEN
                    DO:
                        ASSIGN log_nmdcampo = "nivel cargo " + 
                                              STRING(log_idseqttl) + ".ttl".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
    
               IF   crapttl.nrcadast <> log_nrcadast       THEN
                    DO:
                        ASSIGN log_nmdcampo = "cadastro " + 
                                              STRING(log_idseqttl) + ".ttl".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
    
               IF   crapttl.cdturnos <> log_cdturnos_ttl   THEN
                    DO:
                        ASSIGN log_nmdcampo = "turno " + 
                                              STRING(log_idseqttl) + ".ttl".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
    
               IF   crapttl.dtadmemp <> log_dtadmemp_ttl   THEN
                    DO:
                        ASSIGN log_nmdcampo = "adm.empr. " + 
                                              STRING(log_idseqttl) + ".ttl".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
    
               IF   crapttl.vlsalari <> log_vlsalari_ttl   THEN
                    DO:
                        ASSIGN log_nmdcampo = "salario " +
                                              STRING(log_idseqttl) + ".ttl".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
    
               IF   crapttl.tpdrendi[1] <> log_cdtipren[1]   OR
                    crapttl.tpdrendi[2] <> log_cdtipren[2]   OR
                    crapttl.tpdrendi[3] <> log_cdtipren[3]   OR
                    crapttl.tpdrendi[4] <> log_cdtipren[4]   THEN
                    DO:
                        ASSIGN log_nmdcampo = "tip.ren. " + 
                                              STRING(log_idseqttl) + ".ttl".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
    
               IF   crapttl.vldrendi[1] <> log_vlrendim[1]   OR
                    crapttl.vldrendi[2] <> log_vlrendim[2]   OR
                    crapttl.vldrendi[3] <> log_vlrendim[3]   OR
                    crapttl.vldrendi[4] <> log_vlrendim[4]   THEN
                    DO:
                        ASSIGN log_nmdcampo = "valor ren. " +
                                              STRING(log_idseqttl) + ".ttl".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
    
               IF   crapttl.dsjusren <> log_dsjusren   THEN
                    DO:
                        ASSIGN log_nmdcampo = "justificativa rend. " +
                                              STRING(log_idseqttl) + ".ttl".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                   
                    END.

               /* Verificacoes para o log da tela: CONTAS -> INF. CADASTRAL */
               IF   crapttl.nrinfcad <> log_nrinfcad   THEN
                    DO:
                        ASSIGN log_nmdcampo = "inf.cadastral " +
                                              STRING(log_idseqttl) + ".ttl".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
                
               IF   crapttl.nrpatlvr <> log_nrpatlvr   THEN
                    DO:
                        ASSIGN log_nmdcampo = "patr.livre " +
                                              STRING(log_idseqttl) + ".ttl".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.

               IF   crapttl.inpolexp <> log_inpolexp   THEN
                    DO:
                        ASSIGN log_nmdcampo = "P. politicamente exposta " + 
                                              STRING(log_idseqttl) + ".ttl".

                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.                
                    END.
        
       END. /* Fim da crapttl */
            
       
       /* Verificacoes para o log da tela: CONTAS -> REFERENCIAS (JURIDICA)
                                           CONTAS -> CONTATOS (FISICA) */
       IF   AVAILABLE crapavt   THEN
            DO:
                /* REFERENCIAS (JURIDICA) E CONTATOS (FISICA)*/
                IF   crapavt.tpctrato = 5   THEN
                     DO:
                         IF   log_cddopcao = "E"   THEN  /* Exclusao */
                              DO:
                                  IF   crapass.inpessoa = 1  THEN
                                       log_nmdcampo = "Exc.Contato " +
                                           (IF  log_nrdctato <> 0  THEN
                                                TRIM(STRING(log_nrdctato,
                                                       "zzzz,zzz,9"))
                                            ELSE
                                                ENTRY(1,log_nmdavali," ")) +
                                            " " + STRING(log_idseqttl) + ".ttl".
                                  ELSE
                                       log_nmdcampo = "Exc.Ref." + 
                                            (IF  log_nrdctato <> 0  THEN
                                                TRIM(STRING(log_nrdctato,
                                                       "zzzz,zzz,9"))
                                            ELSE
                                                ENTRY(1,log_nmdavali," ")). 
                                  
                                  IF  NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)
                                      THEN
                                      RUN atualiza_crapalt.
    
                                  LEAVE.
                              END.
                         
                         IF   crapavt.nmdavali <> log_nmdavali   THEN
                              DO:
                                  IF   crapass.inpessoa = 1  THEN
                                       ASSIGN log_nmdcampo = "nome contato".
                                  ELSE
                                       ASSIGN log_nmdcampo = "nome ref.".
                                    
                                  IF  NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)
                                      THEN
                                      RUN atualiza_crapalt.
                              END.
                    
                         IF   crapavt.nmextemp <> log_nmextemp   THEN
                              DO:
                                  ASSIGN log_nmdcampo = "empresa ref.".
    
                                  IF  NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)
                                      THEN
                                      RUN atualiza_crapalt.
                              END.
    
                         IF   crapavt.cddbanco <> log_cddbanco   THEN
                              DO:
                                  ASSIGN log_nmdcampo = "banco ref.".
    
                                  IF  NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)
                                      THEN
                                      RUN atualiza_crapalt.
                              END.
            
                         IF   crapavt.cdagenci <> log_cdagenci   THEN
                              DO:
                                  ASSIGN log_nmdcampo = "age.ref.".
    
                                  IF  NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)
                                      THEN
                                      RUN atualiza_crapalt.
                              END.
                    
                         IF   crapavt.dsproftl <> log_dsproftl   THEN
                              DO:
                                  ASSIGN log_nmdcampo = "profis.ref.".
    
                                  IF  NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)
                                      THEN
                                      RUN atualiza_crapalt.
                              END.
                       
                         IF   crapavt.nrcepend <> log_cepender   THEN
                              DO:
                                  IF   crapass.inpessoa = 1  THEN
                                       ASSIGN log_nmdcampo = "cep contato".
                                  ELSE
                                       ASSIGN log_nmdcampo = "cep ref."
                                              log_flgrecad = TRUE.
                                    
                                  IF  NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)
                                      THEN
                                      RUN atualiza_crapalt.
                              END.
                       
                         IF   crapavt.dsendres[1] <> log_endereco[1]   THEN
                              DO:
                                  IF   crapass.inpessoa = 1  THEN
                                       ASSIGN log_nmdcampo = "end.contato".
                                  ELSE
                                       ASSIGN log_nmdcampo = "end.ref."
                                              log_flgrecad = TRUE.
                                   
                                  IF  NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)
                                      THEN
                                      RUN atualiza_crapalt.
                              END.
                            
                         IF   crapavt.nrendere <> log_numender   THEN
                              DO:
                                  IF   crapass.inpessoa = 1  THEN
                                       ASSIGN log_nmdcampo = "nro.contato".
                                  ELSE
                                       ASSIGN log_nmdcampo = "nro.ref.".
    
                                  IF  NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)
                                      THEN
                                      RUN atualiza_crapalt.
                              END.
                            
                         IF   crapavt.complend <> log_compleme   THEN
                              DO:
                                  IF   crapass.inpessoa = 1  THEN
                                       ASSIGN log_nmdcampo = "complem.contato".
                                  ELSE
                                       ASSIGN log_nmdcampo = "complem.ref.".
    
                                  IF  NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)
                                      THEN
                                      RUN atualiza_crapalt.
                              END.
                    
                         IF   crapavt.nmbairro <> log_dsbairro   THEN
                              DO:
                                  IF   crapass.inpessoa = 1  THEN
                                       ASSIGN log_nmdcampo = "bairro contato".
                                  ELSE
                                       ASSIGN log_nmdcampo = "bairro ref."
                                              log_flgrecad = TRUE.
                                    
                                  IF  NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)
                                      THEN
                                      RUN atualiza_crapalt.
                              END. 
    
                         IF   crapavt.nmcidade <> log_dscidade   THEN
                              DO:
                                  IF   crapass.inpessoa = 1  THEN
                                       ASSIGN log_nmdcampo = "cidade contato".
                                  ELSE
                                       ASSIGN log_nmdcampo = "cidade ref."
                                              log_flgrecad = TRUE.
                                    
                                  IF  NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)
                                      THEN
                                      RUN atualiza_crapalt.
                              END.
    
                         IF   crapavt.cdufresd <> log_sigladuf   THEN
                              DO:
                                  IF   crapass.inpessoa = 1  THEN
                                       ASSIGN log_nmdcampo = "uf contato".
                                  ELSE
                                       ASSIGN log_nmdcampo = "uf ref."
                                              log_flgrecad = TRUE.
                                    
                                  IF  NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)
                                      THEN
                                      RUN atualiza_crapalt.
                              END.
     
                         IF   crapavt.nrcxapst <> log_caixapst   THEN
                              DO:
                                  IF   crapass.inpessoa = 1  THEN
                                       ASSIGN log_nmdcampo = "cxa.pst.contato".
                                  ELSE
                                       ASSIGN log_nmdcampo = "cxa.pst.ref.".
    
                                  IF  NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)
                                      THEN
                                      RUN atualiza_crapalt.
                              END.
                    
                         IF   crapavt.nrtelefo <> log_telefone   THEN
                              DO:
                                  IF   crapass.inpessoa = 1  THEN
                                       ASSIGN log_nmdcampo = "fone contato".
                                  ELSE
                                       ASSIGN log_nmdcampo = "fone ref.".
    
                                  IF  NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)
                                      THEN
                                      RUN atualiza_crapalt.
                              END.
                     
                         IF   crapavt.dsdemail <> log_endemail   THEN
                              DO:
                                  IF   crapass.inpessoa = 1  THEN
                                       ASSIGN log_nmdcampo = "email contato".
                                  ELSE
                                       ASSIGN log_nmdcampo = "email ref.".
    
                                  IF  NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)
                                      THEN
                                      RUN atualiza_crapalt.
                              END.
                     END. /* Fim tipo 5 */
                
                
            END. /* Fim crapavt */
       
            
       /*Verificacoes para o log da tela: CONTAS -> RESPONSAVEL LEGAL(fisica)*/
       IF AVAIL crapcrl THEN
          DO: 
             IF log_cddopcao = "E"   THEN  /* Exclusao */
                DO:
                    log_nmdcampo = "Exc.Resp. " +
                              (IF  log_nrdconta <> 0  THEN
                                   TRIM(STRING(log_nrdconta_crl,
                                               "zzzz,zzz,9"))
                               ELSE
                                   ENTRY(1,log_nmrespon_crl," ")) +
                               " " + STRING(log_idseqmen_crl) + 
                               ".ttl". 
    
                    IF  NOT CAN-DO(crapalt.dsaltera,log_nmdcampo) THEN
                        RUN atualiza_crapalt.
                    LEAVE.
                END.
             
             IF crapcrl.cdcooper <> log_cdcooper_crl   THEN
                DO:
                    ASSIGN log_nmdcampo = "cooperativa " +
                                          STRING(log_idseqmen_crl) +
                                          ".ttl".
                      
                    IF  NOT CAN-DO(crapalt.dsaltera,log_nmdcampo) THEN
                        RUN atualiza_crapalt.
                END.
             
             IF crapcrl.nrctamen <> log_nrctamen_crl   THEN
                DO:
                    ASSIGN log_nmdcampo = "conta tit/proc. " +
                                          STRING(log_idseqmen_crl) +
                                          ".ttl".
                      
                    IF  NOT CAN-DO(crapalt.dsaltera,log_nmdcampo) THEN
                        RUN atualiza_crapalt.
                END.
             
             IF crapcrl.nrcpfmen <> log_nrcpfmen_crl   THEN
                DO:
                    ASSIGN log_nmdcampo = "cpf tit/proc. " +
                                          STRING(log_idseqmen_crl) +
                                          ".ttl".
                      
                    IF  NOT CAN-DO(crapalt.dsaltera,log_nmdcampo) THEN
                        RUN atualiza_crapalt.
                END.
            
             IF crapcrl.idseqmen <> log_idseqmen_crl   THEN
                DO:
                    ASSIGN log_nmdcampo = "sequencial tit/proc. " +
                                          STRING(log_idseqmen_crl) +
                                          ".ttl".
                      
                    IF  NOT CAN-DO(crapalt.dsaltera,log_nmdcampo) THEN
                        RUN atualiza_crapalt.
                END.
        
             IF crapcrl.nrdconta <> log_nrdconta_crl   THEN
                DO:
                    ASSIGN log_nmdcampo = "conta resp. " +
                                         STRING(log_idseqmen_crl) +
                                         ".ttl".
                     
                    IF  NOT CAN-DO(crapalt.dsaltera,log_nmdcampo) THEN
                        RUN atualiza_crapalt.
                END.

             IF crapcrl.nrcpfcgc <> log_nrcpfcgc_crl   THEN
                DO:
                   ASSIGN log_nmdcampo = "cpf resp. " +
                                         STRING(log_idseqmen_crl) +
                                         ".ttl".
                     
                   IF  NOT CAN-DO(crapalt.dsaltera,log_nmdcampo) THEN
                       RUN atualiza_crapalt.
                END.

             IF crapcrl.nmrespon <> log_nmrespon_crl   THEN
                DO:
                   ASSIGN log_nmdcampo = "nome resp. " +
                                         STRING(log_idseqmen_crl) +
                                         ".ttl".
                     
                   IF  NOT CAN-DO(crapalt.dsaltera,log_nmdcampo) THEN
                       RUN atualiza_crapalt.
                END.

             IF crapcrl.nridenti <> log_nridenti_crl   THEN
                DO:
                   ASSIGN log_nmdcampo = "identidade. " +
                                         STRING(log_idseqmen_crl) +
                                         ".ttl".
                     
                   IF  NOT CAN-DO(crapalt.dsaltera,log_nmdcampo) THEN
                       RUN atualiza_crapalt.
                END.

             IF crapcrl.tpdeiden <> log_tpdeiden_crl   THEN
                DO:
                   ASSIGN log_nmdcampo = "tipo doc. " +
                                         STRING(log_idseqmen_crl) +
                                         ".ttl".
                     
                   IF  NOT CAN-DO(crapalt.dsaltera,log_nmdcampo) THEN
                       RUN atualiza_crapalt.
                END.

             IF crapcrl.idorgexp <> log_idorgexp_crl   THEN
                DO:
                   ASSIGN log_nmdcampo = "org emi doc. " +
                                         STRING(log_idseqmen_crl) +
                                         ".ttl".
                     
                   IF  NOT CAN-DO(crapalt.dsaltera,log_nmdcampo) THEN
                       RUN atualiza_crapalt.
                END.

             IF crapcrl.cdufiden <> log_cdufiden_crl   THEN
                DO:
                   ASSIGN log_nmdcampo = "uf doc. " +
                                         STRING(log_idseqmen_crl) +
                                         ".ttl".
                     
                   IF  NOT CAN-DO(crapalt.dsaltera,log_nmdcampo) THEN
                       RUN atualiza_crapalt.
                END.

             IF crapcrl.dtemiden <> log_dtemiden_crl   THEN
                DO:
                   ASSIGN log_nmdcampo = "data emissao doc. " +
                                         STRING(log_idseqmen_crl) +
                                         ".ttl".
                     
                   IF  NOT CAN-DO(crapalt.dsaltera,log_nmdcampo) THEN
                       RUN atualiza_crapalt.

                END.
                
             IF crapcrl.dtnascin <> log_dtnascin_crl   THEN
                DO:
                   ASSIGN log_nmdcampo = "data nascimento. " +
                                         STRING(log_idseqmen_crl) +
                                         ".ttl".
                     
                   IF  NOT CAN-DO(crapalt.dsaltera,log_nmdcampo) THEN
                       RUN atualiza_crapalt.

                END.

             IF crapcrl.cddosexo <> log_cddosexo_crl   THEN
                DO:
                   ASSIGN log_nmdcampo = "sexo. " +
                                         STRING(log_idseqmen_crl) +
                                         ".ttl".
                     
                   IF  NOT CAN-DO(crapalt.dsaltera,log_nmdcampo) THEN
                       RUN atualiza_crapalt.

                END.

             IF crapcrl.cdestciv <> log_cdestciv_crl   THEN
                DO:
                   ASSIGN log_nmdcampo = "estado civil. " +
                                         STRING(log_idseqmen_crl) +
                                         ".ttl".
                     
                   IF  NOT CAN-DO(crapalt.dsaltera,log_nmdcampo) THEN
                       RUN atualiza_crapalt.

                END.

             IF crapcrl.cdnacion <> log_cdnacion_crl   THEN
                DO:
                   ASSIGN log_nmdcampo = "nacionalidade. " +
                                         STRING(log_idseqmen_crl) +
                                         ".ttl".
                     
                   IF  NOT CAN-DO(crapalt.dsaltera,log_nmdcampo) THEN
                       RUN atualiza_crapalt.

                END.

             IF crapcrl.dsnatura <> log_dsnatura_crl   THEN
                DO:
                   ASSIGN log_nmdcampo = "naturalidade. " +
                                         STRING(log_idseqmen_crl) +
                                         ".ttl".
                     
                   IF  NOT CAN-DO(crapalt.dsaltera,log_nmdcampo) THEN
                       RUN atualiza_crapalt.
                
                END.

             IF crapcrl.cdcepres <> log_cdcepres_crl   THEN
                DO:
                   ASSIGN log_nmdcampo = "cep residencial. " +
                                         STRING(log_idseqmen_crl) +
                                         ".ttl".
                     
                   IF  NOT CAN-DO(crapalt.dsaltera,log_nmdcampo) THEN
                       RUN atualiza_crapalt.
                
                END.

             IF crapcrl.dsendres <> log_dsendres_crl   THEN
                DO:
                   ASSIGN log_nmdcampo = "endreco residencial. " +
                                         STRING(log_idseqmen_crl) +
                                         ".ttl".
                     
                   IF  NOT CAN-DO(crapalt.dsaltera,log_nmdcampo) THEN
                       RUN atualiza_crapalt.

                END.

             IF crapcrl.nrendres <> log_nrendres_crl   THEN
                DO:
                   ASSIGN log_nmdcampo = "numero residencial. " +
                                         STRING(log_idseqmen_crl) +
                                         ".ttl".
                     
                   IF  NOT CAN-DO(crapalt.dsaltera,log_nmdcampo) THEN
                       RUN atualiza_crapalt.

                END.


             IF crapcrl.dscomres <> log_dscomres_crl   THEN
                DO:
                   ASSIGN log_nmdcampo = "complemento residencial. " +
                                         STRING(log_idseqmen_crl) +
                                         ".ttl".
                     
                   IF  NOT CAN-DO(crapalt.dsaltera,log_nmdcampo) THEN
                       RUN atualiza_crapalt.

                END.

             IF crapcrl.dsbaires <> log_dsbaires_crl   THEN
                DO:
                   ASSIGN log_nmdcampo = "bairro. " +
                                         STRING(log_idseqmen_crl) +
                                         ".ttl".
                     
                   IF  NOT CAN-DO(crapalt.dsaltera,log_nmdcampo) THEN
                       RUN atualiza_crapalt.

                END.

             IF crapcrl.nrcxpost <> log_nrcxpost_crl   THEN
                DO:
                   ASSIGN log_nmdcampo = "caixa postal. " +
                                         STRING(log_idseqmen_crl) +
                                         ".ttl".
                     
                   IF  NOT CAN-DO(crapalt.dsaltera,log_nmdcampo) THEN
                       RUN atualiza_crapalt.

                END.

             IF crapcrl.dscidres <> log_dscidres_crl   THEN
                DO:
                   ASSIGN log_nmdcampo = "cidade. " +
                                         STRING(log_idseqmen_crl) +
                                         ".ttl".
                     
                   IF  NOT CAN-DO(crapalt.dsaltera,log_nmdcampo) THEN
                       RUN atualiza_crapalt.

                END.

             IF crapcrl.dsdufres <> log_dsdufres_crl   THEN
                DO:
                   ASSIGN log_nmdcampo = "uf. " +
                                         STRING(log_idseqmen_crl) +
                                         ".ttl".
                     
                   IF  NOT CAN-DO(crapalt.dsaltera,log_nmdcampo) THEN
                       RUN atualiza_crapalt.

                END.

             IF crapcrl.nmpairsp <> log_nmpairsp_crl   THEN
                DO:
                   ASSIGN log_nmdcampo = "nome pai. " +
                                         STRING(log_idseqmen_crl) +
                                         ".ttl".
                     
                   IF  NOT CAN-DO(crapalt.dsaltera,log_nmdcampo) THEN
                       RUN atualiza_crapalt.

                END.

             IF crapcrl.nmmaersp <> log_nmmaersp_crl   THEN
                DO:
                   ASSIGN log_nmdcampo = "nome mae. " +
                                         STRING(log_idseqmen_crl) +
                                         ".ttl".
                     
                   IF  NOT CAN-DO(crapalt.dsaltera,log_nmdcampo) THEN
                       RUN atualiza_crapalt.

                END.

          
          END. /* Fim crapcrl*/


       /* Verificacoes para o log da tela: CONTAS -> CONJUGE (fisica) */
       IF   AVAILABLE crapcje   THEN
           IF (log_nrctacje <> 0 OR
               log_nmconjug <> " ") THEN /* Chamado 305924 (Heitor - RKAM) */
            DO:
               IF   crapcje.nrctacje <> log_nrctacje   THEN
                    DO:
                        ASSIGN log_nmdcampo = "conta cje".
               
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
               IF   crapcje.nmconjug <> log_nmconjug   THEN
                    DO:
                        ASSIGN log_nmdcampo = "nome cje".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
                    
               IF   crapcje.nrcpfcjg <> log_nrcpfcjg   THEN
                    DO:
                        ASSIGN log_nmdcampo = "nro cpf cje".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
             
               IF   crapcje.dtnasccj <> log_dtnasccj   THEN
                    DO:
                        ASSIGN log_nmdcampo = "nasc. cje".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
               
               IF   crapcje.tpdoccje <> log_tpdoccje   THEN
                    DO:
                        ASSIGN log_nmdcampo = "tipo doc.cje".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
                    
               IF   crapcje.nrdoccje <> log_nrdoccje   THEN
                    DO:
                        ASSIGN log_nmdcampo = "nro doc.cje".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
             
               IF   crapcje.idorgexp <> log_idorgexp_cje   THEN
                    DO:
                        ASSIGN log_nmdcampo = "org.emiss.cje".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
               
               
               IF   crapcje.cdufdcje <> log_cdufdcje   THEN
                    DO:
                        ASSIGN log_nmdcampo = "UF cje".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
                    
               IF   crapcje.dtemdcje <> log_dtemdcje   THEN
                    DO:
                        ASSIGN log_nmdcampo = "dt.emiss.doc.cje".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
             
               IF   crapcje.grescola <> log_gresccjg    THEN
                    DO:
                        ASSIGN log_nmdcampo = "grau escolar cje".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
               
               IF   crapcje.cdfrmttl <> log_cdfrmcje   THEN
                    DO:
                        ASSIGN log_nmdcampo = "formacao cje".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
                    
               IF   crapcje.cdnatopc <> log_cdnatopc   THEN
                    DO:
                        ASSIGN log_nmdcampo = "natural.cje".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
             
               IF   crapcje.cdocpcje <> log_cdocpttl   THEN
                    DO:
                        ASSIGN log_nmdcampo = "ocup.cje".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
        
    
               IF   crapcje.tpcttrab <> log_tpcttrab   THEN
                    DO:
                        ASSIGN log_nmdcampo = "ctrato trab.cje".
    
                        IF    crapcje.tpcttrab = 3 THEN  /* Sem Vinculo */
                              log_flgrecad = FALSE.
                        ELSE
                              log_flgrecad = TRUE.
                        
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
                    
               IF   crapcje.nmextemp <> log_nmempcje   THEN
                    DO:
                        ASSIGN log_nmdcampo = "empresa cje".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
             
               IF   crapcje.nrdocnpj <> log_nrcpfemp   THEN
                    DO:
                        ASSIGN log_nmdcampo = "CNPJ empr.cje".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
               
               IF   crapcje.dsproftl <> log_dsprocje   THEN
                    DO:
                        ASSIGN log_nmdcampo = "funcao cje".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
                    
               IF   crapcje.cdnvlcgo <> log_cdnvlcgo   THEN
                    DO:
                        ASSIGN log_nmdcampo = "nvl cargo cje".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
             
               IF   crapcje.nrfonemp <> log_nrfonemp   THEN
                    DO:
                        ASSIGN log_nmdcampo = "fone empr.cje".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
    
               IF   crapcje.nrramemp <> log_nrramemp   THEN
                    DO:
                        ASSIGN log_nmdcampo = "ramal empr.cje".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
               
               IF   crapcje.cdturnos <> log_cdturnos   THEN
                    DO:
                        ASSIGN log_nmdcampo = "turno cje".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
                    
               IF   crapcje.dtadmemp <> log_dtadmemp   THEN
                    DO:
                        ASSIGN log_nmdcampo = "dt admiss.cje".
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
             
               IF   crapcje.vlsalari <> log_vlsalari   THEN
                    DO:
                        ASSIGN log_nmdcampo = "sal. cje".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
            END.   /* Fim conjuge*/
    
            
       /* Verificacoes para o log da tela: CONTAS -> DEPENDENTES */
       IF   AVAILABLE crapdep   THEN
            DO:
               IF   log_cddopcao = "E"   THEN  /* Exclusao de dependente */
                    DO:
                        ASSIGN log_nmdcampo = "Exc.dep." +
                                              ENTRY(1,crapdep.nmdepend," ") +
                                              " " + STRING(log_idseqttl) + ".ttl".
                                              
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
               
               IF   crapdep.dtnascto <> log_dtnascim   THEN
                    DO:
                        ASSIGN log_nmdcampo = "dt.nasc.".
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
                    
               IF   crapdep.tpdepen <> log_cdtipdep   THEN
                    DO:
                        ASSIGN log_nmdcampo = "tp.dep." + 
                                              STRING(log_cdtipdep) + 
                                              "-" + STRING(crapdep.tpdepen).
    
                        IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.
                    END.
    
            END.
            
       /* Log dos bens do cooperado */
       IF   AVAILABLE crapbem   THEN
            DO:

                IF   log_cddopcao = "E"   THEN
                     DO:
                         ASSIGN log_nmdcampo = " [" + log_nmdatela + "] "  +
                                               "Exc. do bem " + 
                                               crapbem.dsrelbem +
                                               " " + STRING(log_idseqttl) + 
                                               ".ttl ".
    
                         IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                              RUN atualiza_crapalt.
                     END.
            
                IF   crapbem.dsrelbem <> log_dsrelbem   THEN
                     DO:

                         ASSIGN log_nmdcampo = " [" + log_nmdatela + "] "  +
                                               "Alt. descricao do bem "   + 
                                               crapbem.dsrelbem           +
                                               " " + STRING(log_idseqttl) + 
                                               ".ttl ".

                         IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                              RUN atualiza_crapalt.
                     END.
    
                IF   crapbem.persemon <> log_persemon   THEN    
                     DO:
                         log_nmdcampo = " [" + log_nmdatela + "] "   +
                                        "Alt. " + crapbem.dsrelbem + ": "  +
                                        "Percentual s/ onus"               + 
                                        " - "                              +
                                        STRING(crapbem.persemon,"zz9.99" ) + 
                                        " "                                +
                                        STRING(log_idseqttl) + ".ttl ".
                                                
                         IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                              RUN atualiza_crapalt.
                     END.
                     
                IF   crapbem.qtprebem <> log_qtprebem   THEN
                     DO:
                         ASSIGN log_nmdcampo = " [" + log_nmdatela + "] "      +
                                               "Alt. " + crapbem.dsrelbem + ": " +
                                               "Parcelas "                    +
                                               " - "                          +
                                               STRING(crapbem.qtprebem,"zz9") +
                                               " "                            +
                                               STRING(log_idseqttl) + ".ttl ".
                         
                         IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                              RUN atualiza_crapalt.
    
                     END.
    
                IF   crapbem.vlprebem <> log_vlprebem   THEN
                     DO:                                       
                         log_nmdcampo = " [" + log_nmdatela + "] "   +
                                        "Alt. " + crapbem.dsrelbem + ": "  +
                                        "Valor Parcela "                   +
                                        " - "                              +
                                        STRING(crapbem.vlprebem,"zzz,zz9.99")
                                        + " "                              +
                                        STRING(log_idseqttl) + ".ttl ".
                        
                         IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                              RUN atualiza_crapalt.
                     
                     END.
    
                IF   crapbem.vlrdobem <> log_vlrdobem  THEN
                     DO:
                         log_nmdcampo = " [" + log_nmdatela + "] "   +
                                        "Alt. " + crapbem.dsrelbem + ": " +
                                        "Valor Bem "                      +
                                        " - "                             +
                                        STRING(crapbem.vlrdobem,
                                               "zzz,zzz,zz9.99") + " " +
                                        STRING(log_idseqttl) + ".ttl".
    
                         IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                              RUN atualiza_crapalt.
    
                     END.

            END.
        
            
       IF   AVAILABLE crapjfn   THEN
            DO:
                IF   crapjfn.perfatcl <> log_perfatcl   THEN
                     DO:
                         log_nmdcampo = "Concentracao faturamento unico " +
                                        "cliente 1.ttl".
    
                         IF   NOT CAN-DO (crapalt.dsaltera,log_nmdcampo)   THEN
                              RUN atualiza_crapalt.
    
                     END.
                
                /* Se alterado qualquer um desses loga alteracao 
                   de faturamento */
                DO aux_contador = 1 TO 12:
                
                    IF  crapjfn.mesftbru[aux_contador] <> 
                                    log_mesftbru[aux_contador]  OR
                        
                        crapjfn.anoftbru[aux_contador] <>
                                    log_anoftbru[aux_contador]  OR
                                    
                        crapjfn.vlrftbru[aux_contador] <>
                                    log_vlrftbru[aux_contador]  THEN
                                    
                        DO:
                            log_nmdcampo = "Faturamento medio bruto mensal " +
                                           "1.ttl".
                            
                            IF  NOT CAN-DO (crapalt.dsaltera,log_nmdcampo) THEN
                                RUN atualiza_crapalt.
    
                            LEAVE.
                            
                        END.
    
                END. /* Fim DO .. TO */
    
            END.  /* fim crapjfn */
      
   &ENDIF   /* {&TELA-CONTAS} */
   
   &IF DEFINED(TELA-MANTAL) <> 0 &THEN
    
        /****** LOG DAS ALTERACOES FEITAS PELA TELA MANTAL *******/
        IF  log_cddopcao <> "" AND
            log_nrdctabb <> 0  AND
            log_nrdocmto <> 0  THEN
            DO:
                IF  log_cddopcao = "B"  THEN
                    ASSIGN log_desopcao = "canc.chq.  ".
                ELSE
                    ASSIGN log_desopcao = "libr.chq.  ".

                ASSIGN log_nmdcampo = log_desopcao + 
                                    string(log_nrdocmto,"zzz,z99,9") +
                                    " cta base " +
                                    string(log_nrdctabb,"zzzz,zzz,9").

                IF  NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)THEN
                    DO:
                         /* corrigir o registro, pois este log exige que o 
                            tamanho dele seja 41 para mostrar correto na 
                            tela altera */ 
                         ASSIGN log_qtlinhas = LENGTH(crapalt.dsaltera) / 41
                                log_qtletras = log_qtlinhas * 41.
                         IF  log_qtletras < LENGTH(crapalt.dsaltera) THEN
                             ASSIGN log_qtlinhas = log_qtlinhas + 1
                                    log_qtletras = log_qtlinhas * 41.
                         IF  log_qtletras <> 0 THEN
                             ASSIGN 
                                SUBSTR(crapalt.dsaltera,log_qtletras,1) = ",". 
    
                         ASSIGN crapalt.dsaltera = crapalt.dsaltera + 
                                                  log_nmdcampo + ",".
                    END.

            END.
               
   &ENDIF /* {&TELA-MANTAL} */
   
    &IF DEFINED(TELA-CADSPC) <> 0 &THEN
    
        ASSIGN log_desopcao = "CADSPC="
               log_nmdcampo = "".

        IF  log_dtvencto <> crapspc.dtvencto THEN
            ASSIGN log_nmdcampo = log_desopcao + " Vencto " +
                                  STRING(log_dtvencto,"99/99/9999") + ","
                   log_desopcao = "".    

        IF  log_vldivida <> crapspc.vldivida THEN
            ASSIGN log_nmdcampo = log_nmdcampo + log_desopcao +
                                  " Valor Divida " +
                                  STRING(log_vldivida,"zzz,zz9.99") + ","
                   log_desopcao = "". 

        IF  log_dtinclus <> crapspc.dtinclus THEN
            ASSIGN log_nmdcampo = log_nmdcampo + log_desopcao +
                                  " Data Inclusao " +
                                  STRING(log_dtinclus,"99/99/9999") + ","
                   log_desopcao = "".   

        IF  log_dtdbaixa <> crapspc.dtdbaixa THEN
            ASSIGN log_nmdcampo = log_nmdcampo + log_desopcao +
                                  " Data Baixa " +
                                  STRING(log_dtdbaixa,"99/99/9999") + ","
                   log_desopcao = "".     

        IF  log_dsoberv1 <> crapspc.dsoberva THEN
            ASSIGN log_nmdcampo = log_nmdcampo + log_desopcao +
                                  " Obser.Inclusao " + log_dsoberv1 + ","
                   log_desopcao = "".    

        IF  log_dsoberv2 <> crapspc.dsobsbxa THEN
            ASSIGN log_nmdcampo = log_nmdcampo + log_desopcao + 
                                  " Obser.Baixa " + log_dsoberv2 + ","
                   log_desopcao = "".   

        ASSIGN  crapalt.dsaltera = crapalt.dsaltera + log_nmdcampo.
               
   &ENDIF /* {&TELA-CADSPC} */ 

   ASSIGN
       log_flaltera = YES
       log_msgrecad = "" /* mensagem para criacao do recadastramento */
       log_tpatlcad = 0  /* tipo de atualizacao do cadastro  */
       log_msgatcad = "" /* mensagem atualizacao do cadastro */
       log_chavealt = STRING(crapalt.cdcooper,"999")       + "," +
                      STRING(crapalt.nrdconta,"999999999") + "," + 
                      STRING(crapalt.dtaltera,"99/99/9999").

   IF  CAN-DO("ALTRAM,DESEXT,ACESSO",log_nmdatela) THEN
       DO:
          IF  crapalt.cdoperad = ""  THEN
              ASSIGN crapalt.cdoperad = log_cdoperad.
       END.
   ELSE
       ASSIGN crapalt.cdoperad = log_cdoperad.

   &IF DEFINED(TELA-MATRIC) <> 0 &THEN
   
       IF  log_dtaltera = ?   THEN
           DO:
              IF  CAN-DO("ACESSO,CONTA,MATRIC,DESEXT,ALTRAM",log_nmdatela) THEN
                  ASSIGN log_flaltera = NO.
              ELSE
                  DO:
                     FOR FIRST crapcri FIELDS(dscritic) 
                                       WHERE crapcri.cdcritic = 401 NO-LOCK:
                     END.
    
                     IF  AVAILABLE crapcri  THEN     
                         ASSIGN log_msgrecad = crapcri.dscritic.
                     ELSE
                         ASSIGN log_msgrecad = "".
    
                     /* sera atualizado na procedure 'proc_altcad' */
                     ASSIGN
                         log_tpaltera = 1
                         log_chavealt = log_chavealt + "," + 
                                        STRING(log_tpaltera,"9").
                  END.
           END.
       ELSE
           ASSIGN log_tpaltera = 2.

   &ENDIF

   IF  log_flgrecad AND log_flaltera THEN
       DO:
          FOR FIRST crapcri FIELDS(dscritic) 
                            WHERE crapcri.cdcritic = 402 NO-LOCK:
          END.

          IF  AVAILABLE crapcri  THEN     
              ASSIGN log_msgatcad = crapcri.dscritic.

          ASSIGN log_tpatlcad = 1.
       END.
   ELSE
   IF  log_flaltera     = YES    AND
       crapalt.tpaltera = 2      AND 
       log_nmdatela <> "MANTAL"  AND
       log_nmdatela <> "CADSPC" THEN
       DO:
          FOR FIRST crapcri FIELDS(dscritic) 
                            WHERE crapcri.cdcritic = 764 NO-LOCK:
          END.
    
          IF  AVAILABLE crapcri  THEN     
              ASSIGN log_msgatcad = crapcri.dscritic.

          ASSIGN log_tpatlcad = 2.
       END.
         
   /* Se criou o registro e nao teve alteracao */
   /*  IF   NEW crapalt*/ 
   IF  aux_flgnvalt THEN
       IF  crapalt.dsaltera = "" AND crapalt.tpaltera = 2 THEN
           UNDO LOG, LEAVE.
   
   LEAVE.

END. /* Fim do WHILE */

/** Liberar registro crapalt que estava em LOCK **/
IF  AVAILABLE crapalt  THEN
    FIND CURRENT crapalt NO-LOCK NO-ERROR.

/*...........................................................................*/


