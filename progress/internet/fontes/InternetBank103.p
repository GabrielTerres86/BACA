/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank103.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Jonathan C. da Silva - RKAM
   Data    : 26/08/2014                        Ultima atualizacao: 07/03/2017)

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Consultas de TEDs/TECs - Chamado: 161899
   
   Alteracoes: 29/12/2014 - Adicionado param de entrada aux_cdhistor, consulta
                            de DOC e Transferencia. (Jorge/Elton) - SD 229245
                            
               16/03/2015 - Ajuste para incluir historico "0". (Jorge/Elton)
               
               19/08/2015 - Na chamada da procedure obtem-log-cecred, incluir
                            novo parametro - Melhoria Gestao de TEDs/TECs - 85
                            (Lucas Ranghetti)
                             
               12/11/2015 - Na chamada da procedure obtem-log-cecred, incluir
                            novo parametro inestcri, projeto Estado de Crise
                            (Jorge/Andrino)              

               27/09/2016 - M211 - Envio do parado cdifconv na chamada da 
                            obtem-log-cecred (Jonata-RKAM)                  
                            
               07/03/2017 - Inclusao do campo dsprotoc para TEDs.
                            PRJ335 - OFSSA(Odirlei-AMcom)
 .............................................................................*/
    
CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0050tt.i }
{ sistema/generico/includes/var_oracle.i   }

DEF VAR h-b1wgen0050 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dsmsgenv AS CHAR                                           NO-UNDO.
DEF VAR aux_dsmsgrec AS CHAR                                           NO-UNDO.

DEF  INPUT PARAM par_cdcooper LIKE crapcob.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapcob.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_nrsequen AS INT                                   NO-UNDO.
DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF  INPUT PARAM par_dtiniper AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_dtfimper AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_qtregpag AS INT                                   NO-UNDO.
DEF  INPUT PARAM par_cdhistor AS INT                                   NO-UNDO.
DEF  INPUT PARAM par_vllanmto AS DEC                                   NO-UNDO.
DEF  INPUT PARAM par_nrdocmto AS INT                                   NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF TEMP-TABLE tt-bkp-logspb-detalhe LIKE tt-logspb-detalhe
    FIELD dscopera AS CHAR.

EMPTY TEMP-TABLE tt-logspb-detalhe.
EMPTY TEMP-TABLE tt-bkp-logspb-detalhe.

ASSIGN xml_dsmsgerr = "".

RUN sistema/generico/procedures/b1wgen0050.p PERSISTENT SET h-b1wgen0050.

IF  NOT VALID-HANDLE(h-b1wgen0050)  THEN
    ASSIGN xml_dsmsgerr = "<dsmsgerr>Handle invalido para BO b1wgen0050." +
                          "</dsmsgerr>".  

IF  xml_dsmsgerr <> ""  THEN
    DO:
        DELETE PROCEDURE h-b1wgen0050.

        RETURN "NOK".
    END.

/* TED TEC */
IF CAN-DO("0,519,555,578,799,958",STRING(par_cdhistor)) THEN
DO:
    
      /* Buscar TED Enviada */
      RUN busca_protocolo(INPUT 9).

      FIND FIRST tt-bkp-logspb-detalhe 
      NO-LOCK NO-ERROR.
      
      IF NOT AVAILABLE tt-bkp-logspb-detalhe THEN
      DO: 
      RUN transacao(INPUT 1).

      IF  RETURN-VALUE <> "OK" THEN
          ASSIGN aux_dsmsgenv = "NOK".
      
      FOR EACH tt-logspb-detalhe NO-LOCK:
          CREATE tt-bkp-logspb-detalhe.
          BUFFER-COPY tt-logspb-detalhe TO tt-bkp-logspb-detalhe.
              ASSIGN dscopera = "578".
      END.
      
      
      /* Buscar TED Recebida */
      RUN transacao(INPUT 2).
      
      IF  RETURN-VALUE <> "OK"   THEN
          ASSIGN aux_dsmsgrec = "NOK".
                      
      FOR EACH tt-logspb-detalhe NO-LOCK:
          CREATE tt-bkp-logspb-detalhe.
          BUFFER-COPY tt-logspb-detalhe TO tt-bkp-logspb-detalhe.
              ASSIGN dscopera = "555".
      END.
      
      IF aux_dsmsgenv = "NOK" AND aux_dsmsgrec = "NOK" THEN
          RETURN "NOK".
      END. 

END.
/* DOC */
ELSE IF CAN-DO("103,355,575", STRING(par_cdhistor)) THEN
DO:
    RUN busca-detalhe-doc IN h-b1wgen0050(INPUT par_cdcooper,
                                          INPUT 90,
                                          INPUT 900,
                                          INPUT 996,
                                          INPUT "INTERNETBANK",
                                          INPUT 3,
                                          INPUT par_nrdconta,
                                          INPUT par_dtiniper,
                                          INPUT par_cdhistor,
                                          INPUT par_nrdocmto,
                                          INPUT par_vllanmto,
                                         OUTPUT TABLE tt-logspb-detalhe,
                                         OUTPUT TABLE tt-erro).
    IF  RETURN-VALUE = "NOK"  THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
        
        IF  AVAILABLE tt-erro  THEN
            aux_dscritic = tt-erro.dscritic.
        ELSE
            aux_dscritic = "Nao foi possivel carregar os detalhes.".
            
        xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  

        RETURN "NOK".
    END.

    FOR EACH tt-logspb-detalhe NO-LOCK:
        CREATE tt-bkp-logspb-detalhe.
        BUFFER-COPY tt-logspb-detalhe TO tt-bkp-logspb-detalhe.
        ASSIGN tt-bkp-logspb-detalhe.dscopera = STRING(par_cdhistor).
    END.
END.
/* Transferencia */
ELSE IF CAN-DO("375,377,537,539,1009,1011,1014,1015", STRING(par_cdhistor)) THEN
DO: 
    RUN busca-detalhe-transferencia IN h-b1wgen0050(
                                    INPUT par_cdcooper,
                                    INPUT 90,
                                    INPUT 900,
                                    INPUT 996,
                                    INPUT "INTERNETBANK",
                                    INPUT 3,
                                    INPUT par_nrdconta,
                                    INPUT par_dtiniper,
                                    INPUT par_cdhistor,
                                    INPUT par_nrdocmto,
                                    INPUT par_vllanmto,
                                   OUTPUT TABLE tt-logspb-detalhe,
                                   OUTPUT TABLE tt-erro).
    IF  RETURN-VALUE = "NOK"  THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
        
        IF  AVAILABLE tt-erro  THEN
            aux_dscritic = tt-erro.dscritic.
        ELSE
            aux_dscritic = "Nao foi possivel carregar os detalhes.".
            
        xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  

        RETURN "NOK".
    END.

    FOR EACH tt-logspb-detalhe NO-LOCK:
        CREATE tt-bkp-logspb-detalhe.
        BUFFER-COPY tt-logspb-detalhe TO tt-bkp-logspb-detalhe.
        ASSIGN tt-bkp-logspb-detalhe.dscopera = STRING(par_cdhistor).
    END.
END.
ELSE
DO: 
    ASSIGN aux_dscritic = "Historico nao encontrado."
           xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  

    RETURN "NOK".
END.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = '<EXTRATO>'.

FOR EACH tt-bkp-logspb-detalhe NO-LOCK BY tt-bkp-logspb-detalhe.dttransa:

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<DADOS><nrseqlog>" +
                                    TRIM(STRING(tt-bkp-logspb-detalhe.nrseqlog)) +
                                    "</nrseqlog><cdbandst>" + 
                                    TRIM(STRING(tt-bkp-logspb-detalhe.cdbandst)) +
                                    "</cdbandst><cdagedst>" + 
                                    TRIM(STRING(tt-bkp-logspb-detalhe.cdagedst)) +
                                    "</cdagedst><nrctadst>" + 
                                    TRIM(STRING(tt-bkp-logspb-detalhe.nrctadst, 
                                                "xxxxxxx.xxx.xxx-x")) +
                                    "</nrctadst><dsnomdst>" + 
                                    TRIM(REPLACE(tt-bkp-logspb-detalhe.dsnomdst, "&", "")) +
                                    "</dsnomdst><dscpfdst>" + 
                                    TRIM(STRING(tt-bkp-logspb-detalhe.dscpfdst)) +
                                    "</dscpfdst><cdbanrem>" + 
                                    TRIM(STRING(tt-bkp-logspb-detalhe.cdbanrem)) +
                                    "</cdbanrem><cdagerem>" + 
                                    TRIM(STRING(tt-bkp-logspb-detalhe.cdagerem)) +
                                    "</cdagerem><nrctarem>" + 
                                    TRIM(STRING(tt-bkp-logspb-detalhe.nrctarem,
                                                "xxxxxxx.xxx.xxx-x")) +
                                    "</nrctarem><dsnomrem>" + 
                                    TRIM(REPLACE(tt-bkp-logspb-detalhe.dsnomrem, "&", "")) +
                                    "</dsnomrem><dscpfrem>" + 
                                    TRIM(STRING(tt-bkp-logspb-detalhe.dscpfrem)) +
                                    "</dscpfrem><dttransa>" + 
                                    TRIM(STRING(tt-bkp-logspb-detalhe.dttransa)) +
                                    "</dttransa><hrtransa>" + 
                                    TRIM(tt-bkp-logspb-detalhe.hrtransa) +
                                    "</hrtransa><vltransa>" + 
                                    TRIM(STRING(tt-bkp-logspb-detalhe.vltransa,
                                                "zz,zzz,zz9.99-")) +
                                    "</vltransa><dsmotivo>" + 
                                    TRIM(tt-bkp-logspb-detalhe.dsmotivo) +
                                    "</dsmotivo><dstransa>" + 
                                    TRIM(tt-bkp-logspb-detalhe.dstransa) +
                                    "</dstransa><dsorigem>" + 
                                    TRIM(tt-bkp-logspb-detalhe.dsorigem) +
                                    "</dsorigem><cdagenci>" + 
                                    TRIM(STRING(tt-bkp-logspb-detalhe.cdagenci)) +
                                    "</cdagenci><nrdcaixa>" + 
                                    TRIM(STRING(tt-bkp-logspb-detalhe.nrdcaixa)) +
                                    "</nrdcaixa><cdoperad>" + 
                                    TRIM(tt-bkp-logspb-detalhe.cdoperad) +
                                    "</cdoperad><dscopera>" + 
                                    TRIM(tt-bkp-logspb-detalhe.dscopera) +
                                    "</dscopera><nrsequen>" + 
                                    TRIM(STRING(tt-bkp-logspb-detalhe.nrsequen)) +
                                    "</nrsequen><dsprotoc>" +
                                    TRIM(tt-bkp-logspb-detalhe.dsprotoc) +
                                    "</dsprotoc></DADOS>".

END. /** Fim do FOR EACH tt-bkp-logspb-detalhe **/

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = '</EXTRATO>'.
                  
DELETE PROCEDURE h-b1wgen0050.

RETURN "OK".

PROCEDURE transacao:
    DEF INPUT PARAM par_numedlog AS INT NO-UNDO.
  
    RUN obtem-log-cecred IN h-b1wgen0050 (INPUT par_cdcooper,
                                          INPUT 90,
                                          INPUT 900,
                                          INPUT "996",
                                          INPUT "INTERNETBANK",
                                          INPUT 0,
                                          INPUT par_dtiniper,
                                          INPUT par_dtfimper,
                                          INPUT par_numedlog,
                                          INPUT "P",
                                          INPUT par_nrdconta,
                                          INPUT par_nrsequen,
                                          INPUT 0,
                                          INPUT par_qtregpag,
                                          INPUT 0,  /* inestcri 0 Nao, 1 Sim*/
                                          INPUT 3,  /* IF da TED - Todas */
                                          INPUT 0,  /* par_vlrdated */
                                         OUTPUT TABLE tt-logspb,
                                         OUTPUT TABLE tt-logspb-detalhe,
                                         OUTPUT TABLE tt-logspb-totais,
                                         OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  AVAILABLE tt-erro  THEN
                aux_dscritic = tt-erro.dscritic.
            ELSE
                aux_dscritic = "Nao foi possivel carregar o extrato.".
                
            xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  

            RETURN "NOK".
        END.

        RETURN "OK".

END.

PROCEDURE busca_protocolo:
  DEF INPUT PARAM par_cdtippro AS INT NO-UNDO.
  
  DEF VAR aux_dstiptra AS CHAR        NO-UNDO.  
  DEF VAR aux_nmprintl AS CHAR        NO-UNDO.  
  DEF VAR aux_dsbandst AS CHAR        NO-UNDO.  
  DEF VAR aux_cdagedst AS CHAR        NO-UNDO.  
  DEF VAR aux_nrctadst AS CHAR        NO-UNDO.  
  DEF VAR aux_cdispbif AS CHAR        NO-UNDO.  
  DEF VAR aux_dsnomdst AS CHAR        NO-UNDO.  
  DEF VAR aux_dscpfdst AS CHAR        NO-UNDO.  
  DEF VAR aux_dstransf AS CHAR        NO-UNDO.  
  DEF VAR aux_cdcritic AS INT         NO-UNDO.

{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    

RUN STORED-PROCEDURE pc_busca_protocolo_wt
    aux_handproc = PROC-HANDLE NO-ERROR
                            (INPUT par_cdcooper,
                             INPUT par_dtiniper,
                             INPUT par_nrdconta,
                             INPUT par_cdtippro,
                             INPUT 3, /*par_idorigem*/
                             INPUT STRING(par_nrdocmto),
                             OUTPUT 0,
                             OUTPUT "").

CLOSE STORED-PROC pc_busca_protocolo_wt
      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

ASSIGN aux_cdcritic = 0
       aux_dscritic = ""
       aux_cdcritic = pc_busca_protocolo_wt.pr_cdcritic 
                          WHEN pc_busca_protocolo_wt.pr_cdcritic <> ?
       aux_dscritic = pc_busca_protocolo_wt.pr_dscritic
                          WHEN pc_busca_protocolo_wt.pr_dscritic <> ?.

IF aux_cdcritic <> 0   OR
   aux_dscritic <> ""  THEN
   DO: 
      IF aux_dscritic = "" THEN
         DO:
            FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic 
                               NO-LOCK NO-ERROR.

            IF AVAIL crapcri THEN
               ASSIGN aux_dscritic = crapcri.dscritic.
            ELSE
               ASSIGN aux_dscritic = "Nao foi possivel encontrar o protocolo.".

         END.
      
      ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                            "</dsmsgerr>".  
      RETURN "NOK".
       
   END.
   
FIND FIRST crapass 
     WHERE crapass.cdcooper = par_cdcooper
       AND crapass.nrdconta = par_nrdconta
       NO-LOCK NO-ERROR.     
   
FOR EACH wt_protocolo NO-LOCK:

    IF wt_protocolo.cdtippro = 9 THEN /*TED*/
      DO:
        ASSIGN aux_dstiptra = ENTRY(1,wt_protocolo.dsinform[1],"#")
               aux_nmprintl = ENTRY(1,wt_protocolo.dsinform[2],"#")
               aux_dsbandst = ENTRY(2,wt_protocolo.dsinform[2],"#")
               aux_cdagedst = ENTRY(3,wt_protocolo.dsinform[2],"#")
               aux_nrctadst = TRIM(REPLACE(ENTRY(4,wt_protocolo.dsinform[2],"#"),'.',''))
               aux_cdispbif = ENTRY(5,wt_protocolo.dsinform[2],"#")
               aux_dsnomdst = ENTRY(1,wt_protocolo.dsinform[3],"#")
               aux_dscpfdst = ENTRY(2,wt_protocolo.dsinform[3],"#")
               aux_dstransf = ENTRY(3,wt_protocolo.dsinform[3],"#").
                       
      END.
   

    CREATE tt-bkp-logspb-detalhe.   
    ASSIGN tt-bkp-logspb-detalhe.nrseqlog = 0
           tt-bkp-logspb-detalhe.cdbandst = INT(TRIM(ENTRY(1,aux_dsbandst,'-')))
           tt-bkp-logspb-detalhe.cdagedst = INT(TRIM(ENTRY(1,aux_cdagedst,'-')))
           tt-bkp-logspb-detalhe.nrctadst = STRING(INT(aux_nrctadst), "99999999999999")
           tt-bkp-logspb-detalhe.dsnomdst = aux_dsnomdst
           tt-bkp-logspb-detalhe.dscpfdst = DEC(TRIM(REPLACE(REPLACE(REPLACE(aux_dscpfdst,'.',''),'-',''),'/','')))  
           tt-bkp-logspb-detalhe.cdbanrem = wt_protocolo.cdbcoctl
           tt-bkp-logspb-detalhe.cdagerem = wt_protocolo.cdagectl
           tt-bkp-logspb-detalhe.nrctarem = STRING(par_nrdconta,"99999999999999")
           tt-bkp-logspb-detalhe.dsnomrem = aux_nmprintl
           tt-bkp-logspb-detalhe.dscpfrem = crapass.nrcpfcgc
           tt-bkp-logspb-detalhe.hrtransa = string(wt_protocolo.hrautent)
           tt-bkp-logspb-detalhe.vltransa = wt_protocolo.vldocmto
           tt-bkp-logspb-detalhe.dsmotivo = ""
           tt-bkp-logspb-detalhe.dstransa = ""
           tt-bkp-logspb-detalhe.dsorigem = ""
           tt-bkp-logspb-detalhe.cdagenci = 0
           tt-bkp-logspb-detalhe.nrdcaixa = 0
           tt-bkp-logspb-detalhe.cdoperad = ""
           tt-bkp-logspb-detalhe.dttransa = wt_protocolo.dttransa
           tt-bkp-logspb-detalhe.nrsequen = wt_protocolo.nrseqaut
           tt-bkp-logspb-detalhe.cdisprem = 0
           tt-bkp-logspb-detalhe.cdispdst = 0
           tt-bkp-logspb-detalhe.cdtiptra = 3 /*TED*/
           tt-bkp-logspb-detalhe.dstiptra = aux_dstiptra
           tt-bkp-logspb-detalhe.nmevento = ""
           tt-bkp-logspb-detalhe.nrctrlif = ""
           tt-bkp-logspb-detalhe.dscopera = STRING(par_cdhistor)
           tt-bkp-logspb-detalhe.dsprotoc = wt_protocolo.dsprotoc.
           
END.    

    
    
    
    
    
    

END.

/*............................................................................*/
