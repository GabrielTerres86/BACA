/* .............................................................................

   Programa: includes/log_logcontas.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Abril/2006.                    Ultima atualizacao: 24/04/2017

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
               
               19/05/2011 - Substituicao do campo crapenc.nranores por 
                            crapenc.dtinires (data que o cooperado passou a
                            residir no endereco informado). Fabricio 
                            
               16/04/2012 - Incluido tratamento para a tabela crapcrl - Resp.
                            Legal (Adriano).                            

               20/09/2013 - Alteracao de PAC/P.A.C para PA. (James)
               
               11/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( André Euzébio / SUPERO) 

               24/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                crapass, crapttl, crapjur 
							(Adriano - P339).

.............................................................................*/ 

ASSIGN log_nmdcampo = ""
       log_tpaltera = 2 /* Por default fica como 2 */
       log_flgctitg = 3
       log_flgrecad = FALSE.
       
LOG:

DO WHILE TRUE ON ERROR UNDO LOG, LEAVE:

   DO WHILE TRUE:

      FIND crapalt WHERE crapalt.cdcooper = glb_cdcooper    AND
                         crapalt.nrdconta = tel_nrdconta    AND
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
                    ASSIGN crapalt.nrdconta = tel_nrdconta
                           crapalt.dtaltera = glb_dtmvtolt
                           crapalt.tpaltera = log_tpaltera
                           crapalt.dsaltera = ""
                           crapalt.cdcooper = glb_cdcooper.
                    VALIDATE crapalt.
                END.
           
      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */
   
   /* Se for conta integracao ativa, seta a flag para enviar ao BB */
   IF   crapass.nrdctitg <> ""   AND
        crapass.flgctitg = 2     THEN  /* Ativa */
        ASSIGN log_flgctitg = 0.
  
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
                
           IF   (crapass.inlbacen = 0    AND
                 tel_dslbacen     = "S") OR
                (crapass.inlbacen = 1    AND
                 tel_dslbacen     = "N") THEN           
                DO:
                    ASSIGN log_nmdcampo = "esta no ccf".

                    IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                         RUN atualiza_crapalt.
                END.     
                
        END. /* Fim da crapass */
        
   /* Verificacoes para o log da tela: CONTAS -> TELEFONES */
   IF   AVAILABLE craptfc   THEN
        DO:
           IF   glb_cddopcao = "E"   THEN  /* Exclusao de telefone */
                DO:
                    ASSIGN log_nmdcampo = "Exc.Telef." + 
                                          STRING(craptfc.nrtelefo) +
                                          " " + STRING(tel_idseqttl) + ".ttl".

                    IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                         RUN atualiza_crapalt.
                                        
                    LEAVE.
                END.        
        
           IF   craptfc.cdopetfn <> log_cdopetfn   THEN
                DO:
                    ASSIGN log_nmdcampo = "Ope.Telef." + STRING(log_cdopetfn) +
                                          "-" + STRING(craptfc.cdopetfn) + 
                                          " " + STRING(tel_idseqttl) + ".ttl".

                    IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                         RUN atualiza_crapalt.
                END.
                
           IF   craptfc.nrdddtfc <> log_nrdddtfc   THEN
                DO:
                    ASSIGN log_nmdcampo = "DDD " + STRING(log_nrdddtfc) +
                                          "-" + STRING(craptfc.nrdddtfc) +
                                          " " + STRING(tel_idseqttl) + ".ttl".

                    IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                         RUN atualiza_crapalt.
                END.
                
           IF   craptfc.nrtelefo <> log_nrtelefo   THEN
                DO:
                    ASSIGN log_nmdcampo = "Telef." + STRING(log_nrtelefo) +
                                          "-" + STRING(craptfc.nrtelefo) +
                                          " " + STRING(tel_idseqttl) + ".ttl"
                           log_flgrecad = TRUE.               

                    IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                         RUN atualiza_crapalt.
                END.
                
           IF   craptfc.nrdramal <> log_nrdramal   THEN
                DO:
                    ASSIGN log_nmdcampo = "Ramal " + STRING(log_nrdramal) +
                                          "-" + STRING(craptfc.nrdramal) +
                                          " " + STRING(tel_idseqttl) + ".ttl".

                    IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                         RUN atualiza_crapalt.
                END.
                
           IF   craptfc.tptelefo <> log_tptelefo   THEN
                DO:
                    ASSIGN log_nmdcampo = "Ident.Telef." + 
                                          STRING(log_tptelefo) +
                                          "-" + STRING(craptfc.tptelefo) +
                                          " " + STRING(tel_idseqttl) + ".ttl".

                    IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                         RUN atualiza_crapalt.
                END.
                
           IF   craptfc.secpscto <> log_secpscto_tfc   THEN
                DO:
                    ASSIGN log_nmdcampo = "Setor Telef." + 
                                          STRING(log_secpscto_tfc) +
                                          "-" + STRING(craptfc.secpscto) +
                                          " " + STRING(tel_idseqttl) + ".ttl".

                    IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                         RUN atualiza_crapalt.
                END.
                
           IF   craptfc.nmpescto <> log_nmpescto_tfc   THEN
                DO:
                    ASSIGN log_nmdcampo = "Contato Telef." + 
                                          STRING(log_nmpescto_tfc) +
                                          "-" + STRING(craptfc.nmpescto) +
                                          " " + STRING(tel_idseqttl) + ".ttl".

                    IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                         RUN atualiza_crapalt.
                END.
        END. /* Fim da craptfc */

        
   /* Verificacoes para o log da tela: CONTAS -> EMAILS */
   IF   AVAILABLE crapcem   THEN
        DO:
           IF   glb_cddopcao = "E"   THEN  /* Exclusao de email */
                DO:
                    ASSIGN log_nmdcampo = "Exc.Email " + 
                                          STRING(crapcem.dsdemail) +
                                          " " + STRING(tel_idseqttl) + ".ttl".

                    IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                         RUN atualiza_crapalt.
                                        
                    LEAVE.
                END.        
        
           IF   crapcem.dsdemail <> log_dsdemail   THEN
                DO:
                    ASSIGN log_nmdcampo = "Email " + STRING(log_dsdemail) +
                                          "-" + STRING(crapcem.dsdemail) + 
                                          " " + STRING(tel_idseqttl) + ".ttl".

                    IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                         RUN atualiza_crapalt.
                END.
                
           IF   crapcem.secpscto <> log_secpscto_cem   THEN
                DO:
                    ASSIGN log_nmdcampo = "Setor Email " + 
                                          STRING(log_secpscto_cem) +
                                          "-" + STRING(crapcem.secpscto) + 
                                          " " + STRING(tel_idseqttl) + ".ttl".

                    IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                         RUN atualiza_crapalt.
                END.
                
           IF   crapcem.nmpescto <> log_nmpescto_cem   THEN
                DO:
                    ASSIGN log_nmdcampo = "Contato Email " +
                                          STRING(log_nmpescto_cem) +
                                          "-" + STRING(crapcem.nmpescto) + 
                                          " " + STRING(tel_idseqttl) + ".ttl".

                    IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                         RUN atualiza_crapalt.
                END.
        END. /* Fim da crapcem */

   /* Verificacoes para o log da tela: CONTAS -> ENDERECO */
   IF   AVAILABLE crapenc   THEN
        DO:
            IF   crapenc.incasprp <> log_incasprp   THEN
                 DO:
                     ASSIGN log_nmdcampo = "imovel".
                     
                     IF   crapenc.tpendass = 9   THEN /* Comercial */
                          log_nmdcampo = log_nmdcampo + " com.".
                          
                     IF   crapass.inpessoa = 1   THEN
                          log_nmdcampo = log_nmdcampo + " " +
                                         STRING(tel_idseqttl) + ".ttl".
                          
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
                                         STRING(tel_idseqttl) + ".ttl".

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
                                         STRING(tel_idseqttl) + ".ttl".

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
                                         STRING(tel_idseqttl) + ".ttl".

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
                                         STRING(tel_idseqttl) + ".ttl".

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
                                         STRING(tel_idseqttl) + ".ttl".

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
                                         STRING(tel_idseqttl) + ".ttl".

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
                                         STRING(tel_idseqttl) + ".ttl".

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
                                         STRING(tel_idseqttl) + ".ttl".

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
                                         STRING(tel_idseqttl) + ".ttl".

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
                                         STRING(tel_idseqttl) + ".ttl".

                     IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                          RUN atualiza_crapalt.
                 END.     
        END.
   
   /* Verificacoes para o log da tela: CONTAS -> IDENTIFICACAO (juridica) */
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
           
           IF   crapttl.cdoedttl <> log_cdoedttl   THEN
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

           IF   crapttl.dsnacion <> log_dsnacion   THEN
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
                                          STRING(tel_idseqttl) + ".ttl".

                    IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                         RUN atualiza_crapalt.
                END.

           IF   crapttl.cdocpttl <> log_cdocpttl_tll   THEN
                DO:
                    ASSIGN log_nmdcampo = "ocupacao " + STRING(tel_idseqttl) +
                                          ".ttl".

                    IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                         RUN atualiza_crapalt.
                END.

           IF   crapttl.tpcttrab <> log_tpcttrab_ttl   THEN
                DO:
                    ASSIGN log_nmdcampo = "tp.ctr.trab " + 
                                          STRING(tel_idseqttl) + ".ttl".
                                          
                    IF    crapttl.tpcttrab = 3 THEN  /* Sem Vinculo */
                          log_flgrecad = FALSE.
                    ELSE
                          log_flgrecad = TRUE.

                    IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                         RUN atualiza_crapalt.
                END.

           IF   crapttl.cdempres <> log_cdempres       THEN
                DO:
                    ASSIGN log_nmdcampo = "empr." + 
                                          STRING(log_cdempres,"99999") +
                                          "-" +
                                          STRING(crapttl.cdempres,"99999") + 
                                          " " +
                                          STRING(tel_idseqttl) + ".ttl".

                    IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                         RUN atualiza_crapalt.
                END.

           IF   crapttl.nmextemp <> log_nmextemp_ttl   THEN
                DO:
                    ASSIGN log_nmdcampo = "nome empresa " +
                                          STRING(tel_idseqttl) + ".ttl".

                    IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                         RUN atualiza_crapalt.
                END.

           IF   crapttl.nrcpfemp <> log_nrcpfemp_ttl   THEN
                DO:
                    ASSIGN log_nmdcampo = "cnpj empresa " + 
                                          STRING(tel_idseqttl) + ".ttl".

                    IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                         RUN atualiza_crapalt.
                END.

           IF   crapttl.dsproftl <> log_dsproftl_ttl   THEN
                DO:
                    ASSIGN log_nmdcampo = "funcao " +
                                          STRING(tel_idseqttl) + ".ttl".

                    IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                         RUN atualiza_crapalt.
                END.

           IF   crapttl.cdnvlcgo <> log_cdnvlcgo_ttl   THEN
                DO:
                    ASSIGN log_nmdcampo = "nivel cargo " + 
                                          STRING(tel_idseqttl) + ".ttl".

                    IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                         RUN atualiza_crapalt.
                END.

           IF   crapttl.nrcadast <> log_nrcadast       THEN
                DO:
                    ASSIGN log_nmdcampo = "cadastro " + STRING(tel_idseqttl) +
                                          ".ttl".

                    IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                         RUN atualiza_crapalt.
                END.

           IF   crapttl.cdturnos <> log_cdturnos_ttl   THEN
                DO:
                    ASSIGN log_nmdcampo = "turno " + 
                                          STRING(tel_idseqttl) + ".ttl".

                    IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                         RUN atualiza_crapalt.
                END.

           IF   crapttl.dtadmemp <> log_dtadmemp_ttl   THEN
                DO:
                    ASSIGN log_nmdcampo = "adm.empr. " + 
                                          STRING(tel_idseqttl) + ".ttl".

                    IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                         RUN atualiza_crapalt.
                END.

           IF   crapttl.vlsalari <> log_vlsalari_ttl   THEN
                DO:
                    ASSIGN log_nmdcampo = "salario " +
                                          STRING(tel_idseqttl) + ".ttl".

                    IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                         RUN atualiza_crapalt.
                END.

           IF   crapttl.tpdrendi[1] <> log_cdtipren[1]   OR
                crapttl.tpdrendi[2] <> log_cdtipren[2]   OR
                crapttl.tpdrendi[3] <> log_cdtipren[3]   OR
                crapttl.tpdrendi[4] <> log_cdtipren[4]   THEN
                DO:
                    ASSIGN log_nmdcampo = "tip.ren. " + STRING(tel_idseqttl) +
                                          ".ttl".

                    IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                         RUN atualiza_crapalt.
                END.

           IF   crapttl.vldrendi[1] <> log_vlrendim[1]   OR
                crapttl.vldrendi[2] <> log_vlrendim[2]   OR
                crapttl.vldrendi[3] <> log_vlrendim[3]   OR
                crapttl.vldrendi[4] <> log_vlrendim[4]   THEN
                DO:
                    ASSIGN log_nmdcampo = "valor ren. " +
                                          STRING(tel_idseqttl) + ".ttl".

                    IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                         RUN atualiza_crapalt.
                END.

           /* Verificacoes para o log da tela: CONTAS -> INF. CADASTRAL */
           IF   crapttl.nrinfcad <> log_nrinfcad   THEN
                DO:
                    ASSIGN log_nmdcampo = "inf.cadastral " +
                                          STRING(tel_idseqttl) + ".ttl".

                    IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                         RUN atualiza_crapalt.
                END.
            
           IF   crapttl.nrpatlvr <> log_nrpatlvr   THEN
                DO:
                    ASSIGN log_nmdcampo = "patr.livre " +
                                          STRING(tel_idseqttl) + ".ttl".

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
                     IF   glb_cddopcao = "E"   THEN  /* Exclusao */
                          DO:
                              IF   crapass.inpessoa = 1  THEN
                                   ASSIGN log_nmdcampo = "Exc.Contato " +
                                               ENTRY(1,tel_nmdavali," ") + " " 
                                               + STRING(tel_idseqttl) + ".ttl". 
                              ELSE
                                   ASSIGN log_nmdcampo = "Exc.Ref." + 
                                               ENTRY(1,tel_nmdavali," ") + " "
                                               + STRING(tel_idseqttl) + ".ttl".

                              IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)
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
                                
                              IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)
                                   THEN
                                   RUN atualiza_crapalt.
                          END.
                
                     IF   crapavt.nmextemp <> log_nmextemp   THEN
                          DO:
                              ASSIGN log_nmdcampo = "empresa ref.".

                              IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)
                                   THEN
                                   RUN atualiza_crapalt.
                          END.

                     IF   crapavt.cddbanco <> log_cddbanco   THEN
                          DO:
                              ASSIGN log_nmdcampo = "banco ref.".

                              IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)
                                   THEN
                                   RUN atualiza_crapalt.
                          END.
        
                     IF   crapavt.cdagenci <> log_cdagenci   THEN
                          DO:
                              ASSIGN log_nmdcampo = "age.ref.".

                              IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)
                                   THEN
                                   RUN atualiza_crapalt.
                          END.
                
                     IF   crapavt.dsproftl <> log_dsproftl   THEN
                          DO:
                              ASSIGN log_nmdcampo = "profis.ref.".

                              IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)
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
                                
                              IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)
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
                               
                              IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)
                                   THEN
                                   RUN atualiza_crapalt.
                          END.
                        
                     IF   crapavt.nrendere <> log_numender   THEN
                          DO:
                              IF   crapass.inpessoa = 1  THEN
                                   ASSIGN log_nmdcampo = "nro.contato".
                              ELSE
                                   ASSIGN log_nmdcampo = "nro.ref.".

                              IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)
                                   THEN
                                   RUN atualiza_crapalt.
                          END.
                        
                     IF   crapavt.complend <> log_compleme   THEN
                          DO:
                              IF   crapass.inpessoa = 1  THEN
                                   ASSIGN log_nmdcampo = "complem.contato".
                              ELSE
                                   ASSIGN log_nmdcampo = "complem.ref.".

                              IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)
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
                                
                              IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)
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
                                
                              IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)
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
                                
                              IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)
                                   THEN
                                   RUN atualiza_crapalt.
                          END.
 
                     IF   crapavt.nrcxapst <> log_caixapst   THEN
                          DO:
                              IF   crapass.inpessoa = 1  THEN
                                   ASSIGN log_nmdcampo = "cxa.pst.contato".
                              ELSE
                                   ASSIGN log_nmdcampo = "cxa.pst.ref.".

                              IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)
                                   THEN
                                   RUN atualiza_crapalt.
                          END.
                
                     IF   crapavt.nrtelefo <> log_telefone   THEN
                          DO:
                              IF   crapass.inpessoa = 1  THEN
                                   ASSIGN log_nmdcampo = "fone contato".
                              ELSE
                                   ASSIGN log_nmdcampo = "fone ref.".

                              IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)
                                   THEN
                                   RUN atualiza_crapalt.
                          END.
                 
                     IF   crapavt.dsdemail <> log_endemail   THEN
                          DO:
                              IF   crapass.inpessoa = 1  THEN
                                   ASSIGN log_nmdcampo = "email contato".
                              ELSE
                                   ASSIGN log_nmdcampo = "email ref.".

                              IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)
                                   THEN
                                   RUN atualiza_crapalt.
                          END.
                 END. /* Fim tipo 5 */
            ELSE
            
        END. /* Fim crapavt */
   
   /* Verificacoes para o log da tela: CONTAS -> RESPONSAVEL LEGAL(FISICA) */
   IF AVAIL crapcrl THEN
      DO:
         IF glb_cddopcao = "E"   THEN  /* Exclusao */
            DO:
                ASSIGN log_nmdcampo = "Exc.Resp. " +
                                 ENTRY(1,tel_nmrespon_crl," ") + " " 
                                 + STRING(tel_idseqmen_crl) + ".ttl". 

                IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo) THEN
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
                                     STRING(log_ideseqmen_crl) +
                                     ".ttl".
                 
               IF  NOT CAN-DO(crapalt.dsaltera,log_nmdcampo) THEN
                   RUN atualiza_crapalt.
            END.

         IF crapcrl.dsorgemi <> log_dsorgemi_crl   THEN
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

         IF crapcrl.dsnacion <> log_dsnacion_crl   THEN
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
       
      END.


   /* Verificacoes para o log da tela: CONTAS -> CONJUGE (fisica) */
   IF   AVAILABLE crapcje   THEN
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
         
           IF   crapcje.cdoedcje <> log_cdoedcje   THEN
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
           IF   glb_cddopcao = "E"   THEN  /* Exclusao de dependente */
                DO:
                    ASSIGN log_nmdcampo = "Exc.dep." +
                                          ENTRY(1,crapdep.nmdepend," ") +
                                          " " + STRING(tel_idseqttl) + ".ttl".
                                          
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
                    ASSIGN log_nmdcampo = "tp.dep." + STRING(log_cdtipdep) + 
                                          "-" + STRING(crapdep.tpdepen).

                    IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                         RUN atualiza_crapalt.
                END.

        END.

   /* Log dos bens do cooperado */
   IF   AVAILABLE crapbem   THEN
        DO:
            IF   glb_cddopcao = "E"   THEN
                 DO:
                     ASSIGN log_nmdcampo = "Exc. do bem " + crapbem.dsrelbem +
                                           " " + STRING(tel_idseqttl) + ".ttl".

                     IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                          RUN atualiza_crapalt.
                 END.
        
            IF   crapbem.dsrelbem <> log_dsrelbem   THEN
                 DO:
                     ASSIGN log_nmdcampo = "Descricao do bem " + log_dsrelbem + 
                                           " - "                              + 
                                           crapbem.dsrelbem                   +
                                           " "                                +
                                           STRING(tel_idseqttl) + ".ttl".
                     
                     IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                          RUN atualiza_crapalt.
                 END.

            IF   crapbem.persemon <> log_persemon   THEN    
                 DO:
                     ASSIGN log_nmdcampo = log_dsrelbem + ": "                +
                                           "Percentual s/ onus "              + 
                                           STRING(log_persemon,"zz9.99")      + 
                                           " - "                              +
                                           STRING(crapbem.persemon,"zz9.99" ) + 
                                           " "                                +
                                           STRING(tel_idseqttl) + ".ttl".
                                            
                     IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                          RUN atualiza_crapalt.

                 END.
                 
            IF   crapbem.qtprebem <> log_qtprebem   THEN
                 DO:
                     ASSIGN log_nmdcampo = log_dsrelbem + ": "                +
                                           "Parcelas "                        + 
                                           STRING(log_qtprebem,"zz9")         +
                                           " - "                              +
                                           STRING(crapbem.qtprebem,"zz9")     +
                                           " "                                + 
                                           STRING(tel_idseqttl) + ".ttl".
                     
                     IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                          RUN atualiza_crapalt.

                 END.

            IF   crapbem.vlprebem <> log_vlprebem   THEN
                 DO:
                     ASSIGN log_nmdcampo = log_dsrelbem + ": "                +
                                           "Valor Parcela "                   +
                                           STRING(log_vlprebem,"zzz,zz9.99")  +
                                           " - "                              +
                                           STRING(crapbem.vlprebem,"zzz,zz9.99")
                                           + " "                              +
                                           STRING(tel_idseqttl) + ".ttl".
                    
                     IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                          RUN atualiza_crapalt.
                 
                 END.

            IF   crapbem.vlrdobem <> log_vlrdobem  THEN
                 DO:
                     log_nmdcampo = log_dsrelbem + ": "                       +
                                    "Valor Bem "                              +
                                    STRING(log_vlrdobem,"zzz,zzz,zz9.99")     +
                                    " - "                                     +
                                    STRING(crapbem.vlrdobem,"zzz,zzz,zz9.99") +
                                    " "                                       +
                                    STRING(tel_idseqttl) + ".ttl".

                     IF   NOT CAN-DO(crapalt.dsaltera,log_nmdcampo)   THEN
                          RUN atualiza_crapalt.

                 END.
        END.
    
   IF   AVAILABLE crapjfn   THEN
        DO:
            IF   crapjfn.perfatcl <> log_perfatcl   THEN
                 DO:
                     log_nmdcampo = "Concentracao faturamento unico cliente" +
                                    " 1.ttl".

                     IF   NOT CAN-DO (crapalt.dsaltera,log_nmdcampo)   THEN
                          RUN atualiza_crapalt.

                 END.
            
            /* Se alterado qualquer um desses loga alteracao de faturamento */
            DO aux_contador = 1 TO 12:
            
                IF  crapjfn.mesftbru[aux_contador] <> 
                                log_mesftbru[aux_contador]  OR
                    
                    crapjfn.anoftbru[aux_contador] <>
                                log_anoftbru[aux_contador]  OR
                                
                    crapjfn.vlrftbru[aux_contador] <>
                                log_vlrftbru[aux_contador]  THEN
                                
                    DO:
                        log_nmdcampo = "Faturamento medio bruto mensal 1.ttl".
                        
                        IF   NOT CAN-DO (crapalt.dsaltera,log_nmdcampo)   THEN
                             RUN atualiza_crapalt.

                        LEAVE.
                        
                    END.

            END. /* Fim DO .. TO */

        END.  /* fim crapjfn */

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
                       crapalt.tpaltera = 1
                       crapalt.cdoperad = glb_cdoperad.
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
                     ASSIGN crapalt.tpaltera = 1
                            crapalt.cdoperad = glb_cdoperad.
                 END.
        END.
         
   /* Se criou o registro o nao teve alteracao */
   IF   NEW crapalt   THEN
        IF   crapalt.dsaltera = ""   AND   crapalt.tpaltera = 2   THEN
             UNDO LOG, LEAVE.

   LEAVE.

END. /* Fim do WHILE */

/*...........................................................................*/
