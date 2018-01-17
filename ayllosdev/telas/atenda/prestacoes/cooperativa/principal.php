<?php
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : André Socoloski - DB1
 * DATA CRIAÇÃO : 25/03/2011 
 * OBJETIVO     : Mostrar opcao Principal da rotina de prestações da tela ATENDA 
 * 
  * --------------
 * ALTERAÇÕES   : 
 * --------------
 * 001: [29/04/2011] Rogerius (DB1): adiciona no array de avalista e interveniente anuente os novos campos do endereco.  
 * 002: [24/08/2011] Marcelo L. Pereira (GATI): adicionado chamada para pagamento
 * 003: [29/08/2011] Marcelo L. Pereira (GATI): alterando listagem do extrato
 * 004: [16/09/2011] David G. Kistner (CECRED): incluir parâmetro flgcondc no xml de requisição
 * 005: [01/03/2012] Tiago            (CECRED): incluir parâmetro txmensal no xml de requisição 
 * 006: [13/04/2012] Gabriel		  (CECRED): Incluir campo dtlibera.
 * 007: [22/02/2013] Gabriel		  (CECRED): Incluir valor do desconto parcial (Gabriel).
 * 008: [07/05/2013] Lucas Lunelli	  (CECRED): Alterações para Consultar Imagem de docmto. digitalizado.
 * 009: [24/05/2013] Lucas R.		  (CECRED): Incluir camada nas includes "../".
 * 010: [18/09/2013] Gabriel 		  (CECRED): Mandar como parametro para a BO a opcao (Gabriel)
 * 011: [19/02/2014] Jorge			  (CECRED): Ajuste para incluir paginacao dos resultados.
 * 012: [07/03/2014] James			  (CECRED): Ajuste para carregar os valores da Multa, Juros de Mora e Total Pagamento.
 * 013: [20/03/2014] James			  (CECRED): Ajuste no parametro "cddopcao".
 * 014: [05/06/2014] James			  (CECRED): Ajuste para permitir o avalista efetuar o pagamento de parcelas no emprestimo.
 * 015: [14/08/2014] Daniel           (CECRED): Ajuste informacoes do avalista, incluso novos campos.
 * 016: [11/09/2014] James            (CECRED): Ajuste na acao desfazer a efetivacao para passar o cdpactra e nao mais o cdagenci
 * 017: [03/11/2014] Daniel           (CECRED): Incluso novos tratamentos para Projeto Transferencia Prejuizo.
 * 018: [26/11/2014] Jorge/Rosangela  (CECRED): Inclusao de funcao php para retirar caracteres especiais. SD 218402
 * 019: [01/12/2014] Jonata           (RKAM)  : Incluir as telas de consultas automatizadas. 
 * 020: [14/01/2015] Jonata           (RKAM)  : Projeto microcredito. 
 * 021: [08/04/2015] Gabriel          (RKAM)  : Consultas automatizadas para o limite de credito.
 * 022: [14/04/2015] Jaison/Gielow    (CECRED): Inclusao da funcao 'formataMoeda' nas variaveis 'vlpreapg' e 'vltotpag' (SD: 275792).
 * 023: [23/04/2015] Jaison/Gielow    (CECRED): Soma 'Saldo Devedor' com 'Multa' e 'Juros Mora' na variavel 'vlsldliq' (SD: 262029).
 * 024: [24/06/2015] Daniel           (CECRED): Ajustes projeto 215 - DV3
 * 025: [03/07/2015] Gabriel            (RKAM): Revisao de contratos.
 * 026: [25/08/2015] Odirlei Busana    (AMcom): Alterada a chamada da obtem-dados-emprestimos para a rotina convertida para oracle.
 * 027: [23/11/2015] Carlos Rafael Tanholi: Merge de implementacoes de Portabilidade.
 * 028: [04/01/2016] Heitor             (RKAM): Inclusao do tipo de risco na tela de prejuizo
 * 029:  17/06/2016 - M181 - Alterar o CDAGENCI para passar o CDPACTRA (Rafael Maciel - RKAM)
 * 030: [15/12/2016] Tiago            (CECRED): Ajustes na hora da consulta das prestações pois nao carrega dados corretamente(SD531549)
 * 031: [03/04/2017] - Jean             (MOut´S): Chamado 643208 - tratamento de caracteres especiais dos campos descritivos, pois estava
 *                                                causando travamento na tela
 * 032: [17/01/2018] Inclu�do novo campo (Qualif Oper. Controle) (Diego Simas - AMcom)
 */
 
?>

<?
    session_start();
	require_once('../../../../includes/config.php');
	require_once('../../../../includes/funcoes.php');
	require_once('../../../../includes/controla_secao.php');
	require_once('../../../../class/xmlfile.php');
	isPostMethod();

	$cddopcao = ( isset($_POST['cddopcao']) && $_POST['cddopcao'] != '') ? $_POST['cddopcao'] : '@';
	
	// Verifica permissões de acessa a tela
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos',"controlaOperacao('');",false);
	}		
	
	// Verifica se o número da conta e o titular foram informados
	if (!isset($_POST['nrdconta']) || !isset($_POST['idseqttl'])) exibirErro('error','Parâmetros incorretos.','Alerta - Ayllos','fechaRotina(divRotina)',false);	
	
	// Guardo os parâmetos do POST em variáveis	
	$nrdconta = $_POST['nrdconta'] == '' ? 0 : $_POST['nrdconta'];
	$idseqttl = $_POST['idseqttl'] == '' ? 1 : $_POST['idseqttl'];	
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
	$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : 0;
	$prejuizo = (isset($_POST['prejuizo'])) ? $_POST['prejuizo'] : 0;
	$tpemprst = (isset($_POST['tpemprst'])) ? $_POST['tpemprst'] : 0;
	$nrparepr = (isset($_POST['nrparepr'])) ? $_POST['nrparepr'] : 0;
	$vlpagpar = (isset($_POST['vlpagpar'])) ? $_POST['vlpagpar'] : 0;
	$nrregist = (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 0; 
	$nriniseq = (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 0; 
	$inconcje = (isset($_POST['inconcje'])) ? $_POST['inconcje'] : 0;
	$dtcnsspc = (isset($_POST['dtcnsspc'])) ? $_POST['dtcnsspc'] : '';
	$idSocio  = (isset($_POST['idSocio']))  ? $_POST['idSocio']	 : 0;
	$iddoaval_busca = (isset($_POST['iddoaval_busca'])) ? $_POST['iddoaval_busca'] : 0;
	$inpessoa_busca = (isset($_POST['inpessoa_busca'])) ? $_POST['inpessoa_busca'] : '';
	$nrdconta_busca = (isset($_POST['nrdconta_busca'])) ? $_POST['nrdconta_busca'] : 0;
	$nrcpfcgc_busca = (isset($_POST['nrcpfcgc_busca'])) ? $_POST['nrcpfcgc_busca'] : 0;
	
	
	// Verifica se o número da conta e o titular são inteiros válidos
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inválida.','Alerta - Ayllos','fechaRotina(divRotina)',false);
	if (!validaInteiro($idseqttl)) exibirErro('error','Seq.Ttl inválida.','Alerta - Ayllos','fechaRotina(divRotina)',false);
	
	$dtiniper = isset($_POST["dtpesqui"]) && validaData($_POST["dtpesqui"]) ? $_POST["dtpesqui"] : "01/01/0001";
	$dtfimper = $glbvars["dtmvtolt"];

	if 	(in_array($operacao,array('C_NOVA_PROP'))){
		$procedure = 'obtem-dados-proposta-emprestimo';
	} else if (in_array($operacao,array('C_EXTRATO'))){
		$procedure = 'obtem-extrato-emprestimo';
	} else if (in_array($operacao,array('C_DESCONTO'))) {
		$procedure = 'calcula_desconto_parcela';
	} else if (in_array($operacao,array('C_PAG_PREST'))) {
		$procedure = 'busca_pagamentos_parcelas';	
	} else if (in_array($operacao,array('C_TRANSF_PREJU'))) {
		$procedure = 'transf_contrato_prejuizo';} 
	else if (in_array($operacao,array('C_DESFAZ_PREJU'))) {
		$procedure = 'desfaz_transferencia_prejuizo';
	} else{
		$procedure = 'obtem-dados-emprestimos';
	}
	
	if (in_array($operacao,array('C_EXTRATO','TC','C_NOVA_PROP',''))) {
	    if ($procedure ==  'obtem-dados-emprestimos' )  {
            // Monta o xml de requisição
            $xml  = "";
            $xml .= "<Root>";
            $xml .= "  <Dados>";
            $xml .= "    <nrdconta>".$nrdconta."</nrdconta>";
            $xml .= "    <idseqttl>".$idseqttl."</idseqttl>";
            $xml .= "    <dtcalcul></dtcalcul>";	
            $xml .= "    <nrctremp>".$nrctremp."</nrctremp>";
            $xml .= "    <cdprogra>".$glbvars["nmdatela"]."</cdprogra>";
            $xml .= "    <flgcondc>1</flgcondc>";
            $xml .= "	 <nrregist>".$nrregist."</nrregist>";
            
                      if($nrctremp == '0'){
            $xml .= "    <nriniseq>".$nriniseq."</nriniseq>";
                      }else{
                          $xml .= "    <nriniseq>1</nriniseq>";
                      }

            $xml .= "  </Dados>";
            $xml .= "</Root>";

            $xmlResult = mensageria($xml, "ATENDA", "OBTDADEMPR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
            
        } else {     
            // Monta o xml de requisição
            $xml  = "";
            $xml .= "<Root>";
            $xml .= "  <Cabecalho>";
            $xml .= "    <Bo>b1wgen0002.p</Bo>";
            $xml .= "    <Proc>".$procedure."</Proc>";
            $xml .= "  </Cabecalho>";
            $xml .= "  <Dados>";
            $xml .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
            $xml .= "    <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
            $xml .= "    <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
            $xml .= "    <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
            $xml .= "    <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
            $xml .= "    <idorigem>".$glbvars["idorigem"]."</idorigem>";
            $xml .= "    <cdprogra>".$glbvars["nmdatela"]."</cdprogra>";
            $xml .= "    <inproces>".$glbvars["inproces"]."</inproces>";	
            $xml .= "    <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
            $xml .= "    <dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";
            $xml .= "    <dtmvtoan>".$glbvars["dtmvtoan"]."</dtmvtoan>";
            $xml .= "    <nrdconta>".$nrdconta."</nrdconta>";
            $xml .= "    <idseqttl>".$idseqttl."</idseqttl>";
            $xml .= "    <nrctremp>".$nrctremp."</nrctremp>";
            $xml .= "    <cddopcao>".$cddopcao."</cddopcao>";
            $xml .= "	 <dtiniper>".$dtiniper."</dtiniper>";
            $xml .= "	 <dtfimper>".$dtfimper."</dtfimper>";
            $xml .= "	 <ccdopcao>C</ccdopcao>";
            $xml .= "    <dtcalcul>?</dtcalcul>";		
            $xml .= "    <flgcondc>yes</flgcondc>";
            $xml .= "	 <nrregist>".$nrregist."</nrregist>";
            $xml .= "    <nriniseq>".$nriniseq."</nriniseq>";
            $xml .= "  </Dados>";
            $xml .= "</Root>";
            
            $xmlResult = getDataXML($xml);
		}
        
		$xmlObjeto = getObjectXML($xmlResult);
		
		if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
			exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos',"controlaOperacao('');",false); 
		}
		
		if (in_array($operacao,array('C_EXTRATO',''))){

			$registros = $xmlObjeto->roottag->tags[0]->tags;
			
		} else if (in_array($operacao,array('TC'))){

			$registros = $xmlObjeto->roottag->tags[0]->tags[0]->tags;
			$flgdigit  = getByTagName($registros,'flgdigit');
			$tpdocged  = getByTagName($registros,'tpdocged');
			$nrdconta  = getByTagName($registros,'nrdconta');
			$nrctremp  = getByTagName($registros,'nrctremp');
            
            $vlsldliq = str_replace(',', '.', str_replace('.', '', getByTagName($registros,'vlsdeved'))) +
                        str_replace(',', '.', str_replace('.', '', getByTagName($registros,'vlmtapar'))) +
                        str_replace(',', '.', str_replace('.', '', getByTagName($registros,'vlmrapar')));
		
			?><script type="text/javascript">
			var arrayRegistros = new Object();

			arrayRegistros['inpessoa'] = '<? echo getByTagName($registros,'inpessoa'); ?>';
			arrayRegistros['nrdconta'] = '<? echo getByTagName($registros,'nrdconta'); ?>';
			arrayRegistros['nmprimtl'] = '<? echo getByTagName($registros,'nmprimtl'); ?>';
			arrayRegistros['nrctremp'] = '<? echo getByTagName($registros,'nrctremp'); ?>';
			arrayRegistros['vlemprst'] = '<? echo getByTagName($registros,'vlemprst'); ?>';
			arrayRegistros['vlsdeved'] = '<? echo formataMoeda($vlsldliq); ?>';
			arrayRegistros['vlpreemp'] = '<? echo getByTagName($registros,'vlpreemp'); ?>';
			arrayRegistros['vlprepag'] = '<? echo getByTagName($registros,'vlprepag'); ?>'; 
			arrayRegistros['txmensal'] = '<? echo getByTagName($registros,'txmensal'); ?>';
			arrayRegistros['txjuremp'] = '<? echo str_replace('.', ',',getByTagName($registros,'txjuremp')); ?>';
			arrayRegistros['vljurmes'] = '<? echo getByTagName($registros,'vljurmes'); ?>';
			arrayRegistros['vljuracu'] = '<? echo getByTagName($registros,'vljuracu'); ?>';
			arrayRegistros['vlprejuz'] = '<? echo getByTagName($registros,'vlprejuz'); ?>';
			arrayRegistros['vlsdprej'] = '<? echo getByTagName($registros,'vlsdprej'); ?>';
			arrayRegistros['dtprejuz'] = '<? echo getByTagName($registros,'dtprejuz'); ?>';
			arrayRegistros['vljrmprj'] = '<? echo getByTagName($registros,'vljrmprj'); ?>';
			arrayRegistros['vljraprj'] = '<? echo getByTagName($registros,'vljraprj'); ?>';
			arrayRegistros['inprejuz'] = '<? echo getByTagName($registros,'inprejuz'); ?>';
			arrayRegistros['vlprovis'] = '<? echo getByTagName($registros,'vlprovis'); ?>';
			arrayRegistros['flgpagto'] = '<? echo getByTagName($registros,'flgpagto'); ?>';
			arrayRegistros['dtdpagto'] = '<? echo getByTagName($registros,'dtdpagto'); ?>';
			arrayRegistros['cdpesqui'] = '<? echo getByTagName($registros,'cdpesqui'); ?>';
			arrayRegistros['dspreapg'] = '<? echo getByTagName($registros,'dspreapg'); ?>';
			arrayRegistros['cdlcremp'] = '<? echo getByTagName($registros,'cdlcremp'); ?>';
			arrayRegistros['dslcremp'] = '<? echo retiraCharEsp(getByTagName($registros,'dslcremp')); ?>';
			arrayRegistros['cdfinemp'] = '<? echo getByTagName($registros,'cdfinemp'); ?>';
			arrayRegistros['dsfinemp'] = '<? echo retiraCharEsp(getByTagName($registros,'dsfinemp')); ?>';
			arrayRegistros['dsdaval1'] = '<? echo retiraCharEsp(getByTagName($registros,'dsdaval1')); ?>';
			arrayRegistros['dsdaval2'] = '<? echo retiraCharEsp(getByTagName($registros,'dsdaval2')); ?>';
			arrayRegistros['vlpreapg'] = '<? echo formataMoeda(getByTagName($registros,'vlpreapg')); ?>';
			arrayRegistros['qtmesdec'] = '<? echo getByTagName($registros,'qtmesdec'); ?>';
			arrayRegistros['qtprecal'] = '<? echo getByTagName($registros,'qtprecal'); ?>';
			arrayRegistros['vlacresc'] = '<? echo getByTagName($registros,'vlacresc'); ?>';
			arrayRegistros['vlrpagos'] = '<? echo getByTagName($registros,'vlrpagos'); ?>';
			arrayRegistros['slprjori'] = '<? echo getByTagName($registros,'slprjori'); ?>';
			arrayRegistros['dtmvtolt'] = '<? echo getByTagName($registros,'dtmvtolt'); ?>';
			arrayRegistros['qtpreemp'] = '<? echo getByTagName($registros,'qtpreemp'); ?>';
			arrayRegistros['qtpreemp'] = '<? echo getByTagName($registros,'qtpreemp'); ?>';
			arrayRegistros['vlrabono'] = '<? echo getByTagName($registros,'vlrabono'); ?>';
			arrayRegistros['qtaditiv'] = '<? echo getByTagName($registros,'qtaditiv'); ?>';
			arrayRegistros['dsdpagto'] = '<? echo getByTagName($registros,'dsdpagto'); ?>';
			arrayRegistros['dsdavali'] = '<? echo getByTagName($registros,'dsdavali'); ?>';
			arrayRegistros['qtmesatr'] = '<? echo getByTagName($registros,'qtmesatr'); ?>';			
			arrayRegistros['tpemprst'] = '<? echo getByTagName($registros,'tpemprst'); ?>';			
			arrayRegistros['flgdigit'] = '<? echo getByTagName($registros,'flgdigit'); ?>';	
			arrayRegistros['tpdocged'] = '<? echo getByTagName($registros,'tpdocged'); ?>';			
			arrayRegistros['vlmtapar'] = '<? echo getByTagName($registros,'vlmtapar'); ?>';
			arrayRegistros['vlmrapar'] = '<? echo getByTagName($registros,'vlmrapar'); ?>';
			arrayRegistros['vltotpag'] = '<? echo formataMoeda(getByTagName($registros,'vltotpag')); ?>';
			arrayRegistros['qtimpctr'] = '<? echo getByTagName($registros,'qtimpctr'); ?>';
                        
                        
			/* Daniel */
			arrayRegistros['vlttmupr'] = '<? echo getByTagName($registros,'vlttmupr'); ?>';
			arrayRegistros['vlttjmpr'] = '<? echo getByTagName($registros,'vlttjmpr'); ?>';
			arrayRegistros['vlpgmupr'] = '<? echo getByTagName($registros,'vlpgmupr'); ?>';
			arrayRegistros['vlpgjmpr'] = '<? echo getByTagName($registros,'vlpgjmpr'); ?>';
			arrayRegistros['vlsdpjtl'] = '<? echo getByTagName($registros,'vlsdpjtl'); ?>';
			
			</script><?
			
		} else if (in_array($operacao,array('C_NOVA_PROP'))) {
		
			$cooperativa  = $xmlObjeto->roottag->tags[0]->tags[0]->tags;
			$associado    = $xmlObjeto->roottag->tags[1]->tags[0]->tags;
			$proposta     = $xmlObjeto->roottag->tags[4]->tags[0]->tags;
			$regBensAssoc = $xmlObjeto->roottag->tags[5]->tags;
			$alienacoes	  = $xmlObjeto->roottag->tags[6]->tags;
			$rendimento   = $xmlObjeto->roottag->tags[7]->tags[0]->tags;
			$faturamentos = $xmlObjeto->roottag->tags[8]->tags;
			$analise	  = $xmlObjeto->roottag->tags[9]->tags[0]->tags;
			$intervs	  = $xmlObjeto->roottag->tags[10]->tags;
			$hipotecas    = $xmlObjeto->roottag->tags[11]->tags;
			$avalistas	  = $xmlObjeto->roottag->tags[12]->tags;
			$regBensAval  = $xmlObjeto->roottag->tags[13]->tags;
								
			$inpessoa 	  = getByTagName($rendimento,'inpessoa');
			
			?><script type="text/javascript">
			
			var cdcooper = '<? echo $glbvars["cdcooper"];?>';
			var cdoperad = '<? echo $glbvars["cdoperad"];?>';
			
			var arrayAssociado = new Object();
			
			arrayAssociado['inpessoa'] = '<? echo getByTagName($associado,'inpessoa'); ?>';
			arrayAssociado['inmatric'] = '<? echo getByTagName($associado,'inmatric'); ?>';
			arrayAssociado['cdagenci'] = '<? echo getByTagName($associado,'cdagenci'); ?>';
			arrayAssociado['cdempres'] = '<? echo getByTagName($associado,'cdempres'); ?>';
			arrayAssociado['flgpagto'] = '<? echo getByTagName($associado,'flgpagto'); ?>';
			arrayAssociado['nrctacje'] = '<? echo getByTagName($associado,'nrctacje'); ?>';
			arrayAssociado['nrcpfcjg'] = '<? echo getByTagName($associado,'nrcpfcjg'); ?>';
						
			var arrayCooperativa = new Object();
			
			vleprori = '<? echo getByTagName($cooperativa,'vlemprst'); ?>';
			
			arrayCooperativa['vlmaxleg'] = '<? echo getByTagName($cooperativa,'vlmaxleg'); ?>';
			arrayCooperativa['vlmaxutl'] = '<? echo getByTagName($cooperativa,'vlmaxutl'); ?>';
			arrayCooperativa['vlcnsscr'] = '<? echo getByTagName($cooperativa,'vlcnsscr'); ?>';
			arrayCooperativa['vllimapv'] = '<? echo getByTagName($cooperativa,'vllimapv'); ?>';
			arrayCooperativa['flgcmtlc'] = '<? echo getByTagName($cooperativa,'flgcmtlc'); ?>';
			arrayCooperativa['vlminimo'] = '<? echo getByTagName($cooperativa,'vlminimo'); ?>';
			arrayCooperativa['vlemprst'] = '<? echo getByTagName($cooperativa,'vlemprst'); ?>';
			arrayCooperativa['inusatab'] = '<? echo getByTagName($cooperativa,'inusatab'); ?>';
			arrayCooperativa['nrctremp'] = '<? echo getByTagName($cooperativa,'nrctremp'); ?>';
			arrayCooperativa['nralihip'] = '<? echo getByTagName($cooperativa,'nralihip'); ?>';
			arrayCooperativa['lssemseg'] = '<? echo getByTagName($cooperativa,'lssemseg'); ?>';
			arrayCooperativa['flginter'] = '<? echo getByTagName($cooperativa,'flginter'); ?>';
			
			var arrayProposta = new Object();
			
			arrayProposta['vlemprst'] = '<? echo getByTagName($proposta,'vlemprst'); ?>';
			arrayProposta['vlpreemp'] = '<? echo getByTagName($proposta,'vlpreemp'); ?>';     
			arrayProposta['qtpreemp'] = '<? echo getByTagName($proposta,'qtpreemp'); ?>';     
			arrayProposta['nivrisco'] = '<? echo getByTagName($proposta,'nivrisco'); ?>';     
			arrayProposta['nivcalcu'] = '<? echo getByTagName($proposta,'nivcalcu'); ?>';     
			arrayProposta['cdlcremp'] = '<? echo getByTagName($proposta,'cdlcremp'); ?>';     
			arrayProposta['cdfinemp'] = '<? echo getByTagName($proposta,'cdfinemp'); ?>';     
			arrayProposta['qtdialib'] = '<? echo getByTagName($proposta,'qtdialib'); ?>';     
			arrayProposta['flgimppr'] = '<? echo getByTagName($proposta,'flgimppr'); ?>';     
			arrayProposta['flgimpnp'] = '<? echo getByTagName($proposta,'flgimpnp'); ?>';     
			arrayProposta['flgpagto'] = '<? echo getByTagName($proposta,'flgpagto'); ?>';     
			arrayProposta['dtdpagto'] = '<? echo getByTagName($proposta,'dtdpagto'); ?>';     
			arrayProposta['dsctrliq'] = '<? echo retiraCharEsp(getByTagName($proposta,'dsctrliq')); ?>';     
			arrayProposta['qtpromis'] = '<? echo getByTagName($proposta,'qtpromis'); ?>';     
			arrayProposta['nrseqrrq'] = '<? echo getByTagName($proposta,'nrseqrrq'); ?>'; 
			arrayProposta['nmchefia'] = '<? echo getByTagName($proposta,'nmchefia'); ?>';     
			arrayProposta['vlsalari'] = '<? echo getByTagName($proposta,'vlsalari'); ?>';    
			arrayProposta['vlsalcon'] = '<? echo getByTagName($proposta,'vlsalcon'); ?>';
			arrayProposta['vldrendi'] = '<? echo getByTagName($proposta,'vldrendi'); ?>';
			arrayProposta['dsobserv'] = '<? echo retiraCharEsp(getByTagName($proposta,'dsobserv')); ?>';
			arrayProposta['dsrelbem'] = '<? echo retiraCharEsp(getByTagName($proposta,'dsrelbem')); ?>';
			arrayProposta['tplcremp'] = '<? echo getByTagName($proposta,'tplcremp'); ?>';
			arrayProposta['dslcremp'] = '<? echo retiraCharEsp(getByTagName($proposta,'dslcremp')); ?>';
			arrayProposta['dsfinemp'] = '<? echo retiraCharEsp(getByTagName($proposta,'dsfinemp')); ?>';
			arrayProposta['idquapro'] = '<? echo getByTagName($proposta,'idquapro'); ?>';
			arrayProposta['idquaprc'] = '<? echo getByTagName($proposta,'idquaprc'); ?>';
			arrayProposta['dsquapro'] = '<? echo retiraCharEsp(getByTagName($proposta,'dsquapro')); ?>';
			arrayProposta['percetop'] = '<? echo getByTagName($proposta,'percetop'); ?>';
			arrayProposta['dtmvtolt'] = '<? echo getByTagName($proposta,'dtmvtolt'); ?>';
			arrayProposta['nrctremp'] = '<? echo getByTagName($proposta,'nrctremp'); ?>';
			arrayProposta['nrdrecid'] = '<? echo getByTagName($proposta,'nrdrecid'); ?>';
			arrayProposta['cdoperad'] = '<? echo getByTagName($proposta,'cdoperad'); ?>';
			arrayProposta['flgenvio'] = '<? echo getByTagName($proposta,'flgenvio'); ?>';
			arrayProposta['dtvencto'] = '<? echo getByTagName($proposta,'dtvencto'); ?>';
			arrayProposta['tpemprst'] = '<? echo getByTagName($proposta,'tpemprst'); ?>';
			arrayProposta['dsobscmt'] = '<? echo retiraCharEsp(getByTagName($proposta,'dsobscmt')); ?>';
			arrayProposta['flgcrcta'] = '<? echo getByTagName($proposta,'flgcrcta'); ?>';
			arrayProposta['tpemprst'] = '<? echo getByTagName($proposta,'tpemprst'); ?>';
			arrayProposta['cdtpempr'] = '<? echo getByTagName($proposta,'cdtpempr'); ?>';
			arrayProposta['dstpempr'] = '<? echo retiraCharEsp(getByTagName($proposta,'dstpempr')); ?>';
			arrayProposta['dtlibera'] = '<? echo getByTagName($proposta,'dtlibera'); ?>';


			var arrayRendimento = new Object();
			
			var contRend = <? echo count($rendimento[0]->tags)?>;
						
			<? for($i=1; $i <= count($rendimento[0]->tags); $i++) {?>		
				
				arrayRendimento['tpdrend'+<? echo $i?>] = '<? echo getByTagName($rendimento[0]->tags,'tpdrendi.'.$i); ?>';
				arrayRendimento['dsdrend'+<? echo $i?>] = '<? echo getByTagName($rendimento[1]->tags,'dsdrendi.'.$i); ?>';
				arrayRendimento['vldrend'+<? echo $i?>] = '<? echo getByTagName($rendimento[2]->tags,'vldrendi.'.$i); ?>';
												
			<?}?>
			
			arrayRendimento['vlsalari'] = '<? echo getByTagName($rendimento,'vlsalari'); ?>';
			arrayRendimento['vlsalcon'] = '<? echo getByTagName($rendimento,'vlsalcon'); ?>';
			arrayRendimento['nmextemp'] = '<? echo getByTagName($rendimento,'nmextemp'); ?>';
			arrayRendimento['perfatcl'] = '<? echo getByTagName($rendimento,'perfatcl'); ?>';
			arrayRendimento['vlmedfat'] = '<? echo getByTagName($rendimento,'vlmedfat'); ?>';
			arrayRendimento['inpessoa'] = '<? echo getByTagName($rendimento,'inpessoa'); ?>';
			arrayRendimento['flgconju'] = '<? echo getByTagName($rendimento,'flgconju'); ?>';
			arrayRendimento['nrctacje'] = '<? echo getByTagName($rendimento,'nrctacje'); ?>';
			arrayRendimento['nrcpfcjg'] = '<? echo getByTagName($rendimento,'nrcpfcjg'); ?>';
			arrayRendimento['flgdocje'] = '<? echo getByTagName($rendimento,'flgdocje'); ?>';
			arrayRendimento['vloutras'] = '<? echo getByTagName($rendimento,'vloutras'); ?>';
			arrayRendimento['vlalugue'] = '<? echo getByTagName($rendimento,'vlalugue'); ?>';
			arrayRendimento['inconcje'] = '<? echo getByTagName($rendimento,'inconcje'); ?>';
			
			inpessoa = '<? echo $inpessoa; ?>';
								
			var arrayBensAss = new Array();
														
			<?for($i=0; $i<count($regBensAssoc); $i++) {?>
			
				var arrayBem<? echo $i; ?> = new Object();
				arrayBem<? echo $i; ?>['dsrelbem'] = '<? echo getByTagName($regBensAssoc[$i]->tags,'dsrelbem'); ?>';
				arrayBem<? echo $i; ?>['cdsequen'] = '<? echo getByTagName($regBensAssoc[$i]->tags,'cdsequen'); ?>';
				arrayBem<? echo $i; ?>['persemon'] = '<? echo getByTagName($regBensAssoc[$i]->tags,'persemon'); ?>';
				arrayBem<? echo $i; ?>['qtprebem'] = '<? echo getByTagName($regBensAssoc[$i]->tags,'qtprebem'); ?>';
				arrayBem<? echo $i; ?>['vlprebem'] = '<? echo getByTagName($regBensAssoc[$i]->tags,'vlprebem'); ?>';
				arrayBem<? echo $i; ?>['vlrdobem'] = '<? echo getByTagName($regBensAssoc[$i]->tags,'vlrdobem'); ?>';
				arrayBem<? echo $i; ?>['cdcooper'] = '<? echo getByTagName($regBensAssoc[$i]->tags,'cdcooper'); ?>';
				arrayBem<? echo $i; ?>['nrdconta'] = '<? echo getByTagName($regBensAssoc[$i]->tags,'nrdconta'); ?>';
				arrayBem<? echo $i; ?>['idseqttl'] = '<? echo getByTagName($regBensAssoc[$i]->tags,'idseqttl'); ?>';
				arrayBem<? echo $i; ?>['dtmvtolt'] = '<? echo getByTagName($regBensAssoc[$i]->tags,'dtmvtolt'); ?>';
				arrayBem<? echo $i; ?>['cdoperad'] = '<? echo getByTagName($regBensAssoc[$i]->tags,'cdoperad'); ?>';
				arrayBem<? echo $i; ?>['dtaltbem'] = '<? echo getByTagName($regBensAssoc[$i]->tags,'dtaltbem'); ?>';
				arrayBem<? echo $i; ?>['idseqbem'] = '<? echo getByTagName($regBensAssoc[$i]->tags,'idseqbem'); ?>';
				arrayBem<? echo $i; ?>['nrdrowid'] = '<? echo getByTagName($regBensAssoc[$i]->tags,'nrdrowid'); ?>';
				arrayBem<? echo $i; ?>['nrcpfcgc'] = '<? echo getByTagName($regBensAssoc[$i]->tags,'nrcpfcgc'); ?>';
				
				arrayBensAss[<? echo $i; ?>] = arrayBem<? echo $i; ?>;
				
			<?}?>
			
			var arrayAvalistas = new Array();
			nrAvalistas    = "<?echo count($avalistas)?>";
			contAvalistas  = 0;
								
			<?for($i=0; $i<count($avalistas); $i++) {?>
			
				var arrayAvalista<? echo $i; ?> = new Object();
				arrayAvalista<? echo $i; ?>['nrctaava'] = '<? echo getByTagName($avalistas[$i]->tags,'nrctaava'); ?>';
				arrayAvalista<? echo $i; ?>['dsnacion'] = '<? echo getByTagName($avalistas[$i]->tags,'dsnacion'); ?>';
				arrayAvalista<? echo $i; ?>['tpdocava'] = '<? echo getByTagName($avalistas[$i]->tags,'tpdocava'); ?>';
				arrayAvalista<? echo $i; ?>['nmconjug'] = '<? echo getByTagName($avalistas[$i]->tags,'nmconjug'); ?>';
				arrayAvalista<? echo $i; ?>['tpdoccjg'] = '<? echo getByTagName($avalistas[$i]->tags,'tpdoccjg'); ?>';
				arrayAvalista<? echo $i; ?>['dsendre1'] = '<? echo getByTagName($avalistas[$i]->tags,'dsendre1'); ?>';
				arrayAvalista<? echo $i; ?>['nrfonres'] = '<? echo getByTagName($avalistas[$i]->tags,'nrfonres'); ?>';
				arrayAvalista<? echo $i; ?>['nmcidade'] = '<? echo getByTagName($avalistas[$i]->tags,'nmcidade'); ?>';
				arrayAvalista<? echo $i; ?>['nrcepend'] = '<? echo getByTagName($avalistas[$i]->tags,'nrcepend'); ?>';
				arrayAvalista<? echo $i; ?>['vlrenmes'] = '<? echo getByTagName($avalistas[$i]->tags,'vlrenmes'); ?>';
				arrayAvalista<? echo $i; ?>['nmdavali'] = '<? echo getByTagName($avalistas[$i]->tags,'nmdavali'); ?>';
				arrayAvalista<? echo $i; ?>['nrcpfcgc'] = '<? echo getByTagName($avalistas[$i]->tags,'nrcpfcgc'); ?>';
				arrayAvalista<? echo $i; ?>['nrdocava'] = '<? echo getByTagName($avalistas[$i]->tags,'nrdocava'); ?>';
				arrayAvalista<? echo $i; ?>['nrcpfcjg'] = '<? echo getByTagName($avalistas[$i]->tags,'nrcpfcjg'); ?>';
				arrayAvalista<? echo $i; ?>['nrdoccjg'] = '<? echo getByTagName($avalistas[$i]->tags,'nrdoccjg'); ?>';
				arrayAvalista<? echo $i; ?>['dsendre2'] = '<? echo getByTagName($avalistas[$i]->tags,'dsendre2'); ?>';
				arrayAvalista<? echo $i; ?>['dsdemail'] = '<? echo getByTagName($avalistas[$i]->tags,'dsdemail'); ?>';
				arrayAvalista<? echo $i; ?>['cdufresd'] = '<? echo getByTagName($avalistas[$i]->tags,'cdufresd'); ?>';
				arrayAvalista<? echo $i; ?>['vledvmto'] = '<? echo getByTagName($avalistas[$i]->tags,'vledvmto'); ?>';
				arrayAvalista<? echo $i; ?>['nrendere'] = '<? echo getByTagName($avalistas[$i]->tags,'nrendere'); ?>';
				arrayAvalista<? echo $i; ?>['complend'] = '<? echo getByTagName($avalistas[$i]->tags,'complend'); ?>';
				arrayAvalista<? echo $i; ?>['nrcxapst'] = '<? echo getByTagName($avalistas[$i]->tags,'nrcxapst'); ?>';
				
				arrayAvalista<? echo $i; ?>['inpessoa'] = '<? echo getByTagName($avalistas[$i]->tags,'inpessoa'); ?>'; // Daniel
				arrayAvalista<? echo $i; ?>['dtnascto'] = '<? echo getByTagName($avalistas[$i]->tags,'dtnascto'); ?>'; // Daniel
				
				var arrayBensAval = new Array();
			
				<? for($j = 0; $j<count($regBensAval); $j++){
						if( getByTagName($regBensAval[$j]->tags,'nrdconta') == getByTagName($avalistas[$i]->tags,'nrctaava') ){
						
						$identificador = $j.getByTagName($regBensAval[$j]->tags,'nrdconta');
						
						?>
												
						var arrayBemAval<? echo $identificador ?> = new Object();
						arrayBemAval<? echo $identificador; ?>['cdcooper'] = '<? echo getByTagName($regBensAval[$j]->tags,'cdcooper'); ?>';	
						arrayBemAval<? echo $identificador; ?>['nrdconta'] = '<? echo getByTagName($regBensAval[$j]->tags,'nrdconta'); ?>';   
						arrayBemAval<? echo $identificador; ?>['idseqttl'] = '<? echo getByTagName($regBensAval[$j]->tags,'idseqttl'); ?>';   
						arrayBemAval<? echo $identificador; ?>['dtmvtolt'] = '<? echo getByTagName($regBensAval[$j]->tags,'dtmvtolt'); ?>';   
						arrayBemAval<? echo $identificador; ?>['cdoperad'] = '<? echo getByTagName($regBensAval[$j]->tags,'cdoperad'); ?>';   
						arrayBemAval<? echo $identificador; ?>['dtaltbem'] = '<? echo getByTagName($regBensAval[$j]->tags,'dtaltbem'); ?>';   
						arrayBemAval<? echo $identificador; ?>['idseqbem'] = '<? echo getByTagName($regBensAval[$j]->tags,'idseqbem'); ?>';   
						arrayBemAval<? echo $identificador; ?>['dsrelbem'] = '<? echo getByTagName($regBensAval[$j]->tags,'dsrelbem'); ?>';   
						arrayBemAval<? echo $identificador; ?>['persemon'] = '<? echo getByTagName($regBensAval[$j]->tags,'persemon'); ?>';   
						arrayBemAval<? echo $identificador; ?>['qtprebem'] = '<? echo getByTagName($regBensAval[$j]->tags,'qtprebem'); ?>';   
						arrayBemAval<? echo $identificador; ?>['vlrdobem'] = '<? echo getByTagName($regBensAval[$j]->tags,'vlrdobem'); ?>';   
						arrayBemAval<? echo $identificador; ?>['vlprebem'] = '<? echo getByTagName($regBensAval[$j]->tags,'vlprebem'); ?>';   
						arrayBemAval<? echo $identificador; ?>['nrdrowid'] = '<? echo getByTagName($regBensAval[$j]->tags,'nrdrowid'); ?>';   
						arrayBemAval<? echo $identificador; ?>['nrcpfcgc'] = '<? echo getByTagName($regBensAval[$j]->tags,'nrcpfcgc'); ?>';   
											
						arrayBensAval[<? echo $j; ?>] = arrayBemAval<? echo $identificador; ?>;
										
					<?}
				}?>				
				
				arrayAvalista<? echo $i; ?>['bensaval'] = arrayBensAval ;
																								
				arrayAvalistas[<? echo $i; ?>] = arrayAvalista<? echo $i; ?>;
			<?}?>
									
			var arrayAlienacoes = new Array();
			nrAlienacao    = "<?echo count($alienacoes)?>";
			contAlienacao  = 0;
								
			<?for($i=0; $i<count($alienacoes); $i++) {?>
			
				var arrayAlienacao<? echo $i; ?> = new Object();
				arrayAlienacao<? echo $i; ?>['lsbemfin'] = '<? echo getByTagName($alienacoes[$i]->tags,'lsbemfin'); ?>';
				arrayAlienacao<? echo $i; ?>['dscatbem'] = '<? echo getByTagName($alienacoes[$i]->tags,'dscatbem'); ?>';
				arrayAlienacao<? echo $i; ?>['dsbemfin'] = '<? echo getByTagName($alienacoes[$i]->tags,'dsbemfin'); ?>';
				arrayAlienacao<? echo $i; ?>['dscorbem'] = '<? echo getByTagName($alienacoes[$i]->tags,'dscorbem'); ?>';
				arrayAlienacao<? echo $i; ?>['dschassi'] = '<? echo getByTagName($alienacoes[$i]->tags,'dschassi'); ?>';
				arrayAlienacao<? echo $i; ?>['nranobem'] = '<? echo getByTagName($alienacoes[$i]->tags,'nranobem'); ?>';
				arrayAlienacao<? echo $i; ?>['nrmodbem'] = '<? echo getByTagName($alienacoes[$i]->tags,'nrmodbem'); ?>';
				arrayAlienacao<? echo $i; ?>['nrdplaca'] = '<? echo getByTagName($alienacoes[$i]->tags,'nrdplaca'); ?>';
				arrayAlienacao<? echo $i; ?>['nrrenava'] = '<? echo getByTagName($alienacoes[$i]->tags,'nrrenava'); ?>';
				arrayAlienacao<? echo $i; ?>['tpchassi'] = '<? echo getByTagName($alienacoes[$i]->tags,'tpchassi'); ?>';
				arrayAlienacao<? echo $i; ?>['ufdplaca'] = '<? echo getByTagName($alienacoes[$i]->tags,'ufdplaca'); ?>';
				arrayAlienacao<? echo $i; ?>['nrcpfbem'] = '<? echo getByTagName($alienacoes[$i]->tags,'nrcpfbem'); ?>';
				arrayAlienacao<? echo $i; ?>['dscpfbem'] = '<? echo getByTagName($alienacoes[$i]->tags,'dscpfbem'); ?>';
				arrayAlienacao<? echo $i; ?>['vlmerbem'] = '<? echo getByTagName($alienacoes[$i]->tags,'vlmerbem'); ?>';
				arrayAlienacao<? echo $i; ?>['idalibem'] = '<? echo getByTagName($alienacoes[$i]->tags,'idalibem'); ?>';
								
				arrayAlienacoes[<? echo $i; ?>] = arrayAlienacao<? echo $i; ?>;
				
			<?}?>
			
			var arrayIntervs = new Array();
			nrIntervis       = "<?echo count($intervs)?>";
			contIntervis     = 0;
								
			<?for($i=0; $i<count($intervs); $i++) {?>
			
				var arrayInterv<? echo $i; ?> = new Object();
				arrayInterv<? echo $i; ?>['nrctaava'] = '<? echo getByTagName($intervs[$i]->tags,'nrctaava'); ?>';
				arrayInterv<? echo $i; ?>['dsnacion'] = '<? echo getByTagName($intervs[$i]->tags,'dsnacion'); ?>';
				arrayInterv<? echo $i; ?>['tpdocava'] = '<? echo getByTagName($intervs[$i]->tags,'tpdocava'); ?>';
				arrayInterv<? echo $i; ?>['nmconjug'] = '<? echo getByTagName($intervs[$i]->tags,'nmconjug'); ?>';
				arrayInterv<? echo $i; ?>['tpdoccjg'] = '<? echo getByTagName($intervs[$i]->tags,'tpdoccjg'); ?>';
				arrayInterv<? echo $i; ?>['dsendre1'] = '<? echo getByTagName($intervs[$i]->tags,'dsendlog'); ?>';
				arrayInterv<? echo $i; ?>['nrfonres'] = '<? echo getByTagName($intervs[$i]->tags,'nrfonres'); ?>';
				arrayInterv<? echo $i; ?>['nmcidade'] = '<? echo getByTagName($intervs[$i]->tags,'nmcidade'); ?>';
				arrayInterv<? echo $i; ?>['nrcepend'] = '<? echo getByTagName($intervs[$i]->tags,'nrcepend'); ?>';
				arrayInterv<? echo $i; ?>['vlrenmes'] = '<? echo getByTagName($intervs[$i]->tags,'vlrenmes'); ?>';
				arrayInterv<? echo $i; ?>['nmdavali'] = '<? echo getByTagName($intervs[$i]->tags,'nmdavali'); ?>';
				arrayInterv<? echo $i; ?>['nrcpfcgc'] = '<? echo getByTagName($intervs[$i]->tags,'nrcpfcgc'); ?>';
				arrayInterv<? echo $i; ?>['nrdocava'] = '<? echo getByTagName($intervs[$i]->tags,'nrdocava'); ?>';
				arrayInterv<? echo $i; ?>['nrcpfcjg'] = '<? echo getByTagName($intervs[$i]->tags,'nrcpfcjg'); ?>';
				arrayInterv<? echo $i; ?>['nrdoccjg'] = '<? echo getByTagName($intervs[$i]->tags,'nrdoccjg'); ?>';
				arrayInterv<? echo $i; ?>['dsendre2'] = '<? echo getByTagName($intervs[$i]->tags,'dsbarlog'); ?>';
				arrayInterv<? echo $i; ?>['dsdemail'] = '<? echo getByTagName($intervs[$i]->tags,'dsdemail'); ?>';
				arrayInterv<? echo $i; ?>['cdufresd'] = '<? echo getByTagName($intervs[$i]->tags,'cdufresd'); ?>';
				arrayInterv<? echo $i; ?>['vledvmto'] = '<? echo getByTagName($intervs[$i]->tags,'vledvmto'); ?>';
				arrayInterv<? echo $i; ?>['nrendere'] = '<? echo getByTagName($intervs[$i]->tags,'nrendere'); ?>';
				arrayInterv<? echo $i; ?>['complend'] = '<? echo getByTagName($intervs[$i]->tags,'complend'); ?>';
				arrayInterv<? echo $i; ?>['nrcxapst'] = '<? echo getByTagName($intervs[$i]->tags,'nrcxapst'); ?>';
				
				
				
				arrayIntervs[<? echo $i; ?>] = arrayInterv<? echo $i; ?>;
				
			<?}?>
			
			var arrayProtCred = new Object();
			
			arrayProtCred['nrperger'] = '<? echo getByTagName($analise,'nrperger'); ?>';
			arrayProtCred['dsperger'] = '<? echo getByTagName($analise,'dsperger'); ?>';     
			arrayProtCred['dtcnsspc'] = '<? echo getByTagName($analise,'dtcnsspc'); ?>';     
			arrayProtCred['nrinfcad'] = '<? echo getByTagName($analise,'nrinfcad'); ?>';     
			arrayProtCred['dsinfcad'] = '<? echo getByTagName($analise,'dsinfcad'); ?>';     
			arrayProtCred['dtdrisco'] = '<? echo getByTagName($analise,'dtdrisco'); ?>';     
			arrayProtCred['vltotsfn'] = '<? echo getByTagName($analise,'vltotsfn'); ?>';     
			arrayProtCred['qtopescr'] = '<? echo getByTagName($analise,'qtopescr'); ?>';     
			arrayProtCred['qtifoper'] = '<? echo getByTagName($analise,'qtifoper'); ?>';     
			arrayProtCred['nrliquid'] = '<? echo getByTagName($analise,'nrliquid'); ?>';     
			arrayProtCred['dsliquid'] = '<? echo getByTagName($analise,'dsliquid'); ?>';     
			arrayProtCred['vlopescr'] = '<? echo getByTagName($analise,'vlopescr'); ?>';     
			arrayProtCred['vlrpreju'] = '<? echo getByTagName($analise,'vlrpreju'); ?>';     
			arrayProtCred['nrpatlvr'] = '<? echo getByTagName($analise,'nrpatlvr'); ?>';     
			arrayProtCred['dspatlvr'] = '<? echo getByTagName($analise,'dspatlvr'); ?>';     
			arrayProtCred['nrgarope'] = '<? echo getByTagName($analise,'nrgarope'); ?>';    
			arrayProtCred['dsgarope'] = '<? echo getByTagName($analise,'dsgarope'); ?>';
			arrayProtCred['dtoutspc'] = '<? echo getByTagName($analise,'dtoutspc'); ?>';
			arrayProtCred['dtoutris'] = '<? echo getByTagName($analise,'dtoutris'); ?>';
			arrayProtCred['vlsfnout'] = '<? echo getByTagName($analise,'vlsfnout'); ?>';
			arrayProtCred['flgcentr'] = '<? echo getByTagName($analise,'flgcentr'); ?>';
			arrayProtCred['flgcoout'] = '<? echo getByTagName($analise,'flgcoout'); ?>';
			
			var arrayHipotecas = new Array();
			nrHipotecas      = "<?echo count($hipotecas)?>";
			contHipotecas    = 0;
								
			<?for($i=0; $i<count($hipotecas); $i++) {?>
			
				var arrayHipoteca<? echo $i; ?> = new Object();
				arrayHipoteca<? echo $i; ?>['lsbemfin'] = '<? echo getByTagName($hipotecas[$i]->tags,'lsbemfin'); ?>';
				arrayHipoteca<? echo $i; ?>['dscatbem'] = '<? echo getByTagName($hipotecas[$i]->tags,'dscatbem'); ?>';
				arrayHipoteca<? echo $i; ?>['dsbemfin'] = '<? echo getByTagName($hipotecas[$i]->tags,'dsbemfin'); ?>';
				arrayHipoteca<? echo $i; ?>['dscorbem'] = '<? echo getByTagName($hipotecas[$i]->tags,'dscorbem'); ?>';
				arrayHipoteca<? echo $i; ?>['idseqhip'] = '<? echo getByTagName($hipotecas[$i]->tags,'idseqhip'); ?>';
				arrayHipoteca<? echo $i; ?>['vlmerbem'] = '<? echo getByTagName($hipotecas[$i]->tags,'vlmerbem'); ?>';
				
				arrayHipotecas[<? echo $i; ?>] = arrayHipoteca<? echo $i; ?>;
				
			<?}?>
			
			var arrayFaturamentos = new Array();
														
			<?for($i=0; $i<count($faturamentos); $i++) {?>
			
				var arrayFaturamento<? echo $i; ?> = new Object();
				arrayFaturamento<? echo $i; ?>['mesftbru'] = '<? echo getByTagName($faturamentos[$i]->tags,'mesftbru'); ?>';
				arrayFaturamento<? echo $i; ?>['anoftbru'] = '<? echo getByTagName($faturamentos[$i]->tags,'anoftbru'); ?>';
				arrayFaturamento<? echo $i; ?>['vlrftbru'] = '<? echo getByTagName($faturamentos[$i]->tags,'vlrftbru'); ?>';
				arrayFaturamento<? echo $i; ?>['nrposext'] = '<? echo getByTagName($faturamentos[$i]->tags,'nrposext'); ?>';
				arrayFaturamento<? echo $i; ?>['cdoperad'] = '<? echo getByTagName($faturamentos[$i]->tags,'cdoperad'); ?>';
				arrayFaturamento<? echo $i; ?>['nmoperad'] = '<? echo getByTagName($faturamentos[$i]->tags,'nmoperad'); ?>';
				arrayFaturamento<? echo $i; ?>['dtaltjfn'] = '<? echo getByTagName($faturamentos[$i]->tags,'dtaltjfn'); ?>';
				arrayFaturamento<? echo $i; ?>['nrdrowid'] = '<? echo getByTagName($faturamentos[$i]->tags,'nrdrowid'); ?>';
				
				arrayFaturamentos[<? echo $i; ?>] = arrayFaturamento<? echo $i; ?>;
				
			<?}?>
							
			</script><?
		
		}
	}else if (in_array($operacao,array('C_PAG_PREST','C_DESCONTO'))){

		$xml = "<Root>";
		$xml .= "	<Cabecalho>";
		$xml .= "		<Bo>b1wgen0084a.p</Bo>";
		$xml .= "		<Proc>".$procedure."</Proc>";
		$xml .= "	</Cabecalho>";
		$xml .= "	<Dados>";
		$xml .= "       <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
		$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
		$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
		$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";	
		$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
		$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "		<idseqttl>".$idseqttl."</idseqttl>";
		$xml .= "		<nrctremp>".$nrctremp."</nrctremp>";
		$xml .= "		<nrparepr>".$nrparepr."</nrparepr>";
		$xml .= "		<vlpagpar>".$vlpagpar."</vlpagpar>";
		$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
		$xml .= "		<flgerlog>TRUE</flgerlog>";
		$xml .= "	</Dados>";
		$xml .= "</Root>";
		
		$xmlResult = getDataXML($xml);
		
		$xmlObjeto = getObjectXML($xmlResult);

		if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
			exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos',"controlaOperacao('')",false);
		}
		
		if (in_array($operacao,array('C_PAG_PREST'))){ 
			$prestacoes = $xmlObjeto->roottag->tags[0]->tags;
		
			$calculado =  $xmlObjeto->roottag->tags[1]->tags;
		}
		else {
		
			$descontos = $xmlObjeto->roottag->tags[0]->tags;
			
			for($i=0; $i < count($descontos); $i++) {
			
				 $nr_parcela = getByTagName($descontos[$i]->tags,'nrparepr');
				 $vldespar = number_format(str_replace(",",".",getByTagName($descontos[$i]->tags,'vldespar')),2,",",".");
				 
				 echo "$('#vldespar_' + $nr_parcela ,'#divTabela').html(' $vldespar ');";

			}			
		
		}
		
	}
	else if(in_array($operacao,array('C_TRANSF_PREJU','C_DESFAZ_PREJU'))) {
	
			$xml .= "<Root>";
			$xml .= "	<Cabecalho>";
			$xml .= "		<Bo>b1wgen0084.p</Bo>";
			$xml .= "		<Proc>".$procedure."</Proc>";
			$xml .= "	</Cabecalho>";
			$xml .= "	<Dados>";
			$xml .= "       <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
			$xml .= "		<cdagenci>".$glbvars["cdpactra"]."</cdagenci>";
			$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
			$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
			$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
			$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
			$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
			$xml .= "		<idseqttl>".$idseqttl."</idseqttl>";
			$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
			$xml .= "		<dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";
			$xml .= "		<flgerlog>true</flgerlog>";
			$xml .= "		<nrctremp>".$nrctremp."</nrctremp>";
			$xml .= "		<inproces>".$glbvars["inproces"]."</inproces>";
			$xml .= "		<cdprogra>'ATENDA'</cdprogra>";
			$xml .= "	</Dados>";
			$xml .= "</Root>";
			
			// Executa script para envio do XML
			$xmlResult = getDataXML($xml);
			
			// Cria objeto para classe de tratamento de XML
			$xmlObj = getObjectXML($xmlResult);
			
			if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
				exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos',"controlaOperacao('')",false);
			}
		
	}
	else if(in_array($operacao,array('D_EFETIVA', 'TD_EFETIVA'))) {
		// Monta o xml de requisição
		if($operacao == 'D_EFETIVA') {
			$procedure = 'busca_desfazer_efetivacao_emprestimo';
		}else if($operacao == 'TD_EFETIVA') {
			$procedure = 'desfaz_efetivacao_emprestimo';
		}
		
		$xml .= "<Root>";
		$xml .= "	<Cabecalho>";
		$xml .= "		<Bo>b1wgen0084.p</Bo>";
		$xml .= "		<Proc>".$procedure."</Proc>";
		$xml .= "	</Cabecalho>";
		$xml .= "	<Dados>";
		$xml .= "       <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xml .= "		<cdagenci>".$glbvars["cdpactra"]."</cdagenci>";
		$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
		$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
		$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
		$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
		$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "		<idseqttl>".$idseqttl."</idseqttl>";
		$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
		$xml .= "		<flgerlog>true</flgerlog>";
		$xml .= "		<nrctremp>".$nrctremp."</nrctremp>";
		$xml .= "		<cdprogra>'ATENDA'</cdprogra>";
		$xml .= "	</Dados>";
		$xml .= "</Root>";
		
		// Executa script para envio do XML
		$xmlResult = getDataXML($xml);
		
		// Cria objeto para classe de tratamento de XML
		$xmlObj = getObjectXML($xmlResult);
		
		if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
			exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos',"controlaOperacao('')",false);
		}
	} else if(in_array($operacao,array('C_LIQ_MESMO_DIA'))) {
	
		// Montar o xml de Requisicao
		
		$xml .= "<Root>";
		$xml .= "	<Dados>";
		$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "		<idseqttl>".$idseqttl."</idseqttl>";
		$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
		$xml .= "		<flgerlog>S</flgerlog>";
		$xml .= "		<nrctremp>".$nrctremp."</nrctremp>";
		$xml .= "	</Dados>";
		$xml .= "</Root>";
	    
		$xmlResult = mensageria($xml, "ATENDA", "LIQ_MESMO_DIA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObj = getObjectXML($xmlResult);
		
		//-----------------------------------------------------------------------------------------------
		// Controle de Erros
		//-----------------------------------------------------------------------------------------------

		if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
			$msgErro = $xmlObj->roottag->tags[0]->cdata;
			if($msgErro == null || $msgErro == ''){
				$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
			}
			exibirErro('error',$msgErro,'Alerta - Ayllos','bloqueiaFundo(divRotina);prejuizoRetorno();',false);
			
			exit();
		}
	} else if(in_array($operacao,array('C_PREJU'))) {
		// Classificacao de Risco
		// Montar o xml para requisicao
		$xml  = "";
		$xml .= "<Root>";
		$xml .= " <Dados>";
		$xml .= "    <cdcooper>".$glbvars['cdcooper']."</cdcooper>";
		$xml .= "    <nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "    <nrctremp>".$nrctremp."</nrctremp>";
		$xml .= " </Dados>";
		$xml .= "</Root>";

		$xmlResult = mensageria($xml, "PARRAC", "RETORNA_DESCRICAO_RISCO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xml_dados = simplexml_load_string($xmlResult);

		if ($xml_dados->instatus == '') {
			$tpdrisco = 'Não se aplica';
		} elseif ($xml_dados->instatus == '1') {
			$tpdrisco = 'Risco de Crédito';
		} else {
			$tpdrisco = 'Risco Operacional';
		}

		?><script type="text/javascript">
		arrayRegistros['tpdrisco'] = '<? echo $tpdrisco; ?>';
		</script><?
    }
	
	$qtregist	= $xmlObjeto->roottag->tags[0]->attributes['QTREGIST'];
	
	if(in_array($operacao,array('TC'))) {
		include('form_prestacoes.php');
	} else if(in_array($operacao,array('C_PREJU'))) {
		include('form_prejuizo.php');
	} else if(in_array($operacao,array('C_EXTRATO'))) {
		include('tabela_extrato.php');
	} else if(in_array($operacao,array('C_NOVA_PROP','C_NOVA_PROP_V'))) {
		include('form_nova_prop.php');
	} else if(in_array($operacao,array(''))) {
		include('tab_prestacoes.php');
	} else if (in_array($operacao,array('C_COMITE_APROV'))){
		include('form_comite_aprov.php');
	}else if (in_array($operacao,array('C_DADOS_PROP'))){
		include('form_dados_prop.php');
	}else if (in_array($operacao,array('C_DADOS_PROP_PJ'))){
		include('form_dados_prop_pj.php');
	}else if (in_array($operacao,array('C_DADOS_AVAL'))){
		include('form_dados_aval.php');
	} else if (in_array($operacao,array('C_PROTECAO_TIT','C_PROTECAO_AVAL','C_PROTECAO_CONJ','C_PROTECAO_SOC'))) {
		include ('../../../../includes/consultas_automatizadas/form_orgaos.php');
	} else if (in_array($operacao,array('C_ALIENACAO','AI_ALIENACAO','A_ALIENACAO','E_ALIENACAO','I_ALIENACAO','IA_ALIENACAO'))){
		include('form_alienacao.php');
	}else if (in_array($operacao,array('C_INTEV_ANU'))){
		include('form_intev_anuente.php');
	}else if (in_array($operacao,array('C_PROT_CRED'))){
		include('form_org_prot_cred.php');
	}else if (in_array($operacao,array('C_HIPOTECA'))){
		include('form_hipoteca.php');
	}else if (in_array($operacao,array('C_PAG_PREST'))){
		include('tabela_pagamento.php');
	} else if (in_array($operacao,array('C_MICRO_PERG'))) {
		include ('questionario.php');
	} else if (in_array($operacao,array('PORTAB_CRED_C'))) {
		include('../../emprestimos/portabilidade/portabilidade.php');                
	}
	
	if ((in_array($operacao,array('C_TRANSF_PREJU','C_DESFAZ_PREJU')))) {
?>	
	<script type="text/javascript">
		hideMsgAguardo();
		
		var msgAlert = 'Operacao Efetuada com Sucesso!';
		
		showError('inform',msgAlert,'Alerta - Ayllos','bloqueiaFundo(divRotina);prejuizoRetorno();');
			
	</script>
<? }

	if ((in_array($operacao,array('C_LIQ_MESMO_DIA')))) {

		echo 'showError("inform","Operacao Efetuada com Sucesso!.","Notifica&ccedil;&atilde;o - Ayllos","bloqueiaFundo(divRotina);prejuizoRetorno();");';	
		
	}
	
	if (!(in_array($operacao,array('C_DESCONTO','C_TRANSF_PREJU','C_DESFAZ_PREJU','C_LIQ_MESMO_DIA')))) {
?>	
	<script type="text/javascript">
		var operacao = '<? echo $operacao; ?>';
		var prejuizo = '<? echo $prejuizo; ?>';
		
		atualizaTela(operacao);
		
		controlaLayout(operacao);
		
		if (operacao == 'TC' && arrayRegistros['vlprovis'] > 0 ){
			var msgAlert = ' Valor provisionado no cheque sal&aacute;rio: ' +arrayRegistros['vlprovis'];
		
			showError('inform',msgAlert,'Alerta - Ayllos','bloqueiaFundo(divRotina);');
		}
		
		if ( operacao == 'TC_V' ){ controlaOperacao('TC'); }
		else if ( operacao == 'D_EFETIVA' ){ controlaOperacao('E_EFETIVA'); }
		else if ( operacao == 'TD_EFETIVA' ){ controlaOperacao(''); }
		hideMsgAguardo();
		bloqueiaFundo($('#divRotina'));
	</script>
<? } ?>

<?php
	function retiraCharEsp($valor){
		$valor = str_replace("\n", ' ',$valor);
		$valor = str_replace("\r",'',$valor);
		$valor = str_replace("'","" ,$valor);
		$valor = str_replace("\\","" ,$valor);
		return $valor;
	}
?>
