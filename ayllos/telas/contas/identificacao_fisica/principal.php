<?php
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : Fevereiro/2010 
 * OBJETIVO     : Mostrar opcao Principal da rotina de IDENTIFICAÇÃO FÍSICA da tela de CONTAS 
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 001: [25/03/2010] Rodolpho Telmo  (DB1): Adequação ao novo padrão
 * 002: [20/12/2010] Gabriel Capoia  (DB1): Chamada função validaPermissao
 * 003: [11/06/2012] Adriano			  : Alimentado as variaveis UrlImages, cdhabmen, nrdeanos,estadoCivil.
 * 004: [15/10/2015] Gabriel(RKAM)        : Reformulacao cadastral.
 * 005: [13/07/2016] Carlos R.	: Correcao do uso de variaveis do array $_POST. SD 479874.
 * 006: [20/07/2017] Andrey F.	: Correcao no "continuar" após criar conta na tela MATRIC. SD 715817
 */

	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();
	
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
	$flgcadas = (isset($_POST['flgcadas'])) ? $_POST['flgcadas'] : '';

	$glbvars["nmrotina"] = (isset($_POST['nmrotina'])) ? $_POST['nmrotina'] : $glbvars["nmrotina"];
	
	// Dependendo da operacao, preencho a variável $cddopcao
	if ( $operacao == 'CA' || $operacao == 'BA' ) { 
		$cddopcao = 'A';
	} else if ( $operacao == 'CI' || $operacao == 'BI' ) { 
		$cddopcao = 'I';
	} else {
		$cddopcao = 'C';
	}
	
	$op = ( $cddopcao == 'C' ) ? '@' : $cddopcao ;
	
	// Verifica permissões de acessa a tela
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$op,false)) <> '') {
		$metodo =  ($flgcadas == 'M') ? 'proximaRotina();' : 'encerraRotina(false);';
		exibirErro('error',$msgError,'Alerta - Ayllos',$metodo,false);
	}
	
	// Verifica se o número da conta foi informado
	if (!isset($_POST['nrdconta']) || !isset($_POST['idseqttl'])) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);

	
	// Carrega permissões do operador
	include("../../../includes/carrega_permissoes.php");
	
	setVarSession("opcoesTela",$opcoesTela);

	// Carregas as opções da Rotina de Identificacao
	$flgAlterar  = (in_array("A", $glbvars["opcoesTela"]));
	$flgIncluir  = (in_array("I", $glbvars["opcoesTela"]));
	
	// Recebo os parâmetros do POST em variáveis	
	$nrcpfcgc = ( isset($_POST['nrcpfcgc']) )   ? $_POST['nrcpfcgc'] : '';	
	$nrdconta = ( isset($_POST['nrdconta']) )  ? $_POST['nrdconta'] : 0;
	$idseqttl   = ( isset($_POST['idseqttl']) )    ? $_POST['idseqttl']   : 0;
	$cdgraupr = ( isset($_POST['cdgraupr']) )  ? $_POST['cdgraupr'] : '';
		
	// Verifica se o número da conta e o titular são inteiros válidos
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
	if (!validaInteiro($idseqttl)) exibirErro('error','Seq. Titular n&atilde;o foi informada.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);	
		
	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0055.p</Bo>';
	$xml .= '		<Proc>busca_dados</Proc>';
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
	$xml .= '		<nrcpfcgc>'.$nrcpfcgc.'</nrcpfcgc>';
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';
	$xml .= '		<cdgraupr>'.$cdgraupr.'</cdgraupr>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	$xmlResult   = getDataXML($xml);	
	$xmlObjeto   = getObjectXML($xmlResult);	
	$IdentFisica = $xmlObjeto->roottag->tags[0]->tags[0]->tags;
		
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
		exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','bloqueiaFundo(divRotina);controlaFoco();',false);
	}
	
	// Se não retornou erro, então pegar a mensagem de alerta do Progress na variável msgAlert, para ser utilizada posteriormente
	$msgAlert = trim($xmlObjeto->roottag->tags[0]->attributes['MSGALERT']);	
	
	
	
?>
<script type='text/javascript'>
	$('#divConteudoOpcao').css({'-moz-opacity':'0','filter':'alpha(opacity=0)','opacity':'0'});
</script>
<?	
	include('formulario_identificacao_fisica.php');
?>
<script type='text/javascript'>

	// Declara os flags para as opções da Rotina de Bens
	var flgAlterar   = "<? echo $flgAlterar;   ?>";
	var flgIncluir   = "<? echo $flgIncluir;   ?>";
	var flgcadas     = "<? echo $flgcadas;     ?>";
		
	msgAlert    = '<? echo $msgAlert; ?>';
	operacao    = '<? echo $operacao; ?>';
	UrlImagens  = '<? echo $UrlImagens; ?>';
	cdhabmen    = '<? echo getByTagName($IdentFisica,"inhabmen"); ?>';
	nrdeanos    = '<? echo getByTagName($IdentFisica,"nrdeanos"); ?>';
	dtmvtolt    = '<?echo $glbvars['dtmvtolt']?>';
	estadoCivil =  '<? echo getByTagName($IdentFisica,"cdestcvl"); ?>';
		
	controlaLayout(operacao);
	
	if ( msgAlert != '' ) { 
		showError('inform',msgAlert,'Alerta - Ayllos','bloqueiaFundo(divRotina);controlaFoco(operacao);');
	}else{
		controlaFoco();
	}
</script>
