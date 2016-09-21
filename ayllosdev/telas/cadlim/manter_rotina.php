<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIA��O      : James Prust Junior
 * DATA CRIA��O : 15/12/2014
 * OBJETIVO     : Rotina para altera��o cadastral da tela CADLIM
 * --------------
 * ALTERA��ES   : 
 * -------------- 
 */
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		

	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
	$inpessoa = (isset($_POST['inpessoa'])) ? $_POST['inpessoa'] : '';
	$vlmaxren = (isset($_POST['vlmaxren'])) ? converteFloat($_POST['vlmaxren']) : '';
	$qtdiaren = (isset($_POST['qtdiaren'])) ? $_POST['qtdiaren'] : '';
	$qtmaxren = (isset($_POST['qtmaxren'])) ? $_POST['qtmaxren'] : '';
	$qtdiaatr = (isset($_POST['qtdiaatr'])) ? $_POST['qtdiaatr'] : '';
	$qtatracc = (isset($_POST['qtatracc'])) ? $_POST['qtatracc'] : '';
	$qtmincta = (isset($_POST['qtmincta'])) ? $_POST['qtmincta'] : '';
	$nrrevcad = (isset($_POST['nrrevcad'])) ? $_POST['nrrevcad'] : '';
	$vlsitdop = (isset($_POST['vlsitdop'])) ? $_POST['vlsitdop'] : '';	
	$vlriscop = (isset($_POST['vlriscop'])) ? $_POST['vlriscop'] : '';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	if ($cddopcao == 'A'){
		// Monta o xml de requisicao
		$xml  = "";
		$xml .= "<Root>";
		$xml .= " <Dados>";			
		$xml .= "   <inpessoa>".$inpessoa."</inpessoa>";
		$xml .= "   <vlmaxren>".$vlmaxren."</vlmaxren>";
		$xml .= "   <nrrevcad>".$nrrevcad."</nrrevcad>";
		$xml .= "   <qtmincta>".$qtmincta."</qtmincta>";
		$xml .= "   <qtdiaren>".$qtdiaren."</qtdiaren>";
		$xml .= "   <qtmaxren>".$qtmaxren."</qtmaxren>";
		$xml .= "   <qtdiaatr>".$qtdiaatr."</qtdiaatr>";
		$xml .= "   <qtatracc>".$qtatracc."</qtatracc>";		
		$xml .= "   <dssitdop>".$vlsitdop."</dssitdop>";
		$xml .= "   <dsrisdop>".$vlriscop."</dsrisdop>";		
		$xml .= "   <idgerlog>0</idgerlog>";
		$xml .= " </Dados>";
		$xml .= "</Root>";
		
		$xmlResult = mensageria($xml, "CADLIM", "CADLIM_ALTERAR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObjeto = getObjectXML($xmlResult);
		
		if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO"){
			$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
			if ($msgErro == "") {
				$msgErro = $xmlObjeto->roottag->tags[0]->cdata;
			}
			exibirErro('error',$msgErro,'Alerta - Ayllos',"estadoInicial();",false);
		}

		echo "hideMsgAguardo();";
		echo 'showError("inform","Regras de renova&ccedil;&atilde;o alterada com sucesso!","Alerta - Ayllos","estadoInicial();");';		
	}

?>