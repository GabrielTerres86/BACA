/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank3.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Marco/2007                        Ultima atualizacao: 16/12/2016

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Carregar informacoes para geracao de boleto bancario.
   
   Alteracoes: 03/11/2008 - Inclusao do widget-pool (martin) 
        
               03/03/2009 - Melhorias no servico de cobranca (David).
               
               22/04/2009 - Retornar CPF/CNPJ formatado no xml (David).

               28/05/2009 - Retornar numero variavel de carteira (David).
               
               15/06/2009 - Adaptar para validacao de emprestimos(Guilherme).
               
               31/05/2011 - Adicionado verificacao de operacao ao carregar
                            passado horario de operacao para XML (Jorge).
                            
               22/06/2011 - Adicionado parametro de XML idesthor no retorno de
                            <LIMITE> (Jorge).
                        
               24/06/2011 - Retirado comentario que enviava dados dos sacados
                            , passa-se quando < 4000 registros(Jorge).
                            
               25/07/2013 - Incluido <intipemi> no XML ref. ao tipo de emissao
                            de boleto (Cooperado emite e expede ou Banco emite
                            e expede) (Rafael/Jorge).
                            
               22/01/2015 - Adicionar a flgemail no XML de retorno para 
                            identificar que o pagador possui e-mail cadastrado
                            Projeto Boleto por E-mail (Douglas)             
                            
               08/01/2016 - Ajustes referente Projeto Negativacao Serasa (Daniel)

               16/02/2016 - Criacao do campo flprotes no XML. (Jaison/Marcos)

               11/10/2016 - Ajustes para permitir Aviso cobrança por SMS.
                            PRJ319 - SMS Cobrança(Odirlei-AMcom)

			   14/12/2016 Retirado limitacao de resultados aqui
                          pois qdo atinigia o limite nao mostrava nada na tela
						  mas mesmo assim levava todo o tempo como se tivesse 
						  carregado, validacao agora esta dentro da b1wnet0001.seleciona-sacados
						  (Tiago/Ademir SD566906)

               16/12/2016 - PRJ340 - Nova Plataforma de Cobranca - Fase II. 
                            (Jaison/Cechet)

..............................................................................*/
    
CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i   }
{ sistema/internet/includes/b1wnet0001tt.i }
{ sistema/generico/includes/b1wgen0023tt.i }
{ sistema/generico/includes/b1wgen0015tt.i }

DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapttl.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF  INPUT PARAM par_dtmvtolt LIKE crapepr.dtmvtolt                    NO-UNDO.
DEF  INPUT PARAM par_vldsacad AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrctremp LIKE crapepr.nrctremp                    NO-UNDO.
DEF  INPUT PARAM par_nrctasac LIKE crapsab.nrctasac                    NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR h-b1wnet0001 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0023 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0015 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_contador AS INTE                                           NO-UNDO.
DEF VAR aux_dsxmlout AS CHAR                                           NO-UNDO.
DEF VAR aux_des_erro AS CHAR                                           NO-UNDO.

/* sistema deve atribuir data do dia vindo da crapdat
   Rafael Cechet - 06/04/2011 */
FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

IF  AVAILABLE crapdat  THEN
    ASSIGN par_dtmvtolt = crapdat.dtmvtolt.

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
    ASSIGN xml_operacao.dslinxml =  "<LIMITE><hrinicob>" + 
                                    tt-limite.hrinipag + 
                                    "</hrinicob><hrfimcob>" +
                                    tt-limite.hrfimpag + 
                                    "</hrfimcob><idesthor>" +
                                    STRING(tt-limite.idesthor) +
                                    "</idesthor></LIMITE>".
END.

IF  par_nrctremp <> 0  THEN
    DO:
        RUN sistema/generico/procedures/b1wgen0023.p 
            PERSISTENT SET h-b1wgen0023.

        IF NOT VALID-HANDLE(h-b1wgen0023)  THEN
            DO:
                ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0023.".
                       xml_dsmsgerr = "<dsmsgerr>" + 
                                      aux_dscritic + 
                                      "</dsmsgerr>".  
                
                RETURN "NOK".
            END.

        RUN valida_contrato_epr IN h-b1wgen0023 
                               (INPUT par_cdcooper,
                                INPUT 90,             /** PAC      **/
                                INPUT 900,            /** Caixa    **/
                                INPUT "996",          /** Operador **/
                                INPUT par_nrdconta,
                                INPUT par_idseqttl,
                                INPUT "3",            /** Origem   **/
                                INPUT "INTERNETBANK", /** Tela     **/
                                INPUT par_nrctremp,
                                INPUT par_nrctasac,
                                INPUT TRUE,           /** Logar    **/
                               OUTPUT TABLE tt-erro,
                               OUTPUT TABLE tt-dados_epr_net).

        DELETE PROCEDURE h-b1wgen0023.
           
        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                
                IF  AVAILABLE tt-erro  THEN
                    aux_dscritic = tt-erro.dscritic.
                ELSE
                    aux_dscritic = "Nao foi possivel concluir a requisicao.".
                    
                xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
                
                RETURN "NOK".
            END.
    
        FIND FIRST tt-dados_epr_net NO-LOCK NO-ERROR.

        CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = "<EMPRESTIMOS_INTERNET><dtvencto>" +
                                       STRING(tt-dados_epr_net.dtdpagto,
                                              "99/99/9999") +
                                       "</dtvencto><vltitulo>" +
                                       STRING(tt-dados_epr_net.vlpreemp) +
                                       "</vltitulo><qttitulo>" +
                                       STRING(tt-dados_epr_net.qtpreemp) +
                                       "</qttitulo></EMPRESTIMOS_INTERNET>".
        
        RETURN "OK".
    END.

RUN sistema/internet/procedures/b1wnet0001.p PERSISTENT SET h-b1wnet0001.

IF  NOT VALID-HANDLE(h-b1wnet0001)  THEN
    DO:
        ASSIGN aux_dscritic = "Handle invalido para BO b1wnet0001.".
               xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
                
        RETURN "NOK".
    END.

RUN gera-dados IN h-b1wnet0001 (INPUT par_cdcooper,
                                INPUT 90,             /** PAC      **/
                                INPUT 900,            /** Caixa    **/
                                INPUT "996",          /** Operador **/
                                INPUT "INTERNETBANK", /** Tela     **/
                                INPUT "3",            /** Origem   **/
                                INPUT par_nrdconta,
                                INPUT par_idseqttl,
                                INPUT par_vldsacad,
                                INPUT TRUE,           /** Logar    **/
                               OUTPUT TABLE tt-erro,
                               OUTPUT TABLE tt-dados-blt,
                               OUTPUT TABLE tt-sacados-blt).

DELETE PROCEDURE h-b1wnet0001.
           
IF  RETURN-VALUE = "NOK"  THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
                
        IF  AVAILABLE tt-erro  THEN
            aux_dscritic = tt-erro.dscritic.
        ELSE
            aux_dscritic = "Nao foi possivel concluir a requisicao.".
                    
        xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
                
        RETURN "NOK".
    END.

RUN sistema/generico/procedures/b1wgen0023.p PERSISTENT SET h-b1wgen0023.

IF  NOT VALID-HANDLE(h-b1wgen0023)  THEN
    DO:
        ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0023.".
               xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
                
        RETURN "NOK".
    END.

RUN busca_cta_coop_epr IN h-b1wgen0023 
                               (INPUT par_cdcooper,
                                INPUT 90,             /** PAC      **/
                                INPUT 900,            /** Caixa    **/
                                INPUT "996",          /** Operador **/
                                INPUT par_nrdconta,
                                INPUT par_idseqttl,
                                INPUT "3",            /** Origem   **/
                                INPUT "INTERNETBANK", /** Tela     **/
                                INPUT TRUE,           /** Logar    **/
                               OUTPUT TABLE tt-erro,
                               OUTPUT TABLE tt-dados_epr_net).

DELETE PROCEDURE h-b1wgen0023.
           
IF  RETURN-VALUE = "NOK"  THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
                
        IF  AVAILABLE tt-erro  THEN
            aux_dscritic = tt-erro.dscritic.
        ELSE
            aux_dscritic = "Nao foi possivel concluir a requisicao.".
                    
        xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
                
        RETURN "NOK".
    END.    


FIND FIRST tt-dados-blt NO-LOCK NO-ERROR.
         
IF  AVAILABLE tt-dados-blt  THEN    
    DO:
        IF  tt-dados-blt.inpessoa > 1  THEN
            DO:
                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                RUN STORED-PROCEDURE pc_busca_config_nome_blt
                  aux_handproc = PROC-HANDLE NO-ERROR
                                     (INPUT par_cdcooper,
                                      INPUT par_nrdconta,
                                      OUTPUT "",
                                      OUTPUT "",
                                      OUTPUT "").
                                      
                                     
                CLOSE STORED-PROC pc_busca_config_nome_blt aux_statproc = PROC-STATUS
                      WHERE PROC-HANDLE = aux_handproc.

                ASSIGN aux_dsxmlout = ""
                       aux_des_erro = ""
                       aux_dscritic = ""
                       aux_des_erro = pc_busca_config_nome_blt.pr_des_erro
                                      WHEN pc_busca_config_nome_blt.pr_des_erro <> ?
                       aux_dscritic = pc_busca_config_nome_blt.pr_dscritic
                                      WHEN pc_busca_config_nome_blt.pr_dscritic <> ?
                       aux_dsxmlout = pc_busca_config_nome_blt.pr_clobxmlc
                                      WHEN pc_busca_config_nome_blt.pr_clobxmlc <> ?.      

                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                IF  aux_des_erro <> "OK" OR
                    aux_dscritic <> ""   THEN 
                    ASSIGN aux_dsxmlout = "".                
            END.
        ELSE
            ASSIGN aux_dsxmlout = "".
            
        CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = "<BOLETO><nrdctabb>" +
                                       TRIM(STRING(tt-dados-blt.nrdctabb,
                                                   "zzzz,zzz,9")) +
                                       "</nrdctabb><nrconven>" +
                                       STRING(tt-dados-blt.nrconven) +
                                       "</nrconven><tamannro>" +
                                       STRING(tt-dados-blt.tamannro) +
                                       "</tamannro><nrcpfcgc>" +
                                       STRING(tt-dados-blt.nrcpfcgc) +
                                       "</nrcpfcgc><dsendere>" +
                                       tt-dados-blt.dsendere +
                                       "</dsendere><nrendere>" +
                                       STRING(tt-dados-blt.nrendere) +
                                       "</nrendere><nmbairro>" +
                                       tt-dados-blt.nmbairro +
                                       "</nmbairro><nmcidade>" +
                                       tt-dados-blt.nmcidade +  
                                       "</nmcidade><cdufende>" +
                                       tt-dados-blt.cdufende +  
                                       "</cdufende><nrcepend>" +
                                       STRING(tt-dados-blt.nrcepend,"99999999") 
                                       + "</nrcepend><dtmvtolt>" +
                                       STRING(tt-dados-blt.dtmvtolt,
                                              "99/99/9999") +
                                       "</dtmvtolt><inpessoa>" +
                                       STRING(tt-dados-blt.inpessoa) +
                                       "</inpessoa><vllbolet>" +
                                       TRIM(STRING(tt-dados-blt.vllbolet,
                                                   "zzzzzzzz9.99")) +
                                       "</vllbolet><nmprimtl>" + 
                                       tt-dados-blt.nmprimtl +
                                       "</nmprimtl><dsdinstr>" +
                                       tt-dados-blt.dsdinstr +
                                       "</dsdinstr><cdcartei>" +
                                       STRING(tt-dados-blt.cdcartei) +
                                       "</cdcartei><nrvarcar>" + 
                                       STRING(tt-dados-blt.nrvarcar) +
                                       "</nrvarcar><intipcob>" +
                                       STRING(tt-dados-blt.intipcob) + 
                                       "</intipcob><intipemi>" + 
                                       STRING(tt-dados-blt.intipemi) +
                                       "</intipemi>" +
                                       "<flserasa>" + STRING(tt-dados-blt.flserasa) + "</flserasa>" +
                                       "<qtminneg>" + STRING(tt-dados-blt.qtminneg) + "</qtminneg>" +
                                       "<qtmaxneg>" + STRING(tt-dados-blt.qtmaxneg) + "</qtmaxneg>" +
                                       "<valormin>" + STRING(tt-dados-blt.valormin) + "</valormin>" +
                                       "<textodia>" + STRING(tt-dados-blt.textodia) + "</textodia>" +
                                       "<flprotes>" + STRING(tt-dados-blt.flprotes) + "</flprotes>" +
                                       "<flpersms>" + STRING(tt-dados-blt.flpersms) + "</flpersms>" +
                                       "<fllindig>" + STRING(tt-dados-blt.fllindig) + "</fllindig>" +
                                       "<cddbanco>" + STRING(tt-dados-blt.cddbanco) + "</cddbanco>" +
                                       "<flgregon>" + STRING(tt-dados-blt.flgregon) + "</flgregon>" +
                                       "<flgpgdiv>" + STRING(tt-dados-blt.flgpgdiv) + "</flgpgdiv>" +
                                       (IF aux_dsxmlout <> "" THEN aux_dsxmlout ELSE "") +
                                       "</BOLETO>".                                       

    END.
                  

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<EMPRESTIMOS_INTERNET><nrdconta>".

FIND FIRST tt-dados_epr_net NO-LOCK NO-ERROR.

IF  AVAILABLE tt-dados_epr_net  THEN    
    ASSIGN xml_operacao.dslinxml = xml_operacao.dslinxml +
                                   STRING(tt-dados_epr_net.nrdconta).

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "</nrdconta></EMPRESTIMOS_INTERNET>".


/* comentado por Rafael Cechet - 29/04/11
   Problemas de cooperados com muitos sacados (> 4500) 
   
   24/06/2011 - descomentado por Jorge Hamaguchi
   carregar dados ateh 4000 resultados. 
   caso ultrapasse, nao carrega
   
   24/06/2011 carregar dados até 2000
   caso ultrapasse, nao carreca SD 292432 
   (Kelviin)

   14/12/2016 Retirado limitacao de resultados aqui
   pois qdo atingia o limite nao mostrava nada na tela
   mas mesmo assim levava todo o tempo como se tivesse 
   carregado, validacao agora esta dentro da b1wnet0001.seleciona-sacados
   (Tiago/Ademir SD566906)
   */


FOR EACH tt-sacados-blt NO-LOCK:
    ASSIGN aux_contador = aux_contador + 1.
END.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<SACADOS qttotsac='" + 
                                STRING(aux_contador) + "'>".

    FOR EACH tt-sacados-blt NO-LOCK BY tt-sacados-blt.nmdsacad:
        CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = "<DADOS><nmdsacad>" +
                                       tt-sacados-blt.nmdsacad +
                                       "</nmdsacad><nrinssac>" +
                                       STRING(tt-sacados-blt.nrinssac) +
                                       "</nrinssac><dsinssac>" + 
                                       tt-sacados-blt.dsinssac +
                                       "</dsinssac><nrctasac>" +
                                       STRING(tt-sacados-blt.nrctasac) +
                                       "</nrctasac><dsctasac>" +
                                       tt-sacados-blt.dsctasac +
                                       "</dsctasac><flgemail>" +
                                       (IF(tt-sacados-blt.flgemail)THEN
                                           "1"
                                        ELSE 
                                           "0") +
                                       "</flgemail><nmsacado>" +
                                       tt-sacados-blt.nmsacado +
                                       "</nmsacado><dsflgend>" +
                                       STRING(tt-sacados-blt.dsflgend) +
                                       "</dsflgend><dsflgprc>" +
                                       STRING(tt-sacados-blt.dsflgprc) +
                                       "</dsflgprc></DADOS>".
                                         
END.
         
CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "</SACADOS>".

RETURN "OK".
/*............................................................................*/
