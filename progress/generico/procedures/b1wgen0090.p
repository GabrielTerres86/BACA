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
  | p_altera_email_cel_sacado        | COBR0006.pc_altera_email_cel_sacado     |
  | pi_grava_rtc                     | COBR0006.pc_grava_rtc`                  |
  | p_integra_arq_remessa            | COBR0006.pc_integra_arq_remessa         |
  | p_integra_arq_remessa_cnab240_085 | COBR0006.pc_intarq_remes_cnab240_085   |
  | p_integra_arq_remessa_cnab400_085 | COBR0006.pc_intarq_remes_cnab400_85    |
  | p_grava_instrucao                | CORB0006.pc_grava_instrucao             |
  | p_processa_instrucoes            | COBR0006.pc_processa_instrucoes         |
  | prep-retorno-cooperado-rejeitado | COBR0006                                |
  | p_processa_titulos               | COBR0006.pc_processa_titulos            |
  | valida-execucao-instrucao        | COBR0006.pc_valida_exec_instrucao       |
  | valida_cpf_cnpj                  | COBR0005.pc_valida_cpf_cnpj             |
  | valida_caracteres                | COBR0006.fn_valida_caracteres           |
  | pi_protocolo_transacao           | COBR0006.pc_protocolo_transacao         |
  | p_grava_sacado                   | COBR0006.pc_grava_sacado                |
  | p_grava_boleto                   | COBR0006.pc_grava_boleto                |
  | prep-retorno-cooperado           | COBR0006.pc_prep_retorno_cooper_90      |
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
   Data    : 15/03/2011                        Ultima atualizacao: 08/03/2016

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

			  08/03/2016 - Conversao das rotinas abaixo para PL SQL:
							- p_altera_email_cel_sacado       
							- pi_grava_rtc                     
							- p_integra_arq_remessa            
							- p_integra_arq_remessa_cnab240_085 
							- p_integra_arq_remessa_cnab400_085 
							- p_grava_instrucao                
							- p_processa_instrucoes            
							- prep-retorno-cooperado-rejeitado 
							- p_processa_titulos               
							- valida-execucao-instrucao        
							- valida_cpf_cnpj                  
							- valida_caracteres                
							- pi_protocolo_transacao           
							- p_grava_sacado                   
							- p_grava_boleto                   
							- prep-retorno-cooperado           			  
						   (Andrei - RKAM).
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




