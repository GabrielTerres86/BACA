/* ............................................................................

   Programa: fontes/traesp.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Fernando Hilgenstieler
   Data    : Julho/2003.                     Ultima atualizacao: 10/04/2018
         
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Consulta transacoes realizadas em especie.

   Alteracoes: 30/09/2003 - Nao registar acima de R$ 100.000 quando pessoa
                            juridica (Margarete).
               
               07/11/2003 - Incluir opcao P, listar movimento que
                            o PAC nao fez o documento (Margarete).

               27/01/2005 - Modificados os termos "Agencia" ou "Ag" por "PAC"
                            (Evandro).

               19/10/2005 - Inclusao do FIND crapcop (Julio).

               02/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando 
               
               20/09/2006 - Modificado help dos campos (Elton).
               
               04/05/2010 - Ajustado programa para as movimentaç?es em
                            espécie criadas na rotina 20 (a partir da
                            craptvl). (Fernando)  

               24/06/2010 - Nao estava imprimindo doctos outros dias (Magui).
               
               24/05/2011 - Opcao "T,F,S" estarao disponiveis apenas para a
                            CECRED (Adriano).
                            
               20/07/2011 - Realizado correcao nos for each crapcme
                            (Adriano).     
                            
               16/08/2011 - Quando transacao nao for informada ao COAF, sera 
                            obrigatorio prescrever uma justificativa (Adriano).
                            
               02/12/2011 - Ajuste para a transferencia intercooperativa
                            (Gabriel)
                           
               18/07/2012 - Adicionado campo tel_nrdconta quando opcao "I" e 
                            tipo 0 .   (Jorge)
               
               15/08/2013 - Nova forma de chamar as ag?ncias, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               12/11/2013 - Adequacao da regra de negocio a b1wgen0135.p
                            (conversao tela web). (Fabricio)
                            
               17/01/2014 - Alterado cdcritic ao nao encontrar PA para "962 - PA
                            nao cadastrado.". (Reinert)                            
               
               28/11/2017 - Alteracoes melhoria 458 - Antonio R Junior - Mouts

			   20/02/2018 - Alterado valor do tamanho do campo NRDOCMTO de 10 para 13 caracteres
                            adicionado o format para o campo tel_nrdocmto- Antonio R. Junior (mouts) - chamado 851313
............................................................................. */

{ includes/var_batch.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0135tt.i }

DEF        VAR tel_dtmvtolt AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR tel_nrdconta AS INT     FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF        VAR tel_cdagenci AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR tel_nrdolote AS INT     FORMAT "zzz,zz9"              NO-UNDO.
DEF        VAR tel_nrdocmto LIKE crapcme.nrdocmto FORMAT "z,zzz,zzz,zz9" NO-UNDO.
DEF        VAR tel_tpdocmto AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR tel_cddopcao AS LOGICAL FORMAT "S/N"                  NO-UNDO.
DEF        VAR tel_cdcooper AS CHAR    FORMAT "x(12)" VIEW-AS COMBO-BOX   
                                       INNER-LINES 11  NO-UNDO.

DEF        VAR tel_nrdcaixa AS INTE    FORMAT "zz9"                  NO-UNDO.
DEF        VAR tel_cdbccxlt AS INTE    FORMAT "zz9"                  NO-UNDO.

DEF        VAR aux_nmcooper AS CHAR                                  NO-UNDO.
DEF        VAR aux_contador AS INT     FORMAT "99"                   NO-UNDO.
DEF        VAR aux_stimeout AS INT                                   NO-UNDO.
DEF        VAR aux_regexist AS LOGICAL                               NO-UNDO.
DEF        VAR aux_regencon AS LOGICAL                               NO-UNDO.
DEF        VAR aux_tabexist AS LOGICAL                               NO-UNDO.
DEF        VAR aux_fechamen AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgretor AS LOGICAL                               NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_tpoperac AS INTE                                  NO-UNDO.
DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarqpdf AS CHAR                                  NO-UNDO.
DEF        VAR aux_inpessoa LIKE crapass.inpessoa                    NO-UNDO.  
DEF        VAR aux_vlctrmve AS DEC                                   NO-UNDO.
DEF        VAR aux_nrdolote AS INTE                                  NO-UNDO.
DEF        VAR aux_data_inf AS INTE                                  NO-UNDO.
DEF        VAR aux_confirma AS CHAR FORMAT "!(1)" INIT "N"           NO-UNDO.
DEF        VAR aux_existcme AS LOGICAL                               NO-UNDO.

DEF        VAR aux_nmprimtl LIKE crapass.nmprimtl                    NO-UNDO.
DEF        VAR aux_dtmvtolt LIKE crapcme.dtmvtolt                    NO-UNDO.
DEF        VAR aux_flinfdst LIKE crapcme.flinfdst FORMAT "Sim/Nao"   NO-UNDO.
DEF        VAR aux_recursos LIKE crapcme.recursos                    NO-UNDO.
DEF        VAR aux_dstrecur LIKE crapcme.dstrecur                    NO-UNDO.
DEF        VAR tel_dsdjusti LIKE crapcme.dsdjusti                    NO-UNDO.
DEF        VAR aux_nrcpfcgc AS CHAR                                  NO-UNDO.

DEF        VAR h_bo_depos AS HANDLE                                  NO-UNDO.
DEF        VAR h_bo_saque AS HANDLE                                  NO-UNDO.

DEF        VAR h-b1wgen0135 AS HANDLE                                NO-UNDO.

DEF        VAR aux_qtregist AS INTE                                  NO-UNDO.

DEF BUFFER crabcop FOR crapcop.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao  AT 1 LABEL "Opcao" AUTO-RETURN
                       VALIDATE (glb_cdcooper <> 3 AND 
                                (CAN-DO("C,D,I,P",glb_cddopcao)) OR
                                (glb_cdcooper = 3 AND
                                (CAN-DO("F,S",glb_cddopcao))),
                                 "014 - Opcao errada.")
     WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_opcao.

FORM tel_nrdconta  AT 2  LABEL "Conta/dv" AUTO-RETURN
                        HELP "Informe o numero da conta."
     WITH ROW 6 COLUMN 10 SIDE-LABELS OVERLAY NO-BOX FRAME f_conta.

FORM tel_dtmvtolt  AT 2  LABEL "Data" AUTO-RETURN
                         HELP "Informe a data."
     WITH ROW 6 COLUMN 10 SIDE-LABELS OVERLAY NO-BOX FRAME f_data.

FORM tel_cdagenci AT 2 LABEL "PA"
                        HELP "Informe o numero do PA."
                        VALIDATE (CAN-FIND (crapage WHERE 
                                            crapage.cdcooper = glb_cdcooper AND
                                            crapage.cdagenci = tel_cdagenci)
                                            ,"962 - PA nao cadastrado.")
     WITH ROW 6 COLUMN 10 SIDE-LABELS OVERLAY NO-BOX FRAME f_pac.

FORM tel_dtmvtolt AT  2 LABEL "Data"                          AUTO-RETURN
                        HELP "Informe a data."
     tel_tpdocmto       LABEL "Tp. Docmto"                    AUTO-RETURN
                        VALIDATE(tel_tpdocmto <= 4,
                                 "Tipo do documento incorreto.")
   HELP "Informe 0- Outros, 1- DOC C, 2- DOC D, 3- TED , 4-DEP. INTERCOOP"
    
     WITH ROW 6 COLUMN 10 SIDE-LABELS OVERLAY NO-BOX FRAME f_opcao2.


FORM tel_cdagenci AT 11 LABEL "PA"   AUTO-RETURN
                        HELP "Entre com o codigo do PA."
                        VALIDATE(CAN-FIND(crapage WHERE 
                                          crapage.cdcooper = glb_cdcooper  AND
                                          crapage.cdagenci = tel_cdagenci),
                                          "962 - PA nao cadastrado.")

     tel_nrdcaixa AT 25 LABEL "Caixa" AUTO-RETURN 
                        HELP "Entre com o numero do Caixa."
                        VALIDATE(tel_nrdcaixa <> 0,
                                 "375 - O campo deve ser preenchido.")

     tel_nrdocmto AT 49 LABEL "Docmto" 
                        HELP "Informe o numero do documento do deposito."
                        VALIDATE(tel_nrdocmto <> 0,
                                 "375 - O campo deve ser preenchido.")    
     WITH ROW 7 SIDE-LABELS OVERLAY NO-BOX WIDTH 78 CENTERED FRAME f_opcao3.

FORM tel_cdagenci AT 3 LABEL "PA" AUTO-RETURN
                        HELP "Entre com o codigo do PA."
                        VALIDATE(CAN-FIND(crapage WHERE 
                                          crapage.cdcooper = glb_cdcooper  AND
                                          crapage.cdagenci = tel_cdagenci),
                                          "962 - PA nao cadastrado.")

     tel_cdbccxlt AT 16 LABEL "Banco/Caixa" AUTO-RETURN 
                        HELP "Entre com o codigo do Banco/Caixa."
                        VALIDATE(CAN-FIND(crapbcl WHERE 
                                          crapbcl.cdbccxlt = tel_cdbccxlt),
                                          "057 - Banco nao cadastrado.")

     tel_nrdolote AT 39 LABEL "Lote" AUTO-RETURN
                        HELP "Entre com o numero do lote."
                        VALIDATE(tel_nrdolote > 0,
                                "058 - Numero do lote errado.")

     tel_nrdocmto AT 58 LABEL "Docmto"  
                        HELP "Informe o numero do documento do deposito."
                        VALIDATE(tel_nrdocmto <> 0,
                                 "375 - O campo deve ser preenchido.")

     WITH ROW 7 SIDE-LABELS OVERLAY NO-BOX WIDTH 78 CENTERED FRAME f_opcao4.


FORM tel_nrdconta AT 57 LABEL "Conta/Dv" AUTO-RETURN
                        HELP "Informe o numero da conta"
                        VALIDATE(tel_nrdconta <> 0,
                                 "375 - O campo deve ser preenchido.")
     WITH ROW 8 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_nrdconta.


FORM tel_cdcooper AT 07 LABEL "Cooperativa"
                        HELP "Selecione a Cooperativa"
     WITH ROW 6 COLUMN 12 SIDE-LABELS OVERLAY NO-BOX FRAME f_dscoop.

FORM tel_dtmvtolt AT 07  LABEL "Data"
                         HELP "Informe a data."
     WITH ROW 6 COLUMN 50 SIDE-LABELS OVERLAY NO-BOX FRAME f_data2.

FORM "Pa   Lote  Conta/dv Titular/Valor(R$)              Docmto/Data "
     "Oper/COAF"
     WITH ROW 10 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_cabecalho.


FORM aux_nmprimtl LABEL "Cooperado"     FORMAT "x(15)"
     aux_dtmvtolt AT 46 LABEL "Dt Mvto"
     SKIP
     aux_flinfdst LABEL "Informaçoes foram prestadas"
     aux_nrcpfcgc AT 45 LABEL "CPF/CNPJ" FORMAT "x(18)"
     aux_recursos LABEL "Origem"
     aux_dstrecur LABEL "Destino"       FORMAT "x(35)"
     tel_dsdjusti LABEL "Justificativa" FORMAT "x(55)"
             HELP "Informe a descricao da justificativa."
             VALIDATE (INPUT tel_dsdjusti <> "", "Informe uma descricao")
     WITH ROW 16 COLUMN 2 NO-BOX SIDE-LABELS OVERLAY FRAME f_detalhes.



FORM SKIP   
     tt-transacoes-especie.cdagenci  AT  1 FORMAT "x(03)"
     tt-transacoes-especie.nrdolote  AT  4 FORMAT "zzz,zz9"
     tt-transacoes-especie.nrdconta  AT 11 FORMAT "x(10)"
     tt-transacoes-especie.nmprimtl  AT 22 FORMAT "x(26)" 
     tt-transacoes-especie.nrdocmto  AT 49 FORMAT "x(13)"
     tt-transacoes-especie.tpoperac  AT 66 FORMAT "x(09)"
     SKIP
     tt-transacoes-especie.vllanmto  AT 21 FORMAT "x(14)"
     tt-transacoes-especie.dtmvtolt  AT 60       
     tt-transacoes-especie.sisbacen  AT 76 FORMAT "Sim/Nao"
     WITH ROW 11 COLUMN 2 OVERLAY 4 DOWN NO-LABEL NO-BOX FRAME f_transacoes.    

DEF QUERY q_crapcme FOR tt-crapcme.

DEF BROWSE b_crapcme QUERY q_crapcme
    DISP   tt-crapcme.cdcooper COLUMN-LABEL "Coop"
           tt-crapcme.cdagenci COLUMN-LABEL "PA"  
           tt-crapcme.nrdconta COLUMN-LABEL "Conta" 
           tt-crapcme.nrdocmto COLUMN-LABEL "Docmto"
           tt-crapcme.tpoperac COLUMN-LABEL "Operacao"  FORMAT "x(09)"  
           tt-crapcme.vllanmto COLUMN-LABEL "Valor"  
           tt-crapcme.infrepcf COLUMN-LABEL "COAF" SPACE (5)
           WITH 5 DOWN WIDTH 76 NO-BOX.

DEF FRAME f_crapcme 
          b_crapcme
     WITH CENTERED OVERLAY ROW 7.


DEF BUFFER b-craptab1 FOR craptab.
DEF BUFFER b-craptab2 FOR craptab.
         

ON RETURN OF tel_cdcooper DO:

  ASSIGN tel_cdcooper = tel_cdcooper:SCREEN-VALUE
         aux_contador = 0.
        

  APPLY "GO".

END.

ON VALUE-CHANGED, ENTRY OF b_crapcme
   DO: 
       IF AVAIL tt-crapcme THEN
          DO:
             ASSIGN aux_nmprimtl = tt-crapcme.nmprimtl
                    aux_nrcpfcgc = tt-crapcme.nrcpfcgc
                    aux_dtmvtolt = tt-crapcme.dtmvtolt
                    aux_flinfdst = tt-crapcme.flinfdst
                    aux_recursos = tt-crapcme.recursos
                    aux_dstrecur = tt-crapcme.dstrecur
                    tel_dsdjusti = tt-crapcme.dsdjusti.
                    
          
             DISP aux_nmprimtl 
                  aux_nrcpfcgc
                  aux_dtmvtolt 
                  aux_flinfdst 
                  aux_recursos 
                  aux_dstrecur
                  tel_dsdjusti
                  WITH FRAME f_detalhes.
             
          END.

   END.


/* Alimenta SELECTION-LIST de COOPERATIVAS */
FOR EACH crapcop WHERE crapcop.cdcooper <> 3 NO-LOCK BY crapcop.dsdircop:

    IF   aux_contador = 0 THEN
         ASSIGN aux_nmcooper = "TODAS,3," + CAPS(crapcop.dsdircop) + "," +
                               STRING(crapcop.cdcooper)
                aux_contador = 1.
    ELSE
          ASSIGN aux_nmcooper = aux_nmcooper + "," + CAPS(crapcop.dsdircop)
                                             + "," + STRING(crapcop.cdcooper).
END.

ASSIGN tel_cdcooper:LIST-ITEM-PAIRS = aux_nmcooper.



ON "RETURN" OF b_crapcme 
DO:     
   ASSIGN aux_existcme = FALSE.

   IF AVAIL tt-crapcme THEN
      DO:  
         IF glb_cddopcao = "F" THEN
            DO:
               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                
                  MESSAGE "Operacao deve ser informada ao COAF?" 
                           UPDATE aux_confirma.

                  LEAVE.

               END.

               IF KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
                  DO:
                     glb_cdcritic = 79.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     PAUSE 2 NO-MESSAGE.
                     glb_cdcritic = 0.
                     HIDE MESSAGE.
                     RETURN.
               
                  END.
			   
			   EMPTY TEMP-TABLE tt-reg-crapcme.

               IF aux_confirma = "S" THEN
                  DO:
                     FIND crapcme WHERE ROWID(crapcme) = tt-crapcme.nrdrowid
                                        NO-LOCK NO-ERROR.
                  
                     IF AVAIL crapcme THEN 
                        DO:
                          
                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                 
                                 UPDATE tel_dsdjusti 
                                        WITH FRAME f_detalhes.
                                 
                                 LEAVE.
                                        
                              END.

                              IF KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
                                 DO: 
                                     ASSIGN tel_dsdjusti = "".

                                     glb_cdcritic = 79.
                                     RUN fontes/critic.p.
                                     BELL.
                                     MESSAGE glb_dscritic.
                                     PAUSE 2 NO-MESSAGE.
                                     glb_cdcritic = 0.
                                     HIDE MESSAGE.
                                     RETURN.
                              
                                 END.
                                 
                            CREATE tt-reg-crapcme.
                            ASSIGN tt-reg-crapcme.cdcooper = crapcme.cdcooper
                                   tt-reg-crapcme.cdagenci = crapcme.cdagenci
                                   tt-reg-crapcme.nrdconta = crapcme.nrdconta
                                   tt-reg-crapcme.dtmvtolt = crapcme.dtmvtolt
                                   tt-reg-crapcme.nrdocmto = crapcme.nrdocmto.

                            RUN efetua-confirmacao-sisbacen IN h-b1wgen0135 (INPUT glb_cdcooper,
                                                             INPUT glb_cdagenci,
                                                             INPUT 1,
                                                             INPUT glb_cdoperad,
                                                             INPUT 0,
                                                             INPUT TRUE,
                                                             INPUT tel_dsdjusti,
                                                             INPUT TABLE tt-reg-crapcme,
                                                            OUTPUT TABLE tt-erro).

                            IF RETURN-VALUE = "NOK" THEN
                            DO:
                                FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
                                BELL.
                                MESSAGE tt-erro.dscritic.
                                CLEAR FRAME f_crapcme ALL NO-PAUSE.
                                RETURN.
                            END.

                            ASSIGN tel_dsdjusti = "".

                            DELETE tt-crapcme.
                 
                            b_crapcme:REFRESH().
        
                        END.
                      
                  END.
               ELSE
                  IF aux_confirma = "N" THEN
                     DO:
                        FIND crapcme WHERE ROWID(crapcme) = tt-crapcme.nrdrowid
                                           NO-LOCK NO-ERROR.
                        
                        IF AVAIL crapcme THEN 
                           DO:
                              DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                 
                                 UPDATE tel_dsdjusti 
                                        WITH FRAME f_detalhes.
                                 
                                 LEAVE.
                                        
                              END.

                              IF KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
                                 DO: 
                                     ASSIGN tel_dsdjusti = "".

                                     glb_cdcritic = 79.
                                     RUN fontes/critic.p.
                                     BELL.
                                     MESSAGE glb_dscritic.
                                     PAUSE 2 NO-MESSAGE.
                                     glb_cdcritic = 0.
                                     HIDE MESSAGE.
                                     RETURN.
                              
                                 END.

                              CREATE tt-reg-crapcme.
                              ASSIGN tt-reg-crapcme.cdcooper = crapcme.cdcooper
                                     tt-reg-crapcme.cdagenci = crapcme.cdagenci
                                     tt-reg-crapcme.nrdconta = crapcme.nrdconta
                                     tt-reg-crapcme.dtmvtolt = crapcme.dtmvtolt
                                     tt-reg-crapcme.nrdocmto = crapcme.nrdocmto.

                              RUN efetua-confirmacao-sisbacen IN h-b1wgen0135 (INPUT glb_cdcooper,
                                                               INPUT glb_cdagenci,
                                                               INPUT 1,
                                                               INPUT glb_cdoperad,
                                                               INPUT 0,
                                                               INPUT FALSE,
                                                               INPUT tel_dsdjusti,
                                                               INPUT TABLE tt-reg-crapcme,
                                                              OUTPUT TABLE tt-erro).

                              IF RETURN-VALUE = "NOK" THEN
                              DO:
                                  FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
                                  BELL.
                                  MESSAGE tt-erro.dscritic.
                                  CLEAR FRAME f_crapcme ALL NO-PAUSE.
                                  RETURN.
                              END.

                        
                              ASSIGN tel_dsdjusti = "".
                              
                              DELETE tt-crapcme.
                        
                              b_crapcme:REFRESH().
                        
                           END.
                        
                        PAUSE(0).
                        HIDE MESSAGE NO-PAUSE.
                        APPLY "GO" TO b_crapcme.
                    

                     END.
        
            END.  /* FIM OPCAO F */

      END.
   ELSE
     DO:
        PAUSE(0).
        HIDE MESSAGE NO-PAUSE.
        APPLY "GO" TO b_crapcme.

     END.
   
                  
END. /* FIM ON RETURN */

ON t, T OF b_crapcme IN FRAME f_crapcme
   DO:
      IF AVAIL tt-crapcme THEN
         DO:
            RUN efetua-confirmacao-sisbacen IN h-b1wgen0135 (INPUT glb_cdcooper,
                                             INPUT glb_cdagenci,
                                             INPUT 1,
                                             INPUT glb_cdoperad,
                                             INPUT -1,
                                             INPUT FALSE,
                                             INPUT "",
                                             INPUT TABLE tt-crapcme,
                                            OUTPUT TABLE tt-erro).

            IF RETURN-VALUE = "NOK" THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                
                BELL.
                MESSAGE tt-erro.dscritic.
                CLEAR FRAME f_crapcme ALL NO-PAUSE.
                RETURN.
            END.

            MESSAGE "Todos os registros foram atualizados.".
             
            PAUSE(2) NO-MESSAGE.
            
            EMPTY TEMP-TABLE tt-crapcme.
            b_crapcme:REFRESH().

            CLEAR FRAME f_detalhes.
            
            APPLY "GO" TO b_crapcme.
      
         END.

END.


VIEW FRAME f_moldura.

PAUSE(0).



ASSIGN glb_cddopcao = ""
       glb_cdcritic = 0.
   
FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                   craptab.nmsistem = "CRED"         AND
                   craptab.tptabela = "GENERI"       AND
                   craptab.cdempres = 0              AND
                   craptab.cdacesso = "VLCTRMVESP"   AND
                   craptab.tpregist = 0              NO-LOCK NO-ERROR.

IF   AVAILABLE craptab   THEN             
     ASSIGN aux_vlctrmve = DEC(craptab.dstextab).                         
ELSE
     ASSIGN aux_vlctrmve = 0.

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   tel_cddopcao = FALSE.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      HIDE FRAME f_cabecalho.
      HIDE FRAME f_transacoes.
      HIDE FRAME f_browse.
      HIDE FRAME f_dscoop.
      HIDE FRAME f_data2.
      HIDE FRAME f_justificativa.
      
      
      EMPTY TEMP-TABLE tt-crapcme.

      glb_cddopcao:HELP = (IF glb_cdcooper = 3 THEN
                              "Informe a opcao desejada (F, S)" ELSE
                              "Informe a opcao desejada (C, D, I, P)").
      
      UPDATE glb_cddopcao WITH FRAME f_opcao.


      IF glb_cddopcao <> "F"  AND
         glb_cddopcao <> "T"  AND 
         glb_cddopcao <> "S"  THEN
         VIEW FRAME f_cabecalho.

      IF   glb_cddopcao = "I" THEN
           ASSIGN tel_dtmvtolt = ?
                  tel_cdagenci = 0
                  tel_nrdolote = 0
                  tel_nrdocmto = 0
                  tel_cdbccxlt = 0.
      ELSE
           DO:
              IF   glb_cddopcao = "C" THEN
                   ASSIGN tel_nrdconta = 0.
              ELSE
                   IF   glb_cddopcao = "D" THEN
                        ASSIGN tel_dtmvtolt = ?.
           END.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   glb_nmdatela <> "traesp" THEN
                 DO:
                     IF VALID-HANDLE(h-b1wgen0135) THEN
                         DELETE PROCEDURE h-b1wgen0135.

                     HIDE FRAME f_opcao.
                     HIDE FRAME f_opcao2.
                     HIDE FRAME f_conta.
                     HIDE FRAME f_data.
                     HIDE FRAME f_data2.
                     HIDE FRAME f_transacoes.
                     HIDE FRAME f_moldura.
                     HIDE FRAME f_nrdconta.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   DISPLAY glb_cddopcao WITH FRAME f_opcao.
   
   CLEAR FRAME f_transacoes ALL NO-PAUSE.

   IF VALID-HANDLE(h-b1wgen0135) THEN
       DELETE PROCEDURE h-b1wgen0135.

   RUN sistema/generico/procedures/b1wgen0135.p PERSISTENT SET h-b1wgen0135.

   PAUSE(0) NO-MESSAGE.
   
   CASE glb_cddopcao:

        WHEN "C" THEN       

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               { includes/traespc.i }
               
            END.  /*  Fim do DO WHILE TRUE  */
        
        WHEN "D" THEN
   
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               { includes/traespd.i }
           
            END.  /*  Fim do DO WHILE TRUE  */

        WHEN "P" THEN
           
             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                
                {includes/traespp.i}
                
             END. /* Fim dO DO WHILE TRUE */
        
         WHEN "F" THEN
   
          DO:

             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                
                UPDATE tel_cdcooper
                       WITH FRAME f_dscoop.

                LEAVE.

             END.

             tel_dtmvtolt = glb_dtmvtoan.
             
             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                UPDATE tel_dtmvtolt  
                       WITH FRAM f_data2.
                LEAVE.
             END.

             IF KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
                NEXT.

             MESSAGE "Carregando informacoes...".

             RUN consulta-dados-fechamento IN h-b1wgen0135 
                                                (INPUT INT(tel_cdcooper),
                                                 INPUT glb_cdagenci,
                                                 INPUT 1,
                                                 INPUT tel_dtmvtolt,
                                                OUTPUT aux_qtregist,
                                                OUTPUT TABLE tt-crapcme,
                                                OUTPUT TABLE tt-erro).

             IF RETURN-VALUE = "NOK" THEN
             DO:
                 FIND FIRST tt-erro NO-LOCK NO-ERROR.

                 BELL.
                 MESSAGE tt-erro.dscritic.
                 CLEAR FRAME f_crapcme ALL NO-PAUSE.
                 NEXT.
             END.
             
             FIND FIRST tt-crapcme NO-LOCK NO-ERROR.

             IF AVAIL tt-crapcme THEN
                DO:
                   OPEN QUERY q_crapcme FOR EACH tt-crapcme
                                                 NO-LOCK BY tt-crapcme.cdcooper
                                                          BY tt-crapcme.cdagenci
                                                           BY tt-crapcme.nrdconta.
                
                   HIDE MESSAGE NO-PAUSE.
                 
                   b_crapcme:HELP = "Tecle ENTER para selecionar o registro," + 
                                    "(T)odos e <F4> para sair.".                 
                 
                   
                   ENABLE b_crapcme WITH FRAME f_crapcme.
                 
                   
                   WAIT-FOR END-ERROR OF DEFAULT-WINDOW.
                   
                 
                   HIDE MESSAGE NO-PAUSE.
            
                END.
             ELSE
               DO:
                  HIDE MESSAGE NO-PAUSE.
                  MESSAGE "Nenhum registro encontrado.".
                  PAUSE (2) NO-MESSAGE.
                  NEXT.

               END.

            /*  Nunca vai chegar aqui!!!... Fabricio.
             RELEASE crapcme.
             
             IF aux_existcme = TRUE    THEN
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    
                   MESSAGE "AGUARDE...".
                    
                   IF INT(tel_cdcooper) <> 3 THEN
                      DO:
                         ASSIGN aux_regexist = NO.        
                       
                         FIND craptab WHERE 
                                       craptab.cdcooper = INT(tel_cdcooper) AND 
                                       craptab.nmsistem = "CRED"            AND
                                       craptab.tptabela = "GENERI"          AND
                                       craptab.cdempres = 0                 AND
                                       craptab.cdacesso = "VMINCTRCEN"      AND
                                       craptab.tpregist = 0            
                                       NO-LOCK NO-ERROR.
                         
                         IF NOT AVAILABLE craptab THEN
                            DO:
                                glb_cdcritic = 50.
                                RUN fontes/critic.p.
                                MESSAGE glb_dscritic.
                                LEAVE.

                            END.
                      
                         FOR EACH crapcme WHERE 
                                  crapcme.cdcooper = INT(tel_cdcooper)      AND
                                 (crapcme.vllanmto >= DEC(craptab.dstextab) OR
                                  crapcme.ilicita)                          
                                  NO-LOCK:
                            
                             FIND crapass WHERE 
                                  crapass.cdcooper = crapcme.cdcooper AND 
                                  crapass.nrdconta = crapcme.nrdconta 
                                  NO-LOCK NO-ERROR.
                          
                             ASSIGN aux_inpessoa = IF AVAILABLE crapass 
                                                   THEN crapass.inpessoa ELSE 1.
                             
                             IF   aux_inpessoa <> 2   OR
                                  crapcme.ilicita     THEN
                                  DO:             
                                      ASSIGN aux_regexist = YES.
                                      LEAVE.
                      
                                  END.    
                         END.
                      
                         IF   NOT aux_regexist THEN
                              DO:
                                  glb_cdcritic = 11.
                                  RUN fontes/critic.p.
                                  MESSAGE glb_dscritic.
                                  LEAVE.
                      
                              END.
                         
                         DO WHILE TRUE TRANSACTION:
                            
                            FIND craptab WHERE 
                                         craptab.cdcooper = INT(tel_cdcooper) AND 
                                         craptab.nmsistem = "CRED"            AND
                                         craptab.tptabela = "GENERI"          AND
                                         craptab.cdempres = 0                 AND
                                         craptab.cdacesso = "CTRMVESCEN"      AND
                                         craptab.tpregist = 0                
                                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                            
                            IF   NOT AVAILABLE craptab THEN
                                 DO:             
                                     IF LOCKED craptab THEN
                                        DO:
                                            PAUSE(1) NO-MESSAGE.
                                            NEXT.
                                        END.
                                     ELSE
                                        DO:
                                           glb_cdcritic = 55.
                                           RUN fontes/critic.p.
                                           MESSAGE glb_dscritic.
                                           LEAVE.
                      
                                        END.
                                 END.
                            ELSE                     
                               DO: 
                                   ASSIGN craptab.dstextab = "1". 
                                   LEAVE. 
                      
                               END.

                         END.  /*  Fim do TRANSACTION  */ 
                      
                         LEAVE.                           
                                 
              
                      END.
                   ELSE
                     DO: 
                        FOR EACH crapcop NO-LOCK:  
                                   
                            FIND FIRST b-craptab1 WHERE 
                                       b-craptab1.cdcooper = crapcop.cdcooper AND
                                       b-craptab1.nmsistem = "CRED"           AND
                                       b-craptab1.tptabela = "GENERI"         AND
                                       b-craptab1.cdempres = 0                AND
                                       b-craptab1.cdacesso = "VMINCTRCEN"     AND
                                       b-craptab1.tpregist = 0            
                                       NO-LOCK NO-ERROR.

                            IF NOT AVAIL b-craptab1 THEN
                               NEXT.
                            
                            ASSIGN aux_regexist = NO
                                   aux_tabexist = TRUE.
                                   
                            FOR EACH crapcme WHERE 
                                     crapcme.cdcooper = b-craptab1.cdcooper       AND
                                    (crapcme.vllanmto >= DEC(b-craptab1.dstextab) OR
                                     crapcme.ilicita)                         
                                     NO-LOCK:
                                
                                 FIND crapass WHERE 
                                      crapass.cdcooper = crapcme.cdcooper AND 
                                      crapass.nrdconta = crapcme.nrdconta 
                                      NO-LOCK NO-ERROR.
                              
                                 ASSIGN aux_inpessoa = IF AVAILABLE crapass 
                                                       THEN crapass.inpessoa ELSE 1.
                                 
                                 IF   aux_inpessoa <> 2   OR
                                      crapcme.ilicita     THEN
                                      DO:             
                                          ASSIGN aux_regexist = YES
                                                 aux_regencon = YES.
                          
                                          LEAVE.
                            
                                      END.    
                            END.
                            
                            IF NOT aux_regexist THEN
                               NEXT.
                            
                            DO WHILE TRUE TRANSACTION:
                            
                               FIND FIRST craptab WHERE 
                                          craptab.cdcooper = b-craptab1.cdcooper AND
                                          craptab.nmsistem = "CRED"              AND
                                          craptab.tptabela = "GENERI"            AND
                                          craptab.cdempres = 0                   AND
                                          craptab.cdacesso = "CTRMVESCEN"        AND
                                          craptab.tpregist = 0             
                                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                               
                                IF  NOT AVAILABLE craptab THEN
                                    DO:             
                                        IF LOCKED craptab THEN
                                           DO:
                                               PAUSE(1) NO-MESSAGE.
                                               NEXT.
                                           END.
                                        ELSE
                                           DO:
                                              glb_cdcritic = 55.
                                              RUN fontes/critic.p.
                                              MESSAGE glb_dscritic.
                                              LEAVE.
                             
                                           END.
                                    END.
                                ELSE                     
                                  DO: 
                                    FIND b-craptab2 WHERE 
                                         b-craptab2.cdcooper = b-craptab1.cdcooper AND 
                                         b-craptab2.nmsistem = "CRED"              AND
                                         b-craptab2.tptabela = "GENERI"            AND
                                         b-craptab2.cdempres = 0                   AND
                                         b-craptab2.cdacesso = "CTRMVESCEN"        AND
                                         b-craptab2.tpregist = 0             
                                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                      
                                    ASSIGN b-craptab2.dstextab = "1".
                                           
                          
                                    LEAVE.
                             
                                  END.
                           
                            END.  /*  Fim do TRANSACTION  */ 
                          
                              
                        END.

                        HIDE MESSAGE NO-PAUSE.
                               
                        IF   NOT aux_regencon THEN
                             DO:
                                glb_cdcritic = 11.
                                RUN fontes/critic.p.
                                MESSAGE glb_dscritic.
                                LEAVE.
                                   
                             END.

                        IF aux_tabexist = FALSE THEN
                           DO:
                               HIDE MESSAGE NO-PAUSE.
                               glb_cdcritic = 50.
                               RUN fontes/critic.p.
                               MESSAGE glb_dscritic.
                               PAUSE(2) NO-MESSAGE.
                               LEAVE.

                           END.
                     
                     END.
                
                     LEAVE.
              
              
                END.
             
             HIDE MESSAGE NO-PAUSE.

             RELEASE craptab.
             RELEASE b-craptab2.
             */   
             HIDE FRAME f_crapcme.
             HIDE FRAME f_detalhes.
             
             IF KEYFUNCTION (LAST-KEY) = "END-ERROR" THEN
                NEXT.
              

          END.

        WHEN "I" THEN
   
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               { includes/traespi.i }   
                           
            END.  /*  Fim do DO WHILE TRUE  */
    
        WHEN "S" THEN
            
            DO:
                RUN fontes/traespm.p (INPUT h-b1wgen0135).
               
            END.
                        
   END CASE. /*  Fim do CASE  */
 
   HIDE FRAME f_conta.
   HIDE FRAME f_data.
   HIDE FRAME f_pac.
   HIDE FRAME f_opcao2.
   HIDE FRAME f_opcao3.
   HIDE FRAME f_opcao4.
   HIDE FRAME f_nrdconta.
       
END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */



