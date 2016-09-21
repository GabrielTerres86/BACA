/*..............................................................................

   Programa: b1wgen0028.i
   Autor   : Guilherme
   Data    : Junho/2008                        Ultima atualizacao:   /  /    

   Objetivo  : Include para criacao da tabela de avais do contrato para geracao
               da nota promissoria.

   Alteracoes:

..............................................................................*/
    
    IF  crawcrd.nrctaav1 <> 0  THEN
        DO:
            CREATE tt-avais-ctr.
            
            FIND crabass WHERE crabass.cdcooper = par_cdcooper     AND
                               crabass.nrdconta = crawcrd.nrctaav1 
                               NO-LOCK NO-ERROR.
                                       
            
            IF  AVAILABLE crabass   THEN 
                DO:
                   IF  crabass.inpessoa = 1 THEN
                       ASSIGN tt-avais-ctr.cpfavali =
                                  STRING(crabass.nrcpfcgc,"99999999999")
                              tt-avais-ctr.cpfavali =
                                          STRING(tt-avais-ctr.cpfavali,
                                          "    xxx.xxx.xxx-xx")
                              tt-avais-ctr.cpfavali =
                                      "C.P.F. " + 
                                      STRING(tt-avais-ctr.cpfavali,"x(23)") +
                                      STRING(crabass.nrdconta,"zzzz,zz9,9").
                                                
                   ELSE
                       ASSIGN tt-avais-ctr.cpfavali =
                                  STRING(crabass.nrcpfcgc,"99999999999999")
                               tt-avais-ctr.cpfavali =
                                        STRING(tt-avais-ctr.cpfavali,
                                        "xx.xxx.xxx/xxxx-xx")
                               tt-avais-ctr.cpfavali =
                                        "CNPJ " + 
                                        STRING(tt-avais-ctr.cpfavali,"x(25)") +
                                        STRING(crabass.nrdconta,"zzzz,zz9,9").
                           
                                             
                   FIND crapenc WHERE crapenc.cdcooper = par_cdcooper       AND
                                      crapenc.nrdconta = crabass.nrdconta  AND
                                      crapenc.idseqttl = 1                 AND
                                      crapenc.cdseqinc = 1 NO-LOCK NO-ERROR.
                  
                   ASSIGN tt-avais-ctr.nmdavali = crabass.nmprimtl
                          tt-avais-ctr.nmconjug = IF crawcrd.nmcjgav1 = "" 
                                               THEN FILL("_",40)
                                            ELSE crawcrd.nmcjgav1
                          tt-avais-ctr.nrcpfcjg = IF crawcrd.dscfcav1 = ""
                                               THEN FILL("_",40)
                                            ELSE crawcrd.dscfcav1
                          tt-avais-ctr.dsendav1 =
                                            SUBSTRING(crapenc.dsendere,1,32)
                                            + " " +
                                            TRIM(STRING(crapenc.nrendere,
                                                        "zzz,zzz" ))
                          tt-avais-ctr.dsendav2 = TRIM(crapenc.nmbairro)
                          tt-avais-ctr.dsendav3 = STRING(crapenc.nrcepend,"99999,999") +
                                                  " - " +
                                                  TRIM(crapenc.nmcidade) + "/" +
                                                  crapenc.cdufende.
                END.         
            ELSE
                ASSIGN tt-avais-ctr.nmdavali = "*** NAO CADASTRADO ***"
                       tt-avais-ctr.nrcpfcjg = FILL("-",40)
                       tt-avais-ctr.nmconjug = FILL("_",40)
                       tt-avais-ctr.nrcpfcjg = FILL("_",40)
                       tt-avais-ctr.dsendav1 = FILL("_",40)
                       tt-avais-ctr.dsendav2 = FILL("_",40)
                       tt-avais-ctr.dsendav3 = FILL("_",40).            
        END.
        
    IF  crawcrd.nrctaav2 <> 0  THEN
        DO:
            CREATE tt-avais-ctr.
            
            FIND crabass WHERE crabass.cdcooper = par_cdcooper     AND
                               crabass.nrdconta = crawcrd.nrctaav2 
                               NO-LOCK NO-ERROR.
            
            IF  AVAILABLE crabass   THEN 
                DO:
                   IF  crabass.inpessoa = 1 THEN
                       ASSIGN tt-avais-ctr.cpfavali =
                                  STRING(crabass.nrcpfcgc,"99999999999")
                              tt-avais-ctr.cpfavali =
                                          STRING(tt-avais-ctr.cpfavali,
                                          "    xxx.xxx.xxx-xx")
                              tt-avais-ctr.cpfavali =
                                      "C.P.F. " + 
                                      STRING(tt-avais-ctr.cpfavali,"x(23)") +
                                      STRING(crabass.nrdconta,"zzzz,zz9,9").
                                                
                   ELSE
                       ASSIGN tt-avais-ctr.cpfavali =
                                  STRING(crabass.nrcpfcgc,"99999999999999")
                               tt-avais-ctr.cpfavali =
                                          STRING(tt-avais-ctr.cpfavali,
                                          "xx.xxx.xxx/xxxx-xx")
                               tt-avais-ctr.cpfavali =
                                      "CNPJ " + 
                                      STRING(tt-avais-ctr.cpfavali,"x(25)") +
                                      STRING(crabass.nrdconta,"zzzz,zz9,9").
                           
                   FIND crapenc WHERE crapenc.cdcooper = par_cdcooper      AND
                                      crapenc.nrdconta = crabass.nrdconta  AND
                                      crapenc.idseqttl = 1                 AND
                                      crapenc.cdseqinc = 1 NO-LOCK NO-ERROR.
                  
                   ASSIGN tt-avais-ctr.nmdavali = crabass.nmprimtl
                          tt-avais-ctr.nmconjug = IF crawcrd.nmcjgav1 = "" 
                                               THEN FILL("_",40)
                                            ELSE crawcrd.nmcjgav1
                          tt-avais-ctr.nrcpfcjg = IF crawcrd.dscfcav1 = ""
                                               THEN FILL("_",40)
                                            ELSE crawcrd.dscfcav1
                          tt-avais-ctr.dsendav1 =
                                            SUBSTRING(crapenc.dsendere,1,32)
                                            + " " +
                                            TRIM(STRING(crapenc.nrendere,
                                                        "zzz,zzz" ))
                          tt-avais-ctr.dsendav2 = TRIM(crapenc.nmbairro)
                          tt-avais-ctr.dsendav3 = STRING(crapenc.nrcepend,"99999,999") +
                                                  " - " +
                                                  TRIM(crapenc.nmcidade) + "/" +
                                                  crapenc.cdufende.
                       
                END.         
            ELSE
                ASSIGN tt-avais-ctr.nmdavali = "*** NAO CADASTRADO ***"
                       tt-avais-ctr.nrcpfcjg = FILL("-",40)
                       tt-avais-ctr.nmconjug = FILL("_",40)
                       tt-avais-ctr.nrcpfcjg = FILL("_",40)
                       tt-avais-ctr.dsendav1 = FILL("_",40)
                       tt-avais-ctr.dsendav2 = FILL("_",40)
                       tt-avais-ctr.dsendav3 = FILL("_",40).
        END.

    FOR EACH crapavt WHERE crapavt.cdcooper = par_cdcooper     AND
                           crapavt.nrdconta = crawcrd.nrdconta AND
                           crapavt.nrctremp = crawcrd.nrctrcrd AND
                           crapavt.tpctrato = 4                NO-LOCK:
        
        CREATE tt-avais-ctr.
        ASSIGN tt-avais-ctr.nmdavali = crapavt.nmdavali
               tt-avais-ctr.cpfavali = "CPF: " + STRING(STRING(crapavt.nrcpfcgc,
                                       "99999999999"),"xxx.xxx.xxx-xx")
               tt-avais-ctr.dsdocava = crapavt.tpdocava + ": " + 
                                       crapavt.nrdocava
               tt-avais-ctr.dsendav1 = IF  crapavt.nrendere > 0  THEN 
                                           SUBSTR(crapavt.dsendres[1],1,32) +
                                           " " +
                                           STRING(crapavt.nrendere)
                                       ELSE
                                           crapavt.dsendres[1]
               tt-avais-ctr.dsendav2 = crapavt.dsendres[2]
               tt-avais-ctr.dsendav3 = STRING(crapavt.nrcepend,"99999,999") + 
                                       " - " +
                                       TRIM(crapavt.nmcidade) + "/" +
                                       crapavt.cdufresd.       

        IF  crapavt.nmconjug <> ""  THEN
            ASSIGN tt-avais-ctr.nmconjug = crapavt.nmconjug.
        ELSE 
            ASSIGN tt-avais-ctr.nmconjug = FILL("_",40).
               
        IF  crapavt.nrcpfcjg <> 0  THEN    
            ASSIGN tt-avais-ctr.nrcpfcjg = "CPF: " +
                                           STRING(STRING(crapavt.nrcpfcjg,
                                           "99999999999"),"xxx.xxx.xxx-xx").
        ELSE       
            ASSIGN tt-avais-ctr.nrcpfcjg = "CPF: " + FILL("_",35).
                   
        IF  crapavt.tpdoccjg <> "" AND crapavt.nrdoccjg <> ""  THEN    
            ASSIGN tt-avais-ctr.dsdoccjg = crapavt.tpdoccjg + ": " +
                                           crapavt.nrdoccjg.
        ELSE  
            ASSIGN tt-avais-ctr.dsdoccjg = "CI: " + FILL("_",36).

    END. /** Fim do FOR EACH crapavt **/
    
/* ************************************************************************** */
