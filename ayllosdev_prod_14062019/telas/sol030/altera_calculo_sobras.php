<? 
/*!
 * FONTE        : altera_calculo_sobras.php
 * CRIAÇÃO      : Lucas Lombardi
 * DATA CRIAÇÃO : 10/08/2016
 * OBJETIVO     : Rotina para alteração da data informativo da tela IMPPRE
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
	
	$ininccmi = (isset($_POST['ininccmi'])) ? $_POST['ininccmi'] : '';
	$increret = (isset($_POST['increret'])) ? $_POST['increret'] : '';
	$txretorn = (isset($_POST['txretorn'])) ? $_POST['txretorn'] : '';
	$txjurcap = (isset($_POST['txjurcap'])) ? $_POST['txjurcap'] : '';
	$txjurapl = (isset($_POST['txjurapl'])) ? $_POST['txjurapl'] : '';
	$txjursdm = (isset($_POST['txjursdm'])) ? $_POST['txjursdm'] : '';
	$txjurtar = (isset($_POST['txjurtar'])) ? $_POST['txjurtar'] : '';
	$txreauat = (isset($_POST['txreauat'])) ? $_POST['txreauat'] : '';
	$inpredef = (isset($_POST['inpredef'])) ? $_POST['inpredef'] : '';
	$indeschq = (isset($_POST['indeschq'])) ? $_POST['indeschq'] : '';
	$indemiti = (isset($_POST['indemiti'])) ? $_POST['indemiti'] : '';
	$unsobdep = (isset($_POST['unsobdep'])) ? $_POST['unsobdep'] : '';
	$indestit = (isset($_POST['indestit'])) ? $_POST['indestit'] : '';
	$dssopfco = (isset($_POST['dssopfco'])) ? $_POST['dssopfco'] : '';
	$dssopjco = (isset($_POST['dssopjco'])) ? $_POST['dssopjco'] : '';
	
	// Carrega permissões do operador
	require_once('../../includes/carrega_permissoes.php');
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'A')) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','estadoInicial();',false);
	}
	
	// Monta o xml de requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <ininccmi>".$ininccmi."</ininccmi>";
	$xml .= "   <increret>".$increret."</increret>";
	$xml .= "   <txretorn>".$txretorn."</txretorn>";
	$xml .= "   <txjurcap>".$txjurcap."</txjurcap>";
	$xml .= "   <txjurapl>".$txjurapl."</txjurapl>";
	$xml .= "   <txjursdm>".$txjursdm."</txjursdm>";
	$xml .= "   <txjurtar>".$txjurtar."</txjurtar>";
	$xml .= "   <txreauat>".$txreauat."</txreauat>";
	$xml .= "   <inpredef>".$inpredef."</inpredef>";
	$xml .= "   <indeschq>".$indeschq."</indeschq>";
	$xml .= "   <indemiti>".$indemiti."</indemiti>";
	$xml .= "   <unsobdep>".$unsobdep."</unsobdep>";
	$xml .= "   <indestit>".$indestit."</indestit>";
	$xml .= "   <dssopfco>".$dssopfco."</dssopfco>";
	$xml .= "   <dssopjco>".$dssopjco."</dssopjco>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "TELA_SOL030", "ALTERA_CALC_SOBRAS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);
	
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		
		$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		
		if ($msgErro == "") {
			$msgErro = $xmlObjeto->roottag->tags[0]->cdata;
		}
		
		$campoErro = $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO']; 
		$funcao = $campoErro != '' ? '$(\'#'.$campoErro.'\', \'#frmCalculoSobras\').focus();' : 'estadoInicial();';
		 
		echo 'showError("error","' .htmlentities($msgErro). '","Alerta - Ayllos","'.$funcao.'");';
		exit();
	}
	$dados = $xmlObjeto->roottag->tags[0]->cdata;
	if($inpredef == '0'){
		echo "calcula_retorno_sobras();";
	}else {
		echo "estadoInicial();";
	}
?>