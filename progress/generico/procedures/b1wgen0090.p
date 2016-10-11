/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +----------------------------------+-----------------------------------------+
  | Rotina Progress                  | Rotina Oracle PLSQL                     |
  +----------------------------------+-----------------------------------------+
  | procedures/b1wgen0090.p          | PAGA0001                                |
  | gera_arq_cooperado               | PAGA0001.pc_gera_arq_cooperado          |
  | gera_arq_cooperado_cnab240       | PAGA0001.pc_gera_arq_coop_cnab240       |
  | gera_arq_cooperado_cnab400       | PAGA0001.pc_gera_arq_coop_cnab400       |
  | prep-retorno-cooperado           | PAGA0001.pc_prep_retorno_cooper_90      | 
  | efetua-lancamento-tarifas-lat    | PAGA0001.pc_efetua_lancto_tarifas_lat   |
  +----------------------------------+-----------------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/

/*..............................................................................

   Programa: sistema/internet/procedures/b1wgen0090.p
   Autor   : Guilherme/Supero
   Data    : 15/03/2011                        Ultima atualizacao: 15/02/2016

   Dados referentes ao programa:

   Objetivo  : BO para preparacao de retorno ao cooperado - Cob. Registrada 

   Alteracoes: 16/05/2011 - Incluso leitura crapcop na gera_arq_cooperado 
                          - Incluso leitura crapcob na gera_arq_cooperado
                          - Incluso TIME na geracao do arq para nao dar
                            duplicates e ter controle de hora na 
                            gera_arq_cooperado 
                          - Tratar RETURN na gera-lcm-cooperado (Guilherme).
                            
               10/06/2011 - Nao cobrar tarifa ao gerar retorno para o 
                            cooperado de ent confirmada (Rafael).
                            
               26/07/2011 - Incluido campos de abatimento e desconto
                            na procedure prep-retorno-cooperado (Rafael). 
                            
               25/08/2011 - Inclusao de procedures para importacao de boletos 
                            (André R./Supero).
                            
               06/09/2011 - Ajustes na rotina de importacao de boletos (Rafael).
               
               27/10/2011 - Parametros na gera_protocolo 
                          - Tratamento de erro na geracao do protocolo,
                            foi utilizado o mesmo tratando que existe na 
                            pi_grava_rtc (Guilherme).
                            
               08/11/2011 - Ajuste na rotina de geracao de arq de retorno
                            ao cooperado (Rafael).
                            
               26/12/2011 - Incluido TIME no registro da craplcm. (Rafael).
               
               14/08/2012 - Ajuste em proc. p_integra_arq_remessa, nao gera 
                            boleto quando encontrado cdcritic. (Jorge).
                            
               25/04/2013 - Projeto Melhorias da Cobranca - implementar rotina
                            de importacao de titulos CNAB240 - 085. (Rafael)
                            
               05/06/2013 - Projeto Melhorias da Cobranca - implementar rotina
                            gerar arquivo de retorno CNAB400. (Rafael)
                            
               26/06/2013 - Ajuste na rotina de geracao de arquivo de retorno
                            ao cooperado - CNAB240 e CNAB400. (Rafael)
                            
               04/07/2013 - Incluso novo parametro na procedures gera-lcm-cooperado,
                            alterado processo de busca valor tarifa para utilizar a
                            rotina carrega_dados_tarifa_cobranca da b1wgen0153 e 
                            alterado a procedures gera-lcm-cooperado para utilzar a 
                            procedure cria_lan_auto_tarifa da b1wgen0153. (Daniel) 
                            
               30/07/2013 - Incluso as procedures carrega_dados_tarifa_cobranca e 
                            cria-log-tarifa-cobranc. (Daniel)
                            
               16/08/2013 - Nao cobrar tarifa de baixa/comandada banco (baixa
                            automatica) quando realizada pelo sistema. (Rafael)
                            
               28/08/2013 - Incluso parametro tt-lat-consolidada na procedure
                            inst-pedido-baixa, criado a procedure. (Daniel)   
                            
               05/09/2013 - Efetuado ajustes na procedure p_integra_arq_remessa_cnab240_085
                            para efetuar validacao de campos e retornar motivo de
                            recusa (Daniel).
                            
               10/09/2013 - Efetuado ajustes na procedure p_integra_arq_remessa_cnab400_085
                            para efetuar validacao de campos e retornar motivo de
                            recusa, incluso processo para tratamento de instrucoes (Daniel).
                            
               23/09/2013 - Ajuste na integracao de arquivo remessa - cobranca
                            sem registro. (Rafael)                           
                            
               10/10/2013 - Incluido parametro cdprogra nas procedures da 
                            b1wgen0153 que carregam dados de tarifas (Tiago).
                            
               27/11/2013 - Alterado processo de criacao crapcre para inicar nrremcre com
                            999999 e nao mais 1 (Daniel).                                       
                            
               03/12/2013 - Tratamento especial no controle da numeracao da 
                            tabela crapcre dos titulos da cobranca com
                            registro BB. (Rafael).
                          - Removido procedure p_cria_titulo_dda. (Rafael)
                          
               26/12/2013 - Melhoria processo leitura crapcob e craprtc (Daniel).
               
               09/01/2014 - substituido campo crapret.nrremret por 
                            craprtc.nrremret nas procedures
                            gera_arq_cooperado_cnab240 e 
                            gera_arq_cooperado_cnab400 (Tiago)
                            
               16/01/2014 - Retirado verificacao se par_flgproce <> craprtc.flgproce na
                            na geracao retorno cooperado (Daniel).             
                            
               31/01/2014 - Ajustar conversao do valor da multa (CNAB400) de 
                            string para deci / 100 (Rafael).
                            
               04/02/2014 - Ajuste Projeto Novo Fator de Vencimento (Daniel). 
               
               28/02/2014 - Trocar "&" por "E" ao gerar arquivo de retorno de 
                            cobranca ao cooperado - softdesk 133028. (Rafael).
                            
               05/03/2014 - Incluso VALIDATE (Daniel). 
               
               28/03/2014 - Inclusao do filtro pelo numero da conta no
                            FIND FIRST crapass (linha 3913). (Fabricio)
                            
               28/04/2014 - Ajuste na procedure prep-retorno-cooperado e 
                            prep-retorno-cooperado-rejeitado para usar sequence
                            atraves do Oracle (Daniel)   
                            
               04/06/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).           
               
               05/06/2014 - Removido variável aux_tpdmulta da "p_integra_arq_remessa_cnab400_085"
                            para que seja utilizada a variável global. (Douglas - Chamado 165307)
                            
               24/06/2014 - Iniciar valor de desconto e abatimento como zero para 
                            nao replicar para os outros boletos, nas procedures
                            p_integra_arq_remessa_cnab240_085 e 
                            p_integra_arq_remessa_cnab400_085. 
                            (Lucas R. Softdesk 163658).
                            
               29/07/2014 - Alterado a sequencia das validacoes no cnab240
                            para verificar nosso numero antes do convenio.
                            procedure p_integra_arq_remessa_cnab240_085
                            (Tiago/Rosangela SD139129).         
                            
              06/08/2014 - Ajuste nas rotinas gera_arq_cooperado_cnab240 e gera_arq_cooperado_cnab400
                           para retirar acentuaçao antes de gerar arquivo de retorno. 
                           (Odirlei/Amcom SD185976)
                           
              27/10/2014 - Fazer verificação de CEP na base dos Correios em validações
                           (Lucas Lunelli SD 206001).
                           
              02/12/2014 - Ajuste nas rotinas p_integra_arq_remessa_cnab240_085 e 
                           p_integra_arq_remessa_cnab400_085 para importar flag Aceite do arquivo. 
                           (Odirlei/Amcom SD226890)
                            
              11/12/2014 - Conversão da fn_sequence para procedure para não
                           gerar cursores abertos no Oracle. (Dionathan)

              21/01/2015 - Ajustar gera_arq_cooperado_cnab240 para carregar o 
                           campo crapcob.dsdoccop no Segmento T, posição 59-73
                           (Douglas - Chamado 235429)

              21/01/2015 - Adicionar tratamento na procedure 
                           p_integra_arq_remessa_cnab400_085, para se vier 
                           preenchido no arquivo que deve ser efetuado protesto 
                           em dias corridos a flag "flgdprot" deve ser TRUE
                           (Douglas - Chamado 233956)

              12/03/2015 - Ajustar o tratamento de protesto na p_integra_arq_remessa_cnab400_085 
                           (Douglas - Chamado 265075)

              23/03/2015 - Adicionado campo e-mail na p_grava_sacado. Essa informacao
                           vem da integração de arquivos cnab240 e cnab400.
                           (Projeto Boleto por email - Douglas)
                           
              28/04/2015 - Ajustes referente Projeto Cooperativa Emite e Expede 
                          (Daniel/Rafael/Reinert)

              05/05/2015 - Adicionado validação no processamento do arquivo
                           de remessa para quando o boleto já existir e possuir 
                           dsinform com "LIQAPOSBX" e o incobran zero, ele seja
                           excluido e criado pela rotina sem gerar erro.
                           (Douglas - Chamado 273377)

              05/05/2015 - Ajustado a validacao para o numero do arquivo de
                           remessa para o cnab240. (Douglas - Chamado 281828)
              
              07/05/2015 - Adicionado validacoes para data de emissao retroativa
                           maior que 30 dias e para Data de emissao superior 
                           ao limite 13/10/2049 e para data de emissao superior
                           a data de vencimento. SD 257997 (Kelvin).       
                           
                          19/05/2015 - Correcao do cadastro de avalistas obrigando o cadastro de
                                                   tipo e cpf/cnpj e alteracao da inicializacao da variavel 
                                                   aux_tpdjuros que deve ser iniciada com 3 (isento).
                                                   SD 266252 (Carlos Rafael Tanholi).                
                           
              01/06/2015 - Ajute na validacao de data de emissao retroativa
                           para maior que 90 dias ao inves de 30
                           (Adriano).
                           
              31/07/2015 - Ajuste para retirar o caminho absoluto na chamada
                           de fontes
                           (Adriano - SD 314469).       
                           
              10/09/2015 - Ajustado rotina p_processa_titulos para gerar log
                           quando o tipo de emissao do boleto fo coop. emite e 
                           expede SD326749 (Odirlei-AMcom)
                           
              10/09/2015 - Ajustado rotina p_integra_arq_remessa_cnab240_085 e 
                           p_integra_arq_remessa_cnab400_085 para qnd
                           não for enviado valor de multa, definir tipo como
                           Isento SD32868 (Odirlei-AMcom)
                           
              11/09/2015 - Replicado ajustes realizados na rotina 
                           pc_prep_retorno_coop_90 para a prep-retorno-cooperado
                           (Adriano).
                           
              26/10/2015 - Realizado ajustes para eliminar as rotinas abaixo,
                           pois, os programas que as utilizam foram alterados
                           para chamar as resptevias conversoes PLSQL.
                           - gera_arq_cooperado         
                           - gera_arq_cooperado_cnab240 
                           - gera_arq_cooperado_cnab400  
                           (Adriano - SD 335749).
                           
              11/01/2016 - Ajuste referente Projeto Negativacao Serasa (Daniel)

              15/02/2016 - Inclusao do parametro conta na chamada da
                           carrega_dados_tarifa_cobranca. (Jaison/Marcos)

			  26/02/2016 - Ajuste para utilizar sequence ao alimentar o campo
                           nrremret na criacao do registro craprtc
                           (Adriano - SD 391157)  


              03/02/2016 - Ajuste para utilizar sequence ao alimentar o campo
                           nrremret na criacao do registro craprtc dentro da 
						   prep-retorno-cooperado-rejeitado
                           (Adriano - SD 391157)  

..............................................................................*/

DEF STREAM str_1.

{ sistema/generico/includes/b1wgen0010tt.i }
{ sistema/generico/includes/b1wgen0087tt.i }
{ sistema/generico/includes/var_internet.i }

{ sistema/generico/includes/var_oracle.i }

DEF STREAM str_1.
DEF STREAM str_3.

DEF STREAM str_arq_coop.   /* Para arquivo individual por cliente */
DEF STREAM str_arq_cnab.   /* Para arquivo por cooperado via InternetBanking */

/* temp-table para armazenar instrucoes comandas por arquivo pelo cooperado */
DEF TEMP-TABLE tt-instr
    FIELD cdcooper LIKE crapcob.cdcooper
    FIELD nrdconta LIKE crapcob.nrdconta
    FIELD nrcnvcob LIKE crapcob.nrcnvcob
    FIELD nrdocmto LIKE crapcob.nrdocmto
    FIELD nrremass AS INTE
    FIELD cdocorre AS INTE
    FIELD vldescto AS DECI
    FIELD vlabatim AS DECI
    FIELD dtvencto AS DATE
    FIELD nrnosnum AS CHAR
    FIELD nrinssac AS DECI
    FIELD dsendsac AS CHAR
    FIELD nmbaisac AS CHAR
    FIELD nrcepsac AS INTE
    FIELD nmcidsac AS CHAR
    FIELD cdufsaca AS CHAR
    FIELD qtdiaprt AS INTE
    FIELD dsdoccop AS CHAR
    FIELD cdbandoc LIKE crapcob.cdbandoc
    FIELD nrdctabb LIKE crapcob.nrdctabb
    FIELD inemiten AS INTE
    FIELD dtemscob AS DATE.


DEF TEMP-TABLE tt-aux-consolidada LIKE tt-lat-consolidada.

DEF NEW SHARED VAR glb_cdcritic AS INTE                          NO-UNDO.
DEF NEW SHARED VAR glb_dscritic AS CHAR                          NO-UNDO.
DEF NEW SHARED VAR glb_nrcalcul AS DECI                          NO-UNDO.
DEF NEW SHARED VAR glb_stsnrcal AS LOGI                          NO-UNDO.

DEF VAR aux_nrdconta AS INTE                                     NO-UNDO.
DEF VAR aux_nmprimtl AS CHAR                                     NO-UNDO.
DEF VAR aux_nrbloque AS DECI                                     NO-UNDO.
DEF VAR aux_cdcooper AS INTE                                     NO-UNDO.
DEF VAR aux_dtmvtolt AS DATE                                     NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                     NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                     NO-UNDO.
DEF VAR aux_setlinha AS CHAR    FORMAT "x(243)"                  NO-UNDO.
DEF VAR aux_dsusoemp AS CHAR                                     NO-UNDO.
DEF VAR aux_flgregis AS LOGI                                     NO-UNDO.
DEF VAR aux_nrprotoc AS CHAR                                     NO-UNDO.
DEF VAR aux_nmarquiv AS CHAR                                     NO-UNDO.
DEF VAR aux_vlrtotal AS DECI                                     NO-UNDO.

DEF VAR aux_qtbloque AS INTE                                     NO-UNDO.
DEF VAR aux_cdbancbb AS INTE                                     NO-UNDO.
DEF VAR aux_cdbccxlt AS INTE                                     NO-UNDO.
DEF VAR aux_nrdolote AS INTE                                     NO-UNDO.
DEF VAR aux_cdhistor AS INTE                                     NO-UNDO.
DEF VAR aux_nrdctabb AS INTE                                     NO-UNDO.
DEF VAR aux_cdbandoc AS INTE                                     NO-UNDO.
DEF VAR aux_cdocorre AS INTE                                     NO-UNDO.
DEF VAR aux_nrcnvcob AS INTE                                     NO-UNDO.
DEF VAR aux_nrremass AS INTE                                     NO-UNDO.
DEF VAR aux_dsnosnum AS CHAR                                     NO-UNDO.
DEF VAR aux_tpdjuros AS INTE                                     NO-UNDO.
DEF VAR aux_vldjuros AS DECI                                     NO-UNDO.
DEF VAR aux_tpdmulta AS INTE                                     NO-UNDO.
DEF VAR aux_vldmulta AS DECI                                     NO-UNDO.
DEF VAR aux_flgddaok AS LOGICAL                                  NO-UNDO.
DEF VAR aux_inemiten AS INTE                                     NO-UNDO.
DEF VAR aux_flgdprot AS LOGICAL                                  NO-UNDO.
DEF VAR aux_flgaceit AS LOGICAL                                  NO-UNDO.
DEF VAR aux_qtdiaprt AS INTE                                     NO-UNDO.
DEF VAR aux_vlabatim AS DECI                                     NO-UNDO.

DEF VAR aux_cdcartei LIKE crapcob.cdcartei                       NO-UNDO.
DEF VAR aux_cddespec LIKE crapcob.cddespec                       NO-UNDO.
DEF VAR aux_vltitulo LIKE crapcob.vltitulo                       NO-UNDO.
DEF VAR aux_vldescto LIKE crapcob.vldescto                       NO-UNDO.
DEF VAR aux_dsdoccop LIKE crapcob.dsdoccop                       NO-UNDO.
DEF VAR aux_dtemscob AS DATE                                     NO-UNDO.
DEF VAR aux_dtvencto LIKE crapcob.dtvencto                       NO-UNDO.
DEF VAR aux_cdtpinsc LIKE crapcob.cdtpinsc                       NO-UNDO.
DEF VAR aux_nrinssac LIKE crapcob.nrinssac                       NO-UNDO.
DEF VAR aux_nmdsacad LIKE crapcob.nmdsacad                       NO-UNDO.
DEF VAR aux_dsendsac LIKE crapcob.dsendsac                       NO-UNDO.
DEF VAR aux_nmbaisac LIKE crapcob.nmbaisac                       NO-UNDO.
DEF VAR aux_nrcepsac LIKE crapcob.nrcepsac                       NO-UNDO.
DEF VAR aux_nmcidsac LIKE crapcob.nmcidsac                       NO-UNDO.
DEF VAR aux_cdufsaca LIKE crapcob.cdufsaca                       NO-UNDO.
DEF VAR aux_cdtpinav LIKE crapcob.cdtpinav                       NO-UNDO.
DEF VAR aux_nrinsava LIKE crapcob.nrinsava                       NO-UNDO.
DEF VAR aux_nmdavali LIKE crapcob.nmdavali                       NO-UNDO.

/* E-mail do pagador */
DEF VAR aux_dsdemail AS CHAR				                     NO-UNDO.
DEF VAR aux_nrcelsac LIKE crapsab.nrcelsac                       NO-UNDO.

DEF VAR aux_dsdinstr LIKE crapcob.dsdinstr                       NO-UNDO.

DEF VAR aux_cdtocede AS INTE                                     NO-UNDO.

DEF VAR aux_inemiexp AS INTE                                     NO-UNDO.

DEF VAR aux_flserasa AS LOGICAL                                  NO-UNDO.
DEF VAR aux_qtdianeg AS INTE                                     NO-UNDO.
DEF VAR aux_inserasa AS INTE                                     NO-UNDO.
DEF VAR par_dscritic AS CHAR                                     NO-UNDO.

DEF VAR h-b1crapcob  AS HANDLE                                   NO-UNDO.
DEF VAR h-b1wgen0087 AS HANDLE                                   NO-UNDO.
DEF VAR h-b1wgen0089 AS HANDLE                                   NO-UNDO.
DEF VAR h-b1wgen9999 AS HANDLE                                   NO-UNDO.

/*............................................................................*/

PROCEDURE gera-lcm-cooperado:

    DEF  INPUT PARAM par_idregcob AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_idregcco AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_cdhistor AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_vltarifa AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdfvlcop AS INTE                           NO-UNDO.
    /* incluido parametro de ret de erro - Rafael Cechet - 06/04/11 */
    DEF OUTPUT PARAM ret_dsinserr AS CHAR                           NO-UNDO.
   
    DEF VAR aux_nrdocmto LIKE craplcm.nrdocmto                      NO-UNDO.

    DEF VAR aux_nmprimtl AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrbloque AS DECI                                    NO-UNDO.
    DEF VAR aux_setlinha AS CHAR    FORMAT "x(243)"                 NO-UNDO.

    DEF VAR aux_nrdconta AS INTE                                    NO-UNDO.
    DEF VAR aux_cdcooper AS INTE                                    NO-UNDO.
    DEF VAR aux_dtmvtolt AS DATE                                    NO-UNDO.
    DEF VAR aux_cdoperad AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsusoemp AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmdatela AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrprotoc AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmarquiv AS CHAR                                    NO-UNDO.

    DEF VAR h-b1wgen0153 AS HANDLE                                  NO-UNDO.

    DEF BUFFER bcrapcco FOR crapcco.
    DEF BUFFER bcrapcob FOR crapcob.

    FIND FIRST bcrapcco WHERE ROWID(bcrapcco) = par_idregcco
         NO-LOCK NO-ERROR.

    FIND FIRST bcrapcob WHERE ROWID(bcrapcob) = par_idregcob
         NO-LOCK NO-ERROR.

    IF par_vltarifa > 0 THEN DO TRANSACTION:
    
        
        FIND FIRST crapdat WHERE crapdat.cdcooper = bcrapcco.cdcooper
                                NO-ERROR NO-WAIT.

        IF NOT AVAIL crapdat THEN DO:
            ret_dsinserr = "ERRO no Lancamento - Tabela crapdat nao encontrada ".
            RETURN "NOK".
        END.

        IF  NOT VALID-HANDLE(h-b1wgen0153) THEN
                RUN sistema/generico/procedures/b1wgen0153.p PERSISTENT SET h-b1wgen0153.

        /* Efetua lancamento Tarifa */
        RUN cria_lan_auto_tarifa IN h-b1wgen0153
                           (INPUT bcrapcco.cdcooper,
                            INPUT bcrapcob.nrdconta,            
                            INPUT par_dtmvtolt,
                            INPUT par_cdhistor, 
                            INPUT par_vltarifa,
                            INPUT "1",                                              /* cdoperad */
                            INPUT bcrapcco.cdagenci,                                /* cdagenci */
                            INPUT bcrapcco.cdbccxlt,                                /* cdbccxlt */         
                            INPUT bcrapcco.nrdolote,                                /* nrdolote */        
                            INPUT 1,                                                /* tpdolote */         
                            INPUT 0,                                                /* nrdocmto */
                            INPUT bcrapcob.nrdconta,                                /* nrdconta */
                            INPUT STRING(bcrapcob.nrdconta,"99999999"),             /* nrdctitg */
                            INPUT "",                                               /* cdpesqbb */
                            INPUT 0,                                                /* cdbanchq */
                            INPUT 0,                                                /* cdagechq */
                            INPUT 0,                                                /* nrctachq */
                            INPUT FALSE,                                            /* flgaviso */
                            INPUT 0,                                                /* tpdaviso */
                            INPUT par_cdfvlcop,                                     /* cdfvlcop */
                            INPUT crapdat.inproces,                                 /* inproces */
                            OUTPUT TABLE tt-erro).

        DELETE PROCEDURE h-b1wgen0153.

        IF  RETURN-VALUE = "NOK"  THEN DO:

            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF AVAIL tt-erro THEN 
            DO:
                ret_dsinserr = "ERRO no Lancamento em Conta: " + STRING(crapass.nrdconta,"zzzz,zz9,9") + 
                               " " + tt-erro.dscritic.

                RUN cria-log-tarifa-cobranca(INPUT par_idregcob,
                                             INPUT ret_dsinserr).

                RETURN "NOK".
            END.
        END.


    END. /* FIM do DO TRANSACTION */
    ELSE
    DO:
        ret_dsinserr = "Valor da Tarifa nao valido [" +
                       STRING(par_vltarifa,"z9.99") +
                       "] - Erro Lancamento em Conta".
        RETURN "NOK".
    END.

    RETURN "OK".

END PROCEDURE.

/*............................................................................*/

PROCEDURE prep-retorno-cooperado:

    DEF  INPUT PARAM par_idregcob AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_cdocorre AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_cdmotivo AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_vltarifa AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_cdbcoctl AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_cdagectl AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrremass AS INT                            NO-UNDO.

    DEF VAR aux_nmarquiv AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmarqcre AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsinserr AS CHAR                                    NO-UNDO. 
    DEF VAR aux_cdhistor AS INT                                     NO-UNDO.

    DEF VAR aux_nrremrtc AS INT                                     NO-UNDO.
    DEF VAR aux_nrremcre AS INT                                     NO-UNDO.
    DEF VAR aux_nrseqreg AS INT                                     NO-UNDO.
    DEF VAR aux_vltarifa AS DECI                                    NO-UNDO.

    DEF VAR tar_cdhistor AS INTE                                    NO-UNDO.
    DEF VAR tar_cdhisest AS INTE                                    NO-UNDO.
    DEF VAR tar_vltarifa AS DECI                                    NO-UNDO.
    DEF VAR tar_dtdivulg AS DATE                                    NO-UNDO.
    DEF VAR tar_dtvigenc AS DATE                                    NO-UNDO.
    DEF VAR tar_cdfvlcop AS INTE                                    NO-UNDO.
    DEF VAR aux_cdfvlcop AS INTE                                    NO-UNDO.

    DEF VAR aux_busca    AS CHAR                                    NO-UNDO.
    
    DEF BUFFER bcrapcco FOR crapcco.
    DEF BUFFER bcrapcob FOR crapcob.

    FIND FIRST bcrapcob WHERE ROWID(bcrapcob) = par_idregcob
                              NO-LOCK NO-ERROR.

    /* Em caso de Entrada Rejeitada ou Instrucao Rejeitada Zera Valor Tarifa */
    IF par_cdocorre = 03 OR
       par_cdocorre = 26 THEN 
       ASSIGN aux_vltarifa = 0
              aux_cdhistor = 0.
    ELSE 
       DO:
	      
		  IF NOT VALID-HANDLE(h-b1wgen0089) THEN		  
	      RUN sistema/generico/procedures/b1wgen0089.p 
                PERSISTENT SET h-b1wgen0089.
          
		  IF NOT VALID-HANDLE(h-b1wgen0089) THEN RETURN "NOK".

          RUN busca-dados-tarifa IN h-b1wgen0089
		                        (INPUT  bcrapcob.cdcooper,    /* cdcooper */
                                 INPUT  bcrapcob.nrdconta,    /* nrdconta */ 
                                 INPUT  bcrapcob.nrcnvcob,    /* nrconven */ 
                                 INPUT  "RET",                /* dsincide */
                                 INPUT  par_cdocorre,         /* cdocorre */
                                 INPUT  par_cdmotivo,         /* cdmotivo */
                                 INPUT  par_idregcob,
                                 INPUT  0,                    /* flaputar - Nao apurar */
                                 OUTPUT tar_cdhistor,         /* cdhistor */
                                 OUTPUT tar_cdhisest,         /* cdhisest */
                                 OUTPUT tar_vltarifa,         /* vltarifa */
                                 OUTPUT tar_dtdivulg,         /* dtdivulg */
                                 OUTPUT tar_dtvigenc,         /* dtvigenc */
                                 OUTPUT tar_cdfvlcop,         /* cdfvlcop */
                                 OUTPUT TABLE tt-erro) .
          
          IF RETURN-VALUE = "OK" THEN
             DO:
                /* Cobrar Tarifas Apenas Quando Instrucao */
                IF par_cdocorre <> 2 THEN 
                   DO:
                      IF  par_vltarifa = 0 THEN
                          ASSIGN aux_vltarifa = tar_vltarifa
                                 aux_cdhistor = tar_cdhistor
                                 aux_cdfvlcop = tar_cdfvlcop.
                          ELSE
                             ASSIGN aux_vltarifa = par_vltarifa
                                    aux_cdhistor = tar_cdhistor
                                    aux_cdfvlcop = tar_cdfvlcop.
                      
                   END.                                        
                ELSE
                   ASSIGN aux_vltarifa = tar_vltarifa
                          aux_cdhistor = 0.

             END.

       END.

    /*** Gerar tarifas Cooperado **/
    /*** somente se for comandado pelo cooperado ***/
    /* 9=Baixa '09'=Comandada pelo Banco 085 (temporario) */
    IF  (par_cdoperad = "1" OR par_cdoperad = "0") AND
        (par_cdocorre = 9 AND par_cdmotivo = "09") AND 
        (bcrapcob.cdbandoc = 085) THEN
        ASSIGN aux_vltarifa = 0
               aux_cdhistor = 0.

    ASSIGN aux_nmarquiv = "cobret" + STRING(MONTH(par_dtmvtolt),"99") + 
                                     STRING(DAY(par_dtmvtolt),"99")
           aux_nmarqcre = "ret085" + STRING(MONTH(par_dtmvtolt),"99") + 
                                     STRING(DAY(par_dtmvtolt),"99").

    DO TRANSACTION:

        /*** Localiza o ultimo RTC desta data ***/
        FIND LAST craprtc WHERE craprtc.cdcooper = bcrapcob.cdcooper AND
                                craprtc.nrdconta = bcrapcob.nrdconta AND
                                craprtc.nrcnvcob = bcrapcob.nrcnvcob AND
                                craprtc.dtmvtolt = par_dtmvtolt      AND
                                craprtc.intipmvt = 2                 
                                NO-LOCK NO-ERROR.
    
        IF NOT AVAIL craprtc THEN 
           DO:
              { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
              
              /* Busca a proxima sequencia do campo crapldt.nrsequen */
              RUN STORED-PROCEDURE pc_sequence_progress
              aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPRTC"
                                                  ,INPUT "NRREMRET"
                                                  ,INPUT STRING(bcrapcob.cdcooper) + ";" +
                                                         STRING(bcrapcob.nrdconta) + ";" +
                                                         STRING(bcrapcob.nrcnvcob) + ";2"                                                   
                                                  ,INPUT "N"
                                                  ,"").
             
              CLOSE STORED-PROC pc_sequence_progress
                    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
             
              { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
             
              ASSIGN aux_nrremrtc = INTE(pc_sequence_progress.pr_sequence)
                                    WHEN pc_sequence_progress.pr_sequence <> ?.
             
              CREATE craprtc.
              ASSIGN craprtc.cdcooper = bcrapcob.cdcooper
                     craprtc.nrdconta = bcrapcob.nrdconta
                     craprtc.nrcnvcob = bcrapcob.nrcnvcob
                     craprtc.dtmvtolt = par_dtmvtolt
                     craprtc.nrremret = aux_nrremrtc
                     craprtc.nmarquiv = aux_nmarquiv
                     craprtc.flgproce = NO
                     craprtc.cdoperad = par_cdoperad
                     craprtc.dtaltera = par_dtmvtolt
                     craprtc.hrtransa = TIME
                     craprtc.dtdenvio = ?
                     craprtc.qtreglot = 1
                     craprtc.intipmvt = 2.

              VALIDATE craprtc.

           END.
        ELSE
           /*Se encontrou, utiliza o que já existe - Numero remessa*/
           ASSIGN aux_nrremrtc = craprtc.nrremret.

        FIND LAST crapcre WHERE crapcre.cdcooper = bcrapcob.cdcooper AND
                                crapcre.nrcnvcob = bcrapcob.nrcnvcob AND
                                crapcre.dtmvtolt = par_dtmvtolt      AND
                                crapcre.intipmvt = 2
                                NO-LOCK NO-ERROR.
    
        IF NOT AVAIL crapcre THEN 
           DO:
              /* tratamento especial para titulos cobranca com registro BB */
              IF  bcrapcob.cdbandoc = 1 THEN 
                  DO:
                     FIND LAST crapcre WHERE 
                               crapcre.cdcooper = bcrapcob.cdcooper AND
                               crapcre.nrcnvcob = bcrapcob.nrcnvcob AND
                               crapcre.nrremret > 999999            AND
                               crapcre.intipmvt = 2 /* retorno */
                               NO-LOCK NO-ERROR.
                     
                     /* numeracao BB quando gerado pelo sistema, comecar 
                        a partir de 999999 para nao confundir com o numero 
                        de controle do arquivo de retorno BB */
                     IF  NOT AVAIL crapcre THEN
                         ASSIGN aux_nrremcre = 999999.
                     ELSE
                         ASSIGN aux_nrremcre = crapcre.nrremret + 1.
                  END.
              ELSE 
                 DO:
                    FIND LAST crapcre WHERE 
                              crapcre.cdcooper = bcrapcob.cdcooper AND
                              crapcre.nrcnvcob = bcrapcob.nrcnvcob AND
                              crapcre.intipmvt = 2 /* retorno */
                              NO-LOCK NO-ERROR.
                   
                    IF  NOT AVAIL crapcre THEN
                        ASSIGN aux_nrremcre = 1.
                    ELSE
                        ASSIGN aux_nrremcre = crapcre.nrremret + 1.
                 END.
              
              CREATE crapcre.
              ASSIGN crapcre.cdcooper = bcrapcob.cdcooper
                     crapcre.nrcnvcob = bcrapcob.nrcnvcob
                     crapcre.dtmvtolt = par_dtmvtolt
                     crapcre.nrremret = aux_nrremcre
                     crapcre.intipmvt = 2
                     crapcre.nmarquiv = aux_nmarqcre
                     crapcre.flgproce = YES
                     crapcre.cdoperad = par_cdoperad
                     crapcre.dtaltera = par_dtmvtolt
                     crapcre.hrtranfi = TIME.

              VALIDATE crapcre.

           END.
        ELSE
           /*Se encontrou, utiliza o que já existe - Numero remessa*/
           ASSIGN aux_nrremcre = crapcre.nrremret.

        /* Localiza ultima sequencia */
        ASSIGN aux_busca = TRIM(STRING(bcrapcob.cdcooper))   + ";" +
                           TRIM(STRING(bcrapcob.nrcnvcob))   + ";" +
                           TRIM(STRING(aux_nrremcre)).

        RUN STORED-PROCEDURE pc_sequence_progress
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPRET"
                                            ,INPUT "NRSEQREG"
                                            ,INPUT aux_busca
                                            ,INPUT "N"
                                            ,"").
        
        CLOSE STORED-PROC pc_sequence_progress
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                          
        ASSIGN aux_nrseqreg = INTE(pc_sequence_progress.pr_sequence)
                              WHEN pc_sequence_progress.pr_sequence <> ?.

        CREATE crapret.
        ASSIGN crapret.cdcooper = bcrapcob.cdcooper
               crapret.nrcnvcob = bcrapcob.nrcnvcob
               crapret.nrdconta = bcrapcob.nrdconta
               crapret.nrdocmto = bcrapcob.nrdocmto
               crapret.nrretcoo = aux_nrremrtc      /* Ultimo da RTC */
               crapret.nrremret = aux_nrremcre      /* Ultimo da CRE */
               crapret.nrseqreg = aux_nrseqreg      /* Ultimo da RET */
               crapret.cdocorre = par_cdocorre
               crapret.cdmotivo = par_cdmotivo
               crapret.vltitulo = bcrapcob.vltitulo
               crapret.vlabatim = bcrapcob.vlabatim
               crapret.vldescto = bcrapcob.vldescto
               crapret.vltarass = aux_vltarifa
               crapret.cdbcorec = par_cdbcoctl
               crapret.cdagerec = par_cdagectl
               crapret.dtocorre = par_dtmvtolt
               crapret.cdoperad = par_cdoperad
               crapret.dtaltera = par_dtmvtolt
               crapret.hrtransa = TIME
               crapret.nrnosnum = bcrapcob.nrnosnum
                                 
               crapret.dsdoccop = bcrapcob.dsdoccop
               crapret.nrremass = par_nrremass
               crapret.dtvencto = bcrapcob.dtvencto.

        VALIDATE crapret.

        LEAVE.

    END. /* END do DO TRANSACTION */

END PROCEDURE.

/*.......................................................................... */

PROCEDURE p_integra_arq_remessa:
   
   DEF INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
   DEF INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
   DEF INPUT PARAM par_nmarquiv AS CHAR                              NO-UNDO.
   DEF INPUT PARAM par_idorigem AS INTE                              NO-UNDO.
   DEF INPUT PARAM par_dtmvtolt AS DATE                              NO-UNDO.
   DEF INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.
   DEF INPUT PARAM par_nmdatela AS CHAR                              NO-UNDO.
                                       
   DEF OUTPUT PARAM ret_qtreqimp AS INTE                             NO-UNDO.
   DEF OUTPUT PARAM ret_nrremret AS INTE                             NO-UNDO.
   DEF OUTPUT PARAM ret_nrprotoc AS CHAR                             NO-UNDO.
   DEF OUTPUT PARAM ret_cdcritic AS INTE                             NO-UNDO.
   DEF OUTPUT PARAM ret_hrtransa AS INTE                             NO-UNDO.
   DEF OUTPUT PARAM TABLE FOR crawrej.

   DEF VAR aux_setlinha AS CHAR    FORMAT "x(243)"                   NO-UNDO.
   DEF VAR aux_flgfirst AS LOGICAL                                   NO-UNDO.
   DEF VAR aux_nmendter AS CHAR                                      NO-UNDO.
   DEF VAR aux_server   AS CHAR                                      NO-UNDO.
   DEF VAR aux_nmfisico AS CHAR                                      NO-UNDO.
   DEF VAR aux_cdagenci AS INT                                       NO-UNDO.
   DEF VAR aux_contador AS INT                                       NO-UNDO.
   DEF VAR aux_flgutceb AS LOGICAL                                   NO-UNDO.

   DEF VAR tel_nmarqint AS CHAR FORMAT "x(60)"                       NO-UNDO.
   DEF VAR aux_nmarqimp AS CHAR                                      NO-UNDO.
   DEF VAR aux_dscritic AS CHAR                                      NO-UNDO.

   /*DEF VAR glb_cdcooper AS INTE                                      NO-UNDO.*/
   /*DEF VAR glb_dtmvtolt AS DATE                                      NO-UNDO.*/
   /*DEF VAR glb_cdrelato AS INTE                                      NO-UNDO.*/
   /*DEF VAR glb_cdempres AS INTE                                      NO-UNDO.*/

   ASSIGN aux_nrdconta = par_nrdconta
          aux_cdcooper = par_cdcooper
          aux_dtmvtolt = par_dtmvtolt
          aux_cdoperad = par_cdoperad
          aux_nmdatela = par_nmdatela
          aux_nmarquiv = par_nmarquiv.
  
   FORM aux_setlinha  FORMAT "x(243)"
        WITH FRAME AA WIDTH 243 NO-BOX NO-LABELS.

   /*  Acessa dados da cooperativa  */
   FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE crapcop   THEN
        DO:
            ret_cdcritic = 651. /* Falta registro de controle da cooperativa */
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic VIEW-AS ALERT-BOX.
            RETURN.
        END.

   EMPTY TEMP-TABLE crawaux.
   EMPTY TEMP-TABLE crawrej.

   ASSIGN  aux_flgfirst = FALSE
           ret_cdcritic = 0.

   INPUT STREAM str_3 THROUGH VALUE( "ls " + par_nmarquiv + " 2> /dev/null")
                NO-ECHO.

   ASSIGN aux_contador = 0.
   
   DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

      ASSIGN aux_contador = aux_contador + 1
             aux_nmfisico = "integra/cobran" + STRING(par_dtmvtolt,"999999") +
                            "_" + STRING(aux_contador,"9999") + "_"
                            + STRING(par_nrdconta,"99999999").

      SET STREAM str_3 aux_nmarquiv FORMAT "x(90)" WITH WIDTH 100 NO-ERROR.

      IF  ERROR-STATUS:ERROR THEN DO:
          glb_cdcritic = 999.
          glb_dscritic = "Nome do Arquivo muito grande".
          RUN fontes/critic.p.
          /* cria rejeitado */
          CREATE crawrej.
          ASSIGN crawrej.cdcooper = par_cdcooper
                 crawrej.nrdconta = par_nrdconta
                 crawrej.nrdocmto = 0
                 crawrej.dscritic = glb_dscritic.
          RETURN "NOK".
      END.

      UNIX SILENT VALUE("dos2ux " + aux_nmarquiv + " > " + 
                        "/usr/coop/" + crapcop.dsdircop + "/" + aux_nmfisico +
                        " 2> /dev/null").

      UNIX SILENT VALUE("quoter " + "/usr/coop/" + crapcop.dsdircop + "/" + 
                        aux_nmfisico + " > " + 
                        "/usr/coop/" + crapcop.dsdircop + "/" + aux_nmfisico +
                        ".q" + " 2> /dev/null").

      INPUT STREAM str_1 FROM VALUE("/usr/coop/" + crapcop.dsdircop + "/" +
                                    aux_nmfisico + ".q") NO-ECHO.

      SET STREAM str_1 aux_setlinha WITH FRAME AA WIDTH 243 NO-ERROR.

      IF  ERROR-STATUS:ERROR THEN DO:
          glb_cdcritic = 999.
          glb_dscritic = "Arquivo fora do formato".
          RUN fontes/critic.p.
          /* cria rejeitado */
          CREATE crawrej.
          ASSIGN crawrej.cdcooper = par_cdcooper
                 crawrej.nrdconta = par_nrdconta
                 crawrej.nrdocmto = 0
                 crawrej.dscritic = glb_dscritic.
          RETURN "NOK".
      END.

      CREATE crawaux.
      ASSIGN crawaux.nrsequen = INT(SUBSTR(aux_setlinha,158,06))
             crawaux.nmarquiv = "/usr/coop/" + crapcop.dsdircop + "/" + 
                                aux_nmfisico + ".q".
             aux_flgfirst     = TRUE.

      INPUT STREAM str_1 CLOSE.

   END.  /*  Fim do DO WHILE TRUE  */

   INPUT STREAM str_3 CLOSE.

   IF   NOT aux_flgfirst  THEN
        DO:
           ret_cdcritic = 887. /* Identificacao do arquivo Invalida */
           RETURN "NOK".
        END.
   
   INPUT THROUGH basename `tty` NO-ECHO.
   SET aux_nmendter WITH FRAME f_terminal.
   INPUT CLOSE.

   INPUT THROUGH basename `hostname -s` NO-ECHO.
   IMPORT UNFORMATTED aux_server.
   INPUT CLOSE.

   aux_nmendter = substr(aux_server,length(aux_server) - 1) +
                         aux_nmendter.

   UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").
   ASSIGN aux_nmarqimp = "rl/" + aux_nmendter + STRING(TIME) + ".ex".

   aux_qtbloque = 0.

   FOR EACH crawaux BY crawaux.nrsequen
                    BY crawaux.nmarquiv:

       ASSIGN ret_cdcritic = 0
              aux_flgfirst = FALSE
              aux_vlrtotal = 0.

       INPUT STREAM str_3 FROM VALUE(crawaux.nmarquiv) NO-ECHO.

       /*   Header do Arquivo   */

       SET STREAM str_3 aux_setlinha WITH FRAME AA WIDTH 243.

       /* numero da remessa do cooperado */
       ASSIGN aux_nrremass = INT(SUBSTR(aux_setlinha, 158, 06)).

       IF   SUBSTR(aux_setlinha,08,01) <> "0" THEN
            ret_cdcritic = 468. /* Tipo de registro errado */

       FIND crapcco WHERE
                    crapcco.cdcooper  = par_cdcooper                     AND
                    crapcco.cddbanco  = 1                                AND
                    crapcco.cdagenci  = 1                                AND
                    crapcco.nrdctabb  = INT(SUBSTR(aux_setlinha,59,13))  AND
                    crapcco.nrconven  = INT(SUBSTR(aux_setlinha,33,20))
                    NO-LOCK NO-ERROR.

       IF   NOT AVAILABLE crapcco   THEN
            ret_cdcritic = 563. /* Convenio nao cadastrado */
       ELSE
            ASSIGN aux_cdbancbb = crapcco.cddbanco
                   aux_cdagenci = crapcco.cdagenci
                   aux_cdbccxlt = crapcco.cdbccxlt
                   aux_nrdolote = crapcco.nrdolote
                   aux_cdhistor = crapcco.cdhistor
                   aux_nrdctabb = crapcco.nrdctabb
                   aux_cdbandoc = crapcco.cddbanco
                   aux_nrcnvcob = crapcco.nrconven
                   aux_flgutceb = crapcco.flgutceb
                   aux_flgregis = crapcco.flgregis.

       IF   ret_cdcritic <> 0   THEN
            DO:
                /* apaga arquivo */
                UNIX SILENT VALUE("rm " + SUBSTRING(crawaux.nmarquiv,1,
                                              LENGTH(crawaux.nmarquiv) - 2) +
                                  " 2> /dev/null").

                /* apaga o arquivo QUOTER */
                UNIX SILENT VALUE("rm -f " + crawaux.nmarquiv +
                                  " 2> /dev/null").

                RETURN "NOK".
            END.

       /*   Header do Lote   */            

       SET STREAM str_3 aux_setlinha WITH FRAME AA WIDTH 243.

       IF   SUBSTR(aux_setlinha,08,01) <> "1" THEN
            ret_cdcritic = 468. /* Tipo de registro errado */

       IF   ret_cdcritic <> 0 THEN
            DO:
                /* apaga arquivo */
                UNIX SILENT VALUE("rm " + SUBSTRING(crawaux.nmarquiv,1,
                                              LENGTH(crawaux.nmarquiv) - 2) +
                                  " 2> /dev/null").

                /* apaga o arquivo QUOTER */
                UNIX SILENT VALUE("rm -f " + crawaux.nmarquiv +
                                  " 2> /dev/null").

                NEXT.
            END.

       aux_contador = 0.
    
       /*   Detalhe   */
       DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
          
          SET STREAM str_3 aux_setlinha WITH FRAME AA WIDTH 243.

          IF   INTEGER(SUBSTR(aux_setlinha,08,01)) = 3 AND
               SUBSTR(aux_setlinha,16,02)= "01" THEN
               DO:
                   IF   SUBSTR(aux_setlinha,14,01) = "P" THEN
                        DO:
                          /* cria o boleto apenas se nao tiver erros */
                          IF  aux_flgfirst     AND 
                              ret_cdcritic = 0 AND 
                              glb_cdcritic = 0 THEN
                              RUN p_grava_boleto.
                          ELSE
                               ASSIGN aux_flgfirst = TRUE.
                       
                          ASSIGN glb_cdcritic = 0
                                 ret_cdcritic = 0.
                          
                          /*Se existe a data de emissao*/      
                          IF INT(SUBSTRING(aux_setlinha,112,2)) <> 0 THEN
                              DO:
                                  /*Atribui o valor da data de emissao na variavel*/  
                                  aux_dtemscob = DATE(INT(SUBSTRING(aux_setlinha,112,2)),
                                                      INT(SUBSTRING(aux_setlinha,110,2)),
                                                      INT(SUBSTRING(aux_setlinha,114,4))).
                                  
                                  /*Se a data de documento for superior ao limite 13/10/2049*/
                                  IF aux_dtemscob > DATE("13/10/2049") THEN
                                      DO:
                                          
                                          /* cria rejeitado */
                                          ASSIGN glb_dscritic = "Data de documento superior " + 
                                                                "ao limite 13/10/2049."
                                                 glb_cdcritic = 999.
                                                 
                                          CREATE crawrej.
                                          ASSIGN crawrej.cdcooper =
                                                         par_cdcooper
                                                 crawrej.nrdconta =
                                                         par_nrdconta
                                                 crawrej.nrdocmto =
                                                         aux_nrbloque
                                                 crawrej.dscritic = glb_dscritic.
                                         
                                          NEXT.
                                      END.
                                  
                                  /*Caso a data retroativa seja maior que 90 dias*/    
                                  IF (TODAY - 90) > aux_dtemscob THEN
                                      DO:
                                          /* cria rejeitado */
                                          ASSIGN glb_dscritic = "Data retroativa maior que 90 dias."
                                                 glb_cdcritic = 999.
                                                 
                                          CREATE crawrej.
                                          ASSIGN crawrej.cdcooper =
                                                         par_cdcooper
                                                 crawrej.nrdconta =
                                                         par_nrdconta
                                                 crawrej.nrdocmto =
                                                         aux_nrbloque
                                                 crawrej.dscritic = glb_dscritic.
                                         
                                          NEXT.
                                      END.
                              END.
                          ELSE aux_dtemscob = ?.

                          /*Se existe a data de vencimento*/
                          IF INT(SUBSTRING(aux_setlinha,078,2)) <> 0 THEN
                              DO:
                                  /*Atribui o valor da data de vencimento na variavel*/  
                                  aux_dtvencto = DATE(INT(SUBSTRING(aux_setlinha,080,2)),
                                                      INT(SUBSTRING(aux_setlinha,078,2)),
                                                      INT(SUBSTRING(aux_setlinha,082,4))).
                                  
                                  /*Se existe a data de emissao para pode validar */
                                  IF aux_dtemscob <> ? THEN
                                      DO:
                                          IF  aux_dtvencto < aux_dtemscob  OR
                                              aux_dtvencto < TODAY  THEN
                                              DO:
                                                  ASSIGN glb_dscritic = "Data de vencimento anterior a data de emissao"
                                                         glb_cdcritic = 999.
                                                         
                                                  CREATE crawrej.
                                                  ASSIGN crawrej.cdcooper =
                                                                 par_cdcooper
                                                         crawrej.nrdconta =
                                                                 par_nrdconta
                                                         crawrej.nrdocmto =
                                                                 aux_nrbloque
                                                         crawrej.dscritic = glb_dscritic.
                                                  NEXT.
                                              END.
                                      END.
                              END.
                          ELSE aux_dtvencto = ?. 

                          ASSIGN aux_dsnosnum = TRIM(SUBSTR(aux_setlinha,38,20))
                                 aux_dsnosnum = LEFT-TRIM(aux_dsnosnum,"0")
                                 aux_cdcartei = INT(SUBSTR(aux_setlinha,58,01))
                                 aux_cddespec = INT(SUBSTR(aux_setlinha,107,2))
                                 aux_vltitulo = DEC(SUBSTR(aux_setlinha,86,15))
                                                 / 100
                                 aux_vldescto = DEC(SUBSTR(aux_setlinha,151,15))
                                                 / 100
                                 aux_dsdoccop = TRIM(SUBSTR(aux_setlinha,63,15))
                                 aux_dsusoemp = SUBSTR(aux_setlinha,196,25)
                                 aux_dsdinstr = ""
                                 aux_tpdmulta = 3 /* isento */
                                 aux_vldmulta = 0
                                 aux_tpdjuros = 3 /* isento */
                                 aux_vldjuros = 0
                                 /* inemiten => quem emite e expede 
                                    informacao nao tratada na cob. sem registro */
                                 aux_inemiten = 0
                                 aux_flgdprot = FALSE /* nao protestar */
                                 aux_qtdiaprt = 0 /* zero dias de protesto */. 

                          DO WHILE LENGTH(aux_dsnosnum) < 17:
                             ASSIGN aux_dsnosnum = "0" + aux_dsnosnum.
                          END.

                          IF   NOT aux_flgutceb THEN
                               ASSIGN aux_nrdconta =
                                           INT(SUBSTR(aux_dsnosnum,01,08))
                                      aux_nrbloque =
                                           DEC(SUBSTR(aux_dsnosnum,09,09)).
                          ELSE
                               ASSIGN aux_nrdconta =
                                           INT(SUBSTR(aux_dsnosnum,08,04))
                                      aux_nrbloque =
                                           DEC(SUBSTR(aux_dsnosnum,12,06)).

                        END.  /*  Tipo de  Registro  P   */
                   ELSE
                   IF   SUBSTR(aux_setlinha,14,01) = "Q" THEN
                        DO:
                          ASSIGN glb_cdcritic = 0.

                          IF  aux_nrbloque = 0 THEN
                              DO:
                               /* cria rejeitado */
                               ASSIGN glb_cdcritic = 563.
                                      
                               CREATE crawrej.
                               ASSIGN crawrej.cdcooper =
                                              par_cdcooper
                                      crawrej.nrdconta =
                                              par_nrdconta
                                      crawrej.nrdocmto =
                                              aux_nrbloque
                                      crawrej.dscritic =
                                              "Nosso numero invalido"
                                                + " : " +
                                 STRING(aux_dsnosnum).

                                 NEXT.
                              END.

                          /*  Possui convenio CECRED */
                          IF   aux_flgutceb THEN
                               DO:
                                   FIND crapceb WHERE
                                        crapceb.cdcooper = par_cdcooper AND
                                        crapceb.nrconven = aux_nrcnvcob AND
                                        crapceb.nrcnvceb = aux_nrdconta 
                                        USE-INDEX crapceb3 NO-LOCK NO-ERROR.
                               END.
                          ELSE
                               DO:
                                   FIND crapceb WHERE
                                        crapceb.cdcooper = par_cdcooper AND
                                        crapceb.nrdconta = aux_nrdconta AND
                                        crapceb.nrconven = aux_nrcnvcob
                                        NO-LOCK NO-ERROR.
                               END.
                                                                  
                          IF   NOT AVAILABLE crapceb  OR 
                               crapceb.insitceb <> 1  THEN
                               DO:
                                   IF  NOT AVAIL crapceb   THEN
                                       glb_cdcritic = 563.
                                   ELSE
                                       glb_cdcritic = 933. 

                                   RUN fontes/critic.p.

                                   /* cria rejeitado */
                                   CREATE crawrej.
                                   ASSIGN crawrej.cdcooper =
                                                  par_cdcooper
                                          crawrej.nrdconta =
                                                  par_nrdconta
                                          crawrej.nrdocmto =
                                                  aux_nrbloque
                                          crawrej.dscritic =
                                                  glb_dscritic
                                                    + " -  CNV : " +
                                     STRING(par_nrdconta,"zzzz,zzz,9").

                                   NEXT.
                               END.
                           ELSE
                               ASSIGN aux_nrdconta = crapceb.nrdconta.

                          IF  aux_nrdconta <> par_nrdconta THEN
                               DO:
                                /* cria rejeitado */
                                ASSIGN glb_cdcritic = 563.

                                CREATE crawrej.
                                ASSIGN crawrej.cdcooper =
                                               par_cdcooper
                                       crawrej.nrdconta =
                                               par_nrdconta
                                       crawrej.nrdocmto =
                                               aux_nrbloque
                                       crawrej.dscritic =
                                               "Nosso numero invalido"
                                                 + " : " +
                                  STRING(aux_dsnosnum).

                                  NEXT.
                               END.

                          FIND crapass WHERE
                                       crapass.cdcooper = par_cdcooper AND
                                       crapass.nrdconta = par_nrdconta
                                       USE-INDEX crapass1 NO-LOCK NO-ERROR.

                          IF   NOT AVAILABLE crapass   THEN
                               DO:
                                   ret_cdcritic = 9. /* Associado nao cadastrado */
                                   RUN fontes/critic.p.

                                   /* cria rejeitado */
                                   CREATE crawrej.
                                   ASSIGN crawrej.cdcooper = par_cdcooper
                                          crawrej.nrdconta = par_nrdconta
                                          crawrej.nrdocmto = aux_nrbloque
                                          crawrej.dscritic = glb_dscritic
                                                             + " -  C/C : " +
                                              STRING(par_nrdconta,"zzzz,zzz,9").
                                   NEXT.
                               END.
                          ELSE
                               aux_nmprimtl = crapass.nmprimtl.

                          ASSIGN aux_cdtpinsc = INT(SUBSTR(aux_setlinha,18,01))
                                 aux_nrinssac = DEC(SUBSTR(aux_setlinha,19,15))
                                 aux_nmdsacad = REPLACE(SUBSTR(aux_setlinha,34,40),"&","E")
                                 aux_dsendsac = SUBSTR(aux_setlinha,74,40)
                                 aux_nmbaisac = SUBSTR(aux_setlinha,114,15)
                                 aux_nrcepsac = INT(SUBSTR(aux_setlinha,129,8))
                                 aux_nmcidsac = SUBSTR(aux_setlinha,137,15)
                                 aux_cdufsaca = SUBSTR(aux_setlinha,152,02)
                                 aux_nmdavali = SUBSTR(aux_setlinha,170,40)
                                 aux_nrinsava = DEC(SUBSTR(aux_setlinha,155,15))
                                 aux_cdtpinav = INT(SUBSTR(aux_setlinha,154,1)).

                          RUN p_grava_sacado.

                        END.  /*  Tipo de  Registro  Q   */
                   ELSE
                   IF   SUBSTR(aux_setlinha,14,01) = "S"   AND
                        INT(SUBSTR(aux_setlinha,18,1)) = 3 THEN
                        DO:
                          /*   Concatena instrucoes separadas por _   */
                          ASSIGN aux_dsdinstr = SUBSTR(aux_setlinha,19,40) +
                                                "_" +
                                                SUBSTR(aux_setlinha,59,40) +
                                                "_" +
                                                SUBSTR(aux_setlinha,99,40) +
                                                "_" +
                                                SUBSTR(aux_setlinha,139,40) +
                                                "_" +
                                                SUBSTR(aux_setlinha,179,40).

                        END.  /*  Tipo de  Registro  S   */

               END.  /*   Tipo de Registro 3  */


       END.  /*    Fim do While True   */

       /* cria o ultimo boleto apenas se nao tiver erros */
       IF  aux_flgfirst AND ret_cdcritic = 0 AND glb_cdcritic = 0 THEN
           RUN p_grava_boleto.

       /* apos a importacao, processar temp-table dos titulos */
       RUN p_processa_titulos.

       INPUT STREAM str_3 CLOSE.

       /* move o arquivo UNIX para o "salvar" */
       UNIX SILENT VALUE("mv -f " + SUBSTRING(crawaux.nmarquiv,1,
                                    LENGTH(crawaux.nmarquiv) - 2) + " salvar").

       /* apaga o arquivo QUOTER */
       UNIX SILENT VALUE("rm -f " + crawaux.nmarquiv + " 2> /dev/null").
       
       IF aux_qtbloque > 0 THEN
          DO:        
              RUN pi_protocolo_transacao( INPUT par_cdcooper,
                                          INPUT par_nrdconta,
                                         OUTPUT ret_nrprotoc,
                                         OUTPUT ret_hrtransa,
                                         OUTPUT aux_dscritic).
              IF  RETURN-VALUE <> "OK" THEN
              DO:
                  /*cria rejeitado*/
                  CREATE crawrej.
                  ASSIGN crawrej.cdcooper = par_cdcooper
                         crawrej.nrdconta = par_nrdconta
                         crawrej.nrdocmto = aux_nrbloque
                         crawrej.dscritic = aux_dscritic +
                                 "- Remessa: " + STRING(aux_nrremass).

                  /* apaga arquivo */
                  UNIX SILENT VALUE("rm " + SUBSTRING(crawaux.nmarquiv,1,
                                            LENGTH(crawaux.nmarquiv) - 2) +
                                    " 2> /dev/null").
        
                  /* apaga o arquivo QUOTER */
                  UNIX SILENT VALUE("rm -f " + crawaux.nmarquiv +
                                     " 2> /dev/null").
        
                  NEXT.
              END.

              /* cria lote de remessa do cooperado */
              RUN pi_grava_rtc( INPUT par_cdcooper,
                                INPUT par_nrdconta,
                                INPUT crapcco.nrconven,
                                INPUT aux_nrremass ).  

              IF RETURN-VALUE = "NOK" THEN
              DO:
                  /* apaga arquivo */
                  UNIX SILENT VALUE("rm " + SUBSTRING(crawaux.nmarquiv,1,
                                            LENGTH(crawaux.nmarquiv) - 2) +
                                    " 2> /dev/null").
        
                  /* apaga o arquivo QUOTER */
                  UNIX SILENT VALUE("rm -f " + crawaux.nmarquiv +
                                     " 2> /dev/null").
        
                  NEXT.
              END.
          END.

       IF AVAIL craprtc THEN
       DO:
           ASSIGN craprtc.flgproce = YES
                  craprtc.qtreglot = aux_qtbloque
                  craprtc.qttitcsi = aux_qtbloque
                  craprtc.vltitcsi = aux_vlrtotal
                  craprtc.dsprotoc = ret_nrprotoc.

           IF TEMP-TABLE crawrej:HAS-RECORDS THEN
           DO:
               ret_cdcritic = 999. /* Rotina nao disponivel */
               RUN fontes/critic.p.
    
               /* cria rejeitado */
               CREATE crawrej.
               ASSIGN crawrej.cdcooper = par_cdcooper
                      crawrej.nrdconta = par_nrdconta
                      crawrej.nrdocmto = 999999
                      crawrej.dscritic = "Arquivo processado parcialmente!".
           END.
       END.
       ELSE DO:
           ret_cdcritic = 999. /* Rotina nao disponivel */
           RUN fontes/critic.p.

           /* cria rejeitado */
           CREATE crawrej.
           ASSIGN crawrej.cdcooper = par_cdcooper
                  crawrej.nrdconta = par_nrdconta
                  crawrej.nrdocmto = 999999
                  crawrej.dscritic = "Nenhum boleto foi processado!".
           NEXT.
       END.
   END.  /*   Fim do for each   */
 
  
END PROCEDURE.

/* .......................................................................... */

PROCEDURE p_grava_boleto:
   
   DEF VAR glb_dscritic AS CHAR                                         NO-UNDO.
   DEF VAR glb_cdcritic AS INTE                                         NO-UNDO.
   DEF VAR aux_nrremret AS INTE                                         NO-UNDO.

   FIND FIRST cratcob WHERE 
              cratcob.cdcooper = aux_cdcooper AND
              cratcob.cdbandoc = aux_cdbandoc AND  
              cratcob.nrdctabb = aux_nrdctabb AND
              cratcob.nrcnvcob = aux_nrcnvcob AND
              cratcob.nrdconta = aux_nrdconta AND
              cratcob.nrdocmto = aux_nrbloque
              NO-LOCK NO-ERROR.

   IF AVAIL(cratcob) THEN DO:
       RETURN "NOK".
   END.

   FIND FIRST crapcob WHERE 
              crapcob.cdcooper = aux_cdcooper AND
              crapcob.cdbandoc = aux_cdbandoc AND  
              crapcob.nrdctabb = aux_nrdctabb AND
              crapcob.nrcnvcob = aux_nrcnvcob AND
              crapcob.nrdconta = aux_nrdconta AND
              crapcob.nrdocmto = aux_nrbloque
               NO-LOCK NO-ERROR.

   IF AVAIL(crapcob) THEN DO:
       /* Se o boleto possuir informacao de "LIQAPOSBX" e o cobranca
         nao entrou o boleto deve adicionado para ser processado */
       IF NOT (crapcob.dsinform MATCHES "LIQAPOSBX*" AND 
               crapcob.incobran = 0) THEN DO:
           RETURN "NOK".
       END.
   END.

   DO TRANSACTION:
                                
          CREATE cratcob.
          ASSIGN cratcob.cdcooper = aux_cdcooper
                 cratcob.dtmvtolt = aux_dtmvtolt
                 cratcob.incobran = 0
                 cratcob.nrdconta = aux_nrdconta
                 cratcob.nrdctabb = aux_nrdctabb
                 cratcob.cdbandoc = aux_cdbandoc
                 cratcob.nrdocmto = aux_nrbloque
                 cratcob.nrcnvcob = aux_nrcnvcob
                 cratcob.dtretcob = aux_dtemscob
                 cratcob.dsdoccop = aux_dsdoccop
                 cratcob.vltitulo = aux_vltitulo
                 cratcob.vldescto = aux_vldescto
                 cratcob.dtvencto = aux_dtvencto
                 cratcob.cdcartei = aux_cdcartei
                 cratcob.cddespec = aux_cddespec
                 cratcob.cdtpinsc = aux_cdtpinsc
                 cratcob.nrinssac = aux_nrinssac
                 cratcob.nmdsacad = aux_nmdsacad
                 cratcob.dsendsac = aux_dsendsac
                 cratcob.nmbaisac = aux_nmbaisac
                 cratcob.nmcidsac = aux_nmcidsac
                 cratcob.cdufsaca = aux_cdufsaca
                 cratcob.nrcepsac = aux_nrcepsac
                 cratcob.nmdavali = aux_nmdavali
                 cratcob.nrinsava = aux_nrinsava
                 cratcob.cdtpinav = aux_cdtpinav
                 cratcob.dsdinstr = aux_dsdinstr
                 cratcob.dsusoemp = aux_dsusoemp
                 cratcob.nrremass = aux_nrremass
                 cratcob.flgregis = aux_flgregis
                 cratcob.cdimpcob = 2
                 cratcob.flgimpre = TRUE
                 cratcob.nrnosnum = aux_dsnosnum
                 cratcob.dtdocmto = aux_dtemscob
                 cratcob.tpjurmor = aux_tpdjuros
                 cratcob.vljurdia = aux_vldjuros
                 cratcob.tpdmulta = aux_tpdmulta
                 cratcob.vlrmulta = aux_vldmulta
                 cratcob.inemiten = aux_inemiten
                 cratcob.flgdprot = aux_flgdprot
                 cratcob.flgaceit = aux_flgaceit 
                 cratcob.idseqttl = 1
                 cratcob.cdoperad = "996"
                 cratcob.qtdiaprt = aux_qtdiaprt 
                 cratcob.inemiexp = aux_inemiexp
                 cratcob.flserasa = aux_flserasa
                 cratcob.qtdianeg = aux_qtdianeg
                 cratcob.inserasa = aux_inserasa
                 NO-ERROR.

          IF ERROR-STATUS:ERROR THEN
          DO:
              UNDO, RETURN "NOK".
          END.

   END.
  
  ASSIGN aux_qtbloque = aux_qtbloque + 1 
         aux_vlrtotal = aux_vlrtotal + aux_vltitulo.

  RETURN "OK".
           
END PROCEDURE.
/* .......................................................................... */

PROCEDURE p_grava_sacado:

    DEF VAR h-b1crapsab  AS HANDLE                            NO-UNDO.

    DEF VAR glb_dscritic AS CHAR                              NO-UNDO.
   
    IF  aux_nrinssac = 0 THEN
        RETURN.

    /*  Sacado possui registro */
    FIND crapsab WHERE crapsab.cdcooper = aux_cdcooper AND
                       crapsab.nrdconta = aux_nrdconta AND
                       crapsab.nrinssac = aux_nrinssac EXCLUSIVE-LOCK NO-ERROR.
                          
    IF   NOT AVAILABLE crapsab THEN
        DO:
            EMPTY TEMP-TABLE cratsab.

            CREATE cratsab.
            ASSIGN cratsab.cdcooper = aux_cdcooper
                   cratsab.nrdconta = aux_nrdconta
                   cratsab.nmdsacad = aux_nmdsacad
                   cratsab.cdtpinsc = aux_cdtpinsc
                   cratsab.nrinssac = aux_nrinssac
                   cratsab.dsendsac = aux_dsendsac
                   cratsab.nrendsac = 0
                   cratsab.nmbaisac = aux_nmbaisac
                   cratsab.nmcidsac = aux_nmcidsac
                   cratsab.cdufsaca = aux_cdufsaca
                   cratsab.nrcepsac = aux_nrcepsac
                   cratsab.cdoperad = aux_cdoperad
                   cratsab.dtmvtolt = aux_dtmvtolt.
                                       
            RUN sistema/generico/procedures/b1crapsab.p PERSISTENT 
                SET h-b1crapsab.

            IF   VALID-HANDLE(h-b1crapsab) THEN
                DO:
                    ASSIGN glb_dscritic = "".
                                        
                    RUN cadastra_sacado IN h-b1crapsab (INPUT TABLE cratsab,
                                                       OUTPUT glb_dscritic).
                    DELETE PROCEDURE h-b1crapsab.
                END.

            IF   glb_dscritic <> "" THEN
                DO:
                    /* cria rejeitado */
                    CREATE crawrej.
                    ASSIGN crawrej.cdcooper = aux_cdcooper 
                           crawrej.nrdconta = aux_nrdconta
                           crawrej.nrdocmto = aux_nrbloque
                           crawrej.dscritic = glb_dscritic + " -  C/C : " +
                                              STRING(aux_nrdconta,"zzzz,zzz,9").
                    NEXT.
                END.
        END.
        ELSE DO:

            /* Efetua atualizacao dados do sacado */
            ASSIGN crapsab.nmdsacad = aux_nmdsacad WHEN aux_nmdsacad <> crapsab.dsendsac
                   crapsab.dsendsac = aux_dsendsac WHEN aux_dsendsac <> crapsab.dsendsac
                   crapsab.nrendsac = 0            WHEN aux_dsendsac <> crapsab.dsendsac 
                   crapsab.nmbaisac = aux_nmbaisac WHEN aux_nmbaisac <> crapsab.nmbaisac
                   crapsab.nrcepsac = aux_nrcepsac WHEN aux_nrcepsac <> crapsab.nrcepsac 
                   crapsab.nmcidsac = aux_nmcidsac WHEN aux_nmcidsac <> crapsab.nmcidsac
                   crapsab.cdufsaca = aux_cdufsaca WHEN aux_cdufsaca <> crapsab.cdufsaca
                   
                   crapsab.cdoperad = aux_cdoperad
                   crapsab.dtmvtolt = aux_dtmvtolt.
        END.
   
    ASSIGN aux_nmdsacad = ""
           aux_dsendsac = ""
           aux_nmbaisac = ""
           aux_nmcidsac = ""
           aux_cdufsaca = ""
           aux_nrcepsac = 0.
           
END PROCEDURE.

/* .......................................................................... */

PROCEDURE pi_grava_rtc:

    DEF INPUT PARAM par_cdcooper AS INTE                                NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                                NO-UNDO.
    DEF INPUT PARAM par_nrcnvcob AS INTE                                NO-UNDO.
    DEF INPUT PARAM par_nrremass AS INTE                                NO-UNDO.

    DEF VAR glb_cdcritic AS INTE                                        NO-UNDO.
    DEF VAR aux_nrremret AS INTE                                        NO-UNDO.
    DEF VAR glb_dscritic AS CHAR                                        NO-UNDO.

    FIND LAST craprtc WHERE craprtc.cdcooper = par_cdcooper
                        AND craprtc.nrdconta = par_nrdconta
                        AND craprtc.nrcnvcob = par_nrcnvcob
                        AND craprtc.nrremret = par_nrremass
                        AND craprtc.intipmvt = 1
        NO-LOCK NO-ERROR.

    IF AVAIL craprtc THEN DO:
        /* Lote de remessa ja processado */
        glb_cdcritic = 059.
        RUN fontes/critic.p.

            /*cria rejeitado*/
            CREATE crawrej.
            ASSIGN crawrej.cdcooper = par_cdcooper
                   crawrej.nrdconta = par_nrdconta
                   crawrej.nrdocmto = aux_nrbloque
                   crawrej.dscritic = glb_dscritic + 
                           "- Remessa: " + STRING(par_nrremass).

            RETURN "NOK".
            
    END.
    ELSE 
        IF NOT AVAIL craprtc THEN DO:

            CREATE craprtc.
            ASSIGN craprtc.cdcooper = par_cdcooper
                   craprtc.nrdconta = par_nrdconta
                   craprtc.nrcnvcob = par_nrcnvcob
                   craprtc.dtmvtolt = aux_dtmvtolt
                   craprtc.nrremret = par_nrremass
                   craprtc.nmarquiv = aux_nmarquiv
                   craprtc.flgproce = NO
                   craprtc.cdoperad = aux_cdoperad
                   craprtc.dtaltera = aux_dtmvtolt
                   craprtc.hrtransa = TIME
                   craprtc.dtdenvio = ?
                   craprtc.qtreglot = 1
                   craprtc.intipmvt = 1.
            VALIDATE craprtc.

            RETURN "OK".
        END.

END PROCEDURE.

/* .......................................................................... */

PROCEDURE pi_protocolo_transacao:
  DEF INPUT  PARAM par_cdcooper AS INT                                 NO-UNDO.
  DEF INPUT  PARAM par_nrdconta AS INT                                 NO-UNDO.
  DEF OUTPUT PARAM ret_nrprotoc AS CHAR                                NO-UNDO.
  DEF OUTPUT PARAM ret_hrtransa AS INTE                                NO-UNDO.
  DEF OUTPUT PARAM ret_dscritic AS CHAR                                NO-UNDO.
  
  DEF VAR h-bo_algoritmo_seguranca AS HANDLE.
  DEF VAR aux_dsinfor1 AS CHAR                                         NO-UNDO.
  DEF VAR aux_dsinfor2 AS CHAR                                         NO-UNDO.
  DEF VAR aux_dsinfor3 AS CHAR                                         NO-UNDO.

 /* Gera um protocolo para o pagamento */
 RUN sistema/generico/procedures/bo_algoritmo_seguranca.p
     PERSISTENT SET h-bo_algoritmo_seguranca.

 IF   VALID-HANDLE(h-bo_algoritmo_seguranca)   THEN
      DO:

        FIND crapass WHERE crapass.cdcooper = par_cdcooper 
                       AND crapass.nrdconta = par_nrdconta 
             NO-LOCK NO-ERROR.

         /* Campos gravados na crappro para visualizacao na internet */
         ASSIGN aux_nmarquiv = REPLACE(REPLACE(aux_nmarquiv, 
                                               STRING(par_cdcooper, "999") + "." + 
                                               STRING(par_nrdconta) + ".", ""),
                                          "/usr/coop/" + crapcop.dsdircop + 
                                          "/upload/", "")
                aux_dsinfor1 = "Arquivo Remessa Cobranca"
                aux_dsinfor2 = crapass.nmprimtl +  
                               "#Convenio: " + STRING(crapcco.cddbanco, "999")
                               + "/" + STRING(crapcco.nrconven)
                aux_dsinfor3 = "Total de Boletos: " + STRING(aux_qtbloque,"zzzzz9") +
                               "#Arquivo: " + aux_nmarquiv.

         ASSIGN ret_hrtransa = TIME.

         RUN gera_protocolo IN h-bo_algoritmo_seguranca
            (INPUT par_cdcooper,
             INPUT aux_dtmvtolt,
             INPUT ret_hrtransa,
             INPUT par_nrdconta,
             INPUT aux_nrremass,
             INPUT 0,
             INPUT aux_vlrtotal,
             INPUT 0,
             INPUT YES,
             INPUT 7, 
             INPUT aux_dsinfor1,
             INPUT aux_dsinfor2,
             INPUT aux_dsinfor3,
             INPUT "",
             INPUT false,
             INPUT 0,
             INPUT 0,
             INPUT "",
             OUTPUT ret_nrprotoc,
             OUTPUT ret_dscritic).

         DELETE PROCEDURE h-bo_algoritmo_seguranca.

         IF  RETURN-VALUE <> "OK"  THEN
             RETURN "NOK".
      END.
    
 RETURN "OK".

END PROCEDURE.

/* .......................................................................... */

PROCEDURE p_integra_arq_remessa_cnab240_085:
   
   DEF INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
   DEF INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
   DEF INPUT PARAM par_nmarquiv AS CHAR                              NO-UNDO.
   DEF INPUT PARAM par_idorigem AS INTE                              NO-UNDO.
   DEF INPUT PARAM par_dtmvtolt AS DATE                              NO-UNDO.
   DEF INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.
   DEF INPUT PARAM par_nmdatela AS CHAR                              NO-UNDO.
                                       
   DEF OUTPUT PARAM ret_qtreqimp AS INTE                             NO-UNDO.
   DEF OUTPUT PARAM ret_nrremret AS INTE                             NO-UNDO.
   DEF OUTPUT PARAM ret_nrprotoc AS CHAR                             NO-UNDO.
   DEF OUTPUT PARAM ret_cdcritic AS INTE                             NO-UNDO.
   DEF OUTPUT PARAM ret_hrtransa AS INTE                             NO-UNDO.
   DEF OUTPUT PARAM TABLE FOR crawrej.

   DEF VAR aux_setlinha AS CHAR    FORMAT "x(243)"                   NO-UNDO.
   DEF VAR aux_flgfirst AS LOGICAL                                   NO-UNDO.
   DEF VAR aux_nmendter AS CHAR                                      NO-UNDO.
   DEF VAR aux_nmfisico AS CHAR                                      NO-UNDO.
   DEF VAR aux_cdagenci AS INT                                       NO-UNDO.
   DEF VAR aux_contador AS INT                                       NO-UNDO.
   DEF VAR aux_flgutceb AS LOGICAL                                   NO-UNDO.
  
   DEF VAR tel_nmarqint AS CHAR FORMAT "x(60)"                       NO-UNDO.
   DEF VAR aux_dscritic AS CHAR                                      NO-UNDO.
   DEF VAR aux_qtboleto AS INTE                                      NO-UNDO.
   DEF VAR aux_vltarifa AS DECI                                      NO-UNDO.
   DEF VAR aux_cdtarhis AS INTE                                      NO-UNDO.

   DEF VAR tar_cdhistor AS INTE                                      NO-UNDO.
   DEF VAR tar_cdhisest AS INTE                                      NO-UNDO.
   DEF VAR tar_vltarifa AS DECI                                      NO-UNDO.
   DEF VAR tar_dtdivulg AS DATE                                      NO-UNDO.
   DEF VAR tar_dtvigenc AS DATE                                      NO-UNDO.
   DEF VAR tar_cdfvlcop AS INTE                                      NO-UNDO.
   DEF VAR aux_cdfvlcop AS INTE                                      NO-UNDO.

   DEF VAR aux_flgerro  AS LOGICAL                                   NO-UNDO.

   DEF VAR rej_cdocorre AS INTE                                      NO-UNDO.
   DEF VAR rej_cdmotivo AS CHAR                                      NO-UNDO. 

   DEF VAR aux_tpdescto AS INTE                                      NO-UNDO.   
   DEF VAR aux_cdprotes AS INTE                                      NO-UNDO.  
   DEF VAR aux_dtdescto AS DATE                                      NO-UNDO.

   DEF VAR aux_dtgerarq AS DATE                                      NO-UNDO.

   DEF VAR aux_qtdregis AS INTE                                      NO-UNDO.
   DEF VAR aux_qtdinstr AS INTE                                      NO-UNDO.

   DEF VAR aux_diasvcto AS INTE                                      NO-UNDO.   

   DEF VAR aux_qtminimo AS INTE                                      NO-UNDO.   
   DEF VAR aux_qtmaximo AS INTE                                      NO-UNDO.
   DEF VAR aux_vlminimo AS DEC                                       NO-UNDO.  

   DEF VAR aux_serasa   AS LOGICAL                                   NO-UNDO.
   
   DEF BUFFER bcraprtc FOR craprtc.


   ASSIGN aux_nrdconta = par_nrdconta
          aux_cdcooper = par_cdcooper
          aux_dtmvtolt = par_dtmvtolt
          aux_cdoperad = par_cdoperad
          aux_nmdatela = par_nmdatela
          aux_nmarquiv = par_nmarquiv.

   FORM aux_setlinha  FORMAT "x(243)"
        WITH FRAME AA WIDTH 243 NO-BOX NO-LABELS.

   /*  Acessa dados da Cooperativa  */
   FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE crapcop   THEN
        DO:
            ret_cdcritic = 651. /* Falta registro de controle da cooperativa */
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic VIEW-AS ALERT-BOX.
            
            RETURN.
        END.

   FIND craptab 
   WHERE craptab.cdcooper = 3                   /* Parametro Apenas Cadastrado na Cecred */
     AND craptab.nmsistem = "CRED"             
     AND craptab.tptabela = "GENERI"           
     AND craptab.cdempres = 0                  
     AND craptab.cdacesso = "DIASVCTOCEE"      
     AND craptab.tpregist = 0
     NO-LOCK NO-ERROR.
            
    IF  NOT AVAILABLE craptab   THEN
        DO:
            MESSAGE "Tabela com parametro vencimento nao encontrado." VIEW-AS ALERT-BOX.
            
            RETURN.
        END.

   ASSIGN aux_diasvcto = INT(SUBSTR(craptab.dstextab,1,2)).

   EMPTY TEMP-TABLE crawaux.
   EMPTY TEMP-TABLE crawrej.
   EMPTY TEMP-TABLE tt-verifica-sacado.
   EMPTY TEMP-TABLE tt-instr.

   ASSIGN  aux_flgfirst = FALSE
           ret_cdcritic = 0.

   INPUT STREAM str_3 THROUGH VALUE( "ls " + par_nmarquiv + " 2> /dev/null")
                NO-ECHO.

   ASSIGN aux_contador = 0.
   
   DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

      ASSIGN aux_contador = aux_contador + 1
             aux_nmfisico = "integra/cobran" + STRING(par_dtmvtolt,"999999") +
                            "_" + STRING(aux_contador,"9999") + "_"
                            + STRING(par_nrdconta,"99999999").

      SET STREAM str_3 aux_nmarquiv FORMAT "x(90)" WITH WIDTH 100 NO-ERROR.

      IF  ERROR-STATUS:ERROR THEN 
          DO:
              glb_cdcritic = 999.
              glb_dscritic = "Nome do Arquivo muito grande".
              
              RUN fontes/critic.p.
              
              /* Cria Rejeitado */
              CREATE crawrej.
              ASSIGN crawrej.cdcooper = par_cdcooper
                     crawrej.nrdconta = par_nrdconta
                     crawrej.nrdocmto = 0
                     crawrej.dscritic = glb_dscritic.
              
              RETURN "NOK".
          END.

      UNIX SILENT VALUE("dos2ux " + aux_nmarquiv + " > " + 
                        "/usr/coop/" + crapcop.dsdircop + "/" + aux_nmfisico +
                        " 2> /dev/null").

      UNIX SILENT VALUE("quoter " + "/usr/coop/" + crapcop.dsdircop + "/" + 
                        aux_nmfisico + " > " + 
                        "/usr/coop/" + crapcop.dsdircop + "/" + aux_nmfisico +
                        ".q" + " 2> /dev/null").

      INPUT STREAM str_1 FROM VALUE("/usr/coop/" + crapcop.dsdircop + "/" +
                                    aux_nmfisico + ".q") NO-ECHO.

      SET STREAM str_1 aux_setlinha WITH FRAME AA WIDTH 243 NO-ERROR.

      IF  ERROR-STATUS:ERROR THEN 
          DO:
              glb_cdcritic = 999.
              glb_dscritic = "Arquivo fora do formato".
              
              RUN fontes/critic.p.
              
              /* Cria Rejeitado */
              CREATE crawrej.
              ASSIGN crawrej.cdcooper = par_cdcooper
                     crawrej.nrdconta = par_nrdconta
                     crawrej.nrdocmto = 0
                     crawrej.dscritic = glb_dscritic.
              
              RETURN "NOK".
          END.

      CREATE crawaux.
      ASSIGN crawaux.nrsequen = INT(SUBSTR(aux_setlinha,158,06))
             crawaux.nmarquiv = "/usr/coop/" + crapcop.dsdircop + "/" + 
                                aux_nmfisico + ".q".
             aux_flgfirst     = TRUE.

      INPUT STREAM str_1 CLOSE.

   END.  /*  Fim do DO WHILE TRUE  */

   INPUT STREAM str_3 CLOSE.

   IF   NOT aux_flgfirst  THEN
        DO:
           ret_cdcritic = 887. /* Identificacao do arquivo Invalida */
           
           RETURN "NOK".
        END.
   
   aux_qtbloque = 0.

   ASSIGN aux_qtdregis = 0
          aux_qtdinstr = 0.

   FOR EACH crawaux BY crawaux.nrsequen
                    BY crawaux.nmarquiv:

       ASSIGN ret_cdcritic = 0
              aux_flgfirst = FALSE
              aux_vlrtotal = 0.

       INPUT STREAM str_3 FROM VALUE(crawaux.nmarquiv) NO-ECHO.

       /*  -------------  Header do Arquivo -------------   */

       SET STREAM str_3 aux_setlinha WITH FRAME AA WIDTH 243.

       /* Numero da Remessa do Cooperado */
       ASSIGN aux_nrremass = INT(SUBSTR(aux_setlinha, 158, 06)).

       /* Verifica se convenio esta Homologacao */
       FIND FIRST crapceb WHERE crapceb.cdcooper = par_cdcooper AND
                                crapceb.nrconven = INT(SUBSTR(aux_setlinha,33,20)) AND
                                crapceb.nrdconta = par_nrdconta AND
                                crapceb.insitceb = 1
                                NO-LOCK NO-ERROR.

            IF AVAIL(crapceb) THEN DO:

                IF crapceb.flgcebhm = FALSE THEN
                    ASSIGN aux_dscritic = "Convenio Nao Homologado - Entre em contato com seu Posto de Atendimento.".
            END.
                
       /* 01.0 Codigo do banco na compensacao */
       IF SUBSTR(aux_setlinha,01,03) <> "085" THEN DO:
           IF aux_dscritic = "" THEN
                ASSIGN aux_dscritic = "Codigo do banco na compensacao invalido".
       END.

       /* 02.0 Lote de Servico */
       IF SUBSTR(aux_setlinha,04,04) <> "0000" THEN DO:
           IF aux_dscritic = "" THEN
                ASSIGN aux_dscritic = "Lote de Servico Invalido.".
       END.

       /* 03.0 Tipo de Registro */
       IF SUBSTR(aux_setlinha,08,01) <> "0" THEN DO:
           IF aux_dscritic = "" THEN
                ASSIGN aux_dscritic = "Tipo de Registro Invalido.".
       END.


       /* 05.0 Tipo de Inscricao do Cooperado */
       IF aux_dscritic = "" THEN DO:
           IF SUBSTR(aux_setlinha,18,01) <> "1" AND         /* Pessoa Fisica   */
              SUBSTR(aux_setlinha,18,01) <> "2" THEN DO:    /* Pessoa Juridica */
                  ASSIGN aux_dscritic = "Tipo de Inscricao Invalida.".
           END. 
       END.

       /* 10.0 a 11.0 Conta/DV */
       IF aux_dscritic = "" THEN DO:
           IF INT(SUBSTR(aux_setlinha,59,13)) <> par_nrdconta THEN DO:
                  ASSIGN aux_dscritic = "Conta/DV Header Arquivo Invalida.".
           END. 
       END.

       /* 06.0 Numero de Inscricao do Cooperado */
       IF aux_dscritic = "" THEN DO:
           FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper AND
                                    crapass.nrdconta = par_nrdconta 
                                    NO-LOCK NO-ERROR .
    
           IF NOT AVAIL(crapass) THEN DO:
                ASSIGN aux_dscritic = "Conta/DV Informado Header Arquivo nao pertence a um cooperado cadastrado.".
           END.
           ELSE DO:

               IF crapass.nrcpfcgc <> DEC(SUBSTR(aux_setlinha,19,14)) THEN DO:
                    ASSIGN aux_dscritic = "CPF/CNPJ Informado Header Arquivo Invalido.".
               END.
               ELSE DO:
                   IF crapass.inpessoa <> INTE(SUBSTR(aux_setlinha,18,01)) THEN
                        ASSIGN aux_dscritic = "CPF/CNPJ Informado Header Arquivo incompativel com Tipo de Inscricao.".
               END.
           END.
       END.


       /* 07.0 Codigo do Convenio */
       IF aux_dscritic = "" THEN DO:
           FIND FIRST crapcco WHERE crapcco.cdcooper = par_cdcooper AND
                                    crapcco.cddbanco = 085         AND
                                    crapcco.dsorgarq = "IMPRESSO PELO SOFTWARE"         AND
                                    crapcco.nrconven = INT(SUBSTR(aux_setlinha,33,20))
                                    NO-LOCK NO-ERROR.
    
           IF NOT AVAIL(crapcco) THEN DO:
               ASSIGN aux_dscritic = "Convenio nao Encontrado.".
           END.
           ELSE 
           DO:
                ASSIGN aux_cdbancbb = crapcco.cddbanco
                       aux_cdagenci = crapcco.cdagenci
                       aux_cdbccxlt = crapcco.cdbccxlt
                       aux_nrdolote = crapcco.nrdolote
                       aux_cdhistor = crapcco.cdhistor
                       aux_nrdctabb = crapcco.nrdctabb
                       aux_cdbandoc = crapcco.cddbanco
                       aux_nrcnvcob = crapcco.nrconven
                       aux_flgutceb = crapcco.flgutceb
                       aux_flgregis = crapcco.flgregis.
    
                FIND FIRST crapceb WHERE crapceb.cdcooper = crapcco.cdcooper AND
                                         crapceb.nrconven = crapcco.nrconven AND
                                         crapceb.nrdconta = crapass.nrdconta AND
                                         crapceb.insitceb = 1
                                         NO-LOCK NO-ERROR.
    
                IF NOT AVAIL(crapceb) THEN DO:
                    IF aux_dscritic = "" THEN
                        ASSIGN aux_dscritic = "Convenio Inativo ou Nao Cadastrado.".
                END.
                ELSE
                DO:
                    IF crapceb.flgcebhm = FALSE THEN DO:
                        IF aux_dscritic = "" THEN
                            ASSIGN aux_dscritic = "Convenio Nao Homologado.".
                    END.
                END.
                                
    
           END.
       END.
/*
       /* 08.0 a 12.0 Dados da Conta Corrente do Cooperado */
       IF aux_dscritic = "" THEN DO:
           IF INT(SUBSTR(aux_setlinha,59,13)) <> crapass.nrdconta THEN
               ASSIGN aux_dscritic = "Conta/DV Invalida.". 
       END.
*/

       /* 16.0 Codigo Remessa/Retorno */
       IF aux_dscritic = "" THEN DO:
           IF SUBSTR(aux_setlinha,143,01) <> "1" THEN
                ASSIGN aux_dscritic = "Codigo de Remessa nao encontrado no segmento header do arquivo.".
       END.

       /* 17.0 Data de geracao de arquivo */
       IF aux_dscritic = "" THEN DO:
            aux_dtgerarq = DATE(INT(SUBSTRING(aux_setlinha,146,2)),
                                INT(SUBSTRING(aux_setlinha,144,2)),
                                INT(SUBSTRING(aux_setlinha,148,4))).
    
            IF ( aux_dtgerarq > TODAY ) OR
               ( aux_dtgerarq < ( TODAY - 30 ))   THEN DO:
                   ASSIGN aux_dscritic = "Data de geracao do arquivo fora do periodo permitido.". 
            END.
       END.

       /* 19.0 Sequencia da geracao NSA */
       IF aux_dscritic = "" THEN DO:
           IF INT(SUBSTRING(aux_setlinha,158,6)) = 0 THEN
               ASSIGN aux_dscritic = "Numero da Remessa Invalida.".

           FIND LAST bcraprtc WHERE bcraprtc.cdcooper = crapass.cdcooper AND
                                    bcraprtc.nrdconta = crapass.nrdconta AND 
                                    bcraprtc.nrcnvcob = crapcco.nrconven AND
                                    bcraprtc.intipmvt = 1 /* Remessa */
                                    NO-LOCK NO-ERROR.             
            
           IF  AVAIL(bcraprtc) THEN DO:
               /* Verificacao do numero de remessa que esta sendo processado eh igual ao ultimo processado */
               IF ( bcraprtc.nrremret = INT(SUBSTRING(aux_setlinha,158,6)) ) THEN
                   ASSIGN aux_dscritic = "Arquivo ja processado".
               ELSE
               DO:
                   IF ( bcraprtc.nrremret > INT(SUBSTRING(aux_setlinha,158,6))) THEN DO:
                       /* Verificar se o ultimo arquivo processado possui ateh 6 caracteres que eh o maximo para CNAB240 */
                       IF LENGTH(STRING(bcraprtc.nrremret)) <= 6  THEN
                           ASSIGN aux_dscritic = "Numero de remessa (HEADER) inferior ao ultimo arquivo processado.".
                       ELSE
                       DO:
                           /* Se o ultimo possuir mais de 6 caracteres, pesquisa pelo numero de remessa
                              que esta sendo processado */
                           FIND LAST bcraprtc WHERE bcraprtc.cdcooper = crapass.cdcooper AND
                                                    bcraprtc.nrdconta = crapass.nrdconta AND 
                                                    bcraprtc.nrcnvcob = crapcco.nrconven AND
                                                    bcraprtc.intipmvt = 1 /* Remessa */  AND
                                                    bcraprtc.nrremret = INT(SUBSTRING(aux_setlinha,158,6))
                                                    NO-LOCK NO-ERROR.
                           
                           IF  AVAIL(bcraprtc) THEN
                               ASSIGN aux_dscritic = "Arquivo ja processado".
                       END.
                   END.
               END.
           END.
       END.

       IF aux_dscritic <> "" THEN DO:

           /* Cria Rejeitado */
           CREATE crawrej.
           ASSIGN crawrej.cdcooper = par_cdcooper
                  crawrej.nrdconta = par_nrdconta
                  crawrej.nrdocmto = 0
                  crawrej.dscritic = aux_dscritic.

       END.

       IF   ret_cdcritic <> 0 OR aux_dscritic <> ""  THEN
            DO:
                /* Apaga Arquivo */
                UNIX SILENT VALUE("rm " + SUBSTRING(crawaux.nmarquiv,1,
                                              LENGTH(crawaux.nmarquiv) - 2) +
                                  " 2> /dev/null").

                /* Apaga o Arquivo QUOTER */
                UNIX SILENT VALUE("rm -f " + crawaux.nmarquiv +
                                  " 2> /dev/null").
                
                RETURN "NOK".
            END.

       /*   ------------- Header do Lote -------------   */            

       SET STREAM str_3 aux_setlinha WITH FRAME AA WIDTH 243.

       ASSIGN aux_dscritic = "".
    
       /* 01.1 Codigo do banco na compensacao */
       IF SUBSTR(aux_setlinha,01,03) <> "085" THEN DO:
            ASSIGN aux_dscritic = "Codigo do banco na compensacao invalido".
       END.

       /* 02.1 Lote de Servico */
       IF aux_dscritic = "" THEN DO:
           IF SUBSTR(aux_setlinha,04,04) <> "0001" THEN
                ASSIGN aux_dscritic = "Lote de Servico Invalido.".
       END.

       /* 03.1 Tipo de Registro */
       IF aux_dscritic = "" THEN DO:
           IF SUBSTR(aux_setlinha,08,01) <> "1" THEN
               ASSIGN aux_dscritic = "Tipo de Registro Invalido.".
       END.

       /* 04.1 Operacao */
       IF aux_dscritic = "" THEN DO:
           IF SUBSTR(aux_setlinha,09,01) <> "R" THEN
                ASSIGN aux_dscritic = "Tipo de Operacao Invalido.".
       END.

       /* 05.1 Tipo de Servico */
       IF aux_dscritic = "" THEN DO:
            IF SUBSTR(aux_setlinha,10,02) <> "01" THEN
                ASSIGN aux_dscritic = "Tipo de Servico Invalida.".
       END. 

       /* 09.1 Tipo de Inscricao do Cooperado */
       IF aux_dscritic = "" THEN DO:
           IF SUBSTR(aux_setlinha,18,01) <> "1" AND         /* Pessoa Fisica   */
              SUBSTR(aux_setlinha,18,01) <> "2" THEN DO:    /* Pessoa Juridica */
                  ASSIGN aux_dscritic = "Tipo de Inscricao Invalida.".
           END. 
       END.

       /* 14.1 a 15.1 Conta/DV */
       IF aux_dscritic = "" THEN DO:
           IF INT(SUBSTR(aux_setlinha,60,13)) <> par_nrdconta THEN DO:
                  ASSIGN aux_dscritic = "Conta/DV HEADER Lote Invalida.".
           END. 
       END.

       /* 10.1 Numero de Inscricao do Cooperado */
       IF aux_dscritic = "" THEN DO:
           FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper AND
                                    crapass.nrdconta = par_nrdconta 
                                    NO-LOCK NO-ERROR .
    
           IF NOT AVAIL(crapass) THEN DO:
                ASSIGN aux_dscritic = "Conta/DV Informado HEADER Lote nao pertence a um cooperado cadastrado.".
           END.
           ELSE DO:

               IF crapass.nrcpfcgc <> DEC(SUBSTR(aux_setlinha,19,15)) THEN DO:
                    ASSIGN aux_dscritic = "CPF/CNPJ Informado HEADER Lote Invalido.".
               END.
               ELSE DO:
                   IF crapass.inpessoa <> INTE(SUBSTR(aux_setlinha,18,01)) THEN
                        ASSIGN aux_dscritic = "CPF/CNPJ Informado HEADER Lote incompativel com Tipo de Inscricao.".
               END.
           END.
       END.
/*
       /* 10.1 Numero de Inscricao do Cooperado */
       IF aux_dscritic = "" THEN DO:
           FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper AND
                                    crapass.nrcpfcgc = DEC(SUBSTR(aux_setlinha,19,15))
                                    NO-LOCK NO-ERROR .
    
           IF NOT AVAIL(crapass) THEN DO:
                ASSIGN aux_dscritic = "CPF/CNPJ Informado nao pertence a um cooperado cadastrado.".
           END.
           ELSE DO:

               IF crapass.inpessoa <> INTE(SUBSTR(aux_setlinha,18,01)) THEN
                    ASSIGN aux_dscritic = "CPF/CNPJ Informado incompativel com Tipo de Inscricao cadastrada.".
           END.
       END.

       /* 12.1 a 16.1 Dados da Conta Corrente do Cooperado */
       IF aux_dscritic = "" THEN DO:
           IF INT(SUBSTR(aux_setlinha,60,13)) <> crapass.nrdconta THEN
               ASSIGN aux_dscritic = "Conta/DV Informada incorreta.". 
       END.
*/
       /* 20.1 Sequencia da geracao NSA */
       IF aux_dscritic = "" THEN DO:
           FIND LAST bcraprtc WHERE bcraprtc.cdcooper = crapass.cdcooper AND
                                    bcraprtc.nrdconta = crapass.nrdconta AND 
                                    bcraprtc.nrcnvcob = INT(SUBSTR(aux_setlinha,34,20)) AND
                                    bcraprtc.intipmvt = 1 /* Remessa */
                                    NO-LOCK NO-ERROR. 

            IF AVAIL(bcraprtc) THEN DO:
                IF ( bcraprtc.nrremret = INT(SUBSTRING(aux_setlinha,184,8)) ) THEN
                    ASSIGN aux_dscritic = "Arquivo ja processado".
                ELSE
                DO:
                    IF ( bcraprtc.nrremret > INT(SUBSTRING(aux_setlinha,184,8)) ) THEN DO:
                        /* Verificar se o ultimo arquivo processado possui ateh 6 caracteres que eh o maximo para CNAB240 */
                        IF LENGTH(STRING(bcraprtc.nrremret)) <= 6  THEN
                            ASSIGN aux_dscritic = "Numero de remessa inferior (LOTE) ao ultimo arquivo processado.".
                        ELSE
                        DO:
                            /* Se o ultimo possuir mais de 6 caracteres, pesquisa pelo numero de remessa
                               que esta sendo processado */
                            FIND LAST bcraprtc WHERE bcraprtc.cdcooper = crapass.cdcooper AND
                                                     bcraprtc.nrdconta = crapass.nrdconta AND 
                                                     bcraprtc.nrcnvcob = crapcco.nrconven AND
                                                     bcraprtc.intipmvt = 1 /* Remessa */  AND
                                                     bcraprtc.nrremret = INT(SUBSTRING(aux_setlinha,184,8))
                                                     NO-LOCK NO-ERROR.

                            IF  AVAIL(bcraprtc) THEN
                                ASSIGN aux_dscritic = "Arquivo ja processado".
                        END.
                    END.
                END.
            END.
       END.

       /* 21.1 Data de geracao de arquivo */
       IF aux_dscritic = "" THEN DO:
            aux_dtgerarq = DATE(INT(SUBSTRING(aux_setlinha,194,2)),
                                INT(SUBSTRING(aux_setlinha,192,2)),
                                INT(SUBSTRING(aux_setlinha,196,4))).
    
            IF ( aux_dtgerarq > TODAY ) OR
               ( aux_dtgerarq < ( TODAY - 30 ))   THEN DO:
                   ASSIGN aux_dscritic = "Data de gravacao do arquivo fora do periodo permitido.". 
            END.
       END.

       /* Em caso de critica gera Rejeitado */
       IF aux_dscritic <> "" THEN DO:

           /* Cria Rejeitado */
           CREATE crawrej.
           ASSIGN crawrej.cdcooper = par_cdcooper
                  crawrej.nrdconta = par_nrdconta
                  crawrej.nrdocmto = 0
                  crawrej.dscritic = aux_dscritic.

       END.


       IF   ret_cdcritic <> 0 OR aux_dscritic <> "" THEN
            DO:
                /* Apaga Arquivo */
                UNIX SILENT VALUE("rm " + SUBSTRING(crawaux.nmarquiv,1,
                                              LENGTH(crawaux.nmarquiv) - 2) +
                                  " 2> /dev/null").

                /* Apaga o arquivo QUOTER */
                UNIX SILENT VALUE("rm -f " + crawaux.nmarquiv +
                                  " 2> /dev/null").

                NEXT.
            END.

       aux_contador = 0.
       /*  -------------  Detalhe -------------   */
       DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

          SET STREAM str_3 aux_setlinha WITH FRAME AA WIDTH 243.

          IF  INTEGER(SUBSTR(aux_setlinha,08,01)) = 3 THEN
              DO:
                IF  SUBSTR(aux_setlinha,14,01) = "P" THEN
                    DO: 
                       IF SUBSTR(aux_setlinha,16,2) = "01" THEN
                            aux_qtdregis = aux_qtdregis + 1. 
                       ELSE
                            aux_qtdinstr = aux_qtdinstr + 1.

                       /* Cria o ultimo boleto ou gera instrucao apenas se nao tiver erros */
                       IF  aux_flgfirst     AND 
                           ret_cdcritic = 0 AND 
                           glb_cdcritic = 0 AND
                           rej_cdmotivo = "" THEN
                           DO:  
                                CASE aux_cdocorre:

                                    WHEN 01 THEN /* 01 - Solicitacao de Remessa */
                                        RUN p_grava_boleto.

                                    OTHERWISE
                                        RUN p_grava_instrucao.

                                END CASE.
                           END.

                      ASSIGN aux_vldescto = 0 /* Valor desconto */
                             aux_vlabatim = 0 /* Valor do abatimento */
                             aux_flgfirst = TRUE
                             glb_cdcritic = 0
                             ret_cdcritic = 0
                             aux_tpdmulta = 3 /* Isento */
                             aux_vldmulta = 0
                             rej_cdmotivo = ""
                             aux_dsnosnum = TRIM(SUBSTR(aux_setlinha,38,20))
                             aux_dsnosnum = LEFT-TRIM(aux_dsnosnum,"0")
                             aux_cdcartei = 01
                             aux_dsdoccop = TRIM(SUBSTR(aux_setlinha,63,15))
                             aux_dsusoemp = SUBSTR(aux_setlinha,196,25)
                             aux_dsdinstr = ""
                             aux_inemiten = 2  /* Cooperado Emite e Expede */
                             aux_flgdprot = (IF NOT CAN-DO("2,3",SUBSTR(aux_setlinha,221,01)) THEN 
                                                TRUE 
                                             ELSE
                                                FALSE)
                             /* tratar flag aceite enviada no arquivo
                                motivo 23 - Aceite invalido, nao sera tratado
                                para nao impactar nos cooperados que ignoravam essa informacao*/                   
                             aux_flgaceit = (IF SUBSTR(aux_setlinha,109,01)  = "A" THEN 
                                                TRUE 
                                             ELSE
                                                FALSE)
                          
                             aux_inemiexp = 0.

                      ASSIGN aux_flserasa = FALSE
                             aux_qtdianeg = 0
                             aux_inserasa = 0.

                      ASSIGN aux_serasa = FALSE.

                      /* 07.3P Valida Codigo do Movimento */
                      IF rej_cdmotivo = "" THEN DO:

                          aux_cdocorre = INTE(SUBSTR(aux_setlinha,16,2)) NO-ERROR.
    
                          IF ERROR-STATUS:ERROR THEN
                                ASSIGN rej_cdmotivo = "05".   /* Codigo de Movimento Invalido */
                          ELSE DO:
                              IF NOT CAN-DO("1,2,4,5,6,7,8,9,10,11,31,41,90,93,94",STRING(aux_cdocorre)) THEN
                                  ASSIGN rej_cdmotivo = "05".   /* Codigo de Movimento Invalido */ 
                          END.
                      END.

                      /* Validacao de Comandos de Intrucao */
                      IF rej_cdmotivo = "" THEN DO:
                          IF aux_cdocorre <> 1 THEN DO: /* 01 - Remessa */
        
                              IF aux_cdocorre <> 31 THEN
                                  RUN valida-execucao-instrucao (  INPUT par_cdcooper,
                                                                   INPUT aux_nrdconta,
                                                                   INPUT aux_setlinha,
                                                                   INPUT aux_cdocorre,
                                                                   INPUT "240",
                                                                  OUTPUT rej_cdmotivo).
    
                              IF rej_cdmotivo <> ""  THEN DO:

                                    /* Incluir Geracao Retorno Rejeitado */
                                    RUN prep-retorno-cooperado-rejeitado 
                                                            (INPUT par_cdcooper,
                                                             INPUT par_nrdconta,
                                                             INPUT aux_nrcnvcob,
                                                             INPUT 26,              /* Instrucao */
                                                             INPUT rej_cdmotivo,
                                                             INPUT aux_dsnosnum,
                                                             INPUT aux_vltitulo,
                                                             INPUT crapcop.cdbcoctl,
                                                             INPUT crapcop.cdagectl,
                                                             INPUT par_dtmvtolt,
                                                             INPUT par_cdoperad,
                                                             INPUT aux_dsdoccop,
                                                             INPUT aux_nrremass,
                                                             INPUT aux_dtvencto,
                                                             INPUT aux_dtemscob).
        
                              END.
    
                              NEXT.
    
                          END.
                      END.

                      /* 17.3P Valida Tipo de Emissao do Boleto */
                      IF ( aux_cdocorre = 01 OR aux_cdocorre = 90 ) THEN /* 01 - Remessa  */
                      DO: 

                          aux_inemiten = INT(SUBSTRING(aux_setlinha,061,1)) NO-ERROR.

                          IF ERROR-STATUS:ERROR THEN
                          DO:
                              ASSIGN aux_inemiten = 0
                                     rej_cdmotivo = "13".   /* Identificação da Emissao do Bloqueto invalida */
                          END.
        
                          IF ( aux_inemiten <> 1 ) AND   /* Banco Emite */
                             ( aux_inemiten <> 2 ) THEN  /* Cliente Emite */
                          DO:
                                IF rej_cdmotivo = "" THEN
                                    ASSIGN rej_cdmotivo = "13".   /* Identificação da Emissao do Bloqueto invalida */

                          END.
                          ELSE 
                          DO:   
                               IF aux_inemiten = 1 THEN
                                   ASSIGN aux_inemiten = 3     /* Cooperativa Emite e Expede */
                                          aux_inemiexp = 1.    /* Indicador de emissão, 1 – cooperativa emite e expede – a enviar */
                               ELSE
                                   ASSIGN aux_inemiten = 2     /* Cooperado Emite e Expede */
                                          aux_inemiexp = 0.           
                          END.

                          IF  AVAIL(crapceb) AND 
                              aux_inemiten = 3 AND 
                              crapceb.flceeexp = FALSE THEN
                              ASSIGN rej_cdmotivo = "13".   /* Identificação da Emissao do Bloqueto invalida */

                      END.
                      
                      /* 20.3P Valida Data de Vencimento */
                      IF ( aux_cdocorre = 01 OR aux_cdocorre = 06 ) THEN /* 01 - Remessa   06 - Alteracao Vencimento*/
                      DO: 
                          IF ( INT(SUBSTRING(aux_setlinha,078,2)) <> 0 ) THEN DO:

                                  aux_dtvencto =
                                         DATE(INT(SUBSTRING(aux_setlinha,080,2)),
                                              INT(SUBSTRING(aux_setlinha,078,2)),
                                              INT(SUBSTRING(aux_setlinha,082,4))) NO-ERROR.
        
                                  IF ERROR-STATUS:ERROR THEN
                                  DO:
                                      ASSIGN aux_dtvencto = ?
                                             rej_cdmotivo = "16".   /* Data de Vencimento Invalida */
                                  END.
                                  
                                  IF ( aux_dtvencto < TODAY ) OR ( aux_dtvencto > DATE("13/10/2049") )  THEN DO:
                                        IF rej_cdmotivo = "" THEN
                                            ASSIGN rej_cdmotivo = "18".   /* Vencimento Fora do Prazo de Operacao   */ 

                                  END.

                                  IF  aux_inemiten = 3 THEN DO: /* coop. emite e expede */
        
                                        IF aux_dtvencto <= ADD-INTERVAL(TODAY,aux_diasvcto,'DAYS') THEN
                                        DO:
                                            IF rej_cdmotivo = "" THEN
                                              ASSIGN rej_cdmotivo = "16".   /* Data de Vencimento Invalida */
                                        END.
                                  END.
                             
                          END.
                          ELSE DO:
                                ASSIGN aux_dtvencto = ?.
                                       rej_cdmotivo = "16".    /* Data de Vencimento Invalida */ 
                          END.

                      END.

                      /* 21.3P Valida Valor do Titulo */
                      /* O valor do titulo sempre sera validado independente de ter gerado */
                      /* erro anteriormente */
                      aux_vltitulo = DEC(SUBSTR(aux_setlinha,86,15))/ 100 NO-ERROR.
        
                      IF ERROR-STATUS:ERROR THEN DO:
                          IF rej_cdmotivo = "" THEN
                              ASSIGN rej_cdmotivo = "20".   /* Valor do Titulo Invalido */
                      END.
                      ELSE
                          IF aux_vltitulo = 0 THEN DO:
                              IF rej_cdmotivo = "" THEN
                                  ASSIGN rej_cdmotivo = "20".   /* Valor do Titulo Invalido */
                          END.

                      /* 1.3P Banco */
                      IF rej_cdmotivo = "" THEN DO:

                          IF SUBSTR(aux_setlinha,1,3) <> "085" THEN /* Cecred */
                              ASSIGN rej_cdmotivo = "01".   /* Codigo do Banco Invalido */

                      END.
/*
                      /* 17.3P Valida Tipo de Emissao do Boleto */
                      IF ( aux_cdocorre = 01 OR aux_cdocorre = 90 ) THEN /* 01 - Remessa  */
                      DO: 

                          aux_inemiten = INT(SUBSTRING(aux_setlinha,061,1)) NO-ERROR.

                          IF ERROR-STATUS:ERROR THEN
                          DO:
                              ASSIGN aux_inemiten = 0
                                     rej_cdmotivo = "13".   /* Identificação da Emissao do Bloqueto invalida */
                          END.
        
                          IF ( aux_inemiten <> 1 ) AND   /* Banco Emite */
                             ( aux_inemiten <> 2 ) THEN  /* Cliente Emite */
                          DO:
                                IF rej_cdmotivo = "" THEN
                                    ASSIGN rej_cdmotivo = "13".   /* Identificação da Emissao do Bloqueto invalida */

                          END.
                          ELSE 
                          DO:   
                               IF aux_inemiten = 1 THEN
                                   ASSIGN aux_inemiten = 3     /* Cooperativa Emite e Expede */
                                          aux_inemiexp = 1.    /* Indicador de emissão, 1 – cooperativa emite e expede – a enviar */
                               ELSE
                                   ASSIGN aux_inemiten = 2     /* Cooperado Emite e Expede */
                                          aux_inemiexp = 0.           
                          END.

                      END.
*/
                      /* 14.3P Carteira */
                      IF rej_cdmotivo = "" THEN DO:

                          IF SUBSTR(aux_setlinha,58,1) <> "1" THEN /* Cobrança Simples */
                              ASSIGN rej_cdmotivo = "10".   /* Carteira Invalido */

                      END.

                      /* 24.3P Especie do Titulo */
                      IF rej_cdmotivo = "" THEN DO:

                          aux_cddespec = INT(SUBSTR(aux_setlinha,107,2)) NO-ERROR.

                          IF ERROR-STATUS:ERROR THEN
                               ASSIGN rej_cdmotivo = "21".   /* Especie do Titulo Invalido */ 
                          ELSE DO:

                              /* Tratar Especie do Titulo Febraban -> Cecred */
                              CASE aux_cddespec:
                                  WHEN 02 THEN aux_cddespec = 01. /* DM */
                                  WHEN 04 THEN aux_cddespec = 02. /* DS */
                                  WHEN 12 THEN aux_cddespec = 03. /* NP */
                                  WHEN 17 THEN aux_cddespec = 06. /* Recibo */
                                  WHEN 21 THEN aux_cddespec = 04. /* Mensalidade */
                                  WHEN 23 THEN aux_cddespec = 05. /* Nota Fiscal */
                                  OTHERWISE    
                                        ASSIGN rej_cdmotivo = "21".   /* Especie do Titulo Invalido */ 
                              END CASE.

                          END.
                      END.

                      /* 26.3P Valida Data de Emissao */
                      IF rej_cdmotivo = "" THEN DO:

                          IF   INT(SUBSTRING(aux_setlinha,110,2)) <> 0 THEN DO:
                               
                                aux_dtemscob =
                                     DATE(INT(SUBSTRING(aux_setlinha,112,2)),
                                          INT(SUBSTRING(aux_setlinha,110,2)),
                                          INT(SUBSTRING(aux_setlinha,114,4))) NO-ERROR.

                                IF ERROR-STATUS:ERROR THEN
                                     ASSIGN rej_cdmotivo = "24".   /* Data da Emissao Invalida */
                                ELSE 
                                    DO:
                                        
                                    IF aux_dtemscob > DATE("13/10/2049") OR
                                           (TODAY - 90) > aux_dtemscob THEN
                                            IF rej_cdmotivo = "" THEN
                                                ASSIGN rej_cdmotivo = "24". /*Data de documento superior ao limite 13/10/2049 ou
                                                                            Data retroativa maior que 90 dias.*/
                                          
                                        IF aux_dtvencto < aux_dtemscob THEN
                                            IF rej_cdmotivo = "" THEN
                                                ASSIGN rej_cdmotivo = "17". /*Data de vencimento anterior a data de emissao*/
                                    END.
                          END.
                          ELSE 
                          DO:
                                ASSIGN aux_dtemscob = ?
                                       rej_cdmotivo = "24".   /* Data da Emissao Invalida */
                          END.
                      END.

                      /* 27.3P Valida Codigo do Juros de Mora */
                      IF rej_cdmotivo = "" THEN DO:

                          aux_tpdjuros = INT(SUBSTR(aux_setlinha,118,01)) NO-ERROR.

                          IF ERROR-STATUS:ERROR THEN
                                ASSIGN rej_cdmotivo = "26".   /* Codigo de Juros de Mora Invalido */
                          ELSE DO:
                              IF ( aux_tpdjuros <> 1   AND      /* Valor por Dia */
                                   aux_tpdjuros <> 2   AND      /* Taxa Mensal   */ 
                                   aux_tpdjuros <> 3 ) THEN DO: /* Isento        */
                              
                                   ASSIGN rej_cdmotivo = "26".   /* Codigo de Juros de Mora Invalido */
                              END.
                          END.
                      END.

                      /* 29.3P Valida Valor de Mora */
                      IF rej_cdmotivo = "" THEN DO:

                          aux_vldjuros = DEC(SUBSTR(aux_setlinha,127,15)) / 100 NO-ERROR.
    
                          IF ERROR-STATUS:ERROR THEN
                                ASSIGN rej_cdmotivo = "27".   /* Valor/Taxa de Juros de Mora Invalido */ 
                          ELSE DO:
                              CASE aux_tpdjuros:
                                  WHEN 1 THEN
                                      DO:
                                          IF ( aux_vldjuros > aux_vltitulo ) OR ( aux_vldjuros = 0 ) THEN
                                                ASSIGN rej_cdmotivo = "27".   /* Valor/Taxa de Juros de Mora Invalido */
                                      END.
                                  WHEN 2 THEN
                                      DO:
                                          IF ( aux_vldjuros > 100 ) OR ( aux_vldjuros = 0 ) THEN
                                                ASSIGN rej_cdmotivo = "27".   /* Valor/Taxa de Juros de Mora Invalido */
                                      END.
                                  WHEN 3 THEN
                                      DO:
                                         /* Se Isento Desprezar Valor */
                                         aux_vldjuros = 0.
                                      END.
                              END CASE.
                          END.
                      END.

                      /* 30.3P Valida Codigo do Desconto */
                      IF rej_cdmotivo = "" THEN DO:

                          aux_tpdescto = INT(SUBSTR(aux_setlinha,142,01)) NO-ERROR.

                          IF ERROR-STATUS:ERROR THEN
                               ASSIGN rej_cdmotivo = "28".   /* Codigo do Desconto Invalido */
                          ELSE DO:

                              IF aux_tpdescto <> 0 AND      /* Desprezar Desconto               */
                                 aux_tpdescto <> 1 THEN     /* Valor Fixo ate a Data Informada  */

                                 ASSIGN rej_cdmotivo = "28".   /* Codigo do Desconto Invalido */
                          END.

                      END.

                      /* 31.3P 32.3P Valida Data de Desconto e Valor de Desconto */
                      IF rej_cdmotivo = "" AND 
                         aux_tpdescto = 1 THEN DO: /* Valor Fixo ate a Data Informada  */

                            aux_dtdescto = 
                                DATE(INT(SUBSTRING(aux_setlinha,145,2)),
                                      INT(SUBSTRING(aux_setlinha,143,2)),
                                      INT(SUBSTRING(aux_setlinha,147,4))) NO-ERROR.

                            IF ERROR-STATUS:ERROR THEN
                                ASSIGN rej_cdmotivo = "80".   /* Data do Desconto Invalida    */
                            ELSE DO:

                                aux_vldescto = DEC(SUBSTR(aux_setlinha,151,15)) / 100 NO-ERROR.

                                IF ERROR-STATUS:ERROR THEN
                                     ASSIGN rej_cdmotivo = "30".   /* Desconto a Conceder Nao Confere */
                                ELSE DO:

                                    IF aux_vldescto = 0 THEN
                                        ASSIGN rej_cdmotivo = "30".   /* Desconto a Conceder Nao Confere */

                                    IF ( aux_vldescto >= aux_vltitulo ) THEN
                                               ASSIGN rej_cdmotivo = "29".   /* Valor do Desconto Maior ou Igual ao Valor do Titulo  */
                                END.
                            END.
                      END.
                      
                      DO WHILE LENGTH(TRIM(aux_dsnosnum)) < 17:
                         ASSIGN aux_dsnosnum = "0" + aux_dsnosnum.
                      END.
                           
                      ASSIGN aux_nrdconta = INT(SUBSTR(aux_dsnosnum,01,08))
                             aux_nrbloque = DEC(SUBSTR(aux_dsnosnum,09,09)).
                             

                      /* 13.3P Validacao Nosso Numero */
                      IF rej_cdmotivo = "" THEN DO:

                          IF aux_nrdconta <> par_nrdconta THEN
                                ASSIGN rej_cdmotivo = "08".   /* Nosso Numero Invalido  */
                          ELSE DO:
                              IF aux_cdocorre = 01 THEN DO: /* 01 - Remessa */
        
                                   IF TRIM(aux_dsnosnum) = "" THEN
                                        ASSIGN rej_cdmotivo = "08".   /* Nosso Numero Invalido  */ 
                                   ELSE DO:
                                       /* Verifica existencia */
                                       FIND FIRST crapcob WHERE 
                                                  crapcob.cdcooper = par_cdcooper AND
                                                  crapcob.cdbandoc = aux_cdbandoc AND  
                                                  crapcob.nrdctabb = aux_nrdctabb AND
                                                  crapcob.nrcnvcob = aux_nrcnvcob AND
                                                  crapcob.nrdconta = aux_nrdconta AND
                                                  crapcob.nrdocmto = aux_nrbloque
                                                   NO-LOCK NO-ERROR.
            
                                       IF AVAIL(crapcob) THEN
                                           /* Se o boleto possuir informacao de "LIQAPOSBX" e o cobranca
                                             nao entrou o boleto deve adicionado para ser processado */
                                           IF NOT (crapcob.dsinform MATCHES "LIQAPOSBX*" AND 
                                                   crapcob.incobran = 0) THEN DO:
                                                ASSIGN rej_cdmotivo = "09".   /* Nosso Numero Duplicado */ 
                                           END.
                                   END.
                              END.
                          END.
                      END.

                      /* 08.3P a 12.3P Valida se Conta do Cooperado e igual ao nr da Conta de Importacao do Arquivo*/
                      IF rej_cdmotivo = "" THEN DO:

                          FIND crapceb WHERE
                               crapceb.cdcooper = par_cdcooper AND
                               crapceb.nrdconta = aux_nrdconta AND
                               crapceb.nrconven = aux_nrcnvcob AND
                               crapceb.insitceb = 1 /* Ativo */
                               NO-LOCK NO-ERROR.
                                                                  
                          IF NOT AVAILABLE crapceb THEN 
                              ASSIGN rej_cdmotivo = "96".   /* Numero de contrato invalido  */ 
                      END.

                      /* 19.3P Valida Nro. Documento de Cobranca */
                      IF rej_cdmotivo = "" THEN DO:

                          IF TRIM(aux_dsdoccop) = "" THEN 
                                ASSIGN rej_cdmotivo = "86".    /* Seu Numero Invalido */
                          ELSE
                          DO:
                                RUN valida_caracteres( INPUT TRUE,      /* Validar Numeros */
                                                       INPUT TRUE,      /* Validar Letras  */
                                                       INPUT ".,/,-,_", /* Lista Caracteres Validos */
                                                       INPUT aux_dsdoccop,
                                                       OUTPUT aux_flgerro).
    
                                IF aux_flgerro = TRUE THEN
                                    ASSIGN rej_cdmotivo = "86".    /* Seu Numero Invalido */
                          END.
                      END.

                      /* 34.3P Valor de Abatimento */
                      IF rej_cdmotivo = "" THEN DO:

                          aux_vlabatim = DEC(SUBSTR(aux_setlinha,181,15)) / 100 NO-ERROR.
    
                          IF ERROR-STATUS:ERROR THEN
                                ASSIGN rej_cdmotivo = "33".   /* Valor do Abatimento Invalido */
                          ELSE DO:
                              IF ( ( aux_vlabatim > 0 ) AND 
                                   ( aux_vlabatim >= aux_vltitulo ) ) THEN
                                    ASSIGN rej_cdmotivo = "34".    /* Valor do Abatimento Maior ou Igual ao Valor do Titulo */
                          END.

                      END.

                      /* 36.3P Valida Codigo de Protesto */
                      IF rej_cdmotivo = "" THEN DO:

                          aux_cdprotes = INT(SUBSTR(aux_setlinha,221,01)) NO-ERROR.

                          IF ERROR-STATUS:ERROR THEN
                               ASSIGN rej_cdmotivo = "37".    /* Codigo para Protesto Invalido  */
                          ELSE DO:

                              IF aux_cdprotes <> 1 AND      /* Protestar Dias Corridos          */
                                 aux_cdprotes <> 2 AND      /* Negativar Serasa                 */
                                 aux_cdprotes <> 3 AND      /* Nao Protestar                    */
                                 aux_cdprotes <> 9 THEN DO: /* Cancel. do Protesto automatico   */ 
                                
                                      ASSIGN rej_cdmotivo = "37".    /* Codigo para Protesto Invalido  */
                              END.
                              ELSE DO:
                                  IF ( aux_cdprotes = 9 AND    /* Cancel. do Protesto automatico */
                                       aux_cdocorre <> 31 ) THEN DO: /* Alteracao de Outros Dados      */
            
                                      ASSIGN rej_cdmotivo = "37".    /* Codigo para Protesto Invalido  */
                                  END.
                              END.

                          END.
                      END.

                      IF rej_cdmotivo = "" THEN DO:  
                          IF ( crapass.inpessoa = 1 AND aux_cdprotes = 1 ) THEN
                                ASSIGN rej_cdmotivo = "39".    /* Pedido de protesto nao permitido para o titulo  */
                      END.

                      /* 37.3P Valida Prazo para Protesto */
                      IF rej_cdmotivo = "" THEN DO:

                          IF aux_cdprotes = 1 THEN DO:  /* Protestar Dias Corridos */

                              aux_qtdiaprt = INT(SUBSTR(aux_setlinha,222,02)) NO-ERROR.

                              IF ERROR-STATUS:ERROR THEN
                                    ASSIGN rej_cdmotivo = "38".    /* Prazo para Protesto Invalido  */
                              ELSE DO:

                                  /* Prazo para protesto valido de 5 a 15 dias */
                                  IF ( aux_qtdiaprt < 5    OR 
                                       aux_qtdiaprt > 15 ) THEN
                                        ASSIGN rej_cdmotivo = "38".    /* Prazo para Protesto Invalido  */
                              END.
                          END.
                      END.

                      /* Verifica Serasa */
                      IF rej_cdmotivo = "" THEN DO:

                          IF aux_cdprotes = 2 AND crapceb.flserasa = TRUE  THEN DO:  /* Negativar Serasa e possui convenio serasa */

                              aux_qtdiaprt = INT(SUBSTR(aux_setlinha,222,02)) NO-ERROR.

                              IF ERROR-STATUS:ERROR THEN
                                    ASSIGN rej_cdmotivo = "38".    /* Prazo para Protesto Invalido  */
                              ELSE 
                              DO:
                                 aux_serasa = TRUE.
                                /* Modificado para efetuar demais validação junto ao sacado. */
                              END.
                          END.
                      END.

                      /* Gera Registro de Rejeicao */
                      IF rej_cdmotivo <> "" THEN DO:
                          
                          IF aux_cdocorre = 01 THEN
                              rej_cdocorre = 03. /* Entrada Rejeitada   */
                          ELSE
                              rej_cdocorre = 26. /* Instrucao Rejeitada */
                          
                          RUN prep-retorno-cooperado-rejeitado 
                                        (INPUT par_cdcooper,
                                         INPUT par_nrdconta,
                                         INPUT aux_nrcnvcob,
                                         INPUT rej_cdocorre,
                                         INPUT rej_cdmotivo,
                                         INPUT aux_dsnosnum,
                                         INPUT aux_vltitulo,
                                         INPUT crapcop.cdbcoctl,
                                         INPUT crapcop.cdagectl,
                                         INPUT par_dtmvtolt,
                                         INPUT par_cdoperad,
                                         INPUT aux_dsdoccop,
                                         INPUT aux_nrremass,
                                         INPUT aux_dtvencto,
                                         INPUT aux_dtemscob).
                      END.

                    END.  /*  Tipo de  Registro  P   */
              ELSE
                   IF  SUBSTR(aux_setlinha,14,01) = "Q" AND 
                       rej_cdmotivo = "" THEN /* Nao Tenha Erros */
                       DO:
                            /* So Validas Comandos de Intrucao */
                              IF aux_cdocorre <> 1 THEN DO: /* 01 - Remessa */
            
                                  IF aux_cdocorre = 31 THEN
                                      RUN valida-execucao-instrucao (  INPUT par_cdcooper,
                                                                       INPUT aux_nrdconta,
                                                                       INPUT aux_setlinha,
                                                                       INPUT aux_cdocorre,
                                                                       INPUT "240",
                                                                      OUTPUT rej_cdmotivo).
        
                                  IF rej_cdmotivo <> ""  THEN DO:
        
                                        /* Incluir Geracao Retorno Rejeitado */
                                        RUN prep-retorno-cooperado-rejeitado 
                                                                (INPUT par_cdcooper,
                                                                 INPUT par_nrdconta,
                                                                 INPUT aux_nrcnvcob,
                                                                 INPUT 26,              /* Instrucao */
                                                                 INPUT rej_cdmotivo,
                                                                 INPUT aux_dsnosnum,
                                                                 INPUT aux_vltitulo,
                                                                 INPUT crapcop.cdbcoctl,
                                                                 INPUT crapcop.cdagectl,
                                                                 INPUT par_dtmvtolt,
                                                                 INPUT par_cdoperad,
                                                                 INPUT aux_dsdoccop,
                                                                 INPUT aux_nrremass,
                                                                 INPUT aux_dtvencto,
                                                                 INPUT aux_dtemscob).
            
                                  END.
        
                                  NEXT.        
                              END.

                          ASSIGN glb_cdcritic = 0.

                          ASSIGN aux_nrdconta = par_nrdconta.

                          FIND crapass WHERE
                               crapass.cdcooper = par_cdcooper AND
                               crapass.nrdconta = par_nrdconta
                               NO-LOCK NO-ERROR.

                          IF   NOT AVAILABLE crapass   THEN
                               DO:
                                   ret_cdcritic = 9. /* Associado nao cadastrado */
                                   RUN fontes/critic.p.

                                   /* Cria Rejeitado */
                                   CREATE crawrej.
                                   ASSIGN crawrej.cdcooper = par_cdcooper
                                          crawrej.nrdconta = par_nrdconta
                                          crawrej.nrdocmto = aux_nrbloque
                                          crawrej.dscritic = glb_dscritic
                                                             + " -  C/C : " +
                                              STRING(par_nrdconta,"zzzz,zzz,9").
                                   NEXT.
                               END.
                          ELSE
                               aux_nmprimtl = crapass.nmprimtl.

                          
                          ASSIGN aux_nmdsacad = REPLACE(SUBSTR(aux_setlinha,34,40),"&","E")
                                 aux_dsendsac = SUBSTR(aux_setlinha,74,40)
                                 aux_nmbaisac = SUBSTR(aux_setlinha,114,15)
                                 aux_nmcidsac = SUBSTR(aux_setlinha,137,15)
                                 aux_cdufsaca = SUBSTR(aux_setlinha,152,02).

                          IF aux_serasa = TRUE THEN
                          DO:
                              ASSIGN aux_qtminimo = 0
                                     aux_qtmaximo = 0
                                     aux_vlminimo = 0.
                            
                            /* Rotina para buscar paraemtros de negativacao com base no estado do sacado */
                            RUN busca_parametro_negativ( INPUT par_cdcooper,
                                                         INPUT aux_cdufsaca,
                                                        OUTPUT aux_qtminimo,
                                                        OUTPUT aux_qtmaximo,
                                                        OUTPUT aux_vlminimo,
                                                        OUTPUT par_dscritic).
            
            
                              /* Prazo valido  */
                              IF (( aux_qtdiaprt < aux_qtminimo    OR 
                                    aux_qtdiaprt > aux_qtmaximo ) AND 
                                    aux_qtdiaprt <> 0 ) THEN
                                    ASSIGN rej_cdmotivo = "S3".    /* Prazo para Negativacao Serasa Invalido */
            
                              IF aux_qtdiaprt > 0 AND aux_vltitulo < aux_vlminimo AND rej_cdmotivo = ""  THEN
                                    ASSIGN rej_cdmotivo = "S4".    /* Valor Inferior au Minimo Permitido para Negativacao Serasa Invalido */
            
                              IF rej_cdmotivo = "" THEN
                              DO:
                                IF aux_qtdiaprt = 0 AND aux_vltitulo < aux_vlminimo THEN
                                  ASSIGN aux_flserasa = FALSE
                                         aux_qtdianeg = 0
                                         aux_inserasa = 0.
                                ELSE
                                  ASSIGN aux_flserasa = TRUE
                                         aux_qtdianeg = aux_qtdiaprt
                                         aux_inserasa = 0.
                              END.

                          END.

                          /* 01.3Q Banco */
                          IF rej_cdmotivo = "" THEN DO:
    
                              IF SUBSTR(aux_setlinha,1,3) <> "085" THEN /* Cecred */
                                  ASSIGN rej_cdmotivo = "01".   /* Codigo do Banco Invalido */
    
                          END.

                          /* 08.3Q Valida Tipo de Inscricao */
                          IF rej_cdmotivo = "" THEN DO:

                              aux_cdtpinsc = INT(SUBSTR(aux_setlinha,18,01)) NO-ERROR.
                                
                              IF ERROR-STATUS:ERROR THEN
                                   ASSIGN rej_cdmotivo = "46".    /* Tipo/Numero de Inscricao do Sacado Invalidos    */
                              ELSE DO:
                                  IF aux_cdtpinsc <> 1 AND
                                     aux_cdtpinsc <> 2  THEN
                                         ASSIGN rej_cdmotivo = "46".    /* Tipo/Numero de Inscricao do Sacado Invalidos    */
                              END.
                          END.

                          /* 09.3Q Valida Numero de Inscricao */
                          IF rej_cdmotivo = "" THEN DO: 

                               aux_nrinssac = DEC(SUBSTR(aux_setlinha,19,15)) NO-ERROR.

                               IF ERROR-STATUS:ERROR THEN
                                   ASSIGN rej_cdmotivo = "46".    /* Tipo/Numero de Inscricao do Sacado Invalidos    */
                               ELSE DO:

                                  RUN valida_cpf_cnpj(INPUT  aux_cdtpinsc,
                                                      INPUT  aux_nrinssac,
                                                      OUTPUT aux_flgerro).

                                  IF aux_flgerro = TRUE THEN
                                      ASSIGN rej_cdmotivo = "46".    /* Tipo/Numero de Inscricao do Sacado Invalidos    */
                              END.
                          END.

                          /* 10.3Q Valida Nome do Sacado */
                          IF rej_cdmotivo = "" THEN DO:

                              IF TRIM(aux_nmdsacad) = "" THEN
                                  ASSIGN rej_cdmotivo = "45".    /* Nome do Sacado Nao Informado    */
                              ELSE DO:
                                  RUN valida_caracteres( INPUT TRUE,    /* Validar Numeros          */
                                                         INPUT TRUE,    /* Validar Letras           */
                                                         INPUT ".,/,-,_", /* Lista Caracteres Validos */
                                                         INPUT aux_nmdsacad,
                                                         OUTPUT aux_flgerro).

                                  IF aux_flgerro = TRUE THEN
                                       ASSIGN rej_cdmotivo = "45".    /* Nome do Sacado Nao Informado    */
                              END.
                          END.
                            

                          /* 11.3Q Valida Endereco do Sacado */
                          IF rej_cdmotivo = "" THEN DO:

                              IF TRIM(aux_dsendsac) = "" THEN
                                  ASSIGN rej_cdmotivo = "47".    /* Endereco do Sacado Nao Informado    */
                              ELSE DO:
                                  RUN valida_caracteres( INPUT TRUE,            /* Validar Numeros          */
                                                         INPUT TRUE,            /* Validar Letras           */
                                                         INPUT ".,/,-,_",       /* Lista Caracteres Validos */
                                                         INPUT REPLACE(aux_dsendsac,","," "),
                                                         OUTPUT aux_flgerro).
    
                                  IF aux_flgerro = TRUE THEN
                                      ASSIGN rej_cdmotivo = "47".    /* Endereco do Sacado Nao Informado    */
                              END.
                          END.
                         
                          /* 13.3Q e 14.3Q Valida CEP do Sacado */
                          IF rej_cdmotivo = "" THEN DO:

                              aux_nrcepsac = INT(SUBSTR(aux_setlinha,129,8)) NO-ERROR.

                              IF ERROR-STATUS:ERROR THEN
                                  rej_cdmotivo = "48".    /* CEP Invalido */
                              ELSE DO:

                                FIND FIRST crapdne WHERE crapdne.nrceplog = aux_nrcepsac AND
                                                         crapdne.idoricad = 1           /* Correios */
                                                         NO-LOCK NO-ERROR.
                                IF  NOT AVAIL(crapdne) THEN
                                    DO:
                                        FIND FIRST crapdne WHERE crapdne.nrceplog = aux_nrcepsac AND
                                                                 crapdne.idoricad = 2           /* Ayllos */
                                                                 NO-LOCK NO-ERROR.
                                        IF  NOT AVAIL(crapdne) THEN
                                            ASSIGN rej_cdmotivo = "48".    /* CEP Invalido */
                                    END.
                              END.
                          END.
                          

                          /* 16.3Q Valida UF do Sacado */
                          IF rej_cdmotivo = "" THEN DO:

                              IF aux_cdufsaca <> crapdne.cduflogr THEN
                                    ASSIGN rej_cdmotivo = "51".    /* CEP incompativel com a Unidade da Federacao */

                          END.

                          /* 17.3Q Valida Tipo de Inscricao Avalista */
                          IF rej_cdmotivo = "" THEN DO:

                                aux_cdtpinav = INT(SUBSTR(aux_setlinha,154,1)) NO-ERROR.

                                IF ERROR-STATUS:ERROR THEN
                                    ASSIGN rej_cdmotivo = "53".    /* Tipo/Numero de Inscricao do Sacador/Avalista Invalidos */
                                ELSE DO:

                                  IF aux_cdtpinav <> 0 AND      /* Vazio    */
                                     aux_cdtpinav <> 1 AND      /* Fisica   */
                                     aux_cdtpinav <> 2  THEN    /* Juridica */
                                          ASSIGN rej_cdmotivo = "53".    /* Tipo/Numero de Inscricao do Sacador/Avalista Invalidos */

                                END.
                          END.

                          /* 18.3Q Valida Numero de Inscricao Avalista */
                          IF rej_cdmotivo = "" AND aux_cdtpinav <> 0 THEN DO:

                              aux_nrinsava = DEC(SUBSTR(aux_setlinha,155,15)) NO-ERROR.

                              IF ERROR-STATUS:ERROR THEN
                                  ASSIGN rej_cdmotivo = "53".    /* Tipo/Numero de Inscricao do Sacador/Avalista Invalidos */
                              ELSE DO:
                                  RUN valida_cpf_cnpj(INPUT  aux_cdtpinav, /* Tipo de Pessoa                */
                                                      INPUT  aux_nrinsava, /* Numero da Inscricao do Sacado */
                                                      OUTPUT aux_flgerro).
    
                                  IF aux_flgerro = TRUE THEN
                                       ASSIGN rej_cdmotivo = "53".    /* Tipo/Numero de Inscricao do Sacador/Avalista Invalidos */
    
                              END. 
                          END.
                          

                          /* 19.3Q Valida Nome do Sacado Avalista  */
                          IF rej_cdmotivo = "" AND aux_cdtpinav <> 0 THEN DO:

                                                          aux_nmdavali = SUBSTR(aux_setlinha,170,40) NO-ERROR.
                              IF TRIM(aux_nmdavali) = "" THEN
                                   ASSIGN rej_cdmotivo = "54".    /* Sacador/Avalista Nao Informado    */
                              ELSE DO:

                                  RUN valida_caracteres( INPUT TRUE,            /* Validar Numeros          */
                                                         INPUT TRUE,            /* Validar Letras           */
                                                         INPUT ".,/,-,_",       /* Lista Caracteres Validos */
                                                         INPUT aux_nmdavali,
                                                         OUTPUT aux_flgerro).
        
                                  IF aux_flgerro = TRUE THEN
                                      ASSIGN rej_cdmotivo = "54".    /* Sacador/Avalista Nao Informado    */
                              END.
                          END.

                          /* Se for solicitacao de Remessa, entao devera gravar sacado */
                          IF  aux_cdocorre = 01 AND rej_cdmotivo = "" THEN DO:
                                RUN p_grava_sacado.
                          END.    

                          /* Gera Registro de Rejeicao */
                          IF rej_cdmotivo <> "" THEN DO:
                              
                              IF rej_cdmotivo = "S3" OR rej_cdmotivo = "S4" THEN
                                rej_cdocorre = 92. /* Inconsistencia Negativacao Serasa */
                              ELSE IF aux_cdocorre = 01 THEN
                                rej_cdocorre = 03. /* Remessa Rejeitada   */
                              ELSE
                                rej_cdocorre = 26. /* Instrucao Rejeitada */
                              
                              RUN prep-retorno-cooperado-rejeitado 
                                            (INPUT par_cdcooper,
                                             INPUT par_nrdconta,
                                             INPUT aux_nrcnvcob,
                                             INPUT rej_cdocorre,
                                             INPUT rej_cdmotivo,
                                             INPUT aux_dsnosnum,
                                             INPUT aux_vltitulo,
                                             INPUT crapcop.cdbcoctl,
                                             INPUT crapcop.cdagectl,
                                             INPUT par_dtmvtolt,
                                             INPUT par_cdoperad,
                                             INPUT aux_dsdoccop,
                                             INPUT aux_nrremass,
                                             INPUT aux_dtvencto,
                                             INPUT aux_dtemscob).
                          END.  

                       END.  /*  Final Tipo de  Registro  Q   */
                   ELSE
                   /*  Tipo de  Registro  R  */
                   IF  SUBSTR(aux_setlinha,14,01) = "R"  AND 
                       SUBSTR(aux_setlinha,16,02) = "01" AND 
                       rej_cdmotivo = "" THEN 
                       DO:

                            /* Nao verifica registro R quando Instrucao */
                            IF aux_cdocorre <> 1 THEN /* 1 - Remessa */
                                NEXT.
                            
                            /* 14.3R Valida Codigo da Multa */
                            ASSIGN aux_tpdmulta = INT(SUBSTR(aux_setlinha,66,1)) NO-ERROR.

                            IF ERROR-STATUS:ERROR THEN
                                ASSIGN rej_cdmotivo = "57".    /* Codigo da Multa Invalido */
                            ELSE DO:
                                IF aux_tpdmulta <> 1 AND    /* Valor Fixo */
                                   aux_tpdmulta <> 2 THEN   /* Percentual */
                                      ASSIGN rej_cdmotivo = "57".    /* Codigo da Multa Invalido */
                            END.
    

                            /* 16.3R Valida Valor da Multa */
                            IF rej_cdmotivo = "" THEN DO:

                                ASSIGN aux_vldmulta = DEC(SUBSTR(aux_setlinha,75,15))/ 100 NO-ERROR.

                                IF ERROR-STATUS:ERROR THEN
                                    ASSIGN rej_cdmotivo = "59".    /* Valor/Percentual da Multa Invalido  */
                                ELSE DO:
                                    /* se nao possui valor de multa, colocar o 
                                       tipo de multa para 3-Isento */
                                    IF aux_vldmulta = 0 THEN
                                        aux_tpdmulta = 3.
                                    ELSE
                                    IF aux_tpdmulta = 1  THEN DO:       /* Valor Fixo */
                                        IF aux_vldmulta > aux_vltitulo THEN
                                            ASSIGN rej_cdmotivo = "59".    /* Valor/Percentual da Multa Invalido  */
                                    END.
                                    ELSE /* Percentual */
                                        IF aux_vldmulta > 100  THEN
                                            ASSIGN rej_cdmotivo = "59".    /* Valor/Percentual da Multa Invalido  */
                                END.
                            END.

                            /* Gera Registro de Rejeicao */
                            IF rej_cdmotivo <> "" THEN DO:
                                  
                                  IF aux_cdocorre = 01 THEN
                                      rej_cdocorre = 03. /* Remessa Rejeitada   */
                                  ELSE
                                      rej_cdocorre = 26. /* Instrucao Rejeitada */
                                  
                                  RUN prep-retorno-cooperado-rejeitado 
                                                (INPUT par_cdcooper,
                                                 INPUT par_nrdconta,
                                                 INPUT aux_nrcnvcob,
                                                 INPUT rej_cdocorre,
                                                 INPUT rej_cdmotivo,
                                                 INPUT aux_dsnosnum,
                                                 INPUT aux_vltitulo,
                                                 INPUT crapcop.cdbcoctl,
                                                 INPUT crapcop.cdagectl,
                                                 INPUT par_dtmvtolt,
                                                 INPUT par_cdoperad,
                                                 INPUT aux_dsdoccop,
                                                 INPUT aux_nrremass,
                                                 INPUT aux_dtvencto,
                                                 INPUT aux_dtemscob).
                            END.  

                       END.
                   ELSE
                   /* Tipo de  Registro  S  */
                   /* Importar linha de mensagem quando solicitacao de remessa */
                   IF   SUBSTR(aux_setlinha,14,01) = "S"   AND
                        INT(SUBSTR(aux_setlinha,18,1)) = 3 AND 
                        SUBSTR(aux_setlinha, 16, 2) = "01" AND 
                        rej_cdmotivo = "" THEN
                        DO:

                          /* Nao verifica registro R quando Instrucao */
                          IF aux_cdocorre <> 1 THEN /* 1 - Remessa */
                                NEXT.

                          /* Concatena instrucoes separadas por _   */
                          ASSIGN aux_dsdinstr = SUBSTR(aux_setlinha,19,40) +
                                                "_" +
                                                SUBSTR(aux_setlinha,59,40) +
                                                "_" +
                                                SUBSTR(aux_setlinha,99,40) +
                                                "_" +
                                                SUBSTR(aux_setlinha,139,40) +
                                                "_" +
                                                SUBSTR(aux_setlinha,179,40).

                        END.  /*  Tipo de  Registro  S   */
                   ELSE
                   IF   SUBSTR(aux_setlinha,14,01) = "Y"   AND
                        INT(SUBSTR(aux_setlinha,18,2)) = 3 THEN 
                        DO:
                                   /* 09.4Y - E-mail para envio da informação  */
                            ASSIGN aux_dsdemail = SUBSTR(aux_setlinha,20,50)
                                   /* 10.4Y 11.4Y - Celular do pagador */
                                   aux_nrcelsac = DECI(SUBSTR(aux_setlinha,70,2) +
                                                  SUBSTR(aux_setlinha,72,8)).

                            RUN p_altera_email_cel_sacado(INPUT aux_cdcooper
                                                         ,INPUT aux_nrdconta
                                                         ,INPUT aux_nrinssac
                                                         ,INPUT aux_dsdemail
                                                         ,INPUT aux_nrcelsac).

                            /* Apos atualizar a informacao, limpa os campos*/
                            ASSIGN aux_dsdemail = ""
                                   aux_nrcelsac = 0.

                        END.  /*  Tipo de  Registro  Y   */

               END.  /*   Tipo de Registro 3  */

       END.  /*    Fim do While True   */

       /* Cria o ultimo boleto apenas se nao tiver erros */
       IF  aux_flgfirst     AND 
           ret_cdcritic = 0 AND 
           glb_cdcritic = 0 AND 
           rej_cdmotivo = "" THEN
           DO:
                CASE aux_cdocorre:

                    WHEN 01 THEN /* 01 - Remessa */
                        RUN p_grava_boleto.

                    OTHERWISE 
                        
                        RUN p_grava_instrucao.

                END CASE.
           END.

       INPUT STREAM str_3 CLOSE.

       /*2 Move o Arquivo UNIX para o "salvar" */
       UNIX SILENT VALUE("mv -f " + SUBSTRING(crawaux.nmarquiv,1,
                                    LENGTH(crawaux.nmarquiv) - 2) + " salvar").

       /* Apaga o Arquivo QUOTER */
       UNIX SILENT VALUE("rm -f " + crawaux.nmarquiv + " 2> /dev/null").


       ASSIGN aux_qtbloque = aux_qtdregis + aux_qtdinstr. 

       IF aux_qtbloque > 0 THEN
          DO:        
              RUN pi_protocolo_transacao( INPUT par_cdcooper,
                                          INPUT par_nrdconta,
                                         OUTPUT ret_nrprotoc,
                                         OUTPUT ret_hrtransa,
                                         OUTPUT aux_dscritic).
              
              IF  RETURN-VALUE <> "OK" THEN
              DO:
                  /* Cria Rejeitado */
                  CREATE crawrej.
                  ASSIGN crawrej.cdcooper = par_cdcooper
                         crawrej.nrdconta = par_nrdconta
                         crawrej.nrdocmto = aux_nrbloque
                         crawrej.dscritic = aux_dscritic +
                                 "- Remessa: " + STRING(aux_nrremass).

                  /* Apaga Arquivo */
                  UNIX SILENT VALUE("rm " + SUBSTRING(crawaux.nmarquiv,1,
                                            LENGTH(crawaux.nmarquiv) - 2) +
                                    " 2> /dev/null").
        
                  /* Apaga o Arquivo QUOTER */
                  UNIX SILENT VALUE("rm -f " + crawaux.nmarquiv +
                                     " 2> /dev/null").
        
                  NEXT.
              END.

              /* Cria Lote de Remessa do Cooperado */
              RUN pi_grava_rtc( INPUT par_cdcooper,
                                INPUT par_nrdconta,
                                INPUT crapcco.nrconven,
                                INPUT aux_nrremass ).  

              IF RETURN-VALUE = "NOK" THEN
              DO:
                  /* Apaga Arquivo */
                  UNIX SILENT VALUE("rm " + SUBSTRING(crawaux.nmarquiv,1,
                                            LENGTH(crawaux.nmarquiv) - 2) +
                                    " 2> /dev/null").
        
                  /* Apaga o Arquivo QUOTER */
                  UNIX SILENT VALUE("rm -f " + crawaux.nmarquiv +
                                     " 2> /dev/null").
        
                  NEXT.
              END.
          END.

       IF AVAIL craprtc THEN
       DO:
           ASSIGN craprtc.flgproce = YES
                  craprtc.qtreglot = aux_qtbloque
                  craprtc.qttitcsi = aux_qtbloque
                  craprtc.vltitcsi = aux_vlrtotal
                  craprtc.dsprotoc = ret_nrprotoc.

           IF TEMP-TABLE crawrej:HAS-RECORDS THEN
           DO:
               ret_cdcritic = 999. /* Rotina nao disponivel */
               RUN fontes/critic.p.
    
               /* Cria Rejeitado */
               CREATE crawrej.
               ASSIGN crawrej.cdcooper = par_cdcooper
                      crawrej.nrdconta = par_nrdconta
                      crawrej.nrdocmto = 999999
                      crawrej.dscritic = "Arquivo processado parcialmente!".
           END.
       END.
       ELSE DO:
           ret_cdcritic = 999. /* Rotina nao disponivel */
           RUN fontes/critic.p.

           /* Cria Rejeitado */
           CREATE crawrej.
           ASSIGN crawrej.cdcooper = par_cdcooper
                  crawrej.nrdconta = par_nrdconta
                  crawrej.nrdocmto = 999999
                  crawrej.dscritic = "Nenhum boleto foi processado!".
           NEXT.
       END.
   END.  /*   Fim do for each   */


   /* Apos a importacao, processar temp-table dos titulos */
   RUN p_processa_titulos.

   /* Apos a importacao, processar temp-table das instrucoes */
   RUN p_processa_instrucoes.
 
   /* Rotina para efetuar lancamento de tarifas de forma consolidada */
   RUN efetua-lancamento-tarifas-lat (INPUT par_cdcooper,
                                      INPUT par_dtmvtolt,
                                      INPUT-OUTPUT TABLE tt-lat-consolidada ).
   
   RETURN "OK".
  
END PROCEDURE. /* FIM - p_integra_arq_remessa_cnab240_085 */

PROCEDURE p_integra_arq_remessa_cnab400_085:
   
   DEF INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
   DEF INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
   DEF INPUT PARAM par_nmarquiv AS CHAR                              NO-UNDO.
   DEF INPUT PARAM par_idorigem AS INTE                              NO-UNDO.
   DEF INPUT PARAM par_dtmvtolt AS DATE                              NO-UNDO.
   DEF INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.
   DEF INPUT PARAM par_nmdatela AS CHAR                              NO-UNDO.
                                       
   DEF OUTPUT PARAM ret_qtreqimp AS INTE                             NO-UNDO.
   DEF OUTPUT PARAM ret_nrremret AS INTE                             NO-UNDO.
   DEF OUTPUT PARAM ret_nrprotoc AS CHAR                             NO-UNDO.
   DEF OUTPUT PARAM ret_cdcritic AS INTE                             NO-UNDO.
   DEF OUTPUT PARAM ret_hrtransa AS INTE                             NO-UNDO.
   DEF OUTPUT PARAM TABLE FOR crawrej.

   DEF VAR aux_setlinha AS CHAR    FORMAT "x(403)"                   NO-UNDO.
   DEF VAR aux_flgfirst AS LOGICAL                                   NO-UNDO.
   DEF VAR aux_nmendter AS CHAR                                      NO-UNDO.
   DEF VAR aux_nmfisico AS CHAR                                      NO-UNDO.
   DEF VAR aux_cdagenci AS INT                                       NO-UNDO.
   DEF VAR aux_contador AS INT                                       NO-UNDO.
   DEF VAR aux_flgutceb AS LOGICAL                                   NO-UNDO.
  
   DEF VAR tel_nmarqint AS CHAR FORMAT "x(60)"                       NO-UNDO.
   DEF VAR aux_dscritic AS CHAR                                      NO-UNDO.
   DEF VAR aux_qtboleto AS INTE                                      NO-UNDO.
   DEF VAR aux_vltarifa AS DECI                                      NO-UNDO.
   DEF VAR aux_cdtarhis AS INTE                                      NO-UNDO.
 
   DEF VAR tar_cdhistor AS INTE                                      NO-UNDO.
   DEF VAR tar_cdhisest AS INTE                                      NO-UNDO.
   DEF VAR tar_vltarifa AS DECI                                      NO-UNDO.
   DEF VAR tar_dtdivulg AS DATE                                      NO-UNDO.
   DEF VAR tar_dtvigenc AS DATE                                      NO-UNDO.
   DEF VAR tar_cdfvlcop AS INTE                                      NO-UNDO.
   DEF VAR aux_cdfvlcop AS INTE                                      NO-UNDO.   

   DEF VAR aux_dtgerarq AS DATE                                      NO-UNDO.
   DEF VAR rej_cdmotivo AS CHAR                                      NO-UNDO. 
   DEF VAR rej_cdocorre AS INTE                                      NO-UNDO.
   DEF VAR aux_cpfcnpj  AS DECI                                      NO-UNDO. 
   DEF VAR aux_flgerro  AS LOGICAL                                   NO-UNDO.   

   DEF VAR aux_cdcomand AS CHAR                                      NO-UNDO.                                      
   DEF VAR aux_cdinstr1 AS CHAR                                      NO-UNDO.   
   DEF VAR aux_cdinstr2 AS CHAR                                      NO-UNDO.

   DEF VAR aux_dtamulta AS DATE                                      NO-UNDO. 

   DEF VAR aux_qtdregis AS INTE                                      NO-UNDO.
   DEF VAR aux_qtdinstr AS INTE                                      NO-UNDO.   

   DEF BUFFER bcraprtc FOR craprtc.


   ASSIGN aux_nrdconta = par_nrdconta
          aux_cdcooper = par_cdcooper
          aux_dtmvtolt = par_dtmvtolt
          aux_cdoperad = par_cdoperad
          aux_nmdatela = par_nmdatela
          aux_nmarquiv = par_nmarquiv.

   /*  Acessa dados da cooperativa  */
   FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE crapcop   THEN
        DO:
            ret_cdcritic = 651. /* Falta registro de controle da cooperativa */
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic VIEW-AS ALERT-BOX.
            
            RETURN.
        END.

   /* Tabelas Temporarias */
   EMPTY TEMP-TABLE crawaux.
   EMPTY TEMP-TABLE crawrej.
   EMPTY TEMP-TABLE tt-verifica-sacado.
   EMPTY TEMP-TABLE tt-instr.

   ASSIGN  aux_flgfirst = FALSE
           ret_cdcritic = 0.

   INPUT STREAM str_3 FROM VALUE(par_nmarquiv) NO-ECHO.

   ASSIGN aux_contador = 0.
   
   DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

      ASSIGN aux_contador = aux_contador + 1.     

      /*   Header do Arquivo   */
      IMPORT STREAM str_3 UNFORMATTED aux_setlinha.

      /* Consiste tamanho do arquivo */
      IF  ERROR-STATUS:ERROR THEN 
          DO:
              INPUT STREAM str_3 CLOSE.

              glb_cdcritic = 999.
              glb_dscritic = "Arquivo invalido".
              
              RUN fontes/critic.p.
              /* Cria Rejeitado */
              CREATE crawrej.
              ASSIGN crawrej.cdcooper = par_cdcooper
                     crawrej.nrdconta = par_nrdconta
                     crawrej.nrdocmto = 0
                     crawrej.dscritic = glb_dscritic.
              
              RETURN "NOK".
          END.

      CREATE crawaux.
      ASSIGN crawaux.nrsequen = INT(SUBSTR(aux_setlinha,101,07)) /* Numero sequencial da remessa */
             crawaux.nmarquiv = par_nmarquiv
             aux_flgfirst     = TRUE.

      INPUT STREAM str_3 CLOSE.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */
   
   INPUT STREAM str_3 CLOSE.

   IF   NOT aux_flgfirst  THEN
        DO:
           ret_cdcritic = 887. /* Identificacao do arquivo Invalida */
           
           RETURN "NOK".
        END.

   ASSIGN aux_qtbloque = 0.

   ASSIGN aux_qtdregis = 0
          aux_qtdinstr = 0.  

   FOR EACH crawaux BY crawaux.nrsequen
                    BY crawaux.nmarquiv:

       ASSIGN ret_cdcritic = 0
              aux_flgfirst = FALSE
              aux_vlrtotal = 0.

       INPUT STREAM str_3 FROM VALUE(crawaux.nmarquiv) NO-ECHO.

       /* -------------- Header do Arquivo -------------- */
       IMPORT STREAM str_3 UNFORMATTED aux_setlinha.

       /* Verifica se convenio esta Homologacao */
       FIND FIRST crapceb WHERE crapceb.cdcooper = par_cdcooper AND
                                crapceb.nrconven = INT(SUBSTR(aux_setlinha,130,07)) AND
                                crapceb.nrdconta = par_nrdconta AND
                                crapceb.insitceb = 1
                                NO-LOCK NO-ERROR.

            IF AVAIL(crapceb) THEN DO:

                IF crapceb.flgcebhm = FALSE THEN
                    ASSIGN aux_dscritic = "Convenio Nao Homologado - Entre em contato com seu Posto de Atendimento.".
            END.
       
       /* 01.0 Identificacao do Registro Header */
       IF   SUBSTR(aux_setlinha,01,01) <> "0" THEN
            ret_cdcritic = 468. /* Tipo de registro errado */

       /* 02.0 Tipo de Operacao */
       IF   SUBSTR(aux_setlinha,02,01) <> "1" THEN DO:
           IF aux_dscritic = "" THEN
                ASSIGN aux_dscritic = "Tipo de Operacao Invalida.".
       END.

       /* 03.0 Identificacao por extenso do Tipo de Operacao */
       IF   SUBSTR(aux_setlinha,03,07) <> "REMESSA" THEN DO:
           IF aux_dscritic = "" THEN
                ASSIGN aux_dscritic = "Identificacao do Tipo de Operacao Invalida.".
       END.

       /* 04.0 Tipo de Servico*/
       IF   SUBSTR(aux_setlinha,10,02) <> "01" THEN DO:
           IF aux_dscritic = "" THEN
                ASSIGN aux_dscritic = "Tipo de Servico Invalida.".
       END.

       /* 05.0 Identificacao por extenso do Tipo de Servico*/
       IF   SUBSTR(aux_setlinha,12,08) <> "COBRANCA" THEN DO:
           IF aux_dscritic = "" THEN
                ASSIGN aux_dscritic = "Identificacao do Tipo de Servico Invalida.".
       END. 

       /* 07.0 a 08.0 Agencia/DV */
       IF aux_dscritic = "" THEN DO:
            IF STRING(crapcop.cdagectl,"9999") <> SUBSTR(aux_setlinha,27,04) THEN
                ASSIGN aux_dscritic = "Agencia/DV header Invalida.".

       END.

       /* 09.0 a 10.0 Numero da Conta/DV */
       IF aux_dscritic = "" THEN DO:
            FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper AND
                                     crapass.nrdconta = INT(SUBSTR(aux_setlinha,32,09))
                                     NO-LOCK NO-ERROR.

            IF NOT AVAIL(crapass) THEN
                ASSIGN aux_dscritic = "Conta/DV header Invalida.".

       END. 

       /* 13.0 Fixo "085" */
       IF   SUBSTR(aux_setlinha,77,03) <> "085" THEN DO:
           IF aux_dscritic = "" THEN
                ASSIGN aux_dscritic = "Identificacao HEADER Invalida.".
       END. 

       /* 14.0 Data de Gravacao do Arquivo */
       IF aux_dscritic = "" THEN DO:

           aux_dtgerarq = DATE(INT(SUBSTRING(aux_setlinha,97,2)),
                               INT(SUBSTRING(aux_setlinha,95,2)),
                               INT("20" + SUBSTRING(aux_setlinha,99,2))) NO-ERROR.

           IF ERROR-STATUS:ERROR THEN
                ASSIGN aux_dscritic = "Data de Gravacao do Arquivo Invalida.".
           ELSE 
               IF ( aux_dtgerarq > TODAY ) OR
                   ( aux_dtgerarq < ( TODAY - 30 ))   THEN DO:
                       ASSIGN aux_dscritic = "Data de Gravacao do Arquivo fora do Periodo Permitido.". 
               END. 

       END.
        
       /* 15.0 Sequencial da Remessa */
       IF aux_dscritic = "" THEN DO:

           /* Numero da Remessa do Cooperado */
           ASSIGN aux_nrremass = INT(SUBSTR(aux_setlinha, 101, 07)) NO-ERROR.

           IF ERROR-STATUS:ERROR THEN
                ASSIGN aux_dscritic = "Numero da Remessa Invalida.".
           ELSE DO:

               IF aux_nrremass = 0 THEN
                    ASSIGN aux_dscritic = "Numero da Remessa Invalida.".

                FIND LAST bcraprtc WHERE bcraprtc.cdcooper = crapass.cdcooper AND
                                         bcraprtc.nrdconta = crapass.nrdconta AND 
                                         bcraprtc.nrcnvcob = INT(SUBSTR(aux_setlinha,130,07)) AND
                                         bcraprtc.intipmvt = 1 /* 1 - Remessa */
                                         NO-LOCK NO-ERROR.             
    
                IF AVAIL(bcraprtc) THEN DO:
                    IF ( bcraprtc.nrremret = aux_nrremass ) THEN
                        ASSIGN aux_dscritic = "Arquivo ja processado".
                    ELSE
                        IF ( bcraprtc.nrremret > aux_nrremass ) THEN
                            ASSIGN aux_dscritic = "Numero de remessa inferior ao ultimo arquivo processado.".
                END.
           END.
       END.


       /* 17.0 Numero do Convenio Lider */
       IF aux_dscritic = "" THEN DO:
           
           FIND crapcco WHERE
                crapcco.cdcooper  = par_cdcooper                     AND
                crapcco.cddbanco  = 085                              AND
                crapcco.dsorgarq  = "IMPRESSO PELO SOFTWARE"         AND
                crapcco.nrconven  = INT(SUBSTR(aux_setlinha,130,07))  /* Convenio Lider */
                NO-LOCK NO-ERROR.
    
           /* Se localizou informacoes do convenio atribui as informacoes */
           IF   NOT AVAILABLE crapcco   THEN DO:
                ASSIGN  ret_cdcritic = 563 /* Convenio nao cadastrado*/
                        aux_dscritic = "Convenio nao Encontrado.". 
           END.
           ELSE DO:
                /* Busca e associa informacoes do convenio lider */
                ASSIGN aux_cdbancbb = crapcco.cddbanco   
                       aux_cdagenci = crapcco.cdagenci
                       aux_cdbccxlt = crapcco.cdbccxlt
                       aux_nrdolote = crapcco.nrdolote
                       aux_cdhistor = crapcco.cdhistor
                       aux_nrdctabb = crapcco.nrdctabb
                       aux_cdbandoc = crapcco.cddbanco
                       aux_nrcnvcob = crapcco.nrconven
                       aux_flgutceb = crapcco.flgutceb
                       aux_flgregis = crapcco.flgregis. 

                /* Verifica se convenio esta Habilitado */
                FIND FIRST crapceb WHERE crapceb.cdcooper = crapcco.cdcooper AND
                                         crapceb.nrconven = crapcco.nrconven AND
                                         crapceb.nrdconta = crapass.nrdconta AND 
                                         crapceb.insitceb = 1 /* Habilitado */
                                         NO-LOCK NO-ERROR.   

                    IF NOT AVAIL(crapceb) THEN
                         ASSIGN aux_dscritic = "Convenio nao Habilitado.". 
           END.

       END.
       
       /* 19.0 Sequencial Fixo "000001" */
       IF   SUBSTR(aux_setlinha,395,06) <> "000001" THEN DO:
           IF aux_dscritic = "" THEN
                ASSIGN aux_dscritic = "Sequencial do Registro Header 000001 Invalida.".
       END.  

       IF aux_dscritic <> "" THEN DO:

           /* Cria Rejeitado */
           CREATE crawrej.
           ASSIGN crawrej.cdcooper = par_cdcooper
                  crawrej.nrdconta = par_nrdconta
                  crawrej.nrdocmto = 0
                  crawrej.dscritic = aux_dscritic.

       END.


       /* Se retornou alguma critica, remove o arquivo */
       IF   ret_cdcritic <> 0 OR aux_dscritic <> ""  THEN
            DO:
                INPUT STREAM str_3 CLOSE.

                /* Apaga Arquivo */
                UNIX SILENT VALUE("rm " + crawaux.nmarquiv + " 2> /dev/null").
                
                RETURN "NOK".
            END.
             
       aux_contador = 0.

       /*   Detalhe   */
       DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

          ASSIGN aux_setlinha = "".

          IMPORT STREAM str_3 UNFORMATTED aux_setlinha. 


          IF  SUBSTR(aux_setlinha,01,01) = "1" OR 
              SUBSTR(aux_setlinha,01,01) = "7" THEN DO: /* Remessa */

                  IF SUBSTR(aux_setlinha,109,2) = "01" THEN
                        aux_qtdregis = aux_qtdregis + 1.
                  ELSE    
                        aux_qtdinstr = aux_qtdinstr + 1.  
                 
                                                                                 
                  /* Cria o ultimo boleto ou gera instrucao apenas se nao tiver erros */
                  IF  aux_flgfirst      AND 
                      ret_cdcritic = 0  AND 
                      glb_cdcritic = 0  AND
                      rej_cdmotivo = "" THEN DO:

                            CASE aux_cdocorre:

                                WHEN 01 THEN /* 01 - Solicitacao de Remessa */

                                    RUN p_grava_boleto.

                                OTHERWISE
                                    RUN p_grava_instrucao.

                            END CASE.
                  END.
        
                
                  ASSIGN aux_flgfirst = TRUE
                         glb_cdcritic = 0
                         rej_cdmotivo = ""
                         ret_cdcritic = 0
                         aux_dsnosnum = TRIM(SUBSTR(aux_setlinha,64,17))        /* Nosso Numero */
                         aux_dsnosnum = LEFT-TRIM(aux_dsnosnum,"0")
                         aux_cdcartei = 01                                      /* Carteira */
                         aux_dsdoccop = TRIM(SUBSTR(aux_setlinha,111,10))       /* Numero do Titulo */
                         aux_dsusoemp = SUBSTR(aux_setlinha,39,25)
                         aux_tpdjuros = 03 /*isento*/                                      /* Tipo de Juros - Fixo 01 - Valor por Dia */        
                         
                         aux_dsdinstr = ""
                         aux_inemiten = 2                                       /* Cooperado Emite e Expede */
                         /* tratar flag aceite enviada no arquivo.
                            motivo 23 - Aceite invalido, nao sera tratado
                            para nao impactar nos cooperados que ignoravam essa informacao*/                   
                         aux_flgaceit = (IF SUBSTR(aux_setlinha,150,01)  = "A" THEN 
                                           TRUE 
                                         ELSE
                                           FALSE)
                         aux_cdinstr1 = SUBSTR(aux_setlinha,157,02)
                         aux_cdinstr2 = SUBSTR(aux_setlinha,159,02)
                         aux_qtdiaprt = 0                                      /* Quantidade de dias Protesto */
                         aux_vlabatim = 0                                      /* Valor do Abatimento */
                         aux_vldescto = 0.                                     /* Valor do Desconto */

                  /* 21.7 Comandos */
                  IF rej_cdmotivo = "" THEN DO:
        
                      aux_cdocorre = INTE(SUBSTR(aux_setlinha,109,2)) NO-ERROR.
            
                      IF ERROR-STATUS:ERROR THEN
                              ASSIGN rej_cdmotivo = "05".   /* Codigo de Movimento Invalido */
                      ELSE DO:
                          IF NOT CAN-DO("1,2,4,5,6,9,10,12,31,32",STRING(aux_cdocorre)) THEN
                              ASSIGN rej_cdmotivo = "05".   /* Codigo de Movimento Invalido */ 
                          ELSE DO:
                              /* CNAB 400 -> CNAB 240 */
                              CASE aux_cdocorre:
                                  WHEN 31 THEN aux_cdocorre = 07. /* Concender desconto */
                                  WHEN 32 THEN aux_cdocorre = 08. /* Nao concender desconto */
                                  WHEN 12 THEN aux_cdocorre = 31. /* Alteracao de nome e endereco do sacado */
                              END CASE.
                          END.

                      END.
                  END.
                  
                  /* Validacao de Comandos de Intrucao */
                  IF rej_cdmotivo = "" THEN DO:
                      IF aux_cdocorre <> 1 THEN DO: /* Instrucao */

                          RUN valida-execucao-instrucao (  INPUT par_cdcooper,
                                                           INPUT aux_nrdconta,
                                                           INPUT aux_setlinha,
                                                           INPUT aux_cdocorre,
                                                           INPUT "400",
                                                          OUTPUT rej_cdmotivo).

                          IF rej_cdmotivo <> ""  THEN DO:
                               
                                /* Incluir Geracao Retorno Rejeitado */
                                RUN prep-retorno-cooperado-rejeitado 
                                                        (INPUT par_cdcooper,
                                                         INPUT par_nrdconta,
                                                         INPUT aux_nrcnvcob,
                                                         INPUT 26,              /* Instrucao */
                                                         INPUT rej_cdmotivo,
                                                         INPUT aux_dsnosnum,
                                                         INPUT aux_vltitulo,
                                                         INPUT crapcop.cdbcoctl,
                                                         INPUT crapcop.cdagectl,
                                                         INPUT par_dtmvtolt,
                                                         INPUT par_cdoperad,
                                                         INPUT aux_dsdoccop,
                                                         INPUT aux_nrremass,
                                                         INPUT aux_dtvencto,
                                                         INPUT aux_dtemscob).
    
                          END.

                          NEXT.

                      END.
                  END.


                  /* 02.7 Tipo de Inscricao do Cedente */
                  IF rej_cdmotivo = "" THEN DO:

                        aux_cdtocede = INT(SUBSTR(aux_setlinha,02,02)) NO-ERROR.

                        IF ERROR-STATUS:ERROR THEN
                            ASSIGN rej_cdmotivo = "06".    /* Tipo/Numero de Inscricao do Cedente Invalidos    */
                        ELSE DO:
                          IF  aux_cdtocede <> 01 AND 
                              aux_cdtocede <> 02 THEN
                                    ASSIGN rej_cdmotivo = "06".    /* Tipo/Numero de Inscricao do Cedente Invalidos    */
                        END.
                  END.
        
                  /* 03.7 Numero do CPF/CNPJ do Cedente */
                  IF rej_cdmotivo = "" THEN DO:
        
                      aux_cpfcnpj = DEC(SUBSTR(aux_setlinha,04,14)) NO-ERROR.
        
                      IF ERROR-STATUS:ERROR THEN
                            ASSIGN rej_cdmotivo = "06".    /* Tipo/Numero de Inscricao do Cedente Invalidos    */
                      ELSE DO:
            
                          FIND FIRST crapass WHERE 
                          crapass.cdcooper = par_cdcooper AND
                          crapass.nrcpfcgc = aux_cpfcnpj  AND
                          crapass.nrdconta = par_nrdconta
                          NO-LOCK NO-ERROR.
            
                          IF NOT AVAIL(crapass) THEN
                              ASSIGN rej_cdmotivo = "06".    /* Tipo/Numero de Inscricao do Cedente Invalidos    */
                          ELSE
                               IF crapass.inpessoa <> aux_cdtocede THEN
                                   ASSIGN rej_cdmotivo = "06".    /* Tipo/Numero de Inscricao do Cedente Invalidos    */

                      END.
                  END.
        
                  /* 04.7 a 05.7 Agencia/DV */
                  IF rej_cdmotivo = "" THEN DO:

                      IF STRING(crapcop.cdagectl,"9999") <> SUBSTR(aux_setlinha,18,04) THEN
                            ASSIGN rej_cdmotivo = "07". /* Agencia/Conta/DV Invalido */
            
                  END.
            
                  /* 06.7 a 07.7 Numero da Conta/DV */
                  IF rej_cdmotivo = "" THEN DO:

                        IF crapass.nrdconta <> INT(SUBSTR(aux_setlinha,23,09)) THEN
                            ASSIGN rej_cdmotivo = "07". /* Agencia/Conta/DV Invalido */

                  END.  
                  
                  /* 08.7 Numero do convenio de cobranca */
                  IF rej_cdmotivo = "" THEN DO:
                        
                      /* Convenio Lider */
                      IF aux_nrcnvcob <> INT(SUBSTR(aux_setlinha,32,07)) THEN
                            ASSIGN rej_cdmotivo = "96". /* Numero de Contrato Invalido */  

                  END.
        
                  DO WHILE LENGTH(aux_dsnosnum) < 17:
                     ASSIGN aux_dsnosnum = "0" + aux_dsnosnum.
                  END.
                               
                  /* Atribui Nosso Nunmero ao Numero da Conta e Bloqueto */
                  ASSIGN aux_nrbloque = DEC(SUBSTR(aux_dsnosnum,09,09))
                         aux_dsnosnum = STRING(aux_nrdconta, "99999999") + 
                                        STRING(aux_nrbloque, "999999999").

                  /* Verificacao para impedir cadastro de titulo sem numero */
                  IF aux_nrbloque = 0 THEN DO:
                      IF rej_cdmotivo = "" THEN
                        ASSIGN rej_cdmotivo = "08".   /* Nosso Numero Invalido  */
                  END.

        
                  /* 10.7 Nosso-Numero*/
                  IF par_nrdconta <> INT(SUBSTR(aux_dsnosnum,01,08)) THEN DO:
                        IF rej_cdmotivo = "" THEN
                            ASSIGN rej_cdmotivo = "08".   /* Nosso Numero Invalido  */
                  END.
        
                  IF aux_cdocorre = 01 THEN DO: /* Remessa */
        
                       IF TRIM(aux_dsnosnum) = "" THEN
                            IF rej_cdmotivo = "" THEN
                                ASSIGN rej_cdmotivo = "08".   /* Nosso Numero Invalido  */ 
                    
                       /* Verifica Duplicidade Nosso Numero */
                       FIND FIRST crapcob WHERE 
                                  crapcob.cdcooper = par_cdcooper AND
                                  crapcob.cdbandoc = aux_cdbandoc AND  
                                  crapcob.nrdctabb = aux_nrdctabb AND
                                  crapcob.nrcnvcob = aux_nrcnvcob AND
                                  crapcob.nrdconta = aux_nrdconta AND
                                  crapcob.nrdocmto = aux_nrbloque
                                   NO-LOCK NO-ERROR.
        
                       IF AVAIL(crapcob) THEN
                           /* Se o boleto possuir informacao de "LIQAPOSBX" e o cobranca
                             nao entrou o boleto deve adicionado para ser processado */
                           IF NOT (crapcob.dsinform MATCHES "LIQAPOSBX*" AND 
                                   crapcob.incobran = 0) THEN DO:
                                IF rej_cdmotivo = "" THEN
                                    ASSIGN rej_cdmotivo = "09".   /* Nosso Numero Duplicado */ 
                           END.
                  END.
                  
                  /* 20.7 Carteira */
                  IF rej_cdmotivo = "" THEN DO:
                      IF SUBSTR(aux_setlinha, 107,02) <> "01" THEN /*  Cobranca Simples */
                           rej_cdmotivo = "10".    /* Carteira Invalida */
                  END.
        
                  
                  /* 22.7 Seu numero */
                  IF rej_cdmotivo = "" THEN DO:
                      RUN valida_caracteres( INPUT TRUE,    /* Validar Numeros */
                                             INPUT TRUE,    /* Validar Letras  */
                                             INPUT ".,/,-,_", /* Lista Caracteres Validos */
                                             INPUT aux_dsdoccop,
                                             OUTPUT aux_flgerro).
            
                      IF aux_flgerro = TRUE THEN
                           rej_cdmotivo = "86".    /* Seu Numero Invalido */
                  END.
        
                  /* 23.7 Data de Vencimento */
                  IF ( aux_cdocorre = 01 OR aux_cdocorre = 06 ) /* 01 - Remessa   06 - Alteracao Vencimento*/
                      THEN DO: 
                      IF ( INT(SUBSTRING(aux_setlinha,121,2)) <> 0 ) THEN DO:
        
                              aux_dtvencto =
                                             DATE(INT(SUBSTRING(aux_setlinha,123,2)),
                                                  INT(SUBSTRING(aux_setlinha,121,2)),
                                                  INT("20" + SUBSTRING(aux_setlinha,125,2))) NO-ERROR.
        
                              IF ERROR-STATUS:ERROR THEN
                              DO:
                                  ASSIGN aux_dtvencto = ?
                                         rej_cdmotivo = "16".   /* Data de Vencimento Invalida */
                              END.
        
                              IF ( aux_dtvencto < TODAY ) OR ( aux_dtvencto > DATE("13/10/2049") )  THEN DO:
                                   
                                    IF rej_cdmotivo = "" THEN
                                        ASSIGN rej_cdmotivo = "18".   /* Vencimento Fora do Prazo de Operacao   */ 
                              END.

                         
                      END.
                      ELSE DO:

                            ASSIGN aux_dtvencto = ?.
                                   rej_cdmotivo = "16".    /* Data de Vencimento Invalida */ 
                      END.
                  END.
        
                  /* 24.7 Valor do Titulo */
                    aux_vltitulo = DEC(SUBSTR(aux_setlinha,127,13)) / 100 NO-ERROR.
    
                    IF ERROR-STATUS:ERROR THEN
                          IF aux_cdocorre = 01 THEN         /* 01 - Remessa */
                              ASSIGN rej_cdmotivo = "20".   /* Valor do Titulo Invalido */
        
                          
                  /* 25.7 Numero do Banco Fixo "085" */
                  IF rej_cdmotivo = "" THEN DO:
                      IF SUBSTR(aux_setlinha,140,03) <> "085" THEN
                          ASSIGN rej_cdmotivo = "01".   /* Numero do Banco Invalido */ 
                  END.
        
                  /* 28.7 Especie do Titulo */
                  IF rej_cdmotivo = "" THEN DO:
        
                      aux_cddespec = INT(SUBSTR(aux_setlinha,148,2)) NO-ERROR.

                      IF ERROR-STATUS:ERROR THEN
        
                           ASSIGN rej_cdmotivo = "21".   /* Tipo do Titulo Invalido */ 
                                          
                      ELSE DO:
                          /* Tratar Especie de Documento Febraban -> Cecred */  
                          CASE aux_cddespec:
                              WHEN 01 THEN aux_cddespec = 01. /* Duplicata Mercantil */
                              WHEN 02 THEN aux_cddespec = 03. /* Nota Promissoria */
                              WHEN 05 THEN aux_cddespec = 06. /* Recibo */
                              WHEN 12 THEN aux_cddespec = 02. /* Duplicata de Servico */
                              OTHERWISE 
                                  rej_cdmotivo = "21".  /* Tipo do Titulo Invalido */ 
                          END CASE.
        
                      END.
                  END.
        
                  /* 30.7 Data de Emissao */
                  IF INT(SUBSTRING(aux_setlinha,151,6)) <> 0 THEN
                      DO:
                          aux_dtemscob = DATE(INT(SUBSTRING(aux_setlinha,153,2)),
                                              INT(SUBSTRING(aux_setlinha,151,2)),
                                              INT("20" + SUBSTRING(aux_setlinha,155,2))) NO-ERROR.
                           
                           IF ERROR-STATUS:ERROR THEN 
                               IF rej_cdmotivo = "" THEN
                                    ASSIGN rej_cdmotivo = "24".   /* Data da Emissao Invalida */
                                    
                           IF aux_dtemscob > DATE("13/10/2049") OR 
                              (TODAY - 90) > aux_dtemscob THEN
                               IF rej_cdmotivo = "" THEN 
                                   ASSIGN rej_cdmotivo = "24". /*Data de documento superior ao limite 13/10/2049 ou
                                                               Data retroativa maior que 90 dias.*/

                           IF aux_dtvencto < aux_dtemscob THEN
                               IF rej_cdmotivo = "" THEN 
                                   ASSIGN rej_cdmotivo = "17". /*Data de vencimento anterior a data de emissao*/
                      END.
                  ELSE 
                      DO:
                          aux_dtemscob = ?.
                          IF rej_cdmotivo = "" THEN
                              ASSIGN rej_cdmotivo = "24".   /* Data da Emissao Invalida */
                      END.
        
        
                  /* 31.7 Instrucao Codificada 1 */
                  /* 32.7 Instrucao Codificada 2 */
                  IF rej_cdmotivo = "" THEN DO:
        
                      IF aux_cdocorre = 01 THEN DO: /* 01-Registro de titulos */
                          /* Validar apenas o codigo de instrução 01 - Douglas/Cechet */
                          IF ( aux_cdinstr1 <> "00" AND
                               aux_cdinstr1 <> "06" AND
                               aux_cdinstr1 <> "07" AND
                               aux_cdinstr1 <> "10" AND
                               aux_cdinstr1 <> "15" ) THEN 
                                    ASSIGN rej_cdmotivo = "37". /* Codigo para Protesto Invalido */


                          IF rej_cdmotivo = "" THEN DO:
                              /* Pessoa Fisica nao permitido protesto */
                              IF ( crapass.inpessoa = 1 AND aux_cdinstr1 <> "07" AND aux_cdinstr1 <> "00"  ) THEN
                                    ASSIGN rej_cdmotivo = "39". /* Pedido de protesto nao permitido para o titulo */
                          END.

                          IF rej_cdmotivo = "" THEN DO:
                              /* Adicionado validação no código de instrução 1 
                                 para gerar a flag de protesto e a quantidade de dias para protestar*/
                              /* Se o código for "00" ou "07" não gera protesto e a quantidade de dias é zero */
                              IF aux_cdinstr1 = "00" OR aux_cdinstr1 = "07" THEN
                                  ASSIGN aux_flgdprot = FALSE
                                         aux_qtdiaprt = 0.
                              
                              /* Se o código for "06" gera protesto e a quantidade de dias é calculada no item 48.7
                                 Nesse item são feitas validações para buscar a quantidade de dias nas posições 392 e 393
                                 sendo que esse valor deve ser entre 05 e 15 dias */
                              IF aux_cdinstr1 = "06" THEN
                                  ASSIGN aux_flgdprot = TRUE.
    
                              /* Se o código for "10" gera protesto e a quantidade de dias é dez */
                              IF aux_cdinstr1 = "10" THEN
                                  ASSIGN aux_flgdprot = TRUE
                                         aux_qtdiaprt = 10.
    
                              /* Se o código for "15" gera protesto e a quantidade de dias é quinze */
                              IF aux_cdinstr1 = "15" THEN
                                  ASSIGN aux_flgdprot = TRUE
                                         aux_qtdiaprt = 15.
                          END.
                      END.
        
                      IF aux_cdocorre = 02 THEN DO: /* 02 - Solicitacao de Baixa */
                          IF ( aux_cdinstr1 <> "44" AND     /* 44 - Baixar */
                               aux_cdinstr1 <> "44" ) THEN  /* 44 - Baixar */
                                  ASSIGN rej_cdmotivo = "42". /* Codigo para Baixa/Devolucao Invalido */
                      END.
        
                      IF aux_cdocorre = 09 THEN DO: /* 09 - Instrucao para Protestar */
                          IF ( aux_cdinstr1 <> "06" AND /* 06 a 30 - Protestar no XX dia corridos apos vencido */
                               aux_cdinstr1 <> "10" AND /* 10 - Protestar no 10º dia corrido apos vencido */
                               aux_cdinstr1 <> "15" AND /* 15 - Protestar no 15º dia corrido apos vencido */
                               aux_cdinstr2 <> "06" AND 
                               aux_cdinstr2 <> "10" AND 
                               aux_cdinstr2 <> "15"     
                               ) THEN 
                                  ASSIGN rej_cdmotivo = "37". /* Codigo para Protesto Invalido */
                      END.

                      /*
                      Observacoes: 
                        a)  Os  títulos  com  vencimento  “a  vista”  ou  “na  apresentacao”  e  com  instrucao  para  protesto 
                            03, 04, 05, 10, 15, 20, 25 e 30 dias apos o vencimento terao a data de protesto com 18, 19, 
                            20, 25, 30, 35, 40 45 dias respectivamente apos a data do seu registro; 
                        b)  Nao sao passíveis de Instrucao de Protesto: Notas de Debito, Recibos, Notas Promissorias, 
                            prêmios e notas de seguro; 
                        c)  Os campo 31.7 ou 32.7  - Primeira Instrucao Codificadas e Segunda Instrucao Codificada – 
                            Nao poderao conter “Codigos” conflitantes entre si. Exemplo: 05 – Protestar apos 05 dias e 
                            07 – Nao Protestar. Neste caso, sera valida apenas a primeira instrucao informada, ou seja, 
                            Protestar apos 5 dias; 
                        d)  As  instrucoes  codificadas  remetidas  com  o  mesmo  codigo  serao  canceladas  no 
                            processamento.
                      */

                      IF aux_cdinstr1 = "07" THEN /* 07 - Nao protestar */
                            ASSIGN aux_cdinstr2 = "00". /* 00 - Ausencia de instrucoes */
                      
                  END.
                  
                  /* 33.7 Juros de Mora por Dia de Atraso */
                  IF rej_cdmotivo = "" THEN DO:
        
                      aux_vldjuros = DEC(SUBSTR(aux_setlinha,161,13)) / 100 NO-ERROR. /* Valor de Juros Mora */
            
                      IF ERROR-STATUS:ERROR THEN
                          ASSIGN rej_cdmotivo = "27".   /* Valor/Taxa de Juros de Mora Invalido */ 
                      ELSE DO:
                        
                          IF aux_vldjuros > aux_vltitulo THEN
                                ASSIGN rej_cdmotivo = "27".   /* Valor/Taxa de Juros de Mora Invalido */
                      END.
                      IF rej_cdmotivo = "" AND aux_vldjuros > 0 THEN
                         ASSIGN aux_tpdjuros = 1. /* juros por dia */
                  END.
        
                  /* 35.7 Valor de Desconto */
                  IF rej_cdmotivo = "" THEN DO:
        
                      aux_vldescto = DEC(SUBSTR(aux_setlinha,180,13)) / 100 NO-ERROR. /* Valor de Desconto */
                      
                      IF ERROR-STATUS:ERROR THEN
                            ASSIGN rej_cdmotivo = "30".   /* Desconto a Conceder Nao Confere */
                      ELSE DO:  
                     
                          IF aux_vldescto >= aux_vltitulo THEN
                                ASSIGN rej_cdmotivo = "29".   /* Valor do Desconto Maior ou Igual ao Valor do Titulo  */
                      END.
                  END.
        
                  /* 37.7 Valor de Abatimento */
                  IF rej_cdmotivo = "" THEN DO:
        
                      aux_vlabatim = DEC(SUBSTR(aux_setlinha,206,13)) / 100 NO-ERROR. /* Valor de Abatimento */  
            
                      IF ERROR-STATUS:ERROR THEN
                            ASSIGN rej_cdmotivo = "33".   /* Valor do Abatimento Invalido     */
                      ELSE DO:
                          IF ( ( aux_vlabatim > 0 ) AND ( aux_vlabatim  >= aux_vltitulo ) ) THEN
                                    ASSIGN rej_cdmotivo = "34".    /* Valor do Abatimento Maior ou Igual ao Valor do Titulo */
                      END.
        
                  END.
                  
                  ASSIGN aux_nmdsacad = REPLACE(SUBSTR(aux_setlinha,235,37),"&","E")      /* Nome Sacado */ 
                         aux_dsendsac = SUBSTR(aux_setlinha,275,40)      /* Endereco Sacado */
                         aux_nmbaisac = SUBSTR(aux_setlinha,315,12)      /* Bairro Sacado */
                         aux_nmcidsac = SUBSTR(aux_setlinha,335,15)      /* Cidade */
                         aux_cdufsaca = SUBSTR(aux_setlinha,350,02).      /* UF Sacado */
                        
                  
                  /* 38.7 Tipo de inscricao do sacado */
                  IF rej_cdmotivo = "" THEN DO: 

                      aux_cdtpinsc = INT(SUBSTR(aux_setlinha,219,02)) NO-ERROR. /* Cod Tipo de Inscricao sacado  */  

                      IF ERROR-STATUS:ERROR THEN
                           ASSIGN rej_cdmotivo = "46".    /* Tipo/Numero de Inscricao do Sacado Invalidos    */
                      ELSE DO:
        
                          IF aux_cdtpinsc <> 0 AND      /* Vazio    */
                             aux_cdtpinsc <> 1 AND      /* Fisica   */
                             aux_cdtpinsc <> 2  THEN    /* Juridica */
                          
                                  ASSIGN rej_cdmotivo = "46".    /* Tipo/Numero de Inscricao do Sacado Invalidos    */
                      END.
                          
                  END.
        
                  /* 39.7 Numero CPF/CNPJ do Sacado */
                  IF rej_cdmotivo = "" THEN DO: 

                      aux_nrinssac = DEC(SUBSTR(aux_setlinha,221,14)) NO-ERROR.

                      IF ERROR-STATUS:ERROR THEN
                           ASSIGN rej_cdmotivo = "46".    /* Tipo/Numero de Inscricao do Sacado Invalidos    */
                      ELSE DO:  
        
                          IF aux_cdtpinsc <> 0 THEN DO:      /* Vazio */
                              RUN valida_cpf_cnpj(INPUT  aux_cdtpinsc,
                                                  INPUT  aux_nrinssac,
                                                  OUTPUT aux_flgerro).

                              IF aux_flgerro = TRUE THEN
                                   ASSIGN rej_cdmotivo = "46".    /* Tipo/Numero de Inscricao do Sacado Invalidos    */
                              
                          END.

                      END.
                  END.
        
                  /* 40.7 Nome do Sacado */
                  IF rej_cdmotivo = "" THEN DO: 
        
                    IF TRIM(aux_nmdsacad) = "" THEN
                        ASSIGN rej_cdmotivo = "45". /* Nome do Sacado Nao Informado */
        
        
                    RUN valida_caracteres( INPUT TRUE,      /* Validar Numeros */
                                           INPUT TRUE,      /* Validar Letras  */
                                           INPUT ".,/,-,_", /* Lista Caracteres Validos */
                                           INPUT aux_nmdsacad,
                                           OUTPUT aux_flgerro).
        
                    IF rej_cdmotivo = "" THEN
                        IF aux_flgerro = TRUE THEN
                            ASSIGN rej_cdmotivo = "45".    /* Nome do Sacado Nao Informado */
        
                  END.
        
                  /* 42.7 Endereco do Sacado */
                  IF rej_cdmotivo = "" THEN DO: 
        
                    IF TRIM(aux_dsendsac) = "" THEN
                        ASSIGN rej_cdmotivo = "47". /* Endereco do Sacado Nao Informado */
                    ELSE DO:
        
                        RUN valida_caracteres( INPUT TRUE,    /* Validar Numeros */
                                               INPUT TRUE,    /* Validar Letras  */
                                               INPUT ".,/,-,_", /* Lista Caracteres Validos */
                                               INPUT aux_dsendsac,
                                               OUTPUT aux_flgerro).
            
                        IF aux_flgerro = TRUE THEN
                            ASSIGN rej_cdmotivo = "47".    /* Endereco do Sacado Nao Informado */
                    END.
        
                  END.

                  /* 44.7 CEP do Sacado */
                  IF rej_cdmotivo = "" THEN DO:
        
                        aux_nrcepsac = INT(SUBSTR(aux_setlinha,327,8)) NO-ERROR.  /* Cep Sacado */

                        IF ERROR-STATUS:ERROR THEN
                            rej_cdmotivo = "48". /*  CEP Invalido */
                        ELSE DO:

                            IF TRIM(STRING(aux_nrcepsac)) = "" THEN
                                rej_cdmotivo = "48". /*  CEP Invalido */
                            ELSE DO: 
            
                              RUN valida_caracteres( INPUT TRUE,    /* Validar Numeros */
                                                     INPUT FALSE,   /* Validar Letras  */
                                                     INPUT "",      /* Lista Caracteres Validos */
                                                     INPUT STRING(aux_nrcepsac),
                                                     OUTPUT aux_flgerro).
            
                              IF aux_flgerro = TRUE THEN
                                    ASSIGN rej_cdmotivo = "48".    /*  CEP Invalido */  
            
                            END.

                        END.
        
                        IF rej_cdmotivo = "" THEN DO:

                            FIND FIRST crapdne WHERE crapdne.nrceplog = aux_nrcepsac AND
                                                     crapdne.idoricad = 1           /* Correios */
                                                     NO-LOCK NO-ERROR.
                            IF  NOT AVAIL(crapdne) THEN
                                DO:
                                    FIND FIRST crapdne WHERE crapdne.nrceplog = aux_nrcepsac AND
                                                             crapdne.idoricad = 2           /* Ayllos */
                                                             NO-LOCK NO-ERROR.
                                    IF  NOT AVAIL(crapdne) THEN
                                        ASSIGN rej_cdmotivo = "48".    /* CEP Invalido */
                                END.
                        END.
        
                  END.

                  /* 46.7 UF do Sacado */
                  IF rej_cdmotivo = "" THEN DO:
        
                      IF aux_cdufsaca <> crapdne.cduflogr THEN
                            ASSIGN rej_cdmotivo = "51".    /* CEP Incompativel com a Unidade da Federacao */
                  END.
        
        
                  /* 47.7 Mensagem ou Sacador/Avalista */
                  IF rej_cdmotivo = "" THEN DO:
                      IF  SUBSTR(aux_setlinha,88,01) = "A" THEN DO:

                         IF  SUBSTR(aux_setlinha,374,4) = "CNPJ" THEN DO:
                             ASSIGN aux_nmdavali = SUBSTR(aux_setlinha,352,20)
                                    aux_nrinsava = DEC(SUBSTR(aux_setlinha,378,14))
                                    aux_cdtpinav = 2.

                             IF aux_nrinsava > 0 AND TRIM(aux_nmdavali) = "" THEN
                                    ASSIGN rej_cdmotivo = "54". /* Nome do Sacado Nao Informado */
                             ELSE DO:
                                    RUN valida_cpf_cnpj(INPUT  2, /* CNPJ */
                                                        INPUT  aux_nrinsava,
                                                       OUTPUT  aux_flgerro).

                                    IF aux_flgerro = TRUE THEN
                                        ASSIGN rej_cdmotivo = "53".    /* Tipo/Numero de Inscricao do Sacado Invalidos    */
                             END.


                         END.
                         ELSE
                         IF  SUBSTR(aux_setlinha,378,3) = "CPF" THEN DO:
                             ASSIGN aux_nmdavali = SUBSTR(aux_setlinha,352,24)
                                    aux_nrinsava = DEC(SUBSTR(aux_setlinha,381,11))
                                    aux_cdtpinav = 1.

                             IF aux_nrinsava > 0 AND TRIM(aux_nmdavali) = "" THEN
                                    ASSIGN rej_cdmotivo = "54". /* Nome do Sacado Nao Informado */
                             ELSE DO:
                                    RUN valida_cpf_cnpj(INPUT  1, /* CPF */
                                                        INPUT  aux_nrinsava,
                                                       OUTPUT  aux_flgerro).

                                    IF aux_flgerro = TRUE THEN
                                        ASSIGN rej_cdmotivo = "53".    /* Tipo/Numero de Inscricao do Sacado Invalidos    */
                             END.

                         END.
                         ELSE
                             ASSIGN aux_nmdavali = ""
                                    aux_nrinsava = 0
                                    aux_cdtpinav = 0.
                      END.
                      ELSE DO:
                            IF  SUBSTR(aux_setlinha,88,01) = " " THEN
                                    ASSIGN aux_dsdinstr = SUBSTR(aux_setlinha,352,40)
                                           aux_nmdavali = ""
                                           aux_nrinsava = 0
                                           aux_cdtpinav = 0.
                            ELSE
                                ASSIGN aux_nmdavali = ""
                                    aux_nrinsava = 0
                                    aux_cdtpinav = 0.
                      END.
                  END.

                  /* 48.7 Numero de dias para protesto */
                  /* Caso o campo “Comando” tenha sido preenchido com “01-Registro de titulos” e o campo 
                     “instrucao codificada” tenha sido preenchido com “06”, informar o numero de dias 
                     corridos para protesto: de 06 a 29, 35 ou 40 dias 
                     Nosso sistema trabalha apenas com prazo de 5 a 15 dias. */
                  IF rej_cdmotivo = "" THEN DO:
        
                      IF SUBSTR(aux_setlinha,109,02) = "01" THEN /* 01-Registro de titulos */
                          IF aux_cdinstr1 = "06" OR aux_cdinstr2 = "06" THEN DO:  /* 06-Indica Protesto em dias corridos */
                                
                                aux_qtdiaprt = INT(SUBSTR(aux_setlinha,392,02)) NO-ERROR.
        
                                 IF ERROR-STATUS:ERROR THEN
                                        ASSIGN rej_cdmotivo = "38".   /* Prazo para Protesto Invalido */
                                 ELSE DO:  
                                      IF ( aux_qtdiaprt < 5  OR
                                           aux_qtdiaprt > 15 ) THEN
                                            ASSIGN rej_cdmotivo = "38".   /* Prazo para Protesto Invalido  */
                                 END.
        
                          END.
                  END.

                  IF rej_cdmotivo = "" THEN /* Nao possui erro de Validacao */
                     DO:
                         IF aux_cdocorre = 01 THEN /* 01 - Registro de Titulo */
                            RUN p_grava_sacado.
                     END.
                  ELSE DO:

                      IF aux_cdocorre = 01 THEN
                          rej_cdocorre = 03.
                      ELSE
                          rej_cdocorre = 26.

                      /* Gera Registro de Rejeicao */
                      RUN prep-retorno-cooperado-rejeitado 
                                    (INPUT par_cdcooper,
                                     INPUT par_nrdconta,
                                     INPUT aux_nrcnvcob,
                                     INPUT rej_cdocorre,
                                     INPUT rej_cdmotivo,
                                     INPUT aux_dsnosnum,
                                     INPUT aux_vltitulo,
                                     INPUT crapcop.cdbcoctl,
                                     INPUT crapcop.cdagectl,
                                     INPUT par_dtmvtolt,
                                     INPUT par_cdoperad,
                                     INPUT aux_dsdoccop,
                                     INPUT aux_nrremass,
                                     INPUT aux_dtvencto,
                                     INPUT aux_dtemscob).
                  END.

          END.
          ELSE
              IF SUBSTR(aux_setlinha,01,01) = "5" AND rej_cdmotivo = "" THEN DO: /* Multa */

                  /* Nao executar em caso de Instrucao */
                  IF aux_cdocorre <> 01 THEN
                      NEXT.
                  
                  /* Tipo de Serviço "99" (Multa) e "01" (Envio de Boleto por e-mail) */
                  IF SUBSTR(aux_setlinha,02,02) <> "99" AND SUBSTR(aux_setlinha,02,02) <> "01" THEN DO:
                        ASSIGN rej_cdmotivo = "02".   /* Tipo de servico invalido  */          
                  END. 

                  /* 02.5 Tipo de serviço "01" */
                  IF SUBSTR(aux_setlinha,02,02) = "01" THEN DO:
                      /* Tipo de Serviço: "01" Envio de Boleto por e-mail */

                      /* 03.5 E-mail do Sacado */
                      IF rej_cdmotivo = "" THEN DO:
                          /* E-mail 004 a 139  */
                          ASSIGN aux_dsdemail = SUBSTRING(aux_setlinha,04,136).

                          RUN p_altera_email_cel_sacado(INPUT aux_cdcooper
                                                       ,INPUT aux_nrdconta
                                                       ,INPUT aux_nrinssac
                                                       ,INPUT aux_dsdemail
                                                       ,INPUT 0).
                          
                          /* Apos atualizar a informacao, limpa os campos*/
                          ASSIGN aux_dsdemail = "".
                      END.

                  END. /* 02.5 Tipo de serviço "01" - FIM*/
                  
                  /* 02.5 Tipo de servico "99" */
                  ELSE IF SUBSTR(aux_setlinha,02,02) = "99" THEN DO:
                  
                      /* 03.5 Codigo de Multa */
                      IF rej_cdmotivo = "" THEN DO:

                          aux_tpdmulta = INT(SUBSTRING(aux_setlinha,04,1)) NO-ERROR.

                          IF ERROR-STATUS:ERROR THEN
                              ASSIGN rej_cdmotivo = "57". /* Codigo da Multa Invalido   */
                          ELSE DO:

                              IF aux_tpdmulta <> 1 AND         /* 1-Valor      */
                                 aux_tpdmulta <> 2 AND         /* 2-Percentual */  
                                 aux_tpdmulta <> 9 THEN        /* 9-Isento     */

                                    ASSIGN rej_cdmotivo = "57".   /* Codigo da Multa Invalido   */
                          END.
                      END.

                      /* 04.5 Data de inicio da cobranca de multa */
                      IF rej_cdmotivo = "" THEN DO:

                          aux_dtamulta = DATE(INT(aux_dtamulta),
                                              INT(SUBSTRING(aux_setlinha,05,2)),
                                              INT("20" + SUBSTRING(aux_setlinha,09,2))) NO-ERROR.

                          IF ERROR-STATUS:ERROR THEN
                              ASSIGN rej_cdmotivo = "58".

                      END.

                      /* 05.5 Valor/Percentual da Multa */
                      IF rej_cdmotivo = "" THEN DO:

                          aux_vldmulta = DEC(SUBSTRING(aux_setlinha,11,12)) / 100 NO-ERROR.

                          IF ERROR-STATUS:ERROR THEN
                              ASSIGN rej_cdmotivo = "59".    /* Valor/Percentual da Multa Invalido  */

                          CASE aux_tpdmulta:
                              WHEN 1 THEN /* 1-Valor      */
                                  DO:
                                      IF aux_vldmulta > aux_vltitulo THEN
                                          ASSIGN rej_cdmotivo = "59".    /* Valor/Percentual da Multa Invalido  */
                                  END.
                              WHEN 2 THEN /* 2-Percentual */ 
                                  DO:
                                      IF aux_vldmulta > 100 THEN
                                          ASSIGN rej_cdmotivo = "59".    /* Valor/Percentual da Multa Invalido  */
                                  END.
                              WHEN 9 THEN /* 9-Isento     */
                                  DO:
                                      /* Se Isento Desprezar Valor */
                                      /* IF aux_tpdjuros = 3 THEN */
                                          aux_vldmulta = 0.
                                  END.
                          END CASE. 

                          /* se nao possui valor de multa, 
                             definir como isento */
                          IF aux_vldmulta = 0 THEN
                               ASSIGN aux_tpdmulta  = 9.

                      END. 

                      /* Gera Retorno erro para Cooperado */
                      IF rej_cdmotivo <> "" THEN DO:

                          IF aux_cdocorre = 01 THEN
                              rej_cdocorre = 03. /* Entrada Rejeitada */
                          ELSE
                              rej_cdocorre = 26. /* Instrucao Rejeitada */

                          RUN prep-retorno-cooperado-rejeitado 
                                        (INPUT par_cdcooper,
                                         INPUT par_nrdconta,
                                         INPUT aux_nrcnvcob,
                                         INPUT rej_cdocorre,
                                         INPUT rej_cdmotivo,
                                         INPUT aux_dsnosnum,
                                         INPUT aux_vltitulo,
                                         INPUT crapcop.cdbcoctl,
                                         INPUT crapcop.cdagectl,
                                         INPUT par_dtmvtolt,
                                         INPUT par_cdoperad,
                                         INPUT aux_dsdoccop,
                                         INPUT aux_nrremass,
                                         INPUT aux_dtvencto,
                                         INPUT aux_dtemscob).
                      END.
                  END. /* 02.5 Tipo de servico "99" - FIM */

              END. /* Final Tipo 5 - Multa */

   
       END.  /*    Fim do While True   */


       /* Cria o ultimo boleto apenas se nao tiver erros */
       IF  aux_flgfirst     AND 
           ret_cdcritic = 0 AND 
           glb_cdcritic = 0 AND 
           rej_cdmotivo = "" THEN
           DO:
                CASE aux_cdocorre:

                    WHEN 01 THEN /* 01 - Solicitacao de Remessa */
                        DO:
                            RUN p_grava_boleto.
                        END.                         

                    OTHERWISE 
                        
                        RUN p_grava_instrucao.

                END CASE.
           END.
           
       INPUT STREAM str_3 CLOSE.

       ASSIGN aux_qtbloque = aux_qtdregis + aux_qtdinstr.

       IF  aux_qtbloque > 0 THEN
           DO:        
              RUN pi_protocolo_transacao( INPUT par_cdcooper,
                                          INPUT par_nrdconta,
                                         OUTPUT ret_nrprotoc,
                                         OUTPUT ret_hrtransa,
                                         OUTPUT aux_dscritic).

              IF  RETURN-VALUE <> "OK" THEN
              DO:
                  /* Cria Rejeitado */
                  CREATE crawrej.
                  ASSIGN crawrej.cdcooper = par_cdcooper
                         crawrej.nrdconta = par_nrdconta
                         crawrej.nrdocmto = aux_nrbloque
                         crawrej.dscritic = aux_dscritic +
                                 "- Remessa: " + STRING(aux_nrremass).
                  NEXT.
              END.

              /* Cria Lote de Remessa do Cooperado */
              RUN pi_grava_rtc( INPUT par_cdcooper,
                                INPUT par_nrdconta,
                                INPUT crapcco.nrconven,
                                INPUT aux_nrremass ).  

              IF  RETURN-VALUE = "NOK" THEN
                  NEXT.

           END.

       IF  AVAIL craprtc THEN
           DO:
               ASSIGN craprtc.flgproce = YES
                      craprtc.qtreglot = aux_qtbloque
                      craprtc.qttitcsi = aux_qtbloque
                      craprtc.vltitcsi = aux_vlrtotal
                      craprtc.dsprotoc = ret_nrprotoc.
    
               IF TEMP-TABLE crawrej:HAS-RECORDS THEN
               DO:
                   ret_cdcritic = 999. /* Rotina nao disponivel */
                   RUN fontes/critic.p.
        
                   /* Cria Rejeitado */
                   CREATE crawrej.
                   ASSIGN crawrej.cdcooper = par_cdcooper
                          crawrej.nrdconta = par_nrdconta
                          crawrej.nrdocmto = 999999
                          crawrej.dscritic = "Arquivo processado parcialmente!".
               END.
           END.
       ELSE 
           DO:
               ret_cdcritic = 999. /* Rotina nao disponivel */
               RUN fontes/critic.p.
    
               /* Cria Rejeitado */
               CREATE crawrej.
               ASSIGN crawrej.cdcooper = par_cdcooper
                      crawrej.nrdconta = par_nrdconta
                      crawrej.nrdocmto = 999999
                      crawrej.dscritic = "Nenhum boleto foi processado!".
               NEXT.
           END.
   END.  /*   Fim do for each crawaux */

   /* Apos a importacao, processar temp-table dos titulos */
   RUN p_processa_titulos.

   /* Apos a importacao, processar temp-table das instrucoes */
   RUN p_processa_instrucoes.

   /* Efetua lancamento Tarifas */
   RUN efetua-lancamento-tarifas-lat (INPUT par_cdcooper,
                                      INPUT par_dtmvtolt,
                                      INPUT-OUTPUT TABLE tt-lat-consolidada ).
   
   RETURN "OK".
  
END PROCEDURE. /* FIM - p_integra_arq_remessa_cnab400_085 */

PROCEDURE p_calc_codigo_barras:

    DEF OUTPUT PARAM par_cod_barras     AS CHAR                          NO-UNDO. 

    DEF VAR aux                         AS CHAR                          NO-UNDO.
    DEF VAR dtini                       AS DATE INIT "10/07/1997"        NO-UNDO.

    DEF VAR aux_ftvencto                AS INTE                          NO-UNDO.

    IF crapcob.dtvencto >= DATE("22/02/2025") THEN
           aux_ftvencto = (crapcob.dtvencto - DATE("22/02/2025")) + 1000.
        ELSE
           aux_ftvencto = (crapcob.dtvencto - dtini).

    ASSIGN aux = STRING(crapcob.cdbandoc,"999")
                           + "9" /* moeda */
                           + "1" /* nao alterar - constante */
                           + STRING(aux_ftvencto, "9999")
                           + STRING(crapcob.vltitulo * 100, "9999999999")
                           + STRING(crapcob.nrcnvcob, "999999")
                           + STRING(crapcob.nrnosnum, "99999999999999999")
                           + STRING(crapcob.cdcartei, "99")
               glb_nrcalcul = DECI(aux).

    RUN sistema/ayllos/fontes/digcbtit.p.
        ASSIGN par_cod_barras = string(glb_nrcalcul, 
           "99999999999999999999999999999999999999999999").
        
END PROCEDURE.

PROCEDURE p_processa_titulos:

    RUN sistema/generico/procedures/b1wgen0089.p
        PERSISTENT SET h-b1wgen0089.

    IF  NOT VALID-HANDLE(h-b1wgen0089) THEN
        DO:
            ASSIGN glb_dscritic = "Handle invalido para BO b1wgen0089.".

            CREATE crawrej.
            ASSIGN crawrej.cdcooper = crapcob.cdcooper
                   crawrej.nrdconta = crapcob.nrdconta
                   crawrej.nrdocmto = 0
                   crawrej.dscritic = glb_dscritic.

            RETURN "NOK".
        END.
    
    DO TRANSACTION:

        FOR EACH cratcob NO-LOCK:
            
            FIND crapcob WHERE 
                 crapcob.cdcooper = cratcob.cdcooper AND
                 crapcob.cdbandoc = cratcob.cdbandoc AND
                 crapcob.nrdctabb = cratcob.nrdctabb AND 
                 crapcob.nrdconta = cratcob.nrdconta AND
                 crapcob.nrcnvcob = cratcob.nrcnvcob AND
                 crapcob.nrdocmto = cratcob.nrdocmto 
                 NO-LOCK NO-ERROR.

            IF  AVAIL crapcob THEN
                DO:
                    /* validar se o boleto possui "LIQAPOSBX" e se 
                       incobran ainda nao foi processado */
                    IF crapcob.dsinform MATCHES "LIQAPOSBX*" AND 
                       crapcob.incobran = 0 THEN
                        DO:
                            /* Pega o boleto atual e exclui para que seja
                               criado novamente com as informacoes atualizadas */
                            FIND CURRENT crapcob EXCLUSIVE-LOCK.
                            DELETE crapcob.
                        END.
                    ELSE 
                        DO:
                            RUN prep-retorno-cooperado 
                                (INPUT ROWID(crapcob),
                                 INPUT 3,    /* Entrada Rejeitada */
                                 INPUT "63", /* Entrada para Titulo ja Cadastrado */
                                 INPUT 0,
                                 INPUT crapcop.cdbcoctl,
                                 INPUT crapcop.cdagectl,
                                 INPUT aux_dtmvtolt,
                                 INPUT aux_cdoperad,
                                 INPUT aux_nrremass).
                            
                            NEXT.
                        END.
                END.
        
            CREATE crapcob.
            BUFFER-COPY cratcob TO crapcob
                 ASSIGN crapcob.idopeleg = 0
                        crapcob.idtitleg = 0
                        crapcob.flgcbdda = FALSE
                        /* insitpro = 1 -> verificar sacado DDA (crps618) */
                        crapcob.insitpro = (IF crapcob.flgregis THEN 1 ELSE 0).
                VALIDATE crapcob.
            
                    IF  crapcob.flgregis THEN
                        DO: 
                            RUN cria-log-cobranca IN h-b1wgen0089
                                (INPUT ROWID(crapcob),
                                 INPUT aux_cdoperad,
                                 INPUT aux_dtmvtolt,
                                 INPUT "Titulo integrado por arquivo - " + 
                                       TRIM(STRING(aux_nrremass,"zzzzz9")) + 
                                       " - Emissao " + STRING(crapcob.dtdocmto,"99/99/99")).

                            /* Caso o tip de emissao seja cooperativa emite e expede
                               deve gerar log para a tela cobran*/
                            IF crapcob.cdbandoc = 085 AND
                               crapcob.inemiten = 3   THEN
                            DO:
                              RUN cria-log-cobranca IN h-b1wgen0089
                                (INPUT ROWID(crapcob),
                                 INPUT aux_cdoperad,
                                 INPUT aux_dtmvtolt,
                                 INPUT "Titulo a enviar para PG").
                            END.

                            /* se o sacado nao for DDA, confirmar registro do titulo, 
                               pois quando o sacado eh DDA, a confirmacao eh realizada
                               pelo programa crps618.p */
                            IF  crapcob.cdbandoc = 085 AND 
                                crapcob.inemiten = 2 THEN
                                DO:
                                    /* se sacado nao-DDA, registrar ent confirmada */
                                        RUN prep-retorno-cooperado 
                                            (INPUT ROWID(crapcob),
                                             INPUT 2, /* Entrada Confirmada */
                                             INPUT "",
                                             INPUT 0,
                                             INPUT crapcop.cdbcoctl,
                                             INPUT crapcop.cdagectl,
                                             INPUT aux_dtmvtolt,
                                             INPUT aux_cdoperad,
                                             INPUT aux_nrremass).

                                        /* Cria registro para cobranca tarifa. */
                                        CREATE tt-lat-consolidada.
                                        ASSIGN tt-lat-consolidada.cdcooper = crapcob.cdcooper
                                               tt-lat-consolidada.nrdconta = crapcob.nrdconta
                                               tt-lat-consolidada.nrdocmto = crapcob.nrdocmto
                                               tt-lat-consolidada.nrcnvcob = crapcob.nrcnvcob
                                               tt-lat-consolidada.dsincide = "RET"
                                               tt-lat-consolidada.cdocorre = 02    /* 02 - Entrada Confirmada */
                                               tt-lat-consolidada.cdmotivo = ""
                                               tt-lat-consolidada.vllanmto = crapcob.vltitulo.

                                END.
        
                        END. /* fim - if crapcob.flgregis */
                
        END. /* fim - for each cratcob */

    END. /* fim - transaction */
    
    IF  VALID-HANDLE(h-b1wgen0087) THEN
        DELETE PROCEDURE h-b1wgen0087.

    IF  VALID-HANDLE(h-b1wgen0089) THEN
        DELETE PROCEDURE h-b1wgen0089.

    RETURN "OK".

END PROCEDURE. /* fim p_processa_titulos */

PROCEDURE p_grava_instrucao:

    CREATE tt-instr.
    ASSIGN tt-instr.cdcooper = crapcop.cdcooper
           tt-instr.nrdconta = aux_nrdconta
           tt-instr.nrcnvcob = aux_nrcnvcob
           tt-instr.nrdocmto = aux_nrbloque
           tt-instr.nrremass = aux_nrremass
           tt-instr.cdocorre = aux_cdocorre
           tt-instr.vldescto = aux_vldescto
           tt-instr.vlabatim = aux_vlabatim
           tt-instr.dtvencto = aux_dtvencto
           tt-instr.nrnosnum = aux_dsnosnum

           tt-instr.nrinssac = aux_nrinssac
           tt-instr.dsendsac = aux_dsendsac
           tt-instr.nmbaisac = aux_nmbaisac
           tt-instr.nrcepsac = aux_nrcepsac
           tt-instr.nmcidsac = aux_nmcidsac
           tt-instr.cdufsaca = aux_cdufsaca

           tt-instr.cdbandoc = aux_cdbandoc  
           tt-instr.nrdctabb = aux_nrdctabb

           tt-instr.qtdiaprt = aux_qtdiaprt
           tt-instr.dsdoccop = aux_dsdoccop
        
           tt-instr.inemiten = aux_inemiten
           tt-instr.dtemscob = aux_dtemscob.

    RETURN "OK".

END PROCEDURE.

PROCEDURE p_processa_instrucoes:

    DEF VAR h-b1wgen0088 AS HANDLE                                    NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                      NO-UNDO.
    DEF VAR aux_cdcritic AS INT                                       NO-UNDO.  

    DEF BUFFER b-crapcob FOR crapcob.

    RUN sistema/generico/procedures/b1wgen0088.p 
        PERSISTENT SET h-b1wgen0088.

    IF  NOT VALID-HANDLE(h-b1wgen0088) THEN
        RETURN "NOK".

    RUN sistema/generico/procedures/b1wgen0089.p
        PERSISTENT SET h-b1wgen0089.

    IF  NOT VALID-HANDLE(h-b1wgen0089) THEN
        RETURN "NOK".

    FOR EACH tt-instr NO-LOCK:

        FIND crapcob WHERE
             crapcob.cdcooper = tt-instr.cdcooper AND
             crapcob.cdbandoc = tt-instr.cdbandoc AND
             crapcob.nrdctabb = tt-instr.nrdctabb AND
             crapcob.nrdconta = tt-instr.nrdconta AND
             crapcob.nrcnvcob = tt-instr.nrcnvcob AND
             crapcob.nrdocmto = tt-instr.nrdocmto 
             NO-LOCK NO-ERROR.

        IF  NOT AVAIL crapcob THEN
            DO:
                RUN prep-retorno-cooperado-rejeitado 
                    (INPUT tt-instr.cdcooper,
                     INPUT tt-instr.nrdconta,
                     INPUT tt-instr.nrcnvcob,
                     INPUT 26,   /* Instrucao Rejeitada */
                     INPUT "60", /* Movimento para Titulo Nao Cadastrado */
                     INPUT tt-instr.nrnosnum,
                     INPUT 0,    /* vltitulo */
                     INPUT crapcop.cdbcoctl,
                     INPUT crapcop.cdagectl,
                     INPUT aux_dtmvtolt,
                     INPUT aux_cdoperad,
                     INPUT tt-instr.dsdoccop,
                     INPUT aux_nrremass,
                     INPUT tt-instr.dtvencto,
                     INPUT tt-instr.dtemscob).
    
                NEXT.
            END.

        IF crapcob.incobran = 5 /* liquidado */ THEN
            DO:
                RUN prep-retorno-cooperado 
                    (INPUT ROWID(crapcob),
                     INPUT 26, /* Instrucao Rejeitada */
                     INPUT "",
                     INPUT 0,
                     INPUT crapcop.cdbcoctl,
                     INPUT crapcop.cdagectl,
                     INPUT aux_dtmvtolt,
                     INPUT aux_cdoperad,
                     INPUT aux_nrremass).

                NEXT.
            END.   

        IF tt-instr.cdocorre <> 02 AND /* Baixar                     */
           tt-instr.cdocorre <> 10 AND /* Sustar Protesto e Baixar   */
           tt-instr.cdocorre <> 11 AND /* Sustar Protesto e Carteira */
           crapcob.incobran = 3    AND /* Baixado                    */
           TRIM(crapcob.cdtitprt) = ""  THEN DO:

           RUN prep-retorno-cooperado 
                    (INPUT ROWID(crapcob),
                     INPUT 26, /* Instrucao Rejeitada */
                     INPUT "",
                     INPUT 0,
                     INPUT crapcop.cdbcoctl,
                     INPUT crapcop.cdagectl,
                     INPUT aux_dtmvtolt,
                     INPUT aux_cdoperad,
                     INPUT aux_nrremass).

                NEXT. 

        END.

        RUN cria-log-cobranca IN h-b1wgen0089
            (INPUT ROWID(crapcob),
             INPUT aux_cdoperad,
             INPUT aux_dtmvtolt,
             INPUT "Instrucao " + STRING(tt-instr.cdocorre) + 
                   " integrada por arquivo - " + 
                   TRIM(STRING(aux_nrremass,"zzzzz9"))).

        CASE tt-instr.cdocorre:

            /* 02 = Instrucoes de Baixa */
            WHEN 02 THEN
                DO:

                    /* Tratamento para solicitar baixa boleto BB vinculado ao boleto 085*/
                    IF  crapcob.incobran = 3 AND 
                        TRIM(crapcob.cdtitprt) <> "" THEN DO:

                        RELEASE b-crapcob.

                        FIND FIRST crapcco 
                             WHERE crapcco.cdcooper = INT(ENTRY(1,crapcob.cdtitprt, ";"))
                               AND crapcco.nrconven = INT(ENTRY(3,crapcob.cdtitprt, ";"))
                               NO-LOCK NO-ERROR.

                        IF  AVAIL crapcco THEN DO:

                            FIND FIRST b-crapcob 
                                     WHERE b-crapcob.cdcooper = INT(ENTRY(1,crapcob.cdtitprt, ";"))
                                   AND b-crapcob.cdbandoc = crapcco.cddbanco
                                   AND b-crapcob.nrdctabb = crapcco.nrdctabb
                                       AND b-crapcob.nrdconta = INT(ENTRY(2,crapcob.cdtitprt, ";"))
                                       AND b-crapcob.nrcnvcob = INT(ENTRY(3,crapcob.cdtitprt, ";"))
                                       AND b-crapcob.nrdocmto = INT(ENTRY(4,crapcob.cdtitprt, ";"))
                                       NO-LOCK NO-ERROR.

                        END.

                        IF  AVAIL b-crapcob THEN DO:
                            RUN inst-pedido-baixa IN h-b1wgen0088
                                (INPUT b-crapcob.cdcooper,
                                 INPUT b-crapcob.nrdconta,
                                 INPUT b-crapcob.nrcnvcob,
                                 INPUT b-crapcob.nrdocmto,
                                 INPUT tt-instr.cdocorre,
                                 INPUT aux_dtmvtolt,
                                 INPUT aux_cdoperad,
                                 INPUT aux_nrremass,
                                OUTPUT aux_dscritic,
                                INPUT-OUTPUT TABLE tt-lat-consolidada ).
                        END.

                    END.
                    ELSE 

                        RUN inst-pedido-baixa IN h-b1wgen0088
                            (INPUT tt-instr.cdcooper,
                             INPUT tt-instr.nrdconta,
                             INPUT tt-instr.nrcnvcob,
                             INPUT tt-instr.nrdocmto,
                             INPUT tt-instr.cdocorre,
                             INPUT aux_dtmvtolt,
                             INPUT aux_cdoperad,
                             INPUT aux_nrremass,
                            OUTPUT aux_dscritic,
                            INPUT-OUTPUT TABLE tt-lat-consolidada ).
    
                END.

            /* 04 = Concessao de Abatimento */
            WHEN 04 THEN
                DO:
                    RUN inst-conc-abatimento IN h-b1wgen0088
                        (INPUT tt-instr.cdcooper,
                         INPUT tt-instr.nrdconta,
                         INPUT tt-instr.nrcnvcob,
                         INPUT tt-instr.nrdocmto,
                         INPUT tt-instr.cdocorre,
                         INPUT aux_dtmvtolt,
                         INPUT aux_cdoperad,
                         INPUT tt-instr.vlabatim,
                         INPUT aux_nrremass,
                        OUTPUT aux_dscritic,
                        INPUT-OUTPUT TABLE tt-lat-consolidada ).
    
                END.

            /* 05 = Cancelamento de Abatimento */
            WHEN 05 THEN
                DO:
                    RUN inst-canc-abatimento IN h-b1wgen0088
                        (INPUT tt-instr.cdcooper,
                         INPUT tt-instr.nrdconta,
                         INPUT tt-instr.nrcnvcob,
                         INPUT tt-instr.nrdocmto,
                         INPUT tt-instr.cdocorre,
                         INPUT aux_dtmvtolt,
                         INPUT aux_cdoperad,
                         INPUT aux_nrremass,
                        OUTPUT aux_dscritic,
                        INPUT-OUTPUT TABLE tt-lat-consolidada ).
    
                END.

            /* 06 = Alteracao de Vencimento */
            WHEN 06 THEN
                DO:
                    RUN inst-alt-vencto IN h-b1wgen0088
                        (INPUT tt-instr.cdcooper,
                         INPUT tt-instr.nrdconta,
                         INPUT tt-instr.nrcnvcob,
                         INPUT tt-instr.nrdocmto,
                         INPUT tt-instr.cdocorre,
                         INPUT aux_dtmvtolt,
                         INPUT aux_cdoperad,
                         INPUT tt-instr.dtvencto,
                         INPUT aux_nrremass,
                        OUTPUT aux_dscritic,
                        INPUT-OUTPUT TABLE tt-lat-consolidada ).
    
                END.

            /* 07 = Concessao de Desconto */
            WHEN 07 THEN
                DO:
                    RUN inst-conc-desconto IN h-b1wgen0088
                        (INPUT tt-instr.cdcooper,
                         INPUT tt-instr.nrdconta,
                         INPUT tt-instr.nrcnvcob,
                         INPUT tt-instr.nrdocmto,
                         INPUT tt-instr.cdocorre,
                         INPUT aux_dtmvtolt,
                         INPUT aux_cdoperad,
                         INPUT tt-instr.vldescto,
                         INPUT aux_nrremass,
                        OUTPUT aux_dscritic,
                        INPUT-OUTPUT TABLE tt-lat-consolidada ).
    
                END.

            /* 08 = Cancelamento de Desconto */
            WHEN 08 THEN
                DO:
                    RUN inst-canc-desconto IN h-b1wgen0088
                        (INPUT tt-instr.cdcooper,
                         INPUT tt-instr.nrdconta,
                         INPUT tt-instr.nrcnvcob,
                         INPUT tt-instr.nrdocmto,
                         INPUT tt-instr.cdocorre,
                         INPUT aux_dtmvtolt,
                         INPUT aux_cdoperad,
                         INPUT aux_nrremass,
                        OUTPUT aux_dscritic,
                        INPUT-OUTPUT TABLE tt-lat-consolidada ).
    
                END.

            /* 09 = Protestar */
            WHEN 09 THEN
                DO:
                    RUN inst-protestar-arq-rem-085 IN h-b1wgen0088
                        (INPUT tt-instr.cdcooper,
                         INPUT tt-instr.nrdconta,
                         INPUT tt-instr.nrcnvcob,
                         INPUT tt-instr.nrdocmto,
                         INPUT tt-instr.cdocorre,
                         INPUT tt-instr.qtdiaprt,
                         INPUT aux_dtmvtolt,
                         INPUT aux_cdoperad,
                         INPUT aux_nrremass,
                        OUTPUT aux_dscritic,
                        INPUT-OUTPUT TABLE tt-lat-consolidada ).
    
                END.

            /* 10 = Sustar Protesto e Baixar */
            WHEN 10 THEN
                DO:

                    /* Tratamento para Sustar Protesto e Baixar boleto BB vinculado ao boleto 085*/
                    IF crapcob.incobran = 3 AND 
                       TRIM(crapcob.cdtitprt) <> "" THEN DO:

                        RELEASE b-crapcob.

                        FIND FIRST crapcco 
                             WHERE crapcco.cdcooper = INT(ENTRY(1,crapcob.cdtitprt, ";"))
                               AND crapcco.nrconven = INT(ENTRY(3,crapcob.cdtitprt, ";"))
                               NO-LOCK NO-ERROR.

                        IF  AVAIL crapcco THEN DO:

                            FIND FIRST b-crapcob 
                                     WHERE b-crapcob.cdcooper = INT(ENTRY(1,crapcob.cdtitprt, ";"))
                                   AND b-crapcob.cdbandoc = crapcco.cddbanco
                                   AND b-crapcob.nrdctabb = crapcco.nrdctabb
                                       AND b-crapcob.nrdconta = INT(ENTRY(2,crapcob.cdtitprt, ";"))
                                       AND b-crapcob.nrcnvcob = INT(ENTRY(3,crapcob.cdtitprt, ";"))
                                       AND b-crapcob.nrdocmto = INT(ENTRY(4,crapcob.cdtitprt, ";"))
                                       NO-LOCK NO-ERROR.
                        END.

                        IF  AVAIL b-crapcob THEN DO:
                        
                            RUN inst-sustar-baixar IN h-b1wgen0088
                                (INPUT b-crapcob.cdcooper,
                                 INPUT b-crapcob.nrdconta,
                                 INPUT b-crapcob.nrcnvcob,
                                 INPUT b-crapcob.nrdocmto,
                                 INPUT aux_dtmvtolt,
                                 INPUT aux_cdoperad,
                                 INPUT aux_nrremass,
                                OUTPUT aux_dscritic,
                                INPUT-OUTPUT TABLE tt-lat-consolidada ).

                        END.

                    END.
                    ELSE
                        RUN inst-sustar-baixar IN h-b1wgen0088
                            (INPUT tt-instr.cdcooper,
                             INPUT tt-instr.nrdconta,
                             INPUT tt-instr.nrcnvcob,
                             INPUT tt-instr.nrdocmto,
                             INPUT aux_dtmvtolt,
                             INPUT aux_cdoperad,
                             INPUT aux_nrremass,
                            OUTPUT aux_dscritic,
                            INPUT-OUTPUT TABLE tt-lat-consolidada ).
    
                END.

            /* 11 = Sustar Protesto e Manter em Carteira */
            WHEN 11 THEN
                DO:

                    /* Tratamento para Sustar Protesto e Manter em Carteira boleto BB vinculado ao boleto 085*/
                    IF  crapcob.incobran = 3 AND 
                        TRIM(crapcob.cdtitprt) <> "" THEN DO:

                        RELEASE b-crapcob.

                        FIND FIRST crapcco 
                             WHERE crapcco.cdcooper = INT(ENTRY(1,crapcob.cdtitprt, ";"))
                               AND crapcco.nrconven = INT(ENTRY(3,crapcob.cdtitprt, ";"))
                               NO-LOCK NO-ERROR.

                        IF  AVAIL crapcco THEN DO:

                            FIND FIRST b-crapcob 
                                     WHERE b-crapcob.cdcooper = INT(ENTRY(1,crapcob.cdtitprt, ";"))
                                   AND b-crapcob.cdbandoc = crapcco.cddbanco
                                   AND b-crapcob.nrdctabb = crapcco.nrdctabb
                                       AND b-crapcob.nrdconta = INT(ENTRY(2,crapcob.cdtitprt, ";"))
                                       AND b-crapcob.nrcnvcob = INT(ENTRY(3,crapcob.cdtitprt, ";"))
                                       AND b-crapcob.nrdocmto = INT(ENTRY(4,crapcob.cdtitprt, ";"))
                                       NO-LOCK NO-ERROR.
                        END.

                        IF  AVAIL b-crapcob THEN DO:

                            RUN inst-sustar-manter IN h-b1wgen0088
                                (INPUT b-crapcob.cdcooper,
                                 INPUT b-crapcob.nrdconta,
                                 INPUT b-crapcob.nrcnvcob,
                                 INPUT b-crapcob.nrdocmto,
                                 INPUT tt-instr.cdocorre,
                                 INPUT aux_dtmvtolt,
                                 INPUT aux_cdoperad,
                                 INPUT aux_nrremass,
                                OUTPUT aux_dscritic,
                                INPUT-OUTPUT TABLE tt-lat-consolidada ).
                        END.

                    END.
                    ELSE    
                        RUN inst-sustar-manter IN h-b1wgen0088
                            (INPUT tt-instr.cdcooper,
                             INPUT tt-instr.nrdconta,
                             INPUT tt-instr.nrcnvcob,
                             INPUT tt-instr.nrdocmto,
                             INPUT tt-instr.cdocorre,
                             INPUT aux_dtmvtolt,
                             INPUT aux_cdoperad,
                             INPUT aux_nrremass,
                            OUTPUT aux_dscritic,
                            INPUT-OUTPUT TABLE tt-lat-consolidada ).
    
                END.

            /* 31 = Alteracao de Outros Dados */
            WHEN 31 THEN
                DO:
                    RUN inst-alt-outros-dados-arq-rem-085 IN h-b1wgen0088
                        (INPUT tt-instr.cdcooper,
                         INPUT tt-instr.nrdconta,
                         INPUT tt-instr.nrcnvcob,
                         INPUT tt-instr.nrdocmto,
                         INPUT tt-instr.cdocorre,
                         INPUT tt-instr.nrinssac,
                         INPUT tt-instr.dsendsac,
                         INPUT tt-instr.nmbaisac,
                         INPUT tt-instr.nrcepsac,
                         INPUT tt-instr.nmcidsac,
                         INPUT tt-instr.cdufsaca,
                         INPUT aux_dtmvtolt,
                         INPUT aux_cdoperad,
                         INPUT aux_nrremass,
                        OUTPUT aux_dscritic,
                        INPUT-OUTPUT TABLE tt-lat-consolidada ).

                END.

            /* 41 = Cancelar Protesto */
            WHEN 41 THEN
                DO:
                    RUN inst-cancel-protesto IN h-b1wgen0088
                        (INPUT tt-instr.cdcooper,
                         INPUT tt-instr.nrdconta,
                         INPUT tt-instr.nrcnvcob,
                         INPUT tt-instr.nrdocmto,
                         INPUT tt-instr.cdocorre,
                         INPUT aux_dtmvtolt,
                         INPUT aux_cdoperad,
                         INPUT aux_nrremass,
                        OUTPUT aux_dscritic,
                        INPUT-OUTPUT TABLE tt-lat-consolidada ).
    
                END.

            /* 90 = Alterar tipo de emissão CEE */
            WHEN 90 THEN
                DO:
                    RUN inst-alt-tipo-emissao-cee IN h-b1wgen0088
                        (INPUT tt-instr.cdcooper,
                         INPUT tt-instr.nrdconta,
                         INPUT tt-instr.nrcnvcob,
                         INPUT tt-instr.nrdocmto,
                         INPUT tt-instr.cdocorre,
                         INPUT aux_dtmvtolt,
                         INPUT aux_cdoperad,
                         INPUT aux_nrremass,
                        OUTPUT aux_dscritic,
                        INPUT-OUTPUT TABLE tt-lat-consolidada ).
    
                END.
            WHEN 93 THEN
    			DO: /* Negativar Serasa */
                     RUN pc_negativa_serasa IN h-b1wgen0088
                                          ( INPUT tt-instr.cdcooper,
    									    INPUT tt-instr.nrcnvcob,
    										INPUT tt-instr.nrdconta,
    										INPUT tt-instr.nrdocmto,
                                           OUTPUT aux_cdcritic,
                                           OUTPUT aux_dscritic ).
    			END.	
			WHEN 94 THEN
            DO:  /* Cancela Negativação Serasa */
              RUN pc_cancelar_neg_serasa IN h-b1wgen0088
                                       ( INPUT tt-instr.cdcooper,
                                         INPUT tt-instr.nrcnvcob,
                                         INPUT tt-instr.nrdconta,
                                         INPUT tt-instr.nrdocmto,
                                        OUTPUT aux_cdcritic,
                                        OUTPUT aux_dscritic ).
            END.
            OTHERWISE

                DO: 
                    RUN prep-retorno-cooperado 
                        (INPUT ROWID(crapcob),
                         INPUT 26, /* Instrucao Rejeitada */
                         INPUT "",
                         INPUT 0,
                         INPUT crapcop.cdbcoctl,
                         INPUT crapcop.cdagectl,
                         INPUT aux_dtmvtolt,
                         INPUT aux_cdoperad,
                         INPUT aux_nrremass).

                    RUN cria-log-cobranca IN h-b1wgen0089
                        (INPUT ROWID(crapcob),
                         INPUT aux_cdoperad,
                         INPUT aux_dtmvtolt,
                         INPUT "Instrucao " + STRING(tt-instr.cdocorre) +
                               " nao programada").
                END.

        END CASE.

    END.

    IF  VALID-HANDLE(h-b1wgen0088) THEN
        DELETE PROCEDURE h-b1wgen0088.

    IF  VALID-HANDLE(h-b1wgen0089) THEN
        DELETE PROCEDURE h-b1wgen0089.

    RETURN "OK".

END PROCEDURE. /* fim - p_processa_instrucoes */

PROCEDURE prep-retorno-cooperado-rejeitado:
    
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcnvcob AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdocorre AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdmotivo AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrnosnum AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_vltitulo AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_cdbcoctl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagectl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsdoccop AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrremass AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtvencto AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtdemiss AS DATE                           NO-UNDO.

    DEF VAR aux_nmarquiv AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmarqcre AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsinserr AS CHAR                                    NO-UNDO. 
    DEF VAR aux_cdhistor AS INT                                     NO-UNDO.

    DEF VAR aux_nrremrtc AS INT                                     NO-UNDO.
    DEF VAR aux_nrremcre AS INT                                     NO-UNDO.
    DEF VAR aux_nrseqreg AS INT                                     NO-UNDO.
    DEF VAR aux_vltarifa AS DECI                                    NO-UNDO.

    DEF VAR aux_busca    AS CHAR                                    NO-UNDO.

  
    ASSIGN aux_nmarquiv = "cobret" + STRING(MONTH(par_dtmvtolt),"99") + 
                                     STRING(DAY(par_dtmvtolt),"99")
           aux_nmarqcre = "ret085" + STRING(MONTH(par_dtmvtolt),"99") + 
                                     STRING(DAY(par_dtmvtolt),"99").

    DO TRANSACTION:

       /*** Localiza o ultimo RTC desta data ***/
       FIND LAST craprtc WHERE craprtc.cdcooper = par_cdcooper AND
                               craprtc.nrdconta = par_nrdconta AND
                               craprtc.nrcnvcob = par_nrcnvcob AND
                               craprtc.dtmvtolt = par_dtmvtolt AND
                               craprtc.intipmvt = 2
                               NO-LOCK NO-ERROR. 
    
       IF NOT AVAIL craprtc THEN 
          DO:
              { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

              /* Busca a proxima sequencia do campo crapldt.nrsequen */
              RUN STORED-PROCEDURE pc_sequence_progress
              aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPRTC"
                                                  ,INPUT "NRREMRET"
                                                  ,INPUT STRING(par_cdcooper) + ";" +
                                                         STRING(par_nrdconta) + ";" +
                                                         STRING(par_nrcnvcob) + ";2"                                                   
                                                  ,INPUT "N"
                                                  ,"").
             
              CLOSE STORED-PROC pc_sequence_progress
                    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
             
              { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

              ASSIGN aux_nrremrtc = INTE(pc_sequence_progress.pr_sequence)
                                    WHEN pc_sequence_progress.pr_sequence <> ?.
             
              CREATE craprtc.

              ASSIGN craprtc.cdcooper = par_cdcooper
                     craprtc.nrdconta = par_nrdconta
                     craprtc.nrcnvcob = par_nrcnvcob
                     craprtc.dtmvtolt = par_dtmvtolt
                     craprtc.nrremret = aux_nrremrtc
                     craprtc.nmarquiv = aux_nmarquiv
                     craprtc.flgproce = NO
                     craprtc.cdoperad = par_cdoperad
                     craprtc.dtaltera = par_dtmvtolt
                     craprtc.hrtransa = TIME
                     craprtc.dtdenvio = ?
                     craprtc.qtreglot = 1
                     craprtc.intipmvt = 2.

              VALIDATE craprtc.

          END.

       FIND LAST crapcre WHERE crapcre.cdcooper = par_cdcooper AND
                               crapcre.nrcnvcob = par_nrcnvcob AND
                               crapcre.dtmvtolt = par_dtmvtolt AND
                               crapcre.intipmvt = 2
                               NO-LOCK NO-ERROR. 
    
       IF NOT AVAIL crapcre THEN 
          DO:
             /***** Localiza ultima sequencia *****/
             FIND LAST crapcre WHERE crapcre.cdcooper = par_cdcooper AND
                                     crapcre.nrcnvcob = par_nrcnvcob AND
                                     crapcre.intipmvt = 2
                                     NO-LOCK NO-ERROR. 
             
             IF NOT AVAIL crapcre THEN
                ASSIGN aux_nrremcre = 999999.
             ELSE
                ASSIGN aux_nrremcre = crapcre.nrremret + 1.
             
             CREATE crapcre.

             ASSIGN crapcre.cdcooper = par_cdcooper
                    crapcre.nrcnvcob = par_nrcnvcob
                    crapcre.dtmvtolt = par_dtmvtolt
                    crapcre.nrremret = aux_nrremcre
                    crapcre.intipmvt = 2
                    crapcre.nmarquiv = aux_nmarqcre
                    crapcre.flgproce = YES
                    crapcre.cdoperad = par_cdoperad
                    crapcre.dtaltera = par_dtmvtolt
                    crapcre.hrtranfi = TIME.

             VALIDATE crapcre.

          END.                              
/*
       /***** Localiza ultima sequencia *****/
       FIND LAST crapret WHERE crapret.cdcooper = par_cdcooper
                           AND crapret.nrcnvcob = par_nrcnvcob
                           AND crapret.nrremret = crapcre.nrremret
           NO-LOCK NO-ERROR. 
       IF  NOT AVAIL crapret THEN
           aux_nrseqreg = 1.
       ELSE
           aux_nrseqreg = crapret.nrseqreg + 1.
*/
       /* A busca do sequencial do nrseqreg sera atraves de sequence no Oracle */
       /* CDCOOPER;NRCNVCOB;NRREMRET */
       ASSIGN aux_busca = TRIM(STRING(par_cdcooper))   + ";" +
                          TRIM(STRING(par_nrcnvcob))   + ";" +
                          TRIM(STRING(crapcre.nrremret)).
    
       RUN STORED-PROCEDURE pc_sequence_progress
       aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPRET",
                                            INPUT "NRSEQREG",
                                            INPUT aux_busca,
                                            INPUT "N",
                                            "").
       
       CLOSE STORED-PROC pc_sequence_progress
       aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                         
       ASSIGN aux_nrseqreg = INTE(pc_sequence_progress.pr_sequence)
                                  WHEN pc_sequence_progress.pr_sequence <> ?.

       
       CREATE crapret.

       ASSIGN crapret.cdcooper = par_cdcooper
              crapret.nrcnvcob = par_nrcnvcob
              crapret.nrdconta = par_nrdconta
              crapret.nrdocmto = 0
              crapret.nrretcoo = craprtc.nrremret  /* Ultimo da RTC */
              crapret.nrremret = crapcre.nrremret  /* Ultimo da CRE */
              crapret.nrseqreg = aux_nrseqreg      /* Ultimo da RET */
              crapret.cdocorre = par_cdocorre
              crapret.cdmotivo = par_cdmotivo
              crapret.vltitulo = par_vltitulo
              crapret.vlabatim = 0
              crapret.vldescto = 0
              crapret.vltarass = 0
              crapret.vltarcus = 0
              crapret.cdbcorec = par_cdbcoctl
              crapret.cdagerec = par_cdagectl
              crapret.dtocorre = par_dtmvtolt
              crapret.cdoperad = par_cdoperad
              crapret.dtaltera = par_dtmvtolt
              crapret.hrtransa = TIME
              crapret.nrnosnum = par_nrnosnum
                                              
              crapret.dsdoccop = par_dsdoccop
              crapret.nrremass = par_nrremass
              crapret.dtvencto = par_dtvencto.

       VALIDATE crapret.
                                              
       LEAVE.

    END. /* END do DO TRANSACTION */

    RETURN "OK".

END PROCEDURE.

PROCEDURE cria-log-tarifa-cobranca:
    
    DEF  INPUT PARAM par_idtabcob AS ROWID                           NO-UNDO.
    DEF  INPUT PARAM par_dsmensag AS CHAR                            NO-UNDO.

    DEF BUFFER crabcob FOR crapcob.

    FIND FIRST crabcob WHERE ROWID(crabcob) = par_idtabcob
             NO-LOCK NO-ERROR.

    IF AVAIL crabcob THEN
        DO:
            CREATE crapcol.
            ASSIGN crapcol.cdcooper = crabcob.cdcooper
                   crapcol.nrdconta = crabcob.nrdconta
                   crapcol.nrdocmto = crabcob.nrdocmto
                   crapcol.nrcnvcob = crabcob.nrcnvcob
                   crapcol.dslogtit = par_dsmensag
                   crapcol.cdoperad = "TARIFA"
                   crapcol.dtaltera = TODAY
                   crapcol.hrtransa = TIME.
            VALIDATE crapcol.
        END.

END PROCEDURE.


PROCEDURE efetua-lancamento-tarifas-lat:

    DEF INPUT PARAM par_cdcooper    AS INTE         NO-UNDO.    
    DEF INPUT PARAM par_dtmvtolt    AS DATE         NO-UNDO.

    DEF INPUT-OUTPUT PARAM TABLE FOR tt-lat-consolidada.


    DEF VAR aux_qtd         AS INTE                 NO-UNDO.
    DEF VAR h-b1wgen0153    AS HANDLE               NO-UNDO.

    DEF VAR aux_inpessoa    AS INTE                 NO-UNDO.
    DEF VAR aux_cdhistor    AS INTE                 NO-UNDO.
    DEF VAR aux_cdhisest    AS INTE                 NO-UNDO.
    DEF VAR aux_vltarifa    AS DECI                 NO-UNDO.
    DEF VAR aux_dtdivulg    AS DATE                 NO-UNDO.
    DEF VAR aux_dtvigenc    AS DATE                 NO-UNDO.
    DEF VAR aux_cdfvlcop    AS INTE                 NO-UNDO.
    

    ASSIGN aux_qtd = 0.

    /* Busca inprocess*/
    FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper
                       NO-LOCK NO-ERROR.

    IF NOT AVAIL(crapdat) THEN
        RETURN "NOK".

    IF  NOT VALID-HANDLE(h-b1wgen0153) THEN
        RUN sistema/generico/procedures/b1wgen0153.p PERSISTENT SET h-b1wgen0153.
 
    /* Leitura Tabela Lancamentos Tarifa */
    FOR EACH tt-lat-consolidada NO-LOCK
            BREAK BY tt-lat-consolidada.cdcooper
                  BY tt-lat-consolidada.nrdconta
                  BY tt-lat-consolidada.nrcnvcob
                  BY tt-lat-consolidada.cdocorre
                  BY tt-lat-consolidada.cdmotivo:

        IF FIRST-OF(tt-lat-consolidada.cdmotivo) THEN
            ASSIGN aux_qtd = 0.
 
        /* Acumulo quantidade de registros conforme break by */
        ASSIGN aux_qtd = aux_qtd + 1.
 
        IF LAST-OF(tt-lat-consolidada.cdmotivo) THEN
        DO:
            /* Verifica tipo pessoa a ser usada para buscar tarifa  */
            ASSIGN aux_inpessoa = 2. /* Assume como padrao pessoa juridica */

            FIND crapass WHERE crapass.cdcooper = tt-lat-consolidada.cdcooper AND
                               crapass.nrdconta = tt-lat-consolidada.nrdconta NO-LOCK NO-ERROR.

            IF AVAIL(crapass) THEN
                ASSIGN aux_inpessoa = crapass.inpessoa.

            ASSIGN aux_vltarifa = 0.

            /* Busca informacoes tarifa */
            RUN carrega_dados_tarifa_cobranca IN h-b1wgen0153
                              (INPUT  tt-lat-consolidada.cdcooper,         /* cdcooper */
                               INPUT  tt-lat-consolidada.nrdconta,         /* nrdconta */
                               INPUT  tt-lat-consolidada.nrcnvcob,         /* nrconven */ 
                               INPUT  tt-lat-consolidada.dsincide,         /* REM/RET  */ 
                               INPUT  tt-lat-consolidada.cdocorre,         /* cdocorre */
                               INPUT  tt-lat-consolidada.cdmotivo,         /* cdmotivo */
                               INPUT  aux_inpessoa,                        /* inpessoa */
                               INPUT  tt-lat-consolidada.vllanmto,         /* vllanmto */
                               INPUT  "",                                  /* cdprogra */
							   INPUT  1,                                   /* flaputar - Sim */
                               OUTPUT aux_cdhistor,                        /* cdhistor */
                               OUTPUT aux_cdhisest,                        /* cdhisest */
                               OUTPUT aux_vltarifa,                        /* vltarifa */
                               OUTPUT aux_dtdivulg,                        /* dtdivulg */
                               OUTPUT aux_dtvigenc,                        /* dtvigenc */
                               OUTPUT aux_cdfvlcop,                        /* cdfvlcop */
                               OUTPUT TABLE tt-erro).

            IF  RETURN-VALUE = "NOK"  THEN DO:
                NEXT.
            END.

            /* Efetua lancamento CRAPLAT apenas se tiver valor de tarifa */
            IF aux_vltarifa > 0 THEN
            DO:

                /* Busca crapcco.cdbccxlt e crapcco.nrdolote */
                FIND FIRST crapcco WHERE crapcco.cdcooper = tt-lat-consolidada.cdcooper AND
                                         crapcco.nrconven = tt-lat-consolidada.nrcnvcob 
                                         NO-LOCK NO-ERROR.

                IF NOT AVAIL(crapcco) THEN
                DO:
                    tt-lat-consolidada.dscritic = "Erro geracao CRAPLAT. Convenio: "  +
                                                  STRING(tt-lat-consolidada.nrcnvcob) + 
                                                  " - CRAPCCO".
                    NEXT.
                END.

                /* Efetua um lancamento apenas para cada cooper conta convenio ocorrencia motivo*/
                ASSIGN aux_vltarifa = aux_vltarifa * aux_qtd.

                /* Efetua lancamento tarifa (craplat) */
                RUN cria_lan_auto_tarifa IN h-b1wgen0153
                                   (INPUT tt-lat-consolidada.cdcooper,
                                    INPUT tt-lat-consolidada.nrdconta,            
                                    INPUT par_dtmvtolt,
                                    INPUT aux_cdhistor, 
                                    INPUT aux_vltarifa,
                                    INPUT "1",                                              /* cdoperad */
                                    INPUT 1,                                                /* cdagenci */
                                    INPUT crapcco.cdbccxlt,                                 /* cdbccxlt */    
                                    INPUT crapcco.nrdolote,                                 /* nrdolote */        
                                    INPUT 1,                                                /* tpdolote */         
                                    INPUT 0,                                                /* nrdocmto */
                                    INPUT tt-lat-consolidada.nrdconta,                      /* nrdconta */
                                    INPUT STRING(tt-lat-consolidada.nrdconta,"99999999"),   /* nrdctitg */
                                    INPUT "",                                               /* cdpesqbb */
                                    INPUT 0,                                                /* cdbanchq */
                                    INPUT 0,                                                /* cdagechq */
                                    INPUT 0,                                                /* nrctachq */
                                    INPUT FALSE,                                            /* flgaviso */
                                    INPUT 0,                                                /* tpdaviso */
                                    INPUT aux_cdfvlcop,                                     /* cdfvlcop */
                                    INPUT crapdat.inproces,                                 /* inproces */
                                    OUTPUT TABLE tt-erro).

                IF  RETURN-VALUE = "NOK"  THEN DO:

                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
        
                    IF AVAIL tt-erro THEN 
                    DO:
                        tt-lat-consolidada.dscritic = "Erro geracao CRAPLAT. Conta: " + 
                                                      STRING(crapass.nrdconta,"zzzz,zz9,9") + 
                                                      " - " + tt-erro.dscritic  + " - " + STRING(tt-lat-consolidada.cdocorre) .
                        NEXT.
                    END.
                END.

            END. /* fim if aux_vltarifa > 0 */

        END.
       
    END.

    IF  VALID-HANDLE(h-b1wgen0153)  THEN
        DELETE PROCEDURE h-b1wgen0153.


    /* Rotina para replicar erros para demais documentos ja que lancamento estava consolidado */
    /* e apenas registrou erro no ultimo documento                                            */
                                             
    FOR EACH tt-lat-consolidada NO-LOCK:
        CREATE tt-aux-consolidada.
        BUFFER-COPY tt-lat-consolidada TO tt-aux-consolidada.
    END.

    /* Leitura de erros ocorridos */
    FOR EACH tt-aux-consolidada WHERE tt-aux-consolidada.dscritic <> "" NO-LOCK:

        FOR EACH tt-lat-consolidada WHERE tt-lat-consolidada.cdcooper = tt-aux-consolidada.cdcooper AND
                                          tt-lat-consolidada.nrdconta = tt-aux-consolidada.nrdconta AND  
                                          tt-lat-consolidada.nrcnvcob = tt-aux-consolidada.nrcnvcob AND
                                          tt-lat-consolidada.cdocorre = tt-aux-consolidada.cdocorre AND
                                          tt-lat-consolidada.cdmotivo = tt-aux-consolidada.cdmotivo 
                                          NO-LOCK:

              /* Registra erros ocorridos na CRAPCOL */
              CREATE crapcol.
              ASSIGN crapcol.cdcooper = tt-lat-consolidada.cdcooper
                     crapcol.nrdconta = tt-lat-consolidada.nrdconta
                     crapcol.nrdocmto = tt-lat-consolidada.nrdocmto
                     crapcol.nrcnvcob = tt-lat-consolidada.nrcnvcob
                     crapcol.dslogtit = tt-aux-consolidada.dscritic
                     crapcol.cdoperad = "TARIFA"
                     crapcol.dtaltera = TODAY
                     crapcol.hrtransa = TIME.
              VALIDATE crapcol.

        END.

    END.

    EMPTY TEMP-TABLE tt-lat-consolidada.

END PROCEDURE.

PROCEDURE valida_caracteres:
    /* Rotina de validacao de caracteres com base parametros informados */


    /*  - par_flgnumer : Validar lista de numeros ?
        - par_flgletra : Validar lista de letras  ?
        - par_listaesp : Lista de caracteres validados.
        - par_validar  : Campo a ser validado.
        - par_flgerro  : Retorna se campo validado. */

    DEF INPUT  PARAM par_flgnumer    AS LOGICAL         NO-UNDO.
    DEF INPUT  PARAM par_flgletra    AS LOGICAL         NO-UNDO.
    DEF INPUT  PARAM par_listaesp    AS CHAR            NO-UNDO.
    DEF INPUT  PARAM par_validar     AS CHAR            NO-UNDO.
    DEF OUTPUT PARAM par_flgerro     AS LOGICAL         NO-UNDO.


    DEF VAR aux_numeros             AS CHAR             NO-UNDO.
    DEF VAR aux_letras              AS CHAR             NO-UNDO.
    DEF VAR aux_caracteres          AS CHAR             NO-UNDO.
    DEF VAR aux_contador            AS INTE             NO-UNDO.
    DEF VAR aux_posicao             AS CHAR             NO-UNDO.


    ASSIGN aux_numeros  = "1,2,3,4,5,6,7,8,9,0,"
           aux_letras   = "A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,"
           par_flgerro  = FALSE.

    /* Numeros */
    IF par_flgnumer = TRUE  THEN
        aux_caracteres = aux_caracteres + aux_numeros.

    /* Letras */
    IF par_flgletra = TRUE  THEN
        aux_caracteres = aux_caracteres + aux_letras.

    /* Lista Caracteres Aceitos */
    IF par_listaesp <> "" THEN
        aux_caracteres = aux_caracteres + par_listaesp.


    ASSIGN par_validar = REPLACE(UPPER(par_validar)," ","").

    /* Caso nao tenha campos a validar retorna OK */
    IF par_validar = "" THEN
        RETURN "OK".

    DO aux_contador = 1 TO LENGTH(par_validar):
    
        ASSIGN aux_posicao = SUBSTRING(par_validar,aux_contador,1).

        IF NOT CAN-DO(aux_caracteres,aux_posicao) THEN
           ASSIGN par_flgerro  = TRUE.

    END.

END PROCEDURE.

PROCEDURE valida_cpf_cnpj:

    /* Rotina para efetuar validacao de CPF ou CNPJ */

    DEF INPUT  PARAM par_inpessoa    AS INTE            NO-UNDO.
    DEF INPUT  PARAM par_cpfcnpj     AS DECI            NO-UNDO.
    DEF OUTPUT PARAM par_flgerro     AS LOGICAL         NO-UNDO.

    DEF VAR aux_stsnrcal             AS LOGICAL         NO-UNDO.    
    DEF VAR h-b1wgen9999             AS HANDLE          NO-UNDO.


    ASSIGN aux_stsnrcal = TRUE
           par_flgerro  = FALSE.

    IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
        RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.

    IF par_inpessoa = 1 THEN /* Fisica */
        RUN valida-cpf IN h-b1wgen9999
                    ( INPUT  par_cpfcnpj,
                      OUTPUT aux_stsnrcal).
    ELSE
        RUN valida-cnpj IN h-b1wgen9999
                    ( INPUT  par_cpfcnpj,
                      OUTPUT aux_stsnrcal).

    /* Caso retorne FALSE o CPF ou CNPJ nao e valido */
    IF aux_stsnrcal = FALSE THEN
        ASSIGN par_flgerro = TRUE.

    IF VALID-HANDLE(h-b1wgen9999) THEN
        DELETE PROCEDURE h-b1wgen9999.
        
END PROCEDURE.


PROCEDURE valida-execucao-instrucao:

    /* Rotina tem como objetvo efetuar a validacao de campos
       quando for comando de instrucao.                      */

    DEF INPUT  PARAM par_cdcooper    AS INTE            NO-UNDO. 
    DEF INPUT  PARAM par_nrdconta    AS INTE            NO-UNDO.
    DEF INPUT  PARAM par_setlinha    AS CHAR            NO-UNDO.
    DEF INPUT  PARAM par_cdocorre    AS INTE            NO-UNDO.
    DEF INPUT  PARAM par_tipocnab    AS CHAR            NO-UNDO.
    DEF OUTPUT PARAM par_cdmotivo    AS CHAR            NO-UNDO.

    DEF VAR aux_nroconta             AS INTE            NO-UNDO.
    DEF VAR aux_flgerro              AS LOGICAL         NO-UNDO.
    DEF VAR aux_cdprotes             AS INTE            NO-UNDO.


     DEF VAR aux_cdinstr1            AS CHAR            NO-UNDO.
     DEF VAR aux_cdinstr2            AS CHAR            NO-UNDO.

    /* Inicializa variaveis*/
    ASSIGN  aux_vltitulo = 0
            aux_vldescto = 0
            aux_vlabatim = 0
            aux_dtvencto = ?.


    DO  WHILE LENGTH(TRIM(aux_dsnosnum)) < 17:
        ASSIGN aux_dsnosnum = "0" + aux_dsnosnum.
    END.

    ASSIGN  aux_nroconta = INT(SUBSTR(aux_dsnosnum,01,08))
            aux_nrbloque = DEC(SUBSTR(aux_dsnosnum,09,09)).

    /* Verifica se conta do cooperado confere com conta do nosso numero */
    IF par_nrdconta <> aux_nroconta THEN
         ASSIGN par_cdmotivo = "08".   /* Nosso Numero Invalido  */
                    
    /* Verifica Existencia Titulo */
    FIND FIRST crapcob WHERE 
               crapcob.cdcooper = par_cdcooper AND
               crapcob.cdbandoc = aux_cdbandoc AND  
               crapcob.nrdctabb = aux_nrdctabb AND
               crapcob.nrcnvcob = aux_nrcnvcob AND
               crapcob.nrdconta = aux_nroconta AND
               crapcob.nrdocmto = aux_nrbloque
               NO-LOCK NO-ERROR. 
        
    IF NOT AVAIL(crapcob) THEN
        ASSIGN par_cdmotivo = "08".   /* Nosso Numero Invalido  */
    ELSE
        aux_vltitulo = crapcob.vltitulo.

    /* Apenas se nao ocorreu erro */
    IF par_cdmotivo = "" THEN DO :

       /* Concessao de Abatimento */
       IF par_cdocorre = 04 THEN DO: 

             /* Valor de Abatimento */ 
            IF par_tipocnab = "240" THEN
                aux_vlabatim = DEC(SUBSTR(par_setlinha,181,15)) / 100 NO-ERROR.
            ELSE
                aux_vlabatim = DEC(SUBSTR(par_setlinha,206,13)) / 100 NO-ERROR.
    
            IF ERROR-STATUS:ERROR THEN
                ASSIGN par_cdmotivo = "33".   /* Valor do Abatimento Invalido */
            ELSE DO:
              IF ( aux_vlabatim = 0 ) THEN
                    ASSIGN par_cdmotivo = "33".   /* Valor do Abatimento Invalido */
            END.
    
       END.

       /* Cancelamento Concessao de Abatimento */
       IF par_cdocorre = 05 THEN DO:
       END.

       /* Alteracao de Vencimento */
       IF par_cdocorre = 06 THEN DO:

              IF par_tipocnab = "240" THEN DO:
    
                  IF ( INT(SUBSTRING(par_setlinha,078,2)) <> 0 ) THEN DO:
    
                          aux_dtvencto =
                                 DATE(INT(SUBSTRING(par_setlinha,080,2)),
                                      INT(SUBSTRING(par_setlinha,078,2)),
                                      INT(SUBSTRING(par_setlinha,082,4))) NO-ERROR.
    
                          IF ERROR-STATUS:ERROR THEN
                              ASSIGN par_cdmotivo = "16".   /* Data de Vencimento Invalida */
                              
                  END.
                  ELSE 
                        ASSIGN par_cdmotivo = "16".    /* Data de Vencimento Invalida */ 

              END.
              ELSE DO:

                  IF ( INT(SUBSTRING(par_setlinha,121,2)) <> 0 ) THEN DO:
        
                          aux_dtvencto =
                                         DATE(INT(SUBSTRING(par_setlinha,123,2)),
                                              INT(SUBSTRING(par_setlinha,121,2)),
                                              INT("20" + SUBSTRING(par_setlinha,125,2))) NO-ERROR.

                          IF ERROR-STATUS:ERROR THEN
                              ASSIGN par_cdmotivo = "16".   /* Data de Vencimento Invalida */
                              
                  END.
                  ELSE 
                        ASSIGN par_cdmotivo = "16".    /* Data de Vencimento Invalida */

              END.

              IF par_cdmotivo = "" THEN  
                  IF ( aux_dtvencto < TODAY ) OR ( aux_dtvencto > DATE("13/10/2049") )  THEN DO:
                        ASSIGN par_cdmotivo = "18".   /* Vencimento Fora do Prazo de Operacao   */ 
                  END.

       END.

       /* Concessao de Desconto */
       IF par_cdocorre = 07 THEN DO:

           IF par_tipocnab = "240" THEN
                aux_vldescto = DEC(SUBSTR(par_setlinha,151,15)) / 100 NO-ERROR.
           ELSE
                aux_vldescto = DEC(SUBSTR(par_setlinha,180,13)) / 100 NO-ERROR. /* Valor de Desconto */

            IF ERROR-STATUS:ERROR THEN
                 ASSIGN par_cdmotivo = "30".   /* Desconto a Conceder Nao Confere */
            ELSE DO:
                IF aux_vldescto = 0 THEN
                     ASSIGN par_cdmotivo = "30".   /* Desconto a Conceder Nao Confere */
            END.
            
            IF par_cdmotivo = "" THEN DO:
                IF aux_vldescto >= aux_vltitulo THEN
                        ASSIGN par_cdmotivo = "29".   /* Valor do Desconto Maior ou Igual ao Valor do Titulo  */
            END.
         
       END.

       /* Cancelamento Concessao de Desconto */
       IF par_cdocorre = 08 THEN DO:
       END.


       /* Protestar */
       IF par_cdocorre = 09 THEN DO:

           IF crapcob.dtvencto >= TODAY THEN
                ASSIGN par_cdmotivo = "39". /* Pedido de Protesto Nao Permitido para o Titulo */

           IF par_tipocnab = "240" THEN DO:

              /* 36.3P Valida Codigo de Protesto */
              IF par_cdmotivo = "" THEN DO:

                  aux_cdprotes = INT(SUBSTR(par_setlinha,221,01)) NO-ERROR.

                  IF ERROR-STATUS:ERROR THEN
                       ASSIGN par_cdmotivo = "37".    /* Codigo para Protesto Invalido  */
                  ELSE DO:

                      IF aux_cdprotes <> 1 THEN      /* Protestar Dias Corridos          */
                            ASSIGN par_cdmotivo = "37".    /* Codigo para Protesto Invalido  */
                      
                  END.
              END.

              /* 37.3P Valida Prazo para Protesto */
              IF par_cdmotivo = "" THEN DO:

                  aux_qtdiaprt = INT(SUBSTR(par_setlinha,222,02)) NO-ERROR.

                  IF ERROR-STATUS:ERROR THEN
                        ASSIGN par_cdmotivo = "38".    /* Prazo para Protesto Invalido  */
                  ELSE DO:

                      /* Prazo para protesto valido de 5 a 15 dias */
                      IF ( aux_qtdiaprt < 5    OR 
                           aux_qtdiaprt > 15 ) THEN
                            ASSIGN par_cdmotivo = "38".    /* Prazo para Protesto Invalido  */
                  END.
              END.

           END.
           ELSE DO:

                  /* Definido pelo Rafael que instrucao de protesto deve ser apenas em dias corridos */  

                  ASSIGN aux_cdinstr1 = SUBSTR(par_setlinha,157,02)
                         aux_cdinstr2 = SUBSTR(par_setlinha,159,02).
                
                  IF aux_cdinstr1 <> "06" AND
                     aux_cdinstr2 <> "06" THEN          /* 06 - Indica Protesto em dias corridos */
                            ASSIGN par_cdmotivo = "37". /* Codigo de Protesto Invalido */
                  ELSE DO:
                        
                        aux_qtdiaprt = INT(SUBSTR(par_setlinha,392,02)) NO-ERROR.
    
                         IF ERROR-STATUS:ERROR THEN
                                ASSIGN par_cdmotivo = "38".   /* Prazo para Protesto Invalido */
                         ELSE DO:  
                              IF ( aux_qtdiaprt < 5  OR
                                   aux_qtdiaprt > 15 ) THEN
                                    ASSIGN par_cdmotivo = "38".   /* Prazo para Protesto Invalido  */
                         END.
    
                  END.

           END.

       END.

       /* Sustar Protesto e Baixar */
       IF par_cdocorre = 10 THEN DO:
       END.

       /* Sustar Protesto e Mater em Carteira */
       IF par_cdocorre = 11 THEN DO:
       END.

       /* Alteracao de Outros Dados */
       IF par_cdocorre = 31 THEN DO:

           IF par_tipocnab = "240" THEN DO:

                /* 08.3Q Valida Tipo de Inscricao */
                aux_cdtpinsc = INT(SUBSTR(par_setlinha,18,01)) NO-ERROR.
                    
                IF ERROR-STATUS:ERROR THEN
                     ASSIGN par_cdmotivo = "46".        /* Tipo/Numero de Inscricao do Sacado Invalidos    */
                ELSE DO:
                    IF aux_cdtpinsc <> 1 AND
                       aux_cdtpinsc <> 2  THEN
                           ASSIGN par_cdmotivo = "46".  /* Tipo/Numero de Inscricao do Sacado Invalidos    */
                END.
        
                /* 09.3Q Valida Numero de Inscricao */
                IF par_cdmotivo = "" THEN DO: 
        
                    aux_nrinssac = DEC(SUBSTR(par_setlinha,19,15)) NO-ERROR.
        
                    IF ERROR-STATUS:ERROR THEN
                        ASSIGN par_cdmotivo = "46".    /* Tipo/Numero de Inscricao do Sacado Invalidos    */
                    ELSE DO:
        
                       RUN valida_cpf_cnpj(INPUT  aux_cdtpinsc,
                                           INPUT  aux_nrinssac,
                                           OUTPUT aux_flgerro).
        
                       IF aux_flgerro = TRUE THEN
                           ASSIGN par_cdmotivo = "46". /* Tipo/Numero de Inscricao do Sacado Invalidos    */
                    END.
                END.

                IF par_cdmotivo <> "" THEN
                    RETURN.
                    
                ASSIGN aux_dsendsac = REPLACE(SUBSTR(par_setlinha,74,40),",", " ")  /* Endereco Sacado */
                       aux_nmbaisac = SUBSTR(par_setlinha,114,15)                   /* Bairro Sacado */
                       aux_nmcidsac = SUBSTR(par_setlinha,137,15)                   /* Cidade */
                       aux_cdufsaca = SUBSTR(par_setlinha,152,02).                  /* UF Sacado */



                /* 11.3Q Valida Endereco do Sacado */
                IF TRIM(aux_dsendsac) = "" THEN
                    ASSIGN par_cdmotivo = "47".    /* Endereco do Sacado Nao Informado    */
                ELSE DO:
                    RUN valida_caracteres( INPUT TRUE,        /* Validar Numeros          */
                                           INPUT TRUE,        /* Validar Letras           */
                                           INPUT ".,/,-,_",   /* Lista Caracteres Validos */
                                           INPUT aux_dsendsac,
                                           OUTPUT aux_flgerro).
        
                    IF aux_flgerro = TRUE THEN
                        ASSIGN par_cdmotivo = "47".    /* Endereco do Sacado Nao Informado    */
                END.
                 
                /* 13.3Q e 14.3Q Valida CEP do Sacado */
                IF par_cdmotivo = "" THEN DO:

                      aux_nrcepsac = INT(SUBSTR(par_setlinha,129,8)) NO-ERROR.

                      IF ERROR-STATUS:ERROR THEN
                          par_cdmotivo = "48".          /* CEP Invalido */
                      ELSE DO:

                        FIND FIRST crapdne WHERE crapdne.nrceplog = aux_nrcepsac AND
                                                 crapdne.idoricad = 1           /* Correios */
                                                 NO-LOCK NO-ERROR.
                        IF  NOT AVAIL(crapdne) THEN
                            DO:
                                FIND FIRST crapdne WHERE crapdne.nrceplog = aux_nrcepsac AND
                                                         crapdne.idoricad = 2           /* Ayllos */
                                                         NO-LOCK NO-ERROR.
                                IF  NOT AVAIL(crapdne) THEN
                                    ASSIGN par_cdmotivo = "48".    /* CEP Invalido */
                            END.
                      END.
                END.
                  

                /* 16.3Q Valida UF do Sacado */
                IF par_cdmotivo = "" THEN DO:

                    IF aux_cdufsaca <> crapdne.cduflogr THEN
                          ASSIGN par_cdmotivo = "51".   /* CEP incompativel com a Unidade da Federacao */

                END.


           END.
           ELSE DO:

                /* 38.7 Tipo de inscricao do sacado */
                aux_cdtpinsc = INT(SUBSTR(par_setlinha,219,02)) NO-ERROR. /* Cod Tipo de Inscricao sacado  */  
    
                IF ERROR-STATUS:ERROR THEN
                     ASSIGN par_cdmotivo = "46".    /* Tipo/Numero de Inscricao do Sacado Invalidos    */
                ELSE DO:
   
                    IF aux_cdtpinsc <> 1 AND      /* Fisica   */
                       aux_cdtpinsc <> 2  THEN    /* Juridica */
                   
                            ASSIGN par_cdmotivo = "46".    /* Tipo/Numero de Inscricao do Sacado Invalidos    */
                END.
                          
        
                /* 39.7 Numero CPF/CNPJ do Sacado */
                IF par_cdmotivo = "" THEN DO: 

                      aux_nrinssac = DEC(SUBSTR(par_setlinha,221,14)) NO-ERROR.

                      IF ERROR-STATUS:ERROR THEN
                           ASSIGN par_cdmotivo = "46".    /* Tipo/Numero de Inscricao do Sacado Invalidos    */
                      ELSE DO:  
        
                          IF aux_cdtpinav = 1 OR          /* Fisica   */
                             aux_cdtpinav = 2 THEN DO:    /* Juridica */

                             RUN valida_cpf_cnpj(INPUT  aux_cdtpinsc,
                                                 INPUT  aux_nrinssac,
                                                 OUTPUT aux_flgerro).

                             IF aux_flgerro = TRUE THEN
                                  ASSIGN par_cdmotivo = "46".    /* Tipo/Numero de Inscricao do Sacado Invalidos    */
                              
                          END.

                      END.
                END.

                IF par_cdmotivo <> "" THEN 
                    RETURN.


                ASSIGN  aux_dsendsac = REPLACE(SUBSTR(par_setlinha,275,40), ",", " ")      /* Endereco Sacado */
                        aux_nmbaisac = SUBSTR(par_setlinha,315,12)      /* Bairro Sacado */
                        aux_nmcidsac = SUBSTR(par_setlinha,335,15)      /* Cidade */
                        aux_cdufsaca = SUBSTR(par_setlinha,350,02).     /* UF Sacado */
               
                /* 42.7 Endereco do Sacado */
                IF TRIM(aux_dsendsac) = "" THEN
                    ASSIGN par_cdmotivo = "47". /* Endereco do Sacado Nao Informado */
                ELSE DO:
                    RUN valida_caracteres( INPUT TRUE,    /* Validar Numeros */
                                           INPUT TRUE,    /* Validar Letras  */
                                           INPUT ".,/,-,_", /* Lista Caracteres Validos */
                                           INPUT aux_dsendsac,
                                           OUTPUT aux_flgerro).
                
                    IF aux_flgerro = TRUE THEN
                        ASSIGN par_cdmotivo = "47".    /* Endereco do Sacado Nao Informado */
                END.
        
                /* 44.7 CEP do Sacado */
                IF par_cdmotivo = "" THEN DO:
        
                    aux_nrcepsac = INT(SUBSTR(par_setlinha,327,8)) NO-ERROR.  /* Cep Sacado */
    
                    IF ERROR-STATUS:ERROR THEN
                        par_cdmotivo = "48". /*  CEP Invalido */
                    ELSE DO:
    
                        IF TRIM(STRING(aux_nrcepsac)) = "" THEN
                            par_cdmotivo = "48". /*  CEP Invalido */
                        ELSE DO: 
        
                          RUN valida_caracteres( INPUT TRUE,    /* Validar Numeros */
                                                 INPUT FALSE,   /* Validar Letras  */
                                                 INPUT "",      /* Lista Caracteres Validos */
                                                 INPUT STRING(aux_nrcepsac),
                                                 OUTPUT aux_flgerro).
        
                          IF aux_flgerro = TRUE THEN
                                ASSIGN par_cdmotivo = "48".    /*  CEP Invalido */  
        
                        END.
    
                    END.
        
                    IF par_cdmotivo = "" THEN DO:

                        FIND FIRST crapdne WHERE crapdne.nrceplog = aux_nrcepsac AND
                                                 crapdne.idoricad = 1           /* Correios */
                                                 NO-LOCK NO-ERROR.
                        IF  NOT AVAIL(crapdne) THEN
                            DO:
                                FIND FIRST crapdne WHERE crapdne.nrceplog = aux_nrcepsac AND
                                                         crapdne.idoricad = 2           /* Ayllos */
                                                         NO-LOCK NO-ERROR.
                                IF  NOT AVAIL(crapdne) THEN
                                    ASSIGN par_cdmotivo = "48".    /* CEP Invalido */
                            END.
                    END.
        
                  END.
        
                  /* 46.7 UF do Sacado */
                  IF par_cdmotivo = "" THEN DO:
        
                      IF aux_cdufsaca <> crapdne.cduflogr THEN
                            ASSIGN par_cdmotivo = "51".    /* CEP Incompativel com a Unidade da Federacao */
                  END.
           END.

       END.

       /* Cancelar Protesto */
       IF par_cdocorre = 41 THEN DO:
       END.

       /* Negativar Serasa */
       IF par_cdocorre = 93 THEN DO:
    END.

       /* Cancela Negativar Serasa */
       IF par_cdocorre = 94 THEN DO:
       END.

    END.

    RETURN "OK".

END.

PROCEDURE p_altera_email_cel_sacado:

    DEF  INPUT PARAM par_cdcooper LIKE crapsab.cdcooper             NO-UNDO.
    DEF  INPUT PARAM par_nrdconta LIKE crapsab.nrdconta             NO-UNDO.
    DEF  INPUT PARAM par_nrinssac LIKE crapsab.nrinssac             NO-UNDO.
    DEF  INPUT PARAM par_dsdemail AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcelsac LIKE crapsab.nrcelsac             NO-UNDO.

    DEF VAR aux_ponteiro AS INTE                              NO-UNDO.
    DEF VAR aux_retorno  AS INTE                              NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                              NO-UNDO.
    
	IF  par_nrinssac = 0 THEN
        RETURN.

    /* Tirar os espaços em branco do e-mail*/
    ASSIGN par_dsdemail = TRIM(par_dsdemail).

    /* Se o e-mail foi preenchido, temos que verificar se ele eh valido */
    IF  par_dsdemail <> ""  THEN
        DO:
        
             { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }   
             RUN STORED-PROCEDURE pc_grava_email_pagador
                 aux_handproc = PROC-HANDLE NO-ERROR
                                         (INPUT par_cdcooper,
                                          INPUT par_nrdconta,
                                          INPUT par_nrinssac,
                                          INPUT par_dsdemail,
                                         OUTPUT "",  /* pr_des_erro */
                                         OUTPUT ""). /* pr_dscritic */
             CLOSE STORED-PROC pc_grava_email_pagador
                   aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
             { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
             ASSIGN aux_dscritic = ""
                    aux_dscritic = pc_grava_email_pagador.pr_dscritic
                                       WHEN pc_grava_email_pagador.pr_dscritic <> ?.
        
            IF  aux_dscritic <> "" THEN DO:
                ASSIGN glb_dscritic = "Email invalido." + aux_dscritic .
                RETURN.
            END.
        END.

    /*  Sacado possui registro */
    FIND crapsab WHERE crapsab.cdcooper = par_cdcooper AND
                       crapsab.nrdconta = par_nrdconta AND
                       crapsab.nrinssac = par_nrinssac EXCLUSIVE-LOCK NO-ERROR.
                          
    IF AVAILABLE crapsab THEN DO:
        
        IF par_nrcelsac <> 0 AND par_nrcelsac <> crapsab.nrcelsac THEN DO:
            ASSIGN crapsab.nrcelsac = par_nrcelsac.
        END.
            
    END.

END PROCEDURE.


PROCEDURE busca_parametro_negativ:

    DEF  INPUT PARAM par_cdcooper LIKE crapsab.cdcooper             NO-UNDO.
    DEF  INPUT PARAM par_cdufsaca AS CHAR                           NO-UNDO.
    DEF  OUTPUT PARAM par_qtminimo AS INT                            NO-UNDO.
    DEF  OUTPUT PARAM par_qtmaximo AS INT                            NO-UNDO.
    DEF  OUTPUT PARAM par_vlminimo AS DEC                            NO-UNDO.
    DEF  OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }    

    RUN STORED-PROCEDURE pc_busca_param_negativ
    aux_handproc = PROC-HANDLE NO-ERROR
                                (INPUT par_cdcooper,
                                 INPUT par_cdufsaca,
                                 OUTPUT 0,
                                 OUTPUT 0,
                                 OUTPUT 0,   
                                 OUTPUT "", 
                                 OUTPUT ""). /* pr_dscritic */

    CLOSE STORED-PROC pc_busca_param_negativ
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

    ASSIGN par_dscritic = ""

           par_dscritic = pc_busca_param_negativ.pr_dscritic
                              WHEN pc_busca_param_negativ.pr_dscritic <> ?

           par_qtminimo = pc_busca_param_negativ.pr_qtminimo_negativacao
                              WHEN pc_busca_param_negativ.pr_qtminimo_negativacao <> ?

           par_qtmaximo = pc_busca_param_negativ.pr_qtmaximo_negativacao
                              WHEN pc_busca_param_negativ.pr_qtmaximo_negativacao <> ?

           par_vlminimo = pc_busca_param_negativ.pr_vlminimo_boleto
                              WHEN pc_busca_param_negativ.pr_vlminimo_boleto <> ?.
/*
           aux_textodia = pc_busca_param_negativ.pr_dstexto_dia
                              WHEN pc_busca_param_negativ.pr_dstexto_dia <> ?.
*/

END PROCEDURE.

/* .......................................................................... */




