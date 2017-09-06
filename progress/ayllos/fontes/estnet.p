/* ............................................................................

   Programa: fontes/estnet.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Abril/2008                        Ultima atualizacao: 01/09/2017

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela ESTNET - Estorno de pagamentos de titulos e
               faturas efetuados atraves da internet.

   Alteracoes: 08/12/2008 - Chamar programa pcrap04.p em vez do pcrap03.p
                            (David).
                            
               27/05/2010 - Permitir o PAC 91 - TAA (Evandro).
               
               23/06/2010 - Ajuste no tratamento de escolha de PAC (Evandro).
               
               03/02/2011 - Inserido FORMAT "x(40)" para crapass.nmprimtl
                            (Diego).
                            
               04/03/2011 - Nao mostrar titulos DDA (David).
               
               05/06/2013 - Adicionados valores de multa e juros ao valor total
                            das faturas, para DARFs (Lucas).
                            
               13/08/2013 - Nova forma de chamar as agências, alterado para
                          "Posto de Atendimento" (PA). (André Santos - SUPERO)             
                          
               05/12/2013 - Inclusao de VALIDATE craptab (Carlos) 
                         
			   09/03/2016 - Alterado para validar o campo Cancelamento de 
							Pagamentos e não mais validar o campo 
							Pagamentos Titulos/Faturas. 
							(RKAM Gisele Campos Neves - Chamado 408875)
							
			   07/11/2016 - Desconsiderar Guias DARF/DAS pois não podem ser
			                estornadas - Projeto 338 (David)
							
               30/06/2017 - Validar saida de critica para as procedures
                            (Lucas Ranghetti #674894)

               01/09/2017 - Permitir estorno de titulos DDA (Rafael)
............................................................................. */

{ includes/var_online.i }

DEF VAR tel_cdagenci    LIKE crapage.cdagenci                       NO-UNDO.
DEF VAR tel_nrdcaixa    LIKE crapbcx.nrdcaixa                       NO-UNDO.
DEF VAR tel_cdoperad    LIKE crapope.cdoperad                       NO-UNDO.
DEF VAR tel_nrdconta    LIKE crapass.nrdconta                       NO-UNDO.

DEF VAR aux_contador    AS INT                                      NO-UNDO.
DEF VAR aux_confirma    AS CHAR         FORMAT "!(1)"               NO-UNDO.
DEF VAR aux_cdfatura    AS DEC                                      NO-UNDO.
DEF VAR aux_cddigito    AS INT                                      NO-UNDO.
DEF VAR aux_flgretbo    AS LOGICAL                                  NO-UNDO.
DEF VAR aux_cdhistor    AS INTE                                     NO-UNDO.
DEF VAR aux_flgpagto    AS LOG                                      NO-UNDO.
DEF VAR aux_nrdocmto    AS DEC                                      NO-UNDO.
DEF VAR aux_dslitera    AS CHAR                                     NO-UNDO.
DEF VAR aux_nrsequen    AS INTE                                     NO-UNDO.
DEF VAR aux_nrdrecid    AS RECID                                    NO-UNDO.
DEF VAR aux_nrdrowid    AS ROWID                                    NO-UNDO.
        
DEF VAR aux_fltransa    AS LOGICAL                                  NO-UNDO.
DEF VAR aux_dstransa    AS CHAR                                     NO-UNDO.
DEF VAR aux_dscritic    LIKE crapcri.dscritic                       NO-UNDO.
DEF VAR aux_dsprotoc    LIKE crappro.dsprotoc                       NO-UNDO.

DEF VAR aut_flgsenha    AS LOGICAL                                  NO-UNDO.
DEF VAR aut_cdoperad    AS CHAR                                     NO-UNDO.
DEF VAR aux_idorigem    AS INT                                      NO-UNDO.
        
DEF VAR h-b1wgen0016    AS HANDLE                                   NO-UNDO.
DEF VAR h-b1wgen0014    AS HANDLE                                   NO-UNDO.

DEF TEMP-TABLE w_doctos                                             NO-UNDO
    FIELD cdbarras  LIKE craplft.cdbarras
    FIELD cdseqdoc  LIKE craplft.cdseqfat
    FIELD dsbarras  LIKE craplft.cdbarras
    FIELD vllanmto  LIKE craplft.vllanmto
    FIELD tpdocmto  AS LOGICAL  FORMAT "FAT/TIT"
    FIELD cdagenci  LIKE craptit.cdagenci
    FIELD dtmvtolt  LIKE craptit.dtmvtolt
    FIELD cdctrbxo  LIKE craptit.cdctrbxo
    FIELD nrdident  LIKE craptit.nrdident.
    
DEF QUERY q_doctos FOR w_doctos.
    
DEF BROWSE b_doctos QUERY q_doctos
    DISPLAY w_doctos.dsbarras       COLUMN-LABEL "Codigo de Barras"
                                    FORMAT "x(55)"
            w_doctos.vllanmto       COLUMN-LABEL "Valor"
                                    FORMAT "zzzz,zz9.99"
            w_doctos.tpdocmto       COLUMN-LABEL "Tipo"
            WITH 7 DOWN NO-BOX.

FORM SKIP(1)
     tel_cdagenci       AT  8   LABEL "PA"
                                HELP "Informe 90 - INTERNET ou 91 - TAA"
                                VALIDATE(tel_cdagenci = 90 OR
                                         tel_cdagenci = 91,"PA Invalido")
     "-"                AT 17 
     crapage.nmresage   AT 19   NO-LABEL            FORMAT "x(10)"
     tel_nrdcaixa       AT 32   LABEL "Caixa"
     glb_dtmvtolt       AT 49   LABEL "Data"        FORMAT "99/99/9999"
     SKIP(1)
     tel_nrdconta       AT  3   LABEL "Conta/dv"
                                HELP "Informe o numero da Conta/dv."
     crapass.nmprimtl   AT 30   LABEL "Titular"     FORMAT "x(40)"
     WITH ROW 4 SIZE 80 BY 18 OVERLAY SIDE-LABELS TITLE glb_tldatela
          FRAME f_estnet.
          
FORM b_doctos   HELP "Pressione ENTER para estornar ou F4/END para sair."
     WITH ROW 10 COLUMN 2 OVERLAY SIDE-LABELS TITLE " Documentos Pagos "
               FRAME f_doctos.
     
ON  RETURN OF b_doctos IN FRAME f_doctos DO:

    IF   NOT AVAILABLE w_doctos   THEN
         LEAVE.
         
    /* Confirma */
    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
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
             PAUSE 3 NO-MESSAGE.
             LEAVE.
         END. /* Mensagem de confirmacao */
    
    /* Faturas */
    IF   w_doctos.tpdocmto = YES   THEN
         DO:
             RUN sistema/generico/procedures/b1wgen0016.p             
                 PERSISTENT SET h-b1wgen0016.
                 
             IF   VALID-HANDLE(h-b1wgen0016)   THEN
                  DO:
                      RUN estorna_convenio IN h-b1wgen0016
                                             (INPUT  glb_cdcooper,
                                              INPUT  tel_nrdconta,
                                              INPUT  1, /* Titularidade */
                                              INPUT  w_doctos.cdbarras,
                                              INPUT  "",
                                              INPUT  w_doctos.cdseqdoc,
                                              INPUT  w_doctos.vllanmto,
                                              INPUT  glb_cdoperad,
                                              INPUT  aux_idorigem,
                                              OUTPUT aux_dstransa,
                                              OUTPUT aux_dscritic,
                                              OUTPUT aux_dsprotoc).

                      DELETE PROCEDURE h-b1wgen0016.
                  END.
         END.
    ELSE
    /* Titulos */
         DO:
             RUN sistema/generico/procedures/b1wgen0016.p
                 PERSISTENT SET h-b1wgen0016.
                 
             IF   VALID-HANDLE(h-b1wgen0016)   THEN
                  DO:
                      RUN estorna_titulo IN h-b1wgen0016
                                            (INPUT  glb_cdcooper,
                                             INPUT  w_doctos.cdagenci,
                                             INPUT  w_doctos.dtmvtolt,
                                             INPUT  tel_nrdconta,
                                             INPUT  1, /* Titularidade */
                                             INPUT  w_doctos.cdbarras,
                                             INPUT  "",
                                             INPUT  w_doctos.vllanmto,
                                             INPUT  glb_cdoperad,
                                             INPUT  aux_idorigem,
                                             INPUT  w_doctos.cdctrbxo,
                                             INPUT  w_doctos.nrdident,
                                             OUTPUT aux_dstransa,
                                             OUTPUT aux_dscritic,
                                             OUTPUT aux_dsprotoc).

                      DELETE PROCEDURE h-b1wgen0016.
                  END.
         END.
         
    /* Status da transacao */
    aux_fltransa = IF   RETURN-VALUE = "OK"   THEN
                        YES
                   ELSE NO.

    /* Log da operacao realizada */         
    RUN sistema/generico/procedures/b1wgen0014.p PERSISTENT 
        SET h-b1wgen0014.
        
    IF   VALID-HANDLE(h-b1wgen0014)   THEN
         DO:
             RUN gera_log IN h-b1wgen0014 (INPUT glb_cdcooper,
                                           INPUT glb_cdoperad,
                                           INPUT aux_dscritic,
                                           INPUT "AYLLOS",
                                           INPUT aux_dstransa,
                                           INPUT glb_dtmvtolt,
                                           INPUT aux_fltransa,
                                           INPUT TIME,
                                           INPUT 1,
                                           INPUT "ESTNET",
                                           INPUT tel_nrdconta,
                                           OUTPUT aux_nrdrowid).
                                           
             IF   RETURN-VALUE = "OK"   THEN
                  DO:
                      RUN gera_log_item IN h-b1wgen0014 
                                              (INPUT aux_nrdrowid,
                                               INPUT "Representacao Numerica",
                                               INPUT "",
                                               INPUT w_doctos.cdbarras).
                                                            
                      RUN gera_log_item IN h-b1wgen0014 
                                              (INPUT aux_nrdrowid,
                                               INPUT "Valor",
                                               INPUT "",
                                               INPUT STRING(w_doctos.vllanmto,
                                                            "z,zzz,zz9.99")).
                                                            
                      RUN gera_log_item IN h-b1wgen0014 
                                              (INPUT aux_nrdrowid,
                                               INPUT "Protocolo",
                                               INPUT "",
                                               INPUT aux_dsprotoc).
                  END.

             DELETE PROCEDURE h-b1wgen0014.
         END.
    
    IF   NOT aux_fltransa   THEN
         DO:
             BELL.
             MESSAGE aux_dscritic.
             PAUSE 3 NO-MESSAGE.
             LEAVE.
         END.


    DELETE w_doctos.
         
    CLOSE QUERY q_doctos.
    OPEN QUERY q_doctos FOR EACH w_doctos.
END. /* Fim do ON RETURN */



/*--- Controle de 1 operador utilizando tela --*/  
DO  WHILE TRUE:

    FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND       
                       craptab.nmsistem = "CRED"         AND
                       craptab.tptabela = "GENERI"       AND
                       craptab.cdempres = glb_cdcooper   AND         
                       craptab.cdacesso = "ESTNET"       AND
                       craptab.tpregist = 1
                       NO-LOCK NO-ERROR.
            
    IF   NOT AVAIL craptab   THEN
         DO TRANSACTION:
             CREATE craptab.
             ASSIGN craptab.nmsistem = "CRED"      
                    craptab.tptabela = "GENERI"          
                    craptab.cdempres = glb_cdcooper            
                    craptab.cdacesso = "ESTNET"                
                    craptab.tpregist = 1  
                    craptab.cdcooper = glb_cdcooper
                    craptab.dstextab = glb_cdoperad + "-" + glb_nmoperad.

             VALIDATE craptab.

             LEAVE.
         END.
    ELSE
         DO:
             IF   craptab.dstextab <> ""   THEN
                  DO:
                      MESSAGE "Processo sendo utilizado pelo Operador " +
                              TRIM(SUBSTR(craptab.dstextab,1,20)).
                      MESSAGE "Peca liberacao Coordenador ou Aguarde...".
                      
                      PAUSE 3 NO-MESSAGE.
                    
                      RUN fontes/pedesenha.p (INPUT glb_cdcooper,  
                                              INPUT 2, 
                                              OUTPUT aut_flgsenha,
                                              OUTPUT aut_cdoperad).
                  END.
             ELSE
                  aut_flgsenha = YES.
                  
             IF   aut_flgsenha   THEN
                  DO  TRANSACTION:
                  
                      FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                                         craptab.nmsistem = "CRED"         AND
                                         craptab.tptabela = "GENERI"       AND
                                         craptab.cdempres = glb_cdcooper   AND
                                         craptab.cdacesso = "ESTNET"       AND
                                         craptab.tpregist = 1
                                         EXCLUSIVE-LOCK NO-ERROR.
                      
                      IF   AVAILABLE craptab   THEN
                           craptab.dstextab = glb_cdoperad + "-" +
                                              glb_nmoperad.
                      LEAVE.
                  END.
                  
            IF   KEY-FUNCTION(LASTKEY) = "END-ERROR"   THEN
                 DO:
                    /* Forca a saida para a tela do MENU */
                    glb_nmdatela = "".
                    RETURN.
                 END.
         END.
END. /* Fim da Transacao */


DO  WHILE TRUE:
    
    RUN fontes/inicia.p.

    /* permite escolher entre os PA's:
       90 - INTERNET
       91 - TAA */
    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
        UPDATE tel_cdagenci tel_nrdconta WITH FRAME f_estnet.
        LEAVE.
    END.

    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
         DO:
             RUN fontes/novatela.p.
             IF   glb_nmdatela <> "ESTNET"   THEN
                  DO:
                      HIDE FRAME f_moldura.
                      HIDE FRAME f_atenda.
                      
                      IF   AVAILABLE craptab   THEN
                           DO  TRANSACTION:
                               
                               FIND craptab WHERE
                                    craptab.cdcooper = glb_cdcooper    AND
                                    craptab.nmsistem = "CRED"         AND
                                    craptab.tptabela = "GENERI"       AND
                                    craptab.cdempres = glb_cdcooper   AND
                                    craptab.cdacesso = "ESTNET"       AND
                                    craptab.tpregist = 1
                                    EXCLUSIVE-LOCK NO-ERROR.
                               
                               IF   AVAILABLE craptab   THEN
                                    craptab.dstextab = "".
                           END.
                      
                      RETURN.
                  END.
             ELSE
                  NEXT.
         END.

    
    /* Fixo */
    ASSIGN tel_nrdcaixa = 900
           tel_cdoperad = "996"
           glb_cddopcao = "E"
           aux_idorigem = IF  tel_cdagenci = 90  THEN
                              3  /* INTERNET */
                          ELSE
                              4. /* CASH/TAA */

    { includes/acesso.i }
           
    FIND crapage WHERE crapage.cdcooper = glb_cdcooper   AND
                       crapage.cdagenci = tel_cdagenci
                       NO-LOCK NO-ERROR.
                                           
    /* Verifica se os pagamentos ja foram enviados */
    FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                       craptab.nmsistem = "CRED"        AND
                       craptab.tptabela = "GENERI"      AND
                       craptab.cdempres = 00            AND
                       craptab.cdacesso = "HRTRTITULO"  AND
                       craptab.tpregist = tel_cdagenci
                       NO-LOCK NO-ERROR.                   
    DISPLAY tel_cdagenci
            crapage.nmresage
            tel_nrdcaixa
            glb_dtmvtolt
            WITH FRAME f_estnet.
    
    FIND crapass WHERE crapass.cdcooper = glb_cdcooper   AND
                       crapass.nrdconta = tel_nrdconta
                       NO-LOCK NO-ERROR.
                                           
           
    IF   NOT AVAILABLE crapass   THEN
         DO:
             glb_cdcritic = 009.
             DISPLAY "" @ crapass.nmprimtl WITH FRAME f_estnet.
         END.
    ELSE
        DISPLAY crapass.nmprimtl WITH FRAME f_estnet.         
         
        IF   AVAILABLE crapage   THEN
         DO:
            IF TIME > INT(crapage.hrcancel)   THEN                        
                glb_cdcritic = 676.                                
            ELSE
                                IF   AVAILABLE craptab   THEN
                                DO:
                                        IF   INT(SUBSTRING(craptab.dstextab,1,1)) <> 0   THEN
                                                glb_cdcritic = 677.
                                END.                                        
        END.
                ELSE
         glb_cdcritic = 055.
 
    
    IF   glb_cdcritic <> 0   THEN
         DO:
             RUN fontes/critic.p.
             BELL.
             MESSAGE glb_dscritic.
             glb_cdcritic = 0.
             NEXT.
         END.
    
    
    EMPTY TEMP-TABLE w_doctos.         
    
    /* Carrega as Faturas */
    FOR EACH craplft WHERE craplft.cdcooper = glb_cdcooper           AND
                           craplft.dtmvtolt = glb_dtmvtolt           AND
                           craplft.cdagenci = tel_cdagenci           AND
                           craplft.cdbccxlt = 11                     AND
                           craplft.nrdolote = 15000 + tel_nrdcaixa   AND
                           craplft.nrdconta = tel_nrdconta
                           NO-LOCK:
					
        /* Desconsiderar Guias DARF/DAS */					
		IF  craplft.tpfatura = 1  OR
		    craplft.tpfatura = 2  THEN
			NEXT.
                           
        CREATE w_doctos.
        ASSIGN w_doctos.cdbarras = craplft.cdbarras
               w_doctos.cdseqdoc = craplft.cdseqfat
               w_doctos.vllanmto = (craplft.vllanmto + craplft.vlrmulta + craplft.vlrjuros)
               w_doctos.tpdocmto = YES.
               
        /* Monta o codigo de barras da fatura */
        DO  aux_contador = 1 TO 44 BY 11:
        
            aux_cdfatura = DEC(SUBSTRING(craplft.cdbarras,aux_contador,11) +
                               "0").

            RUN dbo/pcrap04.p (INPUT-OUTPUT aux_cdfatura,
                                     OUTPUT aux_cddigito,
                                     OUTPUT aux_flgretbo).
                               
            w_doctos.dsbarras = w_doctos.dsbarras + 
                                SUBSTRING(craplft.cdbarras,aux_contador,11) +
                                "-" + STRING(aux_cddigito) + " ".
        END.
    END.

    /* Carrega os Titulos */
    FOR EACH craptit WHERE craptit.cdcooper = glb_cdcooper           AND
                           craptit.dtmvtolt = glb_dtmvtolt           AND
                           craptit.cdagenci = tel_cdagenci           AND
                           craptit.cdbccxlt = 11                     AND
                           craptit.nrdolote = 16000 + tel_nrdcaixa   AND
                           craptit.nrdconta = tel_nrdconta
                           NO-LOCK:

        CREATE w_doctos.
        ASSIGN w_doctos.cdbarras = craptit.dscodbar
               w_doctos.cdseqdoc = craptit.nrdocmto
               w_doctos.vllanmto = craptit.vldpagto
               w_doctos.cdagenci = craptit.cdagenci
               w_doctos.dtmvtolt = craptit.dtmvtolt
               w_doctos.tpdocmto = NO
               w_doctos.cdctrbxo = craptit.cdctrbxo
               w_doctos.nrdident = craptit.nrdident
               w_doctos.dsbarras = SUBSTRING(craptit.dscodbar,01,04) + 
                                   SUBSTRING(craptit.dscodbar,20,01) + "." +
                                   SUBSTRING(craptit.dscodbar,21,04) + "0" +
                                   " " +
                                   SUBSTRING(craptit.dscodbar,25,5) + "." + 
                                   SUBSTRING(craptit.dscodbar,30,5) + "0" +
                                   " " +
                                   SUBSTRING(craptit.dscodbar,35,5) + "." + 
                                   SUBSTRING(craptit.dscodbar,40,5) + "0" +
                                   " " +
                                   SUBSTRING(craptit.dscodbar,05,01) +
                                   " " +
                                   SUBSTRING(craptit.dscodbar,06,14).
    END.
    
    OPEN QUERY q_doctos FOR EACH w_doctos.
    PAUSE 0.
    
    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
        UPDATE b_doctos WITH FRAME f_doctos.
        LEAVE.
    END.
    
    CLOSE QUERY q_doctos.
END.

/* .......................................................................... */
