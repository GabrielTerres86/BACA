<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : James Prust Junior
 * DATA CRIAÇÃO : 15/12/2014
 * OBJETIVO     : Rotina para alteração cadastral da tela CADLIM
 * --------------
 * ALTERAÇÕES   : 21/09/2016 - Inclusão do filtro "Tipo de Limite" no cabecalho. Inclusão dos campos
 *                             "pcliqdez" e "qtdialiq" no formulario de regras. Projeto 300. (Lombardi)
 *
 *                16/03/2018 - Inclusão de novo campo (Quantidade de Meses do novo limite após o cancelamento)
 *                             Diego Simas (AMcom)
 *    
 * -------------- 
 */
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		

	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
	$tplimite = (isset($_POST['tplimite'])) ? $_POST['tplimite'] : '';
	$inpessoa = (isset($_POST['inpessoa'])) ? $_POST['inpessoa'] : '';
	$vlmaxren = (isset($_POST['vlmaxren'])) ? converteFloat($_POST['vlmaxren']) : '';
	$qtdiaren = (isset($_POST['qtdiaren'])) ? $_POST['qtdiaren'] : '';
	//Diego Simas (AMcom)
	$qtmeslic = (isset($_POST['qtmeslic'])) ? $_POST['qtmeslic'] : '';
	$qtmaxren = (isset($_POST['qtmaxren'])) ? $_POST['qtmaxren'] : '';
	$qtdiaatr = (isset($_POST['qtdiaatr'])) ? $_POST['qtdiaatr'] : '';
	$qtatracc = (isset($_POST['qtatracc'])) ? $_POST['qtatracc'] : '';
	$qtmincta = (isset($_POST['qtmincta'])) ? $_POST['qtmincta'] : '';
	$nrrevcad = (isset($_POST['nrrevcad'])) ? $_POST['nrrevcad'] : '';
	$vlsitdop = (isset($_POST['vlsitdop'])) ? $_POST['vlsitdop'] : '';	
	$vlriscop = (isset($_POST['vlriscop'])) ? $_POST['vlriscop'] : '';
	$pcliqdez = (isset($_POST['pcliqdez'])) ? $_POST['pcliqdez'] : '';	
	$qtdialiq = (isset($_POST['qtdialiq'])) ? $_POST['qtdialiq'] : '';

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
		//Diego Simas (AMcom)
		$xml .= "   <qtmeslic>".$qtmeslic."</qtmeslic>";
		$xml .= "   <qtmaxren>".$qtmaxren."</qtmaxren>";
		$xml .= "   <qtdiaatr>".$qtdiaatr."</qtdiaatr>";
		$xml .= "   <qtatracc>".$qtatracc."</qtatracc>";		
		$xml .= "   <dssitdop>".$vlsitdop."</dssitdop>";
		$xml .= "   <dsrisdop>".$vlriscop."</dsrisdop>";
		$xml .= "   <tplimite>".$tplimite."</tplimite>";
		$xml .= "   <pcliqdez>".$pcliqdez."</pcliqdez>";
		$xml .= "   <qtdialiq>".$qtdialiq."</qtdialiq>";
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
