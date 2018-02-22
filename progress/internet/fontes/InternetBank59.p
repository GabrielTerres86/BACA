/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank59.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Marco/2009                        Ultima atualizacao: 20/03/2017

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Carregar dados para relatorios de cobranca 
   
   Alteracoes: 16/07/2009 - Retornar campo "dsdoccop" no xml (David).
   
               21/06/2011 - Incluido dois parametros na procedure
                            consultar-boleto (Rafael)
                            
               15/07/2011 - Alterado limites de qtd de dados na geracao de XML
                          - Adicionado param de entrada flgregis (Jorge).
                          
               20/07/2011 - Adicionado idrelato 5, relatorio de cabranca
                            registrada assim como seu xml(Jorge).
                            
               27/02/2013 - Ajuste em ordenacao da tt-consulta-blt, retirado
                            "BY" do "FOR EACH" deixando na sequencia da 
                            temp-table. (46075 - Jorge) 
                            
               18/10/2013 - Adicionado campo "origem" no XML para definir de
                            onde foi comandado a instrução nos relatórios da
                            cobrança com registro (Rafael).
                            
               11/09/2014 - Adicionado campo "dtcredit" no XML para retornar
                            a data do credito quando titulo liquidado nos 
                            relat. da cobrança c/ registro - Lib Out/14 (Rafael)
               
               14/01/2015 - Inclusão de novas tags para o 4-relatorio cedente,
                            para montagem do relatorio de titulo descontados
                            (Odirlei-AMcom)             
                            
               04/05/2015 - Incluido tag de descricao do emitente. 
                            (Projeto DP 219 - Cooperativa Emite e Expede - Reinert)
               
               07/05/2015 - Adicionado data do documento para o relatorio de 
                            beneficiarios, Movimento de Cobranca Com Registro
                            e Movimento de liquidacoes SD 257997 (Kelvin).
                            
               04/08/2016 - Adicionado tratamento para envio de relatorio de 
                            movimento de cobranca por email para convenios com
                            inenvcob = 2 (envio de arquivo por FTP) (Reinert).
                            
			   11/10/2016 - Ajustes realizado para inserir parte do campo nosso numero
							ao relatório de  movimento de cobranca com registro,
							conforme solicitado no chamado 496856 (Kelvin).
                            
               17/10/2016 - Inclusao Relatorio de Envio de SMS.    
	                          PRJ319 - SMS Cobrança(Odirlei-AMcom)   
                            
               17/03/2017 - Inclusao Relatorio de Resumo do serviço de SMS.    
	                          PRJ319 - SMS Cobrança(Odirlei-AMcom)              
                            
               20/03/2017 - Alteraçao filtro relatório e adiçao de campo
	                          PRJ319 - SMS Cobrança(Ricardo Linhares)                                          

               30/01/2018 - Adicionado novas tags devido ao projeto 285 - Novo IB (Rafael).                                         
..............................................................................*/
    
CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0010tt.i }
{ sistema/generico/includes/var_oracle.i }

DEF VAR h-b1wnet0001 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0010 AS HANDLE                                         NO-UNDO.

DEF VAR i            AS INTE                                           NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dslinxml AS CHAR                                           NO-UNDO.
DEF VAR vr_flgfirst  AS LOGI                                           NO-UNDO.
DEF VAR aux_dsiduser AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                           NO-UNDO.
DEF VAR aux_dsxmlrel AS CHAR                                           NO-UNDO.
DEF VAR aux_iteracoes AS INTEGER                                       NO-UNDO.
DEF VAR aux_posini    AS INTEGER                                       NO-UNDO.
DEF VAR aux_contador  AS INTEGER                                       NO-UNDO.


DEF  INPUT PARAM par_cdcooper LIKE crapcob.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapcob.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF  INPUT PARAM par_idrelato AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_indordem AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrinssac AS DECI                                  NO-UNDO.
DEF  INPUT PARAM par_idsituac AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_inivecto AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_fimvecto AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_inipagto AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_fimpagto AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_iniemiss AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_fimemiss AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_flgregis AS LOGI                                  NO-UNDO.
DEF  INPUT PARAM par_inserasa AS INTE                                  NO-UNDO. 
DEF  INPUT PARAM par_instatussms AS INTE                               NO-UNDO. 
DEF  INPUT PARAM par_tppacote AS INTE                                  NO-UNDO. 

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.

function roundUp returns integer ( x as decimal ):
  if x = truncate( x, 0 ) then
    return integer( x ).
  else
    return integer( truncate( x, 0 ) + 1 ).
end.

/*    se for 1. Carteira de Cobranca sem Registro
   ou se for 3. Movimento de Liquidações (Francesa)
   ou se for 4. Relatorio Cedente (Cobranca registrada) 
   ou se for 5. Relatorio Movimento de Cobrança Registrada  */
IF  par_idrelato = 1 OR 
    par_idrelato = 3 OR 
    par_idrelato = 4 OR 
    par_idrelato = 5 THEN
    DO:
        RUN sistema/internet/procedures/b1wnet0001.p PERSISTENT 
            SET h-b1wnet0001.

        IF  NOT VALID-HANDLE(h-b1wnet0001)  THEN
            DO:
                ASSIGN aux_dscritic = "Handle invalido para BO b1wnet0001.".
                       xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + 
                                      "</dsmsgerr>".  
                
                RETURN "NOK".
            END.

        RUN consultar-boleto IN h-b1wnet0001 
                                     (INPUT par_cdcooper,
                                      INPUT 90,             /** PAC          **/
                                      INPUT 900,            /** Caixa        **/
                                      INPUT "996",          /** Operador     **/
                                      INPUT "INTERNETBANK", /** Tela         **/
                                      INPUT "3",            /** Origem       **/
                                      INPUT par_nrdconta,
                                      INPUT par_idseqttl,
                                      INPUT par_indordem,
                                      INPUT par_nrinssac,
                                      INPUT "",             /** Nome Sacado  **/
                                      INPUT par_idsituac,
                                      INPUT 999999,          /** Nr.Registros **/
                                      INPUT 1,              /** Ini.Sequenc. **/
                                      INPUT 0,              /** Ini.Docto    **/
                                      INPUT 0,              /** Fim.Docto    **/
                                      INPUT par_inivecto,
                                      INPUT par_fimvecto,
                                      INPUT par_inipagto,
                                      INPUT par_fimpagto,
                                      INPUT par_iniemiss,
                                      INPUT par_fimemiss,
                                      INPUT FALSE,           /** Logar       **/
                                      INPUT "",
                                      INPUT par_flgregis,
                                      INPUT par_inserasa,
                                     OUTPUT TABLE tt-consulta-blt,
                                     OUTPUT TABLE tt-erro).
           
        DELETE PROCEDURE h-b1wnet0001.
        
        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                
                IF  AVAILABLE tt-erro  THEN
                    aux_dscritic = tt-erro.dscritic.
                ELSE
                    aux_dscritic = "Nao foi possivel obter dados para o " +
                                   "relatorio.".
                    
                xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
                
                RETURN "NOK".
            END.    
        
        FIND LAST tt-consulta-blt NO-LOCK NO-ERROR.
    
        IF  AVAILABLE tt-consulta-blt  THEN
            DO:
                /* limites para geracao de relatorios (Jorge) 14/07/2011 */
                IF (par_idrelato = 1 AND tt-consulta-blt.nrregist > 2600) OR 
                   (par_idrelato = 3 AND tt-consulta-blt.nrregist > 3000) OR
                   (par_idrelato = 4 AND tt-consulta-blt.nrregist > 2800) OR
                   (par_idrelato = 5 AND tt-consulta-blt.nrregist > 3000) THEN
                    DO:
                        xml_dsmsgerr = "<dsmsgerr>Ha muitos registros para " +
                                       "a consulta. Diminua o periodo " + 
                                       "solicitado.</dsmsgerr>".

                        RETURN "NOK".
                    END.
            END.
        
        IF par_idrelato = 1 OR par_idrelato = 3 OR par_idrelato = 4 THEN
        DO:
            ASSIGN vr_flgfirst = TRUE.

            FOR EACH tt-consulta-blt NO-LOCK:

                IF par_indordem = 16 AND vr_flgfirst THEN
                DO:
                    CREATE xml_operacao.   
                    xml_operacao.dslinxml = "<limite><vllimtit>" +
                                            TRIM(STRING(tt-consulta-blt.vllimtit,
                                                        "zzzzzzzzz9.99")) +
                                            "</vllimtit><vltdscti>" +
                                            TRIM(STRING(tt-consulta-blt.vltdscti,
                                                        "zzzzzzzzz9.99")) +
                                            "</vltdscti><nrctrlim_ativo>" +
                                            STRING(tt-consulta-blt.nrctrlim_ativo) + 
                                            "</nrctrlim_ativo></limite>".
                    
                    ASSIGN vr_flgfirst = FALSE.
                END.                          
                
                CREATE xml_operacao.
                   
                IF  par_idrelato = 1 OR par_idrelato = 4 THEN    
                    xml_operacao.dslinxml = "<boleto><nossonro>" +
                                            tt-consulta-blt.nrnosnum +
                                            "</nossonro><nmdsacad>" +
                                            tt-consulta-blt.nmdsacad +
                                            "</nmdsacad><nrinssac>" +
                                            STRING(tt-consulta-blt.nrinssac) +
                                            "</nrinssac><cdtpinsc>" +
                                            STRING(tt-consulta-blt.cdtpinsc) +
                                            "</cdtpinsc><nrdocmto>" +
                                            STRING(tt-consulta-blt.nrdocmto) +
                                            "</nrdocmto><dtmvtolt>" +
                                            STRING(tt-consulta-blt.dtmvtolt,
                                                   "99/99/9999") +
                                            "</dtmvtolt><dtvencto>" +
                                            STRING(tt-consulta-blt.dtvencto,
                                                   "99/99/9999") +
                                            "</dtvencto><dtdpagto>" +
                                           (IF  tt-consulta-blt.dtdpagto = ? 
                                            THEN 
                                               (IF tt-consulta-blt.dtdbaixa = ?
                                                THEN " " ELSE
                                                STRING(tt-consulta-blt.dtdbaixa,
                                                          "99/99/9999"))
                                            ELSE 
                                                STRING(tt-consulta-blt.dtdpagto,
                                                       "99/99/9999")) +
                                            "</dtdpagto><vltitulo>" +
                                            TRIM(STRING(tt-consulta-blt.vltitulo,
                                                        "zzzzzzzzz9.99")) +
                                            "</vltitulo><vldpagto>" + 
                                            TRIM(STRING(tt-consulta-blt.vldpagto,
                                                        "zzzzzzzzz9.99")) +
                                            "</vldpagto><cdbanpag>" +
                                            STRING(tt-consulta-blt.cdbanpag) +
                                            "</cdbanpag><cdagepag>" + 
                                            STRING(tt-consulta-blt.cdagepag) +
                                            "</cdagepag><cdsituac>" +
                                            tt-consulta-blt.cdsituac +
                                            "</cdsituac><dssituac>" + 
                                            SUBSTR(tt-consulta-blt.dssituac,1,10) +
                                            "</dssituac><flgdesco>" +
                                            tt-consulta-blt.flgdesco +
                                            "</flgdesco><dtelimin>" +
                                           (IF  tt-consulta-blt.dtelimin = ? 
                                            THEN
                                                " "
                                            ELSE
                                                STRING(tt-consulta-blt.dtelimin,
                                                       "99/99/9999")) +
                                            "</dtelimin><dsdoccop>" +
                                            tt-consulta-blt.dsdoccop +
                                            "</dsdoccop><nrborder>" +
                                            STRING(tt-consulta-blt.nrborder) +
                                            "</nrborder><nrctrlim>" +
                                            STRING(tt-consulta-blt.nrctrlim) +
                                            "</nrctrlim><dsemitnt>" +
                                            tt-consulta-blt.dsemitnt + 
                                            "</dsemitnt><dtdocmto>" +
                                             STRING(tt-consulta-blt.dtdocmto, "99/99/9999") +
                                            "</dtdocmto></boleto>".            
                ELSE
                IF  par_idrelato = 3  THEN
                    xml_operacao.dslinxml = "<boleto><nossonro>" +
                                            tt-consulta-blt.nossonro +
                                            "</nossonro><nmdsacad>" +
                                            tt-consulta-blt.nmdsacad +
                                            "</nmdsacad><nrinssac>" +
                                            STRING(tt-consulta-blt.nrinssac) +
                                            "</nrinssac><cdtpinsc>" +
                                            STRING(tt-consulta-blt.cdtpinsc) +
                                            "</cdtpinsc><nrconven>" + 
                                            STRING(tt-consulta-blt.nrcnvcob) + 
                                            "</nrconven><nrdocmto>" +
                                            STRING(tt-consulta-blt.nrdocmto) +
                                            "</nrdocmto><dtmvtolt>" +
                                            STRING(tt-consulta-blt.dtmvtolt,
                                                   "99/99/9999") +
                                            "</dtmvtolt><dtvencto>" +
                                            STRING(tt-consulta-blt.dtvencto,
                                                   "99/99/9999") +
                                             "</dtvencto><dtdpagto>" +
                                           (IF  tt-consulta-blt.dtdpagto = ?
                                            THEN 
                                                " "
                                            ELSE 
                                                STRING(tt-consulta-blt.dtdpagto,
                                                       "99/99/9999")) +
                                            "</dtdpagto><vltitulo>" +
                                            TRIM(STRING(tt-consulta-blt.vltitulo,
                                                        "zzzzzzzzz9.99")) +
                                            "</vltitulo><vldpagto>" + 
                                            TRIM(STRING(tt-consulta-blt.vldpagto,
                                                        "zzzzzzzzz9.99")) +
                                            "</vldpagto><dsdpagto>" + 
                                            tt-consulta-blt.dsdpagto +
                                            "</dsdpagto><cdbanpag>" +
                                            STRING(tt-consulta-blt.cdbanpag) +
                                            "</cdbanpag><cdagepag>" + 
                                            STRING(tt-consulta-blt.cdagepag) +
                                            "</cdagepag><dsdoccop>"+
                                            tt-consulta-blt.dsdoccop +
                                            "</dsdoccop><dtdocmto>" +
                                            STRING(tt-consulta-blt.dtdocmto, "99/99/9999") +
                                            "</dtdocmto></boleto>".
                                                                                   
            END. /** Fim do FOR EACH tt-consulta-blt **/
        END.
        ELSE IF par_idrelato = 5 THEN
        DO:
            FOR FIRST crapceb
               FIELDS (cddemail)
                WHERE crapceb.cdcooper = par_cdcooper
                  AND crapceb.nrdconta = par_nrdconta
                  AND crapceb.insitceb = 1 /* Ativo */
                  AND crapceb.inenvcob = 2 /* FTP */
              NO-LOCK:
            END.
            
            IF AVAILABLE crapceb THEN
               DO:
            
                  RUN sistema/generico/procedures/b1wgen0010.p PERSISTENT 
                      SET h-b1wgen0010.

                  IF  NOT VALID-HANDLE(h-b1wgen0010)  THEN
                      DO:
                          ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0010.".
                                 xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + 
                                                "</dsmsgerr>".  
                          
                          RETURN "NOK".
                      END.
                      
                  FOR FIRST crapdat 
                     FIELDS (dtmvtolt)
                      WHERE crapdat.cdcooper = par_cdcooper
                      NO-LOCK:
                  END.
                  
                  IF  NOT AVAILABLE crapdat  THEN
                      DO:
                                              
                        ASSIGN xml_dsmsgerr = "<dsmsgerr>Sistema sem data de movimento.</dsmsgerr>".   
                            
                        RUN proc_geracao_log (INPUT FALSE).  
                                             
                        RETURN "NOK".
                        
                      END.            
                      
                  FOR FIRST crapass
                     FIELDS (nmprimtl cdagenci)
                      WHERE crapass.cdcooper = par_cdcooper
                        AND crapass.nrdconta = par_nrdconta
                        NO-LOCK:
                  END.
                      
                  IF  NOT AVAILABLE crapass  THEN
                      DO:
                          FIND crapcri WHERE crapcri.cdcritic = 9 NO-LOCK NO-ERROR.

                          IF  AVAILABLE crapcri  THEN
                              ASSIGN aux_dscritic = crapcri.dscritic.
                          ELSE
                              ASSIGN aux_dscritic = "Nao foi possivel obter dados para o " +
                                                    "relatorio.".
                                                    
                          ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".   
                            
                          RUN proc_geracao_log (INPUT FALSE).  
                                               
                          RETURN "NOK".
                      END.
                      
                  ASSIGN aux_dsiduser = STRING(par_nrdconta) + STRING(TIME).
                                            
                  RUN gera_relatorio IN h-b1wgen0010 
                               ( INPUT par_cdcooper,
                                 INPUT 90,
                                 INPUT 900,
                                 INPUT 3, /* idorigem */
                                 INPUT "INTERNETBANK",
                                 INPUT "",
                                 INPUT crapdat.dtmvtolt,
                                 INPUT par_nrdconta,
                                 INPUT crapass.nmprimtl,
                                 INPUT 6,
                                 INPUT par_iniemiss,
                                 INPUT par_fimemiss,
                                 INPUT 0,
                                 INPUT crapass.cdagenci,
                                 INPUT aux_dsiduser,
                                 INPUT 0,
                                 INPUT crapceb.cddemail,
                                OUTPUT aux_nmarqimp,
                                OUTPUT aux_nmarqpdf,
                                OUTPUT TABLE tt-erro).

                  DELETE PROCEDURE h-b1wgen0010.
                  
                  IF  RETURN-VALUE = "NOK"  THEN
                      DO:
                          FIND FIRST tt-erro NO-LOCK NO-ERROR.
                          
                          IF  AVAILABLE tt-erro  THEN
                              aux_dscritic = tt-erro.dscritic.
                          ELSE
                              aux_dscritic = "Nao foi possivel obter dados para o " +
                                             "relatorio.".
                              
                          xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
                          
                          RETURN "NOK".
                      END.    
                  ELSE
                      DO:
                          ASSIGN xml_dsmsgerr = "<dsmsgerr>Relatorio solicitado enviado por e-mail.</dsmsgerr>".  
                          
                          RETURN "OK".
                      END.
               END.       
        
            FOR EACH tt-consulta-blt NO-LOCK BREAK BY tt-consulta-blt.nrcnvcob
                                                   BY tt-consulta-blt.cdocorre
                                                   BY tt-consulta-blt.nrdconta
                                                   BY tt-consulta-blt.nrdocmto:
                
                IF FIRST-OF(tt-consulta-blt.cdocorre) THEN
                DO:
                    CREATE xml_operacao.
                    ASSIGN xml_operacao.dslinxml = "<ocorrencia>".
                END.

                CREATE xml_operacao.
                ASSIGN xml_operacao.dslinxml = "<boleto><cdbanpag>" +
                                        STRING(tt-consulta-blt.cdbanpag) +
                                        "</cdbanpag><iniemiss>" +
                                        STRING(par_iniemiss,"99/99/9999") + 
                                        "</iniemiss><fimemiss>" + 
                                        STRING(par_fimemiss,"99/99/9999") + 
                                        "</fimemiss><cdocorre>" +
                                        STRING(tt-consulta-blt.cdocorre) +
                                        "</cdocorre><dsocorre>" +
                                        tt-consulta-blt.dsocorre + 
                                        "</dsocorre><cdagepag>" +
                                        STRING(tt-consulta-blt.cdagepag) +
                                        "</cdagepag><nrdconta>" +
                                        STRING(tt-consulta-blt.nrdconta) +
                                        "</nrdconta><nrcnvcob>" +
                                        STRING(tt-consulta-blt.nrcnvcob) +
                                        "</nrcnvcob><nrdocmto>" +
                                        STRING(tt-consulta-blt.nrdocmto) +
                                        "</nrdocmto><dsdoccop>" +
                                        tt-consulta-blt.dsdoccop +
                                        "</dsdoccop><nmdsacad>" +
                                        tt-consulta-blt.nmdsacad +
                                        "</nmdsacad><dtvencto>" +
                                        STRING(tt-consulta-blt.dtvencto,
                                               "99/99/9999") +
                                        "</dtvencto><vltitulo>" +
                                        TRIM(STRING(tt-consulta-blt.vltitulo,
                                                    "zzzzzzzzz9.99")) +
                                        "</vltitulo><vldescto>" +
                                        TRIM(STRING(tt-consulta-blt.vldescto,
                                                    "zzzzzzzzz9.99")) +
                                        "</vldescto><vlabatim>" +
                                        TRIM(STRING(tt-consulta-blt.vlabatim,
                                                    "zzzzzzzzz9.99")) +
                                        "</vlabatim><vlrjuros>" +
                                        TRIM(STRING(tt-consulta-blt.vlrjuros,
                                                    "zzzzzzzzz9.99")) +
                                        "</vlrjuros><vloutdes>" +
                                        TRIM(STRING(tt-consulta-blt.vloutdes,
                                                    "zzzzzzzzz9.99")) +
                                        "</vloutdes><vloutcre>" +
                                        TRIM(STRING(tt-consulta-blt.vloutcre,
                                                    "zzzzzzzzz9.99")) +
                                        "</vloutcre><vldpagto>" +
                                        TRIM(STRING(tt-consulta-blt.vldpagto,
                                                    "zzzzzzzzz9.99")) +
                                        "</vldpagto><vltarifa>" +
                                        TRIM(STRING(tt-consulta-blt.vltarifa,
                                                    "zzzzzzzzz9.99")) +
                                        "</vltarifa><dtocorre>" +
                                        STRING(tt-consulta-blt.dtocorre,
                                               "99/99/9999") +
                                        "</dtocorre><dtcredit>" + 
                                        (IF tt-consulta-blt.dtcredit = ? THEN 
                                               " "
                                        ELSE 
                                           STRING(tt-consulta-blt.dtcredit,
                                               "99/99/9999")) + 
                                        "</dtcredit><dsmotivo>" +
                                        tt-consulta-blt.dsmotivo +
                                        "</dsmotivo>" +
                                        "<dsorigem>" + tt-consulta-blt.dsorigem + "</dsorigem>" + 
                                        "<dsorigem_proc>" + tt-consulta-blt.dsorigem_proc + "</dsorigem_proc>" +
                                        "<dtdocmto>" + STRING(tt-consulta-blt.dtdocmto, "99/99/9999") + "</dtdocmto>" + 
                                        "<nossonro>" + tt-consulta-blt.nossonro + "</nossonro>" + 
                                        "<nrborder>" + STRING(tt-consulta-blt.nrborder) + "</nrborder>" +
                                        "<dscredit>" + tt-consulta-blt.dscredit + "</dscredit>" +
                                        "<dsbcoage>" + tt-consulta-blt.dsbcoage + "</dsbcoage>" +
                                        "</boleto>".   

                                             
                
                IF LAST-OF(tt-consulta-blt.cdocorre) THEN
                DO:
                    CREATE xml_operacao.
                    ASSIGN xml_operacao.dslinxml = "</ocorrencia>".
                END.
                    
            END. /* FOR EACH tt-consulta-blt */
        END. /* if idrelato = 5 */
    END. /* if idrelato = 1, 3, 4 ou 5 */
ELSE IF par_idrelato = 2 THEN
    DO:
        RUN sistema/generico/procedures/b1wgen0010.p PERSISTENT 
            SET h-b1wgen0010.

        IF  NOT VALID-HANDLE(h-b1wgen0010)  THEN
            DO:
                ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0010.".
                       xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + 
                                      "</dsmsgerr>".  
                
                RETURN "NOK".
            END.

        RUN gera_totais_cobranca IN h-b1wgen0010 
                                        (INPUT par_cdcooper,
                                         INPUT par_nrdconta,
                                         INPUT 90,    /** PAC    **/
                                         INPUT 900,   /** Caixa  **/
                                         INPUT 3,     /** Origem **/
                                        OUTPUT TABLE tt-erro,
                                        OUTPUT TABLE tt-totais-cobranca).

        DELETE PROCEDURE h-b1wgen0010.

        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                
                IF  AVAILABLE tt-erro  THEN
                    aux_dscritic = tt-erro.dscritic.
                ELSE
                    aux_dscritic = "Nao foi possivel obter dados para o " +
                                   "relatorio.".
                    
                xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
                
                RETURN "NOK".
            END.

        FIND FIRST tt-totais-cobranca NO-LOCK NO-ERROR.

        CREATE xml_operacao.

        DO i = 1 TO 4:

            aux_dslinxml = (IF  i = 1  THEN
                                "<qtvencid>" +
                                STRING(tt-totais-cobranca.qtvencid) +
                                "</qtvencid><vlvencid>" +
                                TRIM(STRING(tt-totais-cobranca.vlvencid,
                                            "zzz,zzz,zzz,zz9.99")) +
                                "</vlvencid>"
                            ELSE
                                "") +
                            "<qtdatual>" +
                            STRING(tt-totais-cobranca.qtdatual[i]) +
                            "</qtdatual><vldatual>" +
                            TRIM(STRING(tt-totais-cobranca.vldatual[i],
                                        "zzz,zzz,zzz,zz9.99")) +
                            "</vldatual><qtate10d>" + 
                            STRING(tt-totais-cobranca.qtate10d[i]) +
                            "</qtate10d><vlate10d>" +
                            TRIM(STRING(tt-totais-cobranca.vlate10d[i],
                                        "zzz,zzz,zzz,zz9.99")) +
                            "</vlate10d><qtate30d>" + 
                            STRING(tt-totais-cobranca.qtate30d[i]) +
                            "</qtate30d><vlate30d>" +
                            TRIM(STRING(tt-totais-cobranca.vlate30d[i],
                                        "zzz,zzz,zzz,zz9.99")) +
                            "</vlate30d><qtsup30d>" +
                            STRING(tt-totais-cobranca.qtsup30d[i]) +
                            "</qtsup30d><vlsup30d>" +
                            TRIM(STRING(tt-totais-cobranca.vlsup30d[i],
                                        "zzz,zzz,zzz,zz9.99")) +
                            "</vlsup30d>".    
                
           CASE i:
               WHEN 1 THEN xml_operacao.dslinxml = xml_operacao.dslinxml + 
                           "<vencimentos>" + aux_dslinxml + "</vencimentos>".
               WHEN 2 THEN xml_operacao.dslinxml = xml_operacao.dslinxml +
                           "<liquidados>" + aux_dslinxml + "</liquidados>".
               WHEN 3 THEN xml_operacao.dslinxml = xml_operacao.dslinxml +
                           "<baixados>" + aux_dslinxml + "</baixados>".
               WHEN 4 THEN xml_operacao.dslinxml = xml_operacao.dslinxml +
                           "<descontados>" + aux_dslinxml + "</descontados>".
           END CASE.

        END.
           
    END.

/* Relatorio analitico de envio de SMS*/    
ELSE IF par_idrelato = 6 THEN
    DO:
       
      ASSIGN aux_dsiduser = STRING(par_nrdconta) + STRING(TIME).
      
      { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }    

      RUN STORED-PROCEDURE pc_relat_anali_envio_sms
          aux_handproc = PROC-HANDLE NO-ERROR
                                  (INPUT par_cdcooper,      /* pr_cdcooper */
                                   INPUT par_nrdconta,      /* pr_nrdconta */
                                   INPUT par_iniemiss,      /* pr_dtiniper */
                                   INPUT par_fimemiss,      /* pr_dtfimper */
                                   INPUT 3,                 /* pr_idorigem */
                                   INPUT aux_dsiduser,      /* pr_dsiduser */
                                   INPUT par_instatussms,   /* pr_instatus */
                                   INPUT par_tppacote,       /* pr_tppacote */
                                   
                                  OUTPUT "",            /* pr_nmarqpdf */
                                  OUTPUT "",            /* pr_dsxmlrel */
                                  OUTPUT 0,             /* pr_cdcritic */ 
                                  OUTPUT "").           /* pr_dscritic */

      CLOSE STORED-PROC pc_relat_anali_envio_sms
            aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

      { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

      ASSIGN aux_dscritic = ""
             aux_cdcritic = 0
             aux_nmarqpdf = ""
             aux_cdcritic = pc_relat_anali_envio_sms.pr_cdcritic
                                WHEN pc_relat_anali_envio_sms.pr_cdcritic <> ?
             aux_dscritic = pc_relat_anali_envio_sms.pr_dscritic
                                WHEN pc_relat_anali_envio_sms.pr_dscritic <> ?
             aux_dsxmlrel = pc_relat_anali_envio_sms.pr_dsxmlrel
                                WHEN pc_relat_anali_envio_sms.pr_dsxmlrel <> ?.
      
      IF aux_dscritic <> "" THEN
        DO:
            xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
            RETURN "NOK".
        END.  

      /* Atribuir xml de retorno a temptable*/ 
      IF aux_dsxmlrel <> "" THEN
      DO:    
        ASSIGN aux_iteracoes = roundUp(LENGTH(aux_dsxmlrel) / 31000)
               aux_posini    = 1.    
        
        DO aux_contador = 1 TO aux_iteracoes:
          CREATE xml_operacao.
          ASSIGN xml_operacao.dslinxml = SUBSTRING(aux_dsxmlrel, aux_posini, 31000)
                 aux_posini            = aux_posini + 31000.
        END.
        
      END.
    END.
    
/* Relatório Resumido do Serviço de SMS */ 
ELSE IF par_idrelato = 7 THEN
    DO:
       
      ASSIGN aux_dsiduser = STRING(par_nrdconta) + STRING(TIME).
      
      { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }    

      RUN STORED-PROCEDURE pc_relat_resumo_envio_sms
          aux_handproc = PROC-HANDLE NO-ERROR
                                  (INPUT par_cdcooper,      /* pr_cdcooper */
                                   INPUT par_nrdconta,      /* pr_nrdconta */
                                   INPUT par_iniemiss,      /* pr_dtiniper */
                                   INPUT par_fimemiss,      /* pr_dtfimper */
                                   INPUT 3,                 /* pr_idorigem */
                                   INPUT aux_dsiduser,      /* pr_dsiduser */
                                   INPUT par_instatussms,   /* pr_instatus */
                                   
                                  OUTPUT "",            /* pr_nmarqpdf */
                                  OUTPUT "",            /* pr_dsxmlrel */
                                  OUTPUT 0,             /* pr_cdcritic */ 
                                  OUTPUT "").           /* pr_dscritic */

      CLOSE STORED-PROC pc_relat_resumo_envio_sms
            aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

      { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

      ASSIGN aux_dscritic = ""
             aux_cdcritic = 0
             aux_nmarqpdf = ""
             aux_cdcritic = pc_relat_resumo_envio_sms.pr_cdcritic
                                WHEN pc_relat_resumo_envio_sms.pr_cdcritic <> ?
             aux_dscritic = pc_relat_resumo_envio_sms.pr_dscritic
                                WHEN pc_relat_resumo_envio_sms.pr_dscritic <> ?
             aux_dsxmlrel = pc_relat_resumo_envio_sms.pr_dsxmlrel
                                WHEN pc_relat_resumo_envio_sms.pr_dsxmlrel <> ?.
      
      IF aux_dscritic <> "" THEN
        DO:
            xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
            RETURN "NOK".
        END.  

      /* Atribuir xml de retorno a temptable*/ 
      IF aux_dsxmlrel <> "" THEN
      DO:    
        ASSIGN aux_iteracoes = roundUp(LENGTH(aux_dsxmlrel) / 31000)
               aux_posini    = 1.    
        
        DO aux_contador = 1 TO aux_iteracoes:

          CREATE xml_operacao.
          ASSIGN xml_operacao.dslinxml = SUBSTRING(aux_dsxmlrel, aux_posini, 31000)
                 aux_posini            = aux_posini + 31000.
        END.
        
      END.
    END.    

RETURN "OK".

/*............................................................................*/

