<?
/*!
 * FONTE        : manter_rotina.php 
 * CRIAÇÃO      : Alex Sandro (GFT)
 * DATA CRIAÇÃO : 15/02/2018
 * OBJETIVO     : Descrição da rotina
 * --------------
 * ALTERAÇÕES   :
 * --------------

 */
?>

<?

    session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();

	// parâmetos do POST em variáveis
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '' ;
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0 ;
	$nrctrlim = (isset($_POST['nrctrlim'])) ? $_POST['nrctrlim'] : 0 ;
	$insitlim = (isset($_POST['insitlim'])) ? $_POST['insitlim'] : '' ;
	$dssitest = (isset($_POST['dssitest'])) ? $_POST['dssitest'] : '' ;
	$insitapr = (isset($_POST['insitapr'])) ? $_POST['insitapr'] : '' ;
	$vllimite = (isset($_POST['vllimite'])) ? $_POST['vllimite'] : 0 ;
	$cddopera = (isset($_POST['cddopera'])) ? $_POST['cddopera'] : 0 ;


	if ($operacao == 'ENVIAR_ANALISE' ) {
		
		$xml = "<Root>";
	    $xml .= " <Dados>";
	    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	    $xml .= "   <nrctrlim>".$nrctrlim."</nrctrlim>";
	    $xml .= "   <tpctrlim>3</tpctrlim>";
	    $xml .= "	<dtmovito>".$glbvars["dtmvtolt"]."</dtmovito>";
	    $xml .= "   <tpenvest>I</tpenvest>"; // Tipo de envio para esteira I - Inclusao (Emprestimo)
	    $xml .= " </Dados>";
	    $xml .= "</Root>";


	    $xmlResult = mensageria($xml,"TELA_ATENDA_DESCTO","ENVIAR_ESTEIRA_DESCT", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	    $xmlObj = getObjectXML($xmlResult);

		if (strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO'){  
           echo 'showError("error","'.$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata.'","Alerta - Ayllos","bloqueiaFundo(divRotina);carregaLimitesTitulos();");';           
           exit;
		}
		if($xmlObj->roottag->tags[0]){
			echo 'showError("inform","'.$xmlObj->roottag->tags[0]->cdata.'","Alerta - Ayllos","bloqueiaFundo(divRotina);carregaLimitesTitulos();");';
		} else{
			echo 'showError("inform","An&aacute;lise enviada com sucesso!","Alerta - Ayllos","bloqueiaFundo(divRotina);carregaLimitesTitulos();");';
		}	
		
        exit;

	}else if ($operacao == 'ENVIAR_ESTEIRA' ) {

		$xml = "<Root>";
	    $xml .= " <Dados>";
	    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	    $xml .= "   <nrctrlim>".$nrctrlim."</nrctrlim>";
	    $xml .= "   <tpctrlim>3</tpctrlim>";
	    $xml .= "	<dtmovito>".$glbvars["dtmvtolt"]."</dtmovito>";
	    $xml .= "   <tpenvest>I</tpenvest>"; // Tipo de envio para esteira I - Inclusao (Emprestimo)
	    $xml .= " </Dados>";
	    $xml .= "</Root>";

	    // FAZER O INSERT CRAPRDR e CRAPACA
	    $xmlResult = mensageria($xml,"TELA_ATENDA_DESCTO","SENHA_ENVIAR_ESTEIRA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	    $xmlObj = getObjectXML($xmlResult);

		$registros = $xmlObj->roottag->tags[0]->tags;
		
	    // Se ocorrer um erro, mostra mensagem
		if (strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO') {
           echo 'showError("error","'.$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata.'","Alerta - Ayllos","bloqueiaFundo(divRotina);carregaLimitesTitulos();");';           
		}
		else{
			if($xmlObj->roottag->tags[0]){
				echo 'showError("inform","'.$xmlObj->roottag->tags[0]->cdata.'","Alerta - Ayllos","bloqueiaFundo(divRotina);carregaLimitesTitulos();");';
			} else{
				echo 'showError("inform","An&aacute;lise enviada com sucesso!","Alerta - Ayllos","bloqueiaFundo(divRotina);carregaLimitesTitulos();");';
			}	
		}


		exit;
		
	}else if ($operacao == 'CONFIMAR_NOVO_LIMITE' ) {

		$xml = "<Root>";
	    $xml .= " <Dados>";
	    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	    $xml .= "   <nrctrlim>".$nrctrlim."</nrctrlim>";
	    $xml .= "   <vllimite>".converteFloat($vllimite)."</vllimite>";
	    $xml .= "   <cddopera>".$cddopera."</cddopera>";
	    $xml .= " </Dados>";
	    $xml .= "</Root>";



	    $xmlResult = mensageria($xml,"TELA_ATENDA_DESCTO","CONFIRMAR_NOVO_LIMITE_TIT", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");


	    $xmlObj = getObjectXML($xmlResult);

	    // Se ocorrer um erro, mostra crítica
		if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
			if ($msgErro == "") {
				$msgErro = $xmlObj->roottag->tags[0]->cdata;
			}
			exibeErro(htmlentities($msgErro));
		}
		
		if (strtoupper($xmlObj->roottag->tags[0]->name) == "MSG") {
			
			$mensagem_01 = $xmlObj->roottag->tags[0]->tags[0]->cdata;
			$mensagem_02 = $xmlObj->roottag->tags[0]->tags[1]->cdata;
			$mensagem_03 = $xmlObj->roottag->tags[0]->tags[2]->cdata;
			$mensagem_04 = $xmlObj->roottag->tags[0]->tags[3]->cdata;
			$mensagem_05 = $xmlObj->roottag->tags[0]->tags[4]->cdata;
			$qtctarel    = '';
			
			if ($mensagem_03 != '') {
				$tab_grupo   = $xmlObj->roottag->tags[0]->tags[5]->tags;
				$qtctarel    = $xmlObj->roottag->tags[0]->tags[6]->cdata;
			}
			
			$grupo = '';
			if ($mensagem_03 != '') {
				foreach( $tab_grupo as $reg ) { 
					$grupo .= ($reg->cdata).";";
				}
				if ($grupo != '')
					$grupo = substr($grupo,0,-1);
			}
			
			echo 'verificaMensagens("'.$mensagem_01.'","'.$mensagem_02.'","'.$mensagem_03.'","'.$mensagem_04.'","'.$mensagem_05.'","'.$qtctarel.'","'.$grupo.'");';
			exit;
		}
		else{
			if ($xmlObj->roottag->tags[0]->cdata == 'OK') {
				echo 'showError("inform","Opera&ccedil;&atilde;o efetuada com sucesso!","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));carregaLimitesTitulos();");';
			}
		}
		
	}else if ($operacao == 'ACEITAR_REJEICAO_LIMITE' ) {

		$xml = "<Root>";
	    $xml .= " <Dados>";
	    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	    $xml .= "   <nrctrlim>".$nrctrlim."</nrctrlim>";
	    $xml .= " </Dados>";
	    $xml .= "</Root>";

	    // FAZER O INSERT CRAPRDR e CRAPACA
	    $xmlResult = mensageria($xml,"TELA_ATENDA_DESCTO","ACEITAR_REJEICAO_LIM_TIT", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	    $xmlObj = getObjectXML($xmlResult);


	    // Se ocorrer um erro, mostra crítica
		if (strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO'){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
			if ($msgErro == "") {
				$msgErro = $xmlObj->roottag->tags[0]->cdata;
			}
			exibeErro(htmlentities($msgErro));
			exit;
		}
		else{
			if ($xmlObj->roottag->tags[0]->cdata == 'OK') {
				echo 'showError("inform","Opera&ccedil;&atilde;o efetuada com sucesso!","Alerta - 	Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));carregaLimitesTitulos();");';
				exit;
			} // OK
		}// != ERROR
		
	}//ACEITAR_REJEICAO_LIMITE

	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}


	function exibeErroNew($msgErro,$nmdcampo) {
	    echo 'hideMsgAguardo();';
	    if ($nmdcampo <> ""){
	        $nmdcampo = '$(\'#'.$nmdcampo.'\', \'#frmTab052\').focus();';
	    }
	    $msgErro = str_replace('"','',$msgErro);
	    $msgErro = preg_replace('/\s/',' ',$msgErro);
	    
	    echo 'showError("error","' .$msgErro. '","Alerta - Ayllos","liberaCampos(); '.$nmdcampo.'");'; 
	    exit();
	}

?>