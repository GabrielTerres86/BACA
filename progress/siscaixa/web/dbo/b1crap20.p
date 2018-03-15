/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +-----------------------------------+---------------------------------------+
  | Rotina Progress                   | Rotina Oracle PLSQL                   |
  +-----------------------------------+---------------------------------------+
  | dbo/b1crap20.p                    | CXON0020                              |
  |  busca-tarifa-ted                 | CXON0020.pc_busca_tarifa_ted          |
  |  enviar-ted                       | CXON0020.pc_enviar_ted                | 
  |  validar-ted                      | CXON0020.pc_validar_ted               |
  +-----------------------------------+---------------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/







/*-----------------------------------------------------------------------------

    b1crap20.p - DOC/TED - Inclusao
    
    Ultima Atualizacao: 12/12/2017
    
    Alteracoes:
                23/02/2006 - Unificacao dos bancos - SQLWorks - Eder
                              
                17/04/2007 - Critica quando nao encontra cidade para
                             determinada agencia bancaria (Elton).
                             
                23/04/2007 - Alterado para nao deixar fixo as informacoes do
                             Banco e Agencia do remetente (Elton).
                
                10/05/2007 - Criticar situacao da agencia destino  (Mirtes)
                
                29/01/2008 - Mostra o PAC do cooperado na autenticacao (Elton).
                
                19/02/2008 - Retirada critica que nao permite utilizacao de
                             TED's (Elton/Evandro).
                             
                17/04/2008 - Tratamento horario TED (Diego)
                             Validacao de operador para TED (Evandro).

                22/12/2008 - Ajustes para unificacao dos bancos de dados
                             (Evandro).
                             
                25/03/2009 - Retirado comentario dos campos craptvl.cdoperad e
                             craptvl.cdopeaut;
                           - Incluida critica no campo CPF/CNPJ do destinatario
                             do TED (Elton).                
                             
                25/05/2009 - Alteracao CDOPERAD (Kbase).

                26/08/2009 - Substituicao do campo banco/agencia da COMPE, 
                             para o banco/agencia COMPE de DOC (cdagedoc e
                             cdbandoc) - (Sidnei - Precise).
                             
                23/10/2009 - Alterada a procedure atualiza-doc-ted para enviar 
                             TED´s por mensageria - SPB (Fernando).  
                             
                04/05/2010 - Criar lote 11000 + caixa sempre que uma transaçao
                             for efetuada (Fernando).        
                             
                31/05/2010 - Criada procedure valida-saldo para alertar quando
                             o saldo + limite de credito do remetente for menor
                             que o valor a ser enviado no DOC/TED (Fernando).   
                             
                24/06/2010 - Criticar o envio de TEDs entre cooperativas do
                             Sistema CECRED (Fernando).        
                             
                26/06/2010 - Ajustar chamada da b1wgen0046 para os TEDs via 
                             SPB.
                             Criticar envio de TED C debito em conta com mesma
                             titularidade. Solicitar envio do TED D (Fernando).      
                             
                11/08/2010 - Retirar criticas da procedure atualiza-doc-ted
                             e colocar na procedure valida-valores (Fernando).         
                             
                24/09/2010 - Incluido parametro p-cod-id-transf (Guilherme).
                
                29/03/2011 - Incluido validacao de valores na verifica-operador
                             (Guilherme).
                             
                17/05/2011 - Ajuste no comprovante de TED/DOC (Gabriel). 
                
                25/08/2011 - Inclusao do parametro 'cod.rotina' na procedure 
                             valida-saldo-conta (Diego).
                             
                14/12/2011 - Incluido os parametro p-cod-rotina e p-coopdest na
                             procedure valida-saldo e na chamada da procedure
                             valida-saldo-conta (Elton).
                             
                12/04/2012 - Inclusao do parametro "origem", na chamada da
                             procedure proc_envia_tec_ted. (Fabricio)
                             
                11/05/2012 - Projeto TED Internet (David).
                             
                22/11/2012 - Ajuste para utilizar campo crapdat.dtmvtocd no
                             lugar do crapdat.dtmvtolt. (Jorge)
                             
                04/12/2012 - Incluir origem da mensagem no numero de controle
                            (Diego). 
                            
                15/03/2013 - Novo tratamento para Bancos que nao possuem
                             agencia (David Kruger).
                             
                16/05/2013 - Incluso nova estrutura para buscar valor tarifa
                             utilizando b1wgen0153 (Daniel). 
                             
                20/05/2013 - Novo param. procedure 'grava-autenticacao-internet'
                            (Lucas). 
                            
                04/06/2013 - Incluso bloco de repeticao nas procedures enviar-ted
                             e atualiza-doc-tec ao efetuar lancamento na craplcm
                             (Daniel).
                             
                23/07/2013 - Alterado lancamento tarifa nas procedures enviar-ted
                             e atualiza-doc-ted para utilizar procedure 
                             lan-tarifa-online da b1wgen0153.p (Daniel). 
                
                27/08/2013 - Alteracao dos parametros na lan-tarifa-online
                             (Tiago).             
                             
                19/09/2013 - Alterado envio do parametro p-nro-conta-de para
                             p-nro-conta-rm na chamada da procedure 
                             busca-tarifa-ted(Tiago).
                             
                10/10/2013 - Incluido parametro cdprogra nas procedures da 
                             b1wgen0153 que carregam dados de tarifas (Tiago).
                             
                08/11/2013 - Nova forma de chamar as agencias, de PAC agora 
                             a escrita será PA (Guilherme Gielow)
                             
                14/11/2013 - Alterado totalizador de PAs de 99 para 999.
                             (Reinert)                             
             
                03/12/2013 - Inserido campo nrdctabb no lugar do nrdconta
                             nas consultas da craplcm (Tiago).
                             
                06/12/2013 - Ajustado processo de lock da tabela crapmat (Daniel).
                
                27/12/2013 - Adicionado validate para as tabelas craplot,
                             craplcm (Tiago).
                             
                24/03/2014 - Ajuste na procedure "enviar-ted" para buscar a 
                             proxima sequencia crapmat.nrseqted apartir da 
                             sequence banco Oracle. (James)
                             
                23/05/2014 - Adicionado parametros dtagendt, nrseqarq, cdconven
                             'a chamada da procedure proc_envia_tec_ted.
                             (PRJ Automatizacao TED pagto convenio repasse) -
                             (Fabricio)
                             
                12/08/2014 - Inclusao da Obrigatoriedade do campo Histórico para TED/DOC  
                            com Finalidade "99-Outros" (Vanessa).
                            
                24/10/2014 - Enviar a hora do lancamento (Jonata-RKAM).    
                
                03/12/2014 - (Chamado 204932) - Foi incluido um tratamento para travar 
                             TEDs duplicados com intervalo de 10ss, conforme ocorrido
                             em setembro 2014, um TED duplicado com intervalo de 1ss
                             Diego Vicentini solicitou essa trava (Tiago Castro - RKAM).
                             
                09/12/2014 - Retirada da Validação da Agencia no cadatro de Contas 
                             para TEDs nas procedures valida-valores e validar-ted
                             SD231030 (Vanessa)
                             
                22/12/2014 - (Chamado 229263) - Incluido na procedure valida-valores
                             a find para a tabela crapagb a fim de validar a agencia 
                             bancaria informada na operação - Jean (RKAM)
                             
                20/01/2015 - Inclusão da Validação do campo historico na  procedures 
                             validar-ted e enviar-ted SD 244456 (Vanessa)
                             
                21/01/2015 - Conversão da fn_sequence para procedure para não
                             gerar cursores abertos no Oracle. (Dionathan)
                             
                20/04/2015 - Inclusão do campo ISPB SD271603 FDR041 (Vanessa) 
                
                27/04/2015 - Inclusao da procedure verifica-operador-ted
                             (Valor limite ted por operador) - Tiago/Elton
                             
                22/05/2015 - Chamado 267552 - Evitar duplicidade de TED
                             (Gabriel-RKAM).    
                             
                06/08/2015 - Incluir regra para evitar que sejam efetivadas
                             2 TEDs iguais enviadas pelo ambiente mobile.
                             Chamado 314085 (David).
              
                21/10/2015 - Incluir Chamada da procedure gera_arquivo_log_ted ao
                             enviar teds e tambem efetuar tratamento de return-value
                             (Lucas ranghetti/Elton #343312)
                             
                30/10/2015 - Adicionar verificacao da crapaut na procedure enviar-ted
                             (Lucas Ranghetti #343312)
                             
                09/11/2015 - Incluir log na validacao da crapaut ao enviar teds
                            (Lucas Ranghetti #355418)
                            
                18/11/2015 - Alterado procedure gera_arquivo_log_ted para buscar 
                             a data da variavel aux_dtmvtocd e incluir novos logs
                             na procedure enviar-ted (Lucas Ranghetti/Elton)
                             
                19/11/2015 - Estado de crise (Gabriel-RKAM).              
                             
                20/11/2015 - Incluir VALIDATE craplcm na procedure enviar-ted 
                             (Lucas Ranghetti/Elton)
                             
                02/03/2016 - Tratamentos para utilizaçao do Cartao CECRED e 
                             PinPad Novo (Lucas Lunelli - [PROJ290])
                            
                             
                01/03/2016 - Alterado rotina enviar-ted para inclusão de log  
                            para monitoramento de lote em uso e 
                            removido tratamento de TED duplicada com leitura na 
                            craptvl sem nrdconta e ajustado a mensagem.
                            (Odirlei-AMcom)

				07/03/2016 - Incluir validacao para agencia zerada (Lucas Ranghetti #411852)

  			    26/04/2016 - Inclusao dos horarios de SAC e OUVIDORIA nos
			                 comprovantes, melhoria 112 (Tiago/Elton).				
							 
				27/04/2016 - Adicionado tratamento para verificar isencao ou nao
                             de tarifa no envio de DOC/TED. PRJ 218/2 (Reinert).			 
							 
			    25/08/2016 - Ajustado para gerar o log de cartão no envio da TED antes de 
				             chamar a rotina que envia as informações para a Cabine,
							 para garantir que envie as informacoes para a cabine e posteriormente
							 aborte o programa. (Odirlei - AMcom)				 		 
						
				        17/02/2017 - Incluir validacao de senha na procedure valida_senha_cartao (Lucas Ranghetti #597410)						
									 		 
               17/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
                             crapass, crapttl, crapjur (Adriano - P339). 

                02/06/2017 - Ajustes referentes ao Novo Catalogo do SPB(Lucas Ranghetti #668207)
									 		 
			    23/08/2017 - Alterado para validar as informacoes do operador 
							 pelo AD. (PRJ339 - Reinert)
							
                12/12/2017 - Passar como texto o campo nrcartao na chamada da procedure 
                             pc_gera_log_ope_cartao (Lucas Ranghetti #810576)
-----------------------------------------------------------------------------*/
                             
{dbo/bo-erro1.i}
{ sistema/generico/includes/b1wgen0015tt.i }
{ sistema/generico/includes/var_internet.i }

DEF VAR i-cod-erro           AS INT                                 NO-UNDO.
DEF VAR c-desc-erro          AS CHAR                                NO-UNDO.

DEF VAR p-retorno            AS LOG                                 NO-UNDO.
DEF VAR p-pessoa             AS INTE                                NO-UNDO.
DEF VAR i-nro-lote-lcm       AS INTE                                NO-UNDO.
DEF VAR i-nro-lote           AS INTE                                NO-UNDO.
DEF VAR i-tipo-lote          AS INTE                                NO-UNDO.
DEF VAR i-tipo-lote-lcm      AS INTE                                NO-UNDO.
DEF VAR i-cdhistor           AS INTE                                NO-UNDO.
DEF VAR c-literal            AS CHAR    FORMAT "x(48)" EXTENT 100.
DEF VAR i_conta            AS DEC                               NO-UNDO.

DEF VAR h_b1crap00           AS HANDLE                              NO-UNDO.
DEF VAR h-b1wgen0012         AS HANDLE                              NO-UNDO.
DEF VAR h-b1wgen0046         AS HANDLE                              NO-UNDO.
DEF VAR h-b1crap56           AS HANDLE                              NO-UNDO.
DEF VAR h_bo_ted             AS HANDLE                              NO-UNDO.
DEF VAR h_b2crap00           AS HANDLE                              NO-UNDO.
DEF VAR h-b1crap02           AS HANDLE                              NO-UNDO.

DEF VAR p-literal            AS CHAR                                NO-UNDO.
DEF VAR p-literal-lcm        AS CHAR                                NO-UNDO.
DEF VAR p-ult-sequencia      AS INTE                                NO-UNDO.
DEF VAR p-ult-sequencia-lcm  AS INTE                                NO-UNDO.
DEF VAR p-registro           AS RECID                               NO-UNDO.
DEF VAR p-registro-lcm       AS RECID                               NO-UNDO.
DEF VAR i-nro-docto          AS INTE                                NO-UNDO.

DEF VAR c-tipo-docto         AS CHAR    FORMAT "x(38)"              NO-UNDO.
DEF VAR c-desc-agencia       AS CHAR    FORMAT "x(38)"              NO-UNDO.
DEF VAR c-desc-banco         AS CHAR    FORMAT "x(38)"              NO-UNDO.
DEF VAR c-desc-banco2        AS CHAR    FORMAT "x(38)"              NO-UNDO.
DEF VAR c-desc-finalidade    AS CHAR    FORMAT "x(38)"              NO-UNDO.
DEF VAR c-desc-conta-db      AS CHAR    FORMAT "x(38)"              NO-UNDO.
DEF VAR c-desc-conta-cr      AS CHAR    FORMAT "x(38)"              NO-UNDO.
DEF VAR c-nome-titular1      AS CHAR    FORMAT "x(40)"              NO-UNDO.
DEF VAR c-nome-titular2      AS CHAR    FORMAT "x(40)"              NO-UNDO.
DEF VAR c-nome-titular2-para AS CHAR    FORMAT "x(40)"              NO-UNDO.
DEF VAR c-tipo-pessoa-de     AS CHAR    FORMAT "x(08)"              NO-UNDO.
DEF VAR c-tipo-pessoa-para   AS CHAR    FORMAT "x(08)"              NO-UNDO.
DEF VAR c-texto-2-via        AS CHAR                                NO-UNDO.
DEF VAR in99                 AS INTE                                NO-UNDO.

DEF VAR c-cgc-de-1           AS CHAR    FORMAT "x(19)"              NO-UNDO.
DEF VAR c-cgc-de-2           AS CHAR    FORMAT "x(19)"              NO-UNDO.
DEF VAR c-cgc-para-1         AS CHAR    FORMAT "x(19)"              NO-UNDO.
DEF VAR c-cgc-para-2         AS CHAR    FORMAT "x(19)"              NO-UNDO.

DEF VAR aux_dsagenci         AS CHAR    FORMAT "x(20)"              NO-UNDO.
DEF VAR aux_nrdctitg         LIKE crapass.nrdctitg                  NO-UNDO.
DEF VAR aux_cdagenci         AS CHAR    FORMAT "x(03)"              NO-UNDO.

DEF VAR in01                 AS INTE                                NO-UNDO.

/* Para geracao do arquivo TED on-line */
DEF TEMP-TABLE crattem                                              NO-UNDO
    FIELD cdseqarq AS INTEGER
    FIELD nrdolote AS INTEGER
    FIELD cddbanco AS INTEGER
    FIELD nmarquiv AS CHAR
    FIELD nrrectit AS RECID
    FIELD nrdconta LIKE crapccs.nrdconta
    FIELD cdagenci LIKE crapccs.cdagenci
    FIELD cdbantrf LIKE crapccs.cdbantrf
    FIELD cdagetrf LIKE crapccs.cdagetrf
    FIELD nrctatrf LIKE crapccs.nrctatrf
    FIELD nrdigtrf LIKE crapccs.nrdigtrf
    FIELD nmfuncio LIKE crapccs.nmfuncio
    FIELD nrcpfcgc LIKE crapccs.nrcpfcgc
    FIELD nrdocmto LIKE craplcs.nrdocmto
    FIELD vllanmto LIKE craplcs.vllanmto
    FIELD dtmvtolt LIKE craplcs.dtmvtolt
    FIELD tppessoa AS INT FORMAT "9"
    INDEX crattem1 cdseqarq nrdolote.

PROCEDURE  verifica-docto-ted:
    DEF INPUT PARAM p-cooper        AS CHAR     NO-UNDO.
    DEF INPUT PARAM p-cod-agencia   AS INTEGER  NO-UNDO.  /* Cod. Agencia  */
    DEF INPUT PARAM p-nro-caixa     AS INTEGER  NO-UNDO.  /* Numero Caixa  */
        
    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    RETURN "OK".
    
END PROCEDURE.
              
PROCEDURE retorna-conta-de:
    DEFINE INPUT  PARAMETER p-cooper        AS CHAR         NO-UNDO.    
    DEFINE INPUT  PARAMETER p-cod-agencia   AS INTEGER      NO-UNDO.
    DEFINE INPUT  PARAMETER p-nro-caixa     AS INTEGER      NO-UNDO.
    DEFINE INPUT  PARAMETER p-nro-conta-de  AS INTEGER      NO-UNDO.
    DEFINE OUTPUT PARAMETER p-nome-de1      AS CHARACTER    NO-UNDO.
    DEFINE OUTPUT PARAMETER p-cpfcnpj-de1   AS CHARACTER    NO-UNDO.
    DEFINE OUTPUT PARAMETER p-nome-de2      AS CHARACTER    NO-UNDO.
    DEFINE OUTPUT PARAMETER p-cpfcnpj-de2   AS CHARACTER    NO-UNDO.
    DEFINE OUTPUT PARAMETER p-pessoa-de     AS CHARACTER    NO-UNDO.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.
 
    ASSIGN p-nro-conta-de  = INT(REPLACE(STRING(p-nro-conta-de),'.','')).

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia, 
                      INPUT p-nro-caixa).

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.

    IF  p-nro-conta-de <> 0 THEN 
        DO:

            FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper  AND
                               crapass.nrdconta = p-nro-conta-de 
                               NO-LOCK NO-ERROR.
                               
            IF  NOT AVAIL crapass THEN 
                DO:
                    ASSIGN i-cod-erro  = 9
                           c-desc-erro = " ".
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN 'NOK'.
                END.
            ELSE
                DO:
                    ASSIGN p-nome-de1    = crapass.nmprimtl
                           p-pessoa-de   = IF crapass.inpessoa = 1 THEN 
                                              'V1' 
                                           ELSE 'V2'.

                    IF   crapass.inpessoa = 1   THEN
					   DO:
					       ASSIGN p-cpfcnpj-de1 = STRING(crapass.nrcpfcgc,"99999999999")
                                  p-cpfcnpj-de1 = STRING(p-cpfcnpj-de1, "xxx.xxx.xxx-xx").

					       FOR FIRST crapttl FIELDS(crapttl.nmextttl crapttl.nrcpfcgc)
						                      WHERE crapttl.cdcooper = crapass.cdcooper AND
											        crapttl.nrdconta = crapass.nrdconta AND
											        crapttl.idseqttl = 2
											        NO-LOCK:
						   
						      ASSIGN p-cpfcnpj-de2 = STRING(crapttl.nrcpfcgc,"99999999999")
				                     p-cpfcnpj-de2 = STRING(p-cpfcnpj-de2,"xxx.xxx.xxx-xx")
									 p-nome-de2    = crapttl.nmextttl.

						   END.

					   END.
                    ELSE
                       ASSIGN p-cpfcnpj-de1 = STRING(crapass.nrcpfcgc,"99999999999999")
                              p-cpfcnpj-de1 = STRING(p-cpfcnpj-de1,"xx.xxx.xxx/xxxx-xx").  


                END.

        END.

    RETURN.
    
END PROCEDURE.

PROCEDURE valida-valores:

    /* Procedure validar-ted foi criada nessa BO para InternetBank 
       baseada nessa procedure */

    DEFINE INPUT PARAMETER p-cooper        AS CHAR     NO-UNDO.    
    DEFINE INPUT PARAMETER p-cod-agencia AS INT   NO-UNDO. /* Cod. Agencia   */
    DEFINE INPUT PARAMETER p-nro-caixa   AS INT   NO-UNDO. /* Numero Caixa   */
    DEFINE INPUT PARAMETER p-tipo-doc    AS CHAR  NO-UNDO. /*Doc: C,D TED: C,D*/
    DEFINE INPUT PARAMETER p-tipo-pag    AS CHAR  NO-UNDO. /*Especie ou C/C */
    DEFINE INPUT PARAMETER p-val-doc     AS DEC   NO-UNDO. /* Valor DOC      */
    DEFINE INPUT PARAMETER p-cod-banco   AS INT   NO-UNDO.  /* Cod. Banco    */
    DEFINE INPUT PARAMETER p-cod-agencia-banco AS INT NO-UNDO. /* Cod.Agencia*/
    DEFINE INPUT PARAMETER p-nro-conta-de     AS INT  NO-UNDO. /* Conta De   */
    DEFINE INPUT PARAMETER p-nome-de          AS CHAR NO-UNDO. /* Nome De    */
    DEFINE INPUT PARAMETER p-nome-de1         AS CHAR NO-UNDO. 
    DEFINE INPUT PARAMETER p-cpfcnpj-de       AS CHAR NO-UNDO. /*CPF/CNPJ De */
    DEFINE INPUT PARAMETER p-cpfcnpj-de1      AS CHAR NO-UNDO.
    DEFINE INPUT PARAMETER p-tipo-pessoa-de   AS INT  NO-UNDO.
    DEFINE INPUT PARAMETER p-titular          AS LOG  NO-UNDO. /*Titularidade*/
    DEFINE INPUT PARAMETER p-nro-conta-para   AS DEC  NO-UNDO. /* Conta Para */
    DEFINE INPUT PARAMETER p-nome-para        AS CHAR NO-UNDO. /* Nome Para  */
    DEFINE INPUT PARAMETER p-nome-para1       AS CHAR NO-UNDO.
    DEFINE INPUT PARAMETER p-cpfcnpj-para     AS CHAR NO-UNDO. /*CPF/CNPJ Para*/
    DEFINE INPUT PARAMETER p-cpfcnpj-para1    AS CHAR NO-UNDO.
    DEFINE INPUT PARAMETER p-tipo-pessoa-para AS INT  NO-UNDO.
    DEFINE INPUT PARAMETER p-tipo-conta-db    AS INT  NO-UNDO. /*Cta Debitada */
    DEFINE INPUT PARAMETER p-tipo-conta-cr    AS INT  NO-UNDO. /*Cta Creditada */
    DEFINE INPUT PARAMETER p-cod-finalidade   AS INT  NO-UNDO. /*Cod.Finalidade*/
    DEFINE INPUT PARAMETER p-dsc-historico    AS CHAR NO-UNDO. /*Descriçao do Histórico*/
    DEFINE INPUT PARAMETER p-ispb-if          AS CHAR   NO-UNDO.  /* ISPB Banco    */


    DEF VAR aux_flestcri AS INTE                    NO-UNDO.


    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.

    ASSIGN p-nro-conta-de   = DEC(REPLACE(STRING(p-nro-conta-de),".",""))
           p-nro-conta-para = DEC(REPLACE(STRING(p-nro-conta-para),".","")). 
     
    ASSIGN  p-cpfcnpj-de    = REPLACE(p-cpfcnpj-de,"/","")
            p-cpfcnpj-de    = REPLACE(p-cpfcnpj-de,".","")
            p-cpfcnpj-de    = REPLACE(p-cpfcnpj-de,"-","")
                            
            p-cpfcnpj-de1   = REPLACE(p-cpfcnpj-de1,"/","") 
            p-cpfcnpj-de1   = REPLACE(p-cpfcnpj-de1,".","") 
            p-cpfcnpj-de1   = REPLACE(p-cpfcnpj-de1,"-","") 
                            
            p-cpfcnpj-para  = REPLACE(p-cpfcnpj-para,"/","")
            p-cpfcnpj-para  = REPLACE(p-cpfcnpj-para,".","")
            p-cpfcnpj-para  = REPLACE(p-cpfcnpj-para,"-","")
        
            p-cpfcnpj-para1 = REPLACE(p-cpfcnpj-para1,"/","")
            p-cpfcnpj-para1 = REPLACE(p-cpfcnpj-para1,".","")
            p-cpfcnpj-para1 = REPLACE(p-cpfcnpj-para1,"-","").

    IF  p-cpfcnpj-de = "0" THEN
        ASSIGN  p-cpfcnpj-de = REPLACE(p-cpfcnpj-de,"0","").
   
    IF  p-cpfcnpj-para = "0" THEN
        ASSIGN  p-cpfcnpj-para = REPLACE(p-cpfcnpj-para,"0","").
         
    IF  p-cpfcnpj-de1 = "0" THEN
        ASSIGN  p-cpfcnpj-de1 = REPLACE(p-cpfcnpj-de1,"0","").
   
    IF  p-cpfcnpj-para1 = "0" THEN
        ASSIGN  p-cpfcnpj-para1 = REPLACE(p-cpfcnpj-para1,"0","").

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    
    
    IF (p-tipo-doc = 'TEDC' OR p-tipo-doc = 'TEDD')  THEN
       DO:
          { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 

          /* Efetuar a chamada a rotina Oracle */
          RUN STORED-PROCEDURE pc_estado_crise
          aux_handproc = PROC-HANDLE NO-ERROR (INPUT "N"   /* Identificador para verificar processo (N – Nao / S – Sim) */
                                              ,OUTPUT 0    /* Identificador estado de crise (0 - Nao / 1 - Sim) */
                                              ,OUTPUT ?).  /* XML com informacoes das cooperativas */
          
          /* Fechar o procedimento para buscarmos o resultado */ 
          CLOSE STORED-PROC pc_estado_crise
                aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
          
          { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
          
          ASSIGN aux_flestcri = 0
                 aux_flestcri = pc_estado_crise.pr_inestcri
                                WHEN pc_estado_crise.pr_inestcri <> ?.

         /* Se estiver em estado de crise */
         IF  aux_flestcri > 0  THEN
             DO:
                 ASSIGN i-cod-erro  = 0
                        c-desc-erro = "Sistema em estado de crise.". 
         
                 RUN cria-erro (INPUT p-cooper,
                                INPUT p-cod-agencia,
                                INPUT p-nro-caixa,
                                INPUT i-cod-erro,
                                INPUT c-desc-erro,
                                INPUT YES).
                 RETURN "NOK".
             END.
       END.

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.

    IF  p-val-doc = 0 THEN 
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Valor do DOC/TED deve ser Informado". 
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN 'NOK'.
        END. 

     IF p-ispb-if = ' '  AND  p-cod-banco = 0 THEN 
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "O Banco deve ser informado". 
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN 'NOK'.
        END. 

    FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
                       craptab.nmsistem = "CRED"            AND  
                       craptab.tptabela = "GENERI"          AND  
                       craptab.cdempres = 0                 AND 
                       craptab.cdacesso = "VLMAXPDOCS"      AND
                       craptab.tpregist = 0                 NO-LOCK NO-ERROR.

    IF  NOT AVAIL craptab THEN 
        DO:
            ASSIGN i-cod-erro  = 0  
                   c-desc-erro = "Tabela valor maximo DOC nao cadastrada".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN 'NOK'.
        END. 
    
    IF  AVAILABLE craptab THEN   
        DO:
            IF  p-val-doc <= DECIMAL(craptab.dstextab) AND
               (p-tipo-doc = 'TEDC' OR p-tipo-doc = 'TEDD')   THEN 
                DO:
                    ASSIGN i-cod-erro  = 269 /* Valor Incorreto */
                           c-desc-erro = " ".
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN 'NOK'.
                END.
   
            IF  p-val-doc   > DEC(craptab.dstextab)     AND
               (p-tipo-doc <> 'TEDD' AND p-tipo-doc <> 'TEDC')   THEN 
                DO:
                    ASSIGN i-cod-erro  = 269  /* Valor Incorreto */
                           c-desc-erro = " ".
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN 'NOK'.
                END.
        END. 

    IF   p-cod-banco = crapcop.cdbcoctl AND
         (p-tipo-doc = 'TEDC' OR p-tipo-doc = 'TEDD') AND 
         (crapcop.flgopstr OR crapcop.flgoppag)  THEN
         DO:
            ASSIGN i-cod-erro  = 0.
                   c-desc-erro = "Nao é posssivel efetuar transferencia entre "
                                 + "IFs do Sistema CECRED".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN 'NOK'.
         END.

    
    IF p-cod-banco > 0 THEN
       FIND crapban WHERE crapban.cdbccxlt = p-cod-banco  NO-LOCK NO-ERROR.
    ELSE
       FIND crapban WHERE crapban.nrispbif = int(p-ispb-if)  NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE crapban THEN 
        DO:
            ASSIGN i-cod-erro  = 57
                   c-desc-erro = "". 
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

     IF   p-tipo-doc <> 'TEDC'   AND
          p-tipo-doc <> 'TEDD'   THEN
          DO:        
              FIND crapagb WHERE 
                   crapagb.cddbanco = p-cod-banco         AND 
                   crapagb.cdageban = p-cod-agencia-banco NO-LOCK NO-ERROR.
              
              IF  NOT AVAILABLE crapagb THEN  
                  DO:
                     ASSIGN i-cod-erro  = 0
                            c-desc-erro = "Agencia invalida.". 
              
                          RUN cria-erro (INPUT p-cooper,
                                         INPUT p-cod-agencia,
                                         INPUT p-nro-caixa,
                                         INPUT i-cod-erro,
                                         INPUT c-desc-erro,
                                         INPUT YES).
              
                          RETURN "NOK".
                    
                  END.
          END.

    IF  p-tipo-doc = 'C' OR p-tipo-doc = 'D' THEN
        FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
                           craptab.nmsistem = "CRED"            AND
                           craptab.tptabela = "GENERI"          AND
                           craptab.cdempres = 00                AND
                           craptab.cdacesso = "FINTRFDOCS"      AND
                           craptab.tpregist = p-cod-finalidade  
                           NO-LOCK NO-ERROR.
    ELSE
        FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
                           craptab.nmsistem = "CRED"            AND
                           craptab.tptabela = "GENERI"          AND
                           craptab.cdempres = 00                AND
                           craptab.cdacesso = "FINTRFTEDS"      AND
                           craptab.tpregist = p-cod-finalidade  
                           NO-LOCK NO-ERROR.

    IF  NOT AVAIL craptab THEN 
        DO:
            ASSIGN i-cod-erro  = 362
                   c-desc-erro = "". 
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

    IF  p-tipo-doc = 'D' OR p-tipo-doc = 'TEDD'  THEN 
        DO:
            IF  p-tipo-doc = 'D' THEN /* Critica Conta Debitada */
                FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
                                   craptab.nmsistem = "CRED"            AND
                                   craptab.tptabela = "GENERI"          AND
                                   craptab.cdempres = 00                AND
                                   craptab.cdacesso = "TPCTADBTRF"      AND
                                   craptab.tpregist = p-tipo-conta-db   
                                   NO-LOCK NO-ERROR.
            ELSE
                FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
                                   craptab.nmsistem = "CRED"            AND
                                   craptab.tptabela = "GENERI"          AND
                                   craptab.cdempres = 00                AND
                                   craptab.cdacesso = "TPCTADBTED"      AND
                                   craptab.tpregist = p-tipo-conta-db   
                                   NO-LOCK NO-ERROR.
                 
            IF  NOT AVAIL craptab THEN
                DO:
                    ASSIGN i-cod-erro  = 017
                           c-desc-erro = "". 
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.
        END.

    IF  p-tipo-doc = 'D' OR p-tipo-doc = 'TEDD'  THEN 
        DO:

            IF p-tipo-doc = 'D' THEN /* Critica Conta Creditada */
                FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
                                   craptab.nmsistem = "CRED"            AND
                                   craptab.tptabela = "GENERI"          AND
                                   craptab.cdempres = 00                AND
                                   craptab.cdacesso = "TPCTACRTRF"      AND
                                   craptab.tpregist = p-tipo-conta-cr  
                                   NO-LOCK NO-ERROR.
            ELSE
                FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
                                   craptab.nmsistem = "CRED"            AND
                                   craptab.tptabela = "GENERI"          AND
                                   craptab.cdempres = 00                AND
                                   craptab.cdacesso = "TPCTACRTED"      AND
                                   craptab.tpregist = p-tipo-conta-cr   
                                   NO-LOCK NO-ERROR.
                  
            IF  NOT AVAIL craptab  THEN 
                DO:
                    ASSIGN i-cod-erro  = 017
                           c-desc-erro = "". 
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.
        END. 

    IF  p-nro-conta-de = 0 AND (p-nome-de = "" OR p-cpfcnpj-de   = "") THEN 
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = 
                        "Deve ser informada a conta ou os dados do emitente". 
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END. 

    IF  p-nro-conta-de <> 0 THEN 
        DO:
     
            FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper  AND
                               crapass.nrdconta = p-nro-conta-de 
                               NO-LOCK NO-ERROR.
                 
            IF  NOT AVAIL crapass THEN 
                DO:
                    ASSIGN i-cod-erro  = 9
                           c-desc-erro = "". 
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                END.

        END.
    ELSE 
        DO:
            IF   p-tipo-pag = 'D'   THEN
                 DO:
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = "Necessario informar a Conta De para" +
                                         " forma de pagto Debito em C/C.". 
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                 END.

            in01  = 1.
            ASSIGN c-desc-erro = " "
                   i-cod-erro  = 0.
            DO  WHILE in01 LE LENGTH(p-cpfcnpj-de):
                IF  SUBSTR(p-cpfcnpj-de,in01,1) <> "0"  AND
                    SUBSTR(p-cpfcnpj-de,in01,1) <> "1"  AND
                    SUBSTR(p-cpfcnpj-de,in01,1) <> "2"  AND
                    SUBSTR(p-cpfcnpj-de,in01,1) <> "3"  AND
                    SUBSTR(p-cpfcnpj-de,in01,1) <> "4"  AND
                    SUBSTR(p-cpfcnpj-de,in01,1) <> "5"  AND
                    SUBSTR(p-cpfcnpj-de,in01,1) <> "6"  AND
                    SUBSTR(p-cpfcnpj-de,in01,1) <> "7"  AND
                    SUBSTR(p-cpfcnpj-de,in01,1) <> "8"  AND
                    SUBSTR(p-cpfcnpj-de,in01,1) <> "9"  THEN 
                    DO:
                        ASSIGN  i-cod-erro = 27.
                        LEAVE.
                    END.    
                in01 = in01 + 1.
            END. /* fim do DO  WHILE in01 */
            
            IF  i-cod-erro > 0 THEN 
                DO:
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa, 
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.   

            RUN dbo/pcrap06.p (INPUT  p-cpfcnpj-de,
                               OUTPUT p-retorno,
                               OUTPUT p-pessoa).
         
            IF  NOT p-retorno THEN 
                DO:
                    ASSIGN i-cod-erro  = 27
                           c-desc-erro = "". 
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                END.
            
            IF  p-tipo-pessoa-de <> p-pessoa THEN
                DO:
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = "Tipo de pessoa(De) Incorreto". 
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                END.

            IF  p-cpfcnpj-de1 <> "" THEN 
                DO:
             
                    in01  = 1.
                    ASSIGN c-desc-erro = " "
                           i-cod-erro  = 0.
                    DO  WHILE in01 LE LENGTH(p-cpfcnpj-de1):
                    
                        IF  SUBSTR(p-cpfcnpj-de1,in01,1) <> "0"     AND
                            SUBSTR(p-cpfcnpj-de1,in01,1) <> "1"     AND
                            SUBSTR(p-cpfcnpj-de1,in01,1) <> "2"     AND
                            SUBSTR(p-cpfcnpj-de1,in01,1) <> "3"     AND
                            SUBSTR(p-cpfcnpj-de1,in01,1) <> "4"     AND
                            SUBSTR(p-cpfcnpj-de1,in01,1) <> "5"     AND
                            SUBSTR(p-cpfcnpj-de1,in01,1) <> "6"     AND
                            SUBSTR(p-cpfcnpj-de1,in01,1) <> "7"     AND
                            SUBSTR(p-cpfcnpj-de1,in01,1) <> "8"     AND
                            SUBSTR(p-cpfcnpj-de1,in01,1) <> "9"     THEN 
                            DO:
                                ASSIGN  i-cod-erro = 27.
                                LEAVE.
                            END.    
                        in01 = in01 + 1.
                    END. /* fim do DO  WHILE in01  */

                    IF  i-cod-erro > 0 THEN 
                        DO:
                            RUN cria-erro (INPUT p-cooper,
                                           INPUT p-cod-agencia,
                                           INPUT p-nro-caixa, 
                                           INPUT i-cod-erro,
                                           INPUT c-desc-erro,
                                           INPUT YES).
                            RETURN "NOK".
                        END.   

             
                    RUN  dbo/pcrap06.p (INPUT  p-cpfcnpj-de1,
                                        OUTPUT p-retorno,
                                        OUTPUT p-pessoa).

                    IF  NOT p-retorno THEN 
                        DO:
                            ASSIGN i-cod-erro  = 27
                                   c-desc-erro = "". 
                            RUN cria-erro (INPUT p-cooper,
                                           INPUT p-cod-agencia,
                                           INPUT p-nro-caixa,
                                           INPUT i-cod-erro,
                                           INPUT c-desc-erro,
                                           INPUT YES).
                        END.
                END.

            IF  p-tipo-doc = 'D' OR p-tipo-doc = 'TEDD' THEN 
                DO:
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = 
                      "Para Doc D e TED, deve-se informar a conta do cliente.".
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                END.

        END.

    /* DOC */
    IF  p-tipo-doc = 'D' OR p-tipo-doc = 'C' THEN
        DO:        
	IF  p-cod-agencia-banco = 0 THEN 
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = 
                        "Agencia deve ser informada.". 
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).            
        END. 

             /* Para DOC continua como 13 o tamanho maximo */
             IF LENGTH(STRING(p-nro-conta-para)) > 13 THEN
                DO:
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = "Informe o numero da conta com ate 13 caracteres." .
                           
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).            
                END.
        END.
    ELSE  /* TED */
        DO:
            IF  p-cod-agencia-banco = 0 AND 
               (p-tipo-conta-cr = 1  OR 
                p-tipo-conta-cr = 2) THEN
                DO:
                    IF  p-tipo-conta-cr = 1 THEN
                        ASSIGN i-cod-erro  = 0
                               c-desc-erro = 
                                     "Preenchimento de campo agencia obrigatorio para o " +
                                     "tipo de conta: Conta Corrente.". 
                    ELSE
                        ASSIGN i-cod-erro  = 0
                               c-desc-erro = 
                                     "Preenchimento de campo agencia obrigatorio para o " +
                                     "tipo de conta: Conta Poupanca.". 
                           
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).                           
                END.
            ELSE
                DO:
                    IF  p-cod-agencia-banco <> 0 AND
                        p-tipo-conta-cr = 3 THEN
                        DO:
                            ASSIGN i-cod-erro  = 0
                                   c-desc-erro = 
                                         "Preenchimento de campo agencia nao e permitido para o " +
                                         "tipo de conta: Conta de Pagamento.". 

                            RUN cria-erro (INPUT p-cooper,
                                           INPUT p-cod-agencia,
                                           INPUT p-nro-caixa,
                                           INPUT i-cod-erro,
                                           INPUT c-desc-erro,
                                           INPUT YES).            
                        END.
                END.
                
           IF ((p-tipo-conta-cr = 1  OR  /* Conta Corrente */
                p-tipo-conta-cr = 2) AND /* Conta Poupanca */
                LENGTH(STRING(p-nro-conta-para)) > 13 ) THEN
                DO:
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = "Informe o numero da conta com ate 13 caracteres." .
                           
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).            
                  END.
        END.

    IF  p-nro-conta-para = 0  THEN 
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Conta do Favorecido deve ser informada". 
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
        END. 
                                                           


    IF  p-nome-para = ""  THEN  
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = 
                            "Nome Destinatario deve ser Informado".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
        END.                           

    in01  = 1.
    ASSIGN c-desc-erro = " "
           i-cod-erro  = 0.
                   
    DO  WHILE in01 LE LENGTH(p-cpfcnpj-para):
        IF  SUBSTR(p-cpfcnpj-para,in01,1) <> "0"    AND
            SUBSTR(p-cpfcnpj-para,in01,1) <> "1"    AND
            SUBSTR(p-cpfcnpj-para,in01,1) <> "2"    AND
            SUBSTR(p-cpfcnpj-para,in01,1) <> "3"    AND
            SUBSTR(p-cpfcnpj-para,in01,1) <> "4"    AND
            SUBSTR(p-cpfcnpj-para,in01,1) <> "5"    AND
            SUBSTR(p-cpfcnpj-para,in01,1) <> "6"    AND
            SUBSTR(p-cpfcnpj-para,in01,1) <> "7"    AND
            SUBSTR(p-cpfcnpj-para,in01,1) <> "8"    AND
            SUBSTR(p-cpfcnpj-para,in01,1) <> "9"    THEN 
            DO:
                ASSIGN  i-cod-erro = 27.
                LEAVE.
            END.    
        
        in01 = in01 + 1.
    END. /* Fim do DO  WHILE in01 */

    IF  i-cod-erro > 0 THEN 
        DO:
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa, 
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.   

    RUN  dbo/pcrap06.p (INPUT  p-cpfcnpj-para,
                       OUTPUT p-retorno,
                       OUTPUT p-pessoa).

    IF  NOT p-retorno THEN 
        DO:
            ASSIGN i-cod-erro  = 27
                   c-desc-erro = " ". 
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
        END.
            
    IF  p-tipo-pessoa-para <> p-pessoa THEN
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Tipo de pessoa(Para) Incorreto".
                                 
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
        END.

    IF  p-cpfcnpj-para1 <> " " THEN 
        DO:
            in01  = 1.
            ASSIGN c-desc-erro = " "
                   i-cod-erro  = 0.
                       
            DO  WHILE in01 LE LENGTH(p-cpfcnpj-para1):
                IF  SUBSTR(p-cpfcnpj-para1,in01,1) <> "0"   AND
                    SUBSTR(p-cpfcnpj-para1,in01,1) <> "1"   AND
                    SUBSTR(p-cpfcnpj-para1,in01,1) <> "2"   AND
                    SUBSTR(p-cpfcnpj-para1,in01,1) <> "3"   AND
                    SUBSTR(p-cpfcnpj-para1,in01,1) <> "4"   AND
                    SUBSTR(p-cpfcnpj-para1,in01,1) <> "5"   AND
                    SUBSTR(p-cpfcnpj-para1,in01,1) <> "6"   AND
                    SUBSTR(p-cpfcnpj-para1,in01,1) <> "7"   AND
                    SUBSTR(p-cpfcnpj-para1,in01,1) <> "8"   AND
                    SUBSTR(p-cpfcnpj-para1,in01,1) <> "9"   THEN 
                    DO:
                        ASSIGN  i-cod-erro = 27.
                        LEAVE.
                    END.    
                in01 = in01 + 1.
            END. /* fim do DO  WHILE in01 */
                    
            IF  i-cod-erro > 0 THEN 
                DO:
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa, 
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.   
            
            RUN  dbo/pcrap06.p (INPUT  p-cpfcnpj-para1,
                               OUTPUT p-retorno,
                               OUTPUT p-pessoa).
         
            IF  NOT p-retorno THEN 
                DO:
                    ASSIGN i-cod-erro  = 27
                           c-desc-erro = " ". 
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                END.         
        END.

    IF   TRIM(p-cpfcnpj-de1) = "0"   THEN
         ASSIGN p-cpfcnpj-de1 = "".

    /* Se CPFs de origem for igual ao CPF de destino e for selecionado TED C
      , solicitar o envio atraves de TED D - Restricao valida para TED C com
      debito em conta corrente */
    IF   p-tipo-doc = 'TEDC' AND p-nro-conta-de <> 0 THEN
         DO: 
             IF   ( ( TRIM(p-cpfcnpj-de) = TRIM(p-cpfcnpj-para) AND
                      TRIM(p-cpfcnpj-de1) = TRIM(p-cpfcnpj-para1)  ) OR
                    ( TRIM(p-cpfcnpj-de1) = TRIM(p-cpfcnpj-para) AND
                    TRIM(p-cpfcnpj-de) = TRIM(p-cpfcnpj-para1)   )  )  THEN
                    DO:
                        ASSIGN i-cod-erro  = 0           
                             c-desc-erro = "TED preenchido com mesma titularidade, " +
                                           "favor utilizar a opcao TED D.".
                                 
                        RUN cria-erro (INPUT p-cooper,
                                       INPUT p-cod-agencia,
                                       INPUT p-nro-caixa,
                                       INPUT i-cod-erro,
                                       INPUT c-desc-erro,
                                       INPUT YES).
                        RETURN "NOK"  .
                    END.
         END.

    /* Caso nao estiver operando com o SPB e a conta de destino estiver
       com mais de 12 digitos, informar o usuário que o TED deve ser
       gerado manualmente no Gerenciador Financeiro */
    IF  (crapcop.flgoppag = FALSE AND crapcop.flgopstr = FALSE) AND 
        (LENGTH(STRING(p-nro-conta-para)) > 12)   THEN
         DO:
            ASSIGN i-cod-erro  = 0           
                   c-desc-erro = 
                       "Conta de destino contém mais de 12 digitos, favor" +
                       " efetuar o envio do TED/DOC no Gerenciador Financeiro.".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
            
         END.
        
    FIND craptab WHERE 
          craptab.cdcooper = crapcop.cdcooper AND
          craptab.nmsistem = "CRED"           AND /* Verif. horario */
          craptab.tptabela = "GENERI"         AND
          craptab.cdempres = 0                AND
          craptab.cdacesso = "HRTRDOCTOS"     AND  
          craptab.tpregist = p-cod-agencia    NO-LOCK NO-ERROR.
   
    IF  NOT AVAIL craptab THEN 
        DO:
            ASSIGN i-cod-erro  = 0 
                   c-desc-erro = "". 
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
        END.
    ELSE 
        DO: /* Verifica horario dos TED'S */  
            IF (p-tipo-doc = 'TEDD' OR p-tipo-doc = 'TEDC') AND
               (crapcop.flgoppag = FALSE AND crapcop.flgopstr = FALSE) THEN
                DO: 
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = "Cooperativa está inoperante no SPB.". 
                                    RUN cria-erro (INPUT p-cooper,
                                                   INPUT p-cod-agencia,
                                                   INPUT p-nro-caixa,
                                                   INPUT i-cod-erro,
                                                   INPUT c-desc-erro,
                                                   INPUT YES).
                              END.
            ELSE  /* DOC */ 
                DO:
                    IF  p-tipo-doc = 'D' OR p-tipo-doc = 'C' THEN
                        DO:
                           IF  INT(SUBSTR(craptab.dstextab,1,1)) <> 0 THEN
                               DO: 
                                   ASSIGN i-cod-erro  = 677
                                          c-desc-erro = "". 
                                   RUN cria-erro (INPUT p-cooper,
                                                  INPUT p-cod-agencia,
                                                  INPUT p-nro-caixa,
                                                  INPUT i-cod-erro,
                                                  INPUT c-desc-erro,
                                                  INPUT YES).
                               END.
                           ELSE
                               DO:
                                  IF  INT(SUBSTR(craptab.dstextab,3,5)) <= TIME
                                      THEN 
                                      DO:
                                           ASSIGN i-cod-erro  = 676
                                                  c-desc-erro = "". 
                                           RUN cria-erro (INPUT p-cooper,
                                                          INPUT p-cod-agencia,
                                                          INPUT p-nro-caixa,
                                                          INPUT i-cod-erro,
                                                          INPUT c-desc-erro,
                                                          INPUT YES).
                                      END.
                               END.
                        END.
                END. 
        END. 
      
        IF  (INT(p-cod-finalidade) = 99 OR INT(p-cod-finalidade) = 99999 OR INT(p-cod-finalidade) = 999) AND p-dsc-historico = ''
          THEN 
          DO:
               ASSIGN i-cod-erro  = 0
                      c-desc-erro = "Informe a descriçao do histórico". 
               RUN cria-erro (INPUT p-cooper,
                              INPUT p-cod-agencia,
                              INPUT p-nro-caixa,
                              INPUT i-cod-erro,
                              INPUT c-desc-erro,
                              INPUT YES).
          END. 
    
    RUN verifica-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa).
    
    IF  RETURN-VALUE = "NOK" THEN
        RETURN "NOK".      

    RETURN "OK".
    
END PROCEDURE.         


FUNCTION centraliza RETURNS CHARACTER ( INPUT par_frase AS CHARACTER, INPUT par_tamlinha AS INTEGER ):

    DEF VAR vr_contastr AS INTEGER NO-UNDO.
    
    ASSIGN vr_contastr = TRUNC( (par_tamlinha - LENGTH(TRIM(par_frase))) / 2 ,0).

    RETURN FILL(' ',vr_contastr) + TRIM(par_frase).
END.

PROCEDURE atualiza-doc-ted: /* Caixa on line*/

    /* Procedure enviar-ted foi criada nessa BO para InternetBank 
       baseada nessa procedure */

    DEFINE INPUT PARAMETER p-cooper         AS CHAR NO-UNDO.    
    DEFINE INPUT PARAMETER p-cod-agencia    AS INT NO-UNDO. /* Cod. Agencia  */
    DEFINE INPUT PARAMETER p-nro-caixa      AS INT NO-UNDO. /* Numero  Caixa */
    DEFINE INPUT PARAMETER p-cod-operador   AS CHAR NO-UNDO.  
    DEFINE INPUT PARAMETER p-cod-opeaut     AS CHAR NO-UNDO.
    DEFINE INPUT PARAMETER p-tipo-doc       AS INT NO-UNDO. /* Tipo Doc      */
    DEFINE INPUT PARAMETER p-titular        AS LOG NO-UNDO. /* Mesma Titular.*/
    DEFINE INPUT PARAMETER p-tipo-pag       AS CHAR NO-UNDO. /* TpPagto */
    DEFINE INPUT PARAMETER p-val-doc        AS DEC NO-UNDO. /* Vlr. DOC      */
    DEFINE INPUT PARAMETER p-nro-conta-de   AS INT NO-UNDO. /* Nro Conta De  */
    DEFINE INPUT PARAMETER p-cod-banco      AS INT NO-UNDO. /* Codigo Banco  */
    DEFINE INPUT PARAMETER p-cod-agencia-banco AS INT NO-UNDO. /* Cod Agencia*/
    DEFINE INPUT PARAMETER p-nro-conta-para AS DEC NO-UNDO.  
    DEFINE INPUT PARAMETER p-cod-finalidade AS INT NO-UNDO.  
    DEFINE INPUT PARAMETER p-tipo-conta-db  AS INT NO-UNDO. 
    DEFINE INPUT PARAMETER p-tipo-conta-cr  AS INT NO-UNDO.  
    DEFINE INPUT PARAMETER p-desc-hist      AS CHAR NO-UNDO. /* Descricao Hist*/
    DEFINE INPUT PARAMETER p-nome-de        AS CHAR NO-UNDO.  /* Nome De */  
    DEFINE INPUT PARAMETER p-nome-de1       AS CHAR NO-UNDO.                 
    DEFINE INPUT PARAMETER p-cpfcnpj-de     AS CHAR NO-UNDO.  /* CPF/CNPJ De*/
    DEFINE INPUT PARAMETER p-cpfcnpj-de1    AS CHAR NO-UNDO.   
    DEFINE INPUT PARAMETER p-nome-para      AS CHAR NO-UNDO.  /* Nome Para  */
    DEFINE INPUT PARAMETER p-nome-para1     AS CHAR NO-UNDO.  
    DEFINE INPUT PARAMETER p-cpfcnpj-para   AS CHAR NO-UNDO. /* CPF/CNPJ Para*/
    DEFINE INPUT PARAMETER p-cpfcnpj-para1       AS CHAR NO-UNDO.
    DEFINE INPUT PARAMETER p-tipo-pessoa-de      AS INT  NO-UNDO.
    DEFINE INPUT PARAMETER p-tipo-pessoa-para    AS INT  NO-UNDO.
    DEFINE INPUT PARAMETER p-cod-id-transf       AS CHAR NO-UNDO.
    DEFINE INPUT PARAMETER p-ispb-if             AS INT NO-UNDO. /* ISPB Banco  */
    DEFINE INPUT PARAMETER p-idtipcar            AS INT  NO-UNDO.
    DEFINE INPUT PARAMETER p-opcao               AS CHAR NO-UNDO. 
    DEFINE INPUT PARAMETER p-dsimpvia            AS CHAR NO-UNDO.    
    DEFINE INPUT PARAMETER p-nrcartao            AS DECI NO-UNDO.    
    DEFINE OUTPUT PARAMETER p-nro-lote           AS INT  NO-UNDO.
    DEFINE OUTPUT PARAMETER p-nro-docmto         AS INT  NO-UNDO.
    DEFINE OUTPUT PARAMETER p-literal-autentica  AS CHAR NO-UNDO.
    DEFINE OUTPUT PARAMETER p-ult-seq-autentica  AS INT  NO-UNDO.
    DEFINE OUTPUT PARAMETER p-nro-conta-rm       AS INT  NO-UNDO.
    DEFINE OUTPUT PARAMETER p-aviso-cx           AS LOG  NO-UNDO.

    DEFINE VARIABLE p-cdlantar    LIKE craplat.cdlantar  NO-UNDO.

    DEFINE VARIABLE iLnAut        AS INTEGER      NO-UNDO.
    DEFINE VARIABLE iContLn       AS INTEGER      NO-UNDO.
    DEFINE VARIABLE aux_linha1    AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE aux_linha2    AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE aux_flgopspb  AS LOGICAL      NO-UNDO.
    DEFINE VARIABLE aux_nrctrlif  AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE aux_contador  AS INTEGER      NO-UNDO.
    DEFINE VARIABLE aux_cdhistor  AS INTEGER      NO-UNDO.
    DEFINE VARIABLE aux_vllanmto  AS DECIMAL      NO-UNDO.
    DEFINE VARIABLE aux_mensagem  AS CHARACTER    NO-UNDO.        
    DEFINE VARIABLE aux_indopera  AS INTEGER      NO-UNDO.

    DEFINE VARIABLE tar_cdhistor  AS INTEGER      NO-UNDO.
    DEFINE VARIABLE tar_vllanmto  AS DECIMAL      NO-UNDO.

    DEF VAR h-b1wgen0153 AS HANDLE                NO-UNDO.

    DEF VAR aux_cdbattar AS CHAR                  NO-UNDO.
    DEF VAR aux_cdhisest AS INTE                  NO-UNDO.
    DEF VAR aux_dtdivulg AS DATE                  NO-UNDO.
    DEF VAR aux_dtvigenc AS DATE                  NO-UNDO.
    DEF VAR aux_cdfvlcop AS INTE                  NO-UNDO.
    DEF VAR aux_ponteiro AS INTE                  NO-UNDO.
    DEF VAR aux_nrseqdoc AS INTE                  NO-UNDO.
    DEF VAR aux_nrseqted AS INTE                  NO-UNDO.
    DEF VAR aux_hrtransa AS INTE                  NO-UNDO.
    DEF VAR aux_nmdBanco AS CHAR                  NO-UNDO.
    DEF VAR aux_cddBanco AS CHAR                  NO-UNDO.   

    DEF VAR aux_qtacobra AS INTE                  NO-UNDO.
    DEF VAR aux_fliseope AS INTE                  NO-UNDO.
    DEF VAR aux_cdcritic AS INTE                  NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                  NO-UNDO.

    DEF BUFFER crabhis FOR craphis.


    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.
    
    IF   crapcop.flgopstr OR crapcop.flgoppag   THEN
         ASSIGN aux_flgopspb = TRUE.
    
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia, 
                      INPUT p-nro-caixa).
    
    /* Retirar caracteres especiais do nome do titular de origem */
    RUN fontes/substitui_caracter.p (INPUT-OUTPUT p-nome-de).

    /* Retirar caracteres especiais do nome do segundo titular de origem */
    RUN fontes/substitui_caracter.p (INPUT-OUTPUT p-nome-de1).
    
    /* Retirar caracteres especiais do nome do titular de destino */
    RUN fontes/substitui_caracter.p (INPUT-OUTPUT p-nome-para).

    /* Retirar caracteres especiais do nome do segundo titular de destino */
    RUN fontes/substitui_caracter.p (INPUT-OUTPUT p-nome-para1).

    IF   TRIM(p-cpfcnpj-de1) = "0"   THEN
         ASSIGN p-cpfcnpj-de1 = "".

    /*----- Campos desabilitados  - Necessario mover valor --*/
    IF  p-tipo-doc = 2 /*DOC D*/ OR                   
        p-tipo-doc = 4 /*TED D*/     THEN  
        DO:
            ASSIGN p-nome-para     = p-nome-de 
                   p-cpfcnpj-para  = p-cpfcnpj-de 
                   p-nome-para1    = p-nome-de1 
                   p-cpfcnpj-para1 = p-cpfcnpj-de1. 
        END.
    /*------------------------------------------------------*/

    ASSIGN p-cpfcnpj-de    = REPLACE(p-cpfcnpj-de,"/","")
           p-cpfcnpj-de    = REPLACE(p-cpfcnpj-de,".","")
           p-cpfcnpj-de    = REPLACE(p-cpfcnpj-de,"-","")
                           
           p-cpfcnpj-de1   = REPLACE(p-cpfcnpj-de1,"/","")
           p-cpfcnpj-de1   = REPLACE(p-cpfcnpj-de1,".","")
           p-cpfcnpj-de1   = REPLACE(p-cpfcnpj-de1,"-","")
                           
           p-cpfcnpj-para  = REPLACE(p-cpfcnpj-para,"/","")
           p-cpfcnpj-para  = REPLACE(p-cpfcnpj-para,".","")
           p-cpfcnpj-para  = REPLACE(p-cpfcnpj-para,"-","")

           p-cpfcnpj-para1 = REPLACE(p-cpfcnpj-para1,"/","")
           p-cpfcnpj-para1 = REPLACE(p-cpfcnpj-para1,".","")
           p-cpfcnpj-para1 = REPLACE(p-cpfcnpj-para1,"-","").

    FIND FIRST crapdat WHERe crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.

    IF  p-cod-agencia   = 0   OR
        P-nro-caixa     = 0   OR
        P-cod-operador  = ""  THEN
        DO:
            ASSIGN i-cod-erro  = 0           
                   c-desc-erro = 
                          "ERRO!!! PA ZERADO. FECHE O CAIXA E AVISE O CPD ".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

    /* Lote para craptvl e para autenticacao */
    IF  p-tipo-doc = 3 OR p-tipo-doc = 4  THEN
        DO:
           IF   aux_flgopspb   THEN /* TED C e TED D - SPB */
                ASSIGN i-nro-lote  = 23000 + p-nro-caixa
                       i-tipo-lote = 25
                       i-cdhistor  = 523.
           ELSE
                ASSIGN i-nro-lote  = 21000 + p-nro-caixa
                       i-tipo-lote = 25
                       i-cdhistor  = 558.
        END.
    ELSE                           /* DOC */
        ASSIGN i-nro-lote  = 20000 + p-nro-caixa
               i-tipo-lote = 24
               i-cdhistor  = 557.

    
    ASSIGN p-nro-lote      = i-nro-lote
           /* Lote para debito em CC*/
           i-nro-lote-lcm  = 11000 + p-nro-caixa
           i-tipo-lote-lcm = 1. 

    FIND craplot WHERE craplot.cdcooper = crapcop.cdcooper  AND
                       craplot.dtmvtolt = crapdat.dtmvtocd  AND
                       craplot.cdagenci = p-cod-agencia     AND
                       craplot.cdbccxlt = 11                AND  /* Fixo */
                       craplot.nrdolote = i-nro-lote        NO-ERROR.
                       
    IF  NOT AVAIL craplot THEN 
        DO:
            CREATE craplot.
            ASSIGN craplot.cdcooper = crapcop.cdcooper
                   craplot.dtmvtolt = crapdat.dtmvtocd
                   craplot.cdagenci = p-cod-agencia   
                   craplot.cdbccxlt = 11              
                   craplot.nrdolote = i-nro-lote
                   craplot.tplotmov = i-tipo-lote
                   craplot.cdoperad = p-cod-operador
                   craplot.cdhistor = i-cdhistor
                   craplot.nrdcaixa = p-nro-caixa
                   craplot.cdopecxa = p-cod-operador.
         
        END.

    ASSIGN in99 = 0.

    IF p-tipo-doc = 1 OR p-tipo-doc = 2 THEN
       DO:
            /* Busca a proxima sequencia do campo CRAPMAT.NRSEQDOC */
        	RUN STORED-PROCEDURE pc_sequence_progress
        	aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPMAT"
        										,INPUT "NRSEQDOC"
        										,INPUT STRING(crapcop.cdcooper)
        										,INPUT "N"
        										,"").
        	
        	CLOSE STORED-PROC pc_sequence_progress
        	aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
        			  
        	ASSIGN aux_nrseqdoc = INTE(pc_sequence_progress.pr_sequence)
        						  WHEN pc_sequence_progress.pr_sequence <> ?.
       END.
    ELSE
       DO:
            /* Busca a proxima sequencia do campo CRAPMAT.NRSEQTED */
        	RUN STORED-PROCEDURE pc_sequence_progress
        	aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPMAT"
        										,INPUT "NRSEQTED"
        										,INPUT STRING(crapcop.cdcooper)
        										,INPUT "N"
        										,"").
        	
        	CLOSE STORED-PROC pc_sequence_progress
        	aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
        			  
        	ASSIGN aux_nrseqted = INTE(pc_sequence_progress.pr_sequence)
        						  WHEN pc_sequence_progress.pr_sequence <> ?.
       END.

    IF  p-tipo-doc = 3 OR p-tipo-doc = 4  THEN
        ASSIGN i-nro-docto = aux_nrseqted.
    ELSE
        ASSIGN i-nro-docto = aux_nrseqdoc.
    
    /* Se conta nao informada e CPF/CNPJ for de cooperado, buscar conta */
    IF   p-nro-conta-de = 0   THEN
         DO: 
            /* Pessoa Fisica */
            IF   p-tipo-pessoa-de = 1  THEN
                 DO:
                    aux_contador = 0.
                    FOR EACH crapttl WHERE 
                             crapttl.cdcooper = crapcop.cdcooper  AND
                             crapttl.nrcpfcgc = DEC(p-cpfcnpj-de) NO-LOCK,
                        EACH  crapass WHERE
                              crapass.cdcooper = crapcop.cdcooper  AND
                              crapass.nrdconta = crapttl.nrdconta  AND
                              crapass.dtdemiss = ?                 AND
                              NOT CAN-DO("5,6,7,17,18",STRING(crapass.cdtipcta))
                              NO-LOCK:

                        ASSIGN aux_contador   = aux_contador + 1
                               p-nro-conta-rm = crapttl.nrdconta.

                    END. /* Fim do FOR EACH */
         
                    /* Mesmo CPF em mais contas */
                    IF   aux_contador > 1   THEN
                         ASSIGN p-nro-conta-rm = 0
                                p-aviso-cx  = YES.
                 END.
            ELSE
                 /* Pessoa Juridica */
                 DO:
                    FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper  AND
                                       crapass.nrcpfcgc = DEC(p-cpfcnpj-de)
                                       NO-LOCK NO-ERROR.
                    
                    IF   AVAILABLE crapass   THEN
                         ASSIGN p-nro-conta-rm = crapass.nrdconta.
                 END.
         END.
    ELSE
         ASSIGN p-nro-conta-rm = p-nro-conta-de.
    
    ASSIGN aux_nrdctitg = " "
           aux_cdagenci = " ".
    IF  p-nro-conta-rm > 0 THEN
        DO:
            FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper  AND
                               crapass.nrdconta = p-nro-conta-rm 
                               NO-LOCK NO-ERROR.
                               
            IF  AVAIL crapass THEN
                ASSIGN aux_nrdctitg = crapass.nrdctitg
                       aux_cdagenci = STRING(crapass.cdagenci). 

        END. 

    /* Envio para o SPB */ 
    IF   aux_flgopspb AND (p-tipo-doc = 3 OR p-tipo-doc = 4)   THEN
         DO:    
            /* Se alterar numero de controle, ajustar procedure enviar-ted */
            ASSIGN aux_nrctrlif = "1" + 
                                  SUBSTRING(STRING(YEAR(crapdat.dtmvtocd)),3) +
                                  STRING(MONTH(crapdat.dtmvtocd),"99") +
                                  STRING(DAY(crapdat.dtmvtocd),"99") +
                                  STRING(crapcop.cdagectl,"9999") +
                                  STRING(i-nro-docto,"99999999") + 
                                  "C".
                        
            FIND craptvl WHERE craptvl.cdcooper = crapcop.cdcooper  AND
                               craptvl.tpdoctrf = 3 /* TED - SPB */ AND
                               craptvl.idopetrf = aux_nrctrlif      NO-LOCK 
                               NO-ERROR.

            IF   AVAILABLE craptvl   THEN
                 DO:
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = "ERRO!!! DOCTO DUPLICADO," + 
                                         "TENTE NOVAMENTE".
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
            FIND craptvl WHERE craptvl.cdcooper = crapcop.cdcooper  AND
                               craptvl.dtmvtolt = crapdat.dtmvtocd  AND
                               craptvl.cdagenci = p-cod-agencia     AND
                               craptvl.cdbccxlt = 11                AND
                               craptvl.nrdolote = i-nro-lote        AND
                               craptvl.tpdoctrf = p-tipo-doc        AND
                               craptvl.nrdocmto = i-nro-docto - 1   
                               NO-LOCK NO-ERROR.

            ASSIGN aux_nrctrlif = "".

            IF  AVAIL craptvl                   AND
                TIME <= (craptvl.hrtransa + 60) THEN 
                DO: 
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = "ERRO!!! DOCTO DUPLICADO," + 
                                         "TENTE NOVAMENTE".
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END. 
         END.

    FIND crapage WHERE  crapage.cdcooper = crapcop.cdcooper AND
                        crapage.cdagenci = p-cod-agencia
                        NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapage   THEN
         DO:
            ASSIGN i-cod-erro  = 015
                   c-desc-erro = "".
                 
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
                  
            RETURN "NOK".
         END.
    
    CREATE craptvl.
    ASSIGN craptvl.cdcooper = crapcop.cdcooper
           craptvl.tpdoctrf = IF p-tipo-doc = 3 OR p-tipo-doc = 4 THEN
                                 3
                              ELSE p-tipo-doc
           craptvl.idopetrf = aux_nrctrlif                              
           craptvl.nrdconta = p-nro-conta-rm
           craptvl.cpfcgemi = DEC(p-cpfcnpj-de)
           craptvl.cpfsgemi = DEC(p-cpfcnpj-de1)
           craptvl.nmpesemi = CAPS(p-nome-de)
           craptvl.nmsegemi = CAPS(p-nome-de1)
    
           craptvl.nrdctitg = aux_nrdctitg
           craptvl.cdbccrcb = p-cod-banco
           craptvl.cdagercb = p-cod-agencia-banco
           craptvl.cpfcgrcb = DEC(p-cpfcnpj-para) 
           craptvl.nmpesrcb = CAPS(p-nome-para)
           
           craptvl.cpstlrcb = DEC(p-cpfcnpj-para1)
           craptvl.nmstlrcb = CAPS(p-nome-para1)
           
           craptvl.cdbcoenv = IF p-tipo-doc = 1 OR p-tipo-doc = 2 THEN
                                 0 /* Mirtes */
                              ELSE 
                              IF aux_flgopspb THEN
                                 crapcop.cdbcoctl
                              ELSE 1
           craptvl.vldocrcb = p-val-doc
           craptvl.dtmvtolt = crapdat.dtmvtocd
           craptvl.hrtransa = TIME
           craptvl.nrdolote = i-nro-lote
           craptvl.cdagenci = p-cod-agencia
           craptvl.cdbccxlt = 11 /* Fixo */
           craptvl.nrdocmto = i-nro-docto
           craptvl.nrseqdig = craplot.nrseqdig + 1   
           craptvl.nrcctrcb = p-nro-conta-para             
           craptvl.cdfinrcb = p-cod-finalidade
           craptvl.tpdctacr = p-tipo-conta-cr
           craptvl.tpdctadb = p-tipo-conta-db
           craptvl.dshistor = p-desc-hist
           craptvl.cdoperad = p-cod-operador
           craptvl.cdopeaut = p-cod-opeaut
           craptvl.flgespec = 
            IF (p-tipo-doc = 1 OR p-tipo-doc = 3) AND p-tipo-pag = 'E'  THEN
               TRUE
             ELSE FALSE
           craptvl.nrispbif = p-ispb-if.

    IF  p-tipo-doc = 1   THEN
        ASSIGN craptvl.flgtitul = FALSE.
    ELSE
        IF  p-tipo-doc = 2  THEN
            ASSIGN craptvl.flgtitul = TRUE.
        ELSE      
            ASSIGN craptvl.flgtitul = p-titular
                   craptvl.flgenvio = YES. /* arquivo TED gerado on-line */

    IF  p-tipo-pessoa-de = 1 THEN
        ASSIGN craptvl.flgpesdb = YES.
    ELSE
        ASSIGN craptvl.flgpesdb = NO.

    IF  p-tipo-pessoa-para = 1  THEN
        ASSIGN craptvl.flgpescr = YES.
    ELSE 
        ASSIGN craptvl.flgpescr = NO.
               
    ASSIGN craplot.qtcompln = craplot.qtcompln + 1
           craplot.vlcompcr = craplot.vlcompcr + p-val-doc
           craplot.qtinfoln = craplot.qtinfoln + 1
           craplot.vlinfocr = craplot.vlinfocr + p-val-doc
           craplot.nrseqdig = craptvl.nrseqdig
           p-nro-docmto     = craptvl.nrdocmto.

    VALIDATE craplot.

    /*--- Grava Autenticacao Arquivo/Spool --*/
    RUN dbo/b1crap00.p PERSISTENT SET h_b1crap00.
    RUN grava-autenticacao  IN h_b1crap00 (INPUT p-cooper,
                                           INPUT p-cod-agencia,
                                           INPUT p-nro-caixa,
                                           INPUT p-cod-operador,
                                           INPUT p-val-doc,
                                           INPUT dec(p-nro-docmto),
                                           INPUT no, /* YES (PG), NO (REC) */
                                           INPUT "1",  /* On-line            */         
                                           INPUT NO,   /* Nao estorno        */
                                           INPUT i-cdhistor, 
                                           INPUT ?, /* Data off-line */
                                           INPUT 0, /* Sequencia off-line */
                                           INPUT 0, /* Hora off-line */
                                           INPUT 0, /* Seq.orig.Off-line */
                                           OUTPUT p-literal,
                                           OUTPUT p-ult-sequencia,
                                           OUTPUT p-registro).
    DELETE PROCEDURE h_b1crap00.

    IF  RETURN-VALUE = "NOK" THEN
        RETURN "NOK".
   
    FIND craplot WHERE craplot.cdcooper = crapcop.cdcooper    AND
                       craplot.dtmvtolt = crapdat.dtmvtocd    AND
                       craplot.cdagenci = p-cod-agencia       AND
                       craplot.cdbccxlt = 11   /* Fixo */     AND  
                       craplot.nrdolote = i-nro-lote-lcm      
                       NO-ERROR.

    IF  NOT AVAIL craplot THEN 
        DO:
           CREATE craplot.
           ASSIGN craplot.cdcooper = crapcop.cdcooper
                  craplot.dtmvtolt = crapdat.dtmvtocd
                  craplot.cdagenci = p-cod-agencia   
                  craplot.cdbccxlt = 11              
                  craplot.nrdolote = i-nro-lote-lcm
                  craplot.tplotmov = i-tipo-lote-lcm
                  craplot.cdoperad = p-cod-operador
                  craplot.cdhistor = i-cdhistor
                  craplot.nrdcaixa = p-nro-caixa
                  craplot.cdopecxa = p-cod-operador.
        END.
   
    IF   p-nro-conta-rm <> 0   THEN
         DO:

             /* Rotina para buscar valor tarifa TED/DOC */
             RUN busca-tarifa-ted (INPUT crapcop.cdcooper,
                              INPUT p-cod-agencia,
                              INPUT p-nro-conta-rm, 
                              INPUT 1, /* vllanmto */
                              OUTPUT tar_vllanmto,
                              OUTPUT tar_cdhistor,
                              OUTPUT aux_cdhisest,
                              OUTPUT aux_cdfvlcop,
                              OUTPUT aux_dscritic).
    
             IF  RETURN-VALUE = "NOK"  THEN
             DO:
    
                 ASSIGN i-cod-erro  = 0
                        c-desc-erro = aux_dscritic.
                
                 RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
    
                 RETURN "NOK". 
               
             END.
             
             ASSIGN aux_vllanmto = p-val-doc.                                                                                             
                               
             IF  aux_vllanmto <> 0  OR 
                 tar_vllanmto <> 0  THEN
                 DO:                                                                 
                    IF   p-tipo-pag = 'D'   THEN /* Debito em C.Corrente */
                         DO:
                            ASSIGN aux_cdhistor = IF  p-tipo-doc = 1 AND 
                                                      p-tipo-pag = 'D'    THEN
                                                      355
                                                  ELSE     
                                                  IF  p-tipo-doc = 3 AND
                                                      p-tipo-pag = 'D'   THEN
                                                      555
                                                  ELSE
                                                  IF  p-tipo-doc = 2    THEN
                                                      103                                            
                                                  ELSE
                                                      503. /* p-tipo-doc = 4 */ 

                            /*--- Grava Autenticacao Arquivo/Spool --*/
                            RUN dbo/b1crap00.p PERSISTENT SET h_b1crap00.
                            
                            RUN grava-autenticacao  
                                      IN h_b1crap00 (INPUT p-cooper,
                                                     INPUT p-cod-agencia,
                                                     INPUT p-nro-caixa,
                                                     INPUT p-cod-operador,
                                                     INPUT aux_vllanmto,
                                                     INPUT dec(p-nro-docmto),
                          /* YES (PG), NO (REC) */   INPUT YES, 
                          /* On-line            */   INPUT "1",  
                          /* Nao estorno        */   INPUT NO,   
                                                     INPUT aux_cdhistor, 
                          /* Data off-line */        INPUT ?, 
                          /* Sequencia off-line */   INPUT 0, 
                          /* Hora off-line */        INPUT 0, 
                          /* Seq.orig.Off-line */    INPUT 0, 
                                                     OUTPUT p-literal-lcm,
                                                     OUTPUT p-ult-sequencia-lcm,
                                                     OUTPUT p-registro-lcm).
                            DELETE PROCEDURE h_b1crap00.
                            
                            IF  RETURN-VALUE = "NOK" THEN
                                RETURN "NOK".

                            FIND craphis WHERE 
                                 craphis.cdcooper = crapcop.cdcooper AND
                                 craphis.cdhistor = aux_cdhistor     
                                 NO-LOCK NO-ERROR.
                
                            IF   NOT AVAILABLE craphis   THEN
                                 DO:
                                    ASSIGN i-cod-erro  = 526
                                           c-desc-erro = "". 
                                    RUN cria-erro (INPUT p-cooper,
                                                   INPUT p-cod-agencia,
                                                   INPUT p-nro-caixa,
                                                   INPUT i-cod-erro,
                                                   INPUT c-desc-erro,
                                                   INPUT YES).
                                    RETURN "NOK".
                                 END.

                            /* Verifico se ja existe registro com mesmo nrdocmto, caso sim
                               busco novo sequencial. */
                            FIND craplcm WHERE 
                                     craplcm.cdcooper = crapcop.cdcooper AND
                                     craplcm.dtmvtolt = crapdat.dtmvtocd AND
                                     craplcm.cdagenci = p-cod-agencia    AND
                                     craplcm.cdbccxlt = 11               AND
                                     craplcm.nrdolote = i-nro-lote-lcm   AND
                                     craplcm.nrdctabb = p-nro-conta-rm   AND
                                     craplcm.nrdocmto = i-nro-docto
                                     NO-LOCK NO-ERROR.
                
                            IF AVAIL craplcm THEN DO:

                               ASSIGN in99 = 0.
                               IF p-tipo-doc = 1 OR p-tipo-doc = 2 THEN
                                  DO:
                                   /* Busca a proxima sequencia do campo CRAPMAT.NRSEQDOC */
                                	RUN STORED-PROCEDURE pc_sequence_progress
                                	aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPMAT"
                                										,INPUT "NRSEQDOC"
                                										,INPUT STRING(crapcop.cdcooper)
                                										,INPUT "N"
                                										,"").
                                	
                                	CLOSE STORED-PROC pc_sequence_progress
                                	aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                                			  
                                	ASSIGN aux_nrseqdoc = INTE(pc_sequence_progress.pr_sequence)
                                						  WHEN pc_sequence_progress.pr_sequence <> ?.
                                  END.
                               ELSE
                                  DO:
                                   /* Busca a proxima sequencia do campo CRAPMAT.NRSEQTED */
                                	RUN STORED-PROCEDURE pc_sequence_progress
                                	aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPMAT"
                                										,INPUT "NRSEQTED"
                                										,INPUT STRING(crapcop.cdcooper)
                                										,INPUT "N"
                                										,"").
                                	
                                	CLOSE STORED-PROC pc_sequence_progress
                                	aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                                			  
                                	ASSIGN aux_nrseqted = INTE(pc_sequence_progress.pr_sequence)
                                						  WHEN pc_sequence_progress.pr_sequence <> ?.
                                  END.
                            END.

                            DO aux_contador = 1 TO 10:

                                FIND craplcm WHERE 
                                     craplcm.cdcooper = crapcop.cdcooper AND
                                     craplcm.dtmvtolt = crapdat.dtmvtocd AND
                                     craplcm.cdagenci = p-cod-agencia    AND
                                     craplcm.cdbccxlt = 11               AND
                                     craplcm.nrdolote = i-nro-lote-lcm   AND
                                     craplcm.nrdctabb = p-nro-conta-rm   AND
                                     craplcm.nrdocmto = i-nro-docto
                                     NO-LOCK NO-ERROR.
                
                               IF   NOT AVAILABLE craplcm   THEN
                                    DO:
                                       ASSIGN aux_hrtransa = TIME.

                                       CREATE craplcm.
                                       ASSIGN craplcm.cdcooper = crapcop.cdcooper
                                              craplcm.dtmvtolt = crapdat.dtmvtocd
                                              craplcm.hrtransa = aux_hrtransa
                                              craplcm.cdagenci = p-cod-agencia
                                              craplcm.cdbccxlt = 11
                                              craplcm.nrdolote = i-nro-lote-lcm 
                                              craplcm.nrdconta = p-nro-conta-rm
                                              craplcm.nrdctabb = p-nro-conta-rm
                                              craplcm.nrdctitg = 
                                                   STRING(p-nro-conta-rm,"99999999")
                                              craplcm.nrdocmto = i-nro-docto
                                              craplcm.cdhistor = craphis.cdhistor
                                              craplcm.nrseqdig = craplot.nrseqdig 
                                                                 + 1
                                              craplcm.vllanmto = aux_vllanmto
                                              craplcm.vldoipmf = 0
                                              craplcm.nrautdoc = 
                                                              p-ult-sequencia-lcm
                                              craplcm.cdpesqbb = "CRAP020"
                                               
                                          /* ATUALIZAR LOTE */
                                          craplot.nrseqdig  = craplot.nrseqdig + 1 
                                          craplot.qtcompln  = craplot.qtcompln + 1
                                          craplot.qtinfoln  = craplot.qtinfoln + 1
                                          craplot.vlcompdb  = craplot.vlcompdb + 
                                                              aux_vllanmto
                                          craplot.vlinfodb  = craplot.vlinfodb + 
                                                              aux_vllanmto.                                                                           
                                          VALIDATE craplcm.
                                    END.
                                ELSE
                                     DO: 
                                        IF  aux_contador = 10  THEN
                                        DO:
                                            ASSIGN i-cod-erro  = 0
                                                   c-desc-erro = 
                                                    "ERRO!!! LANCAMENTO DUPLICADO,"
                                                        + "TENTE NOVAMENTE".
                                            
                                            RUN cria-erro (INPUT p-cooper,
                                                           INPUT p-cod-agencia,
                                                           INPUT p-nro-caixa,
                                                           INPUT i-cod-erro,
                                                           INPUT c-desc-erro,
                                                           INPUT YES).
                                            RETURN "NOK".
                                        END.

                                        IF  p-tipo-doc  = 1   OR p-tipo-doc  = 2   THEN  /* DOC */
                                            DO:
                                                ASSIGN i-nro-docto = aux_nrseqdoc.
                                            END.
                                        ELSE /* 3 ou 4 - TED*/
                                            DO:
                                                ASSIGN i-nro-docto = aux_nrseqted.
                                            END.

		                                NEXT.

                                     END.

                                LEAVE.

                            END.
                         END.

                    IF tar_vllanmto <> 0 THEN
                    DO:
					    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 

                        /* Efetuar a chamada a rotina Oracle */
                        RUN STORED-PROCEDURE pc_verifica_tarifa_operacao
                        aux_handproc = PROC-HANDLE NO-ERROR (INPUT crapcop.cdcooper     /* Cooperativa */
                                                            ,INPUT p-cod-operador       /* Operador */
                                                            ,INPUT p-cod-agencia        /* PA */ 
                                                            ,INPUT 100                  /* Banco */
                                                            ,INPUT crapdat.dtmvtolt     /* Data de movimento */
                                                            ,INPUT "b1crap20"           /* Cód. programa */
                                                            ,INPUT 2                    /* Id. Origem*/
                                                            ,INPUT p-nro-conta-rm       /* Nr. da conta */
                                                            ,INPUT IF p-tipo-doc = 1 OR p-tipo-doc = 2 THEN 10 ELSE 11 /* Tipo de tarifa DOC = 14/TED = 15 */
                                                            ,INPUT 0                    /* Tipo TAA */
                                                            ,INPUT 1                    /* Quantidade de operacoes */
                                                            ,OUTPUT 0                   /* Quantidade de operações a serem cobradas */
                                                            ,OUTPUT 0                   /* Indicador de isencao de tarifa (0 - nao isenta, 1 - isenta) */
                                                            ,OUTPUT 0    /* Código da crítica */
                                                            ,OUTPUT "").  /* Descrição da crítica */
                          
                        /* Fechar o procedimento para buscarmos o resultado */ 
                        CLOSE STORED-PROC pc_verifica_tarifa_operacao
                              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
                          
                        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

                        ASSIGN aux_qtacobra = 0
                               aux_fliseope = 0
                               aux_cdcritic = 0
                               aux_dscritic = ""
                               aux_qtacobra = pc_verifica_tarifa_operacao.pr_qtacobra
                                              WHEN pc_verifica_tarifa_operacao.pr_qtacobra <> ?
                               aux_fliseope = pc_verifica_tarifa_operacao.pr_fliseope
                                              WHEN pc_verifica_tarifa_operacao.pr_fliseope <> ?
                               aux_cdcritic = pc_verifica_tarifa_operacao.pr_cdcritic
                                              WHEN pc_verifica_tarifa_operacao.pr_cdcritic <> ?
                               aux_dscritic = pc_verifica_tarifa_operacao.pr_dscritic
                                              WHEN pc_verifica_tarifa_operacao.pr_dscritic <> ?.

                        IF  aux_cdcritic > 0 OR aux_dscritic <> "" THEN
                            DO:                               
                                RUN cria-erro (INPUT p-cooper,
                                               INPUT p-cod-agencia,
                                               INPUT p-nro-caixa,
                                               INPUT aux_cdcritic,
                                               INPUT aux_dscritic,
                                               INPUT YES).
                                RETURN "NOK".
                            END.

                        FIND crabhis WHERE crabhis.cdcooper = crapcop.cdcooper AND
                                           crabhis.cdhistor = tar_cdhistor     
                                           NO-LOCK NO-ERROR.
    
                        IF   NOT AVAILABLE crabhis   THEN
                             DO:
                                 ASSIGN i-cod-erro  = 526
                                        c-desc-erro = "". 
    
                                 RUN cria-erro(INPUT p-cooper,
                                               INPUT p-cod-agencia,
                                               INPUT p-nro-caixa,
                                               INPUT i-cod-erro,
                                               INPUT c-desc-erro,
                                               INPUT YES).
                                 RETURN "NOK".
                             END.
    
                        IF  aux_fliseope <> 1 THEN
                            DO:
                        IF NOT VALID-HANDLE(h-b1wgen0153) THEN
                            RUN sistema/generico/procedures/b1wgen0153.p PERSISTENT SET h-b1wgen0153.

                        RUN lan-tarifa-online IN h-b1wgen0153
                                   (INPUT crapcop.cdcooper,
                                    INPUT 1,
                                    INPUT p-nro-conta-rm,            
                                    INPUT 100,             /* cdbccxlt */         
                                    INPUT 7999,            /* nrdolote */        
                                    INPUT i-tipo-lote,     /* tpdolote */         
                                    INPUT p-cod-operador,
                                    INPUT crapdat.dtmvtolt,
                                    INPUT crapdat.dtmvtocd,
                                    INPUT p-nro-conta-rm,
                                    INPUT STRING(p-nro-conta-rm,"99999999"),
                                    INPUT tar_cdhistor,
                                    INPUT "CRAP020",  
                                    INPUT 0,     /* cdbanchq */
                                    INPUT 0,     /* cdagechq */
                                    INPUT 0,     /* nrctachq */
                                    INPUT FALSE, /* flgaviso */
                                    INPUT 0,     /* tpdaviso */
                                    INPUT tar_vllanmto,
                                    INPUT i-nro-docto,     /* nrdocmto */
                                    INPUT crapcop.cdcooper,
                                    INPUT crapass.cdagenci,
                                    INPUT 0, /* aux_nrterfin */
                                    INPUT 0,
                                    INPUT p-ult-sequencia-lcm,
                                    INPUT "",
                                    INPUT aux_cdfvlcop,
                                    INPUT crapdat.inproces,
                                   OUTPUT p-cdlantar,
                                   OUTPUT TABLE tt-erro).

                        IF  VALID-HANDLE(h-b1wgen0153) THEN
                                DELETE PROCEDURE h-b1wgen0153.
                                      
                        IF  RETURN-VALUE = "NOK"  THEN
                        DO:
                            FIND FIRST tt-erro NO-LOCK NO-ERROR.
        
                            IF AVAIL tt-erro THEN
                                ASSIGN i-cod-erro  = 0
                                       c-desc-erro = tt-erro.dscritic.
                            ELSE
                                ASSIGN i-cod-erro  = 0
                                       c-desc-erro = "Nao foi possivel " +
                                                     "lancar a tarifa.".
    
                             RUN cria-erro (INPUT p-cooper,
                                            INPUT p-cod-agencia,
                                            INPUT p-nro-caixa,
                                            INPUT i-cod-erro,
                                            INPUT c-desc-erro,
                                            INPUT YES).
                             RETURN "NOK".
                        END.
							END.	
                        
                    END.

                 END.
         END.
   
   
    /* GERAÇAO DE LOG atualiza-doc-ted */    
    IF  p-tipo-doc = 3 OR p-tipo-doc = 4  THEN
        ASSIGN aux_indopera = 3.
    ELSE
        ASSIGN aux_indopera = 2.
        
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    
    RUN STORED-PROCEDURE pc_gera_log_ope_cartao
        aux_handproc = PROC-HANDLE NO-ERROR
                                (INPUT crapcop.cdcooper, /* Código da Cooperativa */
                                 INPUT p-nro-conta-rm,   /* Numero da Conta */ 
                                 INPUT aux_indopera,
                                 INPUT 2,                /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA */ 
                                 INPUT p-idtipcar, 
                                 INPUT i-nro-docto,        /* Nrd Documento */               
                                 INPUT aux_cdhistor,
                                 INPUT STRING(p-nrcartao),
                                 INPUT aux_vllanmto,
                                 INPUT p-cod-operador,   /* Código do Operador */
                                 INPUT p-cod-banco,
                                 INPUT p-cod-finalidade,
                                 INPUT p-cod-agencia,
                                 INPUT 0,
                                 INPUT "",
                                 INPUT 0,
                                OUTPUT "").              /* Descrição da crítica */

    /* Código da crítica */    
    CLOSE STORED-PROC pc_gera_log_ope_cartao
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""           
           aux_dscritic = pc_gera_log_ope_cartao.pr_dscritic
                          WHEN pc_gera_log_ope_cartao.pr_dscritic <> ?.
                          
    IF (aux_dscritic <> "" AND aux_dscritic <> ?) THEN
      DO:                 
         RUN cria-erro (INPUT p-cooper,
                        INPUT p-cod-agencia,
                        INPUT p-nro-caixa,
                        INPUT aux_cdcritic,
                        INPUT aux_dscritic,
                        INPUT YES).

         RETURN "NOK".            
      END.
   
    /*--- Atualiza numero autenticacao */
    ASSIGN  craptvl.nrautdoc = p-ult-sequencia.
                         
    /*---- Gera literal autenticacao - RECEBIMENTO(Rolo) ----*/
    ASSIGN c-tipo-docto = " ".
    
    CASE p-tipo-doc:
        WHEN 1 THEN ASSIGN c-tipo-docto = "DOC C".
        WHEN 2 THEN ASSIGN c-tipo-docto = "DOC D".
        WHEN 3 THEN ASSIGN c-tipo-docto = "TED C".
        WHEN 4 THEN ASSIGN c-tipo-docto = "TED D".
    END.

    ASSIGN c-desc-agencia = " ".
    FIND crapagb WHERE crapagb.cdageban = p-cod-agencia-banco   AND
                       crapagb.cddbanco = p-cod-banco       
                       NO-LOCK NO-ERROR.
    
    IF AVAIL crapagb  THEN
       ASSIGN c-desc-agencia = crapagb.nmageban.
    
    ASSIGN c-desc-banco  = " "
           c-desc-banco2 = " ".
           
    IF p-cod-banco > 0 THEN
       FIND crapban WHERE crapban.cdbccxlt = p-cod-banco   NO-LOCK NO-ERROR.
    ELSE
       FIND crapban WHERE crapban.nrispbif = p-ispb-if     NO-LOCK NO-ERROR.
   
    IF  AVAIL crapban THEN 
        ASSIGN c-desc-banco = crapban.nmresbcc. 
                 
    FIND crapage WHERE  crapage.cdcooper = crapcop.cdcooper AND
                        crapage.cdagenci = p-cod-agencia 
                        NO-LOCK NO-ERROR.

    IF  p-tipo-doc = 3 OR p-tipo-doc = 4  THEN    
        DO:
            /** TED **/
            IF   aux_flgopspb   THEN
                 DO:
                    FIND crapban WHERE crapban.cdbccxlt = crapcop.cdbcoctl 
                                       NO-LOCK NO-ERROR.

                    FIND crapagb WHERE crapagb.cdageban = crapcop.cdagectl AND
                                       crapagb.cddbanco = crapban.cdbccxlt
                                       NO-LOCK NO-ERROR.                 
                 END.
            ELSE
                 DO:
                    FIND crapban WHERE crapban.cdbccxlt = 1 /*Banco do Brasil*/
                                       NO-LOCK NO-ERROR.
           
                    FIND crapagb WHERE  crapagb.cdageban = crapcop.cdageitg AND
                                        crapagb.cddbanco = crapban.cdbccxlt
                                        NO-LOCK NO-ERROR.
                 END.
        END.
    ELSE      /** DOC **/
        DO:   
            /* IF CECRED */
            IF   crapage.cdbandoc = 85   THEN
                 DO:
                    FIND crapban WHERE  crapban.cdbccxlt = crapage.cdbandoc 
                                        NO-LOCK NO-ERROR.
             
                    FIND crapagb WHERE  
                         crapagb.cdageban = 
                                  INT(SUBSTR(STRING(crapage.cdagedoc),1,3)) AND
                         crapagb.cddbanco = crapage.cdbandoc
                         NO-LOCK NO-ERROR.               
                 END.
            ELSE
                 DO:
                    FIND crapban WHERE  crapban.cdbccxlt = crapage.cdbandoc 
                                        NO-LOCK NO-ERROR.
             
                    FIND crapagb WHERE  
                         crapagb.cdageban = 
                                  INT(SUBSTR(STRING(crapage.cdagedoc),1,4)) AND
                         crapagb.cddbanco = crapage.cdbandoc
                         NO-LOCK NO-ERROR.
                 END.
        END. 
    
    IF  AVAIL crapban THEN 
        ASSIGN c-desc-banco2 =  STRING(crapban.cdbccxlt) + " - "  +
                                crapban.nmresbcc.
    
    IF  AVAIL crapagb THEN
        ASSIGN aux_dsagenci = STRING(crapagb.cdageban)  +  " - "  + 
                              crapagb.nmageban.
    
    ASSIGN c-desc-conta-db = " "
           c-desc-conta-cr = " ".
           
    IF  p-tipo-doc = 2 THEN  /* DOC D */      /* Critica Conta Debitada */
        FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
                           craptab.nmsistem = "CRED"            AND
                           craptab.tptabela = "GENERI"          AND
                           craptab.cdempres = 00                AND
                           craptab.cdacesso = "TPCTADBTRF"      AND
                           craptab.tpregist = p-tipo-conta-db   
                           NO-LOCK NO-ERROR.
    ELSE
        FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
                           craptab.nmsistem = "CRED"            AND
                           craptab.tptabela = "GENERI"          AND
                           craptab.cdempres = 00                AND
                           craptab.cdacesso = "TPCTADBTED"      AND
                           craptab.tpregist = p-tipo-conta-db   
                           NO-LOCK NO-ERROR.
                           
    IF  AVAIL craptab THEN
        ASSIGN c-desc-conta-db = 
               STRING(p-tipo-conta-db,"zzz") + " - " + craptab.dstextab.
    ELSE 
        ASSIGN c-desc-conta-db = STRING(p-tipo-conta-db,"zzz") + " - ".

    IF  p-tipo-doc = 2   THEN  /* DOC D */    /* Critica Conta Creditada */
        FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
                           craptab.nmsistem = "CRED"            AND
                           craptab.tptabela = "GENERI"          AND
                           craptab.cdempres = 00                AND
                           craptab.cdacesso = "TPCTACRTRF"      AND
                           craptab.tpregist = p-tipo-conta-cr 
                           NO-LOCK NO-ERROR.
    ELSE
        FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
                           craptab.nmsistem = "CRED"            AND
                           craptab.tptabela = "GENERI"          AND
                           craptab.cdempres = 00                AND
                           craptab.cdacesso = "TPCTACRTED"      AND
                           craptab.tpregist = p-tipo-conta-cr   
                           NO-LOCK NO-ERROR.
             
    IF  AVAIL craptab THEN
        ASSIGN c-desc-conta-cr = 
               STRING(p-tipo-conta-cr,"zzz") + " - " + craptab.dstextab. 
    ELSE
        ASSIGN c-desc-conta-cr = STRING(p-tipo-conta-cr,"zzz") + " - ".   

    ASSIGN c-nome-titular1 = p-nome-de
           c-nome-titular2 = p-nome-de1.

    IF  p-tipo-doc = 1 OR p-tipo-doc = 2 THEN
        FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
                           craptab.nmsistem = "CRED"            AND
                           craptab.tptabela = "GENERI"          AND
                           craptab.cdempres = 00                AND
                           craptab.cdacesso = "FINTRFDOCS"      AND
                           craptab.tpregist = p-cod-finalidade  
                           NO-LOCK NO-ERROR.
    ELSE
        FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
                           craptab.nmsistem = "CRED"            AND
                           craptab.tptabela = "GENERI"          AND
                           craptab.cdempres = 00                AND
                           craptab.cdacesso = "FINTRFTEDS"      AND
                           craptab.tpregist = p-cod-finalidade  
                           NO-LOCK NO-ERROR.

          
    IF  AVAIL craptab  THEN
        ASSIGN c-desc-finalidade = 
               STRING(p-cod-finalidade,"zzzzz") + " - " + craptab.dstextab. 
    ELSE
        ASSIGN c-desc-finalidade = STRING(p-cod-finalidade,"zzzzz") + " - ".
   
    IF  p-tipo-pessoa-de  = 1 THEN 
        DO:
            ASSIGN c-cgc-de-1 = STRING(craptvl.cpfcgemi,"99999999999")
                   c-cgc-de-1 = STRING(c-cgc-de-1,"999.999.999-99").

            IF  craptvl.cpfsgemi <> 0 THEN
                ASSIGN c-cgc-de-2 = STRING(craptvl.cpfsgemi,"99999999999")
                       c-cgc-de-2 = STRING(c-cgc-de-2,"999.999.999-99").
        END.
    ELSE 
        DO:
            ASSIGN c-cgc-de-1 = STRING(craptvl.cpfcgemi,"99999999999999")
                   c-cgc-de-1 = STRING(c-cgc-de-1,"99.999.999/9999-99").
            IF  craptvl.cpfsgemi <> 0 THEN
                ASSIGN c-cgc-de-2 = STRING(craptvl.cpfsgemi,"99999999999999")
                       c-cgc-de-2 = STRING(c-cgc-de-2,"99.999.999/9999-99").
        END.

    IF  p-tipo-pessoa-para  = 1  THEN  
        DO:
            ASSIGN c-cgc-para-1 = STRING(craptvl.cpfcgrcb,"99999999999")
                   c-cgc-para-1 = STRING(c-cgc-para-1,"999.999.999-99")
                   c-cgc-para-2 = STRING(craptvl.cpstlrcb,"99999999999")
                   c-cgc-para-2 = STRING(c-cgc-para-2,"999.999.999-99").
        END.            
    ELSE 
        DO:    
            ASSIGN c-cgc-para-1 = STRING(craptvl.cpfcgrcb,"99999999999999")
                   c-cgc-para-1 = STRING(c-cgc-para-1,"99.999.999/9999-99")
                   c-cgc-para-2 = STRING(craptvl.cpstlrcb,"99999999999999")
                   c-cgc-para-2 = STRING(c-cgc-para-2,"99.999.999/9999-99").
        END.    

    IF  craptvl.cpstlrcb = 0 THEN
        ASSIGN c-cgc-para-2 = " ".

    /* Impressao */
    ASSIGN c-tipo-pessoa-de = " ".
    IF  p-tipo-pessoa-de = 1  THEN
        ASSIGN c-tipo-pessoa-de = "Fisica".
    ELSE
        ASSIGN c-tipo-pessoa-de = "Juridica".

    ASSIGN c-tipo-pessoa-para = " ".
    IF  p-tipo-pessoa-para = 1  THEN
        ASSIGN c-tipo-pessoa-para = "Fisica".
    ELSE
        ASSIGN c-tipo-pessoa-para = "Juridica".

    IF   tar_vllanmto <> 0   THEN
         DO:
            /* Pegar valor por extenso */
            RUN fontes/extenso.p (INPUT tar_vllanmto, 
                                  INPUT 17, 
                                  INPUT 44, 
                                  INPUT "M",
                                  OUTPUT aux_linha1,
                                  OUTPUT aux_linha2).
         END.

    ASSIGN c-literal  = "". /* Limpa o conteudo do vetor */

    ASSIGN iLnAut = 1   
           c-literal[iLnAut] = TRIM(crapcop.nmrescop) +  " - " +
                               TRIM(crapcop.nmextcop) 
           iLnAut = iLnAut + 1
           c-literal[iLnAut] = ""
           iLnAut = iLnAut + 1
           c-literal[iLnAut] = STRING(crapdat.dtmvtocd,"99/99/99") + " " + 
                               STRING(TIME,"HH:MM:SS") 
                               +  " PA  " + 
                               STRING(p-cod-agencia,"999") +
                               "  CAIXA: " +
                               STRING(p-nro-caixa,"Z99") + "/" +
                               SUBSTR(p-cod-operador,1,10)
           iLnAut = iLnAut + 1 
           c-literal[iLnAut] = ""
           iLnAut = iLnAut + 1 
           c-literal[iLnAut] = "      ** COMPROVANTE  " +
                               SUBSTR(c-tipo-docto,1,3) + " " +
                               STRING(p-nro-docmto,"zzz,zz9") + " **".
    
    IF c-tipo-docto = "TED D" THEN 
        DO:
           ASSIGN iLnAut = iLnAut + 1 
                       c-literal[iLnAut]   = "         (Mesma Titularidade)".
        END.
    ELSE
        IF c-tipo-docto = "TED C" THEN
           ASSIGN iLnAut = iLnAut + 1 
                       c-literal[iLnAut]  = "       (Titularidades diferentes)".
    
    IF craptvl.cdbccrcb > 0  THEN
        ASSIGN aux_cddBanco =  TRIM(STRING(craptvl.cdbccrcb,"z999")).
               
    ELSE
        ASSIGN aux_cddBanco = "   ".
    
    ASSIGN aux_nmdBanco = " - " + c-desc-banco.
       
    ASSIGN iLnAut = iLnAut + 1  c-literal[iLnAut] = ""
           iLnAut = iLnAut + 1  c-literal[iLnAut] = "REMETENTE: "
           iLnAut = iLnAut + 1  c-literal[iLnAut] = ""

           iLnAut = iLnAut + 1  c-literal[iLnAut] = "BANCO...: " + c-desc-banco2
           iLnAut = iLnAut + 1  c-literal[iLnAut] = "AGENCIA.: " + aux_dsagenci
           
           iLnAut = iLnAut + 1  c-literal[iLnAut] = ""
           iLnAut = iLnAut + 1  c-literal[iLnAut] = "CONTA...: " + 
                                TRIM(STRING(craptvl.nrdconta,"ZZZZ,ZZ9,9")) 
                                + " TIPO DE PESSOA: " +
                                TRIM(c-tipo-pessoa-de)
           iLnAut = iLnAut + 1  c-literal[iLnaut] = "PA......: " +
                                TRIM(aux_cdagenci) 
           iLnAut = iLnAut + 1  c-literal[iLnAut] = "TITULAR1: " +
                                                    TRIM(craptvl.nmpesemi) 
           iLnAut = iLnAut + 1  c-literal[iLnAut] = "TITULAR2: " +  
                                                    TRIM(craptvl.nmsegemi) 
           iLnAut = iLnAut + 1  c-literal[iLnAut] = "CPF/CNPJ TITULAR1: " +
                                                    c-cgc-de-1
           iLnAut = iLnAut + 1  c-literal[iLnAut] = "         TITULAR2: " + 
                                                    c-cgc-de-2
           iLnAut = iLnAut + 1  c-literal[iLnAut] = ""
           iLnAut = iLnAut + 1  c-literal[iLnAut] = "DESTINATARIO:"  
           iLnAut = iLnAut + 1  c-literal[iLnAut] = "" 
           iLnAut = iLnAut + 1  c-literal[iLnAut] = "BANCO...: " + 
                                aux_cddBanco + TRIM(aux_nmdBanco)
           iLnAut = iLnAut + 1  c-literal[iLnAut] = "ISPB....: " + 
                                TRIM(STRING(craptvl.nrispbif,"99999999")) 
           iLnAut = iLnAut + 1  c-literal[iLnAut] = "AGENCIA.: " +
                                TRIM(STRING(craptvl.cdagercb,"z999")) + " - " +                                  
                                TRIM(c-desc-agencia)              
           iLnAut = iLnAut + 1  c-literal[iLnAut] = ""       
           iLnAut = iLnAut + 1  c-literal[iLnAut] = "CONTA...: " + 
                                TRIM(STRING(craptvl.nrcctrcb,"ZZZZZZZZZZZZZZZZZZZ9"))  
                                + " TIPO DE PESSOA: " + 
                                TRIM(c-tipo-pessoa-para)
           iLnAut = iLnAut + 1  c-literal[iLnAut] = "TITULAR1: " + 
                                TRIM(craptvl.nmpesrcb) 
           iLnAut = iLnAut + 1  c-literal[iLnAut] = "TITULAR2: " + 
                                TRIM(CAPS(p-nome-para1))
           iLnAut = iLnAut + 1  c-literal[iLnAut] = "CPF/CNPJ: " + 
                                "TITULAR1: " +  c-cgc-para-1  
           iLnAut = iLnAut + 1  c-literal[iLnAut] = "          " + 
                                "TITULAR2: " +  c-cgc-para-2  
           iLnAut = iLnAut + 1  c-literal[iLnAut] = ""
           iLnAut = iLnAut + 1  c-literal[iLnAut] = "FINALIDADE: " + 
                                SUBSTR(c-desc-finalidade,1,38)
           iLnAut = iLnAut + 1  c-literal[iLnAut] = "TP.CC.DEB.: " +
                                SUBSTR(c-desc-conta-db,1,38)
           iLnAut = iLnAut + 1  c-literal[iLnAut] = "TP.CC.CRD.: " +
                                SUBSTR(c-desc-conta-cr,1,38)
           iLnAut = iLnAut + 1  c-literal[iLnAut] = "". 

    IF   p-nro-conta-rm = 0 OR p-tipo-pag = "E"  THEN
         ASSIGN iLnAut = iLnAut + 1  c-literal[iLnAut] = "Valor...: " +
                         STRING(craptvl.vldocrcb,"ZZZ,ZZZ,ZZ9.99")
                iLnAut = iLnAut + 1  c-literal[iLnAut] = "".                       
    
    ASSIGN iLnAut = iLnAut + 1  c-literal[iLnAut] =
                    "A COOPERATIVA  NAO SERA  RESPONSAVEL PELA DEMORA"
           iLnAut = iLnAut + 1  c-literal[iLnAut] =
                    "OU NAO CUMPRIMENTO DA TRANSFERENCIA POR ERRO DE "
           iLnAut = iLnAut + 1  c-literal[iLnAut] =
                    "PREENCHIMENTO E/OU INFORMACOES INCORRETAS."
        
           iLnAut = iLnAut + 1  c-literal[iLnAut] = ""
           iLnAut = iLnAut + 1  c-literal[iLnAut] = p-literal
           iLnAut = iLnAut + 1  c-literal[iLnAut] = "".
      
    IF   p-nro-conta-rm <> 0 AND aux_vllanmto <> 0   THEN
         DO:
            IF  (p-tipo-doc = 1 AND p-tipo-pag = 'D') OR /* DOC C debito */
                 p-tipo-doc = 2           OR             /* DOC D */    
                (p-tipo-doc = 3 AND p-tipo-pag = 'D') OR /* TED C debito */
                 p-tipo-doc = 4           THEN           /* TED D */   
                 DO: 
                    ASSIGN iLnAut = iLnAut + 1  c-literal[iLnAut] =
                             "   TIPO DE DEBITO                   VALOR EM R$ "
                           iLnAut = iLnAut + 1  c-literal[iLnAut] = FILL('-',48)
                           iLnAut = iLnAut + 1  c-literal[iLnAut] = "    " + 
                                STRING(SUBSTR(craphis.dshistor,1,29),"x(29)") +
                                       STRING(aux_vllanmto,"ZZZ,ZZZ,ZZ9.99")
                           iLnAut = iLnAut + 1  c-literal[iLnAut] = " ".

                         /* (DOC D e debito) ou (TED D e debito) */
                    IF   (p-tipo-doc = 2   AND  p-tipo-pag = 'D')    OR 
                         (p-tipo-doc = 4   AND  p-tipo-pag = 'D')    THEN
                         ASSIGN iLnAut = iLnAut + 1  c-literal[iLnAut] =
                             "AUTORIZO A COOPERATIVA A DEBITAR EM MINHA CONTA "
                           
                                iLnAut = iLnAut + 1  c-literal[iLnAut] =
                             "E AO/A BANCO/COOPERATIVA DE DESTINO CREDITAR EM "
                           
                                iLnAut = iLnAut + 1  c-literal[iLnAut] = 
                             "MINHA CONTA O VALOR ACIMA, ACRESCIDO DA TARIFA  "
                        
                                iLnAut = iLnAut + 1  c-literal[iLnAut] =
                             "DE PRESTACAO DESTE SERVICO.". 

                    ELSE  /* (DOC C e Debito) ou (TED C e Debito) */
                    IF   (p-tipo-doc = 1   AND  p-tipo-pag = 'D')    OR     
                         (p-tipo-doc = 3   AND  p-tipo-pag = 'D')    THEN 
                         ASSIGN iLnAut = iLnAut + 1  c-literal[iLnAut] =
                             "AUTORIZO A COOPERATIVA A DEBITAR EM MINHA CONTA "
                           
                                iLnAut = iLnAut + 1  c-literal[iLnAut] =
                             "E AO/A BANCO/COOPERATIVA DE DESTINO CREDITAR    "
                           
                                iLnAut = iLnAut + 1  c-literal[iLnAut] = 
                             "CONFORME DADOS INFORMADOS ACIMA, ACRESCIDO DA   "
                        
                                iLnAut = iLnAut + 1  c-literal[iLnAut] =
                             "TARIFA DE PRESTACAO DESTE SERVICO.".  

                    ASSIGN iLnAut = iLnAut + 1  c-literal[iLnAut] = ""                        
                           iLnAut = iLnAut + 1  c-literal[iLnAut] = ""
                           iLnAut = iLnAut + 1  c-literal[iLnAut] = 
                                                    p-literal-lcm. 
                 END.
            ELSE   /* Valor da tarifa  */                                
                 ASSIGN iLnAut = iLnAut + 1  c-literal[iLnAut] =
                          "AUTORIZO A COOPERATIVA A DEBITAR EM MINHA CONTA "
                        iLnAut = iLnAut + 1  c-literal[iLnAut] =
                          "ACIMA, O VALOR DE R$ " + STRING(tar_vllanmto,"ZZ9.99") + 
                            " ( " + STRING(aux_linha1, "x(17)")  
                        iLnAut = iLnAut + 1  c-literal[iLnAut] =
                          STRING(aux_linha2, "x(44)") + " )"
                        iLnAut = iLnAut + 1  c-literal[iLnAut] = 
                          "REFERENTE A PAGAMENTO DE TARIFA."
                        iLnAut = iLnAut + 1  c-literal[iLnAut] = "".              
         END.
 
    ASSIGN iLnAut = iLnAut + 1  c-literal[iLnAut] = ""
           iLnAut = iLnAut + 1  c-literal[iLnAut] = ""
           iLnAut = iLnAut + 1  c-literal[iLnAut] = ""
           iLnAut = iLnAut + 1  c-literal[iLnAut] =
                    "------------------------------------------------"
           iLnAut = iLnAut + 1  c-literal[iLnAut] =
                    "         ASSINATURA DO REMETENTE                "
           iLnAut = iLnAut + 1  c-literal[iLnAut] = ""
           iLnAut = iLnAut + 1  c-literal[iLnAut] = ""
           iLnAut = iLnAut + 1  c-literal[iLnAut] = ""
           iLnAut = iLnAut + 1  c-literal[iLnAut] = ""
           iLnAut = iLnAut + 1  c-literal[iLnAut] = ""
           iLnAut = iLnAut + 1  c-literal[iLnAut] = ""
           iLnAut = iLnAut + 1  c-literal[iLnAut] = ""
           iLnAut = iLnAut + 1  c-literal[iLnAut] = ""
           iLnAut = iLnAut + 1  c-literal[iLnAut] = "".

    ASSIGN p-literal-autentica = "".
    DO iContLn = 1 TO iLnAut:
        ASSIGN p-literal-autentica = p-literal-autentica +
                                     STRING(c-literal[iContLn],"x(48)").
    END.
 
    ASSIGN p-literal-autentica = RIGHT-TRIM(p-literal-autentica)
         + FILL(' ',112)
         + STRING(centraliza("SAC - " + STRING(crapcop.nrtelsac),48),"x(48)")
         + STRING(centraliza("Atendimento todos os dias das " + REPLACE(REPLACE(STRING(crapcop.hrinisac,"HH:MM"),':','h'),'h00','h') + " as " + REPLACE(REPLACE(STRING(crapcop.hrfimsac,"HH:MM"),':','h'),'h00','h'),48),"x(48)")
         + STRING(centraliza("OUVIDORIA - " + STRING(crapcop.nrtelouv),48),"x(48)")
         + STRING(centraliza("Atendimento nos dias uteis das " + REPLACE(REPLACE(STRING(crapcop.hriniouv,"HH:MM"),':','h'),'h00','h') + " as " + REPLACE(REPLACE(STRING(crapcop.hrfimouv,"HH:MM"),':','h'),'h00','h'),48),"x(48)")
         + FILL(' ',480).

    ASSIGN c-texto-2-via = p-literal-autentica.
                     
    IF  p-opcao    = "R"  AND 
        p-dsimpvia = "S"  THEN       
    ASSIGN p-literal-autentica = p-literal-autentica + c-texto-2-via.

    ASSIGN p-ult-seq-autentica = p-ult-sequencia.
   
    /* Autenticacao REC */
    ASSIGN in99 = 0. 
    DO  WHILE TRUE:
        
        ASSIGN in99 = in99 + 1.
        FIND crapaut WHERE RECID(crapaut) = p-registro 
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF  NOT AVAIL crapaut THEN  
            DO:
                IF  LOCKED crapaut  THEN 
                    DO:
                        IF  in99 < 100  THEN 
                            DO:
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                            END.
                        ELSE 
                            DO:
                                ASSIGN i-cod-erro  = 0
                                       c-desc-erro = "Tabela CRAPAUT em uso ".
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
                        ASSIGN i-cod-erro  = 0
                               c-desc-erro = 
                                    "Erro Sistema - CRAPAUT nao Encontrado ".
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
                ASSIGN  crapaut.dslitera = p-literal-autentica.
                RELEASE crapaut.
                LEAVE.
            END.
    END. /* fim do DO WHILE */

    IF   p-nro-conta-rm <> 0 AND aux_vllanmto <> 0 AND
         p-tipo-pag <> 'E'                             THEN
         DO:
            /* Autenticacao PAG */
            ASSIGN in99 = 0. 
            DO  WHILE TRUE:
             
             ASSIGN in99 = in99 + 1.
             FIND crapaut WHERE RECID(crapaut) = p-registro-lcm 
                                EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        
             IF  NOT AVAIL crapaut THEN  
                 DO:
                     IF  LOCKED crapaut  THEN 
                         DO:
                             IF  in99 < 100  THEN 
                                 DO:
                                     PAUSE 1 NO-MESSAGE.
                                     NEXT.
                                 END.
                             ELSE 
                                 DO:
                                    ASSIGN i-cod-erro  = 0
                                           c-desc-erro = "Tabela CRAPAUT em uso".
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
                             ASSIGN i-cod-erro  = 0
                                    c-desc-erro = 
                                       "Erro Sistema - CRAPAUT nao Encontrado ".
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
                     ASSIGN  crapaut.dslitera = p-literal-autentica.
                     RELEASE crapaut.
                     LEAVE.
                 END.
            END. /* fim do DO WHILE */
         END.

    /* Gera um arquivo do TED on-line - Banco do Brasil*/
    IF  (c-tipo-docto = 'TED C' OR c-tipo-docto = 'TED D') AND
         aux_flgopspb = FALSE   THEN
        DO:
            FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
                               craptab.nmsistem = "CRED"            AND
                               craptab.tptabela = "CONFIG"          AND
                               craptab.cdempres = 00                AND
                               craptab.cdacesso = "COMPELBBDC"      AND
                               craptab.tpregist = 000
                               NO-LOCK NO-ERROR.

            EMPTY TEMP-TABLE crattem.

            CREATE crattem.
            ASSIGN crattem.cdseqarq = INTEGER(SUBSTR(craptab.dstextab,29,06))
                   crattem.nrdolote = 1
                   crattem.cddbanco = 1
                   crattem.nmarquiv = "td" +
                                      STRING(craptvl.nrdocmto, "9999999") +
                                      STRING(DAY(craptvl.dtmvtolt),"99")   +
                                      STRING(MONTH(craptvl.dtmvtolt),"99") +
                                      STRING(craptvl.cdagenci, "999") +
                                      ".rem"
                   crattem.nrrectit = RECID(craptvl)
                   crattem.nrdconta = craptvl.nrdconta
                   crattem.cdagenci = craptvl.cdagenci
                   crattem.cdbantrf = craptvl.cdbccrcb
                   crattem.cdagetrf = craptvl.cdagercb
                   crattem.nrctatrf = DEC(SUBSTR(STRING(craptvl.nrcctrcb,"99999999999999999999"),1,20))
                   crattem.nrdigtrf = SUBSTR(STRING(craptvl.nrcctrcb,"99999999999999999999"), 
                                             LENGTH(STRING(craptvl.nrcctrcb,"99999999999999999999")),1)
                   crattem.nmfuncio = craptvl.nmpesrcb
                   crattem.nrcpfcgc = craptvl.cpfcgrcb
                   crattem.nrdocmto = craptvl.nrdocmto
                   crattem.vllanmto = craptvl.vldocrcb
                   crattem.dtmvtolt = craptvl.dtmvtolt
                   crattem.tppessoa = IF craptvl.flgpescr = YES THEN 1
                                      ELSE 2.

            /* Instancia a BO */
            RUN sistema/generico/procedures/b1wgen0012.p
                PERSISTENT SET h-b1wgen0012.
            
            RUN gera-arquivo-ted-doc IN h-b1wgen0012(INPUT  TABLE crattem,
                                                     INPUT  crapcop.cdcooper,
                                                     INPUT  crapdat.dtmvtocd,
                                                     OUTPUT c-desc-erro).
            DELETE PROCEDURE h-b1wgen0012.

            IF   c-desc-erro <> ""   THEN
                 DO:
                     ASSIGN i-cod-erro  = 0.

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
    /* Gera um arquivo do TED on-line - SPB */
    IF (c-tipo-docto = 'TED C' OR c-tipo-docto = 'TED D') AND aux_flgopspb  THEN
        DO:        
            RUN sistema/generico/procedures/b1wgen0046.p
                PERSISTENT SET h-b1wgen0046.

            RUN proc_envia_tec_ted IN h-b1wgen0046
                                      (INPUT crapcop.cdcooper,
                                       INPUT p-cod-agencia,
                                       INPUT p-nro-caixa,
                                       INPUT p-cod-operador,
                                       INPUT p-titular,
                                       INPUT p-val-doc,
                                       INPUT aux_nrctrlif,
                                       INPUT p-nro-conta-de,
                                       INPUT p-cod-banco,
                                       INPUT p-cod-agencia-banco,
                                       INPUT p-nro-conta-para,  
                                       INPUT p-cod-finalidade,
                                       INPUT p-tipo-conta-db,
                                       INPUT p-tipo-conta-cr,
                                       INPUT p-nome-de,
                                       INPUT p-nome-de1,
                                       INPUT DECIMAL(p-cpfcnpj-de),
                                       INPUT DECIMAL(p-cpfcnpj-de1),
                                       INPUT p-nome-para,
                                       INPUT p-nome-para1,
                                       INPUT DECIMAL(p-cpfcnpj-para),
                                       INPUT DECIMAL(p-cpfcnpj-para1),
                                       INPUT p-tipo-pessoa-de,
                                       INPUT p-tipo-pessoa-para,
                                       INPUT FALSE,/*Conta Salario*/
                                       INPUT p-cod-id-transf,
                                       INPUT 2, /* origem 2 = Caixa Online */
                                       INPUT ?,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT p-desc-hist,
                                       INPUT aux_hrtransa,
                                       INPUT p-ispb-if,
                                       OUTPUT c-desc-erro).
            
            DELETE PROCEDURE h-b1wgen0046.

            IF   c-desc-erro <> ""   THEN
                 DO: 
                    ASSIGN i-cod-erro  = 0.
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                 END.
        END.

    /* DOC E ou TED C com CPF que contenha
       mais de uma conta na cooperativa */
    IF   p-aviso-cx   THEN
         DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "CPF do remetente com mais de" +
                                 " uma C/C na cooperativa, faça" + 
                                 " o debito da tarifa em uma das" +
                                 " contas.".

            /* Atribuir uma das contas do CPF informado para a variavel de
               saida, pois o campo da rotina crap051f (Conta de origem) deve
               ficar habilitado. Esta conta sempre será de pessoa FISICA */
            FIND FIRST crapttl WHERE crapttl.cdcooper = crapcop.cdcooper  AND
                                     crapttl.nrcpfcgc = DEC(p-cpfcnpj-de)
                                     NO-LOCK NO-ERROR.

            IF   AVAILABLE crapttl    THEN
                 ASSIGN p-nro-conta-rm = crapttl.nrdconta.

            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT NO).
         END.

    RELEASE craplot.
    RELEASE craptvl.

    RETURN "OK".
END PROCEDURE.

PROCEDURE retorna-nome-banco:
    DEF INPUT PARAM p-cooper                AS CHAR         NO-UNDO.
    DEFINE INPUT  PARAMETER iBanco          AS INTEGER      NO-UNDO.
    DEFINE INPUT  PARAMETER iIspb           AS CHARACTER    NO-UNDO.
    DEFINE OUTPUT PARAMETER cNomeBanco      AS CHARACTER    NO-UNDO INITIAL ''.
    DEFINE OUTPUT PARAMETER cIspbBanco      AS CHARACTER    NO-UNDO INITIAL ''.
    DEFINE OUTPUT PARAMETER cBanco          AS CHARACTER    NO-UNDO INITIAL ''.        
    
    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR. 
    IF iBanco > 0  OR iIspb = '00000000' OR iIspb = '0' THEN
    DO:
        IF iIspb = '00000000' OR iIspb = '0' THEN
           ASSIGN iBanco = 1.
        FIND crapban WHERE crapban.cdbccxlt = iBanco    NO-LOCK NO-ERROR.
    
    END.
        
    ELSE 
    DO:
        IF iIspb <> '' THEN
           FIND crapban WHERE crapban.nrispbif = INT(iIspb)    NO-LOCK NO-ERROR.
    END.
       
   
    IF AVAILABLE crapban THEN
        ASSIGN cBanco       = STRING(crapban.cdbccxlt)
               cNomeBanco   = crapban.nmresbcc
               cIspbBanco   = STRING(crapban.nrispbif,"99999999").
              
    ELSE 
        DO:
            ASSIGN cNomeBanco   = ''
                   cIspbBanco   = iIspb
                   cBanco = ''.
            RETURN 'NOK'.
        END.
    
    RETURN 'OK'.

END PROCEDURE.

PROCEDURE retorna-nome-agencia:
    DEFINE INPUT PARAMETER p-cooper            AS CHAR         NO-UNDO. 
    DEFINE INPUT  PARAMETER iBanco          AS INTEGER      NO-UNDO.
    DEFINE INPUT  PARAMETER iAgencia        AS INTEGER      NO-UNDO.
    DEFINE OUTPUT PARAMETER cNomeAgencia    AS CHARACTER    NO-UNDO INITIAL ''.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.

    FIND crapagb WHERE crapagb.cddbanco = iBanco    AND
                       crapagb.cdageban = iAgencia  NO-LOCK NO-ERROR.

    IF AVAILABLE crapagb THEN
        ASSIGN cNomeAgencia = crapagb.nmageban.
    ELSE 
        DO:
            ASSIGN cNomeAgencia = ''.
            RETURN 'NOK'.
        END.

    RETURN 'OK'.
END PROCEDURE.


PROCEDURE verifica-operador:

    DEFINE INPUT PARAMETER p-cooper         AS CHAR     NO-UNDO.    
    DEFINE INPUT PARAMETER p-cod-agencia    AS INT      NO-UNDO.
    DEFINE INPUT PARAMETER p-nro-caixa      AS INT      NO-UNDO.
    DEFINE INPUT PARAMETER p-cod-operador   AS CHAR     NO-UNDO.  
    DEFINE INPUT PARAMETER p-senha-operador AS CHAR     NO-UNDO. 

    DEFINE INPUT  PARAMETER aux_vldocmto AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER aux_vlsddisp AS DECIMAL     NO-UNDO.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper   NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapcop   THEN
         DO:
             RUN cria-erro (INPUT p-cooper,        
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT 794,
                            INPUT "",
                            INPUT YES).
             RETURN "NOK".
         END.

    FIND crapope WHERE crapope.cdcooper = crapcop.cdcooper   AND
                       crapope.cdoperad = p-cod-operador
                       NO-LOCK NO-ERROR.
   
    IF   NOT AVAILABLE crapope   THEN
         DO:
             RUN cria-erro (INPUT p-cooper,        
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT 067,
                            INPUT "",
                            INPUT YES).
             RETURN "NOK".
         END.

/* PRJ339 - REINERT (INICIO) */         
    /* Validacao de senha do usuario no AD somente no ambiente de producao */
    IF TRIM(OS-GETENV("PKGNAME")) = "pkgprod" THEN                
         DO:
      
       { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

       /* Efetuar a chamada da rotina Oracle */ 
       RUN STORED-PROCEDURE pc_valida_senha_AD
           aux_handproc = PROC-HANDLE NO-ERROR(INPUT crapcop.cdcooper, /*Cooperativa*/
                                               INPUT p-cod-operador,   /*Operador   */
                                               INPUT p-senha-operador, /*Nr.da Senha*/
                                              OUTPUT 0,                /*Cod. critica */
                                              OUTPUT "").              /*Desc. critica*/

       /* Fechar o procedimento para buscarmos o resultado */ 
       CLOSE STORED-PROC pc_valida_senha_AD
              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

       { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

       HIDE MESSAGE NO-PAUSE.

       /* Busca possíveis erros */ 
       ASSIGN i-cod-erro  = 0
              c-desc-erro = ""
              i-cod-erro  = pc_valida_senha_AD.pr_cdcritic 
                            WHEN pc_valida_senha_AD.pr_cdcritic <> ?
              c-desc-erro = pc_valida_senha_AD.pr_dscritic 
                            WHEN pc_valida_senha_AD.pr_dscritic <> ?.
                            
      /* Apresenta a crítica */
      IF  i-cod-erro <> 0 OR c-desc-erro <> "" THEN
         DO:
             RUN cria-erro (INPUT p-cooper,        
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                             INPUT i-cod-erro,
                            INPUT "",
                            INPUT YES).
             RETURN "NOK".
         END.
    END.
/* PRJ339 - REINERT (FIM) */

    /* Nivel 2-Coordenador / 3-Gerente */
    IF   crapope.nvoperad < 2   THEN
         DO:
             RUN cria-erro (INPUT p-cooper,        
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT 824,
                            INPUT "",
                            INPUT YES).
             RETURN "NOK".
         END.

    /* Validar quando o valor do TED ultrapassar o limite de valor do operador e
       também o valor do TED tenha ultrapassado o saldo disponivel
       Solicitacao Tarefa: 38772 */
    IF  aux_vlsddisp < aux_vldocmto  AND 
        aux_vldocmto > crapope.vlpagchq THEN
    DO:
        RUN cria-erro (INPUT p-cooper,        
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa,
                       INPUT 0,
                       INPUT "Saldo disponivel inferior ao valor do docto" + 
                             " e valor docto superior ao limite liberado na" +
                             " tela OPERAD.",
                       INPUT YES).
        RETURN "NOK".
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE verifica-operador-ted:

    DEFINE INPUT PARAMETER p-cooper         AS CHAR     NO-UNDO.    
    DEFINE INPUT PARAMETER p-cod-agencia    AS INT      NO-UNDO.
    DEFINE INPUT PARAMETER p-nro-caixa      AS INT      NO-UNDO.
    DEFINE INPUT PARAMETER p-operador       AS CHAR     NO-UNDO.
    DEFINE INPUT PARAMETER p-cod-operador   AS CHAR     NO-UNDO.  
    DEFINE INPUT PARAMETER p-senha-operador AS CHAR     NO-UNDO. 

    DEFINE INPUT  PARAMETER aux_vldocmto AS DECIMAL     NO-UNDO.

    DEFINE VARIABLE aux_cdoperad            AS CHAR     NO-UNDO.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper   NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapcop   THEN
         DO:
             RUN cria-erro (INPUT p-cooper,        
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT 794,
                            INPUT "",
                            INPUT YES).
             RETURN "NOK".
         END.

    /*se foi passado codigo e senha de operador
      verificar o limite deste operador*/
    IF  TRIM(p-cod-operador) <> ""   AND
        TRIM(p-senha-operador) <> "" THEN
        ASSIGN aux_cdoperad = p-cod-operador.
    ELSE
        ASSIGN aux_cdoperad = p-operador.


    FIND crapope WHERE crapope.cdcooper = crapcop.cdcooper   AND
                       crapope.cdoperad = aux_cdoperad
                       NO-LOCK NO-ERROR.


    IF   NOT AVAILABLE crapope   THEN
         DO:
             RUN cria-erro (INPUT p-cooper,        
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT 067,
                            INPUT "",
                            INPUT YES).
             RETURN "NOK".
         END.

    IF  TRIM(p-cod-operador) <> ""   AND
        TRIM(p-senha-operador) <> "" THEN
        DO:
      /* PRJ339 - REINERT (INICIO) */         
          /* Validacao de senha do usuario no AD somente no ambiente de producao */
          IF TRIM(OS-GETENV("PKGNAME")) = "pkgprod" THEN                
            DO:
            
             { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

             /* Efetuar a chamada da rotina Oracle */ 
             RUN STORED-PROCEDURE pc_valida_senha_AD
                 aux_handproc = PROC-HANDLE NO-ERROR(INPUT crapcop.cdcooper, /*Cooperativa*/
                                                     INPUT p-cod-operador,   /*Operador   */
                                                     INPUT p-senha-operador, /*Nr.da Senha*/
                                                    OUTPUT 0,                /*Cod. critica */
                                                    OUTPUT "").              /*Desc. critica*/

             /* Fechar o procedimento para buscarmos o resultado */ 
             CLOSE STORED-PROC pc_valida_senha_AD
                    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

             { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

             HIDE MESSAGE NO-PAUSE.

             /* Busca possíveis erros */ 
             ASSIGN i-cod-erro  = 0
                    c-desc-erro = ""
                    i-cod-erro  = pc_valida_senha_AD.pr_cdcritic 
                                  WHEN pc_valida_senha_AD.pr_cdcritic <> ?
                    c-desc-erro = pc_valida_senha_AD.pr_dscritic 
                                  WHEN pc_valida_senha_AD.pr_dscritic <> ?.
                                  
            /* Apresenta a crítica */
            IF  i-cod-erro <> 0 OR c-desc-erro <> "" THEN
                DO:
                    RUN cria-erro (INPUT p-cooper,        
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT "",
                                   INPUT YES).
                    RETURN "NOK".
                END.
          END.
      /* PRJ339 - REINERT (FIM) */

        END.

    /* Validar quando o valor do TED ultrapassar o limite 
       de valor de TED do operador */
    IF  aux_vldocmto > crapope.vllimted THEN
        DO:
            RUN cria-erro (INPUT p-cooper,        
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT 0,
                           INPUT "Valor de TED maior que o limite cadastrado" +
                                 " para o operador.",
                           INPUT YES).
            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE valida-saldo:
   DEFINE INPUT PARAMETER p-cooper         AS CHAR NO-UNDO.    
   DEFINE INPUT PARAMETER p-cod-agencia    AS INTE NO-UNDO. /* Cod. Agencia  */
   DEFINE INPUT PARAMETER p-nro-caixa      AS INTE NO-UNDO. /* Numero  Caixa */
   DEFINE INPUT PARAMETER p-nro-conta-de   AS INTE NO-UNDO. /* Nro Conta De  */
   DEFINE INPUT PARAMETER p-val-doc        AS DECI NO-UNDO. /* Vlr. DOC      */
   DEFINE INPUT PARAMETER p-cod-rotina     AS INTE NO-UNDO. /* Rotina        */
   DEFINE INPUT PARAMETER p-coopdest       AS CHAR NO-UNDO. /* Coop.Dest - Rotina 22 */
   
   DEFINE OUTPUT PARAMETER p-mensagem AS CHARACTER NO-UNDO.
   DEFINE OUTPUT PARAMETER p-saldo-disponivel AS DEC NO-UNDO.

   RUN elimina-erro (INPUT p-cooper,
                     INPUT p-cod-agencia,
                     INPUT p-nro-caixa).
   
   IF   p-nro-conta-de <> 0 THEN
        DO:
           RUN dbo/b1crap56.p PERSISTENT SET h-b1crap56.

           RUN valida-saldo-conta
               IN h-b1crap56(INPUT p-cooper,
                             INPUT p-cod-agencia,
                             INPUT p-nro-caixa,
                             INPUT p-nro-conta-de,
                             INPUT p-val-doc,
                             INPUT p-cod-rotina,
                             INPUT p-coopdest,  /** Coop. destino **/
                             OUTPUT p-mensagem,
                             OUTPUT p-saldo-disponivel).

           DELETE PROCEDURE h-b1crap56.
           
           IF   p-mensagem <> ' ' THEN
                DO:
                   ASSIGN i-cod-erro  = 0
                          c-desc-erro =  "Alerta - " + p-mensagem. 
                   RUN cria-erro (INPUT p-cooper,
                                  INPUT p-cod-agencia,
                                  INPUT p-nro-caixa,
                                  INPUT i-cod-erro,
                                  INPUT c-desc-erro,
                                  INPUT YES).
                END.
        END.

    RETURN 'OK'.
END.



PROCEDURE busca-tarifa-ted:
    DEFINE INPUT PARAMETER p-cdcooper       AS INTE NO-UNDO.
    DEFINE INPUT PARAMETER p-cdagenci       AS INTE NO-UNDO.
    DEFINE INPUT PARAMETER p-nrdconta       AS INTE NO-UNDO. /* Conta  */
    DEFINE INPUT PARAMETER p-vllanmto       AS DECI NO-UNDO. /* Valor Lancamento */
    
    DEFINE OUTPUT PARAMETER p-vltarifa      AS DECI NO-UNDO.
    DEFINE OUTPUT PARAMETER p-cdhistor      AS INTE NO-UNDO.
    DEFINE OUTPUT PARAMETER p-cdhisest      AS INTE NO-UNDO.
    DEFINE OUTPUT PARAMETER p-cdfvlcop      AS INTE NO-UNDO.
    DEFINE OUTPUT PARAMETER p-dscritic      AS CHAR NO-UNDO.


    DEF VAR h-b1wgen0153 AS HANDLE                  NO-UNDO.
    
    DEF VAR aux_dssigtar AS CHAR                    NO-UNDO.
    DEF VAR aux_cdhisest AS INTE                    NO-UNDO.
    DEF VAR aux_dtdivulg AS DATE                    NO-UNDO.
    DEF VAR aux_dtvigenc AS DATE                    NO-UNDO.

    ASSIGN p-vltarifa = 0
           p-cdhistor = 0
           p-cdfvlcop = 0
           p-cdhisest = 0.

    FIND crapass WHERE crapass.cdcooper = p-cdcooper AND
                       crapass.nrdconta = p-nrdconta NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapass  THEN
        DO:
            ASSIGN p-dscritic = "Associado nao cadastrado.".
            RETURN "NOK".
        END.

    /** Conta administrativa nao sofre tarifacao **/
    IF  crapass.inpessoa = 3  THEN
        RETURN "OK".

    IF  p-cdagenci = 91  THEN  /** TAA **/
        RETURN "OK".
    ELSE
    IF  p-cdagenci = 90  THEN  /** Internet **/
        ASSIGN aux_dssigtar = IF crapass.inpessoa = 1 
                              THEN "TEDELETRPF" ELSE "TEDELETRPJ".
    ELSE  /** Caixa On-Line **/
        ASSIGN aux_dssigtar = IF crapass.inpessoa = 1 
                              THEN "TEDCAIXAPF" ELSE "TEDCAIXAPJ".

    RUN sistema/generico/procedures/b1wgen0153.p PERSISTENT SET h-b1wgen0153.

    IF  NOT VALID-HANDLE(h-b1wgen0153)  THEN
        DO: 
            ASSIGN p-dscritic = "Nao foi possivel carregar a tarifa.".
            RETURN "NOK".
        END.

    /*  Busca valor da tarifa */
    RUN carrega_dados_tarifa_vigente IN h-b1wgen0153
                                    (INPUT p-cdcooper,
                                     INPUT aux_dssigtar,
                                     INPUT p-vllanmto,
                                     INPUT "", /* cdprogra */
                                    OUTPUT p-cdhistor,
                                    OUTPUT p-cdhisest,
                                    OUTPUT p-vltarifa,
                                    OUTPUT aux_dtdivulg,
                                    OUTPUT aux_dtvigenc,
                                    OUTPUT p-cdfvlcop,
                                    OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen0153.

    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAIL tt-erro  THEN
                ASSIGN p-dscritic = tt-erro.dscritic.
            ELSE
                ASSIGN p-dscritic = "Nao foi possivel carregar a tarifa.".

            RETURN "NOK".
        END.
    
    RETURN "OK".

END.

PROCEDURE retorna-conta-cartao:
    
    DEF INPUT        PARAM p-cooper              AS CHAR.
    DEF INPUT        PARAM p-cod-agencia         AS INTEGER.  /* Cod. Agencia    */
    DEF INPUT        PARAM p-nro-caixa           AS INTEGER.  /* Numero Caixa    */
    DEF INPUT        PARAM p-cartao              AS DEC.      /* Nro Cartao */
    DEF OUTPUT       PARAM p-nro-conta           AS DEC.      /* Nro Conta       */
    DEF OUTPUT       PARAM p-nrcartao            AS DECI.
    DEF OUTPUT       PARAM p-idtipcar            AS INTE.
                      
    DEF VAR h-b1wgen0025 AS HANDLE               NO-UNDO.
    DEF VAR aux_dscartao AS CHAR                 NO-UNDO.

    DEF VAR aux_nrcartao AS DEC                  NO-UNDO.
    DEF VAR aux_nrdconta AS INT                  NO-UNDO.
    DEF VAR aux_cdcooper AS INT                  NO-UNDO.
    DEF VAR aux_inpessoa AS INT                  NO-UNDO.
    DEF VAR aux_idsenlet AS LOGICAL              NO-UNDO.
    DEF VAR aux_idseqttl AS INT                  NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                 NO-UNDO.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.

    ASSIGN p-nro-conta = INT(REPLACE(STRING(p-nro-conta),".","")).

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    ASSIGN i-nro-lote = 11000 + p-nro-caixa.
  
    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper NO-LOCK NO-ERROR.
 
    IF   p-cartao = 0   THEN      
          DO:
              ASSIGN i-cod-erro  = 0
                    c-desc-erro = "Numero do cartao deve ser Informado".           
              RUN cria-erro (INPUT p-cooper,
                             INPUT p-cod-agencia,
                             INPUT p-nro-caixa,
                             INPUT i-cod-erro,
                             INPUT c-desc-erro,
                             INPUT YES).
              RETURN "NOK".
END.

     ASSIGN aux_dscartao = "XX" + SUBSTR(STRING(p-cartao),1,16) + "=" + SUBSTR(STRING(p-cartao),17).
          
     RUN sistema/generico/procedures/b1wgen0025.p 
         PERSISTENT SET h-b1wgen0025.
         
     RUN verifica_cartao IN h-b1wgen0025(INPUT crapcop.cdcooper,
                                         INPUT 0,
                                         INPUT aux_dscartao, 
                                         INPUT crapdat.dtmvtolt,
                                        OUTPUT p-nro-conta,
                                        OUTPUT aux_cdcooper,
                                        OUTPUT p-nrcartao,
                                        OUTPUT aux_inpessoa,
                                        OUTPUT aux_idsenlet,
                                        OUTPUT aux_idseqttl,
                                        OUTPUT p-idtipcar,
                                        OUTPUT aux_dscritic).

     DELETE PROCEDURE h-b1wgen0025.
     
     IF   RETURN-VALUE <> "OK"   THEN /* Se retornou erro */
          DO:
              RUN cria-erro (INPUT p-cooper,
                             INPUT p-cod-agencia,
                             INPUT p-nro-caixa,
                             INPUT i-cod-erro,
                             INPUT aux_dscritic,
                             INPUT YES).
              RETURN "NOK".
          END.
    
    RUN dbo/b2crap00.p PERSISTENT SET h_b2crap00.
    
    ASSIGN i_conta = p-nro-conta.

    RUN verifica-digito IN h_b2crap00(INPUT p-cooper,
                                      INPUT p-cod-agencia,
                                      INPUT p-nro-caixa,
                                      INPUT-OUTPUT i_conta).
    DELETE PROCEDURE h_b2crap00.

    IF  RETURN-VALUE = "NOK" THEN
        RETURN "NOK".

    RUN dbo/b1crap02.p PERSISTENT SET h-b1crap02.

    RUN retornaCtaTransferencia IN h-b1crap02 (INPUT p-cooper,
                                               INPUT p-cod-agencia, 
                                               INPUT p-nro-caixa, 
                                               INPUT p-nro-conta, 
                                              OUTPUT aux_nrdconta).
    IF   RETURN-VALUE = "NOK" THEN 
         DO:
             DELETE PROCEDURE h-b1crap02.
             RETURN "NOK".
END.

    IF   aux_nrdconta <> 0 THEN
         ASSIGN p-nro-conta = aux_nrdconta.
    
    RETURN "OK".

END PROCEDURE.

PROCEDURE valida_senha_cartao:

    DEF INPUT  PARAM p-cooper           AS CHAR.
    DEF INPUT  PARAM p-cod-agencia      AS INTE.
    DEF INPUT  PARAM p-nro-caixa        AS INTE.
    DEF INPUT  PARAM p-nro-conta        AS DEC.     
    DEF INPUT  PARAM p-nrcartao         AS DECI.
    DEF INPUT  PARAM p-opcao            AS CHAR.
    DEF INPUT  PARAM p-senha-cartao     AS CHAR.
    DEF INPUT  PARAM p-idtipcar         AS INTE.
    DEF INPUT  PARAM p-infocry          AS CHAR.
    DEF INPUT  PARAM p-chvcry           AS CHAR.

    DEF VAR h-b1wgen0025 AS HANDLE                                NO-UNDO.

    DEF VAR aux_cdcritic AS INTE                                  NO-UNDO.    
    DEF VAR aux_dscritic AS CHAR                                  NO-UNDO.

    ASSIGN p-nro-conta = DEC(REPLACE(STRING(p-nro-conta),".","")).

    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.

    IF   p-opcao = "C"   THEN
         DO:
            IF  TRIM(p-senha-cartao) = '' THEN
                DO:
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT 0,
                                   INPUT "Insira uma senha.",
                                   INPUT YES).
                     RETURN "NOK".
                END.

            RUN sistema/generico/procedures/b1wgen0025.p 
                 PERSISTENT SET h-b1wgen0025.

            RUN valida_senha_tp_cartao IN h-b1wgen0025(INPUT crapcop.cdcooper,
                                                       INPUT p-nro-conta, 
                                                       INPUT p-nrcartao,
                                                       INPUT p-idtipcar,
                                                       INPUT p-senha-cartao,
                                                       INPUT p-infocry,
                                                       INPUT p-chvcry,
                                                      OUTPUT aux_cdcritic,
                                                      OUTPUT aux_dscritic). 

            DELETE PROCEDURE h-b1wgen0025.

            IF   RETURN-VALUE <> "OK"   THEN /* Se retornou erro */
                 DO:
                     RUN cria-erro (INPUT p-cooper,
                                    INPUT p-cod-agencia,
                                    INPUT p-nro-caixa,
                                    INPUT aux_cdcritic,
                                    INPUT aux_dscritic,
                                    INPUT YES).
                     RETURN "NOK".
                 END.
         END.

    RETURN "OK".

END PROCEDURE.

/* b1crap20.p */

/* .......................................................................... */
