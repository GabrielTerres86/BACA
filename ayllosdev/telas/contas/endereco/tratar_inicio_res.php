<? 
/*!
 * FONTE        : tratar_inicio_res.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 03/05/2011 
 * OBJETIVO     : Rotina que trata o campo inicio de residencia
 */
?>
<?	
    session_start();
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");
	isPostMethod();		
		
	// Guardo os parâmetos do POST em variáveis 
	$dtinires = (isset($_POST['dtinires'])) ? $_POST['dtinires'] : '';
		
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0038.p</Bo>";
	$xml .= "		<Proc>trata-inicio-resid</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "       <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<dtinires>".$dtinires."</dtinires>";	           
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	

	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);

	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);
	
	// limpa o campo tempo de residencia
	echo "$('#nranores','#frmEndereco').val('');";
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Aimaro','bloqueiaFundo(divRotina);',false);
	} else {
		$nranores = $xmlObjeto->roottag->tags[0]->attributes['NRANORES'];
		echo "$('#nranores','#frmEndereco').val('".$nranores."');";
		echo "hideMsgAguardo();";
		echo "bloqueiaFundo(divRotina);";
	}
	
?>									 