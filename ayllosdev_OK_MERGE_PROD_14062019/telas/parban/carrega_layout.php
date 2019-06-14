<?php
	/*!
	 * FONTE        : carrega_layout.php
	 * DATA CRIAÇÃO : 26/02/2018
	 * OBJETIVO     : Arquivo para carregar layouts das telas
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
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script>';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));hideMsgAguardo();");';
		echo '</script>';
		exit();
	}
	
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
	$cdbanner = (isset($_POST['cdbanner'])) ? $_POST['cdbanner'] : 0;
	$cdcanal =  (isset($_POST['cdcanal'])) ? $_POST['cdcanal'] : 10; 
	if($cddopcao == "C"){
	 	include 'consultar_banners.php';
	}else if($cddopcao == "I" || $cddopcao == "CM"){
		
		if($cddopcao == "I"){
			$cdbanner = 0;
		}
			

		$xml  = '';
		$xml .= '<Root><Dados>';
		$xml .= '<cdcooper>0</cdcooper>';
		$xml .= '<flgativo>1</flgativo>';
		$xml .= '</Dados></Root>';

		// Enviar XML de ida e receber String XML de resposta
		$xmlResultCooper = mensageria($xml, 'CADA0001','LISTA_COOPERATIVAS', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObjetoCooper = getObjectXML($xmlResultCooper);

		// Se ocorrer um erro, mostra crítica
		if (isset($xmlObjetoCooper->roottag->tags[0]->name) && strtoupper($xmlObjetoCooper->roottag->tags[0]->name) == "ERRO") {
			exibeErro($xmlObjetoCooper->roottag->tags[0]->tags[0]->tags[4]->cdata);
			die();
		}
		
		$msgCooper = $xmlObjetoCooper->roottag->tags[0]->tags;
	
		//Carregar os parametros do canal
		$xml  = '';
		$xml .= '<Root><Dados>';
		$xml .= '<cdcanal>'.$cdcanal.'</cdcanal>';
		$xml .= '</Dados></Root>';

		// Enviar XML de ida e receber String XML de resposta
		$xmlResultParamentro = mensageria($xml, 'TELA_PARBAN','TELA_BANNER_PARAMETROS', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObjetoParamentro = getObjectXML($xmlResultParamentro);

		// Se ocorrer um erro, mostra crítica
		if (isset($xmlObjetoParamentro->roottag->tags[0]->name) && strtoupper($xmlObjetoParamentro->roottag->tags[0]->name) == "ERRO") {
			exibeErro($xmlObjetoParamentro->roottag->tags[0]->tags[0]->tags[4]->cdata);
			die();
		}
		$paramentro = $xmlObjetoParamentro->roottag->tags[0]->tags[1]->tags[0]->tags;
		$dsurl_sevidor_imagem = getByTagName($paramentro,'DSURLSERVER');
	
		
		//Carregar banner
		$xml  = '';
		$xml .= '<Root><Dados>';
	
		if($cddopcao == "I"){
			$xml .= '<cdbanner></cdbanner>';
		}
		else{
			$xml .= '<cdbanner>'.$cdbanner.'</cdbanner>';
		}
		$xml .= '<cdcanal>'.$cdcanal.'</cdcanal>';
		$xml .= '</Dados></Root>';

		// Enviar XML de ida e receber String XML de resposta
		$xmlResultBanner = mensageria($xml, 'TELA_PARBAN','TELA_BANNER_CONSULTA', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObjetoBanner = getObjectXML($xmlResultBanner);

		// Se ocorrer um erro, mostra crítica
		if (isset($xmlObjetoBanner->roottag->tags[0]->name) && strtoupper($xmlObjetoBanner->roottag->tags[0]->name) == "ERRO") {
			exibeErro($xmlObjetoBanner->roottag->tags[0]->tags[0]->tags[4]->cdata);
			die();
		}
		$banner = $xmlObjetoBanner->roottag->tags[0]->tags[2]->tags[0]->tags;
		
		//titulo.php
		$dstitulo_banner = getByTagName($banner,'DSTITULO_BANNER');
		$insituacao_banner = getByTagName($banner,'INSITUACAO_BANNER');
		
		//Image - (banner_detalhamento.php)
		$nmimagem_banner2 = getByTagName($banner,'NMIMAGEM_BANNER');
		$urlimagem_banner = $dsurl_sevidor_imagem ;//getByTagName($banner,'URLIMAGEM_BANNER');
		
		//Ação do Banner - (botao_acao.php)
		$inacao_banner = (getByTagName($banner,'INACAO_BANNER') == 1) ? " checked " : "";
		$idacao_banner = (getByTagName($banner,'IDACAO_BANNER') == "") ? 0 : getByTagName($banner,'IDACAO_BANNER');	
		$cdmenu_acao_mobile = getByTagName($banner,'CDMENU_ACAO_MOBILE');
		$exibie_msg_confirmacao = trim(getByTagName($banner,'INEXIBE_MSG_CONFIRMACAO'));
		$inexibe_msg_confirmacao = ( $exibie_msg_confirmacao == "1" ) ? " checked " : "";
		$dslink_acao_banner = getByTagName($banner,'DSLINK_ACAO_BANNER');
		$dsmensagem_acao_banner = getByTagName($banner,'DSMENSAGEM_ACAO_BANNER');
		echo("<script> console.log('dsmensagem_acao_banner = ".$dsmensagem_acao_banner."');</script> ");
		//Exibir para - (exibir_para.php)
		$tpfiltro = getByTagName($banner,'TPFILTRO');
		$dsfiltro_cooperativas = getByTagName($banner,'DSFILTRO_COOPERATIVAS');
    	$dsfiltro_tipos_conta = getByTagName($banner,'DSFILTRO_TIPOS_CONTA');
		$arrDsFiltro = explode(",",$dsfiltro_tipos_conta);
		$dsfiltro_tipos_conta_fis = in_array(1, $arrDsFiltro) ? " checked" : "";
		$dsfiltro_tipos_conta_jur = in_array(2, $arrDsFiltro)  ? " checked" : "";
		$inoutros_filtros = (getByTagName($banner,'INOUTROS_FILTROS')  == "") ? 0  : getByTagName($banner,'INOUTROS_FILTROS') ;
		$dsfiltro_produto = (getByTagName($banner,'DSFILTRO_PRODUTO')  == "") ? 0  : getByTagName($banner,'DSFILTRO_PRODUTO') ;
		
		//Exibir quando - (Exibir_quando.php)
		$inexibir_quando = (getByTagName($banner,'INEXIBIR_QUANDO') == "") ? 0 : getByTagName($banner,'INEXIBIR_QUANDO');
		$dtexibir_de = getByTagName($banner,'DTEXIBIR_DE');
		$dtexibir_ate = getByTagName($banner,'DTEXIBIR_ATE');
		
		$total_registros_importados = (getByTagName($banner,'TOTAL_COOPERADOS_IMPORTADO') == "") ? 0 : getByTagName($banner,'TOTAL_COOPERADOS_IMPORTADO');  
		$nmarquivo_upload = (getByTagName($banner,'NMARQUIVO_UPLOAD') == "") ? "" : getByTagName($banner,'NMARQUIVO_UPLOAD'); 

		if($cddopcao == "I"){
			$insituacao_banner =  1;
			$dsfiltro_tipos_conta_fis =  " checked" ;
			$dsfiltro_tipos_conta_jur =  " checked" ;
		}
		
		echo "<form enctype=\"multipart/form-data\" id=\"frmBanner\" name=\"frmBanner\" class=\"formulario condensado\" method=\"post\" action=\"upload_banner.php\">";
			echo "<input type=\"hidden\" name=\"cdcooper\" id=\"cdcooper\" value=\"".$glbvars["cdcooper"]."\" />";
			echo "<input type=\"hidden\" name=\"cdagenci\" id=\"cdagenci\" value=\"".$glbvars["cdagenci"]."\" />";
			echo "<input type=\"hidden\" name=\"nrdcaixa\" id=\"nrdcaixa\" value=\"".$glbvars["nrdcaixa"]."\" />";
			echo "<input type=\"hidden\" name=\"idorigem\" id=\"idorigem\" value=\"".$glbvars["idorigem"]."\" />";
			echo "<input type=\"hidden\" name=\"cdoperad\" id=\"cdoperad\" value=\"".$glbvars["cdoperad"]."\" />";
			include 'titulo.php'; //ok
			include 'banner_detalhamento.php'; //ok
			include 'botao_acao.php'; //ok
			include 'exibir_para.php'; 
			include 'exibir_quando.php';
		echo "</form>";
	}
?>