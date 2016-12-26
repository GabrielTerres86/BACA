/* .............................................................................

   Programa: fontes/crps545.p
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Dezembro/2009.                     Ultima atualizacao: 26/12/2016
                                                                          
   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Integrar arquivo de transferencia de creditos do software
               Cabine financeira da empresa JD Consultores
               
   Observacoes: Do programa:
                - Executado no processo noturno. Cadeia EXCLUSIVA.
                  (Somente processo da Cecred);
                - Fara a leitura de um arquivo txt e ira extrair os dados para
                  uma tabela generica (gnmvspb);
                - Arquivo com extensao texto (.txt);
                  
                Do arquivo:
                - Possui um cabecalho, e um rodape e nas linhas intermediarias
                  contem uma transacao por linha
                - Separacao posicional de campos
                - Formatacao do nome do arquivo a ser importado:
                  ISPB_DataInicioPeriodo_DataFimPeriodo.txt
                - Diretorio onde ele eh disponibilizado: /micros/cecred/spb
                
   Alteracoes: 19/05/2010 - Incluido comando REPLACE na atribuicao do campo
                            crawint.vllanmto (Diego).
                            
               17/12/2010 - Tratamento para numero de conta maior que 9
                            digitos (Diego).
                            
               05/05/2011 - Incluido tratamento ref. codigo de agencia das
                            mensagens de devolucao (Diego).             
                
               19/09/2011 - Incluido novo campo criado na tabela gnmvspb 
                            (Henrique).
                            
               18/01/2012 - Tratar data no nome do arquivo (Diego).    
               
               04/04/2012 - Alteração do campo cdfinmsg para dsfinmsg.
                            (David Kruger).        
               
               22/06/2012 - Substituido gncoper por crapcop (Tiago).   
               
               17/10/2012 - Tratamento contas transferidas (Diego).
               
               22/01/2013 - Quando TEC salario utilizar campos da Conta Debito
                            do arquivo (Diego).
               
               19/07/2013 - Na verificação das STR´s, setar aux_cdagectl em 
                            função do código de barras, descobrindo a 
                            cooperativa pelo código do convenio (Carlos).
                            
               22/10/2013 - Retirada a var aux_flgregis, nao utilizada (Carlos)
               
               06/11/2013 - Melhoria na performance retirando o RUN da BO 46 de
                            dentro do FOR EACH da crawint (Carlos)
                            
               18/12/2014 - Tratamento contas incorporadas CONCREDI e CREDIMILSUL
                           (Diego).       
                           
               26/03/2015 - Correção de status do movimento e codigo da cooperativa 
                            para VRBOLETO(STR0026R2). (SD 269372 - Carlos Rafael Tanholi)
                            
               11/08/2015 - Comentado tratamento para contas incorporadas 
                            (Diego). 

               28/07/2015 - Corrigida atribuicao da variavel aux_nrcpfcre nas 
                            mensagens de TEC Salario (Diego).                        

               29/03/2016 - Ajustado tratamento para validacao das contas
                            migradas ACREDI >> VIACREDI 
                            (Douglas - Chamado 424491)

               23/05/2016 - Ajustado tratamento para validacao das contas
                            migradas VIACREDI >> VIACREDI ALTO VALE
                            (Douglas - Chamado 406267)

			   26/12/2016 - Tratamento incorporação Transposul (Diego).
			    	
............................................................................. */

{ includes/var_batch.i } 

{ sistema/generico/includes/b1wgen0046tt.i }
{ sistema/generico/includes/var_internet.i }

DEF STREAM str_1.

DEF TEMP-TABLE crawarq NO-UNDO
    FIELD nmarquiv AS CHAR.
    
DEF TEMP-TABLE crawint NO-UNDO
    FIELD nrseqreg AS INTE

    FIELD cdcooper AS INTE
    FIELD cdagenci AS INTE
    FIELD dtmvtolt AS DATE
    FIELD dsdgrupo AS CHAR
    FIELD dsorigem AS CHAR
    FIELD dsdebcre AS CHAR
    FIELD dsareneg AS CHAR
    FIELD dsmensag AS CHAR
    FIELD dtmensag AS DATE
    FIELD vllanmto AS DECI

    FIELD dsinstcr AS CHAR
    FIELD nrcnpjcr AS DECI
    FIELD nmcliecr AS CHAR
    FIELD dstpctcr AS CHAR
    FIELD cdagencr AS INTE
    FIELD dscntacr AS CHAR

    FIELD dsinstdb AS CHAR
    FIELD nrcnpjdb AS DECI
    FIELD nmcliedb AS CHAR
    FIELD dstpctdb AS CHAR
    FIELD cdagendb AS INTE
    FIELD dscntadb AS CHAR
    FIELD dsfinmsg AS CHAR.

DEF BUFFER b-crapcop FOR crapcop.
    
DEF VAR aux_nmarquiv AS CHAR   NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR   NO-UNDO.
DEF VAR aux_setlinha AS CHAR   NO-UNDO.
DEF VAR aux_nrseqreg AS INTE   NO-UNDO.
DEF VAR aux_flgcabec AS LOGI   NO-UNDO.

DEF VAR aux_codiispb AS CHAR   NO-UNDO.
DEF VAR aux_cdagectl AS INTE   NO-UNDO.
DEF VAR aux_cddbanco AS INTE   NO-UNDO.
DEF VAR aux_cdcooper AS INTE   NO-UNDO.
DEF VAR aux_nrdconta AS INTE   NO-UNDO.
DEF VAR aux_cdagenci AS INTE   NO-UNDO.
DEF VAR aux_cdagencr AS INTE   NO-UNDO.
DEF VAR aux_nrctacre AS DEC    NO-UNDO.
DEF VAR aux_nrcpfcre AS DEC    NO-UNDO.

DEF VAR h-b1wgen0046 AS HANDLE NO-UNDO.

ASSIGN glb_cdprogra = "crps545".

RUN fontes/iniprg.p.

IF  glb_cdcritic > 0  THEN
    RETURN.

ASSIGN aux_codiispb = "05463212_" + STRING(YEAR(glb_dtmvtolt),"9999") + 
                      STRING(MONTH(glb_dtmvtolt),"99") +
                      STRING(DAY(glb_dtmvtolt),"99").

INPUT STREAM str_1 THROUGH VALUE("ls /micros/cecred/spb/" + aux_codiispb 
                                 + "_*.txt 2> /dev/null") NO-ECHO.

DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

    IMPORT STREAM str_1 UNFORMATTED aux_nmarquiv.
                                          
    CREATE crawarq.
    ASSIGN crawarq.nmarquiv = aux_nmarquiv.
                      
END. /*** Fim do DO WHILE TRUE ***/

INPUT STREAM str_1 CLOSE.

IF  NOT AVAILABLE crawarq  THEN
    DO:
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS")  
                          + " - " + glb_cdprogra + "' --> '"
                          + "Arquivo nao encontrado." +
                          " >> log/proc_batch.log").
        RUN fontes/fimprg.p.
        RETURN.
    END.

ASSIGN aux_flgcabec = FALSE.

/* Instanciar BO e processar o registro */
RUN sistema/generico/procedures/b1wgen0046.p
    PERSISTENT SET h-b1wgen0046.

IF  NOT VALID-HANDLE(h-b1wgen0046)  THEN
    DO:
        glb_dscritic = "Handle invalido para h-b1wgen0046.".
        
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS")
                      + " - " + glb_cdprogra + "' --> '"
                      + glb_dscritic +
                      " >> log/proc_batch.log").
        
        LEAVE.
    END.

/* Processar cada arquivo */
FOR EACH crawarq NO-LOCK:

    INPUT STREAM str_1 FROM VALUE(crawarq.nmarquiv) NO-ECHO.

    IMPORT STREAM str_1 UNFORMATTED aux_setlinha.
    
    /*** HEADER -> 0005463212AAAAMMMDD */
    /* Criticar o tipo de arquivo */
    IF  SUBSTR(aux_setlinha,1,2) <> "00"  THEN
        DO:
            glb_cdcritic = 468.

            RUN fontes/critic.p.
            
            RUN proc_critica_header. 

            NEXT.
        END.
    
    /* Criticar o codigo ISPB */
    IF  SUBSTR(aux_setlinha,3,8) <> SUBSTR(aux_codiispb,1,8)  THEN
        DO:
            glb_dscritic = "Codigo ISPB invalido.".
            
            RUN proc_critica_header.

            NEXT.
        END.

    ASSIGN aux_nrseqreg = 0.
    
    EMPTY TEMP-TABLE crawint.
    
    DO WHILE TRUE ON ERROR UNDO, RETURN ON ENDKEY UNDO, LEAVE:

        ASSIGN aux_setlinha = ""
               aux_cdcooper = 0
               aux_cdagenci = 0
               aux_cdagencr = 0
               aux_nrctacre = 0
               aux_nrdconta = 0.
        
        IMPORT STREAM str_1 UNFORMATTED aux_setlinha.
        
        IF  SUBSTR(aux_setlinha,1,2) = "01"  THEN 
            DO:
                ASSIGN aux_nrseqreg = aux_nrseqreg + 1.

                INTEGER(SUBSTR(aux_setlinha,186,4)) NO-ERROR.

                IF  ERROR-STATUS:ERROR  THEN
                    DO:
                        glb_dscritic = SUBSTR(aux_setlinha,186,4) + 
                                       " Nao e uma agencia credito valida.".

                        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                          " - " + glb_cdprogra + "' --> '"  +
                                          glb_dscritic + " Arquivo: " + 
                                          crawarq.nmarquiv + " Registro: " +
                                          STRING(aux_nrseqreg) +
                                          " >> log/proc_batch.log").
                        NEXT.
                    END.

                INTEGER(SUBSTR(aux_setlinha,307,4)) NO-ERROR.

                IF  ERROR-STATUS:ERROR  THEN
                    DO:
                        glb_dscritic = SUBSTR(aux_setlinha,307,4) + 
                                       " Nao e uma agencia debito valida.".

                        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                          " - " + glb_cdprogra + "' --> '"  +
                                          glb_dscritic + " Arquivo: " + 
                                          crawarq.nmarquiv + " Registro: " +
                                          STRING(aux_nrseqreg) +
                                          " >> log/proc_batch.log").
                        
                        NEXT.
                    END.

                IF  TRIM(SUBSTR(aux_setlinha,71,11)) = "STR0010R2" OR
                    TRIM(SUBSTR(aux_setlinha,71,11)) = "PAG0111R2" OR
                    TRIM(SUBSTR(aux_setlinha,71,11)) = "STR0010"   OR
                    TRIM(SUBSTR(aux_setlinha,71,11)) = "PAG0111"   THEN
                    /* Codigo da Agencia(debito ou credito) nas mensagens de devolucao */
                    ASSIGN aux_cdagectl = INT(SUBSTR(aux_setlinha,21,4)).
                ELSE
                IF  TRIM(SUBSTR(aux_setlinha,71,11)) = "STR0026R2" THEN
                    DO:
                        /* Setar aux_cdagectl em função do código de barras que deverá vir no arquivo(370/6). 
                        Pelo código de barras, descobrir a cooperativa pelo código do convenio */

                        FIND crapcco WHERE crapcco.nrconven = INT(SUBSTR(aux_setlinha,370,6))
                                       AND NOT CAN-DO("INCORPORACAO,MIGRACAO",crapcco.dsorgarq)
                                   NO-LOCK NO-ERROR.

                        IF NOT AVAIL crapcco THEN
                            DO:
                                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " + glb_cdprogra + "' --> '"  +
                                                  "Convenio nao encontrado: " + SUBSTR(aux_setlinha,370,6) + " Arquivo: " + 
                                                  crawarq.nmarquiv + " Registro: " + STRING(aux_nrseqreg) + " >> log/proc_batch.log").
                                NEXT.
                            END.
                        
                        /* encontrar agencia da cooperativa */
                        FIND crapcop WHERE crapcop.cdcooper = crapcco.cdcooper NO-LOCK NO-ERROR.
                        ASSIGN aux_cdagectl = crapcop.cdagectl.

                     END.
                ELSE
                IF  SUBSTR(aux_setlinha,20,1) = "D"  THEN
                    DO:
                        ASSIGN aux_cddbanco = INT(SUBSTR(aux_setlinha,203,8))
                               aux_cdagectl = INT(SUBSTR(aux_setlinha,307,4)).

                        /* Numero de conta invalido */
                        IF  LENGTH(
                            STRING(DEC(SUBSTR(aux_setlinha,311,13)))) > 9 THEN
                            aux_nrdconta = 0.
                        ELSE
                            aux_nrdconta = INT(SUBSTR(aux_setlinha,311,13)).
                    END.
                ELSE
                IF  SUBSTR(aux_setlinha,20,1) = "C"  THEN 
                    DO:
                        ASSIGN aux_cddbanco = INT(SUBSTR(aux_setlinha,82,8))
                               aux_cdagectl = INT(SUBSTR(aux_setlinha,186,4))
                               /* utilizadas na validacao conta transferida */
                               aux_cdagencr = INT(SUBSTR(aux_setlinha,186,4))
                               aux_nrctacre = DECI(SUBSTR(aux_setlinha,190,13))
                               aux_nrcpfcre = IF TRIM(SUBSTR(aux_setlinha,71,11)) = "STR0037R2" OR
                                                 TRIM(SUBSTR(aux_setlinha,71,11)) = "PAG0137R2" THEN
                                                 DECI(SUBSTR(aux_setlinha,211,14))
                                              ELSE DECI(SUBSTR(aux_setlinha,90,14)).

                        /* Numero de conta invalido */
                        IF  LENGTH(
                            STRING(DEC(SUBSTR(aux_setlinha,190,13)))) > 9 THEN
                            ASSIGN aux_nrdconta = 0.
                        ELSE
                            aux_nrdconta = INT(SUBSTR(aux_setlinha,190,13)).
                    END.
                ELSE
                    ASSIGN aux_cddbanco = 0
                           aux_nrdconta = 0.

                FIND crapcop WHERE 
                     crapcop.cdagectl = aux_cdagectl NO-LOCK NO-ERROR.

                IF  AVAIL crapcop  THEN
                    DO:
                        ASSIGN aux_cdcooper = crapcop.cdcooper.
                        FIND crapass WHERE 
                             crapass.cdcooper = crapcop.cdcooper AND
                             crapass.nrdconta = aux_nrdconta NO-LOCK NO-ERROR.

                        IF  AVAIL crapass  THEN
                            DO:
                                ASSIGN aux_cdagenci = crapass.cdagenci.
                            END.
                        ELSE
                            ASSIGN aux_cdagenci = 0.

                        IF  SUBSTR(aux_setlinha,20,1) = "C"  THEN
						    RUN verifica_conta_transferida.
                    END.

                           
                CREATE crawint.
                ASSIGN crawint.nrseqreg = aux_nrseqreg
                       crawint.dtmvtolt = glb_dtmvtolt
                       crawint.cdcooper = aux_cdcooper
                       crawint.cdagenci = aux_cdagenci
                       crawint.dsdgrupo = SUBSTR(aux_setlinha,3,3)
                       crawint.dsorigem = SUBSTR(aux_setlinha,6,6)
                       crawint.dtmensag = DATE(INTE(SUBSTR(aux_setlinha,16,2)),
                                               INTE(SUBSTR(aux_setlinha,18,2)),
                                               INTE(SUBSTR(aux_setlinha,12,4)))
                       crawint.dsdebcre = SUBSTR(aux_setlinha,20,1) 
                       crawint.dsareneg = SUBSTR(aux_setlinha,21,50)
                       crawint.dsmensag = TRIM(SUBSTR(aux_setlinha,71,11))
                       
                       crawint.dsinstcr = SUBSTR(aux_setlinha,82,8)
                       /* No XML da TEC salario vem somente dados da conta
                         debito */ 
                       crawint.nrcnpjcr = IF crawint.dsmensag = "STR0037R2" OR
                                             crawint.dsmensag = "PAG0137R2" THEN
                                             DECI(SUBSTR(aux_setlinha,211,14))
                                          ELSE DECI(SUBSTR(aux_setlinha,90,14))
                       crawint.nmcliecr = IF crawint.dsmensag = "STR0037R2" OR
                                             crawint.dsmensag = "PAG0137R2" THEN
                                             SUBSTR(aux_setlinha,225,80)
                                          ELSE SUBSTR(aux_setlinha,104,80)
                       crawint.dstpctcr = SUBSTR(aux_setlinha,184,2)
                       crawint.cdagencr = IF crawint.dsmensag = "STR0010R2" OR
                                             crawint.dsmensag = "PAG0111R2" THEN
                                             INT(SUBSTR(aux_setlinha,21,4))
                                          ELSE aux_cdagencr
                       crawint.dscntacr = STRING(aux_nrctacre)
                       crawint.dsinstdb = SUBSTR(aux_setlinha,203,8)
                       crawint.nrcnpjdb = DECI(SUBSTR(aux_setlinha,211,14))
                       crawint.nmcliedb = SUBSTR(aux_setlinha,225,80)
                       crawint.dstpctdb = SUBSTR(aux_setlinha,305,2)
                       crawint.cdagendb = IF crawint.dsmensag = "STR0010" OR
                                             crawint.dsmensag = "PAG0111" THEN
                                             INT(SUBSTR(aux_setlinha,21,4))
                                          ELSE INT(SUBSTR(aux_setlinha,307,4))
                       crawint.dscntadb = SUBSTR(aux_setlinha,311,13)
                       crawint.vllanmto = DECI(REPLACE(SUBSTR(aux_setlinha,
                                                       324,22),".",","))
                       crawint.dsfinmsg = TRIM(SUBSTR(aux_setlinha,346,5)).
            END. 
          
    END. /*** Fim do DO WHILE TRUE ***/
    
    INPUT STREAM str_1 CLOSE.


    IF  glb_dsrestar <> "" AND crawarq.nmarquiv = SUBSTR(glb_dsrestar,8)  THEN
        ASSIGN aux_nrseqreg = INTE(SUBSTR(glb_dsrestar,1,6)).
    ELSE
        ASSIGN aux_nrseqreg = 0.
    
    TRANS_1:
    FOR EACH crawint WHERE crawint.nrseqreg > aux_nrseqreg 
                           NO-LOCK BY crawint.nrseqreg 
                           TRANSACTION ON ERROR UNDO, LEAVE:

        RUN cria_gnmvspb IN h-b1wgen0046 (INPUT glb_cdcooper,
                                          INPUT 0, /* cdagenci */
                                          INPUT 0, /* nrdcaixa */
                                          
                                          INPUT crawint.cdcooper,
                                          INPUT crawint.cdagenci,
                                          INPUT crawint.dtmvtolt,
                                          INPUT crawint.dsdgrupo,
                                          INPUT crawint.dsorigem,
                                          INPUT crawint.dsdebcre,
                                          INPUT crawint.dsareneg,
                                          INPUT crawint.dsmensag,
                                          INPUT crawint.dtmensag,
                                          INPUT crawint.vllanmto,
                                          
                                          INPUT crawint.dsinstcr,
                                          INPUT crawint.nrcnpjcr,
                                          INPUT crawint.nmcliecr,
                                          INPUT crawint.dstpctcr,
                                          INPUT crawint.cdagencr,
                                          INPUT crawint.dscntacr,

                                          INPUT crawint.dsinstdb,
                                          INPUT crawint.nrcnpjdb,
                                          INPUT crawint.nmcliedb,
                                          INPUT crawint.dstpctdb,
                                          INPUT crawint.cdagendb,
                                          INPUT crawint.dscntadb,
                                          INPUT crawint.dsfinmsg,
                                          OUTPUT TABLE tt-erro).

        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                FIND tt-erro NO-LOCK NO-ERROR.

                IF  AVAIL tt-erro  THEN
                    glb_dscritic = tt-erro.dscritic + " Arquivo: " + 
                                   crawarq.nmarquiv + " Registro: " + 
                                   STRING(crawint.nrseqreg).
                ELSE
                    glb_dscritic = "Nao foi possivel criar o registro na " +
                                   "gnmvspb. Arquivo: " + crawarq.nmarquiv +
                                   " Registro: " + STRING(crawint.nrseqreg).
    
                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS")
                              + " - " + glb_cdprogra + "' --> '"
                              + glb_dscritic +
                              " >> log/proc_batch.log").
    
                UNDO TRANS_1, LEAVE.
            END.

        DO WHILE TRUE:

            FIND crapres WHERE crapres.cdcooper = glb_cdcooper AND
                               crapres.cdprogra = glb_cdprogra
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crapres  THEN
                DO:
                    IF  LOCKED crapres  THEN
                        DO:
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        DO:
                            glb_cdcritic = 151.
                            RUN fontes/critic.p.
                        
                            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS")
                                              + " - " + glb_cdprogra + "' --> '"
                                              + glb_dscritic +
                                              " >> log/proc_batch.log").
                        
                            UNDO TRANS_1, LEAVE.
                        END.
                END.
            
            LEAVE.
    
        END. /*** Fim do DO WHILE TRUE ***/

        ASSIGN crapres.dsrestar = STRING(crawint.nrseqreg,"999999") + " " +
                                  crawarq.nmarquiv
               glb_dscritic     = "".

    END. /*** Fim do FOR EACH crawint ***/

    
    UNIX SILENT VALUE("mv " + crawarq.nmarquiv + " salvar").
    
END. /*** Fim do FOR EACH crawarq ***/


IF  VALID-HANDLE(h-b1wgen0046) THEN
    DELETE OBJECT h-b1wgen0046.

RUN fontes/fimprg.p.

/*................................ PROCEDURES ................................*/

PROCEDURE proc_critica_header:

    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - " + glb_cdprogra + "' --> '"  +
                      glb_dscritic + " Arquivo: " + crawarq.nmarquiv +
                      " >> log/proc_batch.log").
    
    UNIX SILENT VALUE("mv " + crawarq.nmarquiv + " salvar").

END PROCEDURE.


PROCEDURE verifica_conta_transferida.

   DEF VAR aux_ctavalid AS LOGICAL NO-UNDO.

   ASSIGN aux_ctavalid = TRUE.

   /* Necessario verificar se conta e cpf/cnpj sao validos, pois se nao forem
      eh porque a mensagem foi devolvida na cooperativa que recebeu a mesma, 
      e nao processou na conta transferida */ 

   FIND crapass WHERE crapass.cdcooper = aux_cdcooper   AND
                      crapass.nrdconta = aux_nrdconta   AND
                      crapass.nrcpfcgc = aux_nrcpfcre NO-LOCK NO-ERROR.
   
   IF   NOT AVAIL crapass  THEN
        DO:
            /* Verifica se eh um dos titulares */ 
            FIND FIRST crapttl WHERE crapttl.cdcooper = aux_cdcooper   AND
                                     crapttl.nrdconta = aux_nrdconta   AND
                                     crapttl.nrcpfcgc = aux_nrcpfcre
                                     NO-LOCK NO-ERROR.
         
            IF   NOT AVAIL crapttl  THEN
                 ASSIGN aux_ctavalid = FALSE.
        END.

   IF   aux_ctavalid = TRUE /*** OR Tratamento incorporadas
        aux_cdcooper = 4 OR aux_cdcooper = 15 ***/  OR
		aux_cdcooper = 9 OR aux_cdcooper = 17 THEN
        DO:
            /* De-Para das incorporadas foi desativado em 25/08/2015.
               Os registros continuarao sendo criados na gnmvspb para
               coop. antiga, mas nao serao tratados na centralizacao */
            IF  aux_cdcooper = 4 OR aux_cdcooper = 15  THEN 
                .
            ELSE
                DO:
				   
				   /* Verifica se eh conta transferida */ 
                   FIND craptco WHERE craptco.cdcopant = aux_cdcooper AND
                                      craptco.nrctaant = aux_nrdconta AND
                                      craptco.flgativo = TRUE         AND
                                      craptco.tpctatrf = 1
                                      NO-LOCK NO-ERROR.
             
                   IF  NOT AVAIL craptco  THEN
				       /* Verifica se eh conta transferida. 
					      Mensagem recebida para Agencia Nova e conta Antiga */ 
                       FIND craptco WHERE craptco.cdcooper = aux_cdcooper AND
                                          craptco.nrctaant = aux_nrdconta AND
                                          craptco.flgativo = TRUE         AND
                                          craptco.tpctatrf = 1
                                          NO-LOCK NO-ERROR. 
				   
				   IF  AVAIL craptco THEN
                       DO:
                           /* Verificar se a conta migrada ACREDI >> VIACREDI */
                           IF  craptco.cdcooper = 1 AND craptco.cdcopant = 2 THEN 
                               .
                           /* Verificar se a conta migrada VIACREDI >> ALTO VALE*/
                           ELSE IF craptco.cdcooper = 16 AND craptco.cdcopant = 1 THEN 
                               .
                           ELSE
                               DO:
                                   FIND b-crapcop WHERE 
                                        b-crapcop.cdcooper = craptco.cdcooper
                                   NO-LOCK NO-ERROR.
                                   
                                   ASSIGN aux_cdcooper = craptco.cdcooper
                                          aux_cdagenci = craptco.cdagenci
                                          aux_nrctacre = DEC(craptco.nrdconta)
                                          aux_cdagencr = b-crapcop.cdagectl.
                               END.
                       END.
                END.        
        END.

END PROCEDURE.
