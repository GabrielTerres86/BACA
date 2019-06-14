<? 
/*!
 * FONTE        : grava_rendimentos.php
 * CRIAÇÃO      : Adriano
 * DATA CRIAÇÃO : 05/12/2011
 * OBJETIVO     : Rotina para gravar os rendimentos.
 *
 * ALTERAÇÕES   : 08/06/2018 - Remover caractere invalido no carregamento da justificativa. (PRB0040072 - Kelvin)
 */
?>
 
<?	
    session_start();
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");
	isPostMethod();		
	
	// Recebe a operação que está sendo realizada
	
	if (!isset($_POST['nrdconta']) ||
		!isset($_POST['idseqttl']) ||
		!isset($_POST['cddopcao']) ||
		//!isset($_POST['cddrendi']) ||
		//!isset($_POST['vlrdrend']) ||
		!isset($_POST['tpdrend2']) ||
		!isset($_POST['vldrend2']) ||
		//!isset($_POST['dsjusren']) ||
		!isset($_POST['dsjusre2'])  ) 
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro','fechaRotina(divRotina)',false);	
	
	$nrdconta = $_POST['nrdconta'] == '' ?  0  : $_POST['nrdconta'];
	$idseqttl = $_POST['idseqttl'] == '' ?  0  : $_POST['idseqttl'];
	$cddopcao = $_POST['cddopcao'] == '' ?  0  : $_POST['cddopcao'];
	$tpdrendi = $_POST['cddrendi'] == '' ?  0  : $_POST['cddrendi'];
	$vldrendi = $_POST['vlrdrend'] == '' ?  0  : $_POST['vlrdrend'];
	$tpdrend2 = $_POST['tpdrend2'] == '' ?  0  : $_POST['tpdrend2'];
	$vldrend2 = $_POST['vldrend2'] == '' ?  0  : $_POST['vldrend2'];
	$dsjusren = $_POST['dsjusren'] == '' ?  0  : $_POST['dsjusren'];
	$dsjusre2 = $_POST['dsjusre2'] == '' ?  0  : $_POST['dsjusre2']; 
	
	

	//Valida dados
	if($cddopcao != 'E'){
		echo '$("input","#frmManipulaRendi").removeClass("campoErro");';	
		
		// Campo Origem
		if ( $tpdrend2 == '' ) 
			exibirErro('error','Tipo de rendimento inválido.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'tpdrend2\',\'frmManipulaRendi\')',false);
		
		//Campo valor
		if ( $vldrend2 == '' ) 
			exibirErro('error','Valor não informado.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'vldrend2\',\'frmManipulaRendi\')',false);
	
	}
	
	
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0075.p</Bo>";
	$xml .= "		<Proc>Grava_Rendimentos</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>"; 
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<idseqttl>".$idseqttl."</idseqttl>";
	$xml .= "		<cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xml .= "		<tpdrendi>".$tpdrendi."</tpdrendi>";
	$xml .= "		<vldrendi>".$vldrendi."</vldrendi>";
	$xml .= "		<tpdrend2>".$tpdrend2."</tpdrend2>";
	$xml .= "		<vldrend2>".$vldrend2."</vldrend2>";
	$xml .= "		<dsjusren>".retiraAcentos(removeCaracteresInvalidos($dsjusren))."</dsjusren>";
	$xml .= "		<dsjusre2>".retiraAcentos(removeCaracteresInvalidos($dsjusre2))."</dsjusre2>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo(divRotina); navegarRendimentos();',false);
		
	}
	

	
	if($tpdrend2 == 6){ 
		if($dsjusre2 != ''){
			echo "$('#dsjusren','#frmJustificativa').val(removeCaracteresInvalidos('".$dsjusre2."'));";
		}else{
			echo "$('#dsjusren','#frmJustificativa').val('');";
		}
	} 
	
	echo "navegarRendimentos();";
		
?>

	
    