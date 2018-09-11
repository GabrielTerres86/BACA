<? 
/*!
 * FONTE        : carrega_consulta_estorno_ct.php
 * CRIAÇÃO      : Diego Simas (AMcom)
 * DATA CRIAÇÃO : 03/09/2018
 * OBJETIVO     : Rotina para carregar os estornos realizados de prejuizo de conta corrente
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'CCT')) <> ''){
		exibirErro('error',$msgError,'Alerta - Ayllos','',true);
	}

	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
	
	$xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";	
    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";	
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "PREJ0003", "CONSULTAR_ESTORNO_PREJU_CC", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObject = getObjectXML($xmlResult);

    if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO"){
        $msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
        exibeErroNew($msgErro);
    }
	
	$estornos = $xmlObject->roottag->tags[0]->tags[2]->tags;	
	require_once("tab_estornos_ct.php");
	
	function exibeErroNew($msgErro) {	
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","trocaBotao(\'estadoInicial()\',\'ajustaBotaoContinuarCT()\',\'Continuar\');$(\'#nrdconta\',\'#frmEstornoPagamentoCT\').focus();");';
		exit();
	}	
		
?>	
<script>
	$('#btSalvar').css('display','none');
	$('#nrdconta','#frmEstornoPagamentoCT').desabilitaCampo();	
</script>