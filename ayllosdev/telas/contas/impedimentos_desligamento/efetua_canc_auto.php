<? 
/*!
 * FONTE        : efetua_canc_auto.php
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : Junho/2017
 * OBJETIVO     : Efetuar o cancelamento automático de produtos
 * --------------
 * ALTERAÇÕES   : 18/11/2017 - Ajuste para recarregar a tela quando encontrar algum erro (Jonata - RKAM P364).
 * --------------

 */	
?>

<?	
	session_start();
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");
	isPostMethod();	
	
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '' ;	
		
	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrdconta"]) || !isset($_POST["idseqttl"])) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);

	$nrdconta = ( isset($_POST['nrdconta']) ) ? $_POST['nrdconta'] : 0;
	$idseqttl = ( isset($_POST['idseqttl']) ) ? $_POST['idseqttl'] : 0;
	$flaceint = ( isset($_POST['flaceint']) ) ? $_POST['flaceint'] : 0;
	$flaplica = ( isset($_POST['flaplica']) ) ? $_POST['flaplica'] : 0;
	$flfolpag = ( isset($_POST['flfolpag']) ) ? $_POST['flfolpag'] : 0;
	$fldebaut = ( isset($_POST['fldebaut']) ) ? $_POST['fldebaut'] : 0;
	$fllimint = ( isset($_POST['fllimint']) ) ? $_POST['fllimint'] : 0;
	$flplacot = ( isset($_POST['flplacot']) ) ? $_POST['flplacot'] : 0;
	$flpouppr = ( isset($_POST['flpouppr']) ) ? $_POST['flpouppr'] : 0;
	
	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0197.p</Bo>';
	$xml .= '		<Proc>canc_auto_produtos</Proc>';
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
	$xml .= '		<flaceint>'.$flaceint.'</flaceint>';
	$xml .= '		<flaplica>'.$flaplica.'</flaplica>';
	$xml .= '		<flfolpag>'.$flfolpag.'</flfolpag>';
	$xml .= '		<fldebaut>'.$fldebaut.'</fldebaut>';
	$xml .= '		<fllimint>'.$fllimint.'</fllimint>';
	$xml .= '		<flplacot>'.$flplacot.'</flplacot>';
	$xml .= '		<flpouppr>'.$flpouppr.'</flpouppr>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	$xmlResult   = getDataXML($xml);	
	$xmlObjServicos   = getObjectXML($xmlResult);	

	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjServicos->roottag->tags[0]->name) == 'ERRO') {
		exibirErro('error',$xmlObjServicos->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','bloqueiaFundo(divRotina);acessaRotina(\'IMPEDIMENTOS DESLIGAMENTO\', \'Impedimentos\', \'impedimentos_desligamento\');',false);
	}else{
		exibirErro('inform',$xmlObjServicos->roottag->tags[0]->tags[0]->tags[1]->cdata,'Alerta - Ayllos','bloqueiaFundo(divRotina);acessaRotina(\'IMPEDIMENTOS DESLIGAMENTO\', \'Impedimentos\', \'impedimentos_desligamento\');',false);
	}
	
?>
