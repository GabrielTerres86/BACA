/*..............................................................................

   Programa: fontes/crps549.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme/Supero
   Data    : Marco/2010                        Ultima atualizacao: 28/11/2018

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Fonte baseado no crps468
               Gerar arquivo de inclusao/retirada do CCF.
               Emite o relatorio crrl548. 

   Alteracoes: 05/04/2010 - Alterado para processar todas cooperativas, nao
                            mais por cooperativa Singular (Guilherme/Supero)
                            
               01/06/2010 - Acertos Gerais (Guilherme).
               
               16/09/2010 - Utilizar o imprim_unif (Guilherme).
               
               09/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               05/11/2013 - Alterado totalizador de PAs de 99 para 999.
                            (Reinert)
                            
               11/09/2014 - Ajuste migraçao Concredi, ao enviar arquivo(registro)    
                            verificar se é uma conta migrada e enviar a cta antiga
                            (Odirlei/Amcom).
                                         
               25/11/2014 - Incluir clausula no craptco flgativo = TRUE
                            (Lucas R./Rodrigo)                                       
                            
               18/10/2016 - #536120 - Correção da verificação de incorporação
                            das cooperativas concredi e credimilsul (Carlos)

               29/11/2016 - Incorporacao Transulcred (Guilherme/SUPERO)

			   18/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                crapass, crapttl, crapjur 
							(Adriano - P339).
              
               29/05/2018 - Alteracao no layout. Sera gerado respeitando o layout CCF607 da ABBC. 
                            Chamado SCTASK0012791 (Heitor - Mouts)
					  
               28/11/2018 - Inclusão da coluna que lista as datas dos cheques devolvidos pela alinea 12.
                            Chamado SCTASK0029233 (Marco Amorim - Mouts)		

..............................................................................*/
                  
{ includes/var_batch.i }

DEF STREAM str_1.
DEF STREAM str_2.

DEF BUFFER crabneg   FOR crapneg.
DEF BUFFER crabttl   FOR crapttl.
DEF BUFFER crabcop   FOR crapcop.
DEF BUFFER b-crapcop FOR crapcop.

DEF TEMP-TABLE w_enviados
    FIELD cdcooper LIKE crapcop.cdcooper
    FIELD cdagenci LIKE crapass.cdagenci
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD idseqttl LIKE crapttl.idseqttl
    FIELD flginclu AS LOGICAL FORMAT "INCLUSAO NO CCF/EXCLUSAO DO CCF"
    FIELD nmextttl LIKE crapttl.nmextttl 
	FIELD dtiniest LIKE crapneg.dtiniest
    FIELD dtfimest LIKE crapneg.dtfimest
    FIELD nrcpfcgc LIKE crapttl.nrcpfcgc    
    FIELD nrcheque LIKE crapneg.nrdocmto
    FIELD cdobserv LIKE crapneg.cdobserv   
    FIELD vlcheque LIKE crapneg.vlestour
    INDEX w_enviados1 cdcooper flginclu cdagenci nrdconta idseqttl
    INDEX w_enviados2 cdcooper cdagenci flginclu nrdconta idseqttl.
    
DEF TEMP-TABLE w_criticas
    FIELD cdcooper LIKE crapcop.cdcooper
    FIELD cdagenci LIKE crapass.cdagenci
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD idseqttl LIKE crapttl.idseqttl
    FIELD nmextttl LIKE crapttl.nmextttl 
	FIELD dtiniest LIKE crapneg.dtiniest
    FIELD dtfimest LIKE crapneg.dtfimest
    FIELD nrcpfcgc LIKE crapttl.nrcpfcgc 
    FIELD nrcheque LIKE crapneg.nrdocmto
    FIELD cdobserv LIKE crapneg.cdobserv 
    FIELD vlcheque LIKE crapneg.vlestour
    INDEX w_criticas1 cdcooper cdagenci nrdconta idseqttl.

DEF BUFFER b_criticas FOR w_criticas.      

DEF VAR aux_contattl AS INT                                            NO-UNDO.
DEF VAR flg_containd AS LOG                                            NO-UNDO.
DEF VAR aux_flgctitg AS INT                                            NO-UNDO.
 
DEF VAR aux_nmarqlog AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqimp_607 AS CHAR                                       NO-UNDO.
DEF VAR aux_nmextttl AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqrel AS CHAR                                           NO-UNDO.

DEF VAR aux_nrrettab AS INTE                                           NO-UNDO.
DEF VAR aux_inpessoa AS INTE                                           NO-UNDO.
DEF VAR aux_cddifttl AS INTE                                           NO-UNDO.
DEF VAR aux_nrcheque AS INTE                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_idseqttl_607 AS INTE                                       NO-UNDO.
DEF VAR aux_nrtextab AS INTE                                           NO-UNDO.
DEF VAR aux_nrtextab_607 AS INTE                                       NO-UNDO.
DEF VAR aux_qttpreg2 AS INTE                                           NO-UNDO.
DEF VAR aux_qttpreg4 AS INTE                                           NO-UNDO.
DEF VAR aux_qttpreg6 AS INTE                                           NO-UNDO.
DEF VAR aux_qtreg607     AS INTE                                       NO-UNDO.
DEF VAR aux_maxregis AS INTE                                           NO-UNDO.
DEF VAR aux_tpregist AS INTE                                           NO-UNDO.
DEF VAR aux_tpcomand     AS INTE                                       NO-UNDO.
DEF VAR aux_nrdconta_arq LIKE crapass.nrdconta                         NO-UNDO.
DEF VAR aux_cdagechq_arq LIKE crapcop.cdagectl                         NO-UNDO.

DEF VAR aux_vlcheque AS DECI                                           NO-UNDO.
DEF VAR aux_nrcpfcgc AS DECI                                           NO-UNDO. 
DEF VAR aux_dscooper AS CHAR                                           NO-UNDO.

DEF VAR aux_flgvisto AS LOGI                                           NO-UNDO.
                                                                       
DEF VAR rel_nrmodulo AS INTE    FORMAT "9"                             NO-UNDO.
                                                                       
DEF VAR rel_nmempres AS CHAR    FORMAT "x(15)"                         NO-UNDO.
DEF VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5                NO-UNDO.

DEF VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                                INIT ["DEP. A VISTA   ","CAPITAL        ",
                                      "EMPRESTIMOS    ","DIGITACAO      ",
                                      "GENERICO       "]               NO-UNDO.
                                                                         
FORM w_enviados.nrdconta    AT   5   LABEL "Conta/DV"
     w_enviados.idseqttl             LABEL "Tit."
     w_enviados.nmextttl             LABEL "Nome do Titular" FORMAT "x(29)"
     w_enviados.nrcpfcgc             LABEL "CPF/CNPJ" 
     w_enviados.nrcheque             LABEL "Cheque"
     w_enviados.cdobserv             LABEL "Alinea"
     w_enviados.dtiniest             LABEL "Data Dev" FORMAT "99/99/99"	 
     w_enviados.dtfimest             LABEL "Data Reg" FORMAT "99/99/99"
     w_enviados.vlcheque             LABEL "Valor"
     WITH DOWN NO-LABELS WIDTH 132 FRAME f_enviados.


FORM w_criticas.nrdconta    AT   5   LABEL "Conta/DV"
     w_criticas.idseqttl             LABEL "Tit."
     w_criticas.nmextttl             LABEL "Nome do Titular" FORMAT "x(29)"
     w_criticas.nrcpfcgc             LABEL "CPF/CNPJ"  
     w_criticas.nrcheque             LABEL "Cheque"
     w_criticas.cdobserv             LABEL "Alinea"
     w_criticas.dtiniest             LABEL "Data Dev" FORMAT "99/99/99"	 
     w_criticas.dtfimest             LABEL "Data Reg" FORMAT "99/99/99"
     w_criticas.vlcheque             LABEL "Valor"
     WITH DOWN NO-LABELS WIDTH 132 FRAME f_criticas.     


ASSIGN glb_cdprogra = "crps549"
       glb_flgbatch = FALSE.
       
RUN fontes/iniprg.p.

IF  glb_cdcritic > 0  THEN
    DO:
        RUN fontes/fimprg.p.
        RETURN.
    END.
    
ASSIGN aux_dscooper = "/usr/coop/cecred/".

RUN abre_arquivo.
RUN abre_arquivo_607.

IF  glb_cdcritic > 0  THEN
    DO:
        RUN fontes/fimprg.p.
        RETURN.
    END.

ASSIGN aux_nrrettab = aux_nrtextab
       aux_nmarqlog = "log/prcctl_" + 
                      STRING(YEAR(glb_dtmvtolt),"9999") + 
                      STRING(MONTH(glb_dtmvtolt),"99") + 
                      STRING(DAY(glb_dtmvtolt),"99") + ".log".

FOR EACH crapcop
   WHERE crapcop.cdcooper <> 3 NO-LOCK:

    /*** Procura os associados que devem ser inclusos no CCF ***/
    FOR EACH crapneg WHERE crapneg.cdcooper  = crapcop.cdcooper   AND
                           crapneg.cdbanchq  = crapcop.cdbcoctl   AND 
                           crapneg.cdhisest  = 1                  AND
                           crapneg.dtfimest  = ?                  AND
                           crapneg.dtiniest <= (glb_dtmvtolt - 9) AND
                          (crapneg.cdobserv  = 12                 OR
                           crapneg.cdobserv  = 13)                AND
                          (crapneg.flgctitg  = 0                  OR
                           crapneg.flgctitg  = 4)                  
                           NO-LOCK USE-INDEX crapneg6:

        DO WHILE TRUE:

            FIND crabneg WHERE crabneg.cdcooper = crapneg.cdcooper AND
                               crabneg.nrdconta = crapneg.nrdconta AND
                               crabneg.nrseqdig = crapneg.nrseqdig
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crabneg  THEN
                IF  LOCKED crabneg  THEN
                    DO:
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.

                LEAVE.

        END. /*** Fim do DO WHILE TRUE ***/

        ASSIGN crabneg.flgctitg = 5.

    END. /*** Fim do FOR EACH crapneg ***/

    FOR EACH crapneg WHERE crapneg.cdcooper  = crapcop.cdcooper  AND
                           crapneg.cdbanchq  = crapcop.cdbcoctl  AND
                           crapneg.cdhisest  = 1                 AND
                          (crapneg.cdobserv  = 12                OR
                           crapneg.cdobserv  = 13)               AND
                           crapneg.flgctitg >= 4 
                           USE-INDEX crapneg6:

        ASSIGN aux_flgctitg = 0. 

        FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper AND
                           crapass.nrdconta = crapneg.nrdconta NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE crapass  THEN
            NEXT.

        ASSIGN aux_nrcheque = INT(SUBSTRING(STRING(crapneg.nrdocmto,
                                            "9999999"),
                                            1,6))
               aux_vlcheque = crapneg.vlestour * 100.

    /*** Se for inclusao ou ocorreu erro na tentativa de inclusao anterior ***/
        IF  crapneg.flgctitg = 5                            OR
           (crapneg.flgctitg = 4 AND crapneg.dtfimest = ?)  THEN
            DO:
                ASSIGN aux_tpregist = 4
                       aux_tpcomand = 10
                       aux_inpessoa = crapass.inpessoa.

                IF  crapass.inpessoa = 1  THEN

                    /** Manda para CCF o titular que assinou o cheque **/
                    FOR EACH crapttl WHERE 
                                     crapttl.cdcooper = crapcop.cdcooper AND
                                     crapttl.nrdconta = crapass.nrdconta 
                                     NO-LOCK BY crapttl.idseqttl:


                        ASSIGN flg_containd = FALSE.

                        /*** Verifica se eh conta individual ***/
                        IF  crapttl.idseqttl = 1  THEN
                            DO:
                                FIND FIRST crabttl
                                     WHERE crabttl.cdcooper = crapcop.cdcooper
                                       AND crabttl.nrdconta = crapass.nrdconta
                                       AND crabttl.idseqttl > 1
                                   NO-LOCK NO-ERROR.

                                IF  NOT AVAILABLE crabttl  THEN
                                    ASSIGN flg_containd  = TRUE.
                            END.


                        IF crapttl.idseqttl = crapneg.idseqttl OR
                           crapneg.idseqttl = 9                OR
                           flg_containd     = TRUE             THEN
                           DO:                           
                               ASSIGN aux_nrcpfcgc = crapttl.nrcpfcgc
                                      aux_nmextttl = crapttl.nmextttl
                                      aux_idseqttl = crapttl.idseqttl
                                      aux_idseqttl_607 = crapttl.idseqttl
                                      aux_cddifttl = crapttl.idseqttl.


                           /*** Se nao for conta conjunta atribui valor 0 ***/
                               IF  crapttl.idseqttl = 1  THEN DO:
                                  FIND FIRST crabttl
                                       WHERE crabttl.cdcooper = crapcop.cdcooper
                                         AND crabttl.nrdconta = crapass.nrdconta
                                         AND crabttl.idseqttl > 1
                                       NO-LOCK NO-ERROR.

                                  IF  NOT AVAILABLE crabttl  THEN
                                      ASSIGN aux_cddifttl     = 0
                                             aux_idseqttl_607 = 1.
                               END.
                               
                               ASSIGN aux_flgctitg = 1.       
                               
                               RUN registro.
                           END.
                          
                        IF  crapneg.idseqttl = 0       AND 
                            flg_containd     = FALSE   THEN
                            DO:  
                                 CREATE w_criticas.
                                 ASSIGN w_criticas.cdcooper = crapcop.cdcooper
                                        w_criticas.cdagenci = crapass.cdagenci
                                        w_criticas.nrdconta = crapass.nrdconta
                                        w_criticas.idseqttl = crapttl.idseqttl 
                                        w_criticas.nmextttl = crapttl.nmextttl
										w_criticas.dtiniest = crapneg.dtiniest
                                        w_criticas.dtfimest = crapneg.dtfimest
                                        w_criticas.nrcpfcgc = crapttl.nrcpfcgc
                                        w_criticas.nrcheque = crapneg.nrdocmto
                                        w_criticas.cdobserv = crapneg.cdobserv
                                        w_criticas.vlcheque = crapneg.vlestour.
                                IF  crapneg.cdobserv = 12  THEN
                                DO:
                                   ASSIGN w_criticas.dtfimest = crapneg.dtfimest.
                                END.
                            END.
                    
                    END. /*** Fim do FOR EACH crapttl ***/
                ELSE     /**** PESSOA JURIDICA ****/
                    DO:
                        ASSIGN aux_nrcpfcgc = crapass.nrcpfcgc
                               aux_nmextttl = crapass.nmprimtl
                               aux_idseqttl = 1
                               aux_cddifttl = 0
                               aux_idseqttl_607 = 1
                               aux_flgctitg = 1. /**enviado**/
                               
                        RUN registro.
                    END. 
            
            END.
                
        ELSE
    /*** Se for exclusao ou ocorreu erro na tentativa de exclusao anterior ***/
        IF  crapneg.flgctitg = 6                             OR
           (crapneg.flgctitg = 4 AND crapneg.dtfimest <> ?)  THEN
            DO:
                ASSIGN aux_tpregist = 2
                       aux_tpcomand = 50
                       aux_inpessoa = crapass.inpessoa
                       aux_cddifttl = 0.
                
                IF  crapass.inpessoa = 1  THEN
                    DO:
                        /** Exclui do CCF o titular que assinou o cheque **/
                        FOR EACH crapttl WHERE 
                                         crapttl.cdcooper = crapcop.cdcooper AND
                                         crapttl.nrdconta = crapass.nrdconta 
                                         NO-LOCK BY crapttl.idseqttl:
                            
                            ASSIGN flg_containd = FALSE.
                            
                            /*** Verifica se a conta eh individual ***/
                            IF  crapttl.idseqttl = 1  THEN
                                DO:
                                   FIND FIRST crabttl
                                        WHERE crabttl.cdcooper = crapcop.cdcooper
                                          AND crabttl.nrdconta = crapass.nrdconta
                                          AND crabttl.idseqttl > 1
                                           NO-LOCK NO-ERROR.
                                           
                                   IF  NOT AVAILABLE crabttl  THEN
                                       ASSIGN flg_containd     = TRUE
                                              aux_idseqttl_607 = 1.
                                END.
    
                            
                            IF  crapttl.idseqttl = crapneg.idseqttl OR
                                crapneg.idseqttl = 9                OR
                                flg_containd     = TRUE             THEN
                                DO:                           
                                    ASSIGN aux_nrcpfcgc = crapttl.nrcpfcgc
                                           aux_nmextttl = crapttl.nmextttl
                                           aux_idseqttl = crapttl.idseqttl  
                                           aux_cddifttl     = crapttl.idseqttl
                                           aux_idseqttl_607 = crapttl.idseqttl.
                                           
                                    ASSIGN aux_flgctitg = 1. /**enviado**/
                                    RUN registro.
                                END.
                            
                            
                            IF  crapneg.idseqttl = 0     AND 
                                flg_containd     = FALSE THEN 
                                DO:   
    
                                   CREATE w_criticas.
                                   ASSIGN w_criticas.cdcooper = crapcop.cdcooper
                                          w_criticas.cdagenci = crapass.cdagenci
                                          w_criticas.nrdconta = crapass.nrdconta
                                          w_criticas.idseqttl = crapttl.idseqttl
                                          w_criticas.nmextttl = crapttl.nmextttl
										  w_criticas.dtiniest = crapneg.dtiniest
                                          w_criticas.dtfimest = crapneg.dtfimest
                                          w_criticas.nrcpfcgc = crapttl.nrcpfcgc
                                          w_criticas.nrcheque = crapneg.nrdocmto
                                          w_criticas.cdobserv = crapneg.cdobserv
                                          w_criticas.vlcheque = crapneg.vlestour.
                                     
                                END.
                            
                        END. /*** Fim do FOR EACH crapttl ***/
                    END.
                ELSE  
                    DO: 
                        ASSIGN aux_nrcpfcgc = crapass.nrcpfcgc
                               aux_nmextttl = crapass.nmprimtl
                               aux_idseqttl = 1
                               aux_flgctitg     = 1
                               aux_idseqttl_607 = 1.   
                               
                        RUN registro.
                     END.
            END.          
         
        ELSE
            NEXT.
        
        /* atualiza flag (flgctitg) da crapneg para enviada(1) */ 
        IF  aux_flgctitg = 1 THEN    
            DO:
               ASSIGN  crapneg.dtectitg = glb_dtmvtolt
                       crapneg.flgctitg = 1.
            END. 
    
    END. /*** Fim do FOR EACH crapneg ***/

END. /** END do FOR EACH da CRAPCOP **/

RUN fecha_arquivo.
RUN fecha_arquivo_607.

RUN rel_enviados. 

RUN fontes/fimprg.p.

/*-------------------------------- PROCEDURES --------------------------------*/

PROCEDURE abre_arquivo:
     
    FIND crabcop WHERE crabcop.cdcooper = 3 NO-LOCK NO-ERROR.
    
    FIND craptab WHERE craptab.cdcooper = crabcop.cdcooper AND
                       craptab.nmsistem = "CRED"           AND
                       craptab.tptabela = "GENERI"         AND
                       craptab.cdempres = 00               AND
                       craptab.cdacesso = "NRARQMVSER"     AND
                       craptab.tpregist = 001           
                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

    IF  NOT AVAILABLE craptab  THEN DO:

        ASSIGN glb_cdcritic = 55.
        RUN fontes/critic.p.
    
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - Processar: CCF" +
                          " - " + glb_cdprogra + '" --> "'  +
                          glb_dscritic + " >> " + aux_nmarqlog).
                    
        LEAVE.
    END.    

    ASSIGN aux_nrtextab = INT(SUBSTRING(craptab.dstextab,1,5))
           aux_nmarqimp = "SER_CCF_" +
                          STRING(DAY(glb_dtmvtolt),"99") +
                          STRING(MONTH(glb_dtmvtolt),"99") +
                          STRING(aux_nrtextab,"99999") + ".txt"
           aux_qttpreg2 = 0
           aux_qttpreg4 = 0
           aux_qttpreg6 = 0.
       
    OUTPUT STREAM str_1 TO VALUE("/usr/coop/cecred/arq/" + aux_nmarqimp).

    /*** Header ***/
    PUT STREAM str_1 crabcop.cdbcoctl       FORMAT "999"
                     FILL("0",27)           FORMAT "x(27)"
                     "0"
                     "SERASA-ACHEI"         FORMAT "x(12)"
                     DAY(glb_dtmvtolt)      FORMAT "99"
                     MONTH(glb_dtmvtolt)    FORMAT "99"
                     YEAR(glb_dtmvtolt)     FORMAT "9999"
                     aux_nrtextab           FORMAT "9999"
                     FILL(" ",73)           FORMAT "x(73)"
                     SKIP.  

END PROCEDURE.

PROCEDURE abre_arquivo_607:
     
    FIND crabcop WHERE crabcop.cdcooper = 3 NO-LOCK NO-ERROR.
    
    ASSIGN aux_nrtextab_607 = 1 /* Inicialmente sera apenas 1 remessa por dia */
           aux_nmarqimp_607 = "Z1" + /* Novo layout CCF607 para inclusao CCF */
                              STRING(crabcop.cdbcoctl,"999") + 
                              STRING(WEEKDAY(glb_dtmvtolt)) +
                              STRING(aux_nrtextab_607,"99") + ".REM"
           aux_qtreg607     = 1.
       
    OUTPUT STREAM str_2 TO VALUE("/usr/coop/cecred/arq/" + aux_nmarqimp_607).

    /*** Header Novo Layout - CCF607 ***/
    PUT STREAM str_2 FILL("0",3)            FORMAT "x(3)"        /* Identificacao Header - Fixo 000 */
                     "CCF607"               FORMAT "x(6)"        /* Nome do arquivo - Fixo CCF607 */
                     YEAR(glb_dtmvtolt)     FORMAT "9999"        /* Ano */
                     MONTH(glb_dtmvtolt)    FORMAT "99"          /* Mes */
                     DAY(glb_dtmvtolt)      FORMAT "99"          /* Dia */
                     crabcop.cdbcoctl       FORMAT "999"         /* Codigo do Banco remetente do arquivo (085) */
                     FILL("0",4)            FORMAT "x(4)"        /* Cesec processador - Uso exclusivo do executante */
                     FILL(" ",161)          FORMAT "x(161)"      /* Filler */
                     aux_nrtextab_607       FORMAT "99999"       /* Versao do arquivo, sequencial por data. Inicialmente sera 1 por dia */
                     aux_qtreg607           FORMAT "9999999999"  /* Sequencial de arquivo, inicia em 1 no Header, com incremento de 1 por registro */
                     SKIP.

END PROCEDURE.

PROCEDURE fecha_arquivo:
    
    /*** Trailer ***/
    PUT STREAM str_1 crabcop.cdbcoctl FORMAT "999"
                     FILL("0",27)     FORMAT "x(27)"
                     "9"
                     aux_qttpreg2     FORMAT "9999999"
                     aux_qttpreg4     FORMAT "9999999"
                     aux_qttpreg6     FORMAT "9999999"
                     FILL(" ",76)     FORMAT "x(76)".

    OUTPUT STREAM str_1 CLOSE.

    /*** Se arquivo gerado nao tem registros "detalhe", entao elimina ***/
    IF  aux_maxregis = 0  THEN DO:

        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - Processar: CCF" +
                      " - SERASA CCF - " + glb_cdprogra + '" --> "' + 
                      "O arquivo " + aux_nmarqimp + " estava sem " + 
                      "registros e foi removido. >> " + aux_nmarqlog).
        
        UNIX SILENT VALUE("rm " + aux_dscooper + "arq/"
                         + aux_nmarqimp + " 2>/dev/null"). 
        
        RETURN.        
    END.
    
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - Processar: CCF" +
                      " - SERASA CCF - " + glb_cdprogra + '" --> "' + 
                      "ATENCAO!! Envie o arquivo pelo Software do SERASA - " +
                      aux_nmarqimp + " >> " + 
                      aux_nmarqlog).
                                                          
    UNIX SILENT VALUE("ux2dos < " + aux_dscooper + "arq/" + aux_nmarqimp +  
                      ' | tr -d "\032"' +  
                      " > /micros/cecred/serasa/" + aux_nmarqimp + 
                      " 2>/dev/null").
      
    UNIX SILENT VALUE("mv " + aux_dscooper + "arq/" + aux_nmarqimp +
                      " " + aux_dscooper + "salvar 2>/dev/null"). 
    
    /*** Atualizacao da craptab ***/
    ASSIGN glb_cdcritic = 0
           aux_maxregis = 0
           aux_nrtextab = aux_nrtextab + 1
           SUBSTR(craptab.dstextab,1,5) = STRING(aux_nrtextab,"99999").

    FIND CURRENT craptab NO-LOCK NO-ERROR.
    RELEASE craptab.
    
END PROCEDURE.

PROCEDURE fecha_arquivo_607:
    
    /*** Trailer Novo Layout - CCF607***/
    ASSIGN aux_qtreg607 = aux_qtreg607 + 1.

    PUT STREAM str_2 FILL("9",3)            FORMAT "x(3)"        /* Identificacao Trailer - Fixo 999 */
                     "CCF607"               FORMAT "x(6)"        /* Nome do arquivo - Fixo CCF607 */
                     YEAR(glb_dtmvtolt)     FORMAT "9999"        /* Ano */
                     MONTH(glb_dtmvtolt)    FORMAT "99"          /* Mes */
                     DAY(glb_dtmvtolt)      FORMAT "99"          /* Dia */
                     crabcop.cdbcoctl       FORMAT "999"         /* Codigo do Banco remetente do arquivo (085) */
                     FILL(" ",165)          FORMAT "x(165)"      /* Filler */
                     aux_nrtextab_607       FORMAT "99999"       /* Versao do arquivo, sequencial por data. Inicialmente sera 1 por dia */
                     aux_qtreg607           FORMAT "9999999999". /* Sequencial de arquivo, inicia em 1 no Header, com incremento de 1 por registro */

    OUTPUT STREAM str_2 CLOSE.

    /*** Se arquivo gerado so tem "Header" e "Trailer", entao elimina ***/
    IF  aux_qtreg607 = 2  THEN DO:

        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - Processar: CCF" +
                      " - SERASA CCF - " + glb_cdprogra + '" --> "' + 
                      "O arquivo " + aux_nmarqimp_607 + " estava sem " + 
                      "registros e foi removido. >> " + aux_nmarqlog).

        /* Remover tambem o novo arquivo CCF607 */
        UNIX SILENT VALUE("rm " + aux_dscooper + "arq/"
                         + aux_nmarqimp_607 + " 2>/dev/null").
        RETURN.        
    END.
    
    /* Novo arquivo CCF607 */
    UNIX SILENT VALUE("ux2dos < " + aux_dscooper + "arq/" + aux_nmarqimp_607 +  
                      ' | tr -d "\032"' +  
                      " > /micros/cecred/abbc/" + aux_nmarqimp_607 + 
                      " 2>/dev/null").
    
	/* Envia FTP ABBC */
	UNIX SILENT VALUE('/usr/local/cecred/bin/ftpabbc_envia.pl' +
                                    ' --arquivo="' +
                                    '/micros/cecred/abbc/' + aux_nmarqimp_607 + '"').
	
	/* Novo arquivo CCF607 */
    UNIX SILENT VALUE("mv " + aux_dscooper + "arq/" + aux_nmarqimp_607 +
                      " " + aux_dscooper + "salvar 2>/dev/null"). 

END PROCEDURE.

PROCEDURE registro:

    IF  aux_maxregis = 9988  THEN  /*** Maximo 9990 linhas ***/
        DO: 
            RUN fecha_arquivo.
            RUN abre_arquivo.
            
            IF  glb_cdcritic > 0  THEN
                RETURN.
        END.
    
    ASSIGN aux_maxregis = aux_maxregis + 1.
    
    IF  aux_tpregist = 2  THEN
        ASSIGN aux_qttpreg2 = aux_qttpreg2 + 1.
    ELSE
    IF  aux_tpregist = 4  THEN
        ASSIGN aux_qttpreg4 = aux_qttpreg4 + 1.

    ASSIGN aux_nrdconta_arq = crapneg.nrdconta
           aux_cdagechq_arq = crapneg.cdagechq.


    /* verifica se é uma conta incorporada*/
    FIND FIRST craptco 
      WHERE craptco.cdcooper = crapcop.cdcooper
        AND craptco.nrdconta = crapneg.nrdconta 
           AND (craptco.cdcopant = 4  OR
                craptco.cdcopant = 15 OR
                craptco.cdcopant = 17) 
        AND craptco.flgativo = TRUE
        NO-LOCK NO-ERROR.

    /* se encontrar deve enviar cta antiga
       se o cheque for da coop. antiga */
    IF  AVAIL(craptco) THEN DO:

        /* COOP ANTIGA
          Verificar se Conta Migrada
          - Se for, verificar o FDC baseado no AGECHQ(AGECTL) da 
            Coop antiga.       */

        FIND FIRST b-crapcop
             WHERE b-crapcop.cdcooper = craptco.cdcopant
           NO-LOCK NO-ERROR.

      FIND FIRST crapfdc
     WHERE crapfdc.cdcooper = craptco.cdcopant
       AND crapfdc.cdbanchq = crapneg.cdbanchq
               AND crapfdc.cdagechq = b-crapcop.cdagectl /*crapneg.cdagechq*/
       AND crapfdc.nrctachq = craptco.nrctaant 
       AND crapfdc.nrcheque = aux_nrcheque 
        NO-LOCK NO-ERROR.
      
        IF  AVAIL crapfdc THEN DO: 
            ASSIGN aux_nrdconta_arq = craptco.nrctaant
                   aux_cdagechq_arq = crapfdc.cdagechq.          
      END.
    END. 

    /*** Detalhe ***/
    PUT STREAM str_1 crapcop.cdbcoctl           FORMAT "999"
                     aux_cdagechq_arq           FORMAT "9999"
                     aux_nrdconta_arq           FORMAT "999999999999"
                     aux_nrcheque               FORMAT "999999"
                     "01"
                     aux_cddifttl               FORMAT "99"
                     " "
                     aux_tpregist               FORMAT "9"
                     crapneg.cdobserv           FORMAT "99"
                     " "
                     aux_inpessoa               FORMAT "9"
                     aux_nrcpfcgc               FORMAT "99999999999999"
                     DAY(crapneg.dtiniest)      FORMAT "99"
                     MONTH(crapneg.dtiniest)    FORMAT "99"
                     YEAR(crapneg.dtiniest)     FORMAT "9999"
                     aux_vlcheque               FORMAT "99999999999999999"
                     aux_nmextttl               FORMAT "x(40)"
                     FILL(" ",14)               FORMAT "x(14)"
                     SKIP.
    
    ASSIGN aux_qtreg607 = aux_qtreg607 + 1.
    
    /*** Detalhe Novo arquivo CCF607 ***/
    PUT STREAM str_2 "1"                                                     /* Tipo de detalhe, fixo 1 */
                     aux_tpcomand               FORMAT "99"                  /* Tipo de comando, 10-Inclusao, 50-Exclusao */
                     aux_nrcpfcgc               FORMAT "99999999999999"      /* Numero do CPF/CNPJ */
                     crapcop.cdbcoctl           FORMAT "999"                 /* Codigo do banco (085) */
                     crapcop.cdagectl           FORMAT "9999"                /* Codigo da agencia */
                     aux_nrdconta_arq           FORMAT "999999999999"        /* Numero da conta */
                     aux_nrcheque               FORMAT "999999"              /* Numero do cheque */
                     aux_vlcheque               FORMAT "99999999999999999"   /* Valor do cheque */
                     crapneg.cdobserv           FORMAT "99"                  /* Motivo da devolucao */
                     YEAR(crapneg.dtiniest)     FORMAT "9999"                /* Data da devolucao */
                     MONTH(crapneg.dtiniest)    FORMAT "99"                  /* Data da devolucao */
                     DAY(crapneg.dtiniest)      FORMAT "99"                  /* Data da devolucao */
                     aux_nmextttl               FORMAT "x(40)"               /* Nome do correntista */
                     aux_idseqttl_607           FORMAT "99"                  /* Titularizacao */
                     aux_inpessoa               FORMAT "99"                  /* Tipo de pessoa */
                     YEAR(glb_dtmvtolt)         FORMAT "9999"                /* Data da inclusao */
                     MONTH(glb_dtmvtolt)        FORMAT "99"                  /* Data da inclusao */
                     DAY(glb_dtmvtolt)          FORMAT "99"                  /* Data da inclusao */
                     "01"                                                    /* Sequencial de cheque do titular */
                     "00000"                                                 /* Quantidade de ocorrencias */
                     "00000000000000"                                        /* CNPJ Original */
                     "00"                                                    /* Natureza Juridica */
                     "000"                                                   /* Banco absorvedor */
                     FILL(" ",38)               FORMAT "x(38)"               /* Filler */
                     aux_nrtextab_607           FORMAT "99999"               /* Versao do arquivo, sequencial por data. Inicialmente sera 1 por dia */
                     aux_qtreg607               FORMAT "9999999999"          /* Sequencial de arquivo, inicia em 1 no Header, com incremento de 1 por registro */
                     SKIP.

    CREATE w_enviados.
    ASSIGN w_enviados.cdcooper = crapcop.cdcooper
           w_enviados.cdagenci = crapass.cdagenci
           w_enviados.nrdconta = crapass.nrdconta
           w_enviados.idseqttl = aux_idseqttl
		   w_enviados.dtiniest = crapneg.dtiniest
           w_enviados.dtfimest = crapneg.dtfimest
           w_enviados.flginclu = IF  crapneg.flgctitg = 5   OR
                                    (crapneg.flgctitg = 4   AND
                                     crapneg.dtfimest = ?)  THEN  
                                     YES
                                 ELSE 
                                     NO
           w_enviados.nmextttl = aux_nmextttl 
           w_enviados.nrcpfcgc = aux_nrcpfcgc     
           w_enviados.nrcheque = crapneg.nrdocmto
           w_enviados.cdobserv = crapneg.cdobserv 
           w_enviados.vlcheque = crapneg.vlestour.

END PROCEDURE.

PROCEDURE rel_enviados:

    DEF VAR aux_dscooper AS CHAR                                    NO-UNDO.

    /*** Monta o cabecalho ***/
    { includes/cabrel132_1.i }

    FOR EACH w_enviados NO-LOCK USE-INDEX w_enviados1
                                BREAK BY w_enviados.cdcooper
                                      BY w_enviados.flginclu DESCENDING
                                      BY w_enviados.cdagenci
                                      BY w_enviados.nrdconta
                                      BY w_enviados.idseqttl:

        IF  FIRST-OF(w_enviados.cdcooper)  THEN DO:

            ASSIGN aux_flgvisto = FALSE.

            FIND crapcop WHERE crapcop.cdcooper = w_enviados.cdcooper
                               NO-LOCK NO-ERROR.
    
            ASSIGN aux_dscooper = "/usr/coop/" + crapcop.dsdircop + "/".
            ASSIGN aux_nmarqrel = aux_dscooper + "rl/crrl548_999.lst".

            OUTPUT STREAM str_1 TO VALUE(aux_nmarqrel) APPEND PAGED PAGE-SIZE 84.

            VIEW STREAM str_1 FRAME f_cabrel132_1.

        END.
                                                   
        IF  FIRST-OF(w_enviados.flginclu)  THEN DO:
            /*** Quebra pagina se exclusao, seta para imprimir visto ***/
            IF  NOT w_enviados.flginclu  THEN
                DO:
                    PAGE STREAM str_1.
                    
                    ASSIGN aux_flgvisto = TRUE.
                END.
         
            PUT STREAM str_1 "*** " AT 54 
                             w_enviados.flginclu 
                             " ***"
                             SKIP(1).
        END.

        IF  FIRST-OF(w_enviados.cdagenci)  THEN DO:

            FIND crapage WHERE crapage.cdcooper = w_enviados.cdcooper AND
                               crapage.cdagenci = w_enviados.cdagenci
                               NO-LOCK NO-ERROR.
            
            PUT STREAM str_1 "PA: " w_enviados.cdagenci " - " 
                                     crapage.nmresage FORMAT "x(15)"
                              SKIP.
        END.

        DISPLAY STREAM str_1
                w_enviados.nrdconta  WHEN FIRST-OF(w_enviados.nrdconta)
                w_enviados.idseqttl  WHEN FIRST-OF(w_enviados.idseqttl)
                w_enviados.nmextttl  WHEN FIRST-OF(w_enviados.idseqttl)
                w_enviados.nrcpfcgc  WHEN FIRST-OF(w_enviados.idseqttl)
                w_enviados.nrcheque
				w_enviados.dtiniest
                w_enviados.dtfimest
                w_enviados.cdobserv   
                w_enviados.vlcheque
                WITH FRAME f_enviados.
            
        DOWN STREAM str_1 WITH FRAME f_enviados.
    
        IF  LAST-OF(w_enviados.nrdconta)  THEN  
            PUT STREAM str_1 SKIP(1).
                
        IF  LINE-COUNTER(str_1) > PAGE-SIZE(str_1)  THEN
            DO:
                PAGE STREAM str_1.

                VIEW STREAM str_1 FRAME f_cabrel132_1.
            
                PUT STREAM str_1 "PA: " w_enviados.cdagenci " - "
                                 crapage.nmresage FORMAT "x(15)" SKIP.
            END.

        IF LAST-OF(w_enviados.cdcooper) THEN
        DO:
            IF  aux_flgvisto  THEN
                PUT STREAM str_1 SKIP(3)
                                 "____________________________"   AT 51
                                 SKIP
                                 "         ASSINATURA"            AT 51
                                 SKIP.
            
            /**** Relatorio de Criticas  ****/
            FOR EACH w_criticas NO-LOCK WHERE 
                     w_criticas.cdcooper = w_enviados.cdcooper 
                                       USE-INDEX w_criticas1
                                        BREAK BY w_criticas.cdcooper
                                              BY w_criticas.cdagenci
                                              BY w_criticas.nrdconta
                                              BY w_criticas.idseqttl:

                IF  FIRST(w_criticas.cdagenci)  THEN
                    DO:

                        PAGE STREAM str_1.

                        VIEW STREAM str_1 FRAME f_cabrel132_1.
                        
                        PUT STREAM str_1 "*** " AT 40 
                                         "CHEQUES SEM INDICACAO DE TITULAR"
                                         " ***"
                                         SKIP(1).
                    END.

                IF  FIRST-OF(w_criticas.cdagenci)  THEN
                    DO:
                        FIND crapage WHERE 
                             crapage.cdcooper = w_criticas.cdcooper AND
                             crapage.cdagenci = w_criticas.cdagenci
                             NO-LOCK NO-ERROR.

                        PUT STREAM str_1 "PA: " w_criticas.cdagenci " - " 
                                         crapage.nmresage FORMAT "x(15)"
                                         SKIP.
                    END.

                FIND LAST b_criticas WHERE 
                          b_criticas.nrdconta = w_criticas.nrdconta
                          NO-LOCK NO-ERROR.

                ASSIGN aux_contattl = b_criticas.idseqttl.

                IF  w_criticas.idseqttl <> aux_contattl THEN
                    DO:
                        IF  FIRST-OF(w_criticas.idseqttl) THEN
                            DISPLAY STREAM str_1
                               w_criticas.nrdconta  
                                               WHEN FIRST-OF(w_criticas.nrdconta)
                               w_criticas.idseqttl  
                                               WHEN FIRST-OF(w_criticas.idseqttl)
                               w_criticas.nmextttl  
                                               WHEN FIRST-OF(w_criticas.idseqttl)  
                               w_criticas.nrcpfcgc  
                                               WHEN FIRST-OF(w_criticas.idseqttl)
							   w_criticas.dtiniest						   
                               w_criticas.dtfimest
                               WITH FRAME f_criticas.
                    END.
                ELSE
                    DISPLAY STREAM str_1
                            w_criticas.nrdconta  
                                               WHEN FIRST-OF(w_criticas.nrdconta)
                            w_criticas.idseqttl  
                                               WHEN FIRST-OF(w_criticas.idseqttl)
                            w_criticas.nmextttl  
                                               WHEN FIRST-OF(w_criticas.idseqttl)  
                            w_criticas.nrcpfcgc  
                                               WHEN FIRST-OF(w_criticas.idseqttl)
                            w_criticas.nrcheque
                            w_criticas.cdobserv
                            w_criticas.dtiniest                              
                            w_criticas.dtfimest							
                            w_criticas.vlcheque
                            WITH FRAME f_criticas.

                DOWN STREAM str_1 WITH FRAME f_criticas.

                IF  LAST-OF(w_criticas.nrdconta)  THEN  
                    PUT STREAM str_1 SKIP(1).

                IF  LINE-COUNTER(str_1) > PAGE-SIZE(str_1)  THEN DO:

                    PAGE STREAM str_1.
                    VIEW STREAM str_1 FRAME f_cabrel132_1.

                    PUT STREAM str_1 "*** " AT 40 
                                     "CHEQUES SEM INDICACAO DE TITULAR"
                                     " ***"
                                     SKIP(1).

                    PUT STREAM str_1 "PA: " w_criticas.cdagenci " - "
                                     crapage.nmresage FORMAT "x(15)" 
                                     SKIP.
                END.

            END. /** Fim do FOR EACH w_criticas **/

            OUTPUT STREAM str_1 CLOSE.

            ASSIGN glb_nmformul = "132col"
                   glb_nmarqimp = aux_nmarqrel
                   glb_nrcopias = 1.

            RUN fontes/imprim_unif.p (INPUT w_enviados.cdcooper).

            /*** Se nao estiver rodando no PROCESSO copia relatorio ***/
            IF  glb_inproces = 1  THEN
                UNIX SILENT VALUE("cp " + aux_nmarqrel + " " + 
                     aux_dscooper + "rlnsv/" +   
                     SUBSTRING(aux_nmarqrel,R-INDEX(aux_nmarqrel,"/") + 1,
                     LENGTH(aux_nmarqrel) - R-INDEX(aux_nmarqrel,"/"))).

        END.

    END. /** Fim do FOR EACH w_enviados **/
    
    FOR EACH w_enviados NO-LOCK USE-INDEX w_enviados2
                                BREAK BY w_enviados.cdcooper
                                      BY w_enviados.cdagenci
                                      BY w_enviados.flginclu DESCENDING
                                      BY w_enviados.nrdconta
                                      BY w_enviados.idseqttl:

        IF  FIRST-OF(w_enviados.cdcooper)  THEN DO:
            FIND crapcop WHERE crapcop.cdcooper = w_enviados.cdcooper
                               NO-LOCK NO-ERROR.
    
            ASSIGN aux_dscooper = "/usr/coop/" + crapcop.dsdircop + "/".
        END.


        IF  FIRST-OF(w_enviados.cdagenci)  THEN DO:

            ASSIGN aux_nmarqrel = aux_dscooper + "rl/crrl548_" + 
                                  STRING(w_enviados.cdagenci,"999") +
                                  ".lst".

            OUTPUT STREAM str_1 TO VALUE(aux_nmarqrel) 
                                APPEND PAGED PAGE-SIZE 84.
            
            VIEW STREAM str_1 FRAME f_cabrel132_1.
            
            FIND crapage WHERE crapage.cdcooper = w_enviados.cdcooper AND
                               crapage.cdagenci = w_enviados.cdagenci
                               NO-LOCK NO-ERROR.
            
            PUT STREAM str_1 SKIP
                             "PA: " crapage.cdagenci " - " crapage.nmresage
                             SKIP(1).
        END.
            
        IF  FIRST-OF(w_enviados.flginclu)  THEN
            DO:
                
               IF  NOT w_enviados.flginclu  THEN
                   DO:
                        PAGE STREAM str_1.
                   END.
                
               PUT STREAM str_1  "*** " AT 54 
                                 w_enviados.flginclu 
                                 " ***"
                                 SKIP(1).
            END.

        DISPLAY STREAM str_1
                w_enviados.nrdconta  WHEN FIRST-OF(w_enviados.nrdconta)
                w_enviados.idseqttl  WHEN FIRST-OF(w_enviados.idseqttl)
                w_enviados.nmextttl  WHEN FIRST-OF(w_enviados.idseqttl)
                w_enviados.nrcpfcgc  WHEN FIRST-OF(w_enviados.idseqttl)
                w_enviados.nrcheque
                w_enviados.cdobserv
                w_enviados.dtiniest
                w_enviados.dtfimest                
                w_enviados.vlcheque
                WITH FRAME f_enviados.
            
        DOWN STREAM str_1 WITH FRAME f_enviados.
    
        IF  LAST-OF(w_enviados.nrdconta)  THEN  
            PUT STREAM str_1 SKIP(1).
                
        IF  LINE-COUNTER(str_1) > PAGE-SIZE(str_1)  THEN
            DO:
                PAGE STREAM str_1.

                PUT STREAM str_1 SKIP
                                 "PA: " w_enviados.cdagenci " - "
                                 crapage.nmresage 
                                 SKIP(1).
            END.

        IF  LAST-OF(w_enviados.cdagenci)  THEN
            DO:
                /* Quebra pagina para relatorio de criticas do PA */
                PAGE STREAM str_1.

                PUT STREAM str_1 "*** " AT 40 
                                 "CHEQUES SEM INDICACAO DE TITULAR"  
                                 " ***"
                                 SKIP(1).

                PUT STREAM str_1 SKIP
                                 "PA: " w_enviados.cdagenci " - " 
                                 crapage.nmresage FORMAT "x(15)"
                                 SKIP(1).

                /******  Relatorio de criticas para cada PA  ******/
                FOR EACH w_criticas NO-LOCK WHERE 
                         w_criticas.cdcooper = w_enviados.cdcooper AND
                         w_criticas.cdagenci = w_enviados.cdagenci 
                         USE-INDEX w_criticas1
                                BREAK BY w_criticas.cdcooper
                                      BY w_criticas.cdagenci
                                      BY w_criticas.nrdconta
                                      BY w_criticas.idseqttl:
    
                    FIND LAST b_criticas WHERE 
                              b_criticas.nrdconta = w_criticas.nrdconta 
                              NO-LOCK NO-ERROR.
    
                    ASSIGN aux_contattl = b_criticas.idseqttl.
    
                    IF  w_criticas.idseqttl <> aux_contattl THEN
                        DO:
                            IF  FIRST-OF(w_criticas.idseqttl) THEN
                                DISPLAY STREAM str_1
                                   w_criticas.nrdconta  
                                               WHEN FIRST-OF(w_criticas.nrdconta)
                                   w_criticas.idseqttl  
                                               WHEN FIRST-OF(w_criticas.idseqttl)
                                   w_criticas.nmextttl  
                                               WHEN FIRST-OF(w_criticas.idseqttl)
                                   w_criticas.nrcpfcgc  
                                               WHEN FIRST-OF(w_criticas.idseqttl)
								   w_criticas.dtiniest              
                                   w_criticas.dtfimest
                                   WITH FRAME f_criticas.
                        END.
                    ELSE
                        DISPLAY STREAM str_1
                                w_criticas.nrdconta  
                                               WHEN FIRST-OF(w_criticas.nrdconta)
                                w_criticas.idseqttl  
                                               WHEN FIRST-OF(w_criticas.idseqttl)
                                w_criticas.nmextttl  
                                               WHEN FIRST-OF(w_criticas.idseqttl)  
                                w_criticas.nrcpfcgc  
                                               WHEN FIRST-OF(w_criticas.idseqttl)
                                w_criticas.nrcheque
                                w_criticas.cdobserv
                                w_criticas.dtiniest              
                                w_criticas.dtfimest								
                                w_criticas.vlcheque
                                WITH FRAME f_criticas.
    
                    DOWN STREAM str_1 WITH FRAME f_criticas.
    
                    IF  LAST-OF(w_criticas.nrdconta)  THEN  
                        PUT STREAM str_1 SKIP(1).
    
                    IF  LINE-COUNTER(str_1) > PAGE-SIZE(str_1)  THEN
                        DO:
                            PAGE STREAM str_1.
    
                            PUT STREAM str_1 "*** " AT 40 
                                             "CHEQUES SEM INDICACAO DE TITULAR"  
                                             " ***"
                                             SKIP(1).
    
                            PUT STREAM str_1 SKIP
                                             "PA: " w_criticas.cdagenci " - " 
                                             crapage.nmresage FORMAT "x(15)"
                                             SKIP(1).
                        END.
    
                END. /*** Fim do FOR EACH w_criticas ***/

                OUTPUT STREAM str_1 CLOSE.

                ASSIGN glb_nmformul = "132col"
                       glb_nmarqimp = aux_nmarqrel
                       glb_nrcopias = 1.
                
                RUN fontes/imprim_unif.p (INPUT w_enviados.cdcooper).
                
                /*** Se nao estiver rodando no PROCESSO copia relatorio ***/
                IF  glb_inproces = 1  THEN
                    UNIX SILENT VALUE("cp " + aux_nmarqrel + " "
                         + aux_dscooper + "rlnsv/" +
                         SUBSTRING(aux_nmarqrel,R-INDEX(aux_nmarqrel,"/") + 1,
                         LENGTH(aux_nmarqrel) - R-INDEX(aux_nmarqrel,"/"))).
            END.
         
    END. /*** Fim do FOR EACH w_enviados ***/
    
END PROCEDURE.
                       
/*............................................................................*/
