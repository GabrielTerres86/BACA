/* ............................................................................

   Programa: Fontes/verlog.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Sidnei (Precise)
   Data    : Outubro/2007                       Ultima alteracao: 21/11/2016
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Tela para visualizacao do log de transacoes do sistema.
   
   Atualizacoes: 24/10/2007 - Criticar acesso para operadores (Guilherme).
        
                 07/04/2008 - Melhoria de Performance (Evandro).
                 
                 28/04/2008 - Aumentado o format do campo "Vlr. Atual" para
                              mostrar o codigo de barras de titulos e faturas
                              (Evandro).
                              
                 25/05/2009 - Alteracao CDOPERAD (Kbase).
                 
                 12/04/2010 - Criar campo de pesquisa (Gabriel).
                 
                 21/10/2010 - Substituido a opcao Origem por F7 (Adriano).
                 
                 30/08/2011 - Criado frame f_complemento. (Fabricio)
                 
                 27/10/2011 - Para PF, pegar nome do cooperado e nome da 
                              empresa com base na titularidade. (Fabricio)
                              
                 18/11/2011 - Corrigido para trazer nome do cooperado e empresa
                              quando nao for informado numero da conta. 
                              (Fabricio)
                              
                 01/12/2011 - Alterado a leitura da crapass por crapjur, pois
                              o campo cdempres sera excluido da crapass.
                              (Fabricio)
                              
                 30/03/2012 - Nao permitir digitar nada na origem, apenas usar
                              o F7 (Evandro).

                 16/07/2013 - Criar Opcao C e T gerar relatorio do operador
                              (Anderson/AMCOM).
                              
                 10/10/2013 - Inserir coluna EMPRESA no arquivo (Ze).

				         21/11/2016 - Tratar nulo ao criar arquivo na opcao T. (SD 557084 Kelvin)
                 
                 29/06/2017 - Alterada busca da opcao INTRANET, para que busque origens
                              INTRANET e AYLLOS WEB.
                              Heitor (Mouts) - Chamado 686993

............................................................................ */

{ includes/var_online.i }

DEF        VAR tel_cdopcao  AS CHAR    FORMAT "X"                    NO-UNDO.
DEF        VAR tel_nrdconta AS INT     FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF        VAR tel_idseqttl AS INT     FORMAT "9"  INIT 0            NO-UNDO.
DEF        VAR tel_nmprimtl AS CHAR    FORMAT "x(40)"                NO-UNDO.
DEF        VAR tel_dataini  AS DATE    FORMAT "99/99/99"             NO-UNDO.
DEF        VAR tel_datafin  AS DATE    FORMAT "99/99/99"             NO-UNDO.
DEF        VAR tel_dsorige  AS CHAR    FORMAT "x(11)"                NO-UNDO.
DEF        VAR tel_cdoperad AS CHAR    FORMAT "x(10)"                NO-UNDO.
DEF        VAR tel_pesquisa AS CHAR    FORMAT "x(45)"                NO-UNDO.

DEF        VAR tel_nmresaux AS CHAR    FORMAT "x(30)"                NO-UNDO.
DEF        VAR tel_nmresemp AS CHAR    FORMAT "x(15)"                NO-UNDO.

DEF        VAR aux_stimeout AS INT                                   NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_query    AS CHAR                                  NO-UNDO.

DEF        VAR tel_nmarqaux AS CHAR                                  NO-UNDO.
DEF        VAR tel_nmarquiv AS CHAR   FORMAT "X(25)"                 NO-UNDO.
DEF        VAR tel_nmdireto AS CHAR   FORMAT "X(20)"                 NO-UNDO.

DEF STREAM str_1.

FORM SPACE(1)
     WITH ROW 4  OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.


FORM tel_nrdconta AT  3 LABEL "Conta/dv"
                        HELP "Entre com o numero da conta do associado."
     
     tel_idseqttl AT 26 LABEL "Seq." 
                  HELP "Entre com a sequencia do titular ou 0 para todos."
     
     tel_nmprimtl AT 39 LABEL "Titular" FORMAT "x(30)"
     SKIP
     tel_dataini  AT 2  LABEL "Dt Inicio"
                  HELP "Entre com a data inicial (DD/MM/AA)"
                  VALIDATE(tel_dataini <> ?,
                           "375 - O campo deve ser preenchido.")

     tel_datafin  AT 24 LABEL "Dt Fim"
                  HELP "Entre com a data final (DD/MM/AA)"
                  VALIDATE (tel_datafin <> ?,
                            "375 - O campo deve ser preenchido.")  
     tel_cdoperad AT 42 LABEL "Ope."
                  HELP  "Entre com o codigo do operador."
    
     tel_dsorige  AT 60 LABEL "Origem"
                  HELP  "Escolha o tipo da origem, pressione F7 para listar."
                  
     tel_pesquisa AT 3  LABEL "Pesquisa"
                  HELP "Entre com a descricao ou deixe em branco para todos."
     
     WITH ROW 6 COLUMN 2 OVERLAY NO-BOX SIDE-LABELS FRAME f_param_log.

     
FORM tel_cdopcao  AT 6 LABEL "Opcao"
                       HELP "Entre com a opcao desejada. C ou T." AUTO-RETURN
          
     WITH ROW 5  COLUMN 2 OVERLAY NO-BOX SIDE-LABELS FRAME f_opcao.

                      

FORM tel_dataini  AT 2  LABEL "Dt Inicio"
                        HELP "Entre com a data inicial (DD/MM/AA)"
                        VALIDATE(tel_dataini <> ?,
                                 "375 - O campo deve ser preenchido.")
     tel_datafin  AT 24 LABEL "Dt Fim"
                        HELP "Entre com a data final (DD/MM/AA)"
                        VALIDATE(tel_datafin <> ? ,
                                 "375 - O campo deve ser preenchido.")  
     tel_cdoperad AT 43 LABEL "Operador"
                        HELP  "Entre com o codigo do operador."
                        VALIDATE(TRIM(tel_cdoperad) <> "",
                                      "375 - O campo deve ser preenchido.")
     WITH ROW 6 COLUMN 2 OVERLAY NO-BOX SIDE-LABELS FRAME f_param_arquivo.


     
DEF QUERY q_craplgi FOR craplgi FIELDS(cdcooper
                                       nrseqcmp
                                       nmdcampo 
                                       dsdadant 
                                       dsdadatu).
 
DEF BROWSE b_craplgi QUERY q_craplgi
    DISP craplgi.nrseqcmp COLUMN-LABEL "Seq"            FORMAT ">>9"
         craplgi.nmdcampo COLUMN-LABEL "Campo"          FORMAT "x(30)"
         craplgi.dsdadant COLUMN-LABEL "Vlr. Anterior"  FORMAT "x(25)"
         craplgi.dsdadatu COLUMN-LABEL "Vlr. Atual"     FORMAT "x(47)"
         WITH 5 DOWN WIDTH 75 NO-BOX.

FORM SKIP(1)
     b_craplgi    AT 01
                  HELP "Pressione <F4> ou <END> para sair."
     WITH ROW 7 COLUMN 2 OVERLAY 1 DOWN WIDTH 78 SIDE-LABELS 
     TITLE " Detalhes do Log " FRAME f_craplgi.

DEF QUERY q_craplgm FOR craplgm FIELDS(cdcooper
                                       nrdconta
                                       dttransa
                                       hrtransa
                                       idseqttl
                                       nrsequen
                                       dsorigem 
                                       dttransa 
                                       hrtransa
                                       nmdatela
                                       dstransa
                                       flgtrans
                                       dscritic
                                       cdoperad),
                        crapope FIELDS(nmoperad).
 
DEF VAR aux_hrtransa AS CHAR FORMAT "x(05)" NO-UNDO.

DEF BROWSE b_craplgm QUERY q_craplgm 
    DISP craplgm.nrdconta COLUMN-LABEL "Conta"        FORMAT "zzzz,zzz,9"
         craplgm.idseqttl COLUMN-LABEL "Tit"          FORMAT "9"
         craplgm.dttransa COLUMN-LABEL "Data"         FORMAT "99/99/9999" 
         STRING(craplgm.hrtransa,"HH:MM:SS") 
                          COLUMN-LABEL "Hora"         FORMAT "x(08)"
         craplgm.dstransa COLUMN-LABEL "Descricao"    FORMAT "x(63)"
         craplgm.cdoperad COLUMN-LABEL "Operador"     FORMAT "x(10)"
         crapope.nmoperad COLUMN-LABEL ""             FORMAT "x(25)"
         craplgm.dsorigem COLUMN-LABEL "Origem"       FORMAT "x(11)" 
         craplgm.nmdatela COLUMN-LABEL "Tela"         FORMAT "x(12)"
         craplgm.flgtrans COLUMN-LABEL "Suces"
         craplgm.dscritic COLUMN-LABEL "Critica  "    FORMAT "x(63)"
         WITH 6 DOWN WIDTH 78 SCROLLBAR-VERTICAL.

DEF FRAME f_craplgm
          b_craplgm
    HELP "Pressione <ENTER> p/ detalhes ou <SETAS> p/ outras informacoes "
    WITH NO-BOX CENTERED OVERLAY ROW 9.

FORM SKIP(1)
     tel_nmresaux AT 02 LABEL "Nome do Cooperado"
     tel_nmresemp AT 02 LABEL "Empresa"
     WITH NO-BOX OVERLAY SIDE-LABELS ROW 18 COLUMN 2 FRAME f_complemento.

FORM SKIP(1)
     "Diretorio:   "     AT 5
     tel_nmdireto
     tel_nmarquiv        HELP "Informe o nome do arquivo."
     SKIP(1)
     WITH OVERLAY CENTERED NO-LABEL WIDTH 70 ROW 10 FRAME f_directory.


ON ENTER OF b_craplgm IN FRAME f_craplgm
   DO:                       
       IF   NOT AVAILABLE craplgm   THEN
            RETURN NO-APPLY.

       OPEN QUERY q_craplgi
            FOR EACH craplgi WHERE craplgi.cdcooper = craplgm.cdcooper   AND
                                   craplgi.nrdconta = craplgm.nrdconta   AND
                                   craplgi.dttransa = craplgm.dttransa   AND
                                   craplgi.hrtransa = craplgm.hrtransa   AND
                                   craplgi.idseqttl = craplgm.idseqttl   AND
                                   craplgi.nrsequen = craplgm.nrsequen
                                   NO-LOCK BY craplgi.nrseqcmp.
       
       ENABLE b_craplgi WITH FRAME f_craplgi.

       APPLY "ENTRY" TO b_craplgi IN FRAME f_craplgi.
       WAIT-FOR "F4" OF b_craplgi.

       IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
            DO:
                DISABLE b_craplgi WITH FRAME f_craplgi.
                HIDE FRAME f_craplgi.
            END.
        
       HIDE FRAME f_craplgi.
       APPLY "ENTRY" TO b_craplgm IN FRAME f_craplgm.

   END.

ON VALUE-CHANGED OF b_craplgm IN FRAME f_craplgm
   DO:
       IF   LENGTH(TRIM(tel_nmprimtl)) > 0 THEN
            DO:
                IF   crapass.inpessoa = 1 THEN
                     DO:
                         FIND crapttl WHERE crapttl.cdcooper = glb_cdcooper AND
                                            crapttl.nrdconta = tel_nrdconta AND
                                            crapttl.idseqttl = craplgm.idseqttl 
                                            NO-LOCK NO-ERROR.

                         IF   AVAILABLE crapttl THEN
                              DO:
                                  ASSIGN tel_nmresaux = crapttl.nmextttl.

                                  FIND crapemp WHERE 
                                       crapemp.cdcooper = crapttl.cdcooper AND
                                       crapemp.cdempres = crapttl.cdempres 
                                       NO-LOCK NO-ERROR.

                                  IF   AVAILABLE crapemp THEN
                                       ASSIGN tel_nmresemp = crapemp.nmresemp.
                                  ELSE
                                       ASSIGN tel_nmresemp = "".
                              END.
                         ELSE
                              ASSIGN tel_nmresaux = ""
                                     tel_nmresemp = "".

                         DISPLAY tel_nmresaux tel_nmresemp 
                                 WITH FRAME f_complemento.
                     END.
            END.
       ELSE
            DO:
                FIND crapttl WHERE crapttl.cdcooper = glb_cdcooper     AND
                                   crapttl.nrdconta = craplgm.nrdconta AND
                                   crapttl.idseqttl = craplgm.idseqttl 
                                   NO-LOCK NO-ERROR.

                IF   AVAILABLE crapttl THEN
                     DO:
                         ASSIGN tel_nmresaux = crapttl.nmextttl.

                         FIND crapemp WHERE 
                              crapemp.cdcooper = crapttl.cdcooper AND
                              crapemp.cdempres = crapttl.cdempres 
                              NO-LOCK NO-ERROR.

                         IF   AVAILABLE crapemp THEN
                              ASSIGN tel_nmresemp = crapemp.nmresemp.
                         ELSE
                              ASSIGN tel_nmresemp = "".
                     END.
                ELSE
                     DO:
                         FIND crapjur WHERE crapjur.cdcooper = glb_cdcooper AND
                                            crapjur.nrdconta = craplgm.nrdconta
                                            NO-LOCK NO-ERROR.

                         IF   AVAILABLE crapjur THEN
                              DO:
                                  ASSIGN tel_nmresaux = crapjur.nmextttl.

                                  FIND crapemp WHERE 
                                       crapemp.cdcooper = crapjur.cdcooper AND
                                       crapemp.cdempres = crapjur.cdempres 
                                       NO-LOCK NO-ERROR.

                                  IF   AVAILABLE crapemp THEN
                                       ASSIGN tel_nmresemp = crapemp.nmresemp.
                                  ELSE
                                       ASSIGN tel_nmresemp = "".
                              END.
                         ELSE
                              ASSIGN tel_nmresaux = ""
                                     tel_nmresemp = "".
                     END.

                DISPLAY tel_nmresaux tel_nmresemp WITH FRAME f_complemento.
            END.
   END.

FIND FIRST crapcop WHERE crapcop.cdcooper = glb_cdcooper
                         NO-LOCK NO-ERROR.

VIEW FRAME f_moldura.

PAUSE(0).

/* Usado para criticar acesso aos operadadores */
glb_cddopcao = "C".

ASSIGN glb_cdcritic = 0
       tel_cdopcao = "C".

DO WHILE TRUE:

   RUN fontes/inicia.p.

   ASSIGN tel_dataini = glb_dtmvtolt
          tel_datafin = glb_dtmvtolt
          tel_nmresaux = ""
          tel_nmresemp = "".

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
           END.

      IF   aux_cddopcao <> glb_cddopcao   THEN
           DO:
              { includes/acesso.i }
              aux_cddopcao = glb_cddopcao.
           END. 
      
      
      HIDE FRAME f_param_log.
      HIDE FRAME f_param_arquivo.
      HIDE FRAME f_directory.

      UPDATE tel_cdopcao WITH FRAME f_opcao.
      
      ASSIGN tel_cdopcao = UPPER(tel_cdopcao).

      IF   NOT CAN-DO("C,T,",tel_cdopcao)  THEN
           DO:
               ASSIGN glb_cdcritic = 014.
               RUN fontes/critic.p.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
               NEXT. 
           END.

      IF   UPPER(tel_cdopcao) = "T" THEN
           DO:
               ASSIGN tel_nrdconta = 0
                      tel_idseqttl = 0
                      tel_dsorige =  "".    

               UPDATE tel_dataini  tel_datafin  tel_cdoperad 
                      WITH FRAME f_param_arquivo.
           END.
      ELSE
           DO:
               ASSIGN tel_cdoperad = "". 
        
               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
         
                  UPDATE tel_nrdconta  tel_idseqttl  tel_dataini  
                         tel_datafin   tel_cdoperad  tel_dsorige
                         WITH FRAME f_param_log
          
                  EDITING:
          
                     aux_stimeout = 0.
           
                     DO WHILE TRUE:
             
                        READKEY PAUSE 1.
               
                        IF   FRAME-FIELD = "tel_dsorige"  THEN
                             DO:
                                 IF   LASTKEY = KEYCODE ("F7") THEN
                                      DO:
                                          RUN fontes/zoom_origem_log.p 
                                                (OUTPUT tel_dsorige).
                               
                                          DISPLAY tel_dsorige
                                                  WITH FRAME f_param_log.
                            
                                          NEXT-PROMPT tel_dsorige
                                                      WITH FRAME f_param_log.
                                      END.
                                 ELSE
                                     IF  KEYFUNCTION(LASTKEY) <> "TAB"       AND
                                         KEYFUNCTION(LASTKEY) <> "BACK-TAB"  AND
                                         KEYFUNCTION(LASTKEY) <> "END-ERROR" AND
                                         KEYFUNCTION(LASTKEY) <> "RETURN"    AND
                                         KEYFUNCTION(LASTKEY) <> "GO"       THEN
                                         NEXT.
                             END.
          
                        IF   LASTKEY = -1   THEN
                             DO:
                                 aux_stimeout = aux_stimeout + 1.
                         
                                 IF   aux_stimeout > glb_stimeout   THEN
                                      QUIT.
             
                                 NEXT.
                             END.
               
                        APPLY LASTKEY.
              
                        LEAVE.

                     END.  
          
                  END. 

                  IF   tel_dsorige = ""  THEN
                       DO:
                           glb_cdcritic = 375.
                           RUN fontes/critic.p.
                           BELL.
                           MESSAGE glb_dscritic.
                           glb_cdcritic = 0.
                           NEXT-PROMPT tel_dsorige WITH FRAME f_param_log.
                           NEXT.
                       END.

                  LEAVE.
               END.
           END.
      
      IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
           NEXT.

      IF   tel_nrdconta > 0   THEN
           DO:
               ASSIGN glb_nrcalcul = tel_nrdconta.
               
               RUN fontes/digfun.p.

               IF   NOT glb_stsnrcal   THEN
                    DO:
                        glb_cdcritic = 8.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        NEXT.
                    END.
               
               FIND crapass WHERE crapass.cdcooper = glb_cdcooper   AND
                                  crapass.nrdconta = tel_nrdconta 
                                  NO-LOCK NO-ERROR.

               IF   NOT AVAILABLE crapass   THEN
                    DO:
                        glb_cdcritic = 9.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        NEXT.
                    END.
               
               IF   crapass.inpessoa = 1 AND  /* pessoa fisica */
                    tel_idseqttl <> 0    THEN /* informado seq titular */
                    DO:
                        FIND crapttl WHERE crapttl.cdcooper = glb_cdcooper AND
                                           crapttl.nrdconta = tel_nrdconta AND
                                           crapttl.idseqttl = tel_idseqttl
                                           NO-LOCK NO-ERROR.
                        
                        IF   NOT AVAILABLE crapttl   THEN
                             DO:
                                 BELL.
                                 MESSAGE "Titular nao cadastrado !".
                                 NEXT.
                             END.
                  
                        ASSIGN tel_nmprimtl = crapttl.nmextttl. 
                    END.
               ELSE
                    ASSIGN tel_nmprimtl = crapass.nmprimtl.

               IF   crapass.inpessoa = 2 THEN
                    DO:
                        FIND crapjur WHERE 
                             crapjur.cdcooper = crapass.cdcooper AND
                             crapjur.nrdconta = crapass.nrdconta
                             NO-LOCK NO-ERROR.

                        tel_nmresaux = crapjur.nmextttl.

                        FIND crapemp WHERE 
                             crapemp.cdcooper = crapjur.cdcooper AND
                             crapemp.cdempres = crapjur.cdempres 
                             NO-LOCK NO-ERROR.

                        IF   AVAILABLE crapemp THEN
                             ASSIGN tel_nmresemp = crapemp.nmresemp.
                        ELSE
                             ASSIGN tel_nmresemp = "".

                        DISPLAY tel_nmresaux tel_nmresemp 
                                WITH FRAME f_complemento.
                    END.

           END. /* Fim do IF .. THEN */
      ELSE
           ASSIGN tel_nmprimtl = "".

      IF   UPPER(tel_cdopcao) = "C" THEN
           DO:
               ASSIGN tel_dsorige = UPPER(tel_dsorige).
           
               DISPLAY tel_nmprimtl  tel_dsorige
                       WITH FRAME f_param_log.

               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  UPDATE tel_pesquisa  WITH FRAME f_param_log.
                  LEAVE.
               END.
           END.
      
      IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
           NEXT.

      IF   UPPER(tel_cdopcao) = "T" THEN
           RUN gera_arquivo.
      ELSE
           IF   UPPER(tel_cdopcao) = "C" THEN
                DO:
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                       /* Montagem da QUERY dinamicamente para 
                          melhoria de performance */
             
                       aux_query = "FOR EACH craplgm WHERE " +
                                       "craplgm.cdcooper = " +
                                            STRING(glb_cdcooper) + " AND " +
                                       "craplgm.dttransa >= " +
                                            STRING(tel_dataini)  + " AND " +
                                       "craplgm.dttransa <= " + 
                                            STRING(tel_datafin)  + " ".
                                       
                       IF   tel_nrdconta <> 0   THEN             
                            aux_query = aux_query + "AND craplgm.nrdconta = " +
                                        STRING(tel_nrdconta) + " ".
                          
                       IF   tel_idseqttl <> 0   THEN
                            aux_query = aux_query + "AND craplgm.idseqttl = " +
                                        STRING(tel_idseqttl) + " ".
                          
                       IF   tel_cdoperad <> ""   THEN
                            aux_query = aux_query + "AND craplgm.cdoperad = '" +
                                        STRING(tel_cdoperad) + "' ".
         
                       IF   tel_dsorige <> "TODOS"  THEN
                         DO:
                           IF tel_dsorige <> "INTRANET" THEN
                             DO:
                               aux_query = aux_query + "AND craplgm.dsorigem = '" +
                                           STRING(tel_dsorige) + "' ".
                             END.
                           ELSE
                             DO:
                               aux_query = aux_query + "AND CAN-DO('INTRANET,AYLLOS WEB', craplgm.dsorigem)".
                             END.
                         END.

                       IF   tel_pesquisa <> ""   THEN
                            aux_query = aux_query + "AND craplgm.dstransa
                                        MATCHES '*" + tel_pesquisa + "*' ".  
           
                       aux_query = aux_query + "NO-LOCK, " +
                                   "FIRST crapope WHERE " +
                                   "crapope.cdcooper = craplgm.cdcooper AND " +
                                   "crapope.cdoperad = STRING(craplgm.cdoperad)"
                                   + "NO-LOCK BY craplgm.dttransa " +
                                   "BY craplgm.hrtransa".

                       QUERY q_craplgm:QUERY-CLOSE().
                       QUERY q_craplgm:QUERY-PREPARE(aux_query).

                       MESSAGE "Aguarde...".
                       QUERY q_craplgm:QUERY-OPEN().
         
                       HIDE MESSAGE NO-PAUSE.
         
                       ENABLE b_craplgm WITH FRAME f_craplgm.
                 
                       WAIT-FOR END-ERROR OF DEFAULT-WINDOW.
                                        
                       HIDE FRAME f_craplgm.
                       HIDE FRAME f_complemento.
             
                       HIDE MESSAGE NO-PAUSE.

                       LEAVE.

                    END.  /*  Fim do DO WHILE TRUE  */

                END.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"    THEN     /*    F4 OU FIM    */
        DO:
            RUN fontes/novatela.p.

            IF   CAPS(glb_nmdatela) <> "VERLOG"  THEN
                 DO:
                     HIDE FRAME f_param_log.
                     HIDE FRAME f_moldura.
                     
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.
END. 

PROCEDURE gera_arquivo:
  
  DEF VAR aux_dataini  AS DATE                                      NO-UNDO.
  DEF VAR aux_datafim  AS DATE                                      NO-UNDO.
  DEF VAR aux_cdcooper AS INTE                                      NO-UNDO.
  DEF VAR aux_cdoperad AS CHAR                                      NO-UNDO.
  DEF VAR aux_nmoperad AS CHAR                                      NO-UNDO.
  DEF VAR aux_nmprimtl AS CHAR                                      NO-UNDO.
  DEF VAR aux_flgtrans AS CHAR                                      NO-UNDO.
  DEF VAR aux_cdempres AS INTE                                      NO-UNDO.
  DEF VAR aux_dsempres AS CHAR                                      NO-UNDO.
  DEF VAR aux_dscritic AS CHAR                                      NO-UNDO.

  ASSIGN tel_nmdireto =  "/micros/" + LOWER(crapcop.dsdircop) + "/".

  DISPLAY tel_nmdireto WITH FRAME f_directory.
  
  UPDATE tel_nmarquiv WITH FRAME f_directory.
  
  HIDE frame f_directory.

  IF   tel_nmarquiv = ""  THEN
       DO:
           glb_cdcritic = 375.
           RUN fontes/critic.p.
           BELL.
           MESSAGE glb_dscritic.
           glb_cdcritic = 0.
           NEXT-PROMPT tel_nmarquiv WITH FRAME f_directory.
           NEXT.
       END.

  ASSIGN aux_cdcooper = glb_cdcooper
         aux_dataini  = tel_dataini
         aux_datafim  = tel_datafin
         aux_cdoperad = tel_cdoperad.

  OUTPUT STREAM str_1 TO VALUE(tel_nmdireto + tel_nmarquiv).

  PUT STREAM str_1 UNFORMATTED 
                   "CONTA;TITULAR;NOME TITULAR;DATA;HORA;DESCRICAO;" + 
                   "COD.OPERADOR;OPERADOR;ORIGEM;TELA;SUCESSO;CRITICA;" +
                   "EMPRESA" SKIP.

  FIND FIRST crapope WHERE crapope.cdcooper = aux_cdcooper AND
                           crapope.cdoperad = aux_cdoperad NO-LOCK NO-ERROR.
                         
  IF   AVAILABLE crapope THEN
       aux_nmoperad = crapope.nmoperad.
  ELSE
       aux_nmoperad = "".
       
  FOR EACH craplgm WHERE craplgm.cdcooper = aux_cdcooper AND
                         craplgm.dttransa >= aux_dataini AND
                         craplgm.dttransa <= aux_datafim AND
                         craplgm.cdoperad = aux_cdoperad
                         NO-LOCK BY craplgm.dttransa
                                 BY craplgm.hrtransa:
                               
      FIND crapttl WHERE crapttl.cdcooper = craplgm.cdcooper AND
                         crapttl.nrdconta = craplgm.nrdconta AND
                         crapttl.idseqttl = craplgm.idseqttl 
                         NO-LOCK NO-ERROR.
                           
      IF   AVAIL crapttl THEN
           ASSIGN aux_nmprimtl = crapttl.nmextttl
                  aux_cdempres = crapttl.cdempres.
      ELSE
           DO:
               FIND crapjur WHERE crapjur.cdcooper = craplgm.cdcooper AND
                                  crapjur.nrdconta = craplgm.nrdconta
                                  NO-LOCK NO-ERROR.
                                                              
               IF   AVAILABLE crapjur THEN
                    ASSIGN aux_nmprimtl = crapjur.nmextttl
                           aux_cdempres = crapjur.cdempres.
               ELSE
                    ASSIGN aux_nmprimtl = ""
                           aux_cdempres = 0.
           END.
    
      IF   aux_cdempres <> 0 THEN
           DO:
               FIND LAST crapemp WHERE crapemp.cdcooper = aux_cdcooper AND
                                       crapemp.cdempres = aux_cdempres
                                       NO-LOCK NO-ERROR.
               
               IF   AVAILABLE crapemp THEN
                    aux_dsempres = STRING(aux_cdempres,"9999") + "-" +
                                   STRING(crapemp.nmresemp,"X(20)").
               ELSE
                    aux_dsempres = STRING(aux_cdempres,"9999") + "-" +
                                   "NAO CADASTRADO".
           END.
      ELSE 
           aux_dsempres = "0000-NAO CADASTRADO".
           
      IF   craplgm.flgtrans THEN
           ASSIGN aux_flgtrans = "SIM".
      ELSE
           ASSIGN aux_flgtrans = "NAO".
      
	  IF   craplgm.dscritic = ? THEN
           ASSIGN aux_dscritic = " ".
      ELSE 
           ASSIGN aux_dscritic = craplgm.dscritic.
	   
      PUT STREAM str_1 UNFORMATTED STRING(craplgm.nrdconta)             + ";" +
                                   STRING(craplgm.idseqttl)             + ";" +
                                          aux_nmprimtl                  + ";" +
                                   STRING(craplgm.dttransa)             + ";" +
                                   STRING(craplgm.hrtransa, "HH:MM:SS") + ";" +
                                          craplgm.dstransa              + ";" +
                                          craplgm.cdoperad              + ";" +
                                          aux_nmoperad                  + ";" +
                                          craplgm.dsorigem              + ";" +
                                          craplgm.nmdatela              + ";" +
                                   STRING(aux_flgtrans)                 + ";" +
                                          aux_dscritic                  + ";" +
                                          aux_dsempres
                                          SKIP.
  END.

  OUTPUT STREAM str_1 CLOSE.

  MESSAGE "Arquivo gerado com sucesso.".
         
  PAUSE 5 NO-MESSAGE.

  HIDE MESSAGE NO-PAUSE.

END PROCEDURE.

/* .......................................................................... */
