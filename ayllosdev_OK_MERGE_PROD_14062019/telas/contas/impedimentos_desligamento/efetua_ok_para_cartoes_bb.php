<? 
/*!
 * FONTE        : efetua_ok_para_cartoes_bb.php
 * CRIA��O      : Andrey Formigari
 * DATA CRIA��O : Outubro/2017
 * OBJETIVO     : Setar como lida para Vendas com Cart�es
 * --------------
 * ALTERA��ES   : 
 * --------------

 */
	session_start();
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");
	isPostMethod();	
	
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '' ;	
		
	// Verifica se o n�mero da conta foi informado
	if (!isset($_POST["nrdconta"]) || !isset($_POST["idseqttl"])) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);

	$nrdconta = ( isset($_POST['nrdconta']) ) ? $_POST['nrdconta'] : 0;
	
	// Monta o xml de requisi��o
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0197.p</Bo>';
	$xml .= '		<Proc>seta_vendas_cartao</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	$xmlResult   = getDataXML($xml);	
	$xmlObjServicos   = getObjectXML($xmlResult);	
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjServicos->roottag->tags[0]->name) == 'ERRO') {
		exibirErro('error',$xmlObjServicos->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo(divRotina);',false);
	}else{
		exibirErro('inform',$xmlObjServicos->roottag->tags[0]->tags[0]->tags[1]->cdata,'Alerta - Aimaro','bloqueiaFundo(divRotina);acessaRotina(\'IMPEDIMENTOS DESLIGAMENTO\', \'Impedimentos\', \'impedimentos_desligamento\');',false);
	}
	
?>
