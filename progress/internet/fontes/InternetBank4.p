/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank4.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Marco/2007                        Ultima atualizacao: 02/01/2017

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Geracao de boleto bancario e dados para impressao.
   
   Alteracoes: 12/05/2008 - Gravar numero do documento do boleto (David).

               03/11/2008 - Inclusao widget-pool (martin).

               19/02/2009 - Melhorias no servico de cobranca (David).

               28/05/2009 - Novo parametro par_cdcartei (David).
               
               19/06/2009 - Novo parametro par_nrctremp (Guilherme).
               
               19/05/2011 - Novo parametro flgsacad passado para <DADOS_SACADO>
                            (Jorge).
               
               27/05/2011 - Adicionado campos nrinsava e cdtpinav para o  
                            XML (Jorge).
                
               31/05/2011 - Adicionado verificacao de operacao ao carregar
                            Passado horario de operacao para XML (Jorge).
                            
               22/06/2011 - Adicionado parametro de XML idesthor no retorno de
                            <LIMITE> e verificao caso seja cob. reg. (Jorge).
                            
               26/12/2011 - Utilizar data do dia - crapdat.dtmvtocd. (Rafael).
               
               18/07/2013 - Nao permitir geracao de boletos "Convenio Banco
                            Emite e Expede" após horário limite. (Rafael)

               03/03/2015 - Adicionado os campos de email no retorno do xml e
                            adicionado a gravação de log para boletos enviados
                            por e-mail (Projeto Boleto por email - Douglas)

               08/04/2015 - Adicionado os parametros para identificar a geração 
                            de boletos no formato carnê, além de não gerar o log
                            do envio por e-mail (Projeto Boleto Formato Carnê - Douglas)
                            
               08/01/2016 - Ajustes referente Projeto Negativacao Serasa (Daniel)
               
               11/10/2016 - Ajustes para permitir Aviso cobrança por SMS.
                            PRJ319 - SMS Cobrança (Odirlei-AMcom)
                            
               
               28/10/2016 - Ajustes realizados referente a melhoria 271. (Kelvin)

               11/10/2016 - Ajustes para permitir Aviso cobrança por SMS.
                            PRJ319 - SMS Cobrança (Odirlei-AMcom)

               22/12/2016 - PRJ340 - Nova Plataforma de Cobranca - Fase II. 
                            (Jaison/Cechet)
                            
..............................................................................*/

CREATE WIDGET-POOL.
    
{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i   }
{ sistema/internet/includes/b1wnet0001tt.i }
{ sistema/generico/includes/b1wgen0010tt.i }
{ sistema/generico/includes/b1wgen0015tt.i }

DEF  INPUT PARAM par_cdcooper LIKE crapcob.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapcob.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF  INPUT PARAM par_dtmvtolt LIKE crapcob.dtmvtolt                    NO-UNDO.
DEF  INPUT PARAM par_nrinssac AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_nmdavali LIKE crapcob.nmdavali                    NO-UNDO.
DEF  INPUT PARAM par_cdtpinav LIKE crapcob.cdtpinav                    NO-UNDO.
DEF  INPUT PARAM par_nrinsava LIKE crapcob.nrinsava                    NO-UNDO.
DEF  INPUT PARAM par_nrcnvcob LIKE crapcob.nrcnvcob                    NO-UNDO.
DEF  INPUT PARAM par_dsdoccop LIKE crapcob.dsdoccop                    NO-UNDO.
DEF  INPUT PARAM par_vltitulo LIKE crapcob.vltitulo                    NO-UNDO.
DEF  INPUT PARAM par_cddespec LIKE crapcob.cddespec                    NO-UNDO.
DEF  INPUT PARAM par_cdcartei LIKE crapcob.cdcartei                    NO-UNDO.
DEF  INPUT PARAM par_nrctremp LIKE crapepr.nrctremp                    NO-UNDO.
DEF  INPUT PARAM par_dtdocmto LIKE crapcob.dtdocmto                    NO-UNDO.
DEF  INPUT PARAM par_dtvencto LIKE crapcob.dtvencto                    NO-UNDO.
DEF  INPUT PARAM par_vldescto LIKE crapcob.vldescto                    NO-UNDO.
DEF  INPUT PARAM par_vlabatim LIKE crapcob.vlabatim                    NO-UNDO.
DEF  INPUT PARAM par_qttitulo AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_cdtpvcto AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_qtdiavct AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_cdmensag LIKE crapcob.cdmensag                    NO-UNDO.
DEF  INPUT PARAM par_dsdinstr LIKE crapcob.dsdinstr                    NO-UNDO.
DEF  INPUT PARAM par_dsinform LIKE crapcob.dsinform                    NO-UNDO.
/** Parametros de Cobranca Registrada **/
DEF  INPUT PARAM par_flgdprot AS LOGI                                  NO-UNDO.
DEF  INPUT PARAM par_qtdiaprt AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_indiaprt AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_inemiten AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_vlrmulta AS DECI                                  NO-UNDO.
DEF  INPUT PARAM par_vljurdia AS DECI                                  NO-UNDO.
DEF  INPUT PARAM par_flgaceit AS LOGI                                  NO-UNDO.
DEF  INPUT PARAM par_flgregis AS LOGI                                  NO-UNDO.
DEF  INPUT PARAM par_tpjurmor AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_tpdmulta AS INTE                                  NO-UNDO.

/* 1 = Boleto / 2 = Carnê */
DEF  INPUT PARAM par_tpemitir AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrdiavct AS INTE                                  NO-UNDO.

/* Parametros Negativacao Serasa */
DEF  INPUT PARAM par_flserasa AS LOGI                                  NO-UNDO.
DEF  INPUT PARAM par_qtdianeg AS INTE                                  NO-UNDO.

/* Aviso SMS */
DEF  INPUT PARAM par_inavisms AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_insmsant AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_insmsvct AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_insmspos AS INTE                                  NO-UNDO.

DEF  INPUT PARAM par_flgregon AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_inpagdiv AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_vlminimo AS DECI                                  NO-UNDO.

/* Configuracao do nome de emissao */
DEF  INPUT PARAM par_idrazfan AS INTE                   			         NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR h-b1wnet0001 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0015 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0088 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

/* Informações do beneficiário */
DEF VAR aux_nmprimtl_ben LIKE crapass.nmprimtl                         NO-UNDO.
DEF VAR aux_nrcpfcgc_ben LIKE crapass.nrcpfcgc                         NO-UNDO.
DEF VAR aux_inpessoa_ben LIKE crapass.inpessoa                         NO-UNDO.
DEF VAR aux_dsdemail_ben LIKE crapcem.dsdemail                         NO-UNDO.

DEF VAR aux_ctdemail AS INTE                                           NO-UNDO.
DEF VAR aux_qtdemail AS INTE                                           NO-UNDO.

/* sistema deve atribuir data do dia vindo da crapdat
   Rafael Cechet - 06/04/2011 */
FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

IF  AVAILABLE crapdat  THEN
    ASSIGN par_dtmvtolt = crapdat.dtmvtocd.
   
RUN sistema/generico/procedures/b1wgen0015.p PERSISTENT SET h-b1wgen0015.

IF  NOT VALID-HANDLE(h-b1wgen0015)  THEN
DO:
    ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0015.".
           xml_dsmsgerr = "<dsmsgerr>" + 
                          aux_dscritic + 
                          "</dsmsgerr>".  
    RETURN "NOK".
END.

/** Verifica o horario inicial e final para a operacao **/
RUN horario_operacao IN h-b1wgen0015 (INPUT par_cdcooper,
                                      INPUT 90,
                                      INPUT 3,
                                      INPUT 0,
                                     OUTPUT aux_dscritic,
                                     OUTPUT TABLE tt-limite).

DELETE PROCEDURE h-b1wgen0015.

FIND FIRST tt-limite NO-LOCK NO-ERROR.

IF  AVAILABLE tt-limite  THEN
DO:
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml =  "<limite><hrinicob>" + 
                                    tt-limite.hrinipag + 
                                    "</hrinicob><hrfimcob>" +
                                    tt-limite.hrfimpag + 
                                    "</hrfimcob><idesthor>" +
                                    STRING(tt-limite.idesthor) + 
                                    "</idesthor></limite>".
END.

IF  RETURN-VALUE = "NOK"  THEN
DO:
    ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + 
                          "</dsmsgerr>".

    RETURN "NOK".
END.

/* se for cobranca registrada e estourou o periodo permitido */
IF par_flgregis = TRUE    AND   /* cobranca registrada */
   tt-limite.idesthor = 1 AND   /* estourou horario permitido */
   par_inemiten = 1       THEN  /* Modalidade - Banco Emite e expede */
DO:
    ASSIGN  aux_dscritic = "Geracao do boleto nao efetuada. " +
                           "Fora do horario permitido.".
            xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + 
                           "</dsmsgerr>".

    RETURN "NOK".
END.

RUN sistema/internet/procedures/b1wnet0001.p PERSISTENT SET h-b1wnet0001.

IF  NOT VALID-HANDLE(h-b1wnet0001)  THEN
DO:
    ASSIGN aux_dscritic = "Handle invalido para BO b1wnet0001.".
           xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
    RETURN "NOK".
END.

IF  par_idrazfan > 0  THEN /* Se houve alteracao na configuracao do nome de emissao */
    DO:
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

        RUN STORED-PROCEDURE pc_grava_config_nome_blt
          aux_handproc = PROC-HANDLE NO-ERROR
                             (INPUT par_cdcooper,
                              INPUT par_nrdconta,
                              INPUT par_idrazfan,
                              OUTPUT "",
                              OUTPUT "").                              
                             
        CLOSE STORED-PROC pc_grava_config_nome_blt aux_statproc = PROC-STATUS
              WHERE PROC-HANDLE = aux_handproc.
                
        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    END.

RUN gravar-boleto IN h-b1wnet0001 (INPUT par_cdcooper,
                                   INPUT 90,             /** PAC      **/
                                   INPUT 900,            /** Caixa    **/
                                   INPUT "996",          /** Operador **/
                                   INPUT "INTERNETBANK", /** Tela     **/
                                   INPUT "3",            /** Origem   **/
                                   INPUT par_nrdconta,
                                   INPUT par_idseqttl,
                                   INPUT par_dtmvtolt,
                                   INPUT par_nrinssac,
                                   INPUT par_nmdavali,
                                   INPUT par_cdtpinav,
                                   INPUT par_nrinsava,
                                   INPUT par_nrcnvcob,
                                   INPUT par_dsdoccop,
                                   INPUT par_vltitulo,
                                   INPUT par_cddespec,
                                   INPUT par_cdcartei,
                                   INPUT par_nrctremp,
                                   INPUT par_dtdocmto,
                                   INPUT par_dtvencto,
                                   INPUT par_vldescto,
                                   INPUT par_vlabatim,
                                   INPUT par_qttitulo,
                                   INPUT par_cdtpvcto,
                                   INPUT par_qtdiavct,
                                   INPUT par_cdmensag,
                                   INPUT par_dsdinstr,
                                   INPUT par_dsinform,
                                   INPUT TRUE,           /** Logar    **/

                                   INPUT par_flgdprot,
                                   INPUT par_qtdiaprt,
                                   INPUT par_indiaprt,
                                   INPUT par_inemiten,
                                   INPUT par_vlrmulta,
                                   INPUT par_vljurdia,
                                   INPUT par_flgaceit,
                                   INPUT par_flgregis,

                                   INPUT par_tpjurmor,
                                   INPUT par_tpdmulta,

                                   INPUT par_tpemitir,
                                   INPUT par_nrdiavct,

                                   /* Serasa */
                                   INPUT par_flserasa,
                                   INPUT par_qtdianeg,

                                   /*Aviso SMS*/
                                   INPUT par_inavisms,
                                   INPUT par_insmsant,
                                   INPUT par_insmsvct,
                                   INPUT par_insmspos,         
        
                                   /* NPC */
                                   INPUT par_flgregon,
                                   INPUT par_inpagdiv,
                                   INPUT par_vlminimo,

                                  OUTPUT TABLE tt-erro,
                                  OUTPUT TABLE tt-consulta-blt,
                                  OUTPUT TABLE tt-dados-sacado-blt).
            
DELETE PROCEDURE h-b1wnet0001.
          
IF  RETURN-VALUE = "NOK"  THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
               
        IF  AVAILABLE tt-erro  THEN
            aux_dscritic = tt-erro.dscritic.
        ELSE
            aux_dscritic = "Nao foi possivel gerar o novo boleto.".
                   
        xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
                
        RETURN "NOK".
    END.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<dados_boletos>".

FOR EACH tt-consulta-blt NO-LOCK:

    ASSIGN aux_nmprimtl_ben = tt-consulta-blt.nmprimtl
           aux_nrcpfcgc_ben = tt-consulta-blt.nrcpfcgc
           aux_inpessoa_ben = tt-consulta-blt.inpessoa.

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<boleto><nossonro>" +
                                   tt-consulta-blt.nossonro +
                                   "</nossonro><nmdsacad>" +
                                   tt-consulta-blt.nmdsacad +
                                   "</nmdsacad><nrinssac>" +
                                   STRING(tt-consulta-blt.nrinssac) +
                                   "</nrinssac><dsendsac>" +
                                   tt-consulta-blt.dsendsac +
                                   "</dsendsac><nmbaisac>" +
                                   tt-consulta-blt.nmbaisac +
                                   "</nmbaisac><nmcidsac>" +
                                   tt-consulta-blt.nmcidsac +
                                   "</nmcidsac><cdufsaca>" +
                                   tt-consulta-blt.cdufsaca +
                                   "</cdufsaca><nrcepsac>" +
                                   STRING(tt-consulta-blt.nrcepsac,
                                          "99999999") +
                                   "</nrcepsac><nmdavali>" +
                                   tt-consulta-blt.nmdavali + 
                                   "</nmdavali><nrconven>" +
                                   STRING(tt-consulta-blt.nrcnvcob) +
                                   "</nrconven><nrcnvceb>" +
                                   STRING(tt-consulta-blt.nrcnvceb) +
                                   "</nrcnvceb><nrdctabb>" +
                                   STRING(tt-consulta-blt.nrdctabb) +
                                   "</nrdctabb><nrcpfcgc>" +
                                   STRING(tt-consulta-blt.nrcpfcgc) +
                                   "</nrcpfcgc><nrdocmto>" +
                                   STRING(tt-consulta-blt.nrdocmto) +
                                   "</nrdocmto><dtmvtolt>" +
                                   STRING(tt-consulta-blt.dtmvtolt,
                                          "99/99/9999") +
                                   "</dtmvtolt><dsdinstr>" +
                                   tt-consulta-blt.dsdinstr +
                                   "</dsdinstr><dsdoccop>" +
                                   STRING(tt-consulta-blt.dsdoccop) + 
                                   "</dsdoccop><dtvencto>" +
                                   STRING(tt-consulta-blt.dtvencto,
                                          "99/99/9999") +
                                   "</dtvencto><dtdpagto>" +
                                  (IF  tt-consulta-blt.dtdpagto = ?  THEN 
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
                                   "</vldpagto><cdtpinsc>" +
                                   STRING(tt-consulta-blt.cdtpinsc) +
                                   "</cdtpinsc><inpessoa>" +
                                   STRING(tt-consulta-blt.inpessoa) +
                                   "</inpessoa><nmprimtl>" +
                                   tt-consulta-blt.nmprimtl +
                                   "</nmprimtl><vldescto>" +
                                   TRIM(STRING(tt-consulta-blt.vldescto,
                                               "zzzzzzzzz9.99")) +
                                   "</vldescto><cdmensag>" +
                                   STRING(tt-consulta-blt.cdmensag) +
                                   "</cdmensag><complend>" +
                                   tt-consulta-blt.complend +
                                   "</complend><idbaiexc>" +
                                   STRING(tt-consulta-blt.idbaiexc) +
                                   "</idbaiexc><cdsituac>" +
                                   tt-consulta-blt.cdsituac +
                                   "</cdsituac><dsinform>" +
                                   tt-consulta-blt.dsinform +
                                   "</dsinform><vlabatim>" +
                                   TRIM(STRING(tt-consulta-blt.vlabatim,
                                               "zzzzzzzzz9.99")) +
                                   "</vlabatim><cddespec>" +
                                   STRING(tt-consulta-blt.cddespec) +
                                   "</cddespec><dtdocmto>" +
                                   STRING(tt-consulta-blt.dtdocmto,
                                          "99/99/9999") +
                                   "</dtdocmto><dsdpagto>" +
                                   tt-consulta-blt.dsdpagto +
                                   "</dsdpagto><cdbanpag>" +
                                   STRING(tt-consulta-blt.cdbanpag) +
                                   "</cdbanpag><cdagepag>" + 
                                   STRING(tt-consulta-blt.cdagepag) +
                                   "</cdagepag><dssituac>" + 
                                   tt-consulta-blt.dssituac + 
                                   "</dssituac><flgdesco>" +
                                   tt-consulta-blt.flgdesco +
                                   "</flgdesco><dtelimin>" +
                                  (IF  tt-consulta-blt.dtelimin = ?  THEN
                                       " "
                                   ELSE
                                       STRING(tt-consulta-blt.dtelimin,
                                              "99/99/9999")) +
                                   "</dtelimin><cdcartei>" +
                                   STRING(tt-consulta-blt.cdcartei) +
                                   "</cdcartei>" + 
                                   /* adicionado codigo do banco
                                      Rafael Cechet - 31/03/11 */
                                   "<cdbandoc>" + 
                                   STRING(tt-consulta-blt.cdbandoc) + 
                                   "</cdbandoc>" + 
                                   /* adicionado flgregis,nrnosnum,agencidv 
                                      - Cob. Registrada
                                      Rafael Cechet - 01/04/11 */
                                   "<flgregis>" + 
                                    (IF TRIM(tt-consulta-blt.flgregis) = "S"  
                                     THEN "1" ELSE "2") + "</flgregis>" + 
                                   "<nrnosnum>" + tt-consulta-blt.nrnosnum + 
                                   "</nrnosnum><agencidv>" + 
                                    tt-consulta-blt.agencidv + "</agencidv>" + 
                                   /* adicionado nrvarcar, flgaceit, tpjurmor,
                                      vljurdia, tpdmulta, vlrmulta - Cob. Reg.
                                      Rafael Cechet - 18/04/11 */
                                   "<nrvarcar>" + 
                                   STRING(tt-consulta-blt.nrvarcar) + 
                                   "</nrvarcar><flgaceit>" + 
                                   TRIM(tt-consulta-blt.flgaceit) + 
                                   "</flgaceit><tpjurmor>" + 
                                   STRING(tt-consulta-blt.tpjurmor) + 
                                   "</tpjurmor><vljurdia>" + 
                                   TRIM(STRING(tt-consulta-blt.vlrjuros,
                                               "zzzzzzzzz9.99")) + 
                                   "</vljurdia><tpdmulta>" + 
                                   STRING(tt-consulta-blt.tpdmulta) + 
                                   "</tpdmulta><vlrmulta>" + 
                                   TRIM(STRING(tt-consulta-blt.vlrmulta,
                                               "zzzzzzzzz9.99")) + 
                                   "</vlrmulta><flgdprot>" + 
                                   (IF (tt-consulta-blt.flgdprot = TRUE) 
                                    THEN "S" ELSE "N") + 
                                   "</flgdprot><qtdiaprt>" + 
                                   STRING(tt-consulta-blt.qtdiaprt, "99") + 
                                   "</qtdiaprt><indiaprt>" + 
                                   STRING(tt-consulta-blt.indiaprt, "9") + 
                                   "</indiaprt><insitpro>" + 
                                   STRING(tt-consulta-blt.insitpro, "9") + 
                                   "</insitpro><cdtpinav>" + 
                                   STRING(tt-consulta-blt.cdtpinav, "9") + 
                                   "</cdtpinav><nrinsava>" + 
                                   STRING(tt-consulta-blt.nrinsava) + 
                                   "</nrinsava>" +
                                   "<flserasa>" +  
                                   (IF tt-consulta-blt.flserasa = TRUE 
                                   THEN "S" ELSE "N") + "</flserasa>" +
                                   "<qtdianeg>" +  STRING(tt-consulta-blt.qtdianeg) + "</qtdianeg>" +
                                   
                                   /* Aviso SMS*/
                                   "<inavisms>" + 
                                   STRING(tt-consulta-blt.inavisms) + 
                                   "</inavisms>" +
                                   "<insmsant>" + 
                                   STRING(tt-consulta-blt.insmsant) + 
                                   "</insmsant>" +
                                   "<insmsvct>" + 
                                   STRING(tt-consulta-blt.insmsvct) + 
                                   "</insmsvct>" +
                                   "<insmspos>" + 
                                   STRING(tt-consulta-blt.insmspos) + 
                                   "</insmspos>" +
                                   
                                   "<inenvcip>" + 
                                   STRING(tt-consulta-blt.inenvcip) + 
                                   "</inenvcip>" +
                                   "<inpagdiv>" + 
                                   STRING(tt-consulta-blt.inpagdiv) + 
                                   "</inpagdiv>" +
                                   "<vlminimo>" + 
                                   STRING(tt-consulta-blt.vlminimo) + 
                                   "</vlminimo>" +
                                   
                                   "</boleto>".

    /* Geramos esse log apenas quando for emissão de boleto */
    IF par_tpemitir = 1 THEN 
    DO:
        /* Carregar a Bo88 para geração do log de cobrança */
        IF NOT VALID-HANDLE(h-b1wgen0088)  THEN
            RUN sistema/generico/procedures/b1wgen0088.p
                PERSISTENT SET h-b1wgen0088.
    
        /* Geração do log para os boletos que são enviados por e-mail 
           Os dados do sacado possuem um registro por pessoa
           Buscar o sacado de cada boleto*/
        FIND FIRST tt-dados-sacado-blt
            WHERE tt-dados-sacado-blt.nrinssac = tt-consulta-blt.nrinssac
            NO-LOCK NO-ERROR.
    
        IF AVAIL tt-dados-sacado-blt THEN
        DO:
            IF tt-dados-sacado-blt.flgemail = TRUE THEN
            DO:
                /* Encontra o rowid da crapcob para gerar o log */
                FIND FIRST crapcob WHERE crapcob.cdcooper = tt-consulta-blt.cdcooper
                                     AND crapcob.nrdconta = tt-consulta-blt.nrdconta
                                     AND crapcob.nrdocmto = tt-consulta-blt.nrdocmto
                                     AND crapcob.cdbandoc = tt-consulta-blt.cdbandoc
                                     AND crapcob.nrdctabb = tt-consulta-blt.nrdctabb
                                     AND crapcob.nrcnvcob = tt-consulta-blt.nrcnvcob
                                   NO-LOCK NO-ERROR.
    
                IF AVAIL crapcob THEN
                DO:
                    IF VALID-HANDLE(h-b1wgen0088) THEN
                    DO:
                    
                        ASSIGN aux_qtdemail = NUM-ENTRIES(tt-dados-sacado-blt.dsdemail,";").
                        
                        DO aux_ctdemail = 1 TO aux_qtdemail:
                        /* Cria o log da cobrança informando que o boleto foi enviado por e-mail */
                        RUN cria-log-cobranca IN h-b1wgen0088
                              (INPUT ROWID(crapcob),
                               INPUT "996", /* cdoperad */
                               INPUT TODAY,
                               INPUT "ENVIADO EMAIL: " + TRIM(ENTRY(aux_ctdemail,tt-dados-sacado-blt.dsdemail,";"))).  
                        END.		   
                    END.
                END.
            END.
        END.
    END.
END.

IF VALID-HANDLE(h-b1wgen0088) THEN
    DELETE PROCEDURE h-b1wgen0088.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "</dados_boletos><dados_sacado>".
                 
FOR EACH tt-dados-sacado-blt NO-LOCK:
               
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<sacado><nmdsacad>" +
                                   tt-dados-sacado-blt.nmdsacad +
                                   "</nmdsacad><dsendsac>" +
                                   tt-dados-sacado-blt.dsendsac +
                                   "</dsendsac><nrendsac>" +
                                   STRING(tt-dados-sacado-blt.nrendsac) +
                                   "</nrendsac><nmbaisac>" +
                                   tt-dados-sacado-blt.nmbaisac +
                                   "</nmbaisac><nmcidsac>" +
                                   tt-dados-sacado-blt.nmcidsac +
                                   "</nmcidsac><cdufsaca>" +
                                   tt-dados-sacado-blt.cdufsaca +
                                   "</cdufsaca><nrcepsac>" +
                                   STRING(tt-dados-sacado-blt.nrcepsac,
                                          "99999999") +
                                   "</nrcepsac><nrinssac>" +
                                   STRING(tt-dados-sacado-blt.nrinssac) +
                                   "</nrinssac><cdtpinsc>" +
                                   STRING(tt-dados-sacado-blt.cdtpinsc) +
                                   "</cdtpinsc><complend>" + 
                                   tt-dados-sacado-blt.complend +
                                   "</complend><flgsacad>" + 
                                   (IF tt-dados-sacado-blt.flgsacad = TRUE 
                                    THEN "S" ELSE "N") + 
                                   "</flgsacad><flgemail>" +
                                   (IF tt-dados-sacado-blt.flgemail = TRUE
                                    THEN "1" ELSE "0") +
                                   "</flgemail><dsdemail>" + 
                                   tt-dados-sacado-blt.dsdemail +
                                   "</dsdemail></sacado>".
           
END.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "</dados_sacado>".


/* Buscar o e-mail do beneficiário que está enviando os boletos por e-mail */
FIND FIRST crapcem WHERE crapcem.cdcooper = par_cdcooper
                     AND crapcem.nrdconta = par_nrdconta
                   NO-LOCK NO-ERROR.

IF AVAIL crapcem THEN
    ASSIGN aux_dsdemail_ben = crapcem.dsdemail.

    
CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<dados_beneficiario><nmprimtl>" + 
                               aux_nmprimtl_ben + 
                               "</nmprimtl><nrcpfcgc>" + 
                               STRING(aux_nrcpfcgc_ben) + 
                               "</nrcpfcgc><inpessoa>" + 
                               STRING(aux_inpessoa_ben) + 
                               "</inpessoa><dsdemail>" + 
                               aux_dsdemail_ben + 
                               "</dsdemail></dados_beneficiario>".

 

RETURN "OK".

/*............................................................................*/
