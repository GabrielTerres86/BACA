<?php 
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 24/05/2010 
 * OBJETIVO     : Mostrar opcao Principal da rotina de Comercial da tela de CONTAS 
 * ALTERACOES   : 20/12/2010 - Adicionado chamada validaPermissao (Gabriel - DB1).
 *								09/12/2011 - Ajuste para inclusao do campo Justificativa (Adriano).
 *								18/12/2013 - Ajuste em casas flutuantes dos valores dos rendimentos. (Jorge)
 *								18/08/2015 - Reformulacao cadastral (Gabriel-RKAM)
 *								03/12/2015 - Gravar valores dos rendimentos corretamente nas variaveis (Gabriel-RKAM).
 *								14/07/2016 - Correcao no uso de variaveis nao declaradas oque gerava erro no LOG. SD 479874. Carlos R.
 */

	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');	
	require_once('../../../class/xmlfile.php');
	isPostMethod();				
	
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
	$flgcadas  = (isset($_POST['flgcadas'])) ? $_POST['flgcadas'] : '';	
	$opcao     = (isset($_POST['opcao']))    ? $_POST['opcao']    : '';
	// variaveis passadas para o Javascript
	$msgConta  = ( isset($msgConta) ) ? $msgConta : '';
	$flgAlterar = false;

	$glbvars["nmrotina"] = (isset($_POST['nmrotina'])) ? $_POST['nmrotina'] : $glbvars["nmrotina"];
	
	// Monta o "cddopcao" de acordo com a operação
	$cddopcao = ( $operacao == 'CA' || $operacao == 'CAE' ) ? 'A' : 'C';
	$op       = ( $cddopcao == 'C' ) ? '@' : $cddopcao ;
	
	// Verifica se o número da conta foi informado
	if (!isset($_POST['nrdconta']) || !isset($_POST['idseqttl'])) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos','fechaRotina(divRotina)',false);

	if ( isset($opcoesTela) ) {
		setVarSession("opcoesTela",$opcoesTela);
	}

	if ( isset($glbvars["opcoesTela"]) ) {
		// Carregas as opções da Rotina de Bens
		$flgAlterar  = (in_array("A", $glbvars["opcoesTela"]));
	}

	// Guardo os parâmetos do POST em variáveis	
	$nrdconta = $_POST['nrdconta'] == '' ?  0  : $_POST['nrdconta'];
	$idseqttl = $_POST['idseqttl'] == '' ?  0  : $_POST['idseqttl'];
	$cooperativa = $glbvars['cdcooper'];
			
	// Verifica se o número da conta e o titular são inteiros válidos
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','fechaRotina(divRotina)',false);
	if (!validaInteiro($idseqttl)) exibirErro('error','Seq.Ttl n&atilde;o foi informada.','Alerta - Ayllos','fechaRotina(divRotina)',false);
	
	// tratamento para as variaveis passadas ao XML que nao possuem declaracao gerando erro no LOG
	$nrdrowid		= ( isset($nrdrowid) )	? $nrdrowid : 0;
	$cdnatopc	= ( isset($cdnatopc) )	? $cdnatopc : 0;
	$cdocpttl		= ( isset($cdocpttl) )		? $cdocpttl : 0;
	$tpcttrab		= ( isset($tpcttrab) )		? $tpcttrab : '';
	$nmdsecao = ( isset($nmdsecao) ) ? $nmdsecao : '';
	$cdempres	= ( isset($cdempres) ) ? $cdempres : 0;
	$dsproftl		= ( isset($dsproftl) )		? $dsproftl : '';
	$cdnvlcgo	= ( isset($cdnvlcgo) )	? $cdnvlcgo : 0;
	$cdturnos		= ( isset($cdturnos) )	? $cdturnos : 0;
	$dtadmemp	= ( isset($dtadmemp) ) ? $dtadmemp : '';
	$nrcadast		= ( isset($nrcadast) )	? $nrcadast : 0;
	$inpolexp		= ( isset($inpolexp) )	? $inpolexp : '';
	
	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0075.p</Bo>';
	$xml .= '		<Proc>Busca_Dados_PPE</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
	$xml .= '		<nrdrowid>'.$nrdrowid.'</nrdrowid>';	
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';	
	$xml .= '		<cdnatopc>'.$cdnatopc.'</cdnatopc>';
	$xml .= '		<cdocpttl>'.$cdocpttl.'</cdocpttl>';
	$xml .= '		<tpcttrab>'.$tpcttrab.'</tpcttrab>';
	$xml .= '		<nmdsecao>'.$nmdsecao.'</nmdsecao>';
	$xml .= '		<cdempres>'.$cdempres.'</cdempres>';	
	$xml .= '		<dsproftl>'.$dsproftl.'</dsproftl>';	
	$xml .= '		<cdnvlcgo>'.$cdnvlcgo.'</cdnvlcgo>';	
	$xml .= '		<cdturnos>'.$cdturnos.'</cdturnos>';	
	$xml .= '		<dtadmemp>'.$dtadmemp.'</dtadmemp>';	
	$xml .= '		<nrcadast>'.$nrcadast.'</nrcadast>';
	$xml .= '		<inpolexp>'.$inpolexp.'</inpolexp>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	$xmlResult = getDataXML($xml);	
	$xmlObjeto = getObjectXML($xmlResult);	
	
	// Se ocorrer um erro, mostra mensagem
	if (isset($xmlObjeto->roottag->tags[0]->name) && strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') 
		exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','fechaRotina(divRotina);',false);	
	
	$ppe = $xmlObjeto->roottag->tags[0]->tags[0]->tags;	
	$msgAlert  = ( isset($xmlObjeto->roottag->tags[0]->attributes['MSGALERT']) ) ? trim($xmlObjeto->roottag->tags[0]->attributes['MSGALERT']) : '';

	$tpexposto        = getByTagName($ppe,'tpexposto');
	$cdocupacao       = getByTagName($ppe,'cdocupacao');
	$cdrelacionamento = getByTagName($ppe,'cdrelacionamento');
	$dtinicio         = getByTagName($ppe,'dtinicio');
	$dttermino        = getByTagName($ppe,'dttermino');
	$nmempresa        = getByTagName($ppe,'nmempresa');
	$nrcnpj_empresa   = getByTagName($ppe,'nrcnpj_empresa');
	$nmpolitico       = getByTagName($ppe,'nmpolitico');
	$nrcpf_politico   = getByTagName($ppe,'nrcpf_politico');
	$inpolexp         = getByTagName($ppe,'inpolexp');
	$nmextttl         = getByTagName($ppe,'nmextttl');
	$nrcpfcgc         = getByTagName($ppe,'nrcpfcgc');

	include('formulario_ppe.php');
?>
<script type='text/javascript'>
	var msgAlert = '<? echo $msgAlert ?>';
	var msgConta = '<? echo $msgConta ?>';
	var operacao = '<? echo $operacao ?>';
	
	if (inpessoa == 1) {
		var flgAlterar   = '<? echo $flgAlterar;   ?>';
		var flgcadas     = '<? echo $flgcadas;     ?>';
		var cooperativa  = '<? echo $cooperativa;  ?>';
		var opcao        = '<? echo $opcao;  ?>';
				
		if (flgcadas == 'M' && operacao == '') {
			controlaOperacao('CA');
		}
		
	}			

	controlaLayout(operacao);
	
	if ( msgConta != '' ) { 
		showError('inform',msgConta,'Alerta - Ayllos','bloqueiaFundo(divRotina);controlaFoco(\''+operacao+'\');');
	}else if ( msgAlert != '' ) { 
		showError('inform',msgAlert,'Alerta - Ayllos','bloqueiaFundo(divRotina);controlaFoco(\''+operacao+'\');');
	}
	
</script>
