<? 
/*!
 * FONTE        : manter_rotina.php
 * DATA CRIAÇÃO : 23/01/2018
 * OBJETIVO     : Rotina para controlar as operações da tela TAB057
 *
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
  
  $cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
  $cdagente = (isset($_POST['cdagente'])) ? $_POST['cdagente'] : '';
  $seqarnsa = (isset($_POST['seqarnsa'])) ? $_POST['seqarnsa'] : 0;
  $seqarfat = (isset($_POST['seqarfat'])) ? $_POST['seqarfat'] : 0;
  $seqtrife = (isset($_POST['seqtrife'])) ? $_POST['seqtrife'] : 0;
  $seqconso = (isset($_POST['seqconso'])) ? $_POST['seqconso'] : 0;
  $cdcooper = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : 0;
  $cdempres = (isset($_POST['cdempres'])) ? $_POST['cdempres'] : 0;
  $dtiniper = (isset($_POST['dtiniper'])) ? $_POST['dtiniper'] : '';
  $dtfimper = (isset($_POST['dtfimper'])) ? $_POST['dtfimper'] : '';
  $nrregist = (isset($_POST["nrregist"])) ? $_POST["nrregist"] : 50;
  $nriniseq = (isset($_POST["nriniseq"])) ? $_POST["nriniseq"] : 1;
  
  //Alteração
  if ($cddopcao == 'A') {
	//Sicredi
	if ($cdagente == 'S') {
		if ((!isset($_POST['seqarfat'])) || $_POST['seqarfat'] == ''){
		  echo 'hideMsgAguardo();';
		  echo 'showError("error","Sequencial do arquivo de arrecadação de fatura é obrigat&oacute;rio! Favor preench&ecirc;-lo","Alerta - Ayllos","$(\'#seqarfat\', \'#frmDadosSicredi\').focus()");';
		  exit();
		}
		if ((!isset($_POST['seqtrife'])) || $_POST['seqtrife'] == ''){
		  echo 'hideMsgAguardo();';
		  echo 'showError("error","Sequencial do arquivo de Tributo Federeal é obrigat&oacute;rio! Favor preench&ecirc;-lo","Alerta - Ayllos","$(\'#seqtrife\', \'#frmDadosSicredi\').focus()");';
		  exit();
		}
		if ((!isset($_POST['seqconso'])) || $_POST['seqconso'] == ''){
		  echo 'hideMsgAguardo();';
		  echo 'showError("error","Sequencial do arquivo de atualização de consórcio é obrigat&oacute;rio! Favor preench&ecirc;-lo","Alerta - Ayllos","$(\'#seqconso\', \'#frmDadosSicredi\').focus()");';
		  exit();
		}
		
		$xml = "<Root>";
		$xml .= " <Dados>";
		$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xml .= "   <seqarfat>".$seqarfat."</seqarfat>";
		$xml .= "   <seqtrife>".$seqtrife."</seqtrife>";
		$xml .= "   <seqconso>".$seqconso."</seqconso>";
		$xml .= " </Dados>";
		$xml .= "</Root>";

		$xmlResult = mensageria($xml, "TAB057", "TAB057_UPD_SEQS_SICREDI", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObj = getObjectXML($xmlResult);
		
		if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		  $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		  if ($msgErro == "") {
			  $msgErro = $xmlObj->roottag->tags[0]->cdata;
		  }

		  exibeErroNew($msgErro);
		  exit();
		}
		
		echo 'showError("inform","Operação efetuada com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';
	  //Bancoob
	} else {
		if ((!isset($_POST['seqarnsa'])) || $_POST['seqarnsa'] == ''){
		  echo 'hideMsgAguardo();';
		  echo 'showError("error","Sequencial obrigat&oacute;rio! Favor preench&ecirc;-lo","Alerta - Ayllos","$(\'#seqarnsa\', \'#frmDadosBancoob\').focus()");';
		  exit();
		}
		
		$xml = "<Root>";
		$xml .= " <Dados>";
		$xml .= "   <cdcooper>".$cdcooper."</cdcooper>";
		$xml .=	"	<cdempres>".$cdempres."</cdempres>";
		$xml .= "   <seqarnsa>".$seqarnsa."</seqarnsa>";
		$xml .= " </Dados>";
		$xml .= "</Root>";

		$xmlResult = mensageria($xml, "TAB057", "TAB057_UPD_SEQS_BANCOOB", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObj = getObjectXML($xmlResult);
		
		if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		  $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		  if ($msgErro == "") {
			  $msgErro = $xmlObj->roottag->tags[0]->cdata;
		  }

		  exibeErroNew($msgErro);
		  exit();
		}
		
		echo 'showError("inform","Operação efetuada com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';
	}
	//Consulta
  } else {
	  //Bancoob
	  if ($cdagente == 'B') {
		  
		$xml = "<Root>";
		$xml .= " <Dados>";
		$xml .= "   <cdcooper>".$cdcooper."</cdcooper>";
		$xml .= "   <cdempres>".$cdempres."</cdempres>";
		$xml .= "   <dtiniper>".$dtiniper."</dtiniper>";
		$xml .= "   <dtfimper>".$dtfimper."</dtfimper>";
		$xml .= "   <nriniseq>".$nriniseq."</nriniseq>";
		$xml .= "   <nrregist>".$nrregist."</nrregist>";
		$xml .= " </Dados>";
		$xml .= "</Root>";

		$xmlResult = mensageria($xml, "TAB057", "TAB057_LISTA_ARRECADACOES", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObj = getObjectXML($xmlResult);
		
		if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
			if ($msgErro == "") {
				$msgErro = $xmlObj->roottag->tags[0]->cdata;
			}
			exibeErroNew($msgErro);
			exit();
		}

		$registros = $xmlObj->roottag->tags[0]->tags;
		$qtregist = $xmlObj->roottag->tags[1]->cdata;
		$qttotdoc = $xmlObj->roottag->tags[2]->cdata;
		$qttotarr = $xmlObj->roottag->tags[3]->cdata;
		$qttottar = $xmlObj->roottag->tags[4]->cdata;
		$qttotpag = $xmlObj->roottag->tags[5]->cdata;

		if ($qtregist == 0) {
			exibeErroNew("Nenhum registro foi encontrado.");
			echo 'showError("inform","Nenhum registro foi encontrado.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';
		} else {
			include('tab_registros.php');	
			include('form_total.php');
		}
	  }
  }
  function exibeErroNew($msgErro) {
    echo 'hideMsgAguardo();';
    echo 'showError("error","' . $msgErro . '","Alerta - Ayllos","desbloqueia()");';
    exit();
  }
?>
