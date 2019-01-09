
/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +--------------------------------+------------------------------------------+
  | Rotina Progress                | Rotina Oracle PLSQL                      |
  +--------------------------------+------------------------------------------+
  | dbo/b1crap14.p                 | CXON0014                                 |
  |    retorna-valores-titulo-iptu | CXON0014.pc_retorna_vlr_titulo_iptu      |
  |    gera-titulos-iptu           | CXON0014.pc_gera_titulos_iptu            |
  |    identifica-titulo-coop      | CXON0014.pc_identifica_titulo_coop       |  
  |    verifica-vencimento-titulo  | CXON0014.pc_verifica_vencimento_titulo   |  
  |    gera-tarifa-titulo          | CXON0014.pc_gera_tarifa_titulo           |
  |    envia_vrboleto_spb          | CXON0014.pc_envia_vrboleto_spb           |
  |    pega_valor_tarifas          | CXON0014.pc_pega_valor_tarifas           |
  |    efetua-lanc-craplat         | CXON0014.pc_efetua_lanc_craplat          |
  +--------------------------------+------------------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/


/* ..........................................................................
    
   Programa: siscaixa/web/dbo/b2crap14.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Mirtes.
   Data    : Marco/2001                      Ultima atualizacao: 03/09/2018

   Dados referentes ao programa:

   Frequencia: Diario (Caixa Online).
   Objetivo  : Tratar Arrecadacao de Titulos com codigo de barras

   Alteracoes: 26/09/2005 - Tratar Identificacao do segmento no codigo de 
                            barras para fatura IPTU Blumenau(Pos. 2 - 2)
                            Passar codigo da cooperativa e nrdconta como
                            parametro para as procedures (Julio)
                            
               12/04/2006 - Permitir bloquetos vencidos quando este for da
                            coopertativa (Julio)       
                            
               08/08/2006 - Tratar novo layout de bloqueto (crapceb) (Julio)

               15/08/2007 - Alterado para usar a data com crapdat.dtmvtocd e
                            tratamento para os erros da internet;
                          - Criada procedure gera-tarifa-titulo e identificar
                            quando boleto for pago pela internet (Evandro).
                            
               03/01/2008 - Validar horario de digitacao somente quando nao
                            for PAC 90 (David).

               15/04/2008 - Adaptacao para agendamentos (David).

               03/06/2008 - Separacao de lotes para titulos da coop (Evandro).

               08/07/2008 - Acerto na leitura do crapcob (Magui).

               15/09/2008 - Alterado campo crapcob.cdbccxlt -> crapcob.cdbandoc
                            (Diego).
                            
               08/10/2008 - Chama a BO efetua_baixa_titulo e nao gera 
                            lancamento de credito para conta do cooperado no
                            caso do titulo estar em desconto (Elton).
                          - Utilizar craplot.nrseqdig + 1 no campo nrdocmto
                            em vez de TIME quando criar o registro da craptit
                            (David).

               08/12/2008 - Incluir parametro na chamada do programa pcrap03.p
                            (David).
             
               15/04/2009 - Tratamento para tarifas (Gabriel).
                          - Origem AUTOMATICO alterado para IMPRESSO PELO
                            SOFTWARE ou INTERNET (Guilherme).
                          - Postergacao da data de vencimento na verificacao
                            se o titulo esta em desconto ou nao(Guilherme).
                            
               19/05/2009 - Chamar a baixa de desconto de titulo somente se 
                            o titulo estiver em desconto(aux_flgdesct = YES)
                            (Guilherme).
                            
               02/06/2009 - Alterar tratamento para verificacao de registros
                            que estao com EXCLUSIVE-LOCK (David).              
                          - Inserido tratamento de erro na chamada da b1wgen0030
                            (Guilherme).
                            
               23/06/2009 - Adaptar para pagamento de titulos que estao em
                            emprestimo (Guilherme).

               24/07/2009 - Se o titulo for da cooperativa, verificar se esta
                            vencido (David).
               
               22/10/2009 - Converte para DECIMAL ao inves de INTEGER o valor
                            passado para variavel p-bloqueto na procedure
                            identifica-titulo-coop (Elton).
                            
               26/10/2009 - Corrigir a busca do convenio (crapcco) para
                            utilizar o cdcooper (Evandro).
                            
               27/10/2009 - Tratamento para nao aceitar titulos vencidos como
                            agendamento (David).
                            
               08/01/2010 - Tratamento para aceitar titulos que venceram no 
                            ultimo dia util do ano (David).
                            
               10/06/2010 - Tratamento para o PAC 91 - TAA (Evandro/Elton).
               
               20/10/2010 - Inclusao de parametros na procedure 
                            gera-titulos-iptu (Vitor)
               
               27/12/2010 - Incluida procedure atualiza-cheque e incluido 
                            novos parametros na procedure gera-titulos-iptu
                            (Elton).
                            
               16/02/2011 - Tratamento para Projeto DDA (David).
                            
               04/03/2011 - Tratamento para Feriado de Carnaval e Feriado em
                            Joinville (David).
                            
               18/03/2011 - Cria crapcob quando boleto for do tipo
                            "IMPRESSO PELO SOFTWARE" e não existir o crapcob 
                            (Elton).                                  
                            
               02/05/2011 - Tratamento para liquidação de cob. registrada
                          - Criticar titulos com numero de caracteres <> de 44
                            e nao aceitar caracteres nao numerico (Guilherme);
                          - Acerto na contabilização dos cheques na craplot
                            (Elton).
                            
               08/07/2011 - Incluido novos parametros na procedure 
                            gera-titulos-iptu (Elton).
                            
               14/07/2011 - Alterado identifica-titulos-coop
                            Quando criar titulo, identificar que pertence
                            a cooperativa (Rafael).
                            
               03/08/2011 - Alterado identifica-titulos-coop
                            Buscar titulos Banco do Brasil somente quando 
                            for cob. sem registro (Rafael).
                            
               12/08/2011 - Feriado Credicomin (David).
               
               08/11/2011 - Ajuste no campo aux_cdmotivo - passado p/ CHAR
                            Ajuste calculo juros/multa na procedure
                            retorna-valores-titulo-iptu (Rafael).
                            
               21/11/2011 - Ajuste no calculo de juros/multa - usado ROUND
                            com 2 casas decimais. (Rafael)
                            
               20/12/2011 - Buscar somente IF operantes quando validar
                            boleto no pagto (Rafael).
                                     
               10/02/2012 - Realizado a chamada para a procedure
                            verifica_feriado (Adriano).
                            
               16/03/2012 - Utilizar o valor de abatimento do boleto antes do 
                            calculo de juros/multa. (Rafael)
                            
               04/05/2012 - Ajuste no pagto DDA vencido. (Rafael)
               
               08/08/2012 - Ajuste da rotina de pagto de titulos descontados
                            da cob. registrada. (Rafael)
                            
               15/08/2012 - Acerto para nao criticar dois titulos com mesmo
                            numero de convenio, mesmo numero de documento e 
                            contas diferentes (Elton).
                            
               19/11/2012 - Titulos migrados para Alto Vale são interbancarios
                            quando pagos na Viacredi. (Rafael)
                            
               29/11/2012 - Ajuste na identificacao dos titulos 085. (Rafael)
               
               08/01/2013 - Ajuste no pagto de titulos migrados. (Rafael)
               
               11/01/2013 - Incluida condicao (craptco.tpctatrf <> 3) na
                            consulta da craptco (Tiago).
                          - Adicionado condicional especial para AltoVale em
                            proc. identifica-titulo-coop. (Jorge)
                            
               22/01/2013 - Ajuste na liquidacao de titulos de convenios
                            migrados 085. (Rafael)
                            
               21/02/2013 - Ajuste na liquidacao de titulos com CEB 5 digitos
                            do convenio 1343313 Viacredi. (Rafael)
                            
               21/03/2013 - Aumentar formato para evitar erros de conversao
                            na gera titulos iptu (Gabriel)             
                            
               09/05/2013 - Projeto VR Boleto - envio de pagto de titulos VR
                            por STR ao SPB. (Rafael)
                            
               20/05/2013 - Novo param. procedure 'grava-autenticacao-internet'
                            (Lucas).
               
               14/06/2013 - Alteração função enviar_email_completo para
                            nova versão (Jean Michel).
                            
               16/07/2013 - Alteracoes na procedure gera-tarifa-titulo para
                            buscar dados da tarifa na b1wgen0153 e criar 
                            lancamentos na craplat ao inves da craplcm
                            (Tiago/Daniel).
                            
               19/07/2013 - Incluso novo parametro na procedure pega_valor_tarifas e
                            alterado procedure gera-tarifa-titulo para diferenciar
                            valores cdfvlcop. (Daniel)
               
               01/10/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               10/10/2013 - Incluido parametro cdprogra nas procedures da 
                            b1wgen0153 que carregam dados de tarifas (Tiago).             
                            
               17/12/2013 - Adicionado validate para as tabelas craplot,
                            crapchd (Tiago).             
                            
               18/12/2013 - Ajuste no pagto de titulos migrados. (Rafael)
               
               02/01/2014 - Ajuste no pagto de titulos migrados. (Rafael)
               
               07/01/2014 - Ajuste no pagto de titulos migrados. (Rafael)
               
               04/02/2014 - Ajuste Projeto Novo Fator de Vencimento (Daniel).
               
               14/02/2014 - Deletar instancia da BO 87 (Gabriel).
               
               09/05/2014 - Tratamento para nao aceitar titulos do banco Real 
                            (Elton).
                            
               09/05/2014 - Ajusta na procedure gera-titulos-iptu para tratar
                            erro na chamada b1wgen0089, retirado flgativo 
                            igual a TRUE (Daniel).             
                            
               17/05/2014 - Nao aceita titulos do banco 409 - Unibanco (Elton).             
               
               23/06/2014 - Efetuar a validacao de codigo de barras fraudulento
			                (Chamado 152909) - (Andrino-RKAM).

               25/06/2014 - Calcular FV apenas quando FV for diferente de zero,
                            pois pode haver pagto de boletos com fator de
                            vencimento zerado. (Rafael).
                            
               16/06/2014 - Implementacao da consistencia de cod-operador diferente
                            de "DDA" para aceitar o pagamento de boletos com valores
                            diferentes, calculados por nosso sistema e calculados 
                            pelo DDA (Carlos Rafael).                            
                            
               22/07/2014 - #179456 - Sufixo do campo aux_nrctrlif respeite a 
                            origem do pagamento efetuado (I=Internet Banking / 
                            C=Caixa Online); - Envie PA, caixa e operador 
                            corretos para a b1wgen0046.proc_envia_vr_boleto.
                            (Carlos)	 

               28/07/2014 - Devido ao desativaçao dos convenios com 5 digitos 
                            foi retirado tratamento para 5 digitos na identifica-titulo-coop
                            (Odirlei - AMcom)

               20/08/2014 - Nao utilizar a cooperativa para leitura na crapcbf
			                (Chamado 152909) - (Andrino-RKAM).
               
               12/11/2014 - Modificado email para onde era enviado os alertas quando realizado o pagamento
                            de um VR boleto, de "convenios@cecred.coop.br" para "compe@cecred.coop.br". (Kelvin)
                            
               05/12/2014 - De acordo com a circula 3.656 do Banco Central, substituir nomenclaturas 
                            Cedente por Beneficiário e  Sacado por Pagador 
                            Chamado 229313 (Jean Reddiga - RKAM).    
               
               12/12/2014 - Tratamento para nao aceitar titulos do Banco Santander (353).
                            (Jaison - SD: 231108)
                            
               12/03/2015 - #202833 Tratamento para nao aceitar titulos do 
                            banco Boavista (231) (Carlos)
                            
               28/04/2015 - #267196 Tratamento para nao aceitar titulos do 
                            banco Standard (012) (Carlos)
                            
               02/07/2015 - #302133 Tratamento para nao aceitar titulos do 
                            banco Itaubank (479) (Carlos)
                            
               01/10/2015 - Ajuste nas rotinas gera-titulos-iptu e identifica-titulo-coop
                            para incluir na criacao da crapcob a informacao no nosso numero
                            SD339759 (Odirlei-AMcom)    

               26/10/2015 - Inclusao de verificacao indicador estado de crise na 
                            retorna-valores-titulo-iptu. (Jaison/Andrino)
                            
               06/11/2015 - Incluso ajuste referente projeto Cobranca de Emprestimo (Daniel)                      
               
               30/11/2015 - Ajuste na rotina retorna-valores-titulo-iptu para
                            pagamento de VR Boleto no ultimo dia do ano
                            (Tiago/Elton SD364467 melhoria 261)
                            
               15/02/2016 - Inclusao do parametro conta na chamada da
                            carrega_dados_tarifa_cobranca. (Jaison/Marcos)

               23/03/2016 - Alterar calculo do digito verificado para pagamentos de 
                            titulos na procedure identifica-titulo-coop para calcular
                            conforme a rotina do caixa online de estorno MOD11
                            (Lucas Ranghetti #421963,#410478 ).
                            
               24/08/2016 - #456682 Atualizacao do campo crapcbf.dscodbar para 
                            dsfraude e inclusao do campo crapcbf.tpfraude (Carlos)

               06/10/2016 - Incluido tratamento na procedure identifica-titulo-coop,
							para origem de "ACORDO", Prj. 302 (Jean Michel).

			   26/05/2018 - Ajustes referente alteracao da nova marca (P413 - Jonata Mouts).

			   03/09/2018 - Correção para remover lote (Jonata - Mouts).

............................................................................ */

/*---------------------------------------------------------------------*/
/*  b2crap14.p - Entrada Arrecadacoes  (Titulos/IPTU) - Antigo LANTIT  */
/*---------------   -----------------------------------------------------*/

{dbo/bo-erro1.i}
{ sistema/generico/includes/b1wgen0030tt.i } 
{ includes/var_cobregis.i }
{ sistema/generico/includes/b1wgen0079tt.i }

DEF VAR tar_cdhistor        AS INTE                                 NO-UNDO.
DEF VAR tar_cdhisest        AS INTE                                 NO-UNDO.
DEF VAR tar_dtdivulg        AS DATE                                 NO-UNDO.
DEF VAR tar_dtvigenc        AS DATE                                 NO-UNDO.
DEF VAR aux_cdfvlcop        AS INTE                                 NO-UNDO.

DEF VAR tar_cdfvlccx        AS INTE                                 NO-UNDO.
DEF VAR tar_cdfvlcnt        AS INTE                                 NO-UNDO.
DEF VAR tar_cdfvltaa        AS INTE                                 NO-UNDO.

DEF VAR tar_vlrtarcx        AS DECI                                 NO-UNDO.
DEF VAR tar_vlrtarnt        AS DECI                                 NO-UNDO.
DEF VAR tar_vltrftaa        AS DECI                                 NO-UNDO.

DEF VAR tar_histarcx        AS INTE                                 NO-UNDO.
DEF VAR tar_histarnt        AS INTE                                 NO-UNDO.
DEF VAR tar_histrtaa        AS INTE                                 NO-UNDO.
                                                                            
DEF VAR tar_inpessoa        AS INTE                                 NO-UNDO.

DEF VAR i-cod-erro          AS INTEGER                              NO-UNDO.
DEF VAR c-desc-erro         AS CHAR                                 NO-UNDO.

DEF VAR in99                AS INTE                                 NO-UNDO.

DEF VAR de-valor-calc       AS DEC                                  NO-UNDO.
DEF VAR de-campo            AS DECIMAL FORMAT "99999999999999"      NO-UNDO.
DEF VAR de-p-titulo5        AS DEC                                  NO-UNDO.  
DEF VAR dt-dtvencto         AS DATE                                 NO-UNDO.

DEF VAR i-nro-lote          LIKE craplft.nrdolote                   NO-UNDO.
DEF VAR i-digito            AS INTE                                 NO-UNDO.
DEF VAR i-cdhistor          AS INTE                                 NO-UNDO.

DEF VAR tab_intransm        AS INT                                  NO-UNDO.
DEF VAR tab_hrlimite        AS INT                                  NO-UNDO.

DEF VAR p-nro-digito        AS INTE                                 NO-UNDO.
DEF VAR p-retorno           AS LOG                                  NO-UNDO.
DEF VAR p-literal           AS CHAR                                 NO-UNDO.   
DEF VAR p-ult-sequencia     AS INTE                                 NO-UNDO.
DEF VAR p-registro          AS RECID                                NO-UNDO.

DEF VAR h-b1crap00          AS HANDLE                               NO-UNDO.
DEF VAR h-b1craplot         AS HANDLE                               NO-UNDO.
DEF VAR h-b1craplcm         AS HANDLE                               NO-UNDO.

DEF VAR h-b1wgen0030        AS HANDLE                               NO-UNDO.
DEF VAR h-b1wgen0023        AS HANDLE                               NO-UNDO.
DEF VAR h-b1wgen0044        AS HANDLE                               NO-UNDO.
DEF VAR h-b1wgen0153        AS HANDLE                               NO-UNDO.
DEF TEMP-TABLE tt-erro      NO-UNDO     LIKE craperr. 

DEF TEMP-TABLE cratlot      NO-UNDO     LIKE craplot.
DEF TEMP-TABLE cratlcm      NO-UNDO     LIKE craplcm.
DEF TEMP-TABLE tt-descontar NO-UNDO     LIKE tt-titulos.


                 
PROCEDURE retorna-valores-titulo-iptu.
                                      
    DEF INPUT  PARAM p-cooper           AS CHAR.
    DEF INPUT  PARAM p-nrdconta         AS INTE.
    DEF INPUT  PARAM p-idseqttl         LIKE crapttl.idseqttl.
    DEF INPUT  PARAM p-cod-operador     AS CHAR.
    DEF INPUT  PARAM p-cod-agencia      AS INTE.
    DEF INPUT  PARAM p-nro-caixa        AS INTE.
   
    DEF INPUT-OUTPUT  PARAM p-titulo1   AS DEC. /* FORMAT "99999,99999"  */
    DEF INPUT-OUTPUT  PARAM p-titulo2   AS DEC. /* FORMAT "99999,999999" */    
    DEF INPUT-OUTPUT  PARAM p-titulo3   AS DEC. /* FORMAT "99999,999999" */
    DEF INPUT-OUTPUT  PARAM p-titulo4   AS DEC. /* FORMAT "9"            */
    DEF INPUT-OUTPUT  PARAM p-titulo5   AS DEC. /* FORMAT "zz,zzz,zzz,zzz999"*/ 

    DEF INPUT-OUTPUT  PARAM p-codigo-barras AS CHAR. 
     
    DEF INPUT   PARAM p-iptu            AS LOG. 
     
    DEF INPUT   PARAM p-valor-informado AS DEC.
   
    DEF INPUT   PARAM p-cadastro        AS DEC. 
    DEF INPUT   PARAM p-cadastro-conf   AS DEC.
    DEF INPUT   PARAM p-dt-agendamento  AS DATE.
    DEF OUTPUT  PARAM p-vlfatura        AS DEC.
    DEF OUTPUT  PARAM p-outra-data      AS LOG.
    DEF OUTPUT  PARAM p-outro-valor     AS LOG.
    DEF OUTPUT  PARAM p-nrdconta-cob    AS INT.
    DEF OUTPUT  PARAM p-insittit        AS INT.
    DEF OUTPUT  PARAM p-intitcop        AS INT.
    DEF OUTPUT  PARAM p-convenio        AS DEC.
    DEF OUTPUT  PARAM p-bloqueto        AS DEC.
    DEF OUTPUT  PARAM p-contaconve      AS INT. 

    DEF OUTPUT  PARAM par_cobregis      AS LOGICAL                    NO-UNDO.
    DEF OUTPUT  PARAM par_msgalert      AS CHARACTER                  NO-UNDO.
    DEF OUTPUT  PARAM par_vlrjuros      AS DECIMAL                    NO-UNDO.
    DEF OUTPUT  PARAM par_vlrmulta      AS DECIMAL                    NO-UNDO.
    DEF OUTPUT  PARAM par_vldescto      AS DECIMAL                    NO-UNDO.
    DEF OUTPUT  PARAM par_vlabatim      AS DECIMAL                    NO-UNDO.
    DEF OUTPUT  PARAM par_vloutdeb      AS DECIMAL                    NO-UNDO.
    DEF OUTPUT  PARAM par_vloutcre      AS DECIMAL                    NO-UNDO.

    DEFINE VARIABLE v-critica-data      AS LOGICAL INITIAL FALSE.
    DEF    VARIABLE h-b1wgen0011        AS HANDLE                     NO-UNDO.
        
    DEFINE VARIABLE aux_nrdcaixa        LIKE crapaut.nrdcaixa         NO-UNDO.
    DEFINE VARIABLE aux-bloqueto2       AS DECIMAL                    NO-UNDO.
    DEFINE VARIABLE aux_vldcdbar        AS DECIMAL                    NO-UNDO.

    DEFINE VARIABLE aux_contador AS INTEGER                           NO-UNDO.
    DEFINE VARIABLE flg_cdbarerr AS LOGICAL                           NO-UNDO.

    DEFINE VARIABLE aux_hrvrbini AS INTE                              NO-UNDO.
    DEFINE VARIABLE aux_hrvrbfim AS INTE                              NO-UNDO.
    DEFINE VARIABLE aux_idtitdda AS DECI INIT 0                       NO-UNDO.
    DEFINE VARIABLE aux_conteudo AS CHAR                              NO-UNDO.

    /* Tratamento especifico para VR Boletos */
    ASSIGN aux_idtitdda = DECI(ENTRY(2,p-codigo-barras,";")) NO-ERROR.

    IF  ERROR-STATUS:ERROR THEN
        ASSIGN aux_idtitdda = 0.

    /* Se titulo for VR Boleto e DDA, remover idtitdda do código de barras */
    IF  aux_idtitdda > 0 THEN
        p-codigo-barras = ENTRY(1,p-codigo-barras,";") NO-ERROR.

    /* Tratamento de erros para internet e TAA */
    IF  p-cod-agencia = 90   OR
        p-cod-agencia = 91   THEN
        aux_nrdcaixa = INT(STRING(p-nrdconta) + STRING(p-idseqttl)).
    ELSE
        aux_nrdcaixa = p-nro-caixa.
         

    ASSIGN p-vlfatura    = 0
           p-outra-data  = NO
           p-outro-valor = NO.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT aux_nrdcaixa).
    
    IF p-valor-informado = 0 THEN
       DO:
           ASSIGN i-cod-erro  = 0
                  c-desc-erro = "Valor deve ser informado".
           RUN cria-erro (INPUT p-cooper,
                          INPUT p-cod-agencia,
                          INPUT aux_nrdcaixa,
                          INPUT i-cod-erro,
                          INPUT c-desc-erro,
                          INPUT YES).
           RETURN "NOK".
       
       END.
    

    FIND crapcop WHERE crapcop.nmrescop = p-cooper 
                       NO-LOCK NO-ERROR.
    
    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.

    IF p-iptu = YES  THEN   
       ASSIGN i-nro-lote = 17000 + p-nro-caixa.
    ELSE
       ASSIGN i-nro-lote = 16000 + p-nro-caixa.

    /* Verificar C¢digo Barras / Linha Digit vel - D¡gito/C¢digo */
    IF p-iptu = NO THEN  /* Titulo */
       DO:         
           /*  Tabela com o horario limite para digitacao  */
           FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper AND
                              craptab.nmsistem = "CRED"           AND
                              craptab.tptabela = "GENERI"         AND
                              craptab.cdempres = 0                AND
                              craptab.cdacesso = "HRTRTITULO"     AND
                              craptab.tpregist = p-cod-agencia    
                              NO-LOCK NO-ERROR.
    
           IF NOT AVAIL craptab  THEN  
              DO:
                  ASSIGN i-cod-erro  = 676           
                         c-desc-erro = " ".
                  RUN cria-erro (INPUT p-cooper,
                                 INPUT p-cod-agencia,
                                 INPUT aux_nrdcaixa,
                                 INPUT i-cod-erro,
                                 INPUT c-desc-erro,
                                 INPUT YES).
                  RETURN "NOK".

              END.
       
           ASSIGN tab_intransm = INT(SUBSTRING(craptab.dstextab,1,1))
                  tab_hrlimite = INT(SUBSTRING(craptab.dstextab,3,5)).
          
           /* Busca o indicador estado de crise */
           FIND craptab WHERE craptab.cdcooper = 0           AND
                              craptab.nmsistem = "CRED"      AND
                              craptab.tptabela = "GENERI"    AND
                              craptab.cdempres = 0           AND
                              craptab.cdacesso = "ESTCRISE"  AND
                              craptab.tpregist = 0           
                              NO-LOCK NO-ERROR.
        
           IF AVAIL craptab  THEN  
              DO:
                  /* Se estiver setado como estado de crise */
                  IF craptab.dstextab = "S" THEN
                     DO:
                         ASSIGN i-cod-erro  = 0
                                c-desc-erro = "Sistema em estado de crise. VR Boleto nao permitido!".
                         RUN cria-erro (INPUT p-cooper,
                                        INPUT p-cod-agencia,
                                        INPUT aux_nrdcaixa,
                                        INPUT i-cod-erro,
                                        INPUT c-desc-erro,
                                        INPUT YES).
                         RETURN "NOK".
                     END.
              END.
          
           IF  p-titulo1 <> 0 OR
               p-titulo2 <> 0 OR
               p-titulo3 <> 0 OR
               p-titulo4 <> 0 OR
               p-titulo5 <> 0 THEN 
               DO:
                   ASSIGN de-valor-calc = p-titulo1.  
                     /*  Calcula digito- Primeiro campo da linha digitavel  */

                   RUN dbo/pcrap03.p (INPUT-OUTPUT de-valor-calc,
                                      INPUT        TRUE,  /* Validar zeros */ 
                                            OUTPUT p-nro-digito,
                                            OUTPUT p-retorno).
                   
                   IF p-retorno = NO  THEN 
                      DO: 
                          ASSIGN i-cod-erro  =  8           
                                 c-desc-erro = " ".
                          RUN cria-erro (INPUT p-cooper,
                                         INPUT p-cod-agencia,
                                         INPUT aux_nrdcaixa,
                                         INPUT i-cod-erro,
                                         INPUT c-desc-erro,
                                         INPUT YES).
                          RETURN "NOK".

                      END.

                   ASSIGN de-valor-calc = p-titulo2.  
                   /*  Calcula digito  - Segundo campo da linha digitavel  */
                   RUN dbo/pcrap03.p (INPUT-OUTPUT de-valor-calc,
                                      INPUT        FALSE,  /* Validar zeros */
                                            OUTPUT p-nro-digito,
                                            OUTPUT p-retorno).

                   IF p-retorno = NO THEN 
                      DO: 
                          ASSIGN i-cod-erro  = 8           
                                 c-desc-erro = " ".
                          RUN cria-erro (INPUT p-cooper,
                                         INPUT p-cod-agencia,
                                         INPUT aux_nrdcaixa,
                                         INPUT i-cod-erro,
                                         INPUT c-desc-erro,
                                         INPUT YES).
                          RETURN "NOK".

                      END.

                   ASSIGN de-valor-calc = p-titulo3.  
                   /*  Calcula digito  - Terceiro campo da linha digitavel  */
                   RUN dbo/pcrap03.p (INPUT-OUTPUT de-valor-calc,
                                      INPUT        FALSE,  /* Validar zeros */
                                            OUTPUT p-nro-digito,
                                            OUTPUT p-retorno).

                   IF p-retorno = NO  THEN 
                      DO: 
                          ASSIGN i-cod-erro  = 8           
                                 c-desc-erro = " ".
                          RUN cria-erro (INPUT p-cooper,
                                         INPUT p-cod-agencia,
                                         INPUT aux_nrdcaixa,
                                         INPUT i-cod-erro,
                                         INPUT c-desc-erro,
                                         INPUT YES).
                          RETURN "NOK".

                      END.

                   /*  Compoe o codigo de barras atraves da linha digitavel  */
                   ASSIGN p-codigo-barras = 
                           SUBSTRING(STRING(p-titulo1,"9999999999"),1,4)   +
                           STRING(p-titulo4,"9")                 +
                           STRING(p-titulo5,"99999999999999")    +
                           SUBSTRING(STRING(p-titulo1,"9999999999"),5,1)   +
                           SUBSTRING(STRING(p-titulo1,"9999999999"),6,4)   +
                           SUBSTRING(STRING(p-titulo2,"99999999999"),1,10) +
                           SUBSTRING(STRING(p-titulo3,"99999999999"),1,10).

               END.
           ELSE 
               DO: /* Compäe a Linha Digit vel atrav‚s do C¢digo de Barras */
                   /* validar tamanho de 44 caracteres no codigo de barras e
                      somente aceitar algarismo 0-9 */
                   ASSIGN flg_cdbarerr = FALSE.

                   DO aux_contador = 1 TO 44:
                      IF  NOT CAN-DO("0,1,2,3,4,5,6,7,8,9",
                                    SUBSTR(p-codigo-barras,aux_contador,1)) THEN
                      DO:
                          flg_cdbarerr = TRUE.
                          LEAVE.
                      END.

                   END.

                   IF LENGTH(p-codigo-barras) <> 44  THEN 
                      flg_cdbarerr = TRUE.
                   
                   IF flg_cdbarerr  THEN 
                      DO:
                          ASSIGN i-cod-erro  = 0
                                 c-desc-erro = "Codigo de Barras invalido.".
                          RUN cria-erro (INPUT p-cooper,
                                         INPUT p-cod-agencia,
                                         INPUT aux_nrdcaixa,
                                         INPUT i-cod-erro,
                                         INPUT c-desc-erro,
                                         INPUT YES).

                          RETURN "NOK".

                      END.
           
                   ASSIGN p-titulo1 = DECIMAL(SUBSTRING(p-codigo-barras,01,04)
                                      + SUBSTRING(p-codigo-barras,20,01) +
                                      SUBSTRING(p-codigo-barras,21,04) + "0")
                          p-titulo2 = DECIMAL(SUBSTRING(p-codigo-barras,
                                                                25,10) + "0")
                          p-titulo3 = DECIMAL(SUBSTRING(p-codigo-barras,
                                                                35,10) + "0")
                          p-titulo4 = INTEGER(SUBSTRING(p-codigo-barras,
                                                                      05,01))
                          p-titulo5 = DECIMAL(SUBSTRING(p-codigo-barras,
                                                                      06,14)).
        
                   /**- VERIFICA COM EDSON A VALIDACAO DE LINHA DIGITAVEL -*/
                   ASSIGN de-valor-calc = p-titulo1.  
                   /*  Calcula digito- Primeiro campo da linha digitavel  */

                   RUN dbo/pcrap03.p (INPUT-OUTPUT de-valor-calc,
                                      INPUT        TRUE,  /* Validar zeros */
                                            OUTPUT p-nro-digito,
                                            OUTPUT p-retorno).
                   ASSIGN p-titulo1 = de-valor-calc.
                   /*
                   IF  p-retorno = NO  THEN 
                       DO:
                           ASSIGN i-cod-erro  = 8           
                                  c-desc-erro = " ".
                           RUN cria-erro (INPUT p-cooper,
                                          INPUT p-cod-agencia,
                                          INPUT aux_nrdcaixa,
                                          INPUT i-cod-erro,
                                          INPUT c-desc-erro,
                                          INPUT YES).
                           RETURN "NOK".
                       END.
                   */
                   ASSIGN de-valor-calc = p-titulo2.  
                   /*  Calcula digito  - Segundo campo da linha digitavel  */
                   RUN dbo/pcrap03.p (INPUT-OUTPUT de-valor-calc,
                                      INPUT        FALSE,  /* Validar zeros */
                                            OUTPUT p-nro-digito,
                                            OUTPUT p-retorno).
                   ASSIGN p-titulo2 = de-valor-calc.
                   /*
                   IF  p-retorno = NO  THEN 
                       DO:
                           ASSIGN i-cod-erro  = 8
                                  c-desc-erro = " ".
                           RUN cria-erro (INPUT p-cooper,
                                          INPUT p-cod-agencia,
                                          INPUT aux_nrdcaixa,
                                          INPUT i-cod-erro,
                                          INPUT c-desc-erro,
                                          INPUT YES).
                           RETURN "NOK".
                       END.
                   */
                   ASSIGN de-valor-calc = p-titulo3.  
                   /*  Calcula digito  - Terceiro campo da linha digitavel  */
                   RUN dbo/pcrap03.p (INPUT-OUTPUT de-valor-calc,
                                      INPUT        FALSE,  /* Validar zeros */
                                            OUTPUT p-nro-digito,
                                            OUTPUT p-retorno).
                   ASSIGN p-titulo3 = de-valor-calc.
                   /*
                   IF  p-retorno = NO  THEN 
                       DO:
                           ASSIGN i-cod-erro  = 8
                                  c-desc-erro = " ".
                           RUN cria-erro (INPUT p-cooper,
                                          INPUT p-cod-agencia,
                                          INPUT aux_nrdcaixa,
                                          INPUT i-cod-erro,
                                          INPUT c-desc-erro,
                                          INPUT YES).
                           RETURN "NOK".
                       END. 
                   */
               END.
           
           ASSIGN de-valor-calc = DEC(p-codigo-barras).
           
           /* C lculo D¡gito Verificador  - T¡tulo */
           RUN dbo/pcrap05.p (INPUT de-valor-calc,  
                              OUTPUT p-retorno).

           IF p-retorno = NO THEN 
              DO:        
                  ASSIGN i-cod-erro  = 8           
                         c-desc-erro = " ".
                  RUN cria-erro (INPUT p-cooper,
                                 INPUT p-cod-agencia,
                                 INPUT aux_nrdcaixa,
                                 INPUT i-cod-erro,
                                 INPUT c-desc-erro,
                                 INPUT YES).

                  RETURN "NOK".

              END. 
              
           /* Verificar se o codigo de barras eh fraudulento - (Andrino-RKAM) */
           FIND crapcbf WHERE crapcbf.tpfraude = 1 AND 
                              crapcbf.dsfraude = p-codigo-barras NO-LOCK NO-ERROR.

           IF avail crapcbf THEN
              DO:

                  RUN sistema/generico/procedures/b1wgen0011.p PERSISTENT SET h-b1wgen0011.

                  ASSIGN aux_conteudo = "<b>Atencao! Houve tentativa de pagamento de codigo de barras fraudulento.<br>" + 
                                        "Conta: </b>" + STRING(p-nrdconta,"zzzz,zzz,9") + "<br>" +
                                        "<b>Cod. Barras: </b>" + p-codigo-barras.

                  RUN enviar_email_completo IN h-b1wgen0011
                       (INPUT crapcop.cdcooper,
                        INPUT "INTERNETBANK",
                        INPUT "cpd@ailos.coop.br",
                        INPUT "prevencaodefraudes@ailos.coop.br",
                        INPUT "Tentativa de pagamento cod. barras fraudulento" ,
                        INPUT "",
                        INPUT "",
                        INPUT aux_conteudo,
                        INPUT TRUE).

                  DELETE PROCEDURE h-b1wgen0011.
                  
                  ASSIGN i-cod-erro  = 0           
                         c-desc-erro = "Dados incompativeis. Pagamento nao realizado!".
                         
                  RUN cria-erro (INPUT p-cooper,
                                 INPUT p-cod-agencia,
                                 INPUT aux_nrdcaixa,
                                 INPUT i-cod-erro,
                                 INPUT c-desc-erro,
                                 INPUT YES).

                  RETURN "NOK".
              END. /* Fim da verificacao de codigo de barras fraudulento */
       END.
    
    IF p-iptu = YES  THEN   /* Processa IPTU */
       DO:   
           IF (INT(SUBSTR(p-codigo-barras, 16, 4)) = 557) AND /* Prefeitura*/
              (INT(SUBSTR(p-codigo-barras, 02, 1)) = 1)  THEN /* Cod.Segmto*/
              DO:  
                  IF (INT(SUBSTR(p-codigo-barras, 28, 3)) = 511)  THEN
                     DO: 
                         IF p-cadastro <> p-cadastro-conf   THEN
                            DO:                                 
                               ASSIGN i-cod-erro  = 841           
                                      c-desc-erro = " ".
                            
                               RUN cria-erro (INPUT p-cooper,
                                              INPUT p-cod-agencia,
                                              INPUT aux_nrdcaixa,
                                              INPUT i-cod-erro,
                                              INPUT c-desc-erro,
                                              INPUT YES).
                               RETURN "NOK".                             

                            END.
                       
                         IF p-cadastro = 0   THEN
                            DO:                                 
                               ASSIGN i-cod-erro  = 375           
                                      c-desc-erro = " ".
                               RUN cria-erro (INPUT p-cooper,
                                              INPUT p-cod-agencia,
                                              INPUT aux_nrdcaixa,
                                              INPUT i-cod-erro,
                                              INPUT c-desc-erro,
                                              INPUT YES).

                               RETURN "NOK".                             

                            END.
                              
                         ASSIGN SUBSTR(p-codigo-barras, 31, 10) =
                                STRING(p-cadastro, "9999999999").

                     END.
                       
                  FIND craptit WHERE
                       craptit.cdcooper = crapcop.cdcooper AND
                       craptit.dtmvtolt = crapdat.dtmvtocd AND
                       craptit.nrdconta = p-nrdconta       AND
                       craptit.cdagenci = p-cod-agencia    AND
                       craptit.cdbccxlt = 11               AND /* FIXO  */
                       craptit.nrdolote = i-nro-lote       AND
                       craptit.dscodbar = p-codigo-barras  
                       NO-LOCK NO-ERROR.

                  IF AVAIL craptit  THEN  
                     DO: 
                         ASSIGN i-cod-erro  = 92
                                c-desc-erro = " ".
                         RUN cria-erro (INPUT p-cooper,
                                        INPUT p-cod-agencia,
                                        INPUT aux_nrdcaixa,
                                        INPUT i-cod-erro,
                                        INPUT c-desc-erro,
                                        INPUT YES).
                         
                         RETURN "NOK".

                     END. 

                  FIND craptit WHERE craptit.cdcooper = crapcop.cdcooper AND
                                     craptit.dtmvtolt = crapdat.dtmvtocd AND
                                     craptit.dscodbar = p-codigo-barras  
                                     USE-INDEX craptit3 NO-LOCK NO-ERROR.

                  IF  AVAIL craptit  THEN  
                      DO:
                          ASSIGN i-cod-erro  = 456        
                                 c-desc-erro = " ".
                          RUN cria-erro (INPUT p-cooper,
                                         INPUT p-cod-agencia,
                                         INPUT aux_nrdcaixa,
                                         INPUT i-cod-erro,
                                         INPUT c-desc-erro,
                                         INPUT YES).

                          RETURN "NOK". 

                      END.
                                                    
                  ASSIGN p-outra-data = CAN-FIND(FIRST craptit WHERE
                                  craptit.cdcooper = crapcop.cdcooper AND
                                  craptit.dscodbar = p-codigo-barras NO-LOCK)
                         p-vlfatura = 
                                 DECIMAL(SUBSTR(p-codigo-barras,5,11)) / 100.
                                                       /* Retorna Valor */   
                   
              END.
           ELSE 
              DO:
                  ASSIGN i-cod-erro  = 100    
                         c-desc-erro = " ".
                  RUN cria-erro (INPUT p-cooper,
                                 INPUT p-cod-agencia,
                                 INPUT aux_nrdcaixa,
                                 INPUT i-cod-erro,
                                 INPUT c-desc-erro,
                                 INPUT YES).

                  RETURN "NOK".  

              END.
       
       END.        /* IPTU */
    ELSE                           
       DO:   /* T¡tulo */         
           IF (INT(SUBSTR(p-codigo-barras, 16, 4)) = 557) AND /* Prefeitura */
              (INT(SUBSTR(p-codigo-barras, 02, 1)) = 1)   THEN 
              DO:  
                  /* Cod. Segmto */
                  ASSIGN i-cod-erro  = 100    
                         c-desc-erro = " ".

                  RUN cria-erro (INPUT p-cooper,
                                 INPUT p-cod-agencia,
                                 INPUT aux_nrdcaixa,
                                 INPUT i-cod-erro,
                                 INPUT c-desc-erro,
                                 INPUT YES).

                  RETURN "NOK".  

              END.
           ELSE 
              DO:
                  FIND craptit WHERE
                       craptit.cdcooper = crapcop.cdcooper AND
                       craptit.dtmvtolt = crapdat.dtmvtocd AND
                       craptit.cdagenci = p-cod-agencia    AND
                       craptit.cdbccxlt = 11               AND /* FIXO */
                       craptit.nrdolote = i-nro-lote       AND
                       craptit.dscodbar = p-codigo-barras  
                       NO-LOCK NO-ERROR.

                  IF AVAIL craptit  THEN  
                     DO: 
                         ASSIGN i-cod-erro  = 92
                                c-desc-erro = " ".

                         RUN cria-erro (INPUT p-cooper,
                                        INPUT p-cod-agencia,
                                        INPUT aux_nrdcaixa,
                                        INPUT i-cod-erro,
                                        INPUT c-desc-erro,
                                        INPUT YES).

                         RETURN "NOK".

                     END. 

                  FIND craptit WHERE craptit.cdcooper = crapcop.cdcooper AND
                                     craptit.dtmvtolt = crapdat.dtmvtocd AND
                                     craptit.dscodbar = p-codigo-barras 
                                     USE-INDEX craptit3 NO-LOCK NO-ERROR.

                  IF AVAIL craptit  THEN  
                     DO:
                         ASSIGN i-cod-erro  = 456        
                                c-desc-erro = " ".

                         RUN cria-erro (INPUT p-cooper,
                                        INPUT p-cod-agencia,
                                        INPUT aux_nrdcaixa,
                                        INPUT i-cod-erro,
                                        INPUT c-desc-erro,
                                        INPUT YES).

                         RETURN "NOK". 

                     END.

                  ASSIGN p-outra-data = CAN-FIND(FIRST craptit WHERE
                                  craptit.cdcooper = crapcop.cdcooper AND
                                  craptit.dscodbar = p-codigo-barras NO-LOCK).
             
                  /*  Verifica a hora somente para a arrecadacao caixa  */
                  IF TIME >= tab_hrlimite AND
                     p-cod-agencia <> 90  AND
                     p-cod-agencia <> 91  THEN 
                     DO:
                         ASSIGN i-cod-erro  = 676           
                                c-desc-erro = " ".

                         RUN cria-erro (INPUT p-cooper,
                                        INPUT p-cod-agencia,
                                        INPUT aux_nrdcaixa,
                                        INPUT i-cod-erro,
                                        INPUT c-desc-erro,
                                        INPUT YES).

                         RETURN "NOK".

                     END. 

                  /* Valida transmissao do arquivo de titulos somente se */
                  /* nao for um agendamento de pagamento                */
                  IF p-dt-agendamento = ? AND
                     tab_intransm > 0     THEN  
                     DO:
                         ASSIGN i-cod-erro  = 677           
                                c-desc-erro = " ".

                         RUN cria-erro (INPUT p-cooper,
                                        INPUT p-cod-agencia,
                                        INPUT aux_nrdcaixa,
                                        INPUT i-cod-erro,
                                        INPUT c-desc-erro,
                                        INPUT YES).

                         RETURN "NOK".

                     END.            
                      
              END.
       END.

    IF p-iptu = NO THEN 
       DO: 
          IF p-titulo5 <> 0  THEN 
             DO:
                 ASSIGN de-campo     = DECI(SUBSTR(STRING(p-titulo5, 
                                                   "99999999999999"),1,4))
                        de-p-titulo5 = DECI(SUBSTR(STRING(p-titulo5,
                                                   "99999999999999"),5,10))
                        p-vlfatura   = de-p-titulo5 / 100.

                        /* Zimmermann
                        dt-dtvencto  = 10/07/1997 + de-campo.
                        */
                 
                 IF de-campo <> 0 THEN
                    DO:

                       RUN calcula_data_vencimento
                            (INPUT  crapdat.dtmvtolt,
                             INPUT  INT(de-campo),
                             OUTPUT dt-dtvencto,
                             OUTPUT i-cod-erro,
                             OUTPUT c-desc-erro).
    
                       IF  RETURN-VALUE = "NOK" THEN DO:
                           RUN cria-erro (INPUT p-cooper,
                                          INPUT p-cod-agencia,
                                          INPUT aux_nrdcaixa,
                                          INPUT i-cod-erro,
                                          INPUT c-desc-erro,
                                          INPUT YES).
    
                           RETURN "NOK".
                       END.

                       RUN verifica-vencimento-titulo (INPUT crapcop.cdcooper,
                                                       INPUT p-cod-agencia,
                                                       INPUT p-dt-agendamento,
                                                       INPUT dt-dtvencto,    
                                                       OUTPUT v-critica-data).
                                                                              
                       IF RETURN-VALUE = "NOK" THEN
                          DO: 
                             FIND FIRST tt-erro NO-LOCK NO-ERROR.
                             
                             IF AVAIL tt-erro THEN
                                DO:
                                    ASSIGN i-cod-erro  = 0
                                           c-desc-erro = tt-erro.dscritic.
                             
                                    RUN cria-erro (INPUT p-cooper,
                                                   INPUT p-cod-agencia,
                                                   INPUT aux_nrdcaixa,
                                                   INPUT i-cod-erro,
                                                   INPUT c-desc-erro,
                                                   INPUT YES).
                             
                                END.
                             ELSE
                                DO:
                                    ASSIGN i-cod-erro  = 0
                                           c-desc-erro = "Nao foi possivel " +
                                                         "realizar o pagamento.".
                             
                                    RUN cria-erro (INPUT p-cooper,
                                                   INPUT p-cod-agencia,
                                                   INPUT aux_nrdcaixa,
                                                   INPUT i-cod-erro,
                                                   INPUT c-desc-erro,
                                                   INPUT YES).
                             
                                END.
                             
                             RETURN "NOK".
                       
                          END.
                       
                    END.

             END.
          
          FIND crapban WHERE crapban.cdbccxlt = INT(SUBSTR(STRING(p-titulo1,
                                                "99999,99999"),1,3)) 
                                                NO-LOCK NO-ERROR.
            /*---
            AND crapban.flgdispb = TRUE NO-ERROR.
             ---*/
          IF NOT AVAIL crapban THEN  
             DO:
                 ASSIGN i-cod-erro  = 57 
                        c-desc-erro =  " ". /*" =  "  +  
                            SUBSTR(STRING(p-titulo1,"99999,99999"),1,3).*/
                 RUN cria-erro (INPUT p-cooper,
                                INPUT p-cod-agencia,
                                INPUT aux_nrdcaixa,
                                INPUT i-cod-erro,
                                INPUT c-desc-erro,
                                INPUT YES).

                RETURN "NOK". 

             END.
              
          IF  crapban.cdbccxlt = 012  OR    /*** Banco Standard ***/
              crapban.cdbccxlt = 231  OR    /*** Banco Boavista ***/
              crapban.cdbccxlt = 353  OR    /*** Banco Santander ***/
              crapban.cdbccxlt = 356  OR    /*** Banco Real ***/
              crapban.cdbccxlt = 409  OR    /*** Unibanco ***/
              crapban.cdbccxlt = 479  THEN  /*** Itaubank ***/
              DO:
                  ASSIGN i-cod-erro  = 57 
                        c-desc-erro =  " ". 
                  RUN cria-erro (INPUT p-cooper,
                                 INPUT p-cod-agencia,
                                 INPUT aux_nrdcaixa,
                                 INPUT i-cod-erro,
                                 INPUT c-desc-erro,
                                 INPUT YES).
                  RETURN "NOK".  
              END.


          FIND FIRST crapagb WHERE crapagb.cddbanco = crapban.cdbccxlt 
                               AND crapagb.cdsitagb = "S" /* Agencia Ativa */
                                   NO-LOCK NO-ERROR.

          IF NOT AVAIL crapagb THEN  
             DO:
                 ASSIGN i-cod-erro  = 956
                        c-desc-erro =  " ". 
                 RUN cria-erro (INPUT p-cooper,
                                INPUT p-cod-agencia,
                                INPUT aux_nrdcaixa,
                                INPUT i-cod-erro,
                                INPUT c-desc-erro,
                                INPUT YES).

                 RETURN "NOK". 

             END.

       END. /* p-iptu = no */
   
    RUN identifica-titulo-coop(INPUT  p-cooper,
                               INPUT  p-nrdconta,
                               INPUT  p-idseqttl,
                               INPUT  p-cod-agencia,
                               INPUT  INT(p-nro-caixa),
                               INPUT  p-codigo-barras,
                               INPUT  TRUE,
                               OUTPUT p-nrdconta-cob,
                               OUTPUT p-insittit,
                               OUTPUT p-intitcop,
                               OUTPUT p-convenio,
                               OUTPUT p-bloqueto,
                               OUTPUT p-contaconve).   
    
    IF RETURN-VALUE = "NOK" THEN
       RETURN "NOK".

    /* Nao eh permitido pagto de VR Boletos pelo TAA */
    IF  p-intitcop = 0     AND
        p-cod-agencia = 91 AND 
        p-iptu = NO        AND
        p-valor-informado >= 250000 AND
        TODAY >= 06/28/2013 THEN
        DO:
            ASSIGN i-cod-erro  = 0           
                   c-desc-erro = "Valor nao permitido para pagamento em TAA.".
  
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT aux_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
  
            RETURN "NOK".
        END.


    /* Nao eh permitido agendamento de VR Boletos */
    IF  p-iptu = NO     AND
        p-valor-informado >= 250000 AND
        TODAY >= 06/28/2013 AND
        p-dt-agendamento <> ? THEN
        DO:
            ASSIGN i-cod-erro  = 0           
                   c-desc-erro = "Valor nao permitido para agendamento.".

            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT aux_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).

            RETURN "NOK".
        END.

    /* Pagto de VR Boleto pelo InternetBanking, apenas pelo DDA */
    IF  p-intitcop = 0 AND 
        p-cod-agencia = 90 AND
        p-iptu = NO AND
        p-valor-informado >= 250000 AND
        TODAY >= 06/28/2013 AND
        aux_idtitdda = 0 THEN
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Valor permitido apenas pelo link " + 
                                 "de pagamentos DDA.".
    
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT aux_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
    
            RETURN "NOK".
        END.

    /* verificar dia util, horario e limite de pagto VR Boleto */
    IF  p-iptu = NO                   AND
        p-valor-informado >= 250000   AND 
        TODAY >= 06/28/2013 THEN
        DO:
            /* limite de pagto VR Boleto */
            FIND crapass WHERE 
                 crapass.cdcooper = crapcop.cdcooper AND
                 crapass.nrdconta = p-nrdconta
                 NO-LOCK NO-ERROR.

            IF  AVAIL crapass THEN
                DO:
                    FIND craptab WHERE 
                         craptab.cdcooper = crapcop.cdcooper  AND
                         craptab.nmsistem = "CRED"            AND
                         craptab.tptabela = "GENERI"          AND
                         craptab.cdempres = 0                 AND
                         craptab.cdacesso = "LIMINTERNT"      AND
                         craptab.tpregist = crapass.inpessoa
                         NO-LOCK NO-ERROR.

                    IF  AVAIL craptab THEN
                        DO:
                            IF  (crapass.inpessoa = 1 AND
                                 p-valor-informado > DECI(ENTRY(15,craptab.dstextab,";"))) OR
                                (crapass.inpessoa = 2 AND
                                 p-valor-informado > DECI(ENTRY(16,craptab.dstextab,";"))) THEN
                                DO:
                                    ASSIGN i-cod-erro  = 0
                                           c-desc-erro = "Pagamento de VR Boleto " + 
                                                         "superior ao limite operacional.".
    
                                    RUN cria-erro (INPUT p-cooper,
                                                   INPUT p-cod-agencia,
                                                   INPUT aux_nrdcaixa,
                                                   INPUT i-cod-erro,
                                                   INPUT c-desc-erro,
                                                   INPUT YES).
                                    RETURN "NOK".
                                END.
                        END.
                END.

            /* pagto de VR Boletos apenas para dias uteis */
            IF  CAN-DO("1,7",STRING(WEEKDAY(TODAY))) OR
                CAN-FIND(crapfer WHERE 
                         crapfer.cdcooper = crapcop.cdcooper  AND
                         crapfer.dtferiad = TODAY             AND
                         crapfer.dtferiad <> DATE("31/12/" + STRING(YEAR(TODAY))) )  THEN
                DO:
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = "Pagamento de VR Boletos " + 
                                         "permitido apenas em dias uteis.".
    
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT aux_nrdcaixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.

            FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper AND
                               craptab.nmsistem = "CRED"           AND
                               craptab.tptabela = "GENERI"         AND
                               craptab.cdempres = 0                AND
                               craptab.cdacesso = "HRVRBOLETO"     
                               NO-LOCK NO-ERROR.

            IF  NOT AVAIL craptab THEN
                DO:
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = "Parametro de pagto de VR Boletos " + 
                                         " nao encontrado.".

                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT aux_nrdcaixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.
            ELSE
                DO:                                       
                    IF  LOGICAL(ENTRY(1,craptab.dstextab,";")) = NO THEN
                        DO:
                            ASSIGN i-cod-erro  = 0
                                   c-desc-erro = "Pagamento de VR Boletos " + 
                                                 "bloqueado.".
            
                            RUN cria-erro (INPUT p-cooper,
                                           INPUT p-cod-agencia,
                                           INPUT aux_nrdcaixa,
                                           INPUT i-cod-erro,
                                           INPUT c-desc-erro,
                                           INPUT YES).
                            RETURN "NOK".
                        END.

                    ASSIGN aux_hrvrbini = INTE(ENTRY(2,craptab.dstextab,";"))
                           aux_hrvrbfim = INTE(ENTRY(3,craptab.dstextab,";"))
                           NO-ERROR.

                    IF  TIME < aux_hrvrbini OR
                        TIME > aux_hrvrbfim THEN
                        DO:
                            ASSIGN i-cod-erro  = 0
                                   c-desc-erro = "Horario excedido para pagto de " + 
                                                 "VR Boletos.".
    
                            RUN cria-erro (INPUT p-cooper,
                                           INPUT p-cod-agencia,
                                           INPUT aux_nrdcaixa,
                                           INPUT i-cod-erro,
                                           INPUT c-desc-erro,
                                           INPUT YES).
                            RETURN "NOK".
                        END.
                END.
        END.


    /* verificar se VR Boleto pertence a outra cooperativa associada */
    IF  p-iptu = NO                   AND
        p-intitcop = 0                AND 
        p-valor-informado >= 250000   AND
        TODAY >= 06/28/2013           AND
        SUBSTR(p-codigo-barras,1,3) = "085" THEN
        DO:
            INT(SUBSTR(p-codigo-barras,20,4)) NO-ERROR.

            IF  NOT ERROR-STATUS:ERROR THEN
                DO:
                   /* Verifica se conv boleto é de cobranca 085 */
                   FIND FIRST crapcco WHERE 
                        SUBSTR(STRING(crapcco.nrconven,"9999999"),2,4)
                          = SUBSTR(p-codigo-barras,20,4) AND
                        crapcco.cddbanco = 085           AND
                   /*     crapcco.flgativo = TRUE          AND */
                        crapcco.dsorgarq <> "MIGRACAO" 
                        NO-LOCK NO-ERROR.

                   IF  AVAIL crapcco THEN
                       DO:
                           ASSIGN i-cod-erro  = 0
                                  c-desc-erro = "VR Boleto deve ser pago " + 
                                                "apenas na cooperativa do " +
                                                "beneficiario.".
    
                           RUN cria-erro (INPUT p-cooper,
                                          INPUT p-cod-agencia,
                                          INPUT aux_nrdcaixa,
                                          INPUT i-cod-erro,
                                          INPUT c-desc-erro,
                                          INPUT YES).

                           RETURN "NOK".
                       END.
                END.
        END.
     
    /********************************************************/
    /***********FAZER CALCULO DO VALOR DO TITULO*************/
    IF p-intitcop = 1 THEN /* Se for título da cooperativa */
       DO:
           /* Verifica se conv boleto é de cobranca 085 */
           FIND crapcco WHERE crapcco.cdcooper = crapcop.cdcooper      AND
                              crapcco.nrconven = INTEGER(p-convenio)   AND
                              crapcco.cddbanco = crapcop.cdbcoctl      AND
                          /*    crapcco.flgativo = TRUE                  AND */
                              crapcco.dsorgarq <> "MIGRACAO" 
                              NO-LOCK NO-ERROR.
           
           /* Se for cobranca registrada, 
              calcular o valor do titulo conforme instrução */
           IF AVAIL crapcco THEN
              DO:
                  FIND crapceb WHERE crapceb.cdcooper = crapcop.cdcooper   AND
                                     crapceb.nrconven = INT(p-convenio)    AND
                                     crapceb.nrcnvceb =                            
                                        INTEGER(SUBSTR(p-codigo-barras, 33, 4))
                                     NO-LOCK NO-ERROR.
                                         
                  /* Quando for boleto da cooperativa, 
                     retira o codigo CEB do documento */
                  IF  AVAIL crapceb THEN
                      DO:
                        IF  crapcco.cddbanco = 085 THEN
                            aux-bloqueto2 = p-bloqueto.
                        ELSE
                            aux-bloqueto2 = DEC(SUBSTR(STRING(p-bloqueto),
                                            LENGTH(STRING(p-bloqueto)) - 5 ,6)).
                      END.  
                  ELSE
                     aux-bloqueto2 = p-bloqueto.
                  
                  FIND crapcob WHERE crapcob.cdcooper = crapcop.cdcooper AND
                                     crapcob.nrcnvcob = INT(p-convenio)  AND
                                     crapcob.nrdconta = p-nrdconta-cob   AND
                                     crapcob.nrdocmto = aux-bloqueto2    AND
                                     crapcob.cdbandoc = crapcco.cddbanco AND
                                     crapcob.nrdctabb = p-contaconve
                                     NO-LOCK NO-ERROR.
              
                  IF NOT AVAIL crapcob THEN  
                     DO:
                         ASSIGN i-cod-erro  = 11
                                c-desc-erro = " ".           
                     
                         RUN cria-erro (INPUT p-cooper,
                                        INPUT p-cod-agencia,
                                        INPUT p-nro-caixa,
                                        INPUT i-cod-erro,
                                        INPUT c-desc-erro,
                                        INPUT YES).
                         RETURN "NOK".

                     END.
                  /******* Dados das instrucoes 
                  crapcob.cdmensag = 2 (Conceder desconto apos vencto)
                  crapcob.tpjurmor (1=Valor por dia, 2=Taxa mensal, 3=isento);
                  crapcob.vljurdia = valor dos juros de mora conforme acima;
                  crapcob.tpdmulta (1=Valor R$, 2= % de multa ref ao valor de 
                                   face do título (crapcob.vltitulo), 3=isento);
                  crapcob.vlrmulta = valor da multa conforme acima;
                  crapcob.vldescto = valor de desconto do título 
                                     (até o vencimento);
                  **************************/
              
                  /* Este mesmo calculo eh usado no crps538, caso alterar aqui
                     nao esquecer de alterar la tambem */
              
                  /* Parametros de saida da cobranca registrada */ 
                  ASSIGN par_vlrjuros = 0
                         par_vlrmulta = 0
                         par_vldescto = 0
                         par_vlabatim = 0
                         par_vloutdeb = 0
                         par_vloutcre = 0
                         p-vlfatura = crapcob.vltitulo.
                  
                  /* trata o desconto */
                  /* se concede apos o vencimento */
                  IF (crapcob.cdmensag = 2)  THEN
                     ASSIGN par_vldescto = crapcob.vldescto
                            p-vlfatura = p-vlfatura - par_vldescto.

                  /* utilizar o abatimento antes do calculo de juros/multa */
                  IF crapcob.vlabatim > 0 THEN
                     ASSIGN par_vlabatim = crapcob.vlabatim
                            p-vlfatura = p-vlfatura - par_vlabatim.

                  /* Verifica se o titulo esta Vencido */
                  RUN verifica-vencimento-titulo (INPUT crapcop.cdcooper,
                                                  INPUT p-cod-agencia,
                                                  INPUT p-dt-agendamento,
                                                  INPUT crapcob.dtvencto,    
                                                  OUTPUT v-critica-data).

                  /* verifica se o titulo esta vencido */
                  IF v-critica-data  THEN
                     DO:
                         /* MULTA PARA ATRASO */
                         IF crapcob.tpdmulta = 1  THEN /* Valor */
                            ASSIGN par_vlrmulta = crapcob.vlrmulta
                                   p-vlfatura   = p-vlfatura + par_vlrmulta.
                         ELSE
                         IF crapcob.tpdmulta = 2  THEN /* % de multa do valor  do boleto */
                            ASSIGN par_vlrmulta = ROUND(((crapcob.vlrmulta / 
                                                  100) * crapcob.vltitulo),2)
                                   p-vlfatura   = p-vlfatura + par_vlrmulta.
                     
                         /* MORA PARA ATRASO */
                         IF crapcob.tpjurmor = 1  THEN /* dias */
                            ASSIGN par_vlrjuros = ROUND((crapcob.vljurdia * 
                                       (crapdat.dtmvtocd - crapcob.dtvencto)),2)
                                   p-vlfatura   = p-vlfatura + par_vlrjuros.
                         ELSE
                         IF crapcob.tpjurmor = 2  THEN /* mes */
                            ASSIGN par_vlrjuros = ROUND((crapcob.vltitulo * 
                                      ((crapcob.vljurdia / 100) / 30) * 
                                      (crapdat.dtmvtocd - crapcob.dtvencto)),2)
                                   p-vlfatura   = p-vlfatura + par_vlrjuros.
                        
                     END.
                  ELSE
                     DO:
                         /* se concede apos vencto, ja calculou */
                         IF crapcob.cdmensag <> 2  THEN
                            ASSIGN par_vldescto = crapcob.vldescto
                                   p-vlfatura = p-vlfatura - par_vldescto.
                         /*ASSIGN par_vlabatim = crapcob.vlabatim
                                p-vlfatura = p-vlfatura - par_vlabatim.*/
                     
                     END.
                 
                  /* Para cobranca registrada nao permite pagar valor menor que o valor do docto 
                     calculando desconto juros abatimento e multa 
                  */
                  IF ROUND(p-valor-informado,2) < ROUND(p-vlfatura,2) AND p-cod-operador <> "DDA"  THEN
                     DO:
                         ASSIGN i-cod-erro  = 0     
                                c-desc-erro = "Cob. Reg. - Valor informado " + 
                                STRING(p-valor-informado, "zzz,zzz,zz9.99") + 
                                " menor que valor doc. " + 
                                STRING(p-vlfatura,"zzz,zzz,zz9.99").
                     
                         RUN cria-erro (INPUT p-cooper,
                                        INPUT p-cod-agencia,
                                        INPUT aux_nrdcaixa,
                                        INPUT i-cod-erro,
                                        INPUT c-desc-erro,
                                        INPUT YES).
                     
                         RETURN "NOK". 

                     END.
              
                  /* Mensagem informando a composição do valor docto */
                  IF par_vlrjuros <> 0  OR  
                     par_vlrmulta <> 0  OR  
                     par_vldescto <> 0  OR  
                     par_vlabatim <> 0  OR  
                     par_vloutdeb <> 0  OR 
                     par_vloutcre <> 0  OR
                     p-vlfatura <> p-valor-informado THEN
                     ASSIGN par_msgalert = "Cob. Reg. - Valor Doc inclui " +
                                           "Abat./Desc./Juros/Multas.".
              
                  /* Parametro para informar que titulo eh de cobranca registrada */
                  ASSIGN par_cobregis = TRUE.
              
              END. /* fim avail crapcco */
          
       END.
    /********* FIM FAZER CALCULO DO VALOR DO TITULO *********/
    /********************************************************/

    IF p-vlfatura <> p-valor-informado AND
       p-vlfatura <> 0                 THEN  
       ASSIGN p-outro-valor = YES.

    /* se p-cod-operador <> "DDA" entao critica titulo vencido - Rafael */
    /* situacao temporaria ate o projeto do TED estar ok */
    IF v-critica-data AND p-cod-operador <> "DDA" THEN
       DO:            
           ASSIGN i-cod-erro  = 13     
                  c-desc-erro = " =  " + STRING(dt-dtvencto,"99/99/9999").
         
           RUN cria-erro (INPUT p-cooper,
                          INPUT p-cod-agencia,
                          INPUT aux_nrdcaixa,
                          INPUT i-cod-erro,
                          INPUT c-desc-erro,
                          INPUT YES).
           
           IF  p-intitcop = 0 OR p-dt-agendamento <> ? THEN
               RETURN "NOK". 

       END.

    RETURN "OK".
       
END PROCEDURE. 

PROCEDURE gera-titulos-iptu.

    DEF INPUT  PARAM p-cooper            AS CHAR.
    DEF INPUT  PARAM p-nrdconta          AS INTE.
    DEF INPUT  PARAM p-idseqttl          LIKE crapttl.idseqttl.
    DEF INPUT  PARAM p-cod-operador      AS CHAR.
    DEF INPUT  PARAM p-cod-agencia       AS INTE.
    DEF INPUT  PARAM p-nro-caixa         AS INTE.

    DEF INPUT  PARAM p-nrinsced          AS DEC. /* CPF/CNPJ do Cedente */
    DEF INPUT  PARAM p-idtitdda          AS DEC. /* IDTITDDA */
    DEF INPUT  PARAM p-nrinssac          AS DEC. /* CPF/CNPJ do Sacado */
    DEF INPUT  PARAM p-fatura4           AS DEC. /* FORMAT "99999,999999,9"*/ 
    
    DEF INPUT  PARAM p-titulo1           AS DEC. /* FORMAT "99999,99999"*/
    DEF INPUT  PARAM p-titulo2           AS DEC. /* FORMAT "99999,999999"*/
    DEF INPUT  PARAM p-titulo3           AS DEC. /* FORMAT "99999,999999"*/
    DEF INPUT  PARAM p-titulo4           AS DEC. /* FORMAT "9"*/
    DEF INPUT  PARAM p-titulo5           AS DEC. /*FORMAT "zz,zzz,zzz,zzz999"*/ 

    DEF INPUT  PARAM p-iptu              AS LOG.
    DEF INPUT  PARAM p-flgpgdda          AS LOG.
    DEF INPUT  PARAM p-codigo-barras     AS CHAR.
    DEF INPUT  PARAM p-valor-informado   AS DEC.
    DEF INPUT  PARAM p-vlfatura          AS DEC.
    DEF INPUT  PARAM p-nrdconta-cob      AS INTE.
    DEF INPUT  PARAM p-insittit          AS INTEGER.
    DEF INPUT  PARAM p-intitcop          AS INTEGER.
    DEF INPUT  PARAM p-convenio          AS DECIMAL.
    DEF INPUT  PARAM p-bloqueto          AS DECIMAL.
    DEF INPUT  PARAM p-contaconve        AS INTEGER.
    DEF INPUT  PARAM par_cdcoptfn        AS INTE                       NO-UNDO.
    DEF INPUT  PARAM par_cdagetfn        AS INTE                       NO-UNDO.
    DEF INPUT  PARAM par_nrterfin        AS INTE                       NO-UNDO.
    
    DEF INPUT  PARAM par_flgpgchq        AS LOGICAL                    NO-UNDO.
    DEF INPUT  PARAM par_vlrjuros        AS DECIMAL                    NO-UNDO.
    DEF INPUT  PARAM par_vlrmulta        AS DECIMAL                    NO-UNDO.
    DEF INPUT  PARAM par_vldescto        AS DECIMAL                    NO-UNDO.
    DEF INPUT  PARAM par_vlabatim        AS DECIMAL                    NO-UNDO.
    DEF INPUT  PARAM par_vloutdeb        AS DECIMAL                    NO-UNDO.
    DEF INPUT  PARAM par_vloutcre        AS DECIMAL                    NO-UNDO.

    DEF OUTPUT PARAM p-rowidcob          AS ROWID                      NO-UNDO.
    DEF OUTPUT PARAM p-indpagto          AS INTE                       NO-UNDO.

    DEF OUTPUT PARAM p-nrcnvbol          AS INTE                       NO-UNDO.
    DEF OUTPUT PARAM p-nrctabol          AS INTE                       NO-UNDO.
    DEF OUTPUT PARAM p-nrboleto          AS INTE                       NO-UNDO.
    DEF OUTPUT PARAM p-histor            AS INTE.
    DEF OUTPUT PARAM p-pg                AS LOG.
    DEF OUTPUT PARAM p-docto             AS DEC.
    DEF OUTPUT PARAM p-literal-r         AS CHAR.
    DEF OUTPUT PARAM p-ult-sequencia-r   AS INTE.
    
    
    DEFINE VARIABLE aux_nrdcaixa LIKE crapaut.nrdcaixa         NO-UNDO.
    DEFINE VARIABLE aux_nrboleto AS DEC                        NO-UNDO.
    DEFINE VARIABLE aux_idorigem AS INTE                       NO-UNDO.
    DEFINE VARIABLE aux_flgdesct AS LOGICAL                    NO-UNDO.
    DEFINE VARIABLE aux_dsmotivo AS CHARACTER                  NO-UNDO.
    DEFINE VARIABLE aux_cdmotivo AS CHAR                       NO-UNDO.
    DEFINE VARIABLE aux_nrretcoo AS INTEGER                    NO-UNDO.
    DEFINE VARIABLE aux_indpagto AS INTEGER     NO-UNDO.
    DEFINE VARIABLE aux_vltarifa AS DECIMAL     NO-UNDO.
    DEFINE VARIABLE aux_flgregst AS LOGICAL     NO-UNDO.
    DEFINE VARIABLE aux_nrinsced AS DECIMAL     NO-UNDO.
    DEFINE VARIABLE aux_nrnosnum AS CHAR        NO-UNDO.
	DEFINE VARIABLE aux_nrseqdig AS INTE        NO-UNDO.

    DEFINE VARIABLE aux_nrdctabb AS INTEGER     NO-UNDO. 
    DEFINE BUFFER crablcm FOR craplcm.  

    DEFINE VARIABLE h-b1wgen0090 AS HANDLE      NO-UNDO.
    DEFINE VARIABLE h-b1wgen0089 AS HANDLE      NO-UNDO.
    DEFINE VARIABLE h-b1wgen0087 AS HANDLE      NO-UNDO.
    DEFINE VARIABLE h-b1wgen9999 AS HANDLE      NO-UNDO.
    

    /* Tratamento de erros para internet */
    IF  p-cod-agencia = 90  THEN
        ASSIGN aux_nrdcaixa = INT(STRING(p-nrdconta) + STRING(p-idseqttl))
               aux_idorigem = 3.    /** Internet **/
    ELSE
    IF  p-cod-agencia = 91  THEN
        ASSIGN aux_nrdcaixa = INT(STRING(p-nrdconta) + STRING(p-idseqttl))
               aux_idorigem = 4.    /** CASH/TAA **/
    ELSE
        ASSIGN aux_nrdcaixa = p-nro-caixa
               aux_idorigem = 2.    /** Caixa On-Line **/

    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
    
    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper 
                             NO-LOCK NO-ERROR.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT aux_nrdcaixa).
                  
    IF  p-cod-agencia   = 0   OR
        P-nro-caixa     = 0   OR
        P-cod-operador  = ""  THEN  
        DO:    
            ASSIGN i-cod-erro  = 0           
                   c-desc-erro = "ERRO!!! PA ZERADO. FECHE O CAIXA E AVISE " +
                                 "O CPD ".
                          
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT aux_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
                           
            RETURN "NOK".
        END.


    IF  p-iptu = YES  THEN   
        ASSIGN i-nro-lote = 17000 + p-nro-caixa.
    ELSE
        ASSIGN i-nro-lote = 16000 + p-nro-caixa.

    ASSIGN i-cdhistor = 0.

    IF  p-iptu = YES  THEN 
        DO: 
            FIND crapcon WHERE
                 crapcon.cdcooper = crapcop.cdcooper                   AND
                 crapcon.cdempcon = inte(SUBSTR(p-codigo-barras,16,4)) AND
                 crapcon.cdsegmto = inte(SUBSTR(p-codigo-barras,2,1))  
                 NO-LOCK NO-ERROR.
          
            IF  AVAIL crapcon  THEN 
                ASSIGN i-cdhistor = crapcon.cdhistor.
        END.
    ELSE 
        ASSIGN i-cdhistor = 713. /* Titulos */  
       
    IF  p-codigo-barras = "" THEN
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "ERRO!!! CODIGO DE BARRAS NULO. AVISE O CPD ".

            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT aux_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
 
            RETURN "NOK".
        END.
    
	/* Busca a proxima sequencia do campo CRAPLOT.NRSEQDIG */
	RUN STORED-PROCEDURE pc_sequence_progress
	aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPLOT"
										,INPUT "NRSEQDIG"
										,STRING(crapcop.cdcooper) + ";" + STRING(crapdat.dtmvtocd,"99/99/9999") + ";" + STRING(p-cod-agencia) + ";11;" + STRING(i-nro-lote)
										,INPUT "N"
										,"").

	CLOSE STORED-PROC pc_sequence_progress
	aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

	ASSIGN aux_nrseqdig = INTE(pc_sequence_progress.pr_sequence)
				               WHEN pc_sequence_progress.pr_sequence <> ?.

    ASSIGN in99 = 0. 

    DO WHILE TRUE:

        ASSIGN in99 = in99 + 1.
    
        FIND craplot WHERE
             craplot.cdcooper = crapcop.cdcooper AND
             craplot.dtmvtolt = crapdat.dtmvtocd AND
             craplot.cdagenci = p-cod-agencia    AND
             craplot.cdbccxlt = 11               AND  /* Fixo */
             craplot.nrdolote = i-nro-lote 
             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        
        IF  NOT AVAILABLE craplot  THEN 
            DO:
                IF  LOCKED craplot  THEN
                    DO:
                        IF  in99 <= 10  THEN 
                            DO:
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                            END.
                        ELSE 
                            DO:
                                ASSIGN i-cod-erro  = 0
                                       c-desc-erro = "Lote ja esta em uso. " +
                                                     "Tente novamente.".
                                            
                                RUN cria-erro (INPUT p-cooper,
                                               INPUT p-cod-agencia,
                                               INPUT aux_nrdcaixa,
                                               INPUT i-cod-erro,
                                               INPUT c-desc-erro,
                                               INPUT YES).
                                               
                                RETURN "NOK".
                            END.
                    END.
                ELSE
                    DO:        
                        CREATE craplot.
                        ASSIGN craplot.cdcooper = crapcop.cdcooper
                               craplot.dtmvtolt = crapdat.dtmvtocd
                               craplot.cdagenci = p-cod-agencia   
                               craplot.cdbccxlt = 11              
                               craplot.nrdolote = i-nro-lote
                               craplot.cdoperad = p-cod-operador
                               craplot.cdhistor = i-cdhistor
                               craplot.nrdcaixa = p-nro-caixa
                               craplot.cdopecxa = p-cod-operador. 
                               
                        IF  p-iptu  THEN
                            ASSIGN craplot.tplotmov = 21.
                        ELSE
                            ASSIGN craplot.tplotmov = 20.                      
                    END.                   
            END.
            
        LEAVE.
  
    END. /* Fim do DO WHILE TRUE */   

    IF  p-iptu  THEN
        ASSIGN i-digito = INTE(SUBSTR(STRING(p-fatura4,"999999999999"),12,1)).
    ELSE
        ASSIGN i-digito = p-titulo4.

    CREATE craptit.            
    ASSIGN craptit.cdcooper = crapcop.cdcooper
           craptit.nrdconta = p-nrdconta
           craptit.dtmvtolt = craplot.dtmvtolt
           craptit.cdagenci = craplot.cdagenci
           craptit.cdbccxlt = craplot.cdbccxlt
           craptit.nrdolote = craplot.nrdolote
           craptit.cdbandst = IF  craplot.tplotmov = 21  THEN
                                  INT(SUBSTRING(p-codigo-barras,16,04))
                              ELSE   
                                  INT(SUBSTRING(p-codigo-barras,01,03))
           craptit.cddmoeda = IF  craplot.tplotmov = 21  THEN
                                  INT(SUBSTRING(p-codigo-barras,03,01))
                              ELSE     
                                  INT(SUBSTRING(p-codigo-barras,04,01))
           craptit.cdoperad = p-cod-operador
           craptit.dscodbar = p-codigo-barras
           craptit.nrdvcdbr = i-digito  /*Digito Verificador Codigo de Barras*/
           craptit.tpdocmto = craplot.tplotmov 
           craptit.vldpagto = p-valor-informado
           craptit.vltitulo = p-vlfatura
           craptit.dtdpagto = crapdat.dtmvtocd                   
           craptit.nrdocmto = aux_nrseqdig
           craptit.cdopedev = ""
           craptit.dtdevolu = ?
           craptit.insittit = p-insittit       /*  Arrec. caixa  */            
           craptit.nrseqdig = aux_nrseqdig
           craptit.intitcop = p-intitcop
           craptit.flgenvio = (p-intitcop = 1) OR 
                              (p-valor-informado >= 250000 AND p-iptu = NO AND
                               TODAY >= 06/28/2013)
           craptit.flgpgdda = p-flgpgdda
           craptit.nrinsced = p-nrinsced
           
           /* Dados do TAA */                                         
           craptit.cdcoptfn = par_cdcoptfn 
           craptit.cdagetfn = par_cdagetfn
           craptit.nrterfin = par_nrterfin.
    VALIDATE craplot.
    VALIDATE craptit.

    /* Buscar nosso numero do codigo de barras */
    ASSIGN aux_nrnosnum = SUBSTRING(p-codigo-barras,26,17).

    /* Titulos da cooperativa */
    IF  NOT p-iptu AND p-intitcop = 1 THEN
        DO:
            FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper AND
                               crapass.nrdconta = p-nrdconta-cob  
                               NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE crapass  THEN
                DO:
                    ASSIGN i-cod-erro  = 9 
                           c-desc-erro = " ". 
                       
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT aux_nrdcaixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                                 
                    RETURN "NOK". 
                END.
     
            /* Verifica se deve extrair o CEB do nro do boleto */
            FIND crapcco WHERE crapcco.cdcooper = crapcop.cdcooper AND
                               crapcco.nrconven = INT(p-convenio)
                               NO-LOCK NO-ERROR.

            ASSIGN aux_nrboleto = p-bloqueto.

            FIND crapceb WHERE crapceb.cdcooper = crapcop.cdcooper AND
                               crapceb.nrdconta = p-nrdconta-cob   AND
                               crapceb.nrconven = INT(p-convenio)
                               NO-LOCK NO-ERROR.

            IF  AVAIL crapceb THEN
                DO:
                    IF  crapcco.cddbanco <> 085 THEN
                        p-bloqueto = DEC(STRING(crapceb.nrcnvceb,"99999") + 
                                         STRING(p-bloqueto, "999999999")).
                END.                          
                              
            FIND craptdb WHERE craptdb.cdcooper = crapcop.cdcooper AND
                               craptdb.nrdconta = p-nrdconta-cob   AND
                               craptdb.cdbandoc = crapcco.cddbanco AND
                               craptdb.nrdctabb = p-contaconve     AND
                               craptdb.nrcnvcob = INT(p-convenio)  AND
                               craptdb.nrdocmto = aux_nrboleto     AND
                               craptdb.insittit = 4                
                               NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE craptdb  THEN
                aux_flgdesct = NO.
            ELSE
                DO:
                    /* a COMPE pode atrasar */
                    IF  craptdb.dtvencto <= crapdat.dtmvtocd  THEN
                        DO:
                            /* postergacao da data de vencimento */
                            IF  craptdb.dtvencto > crapdat.dtmvtoan  THEN
                                aux_flgdesct = YES.
                            ELSE
                                aux_flgdesct = NO.
                        END.
                    ELSE
                        aux_flgdesct = YES.
                END.
            
            IF  p-cod-agencia = 90  THEN
                ASSIGN aux_indpagto = 3  /* Internet */
                       aux_dsmotivo = "33 - Liquidação na Internet (Home banking)"
                       aux_cdmotivo = "33"
                       /* Tarifa para pagamento atraves da internet */
                       aux_vltarifa = crapcco.vlrtarnt.
            ELSE 
            IF  p-cod-agencia = 91 THEN
                ASSIGN aux_indpagto = 4  /* TAA */
                       aux_dsmotivo = "32 - Liquidação Terminal de Auto-Atendimento"
                       aux_cdmotivo = "32"
                       /* Tarifa para pagamento atraves de TAA */
                       aux_vltarifa = crapcco.vltrftaa.
            ELSE
            DO:
                /* Tarifa para pagamento atraves do caixa on-line */
                ASSIGN aux_vltarifa = crapcco.vlrtarcx
                       aux_dsmotivo = ""
                       aux_cdmotivo = "0".

                IF  NOT par_flgpgchq  THEN /* dinheiro */
                    ASSIGN aux_indpagto = 1 /* Caixa On-Line */
                           aux_dsmotivo = "03 - Liquidação no Guichê de Caixa em Dinheiro"
                           aux_cdmotivo = "03".
                ELSE
                IF  par_flgpgchq  THEN /* cheque */
                    ASSIGN aux_indpagto = 1 /* Caixa On-Line */
                           aux_dsmotivo = "30 - Liquidação no Guichê de Caixa em Cheque"
                           aux_cdmotivo = "30".         

            END.
            
            /* identificar se o titulo eh de um convenio de cobranca registrada */
            IF  crapcco.flgregis                     AND
            /*    crapcco.flgativo                     AND */
                crapcco.cddbanco = crapcop.cdbcoctl  THEN
                ASSIGN aux_flgregst = TRUE.
            ELSE
                ASSIGN aux_flgregst = FALSE.

            IF  NOT aux_flgdesct  AND 
                NOT aux_flgregst  THEN
                DO:
				    /* Busca a proxima sequencia do campo CRAPLOT.NRSEQDIG */
					RUN STORED-PROCEDURE pc_sequence_progress
					aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPLOT"
														,INPUT "NRSEQDIG"
														,STRING(crapcop.cdcooper) + ";" + STRING(crapdat.dtmvtocd,"99/99/9999") + ";" + STRING(p-cod-agencia) + ";100;" + STRING(10800 + p-nro-caixa)
														,INPUT "N"
														,"").

					CLOSE STORED-PROC pc_sequence_progress
					aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

					ASSIGN aux_nrseqdig = INTE(pc_sequence_progress.pr_sequence)
				                            WHEN pc_sequence_progress.pr_sequence <> ?.

                    ASSIGN in99 = 0.
                    
                    DO WHILE TRUE:

                        ASSIGN in99 = in99 + 1.
                      
                        FIND craplot WHERE 
                             craplot.cdcooper = crapcop.cdcooper AND
                             craplot.dtmvtolt = crapdat.dtmvtocd AND
                             craplot.cdagenci = p-cod-agencia    AND
                             craplot.cdbccxlt = 100              AND
                             craplot.nrdolote = 10800 + p-nro-caixa
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
     
                        IF  NOT AVAILABLE craplot  THEN 
                            IF  LOCKED craplot  THEN
                                DO:
                                    IF  in99 <= 10  THEN 
                                        DO:
                                            PAUSE 1 NO-MESSAGE.
                                            NEXT.
                                        END.
                                    ELSE 
                                        DO:
                                            ASSIGN i-cod-erro  = 0
                                                   c-desc-erro = "Lote em " +
                                                     "uso. Tente novamente.".
                                                      
                                            RUN cria-erro (INPUT p-cooper,
                                                           INPUT p-cod-agencia,
                                                           INPUT aux_nrdcaixa,
                                                           INPUT i-cod-erro,
                                                           INPUT c-desc-erro,
                                                           INPUT YES).
                                                       
                                            RETURN "NOK".
                                        END.     
                                  END.
                            ELSE
                                DO:                                     
                                    CREATE craplot.                
                                    ASSIGN craplot.cdcooper = crapcop.cdcooper
                                           craplot.dtmvtolt = crapdat.dtmvtocd
                                           craplot.cdagenci = p-cod-agencia
                                           craplot.cdbccxlt = 100              
                                           craplot.nrdolote = 10800 + 
                                                              p-nro-caixa
                                           craplot.tplotmov = 1
                                           craplot.cdoperad = p-cod-operador
                                           craplot.cdhistor = 654
                                           craplot.nrdcaixa = p-nro-caixa
                                           craplot.cdopecxa = p-cod-operador.
                                END.           
                        LEAVE.  
                  
                    END. /* Fim do DO WHILE TRUE */
                    
                    ASSIGN aux_nrdctabb = p-contaconve. 
                    
                    FIND craplcm WHERE craplcm.cdcooper = crapcop.cdcooper AND
                                       craplcm.dtmvtolt = craplot.dtmvtolt AND
                                       craplcm.cdagenci = craplot.cdagenci AND
                                       craplcm.cdbccxlt = craplot.cdbccxlt AND
                                       craplcm.nrdolote = craplot.nrdolote AND
                                       craplcm.cdhistor = craplot.cdhistor AND
                                       craplcm.nrdctabb = p-contaconve     AND
                                       craplcm.nrdocmto = p-bloqueto 
                                       USE-INDEX craplcm1 NO-LOCK NO-ERROR.

                    IF  AVAILABLE craplcm  THEN
                        DO:          
                            IF  craplcm.nrdconta <> p-nrdconta-cob THEN
                                DO:  
                                     FIND  crablcm WHERE   crablcm.cdcooper = crapcop.cdcooper AND
                                                           crablcm.dtmvtolt = craplot.dtmvtolt AND
                                                           crablcm.cdagenci = craplot.cdagenci AND
                                                           crablcm.cdbccxlt = craplot.cdbccxlt AND
                                                           crablcm.nrdolote = craplot.nrdolote AND
                                                           crablcm.cdhistor = craplot.cdhistor AND
                                                           crablcm.nrdctabb = p-nrdconta-cob   AND
                                                           crablcm.nrdocmto = p-bloqueto 
                                                           USE-INDEX craplcm1 NO-LOCK NO-ERROR.

                                     IF  AVAIL crablcm  THEN
                                         DO:
                                               ASSIGN i-cod-erro  = 92
                                                      c-desc-erro = " ". 
        
                                               RUN cria-erro (INPUT p-cooper,
                                                              INPUT p-cod-agencia,
                                                              INPUT aux_nrdcaixa,
                                                              INPUT i-cod-erro,
                                                              INPUT c-desc-erro,
                                                              INPUT YES).
                                               
                                               RETURN "NOK". 
                                         END.
                                        
                                     ASSIGN  aux_nrdctabb = p-nrdconta-cob. 
                                END. 
                            ELSE     
                                DO:
                                   ASSIGN i-cod-erro  = 92
                                          c-desc-erro = " ". 
          
                                   RUN cria-erro (INPUT p-cooper,
                                                  INPUT p-cod-agencia,
                                                  INPUT aux_nrdcaixa,
                                                  INPUT i-cod-erro,
                                                  INPUT c-desc-erro,
                                                  INPUT YES).
                                                  
                                   RETURN "NOK". 

                                END.
                        END.
                    
                    CREATE craplcm.
                    ASSIGN craplcm.cdagenci = craplot.cdagenci
                           craplcm.cdbccxlt = craplot.cdbccxlt
                           craplcm.cdcooper = crapcop.cdcooper
                           craplcm.cdhistor = craplot.cdhistor
                           craplcm.cdoperad = craplot.cdoperad
                           craplcm.cdpesqbb = TRIM(STRING(p-convenio))
                           craplcm.dtmvtolt = craplot.dtmvtolt
                           craplcm.dtrefere = craplot.dtmvtolt
                           craplcm.hrtransa = TIME
                           craplcm.nrautdoc = p-ult-sequencia
                           craplcm.nrdconta = p-nrdconta-cob
                           craplcm.nrdctabb = aux_nrdctabb 
                           craplcm.nrdctitg = crapass.nrdctitg
                           craplcm.nrdocmto = p-bloqueto
                           craplcm.nrdolote = craplot.nrdolote
                           craplcm.nrseqdig = aux_nrseqdig
                           craplcm.vllanmto = p-valor-informado
                           /* Dados do TAA */               
                           craplcm.cdcoptfn = par_cdcoptfn          
                           craplcm.cdagetfn = par_cdagetfn
                           craplcm.nrterfin = par_nrterfin.         
                        

                    /* Faz a baixa de titulos em emprestimo */
                    FIND crapcob WHERE crapcob.cdcooper = crapcop.cdcooper AND
                                       crapcob.nrcnvcob = INT(p-convenio)  AND
                                       crapcob.nrdconta = p-nrdconta-cob   AND
                                       crapcob.nrdocmto = aux_nrboleto     AND
                                       crapcob.nrdctabb = p-contaconve     AND
                                       crapcob.cdbandoc = crapcco.cddbanco
                                       NO-LOCK NO-ERROR.

                    IF  NOT AVAIL crapcob  THEN
                        DO: 
                            IF   crapcco.dsorgarq = "IMPRESSO PELO SOFTWARE" THEN
                                 DO:              
                                     CREATE crapcob.
                                     ASSIGN crapcob.cdcooper = crapcop.cdcooper
                                            crapcob.nrdconta = p-nrdconta-cob
                                            crapcob.cdbandoc = crapcco.cddbanco
                                            crapcob.nrdctabb = p-contaconve
                                            crapcob.nrcnvcob = INT(p-convenio)
                                            crapcob.nrdocmto = aux_nrboleto
                                            crapcob.incobran = 0 
                                            crapcob.dtretcob = crapdat.dtmvtocd
                                            crapcob.nrnosnum = aux_nrnosnum.
                                     VALIDATE crapcob.
                                 END.
                            ELSE 
                                DO:
                                    ASSIGN i-cod-erro  = 0
                                           c-desc-erro = "Registro de boleto nao " +
                                                         "encontrado.".
          
                                    RUN cria-erro (INPUT p-cooper,
                                                   INPUT p-cod-agencia,
                                                   INPUT aux_nrdcaixa,
                                                   INPUT i-cod-erro,
                                                   INPUT c-desc-erro,
                                                   INPUT YES).
              
                                    RETURN "NOK".                        
                                END.
                        END.                    
                    
                    IF  crapcob.nrctremp <> 0  AND
                        crapcob.nrctasac <> 0  THEN
                    DO:
                    RUN sistema/generico/procedures/b1wgen0023.p
                          PERSISTENT SET h-b1wgen0023.

                    IF  NOT VALID-HANDLE(h-b1wgen0023)  THEN
                        DO:
                            ASSIGN i-cod-erro  = 0
                                   c-desc-erro = "Handle invalido para " +
                                                 "h-b1wgen0023".
  
                            RUN cria-erro (INPUT p-cooper,
                                           INPUT p-cod-agencia,
                                           INPUT aux_nrdcaixa,
                                           INPUT i-cod-erro,
                                           INPUT c-desc-erro,
                                           INPUT YES).
      
                            RETURN "NOK". 
                        END.
                    
                    RUN baixa_epr_titulo IN h-b1wgen0023
                                           (INPUT crapcop.cdcooper,
                                            INPUT p-cod-agencia,
                                            INPUT p-nro-caixa,   
                                            INPUT p-cod-operador,
                                            INPUT crapcob.nrdconta,
                                            INPUT 1, /* idseqttl */
                                            INPUT aux_idorigem,
                                            INPUT "b2crap14.p",
                                            INPUT crapdat.dtmvtocd,
                                            INPUT crapcob.nrctremp,
                                            INPUT crapcob.nrctasac,
                                            INPUT crapcob.nrdocmto,
                                            INPUT crapcob.dtvencto,
                                            INPUT crapcob.vltitulo,
                                            INPUT p-valor-informado,
                                            INPUT TRUE,
                                           OUTPUT TABLE tt-erro).

                    DELETE PROCEDURE h-b1wgen0023.

                    /* Em caso de erros */
                    IF  RETURN-VALUE = "NOK"  THEN    
                        DO:
                            FIND FIRST tt-erro NO-LOCK NO-ERROR.
                  
                            IF  AVAILABLE tt-erro   THEN
                                DO:
                                    ASSIGN i-cod-erro  = 0
                                           c-desc-erro = tt-erro.dscritic.
  
                                    RUN cria-erro (INPUT p-cooper,
                                                   INPUT p-cod-agencia,
                                                   INPUT aux_nrdcaixa,
                                                   INPUT i-cod-erro,
                                                   INPUT c-desc-erro,
                                                   INPUT YES).
                                END.
                            ELSE
                                DO:
                                    ASSIGN i-cod-erro  = 0
                                           c-desc-erro = "Nao foi possivel " +
                                                         "baixar titulo do " +
                                                         "emprestimo.".
  
                                    RUN cria-erro (INPUT p-cooper,
                                                   INPUT p-cod-agencia,
                                                   INPUT aux_nrdcaixa,
                                                   INPUT i-cod-erro,
                                                   INPUT c-desc-erro,
                                                   INPUT YES).
                                END.

                            RETURN "NOK".
                        END.  
                    END.
                    /* Fim de lancamentos de titulos em emprestimo */
                
                END. 
            ELSE
            IF  aux_flgregst  THEN
                DO:
                    RUN sistema/generico/procedures/b1wgen0089.p
                          PERSISTENT SET h-b1wgen0089.

                    IF  NOT VALID-HANDLE(h-b1wgen0089)  THEN
                    DO:
                        ASSIGN i-cod-erro  = 0
                               c-desc-erro = "Handle invalido para " +
                                             "h-b1wgen0089".

                        RUN cria-erro (INPUT p-cooper,
                                       INPUT p-cod-agencia,
                                       INPUT aux_nrdcaixa,
                                       INPUT i-cod-erro,
                                       INPUT c-desc-erro,
                                       INPUT YES).

                        RETURN "NOK". 
                    END.

                    FIND crapcob WHERE crapcob.cdcooper = crapcop.cdcooper AND
                                       crapcob.nrcnvcob = INT(p-convenio)  AND
                                       crapcob.nrdconta = p-nrdconta-cob   AND
                                       crapcob.nrdocmto = aux_nrboleto     AND
                                       crapcob.nrdctabb = p-contaconve     AND
                                       crapcob.cdbandoc = crapcco.cddbanco
                                       NO-LOCK NO-ERROR.

                    IF  NOT AVAIL crapcob  THEN
                    DO:
                        ASSIGN i-cod-erro  = 0
                               c-desc-erro = "Registro de boleto nao encontrado.".

                        RUN cria-erro (INPUT p-cooper,
                                       INPUT p-cod-agencia,
                                       INPUT aux_nrdcaixa,
                                       INPUT i-cod-erro,
                                       INPUT c-desc-erro,
                                       INPUT YES).

                        RETURN "NOK".
                    END.
                    ELSE IF crapcob.incobran = 3 OR 
                            crapcob.incobran = 5 THEN
                    DO:
                        ASSIGN i-cod-erro  = 0.
                        IF crapcob.incobran = 3 THEN
                           ASSIGN c-desc-erro = "Boleto ja baixado.".

                        IF crapcob.incobran = 5 THEN
                           ASSIGN c-desc-erro = "Boleto ja pago.".

                        RUN cria-erro (INPUT p-cooper,
                                       INPUT p-cod-agencia,
                                       INPUT aux_nrdcaixa,
                                       INPUT i-cod-erro,
                                       INPUT c-desc-erro,
                                       INPUT YES).

                        RETURN "NOK".
                    END.

                    
                    RUN proc-liquidacao IN h-b1wgen0089 (INPUT ROWID(crapcob),
                                                         INPUT 0, /* nrnosnum */ 
                                                         INPUT crapcop.cdbcoctl,
                                                         INPUT crapcop.cdagectl,
                                                         INPUT crapcob.vltitulo,
                                                         INPUT 0, /* vlliquid */
                                                         INPUT p-valor-informado,
                                                         INPUT par_vlabatim,
                                                         INPUT par_vldescto,
                                                         INPUT par_vlrjuros + par_vlrmulta,
                                                         INPUT par_vloutdeb,
                                                         INPUT par_vloutcre,
                                                         INPUT crapdat.dtmvtocd,
                                                         INPUT crapdat.dtmvtocd,
                                                         INPUT 6, /* cdocorre */
                                                         INPUT aux_cdmotivo,
                                                         INPUT crapdat.dtmvtocd,
                                                         INPUT p-cod-operador,
                                                         INPUT aux_indpagto,
                                                         INPUT 0, /* sem crise */
                                                         OUTPUT aux_nrretcoo,
                                                         OUTPUT i-cod-erro,
                                                         INPUT-OUTPUT TABLE tt-lcm-consolidada,
                                                         INPUT-OUTPUT TABLE tt-descontar).

                    IF  RETURN-VALUE <> "OK"  THEN
                    DO:
                        DELETE PROCEDURE h-b1wgen0089.

                        ASSIGN c-desc-erro = "".

                        RUN cria-erro (INPUT p-cooper,
                                       INPUT p-cod-agencia,
                                       INPUT aux_nrdcaixa,
                                       INPUT i-cod-erro,
                                       INPUT c-desc-erro,
                                       INPUT YES).

                        RETURN "NOK". 
                    END.

                    /** Realiza os Lancamentos na conta do cooperado */
                    RUN realiza-lancto-cooperado
                         IN h-b1wgen0089 ( INPUT crapcob.cdcooper,
                                           INPUT crapdat.dtmvtocd,
                                           INPUT crapcco.cdagenci,
                                           INPUT crapcco.cdbccxlt,
                                           INPUT crapcco.nrdolote,
                                           INPUT crapcob.nrcnvcob,
                                           INPUT TABLE tt-lcm-consolidada).

                    DELETE PROCEDURE h-b1wgen0089.

                    IF  RETURN-VALUE <> "OK"  THEN
                    DO:

                        ASSIGN c-desc-erro = "Nao foi possivel creditar conta cooperado.".

                        RUN cria-erro (INPUT p-cooper,
                                       INPUT p-cod-agencia,
                                       INPUT aux_nrdcaixa,
                                       INPUT i-cod-erro,
                                       INPUT c-desc-erro,
                                       INPUT YES).

                        RETURN "NOK". 
                    END.
                     
                    ASSIGN p-rowidcob = ROWID(crapcob)    
                           p-indpagto = aux_indpagto.

                    IF TEMP-TABLE tt-descontar:HAS-RECORDS THEN
                       ASSIGN aux_flgdesct = TRUE.
                END.

            ASSIGN in99 = 0.

            DO WHILE TRUE:
                
                ASSIGN in99 = in99 + 1. 

                FIND crapcob WHERE crapcob.cdcooper = crapcop.cdcooper AND
                                   crapcob.nrcnvcob = INT(p-convenio)  AND
                                   crapcob.nrdconta = p-nrdconta-cob   AND
                                   crapcob.nrdocmto = aux_nrboleto     AND
                                   crapcob.nrdctabb = p-contaconve     AND
                                   crapcob.cdbandoc = crapcco.cddbanco
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                   /* favor nao retirar exclusive-lock - Rafael */
                                  
                IF  NOT AVAILABLE crapcob  THEN
                    DO:
                        IF  LOCKED crapcob  THEN
                            DO:
                                IF  in99 <= 10  THEN 
                                    DO:
                                        PAUSE 1 NO-MESSAGE.
                                        NEXT.
                                    END.
                                ELSE 
                                    DO:
                                        ASSIGN i-cod-erro  = 0
                                               c-desc-erro = "Tabela CRAPCOB" +
                                                             " em uso!".
                                                         
                                        RUN cria-erro (INPUT p-cooper,
                                                       INPUT p-cod-agencia,
                                                       INPUT aux_nrdcaixa,
                                                       INPUT i-cod-erro,
                                                       INPUT c-desc-erro,
                                                       INPUT YES).
                                                       
                                        RETURN "NOK".
                                    END.
                            END.
                        ELSE
                            DO: 
                                IF  (crapcco.dsorgarq = "IMPRESSO PELO SOFTWARE") OR 
                                    (crapcco.dsorgarq = "MIGRACAO" AND 
                                     CAN-DO("1601301,0457595,0458031", 
                                       STRING(crapcco.nrconven,"9999999")) AND
                                     CAN-FIND(crapass WHERE 
                                              crapass.cdcooper = crapcop.cdcooper AND
                                              crapass.nrdconta = p-nrdconta-cob)) THEN
                                     DO:
                                         CREATE crapcob.
                                         ASSIGN crapcob.cdcooper = crapcop.cdcooper 
                                                crapcob.nrdconta = p-nrdconta-cob
                                                crapcob.cdbandoc = crapcco.cddbanco
                                                crapcob.nrdctabb = p-contaconve
                                                crapcob.nrcnvcob = INT(p-convenio)
                                                crapcob.nrdocmto = aux_nrboleto
                                                crapcob.incobran = 0
                                                crapcob.dtretcob = crapdat.dtmvtocd
                                                crapcob.nrnosnum = aux_nrnosnum.
                                     END.
                                ELSE
                                     DO:
                                        ASSIGN i-cod-erro  = 592
                                               c-desc-erro = "".
          
                                        RUN cria-erro (INPUT p-cooper,
                                                       INPUT p-cod-agencia,
                                                       INPUT aux_nrdcaixa,
                                                       INPUT i-cod-erro,
                                                       INPUT c-desc-erro,
                                                       INPUT YES).
              
                                        RETURN "NOK".
                                     END.
                            END.
                    END.
                
                LEAVE.    
              
            END. /* Fim do DO WHILE TRUE */
              
            ASSIGN crapcob.incobran = 5
                   crapcob.dtdpagto = crapdat.dtmvtocd
                   crapcob.vldpagto = p-valor-informado
                   p-nrcnvbol = crapcob.nrcnvcob  
                   p-nrctabol = crapcob.nrdconta
                   p-nrboleto = crapcob.nrdocmto
                   crapcob.indpagto = aux_indpagto
                   crapcob.cdbanpag = 11
                   crapcob.cdagepag = 0
                   crapcob.vltarifa = aux_vltarifa.

            /* Gerar tarifa somente para titulos que nao estao em emprst
               e nao estiverem na cobranca registrada */

            IF  crapcob.nrctremp = 0  AND
                NOT aux_flgregst      THEN 
                DO:

                    RUN gera-tarifa-titulo (INPUT crapcop.cdcooper,
                                            INPUT p-nrdconta-cob,
                                            INPUT p-cod-agencia,
                                            INPUT p-nro-caixa,
                                            INPUT p-cod-operador,
                                            INPUT p-convenio,
                                            INPUT p-ult-sequencia,
                                           OUTPUT c-desc-erro).
                                   
                    IF  RETURN-VALUE = "NOK"  THEN
                        DO:

                            RUN cria-erro (INPUT p-cooper,
                                           INPUT p-cod-agencia,
                                           INPUT aux_nrdcaixa,
                                           INPUT 0,
                                           INPUT c-desc-erro,
                                           INPUT YES).
  
                            RETURN "NOK".
                        END.
                END.

            /* Se o titulo estiver em desconto chama a rotina de baixa */
            IF  aux_flgdesct  THEN
                DO:
                    CREATE tt-titulos.
                    ASSIGN tt-titulos.cdbandoc = crapcob.cdbandoc
                           tt-titulos.nrdctabb = crapcob.nrdctabb
                           tt-titulos.nrcnvcob = crapcob.nrcnvcob
                           tt-titulos.nrdconta = crapcob.nrdconta
                           tt-titulos.nrdocmto = crapcob.nrdocmto
                           tt-titulos.vltitulo = p-valor-informado
                           tt-titulos.flgregis = crapcob.flgregis.
            
                    RUN sistema/generico/procedures/b1wgen0030.p
                        PERSISTENT SET h-b1wgen0030.
                          
                    RUN efetua_baixa_titulo IN h-b1wgen0030
                                           (INPUT crapcop.cdcooper,
                                            INPUT p-cod-agencia,
                                            INPUT p-nro-caixa,   
                                            INPUT p-cod-operador,
                                            INPUT crapdat.dtmvtocd, 
                                            INPUT aux_idorigem,
                                            INPUT p-nrdconta,
                                            INPUT 1,  
                                            INPUT TABLE tt-titulos,
                                           OUTPUT TABLE tt-erro ).
                      
                    IF  RETURN-VALUE <> "OK"  THEN
                        DO:
                            FIND FIRST tt-erro NO-LOCK NO-ERROR.
                            IF AVAIL tt-erro THEN
                            RUN cria-erro (INPUT p-cooper,
                                           INPUT p-cod-agencia,
                                           INPUT aux_nrdcaixa,
                                           INPUT 0,
                                           INPUT tt-erro.dscritic,
                                           INPUT YES).
                            ELSE
                            RUN cria-erro (INPUT p-cooper,
                                           INPUT p-cod-agencia,
                                           INPUT aux_nrdcaixa,
                                           INPUT 0,
                                           INPUT "Nao foi possivel efetuar " +
                                                 "baixa do desconto de titulos",
                                           INPUT YES).
  
                            RETURN "NOK".
                        END.
                    
                    DELETE PROCEDURE h-b1wgen0030.

                END. /* Final da baixa de desconto de titulos */             

         END.

    ASSIGN p-pg     = NO
           p-docto  = craptit.nrdocmto
           p-histor = i-cdhistor.


    /* enviar VR Boleto ao SPB */
    IF  p-iptu = NO AND
        p-intitcop = 0 AND
        p-valor-informado >= 250000 AND 
        TODAY >= 06/28/2013 THEN
        DO:

            IF  p-idtitdda > 0 THEN
                DO:
                    RUN sistema/generico/procedures/b1wgen9999.p
                        PERSISTENT SET h-b1wgen9999.
    
                    RUN p-conectajddda IN h-b1wgen9999.
    
                    IF  RETURN-VALUE = "OK" THEN
                        DO:
                            RUN sistema/generico/procedures/b1wgen0087.p
                                PERSISTENT SET h-b1wgen0087.
    
                            RUN busca-cedente-DDA IN h-b1wgen0087
                                (INPUT crapcop.cdcooper,
                                 INPUT p-idtitdda,
                                OUTPUT aux_nrinsced).

                            DELETE PROCEDURE h-b1wgen0087.
    
                            RUN p-desconectajddda IN h-b1wgen9999.
                        END.
    
                    DELETE PROCEDURE h-b1wgen9999.
                END.

            IF  aux_nrinsced > 0 OR p-nrinsced > 0 THEN
                DO:

                    RUN envia_vrboleto_spb
                                    (INPUT crapcop.cdcooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT p-cod-operador,
                                     INPUT p-nrinssac,
                                     INPUT p-idseqttl,
                                     INPUT p-codigo-barras,
                                     INPUT (IF p-idtitdda > 0 THEN 
                                               aux_nrinsced 
                                            ELSE 
                                               p-nrinsced),
                                     INPUT p-valor-informado,
                                     INPUT aux_idorigem).

                    IF  i-cod-erro > 0 OR
                        TRIM(c-desc-erro) <> "" THEN
                        DO:
                            RUN cria-erro (INPUT p-cooper,
                                           INPUT p-cod-agencia,
                                           INPUT aux_nrdcaixa,
                                           INPUT i-cod-erro,
                                           INPUT c-desc-erro,
                                           INPUT YES).

                            RETURN "NOK".
                        END.
                END.
        END.

    RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.

    RUN grava-autenticacao-internet IN h-b1crap00
                                          (INPUT p-cooper,
                                           INPUT p-nrdconta,
                                           INPUT p-idseqttl,
                                           INPUT p-cod-agencia,
                                           INPUT p-nro-caixa,
                                           INPUT p-cod-operador,
                                           INPUT DEC(p-valor-informado),
                                           INPUT p-docto, 
                                           INPUT p-pg, /* YES (PG), NO (REC) */
                                           INPUT "1",  /* On-line            */
                                           INPUT NO,   /* NÆo estorno        */
                                           INPUT p-histor, 
                                           INPUT ?, /* Data off-line */
                                           INPUT 0, /* Sequencia off-line */
                                           INPUT 0, /* Hora off-line */
                                           INPUT 0, /* Seq.orig.Off-line */  
                                           INPUT "",
                                          OUTPUT p-literal,
                                          OUTPUT p-ult-sequencia,
                                          OUTPUT p-registro).

    DELETE PROCEDURE h-b1crap00.

    IF  RETURN-VALUE = "NOK" THEN
        RETURN "NOK".
     
    /* Atualiza sequencia Autenticacao */
    ASSIGN craptit.nrautdoc = p-ult-sequencia.

    ASSIGN p-ult-sequencia-r = p-ult-sequencia
           p-literal-r       = p-literal.

    IF  AVAILABLE crapcob  THEN
        RELEASE crapcob NO-ERROR.
        
    RELEASE craplot NO-ERROR.
    RELEASE craptit NO-ERROR.
    RELEASE craplcm NO-ERROR.

    RETURN "OK".

END PROCEDURE.

PROCEDURE identifica-titulo-coop:

   DEFINE INPUT  PARAMETER p-cooper           AS CHARACTER            NO-UNDO.
   DEFINE INPUT  PARAMETER p-nro-conta        AS INT                  NO-UNDO.
   DEFINE INPUT  PARAMETER p-idseqttl         AS INT                  NO-UNDO.
   DEFINE INPUT  PARAMETER p-cod-agencia      AS INTE                 NO-UNDO.
   DEFINE INPUT  PARAMETER p-nro-caixa        AS INTE                 NO-UNDO.
   DEFINE INPUT  PARAMETER p-codbarras        AS CHARACTER            NO-UNDO.
   DEFINE INPUT  PARAMETER p-flgcritica       AS LOGICAL              NO-UNDO.
   DEFINE OUTPUT PARAMETER p-nrdconta         AS INTEGER              NO-UNDO.
   DEFINE OUTPUT PARAMETER p-insittit         AS INTEGER              NO-UNDO.
   DEFINE OUTPUT PARAMETER p-intitcop         AS INTEGER              NO-UNDO.
   DEFINE OUTPUT PARAMETER p-convenio         AS DECIMAL              NO-UNDO.
   DEFINE OUTPUT PARAMETER p-bloqueto         AS DECIMAL              NO-UNDO.
   DEFINE OUTPUT PARAMETER p-contaconve       AS INTEGER              NO-UNDO.

   DEFINE VARIABLE aux-banco                  AS INTEGER              NO-UNDO.
   DEFINE VARIABLE aux-convenio1              AS DECIMAL              NO-UNDO.
   DEFINE VARIABLE aux-convenio2              AS DECIMAL              NO-UNDO.
   DEFINE VARIABLE aux-convenio3              AS DECIMAL              NO-UNDO.
   DEFINE VARIABLE aux-bloqueto1              AS DECIMAL              NO-UNDO.
   DEFINE VARIABLE aux-bloqueto2              AS DECIMAL              NO-UNDO.
   DEFINE VARIABLE aux-bloqueto3              AS DECIMAL              NO-UNDO.
   DEFINE VARIABLE aux-bloqueto4              AS DECIMAL              NO-UNDO.
   DEFINE VARIABLE aux-nrdconta               AS INTEGER              NO-UNDO.
   DEFINE VARIABLE aux-nrconvceb              AS INTEGER              NO-UNDO.
   DEFINE VARIABLE aux_nrnosnum               AS CHAR                 NO-UNDO.

   DEFINE VARIABLE aux-digbloqueto1           AS DECIMAL              NO-UNDO.  
   DEFINE VARIABLE aux-digverif               AS INTEGER              NO-UNDO.   
   DEFINE VARIABLE aux-b2crap00               AS HANDLE               NO-UNDO.

   DEFINE VARIABLE aux_nrdcaixa        LIKE crapaut.nrdcaixa          NO-UNDO.
   DEFINE VARIABLE aux_vltitulo               AS DECIMAL              NO-UNDO.
   DEFINE VARIABLE aux_rowidcob               AS ROWID                NO-UNDO.
   DEFINE VARIABLE aux-retorno                AS LOG                  NO-UNDO.

   DEF BUFFER b-crapcco FOR crapcco.
   
   /* Tratamento de erros para internet e TAA */
   IF   p-cod-agencia = 90   OR
        p-cod-agencia = 91   THEN
        aux_nrdcaixa = INT(STRING(p-nro-conta) + STRING(p-idseqttl)).
   ELSE
        aux_nrdcaixa = p-nro-caixa.

   FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

   /* Data do sistema */
   FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper NO-LOCK NO-ERROR.
   
   ASSIGN aux-banco     = INTEGER(SUBSTR(p-codbarras, 1, 3))
          aux-digverif  = INTEGER(SUBSTR(p-codbarras, 5, 1)) /* Dv */
          aux_vltitulo  = DECIMAL(SUBSTR(p-codbarras, 10, 10)) 
          aux-convenio1 = DECIMAL(SUBSTR(p-codbarras, 20, 6))
          aux-convenio2 = DECIMAL(SUBSTR(p-codbarras, 25, 8))  /* ALPES */
          aux-convenio3 = DECIMAL(SUBSTR(p-codbarras, 26, 7))  /* CEB */
          aux-nrconvceb = DECIMAL(SUBSTR(p-codbarras, 33, 4))  /* CEB */
          aux-bloqueto1 = DECIMAL(SUBSTR(p-codbarras, 26, 5))  /* 5 dígitos */
          aux-bloqueto2 = DECIMAL(SUBSTR(p-codbarras, 34, 9))  /* ALPES */
          aux-bloqueto3 = DECIMAL(SUBSTR(p-codbarras, 33, 10)) /* 10 dígitos */
          aux-bloqueto4 = DECIMAL(SUBSTR(p-codbarras, 37, 6)) /*6 dígitos CEB*/
          aux-nrdconta  = INTEGER(SUBSTR(p-codbarras, 26, 8))  /* ALPES */
          p-insittit    = 4
          p-intitcop    = 0
          p-convenio    = 0
          p-bloqueto    = 0
          aux_nrnosnum  = SUBSTR(p-codbarras, 26, 17).

   ASSIGN aux_vltitulo = aux_vltitulo / 100 NO-ERROR.
   
   /* Validar digito geral do codigo de barras - titulos */ 
   RUN dbo/pcrap05.p(INPUT DEC(p-codbarras),
                    OUTPUT aux-retorno).    

   IF  aux-retorno = NO  THEN 
       DO:
           ASSIGN i-cod-erro  = 8           
                  c-desc-erro = " ".
           RUN cria-erro (INPUT p-cooper,
                                                INPUT p-cod-agencia,
                                                INPUT p-nro-caixa,
                          INPUT i-cod-erro,
                          INPUT c-desc-erro,
                          INPUT YES).
           RETURN "NOK".
       END. 
                       
   ASSIGN aux-bloqueto1 = DECI(STRING(aux-bloqueto1) + 
                               TRIM(STRING(aux-digverif))).
                         
   RUN elimina-erro (INPUT p-cooper,
                     INPUT p-cod-agencia,
                     INPUT aux_nrdcaixa).
   
   IF aux-banco = 1 THEN 
      DO:   
         FIND crapcco WHERE crapcco.cdcooper = crapcop.cdcooper AND
                            crapcco.cddbanco = aux-banco        AND
                            /* Cob. Sem Registro */
                            crapcco.flgregis = FALSE            AND
                            /* Convenio nao CEB */
                         (((crapcco.nrconven = aux-convenio1    OR
                            crapcco.nrconven = aux-convenio2)   AND
                            NOT crapcco.flgutceb)               
                            /* Convenio CEB */                  OR
                           (crapcco.nrconven = aux-convenio3    AND
                            crapcco.flgutceb))
                            NO-LOCK NO-ERROR.  
         
         IF  AVAILABLE crapcco  THEN
             DO:  
                IF  crapcco.dsorgarq = "IMPRESSO PELO SOFTWARE" OR
                    crapcco.dsorgarq = "INTERNET"               OR 
                    crapcco.dsorgarq = "MIGRACAO"               THEN
                    DO:
                       IF  crapcco.flgutceb THEN
                           DO:    

                             /*Desativado convenios com 5 digitos, por isso foi retirado 
                               tratamento para 5 digitos - Odirlei - 28/07/2014 */
                             /* tratamento para titulos com CEB 5 digitos */
                             /*IF  crapcop.cdcooper = 1 AND
                                 crapcco.nrconven = 1343313 AND 
                                 SUBSTR(STRING(aux-nrconvceb),1,3) = "100" THEN
                                 DO:
                                    FIND crapceb WHERE
                                         crapceb.cdcooper = crapcop.cdcooper AND
                                         crapceb.nrconven = crapcco.nrconven AND
                                         SUBSTR(TRIM(STRING(crapceb.nrcnvceb,"zzzz9")),1,4) = 
                                            TRIM(STRING(aux-nrconvceb,"zzz9"))
                                         NO-LOCK NO-ERROR.

                                    IF  ERROR-STATUS:ERROR THEN
                                        DO:
                                            FOR EACH crapceb WHERE 
                                                     crapceb.cdcooper = crapcop.cdcooper AND
                                                     crapceb.nrconven = crapcco.nrconven AND
                                                     SUBSTR(TRIM(STRING(crapceb.nrcnvceb,"zzzz9")),1,4) = 
                                                        TRIM(STRING(aux-nrconvceb,"zzz9"))
                                                     NO-LOCK
                                               ,EACH crapcob WHERE
                                                     crapcob.cdcooper = crapceb.cdcooper AND
                                                     crapcob.nrcnvcob = crapceb.nrconven AND
                                                     crapcob.nrdconta = crapceb.nrdconta AND
                                                     crapcob.nrdctabb = crapcco.nrdctabb AND
                                                     crapcob.cdbandoc = crapcco.cddbanco AND
                                                     crapcob.nrdocmto = aux-bloqueto4    AND
                                                     crapcob.vltitulo = aux_vltitulo
                                                     NO-LOCK:
                                                aux_rowidcob = ROWID(crapcob).
                                            END.

                                            FIND crapcob WHERE ROWID(crapcob) = aux_rowidcob
                                                NO-LOCK NO-ERROR.

                                            IF  AVAIL crapcob THEN
                                                DO:
                                                    FIND crapceb WHERE
                                                         crapceb.cdcooper = crapcob.cdcooper AND
                                                         crapceb.nrconven = crapcob.nrcnvcob AND
                                                         crapceb.nrdconta = crapcob.nrdconta
                                                         NO-LOCK NO-ERROR.

                                                    IF  AVAIL crapceb THEN
                                                        aux-nrconvceb = crapceb.nrcnvceb.
                                                END.
                                        END.

                                 END.*/ /* fim - tratamento para titulos com CEB 5 digitos */

                             FIND crapceb WHERE 
                                  crapceb.cdcooper = crapcop.cdcooper AND
                                  crapceb.nrconven = crapcco.nrconven AND
                                  crapceb.nrcnvceb = aux-nrconvceb 
                                  NO-LOCK NO-ERROR.
                             
                             IF  AVAILABLE crapceb THEN
                                 DO:
                                   FIND craptco WHERE
                                        craptco.cdcopant = crapceb.cdcooper AND
                                        craptco.nrctaant = crapceb.nrdconta AND
                                        craptco.flgativo = TRUE             AND
                                        craptco.tpctatrf <> 3
                                        NO-LOCK NO-ERROR.

                                   IF AVAIL craptco THEN
                                      RETURN "OK".
                                   ELSE
                                       ASSIGN aux-nrdconta  = crapceb.nrdconta
                                              aux-bloqueto2 = aux-bloqueto4.
                                 END.
                             ELSE
                                DO:
                                     /* se convenio for migracao, entao eh 
                                           liquidacao interbancaria */
                                     IF  crapcco.dsorgarq = "MIGRACAO" THEN
                                         RETURN "OK".
                                     ELSE DO:
                                        IF  p-flgcritica THEN DO:
                                            ASSIGN i-cod-erro  = 0     
                                                   c-desc-erro = 
                                                      "882 - Convenio " + 
                                                      "AILOS nao encontrado. (" +
                                                      STRING(aux-nrconvceb, "9999") +
                                                      ")".
              
                                            RUN cria-erro (INPUT p-cooper,
                                                           INPUT p-cod-agencia,
                                                           INPUT aux_nrdcaixa,
                                                           INPUT i-cod-erro,
                                                           INPUT c-desc-erro,
                                                           INPUT YES).
            
                                            RETURN "NOK".
                                        END.
                                     END.
                                END. 
                       END.
 
                       FIND crapcob WHERE 
                            crapcob.cdcooper = crapcop.cdcooper  AND
                            crapcob.cdbandoc = crapcco.cddbanco  AND
                            crapcob.nrcnvcob = crapcco.nrconven  AND
                            crapcob.nrdctabb = crapcco.nrdctabb  AND
                            crapcob.nrdocmto = aux-bloqueto2     AND
                            crapcob.nrdconta = aux-nrdconta
                            NO-LOCK NO-ERROR.

                       IF  NOT AVAIL crapcob THEN DO:

                           /* procurar convenio da cooperativa origem */
                           FIND b-crapcco WHERE
                                b-crapcco.cdcooper <> crapcco.cdcooper AND
                                b-crapcco.nrconven = crapcco.nrconven
                                NO-LOCK NO-ERROR.

                           IF  AVAIL b-crapcco THEN DO:

                               FIND  craptco WHERE 
                                     craptco.cdcopant = b-crapcco.cdcooper AND
                                     craptco.nrctaant = aux-nrdconta       AND
                                     craptco.flgativo = TRUE               AND
                                     craptco.tpctatrf <> 3
                                     NO-LOCK NO-ERROR.

                               IF  AVAIL craptco THEN DO:

                                   FIND crapcob WHERE 
                                        crapcob.cdcooper = crapcop.cdcooper  AND
                                        crapcob.cdbandoc = crapcco.cddbanco  AND
                                        crapcob.nrcnvcob = crapcco.nrconven  AND
                                        crapcob.nrdctabb = crapcco.nrdctabb  AND
                                        crapcob.nrdocmto = aux-bloqueto2     AND
                                        crapcob.nrdconta = craptco.nrdconta
                                        NO-LOCK NO-ERROR.
                               END.
                           END.

                       END.

                END.
                    
                ELSE DO:

                    FIND crapcob WHERE crapcob.cdcooper = crapcop.cdcooper  AND
                                       crapcob.cdbandoc = crapcco.cddbanco  AND
                                       crapcob.nrcnvcob = crapcco.nrconven  AND
                                       crapcob.nrdctabb = crapcco.nrdctabb  AND
                                       crapcob.nrdocmto = aux-bloqueto3     
                                       NO-LOCK NO-ERROR.

                    IF  NOT AVAILABLE crapcob   THEN 
                        FIND crapcob WHERE 
                             crapcob.cdcooper = crapcop.cdcooper  AND
                             crapcob.cdbandoc = crapcco.cddbanco  AND
                             crapcob.nrcnvcob = crapcco.nrconven  AND
                             crapcob.nrdctabb = crapcco.nrdctabb  AND
                             crapcob.nrdocmto = aux-bloqueto1     
                             NO-LOCK NO-ERROR.
                END.   

                /* se nao existir titulo, entao 
                   verificar se cooperado eh migrado */
                IF  NOT AVAIL crapcob THEN
                    DO: 
                        
                        IF  crapcco.dsorgarq = "MIGRACAO" THEN DO:

                            /* buscar convenio origem */
                            FIND b-crapcco WHERE
                                 b-crapcco.cdcooper <> crapcco.cdcooper AND
                                 b-crapcco.nrconven = crapcco.nrconven
                                 NO-LOCK NO-ERROR.

                            IF  AVAIL b-crapcco THEN DO:
                                FIND  craptco WHERE 
                                      craptco.cdcooper = crapcop.cdcooper   AND
                                      craptco.cdcopant = b-crapcco.cdcooper AND
                                      craptco.nrctaant = aux-nrdconta       AND
                                      craptco.flgativo = TRUE               AND
                                      craptco.tpctatrf <> 3
                                      NO-LOCK NO-ERROR.

                                /* se cooperado nao foi migrado, entao eh 
                                   liquidacao interbancaria */
                                IF  NOT AVAIL craptco THEN
                                    RETURN "OK".
                            END.
                        END.
                        ELSE DO:

                            FIND  craptco WHERE 
                                  craptco.cdcopant = crapcop.cdcooper   AND
                                  craptco.nrctaant = aux-nrdconta       AND
                                  craptco.flgativo = TRUE               AND
                                  craptco.tpctatrf <> 3
                                  NO-LOCK NO-ERROR.

                            /* se cooperado foi migrado, entao eh 
                               liquidacao interbancaria */
                            IF  AVAIL craptco THEN
                                RETURN "OK".

                        END.

                END.
                
                /* condicao especial para contas migradas */
                IF  NOT AVAIL crapcob THEN
                    DO:
                       /*IF  ((crapcco.dsorgarq = "IMPRESSO PELO SOFTWARE") OR 
                            (crapcco.dsorgarq = "MIGRACAO" AND 
                            CAN-DO("1601301,0457595,0458031",
                              STRING(crapcco.nrconven,"9999999")))) AND
                            NOT CAN-FIND(crapass WHERE 
                                         crapass.cdcooper = crapcop.cdcooper AND
                                         crapass.nrdconta = aux-nrdconta) THEN*/

                       IF  (crapcco.dsorgarq = "IMPRESSO PELO SOFTWARE" AND 
                            crapcco.cddbanco = 001 AND
                             NOT CAN-FIND(crapass WHERE 
                                         crapass.cdcooper = crapcop.cdcooper AND
                                         crapass.nrdconta = aux-nrdconta)) 
                            OR 

                            (crapcco.dsorgarq = "MIGRACAO" AND 
                             CAN-DO("1601301,0457595,0458031",
                                    STRING(crapcco.nrconven,"9999999")) AND
                             NOT CAN-FIND(craptco WHERE
                                          craptco.cdcooper = crapcop.cdcooper AND
                                          craptco.nrctaant = aux-nrdconta AND
                                          craptco.tpctatrf <> 3 AND
                                          craptco.flgativo = TRUE))
                             THEN

                           RETURN "OK".
                    END.
                
                IF  NOT AVAILABLE crapcob THEN DO: 
                        /*IF (crapcco.dsorgarq = "IMPRESSO PELO SOFTWARE" AND
                             crapcco.cddbanco = 001) OR 
                            (crapcco.dsorgarq = "MIGRACAO" AND 
                             CAN-DO("1601301,0457595,0458031", 
                               STRING(crapcco.nrconven,"9999999")) AND
                             CAN-FIND(crapass WHERE 
                                      crapass.cdcooper = crapcop.cdcooper AND
                                      crapass.nrdconta = aux-nrdconta)) THEN*/

                        IF  (crapcco.dsorgarq = "IMPRESSO PELO SOFTWARE" AND 
                             crapcco.cddbanco = 001 AND
                             CAN-FIND(crapass WHERE 
                                      crapass.cdcooper = crapcop.cdcooper AND
                                      crapass.nrdconta = aux-nrdconta)) THEN
                        DO:

                            CREATE crapcob.
                            ASSIGN crapcob.cdcooper = crapcop.cdcooper
                                   crapcob.nrdconta = aux-nrdconta
                                   crapcob.cdbandoc = crapcco.cddbanco
                                   crapcob.nrdctabb = crapcco.nrdctabb
                                   crapcob.nrcnvcob = crapcco.nrconven
                                   crapcob.nrdocmto = aux-bloqueto2
                                   crapcob.incobran = 0
                                   crapcob.dtretcob = crapdat.dtmvtocd
                                   crapcob.nrnosnum = aux_nrnosnum
                                   /* ao criar titulo, identificar que 
                                      pertence a cooperativa (Rafael) */
                                   p-insittit   = 2
                                   p-intitcop   = 1
                                   p-nrdconta   = crapcob.nrdconta
                                   p-convenio   = crapcob.nrcnvcob
                                   p-bloqueto   = crapcob.nrdocmto
                                   p-contaconve = crapcco.nrdctabb.

                        END.
                        ELSE DO: 
                        
                            IF (crapcco.dsorgarq = "MIGRACAO" AND 
                                CAN-DO("1601301,0457595,0458031",
                                     STRING(crapcco.nrconven,"9999999"))) THEN DO:

                                FIND craptco WHERE
                                     craptco.cdcooper = crapcop.cdcooper AND
                                     craptco.nrctaant = aux-nrdconta AND
                                     craptco.tpctatrf <> 3 AND
                                     craptco.flgativo = TRUE
                                     NO-LOCK NO-ERROR.

                                IF  AVAIL craptco THEN DO:
                                    CREATE crapcob.
                                    ASSIGN crapcob.cdcooper = crapcop.cdcooper
                                           crapcob.nrdconta = craptco.nrdconta
                                           crapcob.cdbandoc = crapcco.cddbanco
                                           crapcob.nrdctabb = crapcco.nrdctabb
                                           crapcob.nrcnvcob = crapcco.nrconven
                                           crapcob.nrdocmto = aux-bloqueto2
                                           crapcob.incobran = 0
                                           crapcob.dtretcob = crapdat.dtmvtocd
                                           crapcob.nrnosnum = aux_nrnosnum
                                           /* ao criar titulo, identificar que 
                                              pertence a cooperativa (Rafael) */
                                           p-insittit   = 2
                                           p-intitcop   = 1
                                           p-nrdconta   = crapcob.nrdconta
                                           p-convenio   = crapcob.nrcnvcob
                                           p-bloqueto   = crapcob.nrdocmto
                                           p-contaconve = crapcco.nrdctabb.
                                END.
                            END.
                            ELSE DO:
                                  ASSIGN i-cod-erro  = 592           
                                         c-desc-erro = "".
                          
                                  RUN cria-erro (INPUT p-cooper,
                                                 INPUT p-cod-agencia,
                                                 INPUT aux_nrdcaixa,
                                                 INPUT i-cod-erro,
                                                 INPUT c-desc-erro,
                                                 INPUT YES).

                                  RETURN "NOK".
                            END.
                        END.
                END.
                ELSE
                    DO:
                      IF (crapcob.incobran = 5 OR   /* excluido/pago */
                          crapcob.incobran = 3) AND /* baixado       */
                          p-flgcritica          THEN
                         DO: 
                            ASSIGN i-cod-erro  = 594     
                                   c-desc-erro = "".
          
                            RUN cria-erro (INPUT p-cooper,
                                           INPUT p-cod-agencia,
                                           INPUT aux_nrdcaixa,
                                           INPUT i-cod-erro,
                                           INPUT c-desc-erro,
                                           INPUT YES).

                            RETURN "NOK".
                         END.
                      ELSE
                      IF crapcob.dtretcob = ? AND p-flgcritica THEN
                         DO:
                            ASSIGN i-cod-erro  = 589     
                                   c-desc-erro = "".

                            RUN cria-erro (INPUT p-cooper,
                                           INPUT p-cod-agencia,
                                           INPUT aux_nrdcaixa,
                                           INPUT i-cod-erro,
                                           INPUT c-desc-erro,
                                           INPUT YES).

                            RETURN "NOK".
                         END.
                      ELSE
                         DO:
                             ASSIGN p-insittit   = 2
                                    p-intitcop   = 1
                                    p-nrdconta   = crapcob.nrdconta
                                    p-convenio   = crapcob.nrcnvcob
                                    p-bloqueto   = crapcob.nrdocmto
                                    p-contaconve = crapcco.nrdctabb.
                         END.
                END.
         END.
   END.
   ELSE
   IF  aux-banco = crapcop.cdbcoctl  THEN /* IF CECRED */
   DO:
       FIND crapcco WHERE crapcco.cdcooper = crapcop.cdcooper    AND
                          crapcco.cddbanco = aux-banco           AND
                          crapcco.nrconven = INTE(aux-convenio1) 
                          NO-LOCK NO-ERROR.

       IF  AVAIL crapcco  THEN
       DO:
           IF  crapcco.dsorgarq = "IMPRESSO PELO SOFTWARE" OR
               crapcco.dsorgarq = "INTERNET"               OR 
               crapcco.dsorgarq = "EMPRESTIMO"             OR
               crapcco.dsorgarq = "MIGRACAO"               OR
			   crapcco.dsorgarq = "ACORDO"				 THEN
           DO:
               FIND crapcob WHERE 
                    crapcob.cdcooper = crapcop.cdcooper  AND
                    crapcob.cdbandoc = crapcco.cddbanco  AND
                    crapcob.nrcnvcob = crapcco.nrconven  AND
                    crapcob.nrdctabb = crapcco.nrdctabb  AND
                    crapcob.nrdocmto = aux-bloqueto2     AND
                    crapcob.nrdconta = aux-nrdconta
                    NO-LOCK NO-ERROR.

               IF  NOT AVAIL crapcob AND 
                   crapcco.dsorgarq = "MIGRACAO" THEN DO:

                   /* procurar convenio da cooperativa origem */
                   FIND b-crapcco WHERE
                        b-crapcco.cdcooper <> crapcco.cdcooper AND
                        b-crapcco.nrconven = crapcco.nrconven
                        NO-LOCK NO-ERROR.

                   IF  AVAIL b-crapcco THEN DO:

                       FIND  craptco WHERE 
                             craptco.cdcopant = b-crapcco.cdcooper AND
                             craptco.nrctaant = aux-nrdconta       AND
                             craptco.flgativo = TRUE               AND
                             craptco.tpctatrf <> 3
                             NO-LOCK NO-ERROR.

                       IF  AVAIL craptco THEN DO:
    
                           FIND crapcob WHERE 
                                crapcob.cdcooper = crapcop.cdcooper  AND
                                crapcob.cdbandoc = crapcco.cddbanco  AND
                                crapcob.nrcnvcob = crapcco.nrconven  AND
                                crapcob.nrdctabb = crapcco.nrdctabb  AND
                                crapcob.nrdocmto = aux-bloqueto2     AND
                                crapcob.nrdconta = craptco.nrdconta
                                NO-LOCK NO-ERROR.
                       END.

                   END.
               END.

               IF  NOT AVAILABLE crapcob THEN
                   DO:   
                       /* verificar se cooperado foi migrado sem 
                          alteracao do numero da conta */
                       FIND  craptco WHERE 
                             craptco.cdcopant = crapcop.cdcooper  AND
                             craptco.nrctaant = aux-nrdconta      AND
                             craptco.flgativo = TRUE              AND
                             craptco.tpctatrf <> 3
                             NO-LOCK NO-ERROR.
    
                        /* se cooperado foi migrado, entao eh 
                           liquidacao interbancaria */
                       IF  AVAIL craptco THEN
                           RETURN "OK".

                       IF  (crapcco.dsorgarq = "IMPRESSO PELO SOFTWARE") OR 
                           (crapcco.dsorgarq = "MIGRACAO" AND 
                             CAN-DO("1601301,0457595,0458031", 
                               STRING(crapcco.nrconven,"9999999")) AND
                             CAN-FIND(crapass WHERE 
                                      crapass.cdcooper = crapcop.cdcooper AND
                                      crapass.nrdconta = aux-nrdconta)) THEN

                             DO:
                                 CREATE crapcob.
                                 ASSIGN crapcob.cdcooper = crapcop.cdcooper
                                        crapcob.nrdconta = aux-nrdconta
                                        crapcob.cdbandoc = crapcco.cddbanco
                                        crapcob.nrdctabb = crapcco.nrdctabb
                                        crapcob.nrcnvcob = crapcco.nrconven
                                        crapcob.nrdocmto = aux-bloqueto2
                                        crapcob.incobran = 0
                                        crapcob.dtretcob = crapdat.dtmvtocd
                                        crapcob.nrnosnum = aux_nrnosnum.
                             END.
                        ELSE
                             DO:
                                 /* se titulo 085 nao encontrado e migracao 
                                    entao eh liquidacao interbancaria */
                                 IF  crapcco.dsorgarq = "MIGRACAO" THEN
                                     RETURN "OK".

                                 ASSIGN i-cod-erro  = 592           
                                        c-desc-erro = "".
    
                                 RUN cria-erro (INPUT p-cooper,
                                                INPUT p-cod-agencia,
                                                INPUT aux_nrdcaixa,
                                                INPUT i-cod-erro,
                                                INPUT c-desc-erro,
                                                INPUT YES).
    
                                 RETURN "NOK".
                             END.
                   END.
               ELSE
                   DO:    
                       /* verificar se cooperado foi migrado */
                      FIND  craptco WHERE 
                            craptco.cdcopant = crapcob.cdcooper AND
                            craptco.nrctaant = crapcob.nrdconta  AND
                            craptco.flgativo = TRUE              AND
                            craptco.tpctatrf <> 3
                            NO-LOCK NO-ERROR.
    
                       /* se cooperado foi migrado, entao eh 
                          liquidacao interbancaria */
                      IF  AVAIL craptco THEN
                          RETURN "OK".

                      IF (crapcob.incobran = 5 OR   /* excluido/pago */
                          crapcob.incobran = 3) AND /* baixado       */
                          p-flgcritica          THEN
                        DO: 
                           ASSIGN i-cod-erro  = 594     
                                  c-desc-erro = "".
    
                           RUN cria-erro (INPUT p-cooper,
                                          INPUT p-cod-agencia,
                                          INPUT aux_nrdcaixa,
                                          INPUT i-cod-erro,
                                          INPUT c-desc-erro,
                                          INPUT YES).
    
                           RETURN "NOK".
                        END.
                     ELSE
                     IF crapcob.dtretcob = ? AND p-flgcritica THEN
                        DO:
                           ASSIGN i-cod-erro  = 589     
                                  c-desc-erro = "".
    
                           RUN cria-erro (INPUT p-cooper,
                                          INPUT p-cod-agencia,
                                          INPUT aux_nrdcaixa,
                                          INPUT i-cod-erro,
                                          INPUT c-desc-erro,
                                          INPUT YES).
    
                           RETURN "NOK".
                        END.
                     ELSE
                        ASSIGN p-insittit   = 2
                               p-intitcop   = 1
                               p-nrdconta   = crapcob.nrdconta
                               p-convenio   = crapcob.nrcnvcob
                               p-bloqueto   = crapcob.nrdocmto
                               p-contaconve = crapcco.nrdctabb.
                     
               END.
           END.
       END.
   END. /* FIM IF CECRED */
   
   VALIDATE crapcob.

   RETURN "OK".

END PROCEDURE. /* lanca-titulos-coop */

PROCEDURE gera-tarifa-titulo:
 
    DEF INPUT  PARAM p-cdcooper          AS INTE                       NO-UNDO.
    DEF INPUT  PARAM p-nrdconta-cob      AS INTE                       NO-UNDO.
    DEF INPUT  PARAM p-cod-agencia       AS INTE                       NO-UNDO.
    DEF INPUT  PARAM p-nro-caixa         AS INTE                       NO-UNDO.
    DEF INPUT  PARAM p-cod-operador      AS CHAR                       NO-UNDO.
    DEF INPUT  PARAM p-convenio          AS INTE                       NO-UNDO.
    DEF INPUT  PARAM p-nrautdoc          AS INTE                       NO-UNDO.
    
    DEF OUTPUT PARAM p-dscritic          AS CHAR                       NO-UNDO.
    
    DEF VARIABLE     aux_cdhistor        LIKE craplcm.cdhistor         NO-UNDO.
    DEF VARIABLE     aux_vltarifa        LIKE craplcm.vllanmto         NO-UNDO.
    
    /* Data do sistema */
    FIND crapdat WHERE crapdat.cdcooper = p-cdcooper NO-LOCK NO-ERROR.
    
    /* Pega o historico e valor da taxa */
    FIND crapcco WHERE crapcco.cdcooper = p-cdcooper AND
                       crapcco.nrconven = p-convenio NO-LOCK NO-ERROR.
                       
    IF  NOT AVAILABLE crapcco  THEN
        DO:
            p-dscritic = "Convenio nao encontrado.".
            RETURN "NOK".
        END. 

    ASSIGN tar_inpessoa = 2. /* Assume tarifa pessoa juridica como padrao */

    FIND crapass WHERE crapass.cdcooper = p-cdcooper AND
                       crapass.nrdconta = p-nrdconta-cob
                       NO-LOCK NO-ERROR.

    IF  AVAIL crapass  THEN
        tar_inpessoa = crapass.inpessoa.
    
    RUN pega_valor_tarifas(
            INPUT  p-cdcooper, 
            INPUT  p-nrdconta-cob,
            INPUT  p-convenio,  
            INPUT  tar_inpessoa,
            OUTPUT tar_histarcx,
            OUTPUT tar_histarnt,
            OUTPUT tar_histrtaa,
            OUTPUT tar_cdhisest,
            OUTPUT tar_dtdivulg,
            OUTPUT tar_dtvigenc,
            OUTPUT tar_cdfvlccx,
            OUTPUT tar_vlrtarcx,
            OUTPUT tar_vlrtarnt,
            OUTPUT tar_vltrftaa,
            OUTPUT tar_cdfvlcnt,
            OUTPUT tar_cdfvltaa,
            OUTPUT TABLE tt-erro).
    
    IF  p-cod-agencia = 90  THEN
        /* Tarifa para pagamento atraves da internet */
        ASSIGN aux_cdhistor = tar_histarnt 
               aux_vltarifa = tar_vlrtarnt 
               aux_cdfvlcop = tar_cdfvlcnt. 
    ELSE
    IF  p-cod-agencia = 91   THEN
        /* Tarifa para pagamento atraves de TAA */
        ASSIGN aux_cdhistor = tar_histrtaa 
               aux_vltarifa = tar_vltrftaa 
               aux_cdfvlcop = tar_cdfvltaa.  
    ELSE
        /* Tarifa para pagamento atraves do caixa on-line */    
        ASSIGN aux_cdhistor = tar_histarcx 
               aux_vltarifa = tar_vlrtarcx 
               aux_cdfvlcop = tar_cdfvlccx. 


    /* Ignora caso tarifa esteja zerada */
    IF  aux_vltarifa = 0  THEN
        RETURN "OK".
 
    /* Gera lancamento tarifa na craplat */
    RUN efetua-lanc-craplat(
               INPUT p-cdcooper,
               INPUT p-nrdconta-cob,
               INPUT crapdat.dtmvtocd,
               INPUT aux_cdhistor,
               INPUT aux_vltarifa,
               INPUT p-cod-operador,
               INPUT p-cod-agencia,
               INPUT 100, /*cdbccxlt*/
               INPUT (10900 + p-nro-caixa),
               INPUT 1, /*tplotmov*/
               INPUT 0,
               INPUT p-nrdconta-cob,
               INPUT STRING(p-nrdconta-cob,"99999999"),
               INPUT "",
               INPUT 0,
               INPUT 0,
               INPUT 0,
               INPUT FALSE,
               INPUT 0, 
               INPUT aux_cdfvlcop,
               INPUT 1,
               OUTPUT TABLE tt-erro).


    RETURN "OK".
 
END PROCEDURE. /* fim gera-tarifa-titulo */

/* mesma procedure utilizada no programa crps538, se alterar aqui
   nao esquecer de alterar la tambem */
PROCEDURE verifica-vencimento-titulo:

    DEF  INPUT PARAM p-cod-cooper     AS INTE               NO-UNDO.
    DEF  INPUT PARAM p-cod-agencia    AS INTE               NO-UNDO.
    DEF  INPUT PARAM p-dt-agendamento AS DATE               NO-UNDO.
    DEF  INPUT PARAM p-dt-vencto      AS DATE               NO-UNDO.
                                                            
    DEF OUTPUT PARAM p-critica-data   AS LOGI               NO-UNDO.
                                                            
    DEF VAR dt-dia-util               AS DATE               NO-UNDO.
    DEF VAR aux_libepgto              AS LOG                NO-UNDO.

    ASSIGN p-critica-data = FALSE
           aux_libepgto   = FALSE.


    FIND crapdat WHERE crapdat.cdcooper = p-cod-cooper 
                       NO-LOCK NO-ERROR.
    
    IF p-dt-agendamento = ?  THEN  
       DO: 
           IF  p-cod-cooper = 1    AND 
               p-cod-agencia = 62  AND 
              (p-dt-vencto >= 09/07/2011   OR
               p-dt-vencto <= 09/12/2011)  AND
               crapdat.dtmvtocd = 09/13/2011  THEN
               RETURN.

           /** Permitir o pagamento de titulos vencidos entre 13/08/2011 e 
               15/08/2011 na Sede da Credicomin, devido ao feriado de 
               na cidade de Lages (15/08) **/
           IF  p-cod-cooper = 10              AND 
               p-cod-agencia = 1              AND 
               p-dt-vencto >= 08/13/2011      AND 
               p-dt-vencto <= 08/15/2011      AND 
               crapdat.dtmvtocd = 08/16/2011  THEN
               RETURN.

           /** Pagamento no dia **/
           IF  p-dt-vencto > crapdat.dtmvtocd  THEN
               RETURN.
               
           IF  crapdat.dtmvtoan < p-dt-vencto  THEN
               RETURN.

          p-critica-data = TRUE.
           
           /** Tratamento para permitir pagamento no primeiro dia util do **/
           /** ano de titulos vencidos no ultimo dia util do ano anterior **/
           IF  YEAR(crapdat.dtmvtoan) <> YEAR(crapdat.dtmvtocd)  THEN
               DO: 
                   dt-dia-util = DATE(12,31,YEAR(crapdat.dtmvtoan)).
                  
                   /** Se dia 31/12 for segunda-feira obtem data do sabado **/
                   /** para aceitar vencidos do ultimo final de semana     **/
                   IF  WEEKDAY(dt-dia-util) = 2  THEN
                       dt-dia-util = DATE(12,29,YEAR(crapdat.dtmvtoan)).
                   ELSE
                   /** Se dia 31/12 for domingo, o ultimo dia util e 29/12 **/
                   IF  WEEKDAY(dt-dia-util) = 1  THEN
                       dt-dia-util = DATE(12,29,YEAR(crapdat.dtmvtoan)).
                   ELSE
                   /** Se dia 31/12 for sabado, o ultimo dia util e 30/12 **/
                   IF  WEEKDAY(dt-dia-util) = 7  THEN
                       dt-dia-util = DATE(12,30,YEAR(crapdat.dtmvtoan)).

                   /** Verifica se pode aceitar o titulo vencido **/
                   IF  p-dt-vencto >= dt-dia-util  THEN
                       p-critica-data = FALSE.
               END.

           /* A verificacao abaixo eh realizada apenas para cdagenci <> 90,
              cdagenci <> 91 */
           IF NOT VALID-HANDLE(h-b1wgen0044) THEN
              RUN sistema/generico/procedures/b1wgen0044.p
                              PERSISTENT SET h-b1wgen0044.
           
           RUN verifica_feriado IN h-b1wgen0044 (INPUT p-cod-cooper,
                                                 INPUT crapdat.dtmvtocd,
                                                 INPUT p-cod-agencia,
                                                 INPUT p-dt-vencto,
                                                 OUTPUT aux_libepgto,
                                                 OUTPUT TABLE tt-erro).

           
           IF  RETURN-VALUE = "NOK" THEN    
               RETURN "NOK".
           
           IF  aux_libepgto = FALSE AND 
               p-cod-agencia <> 90  AND 
               p-cod-agencia <> 91  THEN
               ASSIGN p-critica-data = FALSE.
                     
           IF VALID-HANDLE(h-b1wgen0044) THEN
              DELETE PROCEDURE h-b1wgen0044. 

       END.
    ELSE  
       DO: /** Agendamento de Pagamento **/
           DO WHILE TRUE:
          
               IF  CAN-DO("1,7",STRING(WEEKDAY(p-dt-vencto)))              OR
                   CAN-FIND(crapfer WHERE crapfer.cdcooper = p-cod-cooper  AND
                                          crapfer.dtferiad = p-dt-vencto)  THEN
                   DO:
                       p-dt-vencto = p-dt-vencto + 1.
                       NEXT.
                   END.

               LEAVE.  
          
           END. /** Fim do DO WHILE TRUE **/
           
           IF  p-dt-vencto >= p-dt-agendamento  THEN
               RETURN.
               
           p-critica-data = TRUE.

           /** Aceita agendamento de titulo com vencimento no ultimo dia **/
           /** util do ano somente no primeiro dia util do proximo ano   **/
           /** Exemplo: VENCIMENTO 31/12/2009 - AGENDAMENTO - 04/01/2010 **/   
           IF (YEAR(p-dt-agendamento) - YEAR(p-dt-vencto)) = 1  THEN
               DO:
                   dt-dia-util = DATE(01,01,YEAR(p-dt-agendamento)).
    
                   DO WHILE TRUE:
    
                       IF  CAN-DO("1,7",STRING(WEEKDAY(dt-dia-util)))  OR
                           CAN-FIND(crapfer WHERE 
                                    crapfer.cdcooper = p-cod-cooper    AND
                                    crapfer.dtferiad = dt-dia-util)    THEN
                           DO:
                               dt-dia-util = dt-dia-util + 1.
                               NEXT.
                           END.
    
                       LEAVE.
    
                   END. /** Fim do DO WHILE TRUE **/

                   IF  p-dt-agendamento = dt-dia-util  THEN
                       DO:
                           dt-dia-util = DATE(12,31,YEAR(p-dt-vencto)).

                           /** Se 31/12 for segunda-feira obtem data do **/
                           /** sabado para aceitar vencidos do ultimo   **
                           **  final de semana                          **/
                           IF  WEEKDAY(dt-dia-util) = 2  THEN
                               dt-dia-util = DATE(12,29,YEAR(p-dt-vencto)).
                           ELSE
                           /** Se 31/12 e domingo, ultimo dia util e 29/12 **/
                           IF  WEEKDAY(dt-dia-util) = 1  THEN
                               dt-dia-util = DATE(12,29,YEAR(p-dt-vencto)).
                           ELSE
                           /** Se 31/12 e sabado, ultimo dia util e 30/12 **/
                           IF  WEEKDAY(dt-dia-util) = 7  THEN
                               dt-dia-util = DATE(12,30,YEAR(p-dt-vencto)).

                           /** Verifica se pode aceitar o titulo vencido **/
                           IF  p-dt-vencto >= dt-dia-util  THEN
                               p-critica-data = FALSE.

                       END.

               END.

       END.    

END PROCEDURE.

PROCEDURE atualiza-cheque:

    DEF INPUT  PARAM p-cooper              AS CHAR                     NO-UNDO.
    DEF INPUT  PARAM p-cod-agencia         AS INT  /* Agencia */       NO-UNDO.
    DEF INPUT  PARAM p-nro-caixa           AS INT  FORMAT "999"        NO-UNDO.
    DEF INPUT  PARAM p-operador            AS CHAR                     NO-UNDO.

    DEF INPUT  PARAM p-cmc-7               AS CHAR                     NO-UNDO.
    DEF INPUT  PARAM p-cmc-7-dig           AS CHAR                     NO-UNDO.
   
    DEF INPUT  PARAM p-cdcmpchq            AS INT  FORMAT "zz9"        NO-UNDO. 
    DEF INPUT  PARAM p-cdbanchq            AS INT  FORMAT "zz9"        NO-UNDO.
    DEF INPUT  PARAM p-cdagechq            AS INT  FORMAT "zzz9"       NO-UNDO.
    DEF INPUT  PARAM p-nrddigc1            AS INT  FORMAT "9" /* C1 */ NO-UNDO.
    DEF INPUT  PARAM p-nrctabdb            AS DEC  FORMAT "zzz,zzz,zzz,9"
                                                                       NO-UNDO. 
    DEF INPUT  PARAM p-nrddigc2            AS INT  FORMAT "9" /* C2 */ NO-UNDO.
    DEF INPUT  PARAM p-nro-cheque          AS INT  FORMAT "zzz,zz9"    NO-UNDO.
    DEF INPUT  PARAM p-nrddigc3            AS INT  FORMAT "9" /* C3 */ NO-UNDO.
    DEF INPUT  PARAM p-valor               AS DEC                      NO-UNDO.
                               
    DEF INPUT  PARAM p-nrcnvbol            AS INT                      NO-UNDO.
    DEF INPUT  PARAM p-nrctabol            AS INT                      NO-UNDO.
    DEF INPUT  PARAM p-nrboleto            AS INT                      NO-UNDO.

    DEF VAR aux_cdcritic                   AS INTE                     NO-UNDO.
    DEF VAR tab_vlchqmai                   AS DEC                      NO-UNDO.
    DEF VAR aux_tpdmovto                   AS INTE                     NO-UNDO.
    DEF VAR aux_contador                   AS INTE                     NO-UNDO.
    DEF VAR aux_nrdolote                   AS INTE                     NO-UNDO.

    DEF VAR p-nro-calculado                AS DECI                     NO-UNDO.
    DEF VAR p-lista-digito                 AS CHAR                     NO-UNDO.


    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper NO-LOCK NO-ERROR.


    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    
    ASSIGN aux_nrdolote = 28000 + p-nro-caixa.

    
    /*  Verifica o horario de corte  */

    FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper   AND 
                       craptab.nmsistem = "CRED"         AND
                       craptab.tptabela = "GENERI"       AND
                       craptab.cdempres = 0              AND
                       craptab.cdacesso = "HRTRCOMPEL"   AND
                       craptab.tpregist = p-cod-agencia NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE craptab   THEN
         DO:
             aux_cdcritic = 676.
         END.
    ELSE
    IF   INT(SUBSTR(craptab.dstextab,1,1)) <> 0   THEN
         DO:
             aux_cdcritic = 677.
         END.
    ELSE     
    IF   INT(SUBSTR(craptab.dstextab,3,5)) <= TIME   THEN
         DO:
             aux_cdcritic = 676.
         END.

    IF  aux_cdcritic > 0 THEN
        DO:
            ASSIGN  i-cod-erro  = aux_cdcritic
            c-desc-erro = " ".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.
     
    /*  Le tabela com o valor dos cheques maiores  */

    FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND 
                       craptab.nmsistem = "CRED"         AND
                       craptab.tptabela = "USUARI"       AND
                       craptab.cdempres = 11             AND
                       craptab.cdacesso = "MAIORESCHQ"   AND
                       craptab.tpregist = 1 
                       NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE craptab   THEN
         tab_vlchqmai = 1.
    ELSE
         tab_vlchqmai = DECIMAL(SUBSTRING(craptab.dstextab,01,15)).

    IF   /* tel_vlcheque */ p-valor < tab_vlchqmai   THEN
         aux_tpdmovto = 2.
    ELSE
         aux_tpdmovto = 1.
    
    /*  Verifica se ja existe o lancamento  */
    
    IF   CAN-FIND(crapchd WHERE crapchd.cdcooper = crapcop.cdcooper     AND  
                                crapchd.dtmvtolt = crapdat.dtmvtolt     AND
                                crapchd.cdcmpchq = p-cdcmpchq           AND
                                crapchd.cdbanchq = p-cdbanchq           AND
                                crapchd.cdagechq = p-cdagechq           AND
                                crapchd.nrctachq = p-nrctabdb           AND
                                crapchd.nrcheque = p-nro-cheque)  THEN
         DO:
             ASSIGN i-cod-erro  = 92
                    c-desc-erro = " ".
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                       RETURN "NOK".
             
         END.
 
    DO WHILE TRUE:

        ASSIGN in99 = in99 + 1.
        
        FIND craplot WHERE
             craplot.cdcooper = crapcop.cdcooper  AND
             craplot.dtmvtolt = crapdat.dtmvtocd  AND
             craplot.cdagenci = p-cod-agencia     AND
             craplot.cdbccxlt = 500               AND  /* Fixo */
             craplot.nrdolote = aux_nrdolote
             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        
        IF  NOT AVAILABLE craplot  THEN 
            DO:
                IF  LOCKED craplot  THEN
                    DO:
                        IF  in99 <= 10  THEN 
                            DO:
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                            END.
                        ELSE 
                            DO:
                                ASSIGN i-cod-erro  = 0
                                       c-desc-erro = "Lote ja esta em uso. " +
                                                     "Tente novamente.".
                                            
                                RUN cria-erro (INPUT p-cooper,
                                               INPUT p-cod-agencia,
                                               INPUT p-nro-caixa,
                                               INPUT i-cod-erro,
                                               INPUT c-desc-erro,
                                               INPUT YES).
                                               
                                RETURN "NOK".
                            END.
                    END.
                ELSE
                    DO:        
                        CREATE craplot.
                        ASSIGN craplot.cdcooper = crapcop.cdcooper
                               craplot.dtmvtolt = crapdat.dtmvtocd
                               craplot.cdagenci = p-cod-agencia   
                               craplot.cdbccxlt = 500              
                               craplot.nrdolote = aux_nrdolote
                               craplot.cdoperad = p-operador
                               craplot.cdhistor = i-cdhistor
                               craplot.nrdcaixa = p-nro-caixa
                               craplot.cdopecxa = p-operador 
                               craplot.tplotmov = 23.  
                        
                    END.                   
            END.
            
        LEAVE.
  
    END. /* Fim do DO WHILE TRUE */   

    
    RUN dbo/pcrap09.p  (INPUT p-cooper,
                        INPUT p-cmc-7,
                        OUTPUT p-nro-calculado,
                        OUTPUT p-lista-digito).
    
    CREATE crapchd.
    ASSIGN crapchd.cdagechq = p-cdagechq    
           crapchd.cdagenci = p-cod-agencia 
           crapchd.cdbanchq = p-cdbanchq    
           crapchd.cdbccxlt = 500            
           crapchd.cdcmpchq = p-cdcmpchq    
           crapchd.cdoperad = p-operador 
           crapchd.cdsitatu = 1
           crapchd.dsdocmc7 = p-cmc-7 
           crapchd.dtmvtolt = crapdat.dtmvtolt 
           crapchd.inchqcop = 0 
           crapchd.insitchq = 0
           crapchd.nrcheque = p-nro-cheque 
           crapchd.nrctachq = p-nrctabdb 
           crapchd.nrdconta = 0 
           
           crapchd.nrddigc1 = p-nrddigc1 
           crapchd.nrddigc2 = p-nrddigc2 
           crapchd.nrddigc3 = p-nrddigc3 
           
           crapchd.nrddigv1 = INT(ENTRY(1,p-lista-digito))
           crapchd.nrddigv2 = INT(ENTRY(2,p-lista-digito))
           crapchd.nrddigv3 = INT(ENTRY(3,p-lista-digito))
        
           crapchd.cdtipchq = INT(SUBSTRING(p-cmc-7,20,1)) 
          
           crapchd.nrdocmto = 0
           crapchd.nrdolote = aux_nrdolote  
           crapchd.nrseqdig = craplot.nrseqdig + 1
           crapchd.nrterfin = 0
           crapchd.tpdmovto = aux_tpdmovto
           crapchd.vlcheque = p-valor 
           crapchd.cdcooper = crapcop.cdcooper 
           crapchd.insitprv = 0
           crapchd.nrprevia = 0
           crapchd.hrprevia = 0
           crapchd.nrcnvbol = p-nrcnvbol 
           crapchd.nrctabol = p-nrctabol
           crapchd.nrboleto = p-nrboleto

           craplot.qtcompln = craplot.qtcompln + 1
           craplot.qtinfoln = craplot.qtinfoln + 1
           craplot.vlcompdb = craplot.vlcompdb + p-valor
           craplot.vlcompcr = craplot.vlcompcr + p-valor
           craplot.vlinfodb = craplot.vlinfodb + p-valor
           craplot.vlinfocr = craplot.vlinfocr + p-valor
           craplot.nrseqdig = crapchd.nrseqdig.
    VALIDATE craplot.
    VALIDATE crapchd.

    /** Incrementa contagem de cheques para a previa **/
    RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00. 
    RUN atualiza-previa-caixa  IN h-b1crap00  (INPUT p-cooper,
                                               INPUT p-cod-agencia,
                                               INPUT p-nro-caixa,
                                               INPUT p-operador,
                                               INPUT crapdat.dtmvtolt,
                                               INPUT 1). /*Inclusao*/ 
    DELETE PROCEDURE h-b1crap00.
    
END PROCEDURE.

PROCEDURE envia_vrboleto_spb:
    
    DEF INPUT  PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF INPUT  PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF INPUT  PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF INPUT  PARAM par_nrinssac AS DECI                           NO-UNDO.
    DEF INPUT  PARAM par_idseqttl LIKE crapttl.idseqttl             NO-UNDO.
    DEF INPUT  PARAM par_cdbarras AS CHAR                           NO-UNDO.
    DEF INPUT  PARAM par_nrinsced AS DECI                           NO-UNDO.
    DEF INPUT  PARAM par_vldpagto AS DECI                           NO-UNDO.
    DEF INPUT  PARAM par_idorigem AS INT                            NO-UNDO.    

    DEF VAR h-b1wgen0011          AS HANDLE                         NO-UNDO.
    DEF VAR h-b1wgen0046          AS HANDLE                         NO-UNDO.
    DEF VAR h-b1wgen0079          AS HANDLE                         NO-UNDO.
    DEF VAR h-b1wgen9999          AS HANDLE                         NO-UNDO.
    DEF VAR aux_cdbccxlt          AS INTE                           NO-UNDO.
    DEF VAR aux_conteudo          AS CHAR                           NO-UNDO.
    DEF VAR aux_lindigit          AS CHAR                           NO-UNDO.
    DEF VAR aux_nrctrlif          AS CHAR                           NO-UNDO.
    DEF VAR aux_qttitulo          AS INTE                           NO-UNDO.
    DEF VAR aux_dscritic          AS CHAR                           NO-UNDO.
    DEF VAR aux_tpinsced          AS INTE                           NO-UNDO.
    DEF VAR aux_tppesced          AS CHAR                           NO-UNDO.
    DEF VAR aux_tpinssac          AS INTE                           NO-UNDO.
    DEF VAR aux_tppessac          AS CHAR                           NO-UNDO.
    DEF VAR aux_flginsok          AS LOGICAL                        NO-UNDO.
    DEF VAR aux_cdcritic          AS INTE                           NO-UNDO.

    DEF VAR aux_sufixo            AS CHAR                           NO-UNDO.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    /* Data do sistema */
    FIND crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    /** Validar CPF/CNPJ do Cedente **/
    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT
        SET h-b1wgen9999.

    RUN valida-cpf-cnpj IN h-b1wgen9999
        (INPUT par_nrinsced,
        OUTPUT aux_flginsok,
        OUTPUT aux_tpinsced).

    IF  VALID-HANDLE(h-b1wgen9999) THEN
        DELETE PROCEDURE h-b1wgen9999.

    IF  NOT aux_flginsok THEN
        DO:
            ASSIGN i-cod-erro  = 0           
                   c-desc-erro = "CPF/CNPJ do beneficiario invalido.".
    
            RUN cria-erro (INPUT crapcop.nmrescop,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
    
            RETURN "NOK".

        END.

    IF  aux_tpinsced = 1 THEN
        aux_tppesced = "F".
    ELSE
        aux_tppesced = "J".
        
    /*par_dstransa = "Pagamento VR-Boleto".*/
    
    IF   NOT AVAILABLE crapcop   THEN
         DO: 
             ASSIGN i-cod-erro  = 0           
                    c-desc-erro = "Cooperativa nao cadastrada.".

             RUN cria-erro (INPUT crapcop.nmrescop,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).

             RETURN "NOK".
         END.

     /** Validar CPF/CNPJ do Sacado **/
     RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT
         SET h-b1wgen9999.

     RUN valida-cpf-cnpj IN h-b1wgen9999
         (INPUT par_nrinssac,
         OUTPUT aux_flginsok,
         OUTPUT aux_tpinssac).

     IF  VALID-HANDLE(h-b1wgen9999) THEN
         DELETE PROCEDURE h-b1wgen9999.

     IF  NOT aux_flginsok THEN
         DO:
             ASSIGN i-cod-erro  = 0           
                    c-desc-erro = "CPF/CNPJ do pagador invalido.".

             RUN cria-erro (INPUT crapcop.nmrescop,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).

             RETURN "NOK".

         END.

    IF  aux_tpinssac = 1 THEN
        aux_tppessac = "F".
    ELSE
        aux_tppessac = "J".

    ASSIGN aux_cdbccxlt = INT(SUBSTR(STRING(par_cdbarras),1,3)).

    FIND crapban WHERE crapban.cdbccxlt = aux_cdbccxlt NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapban  THEN  
         DO:
            ASSIGN i-cod-erro  = 0           
                   c-desc-erro = "Banco nao encontrado.".
    
            RUN cria-erro (INPUT crapcop.nmrescop,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).

             RETURN "NOK".
         END.

     IF  par_idorigem = 3 THEN
         ASSIGN par_cdagenci = 90
                par_nrdcaixa = 900
                par_cdoperad = "996"
                aux_sufixo   = "I". /* Internet */
     ELSE
         ASSIGN aux_sufixo   = "C".

     aux_nrctrlif = "1" + 
                    STRING(MONTH(crapdat.dtmvtocd),"99") +
                    STRING(DAY(crapdat.dtmvtocd),"99") +
                    STRING(crapcop.cdagectl,"9999") + 
                    STRING(ETIME,"9999999999") + 
                    aux_sufixo.

     { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
     RUN STORED-PROCEDURE pc_proc_envia_vr_boleto
       aux_handproc = PROC-HANDLE NO-ERROR
         (INPUT par_cdcooper,
          INPUT par_cdagenci, /* PA 90 - Internet */
          INPUT par_nrdcaixa, /* 900 - nrdcaixa */
          INPUT par_cdoperad, /* 996 operador internet */
          INPUT par_idorigem, /* origem = internet */
          INPUT aux_nrctrlif,
          INPUT par_cdbarras,
          INPUT aux_cdbccxlt, /* banco cedente */
          INPUT 0,            /* agencia cedente - nao obrigatorio */
          INPUT aux_tppesced,
          INPUT par_nrinsced,
          INPUT aux_tppessac,
          INPUT par_nrinssac,
          INPUT 0, /* vlr do titulo */
          INPUT 0, /* vlr do abatimento */
          INPUT 0, /* vlr dos juros */
          INPUT 0, /* vlr da multa */
          INPUT 0, /* outros acrescimos */
          INPUT par_vldpagto,
                                    OUTPUT 0,    /* Cod Erro */
                                    OUTPUT "").   /* Descriçao da crítica */
                    
                    CLOSE STORED-PROC pc_proc_envia_vr_boleto
                          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                    
                    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                    
                    ASSIGN 
                           aux_cdcritic = 0
                           aux_dscritic = ""
                           aux_cdcritic = pc_proc_envia_vr_boleto.pr_cdcritic
                                           WHEN pc_proc_envia_vr_boleto.pr_cdcritic <> ?
                           aux_dscritic = pc_proc_envia_vr_boleto.pr_dscritic
                                           WHEN pc_proc_envia_vr_boleto.pr_dscritic <> ?.

     IF  TRIM(aux_dscritic) <> "" THEN
         DO:
             ASSIGN i-cod-erro  = aux_cdcritic
                    c-desc-erro = aux_dscritic.
    
             RUN cria-erro (INPUT crapcop.nmrescop,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
    
             RETURN "NOK".
         END.

    /** Enviar email para operadores da cabine SPB **/
    RUN sistema/generico/procedures/b1wgen0011.p PERSISTENT
        SET h-b1wgen0011.

    ASSIGN aux_conteudo = 
            "Pagamento VR Boleto efetuado via " + 
            (IF par_idorigem = 3 THEN "INTERNET" ELSE "CAIXA") + 
            " na <strong>" +
            crapcop.nmrescop + "</strong><br>" +
            "<br><strong>CPF/CNPJ Beneficiario:</strong> " +
            TRIM(STRING(par_nrinsced)) +
            "<br><strong>CPF/CNPJ Pagador:</strong> " +
            TRIM(STRING(par_nrinssac)) +
            "<br><strong>Codigo de Barras:</strong> " +
            STRING(par_cdbarras,FILL("9",44)) + 
            "<br><strong>Linha Digitavel:</strong> " +
            aux_lindigit + 
            "<br><strong>Valor:</strong> " +
            TRIM(STRING(par_vldpagto,"zzz,zzz,zzz,zz9.99")).

    IF  VALID-HANDLE(h-b1wgen0011)  THEN
        DO:
            RUN enviar_email_completo IN h-b1wgen0011
              (INPUT par_cdcooper,
               INPUT "INTERNETBANK",
               INPUT "cpd@ailos.coop.br",
               INPUT "spb@ailos.coop.br,compe@ailos.coop.br",
               INPUT "PAGTO " +
                     crapcop.nmrescop + " " +
                     TRIM(STRING(par_nrinssac)) + " R$ " +
                     TRIM(STRING(par_vldpagto, "zzz,zzz,zzz,zz9.99")),
               INPUT "",
               INPUT "",
               INPUT aux_conteudo,
               INPUT TRUE).

            DELETE PROCEDURE h-b1wgen0011.
        END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE pega_valor_tarifas:

    DEF INPUT  PARAM par_cdcooper   AS  INTE                    NO-UNDO.
    DEF INPUT  PARAM par_nrdconta   AS  INTE                    NO-UNDO.
    DEF INPUT  PARAM par_nrcnvcob   LIKE    crapcob.nrcnvcob    NO-UNDO.
    DEF INPUT  PARAM par_inpessoa   AS  INTE                    NO-UNDO.

    DEF OUTPUT PARAM par_histarcx   AS  INTE                    NO-UNDO.
    DEF OUTPUT PARAM par_histarnt   AS  INTE                    NO-UNDO.
    DEF OUTPUT PARAM par_histrtaa   AS  INTE                    NO-UNDO.

    DEF OUTPUT PARAM par_cdhisest   AS  INTE                    NO-UNDO.
    DEF OUTPUT PARAM par_dtdivulg   AS  DATE                    NO-UNDO.
    DEF OUTPUT PARAM par_dtvigenc   AS  DATE                    NO-UNDO.
    DEF OUTPUT PARAM par_cdfvlccx   AS  INTE                    NO-UNDO.
    DEF OUTPUT PARAM par_vlrtarcx   AS  DECI                    NO-UNDO.
    DEF OUTPUT PARAM par_vlrtarnt   AS  DECI                    NO-UNDO.
    DEF OUTPUT PARAM par_vltrftaa   AS  DECI                    NO-UNDO.
    DEF OUTPUT PARAM par_cdfvlcnt   AS  INTE                    NO-UNDO.
    DEF OUTPUT PARAM par_cdfvltaa   AS  INTE                    NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.


    RUN sistema/generico/procedures/b1wgen0153.p
        PERSISTENT SET h-b1wgen0153.

    RUN carrega_dados_tarifa_cobranca IN
        h-b1wgen0153(INPUT  par_cdcooper,
                     INPUT  par_nrdconta,
                     INPUT  par_nrcnvcob,
                     INPUT  "RET",
                     INPUT  00,
                     INPUT  "03", /* Caixa da cooperativa */
                     INPUT  par_inpessoa,
                     INPUT  1,
                     INPUT  "", /* cdprogra */
					 INPUT  0, /* flaputar - Nao */
                     OUTPUT par_histarcx,
                     OUTPUT par_cdhisest,
                     OUTPUT par_vlrtarcx,
                     OUTPUT par_dtdivulg,
                     OUTPUT par_dtvigenc,
                     OUTPUT par_cdfvlccx,
                     OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen0153.

    IF  RETURN-VALUE <> "OK"   THEN
        RETURN "NOK".
        

    RUN sistema/generico/procedures/b1wgen0153.p
        PERSISTENT SET h-b1wgen0153.

    RUN carrega_dados_tarifa_cobranca IN
        h-b1wgen0153(INPUT  par_cdcooper,
                     INPUT  par_nrdconta,
                     INPUT  par_nrcnvcob,
                     INPUT  "RET",
                     INPUT  00,
                     INPUT  "33", /* Internet banking */
                     INPUT  par_inpessoa,
                     INPUT  1,
                     INPUT  "", /* cdprogra */
                     OUTPUT par_histarnt,
                     OUTPUT par_cdhisest,
                     OUTPUT par_vlrtarnt,
                     OUTPUT par_dtdivulg,
                     OUTPUT par_dtvigenc,
                     OUTPUT par_cdfvlcnt,
                     OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen0153.

    IF  RETURN-VALUE <> "OK"   THEN
        RETURN "NOK".

    RUN sistema/generico/procedures/b1wgen0153.p
        PERSISTENT SET h-b1wgen0153.

    RUN carrega_dados_tarifa_cobranca IN
        h-b1wgen0153(INPUT  par_cdcooper,
                     INPUT  par_nrdconta,
                     INPUT  par_nrcnvcob,
                     INPUT  "RET",
                     INPUT  00,
                     INPUT  "32", /* TAA */
                     INPUT  par_inpessoa,
                     INPUT  1,
                     INPUT  "", /* cdprogra */
                     OUTPUT par_histrtaa,
                     OUTPUT par_cdhisest,
                     OUTPUT par_vltrftaa,
                     OUTPUT par_dtdivulg,
                     OUTPUT par_dtvigenc,
                     OUTPUT par_cdfvltaa,
                     OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen0153.

    IF  RETURN-VALUE <> "OK"   THEN
        RETURN "NOK".

    RETURN "OK".
END PROCEDURE.

PROCEDURE efetua-lanc-craplat:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF  INPUT PARAM par_cdhistor AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_vllanaut AS DECI                              NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdbccxlt AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdolote AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_tpdolote AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdocmto AS DECI                              NO-UNDO.
    DEF  INPUT PARAM par_nrdctabb AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdctitg AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_cdpesqbb AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_cdbanchq AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagechq AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrctachq AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_flgaviso AS LOGI                              NO-UNDO.
    DEF  INPUT PARAM par_tpdaviso AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdfvlcop AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                              NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro. 

    RUN sistema/generico/procedures/b1wgen0153.p
    PERSISTENT SET h-b1wgen0153.
        
    RUN cria_lan_auto_tarifa 
        IN h-b1wgen0153(INPUT par_cdcooper,
                        INPUT par_nrdconta,
                        INPUT par_dtmvtolt,
                        INPUT par_cdhistor,
                        INPUT par_vllanaut,
                        INPUT par_cdoperad,
                        INPUT par_cdagenci,
                        INPUT par_cdbccxlt,
                        INPUT par_nrdolote,
                        INPUT par_tpdolote,
                        INPUT par_nrdocmto,
                        INPUT par_nrdctabb,
                        INPUT par_nrdctitg,
                        INPUT par_cdpesqbb,
                        INPUT par_cdbanchq,
                        INPUT par_cdagechq,
                        INPUT par_nrctachq,
                        INPUT par_flgaviso,
                        INPUT par_tpdaviso,
                        INPUT par_cdfvlcop,
                        INPUT par_inproces,
                        OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen0153.

    IF RETURN-VALUE = "NOK" THEN
       RETURN "NOK".

    RETURN "OK".
END.

PROCEDURE calcula_data_vencimento:

    DEF INPUT  PARAM p-dtmvtolt         LIKE crapdat.dtmvtolt           NO-UNDO.
    DEF INPUT  PARAM p-de-campo         AS INTE                         NO-UNDO.
    DEF OUTPUT PARAM p-dtvencto         AS DATE                         NO-UNDO.
    DEF OUTPUT PARAM p-cod-erro         AS INTE                         NO-UNDO.           
    DEF OUTPUT PARAM p-desc-erro        AS CHAR                         NO-UNDO.    

    DEF VAR aux_fatordia AS INTE                                        NO-UNDO.
    DEF VAR aux_fator    AS INTE                                        NO-UNDO.
    DEF VAR aux_dtvencto AS DATE                                        NO-UNDO.   

    DEF VAR aux_situacao AS INTE                                        NO-UNDO.
    DEF VAR aux_contador AS INTE                                        NO-UNDO.

    /* 0 - Fora Ranger 
       1 - A Vencer 
       2 - Vencida       */
    ASSIGN aux_situacao = 0. 


    /* Calcular Fator do Dia */
    ASSIGN aux_fatordia = p-dtmvtolt - DATE("07/10/1997").
    
    IF aux_fatordia > 9999 THEN DO:
    
        IF ( aux_fatordia MODULO 9000 ) < 1000 THEN
            aux_fatordia = ( aux_fatordia MODULO 9000 )  + 9000.
        ELSE
            aux_fatordia = ( aux_fatordia MODULO 9000 ).
    
    END.


    /* Verifica se esta A Vencer  */
    aux_fator = aux_fatordia.
    
    DO aux_contador=0 TO 5500:
    
        IF p-de-campo = aux_fator THEN DO:
            aux_situacao = 1. /* A Vencer */
            LEAVE.
        END.
    
        IF aux_fator > 9999 THEN
            aux_fator = 1000.
        ELSE
            aux_fator = aux_fator + 1.
    
    END.

    /* Verifica se esta Vencido */
    aux_fator = aux_fatordia - 1.
    
    IF aux_fator < 1000 THEN
         aux_fator = aux_fator + 9000.
    
    IF aux_situacao = 0 THEN DO:
    
        DO aux_contador=0 TO 3000:
    
            IF p-de-campo = aux_fator THEN DO:
                aux_situacao = 2. /* Vencido */
                LEAVE.
            END.
    
            IF aux_fator < 1000 THEN
                aux_fator = aux_fator + 9000.
            ELSE
                aux_fator = aux_fator - 1.
    
        END.
    
    END.
    
    IF aux_situacao = 0  THEN DO:

        ASSIGN p-cod-erro  = 0           
               p-desc-erro = "Boleto fora do ranger permitido!".

        RETURN "NOK".
    END.
    ELSE
        IF aux_situacao = 1 THEN DO:  /* A Vencer */
            IF aux_fatordia > p-de-campo THEN
                ASSIGN aux_dtvencto = p-dtmvtolt + ( p-de-campo - 1000 + (9999 - aux_fatordia + 1 ) ).
            ELSE
                ASSIGN aux_dtvencto = p-dtmvtolt + ( p-de-campo - aux_fatordia).
            END.
        ELSE DO:   /* Vencido */
             IF aux_fatordia > p-de-campo THEN
                ASSIGN aux_dtvencto = p-dtmvtolt + ( p-de-campo - aux_fatordia).
             ELSE
                ASSIGN aux_dtvencto = p-dtmvtolt + ( p-de-campo - aux_fatordia - 9000 ).
        END.

    ASSIGN p-dtvencto = aux_dtvencto.

    RETURN "OK".
END.

/* b2crap14.p */
 
/* ......................................................................... */





