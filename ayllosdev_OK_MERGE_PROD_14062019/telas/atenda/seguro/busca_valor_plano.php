<? 
/*!
 * FONTE        : busca_valor_plano.php
 * CRIAÇÃO      : Tiago Machado Flor
 * DATA CRIAÇÃO : 18/08/2016 
 * OBJETIVO     : Rotina para consultar valor do plano de seguro
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */
	
    session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();		
	
	// Inicializa	
	$retornoAposErro= '';
	$retornoAposErro = 'focaCampoErro(\'cddopcao\', \'frmCab\');';
		
	// Verifica se os parâmetros necessários foram informados	
	if(!isset($_POST["nrdconta"]) || !isset($_POST["cdsegura"]) || !isset($_POST["tpseguro"]) || !isset($_POST["tpplaseg"])) {
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro',$funcaoAposErro,false);
	}else{
	
		$nrdconta = $_POST["nrdconta"];
		$cdsegura = $_POST["cdsegura"];
		$tpseguro = $_POST["tpseguro"];
		$tpplaseg = $_POST["tpplaseg"];		
		
		// Verifica se número da conta ou tpctrato é um inteiro válido
		if (!validaInteiro($nrdconta)) exibirErro('error','Op&ccedil;&atilde;o inv&aacute;lida.','Alerta - Aimaro',$funcaoAposErro,false);
	}
			

	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <cdsegura>".$cdsegura."</cdsegura>";
	$xml .= "   <tpseguro>".$tpseguro."</tpseguro>";
	$xml .= "   <tpplaseg>".$tpplaseg."</tpplaseg>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "ATENDA", "VALOR_PLANO_SEGURO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);

	if ( strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO" ) {
?>
		$("#vlpreseg").val("0,00");
<?
	} else {
		$vlpreseg = $xmlObj->roottag->tags[0]->cdata;						
?>
		$("#vlpreseg").val(number_format(" <? echo $vlpreseg; ?>",2,',','.'));
		$("#vlpreseg").desabilitaCampo();
<?		
	}	
?>