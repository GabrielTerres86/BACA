/* ............................................................................

   Programa: fontes/crps447.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Mirtes  
   Data    : Maio/2005                    Ultima atualizacao: 18/04/2017

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Gerar arquivo com COMANDOS INCLUSAO/RETIRADA CCF(COO408)     
               Emite relatorio crrl388.

   Alteracoes: 29/07/2005 - Alterada mensagem Log referente critica 847 (Diego).
    
               23/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
               28/11/2005 - Utilizar cooperativa no indice para selecionar 
                            envio CCF contas integracao (Mirtes)
                            
               07/12/2005 - Acerto para pessoa JURIDICA (Evandro).
               
               10/01/2006 - Correcao das mensagens para o LOG (Evandro).

               12/01/2006 - Acertado campo trailer(qtd.registro) (Mirtes).
               
               26/01/2006 - Devido a desativacao da escolha de inclusao no CCF
                            atraves da tela MANCCF foi incluida a rotina para
                            "selecionar" automaticamente os associados que
                            serao inclusos no CCF (Evandro).
                            
               15/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
               
               21/02/2006 - Alimentar a data de envio da crapneg (Evandro).
               
               28/08/2006 - Modificado numero do vias do relatorio 338 para
                            Cecrisacred (Diego).
               
               29/06/2007 - Nao envia para arquivo do CCF os cheques que nao
                            possuem o titular e gera criticas desses cheques no
                            relatorio 388 (Elton).
               
               10/07/2007 - Nao altera situacao do cheque para enviado quando
                            nao esta especificado o titular, nas contas com mais
                            de um titular (Elton).

               26/07/2007 - Adicionado novo campo no relatorio "Data Reg"
                            crapneg.dtfimest (Guilherme).
                            
               17/01/2008 - Alterar para enviar somente o 1o titular na Exclusao
                            do CCF (Ze).
                            
               23/01/2008 - Limpar a crapeca ao enviar os registros (Evandro).
               
               12/02/2008 - Informar os dados de cada titular na exclusao
                            (Evandro).
                            
               05/04/2010 - Adaptacao projeto IF CECRED - CCF (Guilherme).
                          - Melhorado 2o. FOR EACH USE-INDEX crapneg6 
                        
               16/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               11/09/2014 - Ajuste migração Concredi, ao enviar arquivo(registro)    
                            verificar se é uma conta migrada e enviar a cta antiga
                            (Odirlei/Amcom).
                            
               25/11/2014 - Incluir clausula no craptco flgativo = TRUE
                            (Lucas R./Rodrigo)

			   18/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                crapass, crapttl, crapjur 
							(Adriano - P339).

............................................................................ */

{ includes/var_batch.i }  

DEF STREAM str_1.

DEF     VAR aux_nmarqimp AS CHAR      FORMAT "x(50)"                 NO-UNDO.
DEF     VAR aux_nmarqrel AS CHAR      FORMAT "x(50)"                 NO-UNDO.
DEF     VAR aux_nrtextab AS INT                                      NO-UNDO.
DEF     VAR aux_nrregist AS INT                                      NO-UNDO.
DEF     VAR aux_dsdlinha AS CHAR      FORMAT "x(150)"                NO-UNDO.

DEF     VAR aux_cdcomand AS INT                                      NO-UNDO.
DEF     VAR aux_motctror AS CHAR      FORMAT "x(2)"                  NO-UNDO.
DEF     VAR aux_nrcheque AS CHAR                                     NO-UNDO.
DEF     VAR aux_vlcheque AS DECIMAL                                  NO-UNDO.
DEF     VAR aux_maxcon   AS INT                                      NO-UNDO.
DEF     VAR aux_nrdconta LIKE crapcch.nrdconta                       NO-UNDO.
DEF     VAR aux_nrdconta_arq LIKE crapcch.nrdconta                   NO-UNDO.
DEF     VAR aux_inpessoa LIKE crapttl.inpessoa                       NO-UNDO.
DEF     VAR aux_nrcpfcgc LIKE crapttl.nrcpfcgc                       NO-UNDO.
DEF     VAR aux_nmextttl LIKE crapttl.nmextttl                       NO-UNDO.
DEF     VAR aux_idseqttl LIKE crapttl.idseqttl                       NO-UNDO.

/* variaveis para conta de integracao */
DEF BUFFER crabass5 FOR crapass.
DEF     VAR aux_nrctaass AS INT       FORMAT "zzzz,zzz,9"            NO-UNDO.
DEF     VAR aux_ctpsqitg LIKE craplcm.nrdctabb                       NO-UNDO.
DEF     VAR aux_nrdctitg LIKE crapass.nrdctitg                       NO-UNDO.

DEF        VAR rel_nmempres     AS CHAR    FORMAT "x(15)"            NO-UNDO.
DEF        VAR rel_nmresemp     AS CHAR    FORMAT "x(15)"            NO-UNDO.

DEF        VAR rel_nmrelato     AS CHAR    FORMAT "x(40)" EXTENT 5   NO-UNDO.
DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

/* nome do arquivo de log */
DEF        VAR aux_nmarqlog AS CHAR                                  NO-UNDO.

DEF        VAR flg_containd AS LOG                                   NO-UNDO.
DEF        VAR aux_contattl AS INT                                   NO-UNDO.
DEF        VAR aux_flgctitg AS INT                                   NO-UNDO.
   
DEF BUFFER crabttl FOR crapttl.
DEF BUFFER crabneg FOR crapneg.

/* para os que foram enviados */
DEF TEMP-TABLE w_enviados
    FIELD cdagenci LIKE crapass.cdagenci
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD idseqttl LIKE crapttl.idseqttl
    FIELD flginclu AS LOGICAL FORMAT "INCLUSAO NO CCF/EXCLUSAO DO CCF"
    FIELD nrdctitg LIKE crapass.nrdctitg
    FIELD nmextttl LIKE crapttl.nmextttl
    FIELD dtfimest LIKE crapneg.dtfimest
    FIELD nrcpfcgc LIKE crapttl.nrcpfcgc 
    FIELD nrcheque LIKE crapneg.nrdocmto
    FIELD cdobserv LIKE crapneg.cdobserv 
    FIELD vlcheque LIKE crapneg.vlestour
    INDEX w_enviados1         
          cdagenci
          nrdconta
          idseqttl
          flginclu.
          
/* Para os cheques sem indicacao de titularidade */
DEF TEMP-TABLE w_criticas
    FIELD cdagenci LIKE crapass.cdagenci
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD idseqttl LIKE crapttl.idseqttl
    FIELD nrdctitg LIKE crapass.nrdctitg
    FIELD nmextttl LIKE crapttl.nmextttl
    FIELD dtfimest LIKE crapneg.dtfimest
    FIELD nrcpfcgc LIKE crapttl.nrcpfcgc  
    FIELD nrcheque LIKE crapneg.nrdocmto
    FIELD cdobserv LIKE crapneg.cdobserv  
    FIELD vlcheque LIKE crapneg.vlestour
    INDEX w_criticas1         
          cdagenci
          nrdconta
          idseqttl.

DEF BUFFER b_criticas FOR w_criticas.

FORM w_enviados.nrdconta    AT   5   LABEL "Conta/DV"
     w_enviados.nrdctitg             LABEL "Conta Integracao"
     w_enviados.idseqttl             LABEL "Tit."
     w_enviados.nmextttl             LABEL "Nome do Titular" FORMAT "x(29)"
     w_enviados.nrcpfcgc             LABEL "CPF/CNPJ"  
     w_enviados.nrcheque             LABEL "Cheque"
     w_enviados.cdobserv             LABEL "Alinea"    
     w_enviados.dtfimest             LABEL "Data Reg"  FORMAT "99/99/99"
     w_enviados.vlcheque             LABEL "Valor"
     WITH DOWN NO-LABELS WIDTH 132 FRAME f_enviados.


FORM w_criticas.nrdconta    AT   5   LABEL "Conta/DV"
     w_criticas.nrdctitg             LABEL "Conta Integracao"
     w_criticas.idseqttl             LABEL "Tit."
     w_criticas.nmextttl             LABEL "Nome do Titular" FORMAT "x(29)"
     w_criticas.nrcpfcgc             LABEL "CPF/CNPJ"
     w_criticas.nrcheque             LABEL "Cheque"
     w_criticas.cdobserv             LABEL "Alinea"
     w_criticas.dtfimest             LABEL "Data Reg" FORMAT "99/99/99"
     w_criticas.vlcheque             LABEL "Valor"
     WITH DOWN NO-LABELS WIDTH 132 FRAME f_criticas.


ASSIGN glb_cdprogra = "crps447"
       glb_flgbatch = FALSE
       aux_nmarqlog = "log/prcitg_" + STRING(YEAR(glb_dtmvtolt),"9999") + 
                      STRING(MONTH(glb_dtmvtolt),"99") + 
                      STRING(DAY(glb_dtmvtolt),"99") + ".log".


RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> " + aux_nmarqlog).
         RETURN.
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
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> " + aux_nmarqlog).
         RETURN.
     END.    
ELSE
     IF   INTEGER(SUBSTR(craptab.dstextab,07,01)) = 1 THEN
          DO:
              UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                " - COO408 - " + glb_cdprogra + "' --> '"  +
                                "PROGRAMA BLOQUEADO PARA ENVIAR ARQUIVOS" +
                                " >> " + aux_nmarqlog).
              RUN fontes/fimprg.p.
              RETURN.
          END.
     
RUN abre_arquivo.

/* "Seleciona" automaticamente os associados que devem ser inclusos no CCF */
FOR EACH crapneg WHERE crapneg.cdcooper = glb_cdcooper           AND
                       crapneg.cdhisest = 1                      AND
                       crapneg.dtfimest = ?                      AND
                       crapneg.dtiniest <= (glb_dtmvtolt - 9)    AND
                      (crapneg.cdobserv = 12 OR
                       crapneg.cdobserv = 13)                    AND
                      /* 0-Nao enviada | 4-Reenviar */
                      (crapneg.flgctitg = 0  OR
                       crapneg.flgctitg = 4)                     NO-LOCK
                       USE-INDEX crapneg6,
    EACH crapass WHERE crapass.cdcooper = glb_cdcooper           AND
                       crapass.nrdconta = crapneg.nrdconta       AND
                       crapass.flgctitg = 2                      AND
                       crapass.nrdctitg <> ""                    NO-LOCK:
                       
    /* Se o cheque da crapneg for da conta integracao */
    IF   SUBSTRING(STRING(crapass.nrdctitg,"xxxxxxxx"),1,7) =
         SUBSTRING(STRING(crapneg.nrdctabb,"99999999"),1,7)     THEN
         DO:
             DO WHILE TRUE:
             
                /*FIND crabneg OF crapneg EXCLUSIVE-LOCK NO-ERROR NO-WAIT.*/
                FIND crabneg WHERE crabneg.cdcooper = glb_cdcooper     AND
                                   crabneg.nrdconta = crapneg.nrdconta AND
                                   crabneg.nrseqdig = crapneg.nrseqdig
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                
                IF   NOT AVAILABLE crabneg   THEN
                     IF   LOCKED crabneg   THEN
                          DO:
                              PAUSE 1 NO-MESSAGE.
                              NEXT.
                          END.
                          
                LEAVE.
             END.
             
             ASSIGN crabneg.flgctitg = 5. /* Enviar Inclusao CCF */
                          
         END.
END.
                       
FOR EACH crapneg WHERE crapneg.cdcooper = glb_cdcooper AND
                       crapneg.nrdconta > 0            AND
                       crapneg.cdhisest = 1            AND
                       crapneg.cdbanchq = 1            AND
                      (crapneg.cdobserv = 12 OR
                       crapneg.cdobserv = 13)          AND
                       crapneg.flgctitg >= 4  /* 4 --> reprocessar  */
                       USE-INDEX crapneg6,    /* 5 --> inclusao CCF */
                                              /* 6 --> exclusao CCF */
    FIRST crapass WHERE crapass.cdcooper = glb_cdcooper       AND
                        crapass.nrdconta = crapneg.nrdconta   AND
                        crapass.nrdctitg <> " " NO-LOCK TRANSACTION:
    
    /***  Controle de envio dos cheques ***/
    ASSIGN aux_flgctitg = 0.   
       
                          /* cheque sem o digito */
    ASSIGN aux_nrcheque = SUBSTRING(STRING(crapneg.nrdocmto,"9999999"),1,6)
                          /* valor sem casas decimais */
           aux_vlcheque = crapneg.vlestour * 100.

    /* Se for INCLUSAO ou ocorreu ERRO na tentativa de inclusao anterior */
    IF   crapneg.flgctitg = 5                              OR
        (crapneg.flgctitg = 4 AND crapneg.dtfimest = ? )   THEN
         DO:
             IF   crapass.inpessoa = 1   THEN
                  DO:
                      /** Manda para CCF o titular que assinou o cheque **/
                      FOR EACH crapttl WHERE 
                                       crapttl.cdcooper = glb_cdcooper     AND
                                       crapttl.nrdconta = crapass.nrdconta 
                                       NO-LOCK:
                      
                          ASSIGN flg_containd = FALSE.
                      
                          /*** Verifica se eh conta individual ***/
                          IF crapttl.idseqttl = 1  THEN
                             DO:
                                FIND FIRST crabttl WHERE 
                                        crabttl.cdcooper = glb_cdcooper     AND
                                        crabttl.nrdconta = crapass.nrdconta AND
                                        crabttl.idseqttl > 1                
                                        NO-LOCK NO-ERROR.
                                       
                                IF  NOT AVAILABLE crabttl  THEN
                                    ASSIGN flg_containd  = TRUE.
                             END.
                          
                          
                          IF crapttl.idseqttl = crapneg.idseqttl OR
                             crapneg.idseqttl = 9                OR
                             flg_containd     = TRUE             THEN
                             DO:                           
                                 ASSIGN aux_inpessoa = crapttl.inpessoa
                                        aux_nrcpfcgc = crapttl.nrcpfcgc
                                        aux_nmextttl = crapttl.nmextttl
                                        aux_idseqttl = crapttl.idseqttl
                                        aux_flgctitg = 1. /** enviado **/
                                 
                                 RUN registro.
                             END.
                      
                          IF  crapneg.idseqttl = 0      AND
                              flg_containd     = FALSE  THEN
                              DO:
                                 CREATE w_criticas.
                                 ASSIGN w_criticas.cdagenci = crapass.cdagenci
                                        w_criticas.idseqttl = crapttl.idseqttl
                                        w_criticas.nrdconta = crapass.nrdconta
                                        w_criticas.nrdctitg = crapass.nrdctitg
                                        w_criticas.nmextttl = crapttl.nmextttl
                                        w_criticas.dtfimest = crapneg.dtfimest
                                        w_criticas.nrcpfcgc = crapttl.nrcpfcgc
                                        w_criticas.nrcheque = crapneg.nrdocmto
                                        w_criticas.cdobserv = crapneg.cdobserv
                                        w_criticas.vlcheque = crapneg.vlestour.
                              END.
                      END.
                                   
                  END. /** Fim pessoa FISICA **/
             ELSE /* pessoa JURIDICA */ 
                  DO:
                      ASSIGN aux_inpessoa = crapass.inpessoa
                             aux_nrcpfcgc = crapass.nrcpfcgc
                             aux_nmextttl = crapass.nmprimtl
                             aux_idseqttl = 1
                             aux_flgctitg = 1.  /*** enviado ***/

                      RUN registro.
                  END.
         END.
    ELSE
    /* Se for EXCLUSAO ou ocorreu ERRO na tentativa de exclusao anterior */
    IF   crapneg.flgctitg = 6                               OR
        (crapneg.flgctitg = 4 AND crapneg.dtfimest <> ? )   THEN
         DO:
             IF   crapass.inpessoa = 1   THEN
                  DO:
                      /** Manda para CCF o titular que assinou o cheque **/
                      FOR EACH crapttl WHERE
                                       crapttl.cdcooper = glb_cdcooper     AND
                                       crapttl.nrdconta = crapass.nrdconta
                                       NO-LOCK:
                                       
                          ASSIGN flg_containd = FALSE.
                                                                 
                          /*** Verifica se eh conta individual ***/
                          IF crapttl.idseqttl = 1  THEN
                             DO:
                                FIND FIRST crabttl WHERE
                                        crabttl.cdcooper = glb_cdcooper     AND
                                        crabttl.nrdconta = crapass.nrdconta AND
                                        crabttl.idseqttl > 1                
                                        NO-LOCK NO-ERROR.

                                IF  NOT AVAILABLE crabttl  THEN
                                    ASSIGN flg_containd  = TRUE.
                             END.
                                       
                                       
                                       
                      IF   crapttl.idseqttl = crapneg.idseqttl   OR
                           crapneg.idseqttl = 9                  OR
                           flg_containd     = TRUE               THEN
                           DO:
                               ASSIGN aux_inpessoa = crapttl.inpessoa
                                      aux_nrcpfcgc = crapttl.nrcpfcgc
                                      aux_nmextttl = crapttl.nmextttl
                                      aux_idseqttl = crapttl.idseqttl
                                      aux_flgctitg = 1. 
                                 
                               RUN registro.
                           END.

                      IF   crapneg.idseqttl = 0      AND
                           flg_containd     = FALSE  THEN
                           DO:
                               CREATE w_criticas.
                               ASSIGN w_criticas.cdagenci = crapass.cdagenci
                                      w_criticas.idseqttl = crapneg.idseqttl
                                      w_criticas.nrdconta = crapass.nrdconta
                                      w_criticas.nrdctitg = crapass.nrdctitg
                                      w_criticas.nmextttl = crapass.nmprimtl
                                      w_criticas.dtfimest = crapneg.dtfimest
                                      w_criticas.nrcpfcgc = crapass.nrcpfcgc
                                      w_criticas.nrcheque = crapneg.nrdocmto
                                      w_criticas.cdobserv = crapneg.cdobserv
                                      w_criticas.vlcheque = crapneg.vlestour.
                           END.
                      END.
                  END.
             ELSE /* pessoa JURIDICA */ 
                  DO:
                      ASSIGN aux_inpessoa = crapass.inpessoa
                             aux_nrcpfcgc = crapass.nrcpfcgc
                             aux_nmextttl = crapass.nmprimtl
                             aux_idseqttl = 1
                             aux_flgctitg = 1.  
                      
                      RUN registro.
                  END.
         END.
    ELSE
         NEXT.

    IF  aux_flgctitg = 1 THEN
        DO:
            /* atualiza flag (flgctitg) da crapneg para enviada(1) */
            ASSIGN  crapneg.flgctitg = 1
                    crapneg.dtectitg = glb_dtmvtolt.
                    
            /* limpa a crapeca para este cheque */
            FOR EACH crapeca WHERE crapeca.cdcooper = crapneg.cdcooper   AND
                                   crapeca.tparquiv = 508                AND
                                   crapeca.nrdconta = crapneg.nrdconta   AND
                                   SUBSTRING(crapeca.dscritic,
                                             LENGTH(crapeca.dscritic) - 5) =
                                      SUBSTRING(STRING(crapneg.nrdocmto,
                                                "9999999"),1,6)
                                   EXCLUSIVE-LOCK:
                                   
                DELETE crapeca.
            END.
        END.
END.

RUN fecha_arquivo.

RUN rel_enviados. /* relatorio de enviados */

RUN fontes/fimprg.p.                   

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
    
    ASSIGN aux_nrdconta_arq = crapass.nrdconta.
    
    IF glb_cdcooper = 1 THEN
    DO:
      /*verifica se é uma conta migrada*/
      FIND FIRST craptco 
        WHERE craptco.cdcooper = glb_cdcooper 
          AND craptco.nrdconta = crapass.nrdconta 
          AND craptco.cdcopant = 4  
          AND craptco.flgativo = TRUE
           NO-LOCK NO-ERROR.

        /* se encontrar deve enviar cta antiga
           se o cheque for da coop. antiga */
        IF AVAIL(craptco) THEN 
        DO:                      
          FIND FIRST crapfdc
         WHERE crapfdc.cdcooper = craptco.cdcooper
           AND crapfdc.cdbanchq = crapneg.cdbanchq
           AND crapfdc.cdagechq = crapneg.cdagechq
           /* se for banco 1 usar a informação da crapneg
              pois sempre será um chque migrado
              na viacredi terá banco 85 */
           AND crapfdc.nrctachq = (IF crapneg.cdbanchq = 1 THEN 
                                       crapneg.nrctachq 
                                  ELSE craptco.nrctaant)
           AND crapfdc.nrcheque = INT(aux_nrcheque) 
            NO-LOCK NO-ERROR.
        
          IF  AVAIL crapfdc THEN
            ASSIGN aux_nrdconta_arq = craptco.nrctaant.
        END.    
    END.

    /* registro (tipo unico) */             
    ASSIGN aux_maxcon   = aux_maxcon + 1
           aux_nrregist = aux_nrregist + 1
           aux_dsdlinha = STRING(aux_nrregist,"99999") +
                          "01" +
                          STRING(SUBSTRING(crapass.nrdctitg,1,7),"x(7)") +
                          STRING(SUBSTRING(crapass.nrdctitg,8,1),"x(1)") +
                          IF crapneg.flgctitg = 5 OR
                            (crapneg.flgctitg = 4 AND crapneg.dtfimest = ?) 
                            THEN "10"  /* Inclusao CCF */
                            ELSE "50". /* Exclusao CCF */
           aux_dsdlinha = aux_dsdlinha +
                          STRING(aux_inpessoa,"99")                  +
                          STRING(aux_nrcpfcgc,"99999999999999")      +
                          STRING(aux_nrcheque,"999999")              +
                          STRING(aux_vlcheque,"99999999999999999")   +
                          STRING(crapneg.cdobserv,"99")              +
                          STRING(YEAR(crapneg.dtiniest),"9999")      +
                          STRING(MONTH(crapneg.dtiniest),"99")       +
                          STRING(DAY(crapneg.dtiniest),"99")         +
                          STRING(aux_nmextttl,"x(40)")               +
                          STRING(aux_idseqttl,"99")                  +
                          STRING(YEAR(glb_dtmvtolt),"9999")          +
                          STRING(MONTH(glb_dtmvtolt),"99")           +
                          STRING(DAY(glb_dtmvtolt),"99")             +
                          "01"                                       +
                          "00000"                                    +
                          STRING(aux_nrdconta_arq,"99999999").
                          /* o restante sao brancos */

    PUT STREAM str_1  aux_dsdlinha SKIP.
    
    CREATE w_enviados.
    ASSIGN w_enviados.cdagenci = crapass.cdagenci
           w_enviados.nrdconta = crapass.nrdconta
           w_enviados.idseqttl = aux_idseqttl
           w_enviados.flginclu = IF crapneg.flgctitg = 5 OR
                                   (crapneg.flgctitg = 4 AND
                                    crapneg.dtfimest = ?)THEN  YES
                                                         ELSE  NO
           w_enviados.nrdctitg = crapass.nrdctitg
           w_enviados.nmextttl = aux_nmextttl
           w_enviados.dtfimest = crapneg.dtfimest
           w_enviados.nrcpfcgc = aux_nrcpfcgc
           w_enviados.nrcheque = crapneg.nrdocmto
           w_enviados.cdobserv = crapneg.cdobserv
           w_enviados.vlcheque = crapneg.vlestour.

END PROCEDURE.

PROCEDURE rel_enviados:
    
    DEF VAR aux_flgvisto AS LOGICAL         INIT FALSE              NO-UNDO.
    
    ASSIGN aux_nmarqrel = "rl/crrl388_" + STRING(TIME) + ".lst".

    { includes/cabrel132_1.i }  /* Monta o cabecalho */
    
    OUTPUT STREAM str_1 TO VALUE(aux_nmarqrel) PAGED PAGE-SIZE 84.
    
    VIEW STREAM str_1 FRAME f_cabrel132_1.
       
    FOR EACH w_enviados NO-LOCK USE-INDEX w_enviados1
                                BREAK BY w_enviados.flginclu DESCENDING
                                         BY w_enviados.cdagenci    
                                            BY w_enviados.nrdconta
                                               BY w_enviados.idseqttl:

        /* mostra quando eh inclusao/exclusao */
        IF   FIRST-OF(w_enviados.flginclu)   THEN
             DO:
                 /* Quebra pag quando for exclusao, seta para imprimir visto */
                 IF   w_enviados.flginclu = FALSE   THEN
                      DO:
                          PAGE STREAM str_1.
                          aux_flgvisto = TRUE.
                      END.
             
                 PUT STREAM str_1 "*** " AT 54 
                                  w_enviados.flginclu 
                                  " ***"
                                  SKIP(1).
             END.

        IF   FIRST-OF(w_enviados.cdagenci)   THEN
             DO:
                 FIND crapage WHERE crapage.cdcooper = glb_cdcooper        AND
                                    crapage.cdagenci = w_enviados.cdagenci
                                    NO-LOCK NO-ERROR.
                                
                 PUT STREAM str_1 "PA: " w_enviados.cdagenci " - "
                                   crapage.nmresage SKIP.
             END.
    
        DISPLAY STREAM str_1
                w_enviados.nrdconta  WHEN FIRST-OF(w_enviados.nrdconta)
                w_enviados.nrdctitg  WHEN FIRST-OF(w_enviados.nrdconta)
                w_enviados.idseqttl  WHEN FIRST-OF(w_enviados.idseqttl)
                w_enviados.nmextttl  WHEN FIRST-OF(w_enviados.idseqttl)
                FORMAT "x(29)"
                w_enviados.dtfimest  FORMAT "99/99/99"
                w_enviados.nrcpfcgc  WHEN FIRST-OF(w_enviados.idseqttl)
                w_enviados.nrcheque
                w_enviados.cdobserv 
                w_enviados.vlcheque
                WITH FRAME f_enviados.
            
        DOWN STREAM str_1 WITH FRAME f_enviados.
    
        IF   LAST-OF(w_enviados.nrdconta)   THEN  /*pular linha a cada conta*/
             PUT STREAM str_1 SKIP(1).
                
        IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
             DO:
                 PAGE STREAM str_1.

                 PUT STREAM str_1 "PA: " w_enviados.cdagenci " - "
                                   crapage.nmresage SKIP.
             END.
         
    END.
    
    IF   aux_flgvisto   THEN
         PUT STREAM str_1 SKIP(3)
                          "____________________________"   AT 51
                          SKIP
                          "         ASSINATURA"            AT 51
                          SKIP.
    
    
    FOR EACH w_criticas NO-LOCK USE-INDEX w_criticas1
                                BREAK BY w_criticas.cdagenci    
                                            BY w_criticas.nrdconta
                                               BY w_criticas.idseqttl:
         
        /* mostra quando eh inclusao/exclusao */
        IF   FIRST (w_criticas.nrdconta)   THEN
             DO:     
                 PAGE STREAM str_1.
             
                 PUT STREAM str_1 "*** CHEQUES SEM " AT 40  
                                  "INDICACAO DE TITULAR ***"   
                                  SKIP(1).
             END.

        IF   FIRST-OF(w_criticas.cdagenci)   THEN
             DO:
                 FIND crapage WHERE crapage.cdcooper = glb_cdcooper        AND
                                    crapage.cdagenci = w_criticas.cdagenci
                                    NO-LOCK NO-ERROR.
                                
                 PUT STREAM str_1 "PA: " w_criticas.cdagenci " - "
                                   crapage.nmresage SKIP.
             END.
    
        
        FIND LAST b_criticas WHERE b_criticas.nrdconta = w_criticas.nrdconta.
       
        ASSIGN aux_contattl = b_criticas.idseqttl.
                
        IF  w_criticas.idseqttl <> aux_contattl THEN
            DO:
                IF  FIRST-OF(w_criticas.idseqttl) THEN
                    DISPLAY STREAM str_1
                        w_criticas.nrdconta  WHEN FIRST-OF(w_criticas.nrdconta)
                        w_criticas.nrdctitg  WHEN FIRST-OF(w_criticas.nrdconta)
                        w_criticas.idseqttl  WHEN FIRST-OF(w_criticas.idseqttl)
                        w_criticas.nmextttl  WHEN FIRST-OF(w_criticas.idseqttl)
                        FORMAT "x(29)"
                        w_criticas.dtfimest  FORMAT "99/99/99"
                        w_criticas.nrcpfcgc  WHEN FIRST-OF(w_criticas.idseqttl)
                        WITH FRAME f_criticas.
            END.
        ELSE
            DISPLAY STREAM str_1
                    w_criticas.nrdconta  WHEN FIRST-OF(w_criticas.nrdconta)
                    w_criticas.nrdctitg  WHEN FIRST-OF(w_criticas.nrdconta)
                    w_criticas.idseqttl  WHEN FIRST-OF(w_criticas.idseqttl)
                    w_criticas.nmextttl  WHEN FIRST-OF(w_criticas.idseqttl)
                    FORMAT "x(29)"
                    w_criticas.dtfimest  FORMAT "99/99/99"
                    w_criticas.nrcpfcgc  WHEN FIRST-OF(w_criticas.idseqttl)
                    w_criticas.nrcheque
                    w_criticas.cdobserv    
                    w_criticas.vlcheque
                    WITH FRAME f_criticas.
            
        DOWN STREAM str_1 WITH FRAME f_criticas.
        
        
        IF   LAST-OF(w_criticas.nrdconta)   THEN  /*pular linha a cada conta*/
             PUT STREAM str_1 SKIP(1).
                
        IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
             DO:
                 PAGE STREAM str_1.

                 PUT STREAM str_1 "*** CHEQUES SEM " AT 40 
                                  "INDICACAO DE TITULAR ***"  
                                  SKIP(1) .
                 
                 PUT STREAM str_1 "PA: " w_criticas.cdagenci " - "
                                   crapage.nmresage SKIP.
             END.
         
    END.    
    
    OUTPUT STREAM str_1 CLOSE.
    
    IF   glb_cdcooper = 5  THEN
         ASSIGN glb_nrcopias = 2.
    ELSE
         ASSIGN glb_nrcopias = 1.
         
    ASSIGN glb_nmformul = "132col"
           glb_nmarqimp = aux_nmarqrel.
          
    RUN fontes/imprim.p.
          
    /* se nao estiver rodando no PROCESSO copia relatorio para "/rlnsv" */
    IF   glb_inproces = 1   THEN
         UNIX SILENT VALUE("cp " + aux_nmarqrel + " rlnsv/" +
                           SUBSTRING(aux_nmarqrel,R-INDEX(aux_nmarqrel,"/") + 1,
                           LENGTH(aux_nmarqrel) - R-INDEX(aux_nmarqrel,"/"))).

END PROCEDURE.
/*...........................................................................*/

