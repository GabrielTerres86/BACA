CREATE OR REPLACE PACKAGE CECRED.PCPS0004 is
  /* ---------------------------------------------------------------------------------------------------------------
      Programa : PCPS0004
      Sistema  : Rotinas referentes a PLATAFORMA CENTRALIZADA DE PORTABILIDADE DE SALÁRIO
      Sigla    : PCPS
      Autor    : Gilberto - Supero
      Data     : Fevereiro/2019.
  
      Dados referentes ao programa:
  
      Frequencia: -----
      Objetivo  : Rotinas Retornar o texto do termo de portabilidade de salário
  ---------------------------------------------------------------------------------------------------------------*/
PROCEDURE pc_retorna_texto_termo(pr_cdagenci  IN NUMBER
                                ,pr_nrdcaixa  IN NUMBER
                                ,pr_cdorigem  IN NUMBER
                                ,pr_nmdatela  IN VARCHAR2
                                ,pr_nmprogra	IN VARCHAR2
                                ,pr_cdoperad  IN VARCHAR2
                                ,pr_flgerlog  IN NUMBER
                                ,pr_flmobile  IN NUMBER
                                ,pr_dsretxml  OUT  xmltype  --> XML de retorno CLOB
                                ,pr_dscritic  OUT VARCHAR2);

PROCEDURE pc_busca_dados_acompanhamento(pr_cdcooper IN crapcop.cdcooper%TYPE  
                                      ,pr_nrdconta 	IN crapass.nrdconta%TYPE 
                                      ,pr_idseqttl	IN crapttl.idseqttl%TYPE
                                      ,pr_cdagenci	IN NUMBER
                                      ,pr_nrdcaixa	IN NUMBER
                                      ,pr_cdorigem	IN NUMBER
                                      ,pr_nmdatela	IN VARCHAR2
                                      ,pr_nmprogra	IN VARCHAR2
                                      ,pr_cdoperad	IN VARCHAR2
                                      ,pr_flgerlog	IN NUMBER
                                      ,pr_flmobile	IN NUMBER
                                      ,pr_dsretxml  OUT xmltype  --> XML de retorno CLOB
                                      ,pr_dscritic  OUT VARCHAR2);

PROCEDURE pc_gera_cancelamento_portab(pr_cdcooper IN crapcop.cdcooper%TYPE  
		                                 ,pr_nrdconta IN crapass.nrdconta%TYPE 
		                                 ,pr_idseqttl	IN crapttl.idseqttl%TYPE
		                                 ,pr_idsolici	IN NUMBER
		                                 ,pr_cdagenci	IN NUMBER
		                                 ,pr_nrdcaixa	IN NUMBER
		                                 ,pr_cdorigem	IN NUMBER
		                                 ,pr_nmdatela	IN VARCHAR2
                                     ,pr_nmprogra	IN VARCHAR2
		                                 ,pr_cdoperad	IN VARCHAR2
		                                 ,pr_flgerlog	IN NUMBER
		                                 ,pr_flmobile	IN NUMBER
                                     ,pr_dsretxml OUT xmltype  --> XML de retorno CLOB
                                     ,pr_dscritic OUT VARCHAR2);
                                     
PROCEDURE pc_gerar_solicitacao_portab(pr_cdcooper	IN crapcop.cdcooper%TYPE  
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE 
                                     ,pr_idseqttl	IN crapttl.idseqttl%TYPE
                                     ,pr_dsnomass	IN VARCHAR2
                                     ,pr_nrcpfcgc	IN NUMBER
                                     ,pr_nrdddfon	IN NUMBER
                                     ,pr_nrdofone	IN NUMBER
                                     ,pr_dsdemail	IN VARCHAR2
                                     ,pr_nrcnpjep	IN NUMBER
                                     ,pr_dsnomemp	IN VARCHAR2
                                     ,pr_cddbanco	IN NUMBER
                                     ,pr_idvalida	IN NUMBER
                                     ,pr_cdagenci	IN NUMBER
                                     ,pr_nrdcaixa	IN NUMBER
                                     ,pr_cdorigem	IN NUMBER
                                     ,pr_nmdatela	IN VARCHAR2
                                     ,pr_nmprogra	IN VARCHAR2
                                     ,pr_cdoperad	IN VARCHAR2
                                     ,pr_flgerlog	IN NUMBER
                                     ,pr_flmobile	IN NUMBER
                                     ,pr_dsretxml OUT xmltype  --> XML de retorno CLOB
                                     ,pr_dscritic OUT VARCHAR2);

PROCEDURE pc_gera_termo_portabilidade(pr_cdcooper IN crapcop.cdcooper%TYPE  
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE 
                                     ,pr_idseqttl	IN crapttl.idseqttl%TYPE
                                     ,pr_idsolici	IN NUMBER
                                     ,pr_cdagenci	IN NUMBER
                                     ,pr_nrdcaixa	IN NUMBER
                                     ,pr_cdorigem	IN NUMBER
                                     ,pr_nmdatela	IN VARCHAR2
                                     ,pr_nmprogra	IN VARCHAR2
                                     ,pr_cdoperad	IN VARCHAR2
                                     ,pr_flgerlog	IN NUMBER
                                     ,pr_flmobile	IN NUMBER
                                     ,pr_dsretxml  OUT xmltype
                                     ,pr_dscritic  OUT VARCHAR2);
	
END PCPS0004;
/
CREATE OR REPLACE PACKAGE BODY CECRED.PCPS0004 IS

  /* ---------------------------------------------------------------------------------------------------------------

      Programa : PCPS0004
      Sistema  : Rotinas referentes a PLATAFORMA CENTRALIZADA DE PORTABILIDADE DE SALÁRIO
      Sigla    : PCPS
      Autor    : Gilberto - Supero
      Data     : Fevereiro/2019.
  
      Dados referentes ao programa:
  
      Frequencia: -----
      Objetivo  : Rotinas Retornar o texto do termo de portabilidade de salário
      Alteracoes: 29/08/2019 PJ485.6 - Ajuste na rotina de cancelamento - Augusto (Supero)
			            29/08/2019 PJ485.6 - Ajuste para contemplar empregador PF - Augusto (Supero)

  ---------------------------------------------------------------------------------------------------------------*/

  --  Compactar o arquivo PCPS
  PROCEDURE pc_retorna_texto_termo(pr_cdagenci  IN NUMBER  -- Código da agência. Não terá utilidade na rotina.
                                  ,pr_nrdcaixa  IN NUMBER  -- Número do caixa. Não terá utilidade na rotina.
                                  ,pr_cdorigem  IN NUMBER  -- Indica a origem da transação. Não terá utilidade na rotina.
                                  ,pr_nmdatela  IN VARCHAR2   -- Nome da tela. Não terá utilidade na rotina.
                                  ,pr_nmprogra	IN VARCHAR2 -- Nome do programa. Não terá utilidade na rotina.
                                  ,pr_cdoperad  IN VARCHAR2   -- Código do operador. Não terá utilidade na rotina.
                                  ,pr_flgerlog  IN NUMBER     -- Indica geração de log. Não terá utilidade na rotina.
                                  ,pr_flmobile  IN NUMBER     -- Indica utilização pelo mobile. Não terá utilidade na rotina.
                                  ,pr_dsretxml  OUT xmltype -- XML de retorno CLOB
                                  ,pr_dscritic  OUT VARCHAR2) IS

  CURSOR cr_dias_comp IS       

  SELECT o.dsconteu
    FROM crappco o
   WHERE o.cdpartar = 63
     AND o.cdcooper = 3;

    rw_dias_comp cr_dias_comp%ROWTYPE;

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    -- Variaveis de XML 
    vr_clob     CLOB;
    vr_xml_temp VARCHAR2(32767);

    vr_qtde_dias      number;
    vr_dsqtde_dias    VARCHAR2(256);

  BEGIN
    -- Abre o cursor com a parametrização de dias para aceite compulsório    
    OPEN cr_dias_comp;     
     FETCH cr_dias_comp      
      INTO rw_dias_comp;       
      IF cr_dias_comp%NOTFOUND OR rw_dias_comp.dsconteu IS NULL THEN      
         CLOSE cr_dias_comp;       
         RAISE vr_exc_saida;     
      END IF;     
    CLOSE cr_dias_comp;       
    --
    BEGIN    
       vr_qtde_dias   := to_number(rw_dias_comp.dsconteu);       
       vr_dsqtde_dias := gene0002.fn_valor_extenso(pr_idtipval => 'I', pr_valor => vr_qtde_dias);         
    EXCEPTION      
         WHEN OTHERS THEN         
          RAISE vr_exc_saida;    
    END; 

    -- Criar documento XML
    dbms_lob.createtemporary(vr_clob, TRUE); 
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);       

    -- Insere o cabeçalho do XML 
    gene0002.pc_escreve_xml(pr_xml            => vr_clob 
                           ,pr_texto_completo => vr_xml_temp 
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><root>'); 

    -- Montar XML com registros do texto
    gene0002.pc_escreve_xml(pr_xml            => vr_clob 
                           ,pr_texto_completo => vr_xml_temp 
                           ,pr_texto_novo     => '<termo>'
                                               ||'<texto idseq="1">'
                                               ||'<![CDATA['||'Por meio da presente solicitação, com fundamento no artigo 2-A da Resolução 3.402/2006 do Conselho Monetário Nacional, solicito que todos os valores referentes a salários, proventos, soldos, vencimentos e/ou similares, creditados até a presente data em conta de minha titularidade vinculada à instituição financeira abaixo identificada, sejam transferidos, em sua totalidade, para a conta corrente/salário mantida nesta Cooperativa.' ||']]></texto>'
                                               ||'<texto idseq="2">'
                                               ||'<![CDATA['||'Caso o pagamento for feito na conta salário até às 12h00, a transferência do recurso deverá ocorrer no mesmo dia do respectivo crédito e sem qualquer custo. Para pagamentos realizados após às 12h00 a transferência ocorrerá no dia seguinte.' ||']]></texto>'
                                               ||'<texto idseq="3">'
                                               ||'<![CDATA['||'A aprovação desta solicitação poderá ocorrer em até '||vr_qtde_dias||' ( '||vr_dsqtde_dias||' ) dias úteis. A presente solicitação tem o caráter de instrumento permanente, de modo que a sua eventual revogação está condicionada à prévia expressa manifestação por escrito.'||']]></texto>'
                                               ||'</termo>'
                                                );
      
    -- Encerrar a tag raiz 
    gene0002.pc_escreve_xml(pr_xml            => vr_clob 
                           ,pr_texto_completo => vr_xml_temp 
                           ,pr_texto_novo     => '</root>' 
                           ,pr_fecha_xml      => TRUE);
    
    -- Converte para XML
    pr_dsretxml := xmltype(vr_clob);

   
  EXCEPTION
    WHEN vr_exc_saida THEN
         ROLLBACK;
         pr_dscritic := 'Falha ao carregar termo. Dúvidas entrar em contato com o SAC pelo telefone 0800 647 2200.';
    WHEN OTHERS THEN
         BEGIN
            -- Criar documento XML
            dbms_lob.createtemporary(vr_clob, TRUE); 
            dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);       
            -- Insere o cabeçalho do XML 
            gene0002.pc_escreve_xml(pr_xml            => vr_clob 
                                   ,pr_texto_completo => vr_xml_temp 
                                   ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?>'); 

            -- Montar XML com registros do texto
            gene0002.pc_escreve_xml(pr_xml            => vr_clob 
                                   ,pr_texto_completo => vr_xml_temp 
                                   ,pr_texto_novo     => '<root>'
                                                       ||'<dscritic> Falha ao carregar termo. Dúvidas entrar em contato com o SAC pelo telefone 0800 647 2200.</dscritic>'
                                                       );
            -- Encerrar a tag raiz 
            gene0002.pc_escreve_xml(pr_xml            => vr_clob 
                                   ,pr_texto_completo => vr_xml_temp 
                                   ,pr_texto_novo     => '</root>' 
                                   ,pr_fecha_xml      => TRUE);
            -- Converte para XML
            pr_dsretxml := xmltype(vr_clob);
            pr_dscritic := 'Falha ao carregar termo. Dúvidas entrar em contato com o SAC pelo telefone 0800 647 2200.';
         EXCEPTION
            WHEN OTHERS THEN
            NULL;
         END;
  END pc_retorna_texto_termo;
  --
  PROCEDURE pc_busca_dados_acompanhamento(pr_cdcooper IN crapcop.cdcooper%TYPE --Código da cooperativa do cooperado
                                      ,pr_nrdconta 	IN crapass.nrdconta%TYPE --Número da conta do cooperado
                                      ,pr_idseqttl	IN crapttl.idseqttl%TYPE 
                                      ,pr_cdagenci	IN NUMBER
                                      ,pr_nrdcaixa	IN NUMBER
                                      ,pr_cdorigem	IN NUMBER   -- Código da origem
                                      ,pr_nmdatela	IN VARCHAR2 -- Nome da tela 
                                      ,pr_nmprogra	IN VARCHAR2 -- Nome do programa
                                      ,pr_cdoperad	IN VARCHAR2 -- Código do operador
                                      ,pr_flgerlog	IN NUMBER
                                      ,pr_flmobile	IN NUMBER
                                      ,pr_dsretxml  OUT xmltype  --> XML de retorno CLOB
                                      ,pr_dscritic  OUT VARCHAR2) IS

  BEGIN
  
    /* .............................................................................
    
    Programa: pc_busca_dados_acompanhamento
    Sistema : Ayllos Web
    Autor   : Gilberto - Supero
    Data    : Fevereiro/2019                 Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Buscar os dados da solicitação de portabilidade vigente (última realizada)
    
    Alteracoes: -----
    ..............................................................................*/
    DECLARE
    
      -- Selecionar o CPF, Nome
      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT crapass.nrcpfcgc
              ,crapass.nmprimtl
              ,crapass.inpessoa
          FROM crapass
         WHERE crapass.cdcooper = pr_cdcooper
           AND crapass.nrdconta = pr_nrdconta;
    
      -- Seleciona a Instituicao Destinatario
      CURSOR cr_crapban_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT b.nrispbif
              ,b.nrcnpjif
              ,c.cdagectl
              ,upper(b.nmresbcc) nmresbcc
          FROM crapban b
              ,crapcop c
         WHERE b.cdbccxlt = c.cdbcoctl
           AND c.cdcooper = pr_cdcooper;
      -- Seleciona a Banco Folha
      CURSOR cr_crapban(pr_cdbccxlt IN crapban.cdbccxlt%TYPE) IS
        SELECT upper(b.nmresbcc) nmresbcc
          FROM crapban b
         WHERE b.cdbccxlt = pr_cdbccxlt;
    
      -- Seleciona Portab Envia
      CURSOR cr_portab_envia(pr_cdcooper IN crapenc.cdcooper%TYPE
                            ,pr_nrdconta IN crapenc.nrdconta%TYPE) IS
        SELECT '(' || to_char(tpe.nrddd_telefone) || ')' || tpe.nrtelefone AS telefone
              ,tpe.dsdemail
              ,dom.dscodigo AS situacao
              ,dom.cddominio AS cdsituacao
              ,dcp.dscodigo AS motivo
              ,dcp.cddominio AS cdmotivo
              ,to_char(tpe.dtsolicitacao, 'DD/MM/RRRR') AS dtsolicitacao
              ,to_char(tpe.dtretorno, 'DD/MM/RRRR') AS dtretorno
              ,tpe.cdbanco_folha
              ,tpe.nrispb_banco_folha
              ,tpe.nrcnpj_banco_folha
              ,to_char(tpe.nrnu_portabilidade) AS nrnu_portabilidade
              ,tpe.nrcpfcgc
              ,tpe.nmprimtl
              ,LPAD(tpe.nrcnpj_empregador,14,0) nrcnpj_empregador
              ,tpe.dsnome_empregador
              ,tpe.ROWID dsrowid
              ,tpe.nrsolicitacao
              ,decode(tpe.dtassina_eletronica,null,1,2) idsolicitadoib
							,tpe.tppessoa_empregador
          FROM tbcc_portabilidade_envia  tpe
              ,tbcc_dominio_campo       dom
              ,tbcc_dominio_campo       dcp
         WHERE tpe.idsituacao = dom.cddominio
           AND dom.nmdominio = 'SIT_PORTAB_SALARIO_ENVIA'
           AND dcp.nmdominio(+) = tpe.dsdominio_motivo
           AND dcp.cddominio(+) = to_char(tpe.cdmotivo)
           AND tpe.nrdconta = pr_nrdconta
           AND tpe.cdcooper = pr_cdcooper
         ORDER BY tpe.dtsolicitacao DESC;
      rw_portab_envia cr_portab_envia%ROWTYPE;
      
      -- Buscar erros de rejeições
      CURSOR cr_errenvia(pr_cdcooper IN tbcc_portabilidade_env_erros.cdcooper%TYPE
                        ,pr_nrdconta IN tbcc_portabilidade_env_erros.nrdconta%TYPE
                        ,pr_nrsolici IN tbcc_portabilidade_env_erros.nrsolicitacao%TYPE) IS
        SELECT dom.dscodigo
          FROM tbcc_dominio_campo           dom
             , tbcc_portabilidade_env_erros err
         WHERE dom.nmdominio     = err.dsdominio_motivo
           AND dom.cddominio     = err.cdmotivo
           AND err.nrsolicitacao = pr_nrsolici
           AND err.nrdconta      = pr_nrdconta
           AND err.cdcooper      = pr_cdcooper;
      
       -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      vr_dsxmlarq      xmltype;         --> XML do arquivo
    
      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
    
      -- Variaveis de log
      vr_cdbanco_bf VARCHAR2(100);
      vr_nmresbcc   VARCHAR2(100);
      vr_dsmsglog   VARCHAR2(1000);
      vr_nrdrowid ROWID;

      -- Variaveis para CADA0008.pc_busca_inf_emp
      vr_nrdocnpj tbcc_portabilidade_envia.nrcnpj_empregador%TYPE;
			vr_tppesemp tbcc_portabilidade_envia.tppessoa_empregador%TYPE;
      vr_nmpessot tbcadast_pessoa.nmpessoa%TYPE;
    
			vr_nrdocnpj_aux VARCHAR2(200);
    
      -- Variaveis Gerais
      vr_nrcpfcgc     crapass.nrcpfcgc%TYPE;
      vr_nmprimtl     crapass.nmprimtl%TYPE;
      vr_inpessoa     crapass.inpessoa%TYPE;
      vr_nrispbif_cop crapban.nrispbif%TYPE;
      vr_nmresbcc_cop crapban.nmresbcc%TYPE;
      vr_nrdocnpj_cop VARCHAR2(100);
      vr_cdagectl_cop crapcop.cdagectl%TYPE;
      vr_dsmotivo     VARCHAR2(5000);
      v_dsmensagem    VARCHAR2(100);
      vr_dtretorno    VARCHAR2(20);
      
    BEGIN
      -- Incluir Nome do Módulo Logado
      gene0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_PORTAB', pr_action => NULL);
      -- Criar cabecalho do XML
      vr_dsxmlarq := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      -- Selecionar o CPF, Nome e Tipo de Conta
      OPEN cr_crapass(pr_cdcooper, pr_nrdconta);
      FETCH cr_crapass
        INTO vr_nrcpfcgc
            ,vr_nmprimtl
            ,vr_inpessoa;
      IF cr_crapass%NOTFOUND THEN
        CLOSE cr_crapass;
        vr_dscritic := 'Cooperado não encontrado.';
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_crapass;
    
      -- Seleciona Portab Envia
      OPEN cr_portab_envia(pr_cdcooper, pr_nrdconta );
      FETCH cr_portab_envia INTO rw_portab_envia;
      
      -- Se nenhuma portabilidade for encontrada, deve retornar o XML em branco, para que seja apresentada a tela de solicitação
      IF cr_portab_envia%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_portab_envia;
        
        -- Montar o XML de retorno
        pr_dsretxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root></Root>');
         
        -- Encerrarr a execução da rotina
        RETURN;
      END IF;
      -- Fechar o cursor
      CLOSE cr_portab_envia;
    
      -- Selecionar a instituicao destinataria
      OPEN cr_crapban_crapcop(pr_cdcooper);
      FETCH cr_crapban_crapcop
        INTO vr_nrispbif_cop
            ,vr_nrdocnpj_cop
            ,vr_cdagectl_cop
            ,vr_nmresbcc_cop;
      IF cr_crapban_crapcop%NOTFOUND THEN
        CLOSE cr_crapban_crapcop;
        vr_dscritic := 'Instituição Destinatária não encontrada.';
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_crapban_crapcop;
			--
      vr_cdbanco_bf := rw_portab_envia.cdbanco_folha;
      vr_tppesemp   := rw_portab_envia.tppessoa_empregador;
      vr_nrdocnpj   := rw_portab_envia.nrcnpj_empregador;
      vr_nmpessot   := rw_portab_envia.dsnome_empregador;
      -- seleciona o banco folha
      OPEN cr_crapban(vr_cdbanco_bf);
      FETCH cr_crapban
        INTO vr_nmresbcc;
      IF cr_crapban%NOTFOUND THEN
        CLOSE cr_crapban;
        vr_dscritic := 'Banco Folha não encontrado.';
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_crapban;
    
      gene0007.pc_insere_tag(pr_xml      => vr_dsxmlarq,
                             pr_tag_pai  => 'Root',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Portabilidade',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => vr_dsxmlarq,
                             pr_tag_pai  => 'Portabilidade',
                             pr_posicao  => 0,
                             pr_tag_nova => 'nrsolicitacao',
                             pr_tag_cont => rw_portab_envia.nrsolicitacao,
                             pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => vr_dsxmlarq,
                             pr_tag_pai  => 'Portabilidade',
                             pr_posicao  => 0,
                             pr_tag_nova => 'dtsolicitacao',
                             pr_tag_cont =>  rw_portab_envia.dtsolicitacao,
                             pr_des_erro => vr_dscritic);
      -- Banco folha
      gene0007.pc_insere_tag(pr_xml      => vr_dsxmlarq,
                             pr_tag_pai  => 'Portabilidade',
                             pr_posicao  => 0,
                             pr_tag_nova => 'cdbancofolha',
                             pr_tag_cont => lpad(vr_cdbanco_bf, 3, '0'),
                             pr_des_erro => vr_dscritic);
    
      gene0007.pc_insere_tag(pr_xml      => vr_dsxmlarq,
                             pr_tag_pai  => 'Portabilidade',
                             pr_posicao  => 0,
                             pr_tag_nova => 'dsbancofolha',
                             pr_tag_cont => trim(vr_nmresbcc),
                             pr_des_erro => vr_dscritic);
    
      -- Empregador PF
			IF vr_tppesemp = 1 THEN
			   vr_nrdocnpj_aux := LPAD(vr_nrdocnpj,11,0);
			ELSE -- Empregador PJ
				vr_nrdocnpj_aux := LPAD(vr_nrdocnpj,14,0);
			END IF;

      gene0007.pc_insere_tag(pr_xml      => vr_dsxmlarq,
                             pr_tag_pai  => 'Portabilidade',
                             pr_posicao  => 0,
                             pr_tag_nova => 'nrcnpjempregagor',
                             pr_tag_cont => vr_nrdocnpj_aux,
                             pr_des_erro => vr_dscritic);
    
      gene0007.pc_insere_tag(pr_xml      => vr_dsxmlarq,
                             pr_tag_pai  => 'Portabilidade',
                             pr_posicao  => 0,
                             pr_tag_nova => 'dsnomeempregagor',
                             pr_tag_cont => vr_nmpessot,
                             pr_des_erro => vr_dscritic);
      -- Numero da Portabilidade
      gene0007.pc_insere_tag(pr_xml      => vr_dsxmlarq,
                             pr_tag_pai  => 'Portabilidade',
                             pr_posicao  => 0,
                             pr_tag_nova => 'nrnuportabilidade',
                             pr_tag_cont => rw_portab_envia.nrnu_portabilidade,
                             pr_des_erro => vr_dscritic);
      IF rw_portab_envia.nrnu_portabilidade is NULL AND rw_portab_envia.cdsituacao IN (1,2) then
         v_dsmensagem :=  'Aguarde o processamento da CIP. Isso pode levar algumas horas.';    
      ELSE
         v_dsmensagem :=  null;    
      END IF;
      gene0007.pc_insere_tag(pr_xml      => vr_dsxmlarq,
                             pr_tag_pai  => 'Portabilidade',
                             pr_posicao  => 0,
                             pr_tag_nova => 'dsmensagemnu',
                             pr_tag_cont => v_dsmensagem,
                             pr_des_erro => vr_dscritic);
                             
      -- Se a solicitação foi rejeitada
      IF rw_portab_envia.cdsituacao = 8 THEN 
        gene0007.pc_insere_tag(pr_xml      => vr_dsxmlarq,
                               pr_tag_pai  => 'Portabilidade',
                               pr_posicao  => 0,
                               pr_tag_nova => 'idsituacao',
                               pr_tag_cont => 4, -- Retorna como reprovada, permitindo nova solicitação
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => vr_dsxmlarq,
                               pr_tag_pai  => 'Portabilidade',
                               pr_posicao  => 0,
                               pr_tag_nova => 'dssituacao',
                               pr_tag_cont => 'Reprovada' ,
                               pr_des_erro => vr_dscritic);
      -- Se o cancelamento foi rejeitado, volta para aprovada, permitindo novo cancelamento
      ELSIF rw_portab_envia.cdsituacao = 9 THEN 
        gene0007.pc_insere_tag(pr_xml      => vr_dsxmlarq,
                               pr_tag_pai  => 'Portabilidade',
                               pr_posicao  => 0,
                               pr_tag_nova => 'idsituacao',
                               pr_tag_cont => 3, -- Aprovada
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => vr_dsxmlarq,
                               pr_tag_pai  => 'Portabilidade',
                               pr_posicao  => 0,
                               pr_tag_nova => 'dssituacao',
                               pr_tag_cont => 'Aprovada' ,
                               pr_des_erro => vr_dscritic);
      ELSE -- (1,2,3,4,5,6,7)                            
        gene0007.pc_insere_tag(pr_xml      => vr_dsxmlarq,
                               pr_tag_pai  => 'Portabilidade',
                               pr_posicao  => 0,
                               pr_tag_nova => 'idsituacao',
                               pr_tag_cont => rw_portab_envia.cdsituacao,
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => vr_dsxmlarq,
                               pr_tag_pai  => 'Portabilidade',
                               pr_posicao  => 0,
                               pr_tag_nova => 'dssituacao',
                               pr_tag_cont => rw_portab_envia.situacao ,
                               pr_des_erro => vr_dscritic);
      END IF;
      --
      -- Se for solicitação que já teve algum retorno 
      IF rw_portab_envia.cdsituacao > 2   THEN
        vr_dtretorno := rw_portab_envia.dtretorno;
      ELSE 
        vr_dtretorno := NULL;
      END IF;
      
      gene0007.pc_insere_tag(pr_xml      => vr_dsxmlarq,
                             pr_tag_pai  => 'Portabilidade',
                             pr_posicao  => 0,
                             pr_tag_nova => 'dtretorno',
                             pr_tag_cont => vr_dtretorno,
                             pr_des_erro => vr_dscritic);
      /*
      SITUAÇÃO DA PORTABILIDADE:
          1 -	A Solicitar
          2	- Solicitada
          3	- Aprovada
          4	- Reprovada
          5	- A Cancelar
          6	- Aguardando Cancelamento
          7	- Cancelada
          8	- Rejeitada
          9	- Cancelamento Rejeitado
      */
      -- Retornar a mensagem para apresentar como motivo, conforme cada situação
      IF rw_portab_envia.cdsituacao in (4,5,6,7,8)   THEN                              
         vr_dsmotivo := rw_portab_envia.motivo;
         --
         IF upper(rw_portab_envia.cdmotivo) = 'EGENPCPS' THEN 
           vr_dsmotivo := '';
           
           -- Buscar erro na tabela de erros
           OPEN  cr_errenvia(pr_cdcooper
                            ,pr_nrdconta
                            ,rw_portab_envia.nrsolicitacao);
           FETCH cr_errenvia INTO vr_dsmotivo;
           CLOSE cr_errenvia;
         END IF;
      
      ELSIF rw_portab_envia.cdsituacao IN (1,2)   THEN
        vr_dsmotivo := 'Solicitação está pendente de retorno da instituição.';
      ELSIF rw_portab_envia.cdsituacao IN (3,9)   THEN
        vr_dsmotivo := 'Solicitação aprovada pela instituição detentora da conta salário. O próximo '||
                       'pagamento deverá ser creditado automaticamente em sua conta na Cooperativa.';
      ELSE
         vr_dsmotivo := '';
      END IF;
      --                             
      gene0007.pc_insere_tag(pr_xml      => vr_dsxmlarq,
                             pr_tag_pai  => 'Portabilidade',
                             pr_posicao  => 0,
                             pr_tag_nova => 'dsmotivo',
                             pr_tag_cont => vr_dsmotivo,
                             pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => vr_dsxmlarq,
                             pr_tag_pai  => 'Portabilidade',
                             pr_posicao  => 0,
                             pr_tag_nova => 'idsolicitadoib',
                             pr_tag_cont => rw_portab_envia.idsolicitadoib,
                             pr_des_erro => vr_dscritic);

      -- Se houve retorno de erro
      IF nvl(vr_cdcritic, 0) > 0 OR
         vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
        
      
      pr_dsretxml := vr_dsxmlarq;--.getclobval;

    EXCEPTION
      WHEN vr_exc_erro THEN  
        pr_dscritic := 'Falha ao buscar Solicitação de Portabilidade. Dúvidas entrar em contato com o SAC pelo telefone 0800 647 2200. ';
      
        -- Carregar XML padrao para variavel de retorno
        vr_dsxmlarq := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><dscritic>' || pr_dscritic || '</dscritic></Root>');
        pr_dsretxml := vr_dsxmlarq;--.getclobval;
        
        -- LOGS DE EXECUCAO
        BEGIN
          vr_dsmsglog := 'PCPS0004'|| ' --> Erro ao consultar dados de acompanhamento: '||vr_dscritic;
          -- Efetua os inserts para apresentacao na tela VERLOG
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                               pr_cdoperad => 996,--Código do operador – IB
                               pr_dscritic => vr_dsmsglog,
                               pr_dsorigem => 'INTERNET',
                               pr_dstransa => 'Acompanhamento de Portabilidade de Salario',
                               pr_dttransa => TRUNC(SYSDATE),
                               pr_flgtrans => 0, --Indica falha na transação
                               pr_hrtransa => to_char(SYSDATE, 'SSSSS'),
                               pr_idseqttl => 1,
                               pr_nmdatela => 'INTERNETBANK',
                               pr_nrdconta => pr_nrdconta,
                               pr_nrdrowid => vr_nrdrowid);
          COMMIT;
          --        
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
      
      WHEN OTHERS THEN
        pr_dscritic := 'Falha ao buscar Solicitação de Portabilidade. Dúvidas entrar em contato com o SAC pelo telefone 0800 647 2200. ';
      
        -- Carregar XML padrao para variavel de retorno
        pr_dsretxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><dscritic>' || pr_dscritic || '</dscritic></Root>');
         
        -- LOGS DE EXECUCAO
        BEGIN
          vr_dsmsglog := 'PCPS0004 --> Erro ao consultar dados de acompanhamento: '||SQLERRM;
          -- Efetua os inserts para apresentacao na tela VERLOG
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                               pr_cdoperad => 996,--Código do operador – IB
                               pr_dscritic => vr_dsmsglog,
                               pr_dsorigem => 'INTERNET',
                               pr_dstransa => 'Acompanhamento de Portabilidade de Salario',
                               pr_dttransa => TRUNC(SYSDATE),
                               pr_flgtrans => 0, --Indica falha na transação
                               pr_hrtransa => to_char(SYSDATE, 'SSSSS'),
                               pr_idseqttl => 1,
                               pr_nmdatela => 'INTERNETBANK',
                               pr_nrdconta => pr_nrdconta,
                               pr_nrdrowid => vr_nrdrowid);
          COMMIT;
          --        
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
    END;
  
  END pc_busca_dados_acompanhamento;
  --
  PROCEDURE pc_gera_cancelamento_portab(pr_cdcooper IN crapcop.cdcooper%TYPE  --Código da cooperativa do cooperado
		                                   ,pr_nrdconta IN crapass.nrdconta%TYPE --Número da conta do cooperado
		                                   ,pr_idseqttl	IN crapttl.idseqttl%TYPE --Indica o titular da conta. Será sempre considerado apenas o primeiro (1).
		                                   ,pr_idsolici	IN NUMBER --Número sequencial da solicitação (é retornado pela rotina de acompanhamento)
		                                   ,pr_cdagenci	IN NUMBER --Código da agência. Não terá utilidade na rotina.
		                                   ,pr_nrdcaixa	IN NUMBER --Número do caixa. Não terá utilidade na rotina.
		                                   ,pr_cdorigem	IN NUMBER --Código da origem
		                                   ,pr_nmdatela	IN VARCHAR2 --Nome da tela 
                                       ,pr_nmprogra	IN VARCHAR2 -- Nome do programa. Não terá utilidade na rotina.
		                                   ,pr_cdoperad	IN VARCHAR2 --Código do operador
		                                   ,pr_flgerlog	IN NUMBER -- Indica geração de log. Não terá utilidade na rotina.
		                                   ,pr_flmobile	IN NUMBER -- Indica utilização pelo mobile. Não terá utilidade na rotina.
                                       ,pr_dsretxml OUT xmltype  --> XML de retorno CLOB
                                       ,pr_dscritic OUT VARCHAR2)IS --> Erros do processo
  BEGIN
    /* .............................................................................
    
    Programa: pc_gera_cancelamento_portab
    Sistema : Ayllos Web
    Autor   : Gilberto (Supero)
    Data    : Fevereira/2019                 Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Rotina para cancelar portabilidade.
    
    Alteracoes: -----
    ..............................................................................*/
    DECLARE
    
      -- Buscar o motivo
      CURSOR cr_motivo(pr_cdmotivo IN tbcc_dominio_campo.cddominio%TYPE) IS
        SELECT cddominio
              ,nmdominio
              ,dscodigo
          FROM tbcc_dominio_campo
         WHERE nmdominio = 'MOTVCANCELTPORTDDCTSALR'
           AND cddominio = to_char(pr_cdmotivo);
    
      rw_motivo cr_motivo%ROWTYPE;
    
      -- Seleciona Portab Envia
      CURSOR cr_portab_envia(pr_cdcooper IN crapcop.cdcooper%TYPE
                            ,pr_nrdconta IN crapass.nrdconta%TYPE
                            ,pr_nrsolici IN tbcc_portabilidade_envia.nrsolicitacao%TYPE) IS
        SELECT ROWID dsdrowid
             , tpe.idsituacao
             , to_char(nrnu_portabilidade) nrnu_portabilidade
          FROM tbcc_portabilidade_envia tpe
         WHERE tpe.nrsolicitacao = pr_nrsolici
           AND tpe.nrdconta      = pr_nrdconta
           AND tpe.cdcooper      = pr_cdcooper;
      rw_portab_envia cr_portab_envia%ROWTYPE;
    
      -- Variavel de criticas
      vr_dscritic VARCHAR2(10000);
      vr_dsmsglog VARCHAR2(10000);
    
      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
      vr_dsxmlarq      xmltype;         --> XML do arquivo

      -- Variaveis de log
      vr_nrdrowid ROWID;
    
      -- Variaveis locais
      vr_situacao tbcc_dominio_campo.cddominio%TYPE;
      vr_motivo   tbcc_dominio_campo.dscodigo%TYPE;
    
    BEGIN
      -- Incluir Nome do Módulo Logado
      gene0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_PORTAB', pr_action => NULL);
    
      -- Busca dados da instituicao financeira destinataria
      OPEN cr_portab_envia(pr_cdcooper, pr_nrdconta, pr_idsolici);
      FETCH cr_portab_envia
        INTO rw_portab_envia;
      CLOSE cr_portab_envia;
    
      -- Solicitada
      IF rw_portab_envia.idsituacao = 2 THEN        
        vr_situacao := 5; -- Cancelada
      ELSE 
        vr_situacao := 7; -- A cancelar
      END IF;
      -- O motivo de cancelamento será sempre “1 – Desistência do Cliente”, 
      --visto que no Internet Banking não há local para seleção de outro motivo especifico.
      OPEN cr_motivo(1);
      FETCH cr_motivo
        INTO rw_motivo;
    
      IF cr_motivo%NOTFOUND THEN
        CLOSE cr_motivo;
        vr_dscritic := 'Erro ao buscar motivo de cancelamento: ' || SQLERRM;
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_motivo;
    
      vr_motivo := rw_motivo.dscodigo;
    
      BEGIN
        UPDATE tbcc_portabilidade_envia
           SET idsituacao       = vr_situacao
              ,cdmotivo         = 1--pr_cdmotivo
              ,dsdominio_motivo = 'MOTVCANCELTPORTDDCTSALR'
         WHERE ROWID = rw_portab_envia.dsdrowid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao cancelar portabilidade: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;
       -- Efetua os inserts para apresentacao na tela VERLOG
       GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => '996' --fixo
                          ,pr_dscritic => ' ' -- Espaço em branco
                          ,pr_dsorigem => 'INTERNET'
                          ,pr_dstransa => 'Cancelamento de Portabilidade de Salario'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1 -- Transação OK
                          ,pr_hrtransa => to_char(SYSDATE, 'SSSSS')
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'INTERNETBANK'
                          ,pr_nrdconta => pr_nrdconta --Número da conta
                          ,pr_nrdrowid => vr_nrdrowid);
      -- Gera o log para o NU Portabilidade
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'NU Portabilidade'
                               ,pr_dsdadant => rw_portab_envia.nrnu_portabilidade 
                               ,pr_dsdadatu => rw_portab_envia.nrnu_portabilidade);
    
      -- Gera o log para o Motivo Portabilidade
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'Motivo',
                                pr_dsdadant => ' ',
                                pr_dsdadatu => vr_motivo);
             
      -- Criar cabecalho do XML
      vr_dsxmlarq := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      GENE0007.pc_insere_tag(pr_xml      => vr_dsxmlarq,
                             pr_tag_pai  => 'Root',
                             pr_posicao  => 0,
                             pr_tag_nova => 'dsmensag',
                             pr_tag_cont => 'Solicitação de cancelamento realizado com Sucesso.',
                             pr_des_erro => vr_dscritic);
 
      -- Se houve retorno de erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      --
      pr_dsretxml := vr_dsxmlarq; --.getclobval;
      -- Gravar os dados                   
      COMMIT;

    
    EXCEPTION
      WHEN vr_exc_erro THEN
        ROLLBACK;
        
        -- LOGS DE EXECUCAO
        BEGIN
          vr_dsmsglog := 'PCPS0004 --> Erro ao cancelar portabilidade: '||vr_dscritic;
          -- Efetua os inserts para apresentacao na tela VERLOG
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                               pr_cdoperad => 996,--Código do operador – IB
                               pr_dscritic => vr_dsmsglog,
                               pr_dsorigem => 'INTERNET',
                               pr_dstransa => 'Cancelamento de Portabilidade de Salario',
                               pr_dttransa => TRUNC(SYSDATE),
                               pr_flgtrans => 0, --Indica falha na transação
                               pr_hrtransa => to_char(SYSDATE, 'SSSSS'),
                               pr_idseqttl => 1,
                               pr_nmdatela => 'INTERNETBANK',
                               pr_nrdconta => pr_nrdconta,
                               pr_nrdrowid => vr_nrdrowid);
          COMMIT;
          --        
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        
        -- Mensagem para apresentar ao usuário
        pr_dscritic := 'Falha ao solicitar cancelamento de Portabilidade. Dúvidas entrar em contato com o SAC pelo telefone 0800 647 2200.';
        
        -- Carregar XML padrao para variavel de retorno
        pr_dsretxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><dscritic>' || pr_dscritic || '</dscritic></Root>');
        
      WHEN OTHERS THEN
        -- Guardar mensagem de erro do log
        vr_dsmsglog := 'PCPS0004 --> Erro ao cancelar portabilidade: '||SQLERRM;
        
        ROLLBACK;
        
        -- LOGS DE EXECUCAO
        BEGIN
          -- Efetua os inserts para apresentacao na tela VERLOG
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                               pr_cdoperad => 996,--Código do operador – IB
                               pr_dscritic => vr_dsmsglog,
                               pr_dsorigem => 'INTERNET',
                               pr_dstransa => 'Cancelamento de Portabilidade de Salario',
                               pr_dttransa => TRUNC(SYSDATE),
                               pr_flgtrans => 0, --Indica falha na transação
                               pr_hrtransa => to_char(SYSDATE, 'SSSSS'),
                               pr_idseqttl => 1,
                               pr_nmdatela => 'INTERNETBANK',
                               pr_nrdconta => pr_nrdconta,
                               pr_nrdrowid => vr_nrdrowid);
          COMMIT;
          --        
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        
        -- Mensagem para apresentar ao usuário
        pr_dscritic := 'Falha ao solicitar cancelamento de Portabilidade. Dúvidas entrar em contato com o SAC pelo telefone 0800 647 2200.';
        
        -- Carregar XML padrao para variavel de retorno
        pr_dsretxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><dscritic>' || pr_dscritic || '</dscritic></Root>');
                                  
    END;
  
  END pc_gera_cancelamento_portab;
  --
  PROCEDURE pc_gerar_solicitacao_portab(pr_cdcooper	IN crapcop.cdcooper%TYPE  --Código da cooperativa do cooperado
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE --Número da conta do cooperado
                                     ,pr_idseqttl	IN crapttl.idseqttl%TYPE --Indica o titular da conta. Será sempre considerado apenas o primeiro (1).
                                     ,pr_dsnomass	IN VARCHAR2 --Nome do Cooperado
                                     ,pr_nrcpfcgc	IN NUMBER --CPF do cooperado
                                     ,pr_nrdddfon	IN NUMBER --DDD do Telefone cadastrado
                                     ,pr_nrdofone	IN NUMBER --Número do Telefone cadastrado.
                                     ,pr_dsdemail	IN VARCHAR2 --E-mail cadastrado
                                     ,pr_nrcnpjep	IN NUMBER --Número do CNPJ do Empregador
                                     ,pr_dsnomemp	IN VARCHAR2 --Nome da Empresa (Empregador)
                                     ,pr_cddbanco	IN NUMBER --Código do banco selecionado
                                     ,pr_idvalida	IN NUMBER --Indica que deve apenas realizar a validação
                                     ,pr_cdagenci	IN NUMBER --Código da agência. Não terá utilidade na rotina.Valor = 90, quando IB.
                                     ,pr_nrdcaixa	IN NUMBER --Número do caixa. Não terá utilidade na rotina Valor = 900, quando IB.
                                     ,pr_cdorigem	IN NUMBER --Código da origem
                                     ,pr_nmdatela	IN VARCHAR2 --Nome da tela Valor = 'INTERNETBANKING'
                                     ,pr_nmprogra	IN VARCHAR2 --Nome do programa. Não terá utilidade na rotina
                                     ,pr_cdoperad	IN VARCHAR2 --Código do operador Valor = 996, quando IB.
                                     ,pr_flgerlog	IN NUMBER --Indica geração de log. Não terá utilidade na rotina. Valor = 1
                                     ,pr_flmobile	IN NUMBER --Indica utilização pelo mobile. Valor = 0, quando IB
                                     ,pr_dsretxml OUT xmltype  --> XML de retorno CLOB
                                     ,pr_dscritic OUT VARCHAR2) IS
  BEGIN
    /* .............................................................................
    
    Programa: pc_gerar_solicitacao_portab
    Sistema : Ayllos Web
    Autor   : Gilberto (Supero)
    Data    : Fevereira/2019                 Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Rotina para gerar portabilidade.
    
    Alteracoes: -----
    
          07/05/2019 - Não permitir solicitações de portabilidade com CNPJ do 
                       empregador nulo ou igual a zero. (Renato Darosci - Supero)
                       
    ..............................................................................*/
    DECLARE
      
      TYPE typ_tab_valida  IS TABLE OF VARCHAR2(200) INDEX BY PLS_INTEGER;
      vr_tab_valida     typ_tab_valida;
      
      --Se não encontrar a cooperativa (crapcop)
      CURSOR cr_crapcoop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT c.cdcooper
          FROM crapcop c
         WHERE c.cdcooper = pr_cdcooper;
      rw_crapcoop cr_crapcoop%ROWTYPE;
      -- Selecionar o CPF, Nome
      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT crapass.nrcpfcgc
              ,crapass.nmprimtl
              ,crapass.dtdemiss
          FROM crapass
         WHERE crapass.cdcooper = pr_cdcooper
           AND crapass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;


      -- Selecionar o banco folha
      CURSOR cr_crapban(pr_cdbccxlt IN crapban.cdbccxlt%TYPE) IS
        SELECT crapban.nrcnpjif
				      ,nvl(crapban.nrispbif, 0) nrispbif
          FROM crapban
         WHERE crapban.cdbccxlt = pr_cdbccxlt;
      rw_crapban cr_crapban%ROWTYPE;
    
        -- Selecionar dados da empresa do cooperado
      CURSOR cr_crapttl(pr_cdcooper IN crapenc.cdcooper%TYPE
                       ,pr_nrdconta IN crapenc.nrdconta%TYPE) IS
        SELECT crapttl.nrcpfemp
              ,crapttl.nmextemp
							,crapttl.cdempres
          FROM crapttl
         WHERE crapttl.cdcooper = pr_cdcooper
           AND crapttl.nrdconta = pr_nrdconta
           AND crapttl.idseqttl = 1;
      rw_crapttl cr_crapttl%ROWTYPE;  
      -- Seleciona a Instituicao Destinatario
      CURSOR cr_crapcop(pr_cdcooper IN crapenc.cdcooper%TYPE) IS
        SELECT b.nrispbif
              ,b.nrcnpjif
              ,c.cdagectl
          FROM crapban b
              ,crapcop c
         WHERE b.cdbccxlt = c.cdbcoctl
           AND c.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
    
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      CURSOR cr_craptpr(pr_cdcooper IN crapenc.cdcooper%TYPE
                       ,pr_nrdconta IN crapenc.nrdconta%TYPE) IS
        SELECT to_char(tpr.nrnu_portabilidade) nrnu_portabilidade
              ,to_char(tpr.dtsolicitacao, 'DD/MM/RRRR HH24:MI:SS') dtsolicitacao
              ,tpr.idsituacao
              ,dom.dscodigo situacao
              ,tpr.rowid
          FROM tbcc_portabilidade_recebe tpr
                ,tbcc_dominio_campo        dom
         WHERE tpr.idsituacao = dom.cddominio
           AND dom.nmdominio = 'SIT_PORTAB_SALARIO_RECEBE'
           AND tpr.nrdconta = pr_nrdconta
           AND tpr.cdcooper = pr_cdcooper
           AND rownum = 1
         ORDER BY tpr.dtsolicitacao DESC;

      rw_craptpr cr_craptpr%ROWTYPE;
    
      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
      vr_dsmsglog VARCHAR2(10000);
      vr_critica  number := 0;   
      vr_index    VARCHAR2(200); 
  
      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
      vr_dsxmlarq      xmltype; --> XML do arquivo
      -- Variaveis de log
      vr_nrdrowid ROWID;
  
      -- Variaveis locais
      vr_nrsolicitacao tbcc_portabilidade_envia.nrsolicitacao%TYPE;
      vr_contador PLS_INTEGER := 0;  
			vr_tppesemp  tbcc_portabilidade_envia.tppessoa_empregador%TYPE;
			vr_dstppese  VARCHAR2(200);
			vr_dscpfcnpj VARCHAR2(200);

   BEGIN
      -- Incluir Nome do Módulo Logado
      gene0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_PORTAB', pr_action => NULL);
      -- Criar cabecalho do XML
      vr_dsxmlarq := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      -- ** INICIO DAS VALIDAÇÕES
      -- Valida dados do Cooperado
      IF TRIM(pr_cdcooper) IS NULL THEN
        vr_critica      :=  vr_critica + 1 ;
        vr_tab_valida(vr_critica):= 'Código da cooperativa não pode ser nula.';    
      END IF;
      -- Valida Nro da conta
      IF TRIM(pr_nrdconta) IS NULL THEN
        vr_critica      :=  vr_critica + 1 ;
        vr_tab_valida(vr_critica):= 'Número da conta do cooperado nao pode ser nulo.';    
      END IF;
      -- Busca dados da Cooperativa
      IF TRIM(pr_cdcooper) IS NOT NULL THEN
        OPEN cr_crapcoop(pr_cdcooper);
        FETCH cr_crapcoop
          INTO rw_crapcoop;
        IF cr_crapcoop%NOTFOUND THEN
          CLOSE cr_crapcoop;
          vr_critica      :=  vr_critica + 1 ;
          vr_tab_valida(vr_critica):= 'Cooperativa informada não encontrada.';    
        ELSE
           CLOSE cr_crapcoop;
        END IF;
      END IF;
      -- Busca informacoes do cooperado
      IF (TRIM(pr_cdcooper) IS NOT NULL AND TRIM(pr_nrdconta) IS NOT NULL) THEN
        OPEN cr_crapass(pr_cdcooper, pr_nrdconta);
        FETCH cr_crapass
          INTO rw_crapass;
        -- Valida dados do cooperado
        IF cr_crapass%NOTFOUND THEN
          CLOSE cr_crapass;
          vr_critica      :=  vr_critica + 1 ;
          vr_tab_valida(vr_critica):= 'Associado não cadastrado.';    
         ELSE
           IF rw_crapass.dtdemiss IS NOT NULL THEN
              vr_critica      :=  vr_critica + 1 ;
              vr_tab_valida(vr_critica):= 'Conta encerrada.';    
           END IF;
           --
           IF rw_crapass.nrcpfcgc <> pr_nrcpfcgc THEN
              vr_critica      :=  vr_critica + 1 ;
              vr_tab_valida(vr_critica):= 'CPF informado é diferente do cadastro do cooperado.';    
           END IF;
           CLOSE cr_crapass;
        END IF;
        --
        IF UPPER(pr_dsnomass) IS NULL THEN
           vr_critica      :=  vr_critica + 1 ;
           vr_tab_valida(vr_critica):= 'Nome do cooperado deve ser informado.';    
        END IF;
        --
        IF pr_nrcpfcgc IS NULL THEN
           vr_critica      :=  vr_critica + 1 ;
           vr_tab_valida(vr_critica):= 'CPF do cooperado deve ser informado.';    
        END IF;
       -- Valida o telefone do cooperado
        IF length(pr_nrdddfon) <> 2 THEN
          vr_critica      :=  vr_critica + 1 ;
          vr_tab_valida(vr_critica):= 'DDD informado, não é válido.';    
        END IF;

        IF length(pr_nrdofone) > 9 OR
           length(pr_nrdofone) < 6 THEN
           vr_critica      :=  vr_critica + 1 ;
           vr_tab_valida(vr_critica) := 'Número do telefone informado, não é valido.';
        END IF;
        --
        IF NVL(pr_nrcnpjep,0) = 0 THEN
           vr_critica      :=  vr_critica + 1 ;
           vr_tab_valida(vr_critica):= 'CPF/CNPJ do Empregador deve ser informado.';    
        ELSE
          -- Busca CNPJ e Nome da empresa do cooperado    
          OPEN cr_crapttl(pr_cdcooper, pr_nrdconta);
          FETCH cr_crapttl
            INTO rw_crapttl;
          IF rw_crapttl.nrcpfemp <> pr_nrcnpjep/*cr_crapttl%NOTFOUND */THEN
             vr_critica      :=  vr_critica + 1 ;
             vr_tab_valida(vr_critica):= 'CPF/CNPJ do Empregador é diferente do cadastro.';    
          END IF;
					
					-- Tipo de pessoa do empregador
					vr_tppesemp := 2; -- PJ
					vr_dstppese := 'Pessoa Juridica';
					vr_dscpfcnpj := gene0002.fn_mask_cpf_cnpj(rw_crapttl.nrcpfemp, 2);
					IF rw_crapttl.cdempres = 9999 THEN
					   vr_tppesemp := 1; -- PF
						 vr_dstppese := 'Pessoa Fisica';
						 vr_dscpfcnpj := gene0002.fn_mask_cpf_cnpj(rw_crapttl.nrcpfemp, 1);
					END IF;
          CLOSE cr_crapttl;
        END IF;

        --
        IF pr_dsnomemp IS NULL THEN
           vr_critica      :=  vr_critica + 1 ;
           vr_tab_valida(vr_critica):= 'Nome do Empregador deve ser informado.';    
        END IF;

        IF pr_cddbanco IS NULL THEN
           vr_critica      :=  vr_critica + 1 ;
           vr_tab_valida(vr_critica):= 'Banco deve ser selecionado.';    
        ELSE
          -- Busca dados do Banco Folha
          OPEN cr_crapban(pr_cddbanco);
          FETCH cr_crapban
            INTO rw_crapban;
          
          IF cr_crapban%NOTFOUND THEN
             vr_critica      :=  vr_critica + 1 ;
             vr_tab_valida(vr_critica):= 'Banco Folha nao encontrado.';    
          ELSE                                    
            IF rw_crapban.nrcnpjif = 0 THEN
               vr_critica      :=  vr_critica + 1 ;
               vr_tab_valida(vr_critica):= 'Banco selecionado não é participante para Portabilidade de Salário.';    
            END IF;
          END IF;
          CLOSE cr_crapban;	
        END IF;
        		
        -- Busca portabilidade vigente     
        OPEN cr_craptpr(pr_cdcooper, pr_nrdconta);
        FETCH cr_craptpr
          INTO rw_craptpr;
          IF upper(rw_craptpr.situacao) = 'APROVADA' THEN
             vr_critica      :=  vr_critica + 1 ;
             vr_tab_valida(vr_critica):= 'Cooperado já possui portabilidade aprovada vigente.';    
          END IF;
        CLOSE cr_craptpr;
        -- Busca dados da instituicao financeira destinataria
        OPEN cr_crapcop(pr_cdcooper);
        FETCH cr_crapcop
          INTO rw_crapcop;
        
        IF cr_crapcop%NOTFOUND THEN
           vr_critica      :=  vr_critica + 1 ;
           vr_tab_valida(vr_critica):= 'Dados da Instituicao Financeira Destinataria nao encontrados.';    
        END IF;
        CLOSE cr_crapcop;
        
        IF TRIM(rw_crapcop.nrispbif) IS NULL THEN
           vr_critica      :=  vr_critica + 1 ;
           vr_tab_valida(vr_critica):= 'ISPB da Instituicao Financeira Destinataria nao encontrada.';    
        END IF;
        
        IF TRIM(rw_crapcop.nrcnpjif) IS NULL THEN
           vr_critica      :=  vr_critica + 1 ;
           vr_tab_valida(vr_critica):= 'CNPJ da Instituicao Financeira Destinataria nao encontrado.';    
        END IF;
        
        IF TRIM(rw_crapcop.cdagectl) IS NULL THEN
           vr_critica      :=  vr_critica + 1 ;
           vr_tab_valida(vr_critica):= 'Agencia da Instituicao Financeira Destinataria nao encontrada.';    
        END IF;
        ---
      END IF;
      --FIM DAS VALIDAÇÕES.
      IF vr_critica  > 0 THEN

          gene0007.pc_insere_tag(pr_xml      => vr_dsxmlarq,
                                 pr_tag_pai  => 'Root',
                                 pr_posicao  => 0,
                                 pr_tag_nova => 'criticas',
                                 pr_tag_cont => NULL,
                                 pr_des_erro => vr_dscritic);
                                 
        --Buscar Primeiro registro
        vr_index  := vr_tab_valida.FIRST;    
         
        LOOP
        
          IF vr_index  > vr_critica  THEN
             EXIT;
          ELSE   

            gene0007.pc_insere_tag(pr_xml      => vr_dsxmlarq,
                                   pr_tag_pai  => 'criticas',
                                   pr_posicao  => 0,
                                   pr_tag_nova => 'critica',
                                   pr_tag_cont => NULL,
                                   pr_des_erro => vr_dscritic);

            gene0007.pc_insere_tag(pr_xml      => vr_dsxmlarq,
                                   pr_tag_pai  => 'critica',
                                   pr_posicao  => vr_contador,
                                   pr_tag_nova => 'Codigo',
                                   pr_tag_cont => vr_index, 
                                   pr_des_erro => vr_dscritic);
                                   
            gene0007.pc_insere_tag(pr_xml      => vr_dsxmlarq,
                                   pr_tag_pai  => 'critica',
                                   pr_posicao  => vr_contador,
                                   pr_tag_nova => 'Descricao',
                                   pr_tag_cont => vr_tab_valida(vr_index),
                                   pr_des_erro => vr_dscritic);

          vr_contador := vr_contador + 1;

          END IF;
          --Proximo Registro
          vr_index := vr_index + 1;                
        END LOOP;
      END IF;
      --
      IF (NVL(pr_idvalida,0) <> 1 AND NVL(vr_critica,0) = 0) THEN
          BEGIN
            SELECT nvl(MAX(nrsolicitacao), 0) + 1
              INTO vr_nrsolicitacao
              FROM tbcc_portabilidade_envia
             WHERE cdcooper = pr_cdcooper
               AND nrdconta = pr_nrdconta;
          EXCEPTION
            WHEN no_data_found THEN
              vr_nrsolicitacao := 1;
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao buscar Numero de solicitacao: ' || SQLERRM;
              RAISE vr_exc_erro;
          END;
          --    
          BEGIN
            INSERT INTO tbcc_portabilidade_envia
              (cdcooper
              ,nrdconta
              ,nrsolicitacao
              ,dtsolicitacao
              ,nrcpfcgc
              ,nmprimtl
              ,nrddd_telefone
              ,nrtelefone
              ,dsdemail
              ,cdbanco_folha
              ,cdagencia_folha
              ,nrispb_banco_folha
              ,nrcnpj_banco_folha
              ,nrcnpj_empregador
              ,dsnome_empregador
              ,nrispb_destinataria
              ,nrcnpj_destinataria
              ,cdtipo_conta
              ,cdagencia
              ,idsituacao
              ,cdoperador
              ,dtassina_eletronica
							,tppessoa_empregador)
            VALUES
              (pr_cdcooper
              ,pr_nrdconta
              ,vr_nrsolicitacao
              ,SYSDATE
              ,rw_crapass.nrcpfcgc
              ,rw_crapass.nmprimtl
              ,pr_nrdddfon  
              ,pr_nrdofone 
              ,pr_dsdemail
              ,pr_cddbanco
              ,0
              ,rw_crapban.nrispbif
              ,rw_crapban.nrcnpjif
              ,rw_crapttl.nrcpfemp
              ,rw_crapttl.nmextemp
              ,rw_crapcop.nrispbif
              ,rw_crapcop.nrcnpjif
              ,'CC' -- Conta Corrente
              ,rw_crapcop.cdagectl
              ,1 -- a solicitar
              ,nvl(pr_cdoperad,996)
              ,SYSDATE
							,vr_tppesemp);
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao criar solicitacao de portabilidade: ' || SQLERRM;
              RAISE vr_exc_erro;
          END;
        -- Abre o cursor de data
        OPEN btch0001.cr_crapdat(pr_cdcooper);
        FETCH btch0001.cr_crapdat
          INTO rw_crapdat;
        CLOSE btch0001.cr_crapdat;
        
        -- Gerar pendencia de digitalizacao
        DIGI0001.pc_gera_pend_digitalizacao(pr_cdcooper => pr_cdcooper -- Cooperativa
                                           ,pr_nrdconta => pr_nrdconta -- Conta
                                           ,pr_idseqttl => 1 -- Fixo   -- Sera gerado para o titular
                                           ,pr_nrcpfcgc => rw_crapass.nrcpfcgc -- CPF do cooperado
                                           ,pr_dtmvtolt => rw_crapdat.dtmvtolt -- Data do dia
                                           ,pr_lstpdoct => 78          -- DOC: PORT SALARIO - TERMO DE ADESAO
                                           ,pr_cdoperad => pr_cdoperad -- Operador 
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
      
        IF TRIM(vr_dscritic) IS NOT NULL OR nvl(vr_cdcritic, 0) > 0 THEN
          -- Se não tem a descrição
          IF TRIM(vr_dscritic) IS NULL THEN
            -- Buscar com base na critica
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          END IF;
          
          RAISE vr_exc_erro;
        END IF;
      
        -- Efetua os inserts para apresentacao na tela VERLOG
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                             pr_cdoperad => 996,--Código do operador – IB
                             pr_dscritic => ' ',
                             pr_dsorigem => 'INTERNET',
                             pr_dstransa => 'Solicitacao de Portabilidade de Salario',
                             pr_dttransa => TRUNC(SYSDATE),
                             pr_flgtrans => 1,
                             pr_hrtransa => to_char(SYSDATE, 'SSSSS'),
                             pr_idseqttl => 1,
                             pr_nmdatela => 'INTERNETBANK',
                             pr_nrdconta => pr_nrdconta,
                             pr_nrdrowid => vr_nrdrowid);

        -- Gera o log para o CPF do cooperado
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'CPF',
                                  pr_dsdadant => ' ',
                                  pr_dsdadatu => gene0002.fn_mask_cpf_cnpj(rw_crapass.nrcpfcgc, 1));
        -- Gera o log para o nome do cooperado
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Nome',
                                  pr_dsdadant => ' ',
                                  pr_dsdadatu => rw_crapass.nmprimtl);
        -- Gera o log para o DDD do cooperado
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'DDD',
                                  pr_dsdadant => ' ',
                                  pr_dsdadatu => pr_nrdddfon);
        -- Gera o log para o Telefone do cooperado
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Telefone',
                                  pr_dsdadant => ' ',
                                  pr_dsdadatu => pr_nrdofone);
        -- Gera o log para o E-mail do cooperado
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'E-mail',
                                  pr_dsdadant => ' ',
                                  pr_dsdadatu => pr_dsdemail);
        -- Gera o log para o Cod. Banco Folha
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Cod. Banco Folha',
                                  pr_dsdadant => ' ',
                                  pr_dsdadatu => pr_cddbanco);
        -- Gera o log para o ISPB Banco Folha
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'ISPB Banco Folha',
                                  pr_dsdadant => ' ',
                                  pr_dsdadatu => rw_crapban.nrispbif);
        -- Gera o log para o CNPJ Banco Folha
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'CNPJ Banco Folha',
                                  pr_dsdadant => ' ',
                                  pr_dsdadatu => gene0002.fn_mask_cpf_cnpj(rw_crapban.nrcnpjif, 2));
        -- Gera o log para o Tipo de Pessoa do Empregador
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Tipo Pessoa Empregador',
                                  pr_dsdadant => ' ',
                                  pr_dsdadatu => vr_dstppese);
        -- Gera o log para o Documento do Empregador
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Documento Empregador',
                                  pr_dsdadant => ' ',
                                  pr_dsdadatu => vr_dscpfcnpj);																	
        -- Gera o log para o Nome Empregador
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Nome Empregador',
                                  pr_dsdadant => ' ',
                                  pr_dsdadatu => rw_crapttl.nmextemp);
        -- Gera o log para o ISPB Destinataria
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'ISPB Destinataria',
                                  pr_dsdadant => ' ',
                                  pr_dsdadatu => rw_crapcop.nrispbif);
        -- Gera o log para o CNPJ Destinataria
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'CNPJ Destinataria',
                                  pr_dsdadant => ' ',
                                  pr_dsdadatu => rw_crapcop.nrcnpjif);
        -- Gera o log para o Tipo Conta
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Tipo Conta CIP',
                                  pr_dsdadant => ' ',
                                  pr_dsdadatu => 'Conta Corrente');
        -- Gera o log para o Agencia Destinataria
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Agencia Destinataria',
                                  pr_dsdadant => ' ',
                                  pr_dsdadatu => rw_crapcop.cdagectl);
        --Conta Corrente 
        --Data Assinatura Eletronica.
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Data Assinatura Eletronica',
                                  pr_dsdadant => ' ',
                                  pr_dsdadatu => sysdate);
        --
        gene0007.pc_insere_tag(pr_xml      => vr_dsxmlarq,
                               pr_tag_pai  => 'Root',
                               pr_posicao  => 0,
                               pr_tag_nova => 'Dsmensag',
                               pr_tag_cont => 'Solicitação de Portabilidade realizada com Sucesso.',
                               pr_des_erro => vr_dscritic);
     
        COMMIT;

      END IF;
      -- 
      pr_dsretxml := vr_dsxmlarq;--.getclobval;
      --

   EXCEPTION
      WHEN vr_exc_erro THEN
        ROLLBACK;
        
        -- LOGS DE EXECUCAO
        BEGIN
          vr_dsmsglog := 'PCPS0004 --> Erro ao gerar portabilidade: '||vr_dscritic;
          -- Efetua os inserts para apresentacao na tela VERLOG
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                               pr_cdoperad => 996,--Código do operador – IB
                               pr_dscritic => vr_dsmsglog,
                               pr_dsorigem => 'INTERNET',
                               pr_dstransa => 'Solicitacao de Portabilidade de Salario',
                               pr_dttransa => TRUNC(SYSDATE),
                               pr_flgtrans => 0, --Indica falha na transação
                               pr_hrtransa => to_char(SYSDATE, 'SSSSS'),
                               pr_idseqttl => 1,
                               pr_nmdatela => 'INTERNETBANK',
                               pr_nrdconta => pr_nrdconta,
                               pr_nrdrowid => vr_nrdrowid);
          COMMIT;
          --        
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        
        -- Mensagem para apresentar ao usuário
        pr_dscritic := 'Falha ao realizar Solicitação de Portabilidade. Dúvidas entrar em contato com o SAC pelo telefone 0800 647 2200.';
        
        -- Carregar XML padrao para variavel de retorno
        pr_dsretxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><dscritic>' || pr_dscritic || '</dscritic></Root>');
      
      WHEN OTHERS THEN
        -- Guardar mensagem de erro do log
        vr_dsmsglog := 'PCPS0004 --> Erro ao gerar portabilidade: '||SQLERRM;
        
        ROLLBACK;
        
        -- LOGS DE EXECUCAO
        BEGIN
          -- Efetua os inserts para apresentacao na tela VERLOG
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                               pr_cdoperad => 996,--Código do operador – IB
                               pr_dscritic => vr_dsmsglog,
                               pr_dsorigem => 'INTERNET',
                               pr_dstransa => 'Solicitacao de Portabilidade de Salario',
                               pr_dttransa => TRUNC(SYSDATE),
                               pr_flgtrans => 0, --Indica falha na transação
                               pr_hrtransa => to_char(SYSDATE, 'SSSSS'),
                               pr_idseqttl => 1,
                               pr_nmdatela => 'INTERNETBANK',
                               pr_nrdconta => pr_nrdconta,
                               pr_nrdrowid => vr_nrdrowid);
          COMMIT;
          --        
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        
        -- Mensagem para apresentar ao usuário
        pr_dscritic := 'Falha ao realizar Solicitação de Portabilidade. Dúvidas entrar em contato com o SAC pelo telefone 0800 647 2200.';
        
        -- Carregar XML padrao para variavel de retorno
        pr_dsretxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><dscritic>' || pr_dscritic || '</dscritic></Root>');
   END;
  END pc_gerar_solicitacao_portab;
  --
  PROCEDURE pc_gera_termo_portabilidade(pr_cdcooper IN crapcop.cdcooper%TYPE  
                                       ,pr_nrdconta IN crapass.nrdconta%TYPE 
                                       ,pr_idseqttl	IN crapttl.idseqttl%TYPE
                                       ,pr_idsolici	IN NUMBER
                                       ,pr_cdagenci	IN NUMBER
                                       ,pr_nrdcaixa	IN NUMBER
                                       ,pr_cdorigem	IN NUMBER
                                       ,pr_nmdatela	IN VARCHAR2
                                       ,pr_nmprogra	IN VARCHAR2
                                       ,pr_cdoperad	IN VARCHAR2
                                       ,pr_flgerlog	IN NUMBER
                                       ,pr_flmobile	IN NUMBER
                                       ,pr_dsretxml OUT xmltype
                                       ,pr_dscritic OUT VARCHAR2) IS
    /* .............................................................................
    
    Programa: pc_gera_termo_portabilidade
    Sistema : Ayllos Web
    Autor   : Gilberto (Supero)
    Data    : Março/2019                 Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Imprimir o termo de adesão assinado digitalmente pelo cooperado.
    
    Alteracoes: -----
    ..............................................................................*/
    -- Seleciona Portab Envia
    CURSOR cr_portab_envia(pr_cdcooper IN crapenc.cdcooper%TYPE
                          ,pr_nrdconta IN crapenc.nrdconta%TYPE
                          ,pr_nrsolicitacao IN tbcc_portabilidade_envia.nrsolicitacao%TYPE ) IS
      SELECT tpe.ROWID dsrowid
        FROM tbcc_portabilidade_envia  tpe
       WHERE tpe.nrdconta      = pr_nrdconta
         AND tpe.cdcooper      = pr_cdcooper
         AND tpe.nrsolicitacao = pr_nrsolicitacao ;

    -- caminho e nome do arquivo a ser gerado
    vr_nmdireto VARCHAR2(150);
    vr_dssrvarq VARCHAR2(200);
    vr_dsdirarq VARCHAR2(200);
    vr_nrdrowid rowid;

    vr_retorno_xml xmltype;

    -- caminho e nome do arquivo a ser consultado
    vr_nom_direto   VARCHAR2(200); 
    --vr_nmarqimp  VARCHAR2(100);
    vr_nmarqpdf  VARCHAR2(100);    
      
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_exc_erro EXCEPTION;    
    vr_dscritic VARCHAR2(10000);
    vr_dsmsglog VARCHAR2(10000);

    BEGIN
      -- Busca dados da instituicao financeira destinataria
      OPEN cr_portab_envia(pr_cdcooper, pr_nrdconta, pr_idsolici );
      FETCH cr_portab_envia
        INTO vr_nrdrowid;
      IF cr_portab_envia%NOTFOUND THEN
        CLOSE cr_portab_envia;
        vr_dscritic := 'Portabilidade não encontrada.';
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_portab_envia;
      --
      -- Busca do diretório base da cooperativa para a geração de relatórios
      vr_nmdireto:= gene0001.fn_diretorio(pr_tpdireto => 'C'         --> /usr/coop
                                         ,pr_cdcooper => pr_cdcooper --> Cooperativa
                                         ,pr_nmsubdir => '/rl');     --> Utilizaremos o rl
      -- Efetuar solicitação de geração de relatório 
      --
      vr_nom_direto:= vr_nmdireto; -- '/usr/coop/'||rw_crapcop.dsdircop||'/rl';
      --
      PCPS0001.pc_gerar_termo_portab(pr_dsrowid  => vr_nrdrowid
                                    ,pr_cdcooper => pr_cdcooper
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic
                                    ,pr_dssrvarq => vr_dssrvarq
                                    ,pr_dsdirarq => vr_dsdirarq);
      -- Definir nome do relatorio
      vr_nmarqpdf :=  vr_dssrvarq;                                       
      
      -- Se houve retorno de erro
      IF nvl(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        -- Se não tem descrição
        IF TRIM(vr_dscritic) IS NULL THEN 
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        
        RAISE vr_exc_erro;
      END IF;
      -----
      gene0002.pc_copia_arq_para_download(pr_cdcooper => pr_cdcooper, 
                                          pr_dsdirecp => vr_nom_direto, 
                                          pr_nmarqucp => vr_nmarqpdf,
                                          pr_flgcopia => 1, 
                                          pr_dssrvarq => vr_dssrvarq, 
                                          pr_dsdirarq => vr_dsdirarq,
                                          pr_des_erro => vr_dscritic);

      vr_retorno_xml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><root/>');
      GENE0007.pc_insere_tag(pr_xml      => vr_retorno_xml
                            ,pr_tag_pai  => 'root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'nmarqpdf'
                            ,pr_tag_cont => vr_nmarqpdf
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => vr_retorno_xml
                            ,pr_tag_pai  => 'root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'dssrvarq'
                            ,pr_tag_cont => vr_dssrvarq
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => vr_retorno_xml
                            ,pr_tag_pai  => 'root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'dsdirarq'
                            ,pr_tag_cont => vr_dsdirarq
                            ,pr_des_erro => vr_dscritic);

      pr_dsretxml := vr_retorno_xml;
      -- Gravar os dados                   
      COMMIT;
     -- 
    EXCEPTION
      WHEN vr_exc_erro THEN
        ROLLBACK;
        
        -- LOGS DE EXECUCAO
        BEGIN
          vr_dsmsglog := 'PCPS0004 --> Erro ao gerar termo: '||vr_dscritic;
          -- Efetua os inserts para apresentacao na tela VERLOG
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                               pr_cdoperad => 996,--Código do operador – IB
                               pr_dscritic => vr_dsmsglog,
                               pr_dsorigem => 'INTERNET',
                               pr_dstransa => 'Termo de Portabilidade de Salario',
                               pr_dttransa => TRUNC(SYSDATE),
                               pr_flgtrans => 0, --Indica falha na transação
                               pr_hrtransa => to_char(SYSDATE, 'SSSSS'),
                               pr_idseqttl => 1,
                               pr_nmdatela => 'INTERNETBANK',
                               pr_nrdconta => pr_nrdconta,
                               pr_nrdrowid => vr_nrdrowid);
          COMMIT;
          --        
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        
        -- Mensagem para apresentar ao usuário
        pr_dscritic := 'Falha ao gerar Termo de Portabilidade. Dúvidas entrar em contato com o SAC pelo telefone 0800 647 2200.';
        
        -- Carregar XML padrao para variavel de retorno
        pr_dsretxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><dscritic>' || pr_dscritic || '</dscritic></Root>');
      
      WHEN OTHERS THEN
        -- Guardar mensagem de erro do log
        vr_dsmsglog := 'PCPS0004 --> Erro ao gerar termo: '||SQLERRM;
        
        ROLLBACK;
        
        -- LOGS DE EXECUCAO
        BEGIN
          -- Efetua os inserts para apresentacao na tela VERLOG
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                               pr_cdoperad => 996,--Código do operador – IB
                               pr_dscritic => vr_dsmsglog,
                               pr_dsorigem => 'INTERNET',
                               pr_dstransa => 'Termo de Portabilidade de Salario',
                               pr_dttransa => TRUNC(SYSDATE),
                               pr_flgtrans => 0, --Indica falha na transação
                               pr_hrtransa => to_char(SYSDATE, 'SSSSS'),
                               pr_idseqttl => 1,
                               pr_nmdatela => 'INTERNETBANK',
                               pr_nrdconta => pr_nrdconta,
                               pr_nrdrowid => vr_nrdrowid);
          COMMIT;
          --        
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        
        -- Mensagem para apresentar ao usuário
        pr_dscritic := 'Falha ao gerar Termo de Portabilidade. Dúvidas entrar em contato com o SAC pelo telefone 0800 647 2200.';
        
        -- Carregar XML padrao para variavel de retorno
        pr_dsretxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><dscritic>' || pr_dscritic || '</dscritic></Root>');
   END;
    --
END PCPS0004;
/
