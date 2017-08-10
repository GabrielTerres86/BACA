/*.............................................................................

   Programa: Fontes/excccf.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Elton
   Data    : Marco/2008                         Ultima atualizacao: 18/04/2017
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela EXCCCF - Exclusao de cheques BB do CCF.

   Alteracoes: 23/01/2009 - Retirada permissao d o operador 799 e permissao p/
                            o 979 (Gabriel).

               12/03/2009 - Logar em log/excccf.log (Gabriel).
               
               20/05/2009 - Alteracao CDOPERAD (Kbase).
               
               24/03/2016 - Ajustes de permissao conforme solicitado no chamado 358761 (Kelvin).
               
               01/12/2016 - Alterado campo dsdepart para cddepart.
                            PRJ341 - BANCENJUD (Odirlei-AMcom)
                            
               18/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                crapass, crapttl, crapjur 
							(Adriano - P339).
                            
..............................................................................*/

{includes/var_online.i }

DEF STREAM str_1.

DEF  VAR  tel_nrdctitg   AS CHAR                                       NO-UNDO.
DEF  VAR  tel_idseqttl   AS INTE      FORMAT "9"                       NO-UNDO.
DEF  VAR  tel_nmprimtl   AS CHAR      FORMAT "x(40)"                   NO-UNDO.
DEF  VAR  tel_nrcheque   AS DEC       FORMAT "zz,zz9"         EXTENT 5 NO-UNDO.
DEF  VAR  tel_cdobserv   AS INT       FORMAT "z9"             EXTENT 5 NO-UNDO.
DEF  VAR  tel_vlcheque   AS DEC       FORMAT "zzz,zzz,zz9.99" EXTENT 5 NO-UNDO.
DEF  VAR  tel_dtiniest   AS DATE      FORMAT "99/99/9999"     EXTENT 5 NO-UNDO.
DEF  VAR  aux_confirma   AS CHAR      FORMAT "!"                       NO-UNDO.
DEF  VAR  aux_nmarqimp   AS CHAR                                       NO-UNDO.
DEF  VAR  aux_nmarqrel   AS CHAR      FORMAT "x(50)"                   NO-UNDO.
DEF  VAR  aux_nrtextab   AS INT                                        NO-UNDO.
DEF  VAR  aux_nrregist   AS INT                                        NO-UNDO.
DEF  VAR  aux_dsdlinha   AS CHAR      FORMAT "x(150)"                  NO-UNDO.
DEF  VAR  aux_maxcon     AS INT                                        NO-UNDO.
DEF  VAR aux_inpessoa    LIKE crapttl.inpessoa                         NO-UNDO.
DEF  VAR aux_nrcpfcgc    LIKE crapttl.nrcpfcgc                         NO-UNDO.
DEF  VAR aux_nmextttl    LIKE crapttl.nmextttl                         NO-UNDO.
DEF  VAR aux_idseqttl    LIKE crapttl.idseqttl                         NO-UNDO.
DEF  VAR flg_containd    AS LOG                                        NO-UNDO.
DEF  VAR contador        AS INT                                        NO-UNDO.
DEF  VAR aux_gera        AS LOG                                        NO-UNDO.
DEF  VAR aux_existech    AS LOG                                        NO-UNDO.

/* nome do arquivo de log */
DEF  VAR  aux_nmarqlog   AS CHAR                                       NO-UNDO.

  
DEF BUFFER crabttl FOR crapttl.  
  
FORM tel_nrdctitg    LABEL "Conta/ITG"   FORMAT "x.xxx.xxx-x" 
                     HELP  "Informe numero de conta ITG."  SPACE(4)
     tel_idseqttl    LABEL "Titular"     
                     HELP  "Informe o titular responsavel pelo cheque."
                     VALIDATE(tel_idseqttl > 0, 
                              "Numero do titular deve ser maior que '0'.")
     " - "
     aux_nmextttl    NO-LABEL           
                     FORMAT "x(35)"  
                     SKIP(2)
     tel_nrcheque[1] LABEL "Cheque"
                     HELP  "Informe o numero do cheque a ser excluido do CCF."
                     VALIDATE(tel_nrcheque[1] <> 0, 
                               "Numero do cheque deve ser maior que '0'.")
                     SPACE(2)
     tel_cdobserv[1] LABEL "Alinea" 
                     HELP  "Informe o codigo do motivo da devolucao."   
                     SPACE(2)                            
     tel_vlcheque[1] LABEL "Valor" 
                     HELP  "Informe o valor do cheque."
                     VALIDATE(tel_vlcheque > 0, 
                              "Valor do cheque deve ser maior que '0'.")
                     SPACE(2)
     tel_dtiniest[1] LABEL "Devolucao"       
                     HELP  "Informe a data de devolucao do cheque."
                     VALIDATE(tel_dtiniest[1] <> ?,
                              "Data de devolucao deve ser preenchida.")
                     SKIP(1)
     tel_nrcheque[2] LABEL "Cheque"
                     HELP  "Informe o numero do cheque a ser excluido do CCF."
                     VALIDATE(tel_nrcheque[2] <> 0, 
                               "Numero do cheque deve ser maior que '0'.")
                     SPACE(2)
     tel_cdobserv[2] LABEL "Alinea"
                     HELP  "Informe o codigo do motivo da devolucao."   
                     SPACE(2) 
     tel_vlcheque[2] LABEL "Valor" 
                     HELP  "Informe o valor do cheque."
                     VALIDATE(tel_vlcheque > 0, 
                              "Valor do cheque deve ser maior que '0'.")
                     SPACE(2)
     tel_dtiniest[2] LABEL "Devolucao"       
                     HELP  "Informe a data de devolucao do cheque."
                     VALIDATE(tel_dtiniest[2] <> ?,
                              "Data de devolucao deve ser preenchida.")
                     SKIP(1)
     tel_nrcheque[3] LABEL "Cheque"
                     HELP  "Informe o numero do cheque a ser excluido do CCF."
                     VALIDATE(tel_nrcheque[3] <> 0, 
                              "Numero do cheque deve ser maior que '0'.")
                     SPACE(2) 
     tel_cdobserv[3] LABEL "Alinea"
                     HELP  "Informe o codigo do motivo da devolucao."   
                     SPACE(2) 
     tel_vlcheque[3] LABEL "Valor"
                     HELP  "Informe o valor do cheque."
                     VALIDATE(tel_vlcheque > 0, 
                              "Valor do cheque deve ser maior que '0'.")
                     SPACE(2)     
     tel_dtiniest[3] LABEL "Devolucao"       
                     HELP  "Informe a data de devolucao do cheque."
                     VALIDATE(tel_dtiniest[3] <> ?,
                              "Data de devolucao deve ser preenchida.")
                     SKIP(1)
     tel_nrcheque[4] LABEL "Cheque"
                     HELP  "Informe o numero do cheque a ser excluido do CCF."
                     VALIDATE(tel_nrcheque[4] <> 0, 
                               "Numero do cheque deve ser maior que '0'.")                            SPACE(2)   
     tel_cdobserv[4] LABEL "Alinea"
                     HELP  "Informe o codigo do motivo da devolucao."   
                     SPACE(2)
     tel_vlcheque[4] LABEL "Valor" 
                     HELP  "Informe o valor do cheque."
                     VALIDATE(tel_vlcheque > 0, 
                              "Valor do cheque deve ser maior que '0'.")
                     SPACE(2)     
     tel_dtiniest[4] LABEL "Devolucao"       
                     HELP  "Informe a data de devolucao do cheque."
                     VALIDATE(tel_dtiniest[4] <> ?,
                              "Data de devolucao deve ser preenchida.")
                     SKIP(1)
     tel_nrcheque[5] LABEL "Cheque"
                     HELP  "Informe o numero do cheque a ser excluido do CCF."
                     VALIDATE(tel_nrcheque[5] <> 0, 
                               "Numero do cheque deve ser maior que '0'.")
                     SPACE(2)     
     tel_cdobserv[5] LABEL "Alinea"
                     HELP  "Informe o codigo do motivo da devolucao."   
                     SPACE(2)
     tel_vlcheque[5] LABEL "Valor"
                     HELP  "Informe o valor do cheque."
                     VALIDATE(tel_vlcheque > 0, 
                              "Valor do cheque deve ser maior que '0'.")
                     SPACE(2)     
     tel_dtiniest[5] LABEL "Devolucao"       
                     HELP  "Informe a data de devolucao do cheque."
                     VALIDATE(tel_dtiniest[5] <> ?,
                              "Data de devolucao deve ser preenchida.")
                     SKIP(1)
     WITH SIDE-LABELS NO-BOX ROW 6 COLUMN 4 OVERLAY FRAME f_dados.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

DEF TEMP-TABLE w_enviados
    FIELD dtiniest LIKE crapneg.dtiniest
    FIELD nrcheque LIKE crapneg.nrdocmto
    FIELD cdobserv LIKE crapneg.cdobserv 
    FIELD vlcheque LIKE crapneg.vlestour.

/*******************************PRINCIPAL**************************************/

ASSIGN glb_cdcritic = 0.

VIEW FRAME f_moldura.
PAUSE 0.

IF   glb_cdcritic > 0 THEN
     RETURN.

ASSIGN aux_nmarqlog = "log/prcitg_" + STRING(YEAR(glb_dtmvtolt),"9999") + 
                      STRING(MONTH(glb_dtmvtolt),"99") + 
                      STRING(DAY(glb_dtmvtolt),"99") + ".log".


DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

    RUN  fontes/inicia.p.
    
    CLEAR FRAME f_dados.  
    EMPTY TEMP-TABLE w_enviados.
    ASSIGN flg_containd = TRUE
           aux_gera     = FALSE.
    
    ASSIGN glb_cddopcao = "E".

     DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
         UPDATE tel_nrdctitg WITH FRAME f_dados. 
         LEAVE.
    END. 
     
    DO  WHILE LENGTH(tel_nrdctitg) < 8:
        tel_nrdctitg = "0" + tel_nrdctitg.
    END.

    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
         DO:        
             RUN  fontes/novatela.p.
             IF   CAPS(glb_nmdatela) <> "EXCCCF"   THEN
                  DO:
                    HIDE FRAME f_dados.
                    RETURN. 
                  END.
             ELSE
                  NEXT.
         END.         
    
    FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapcop THEN
        DO:
            glb_cdcritic = 651.
            BELL. 
            RUN fontes/critic.p.
            MESSAGE glb_dscritic.
            NEXT.
     END.

    FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                       craptab.nmsistem = "CRED"        AND
                       craptab.tptabela = "GENERI"      AND
                       craptab.cdempres = 00            AND
                       craptab.cdacesso = "NRARQMVITG"  AND
                       craptab.tpregist = 408           NO-ERROR NO-WAIT.

    IF   NOT AVAILABLE craptab   THEN
         DO:
             glb_cdcritic = 393.
             RUN fontes/critic.p.
             glb_cdcritic = 0.
             BELL.
             MESSAGE glb_dscritic.
             PAUSE 2 NO-MESSAGE.
             NEXT.
         END. 
    ELSE
         IF  INTEGER(SUBSTR(craptab.dstextab,07,01)) = 1 THEN
              DO:  
                  BELL.
                  MESSAGE "PROGRAMA BLOQUEADO PARA ENVIAR ARQUIVOS.". 
                  PAUSE 2 NO-MESSAGE.
                  NEXT.
              END.

    IF   glb_cddepart <> 20  AND  /* TI                   */    
         glb_cddepart <>  9  AND  /* COORD.PRODUTOS       */       
         glb_cddepart <>  8  THEN /* COORD.ADM/FINANCEIRO */
         DO:
             BELL.
             MESSAGE "Somente podem utilizar esta tela os departamentos TI,"
                     "COORD.PRODUTOS," SKIP "COORD.ADM/FINANCEIRO.".
             NEXT.
         END.
    
    { includes/acesso.i }
    
    FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                       crapass.nrdctitg = tel_nrdctitg 
                       USE-INDEX crapass7 NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapass   THEN
         DO:
             BELL.
             MESSAGE "009 - Associado nao cadastrado.".
             CLEAR FRAME f_dados.
             DISPLAY tel_nrdctitg WITH FRAME f_dados.
             NEXT.    
         END.


    IF  crapass.inpessoa = 1 THEN
        DO:
            /** Manda para CCF o titular que assinou o cheque **/
            FOR EACH crapttl WHERE crapttl.cdcooper = glb_cdcooper       AND
                                   crapttl.nrdconta = crapass.nrdconta
                                   NO-LOCK:
                      
                ASSIGN flg_containd = FALSE.
                      
                /*** Verifica se eh conta individual ***/
                IF  crapttl.idseqttl = 1  THEN
                    DO:
                        FIND FIRST crabttl WHERE 
                                   crabttl.cdcooper = glb_cdcooper     AND
                                   crabttl.nrdconta = crapass.nrdconta AND
                                   crabttl.idseqttl > 1                
                                   NO-LOCK NO-ERROR.
                                       
                        IF  NOT AVAILABLE crabttl  THEN
                            ASSIGN flg_containd  = TRUE.
                    END.
                
                IF  flg_containd =  TRUE  THEN
                    DO:                           
                         ASSIGN aux_inpessoa = crapttl.inpessoa
                                aux_nrcpfcgc = crapttl.nrcpfcgc
                                aux_nmextttl = crapttl.nmextttl
                                aux_idseqttl = crapttl.idseqttl.
                    END.
            END.
        END.
    ELSE /* pessoa JURIDICA */ 
        DO:
            ASSIGN  aux_inpessoa = crapass.inpessoa
                    aux_nrcpfcgc = crapass.nrcpfcgc
                    aux_nmextttl = crapass.nmprimtl
                    aux_idseqttl = 1.

        END.
           
    /** Caso nao seja conta individual pede atualizacao do campo 'Titular' **/
    IF  flg_containd = FALSE THEN
        DO:
            UPDATE tel_idseqttl WITH FRAME f_dados.
    
            FIND crapttl where crapttl.cdcooper = glb_cdcooper     AND
                               crapttl.nrdconta = crapass.nrdconta AND
                               crapttl.idseqttl = tel_idseqttl 
                               NO-LOCK NO-ERROR.
                               
            IF  NOT AVAIL crapttl THEN
                DO:
                    MESSAGE "Titular '" tel_idseqttl "' inexistente" 
                            "para essa conta.".
                    BELL.
                    PAUSE 2 NO-MESSAGE.
                    LEAVE.
                END.
            ELSE
                DO:
                    ASSIGN aux_inpessoa = crapttl.inpessoa
                           aux_nrcpfcgc = crapttl.nrcpfcgc
                           aux_nmextttl = crapttl.nmextttl
                           aux_idseqttl = crapttl.idseqttl.
                END.
        END.
    ELSE  /*** Se conta eh individual titular eh sempre "1" ***/ 
        ASSIGN tel_idseqttl = 1. 
    
    DISPLAY  tel_idseqttl 
             aux_nmextttl WITH FRAME f_dados.
    
    DO  WHILE TRUE  ON ENDKEY UNDO, LEAVE:
              
        ASSIGN  tel_nrcheque = 0
                tel_cdobserv = 0
                tel_vlcheque = 0
                tel_dtiniest = ?
                aux_existech = FALSE.
        
        DO  contador = 1 TO  5: 
                         
            DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                UPDATE  tel_nrcheque[contador] tel_cdobserv[contador] 
                        tel_vlcheque[contador] tel_dtiniest[contador] 
                        WITH FRAME f_dados.
        
                IF  tel_nrcheque[contador] <> 0 THEN 
                    DO:
                        CREATE w_enviados.
                        ASSIGN w_enviados.nrcheque =  tel_nrcheque[contador]
                               w_enviados.cdobserv =  tel_cdobserv[contador]
                               w_enviados.vlcheque = 
                                          (tel_vlcheque[contador] * 100)
                               w_enviados.dtiniest =  tel_dtiniest[contador].
                        
                    /** Verifica se existem cheques para serem enviados **/
                        ASSIGN aux_existech = TRUE.
                    
                    END.
                LEAVE.
            END.
            
            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                DO: 
                    RUN gera_arquivo.
                    LEAVE.
                END.
        END.  
        
        /* Se nao gerou arquivo antes de cadastrar 5 cheques, gera o arquivo */
        IF  aux_gera = FALSE THEN
            RUN gera_arquivo.
        
        LEAVE.
    END.

END. /*** Fim While True ***/


PROCEDURE gera_arquivo:

    IF  aux_existech = FALSE THEN
        LEAVE.
    
    RUN confirma.
    
    ASSIGN aux_gera = TRUE. /** Confirmacao gerada **/
        
    IF  aux_confirma = "S" THEN
        DO:  
            RUN abre_arquivo.
                
            FOR EACH w_enviados:
                
                RUN registro.      
                
                RUN proc_log.   
                   
            END.
                    
            RUN fecha_arquivo.
                 
            MESSAGE "Gerado arquivo de exclusao de cheques para o CCF.".
            
        END.
END.

PROCEDURE abre_arquivo:
     
   ASSIGN aux_nrtextab = INT(SUBSTRING(craptab.dstextab,1,5))
          aux_nmarqimp = "coo408" +
                         STRING(DAY(glb_dtmvtolt),"99") +
                         STRING(MONTH(glb_dtmvtolt),"99") +
                         STRING(aux_nrtextab,"99999") + ".rem"
          aux_nrregist = 0.
       
   OUTPUT STREAM str_1 TO VALUE("arq/" + aux_nmarqimp).
          
   /* header */
   ASSIGN aux_dsdlinha = "0000000"  +
                         STRING(crapcop.cdageitg,"9999") + 
                         STRING(crapcop.nrctaitg,"99999999") + 
                         "COO408  " + 
                         STRING(aux_nrtextab,"99999")  +
                         STRING(glb_dtmvtolt,"99999999")  +
                         STRING(crapcop.cdcnvitg,"999999999").
                         /* o restante sao brancos */
                      
   PUT STREAM str_1  aux_dsdlinha SKIP.
                
END PROCEDURE.


PROCEDURE fecha_arquivo:
                
    /* trailer */
                          /* total de registros + header + trailer */
    ASSIGN aux_nrregist = aux_nrregist + 2
           aux_dsdlinha = "9999999"  +
                          STRING(aux_nrregist,"999999999").
                          /* o restante sao brancos */
                         
    PUT STREAM str_1 aux_dsdlinha.
    
    OUTPUT STREAM str_1 CLOSE.
    
    /* verifica se o arquivo gerado nao tem registros "detalhe", ai elimina-o */
       
    IF   aux_nrregist <= 2   THEN
         DO:
             UNIX SILENT VALUE("rm arq/" + aux_nmarqimp + " 2>/dev/null"). 
             LEAVE.        
         END.
           
    /* mensagem no log, para enviar o arquivo */
    glb_cdcritic = 847.
    RUN fontes/critic.p.

    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - COO408 - " + glb_cdprogra + "' --> '" + glb_dscritic 
                      + " - " +  aux_nmarqimp +  " >> " + aux_nmarqlog).
                                
    /* copia o arquivo para diretorio "compel" para poder ser enviado ao BB */
    UNIX SILENT VALUE("ux2dos < arq/" + aux_nmarqimp +  
                      ' | tr -d "\032"' +  
                      " > /micros/" + crapcop.dsdircop +
                      "/compel/" + aux_nmarqimp + " 2>/dev/null").
      
    UNIX SILENT VALUE("mv arq/" + aux_nmarqimp + " salvar 2>/dev/null"). 
    
    /* atualizacao da craptab */
    ASSIGN aux_nrtextab = aux_nrtextab + 1
           SUBSTRING(craptab.dstextab,1,5) = STRING(aux_nrtextab,"99999")
           aux_maxcon = 0.
     
END PROCEDURE.


PROCEDURE registro:
    
    IF  aux_maxcon >   9988  THEN  /* Maximo 9990 */
        DO:       
           RUN fecha_arquivo.
           RUN abre_arquivo.
        END.
       
    /* registro (tipo unico) */             
    ASSIGN aux_maxcon   = aux_maxcon + 1
           aux_nrregist = aux_nrregist + 1
           aux_dsdlinha = STRING(aux_nrregist,"99999") +
                          "01" +
                          STRING(SUBSTRING(crapass.nrdctitg,1,7),"x(7)") +
                          STRING(SUBSTRING(crapass.nrdctitg,8,1),"x(1)") +
                          "50" +  /* Exclusao CCF */
                          STRING(aux_inpessoa,"99")                  +
                          STRING(aux_nrcpfcgc,"99999999999999")      +
                          STRING(w_enviados.nrcheque,"999999")              +
                          STRING(w_enviados.vlcheque,"99999999999999999")   +
                          STRING(w_enviados.cdobserv,"99")              +
                          STRING(YEAR(w_enviados.dtiniest),"9999")      +
                          STRING(MONTH(w_enviados.dtiniest),"99")       +
                          STRING(DAY(w_enviados.dtiniest),"99")         +
                          STRING(aux_nmextttl,"x(40)")               +
                          STRING(aux_idseqttl,"99")                  +
                          STRING(YEAR(glb_dtmvtolt),"9999")          +
                          STRING(MONTH(glb_dtmvtolt),"99")           +
                          STRING(DAY(glb_dtmvtolt),"99")             +
                          "01"                                       +
                          "00000"                                    +
                          STRING(crapass.nrdconta,"99999999").
                          /* o restante sao brancos */
    
    PUT STREAM str_1 aux_dsdlinha SKIP.
  
END PROCEDURE.


PROCEDURE proc_log:

    UNIX SILENT VALUE ("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " " +
                       STRING(TIME,"HH:MM:SS") + "' --> 'Operador "      +
                       glb_cdoperad + " - Excluiu o cheque "             + 
                       STRING(w_enviados.nrcheque,"zz,zzz,zz9")          + 
                       " do CCF da conta ITG "                           + 
                       STRING(tel_nrdctitg,"9.999.999-X")                + 
                       " >> log/excccf.log"). 

END PROCEDURE.


PROCEDURE confirma.

   /* Confirma */
   DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
       ASSIGN aux_confirma = "N".
       BELL.      
       MESSAGE "Deseja excluir estes cheques do CCF?" UPDATE aux_confirma.
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

/*............................................................................*/
