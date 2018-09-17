<? 
	/*!
	 * FONTE        : buscar_plano_seguro.php
	 * CRIAÇÃO      : Michel M Candido
	 * DATA CRIAÇÃO : 19/09/2011
	 * OBJETIVO     : Monta o combo com a lista de tipos (casa, vida, prestamista)
	 */
	session_start();
		
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
		
	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		exibeErro($msgError);		
	}
		
	// Verifica se número da conta foi informado
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}

	$nrdconta = (isset($_POST['nrdconta'])?$_POST['nrdconta']:'');
	$cdsegura = (isset($_POST['cdsegura'])?$_POST['cdsegura']:'');
	$idseqttl = (isset($_POST['idseqttl'])?$_POST['idseqttl']:'1');

	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}

	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0033.p</Bo>";
	$xml .= "		<Proc>buscar_plano_seguro</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<idseqttl>".$idseqttl."</idseqttl>";
	$xml.= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xml.= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";	
	$xml .= "		<flgerlog>FALSE</flgerlog>";
	$xml .= "		<cdsegura>".$cdsegura."</cdsegura>";
	$xml .= "		<tpseguro>11</tpseguro>";
	$xml .= "		<tpplaseg></tpplaseg>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);

	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		echo $erro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibeErro($erro);
	}
	
	$planos = $xmlObjeto->roottag->tags[0]->tags;
	
	$retorno= "arrayPlanos.length = 0;";
	
	foreach($planos as $indice => $plano){
		$retorno .= 'var arrayPlano'.$indice.' = new Object();
									 arrayPlano'.$indice.'[\'dsocupac\'] = "'.getByTagName($plano->tags,'dsocupac').'";
									 arrayPlano'.$indice.'[\'dsmorada\'] = "'.getByTagName($plano->tags,'dsmorada').'"; 
									 arrayPlano'.$indice.'[\'tpplaseg\'] = "'.getByTagName($plano->tags,'tpplaseg').'"; 
									 arrayPlano'.$indice.'[\'vlplaseg\'] = "'.getByTagName($plano->tags,'vlplaseg').'"; 
									 arrayPlano'.$indice.'[\'flgunica\'] = "'.getByTagName($plano->tags,'flgunica').'"; 
									 arrayPlano'.$indice.'[\'qtmaxpar\'] = "'.getByTagName($plano->tags,'qtmaxpar').'"; 
									 arrayPlano'.$indice.'[\'mmpripag\'] = "'.getByTagName($plano->tags,'mmpripag').'"; 
									 arrayPlano'.$indice.'[\'qtdiacar\'] = "'.getByTagName($plano->tags,'qtdiacar').'"; 
									 arrayPlano'.$indice.'[\'ddmaxpag\'] = "'.getByTagName($plano->tags,'ddmaxpag').'"; 
									 arrayPlanos['.$indice.'] = arrayPlano'.$indice.';';
	}
	
	$retorno .= 'formataZoom();hideMsgAguardo();';
	
	echo $retorno;
?>