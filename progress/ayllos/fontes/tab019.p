/* .............................................................................

   Programa: Fontes/tab019.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Abril/2003                          Ultima alteracao: 07/12/2016
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela TAB019 - Parametro para o desconto de cheques.
   
   Alteracoes: 16/09/2004 - Tratar tempo de filiacao (Edson).
               
               09/11/2004 - Incluido campo Qtd.Devolucoes Cheques(Mirtes)

               15/03/2005 - Incluido campo Tolerancia de limite excedido 
                            (Edson).

               01/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane.

               06/06/2006 - Efetuado acerto de criticas (Mirtes)

               08/12/2006 - Alterado limite prazo de 330 para 360(Mirtes)

               05/12/2008 - Gerar log para as alteracoes da tab (David).
               
               20/05/2009 - Adicionar parametros CECRED
                          - Travar Perc. Multa em 2% Tarefa 23731(Guilherme).
                          
               15/07/2009 - Alteracao CDOPERAD (Diego).
               
               19/03/2012 - Dias minimos devera ser superior a 1 dia e
                            prazo maximo superior a 10 dias (Ze).
                            
               06/11/2013 - Adicionado parametro "Dias/Hora Limite para Resgate".
                            (Fabricio)
                            
               07/12/2016 - Alterado campo dsdepart para cddepart.
                            PRJ341 - BANCENJUD (Odirlei-AMcom)
                            
............................................................................. */

{ includes/var_online.i }

DEF        VAR tel_vllimite AS DECIMAL FORMAT "zzz,zzz,zz9.99"       NO-UNDO.
DEF        VAR cec_vllimite AS DECIMAL FORMAT "zzz,zzz,zz9.99"       NO-UNDO.
DEF        VAR tel_qtdiavig AS INT     FORMAT "zzz9"                 NO-UNDO.
DEF        VAR cec_qtdiavig AS INT     FORMAT "zzz9"                 NO-UNDO.
DEF        VAR tel_qtrenova AS INT     FORMAT "  z9"                 NO-UNDO.
DEF        VAR cec_qtrenova AS INT     FORMAT "  z9"                 NO-UNDO.
DEF        VAR tel_txdmulta AS DECIMAL FORMAT "zz9.999999"           NO-UNDO.
DEF        VAR cec_txdmulta AS DECIMAL FORMAT "zz9.999999"           NO-UNDO.
DEF        VAR tel_qtprzmin AS INT     FORMAT " zz9"                 NO-UNDO.
DEF        VAR cec_qtprzmin AS INT     FORMAT " zz9"                 NO-UNDO.
DEF        VAR tel_qtprzmax AS INT     FORMAT " zz9"                 NO-UNDO.
DEF        VAR cec_qtprzmax AS INT     FORMAT " zz9"                 NO-UNDO.
DEF        VAR tel_pcchqloc AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR cec_pcchqloc AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR tel_pctollim AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR cec_pctollim AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR tel_vlconchq AS DECIMAL FORMAT "zzz,zzz,zz9.99"       NO-UNDO.
DEF        VAR cec_vlconchq AS DECIMAL FORMAT "zzz,zzz,zz9.99"       NO-UNDO.
DEF        VAR tel_vlmaxemi AS DECIMAL FORMAT "zzz,zzz,zz9.99"       NO-UNDO.
DEF        VAR cec_vlmaxemi AS DECIMAL FORMAT "zzz,zzz,zz9.99"       NO-UNDO.
DEF        VAR tel_pcchqemi AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR cec_pcchqemi AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR tel_qtdiasoc AS INT     FORMAT " zz9"                 NO-UNDO.
DEF        VAR cec_qtdiasoc AS INT     FORMAT " zz9"                 NO-UNDO.
DEF        VAR tel_qtdevchq AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR cec_qtdevchq AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR tel_qtdiasli AS INT     FORMAT "99"                   NO-UNDO.
DEF        VAR tel_horalimt AS INT     FORMAT "99"                   NO-UNDO.
DEF        VAR tel_minlimit AS INT     FORMAT "99"                   NO-UNDO.
DEF        VAR cec_qtdiasli AS INT     FORMAT "99"                   NO-UNDO.
DEF        VAR cec_horalimt AS INT     FORMAT "99"                   NO-UNDO.
DEF        VAR cec_minlimit AS INT     FORMAT "99"                   NO-UNDO.

DEF        VAR log_vllimite AS DECIMAL                               NO-UNDO.
DEF        VAR lgc_vllimite AS DECIMAL                               NO-UNDO.
DEF        VAR lgc_qtdiavig AS INT                                   NO-UNDO.
DEF        VAR lgc_qtrenova AS INT                                   NO-UNDO.
DEF        VAR log_txdmulta AS DECIMAL                               NO-UNDO.
DEF        VAR log_qtprzmin AS INT                                   NO-UNDO.
DEF        VAR log_qtprzmax AS INT                                   NO-UNDO.
DEF        VAR lgc_qtprzmax AS INT                                   NO-UNDO.
DEF        VAR log_pcchqloc AS INT                                   NO-UNDO.
DEF        VAR log_pctollim AS INT                                   NO-UNDO.
DEF        VAR lgc_pctollim AS INT                                   NO-UNDO.
DEF        VAR log_vlconchq AS DECIMAL                               NO-UNDO.
DEF        VAR log_vlmaxemi AS DECIMAL                               NO-UNDO.
DEF        VAR lgc_vlmaxemi AS DECIMAL                               NO-UNDO.
DEF        VAR log_pcchqemi AS INT                                   NO-UNDO.
DEF        VAR log_qtdiasoc AS INT                                   NO-UNDO.
DEF        VAR log_qtdevchq AS INT                                   NO-UNDO.
DEF        VAR log_qtdiasli AS INT                                   NO-UNDO.
DEF        VAR lgc_qtdiasli AS INT                                   NO-UNDO.
DEF        VAR log_horalimt AS INT                                   NO-UNDO.
DEF        VAR log_minlimit AS INT                                   NO-UNDO.
DEF        VAR lgc_horalimt AS INT                                   NO-UNDO.
DEF        VAR lgc_minlimit AS INT                                   NO-UNDO.

DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_confirma AS CHAR    FORMAT "!"                    NO-UNDO.

DEF        VAR aux_contador AS INT                                   NO-UNDO.

DEF        VAR aux_horalimt AS INT                                   NO-UNDO.
DEF        VAR aux_horalim2 AS INT                                   NO-UNDO.

FORM 
     glb_cddopcao AT 36 LABEL "Opcao" AUTO-RETURN FORMAT "!"
                        HELP "Entre com a opcao desejada (A,C)."
                        VALIDATE(CAN-DO("A,C",glb_cddopcao),
                                 "014 - Opcao errada.")
     SKIP
     "Operacional" AT 44
     "CECRED"      AT 64
      SKIP
     tel_vllimite AT 16 LABEL "Limite Maximo do Contrato"
                        HELP "Entre com o valor maximo do contrato."
     cec_vllimite AT 60 NO-LABEL
                        HELP "Entre com o valor maximo do contrato."
     tel_vlconchq AT 15 LABEL "Consultar cheques acima de"
                        HELP "Entre com o valor do cheque a ser consultado."
     cec_vlconchq AT 60 NO-LABEL
     tel_vlmaxemi AT  6 LABEL "Valor Maximo Permitido por Emitente"
             HELP "Entre com o valor maximo do cheque permitido por emitente."
     cec_vlmaxemi AT 60 NO-LABEL
             HELP "Entre com o valor maximo do cheque permitido por emitente."
     tel_qtrenova AT 23 LABEL "Qtd. de Renovacoes"
                        "vezes"
     cec_qtrenova AT 60 NO-LABEL
                        HELP "Entre com a quantidade renovacoes do contrato."
                        "vezes"
     
     tel_qtdiavig AT 26 LABEL "Vigencia Minima"
                        "dias"
     cec_qtdiavig AT 60 NO-LABEL
                    HELP "Entre com a quantidade de dias da vigencia minima."
                    "dias"
                    
     tel_qtprzmin AT 29 LABEL "Prazo Minimo"
                  VALIDATE(tel_qtprzmin > 1,
                           "Quantidade deve ser superior a 1 dia.")
                  HELP "Entre com a qtd. de dias de prazo minimo do cheque"
                  "dias"
   
     cec_qtprzmin AT 60 NO-LABEL
                  "dias"

     tel_qtprzmax AT 29 LABEL "Prazo Maximo"
        HELP "Entre com a qtd.de dias de prazo maximo do cheque(Ate 360 dias)"
             "dias"     
     cec_qtprzmax AT 60 NO-LABEL
        HELP "Entre com a qtd.de dias de prazo maximo do cheque(Ate 360 dias)"
             "dias"
     
     tel_qtdiasoc AT 17 LABEL "Tempo Minimo de Filiacao"
                        HELP "Entre com o tempo minino de filiacao."
                        "dias"
     cec_qtdiasoc AT 60 NO-LABEL
                        "dias"

     tel_pcchqemi AT  7 LABEL "Percentual de Cheques por Emitente"
         HELP "Entre com o percentual de cheques por emitente (concentracao)."
         "%"
     cec_pcchqemi AT 60 NO-LABEL     
         "%"

     tel_qtdevchq AT  5 LABEL "Qtd. Cheques Devolvidos por Emitente"
         HELP "Entre com a quantidade de cheques devolvidos por emitente"
     cec_qtdevchq AT 60 NO-LABEL    
     
     tel_pcchqloc AT  5 LABEL "Percentual de Cheques da COMPE Local"
                      HELP "Entre com o percentual de cheques da COMPE local."
                        "%"
     cec_pcchqloc AT 60 NO-LABEL
                        "%"
     
     tel_pctollim AT 10 LABEL "Tolerancia para Limite Excedido"
         HELP "Entre com a tolencia para limite excedido no contrato."
              "%"
     cec_pctollim AT 60 NO-LABEL
         HELP "Entre com a tolencia para limite excedido no contrato."
              "%"

     tel_txdmulta AT 22 LABEL "Percentual de Multa"
                        HELP "Entre com o percentual de multa sobre devolucao."
                        "%"
     cec_txdmulta AT 60 NO-LABEL                        
                        "%"
     tel_qtdiasli AT 12 LABEL "Dias/Hora Limite para Resgate"
         HELP "Entre com a quantidade de dias limite para resgate de cheque."
         VALIDATE(tel_qtdiasli > 0, "Quantidade de dias uteis deve ser maior que zero.")
              "dia(s)/"
     tel_horalimt AT 53 NO-LABEL
         HELP "Entre com o horario limite para resgate de cheque."
         VALIDATE(tel_horalimt > 0, "A hora limite para resgate deve ser maior que zero.")
              ":" AT 55
     tel_minlimit AT 56 NO-LABEL
         HELP "Entre com o horario limite para resgate de cheque."
              "h" AT 58
     cec_qtdiasli AT 61 NO-LABEL
         HELP "Entre com a quantidade de dias limite para resgate de cheque."
         VALIDATE(cec_qtdiasli > 0, "Quantidade de dias uteis deve ser maior que zero.")
              "dia(s)/"
     cec_horalimt AT 71 NO-LABEL
         HELP "Entre com o horario limite para resgate de cheque."
         VALIDATE(cec_horalimt > 0, "A hora limite para resgate deve ser maior que zero.")
              ":" AT 73
     cec_minlimit AT 74 NO-LABEL
         HELP "Entre com o horario limite para resgate de cheque."
              "h" AT 76
     WITH ROW 4 OVERLAY SIDE-LABELS WIDTH 80 TITLE glb_tldatela FRAME f_tab019.

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               CLEAR FRAME f_tab019 NO-PAUSE.
               glb_cdcritic = 0.
           END.

      UPDATE glb_cddopcao  WITH FRAME f_tab019.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.

            IF   CAPS(glb_nmdatela) <> "tab019"   THEN
                 DO:
                     HIDE FRAME f_tab019.
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
        DO TRANSACTION ON ERROR UNDO, NEXT:

           DO WHILE TRUE:
          
              FIND craptab WHERE craptab.cdcooper = glb_cdcooper    AND
                                 craptab.nmsistem = "CRED"          AND
                                 craptab.tptabela = "USUARI"        AND
                                 craptab.cdempres = 11              AND
                                 craptab.cdacesso = "LIMDESCONT"    AND
                                 craptab.tpregist = 0            
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

              IF   NOT AVAILABLE craptab   THEN
                   IF   LOCKED craptab   THEN
                        DO:
                            HIDE MESSAGE NO-PAUSE.
                            MESSAGE "Dados sendo alterados em outro terminal,"
                                    "aguarde..".
                            PAUSE 2 NO-MESSAGE.
                            NEXT.
                        END.
                   ELSE
                        DO:
                            glb_cdcritic = 55.
                            LEAVE.
                        END.
              
              LEAVE.
              
           END.  /*  Fim do DO WHILE TRUE  */

           IF   glb_cdcritic > 0   THEN
                DO:
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.
                    NEXT.
                END.
                 
           ASSIGN tel_vllimite = DECIMAL(SUBSTRING(craptab.dstextab,01,12))
                  cec_vllimite = DECIMAL(SUBSTRING(craptab.dstextab,87,12))
                  cec_qtdiavig = INTEGER(SUBSTRING(craptab.dstextab,14,04))
                  tel_qtdiavig = cec_qtdiavig
                  cec_qtrenova = DECIMAL(SUBSTRING(craptab.dstextab,19,02))
                  tel_qtrenova = cec_qtrenova
                  tel_qtprzmin = DECIMAL(SUBSTRING(craptab.dstextab,22,03))
                  cec_qtprzmin = tel_qtprzmin
                  tel_qtprzmax = DECIMAL(SUBSTRING(craptab.dstextab,26,03))
                  cec_qtprzmax = DECIMAL(SUBSTRING(craptab.dstextab,113,03))
                  tel_txdmulta = DECIMAL(SUBSTRING(craptab.dstextab,30,10))
                  cec_txdmulta = tel_txdmulta
                  tel_vlconchq = DECIMAL(SUBSTRING(craptab.dstextab,41,12))
                  cec_vlconchq = tel_vlconchq
                  tel_vlmaxemi = DECIMAL(SUBSTRING(craptab.dstextab,54,12))
                  cec_vlmaxemi = DECIMAL(SUBSTRING(craptab.dstextab,101,12))
                  tel_pcchqloc = DECIMAL(SUBSTRING(craptab.dstextab,67,03))
                  cec_pcchqloc = tel_pcchqloc
                  tel_pcchqemi = DECIMAL(SUBSTRING(craptab.dstextab,71,03))
                  cec_pcchqemi = tel_pcchqemi
                  tel_qtdiasoc = INTEGER(SUBSTRING(craptab.dstextab,75,03))
                  cec_qtdiasoc = tel_qtdiasoc
                  tel_qtdevchq = INTEGER(SUBSTRING(craptab.dstextab,79,03))
                  cec_qtdevchq = tel_qtdevchq
                  tel_pctollim = DECIMAL(SUBSTRING(craptab.dstextab,83,03))
                  cec_pctollim = DECIMAL(SUBSTRING(craptab.dstextab,117,03))
                  tel_qtdiasli = INTEGER(SUBSTRING(craptab.dstextab,121,02))
                  cec_qtdiasli = INTEGER(SUBSTRING(craptab.dstextab,130,02))
                  tel_horalimt = INT(SUBSTR(STRING(INT(SUBSTRING(craptab.dstextab,124,05)), "HH:MM"),1,2))
                  tel_minlimit = INT(SUBSTR(STRING(INT(SUBSTRING(craptab.dstextab,124,05)), "HH:MM"),4,2))
                  cec_horalimt = INT(SUBSTR(STRING(INT(SUBSTRING(craptab.dstextab,133,05)),"HH:MM"),1,2))
                  cec_minlimit = INT(SUBSTR(STRING(INT(SUBSTRING(craptab.dstextab,133,05)),"HH:MM"),4,2))
                  log_vllimite = tel_vllimite
                  lgc_vllimite = cec_vllimite
                  lgc_qtdiavig = cec_qtdiavig
                  lgc_qtrenova = cec_qtrenova
                  log_qtprzmin = tel_qtprzmin
                  log_qtprzmax = tel_qtprzmax
                  lgc_qtprzmax = cec_qtprzmax
                  log_txdmulta = tel_txdmulta
                  log_vlconchq = tel_vlconchq
                  log_vlmaxemi = tel_vlmaxemi
                  lgc_vlmaxemi = cec_vlmaxemi
                  log_pcchqloc = tel_pcchqloc
                  log_pcchqemi = tel_pcchqemi
                  log_qtdiasoc = tel_qtdiasoc
                  log_qtdevchq = tel_qtdevchq
                  log_pctollim = tel_pctollim
                  lgc_pctollim = cec_pctollim
                  log_qtdiasli = tel_qtdiasli
                  lgc_qtdiasli = cec_qtdiasli
                  log_horalimt = tel_horalimt
                  log_minlimit = tel_minlimit
                  lgc_horalimt = cec_horalimt
                  lgc_minlimit = cec_minlimit.
                                           
           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
           
              DISPLAY tel_qtrenova tel_qtdiavig cec_vllimite cec_vlconchq
                      cec_vlmaxemi cec_qtprzmin cec_qtprzmax cec_qtdiasoc
                      cec_pcchqemi cec_qtdevchq cec_pcchqloc cec_pctollim
                      cec_qtrenova cec_qtdiavig cec_txdmulta tel_qtdiasli
                      cec_qtdiasli tel_horalimt tel_minlimit cec_horalimt
                      cec_minlimit
                      WITH FRAME f_tab019.

              UPDATE tel_vllimite tel_vlconchq tel_vlmaxemi tel_qtprzmin  
                     tel_qtprzmax tel_qtdiasoc tel_pcchqemi tel_qtdevchq  
                     tel_pcchqloc tel_pctollim tel_txdmulta tel_qtdiasli
                     tel_horalimt tel_minlimit WITH FRAME f_tab019

              EDITING:

                 READKEY.
              
                 IF   FRAME-FIELD = "tel_vllimite"  OR
                      FRAME-FIELD = "tel_vlconchq"  OR
                      FRAME-FIELD = "tel_vlmaxemi"  OR
                      FRAME-FIELD = "tel_txdmulta"  THEN
                      IF   LASTKEY =  KEYCODE(".")   THEN
                           APPLY 44.
                      ELSE
                           APPLY LASTKEY.
                 ELSE
                      APPLY LASTKEY.

              END.  /*  Fim do EDITING  */

              IF   tel_qtprzmin > tel_qtprzmax   OR
                   tel_qtprzmax > 360            THEN
                   DO:
                       glb_cdcritic = 26.
                       RUN fontes/critic.p.
                       BELL.
                       MESSAGE glb_dscritic.
                       
                       NEXT-PROMPT tel_qtprzmin WITH FRAME f_tab019.
                       NEXT.
                   END.

              IF  tel_vllimite > cec_vllimite  THEN
                  DO:
                      MESSAGE "O valor deve ser inferior ou igual ao" +
                              " estipulado pela CECRED".
                      NEXT-PROMPT tel_vllimite
                                  WITH FRAME f_tab019.
                      NEXT.

                  END.

              IF  tel_vlmaxemi > cec_vlmaxemi  THEN
                  DO:
                      MESSAGE "O valor deve ser inferior ou igual ao" +
                              " estipulado pela CECRED".
                      NEXT-PROMPT tel_vlmaxemi
                                  WITH FRAME f_tab019.
                      NEXT.

                  END.
              
              IF  tel_qtprzmax > cec_qtprzmax  THEN
                  DO:
                      MESSAGE "O valor deve ser inferior ou igual ao" +
                              " estipulado pela CECRED".
                      NEXT-PROMPT tel_qtprzmax
                                  WITH FRAME f_tab019.
                      NEXT.
                  END.

              IF  tel_pctollim > cec_pctollim  THEN
                  DO:
                      MESSAGE "O valor deve ser inferior ou igual ao" +
                              " estipulado pela CECRED".
                      NEXT-PROMPT tel_pctollim
                                  WITH FRAME f_tab019.
                      NEXT.
                  END.
                  
              IF  tel_txdmulta > 2  THEN
                  DO:
                      MESSAGE "Valor nao deve ser superior a 2% (Exigencia " +
                              "Legal).".
                      NEXT-PROMPT tel_txdmulta
                                  WITH FRAME f_tab019.
                      NEXT.
                  END.

              IF tel_qtdiasli < cec_qtdiasli THEN
              DO:
                  MESSAGE "A qtd de dias deve ser superior ou" +
                          " igual ao estipulado pela CECRED".

                  NEXT-PROMPT tel_qtdiasli WITH FRAME f_tab019.

                  NEXT.
              END.

              IF tel_qtdiasli = cec_qtdiasli THEN
              DO:
                  IF tel_horalimt > cec_horalimt THEN
                  DO:
                      MESSAGE "O horario deve ser inferior ou igual " +
                              "ao estipulado pela CECRED".

                      NEXT-PROMPT tel_horalimt WITH FRAME f_tab019.

                      NEXT.
                  END.

                  IF (tel_horalimt = cec_horalimt) AND 
                     (tel_minlimit > cec_minlimit) THEN
                  DO:
                      MESSAGE "O horario deve ser inferior ou igual " +
                              "ao estipulado pela CECRED".

                      NEXT-PROMPT tel_minlimit WITH FRAME f_tab019.

                      NEXT.
                  END.
              END.

              IF  NOT CAN-DO("14," + /* PRODUTOS */
                             "8,"  + /* COORD.ADM/FINANCEIRO*/
                             "20"    /* TI*/
                             ,STRING(glb_cddepart))
                      THEN
                  DO:
                      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
                         aux_confirma = "N".
        
                         glb_cdcritic = 78.
                         RUN fontes/critic.p.
                         BELL.
                         glb_cdcritic = 0.
                         MESSAGE COLOR NORMAL glb_dscritic 
                         UPDATE aux_confirma.
                         LEAVE.
        
                      END.
        
                      IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                           aux_confirma <> "S" THEN
                           DO:
                               glb_cdcritic = 79.
                               RUN fontes/critic.p.
                               BELL.
                               MESSAGE glb_dscritic.
                               glb_cdcritic = 0.
                               NEXT.
                           END.
                  END.
              LEAVE.

           END.  /*  Fim do DO WHILE TRUE  */
           IF  CAN-DO( "14," + /* PRODUTOS */
                       "8,"  + /* COORD.ADM/FINANCEIRO*/
                       "20"    /* TI*/
                       ,STRING(glb_cddepart)) THEN
               DO:
                   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                   
                      UPDATE cec_vllimite  cec_vlmaxemi
                             cec_qtrenova  cec_qtdiavig
                             cec_qtprzmax  cec_pctollim  
                             cec_qtdiasli  cec_horalimt
                             cec_minlimit
                             WITH FRAME f_tab019
        
                      EDITING:
        
                         READKEY.
                      
                         IF   FRAME-FIELD = "cec_vllimite"  OR
                              FRAME-FIELD = "cec_vlmaxemi"  THEN
                              IF   LASTKEY =  KEYCODE(".")   THEN
                                   APPLY 44.
                              ELSE
                                   APPLY LASTKEY.
                         ELSE
                              APPLY LASTKEY.
        
                      END.  /*  Fim do EDITING  */
        
                      IF  tel_vllimite > cec_vllimite  THEN
                          DO:
                              MESSAGE "O valor não pode ser menor que o da" +
                                      " cooperativa.".
                              NEXT-PROMPT cec_vllimite
                                          WITH FRAME f_tab019.
                              NEXT.

                          END.

                      IF  tel_vlmaxemi > cec_vlmaxemi  THEN
                          DO:
                              MESSAGE "O valor não pode ser menor que o da" +
                                      " cooperativa.".
                              NEXT-PROMPT cec_vlmaxemi
                                          WITH FRAME f_tab019.
                              NEXT.

                          END.
                      IF  tel_qtprzmax > cec_qtprzmax  THEN
                          DO:
                              MESSAGE "O valor não pode ser menor que o da" +
                                      " cooperativa.".
                              NEXT-PROMPT cec_qtprzmax
                                          WITH FRAME f_tab019.
                              NEXT.
                          END.

                      IF  tel_pctollim > cec_pctollim  THEN
                          DO:
                              MESSAGE "O valor não pode ser menor que o da" +
                                      " cooperativa.".
                              NEXT-PROMPT cec_pctollim
                                          WITH FRAME f_tab019.
                              NEXT.
                          END.
                      
                      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
                         aux_confirma = "N".
        
                         glb_cdcritic = 78.
                         RUN fontes/critic.p.
                         BELL.
                         glb_cdcritic = 0.
                         MESSAGE COLOR NORMAL glb_dscritic 
                         UPDATE aux_confirma.
                         LEAVE.
        
                      END.
        
                      IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                           aux_confirma <> "S" THEN
                           DO:
                               glb_cdcritic = 79.
                               RUN fontes/critic.p.
                               BELL.
                               MESSAGE glb_dscritic.
                               glb_cdcritic = 0.
                               NEXT.
                           END.
        
                      LEAVE.
        
                   END.  /*  Fim do DO WHILE TRUE  */
               END.

           IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /*   F4 OU FIM */
                NEXT.
           
           ASSIGN aux_horalimt = ((tel_horalimt * 60) * 60) +
                                  (tel_minlimit * 60)
                  aux_horalim2 = ((cec_horalimt * 60) * 60) +
                                  (cec_minlimit * 60).
             
           craptab.dstextab = STRING(tel_vllimite,"999999999.99") + " " +
                              STRING(cec_qtdiavig,"9999")         + " " +
                              STRING(cec_qtrenova,"99")           + " " +
                              STRING(tel_qtprzmin,"999")          + " " +
                              STRING(tel_qtprzmax,"999")          + " " +
                              STRING(tel_txdmulta,"999.999999")   + " " +
                              STRING(tel_vlconchq,"999999999.99") + " " +
                              STRING(tel_vlmaxemi,"999999999.99") + " " +
                              STRING(tel_pcchqloc,"999")          + " " +
                              STRING(tel_pcchqemi,"999")          + " " +
                              STRING(tel_qtdiasoc,"999")          + " " +
                              STRING(tel_qtdevchq,"999")          + " " +
                              STRING(tel_pctollim,"999")          + " " +
                              STRING(cec_vllimite,"999999999.99") + " " +
                              STRING(cec_vlmaxemi,"999999999.99") + " " +
                              STRING(cec_qtprzmax,"999")          + " " +
                              STRING(cec_pctollim,"999")          + " " +
                              STRING(tel_qtdiasli,"99")           + " " +
                              STRING(aux_horalimt,"99999")        + " " +
                              STRING(cec_qtdiasli,"99")           + " " +
                              STRING(aux_horalim2,"99999").
                           
           IF   log_vllimite <> tel_vllimite   THEN
                UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + 
                     " " + STRING(TIME,"HH:MM:SS") + "' --> '" +
                     "Operador " + glb_cdoperad +
                     " alterou o limite maximo do contrato de R$ " +
                     TRIM(STRING(log_vllimite,"zzz,zzz,zz9.99")) + " para R$ " +
                     TRIM(STRING(tel_vllimite,"zzz,zzz,zz9.99")) + 
                     " >> log/tab019.log").
           
           IF   lgc_vllimite <> cec_vllimite   THEN
                UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + 
                     " " + STRING(TIME,"HH:MM:SS") + "' --> '" +
                     "Operador " + glb_cdoperad +
                     " alterou o limite maximo do contrato CECRED de R$ " +
                     TRIM(STRING(lgc_vllimite,"zzz,zzz,zz9.99")) + " para R$ " +
                     TRIM(STRING(cec_vllimite,"zzz,zzz,zz9.99")) + 
                     " >> log/tab019.log").
                    
           IF   lgc_qtdiavig <> cec_qtdiavig   THEN
                UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + 
                     " " + STRING(TIME,"HH:MM:SS") + "' --> '" +
                     "Operador " + glb_cdoperad +
                     " alterou a qtd. de dias da vigencia minima de " +
                     TRIM(STRING(lgc_qtdiavig,"zzz9")) + " para " + 
                     TRIM(STRING(cec_qtdiavig,"zzz9")) + " >> log/tab019.log").
                                
           IF   lgc_qtrenova <> cec_qtrenova   THEN
                UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + 
                     " " + STRING(TIME,"HH:MM:SS") + "' --> '" +
                     "Operador " + glb_cdoperad +
                     " alterou a qtd. de renovacoes do contrato de " +
                     TRIM(STRING(lgc_qtrenova,"z9")) + " para " + 
                     TRIM(STRING(cec_qtrenova,"z9")) + " >> log/tab019.log").
                
           IF   log_qtprzmin <> tel_qtprzmin   THEN 
                UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + 
                     " " + STRING(TIME,"HH:MM:SS") + "' --> '" +
                     "Operador " + glb_cdoperad +
                     " alterou a qtd. de dias de prazo minimo do cheque de " +
                     TRIM(STRING(log_qtprzmin,"zz9")) + " para " + 
                     TRIM(STRING(tel_qtprzmin,"zz9")) + " >> log/tab019.log").
                     
           IF   log_qtprzmax <> tel_qtprzmax   THEN
                UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + 
                     " " + STRING(TIME,"HH:MM:SS") + "' --> '" +
                     "Operador " + glb_cdoperad +
                     " alterou a qtd. de dias de prazo maximo do cheque de " +
                     TRIM(STRING(log_qtprzmax,"zz9")) + " para " + 
                     TRIM(STRING(tel_qtprzmax,"zz9")) + " >> log/tab019.log").
                                
           IF   lgc_qtprzmax <> cec_qtprzmax   THEN
                UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + 
                     " " + STRING(TIME,"HH:MM:SS") + "' --> '" +
                     "Operador " + glb_cdoperad +
                     " alterou a qtd. de dias de prazo maximo do cheque " +
                     "CECRED de " +
                     TRIM(STRING(lgc_qtprzmax,"zz9")) + " para " + 
                     TRIM(STRING(cec_qtprzmax,"zz9")) + " >> log/tab019.log").


           IF   log_txdmulta <> tel_txdmulta   THEN
                UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + 
                     " " + STRING(TIME,"HH:MM:SS") + "' --> '" +
                     "Operador " + glb_cdoperad +
                     " alterou o percentual de multa sobre devolucao de " +
                     TRIM(STRING(log_txdmulta,"zz9.999999")) + "% para " + 
                     TRIM(STRING(tel_txdmulta,"zz9.999999")) + 
                     "% >> log/tab019.log").
                                
           IF   log_vlconchq <> tel_vlconchq   THEN
                UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + 
                     " " + STRING(TIME,"HH:MM:SS") + "' --> '" +
                     "Operador " + glb_cdoperad +
                     " alterou o valor do cheque a ser consultado de R$ " +
                     TRIM(STRING(log_vlconchq,"zzz,zzz,zz9.99")) + " para R$ " +
                     TRIM(STRING(tel_vlconchq,"zzz,zzz,zz9.99")) +
                     " >> log/tab019.log").
                                
           IF   log_vlmaxemi <> tel_vlmaxemi   THEN
                UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + 
                     " " + STRING(TIME,"HH:MM:SS") + "' --> '" +
                     "Operador " + glb_cdoperad +
                     " alterou o valor maximo permitido por emitente de R$ " +
                     TRIM(STRING(log_vlmaxemi,"zzz,zzz,zz9.99")) + " para R$ " +
                     TRIM(STRING(tel_vlmaxemi,"zzz,zzz,zz9.99")) + 
                     " >> log/tab019.log").
                                
           IF   lgc_vlmaxemi <> cec_vlmaxemi   THEN
                UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + 
                     " " + STRING(TIME,"HH:MM:SS") + "' --> '" +
                     "Operador " + glb_cdoperad +
                     " alterou o valor maximo permitido por emitente " +
                     "CECRED de R$ " +
                     TRIM(STRING(log_vlmaxemi,"zzz,zzz,zz9.99")) + " para R$ " +
                     TRIM(STRING(tel_vlmaxemi,"zzz,zzz,zz9.99")) + 
                     " >> log/tab019.log").


           IF   log_pcchqloc <> tel_pcchqloc   THEN
                UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + 
                     " " + STRING(TIME,"HH:MM:SS") + "' --> '" +
                     "Operador " + glb_cdoperad +
                     " alterou o percentual de cheques da COMPE local de " +
                     TRIM(STRING(log_pcchqloc,"zz9")) + "% para " + 
                     TRIM(STRING(tel_pcchqloc,"zz9")) + "% >> log/tab019.log").
                     
           IF   log_pcchqemi <> tel_pcchqemi   THEN
                UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + 
                     " " + STRING(TIME,"HH:MM:SS") + "' --> '" +
                     "Operador " + glb_cdoperad +
                     " alterou o percentual de cheques por emitente de " +
                     TRIM(STRING(log_pcchqemi,"zz9")) + "% para " + 
                     TRIM(STRING(tel_pcchqemi,"zz9")) + "% >> log/tab019.log").
                                
           IF   log_qtdiasoc <> tel_qtdiasoc   THEN
                UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + 
                     " " + STRING(TIME,"HH:MM:SS") + "' --> '" +
                     "Operador " + glb_cdoperad +
                     " alterou o tempo minimo de filiacao de " +
                     TRIM(STRING(log_qtdiasoc,"zz9")) + " para " + 
                     TRIM(STRING(tel_qtdiasoc,"zz9")) + " >> log/tab019.log").
                                
           IF   log_qtdevchq <> tel_qtdevchq   THEN
                UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + 
                     " " + STRING(TIME,"HH:MM:SS") + "' --> '" +
                     "Operador " + glb_cdoperad +
                     " alterou a qtd. de cheques devolvidos por emitente de " +
                     TRIM(STRING(log_qtdevchq,"zz9")) + " para " + 
                     TRIM(STRING(tel_qtdevchq,"zz9")) + " >> log/tab019.log").
                                
           IF   log_pctollim <> tel_pctollim   THEN
                UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + 
                     " " + STRING(TIME,"HH:MM:SS") + "' --> '" +
                     "Operador " + glb_cdoperad +
                     " alterou a tolencia para limite excedido no contrato de "
                     + TRIM(STRING(log_pctollim,"zz9")) + "% para " + 
                     TRIM(STRING(tel_pctollim,"zz9")) + "% >> log/tab019.log").
                                       
           IF   lgc_pctollim <> cec_pctollim   THEN
                UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + 
                     " " + STRING(TIME,"HH:MM:SS") + "' --> '" +
                     "Operador " + glb_cdoperad +
                     " alterou a tolencia para limite excedido no contrato " +
                     "CECRED de "
                     + TRIM(STRING(lgc_pctollim,"zz9")) + "% para " + 
                     TRIM(STRING(cec_pctollim,"zz9")) + "% >> log/tab019.log").
           
           IF ((log_qtdiasli <> tel_qtdiasli) OR 
               (log_horalimt <> tel_horalimt) OR
               (log_minlimit <> tel_minlimit)) THEN
               UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + 
                     " " + STRING(TIME,"HH:MM:SS") + "' --> '" +
                     "Operador " + glb_cdoperad +
                     " alterou a quantidade de dias/hora limite para resgate" +
                     " de cheque de "
                     + TRIM(STRING(log_qtdiasli,"99")) + " dia'('s')'/"
                     + TRIM(STRING(log_horalimt,"99")) + ":"
                     + TRIM(STRING(log_minlimit,"99")) + "h para "
                     + TRIM(STRING(tel_qtdiasli,"99")) + " dia'('s')'/"
                     + TRIM(STRING(tel_horalimt,"99")) + ":"
                     + TRIM(STRING(tel_minlimit,"99")) + "h"
                     + " >> log/tab019.log").
           
           IF ((lgc_qtdiasli <> cec_qtdiasli) OR 
               (lgc_horalimt <> cec_horalimt) OR
               (lgc_minlimit <> cec_minlimit)) THEN
               UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + 
                     " " + STRING(TIME,"HH:MM:SS") + "' --> '" +
                     "Operador " + glb_cdoperad +
                     " alterou a quantidade de dias/hora limite para resgate" +
                     " de cheque CECRED de "
                     + TRIM(STRING(lgc_qtdiasli,"99")) + " dia'('s')'/"
                     + TRIM(STRING(lgc_horalimt,"99")) + ":"
                     + TRIM(STRING(lgc_minlimit,"99")) + "h para "
                     + TRIM(STRING(cec_qtdiasli,"99")) + " dia'('s')'/"
                     + TRIM(STRING(cec_horalimt,"99")) + ":"
                     + TRIM(STRING(cec_minlimit,"99")) + "h"
                     + " >> log/tab019.log").
             
                                        
           CLEAR FRAME f_tab019 NO-PAUSE.

        END.  /*  Fim do DO TRANSACTION  */
   ELSE
   IF   glb_cddopcao = "C" THEN
        DO:
            FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                               craptab.nmsistem = "CRED"        AND
                               craptab.tptabela = "USUARI"      AND
                               craptab.cdempres = 11            AND
                               craptab.cdacesso = "LIMDESCONT"  AND
                               craptab.tpregist = 0
                               NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE craptab   THEN
                 DO:
                     glb_cdcritic = 55.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                                        
                     NEXT.
                 END.
      
           ASSIGN tel_vllimite = DECIMAL(SUBSTRING(craptab.dstextab,01,12))
                  cec_vllimite = DECIMAL(SUBSTRING(craptab.dstextab,87,12))
                  cec_qtdiavig = INTEGER(SUBSTRING(craptab.dstextab,14,04))
                  tel_qtdiavig = cec_qtdiavig
                  cec_qtrenova = DECIMAL(SUBSTRING(craptab.dstextab,19,02))
                  tel_qtrenova = cec_qtrenova
                  tel_qtprzmin = DECIMAL(SUBSTRING(craptab.dstextab,22,03))
                  cec_qtprzmin = tel_qtprzmin
                  tel_qtprzmax = DECIMAL(SUBSTRING(craptab.dstextab,26,03))
                  cec_qtprzmax = DECIMAL(SUBSTRING(craptab.dstextab,113,03))
                  tel_txdmulta = DECIMAL(SUBSTRING(craptab.dstextab,30,10))
                  cec_txdmulta = tel_txdmulta
                  tel_vlconchq = DECIMAL(SUBSTRING(craptab.dstextab,41,12))
                  cec_vlconchq = tel_vlconchq
                  tel_vlmaxemi = DECIMAL(SUBSTRING(craptab.dstextab,54,12))
                  cec_vlmaxemi = DECIMAL(SUBSTRING(craptab.dstextab,101,12))
                  tel_pcchqloc = DECIMAL(SUBSTRING(craptab.dstextab,67,03))
                  cec_pcchqloc = tel_pcchqloc
                  tel_pcchqemi = DECIMAL(SUBSTRING(craptab.dstextab,71,03))
                  cec_pcchqemi = tel_pcchqemi
                  tel_qtdiasoc = INTEGER(SUBSTRING(craptab.dstextab,75,03))
                  cec_qtdiasoc = tel_qtdiasoc
                  tel_qtdevchq = INTEGER(SUBSTRING(craptab.dstextab,79,03))
                  cec_qtdevchq = tel_qtdevchq
                  tel_pctollim = DECIMAL(SUBSTRING(craptab.dstextab,83,03))
                  cec_pctollim = DECIMAL(SUBSTRING(craptab.dstextab,117,03))
                  tel_qtdiasli = INTEGER(SUBSTRING(craptab.dstextab,121,02))
                  cec_qtdiasli = INTEGER(SUBSTRING(craptab.dstextab,130,02))
                  tel_horalimt = INT(SUBSTR(STRING(INT(SUBSTRING(craptab.dstextab,124,05)), "HH:MM"),1,2))
                  tel_minlimit = INT(SUBSTR(STRING(INT(SUBSTRING(craptab.dstextab,124,05)), "HH:MM"),4,2))
                  cec_horalimt = INT(SUBSTR(STRING(INT(SUBSTRING(craptab.dstextab,133,05)),"HH:MM"),1,2))
                  cec_minlimit = INT(SUBSTR(STRING(INT(SUBSTRING(craptab.dstextab,133,05)),"HH:MM"),4,2)).

            DISPLAY tel_vllimite tel_qtprzmin tel_qtprzmax tel_txdmulta 
                    tel_vlconchq tel_vlmaxemi tel_pcchqloc tel_pcchqemi 
                    tel_qtdevchq tel_pctollim tel_qtdiasoc tel_qtrenova 
                    tel_qtdiavig cec_vllimite cec_vlconchq cec_vlmaxemi 
                    cec_qtprzmin cec_qtprzmax cec_qtdiasoc cec_pcchqemi 
                    cec_qtdevchq cec_pcchqloc cec_pctollim cec_qtrenova 
                    cec_qtdiavig cec_txdmulta tel_qtdiasli tel_horalimt
                    tel_minlimit cec_qtdiasli cec_horalimt cec_minlimit
                    WITH FRAME f_tab019.                    
        END.

   RELEASE craptab.

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */
                                                                   
