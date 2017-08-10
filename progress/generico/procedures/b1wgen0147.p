/*.............................................................................
    
   Programa: b1wgen0147.p                  
   Autor(a): Lucas R.
   Data    : 02/05/2013                         Ultima atualizacao: 12/06/2017

   Dados referentes ao programa:

   Objetivo  : BO DE PROCEDURES REF. OPERACOES COM O BNDES

   Alteracoes: 28/02/2014 - Incluso VALIDATE (Daniel).
   
               27/08/2014 - Alterado nome do servidor 0302bndesora01 para
                            0302devora01 (Diego).
                            
               28/04/2015 - Alterado nome do servidor dbprdora para dbprdbndes
                            (Diego).             
                            
               13/05/2015 - Incluido "2> /dev/null" no comando "mv" (Diego).  
               
               12/05/2016 - Atualizar somente operacoes com situacao "N,A,P,L"
                           (Diego).            

			   12/06/2017  - Ajuste devido ao aumento do formato para os campos crapass.nrdocptl, crapttl.nrdocttl, 
			                 crapcje.nrdoccje, crapcrl.nridenti e crapavt.nrdocava
							 (Adriano - P339).		            

.............................................................................*/

{ sistema/generico/includes/b1wgen0147tt.i }
{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/gera_erro.i }

DEF STREAM str_1.
DEF STREAM str_2.

DEF VAR aux_setlinha AS CHAR NO-UNDO.
DEF VAR aux_cdcooper AS INTE NO-UNDO.
DEF VAR aux_cdcritic AS INTE NO-UNDO.
DEF VAR aux_dscritic AS CHAR NO-UNDO.

PROCEDURE busca_dados:
    
    DEF INPUT PARAM par_cdcooper AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cddopcao AS CHAR                               NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-infoass.
    
    EMPTY TEMP-TABLE tt-infoass.

    FOR FIRST crapass FIELDS(cdcooper nrdconta nmprimtl nrcpfcgc inpessoa)
                      WHERE crapass.cdcooper = par_cdcooper AND
                            crapass.nrdconta = par_nrdconta NO-LOCK:

    END.
    
    IF  NOT AVAILABLE crapass THEN
        RETURN "NOK".
        

    CREATE tt-infoass.
    ASSIGN tt-infoass.cdcooper = crapass.cdcooper
           tt-infoass.nrdconta = crapass.nrdconta
           tt-infoass.nmprimtl = crapass.nmprimtl
           tt-infoass.cddopcao = par_cddopcao.
           
    IF  crapass.inpessoa = 1  THEN
        DO:
            ASSIGN tt-infoass.nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999")
                   tt-infoass.nrcpfcgc = STRING(tt-infoass.nrcpfcgc,
                                                "    xxx.xxx.xxx-xx").
        END.
    ELSE
        DO:
             ASSIGN tt-infoass.nrcpfcgc = STRING(crapass.nrcpfcgc,
                                                 "99999999999999")
                    tt-infoass.nrcpfcgc = STRING(tt-infoass.nrcpfcgc,
                                             "xx.xxx.xxx/xxxx-xx").
    
        END.

    RETURN "OK".
END.


PROCEDURE cria_dados_totvs:
    
   DEF INPUT PARAM par_cdcooper AS INTE                               NO-UNDO.
   DEF INPUT PARAM par_cdagenci AS INTE                               NO-UNDO.
   DEF INPUT PARAM par_cdoperad AS CHAR                               NO-UNDO.
   DEF INPUT PARAM par_nmdatela AS CHAR                               NO-UNDO.
   DEF INPUT PARAM par_nrdconta AS INTE                               NO-UNDO.
   DEF INPUT PARAM par_cddopcao AS CHAR                               NO-UNDO.
   DEF OUTPUT PARAM TABLE FOR tt-erro.

   DEF VAR aux_tpdocttl AS CHAR                                        NO-UNDO.
   DEF VAR aux_dssexttl AS CHAR                                        NO-UNDO.
   DEF VAR aux_dsestcvl AS CHAR                                        NO-UNDO.
   DEF VAR aux_cderroop AS INTE                                        NO-UNDO.
   DEF VAR aux_dserroop AS CHAR                                        NO-UNDO.
   DEF VAR aux_coopagen AS CHAR                                        NO-UNDO.

   DEF VAR aux_nmarquiv AS CHAR                                        NO-UNDO.
   DEF VAR aux_textoxml AS CHAR EXTENT 30                              NO-UNDO.
   DEF VAR aux_contador AS INTE                                        NO-UNDO.
   DEF VAR aux_nrcpfcgc AS CHAR                                        NO-UNDO.
   DEF VAR aux_nmservid AS CHAR                                        NO-UNDO.

   DEF BUFFER crabcop FOR crapcop.

   FIND crapcop WHERE crapcop.cdcooper = 3 NO-LOCK NO-ERROR.

   FIND crabcop WHERE crabcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

   FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper AND
                            crapass.nrdconta = par_nrdconta
                            NO-LOCK NO-ERROR NO-WAIT.

   /* Verifica nome do servidor para copiar XML */ 
   IF   TRIM(OS-GETENV("PKGNAME")) = "pkgprod" THEN
        ASSIGN aux_nmservid = "dbprdbndes.cecred.coop.br".
   ELSE
   IF   TRIM(OS-GETENV("PKGNAME")) = "pkgdesen" OR
        TRIM(OS-GETENV("PKGNAME")) = "pkghomol" THEN
        ASSIGN aux_nmservid = "0302devora01".

   ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + "/arq/" + 
                         "msg_" + crapcop.dsdircop + "_" + 
                         STRING(crapass.nrdconta) + ".xml".

   ASSIGN aux_coopagen = STRING(crapass.cdcooper) +
                         TRIM(STRING(crapass.cdagenci,"z99")).

   /* pessoa fisica */
   IF  crapass.inpessoa = 1  THEN 
       DO:
           /* Buscar informacoes para procedure */
           FIND FIRST crapttl WHERE crapttl.cdcooper = crapass.cdcooper AND 
                                    crapttl.nrdconta = crapass.nrdconta AND
                                    crapttl.idseqttl = 1
                                    NO-LOCK NO-ERROR.
           
           IF   AVAIL crapttl  THEN 
                DO:
                    /* Tipo doc. */
                    IF    crapttl.tpdocttl = "CH" THEN
                          ASSIGN aux_tpdocttl = "CNH".
                    ELSE
                    IF    crapttl.tpdocttl = "CI"   THEN
                          ASSIGN aux_tpdocttl = "RG".                       
                    ELSE
                    IF   (crapttl.tpdocttl = "CP" OR 
                          crapttl.tpdocttl = "CT") THEN
                          ASSIGN aux_tpdocttl = "CIP".
                    
                    /* Sexo */
                    IF   crapttl.cdsexotl = 1 THEN
                         ASSIGN aux_dssexttl = "M".
                    ELSE
                    IF   crapttl.cdsexotl = 2 THEN
                         ASSIGN aux_dssexttl = "F".
                    
                    /* Estado Civil */
                    IF   crapttl.cdestcvl =  1 THEN
                         ASSIGN aux_dsestcvl = "SO". /*Solteiro*/
                    ELSE
                    IF   crapttl.cdestcvl = 2  THEN
                         ASSIGN aux_dsestcvl = "CT".  /*comunhco total*/
                    ELSE
                    IF   crapttl.cdestcvl = 3  THEN
                         ASSIGN aux_dsestcvl = "CP".  /*comunhco parcial*/
                    ELSE
                    IF   crapttl.cdestcvl =   4 THEN
                         ASSIGN aux_dsestcvl = "ST". /*Separagco total*/
                    ELSE
                    IF   crapttl.cdestcvl = 5  THEN
                         ASSIGN aux_dsestcvl = "VI". /*Viuvo*/
                    ELSE
                    IF   crapttl.cdestcvl = 6  THEN
                         ASSIGN aux_dsestcvl = "SE". /*Separado*/
                    ELSE
                    IF   crapttl.cdestcvl = 7  THEN
                         ASSIGN aux_dsestcvl = "DI". /*Divorciado*/
                    ELSE
                    IF   crapttl.cdestcvl = 8 THEN
                         ASSIGN aux_dsestcvl = "CT".  /*comunhco total*/
                    ELSE
                    IF   crapttl.cdestcvl =   9 THEN
                         ASSIGN aux_dsestcvl = "CP". /*comunhco parcial*/
                    ELSE
                    IF   crapttl.cdestcvl = 11 THEN
                         ASSIGN aux_dsestcvl = "CP". /*comunhco parciaL*/
                    ELSE
                    IF   crapttl.cdestcvl = 12 THEN
                         ASSIGN aux_dsestcvl = "UE". /*Unico estavel*/
                
                    ASSIGN aux_textoxml[1] = '<?xml version="1.0" encoding="ISO-8859-1"?>'
                           aux_textoxml[2] = "<CADASTRO_CONTA>"
                           aux_textoxml[3] = "<SP_CLIENTE>"
                           aux_textoxml[4] = "<CDAGENCI>" + aux_coopagen + 
                                             "</CDAGENCI>"
                           aux_textoxml[5] = "<NRCPFCGC>" + STRING(crapass.nrcpfcgc,
                                                            "99999999999") + 
                                             "</NRCPFCGC>"
                           aux_textoxml[6] = "<NRDCONTA>" + STRING(par_nrdconta) +
                                             "</NRDCONTA>"
                           aux_textoxml[7] = "<CDDOPCAO>" + par_cddopcao + 
                                             "</CDDOPCAO>"
                           aux_textoxml[8] = "<NMPRIMTL>" + "<![CDATA[" +
                                             crapttl.nmextttl + "]]>" +
                                             "</NMPRIMTL>"
                           aux_textoxml[9] = "<DTNASTTL>" + STRING(crapttl.dtnasttl) 
                                           + "</DTNASTTL>"
                           aux_textoxml[10] = "<TPDOCTTL>" + aux_tpdocttl + 
                                             "</TPDOCTTL>"
                           aux_textoxml[11] = "<CDEODTTL>" + crapttl.cdoedttl + 
                                             "</CDEODTTL>"
                           aux_textoxml[12] = "<DTEMDTTL>" + STRING(crapttl.dtemdttl) 
                                            + "</DTEMDTTL>"
                           aux_textoxml[13] = "<NRDOCTTL>" + SUBSTR(TRIM(crapttl.nrdocttl),1,15) + 
                                              "</NRDOCTTL>"
                           aux_textoxml[14] = "<DSEXTTTL>" + aux_dssexttl + 
                                              "</DSEXTTTL>"
                           aux_textoxml[15] = "<DSESTCVL>" + aux_dsestcvl + 
                                              "</DSESTCVL>" 
                           aux_textoxml[16] = "<DTADMISS>" + STRING(crapass.dtadmiss) 
                                                           + "</DTADMISS>"
                           aux_textoxml[17] = "<NRDGRUPO>" + "0" + "</NRDGRUPO>"
                           aux_textoxml[18] = "<CDRMATIV>" + "3999" + 
                                              "</CDRMATIV>"
                           aux_textoxml[19] = "<ISENDIOF>" + "S" + "</ISENDIOF>"
                           aux_textoxml[20] = "<ISENDIRF>" + "S" + "</ISENDIRF>"
                           aux_textoxml[21] = "<DSESPECI>" + "N" + "</DSESPECI>"
                           aux_textoxml[22] = "<CDOPERAD>" + par_cdoperad + 
                                              "</CDOPERAD>"
                           aux_textoxml[23] = "<CDCOOPER>" + crabcop.dsdircop + 
                                              "</CDCOOPER>"
                           aux_textoxml[24] = "</SP_CLIENTE>"
                           aux_textoxml[25] = "</CADASTRO_CONTA>".
                    
                    OUTPUT STREAM str_2 TO VALUE (aux_nmarquiv).

                    DO  aux_contador = 1 TO 26:
                   
                        PUT STREAM str_2 UNFORMATTED aux_textoxml[aux_contador] SKIP. 
                    END.

                END.
           ELSE 
                DO: 
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Registro nao encontrado".
                   
                    RETURN "NOK".
                END.
                
           /******** Desativado
           FIND FIRST crapenc WHERE crapenc.cdcooper = crapass.cdcooper AND
                                    crapenc.nrdconta = crapass.nrdconta AND
                                    crapenc.tpendass = 10 /*residencial*/
                                    NO-LOCK NO-ERROR.
    
           ASSIGN aux_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999").
          
           IF  AVAIL crapenc THEN
               ASSIGN aux_textoxml[1] = "<SP_CLIENTE_ENDERECO>"
                      aux_textoxml[2] = "<CDAGENCI>" + aux_coopagen + "</CDAGENCI>" 
                      aux_textoxml[3] = "<NRCPFCGC>" + aux_nrcpfcgc + "</NRCPFCGC>"
                      aux_textoxml[4] = "<TPENDERE>" + "Residencial" + "</TPENDERE>"
                      aux_textoxml[5] = "<CDDOPCAO>" + par_cddopcao + "</CDDOPCAO>"
                      aux_textoxml[6] = "<ENDERECO>" + crapenc.dsendere + "</ENDERECO>"
                      aux_textoxml[7] = "<NRENDERE>" + STRING(crapenc.nrendere) 
                                                     + "</NRENDERE>"
                      aux_textoxml[8] = "<COMPLEND>" + crapenc.complend + "</COMPLEND>"
                      aux_textoxml[9] = "<NMBAIRRO>" + crapenc.nmbairro + "</NMBAIRRO>"
                      aux_textoxml[10] = "<NRCEPEND>" + STRING(crapenc.nrcepend) 
                                                      + "</NRCEPEND>"
                      aux_textoxml[11] = "<NMCIDADE>" + crapenc.nmcidade + "</NMCIDADE>"
                      aux_textoxml[12] = "<CDUFENDE>" + crapenc.cdufende + "</CDUFENDE>"
                      aux_textoxml[13] = "<CDOPERAD>" + par_cdoperad + "</CDOPERAD>"
                      aux_textoxml[14] = "</SP_CLIENTE_ENDERECO>"
                      aux_textoxml[15] = "</CADASTRO_CONTA>".
           ELSE           
               DO: 
                   
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Endereco nao encontrado".
             
                   RETURN "NOK".
               END.
                 
               DO  aux_contador = 1 TO 15:
             
                  PUT STREAM str_2 UNFORMATTED aux_textoxml[aux_contador] SKIP.
               END. 
           ********/
           
           OUTPUT STREAM str_2 CLOSE.
       END.
   ELSE
       DO: /*pessoa juridica*/
            FIND FIRST crapjur WHERE crapjur.cdcooper = crapass.cdcooper  AND
                                     crapjur.nrdconta = crapass.nrdconta
                                     NO-LOCK NO-ERROR.
            
             IF  AVAIL crapjur  THEN
                 DO:
               
                 ASSIGN aux_textoxml[1] = '<?xml version="1.0" encoding="ISO-8859-1"?>'
                        aux_textoxml[2] = "<CADASTRO_CONTA>"
                        aux_textoxml[3] = "<SP_CLIENTE>"
                        aux_textoxml[4] = "<CDAGENCI>" + aux_coopagen + 
                                          "</CDAGENCI>"
                        aux_textoxml[5] = "<NRCPFCGC>" + STRING(crapass.nrcpfcgc,
                                                         "99999999999999") + 
                                          "</NRCPFCGC>"
                        aux_textoxml[6] = "<NRDCONTA>" + STRING(crapass.nrdconta) +
                                          "</NRDCONTA>"
                        aux_textoxml[7] = "<CDDOPCAO>" + par_cddopcao + 
                                          "</CDDOPCAO>"
                        aux_textoxml[8] = "<NMPRIMTL>" + "<![CDATA[" + 
                                          crapass.nmprimtl + "]]>" +
                                          "</NMPRIMTL>"
                        aux_textoxml[9] = "<NMFANSIA>" + "<![CDATA[" +
                                          crapjur.nmfansia + "]]>" +
                                          "</NMFANSIA>"
                        aux_textoxml[10] = "<V_CD_PRT>" + "0" + "</V_CD_PRT>"
                        aux_textoxml[11] = "<DTADMISS>" + STRING(crapass.dtadmiss) 
                                                       + "</DTADMISS>"
                        aux_textoxml[12] = "<CDRMATIV>" + "3399" +
                                           "</CDRMATIV>"
                        aux_textoxml[13] = "<NRDGRUPO>" + "0" + "</NRDGRUPO>"
                        aux_textoxml[14] = "<ISENDIOF>" + "S" + "</ISENDIOF>"
                        aux_textoxml[15] = "<ISENDIRF>" + "S" + "</ISENDIRF>"
                        aux_textoxml[16] = "<V_FT_ANL>" + "0" + "</V_FT_ANL>"
                        aux_textoxml[17] = "<DSESPECI>" + "N" + "</DSESPECI>"
                        aux_textoxml[18] = "<CDOPERAD>" + par_cdoperad + "</CDOPERAD>"
                        aux_textoxml[19] = "<CDCOOPER>" + crabcop.dsdircop + 
                                              "</CDCOOPER>"
                        aux_textoxml[20] = "</SP_CLIENTE>"
                        aux_textoxml[21] = "</CADASTRO_CONTA>".

                        OUTPUT STREAM str_2 TO VALUE (aux_nmarquiv).       

                        DO  aux_contador = 1 TO 22:

                            PUT STREAM str_2 UNFORMATTED aux_textoxml[aux_contador] SKIP.
                        END.
                 END.
             ELSE           
                 DO: 
                     CREATE tt-erro.
                     ASSIGN tt-erro.dscritic = "Registro nao encontrado".
                 
                     RETURN "NOK".
                 END.

           
           /******* Desativado
           FIND FIRST crapenc WHERE crapenc.cdcooper = crapass.cdcooper AND
                                    crapenc.nrdconta = crapass.nrdconta AND
                                    crapenc.tpendass = 09 /*comercial*/
                                    NO-LOCK NO-ERROR.
    
           ASSIGN aux_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999999").
          
           IF  AVAIL crapenc THEN
               ASSIGN aux_textoxml[1] = "<SP_CLIENTE_ENDERECO>"
                      aux_textoxml[2] = "<CDAGENCI>" + aux_coopagen + "</CDAGENCI>" 
                      aux_textoxml[3] = "<NRCPFCGC>" + aux_nrcpfcgc + "</NRCPFCGC>"
                      aux_textoxml[4] = "<TPENDERE>" + "Comercial" + "</TPENDERE>"
                      aux_textoxml[5] = "<CDDOPCAO>" + par_cddopcao + "</CDDOPCAO>"
                      aux_textoxml[6] = "<ENDERECO>" + crapenc.dsendere + "</ENDERECO>"
                      aux_textoxml[7] = "<NRENDERE>" + STRING(crapenc.nrendere) 
                                                     + "</NRENDERE>"
                      aux_textoxml[8] = "<COMPLEND>" + crapenc.complend + "</COMPLEND>"
                      aux_textoxml[9] = "<NMBAIRRO>" + crapenc.nmbairro + "</NMBAIRRO>"
                      aux_textoxml[10] = "<NRCEPEND>" + STRING(crapenc.nrcepend) 
                                                      + "</NRCEPEND>"
                      aux_textoxml[11] = "<NMCIDADE>" + crapenc.nmcidade + "</NMCIDADE>"
                      aux_textoxml[12] = "<CDUFENDE>" + crapenc.cdufende + "</CDUFENDE>"
                      aux_textoxml[13] = "<CDOPERAD>" + par_cdoperad + "</CDOPERAD>"
                      aux_textoxml[14] = "</SP_CLIENTE_ENDERECO>"
                      aux_textoxml[15] = "</CADASTRO_CONTA>".
           ELSE           
               DO: 
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Endereco nao encontrado".
             
                   RETURN "NOK".
               END.
                 
               DO  aux_contador = 1 TO 15:
             
                  PUT STREAM str_2 UNFORMATTED aux_textoxml[aux_contador] SKIP.
               END. 
           **********/
           
           OUTPUT STREAM str_2 CLOSE.
               
       END. /*fim do juridica*/
           

     UNIX SILENT VALUE ('sudo /usr/bin/su - scpuser -c ' +
                       '"scp ' + aux_nmarquiv + ' scpuser@' + aux_nmservid +
                       ':/usr/local/cecred/bndes/xml/" 2>/dev/null').

     UNIX SILENT VALUE ("rm " + aux_nmarquiv + " 2> /dev/null" ).
      
     RETURN "OK".
    
END.                                          
  
PROCEDURE dados_bndes:
    
    DEF INPUT PARAM par_cdcooper AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                               NO-UNDO.
    
    DEF OUTPUT PARAM par_vlparepr AS DEC                               NO-UNDO.
    DEF OUTPUT PARAM par_vlsaldod AS DEC                               NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-saldo-devedor-bndes.

    EMPTY TEMP-TABLE tt-saldo-devedor-bndes.

    DEF VAR aux_perparce AS CHAR                                       NO-UNDO.
    DEF VAR aux_percaren AS CHAR                                       NO-UNDO.

    FOR EACH crapebn WHERE crapebn.cdcooper = par_cdcooper AND
                           crapebn.nrdconta = par_nrdconta AND
                          (crapebn.insitctr = "N"          OR
                           crapebn.insitctr = "A") 
                           NO-LOCK:

        ASSIGN par_vlparepr = par_vlparepr + crapebn.vlparepr
               par_vlsaldod = par_vlsaldod + crapebn.vlsdeved.
   
        FIND tt-saldo-devedor-bndes WHERE 
                   tt-saldo-devedor-bndes.cdcooper = crapebn.cdcooper AND 
                   tt-saldo-devedor-bndes.nrdconta = crapebn.nrdconta AND 
                   tt-saldo-devedor-bndes.nrctremp = crapebn.nrctremp
                   NO-LOCK NO-ERROR.
            
        /*** periodicidade de vencimento ***/
        CASE crapebn.cdpervct:
             WHEN 1 THEN
                  ASSIGN aux_perparce = "Semanal".
             WHEN 2 THEN
                  ASSIGN aux_perparce = "Quinzenal".
             WHEN 3 THEN
                  ASSIGN aux_perparce = "Mensal".
             WHEN 4 THEN
                  ASSIGN aux_perparce = "Bimestral".
             WHEN 5 THEN
                  ASSIGN aux_perparce = "Trimestral".
             WHEN 6 THEN
                  ASSIGN aux_perparce = "Semestral".
             WHEN 7 THEN
                  ASSIGN aux_perparce = "Anual".
             WHEN 8 THEN
                  ASSIGN aux_perparce = "Nao periodico".
        END CASE.

        /*** Periodicidade de carencia ***/
        CASE crapebn.cdperpca:
            WHEN 1 THEN
                 ASSIGN aux_percaren = "Mensal".
            WHEN 2 THEN
                 ASSIGN aux_percaren = "Bimestral".
            WHEN 3 THEN
                 ASSIGN aux_percaren = "Trimestral".
            WHEN 6 THEN
                 ASSIGN aux_percaren = "Semestral".
            WHEN 12 THEN
                 ASSIGN aux_percaren = "Anual".
        END CASE.
        
        IF  NOT AVAIL tt-saldo-devedor-bndes THEN
            DO: 
               CREATE tt-saldo-devedor-bndes.
               ASSIGN tt-saldo-devedor-bndes.cdcooper = crapebn.cdcooper 
                      tt-saldo-devedor-bndes.nrdconta = crapebn.nrdconta
                      tt-saldo-devedor-bndes.dtinictr = crapebn.dtinictr
                      tt-saldo-devedor-bndes.dtppvenc = crapebn.dtppvenc
                      tt-saldo-devedor-bndes.dtlibera = crapebn.dtlibera
                      tt-saldo-devedor-bndes.dtpripar = crapebn.dtpripar
                      tt-saldo-devedor-bndes.vlsdeved = crapebn.vlsdeved
                      tt-saldo-devedor-bndes.vlparepr = crapebn.vlparepr
                      tt-saldo-devedor-bndes.vlropepr = crapebn.vlropepr
                      tt-saldo-devedor-bndes.qtparctr = crapebn.qtparctr
                      tt-saldo-devedor-bndes.qtdmesca = 
                                             TRUNC(crapebn.qtdiasca / 30,0) + 1
                      tt-saldo-devedor-bndes.percaren = ""
                      tt-saldo-devedor-bndes.perparce = aux_perparce
                      tt-saldo-devedor-bndes.nrctremp = crapebn.nrctremp
                      tt-saldo-devedor-bndes.dsdprodu = crapebn.dsprodut
                      tt-saldo-devedor-bndes.dtpricar = crapebn.dtpricar
                      tt-saldo-devedor-bndes.percaren = aux_percaren.
                                                        
            END.
        ELSE
            RETURN "NOK".    
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE busca-arquivos:

    DEF INPUT PARAM par_nmarquiv AS CHAR NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-arq-imp.

    DEF VAR aux_nmarquiv AS CHAR NO-UNDO.
    DEF VAR aux_contador AS INTE NO-UNDO.

    ASSIGN aux_contador = 0.

    EMPTY TEMP-TABLE tt-arq-imp.

    INPUT STREAM str_1 THROUGH VALUE("ls " + par_nmarquiv + " 2> /dev/null") 
                                                                    NO-ECHO.

    DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

        SET STREAM str_1 aux_nmarquiv FORMAT "x(70)" .

        CREATE tt-arq-imp.
        ASSIGN tt-arq-imp.idsequen = aux_contador
               tt-arq-imp.nmarquiv = aux_nmarquiv.

        ASSIGN aux_contador = aux_contador + 1.
    END.

    INPUT STREAM str_1 CLOSE.

    IF aux_contador = 0 THEN
        RETURN "NOK".

    RETURN "OK".

END PROCEDURE.

PROCEDURE atualiza-operacoes:

    DEF INPUT PARAM par_cdagenci AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE NO-UNDO.
    DEF INPUT PARAM par_dtmvtopr AS DATE NO-UNDO.

    DEF INPUT PARAM TABLE FOR tt-arq-imp.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nrctrbnd AS DECI NO-UNDO.
    DEF VAR aux_dtfimctr AS DATE NO-UNDO.
    DEF VAR aux_dtinictr AS DATE NO-UNDO.
    DEF VAR aux_vlropepr AS DECI NO-UNDO.
    DEF VAR aux_qtparctr AS INTE NO-UNDO.
    DEF VAR aux_txefeanu AS DECI NO-UNDO.
    DEF VAR aux_dtppvenc AS DATE NO-UNDO.
    DEF VAR aux_dtliquid AS DATE NO-UNDO.
    DEF VAR aux_tpliquid AS INTE NO-UNDO.
    DEF VAR aux_vlaat180 AS DECI NO-UNDO.
    DEF VAR aux_vlave360 AS DECI NO-UNDO.
    DEF VAR aux_vlasu360 AS DECI NO-UNDO.
    DEF VAR aux_vlveat60 AS DECI NO-UNDO.
    DEF VAR aux_vlvenc61 AS DECI NO-UNDO.
    DEF VAR aux_vlven181 AS DECI NO-UNDO.
    DEF VAR aux_vlvsu360 AS DECI NO-UNDO.
    DEF VAR aux_vlvenc30 AS DECI NO-UNDO.
    DEF VAR aux_dtprejuz AS DATE NO-UNDO.
    DEF VAR aux_qtdiasca AS INTE NO-UNDO.
    DEF VAR aux_vlsdeved AS DECI NO-UNDO.
    DEF VAR aux_insitctr AS CHAR NO-UNDO.
    DEF VAR aux_cdpervct AS INTE NO-UNDO.
    DEF VAR aux_diapagto AS INTE NO-UNDO.
    DEF VAR aux_cdsubmod AS INTE NO-UNDO.
    DEF VAR aux_vlaa5400 AS DECI NO-UNDO.
    DEF VAR aux_vlav5400 AS DECI NO-UNDO.
    DEF VAR aux_vlav1080 AS DECI NO-UNDO.
    DEF VAR aux_vlav1440 AS DECI NO-UNDO.
    DEF VAR aux_vlav1800 AS DECI NO-UNDO.
    DEF VAR aux_vlave720 AS DECI NO-UNDO.
    DEF VAR aux_vlave180 AS DECI NO-UNDO.
    DEF VAR aux_vlaven90 AS DECI NO-UNDO.
    DEF VAR aux_vlaven60 AS DECI NO-UNDO.
    DEF VAR aux_vlaven30 AS DECI NO-UNDO.
    DEF VAR aux_vlvenc14 AS DECI NO-UNDO.
    DEF VAR aux_vlvenc60 AS DECI NO-UNDO.
    DEF VAR aux_vlvenc90 AS DECI NO-UNDO.
    DEF VAR aux_vlven120 AS DECI NO-UNDO.
    DEF VAR aux_vlven150 AS DECI NO-UNDO.
    DEF VAR aux_vlven180 AS DECI NO-UNDO.
    DEF VAR aux_vlven240 AS DECI NO-UNDO.
    DEF VAR aux_vlven300 AS DECI NO-UNDO.
    DEF VAR aux_vlven360 AS DECI NO-UNDO.
    DEF VAR aux_vlven540 AS DECI NO-UNDO.
    DEF VAR aux_vlvac540 AS DECI NO-UNDO.
    DEF VAR aux_vlprej12 AS DECI NO-UNDO.
    DEF VAR aux_vlprej48 AS DECI NO-UNDO.
    DEF VAR aux_vlprac48 AS DECI NO-UNDO.
    DEF VAR aux_dtlibera AS DATE NO-UNDO.
    DEF VAR aux_vlparepr AS DECI NO-UNDO.
    DEF VAR aux_qtparabe AS INTE NO-UNDO.
    DEF VAR aux_dtvctpto AS DATE NO-UNDO.
    DEF VAR aux_nrdconta AS INTE NO-UNDO.
    DEF VAR aux_natopera AS CHAR NO-UNDO.
    DEF VAR aux_periocar AS INTE NO-UNDO.
    DEF VAR aux_dtcarenc AS DATE NO-UNDO.
    DEF VAR aux_descprod AS CHAR NO-UNDO.

    DEF VAR aux_nrsequen AS INTE   NO-UNDO.
    DEF VAR aux_flagerro AS LOGI   NO-UNDO.
    DEF VAR aux_nmarqdes AS CHAR   NO-UNDO.
    DEF VAR h-b1wgen0043 AS HANDLE NO-UNDO.

    ASSIGN aux_nrsequen = 0
           aux_flagerro = FALSE
           aux_nmarqdes = "/usr/coop/cecred/salvar/".

    FOR EACH tt-arq-imp NO-LOCK: /* Arquivos de todas as cooperativas */ 

        EMPTY TEMP-TABLE tt-erro.

        ASSIGN aux_cdcooper = INTE(SUBSTR(tt-arq-imp.nmarquiv, 
                                     INDEX(tt-arq-imp.nmarquiv, ".") + 1, 3)).

        FIND crapcop WHERE crapcop.cdcooper = aux_cdcooper NO-LOCK NO-ERROR.

        IF NOT AVAIL crapcop THEN
        DO:
            ASSIGN aux_cdcritic = 651. 

            RUN gera_erro (INPUT aux_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, 
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            ASSIGN aux_flagerro = TRUE.

            RUN gera-log-prcbnd (INPUT "Cooperativa: " + 
                                            STRING(aux_cdcooper, "999"),
                                 INPUT par_cdoperad,
                                 INPUT tt-arq-imp.nmarquiv,
                                 INPUT 1,
                                 INPUT "Atualizacao de operacoes",
                                 INPUT 0,
                                 INPUT 0,
                                 INPUT TABLE tt-erro).

            UNIX SILENT VALUE("mv " + tt-arq-imp.nmarquiv + " " +
                              aux_nmarqdes + " 2> /dev/null").

            NEXT.
        END.
    
        INPUT STREAM str_1 FROM VALUE(tt-arq-imp.nmarquiv) NO-ECHO.
    
        IMPORT STREAM str_1 UNFORMATTED aux_setlinha.

        /* trata header do arquivo */
        IF SUBSTR(aux_setlinha, 1, 1) <> "1" THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Arquivo invalido."
                   aux_flagerro = TRUE.

            RUN gera-log-prcbnd (INPUT crapcop.nmrescop,
                                 INPUT par_cdoperad,
                                 INPUT tt-arq-imp.nmarquiv,
                                 INPUT 1,
                                 INPUT "Atualizacao de operacoes",
                                 INPUT 0,
                                 INPUT 0,
                                 INPUT TABLE tt-erro).

            INPUT STREAM str_1 CLOSE.

            UNIX SILENT VALUE("mv " + tt-arq-imp.nmarquiv + " " +
                              aux_nmarqdes + " 2> /dev/null").
    
            NEXT.
        END.

        RUN sistema/generico/procedures/b1wgen0043.p PERSISTENT SET
                                                                h-b1wgen0043.

        IF NOT VALID-HANDLE(h-b1wgen0043) THEN
            RETURN "NOK".
    
        /* trata detalhe do arquivo */
        DO TRANSACTION WHILE TRUE ON ENDKEY UNDO, LEAVE ON ERROR UNDO, LEAVE:

            IMPORT STREAM str_1 UNFORMATTED aux_setlinha.

            IF SUBSTR(aux_setlinha, 1, 1) = "3" THEN /* trailler */
                LEAVE.
    
            ASSIGN aux_nrctrbnd = DECI(SUBSTR(aux_setlinha, 5, 17))
                   aux_dtfimctr = DATE(INTE(SUBSTR(aux_setlinha, 26, 2)),
                                       INTE(SUBSTR(aux_setlinha, 28, 2)),
                                       INTE(SUBSTR(aux_setlinha, 22, 4)))
                   aux_nrdconta = INTE(SUBSTR(aux_setlinha, 496, 10))
                   aux_vlropepr = DECI(SUBSTR(aux_setlinha, 67, 15)) / 100
                   aux_vlsdeved = DECI(SUBSTR(aux_setlinha, 382, 15)) / 100
                   aux_insitctr = SUBSTR(aux_setlinha, 494, 1)
                   aux_qtparctr = INTE(SUBSTR(aux_setlinha, 108, 3))
                   aux_qtdiasca = INTE(SUBSTR(aux_setlinha, 420, 4))
                   aux_cdpervct = INTE(SUBSTR(aux_setlinha, 509, 1))
                   aux_diapagto = INTE(SUBSTR(aux_setlinha, 511, 2))
                   aux_vlparepr = DECI(SUBSTR(aux_setlinha, 1120, 15)) / 100
                   aux_qtparabe = INTE(SUBSTR(aux_setlinha, 1135, 3))
                   aux_tpliquid = INTE(SUBSTR(aux_setlinha, 171, 1))
                   aux_dtinictr = DATE(INTE(SUBSTR(aux_setlinha, 51, 2)),/*mes*/
                                    INTE(SUBSTR(aux_setlinha, 53, 2)),/*dia*/
                                    INTE(SUBSTR(aux_setlinha, 47, 4)))/*ano*/
                             WHEN SUBSTR(aux_setlinha, 47, 4) <> "0000" AND
                                  SUBSTR(aux_setlinha, 47, 1) <> " "
                   aux_dtppvenc = DATE(INTE(SUBSTR(aux_setlinha, 157, 2)),
                                    INTE(SUBSTR(aux_setlinha, 159, 2)),
                                    INTE(SUBSTR(aux_setlinha, 153, 4)))
                             WHEN SUBSTR(aux_setlinha, 153, 4) <> "0000" AND
                                  SUBSTR(aux_setlinha, 153, 1) <> " "
                   aux_dtliquid = DATE(INTE(SUBSTR(aux_setlinha, 167, 2)),
                                    INTE(SUBSTR(aux_setlinha, 169, 2)),
                                    INTE(SUBSTR(aux_setlinha, 163, 4)))
                             WHEN SUBSTR(aux_setlinha, 163, 4) <> "0000" AND
                                  SUBSTR(aux_setlinha, 163, 1) <> " "
                   aux_dtprejuz = DATE(INTE(SUBSTR(aux_setlinha, 416, 2)),
                                    INTE(SUBSTR(aux_setlinha, 418, 2)),
                                    INTE(SUBSTR(aux_setlinha, 412, 4)))
                             WHEN SUBSTR(aux_setlinha, 412, 4) <> "0000" AND
                                  SUBSTR(aux_setlinha, 412, 1) <> " "
                   aux_dtlibera = DATE(INTE(SUBSTR(aux_setlinha, 951, 2)),
                                    INTE(SUBSTR(aux_setlinha, 953, 2)),
                                    INTE(SUBSTR(aux_setlinha, 947, 4)))
                             WHEN SUBSTR(aux_setlinha, 947, 4) <> "0000" AND
                                  SUBSTR(aux_setlinha, 947, 1) <> " "
                   aux_dtvctpto = DATE(INTE(SUBSTR(aux_setlinha, 1165, 2)),
                                    INTE(SUBSTR(aux_setlinha, 1167, 2)),
                                    INTE(SUBSTR(aux_setlinha, 1161, 4)))
                            WHEN SUBSTR(aux_setlinha, 1161, 4) <> "0000" AND
                                 SUBSTR(aux_setlinha, 1161, 1) <> " "

                   /* Divida a vencer */ 
                   aux_vlaven30 = DECI(SUBSTR(aux_setlinha, 677, 15)) / 100
                   aux_vlaven60 = DECI(SUBSTR(aux_setlinha, 662, 15)) / 100
                   aux_vlaven90 = DECI(SUBSTR(aux_setlinha, 647, 15)) / 100
                   aux_vlave180 = DECI(SUBSTR(aux_setlinha, 632, 15)) / 100
                   aux_vlave360 = DECI(SUBSTR(aux_setlinha, 187, 15)) / 100
                   aux_vlave720 = DECI(SUBSTR(aux_setlinha, 617, 15)) / 100
                   aux_vlav1080 = DECI(SUBSTR(aux_setlinha, 602, 15)) / 100
                   aux_vlav1440 = DECI(SUBSTR(aux_setlinha, 587, 15)) / 100
                   aux_vlav1800 = DECI(SUBSTR(aux_setlinha, 572, 15)) / 100
                   aux_vlav5400 = DECI(SUBSTR(aux_setlinha, 557, 15)) / 100
                   aux_vlaa5400 = DECI(SUBSTR(aux_setlinha, 542, 15)) / 100
                   aux_vlaat180 = DECI(SUBSTR(aux_setlinha, 172, 15)) / 100
                   aux_vlasu360 = DECI(SUBSTR(aux_setlinha, 202, 15)) / 100

                   /* Divida vencida */ 
                   aux_vlvenc14 = DECI(SUBSTR(aux_setlinha, 692, 15)) / 100
                   aux_vlvenc30 = DECI(SUBSTR(aux_setlinha, 902, 15)) / 100
                   aux_vlvenc60 = DECI(SUBSTR(aux_setlinha, 707, 15)) / 100
                   aux_vlvenc90 = DECI(SUBSTR(aux_setlinha, 722, 15)) / 100
                   aux_vlven120 = DECI(SUBSTR(aux_setlinha, 737, 15)) / 100
                   aux_vlven150 = DECI(SUBSTR(aux_setlinha, 752, 15)) / 100
                   aux_vlven180 = DECI(SUBSTR(aux_setlinha, 767, 15)) / 100
                   aux_vlven240 = DECI(SUBSTR(aux_setlinha, 782, 15)) / 100
                   aux_vlven300 = DECI(SUBSTR(aux_setlinha, 797, 15)) / 100
                   aux_vlven360 = DECI(SUBSTR(aux_setlinha, 812, 15)) / 100
                   aux_vlven540 = DECI(SUBSTR(aux_setlinha, 827, 15)) / 100
                   aux_vlvac540 = DECI(SUBSTR(aux_setlinha, 955, 16)) / 100
                   aux_vlveat60 = DECI(SUBSTR(aux_setlinha, 217, 15)) / 100
                   aux_vlvenc61 = DECI(SUBSTR(aux_setlinha, 232, 15)) / 100
                   aux_vlven181 = DECI(SUBSTR(aux_setlinha, 247, 15)) / 100
                   aux_vlvsu360 = DECI(SUBSTR(aux_setlinha, 262, 15)) / 100
                   
                   /* Baixado como prejuizo */ 
                   aux_vlprej12 = DECI(SUBSTR(aux_setlinha, 842, 15)) / 100
                   aux_vlprej48 = DECI(SUBSTR(aux_setlinha, 857, 15)) / 100
                   aux_vlprac48 = DECI(SUBSTR(aux_setlinha, 872, 15)) / 100

                   aux_cdsubmod = INTE(SUBSTR(aux_setlinha, 519, 4))

                   aux_natopera = SUBSTR(aux_setlinha, 1215, 1)
                   aux_periocar = INTE(SUBSTR(aux_setlinha, 1217, 2))

                   aux_dtcarenc = DATE(INTE(SUBSTR(aux_setlinha, 1224, 2)),
                                       INTE(SUBSTR(aux_setlinha, 1226, 2)),
                                       INTE(SUBSTR(aux_setlinha, 1220, 4)))

                   aux_descprod = SUBSTR(aux_setlinha, 1229, 40).

            /* Atualiza somente ATIVO na conta dos cooperados, 
              despreza PASSIVO */
            IF  aux_natopera <> "A" THEN
                NEXT.

            /* Normal, Atraso, Prejuizo, Liquidado */
            IF  NOT(CAN-DO("N,A,P,L",aux_insitctr))  THEN
                NEXT.    

            FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper AND
                               crapass.nrdconta = aux_nrdconta 
                               NO-LOCK NO-ERROR.

            IF NOT AVAIL crapass THEN
            DO:
                ASSIGN aux_cdcritic = 9
                       aux_nrsequen = aux_nrsequen + 1.

                RUN gera_erro (INPUT aux_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT aux_nrsequen, 
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

                RUN gera-log-prcbnd (INPUT crapcop.nmrescop,
                                     INPUT par_cdoperad,
                                     INPUT tt-arq-imp.nmarquiv,
                                     INPUT 1,
                                     INPUT "Atualizacao de operacoes",
                                     INPUT aux_nrdconta,
                                     INPUT aux_nrctrbnd,
                                     INPUT TABLE tt-erro).

                ASSIGN aux_flagerro = TRUE.

                NEXT.
            END.

            FIND crapebn WHERE crapebn.cdcooper = aux_cdcooper AND
                               crapebn.nrdconta = aux_nrdconta AND
                               crapebn.nrctremp = INTE(aux_nrctrbnd)
                                    EXCLUSIVE-LOCK NO-ERROR.

            /* Cria novo contrato cadastrado na TOTVS */ 
            IF NOT AVAIL crapebn THEN
            DO:
                CREATE crapebn.
                ASSIGN crapebn.cdcooper = aux_cdcooper
                       crapebn.nrdconta = aux_nrdconta
                       crapebn.nrctremp = aux_nrctrbnd
                       crapebn.dtfimctr = aux_dtfimctr
                       crapebn.insitctr = aux_insitctr
                       crapebn.dtinictr = aux_dtinictr
                       crapebn.vlropepr = aux_vlropepr
                       crapebn.vlparepr = aux_vlparepr
                       crapebn.vlsdeved = aux_vlsdeved
                       crapebn.qtparctr = aux_qtparctr
                       crapebn.dtppvenc = aux_dtppvenc
                       crapebn.dtliquid = aux_dtliquid
                       crapebn.tpliquid = aux_tpliquid
                       crapebn.qtdiasca = aux_qtdiasca
                       crapebn.cdpervct = aux_cdpervct
                       crapebn.diapagto = aux_diapagto
                       crapebn.dtprejuz = aux_dtprejuz
                       crapebn.dtlibera = aux_dtlibera
                       crapebn.qtparabe = aux_qtparabe
                       crapebn.dtvctpro = aux_dtvctpto
                       crapebn.dtpripar = aux_dtvctpto
                       
                       /* Divida a Vencer */ 
                       crapebn.vlaven30 = aux_vlaven30
                       crapebn.vlaven60 = aux_vlaven60
                       crapebn.vlaven90 = aux_vlaven90
                       crapebn.vlave180 = aux_vlave180
                       crapebn.vlave360 = aux_vlave360
                       crapebn.vlave720 = aux_vlave720
                       crapebn.vlav1080 = aux_vlav1080
                       crapebn.vlav1440 = aux_vlav1440
                       crapebn.vlav1800 = aux_vlav1800
                       crapebn.vlav5400 = aux_vlav5400
                       crapebn.vlaa5400 = aux_vlaa5400
                       crapebn.vlaat180 = aux_vlaat180
                       crapebn.vlasu360 = aux_vlasu360

                       /* Divida vencida */ 
                       crapebn.vlvenc14 = aux_vlvenc14
                       crapebn.vlvenc30 = aux_vlvenc30
                       crapebn.vlvenc60 = aux_vlvenc60
                       crapebn.vlvenc90 = aux_vlvenc90
                       crapebn.vlven120 = aux_vlven120
                       crapebn.vlven150 = aux_vlven150
                       crapebn.vlven180 = aux_vlven180
                       crapebn.vlven240 = aux_vlven240
                       crapebn.vlven300 = aux_vlven300
                       crapebn.vlven360 = aux_vlven360
                       crapebn.vlven540 = aux_vlven540
                       crapebn.vlvac540 = aux_vlvac540
                       
                       crapebn.vlveat60 = aux_vlveat60
                       crapebn.vlvenc61 = aux_vlvenc61
                       crapebn.vlven181 = aux_vlven181
                       crapebn.vlvsu360 = aux_vlvsu360

                       /* Baixados como prejuizo */ 
                       crapebn.vlprej12 = aux_vlprej12
                       crapebn.vlprej48 = aux_vlprej48
                       crapebn.vlprac48 = aux_vlprac48

                       crapebn.cdsubmod = aux_cdsubmod
                       crapebn.cdnatope = aux_natopera
                       crapebn.cdperpca = aux_periocar
                       crapebn.dtpricar = aux_dtcarenc
                       crapebn.dsprodut = aux_descprod. 

                VALIDATE crapebn.

            END.
            /* Atualiza informaçoes do contrato */ 
            ELSE
            DO:
                ASSIGN crapebn.insitctr = aux_insitctr
                       crapebn.dtinictr = aux_dtinictr
                       crapebn.dtfimctr = aux_dtfimctr
                       crapebn.vlropepr = aux_vlropepr
                       crapebn.vlparepr = aux_vlparepr
                       crapebn.vlsdeved = aux_vlsdeved
                       crapebn.qtparctr = aux_qtparctr
                       crapebn.dtppvenc = aux_dtppvenc
                       crapebn.dtliquid = aux_dtliquid
                       crapebn.tpliquid = aux_tpliquid
                       crapebn.qtdiasca = aux_qtdiasca
                       crapebn.cdpervct = aux_cdpervct
                       crapebn.diapagto = aux_diapagto
                       crapebn.dtprejuz = aux_dtprejuz
                       crapebn.dtlibera = aux_dtlibera
                       crapebn.qtparabe = aux_qtparabe
                       crapebn.dtvctpro = aux_dtvctpto
                       crapebn.dtpripar = aux_dtvctpto
                       
                       /* Divida a Vencer */ 
                       crapebn.vlaven30 = aux_vlaven30
                       crapebn.vlaven60 = aux_vlaven60
                       crapebn.vlaven90 = aux_vlaven90
                       crapebn.vlave180 = aux_vlave180
                       crapebn.vlave360 = aux_vlave360
                       crapebn.vlave720 = aux_vlave720
                       crapebn.vlav1080 = aux_vlav1080
                       crapebn.vlav1440 = aux_vlav1440
                       crapebn.vlav1800 = aux_vlav1800
                       crapebn.vlav5400 = aux_vlav5400
                       crapebn.vlaa5400 = aux_vlaa5400
                       crapebn.vlaat180 = aux_vlaat180
                       crapebn.vlasu360 = aux_vlasu360

                       /* Divida vencida */ 
                       crapebn.vlvenc14 = aux_vlvenc14
                       crapebn.vlvenc30 = aux_vlvenc30
                       crapebn.vlvenc60 = aux_vlvenc60
                       crapebn.vlvenc90 = aux_vlvenc90
                       crapebn.vlven120 = aux_vlven120
                       crapebn.vlven150 = aux_vlven150
                       crapebn.vlven180 = aux_vlven180
                       crapebn.vlven240 = aux_vlven240
                       crapebn.vlven300 = aux_vlven300
                       crapebn.vlven360 = aux_vlven360
                       crapebn.vlven540 = aux_vlven540
                       crapebn.vlvac540 = aux_vlvac540
                       
                       crapebn.vlveat60 = aux_vlveat60
                       crapebn.vlvenc61 = aux_vlvenc61
                       crapebn.vlven181 = aux_vlven181
                       crapebn.vlvsu360 = aux_vlvsu360

                       /* Baixados como prejuizo */ 
                       crapebn.vlprej12 = aux_vlprej12
                       crapebn.vlprej48 = aux_vlprej48
                       crapebn.vlprac48 = aux_vlprac48

                       crapebn.cdsubmod = aux_cdsubmod
                       crapebn.cdnatope = aux_natopera
                       crapebn.cdperpca = aux_periocar
                       crapebn.dtpricar = aux_dtcarenc
                       crapebn.dsprodut = aux_descprod. 
            END.

            IF aux_insitctr = "L" THEN /* Contrato Liquidado */ 
            DO:
                RUN desativa_rating IN h-b1wgen0043 (INPUT aux_cdcooper,
                                                     INPUT par_cdagenci,
                                                     INPUT par_nrdcaixa,
                                                     INPUT par_cdoperad,
                                                     INPUT par_dtmvtolt,
                                                     INPUT par_dtmvtopr,
                                                     INPUT aux_nrdconta,
                                                     INPUT 90,
                                                     INPUT aux_nrctrbnd,
                                                     INPUT TRUE,
                                                     INPUT 1,
                                                     INPUT 1,
                                                     INPUT "PRCBND",
                                                     INPUT 0,
                                                     INPUT TRUE,
                                                    OUTPUT TABLE tt-erro). 

                IF RETURN-VALUE <> "OK" THEN
                DO:
                    DELETE PROCEDURE h-b1wgen0043.

                    RUN gera-log-prcbnd (INPUT crapcop.nmrescop,
                                         INPUT par_cdoperad,
                                         INPUT tt-arq-imp.nmarquiv,
                                         INPUT 1,
                                         INPUT "Atualizacao de operacoes",
                                         INPUT aux_nrdconta,
                                         INPUT aux_nrctrbnd,
                                         INPUT TABLE tt-erro).

                    ASSIGN aux_flagerro = TRUE.

                    NEXT.
                END.
            END.
        END.

        /* Logar se arquivo foi processado com sucesso ou com erros */ 
        FIND LAST tt-erro NO-LOCK NO-ERROR.

        IF AVAIL tt-erro THEN
            RUN gera-log-prcbnd (INPUT crapcop.nmrescop,
                                 INPUT par_cdoperad,
                                 INPUT tt-arq-imp.nmarquiv,
                                 INPUT 99,
                                 INPUT "Atualizacao de operacoes",
                                 INPUT aux_nrdconta,
                                 INPUT aux_nrctrbnd,
                                 INPUT TABLE tt-erro).
        ELSE
            RUN gera-log-prcbnd (INPUT crapcop.nmrescop,
                                 INPUT par_cdoperad,
                                 INPUT tt-arq-imp.nmarquiv,
                                 INPUT 1,
                                 INPUT "Atualizacao de operacoes",
                                 INPUT aux_nrdconta,
                                 INPUT aux_nrctrbnd,
                                 INPUT TABLE tt-erro).

        DELETE PROCEDURE h-b1wgen0043.

        INPUT STREAM str_1 CLOSE.

        UNIX SILENT VALUE("mv " + tt-arq-imp.nmarquiv + " " + 
                          aux_nmarqdes + " 2> /dev/null").

    END.

    IF aux_flagerro THEN
        RETURN "NOK".

    RETURN "OK".

END PROCEDURE.

PROCEDURE liquida-parcela:

    DEF INPUT PARAM par_cdagenci AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR NO-UNDO.
    DEF INPUT PARAM TABLE FOR tt-arq-imp.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nrcpfcgc AS DECI NO-UNDO.
    DEF VAR aux_nrctrbnd AS INTE NO-UNDO.
    DEF VAR aux_nrdconta AS INTE NO-UNDO.
    DEF VAR aux_tpmovime AS CHAR NO-UNDO.
    DEF VAR aux_vlmulmor AS DECI NO-UNDO.
    DEF VAR aux_vlparcel AS DECI NO-UNDO.
    DEF VAR aux_vlrecebi AS DECI NO-UNDO.
    DEF VAR aux_nmarqdes AS CHAR NO-UNDO.
    DEF VAR aux_nrsequen AS INTE NO-UNDO.

    ASSIGN aux_nmarqdes = "/usr/coop/cecred/salvar/"
           aux_nrsequen = 0.

    FOR EACH tt-arq-imp NO-LOCK:

        EMPTY TEMP-TABLE tt-erro.

        ASSIGN aux_cdcooper = INTE(SUBSTR(tt-arq-imp.nmarquiv, 
                                     INDEX(tt-arq-imp.nmarquiv, ".") + 1, 3)).

        FIND crapcop WHERE crapcop.cdcooper = aux_cdcooper NO-LOCK NO-ERROR.

        IF NOT AVAIL crapcop THEN
        DO:
            ASSIGN aux_cdcritic = 651. 

            RUN gera_erro (INPUT aux_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, 
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RUN gera-log-prcbnd (INPUT "Cooperativa: " + 
                                            STRING(aux_cdcooper, "999"),
                                 INPUT par_cdoperad,
                                 INPUT tt-arq-imp.nmarquiv,
                                 INPUT 1,
                                 INPUT "Baixa/Estorno de Parcela",
                                 INPUT 0,
                                 INPUT 0,
                                 INPUT TABLE tt-erro).

            UNIX SILENT VALUE("mv " + tt-arq-imp.nmarquiv + " " + 
                              aux_nmarqdes + " 2> /dev/null").

            NEXT.
        END.

        INPUT STREAM str_1 FROM VALUE(tt-arq-imp.nmarquiv) NO-ECHO.
    
        IMPORT STREAM str_1 UNFORMATTED aux_setlinha.
    
        /* trata header do arquivo */
        IF SUBSTR(aux_setlinha, 1, 3) <> "000" THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Arquivo invalido.".

            RUN gera-log-prcbnd (INPUT crapcop.nmrescop,
                                 INPUT par_cdoperad,
                                 INPUT tt-arq-imp.nmarquiv,
                                 INPUT 2,
                                 INPUT "Baixa/Estorno de Parcela",
                                 INPUT 0,
                                 INPUT 0,
                                 INPUT TABLE tt-erro).

            INPUT STREAM str_1 CLOSE.

            UNIX SILENT VALUE("mv " + tt-arq-imp.nmarquiv + " " + 
                              aux_nmarqdes + " 2> /dev/null").
    
            NEXT.
        END.
    
        /* trata detalhe do arquivo */
        DO TRANSACTION WHILE TRUE ON ENDKEY UNDO, LEAVE ON ERROR UNDO, LEAVE:

            IMPORT STREAM str_1 UNFORMATTED aux_setlinha.

            ASSIGN aux_nrcpfcgc = DECI(SUBSTR(aux_setlinha, 4, 14))
                   aux_nrctrbnd = INTE(SUBSTR(aux_setlinha, 18, 10))
                   aux_vlrecebi = DECI(SUBSTR(aux_setlinha, 50, 17))
                   aux_vlmulmor = DECI(SUBSTR(aux_setlinha, 84, 17))
                   aux_vlparcel = DECI(SUBSTR(aux_setlinha, 118, 17))
                   aux_tpmovime = SUBSTR(aux_setlinha, 151, 1)
                   aux_nrdconta = 0
                   aux_nrsequen = aux_nrsequen + 1.

            RUN busca-conta-cooperado (INPUT aux_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT aux_nrcpfcgc,
                                       INPUT aux_nrctrbnd,
                                       INPUT aux_nrsequen,
                                      OUTPUT aux_nrdconta,
                                      OUTPUT TABLE tt-erro).

            IF RETURN-VALUE = "NOK" THEN
            DO:
                IF aux_tpmovime = "L" THEN
                    RUN gera-log-prcbnd (INPUT crapcop.nmrescop,
                                         INPUT par_cdoperad,
                                         INPUT tt-arq-imp.nmarquiv,
                                         INPUT 2,
                                         INPUT "Liquidacao de parcela",
                                         INPUT aux_nrdconta,
                                         INPUT aux_nrctrbnd,
                                         INPUT TABLE tt-erro).
                ELSE
                IF aux_tpmovime = "E" THEN
                    RUN gera-log-prcbnd (INPUT crapcop.nmrescop,
                                         INPUT par_cdoperad,
                                         INPUT tt-arq-imp.nmarquiv,
                                         INPUT 2,
                                         INPUT "Estorno de parcela",
                                         INPUT aux_nrdconta,
                                         INPUT aux_nrctrbnd,
                                         INPUT TABLE tt-erro).


                NEXT.
            END.

            IF aux_tpmovime = "L" THEN /* Liquidacao */
            DO:
                /* lanca debito da parcela */
                RUN cria-lancamento (INPUT aux_cdcooper,
                                     INPUT 1, /*cdagenci */
                                     INPUT 10125, /* nrdolote */
                                     INPUT 100, /* cdbccxlt */
                                     INPUT 1, /* tplotmov */
                                     INPUT par_dtmvtolt,
                                     INPUT 1225, /* cdhistor */
                                     INPUT par_cdoperad,
                                     INPUT aux_nrdconta,
                                     INPUT aux_vlparcel,
                                    OUTPUT TABLE tt-erro).

                IF RETURN-VALUE = "NOK" THEN
                DO:
                    RUN gera-log-prcbnd (INPUT crapcop.nmrescop,
                                         INPUT par_cdoperad,
                                         INPUT tt-arq-imp.nmarquiv,
                                         INPUT 2,
                                         INPUT "Liquidacao de parcela",
                                         INPUT aux_nrdconta,
                                         INPUT aux_nrctrbnd,
                                         INPUT TABLE tt-erro).

                    NEXT.
                END.

                IF aux_vlmulmor <> 0 THEN /* lanca debito de multa/mora */
                DO:
                    RUN cria-lancamento (INPUT aux_cdcooper,
                                         INPUT 1, /*cdagenci */
                                         INPUT 10125, /* nrdolote */
                                         INPUT 100, /* cdbccxlt */
                                         INPUT 1, /* tplotmov */
                                         INPUT par_dtmvtolt,
                                         INPUT 1228, /* cdhistor */
                                         INPUT par_cdoperad,
                                         INPUT aux_nrdconta,
                                         INPUT aux_vlmulmor,
                                        OUTPUT TABLE tt-erro).

                    IF RETURN-VALUE = "NOK" THEN
                    DO:
                        RUN gera-log-prcbnd (INPUT crapcop.nmrescop,
                                             INPUT par_cdoperad,
                                             INPUT tt-arq-imp.nmarquiv,
                                             INPUT 2,
                                        INPUT "Liquidacao de parcela(multa)",
                                             INPUT aux_nrdconta,
                                             INPUT aux_nrctrbnd,
                                             INPUT TABLE tt-erro).

                        NEXT.
                    END.
                END.

                RUN gera-log-prcbnd (INPUT crapcop.nmrescop,
                                     INPUT par_cdoperad,
                                     INPUT tt-arq-imp.nmarquiv,
                                     INPUT 2,
                                     INPUT "Liquidacao de parcela",
                                     INPUT aux_nrdconta,
                                     INPUT aux_nrctrbnd,
                                     INPUT TABLE tt-erro).
            END.
            ELSE
            IF aux_tpmovime = "E" THEN /* Estorno de liquidacao */
            DO:
                /* lanca credito do estorno de liquidacao */
                RUN cria-lancamento (INPUT aux_cdcooper,
                                     INPUT 1, /*cdagenci */
                                     INPUT 10126, /* nrdolote */
                                     INPUT 100, /* cdbccxlt */
                                     INPUT 1, /* tplotmov */
                                     INPUT par_dtmvtolt,
                                     INPUT 1229, /* cdhistor */
                                     INPUT par_cdoperad,
                                     INPUT aux_nrdconta,
                                     INPUT aux_vlrecebi,
                                    OUTPUT TABLE tt-erro).

                IF RETURN-VALUE = "NOK" THEN
                DO:
                    RUN gera-log-prcbnd (INPUT crapcop.nmrescop,
                                         INPUT par_cdoperad,
                                         INPUT tt-arq-imp.nmarquiv,
                                         INPUT 2,
                                         INPUT "Estorno de parcela",
                                         INPUT aux_nrdconta,
                                         INPUT aux_nrctrbnd,
                                         INPUT TABLE tt-erro).

                    NEXT.
                END.

                RUN gera-log-prcbnd (INPUT crapcop.nmrescop,
                                     INPUT par_cdoperad,
                                     INPUT tt-arq-imp.nmarquiv,
                                     INPUT 2,
                                     INPUT "Estorno de parcela",
                                     INPUT aux_nrdconta,
                                     INPUT aux_nrctrbnd,
                                     INPUT TABLE tt-erro).
            END.
        END.

        INPUT STREAM str_1 CLOSE.

        UNIX SILENT VALUE("mv " + tt-arq-imp.nmarquiv + " " + 
                          aux_nmarqdes + " 2> /dev/null").
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE atualiza-central-risco:

    DEF INPUT PARAM par_cdagenci AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR NO-UNDO.

    DEF INPUT PARAM TABLE FOR tt-arq-imp.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_txefeanu AS DECI NO-UNDO.
    DEF VAR aux_tpgarant AS CHAR NO-UNDO.
    DEF VAR aux_cdtipgar AS CHAR NO-UNDO.
    DEF VAR aux_dscatbem AS CHAR NO-UNDO.
    DEF VAR aux_vlgarant AS DECI NO-UNDO.
    DEF VAR aux_nrcpfcgc AS DECI NO-UNDO.
    DEF VAR aux_vlpergar AS DECI NO-UNDO.
    DEF VAR aux_nrdconta AS INTE NO-UNDO.
    DEF VAR aux_nrctrbnd AS INTE NO-UNDO.
    DEF VAR aux_idseqbem AS INTE NO-UNDO.
    DEF VAR aux_nmarqdes AS CHAR NO-UNDO.
    DEF VAR aux_nrsequen AS INTE NO-UNDO.

    ASSIGN aux_nmarqdes = "/usr/coop/cecred/salvar/"
           aux_nrsequen = 0.

    FOR EACH tt-arq-imp NO-LOCK:

        EMPTY TEMP-TABLE tt-erro.

        ASSIGN aux_cdcooper = INTE(SUBSTR(tt-arq-imp.nmarquiv, 
                                     INDEX(tt-arq-imp.nmarquiv, ".") + 1, 3)).

        FIND crapcop WHERE crapcop.cdcooper = aux_cdcooper NO-LOCK NO-ERROR.

        IF NOT AVAIL crapcop THEN
        DO:
            ASSIGN aux_cdcritic = 651. 

            RUN gera_erro (INPUT aux_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, 
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RUN gera-log-prcbnd (INPUT "Cooperativa: " + 
                                                STRING(aux_cdcooper, "999"),
                                 INPUT par_cdoperad,
                                 INPUT tt-arq-imp.nmarquiv,
                                 INPUT 3,
                                 INPUT "Atualizacao Central de Risco BNDES",
                                 INPUT 0,
                                 INPUT 0,
                                 INPUT TABLE tt-erro).

            NEXT.
        END.

        INPUT STREAM str_1 FROM VALUE(tt-arq-imp.nmarquiv) NO-ECHO.
    
        IMPORT STREAM str_1 UNFORMATTED aux_setlinha.
    
        /* trata header do arquivo */
        IF SUBSTR(aux_setlinha, 1, 2) <> "00" THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Arquivo invalido.".

            RUN gera-log-prcbnd (INPUT crapcop.nmrescop,
                                 INPUT par_cdoperad,
                                 INPUT tt-arq-imp.nmarquiv,
                                 INPUT 3,
                                 INPUT "Atualizacao Central de Risco BNDES",
                                 INPUT 0,
                                 INPUT 0,
                                 INPUT TABLE tt-erro).

            INPUT STREAM str_1 CLOSE.

            UNIX SILENT VALUE("mv " + tt-arq-imp.nmarquiv + " " + 
                              aux_nmarqdes + " 2> /dev/null").
    
            NEXT.
        END.
    
        /* trata detalhe do arquivo */
        DO TRANSACTION WHILE TRUE ON ENDKEY UNDO, LEAVE ON ERROR UNDO, LEAVE:

            IMPORT STREAM str_1 UNFORMATTED aux_setlinha.

            IF SUBSTR(aux_setlinha, 1, 2) = "02" THEN
            DO:
                ASSIGN aux_nrcpfcgc = DECI(SUBSTR(aux_setlinha, 7, 14))
                       aux_nrctrbnd = INTE(SUBSTR(aux_setlinha, 43, 10))
                       aux_txefeanu = DECI(STRING(
                                           SUBSTR(aux_setlinha, 771, 11),
                                           "9999,9999999"))
                       aux_nrsequen = aux_nrsequen + 1.

                RUN busca-conta-cooperado (INPUT aux_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT aux_nrcpfcgc,
                                           INPUT aux_nrctrbnd,
                                           INPUT aux_nrsequen,
                                          OUTPUT aux_nrdconta,
                                          OUTPUT TABLE tt-erro).

                IF RETURN-VALUE = "NOK" THEN
                DO:
                    RUN gera-log-prcbnd (INPUT crapcop.nmrescop,
                                         INPUT par_cdoperad,
                                         INPUT tt-arq-imp.nmarquiv,
                                         INPUT 3,
                                    INPUT "Atualizacao Central de Risco BNDES",
                                         INPUT aux_nrdconta,
                                         INPUT aux_nrctrbnd,
                                         INPUT TABLE tt-erro).

                    NEXT.
                END.
                /* atualiza taxa efetiva anual */
                FIND crapebn WHERE crapebn.cdcooper = aux_cdcooper AND
                                   crapebn.nrdconta = aux_nrdconta AND
                                   crapebn.nrctremp = aux_nrctrbnd
                                   EXCLUSIVE-LOCK NO-ERROR.

                IF AVAIL crapebn THEN
                    ASSIGN crapebn.txefeanu = aux_txefeanu.


            END.
            ELSE
            IF SUBSTR(aux_setlinha, 1, 2) = "04" THEN
            DO:
                ASSIGN aux_nrctrbnd = INTE(SUBSTR(aux_setlinha, 43, 10))
                       aux_tpgarant = SUBSTR(aux_setlinha, 72, 4)
                       aux_cdtipgar = SUBSTR(aux_tpgarant, 3, 2)
                       aux_nrcpfcgc = DECI(SUBSTR(aux_setlinha, 07, 14))
                       aux_nrsequen = aux_nrsequen + 1.

                
                RUN busca-conta-cooperado (INPUT aux_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT aux_nrcpfcgc,
                                           INPUT aux_nrctrbnd,
                                           INPUT aux_nrsequen,
                                          OUTPUT aux_nrdconta,
                                          OUTPUT TABLE tt-erro).

                IF RETURN-VALUE = "NOK" THEN
                DO:
                    RUN gera-log-prcbnd (INPUT crapcop.nmrescop,
                                         INPUT par_cdoperad,
                                         INPUT tt-arq-imp.nmarquiv,
                                         INPUT 3,
                                    INPUT "Atualizacao Central de Risco BNDES",
                                         INPUT aux_nrdconta,
                                         INPUT aux_nrctrbnd,
                                         INPUT TABLE tt-erro).

                    NEXT.
                END.

                ASSIGN aux_idseqbem = 1.

                FIND LAST crapbpr WHERE crapbpr.cdcooper = aux_cdcooper AND
                                        crapbpr.nrdconta = aux_nrdconta AND
                                        crapbpr.tpctrpro = 95           AND
                                        crapbpr.nrctrpro = aux_nrctrbnd 
                                        NO-LOCK NO-ERROR.

                IF AVAIL crapbpr THEN
                    ASSIGN aux_idseqbem = aux_idseqbem + crapbpr.idseqbem.

                /* Arquivo SCR3040 - Anexo 12 - Garantias */ 

                /* Alienacao Fiduciaria (BENS) */
                IF SUBSTR(aux_tpgarant, 1, 2) = "04" THEN  
                DO:
                    ASSIGN aux_vlgarant = DECI(SUBSTR(aux_setlinha, 76, 17)) / 100.

                    IF aux_cdtipgar = "23" THEN
                        ASSIGN aux_dscatbem = "equipamentos".
                    ELSE
                    IF aux_cdtipgar = "24" THEN
                        ASSIGN aux_dscatbem = "veiculos".
                    ELSE
                    IF aux_cdtipgar = "26" THEN
                        ASSIGN aux_dscatbem = "imoveis residenciais".
                    ELSE
                    IF aux_cdtipgar = "27" THEN
                        ASSIGN aux_dscatbem = "outros imoveis".
                    ELSE
                    IF aux_cdtipgar = "99" THEN
                        ASSIGN aux_dscatbem = "outros".

                    CREATE crapbpr.
                    ASSIGN crapbpr.cdcooper = aux_cdcooper
                           crapbpr.nrdconta = aux_nrdconta
                           crapbpr.tpctrpro = 95
                           crapbpr.nrctrpro = aux_nrctrbnd
                           crapbpr.idseqbem = aux_idseqbem
                           crapbpr.dscatbem = aux_dscatbem
                           crapbpr.vlmerbem = aux_vlgarant.
                    VALIDATE crapbpr.

                END.
                ELSE
                /* Garantia fidejussória (AVAIS) */ 
                IF SUBSTR(aux_tpgarant, 1, 2) = "09" THEN
                DO:
                    ASSIGN aux_nrcpfcgc = DECI(SUBSTR(aux_setlinha, 102, 14))
                           aux_vlpergar = DECI(SUBSTR(aux_setlinha, 116, 5)).

                    IF aux_cdtipgar = "01" THEN
                        ASSIGN aux_dscatbem = "Avalista PF".
                    ELSE
                    IF aux_cdtipgar = "02" THEN
                        ASSIGN aux_dscatbem = "Avalista PJ".
                    ELSE
                    IF aux_cdtipgar = "03" THEN
                        ASSIGN aux_dscatbem = "Avalista PFE".
                    ELSE
                    IF aux_cdtipgar = "04" THEN
                        ASSIGN aux_dscatbem = "Avalista PJE".

                    CREATE crapbpr.
                    ASSIGN crapbpr.cdcooper = aux_cdcooper
                           crapbpr.nrdconta = aux_nrdconta
                           crapbpr.tpctrpro = 95
                           crapbpr.nrctrpro = aux_nrctrbnd
                           crapbpr.idseqbem = aux_idseqbem
                           crapbpr.dscatbem = aux_dscatbem
                           crapbpr.nrcpfbem = aux_nrcpfcgc
                           crapbpr.vlperbem = aux_vlpergar.
                    VALIDATE crapbpr.
                END.
            END.

        END.

        /* Logar se arquivo foi processado com sucesso ou com erros */
        FIND LAST tt-erro NO-LOCK NO-ERROR.

        IF AVAIL tt-erro THEN
            RUN gera-log-prcbnd (INPUT crapcop.nmrescop,
                                 INPUT par_cdoperad,
                                 INPUT tt-arq-imp.nmarquiv,
                                 INPUT 99,
                                 INPUT "Atualizacao Central de Risco BNDES",
                                 INPUT aux_nrdconta,
                                 INPUT aux_nrctrbnd,
                                 INPUT TABLE tt-erro).
        ELSE
            RUN gera-log-prcbnd (INPUT crapcop.nmrescop,
                                 INPUT par_cdoperad,
                                 INPUT tt-arq-imp.nmarquiv,
                                 INPUT 3,
                                 INPUT "Atualizacao Central de Risco BNDES",
                                 INPUT aux_nrdconta,
                                 INPUT aux_nrctrbnd,
                                 INPUT TABLE tt-erro).

        INPUT STREAM str_1 CLOSE.

        UNIX SILENT VALUE("mv " + tt-arq-imp.nmarquiv + " " + 
                          aux_nmarqdes + " 2> /dev/null").

    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE cria-lancamento:

    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdolote AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdbccxlt AS INTE NO-UNDO.
    DEF INPUT PARAM par_tplotmov AS INTE NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE NO-UNDO.
    DEF INPUT PARAM par_cdhistor AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE NO-UNDO.
    DEF INPUT PARAM par_vllanmto AS DECI NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
       
        /* Responsavel por alimentar registro de lote do lancamento */
        FIND craplot WHERE craplot.cdcooper = par_cdcooper AND
                           craplot.dtmvtolt = par_dtmvtolt AND
                           craplot.cdagenci = par_cdagenci AND
                           craplot.cdbccxlt = par_cdbccxlt AND
                           craplot.nrdolote = par_nrdolote
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
       
        IF  NOT AVAIL craplot THEN
            DO:
                IF  LOCKED craplot THEN
                    DO:
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
                ELSE
                    DO:
                         CREATE craplot.
                         ASSIGN craplot.cdcooper = par_cdcooper
                                craplot.dtmvtolt = par_dtmvtolt
                                craplot.cdagenci = par_cdagenci
                                craplot.cdbccxlt = par_cdbccxlt
                                craplot.nrdolote = par_nrdolote
                                craplot.tplotmov = par_tplotmov
                                craplot.cdoperad = par_cdoperad.
                         VALIDATE craplot.
                    END.
            END.
               
        ASSIGN craplot.vlinfodb = craplot.vlinfodb + par_vllanmto
               craplot.vlcompdb = craplot.vlcompdb + par_vllanmto
               craplot.qtinfoln = craplot.qtinfoln + 1
               craplot.qtcompln = craplot.qtcompln + 1
               craplot.nrseqdig = craplot.nrseqdig + 1.

        /* Responsavel por criar lancamento em conta corrente */
        FIND FIRST craplcm WHERE craplcm.cdcooper = par_cdcooper AND
                                 craplcm.nrdconta = par_nrdconta AND
                                 craplcm.dtmvtolt = par_dtmvtolt AND
                                 craplcm.cdhistor = par_cdhistor AND
                                 craplcm.nrdocmto = craplot.nrseqdig
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF  NOT AVAIL craplcm THEN
            DO:
                IF  LOCKED craplcm THEN
                    DO: 
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
                ELSE
                    DO:
                        CREATE craplcm.
                        ASSIGN craplcm.cdcooper = par_cdcooper
                               craplcm.dtmvtolt = craplot.dtmvtolt
                               craplcm.cdagenci = par_cdagenci
                               craplcm.cdbccxlt = par_cdbccxlt
                               craplcm.nrdolote = par_nrdolote
                               craplcm.dtrefere = craplot.dtmvtolt
                               craplcm.hrtransa = TIME
                               craplcm.cdoperad = par_cdoperad
                               craplcm.nrdconta = par_nrdconta
                               craplcm.nrdctabb = par_nrdconta
                               craplcm.nrseqdig = craplot.nrseqdig
                               craplcm.nrsequni = craplot.nrseqdig
                               craplcm.nrdocmto = craplot.nrseqdig
                               craplcm.cdhistor = par_cdhistor
                               craplcm.vllanmto = par_vllanmto.
                        VALIDATE craplcm.

                    END.
            END.
        ELSE
            DO:
                ASSIGN aux_cdcritic = 92.

                RUN gera_erro (INPUT aux_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1, 
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

                RETURN "NOK".
            END.

        LEAVE.

    END. /* fim do while true */

    RETURN "OK".

END PROCEDURE.

PROCEDURE busca-conta-cooperado:

    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrcpfcgc AS DECI NO-UNDO.
    DEF INPUT PARAM par_nrctremp AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrsequen AS INTE NO-UNDO.

    DEF OUTPUT PARAM par_nrdconta AS INTE NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN par_nrdconta = 0.

    FOR EACH crapass WHERE crapass.cdcooper = par_cdcooper AND
                           crapass.nrcpfcgc = par_nrcpfcgc NO-LOCK,
        FIRST crapebn WHERE crapebn.cdcooper = crapass.cdcooper AND
                            crapebn.nrdconta = crapass.nrdconta AND
                            crapebn.nrctremp = par_nrctremp NO-LOCK:

        ASSIGN par_nrdconta = crapass.nrdconta.
                                    
    END.

    IF par_nrdconta = 0 THEN
    DO:
        ASSIGN aux_cdcritic = 356. 

        RUN gera_erro (INPUT aux_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT par_nrsequen, 
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE gera-log-prcbnd:

    DEF INPUT PARAM par_nmrescop AS CHAR NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR NO-UNDO.
    DEF INPUT PARAM par_nmarquiv AS CHAR NO-UNDO.
    DEF INPUT PARAM par_flgtpope AS INTE NO-UNDO.
    DEF INPUT PARAM par_tipopera AS CHAR NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrctremp AS DECI NO-UNDO.
    DEF INPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nmarquiv AS CHAR NO-UNDO.

    ASSIGN aux_nmarquiv = SUBSTR(par_nmarquiv, 
                                 INDEX(par_nmarquiv, "recepcao/") + 9,
                                 LENGTH(par_nmarquiv) - 
                                        R-INDEX(par_nmarquiv, "/")).

    FIND LAST tt-erro NO-LOCK NO-ERROR.

    IF par_flgtpope = 1 OR par_flgtpope = 3 THEN
    DO:
        IF AVAIL tt-erro THEN
        DO:
            UNIX SILENT VALUE("echo " +
                              STRING(TODAY,"99/99/9999") + " "               +
                              STRING(TIME,"HH:MM:SS") + "' ---> '"           +
                              " Operador " + par_cdoperad + "' - '"          +
                              par_tipopera + "' - '"                         +
                              UPPER(par_nmrescop) + "' - '"                  +
                              "Erro: '" + tt-erro.dscritic + "'"             +
                              " Conta: " + STRING(par_nrdconta)              +
                              " Contrato: " + STRING(par_nrctremp)           +
                              " >> /usr/coop/cecred/log/prcbnd.log").
        END.
        ELSE
        DO:
            UNIX SILENT VALUE("echo " +
                              STRING(TODAY,"99/99/9999") + " "               +
                              STRING(TIME,"HH:MM:SS") + "' ---> '"           +
                              " Operador " + par_cdoperad + "' - '"          +
                              par_tipopera + "' - '"                         +
                              UPPER(par_nmrescop) + "' - '"                  +
                              "Arquivo processado com sucesso '- '"          +
                              "Arquivo: " + aux_nmarquiv                     +
                              " >> /usr/coop/cecred/log/prcbnd.log").
        END.
    END.
    ELSE
    IF par_flgtpope = 2 THEN
    DO:
        IF AVAIL tt-erro THEN
        DO:
            UNIX SILENT VALUE("echo " +
                              STRING(TODAY,"99/99/9999") + " "               +
                              STRING(TIME,"HH:MM:SS") + "' ---> '"           +
                              " Operador " + par_cdoperad + "' - '"          +
                              par_tipopera + "' - '"                         +
                              UPPER(par_nmrescop) + "' - '"                  +
                              "Erro: '" + tt-erro.dscritic + "'"             +
                              " Conta: " + STRING(par_nrdconta)              +
                              " Contrato: " + STRING(par_nrctremp)           +
                              " >> /usr/coop/cecred/log/prcbnd.log").
        END.
        ELSE
        DO:
            UNIX SILENT VALUE("echo " +
                              STRING(TODAY,"99/99/9999") + " "               +
                              STRING(TIME,"HH:MM:SS") + "' ---> '"           +
                              " Operador " + par_cdoperad + "' - '"          +
                              par_tipopera + "' - '"                         +
                              UPPER(par_nmrescop) + "' - '"                  +
                              "Conta: " + STRING(par_nrdconta)               +
                              " Contrato: " + STRING(par_nrctremp)           +
                              " >> /usr/coop/cecred/log/prcbnd.log").
        END.
    END.
    ELSE
    IF par_flgtpope = 99 THEN
    DO:
        UNIX SILENT VALUE("echo " +
                          STRING(TODAY,"99/99/9999") + " "               +
                          STRING(TIME,"HH:MM:SS") + "' ---> '"           +
                          " Operador " + par_cdoperad + "' - '"          +
                          par_tipopera + "' - '"                         +
                          UPPER(par_nmrescop) + "' - '"                  +
                          "Arquivo processado com erro '- '"             +
                          "Arquivo: " + aux_nmarquiv                     +
                          " >> /usr/coop/cecred/log/prcbnd.log").
    END.

END PROCEDURE.