/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +----------------------------------------+----------------------------------------+
  | Rotina Progress                        | Rotina Oracle PLSQL                    |
  +----------------------------------------+----------------------------------------+
  | b1wgen0032.p/verifica-letras-seguranca | CADA0004.fn_verif_letras_seguranca     |
  | b1wgen0032.obtem-cartoes-magnetico     | CADA0004.pc_obtem_cartoes_magneticos   |
  | b1wgen0032.verifica-situacao-cartao    | CADA0004.fn_situacao_cartao_mag        |
  | b1wgen0032.bloquear-cartao-magnetico   | CADA0004.pc_bloquear_cartao_magnetico  |
  +----------------------------------------+----------------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/

/*..............................................................................

    Programa: b1wgen0032.p
    Autor   : Guilherme/David
    Data    : Agosto/2008                     Ultima Atualizacao: 14/08/2018
           
    Dados referentes ao programa:
                
    Objetivo  : BO ref. a Cartao Magnetico.
                Baseada no programa fontes/carmag.p.
                
                    
    Alteracoes: 10/09/2008 - Continuar desenvolvimento da BO (David).   
    
                03/06/2009 - Incluido critica na procedure valida-dados-cartao
                             para nao permitir solicitar 2 cartoes para o mesmo
                             titular (Elton).
                           - Novo parametro tpusucar, para permitir alteracao 
                             de titular, na procedure alterar-cartao-magnetico
                           - Melhoria na procedure consiste-cartao
                             (David).
                             
                30/06/2009 - Alteracao CDOPERAD (Kbase/Diego).

                18/08/2009 - Melhorias para utilizacao nas telas ATENDA e
                             OPERAD (David).
                           - Adicionado procedure corrige_segtl(Guilherme).  
                           
                23/09/2009 - Atualizar crapcrm.dtentcrm mesmo quando for
                             'reentrega' de cartao (Diego).
                             
                26/07/2010 - Permite a conta juridica 239.340-9 da Viacredi a 
                             receber mais de um cartao magnentico (Elton).             
                             
                17/09/2010 - Bloquear solicitação de novo cartao magnético
                             para PAC 5 Coop 2 - Transf.de Pac (Irlan).
                             
                13/12/2011 - Saque com o cartao magnetico (Gabriel).
                
                21/12/2011 - Criada procedure solicitar-letras;
                           - Limpar senha-letras na entrega do cartao (Diego).            
                           
                04/01/2012 - Alterado as procedures:
                             - alterar-senha-cartao-magnetico > para validar 
                               se a nova senha eh diferente da senha atual;
                             - entregar-cartao-magnetico > para realizar a 
                               alteracao de senha do cartao 
                             Criano a procedure:
                             - validar-senha-cartao-magnetico
                             (Adriano).
                             
                12/01/2012 - Alterar nome solicitar-letras para limpar-letras
                             Adicionar grava-senha-letras 
                             Adicionar verifica-cartao-letras
                             Nao limpar letras de seguranca quando entregar
                             Remover a limpar-letras 
                             Alterar nrsencar para dssencar (Guilherme).
                             
                07/11/2012 - Ajustar letras de seguranca para Internet (David).
                           - Removido parametro do Nr. do cartão magnético
                             da procedure 'grava-senha-letras' (Lucas).
                             
                11/01/2013 - Alterada proc. 'verifica-senha-atual' para retornar
                             se o cooperado possui letras cadastradas (Lucas).
                
                13/08/2013 - Nova forma de chamar as agências, de PAC agora 
                             a escrita será PA (André Euzébio - Supero).  
                             
                06/11/2013 - Criada proc. gravar-hist-cartmagope
                           - Criada proc. validar-hist-cartmagope
                           - Adicionado verificacao da senha no historico qd
                             for operador em proc. 
                             alterar-senha-cartao-magnetico. (Jorge)
                             
                17/12/2013 - Adaptacao para uso do TAA na procedure
                             alterar-senha-cartao-magnetico (Evandro).
                             
                28/02/2014 - Incluso VALIDATE (Daniel).
                
                24/03/2014 - Ajuste na procedure "incluir-cartao-magnetico" 
                             para buscar a proxima sequencia crapmat.nrseqcar
                             apartir banco Oracle (James)
                             
                15/09/2014 - Tratamento para leitura de cartao na AltoVale,
                             pois a agencia do bancoob foi alterada na tabela
                             crapcop (David).
                             
                27/11/2014 - #227966 Ajustes para a incorporacao da concredi e 
                             credimilsul (Carlos)
                            
                28/11/2014 - #223022 Verificada a situacao do cartao magnetico
                             (validar-entrega-cartao) para somente entrega-lo 
                             quando disponivel (Carlos)
                
                21/01/2015 - #245829 Verificada a situacao do cartao magnetico
                             (validar-entrega-cartao) para entrega-lo tambem
                             quando bloqueado (Carlos)
                             
                21/01/2015 - Conversão da fn_sequence para procedure para não
                             gerar cursores abertos no Oracle. (Dionathan)
                             
                22/07/2015 - Remover procedures que nao sera mais utilizadas. (James)

                06/11/2015 - Reformulacao cadastral (Gabriel-RKAM).
                
                23/11/2015 - #351803 Ajuste na verificacao de avail da crapcrm 
                             (Carlos)
                
                17/12/2015 - Ajuste na validacao do cargo para representante/procurador 
                             (Jonathan - RKAM)
                             
                24/02/2016 - Alteração na rotina de alteração de senha (Lucas Lunelli
                             - [PROJ290])    
                             
                23/12/2015 - Ajustes para proj. 131. Assinatura Multipla.
                             (Jorge/David)             

                17/06/2016 - Inclusão de campos de controle de vendas - M181 ( Rafael Maciel - RKAM)

				07/12/2016 - P341-Automatização BACENJUD - Alterar o uso da descrição do
                             departamento passando a considerar o código (Renato Darosci)

				19/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                 crapass, crapttl, crapjur 
							(Adriano - P339).

                29/03/2018 - Chamar rotina pc_valida_adesao_produto na proc 
                             obtem-permissao-solicitacao. PRJ366 (Lombardi).
							 
				03/08/2018 - Ajuste na grava-senha-letras, para	alterar a situação
				             da senha letras para ativo. INC0019451 (Wagner - Sustentação)

                14/08/2018 - P450 - Procedimentos realizados na c/c para a transferência(Rangel/AMcom)

..............................................................................*/


/*................................ DEFINICOES ................................*/


{ sistema/generico/includes/b1wgen0032tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/var_oracle.i }
{ sistema/ayllos/includes/var_online.i NEW } 

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.
DEF VAR aux_nmmesano AS CHAR EXTENT 12
        INIT ["JANEIRO","FEVEREIRO","MARCO","ABRIL","MAIO","JUNHO",
              "JULHO","AGOSTO","SETEMBRO","OUTUBRO","NOVEMBRO","DEZEMBRO"] 
                                                                       NO-UNDO.
                                                                    
/*............................ PROCEDURES EXTERNAS ...........................*/


/******************************************************************************/
/**           Procedure para obter cartoes magneticos do associado           **/
/******************************************************************************/
PROCEDURE obtem-cartoes-magneticos:
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
            
    DEF OUTPUT PARAM par_qtcarmag AS INTE                           NO-UNDO.
        
    DEF OUTPUT PARAM TABLE FOR tt-cartoes-magneticos.

    DEF VAR aux_tpcarcta AS INTE                                    NO-UNDO.
    
    DEF VAR aux_dssitcar AS CHAR                                    NO-UNDO.
    
    EMPTY TEMP-TABLE tt-cartoes-magneticos.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Obter cartoes magneticos do associado"
           aux_tpcarcta = IF  par_nmdatela = "ATENDA"  THEN
                              1
                          ELSE
                              9.
    
    FOR EACH crapcrm WHERE crapcrm.cdcooper = par_cdcooper AND
                           crapcrm.nrdconta = par_nrdconta AND
                           crapcrm.tpcarcta = aux_tpcarcta NO-LOCK:

        IF  crapcrm.cdsitcar = 2               AND
            crapcrm.dtvalcar >= par_dtmvtolt   THEN
            ASSIGN par_qtcarmag = par_qtcarmag + 1.
            
        FIND crapope WHERE crapope.cdcooper = par_cdcooper  AND
                           crapope.cdoperad = par_cdoperad  NO-LOCK NO-ERROR.
                           
        IF  NOT AVAILABLE crapope  THEN
            DO:
                ASSIGN aux_cdcritic = 67
                       aux_dscritic = "".

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                                       
                IF  par_flgerlog  THEN
                    RUN proc_gerar_log (INPUT par_cdcooper,
                                        INPUT par_cdoperad,
                                        INPUT aux_dscritic,
                                        INPUT aux_dsorigem,
                                        INPUT aux_dstransa,
                                        INPUT FALSE,
                                        INPUT par_idseqttl,
                                        INPUT par_nmdatela,
                                        INPUT par_nrdconta,
                                        OUTPUT aux_nrdrowid).
     
                RETURN "NOK".               
            END.

        /** Mostra todos os cartoes somente para SUPER-USUARIO **/
        /** Despreza cancelados e vencidos ha mais de 180 dias **/
        IF  crapope.cddepart <> 20                AND   /* TI */
            ((crapcrm.cdsitcar = 3 AND 
            crapcrm.dtcancel < (par_dtmvtolt - 180))   OR
            (crapcrm.cdsitcar = 2  AND 
            crapcrm.dtvalcar < (par_dtmvtolt - 180)))  THEN
            NEXT. 

        RUN verifica-situacao-cartao (INPUT par_cdcooper,           
                                      INPUT par_dtmvtolt,
                                      INPUT crapcrm.dtvalcar,
                                      INPUT crapcrm.cdsitcar,
                                      INPUT crapcrm.dtemscar,
                                     OUTPUT aux_dssitcar).
        
        CREATE tt-cartoes-magneticos.
        ASSIGN tt-cartoes-magneticos.nmtitcrd = crapcrm.nmtitcrd
               tt-cartoes-magneticos.nrcartao = STRING(crapcrm.nrcartao,
                                                       "9999,9999,9999,9999")
               tt-cartoes-magneticos.dssitcar = aux_dssitcar
               tt-cartoes-magneticos.tpusucar = crapcrm.tpusucar.
         
    END. /** Fim do FOR EACH crapcrm **/
    
    IF  par_flgerlog  THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT "",
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT TRUE,
                            INPUT par_idseqttl,
                            INPUT par_nmdatela,
                            INPUT par_nrdconta,
                           OUTPUT aux_nrdrowid).
                       
    RETURN "OK".                                                   
    
END.


/******************************************************************************/
/**           Procedure para consultar dados de cartoes magneticos           **/
/******************************************************************************/
PROCEDURE consulta-cartao-magnetico:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcartao AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
            
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-dados-carmag.

    DEF VAR aux_nmoperad AS CHAR                                    NO-UNDO.
    DEF VAR aux_dssitcar AS CHAR                                    NO-UNDO.
                                      
    EMPTY TEMP-TABLE tt-dados-carmag.
    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Consulta dados de cartao magnetico".

    FIND crapcrm WHERE crapcrm.cdcooper = par_cdcooper AND
                       crapcrm.nrdconta = par_nrdconta AND
                       crapcrm.nrcartao = par_nrcartao NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapcrm THEN
        DO:
            ASSIGN aux_cdcritic = 546
                   aux_dscritic = "".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                   
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
     
            RETURN "NOK".            
        END.
        
    IF  crapcrm.tpcarcta = 1  THEN
        DO:
            FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                               crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
           
            IF  NOT AVAILABLE crapass THEN
                DO:
                    ASSIGN aux_cdcritic = 9
                           aux_dscritic = "".
                   
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                                       
                    IF  par_flgerlog  THEN
                        RUN proc_gerar_log (INPUT par_cdcooper,
                                            INPUT par_cdoperad,
                                            INPUT aux_dscritic,
                                            INPUT aux_dsorigem,
                                            INPUT aux_dstransa,
                                            INPUT FALSE,
                                            INPUT par_idseqttl,
                                            INPUT par_nmdatela,
                                            INPUT par_nrdconta,
                                           OUTPUT aux_nrdrowid).
     
                    RETURN "NOK".            
                END.
        END.                       
                       
    FIND crapope WHERE crapope.cdcooper = par_cdcooper     AND
                       crapope.cdoperad = crapcrm.cdoperad NO-LOCK NO-ERROR.
   
    IF  NOT AVAILABLE crapope  THEN
        ASSIGN aux_nmoperad = "NAO CADASTRADO".
    ELSE
        ASSIGN aux_nmoperad = crapope.nmoperad.

    RUN verifica-situacao-cartao (INPUT par_cdcooper,           
                                  INPUT par_dtmvtolt,
                                  INPUT crapcrm.dtvalcar,
                                  INPUT crapcrm.cdsitcar,
                                  INPUT crapcrm.dtemscar,
                                 OUTPUT aux_dssitcar).
                    
    CREATE tt-dados-carmag.
    ASSIGN tt-dados-carmag.nrcartao = STRING(crapcrm.nrcartao,
                                             "9999,9999,9999,9999")
           tt-dados-carmag.nrseqcar = crapcrm.nrseqcar
           tt-dados-carmag.inpessoa = IF  crapcrm.tpcarcta = 1  THEN
                                          crapass.inpessoa
                                      ELSE
                                          1
           tt-dados-carmag.tpusucar = crapcrm.tpusucar
           tt-dados-carmag.dsusucar = IF  crapcrm.tpcarcta = 9  OR
                                          crapass.inpessoa = 1  THEN
                                          IF  crapcrm.tpusucar = 1  THEN 
                                              "(PRIMEIRO TITULAR)"
                                          ELSE
                                          IF  crapcrm.tpusucar = 2  THEN 
                                              "(SEGUNDO TITULAR)"
                                          ELSE 
                                              "(INDETERMINADO)"
                                      ELSE
                                          ""
           tt-dados-carmag.nmtitcrd = crapcrm.nmtitcrd           
           tt-dados-carmag.dtcancel = crapcrm.dtcancel  
           tt-dados-carmag.tpcarcta = crapcrm.tpcarcta
           tt-dados-carmag.dscarcta = IF  crapcrm.tpcarcta = 1  THEN 
                                          "CONTA-CORRENTE"
                                      ELSE
                                      IF  crapcrm.tpcarcta = 9  THEN 
                                          "OPERACAO"
                                      ELSE 
                                          "INDETERMINADO"      
           tt-dados-carmag.cdsitcar = crapcrm.cdsitcar
           tt-dados-carmag.dssitcar = aux_dssitcar
           tt-dados-carmag.nmoperad = aux_nmoperad      
           tt-dados-carmag.dttransa = crapcrm.dttransa  
           tt-dados-carmag.hrtransa = STRING(crapcrm.hrtransa,"HH:MM:SS") 
           tt-dados-carmag.dtentcrm = crapcrm.dtentcrm                         
           tt-dados-carmag.dtemscar = crapcrm.dtemscar  
           tt-dados-carmag.dtvalcar = crapcrm.dtvalcar.

    IF  par_flgerlog  THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT "",
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT TRUE,
                            INPUT par_idseqttl,
                            INPUT par_nmdatela,
                            INPUT par_nrdconta,
                           OUTPUT aux_nrdrowid).
                           
    RETURN "OK".

END PROCEDURE.


/******************************************************************************/
/**                Procedure para carregar prepostos da conta                **/
/******************************************************************************/
PROCEDURE obtem-prepostos:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
            
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-preposto-carmag.    

    DEF BUFFER crabass FOR crapass.

    EMPTY TEMP-TABLE tt-preposto-carmag.
    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Obter prepostos da conta para cartao magnetico".
           
    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
                               
    IF  NOT AVAILABLE crapass  THEN
        DO:
            ASSIGN aux_cdcritic = 9
                   aux_dscritic = "".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                      
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
     
            RETURN "NOK".
        END.

    IF  crapass.inpessoa > 1  THEN
        DO:
            FIND FIRST crapavt WHERE crapavt.cdcooper = par_cdcooper         AND
                                     crapavt.tpctrato = 6                    AND
                                     crapavt.nrdconta = par_nrdconta         AND
                                     CAN-DO("SOCIO/PROPRIETARIO,SOCIO ADMINISTRADOR,DIRETOR/ADMINISTRADOR,SINDICO,ADMINISTRADOR", crapavt.dsproftl)
                                     NO-LOCK NO-ERROR.
                                 
            IF  NOT AVAILABLE crapavt  THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Para continuar a operacao e " +
                                          "necessario cadastrar um SOCIO/" +
                                          "PROPRIETARIO. Va para tela CONTAS.".
                            
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                                       
                    IF  par_flgerlog  THEN
                        RUN proc_gerar_log (INPUT par_cdcooper,
                                            INPUT par_cdoperad,
                                            INPUT aux_dscritic,
                                            INPUT aux_dsorigem,
                                            INPUT aux_dstransa,
                                            INPUT FALSE,
                                            INPUT par_idseqttl,
                                            INPUT par_nmdatela,
                                            INPUT par_nrdconta,
                                           OUTPUT aux_nrdrowid).
         
                    RETURN "NOK".            
                END.
                            
            FOR EACH crapavt WHERE crapavt.cdcooper = par_cdcooper AND
                  /** Juridica **/ crapavt.tpctrato = 6            AND
                                   crapavt.nrdconta = par_nrdconta NO-LOCK:

                CREATE tt-preposto-carmag.
                ASSIGN tt-preposto-carmag.nrdctato = crapavt.nrdctato
                       tt-preposto-carmag.nmdavali = crapavt.nmdavali
                       tt-preposto-carmag.nrcpfcgc = crapavt.nrcpfcgc
                       tt-preposto-carmag.dscpfcgc = STRING(STRING(
                                                            crapavt.nrcpfcgc,
                                                            "99999999999"),
                                                            "xxx.xxx.xxx-xx")
                       tt-preposto-carmag.dsproftl = crapavt.dsproftl.

                /** Se associado, pega os dados da crapass **/
                IF  crapavt.nrdctato <> 0  THEN
                    DO:
                        FIND crabass WHERE 
                             crabass.cdcooper = par_cdcooper     AND
                             crabass.nrdconta = crapavt.nrdctato 
                             NO-LOCK NO-ERROR.
                        
                        IF  AVAILABLE crabass  THEN
                            ASSIGN tt-preposto-carmag.nmdavali =
                                                               crabass.nmprimtl
                                   tt-preposto-carmag.nrcpfcgc =
                                                               crabass.nrcpfcgc
                                   tt-preposto-carmag.dscpfcgc =
                                               STRING(STRING(crabass.nrcpfcgc,
                                               "99999999999"),"xxx.xxx.xxx-xx").
                    END.
                    
                /** Verifica se e o preposto atual **/
                IF  tt-preposto-carmag.nrcpfcgc = crapass.nrcpfppt  THEN
                    ASSIGN tt-preposto-carmag.flgatual = TRUE.
                ELSE
                    ASSIGN tt-preposto-carmag.flgatual = FALSE.
                                
            END. /** Fim do FOR EACH crapavt **/
        END.

    RETURN "OK".

END PROCEDURE.


/******************************************************************************/
/**          Procedure para atualizar preposto do cartao magnetico           **/
/******************************************************************************/
PROCEDURE atualizar-preposto:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfppt AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    
    DEF VAR aux_nrcpfppt AS DECI                                    NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Atualizar preposto para cartao magnetico".

    IF  par_nrcpfppt = 0  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Selecione um preposto.".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                             
            IF  par_flgerlog  THEN                           
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
                                           
            RETURN "NOK".    
        END.

    ASSIGN aux_flgtrans = FALSE.
    
    TRANSACAO:
    
    DO TRANSACTION ON ERROR UNDO TRANSACAO, LEAVE TRANSACAO:
    
        DO aux_contador = 1 TO 10:
        
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "".
            
            FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                               crapass.nrdconta = par_nrdconta 
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
            IF  NOT AVAILABLE crapass  THEN   
                DO:
                    IF  LOCKED crapass  THEN
                        DO:
                            ASSIGN aux_dscritic = "Registro do associado esta" +
                                                  " sendo alterado. Tente " +
                                                  "novamente.".
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        ASSIGN aux_cdcritic = 9.
                END.

            LEAVE.

        END. /** Fim do DO ... TO **/

        IF  aux_cdcritic > 0 OR aux_dscritic <> ""  THEN
            DO:
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                                             
                UNDO TRANSACAO, LEAVE TRANSACAO.                           
            END.

        IF  par_nrcpfppt <> crapass.nrcpfppt  THEN 
            DO:
                FIND FIRST crapavt WHERE crapavt.cdcooper = par_cdcooper AND
                                         crapavt.tpctrato = 6            AND
                                         crapavt.nrdconta = par_nrdconta AND
                                         crapavt.nrcpfcgc = par_nrcpfppt
                                         NO-LOCK NO-ERROR.
                                     
                IF  NOT AVAILABLE crapavt  THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Preposto invalido.".
                       
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,            /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
                                                 
                        UNDO TRANSACAO, LEAVE TRANSACAO.
                    END.

                ASSIGN aux_nrcpfppt     = crapass.nrcpfppt
                       crapass.nrcpfppt = par_nrcpfppt.

                IF  par_flgerlog  THEN
                    DO:
                        RUN proc_gerar_log (INPUT par_cdcooper,
                                            INPUT par_cdoperad,
                                            INPUT "",
                                            INPUT aux_dsorigem,
                                            INPUT aux_dstransa,
                                            INPUT TRUE,
                                            INPUT par_idseqttl,
                                            INPUT par_nmdatela,
                                            INPUT par_nrdconta,
                                           OUTPUT aux_nrdrowid).
                       
                        RUN proc_gerar_log_item 
                                      (INPUT aux_nrdrowid,
                                       INPUT "nrcpfcgc",
                                       INPUT STRING(STRING(aux_nrcpfppt,
                                              "99999999999"),"xxx.xxx.xxx-xx"),
                                       INPUT STRING(STRING(par_nrcpfppt, 
                                              "99999999999"),"xxx.xxx.xxx-xx")).
                    END.
            END.
        
        ASSIGN aux_flgtrans = TRUE.
        
    END. /** Fim do DO TRANSACTION - TRANSACAO **/

    /** Verifica se transacao foi executada com sucesso **/
    IF  NOT aux_flgtrans  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  NOT AVAILABLE tt-erro  THEN
                DO:                
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Nao foi possivel atualizar o " +
                                          "preposto.".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                END.                              
            
            IF  par_flgerlog  THEN                           
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
                   
            RETURN "NOK".
        END.

    RETURN "OK".        

END PROCEDURE.


/******************************************************************************/
/**    Procedure que verifica permissao para solicitar/alterar novo cartao   **/
/******************************************************************************/
PROCEDURE obtem-permissao-solicitacao:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcartao AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
            
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-dados-carmag.
    DEF OUTPUT PARAM TABLE FOR tt-titular-magnetico.

    DEF VAR h-b1wgen0001 AS HANDLE                                  NO-UNDO.
    
    DEF VAR aux_nmtitcrd AS CHAR                                    NO-UNDO.
    
    EMPTY TEMP-TABLE tt-dados-carmag.
    EMPTY TEMP-TABLE tt-titular-magnetico.
    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Obter dados para alterar/incluir cartao magnetico". 
    

    /*******************************************************************/
    /** Quando par_nrcartao = 0, solicitacao de novo cartao magnetico **/
    /** Quando par_nrcartao > 0, alteracao na solicitacao do cartao   **/
    /*******************************************************************/
    
    IF  par_nrcartao = 0  THEN
        DO: 

            /***********************************************************/
            /** Bloquear solicitação de Cartao para o PAC 5 Coop 2    **/
            /***********************************************************/
            
            IF  par_cdcooper = 2 THEN
                DO:
                    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                       crapass.nrdconta = par_nrdconta AND
                                       crapass.cdagenci = 5
                                       NO-LOCK NO-ERROR.
        
                    IF  AVAIL crapass THEN
                        DO:
                            ASSIGN aux_cdcritic = 0
                                   aux_dscritic = "Solicitacao nao permitida. " +
                                                  "Transferencia do PA.".
    
                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT 1,            /** Sequencia **/
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).
    
                            IF  par_flgerlog  THEN
                                RUN proc_gerar_log (INPUT par_cdcooper,
                                                    INPUT par_cdoperad,
                                                    INPUT aux_dscritic,
                                                    INPUT aux_dsorigem,
                                                    INPUT aux_dstransa,
                                                    INPUT FALSE,
                                                    INPUT par_idseqttl,
                                                    INPUT par_nmdatela,
                                                    INPUT par_nrdconta,
                                                    OUTPUT aux_nrdrowid).
                            RETURN "NOK".
    
                        END.
                END.
            /***********************************************************/

            FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
            
            IF  NOT AVAILABLE crapcop  THEN
                DO:
                    ASSIGN aux_cdcritic = 651
                           aux_dscritic = "".
                   
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                                       
                    IF  par_flgerlog  THEN
                        RUN proc_gerar_log (INPUT par_cdcooper,
                                            INPUT par_cdoperad,
                                            INPUT aux_dscritic,
                                            INPUT aux_dsorigem,
                                            INPUT aux_dstransa,
                                            INPUT FALSE,
                                            INPUT par_idseqttl,
                                            INPUT par_nmdatela,
                                            INPUT par_nrdconta,
                                           OUTPUT aux_nrdrowid).
     
                    RETURN "NOK".
                END.
                  
            IF  NOT crapcop.flgcrmag  THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Cooperativa nao utiliza cartao " +
                                          "magnetico.".
                   
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                                       
                    IF  par_flgerlog  THEN
                        RUN proc_gerar_log (INPUT par_cdcooper,
                                            INPUT par_cdoperad,
                                            INPUT aux_dscritic,
                                            INPUT aux_dsorigem,
                                            INPUT aux_dstransa,
                                            INPUT FALSE,
                                            INPUT par_idseqttl,
                                            INPUT par_nmdatela,
                                            INPUT par_nrdconta,
                                           OUTPUT aux_nrdrowid).
     
                    RETURN "NOK".
                END.
            
            { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
            
            RUN STORED-PROCEDURE pc_valida_adesao_produto
            aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper, /* Cooperativa */
                                                 INPUT par_nrdconta, /* Numero da conta */
                                                 INPUT 5,            /* Codigo do produto */
                                                OUTPUT 0,            /* Codigo da crítica */
                                                OUTPUT "").          /* Descriçao da crítica */
            
            CLOSE STORED-PROC pc_valida_adesao_produto
                  aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
            
            { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
            
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = ""
                   aux_cdcritic = pc_valida_adesao_produto.pr_cdcritic 
                                  WHEN pc_valida_adesao_produto.pr_cdcritic <> ?
                   aux_dscritic = pc_valida_adesao_produto.pr_dscritic
                                  WHEN pc_valida_adesao_produto.pr_dscritic <> ?.
            
            IF aux_cdcritic > 0 OR aux_dscritic <> ""  THEN
                 DO:
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                                       
                    IF  par_flgerlog  THEN
                        RUN proc_gerar_log (INPUT par_cdcooper,
                                            INPUT par_cdoperad,
                                            INPUT aux_dscritic,
                                            INPUT aux_dsorigem,
                                            INPUT aux_dstransa,
                                            INPUT FALSE,
                                            INPUT par_idseqttl,
                                            INPUT par_nmdatela,
                                            INPUT par_nrdconta,
                                           OUTPUT aux_nrdrowid).
     
                    RETURN "NOK".
                END.
        END.
        

    IF  par_nmdatela = "ATENDA"  THEN
        DO:
            FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                               crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
           
            IF  NOT AVAILABLE crapass THEN
                DO:
                    ASSIGN aux_cdcritic = 9
                           aux_dscritic = "".
                   
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                                       
                    IF  par_flgerlog  THEN
                        RUN proc_gerar_log (INPUT par_cdcooper,
                                            INPUT par_cdoperad,
                                            INPUT aux_dscritic,
                                            INPUT aux_dsorigem,
                                            INPUT aux_dstransa,
                                            INPUT FALSE,
                                            INPUT par_idseqttl,
                                            INPUT par_nmdatela,
                                            INPUT par_nrdconta,
                                           OUTPUT aux_nrdrowid).
     
                    RETURN "NOK".            
                END.
            
            RUN sistema/generico/procedures/b1wgen0001.p 
                PERSISTENT SET h-b1wgen0001.
        
            IF  VALID-HANDLE(h-b1wgen0001)  THEN
                DO: 
                    RUN ver_capital IN h-b1wgen0001 (INPUT par_cdcooper,
                                                     INPUT par_nrdconta,
                                                     INPUT par_cdagenci, 
                                                     INPUT par_nrdcaixa, 
                                                     INPUT 0,
                                                     INPUT par_dtmvtolt,
                                                     INPUT "B1WGEN0032",
                                                     INPUT par_idorigem, 
                                                    OUTPUT TABLE tt-erro).
                                
                    IF  RETURN-VALUE = "OK"  THEN
                        RUN ver_cadastro IN h-b1wgen0001 (INPUT par_cdcooper,
                                                          INPUT par_nrdconta,
                                                          INPUT par_cdagenci,
                                                          INPUT par_nrdcaixa,
                                                          INPUT par_dtmvtolt,
                                                          INPUT par_idorigem,
                                                         OUTPUT TABLE tt-erro).
                
                    DELETE PROCEDURE h-b1wgen0001.
                
                    IF  RETURN-VALUE = "NOK"  THEN
                        DO:
                            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
                            IF  AVAILABLE tt-erro  THEN
                                ASSIGN aux_dscritic = tt-erro.dscritic.
                    
                            IF  par_flgerlog  THEN
                                RUN proc_gerar_log (INPUT par_cdcooper,
                                                    INPUT par_cdoperad,
                                                    INPUT aux_dscritic,
                                                    INPUT aux_dsorigem,
                                                    INPUT aux_dstransa,
                                                    INPUT FALSE,
                                                    INPUT par_idseqttl,
                                                    INPUT par_nmdatela,
                                                    INPUT par_nrdconta,
                                                   OUTPUT aux_nrdrowid).
     
                            RETURN "NOK".
                        END.
                END.
            ELSE
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Handle invalido para BO b1wgen0001.".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                                 
                    IF  par_flgerlog  THEN
                        RUN proc_gerar_log (INPUT par_cdcooper,
                                            INPUT par_cdoperad,
                                            INPUT aux_dscritic,
                                            INPUT aux_dsorigem,
                                            INPUT aux_dstransa,
                                            INPUT FALSE,
                                            INPUT par_idseqttl,
                                            INPUT par_nmdatela,
                                            INPUT par_nrdconta,
                                           OUTPUT aux_nrdrowid).
     
                    RETURN "NOK".
                END.
                
            IF  par_nrcartao = 0  THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "".
                           
                    IF crapass.cdsitdct = 7 THEN
                      ASSIGN aux_dscritic = "Associado em processo de demissao!".
                    ELSE
                    IF  CAN-DO("5,6,7,8",STRING(crapass.cdsitdtl))  THEN
                        ASSIGN aux_cdcritic = 695.
                    ELSE
                    IF  CAN-DO("2,4,6,8",STRING(crapass.cdsitdtl))  THEN
                        ASSIGN aux_cdcritic = 95.
                    ELSE
                    IF  crapass.dtdemiss <> ?  THEN
                        ASSIGN aux_cdcritic = 75.
                
                    IF  aux_cdcritic > 0 OR aux_dscritic <> "" THEN
                        DO:
                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT 1,            /** Sequencia **/
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).
                                       
                            IF  par_flgerlog  THEN
                                RUN proc_gerar_log (INPUT par_cdcooper,
                                                    INPUT par_cdoperad,
                                                    INPUT aux_dscritic,
                                                    INPUT aux_dsorigem,
                                                    INPUT aux_dstransa,
                                                    INPUT FALSE,
                                                    INPUT par_idseqttl,
                                                    INPUT par_nmdatela,
                                                    INPUT par_nrdconta,
                                                   OUTPUT aux_nrdrowid).
     
                            RETURN "NOK".
                        END.

                    RUN abreviar (INPUT crapass.nmprimtl,
                                  INPUT 28,
                                 OUTPUT aux_nmtitcrd).
                         
                    CREATE tt-dados-carmag.
                    ASSIGN tt-dados-carmag.nrcartao = ""
                           tt-dados-carmag.nrseqcar = 0
                           tt-dados-carmag.inpessoa = crapass.inpessoa
                           tt-dados-carmag.tpusucar = 0
                           tt-dados-carmag.dsusucar = ""
                           tt-dados-carmag.nmtitcrd = aux_nmtitcrd                           
                           tt-dados-carmag.dtcancel = ?
                           tt-dados-carmag.dscarcta = "CONTA-CORRENTE"
                           tt-dados-carmag.cdsitcar = 0
                           tt-dados-carmag.dssitcar = "CARTAO NOVO"
                           tt-dados-carmag.nmoperad = ""      
                           tt-dados-carmag.dttransa = ?
                           tt-dados-carmag.hrtransa = ""
                           tt-dados-carmag.dtentcrm = ?
                           tt-dados-carmag.dtemscar = ?
                           tt-dados-carmag.dtvalcar = 
                             DATE(MONTH(par_dtmvtolt),28,
                                  YEAR(par_dtmvtolt) + 5) + 5
                           tt-dados-carmag.dtvalcar = tt-dados-carmag.dtvalcar -
                                                  DAY(tt-dados-carmag.dtvalcar).
                END.
            
            RUN abreviar (INPUT crapass.nmprimtl,
                                  INPUT 28,
                                 OUTPUT aux_nmtitcrd).
                
            CREATE tt-titular-magnetico.
            ASSIGN tt-titular-magnetico.tpusucar = 1
                   tt-titular-magnetico.dsusucar = "(PRIMEIRO TITULAR)"
                   tt-titular-magnetico.nmtitcrd = aux_nmtitcrd
                   tt-titular-magnetico.flusucar = FALSE.
                           
            IF  crapass.inpessoa = 1 THEN			    
                DO:
				    FOR FIRST crapttl FIELDS(nmextttl)
									  WHERE crapttl.cdcooper = crapass.cdcooper AND
									        crapttl.nrdconta = crapass.nrdconta AND
											crapttl.idseqttl = 2
											NO-LOCK:

					END.

					IF AVAIL crapttl THEN
					   DO:
						   RUN corrige_segtl (INPUT crapttl.nmextttl,
                                       OUTPUT aux_nmtitcrd).

                    RUN abreviar (INPUT aux_nmtitcrd,
                                  INPUT 28,
                                 OUTPUT aux_nmtitcrd).
                
                    CREATE tt-titular-magnetico.
                    ASSIGN tt-titular-magnetico.tpusucar = 2
                           tt-titular-magnetico.dsusucar = "(SEGUNDO TITULAR)"
                           tt-titular-magnetico.nmtitcrd = aux_nmtitcrd
                           tt-titular-magnetico.flusucar = FALSE.

					   END.

                END.
        END.
    ELSE
        DO:
            FIND crapope WHERE crapope.cdcooper = par_cdcooper         AND
                               crapope.cdoperad = STRING(par_nrdconta) 
                               NO-LOCK NO-ERROR.
                               
            IF  NOT AVAILABLE crapope  THEN
                DO:
                    ASSIGN aux_cdcritic = 67
                           aux_dscritic = "".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                                       
                    IF  par_flgerlog  THEN
                        RUN proc_gerar_log (INPUT par_cdcooper,
                                            INPUT par_cdoperad,
                                            INPUT aux_dscritic,
                                            INPUT aux_dsorigem,
                                            INPUT aux_dstransa,
                                            INPUT FALSE,
                                            INPUT par_idseqttl,
                                            INPUT par_nmdatela,
                                            INPUT par_nrdconta,
                                           OUTPUT aux_nrdrowid).
     
                    RETURN "NOK".               
                END.
                               
            IF  par_nrcartao = 0  THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "".
                           
                    IF  crapope.cdsitope = 2   THEN
                        ASSIGN aux_cdcritic = 627.
                    ELSE
                    IF  crapope.tpoperad = 1   THEN
                        ASSIGN aux_cdcritic = 628.
                
                    IF  aux_cdcritic > 0  THEN
                        DO:
                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT 1,            /** Sequencia **/
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).
                                           
                            IF  par_flgerlog  THEN
                                RUN proc_gerar_log (INPUT par_cdcooper,
                                                    INPUT par_cdoperad,
                                                    INPUT aux_dscritic,
                                                    INPUT aux_dsorigem,
                                                    INPUT aux_dstransa,
                                                    INPUT FALSE,
                                                    INPUT par_idseqttl,
                                                    INPUT par_nmdatela,
                                                    INPUT par_nrdconta,
                                                   OUTPUT aux_nrdrowid).
     
                            RETURN "NOK".
                        END.
                        
                    RUN abreviar (INPUT crapope.nmoperad,
                                  INPUT 28,
                                 OUTPUT aux_nmtitcrd).
                         
                    CREATE tt-dados-carmag.
                    ASSIGN tt-dados-carmag.nrcartao = ""
                           tt-dados-carmag.nrseqcar = 0
                           tt-dados-carmag.inpessoa = 1
                           tt-dados-carmag.tpusucar = 0
                           tt-dados-carmag.dsusucar = ""
                           tt-dados-carmag.nmtitcrd = aux_nmtitcrd
                           tt-dados-carmag.dtcancel = ?
                           tt-dados-carmag.dscarcta = "OPERACAO"
                           tt-dados-carmag.cdsitcar = 0
                           tt-dados-carmag.dssitcar = "CARTAO NOVO"
                           tt-dados-carmag.nmoperad = ""      
                           tt-dados-carmag.dttransa = ?
                           tt-dados-carmag.hrtransa = ""
                           tt-dados-carmag.dtentcrm = ?
                           tt-dados-carmag.dtemscar = ?
                           tt-dados-carmag.dtvalcar = 
                             DATE(MONTH(par_dtmvtolt),28,
                                  YEAR(par_dtmvtolt) + 5) + 5
                           tt-dados-carmag.dtvalcar = tt-dados-carmag.dtvalcar -
                                                  DAY(tt-dados-carmag.dtvalcar).
                END.
        END.

    IF  par_nrcartao > 0  THEN
        DO:
            RUN consulta-cartao-magnetico (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT par_cdoperad,
                                           INPUT par_nmdatela,
                                           INPUT par_idorigem,
                                           INPUT par_nrdconta,
                                           INPUT par_idseqttl,
                                           INPUT par_dtmvtolt,
                                           INPUT par_nrcartao,
                                           INPUT FALSE, /** LOG **/
                                          OUTPUT TABLE tt-erro,
                                          OUTPUT TABLE tt-dados-carmag).
        
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                    
                    IF  AVAILABLE tt-erro  THEN
                        ASSIGN aux_dscritic = tt-erro.dscritic.
                        
                    IF  par_flgerlog  THEN
                        RUN proc_gerar_log (INPUT par_cdcooper,
                                            INPUT par_cdoperad,
                                            INPUT aux_dscritic,
                                            INPUT aux_dsorigem,
                                            INPUT aux_dstransa,
                                            INPUT FALSE,
                                            INPUT par_idseqttl,
                                            INPUT par_nmdatela,
                                            INPUT par_nrdconta,
                                           OUTPUT aux_nrdrowid).
                
                    RETURN "NOK".
                END.
        
            FIND FIRST tt-dados-carmag NO-LOCK NO-ERROR.
            
            IF  AVAILABLE tt-dados-carmag  THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "".
                   
                    IF  tt-dados-carmag.cdsitcar <> 1  THEN
                        ASSIGN aux_cdcritic = 552.
                    ELSE
                    IF  tt-dados-carmag.dtemscar <> ?  THEN
                        ASSIGN aux_cdcritic = 629.
                
                    IF  aux_cdcritic > 0  THEN
                        DO:
                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT 1,            /** Sequencia **/
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).
                                           
                            IF  par_flgerlog  THEN
                                RUN proc_gerar_log (INPUT par_cdcooper,
                                                    INPUT par_cdoperad,
                                                    INPUT aux_dscritic,
                                                    INPUT aux_dsorigem,
                                                    INPUT aux_dstransa,
                                                    INPUT FALSE,
                                                    INPUT par_idseqttl,
                                                    INPUT par_nmdatela,
                                                    INPUT par_nrdconta,
                                                   OUTPUT aux_nrdrowid).
     
                            RETURN "NOK". 
                        END.
                END.

            FIND FIRST tt-titular-magnetico WHERE 
                       tt-titular-magnetico.tpusucar = tt-dados-carmag.tpusucar
                       EXCLUSIVE-LOCK NO-ERROR.
                       
            IF  AVAILABLE tt-titular-magnetico  THEN
                ASSIGN tt-titular-magnetico.flusucar = TRUE.
        END.

    IF  par_flgerlog  THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT "",
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT TRUE,
                            INPUT par_idseqttl,
                            INPUT par_nmdatela,
                            INPUT par_nrdconta,
                           OUTPUT aux_nrdrowid).
                               
    RETURN "OK".                               
              
END PROCEDURE.


/******************************************************************************/
/**                 Procedure para alterar cartao magnetico                  **/
/******************************************************************************/
PROCEDURE alterar-cartao-magnetico:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcartao AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tpusucar AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmtitcrd AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
            
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_tpusucar AS INTE                                    NO-UNDO.
    DEF VAR aux_nmtitcrd AS CHAR                                    NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Alterar cartao magnetico"
           aux_flgtrans = FALSE.
   
    TRANSACAO:
    
    DO TRANSACTION ON ERROR UNDO TRANSACAO, LEAVE TRANSACAO:
    
        DO aux_contador = 1 TO 10:
        
            ASSIGN aux_dscritic = "".
            
            FIND crapcrm WHERE crapcrm.cdcooper = par_cdcooper AND
                               crapcrm.nrdconta = par_nrdconta AND
                               crapcrm.nrcartao = par_nrcartao
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crapcrm  THEN
                DO:
                    IF  LOCKED crapcrm  THEN
                        DO:
                            aux_dscritic = "Registro do cartao magnetico esta" +
                                           " sendo alterado.".
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        aux_dscritic = "Cartao magnetico nao cadastrado.".
                END.
        
            LEAVE.
            
        END. /** Fim do DO .. TO **/
        
        IF  aux_dscritic <> ""  THEN
            DO:
                ASSIGN aux_cdcritic = 0.

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                                   
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.
            
        RUN valida-dados-cartao (INPUT par_cdcooper,  
                                 INPUT par_nrdconta,
                                 INPUT par_nrcartao, 
                                 INPUT crapcrm.tpcarcta,
                                 INPUT par_nmtitcrd,
                                 INPUT par_tpusucar).
                                 
        IF  aux_cdcritic <> 0 OR aux_dscritic <> ""  THEN
            DO:
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                                   
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.
                             
        ASSIGN aux_nmtitcrd     = crapcrm.nmtitcrd
               aux_tpusucar     = crapcrm.tpusucar
               crapcrm.nmtitcrd = CAPS(par_nmtitcrd)
               crapcrm.dttransa = par_dtmvtolt
               crapcrm.hrtransa = TIME
               crapcrm.cdoperad = par_cdoperad
               crapcrm.tpusucar = par_tpusucar 
               aux_flgtrans     = TRUE.
    
    END. /** Fim do DO TRANSACTION - TRANSACAO **/
    
    /** Verifica se transacao foi executada com sucesso **/
    IF  NOT aux_flgtrans  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  NOT AVAILABLE tt-erro  THEN
                DO:                
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Nao foi possivel alterar o cartao " +
                                          "magnetico.".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                END.
                                                   
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
                   
            RETURN "NOK".
        END.

    IF  par_flgerlog  THEN
        DO:
            RUN proc_gerar_log (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT "",
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT TRUE,
                                INPUT par_idseqttl,
                                INPUT par_nmdatela,
                                INPUT par_nrdconta,
                               OUTPUT aux_nrdrowid).

            /** Numero do Cartao Magnetico **/
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "nrcartao",
                                     INPUT "",
                                     INPUT STRING(par_nrcartao,
                                                  "9999,9999,9999,9999")).

            /** Usuario do Cartao **/
            IF  aux_tpusucar <> par_tpusucar  THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "tpusucar",
                                         INPUT STRING(aux_tpusucar),
                                         INPUT STRING(par_tpusucar)).
                                         
            /** Nome do Titular do Cartao **/
            IF  aux_nmtitcrd <> par_nmtitcrd  THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "nmtitcrd",
                                         INPUT aux_nmtitcrd,
                                         INPUT par_nmtitcrd).
                                         
        END.

    RETURN "OK".
    
END PROCEDURE.


/******************************************************************************/
/**               Procedure para incluir novo cartao magnetico               **/
/******************************************************************************/
PROCEDURE incluir-cartao-magnetico:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_tpcarcta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpusucar AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmtitcrd AS CHAR                           NO-UNDO.        
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
            
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_nrseqcar AS INTE                                    NO-UNDO.
    
    DEF VAR aux_dtvalcar AS DATE                                    NO-UNDO.
    
    DEF VAR aux_nrcartao AS DECI                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Incluir cartao magnetico"
           aux_flgtrans = FALSE.
    
    RUN valida-dados-cartao (INPUT par_cdcooper,
                             INPUT par_nrdconta, 
                             INPUT 0,               /** Numero Cartao **/
                             INPUT par_tpcarcta,
                             INPUT par_nmtitcrd,
                             INPUT par_tpusucar).
                                 
    IF  aux_cdcritic <> 0 OR aux_dscritic <> ""  THEN
        DO:           
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                   
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
            
            RETURN "NOK".
        END.
            
    TRANSACAO:
    
    DO TRANSACTION ON ERROR UNDO TRANSACAO, LEAVE TRANSACAO:

        /* Busca a proxima sequencia do campo CRAPMAT.NRSEQCAR */
    	RUN STORED-PROCEDURE pc_sequence_progress
    	aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPMAT"
    										,INPUT "NRSEQCAR"
    										,INPUT STRING(par_cdcooper)
    										,INPUT "N"
    										,"").
    	
    	CLOSE STORED-PROC pc_sequence_progress
    	aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    			  
    	ASSIGN aux_nrseqcar = INTE(pc_sequence_progress.pr_sequence)
    						  WHEN pc_sequence_progress.pr_sequence <> ?.

        ASSIGN aux_dtvalcar = DATE(MONTH(par_dtmvtolt),28,
                                   YEAR(par_dtmvtolt) + 5) + 5    
               aux_dtvalcar = aux_dtvalcar - DAY(aux_dtvalcar)
               aux_nrcartao = DECI(STRING(par_tpcarcta,"9") + 
                                   STRING(aux_nrseqcar,"999999") +
                                   STRING(par_nrdconta,"99999999") +
                                   STRING(par_tpusucar,"9")).
            
        /* Inicio - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
        IF par_cdagenci = 0 THEN
          ASSIGN par_cdagenci = glb_cdagenci.
        /* Fim - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */

        CREATE crapcrm.
        ASSIGN crapcrm.cdcooper = par_cdcooper
               crapcrm.nrseqcar = aux_nrseqcar
               crapcrm.nrdconta = par_nrdconta
               crapcrm.nmtitcrd = CAPS(par_nmtitcrd)
               crapcrm.nrcartao = aux_nrcartao 
               crapcrm.cdsitcar = 1
               crapcrm.dtcancel = ?
               crapcrm.dtemscar = ?
               crapcrm.dtvalcar = aux_dtvalcar 
               crapcrm.tpusucar = par_tpusucar
               crapcrm.nrviacar = 1
               crapcrm.tpcarcta = par_tpcarcta
               crapcrm.tptitcar = par_tpcarcta
               crapcrm.dssencar = "TARIFA"
               crapcrm.dttransa = par_dtmvtolt
               crapcrm.hrtransa = TIME
               crapcrm.cdoperad = par_cdoperad
               /* Inicio - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
               crapcrm.cdopeori = par_cdoperad
               crapcrm.cdageori = par_cdagenci
               crapcrm.dtinsori = TODAY
               /* Fim - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
               aux_flgtrans     = TRUE.
        VALIDATE crapcrm.
    
    END. /** Fim do DO TRANSACTION - TRANSACAO **/
    
    /** Verifica se transacao foi executada com sucesso **/
    IF  NOT aux_flgtrans  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  NOT AVAILABLE tt-erro  THEN
                DO:                
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Nao foi possivel incluir o cartao " +
                                          "magnetico.".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                END.
                                                 
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
                   
            RETURN "NOK".
        END.

    IF  par_flgerlog  THEN
        DO:
            RUN proc_gerar_log (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT "",
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT TRUE,
                                INPUT par_idseqttl,
                                INPUT par_nmdatela,
                                INPUT par_nrdconta,
                               OUTPUT aux_nrdrowid).

            /** Numero do Cartao Magnetico **/
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "nrcartao",
                                     INPUT "",
                                     INPUT STRING(aux_nrcartao,
                                                  "9999,9999,9999,9999")).
                                                  
            /** Nome do Titular do Cartao **/
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "nmtitcrd",
                                     INPUT "",
                                     INPUT par_nmtitcrd).
                                     
            /** Tipo de Usuario do Cartao **/
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "tpcarcta",
                                     INPUT "",
                                     INPUT TRIM(STRING(par_tpcarcta))).
                                                 
            /** Titular do Cartao **/
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "tpusucar",
                                     INPUT "",
                                     INPUT TRIM(STRING(par_tpusucar))).
                                     
        END.

    RETURN "OK".
    
END PROCEDURE.


/******************************************************************************/
/**                  Procedure para excluir cartao magnetico                 **/
/******************************************************************************/
PROCEDURE excluir-cartao-magnetico:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcartao AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
            
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Excluir cartao magnetico"
           aux_flgtrans = FALSE.

    TRANSACAO:
    
    DO TRANSACTION ON ERROR UNDO TRANSACAO, LEAVE TRANSACAO:
    
        DO aux_contador = 1 TO 10:
        
            ASSIGN aux_dscritic = "".
            
            FIND crapcrm WHERE crapcrm.cdcooper = par_cdcooper AND
                               crapcrm.nrdconta = par_nrdconta AND
                               crapcrm.nrcartao = par_nrcartao
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crapcrm  THEN
                DO:
                    IF  LOCKED crapcrm  THEN
                        DO:
                            aux_dscritic = "Registro do cartao magnetico esta" +
                                           " sendo alterado.".
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        aux_dscritic = "Cartao magnetico nao cadastrado.".
                END.
        
            LEAVE.
            
        END. /** Fim do DO .. TO **/
        
        IF  aux_dscritic <> ""  THEN
            DO:
                ASSIGN aux_cdcritic = 0.

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                                   
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.
            
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "".
               
        IF  crapcrm.cdsitcar <> 1  THEN
            ASSIGN aux_cdcritic = 552.
        ELSE
        IF  crapcrm.dtemscar <> ?  THEN
            ASSIGN aux_cdcritic = 629.

        IF  aux_cdcritic > 0  THEN
            DO:
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                                   
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.

        DELETE crapcrm.
        
        ASSIGN aux_flgtrans = TRUE.
    
    END. /** Fim do DO TRANSACTION - TRANSACAO **/
    
    /** Verifica se transacao foi executada com sucesso **/
    IF  NOT aux_flgtrans  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  NOT AVAILABLE tt-erro  THEN
                DO:                
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Nao foi possivel excluir o cartao " +
                                          "magnetico.".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                END.
                                                   
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
                   
            RETURN "NOK".
        END.

    IF  par_flgerlog  THEN
        DO:
            RUN proc_gerar_log (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT "",
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT TRUE,
                                INPUT par_idseqttl,
                                INPUT par_nmdatela,
                                INPUT par_nrdconta,
                               OUTPUT aux_nrdrowid).

            /** Numero do Cartao Magnetico **/
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "nrcartao",
                                     INPUT "",
                                     INPUT STRING(par_nrcartao,
                                                  "9999,9999,9999,9999")).
        END.

    RETURN "OK".
    
END PROCEDURE.


/******************************************************************************/
/**                 Procedure para bloquear cartao magnetico                 **/
/******************************************************************************/
PROCEDURE bloquear-cartao-magnetico:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcartao AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
            
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nrcartao AS CHAR                                    NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.
    DEF VAR aux_cdcritic AS INTE                                    NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_nrcartao = STRING(par_nrcartao).

              
   { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

   RUN STORED-PROCEDURE pc_bloquear_cartao_magnetico
         aux_handproc = PROC-HANDLE NO-ERROR
                      (INPUT  par_cdcooper, 
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                                    INPUT par_cdoperad,
                       INPUT  par_nmdatela,
                       INPUT  par_idorigem,
                       INPUT  par_nrdconta, 
                                    INPUT par_idseqttl,
                       INPUT  par_dtmvtolt,
                       INPUT  aux_nrcartao,
                       INPUT  IF par_flgerlog THEN "S" ELSE "N", 
                       
                       OUTPUT 0,
                       OUTPUT "",
                       OUTPUT "").
                       
    CLOSE STORED-PROC pc_bloquear_cartao_magnetico 
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.   
          
   { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }  
   
     ASSIGN aux_cdcritic = pc_bloquear_cartao_magnetico.pr_cdcritic
                             WHEN pc_bloquear_cartao_magnetico.pr_cdcritic <> ?
           aux_dscritic  = pc_bloquear_cartao_magnetico.pr_dscritic 
                             WHEN pc_bloquear_cartao_magnetico.pr_dscritic <> ?.
 
     IF  aux_cdcritic <> 0   OR
        aux_dscritic <> ""  THEN
        DO:                                  
            CREATE tt-erro.
            ASSIGN tt-erro.cdcritic = aux_cdcritic
                   tt-erro.dscritic = aux_dscritic.
                   
            RETURN "NOK".
        END.

    IF  par_flgerlog  THEN
        DO:
            RUN proc_gerar_log (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT "",
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT TRUE,
                                INPUT par_idseqttl,
                                INPUT par_nmdatela,
                                INPUT par_nrdconta,
                               OUTPUT aux_nrdrowid).

            /** Numero do Cartao Magnetico **/
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "nrcartao",
                                     INPUT "",
                                     INPUT STRING(par_nrcartao,
                                                  "9999,9999,9999,9999")).
                                     
            /** Situacao do cartao **/
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "cdsitcar",
                                     INPUT "2",
                                     INPUT "4").
        END.

    RETURN "OK".
    
END PROCEDURE.


/******************************************************************************/
/**                 Procedure para cancelar cartao magnetico                 **/
/******************************************************************************/
PROCEDURE cancelar-cartao-magnetico:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcartao AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
            
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Cancelar cartao magnetico"
           aux_flgtrans = FALSE.

    TRANSACAO:
    
    DO TRANSACTION ON ERROR UNDO TRANSACAO, LEAVE TRANSACAO:
    
        DO aux_contador = 1 TO 10:
        
            ASSIGN aux_dscritic = "".
            
            FIND crapcrm WHERE crapcrm.cdcooper = par_cdcooper AND
                               crapcrm.nrdconta = par_nrdconta AND
                               crapcrm.nrcartao = par_nrcartao
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crapcrm  THEN
                DO:
                    IF  LOCKED crapcrm  THEN
                        DO:
                            aux_dscritic = "Registro do cartao magnetico esta" +
                                           " sendo alterado.".
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        aux_dscritic = "Cartao magnetico nao cadastrado.".
                END.
        
            LEAVE.
            
        END. /** Fim do DO .. TO **/
        
        IF  aux_dscritic <> ""  THEN
            DO:
                ASSIGN aux_cdcritic = 0.

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                                   
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.
        
        IF  crapcrm.cdsitcar <> 2  THEN
            DO:
                ASSIGN aux_cdcritic = 538
                       aux_dscritic = "".

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                                   
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.

        ASSIGN crapcrm.cdsitcar = 3
               crapcrm.dtcancel = par_dtmvtolt
               crapcrm.dttransa = par_dtmvtolt
               crapcrm.hrtransa = TIME
               crapcrm.cdoperad = par_cdoperad               
               aux_flgtrans     = TRUE.
    
    END. /** Fim do DO TRANSACTION - TRANSACAO **/
    
    /** Verifica se transacao foi executada com sucesso **/
    IF  NOT aux_flgtrans  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  NOT AVAILABLE tt-erro  THEN
                DO:                
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Nao foi possivel bloquear o cartao" +
                                          " magnetico.".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                END.                                               
                    
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
                   
            RETURN "NOK".
        END.

    IF  par_flgerlog  THEN
        DO:
            RUN proc_gerar_log (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT "",
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT TRUE,
                                INPUT par_idseqttl,
                                INPUT par_nmdatela,
                                INPUT par_nrdconta,
                               OUTPUT aux_nrdrowid).

            /** Numero do Cartao Magnetico **/
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "nrcartao",
                                     INPUT "",
                                     INPUT STRING(par_nrcartao,
                                                  "9999,9999,9999,9999")).
                                     
            /** Situacao do cartao **/
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "cdsitcar",
                                     INPUT "2",
                                     INPUT "3").
        END.

    RETURN "OK".
    
END PROCEDURE.


/******************************************************************************/
/**                 Procedure para entregar cartao magnetico                 **/
/******************************************************************************/
PROCEDURE entregar-cartao-magnetico:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcartao AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dssenatu AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dssencar AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dssencon AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
            
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF BUFFER crabcrm FOR crapcrm.
    
    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    
    DEF VAR aux_cdsitcar AS INTE                                    NO-UNDO.
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    
    DEF VAR aux_dtcancel AS DATE                                    NO-UNDO.
    DEF VAR aux_dtentcrm AS DATE                                    NO-UNDO.
    
    DEF VAR aux_dssitcar AS CHAR                           NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Entregar cartao magnetico"
           aux_flgtrans = FALSE.

    TRANSACAO:
    
    DO TRANSACTION ON ERROR UNDO TRANSACAO, LEAVE TRANSACAO:
    
        DO aux_contador = 1 TO 10:
        
            ASSIGN aux_dscritic = "".
            
            FIND crapcrm WHERE crapcrm.cdcooper = par_cdcooper AND
                               crapcrm.nrdconta = par_nrdconta AND
                               crapcrm.nrcartao = par_nrcartao
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crapcrm  THEN
                DO:
                    IF  LOCKED crapcrm  THEN
                        DO:
                            aux_dscritic = "Registro do cartao magnetico esta" +
                                           " sendo alterado.".
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        aux_dscritic = "Cartao magnetico nao cadastrado.".
                END.
        
            LEAVE.
            
        END. /** Fim do DO .. TO **/
        
        IF  aux_dscritic <> ""  THEN
            DO:
                ASSIGN aux_cdcritic = 0.

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                                   
                UNDO TRANSACAO, LEAVE TRANSACAO.

            END.

        IF  crapcrm.cdsitcar = 2  THEN
            DO:
                ASSIGN aux_cdcritic = 552
                       aux_dscritic = "".
                       
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                                   
                UNDO TRANSACAO, LEAVE TRANSACAO.

            END.

        IF  crapcrm.tpcarcta = 1  THEN
            DO:
                FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                   crapass.nrdconta = par_nrdconta 
                                   NO-LOCK NO-ERROR.
                                   
                IF  NOT AVAILABLE crapass  THEN
                    DO:
                        ASSIGN aux_cdcritic = 9
                               aux_dscritic = "".

                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,            /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
                                   
                        UNDO TRANSACAO, LEAVE TRANSACAO.

                    END.
                
                IF  crapass.inpessoa > 1                       AND 
                    CAN-FIND(crabcrm WHERE 
                             crabcrm.cdcooper  = par_cdcooper  AND
                             crabcrm.nrdconta  = par_nrdconta  AND
                             crabcrm.cdsitcar  = 2             AND
                             crabcrm.dtvalcar >= par_dtmvtolt) THEN
                    DO:
                        IF  crapass.nrdconta = 2393409   AND
                            crapass.cdcooper = 1         THEN
                            .
                        ELSE
                        DO:
                            ASSIGN aux_cdcritic = 0
                                   aux_dscritic = "Associado ja possui cartao " +
                                                  "entregue.".
    
                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT 1,            /** Sequencia **/
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).
                                       
                            UNDO TRANSACAO, LEAVE TRANSACAO.

                        END.

                    END.



            END.

        RUN alterar-senha-cartao-magnetico (INPUT par_cdcooper,
                                            INPUT 0,
                                            INPUT 0,
                                            INPUT par_cdoperad,   
                                            INPUT par_nmdatela,
                                            INPUT 1,
                                            INPUT par_nrdconta,
                                            INPUT 1,
                                            INPUT par_dtmvtolt,
                                            INPUT par_nrcartao,
                                            INPUT par_dssenatu,
                                            INPUT par_dssencar,
                                            INPUT par_dssencon,
                                            INPUT NO,
                                            OUTPUT TABLE tt-erro).


        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                       
                IF  AVAILABLE tt-erro  THEN
                    ASSIGN aux_dscritic = tt-erro.dscritic.
                           
                IF  par_flgerlog  THEN
                    RUN proc_gerar_log (INPUT par_cdcooper,
                                        INPUT par_cdoperad,
                                        INPUT aux_dscritic,
                                        INPUT aux_dsorigem,
                                        INPUT aux_dstransa,
                                        INPUT FALSE,
                                        INPUT par_idseqttl,
                                        INPUT par_nmdatela,
                                        INPUT par_nrdconta,
                                        OUTPUT aux_nrdrowid).
                    
                UNDO TRANSACAO, LEAVE TRANSACAO.

        END.

        ASSIGN aux_dtcancel     = crapcrm.dtcancel
               aux_cdsitcar     = crapcrm.cdsitcar
               aux_dtentcrm     = crapcrm.dtentcrm
               crapcrm.dtcancel = ?
               crapcrm.cdsitcar = 2
               crapcrm.dtentcrm = par_dtmvtolt
               crapcrm.dttransa = par_dtmvtolt
               crapcrm.hrtransa = TIME
               crapcrm.cdoperad = par_cdoperad
               crapcrm.qtsenerr = 0
               aux_flgtrans     = TRUE.
    
    END. /** Fim do DO TRANSACTION - TRANSACAO **/
    
    /** Verifica se transacao foi executada com sucesso **/
    IF  NOT aux_flgtrans  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  NOT AVAILABLE tt-erro  THEN
                DO:                
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Nao foi possivel entregar o cartao" +
                                          " magnetico.".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                END.
                                                               
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
                   
            RETURN "NOK".

        END.

    IF  par_flgerlog  THEN
        DO:
            RUN proc_gerar_log (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT "",
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT TRUE,
                                INPUT par_idseqttl,
                                INPUT par_nmdatela,
                                INPUT par_nrdconta,
                               OUTPUT aux_nrdrowid).

            /** Numero do Cartao Magnetico **/
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "nrcartao",
                                     INPUT "",
                                     INPUT STRING(par_nrcartao,
                                                  "9999,9999,9999,9999")).
                                     
            /** Situacao do cartao **/
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "cdsitcar",
                                     INPUT TRIM(STRING(aux_cdsitcar)),
                                     INPUT "2").
                                     
            /** Data de Cancelamento **/
            IF  aux_dtcancel <> ?  THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "dtcancel",
                                         INPUT TRIM(STRING(aux_dtcancel,
                                                           "99/99/9999")),
                                         INPUT "").
                                         
            /** Data de 'Reentrega' **/
            IF  aux_dtentcrm <> ?  THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "dtentcrm",
                                         INPUT TRIM(STRING(aux_dtentcrm,
                                                           "99/99/9999")),
                                         INPUT TRIM(STRING(par_dtmvtolt,
                                                           "99/99/9999"))).
          
        END.

    RETURN "OK".
    
END PROCEDURE.

/******************************************************************************/
/**         Procedure que verifica a senha atual do cartao magnetico         **/
/******************************************************************************/
PROCEDURE verifica-senha-atual:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcartao AS DECI                           NO-UNDO.
    /* 1-Altera senha, 2-Entrega cartao */ 
    DEF  INPUT PARAM par_tpoperac AS INT                            NO-UNDO.
            
    DEF OUTPUT PARAM par_flgsenat AS LOGI                           NO-UNDO.
    DEF OUTPUT PARAM par_flgletca AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Verifica senha atual do cartao magnetico".

    FIND crapcrm WHERE crapcrm.cdcooper = par_cdcooper AND
                       crapcrm.nrdconta = par_nrdconta AND
                       crapcrm.nrcartao = par_nrcartao NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapcrm  THEN
        DO:
            ASSIGN aux_cdcritic = 546
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                   
            RETURN "NOK".
        END.

    RUN consiste-cartao (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT par_cdoperad,
                         INPUT par_nmdatela,
                         INPUT par_idorigem,
                         INPUT par_nrdconta,
                         INPUT par_idseqttl,
                         INPUT par_nrcartao,
                         INPUT FALSE, /** Entrega? **/
                        OUTPUT TABLE tt-erro).
        
    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".

    IF  crapcrm.cdsitcar > 2 AND par_tpoperac = 1  THEN
        DO:
            ASSIGN aux_cdcritic = 625
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                   
            RETURN "NOK".
        END.
        
    IF  crapcrm.dssencar = "NAOTARIFA" OR
        crapcrm.dssencar = "TARIFA"    THEN
        ASSIGN par_flgsenat = FALSE.
    ELSE
        ASSIGN par_flgsenat = TRUE.

    RUN verifica-letras-seguranca (INPUT par_cdcooper,
                                   INPUT par_nrdconta,
                                   INPUT par_idseqttl,
                                  OUTPUT par_flgletca).

    RETURN "OK".

END PROCEDURE.


/******************************************************************************/
/**             Procedure para alterar senha do cartao magnetico             **/
/******************************************************************************/
PROCEDURE alterar-senha-cartao-magnetico:

    /*** OBSERVACAO ***
         Devido a comunicacao do TAA com o Servidor nao ser criptografada,
         quando a chamada desta procedure for feita pelo TAA, a senha ja
         vira validada e criptografada, entao as validacoes somente sao feitas
         para o Ayllos, no caso do TAA esta direto no sistema do TAA. */

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcartao AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dssenatu AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dssencar AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dssencon AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
            
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR h-b1wgenprwd AS HANDLE                                  NO-UNDO.
    
    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.    
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_dsdpsrwd AS INTE                                    NO-UNDO.
    DEF VAR aux_ponteiro AS INTE                                    NO-UNDO.
    DEF VAR aux_nrsequen AS CHAR                                    NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_flgtrans = FALSE.

    IF  par_flgerlog  THEN
        ASSIGN aux_dstransa = "Alterar senha do cartao magnetico".

    TRANSACAO:
    
    DO TRANSACTION ON ERROR UNDO TRANSACAO, LEAVE TRANSACAO:
    
        DO aux_contador = 1 TO 10:
        
            ASSIGN aux_dscritic = "".
            
            FIND crapcrm WHERE crapcrm.cdcooper = par_cdcooper AND
                               crapcrm.nrdconta = par_nrdconta AND
                               crapcrm.nrcartao = par_nrcartao
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crapcrm  THEN
                DO:
                    IF  LOCKED crapcrm  THEN
                        DO:
                            aux_dscritic = "Registro do cartao magnetico esta" +
                                           " sendo alterado.".
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        aux_dscritic = "Cartao magnetico nao cadastrado.".
                END.
        
            LEAVE.
            
        END. /** Fim do DO .. TO **/
        
        IF  aux_dscritic <> ""  THEN
            DO:
                ASSIGN aux_cdcritic = 0.

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                                   
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.

        /* Se NAO FOR TAA, valida */
        IF  par_idorigem <> 4  THEN
            DO:
                ASSIGN aux_cdcritic = 0.
                
                IF  crapcrm.dssencar <> "TARIFA"              AND
                    crapcrm.dssencar <> "NAOTARIFA"           AND
                    ENCODE(par_dssenatu) <> crapcrm.dssencar  THEN
                    ASSIGN aux_cdcritic = 3.
                ELSE
                  IF  par_dssenatu = par_dssencar THEN
                      ASSIGN aux_cdcritic = 6.
                  ELSE
                    IF  par_dssencar <> par_dssencon  THEN
                        ASSIGN aux_cdcritic = 3.
                    ELSE
                      IF  LENGTH(par_dssencar) < 6  THEN
                          ASSIGN aux_cdcritic = 623.
                    
                IF  aux_cdcritic > 0  THEN
                    DO:
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,            /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
                                           
                        UNDO TRANSACAO, LEAVE TRANSACAO.
                    END.
            END.
        
        /* se for cartao magnetico de operador (TAA nao altera senha de operador) */
        IF  crapcrm.tptitcar = 9  THEN
            DO:    
                RUN validar-hist-cartmagope (INPUT par_cdcooper,
                                             INPUT par_nrdconta,
                                             INPUT par_idseqttl,
                                             INPUT par_dssencar,
                                             INPUT NO, /* nao vai encodado */
                                            OUTPUT aux_dscritic).
                
                IF  aux_cdcritic > 0  OR aux_dscritic <> "" THEN
                    DO:
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,            /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
                                           
                        UNDO TRANSACAO, LEAVE TRANSACAO.
                    END.
                
                RUN gravar-hist-cartmagope (INPUT par_cdcooper,
                                            INPUT par_nrdconta,
                                            INPUT par_idseqttl,
                                            INPUT ENCODE(par_dssencar),
                                           OUTPUT aux_dscritic).
        
                IF  aux_dscritic <> "" THEN
                    DO:
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,            /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
                                           
                        UNDO TRANSACAO, LEAVE TRANSACAO.
                    END.
    
            END. /* if crapcrm.tptitcar = 9 */

        ASSIGN crapcrm.dssencar = IF  par_idorigem = 4  THEN par_dssencar /* ja vem criptografada do TAA */
                                  ELSE ENCODE(par_dssencar)
               crapcrm.dttransa = par_dtmvtolt
               crapcrm.hrtransa = TIME
               crapcrm.cdoperad = par_cdoperad
               crapcrm.qtsenerr = 0
               aux_flgtrans     = TRUE.
    
        IF  par_idorigem = 4 THEN
            DO:
                RUN sistema/generico/procedures/b1wgenpwrd.p 
                        PERSISTENT SET h-b1wgenprwd ( INPUT crapcrm.dssencar,
                                                     OUTPUT aux_dsdpsrwd).
            
                DELETE PROCEDURE h-b1wgenprwd.
            END.
       ELSE
            ASSIGN aux_dsdpsrwd = INTE(par_dssencar).

       IF   aux_dsdpsrwd > 0 THEN
            DO:
                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                
                RUN STORED-PROCEDURE pc_getPinBlockCripto
                aux_handproc = PROC-HANDLE NO-ERROR (INPUT STRING(crapcrm.nrcartao)
                                                    ,INPUT STRING(aux_dsdpsrwd)
                                                    ,"").
                                                    
                CLOSE STORED-PROC pc_getPinBlockCripto aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                
                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
        
                ASSIGN aux_nrsequen = pc_getPinBlockCripto.pSenhaCrypto
                                      WHEN pc_getPinBlockCripto.pSenhaCrypto <> ?.
                                      
                IF  TRIM(aux_nrsequen) <> "" THEN
                    ASSIGN crapcrm.dssenpin = TRIM(aux_nrsequen).
            END.
    
    END. /** Fim do DO TRANSACTION - TRANSACAO **/
    
    /** Verifica se transacao foi executada com sucesso **/
    IF  NOT aux_flgtrans  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  NOT AVAILABLE tt-erro  THEN
                DO:                
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Nao foi possivel alterar senha do " +
                                          "cartao magnetico.".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                END.

            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
                   
            RETURN "NOK".
        END.

    IF  par_flgerlog  THEN
        DO:
            RUN proc_gerar_log (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT "",
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT TRUE,
                                INPUT par_idseqttl,
                                INPUT par_nmdatela,
                                INPUT par_nrdconta,
                               OUTPUT aux_nrdrowid).

            /** Numero do Cartao Magnetico **/
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "nrcartao",
                                     INPUT "",
                                     INPUT STRING(par_nrcartao,
                                                  "9999,9999,9999,9999")).
        END.

    RETURN "OK".
    
END PROCEDURE.



/******************************************************************************/
/**            Procedure para validar a senha do cartao magnetico            **/
/******************************************************************************/
PROCEDURE validar-senha-cartao-magnetico:


    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcartao AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dssenatu AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dssencar AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dssencon AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
            
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    
    EMPTY TEMP-TABLE tt-erro.
    
    
    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0.
        
    FIND crapcrm WHERE crapcrm.cdcooper = par_cdcooper AND
                       crapcrm.nrdconta = par_nrdconta AND
                       crapcrm.nrcartao = par_nrcartao
                       NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapcrm  THEN
        aux_dscritic = "Cartao magnetico nao cadastrado.".
    
    IF  aux_dscritic <> ""  THEN
        DO:
            ASSIGN aux_cdcritic = 0.

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

           RETURN "NOK".

        END.
        
    IF  crapcrm.dssencar <> "TARIFA"              AND
        crapcrm.dssencar <> "NAOTARIFA"           AND
        ENCODE(par_dssenatu) <> crapcrm.dssencar  THEN
        ASSIGN aux_cdcritic = 3.
    ELSE
      IF  par_dssenatu = par_dssencar THEN
          ASSIGN aux_cdcritic = 6.
      ELSE
        IF  par_dssencar <> par_dssencon  THEN
            ASSIGN aux_cdcritic = 3.
        ELSE
          IF  LENGTH(par_dssencar) < 6  THEN
              ASSIGN aux_cdcritic = 623.
        
    IF  aux_cdcritic > 0  THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                               
            RETURN "NOK".

        END.
        
    /* se for cartao magnetico de operador */
    IF  crapcrm.tptitcar = 9 THEN
        DO:
            RUN validar-hist-cartmagope (INPUT par_cdcooper,
                                         INPUT par_nrdconta,
                                         INPUT par_idseqttl,
                                         INPUT par_dssencar,
                                         INPUT NO, /* nao vai encodado */
                                        OUTPUT aux_dscritic).
        
            IF  aux_cdcritic > 0 OR aux_dscritic <> "" THEN
                DO:
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                    RETURN "NOK".
                END.
        END. /* if crapcrm.tptitcar = 9 */

    RETURN "OK".

END PROCEDURE.


/******************************************************************************/
/**     Procedure para validar e gravar a nosa senha de letras do taa        **/
/******************************************************************************/
PROCEDURE grava-senha-letras:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dssennov AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dssencon AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
            
    DEF OUTPUT PARAM par_flgcadas AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.

    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_contado2 AS INTE                                    NO-UNDO.

    /* letras validas na senha */
    DEF VAR aux_letraval AS CHAR                                    NO-UNDO.
    
    /* letras nao validas na senha */
    DEF VAR aux_letranvl AS CHAR                                    NO-UNDO.

    /* ultimo indice encontrado no nome */
    DEF VAR aux_ultimoin AS INTE                                    NO-UNDO.
    
    /* nome do cooperado + " " para controle dos caracteres */
    DEF VAR aux_nmprimtl AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmrepres AS CHAR                                    NO-UNDO.

    /* nomes do titular */
    DEF VAR aux_nomedotl AS CHAR                                    NO-UNDO.

    /* iniciais dos nomes do titular */
    DEF VAR aux_iniciais AS CHAR                                    NO-UNDO.
    
    DEF VAR aux_nrcpfcgc AS DECIMAL                                 NO-UNDO. 

    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Gravar senha letras do cartao magnetico do TAA"
           aux_flgtrans = FALSE
           aux_letraval = "A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U"
           aux_letranvl = "V,W,X,Y,Z"
           par_flgcadas = "NAO"
           aux_nrcpfcgc = 0
           aux_nmrepres = "".

    IF  par_dssennov <> par_dssencon  THEN
    DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Senhas nao conferem.".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".
    END.
    ELSE
    DO:
        DO aux_contador = 1 TO 3:
            IF  CAN-DO(aux_letranvl,SUBSTR(par_dssennov,aux_contador,1)) THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Letra " + UPPER(SUBSTR(par_dssennov,aux_contador,1)) + 
                                      " nao permitida.".

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                RETURN "NOK".
            END.
            ELSE
            IF  NOT CAN-DO(aux_letraval,SUBSTR(par_dssennov,aux_contador,1)) THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Senha possui caracter nao permitido.".

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                RETURN "NOK".
            END.
        END.
    END.
    
    TRANSACAO:
    DO TRANSACTION ON ERROR UNDO TRANSACAO, LEAVE TRANSACAO:
    
        DO aux_contador = 1 TO 10:
        
            ASSIGN aux_dscritic = "".
            
            FIND crapsnh WHERE crapsnh.cdcooper = par_cdcooper AND
                               crapsnh.nrdconta = par_nrdconta AND
                               crapsnh.idseqttl = par_idseqttl AND
                               crapsnh.tpdsenha = 3 /* Letras */
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crapsnh  THEN
                DO:
                    IF  LOCKED crapsnh  THEN
                        DO:
                            aux_dscritic = "Registro de letras esta " +
                                           "sendo alterado.".
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        DO:
                            CREATE crapsnh.
                            ASSIGN crapsnh.cdcooper = par_cdcooper
                                   crapsnh.nrdconta = par_nrdconta
                                   crapsnh.idseqttl = par_idseqttl
                                   /* Inicio - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
                                   crapsnh.cdopeori = par_cdoperad
                                   crapsnh.cdageori = par_cdagenci
                                   crapsnh.dtinsori = TODAY
                                   /* Fim - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
                                   crapsnh.tpdsenha = 3  /* LETRAS */
                                   crapsnh.cdsitsnh = 1  /* ATIVO  */
                                   crapsnh.dtlibera = par_dtmvtolt.
                            VALIDATE crapsnh.
                        END.
                END.
        
            LEAVE.
            
        END. /** Fim do DO .. TO **/
        
        IF  aux_dscritic <> ""  THEN
            DO:
                ASSIGN aux_cdcritic = 0.

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                                   
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.

        /* Tratamentos:
         - Nao devera permitir letras repetidas.
         - Nao devera permitir primeiras letras do nome, Ex.: "GUI".
         - Nao permitir 1a. letra do nome + 1a. letra dos sobrenomes, ex.: "GAS" - Guilherme Augusto Strube. 
           Se o cooperado possuir apenas 1 sobrenome, esta validação não será efetuada, ex.:  "DV?"  - Diego Vicentini.
         - Nao permitir inicias do nome e sobrenomes, ex.: "GUI", "AUG" "STR".

        */
        IF  SUBSTR(par_dssennov,1,1) = SUBSTR(par_dssennov,2,1) OR
            SUBSTR(par_dssennov,1,1) = SUBSTR(par_dssennov,3,1) OR  
            SUBSTR(par_dssennov,2,1) = SUBSTR(par_dssennov,3,1) THEN
        DO:
            ASSIGN aux_dscritic = "Letras nao podem ser repetidas."
                   aux_cdcritic = 0.

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            UNDO TRANSACAO, LEAVE TRANSACAO.

        END.
        ELSE
        DO:
            FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                               crapass.nrdconta = par_nrdconta
                               NO-LOCK NO-ERROR.

            IF  NOT AVAIL crapass  THEN
            DO:
                ASSIGN aux_cdcritic = 9
                       aux_dscritic = "".

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.

            /* pessoa fisica */
            IF  crapass.inpessoa = 1  THEN
            DO:
                FIND crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                                   crapttl.nrdconta = par_nrdconta AND
                                   crapttl.idseqttl = par_idseqttl
                                   NO-LOCK NO-ERROR.
    
                IF  NOT AVAIL crapttl  THEN
                DO:
                    ASSIGN aux_cdcritic = 9
                           aux_dscritic = "".
    
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
    
                    UNDO TRANSACAO, LEAVE TRANSACAO.
                END.

                ASSIGN aux_nomedotl = crapttl.nmextttl.
            END.
            ELSE
            DO:
                FIND crapjur WHERE crapjur.cdcooper = par_cdcooper AND
                                   crapjur.nrdconta = par_nrdconta
                                   NO-LOCK NO-ERROR.
    
                IF  NOT AVAIL crapjur  THEN
                DO:
                    ASSIGN aux_cdcritic = 9
                           aux_dscritic = "".
    
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
    
                    UNDO TRANSACAO, LEAVE TRANSACAO.
                END.

                ASSIGN aux_nomedotl = crapjur.nmextttl.
            END.

            IF  TRIM(aux_nomedotl) BEGINS par_dssennov  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Senha nao pode iniciar com o nome.".

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.

            ASSIGN aux_ultimoin = 1
                   aux_nmprimtl = TRIM(aux_nomedotl) + " ".

            DO  aux_contador = 1 TO NUM-ENTRIES(TRIM(aux_nmprimtl)," "):

                ASSIGN aux_nomedotl = SUBSTR(aux_nmprimtl,
                                             aux_ultimoin,
                                             INDEX(aux_nmprimtl," ",aux_ultimoin) - aux_ultimoin)
                       aux_iniciais = aux_iniciais + SUBSTR(aux_nomedotl,1,1)
                       aux_ultimoin = INDEX(aux_nmprimtl," ",aux_ultimoin) + 1.
                
                IF  aux_nomedotl BEGINS par_dssennov  THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Senha nao pode iniciar com o nome.".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).

                    UNDO TRANSACAO, LEAVE TRANSACAO.
                END.
            END.

            IF  aux_iniciais BEGINS par_dssennov  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Senha nao pode ser as iniciais do nome.".

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.

        END.
        
        /* Tratamento para contas que exigem assinatura mulptipla */
        IF crapass.idastcjt > 0 AND par_idseqttl > 1 THEN
        DO:
            /* Buscar dados do responsavel legal */
            { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
            RUN STORED-PROCEDURE pc_verifica_rep_assinatura
            aux_handproc = PROC-HANDLE NO-ERROR
                    (INPUT par_cdcooper, /* Codigo da Cooperativa */
                     INPUT par_nrdconta, /* Numero da Conta */
                     INPUT par_idseqttl, /* Sequencia Titularidade */
                     INPUT par_idorigem, /* Codigo Origem */
                    OUTPUT 0,            /* Flag de Assinatura Multipla pr_idastcjt */
                    OUTPUT 0,            /* Numero do CPF pr_nrcpfcgc */
                    OUTPUT "",           /* Nome do Representante/Procurador pr_nmprimtl */
                    OUTPUT 0,            /* Flag de Preposto Cartao Mag. pr_flcartma */
                    OUTPUT 0,            /* Codigo da critica */
                    OUTPUT "").          /* Descricao da critica */

            CLOSE STORED-PROC pc_verifica_rep_assinatura
            aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

            { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

            ASSIGN aux_nrcpfcgc = 0
                   aux_nmrepres = ""
                   aux_cdcritic = 0
                   aux_dscritic = ""
                   aux_nrcpfcgc = pc_verifica_rep_assinatura.pr_nrcpfcgc 
                                  WHEN pc_verifica_rep_assinatura.pr_nrcpfcgc <> ?
                   aux_nmrepres = pc_verifica_rep_assinatura.pr_nmprimtl 
                                  WHEN pc_verifica_rep_assinatura.pr_nmprimtl <> ?
                   aux_cdcritic = pc_verifica_rep_assinatura.pr_cdcritic 
                                  WHEN pc_verifica_rep_assinatura.pr_cdcritic <> ?
                   aux_dscritic = pc_verifica_rep_assinatura.pr_dscritic
                                  WHEN pc_verifica_rep_assinatura.pr_dscritic <> ?.

            IF aux_cdcritic <> 0   OR
               aux_dscritic <> ""  THEN
            DO:
               IF aux_dscritic = "" THEN
               DO:
                 FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic
                            NO-LOCK NO-ERROR.

                 IF AVAIL crapcri THEN
                    ASSIGN aux_dscritic = crapcri.dscritic.

               END.
               
               RUN gera_erro (INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT 1,            /** Sequencia **/
                              INPUT aux_cdcritic,
                              INPUT-OUTPUT aux_dscritic).
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.

            ASSIGN crapsnh.nrcpfcgc = aux_nrcpfcgc.              
                        
        /* FIM Buscar dados responsavel legal */
        END.

        ASSIGN crapsnh.cddsenha = ENCODE(UPPER(SUBSTR(par_dssennov,3,1)) + 
                                         UPPER(SUBSTR(par_dssennov,2,1)) + 
                                         UPPER(SUBSTR(par_dssennov,1,1)))
               crapsnh.dtaltsnh = par_dtmvtolt
               crapsnh.cdoperad = par_cdoperad
			   crapsnh.cdsitsnh = 1 /* Ativo */
               aux_flgtrans     = TRUE.
        
    END. /** Fim do DO TRANSACTION - TRANSACAO **/

    IF  AVAIL crapsnh  THEN
        DO:
            FIND CURRENT crapsnh NO-LOCK NO-ERROR.
            RELEASE crapsnh.
        END.
    
    /** Verifica se transacao foi executada com sucesso **/
    IF  NOT aux_flgtrans  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  NOT AVAILABLE tt-erro  THEN
                DO:                
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Nao foi possivel cadastrar letras.".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                END.
                                                               
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).


            RETURN "NOK".
        END.

    IF  par_flgerlog  THEN
        DO:
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT "",
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT TRUE,
                            INPUT par_idseqttl,
                            INPUT par_nmdatela,
                            INPUT par_nrdconta,
                           OUTPUT aux_nrdrowid).

            /* Gerar o log com CPF do Rep./Proc. */
            IF  aux_nrcpfcgc > 0  THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "CPF Representante/Procurador" ,
                                         INPUT "",
                                         INPUT STRING(STRING(aux_nrcpfcgc,
                                           "99999999999"),"xxx.xxx.xxx-xx")).
        
            /* Gerar o log com Nome do Rep./Proc. */
            IF  aux_nmrepres <> ""  THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "Nome Representante/Procurador" ,
                                         INPUT "",
                                         INPUT aux_nmrepres).
        END.
    
    ASSIGN par_flgcadas = "SIM".

    RETURN "OK".
    
END PROCEDURE.

/******************************************************************************/
/**   Procedure para verificar se as letras de seguranca estao cadastradas   **/
/******************************************************************************/
PROCEDURE verifica-letras-seguranca:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_flgcadas AS LOGI                           NO-UNDO.

    ASSIGN par_flgcadas = FALSE.

    FIND crapsnh WHERE crapsnh.cdcooper = par_cdcooper AND
                       crapsnh.nrdconta = par_nrdconta AND
                       crapsnh.idseqttl = par_idseqttl AND
                       crapsnh.tpdsenha = 3            NO-LOCK NO-ERROR.

    IF  AVAIL crapsnh           AND 
        crapsnh.cddsenha <> ""  THEN
        ASSIGN par_flgcadas = TRUE.
    
    RETURN "OK".
    
END PROCEDURE.


/******************************************************************************/
/**    Procedure para obter dados para declaracao de recebimento do cartao   **/
/******************************************************************************/
PROCEDURE declaracao-recebimento-cartao:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcartao AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-declar-recebimento.
    
    DEF VAR aux_lsparuso AS CHAR                                    NO-UNDO. 
    DEF VAR aux_lsdnivel AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmprimtl AS CHAR                                    NO-UNDO.
    
    DEF BUFFER crabass FOR crapass.
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-declar-recebimento.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Obtem dados para declaracao recebimento magnetico"
           aux_lsparuso = "TERMINAL,CAIXA,TERMINAL + CAIXA,RETAGUARDA,CASH + " +
                          "RETAGUARDA"
           aux_lsdnivel = "OPERADOR,SUPERVISOR,GERENTE".

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapcop  THEN
        DO:
            ASSIGN aux_cdcritic = 651
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
         
            RETURN "NOK".
        END.
        
    FIND crapcrm WHERE crapcrm.cdcooper = par_cdcooper AND
                       crapcrm.nrcartao = par_nrcartao NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapcrm  THEN
        DO:
            ASSIGN aux_cdcritic = 546
                   aux_dscritic = "".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
         
            RETURN "NOK".
        END.
          
    ASSIGN aux_nmprimtl = crapcrm.nmtitcrd.
              
    IF  crapcrm.tpcarcta = 1   THEN
        DO:
            FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                               crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
                          
            IF  NOT AVAILABLE crapass  THEN
                DO:
                    ASSIGN aux_cdcritic = 9
                           aux_dscritic = "".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).

                    IF  par_flgerlog  THEN
                        RUN proc_gerar_log (INPUT par_cdcooper,
                                            INPUT par_cdoperad,
                                            INPUT aux_dscritic,
                                            INPUT aux_dsorigem,
                                            INPUT aux_dstransa,
                                            INPUT FALSE,
                                            INPUT par_idseqttl,
                                            INPUT par_nmdatela,
                                            INPUT par_nrdconta,
                                           OUTPUT aux_nrdrowid).
         
                    RETURN "NOK".
                END.

            IF  crapass.inpessoa > 1  THEN
                DO:
                    FIND crapavt WHERE crapavt.cdcooper = par_cdcooper     AND
                                       crapavt.nrdconta = par_nrdconta     AND
                                       crapavt.nrcpfcgc = crapass.nrcpfppt AND
                                       crapavt.tpctrato = 6            
                                       NO-LOCK NO-ERROR.
                                       
                    IF  NOT AVAILABLE crapavt  THEN
                        DO:
                            ASSIGN aux_cdcritic = 0
                                   aux_dscritic = "Preposto nao cadastrado.".

                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT 1,            /** Sequencia **/
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).
         
                            IF  par_flgerlog  THEN
                                RUN proc_gerar_log (INPUT par_cdcooper,
                                                    INPUT par_cdoperad,
                                                    INPUT aux_dscritic,
                                                    INPUT aux_dsorigem,
                                                    INPUT aux_dstransa,
                                                    INPUT FALSE,
                                                    INPUT par_idseqttl,
                                                    INPUT par_nmdatela,
                                                    INPUT par_nrdconta,
                                                   OUTPUT aux_nrdrowid).
                                   
                            RETURN "NOK".
                        END.                       

                    IF  crapavt.nrdctato <> 0  THEN
                        DO:
                            FIND crabass WHERE 
                                 crabass.cdcooper = par_cdcooper     AND
                                 crabass.nrdconta = crapavt.nrdctato
                                 NO-LOCK NO-ERROR.
                                 
                            IF  NOT AVAILABLE crabass  THEN
                                DO:
                                    ASSIGN aux_cdcritic = 9
                                           aux_dscritic = "".
                               
                                    RUN gera_erro (INPUT par_cdcooper,
                                                   INPUT par_cdagenci,
                                                   INPUT par_nrdcaixa,
                                                   INPUT 1,   /** Sequencia **/
                                                   INPUT aux_cdcritic,
                                                   INPUT-OUTPUT aux_dscritic).
         
                                    IF  par_flgerlog  THEN
                                        RUN proc_gerar_log (INPUT par_cdcooper,
                                                            INPUT par_cdoperad,
                                                            INPUT aux_dscritic,
                                                            INPUT aux_dsorigem,
                                                            INPUT aux_dstransa,
                                                            INPUT FALSE,
                                                            INPUT par_idseqttl,
                                                            INPUT par_nmdatela,
                                                            INPUT par_nrdconta,
                                                           OUTPUT aux_nrdrowid).
                             
                                    RETURN "NOK".
                                END.  

                            ASSIGN aux_nmprimtl = crabass.nmprimtl.
                        END.
                    ELSE
                        ASSIGN aux_nmprimtl = crapavt.nmdavali.
                END.
        END.              
        
    FIND crapope WHERE crapope.cdcooper = par_cdcooper AND 
                       crapope.cdoperad = par_cdoperad NO-LOCK NO-ERROR.
                       
    IF  NOT AVAILABLE crapope  THEN
        DO:
            ASSIGN aux_cdcritic = 67
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
         
            RETURN "NOK".
        END.        
        
    CREATE tt-declar-recebimento.
    ASSIGN tt-declar-recebimento.nmrescop = CAPS(crapcop.nmrescop)
           tt-declar-recebimento.nmextcop = CAPS(crapcop.nmextcop)
           tt-declar-recebimento.nrdconta = crapcrm.nrdconta
           tt-declar-recebimento.nmprimtl = aux_nmprimtl
           tt-declar-recebimento.inpessoa = IF  crapcrm.tpcarcta = 1  THEN
                                                crapass.inpessoa
                                            ELSE
                                                1
           tt-declar-recebimento.nrcartao = crapcrm.nrcartao
           tt-declar-recebimento.tpcarcta = crapcrm.tpcarcta
           tt-declar-recebimento.dtvalcar = crapcrm.dtvalcar
           tt-declar-recebimento.dtemscar = crapcrm.dtemscar           
           tt-declar-recebimento.nmoperad = crapope.nmoperad
           tt-declar-recebimento.dsmvtolt = STRING(par_dtmvtolt,"99/99/9999") +
                                            " - " + STRING(TIME,"HH:MM:SS")
           tt-declar-recebimento.dsrefere = TRIM(crapcop.nmcidade) + ", " + 
                                            STRING(DAY(par_dtmvtolt),"99") +
                                            " DE " + 
                                            aux_nmmesano[MONTH(par_dtmvtolt)] +
                                            " DE " + 
                                            STRING(YEAR(par_dtmvtolt),"9999") +
                                            ".".

    IF  crapcrm.tpcarcta = 9  THEN
        DO:
            FIND crapope WHERE crapope.cdcooper = par_cdcooper             AND
                               crapope.cdoperad = STRING(crapcrm.nrdconta)
                               NO-LOCK NO-ERROR.
                            
            IF  NOT AVAILABLE crapope  THEN
                DO:
                    ASSIGN aux_cdcritic = 67
                           aux_dscritic = "".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).

                    IF  par_flgerlog  THEN
                        RUN proc_gerar_log (INPUT par_cdcooper,
                                            INPUT par_cdoperad,
                                            INPUT aux_dscritic,
                                            INPUT aux_dsorigem,
                                            INPUT aux_dstransa,
                                            INPUT FALSE,
                                            INPUT par_idseqttl,
                                            INPUT par_nmdatela,
                                            INPUT par_nrdconta,
                                           OUTPUT aux_nrdrowid).
         
                    RETURN "NOK".
                END.
        
            ASSIGN tt-declar-recebimento.dsparuso = ENTRY(crapope.tpoperad,
                                                          aux_lsparuso)
                   tt-declar-recebimento.dsdnivel = ENTRY(crapope.nvoperad,
                                                          aux_lsdnivel).
        END.
    
    RETURN "OK".

END PROCEDURE.


/******************************************************************************/
/**   Procedure que obtem dados para termo de responsabilidade para cartao   **/
/******************************************************************************/
PROCEDURE termo-responsabilidade-cartao:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
                
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-termo-magnetico.
    DEF OUTPUT PARAM TABLE FOR tt-represen-carmag.
    
    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.
    
    DEF VAR aux_nrcpfppt AS CHAR                                    NO-UNDO.
                                                                    
    DEF BUFFER crabass FOR crapass.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-termo-magnetico.
    EMPTY TEMP-TABLE tt-represen-carmag.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Obtem dados para termo responsabilidade magnetico".

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapcop  THEN
        DO:
            ASSIGN aux_cdcritic = 651
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
         
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
                                   
            RETURN "NOK".
        END.

    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND 
                       crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapass  THEN
        DO:
            ASSIGN aux_cdcritic = 9
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
         
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
                                   
            RETURN "NOK".
        END.

    FIND crapope WHERE crapope.cdcooper = par_cdcooper AND 
                       crapope.cdoperad = par_cdoperad NO-LOCK NO-ERROR.
                       
    IF  NOT AVAILABLE crapope  THEN
        DO:
            ASSIGN aux_cdcritic = 67
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
         
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
                                   
            RETURN "NOK".
        END.                       

    CREATE tt-termo-magnetico.
    ASSIGN tt-termo-magnetico.nmrescop = crapcop.nmrescop
           tt-termo-magnetico.nmextcop = crapcop.nmextcop
           tt-termo-magnetico.nrdocnpj = STRING(STRING(crapcop.nrdocnpj,
                                                "99999999999999"),
                                                "xx.xxx.xxx/xxxx-xx")
           tt-termo-magnetico.nrdconta = crapass.nrdconta
           tt-termo-magnetico.nmprimtl = crapass.nmprimtl
           tt-termo-magnetico.nrcpfcgc = STRING(STRING(crapass.nrcpfcgc,
                                                "99999999999999"),
                                                "xx.xxx.xxx/xxxx-xx")
           tt-termo-magnetico.nmoperad = TRIM(crapope.nmoperad)
           tt-termo-magnetico.nmcidade = TRIM(SUBSTR(crapcop.nmcidade,1,1) +
                                         SUBSTR(LOWER(crapcop.nmcidade),2))
           tt-termo-magnetico.dsrefere = tt-termo-magnetico.nmcidade + ", " + 
                                         STRING(DAY(par_dtmvtolt),"99") +
                                         " de " + 
                                         LC(aux_nmmesano[MONTH(par_dtmvtolt)]) +
                                         " de " + 
                                         STRING(YEAR(par_dtmvtolt),"9999") + "."
           tt-termo-magnetico.dsmvtolt = STRING(par_dtmvtolt,"99/99/9999") + 
                                         " - " + STRING(TIME,"HH:MM:SS").
            

    FOR EACH crapavt WHERE crapavt.cdcooper = par_cdcooper AND
       /** JURIDICA **/    crapavt.tpctrato = 6            AND
                           crapavt.nrdconta = par_nrdconta NO-LOCK:

        /** Se nao for socio ou preposto nao cria registro **/
        IF  crapavt.dsproftl <> "SOCIO/PROPRIETARIO"  AND
            crapavt.nrcpfcgc <> crapass.nrcpfppt      THEN
            NEXT.
                            
        IF  crapavt.nrdctato <> 0  THEN
            DO:
                FIND crabass WHERE crabass.cdcooper = par_cdcooper     AND
                                   crabass.nrdconta = crapavt.nrdctato
                                   NO-LOCK NO-ERROR.
                                       
                IF  NOT AVAILABLE crabass  THEN
                    DO:
                        ASSIGN aux_cdcritic = 9
                               aux_dscritic = "".
                               
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,            /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
         
                        IF  par_flgerlog  THEN
                            RUN proc_gerar_log (INPUT par_cdcooper,
                                                INPUT par_cdoperad,
                                                INPUT aux_dscritic,
                                                INPUT aux_dsorigem,
                                                INPUT aux_dstransa,
                                                INPUT FALSE,
                                                INPUT par_idseqttl,
                                                INPUT par_nmdatela,
                                                INPUT par_nrdconta,
                                               OUTPUT aux_nrdrowid).
                                   
                        RETURN "NOK".
                    END.
                        
                IF  crabass.inpessoa <> 1  THEN
                    DO:
                        ASSIGN aux_cdcritic = 833
                               aux_dscritic = "".
                               
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,            /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).

                        IF  par_flgerlog  THEN
                            RUN proc_gerar_log (INPUT par_cdcooper,
                                                INPUT par_cdoperad,
                                                INPUT aux_dscritic,
                                                INPUT aux_dsorigem,
                                                INPUT aux_dstransa,
                                                INPUT FALSE,
                                                INPUT par_idseqttl,
                                                INPUT par_nmdatela,
                                                INPUT par_nrdconta,
                                               OUTPUT aux_nrdrowid).
         
                        RETURN "NOK".           
                    END.
                    
                FIND crapttl WHERE crapttl.cdcooper = par_cdcooper     AND
                                   crapttl.nrdconta = crapavt.nrdctato AND
                                   crapttl.idseqttl = 1
                                   NO-LOCK NO-ERROR.
              
                IF  NOT AVAILABLE crapttl  THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Titular nao cadastrado.".
                               
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,            /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).

                        IF  par_flgerlog  THEN
                            RUN proc_gerar_log (INPUT par_cdcooper,
                                                INPUT par_cdoperad,
                                                INPUT aux_dscritic,
                                                INPUT aux_dsorigem,
                                                INPUT aux_dstransa,
                                                INPUT FALSE,
                                                INPUT par_idseqttl,
                                                INPUT par_nmdatela,
                                                INPUT par_nrdconta,
                                               OUTPUT aux_nrdrowid).
         
                        RETURN "NOK".           
                    END.         

                FIND crapenc WHERE crapenc.cdcooper = par_cdcooper     AND
                                   crapenc.nrdconta = crapavt.nrdctato AND
                                   crapenc.idseqttl = 1                AND
                                   crapenc.cdseqinc = 1                AND
                                   crapenc.tpendass = 10 /** Residencial **/
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAILABLE crapenc  THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Endereco nao cadastrado.".
                               
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,            /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).

                        IF  par_flgerlog  THEN
                            RUN proc_gerar_log (INPUT par_cdcooper,
                                                INPUT par_cdoperad,
                                                INPUT aux_dscritic,
                                                INPUT aux_dsorigem,
                                                INPUT aux_dstransa,
                                                INPUT FALSE,
                                                INPUT par_idseqttl,
                                                INPUT par_nmdatela,
                                                INPUT par_nrdconta,
                                               OUTPUT aux_nrdrowid).
         
                        RETURN "NOK".           
                    END.

                ASSIGN aux_nrcpfppt = STRING(STRING(crapttl.nrcpfcgc,
                                             "99999999999"),"xxx.xxx.xxx-xx").
                                             
                CREATE tt-represen-carmag.
                ASSIGN tt-represen-carmag.nrdctato = crapttl.nrdconta
                       tt-represen-carmag.nmdavali = crapttl.nmextttl
                       tt-represen-carmag.nrcpfppt = aux_nrcpfppt
                       tt-represen-carmag.dsproftl = crapavt.dsproftl
                       tt-represen-carmag.cdestcvl = crapttl.cdestcvl    
                       tt-represen-carmag.dsendere = crapenc.dsendere 
                       tt-represen-carmag.nrendere = STRING(crapenc.nrendere)
                       tt-represen-carmag.complend = crapenc.complend    
                       tt-represen-carmag.nmbairro = crapenc.nmbairro    
                       tt-represen-carmag.nmcidade = crapenc.nmcidade    
                       tt-represen-carmag.cdufende = crapenc.cdufende.    
            END. 
        ELSE
            DO:
                ASSIGN aux_nrcpfppt = STRING(STRING(crapavt.nrcpfcgc,
                                             "99999999999"),"xxx.xxx.xxx-xx").
                                             
                CREATE tt-represen-carmag.
                ASSIGN tt-represen-carmag.nrdctato = crapavt.nrdctato
                       tt-represen-carmag.nmdavali = crapavt.nmdavali
                       tt-represen-carmag.nrcpfppt = aux_nrcpfppt
                       tt-represen-carmag.dsproftl = crapavt.dsproftl
                       tt-represen-carmag.cdestcvl = crapavt.cdestcvl    
                       tt-represen-carmag.dsendere = crapavt.dsendres[1] 
                       tt-represen-carmag.nrendere = STRING(crapavt.nrendere)
                       tt-represen-carmag.complend = crapavt.complend    
                       tt-represen-carmag.nmbairro = crapavt.nmbairro    
                       tt-represen-carmag.nmcidade = crapavt.nmcidade    
                       tt-represen-carmag.cdufende = crapavt.cdufresd.    
            END.   
             
        /** Verifica se este avalista e o preposto **/
       IF  crapass.nrcpfppt = crapavt.nrcpfcgc  THEN
           ASSIGN tt-represen-carmag.flgprepo = TRUE.
       ELSE
           ASSIGN tt-represen-carmag.flgprepo = FALSE.                       
    
        /** Estado civil **/
        RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT 
            SET h-b1wgen9999.
                          
        IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Handle invalido para BO b1wgen9999.".
                               
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

                IF  par_flgerlog  THEN
                    RUN proc_gerar_log (INPUT par_cdcooper,
                                        INPUT par_cdoperad,
                                        INPUT aux_dscritic,
                                        INPUT aux_dsorigem,
                                        INPUT aux_dstransa,
                                        INPUT FALSE,
                                        INPUT par_idseqttl,
                                        INPUT par_nmdatela,
                                        INPUT par_nrdconta,
                                       OUTPUT aux_nrdrowid).
         
                RETURN "NOK".
            END.
            
        RUN p-conectagener IN h-b1wgen9999.
                 
        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Nao foi possivel conectar ao banco " +
                                      "generico.".
                               
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

                IF  par_flgerlog  THEN
                    RUN proc_gerar_log (INPUT par_cdcooper,
                                        INPUT par_cdoperad,
                                        INPUT aux_dscritic,
                                        INPUT aux_dsorigem,
                                        INPUT aux_dstransa,
                                        INPUT FALSE,
                                        INPUT par_idseqttl,
                                        INPUT par_nmdatela,
                                        INPUT par_nrdconta,
                                       OUTPUT aux_nrdrowid).
         
                RETURN "NOK".
            END.
            
        RUN sistema/generico/procedures/b1wgen0015a.p 
                                           (INPUT tt-represen-carmag.cdestcvl,
                                           OUTPUT tt-represen-carmag.dsestcvl).
                              
        RUN p-desconectagener IN h-b1wgen9999.

        DELETE PROCEDURE h-b1wgen9999.
        
    END.
    
    RETURN "OK".

END PROCEDURE.


/******************************************************************************/
/**       Procedure que verifica se cartao esta disponivel para entrega      **/
/******************************************************************************/
PROCEDURE consiste-cartao:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcartao AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_flgentrg AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    EMPTY TEMP-TABLE tt-erro.

    DEF VAR aux_dssitcar AS CHAR                                    NO-UNDO.

    FIND crapcrm WHERE crapcrm.cdcooper = par_cdcooper AND
                       crapcrm.nrdconta = par_nrdconta AND
                       crapcrm.nrcartao = par_nrcartao NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapcrm  THEN
        DO:
            ASSIGN aux_cdcritic = 546
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                   
            RETURN "NOK".
        END.
    
    FIND craptab where craptab.cdcooper = par_cdcooper AND
                       craptab.nmsistem = "CRED"       AND
                       craptab.tptabela = "AUTOMA"     AND
                       craptab.cdempres = 0            AND
                       craptab.cdacesso = "CM" + STRING(crapcrm.dtemscar,
                                                        "99999999")   AND
                       craptab.tpregist = 0            NO-LOCK NO-ERROR.
                                               
    IF  AVAILABLE craptab AND craptab.dstextab = "0"  THEN
        DO:
            ASSIGN aux_cdcritic = IF par_flgentrg THEN 547 ELSE 538
                   aux_dscritic = "".
                               
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                               
            RETURN "NOK".
        END.
    
    RETURN "OK".
    
END PROCEDURE.


PROCEDURE valida_cartao:
    
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dscartao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtocd AS DATE                           NO-UNDO.
    DEF OUTPUT PARAM par_nrcartao AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.


    DEF VAR aux_cddbanco          AS INTE                           NO-UNDO.
    DEF VAR aux_cdageban          AS INTE                           NO-UNDO.
    DEF VAR aux_dtvalida          AS DATE                           NO-UNDO.
    DEF VAR aux_tptitcar          AS INTE                           NO-UNDO.
    DEF VAR aux_tpusucar          AS INTE                           NO-UNDO.
    DEF VAR aux_nrseqcar          AS INTE                           NO-UNDO.
    

    /* separa os dados da trilha */
    ASSIGN  aux_cddbanco = INTEGER(SUBSTRING(par_dscartao,02,03))

            aux_cdageban = INTEGER(SUBSTRING(par_dscartao,05,04))
        
            /* dia 1 do mes e ano de validade */
            aux_dtvalida = DATE(INT(SUBSTR(par_dscartao,17,02)),1,
                                INT(SUBSTR(par_dscartao,19,04)))

            aux_tptitcar = INT(SUBSTR(par_dscartao,23,02))
        
            aux_tpusucar = INT(SUBSTR(par_dscartao,25,02))

            par_nrdconta = INT(SUBSTR(par_dscartao,09,08)) 
         
            aux_nrseqcar = INT(SUBSTR(par_dscartao,27,10)) NO-ERROR.

    IF   ERROR-STATUS:ERROR                        OR
        (aux_tptitcar <> 9 AND aux_tptitcar <> 1)  OR
         aux_tpusucar  > 9                         OR 
        LENGTH(par_dscartao) <> 36                 THEN
         DO:
             par_dscritic = "Erro de leitura.".
             RETURN "NOK".
         END.  
       
    IF   YEAR(aux_dtvalida) < YEAR(par_dtmvtocd)    OR
        (YEAR(aux_dtvalida) = YEAR(par_dtmvtocd)    AND
         MONTH(aux_dtvalida) < MONTH(par_dtmvtocd)) THEN
         DO:
             ASSIGN par_dscritic = "Cartão Vencido".
             RETURN "NOK".
         END.

    /* São aceitos seguintes cartões:
         BANCO: 756 - BANCOOB
       AGENCIA: NNN - AGENCIA DA COOPERATIVA NO BANCOOB
       
          OU
          
         BANCO: 085 - CECRED
       AGENCIA: NNN - AGENCIA DA COOPERATIVA NA CECRED
    */

    IF  aux_cddbanco = 756  THEN
        DO:
            FIND crapcop WHERE crapcop.cdagebcb = aux_cdageban NO-LOCK NO-ERROR.
        
            /* Agencia do Bancoob na AltoVale foi alterada */
            IF  NOT AVAIL crapcop   AND 
                aux_cdageban = 115  THEN /* AltoVale */
                FIND crapcop WHERE crapcop.cdagectl = aux_cdageban 
                                   NO-LOCK NO-ERROR.
        END.
    ELSE
    IF  aux_cddbanco = 85  THEN
        FIND crapcop WHERE crapcop.cdagectl = aux_cdageban NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapcop  THEN
        DO:
            ASSIGN par_dscritic = "Cartão Inválido.".
            RETURN "NOK".
        END.
    
    /* cartao tratado */
    par_nrcartao = DECIMAL(STRING(aux_tptitcar,"9")        +
                           STRING(aux_nrseqcar,"999999")   +
                           STRING(par_nrdconta,"99999999") +
                           STRING(aux_tpusucar,"9")).

    /* verifica o cartao */
    FIND crapcrm WHERE crapcrm.cdcooper = par_cdcooper   AND
                       crapcrm.nrdconta = par_nrdconta   AND
                       crapcrm.nrcartao = par_nrcartao
                       NO-LOCK NO-ERROR.
                                                       
    IF  NOT AVAILABLE crapcrm   THEN
    DO: /* #227966 Verificar se eh cooperativa incorporada */
        FIND FIRST craptco WHERE    craptco.cdcooper = par_cdcooper     AND
                                    craptco.nrctaant = par_nrdconta     AND
                                    craptco.cdcopant = crapcop.cdcooper AND
                                    craptco.flgativo = TRUE 
                                    NO-LOCK NO-ERROR.
        IF AVAIL craptco THEN   
        DO:
            /* Atualiza parametro do nr da conta para a nova conta */
            par_nrdconta = craptco.nrdconta.

            FIND FIRST crapcrm WHERE   crapcrm.cdcooper = craptco.cdcopant AND
                                       crapcrm.nrdconta = craptco.nrctaant AND
                                       crapcrm.nrcartao = par_nrcartao
                                       NO-LOCK NO-ERROR.
        END.
    END.

    IF NOT AVAIL crapcrm THEN
    DO:
        ASSIGN par_dscritic = "Cartão não cadastrado.".
        RETURN "NOK".
    END.

     /* se o cartao nao estiver ativo */
    IF  crapcrm.cdsitcar <> 2  THEN
        DO:
            par_dscritic = IF  crapcrm.cdsitcar = 1  THEN
                               "Cartão Inválido"
                           ELSE
                           IF  crapcrm.cdsitcar = 3  THEN
                               "Cartão Cancelado"
                           ELSE
                           IF  crapcrm.cdsitcar = 4  THEN
                               "Cartão Bloqueado"
                           ELSE
                               "Cartão Inválido".

            RETURN "NOK".
        END.
  
    RETURN "OK".

END PROCEDURE.


/*............................ PROCEDURES INTERNAS ...........................*/


/******************************************************************************/
/**                Procedure para retornar situacao do cartao                **/
/******************************************************************************/
PROCEDURE verifica-situacao-cartao:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtvalcar AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdsitcar AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtemscar AS DATE                           NO-UNDO.

    DEF OUTPUT PARAM par_dssitcar AS CHAR                           NO-UNDO.
    
    IF  par_cdsitcar = 1  THEN
        DO:
            FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                               craptab.nmsistem = "CRED"       AND
                               craptab.tptabela = "AUTOMA"     AND
                               craptab.cdempres = 0            AND
                               craptab.cdacesso = "CM" + 
                                                  STRING(par_dtemscar,
                                                   "99999999") AND  
                               craptab.tpregist = 0 
                               NO-LOCK NO-ERROR.             
                   
            ASSIGN par_dssitcar = IF  AVAILABLE craptab             AND
                                      TRIM(craptab.dstextab) = "1"  THEN 
                                      "DISPONIVEL"
                                  ELSE 
                                      "SOLICITADO".
        END.
    ELSE
        ASSIGN par_dssitcar =  IF  par_cdsitcar = 2             AND
                                   par_dtvalcar < par_dtmvtolt  THEN 
                                   "VENCIDO"
                               ELSE
                               IF  par_cdsitcar = 2  THEN 
                                   "ENTREGUE"
                               ELSE
                               IF  par_cdsitcar = 3  THEN 
                                   "CANCELADO"
                               ELSE
                               IF  par_cdsitcar = 4  THEN 
                                   "BLOQUEADO"
                               ELSE 
                                   "INDETERMINADO".
                                   
    RETURN "OK".
                                       
END PROCEDURE.


/******************************************************************************/
/**            Procedure que valida dados para registro do cartao            **/
/******************************************************************************/
PROCEDURE valida-dados-cartao:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcartao AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tpcarcta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmtitcrd AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_tpusucar AS INTE                           NO-UNDO.    

    DEF  BUFFER crabcrm FOR crapcrm. 

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".
           
    IF  par_tpcarcta <> 1 AND par_tpcarcta <> 9  THEN
        ASSIGN aux_dscritic = "Tipo invalido de usuario do cartao.".
    ELSE
    IF  TRIM(par_nmtitcrd) = ""  THEN
        ASSIGN aux_cdcritic = 16.
    ELSE
    IF  par_tpusucar <= 0  THEN
        ASSIGN aux_dscritic = "Titular invalido.".
    ELSE
        DO:     
            IF  par_nrcartao = 0  THEN  /** Inclusao **/
                FIND FIRST crabcrm WHERE crabcrm.cdcooper = par_cdcooper AND
                                         crabcrm.nrdconta = par_nrdconta AND
                                         crabcrm.tpusucar = par_tpusucar AND
                                         crabcrm.cdsitcar = 1       
                                         NO-LOCK NO-ERROR.
            ELSE  /** Alteracao **/ 
                FIND FIRST crabcrm WHERE crabcrm.cdcooper  = par_cdcooper AND
                                         crabcrm.nrdconta  = par_nrdconta AND
                                         crabcrm.tpusucar  = par_tpusucar AND
                                         crabcrm.cdsitcar  = 1            AND
                                         crabcrm.nrcartao <> par_nrcartao   
                                         NO-LOCK NO-ERROR.
            
            IF  AVAILABLE crabcrm  THEN  
                aux_dscritic = "Cartao magnetico ja foi solicitado para " +
                               "este titular.".
        END.
    
    RETURN "OK".
    
END PROCEDURE.

/******************************************************************************/
/**             Procedure para abreviar nome do titular do cartao            **/
/******************************************************************************/
PROCEDURE abreviar:

    DEF  INPUT PARAM par_nmdentra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_qtletras AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM par_nmabrevi AS CHAR                           NO-UNDO.

    DEF VAR aux_lssufixo AS CHAR                                    NO-UNDO.
    DEF VAR aux_lsprfixo AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdletra AS CHAR                                    NO-UNDO.
    DEF VAR aux_palavras AS CHAR EXTENT 99                          NO-UNDO.
    
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_qtdnomes AS INTE                                    NO-UNDO.
    DEF VAR aux_qtletini AS INTE                                    NO-UNDO.
    
    DEF VAR aux_eliminar AS LOGI                                    NO-UNDO.

    ASSIGN par_nmabrevi = TRIM(par_nmdentra)
           aux_eliminar = FALSE
           aux_lssufixo = "FILHO,NETO,SOBRINHO,JUNIOR,JR."
           aux_lsprfixo = "E/OU".

    DO WHILE TRUE:

        aux_qtletini = LENGTH(par_nmabrevi).

        IF  aux_qtletini <= par_qtletras THEN
            LEAVE.

        ASSIGN aux_palavras = ""
               aux_qtdnomes = 1.

        /** Separa os nomes **/
        DO aux_contador = 1 TO LENGTH(par_nmabrevi):

            aux_dsdletra = SUBSTR(par_nmabrevi,aux_contador,1).

            IF  aux_dsdletra <> ""  THEN
                aux_palavras[aux_qtdnomes] = aux_palavras[aux_qtdnomes] +
                                             aux_dsdletra.
            ELSE
                aux_qtdnomes = aux_qtdnomes + 1.

        END.

        IF  CAN-DO(aux_lsprfixo,TRIM(aux_palavras[1]))  THEN
            DO:
                aux_palavras[1] = aux_palavras[1] + " " + aux_palavras[2].
             
                DO aux_contador = 2 TO aux_qtdnomes:
             
                    aux_palavras[aux_contador] = aux_palavras[aux_contador + 1].
         
                END.       
                    
                ASSIGN aux_palavras[aux_qtdnomes] = ""
                       aux_qtdnomes = aux_qtdnomes - 1.
            END.
                    
        IF  CAN-DO(aux_lssufixo,TRIM(aux_palavras[aux_qtdnomes]))  THEN
            DO:
                IF  aux_palavras[aux_qtdnomes] = "JUNIOR"  THEN
                    aux_palavras[aux_qtdnomes] = "JR.".

                ASSIGN aux_palavras[aux_qtdnomes - 1] =
                                   aux_palavras[aux_qtdnomes - 1] + " " +
                                   aux_palavras[aux_qtdnomes]
                       aux_palavras[aux_qtdnomes] = ""
                       aux_qtdnomes = aux_qtdnomes - 1.

            END.

        par_nmabrevi = "".

        DO aux_contador = 1 TO aux_qtdnomes:

            par_nmabrevi = par_nmabrevi + 
                           (IF  aux_contador <> 1  THEN 
                                " "
                            ELSE 
                                "") + 
                           aux_palavras[aux_contador].

        END.

        IF  aux_qtdnomes < 3  THEN
            LEAVE.

        ASSIGN par_nmabrevi = aux_palavras[1]
               aux_contador = 2.

        DO WHILE TRUE:

            IF  LENGTH(aux_palavras[aux_contador]) > 2  THEN
                DO:
                    par_nmabrevi = par_nmabrevi + " " +
                                   SUBSTR(aux_palavras[aux_contador],1,1) + ".".
                    LEAVE.
                END.
            ELSE
            IF  aux_eliminar  THEN
                aux_eliminar = FALSE.
            ELSE
                par_nmabrevi = par_nmabrevi + " " + aux_palavras[aux_contador].

            aux_contador = aux_contador + 1.

            IF  aux_contador >= aux_qtdnomes  THEN
                DO:
                    aux_contador = aux_contador - 1.
                    LEAVE.
                END.

        END.

        DO aux_contador = (aux_contador + 1) TO aux_qtdnomes:

            par_nmabrevi = par_nmabrevi + " " + aux_palavras[aux_contador].

        END.

        IF  aux_qtletini = LENGTH(par_nmabrevi)  THEN
            IF  aux_qtdnomes > 2  THEN
                aux_eliminar = TRUE.
            ELSE
                LEAVE.

    END. /** Fim do DO WHILE TRUE **/

END PROCEDURE.

PROCEDURE corrige_segtl:

    DEF   INPUT  PARAMETER    par_nmsegntl   AS CHAR                   NO-UNDO.
    DEF   OUTPUT PARAMETER    par_nmresult   AS CHAR                   NO-UNDO.

    DO  WHILE TRUE:
    
        IF  CAPS(SUBSTR(par_nmsegntl, 1, 4)) = "EOU "   THEN 
            DO:
                par_nmsegntl = SUBSTR(par_nmsegntl, 5, LENGTH(par_nmsegntl)).
                NEXT.
            END.

        IF  INDEX(SUBSTR(par_nmsegntl, 1, 5), "/") > 0   THEN
            DO:
                par_nmsegntl = SUBSTR(par_nmsegntl, 
                                 INDEX(SUBSTR(par_nmsegntl, 1, 5), "/") + 1, 
                                 LENGTH(par_nmsegntl)).
               NEXT.
           END.
     
        IF  INDEX(SUBSTR(par_nmsegntl, 1, 2), " ") > 0   THEN
            DO:
                par_nmsegntl = SUBSTR(par_nmsegntl, 
                                  INDEX(SUBSTR(par_nmsegntl, 1, 2), " ") + 1,
                                  LENGTH(par_nmsegntl)).
                NEXT.
            END.

        IF  INDEX(CAPS(SUBSTR(par_nmsegntl, 1, 3)), "OU ") > 0   THEN
            DO:
                par_nmsegntl = SUBSTR(par_nmsegntl, 
                             INDEX(CAPS(SUBSTR(par_nmsegntl, 1, 3)), "OU ") + 1,
                             LENGTH(par_nmsegntl)).
                NEXT.
            END.
     
        LEAVE.
  
    END.

    par_nmresult = par_nmsegntl.


END PROCEDURE.

/***************************************************************************** */
/*Procedure para validar no historico de senhas do cartao magnetico do operad. */
/***************************************************************************** */
PROCEDURE validar-hist-cartmagope:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpusucar AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dssencar AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgencod AS LOGICAL                        NO-UNDO.

    DEF OUTPUT PARAM par_dsdoerro AS CHAR                           NO-UNDO.
    
    FOR EACH craphsh WHERE craphsh.cdcooper = par_cdcooper AND
                           craphsh.nrdconta = par_nrdconta AND
                           craphsh.idseqttl = par_tpusucar AND
                           craphsh.tpdsenha = 9            AND
                           craphsh.nrcpfope = 0            AND
                           craphsh.cddsenha <> ""          NO-LOCK:
        
        /* Parametro par_flgencod indica se a senha ja veio codificada */
        IF  NOT par_flgencod  AND ENCODE(par_dssencar) = craphsh.cddsenha OR 
            par_flgencod AND par_dssencar = craphsh.cddsenha THEN
            DO: 
                par_dsdoerro = "A senha deve ser diferente das 3 ultimas " +
                               "cadastradas".
                RETURN "NOK".
            END.
        
    END.
   
    RETURN "OK".
        
END PROCEDURE. /* FIM gravar-hist-cartmagope */


/***************************************************************************** */
/*Procedure para gravar no historico de senhas do cartao magnetico do operador */
/***************************************************************************** */
PROCEDURE gravar-hist-cartmagope:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpusucar AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dssencar AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM par_dsdoerro AS CHAR                           NO-UNDO.

    DEF VAR aux_flgfirst AS LOGICAL                                 NO-UNDO.

    ASSIGN aux_flgfirst = TRUE.

    FOR EACH craphsh WHERE craphsh.cdcooper = par_cdcooper AND
                           craphsh.nrdconta = par_nrdconta AND
                           craphsh.idseqttl = par_tpusucar AND
                           craphsh.tpdsenha = 9            AND
                           craphsh.nrcpfope = 0
                           EXCLUSIVE-LOCK BY craphsh.idseqsnh DESC:
                    
        IF  aux_flgfirst  THEN
            DO:        
                IF  craphsh.idseqsnh >= 3 THEN
                    DO:
                        DELETE craphsh.
                        NEXT.
                    END.
            END.
        
        ASSIGN aux_flgfirst     = FALSE.
               craphsh.idseqsnh = craphsh.idseqsnh + 1.
    
    END.
   
    CREATE craphsh.
    ASSIGN craphsh.cdcooper = par_cdcooper
           craphsh.nrdconta = par_nrdconta
           craphsh.idseqttl = par_tpusucar
           craphsh.tpdsenha = 9
           craphsh.nrcpfope = 0
           craphsh.idseqsnh = 1
           craphsh.dtcadsnh = aux_datdodia
           craphsh.hrcadsnh = TIME
           craphsh.cddsenha = par_dssencar.
    VALIDATE craphsh.

    RETURN "OK".
        
END PROCEDURE. /* FIM gravar-hist-cartmagope */

PROCEDURE validar-entrega-cartao:
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcartao AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_dssitcar AS CHAR                                    NO-UNDO.
    
    FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    FIND FIRST crapcrm WHERE crapcrm.cdcooper = par_cdcooper AND 
                             crapcrm.nrdconta = par_nrdconta AND
                             crapcrm.nrcartao = par_nrcartao
                             NO-LOCK NO-ERROR.

    RUN verifica-situacao-cartao (INPUT par_cdcooper,           
                                  INPUT crapdat.dtmvtolt,
                                  INPUT crapcrm.dtvalcar,
                                  INPUT crapcrm.cdsitcar,
                                  INPUT crapcrm.dtemscar,
                                 OUTPUT aux_dssitcar).
    
    IF  aux_dssitcar <> "DISPONIVEL" AND 
        aux_dssitcar <> "BLOQUEADO" THEN
    DO:
        CREATE tt-erro.
        ASSIGN tt-erro.dscritic = "Este cartao nao esta disponivel para entrega.".
        RETURN "NOK".
    END.
    
    RETURN "OK".

END PROCEDURE.


/*............................................................................*/
