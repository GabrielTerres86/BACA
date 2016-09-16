<?php
	/*!
	 * FONTE        : manter_rotina.php
	 * CRIAÇÃO      : Douglas Quisinski
	 * DATA CRIAÇÃO : 30/07/2015
	 * OBJETIVO     : Rotina para manter as operações da tela CONSPB
	 * --------------
	 * ALTERAÇÕES   : 
	 * -------------- 
	 */		
	 
	if( !ini_get('safe_mode') ){
		set_time_limit(300);
	}
	session_cache_limiter("private");
	session_start();

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],"P")) <> '') {
		gerarErro($msgError);
	}
	
	// Ler parametros passados via POST
	$partes = (isset($_POST['dspartes']))  ? $_POST['dspartes']  : '';
	$opcao  = (isset($_POST['dsdopcao']))  ? $_POST['dsdopcao']  : '';
	$file   = (isset($_FILES['userfile'])) ? $_FILES['userfile'] : '';

	// retorno sera de eval ou html
    $tempo    = time();
    // Local de Upload do arquivo -  Antes de passar pelo "upload_file.php"
	$nmupload  = "../../upload_files/conspb." . $tempo . ".";

	// Instanciar arrays....
	$arrCrit    = array();
	$arrStrFile = array();

	// se destinatario for por upload file
	if($file["error"] > 0){
		switch($file["error"]){
			case 1:	$arrCrit[] = "ATENCAO: Tamanho do arquivo excedeu o permitido.";		break;
			case 2:	$arrCrit[] = "ATENCAO: Tamanho do arquivo deve conter menos de 8 mb.";  break;
			case 3:	$arrCrit[] = "ATENCAO: Falha ao enviar arquivo ER3.";					break;
			case 4:	$arrCrit[] = "ATENCAO: Falha ao enviar arquivo ER4.";					break;
			case 6:	$arrCrit[] = "ATENCAO: Falha ao enviar arquivo ER6.";					break;
			case 7:	$arrCrit[] = "ATENCAO: Falha ao gravar arquivo ER7.";					break;
			case 8:	$arrCrit[] = "ATENCAO: Falha ao enviar arquivo ER8.";					break;
		}
	}

	// Se não encontrar o arquivo...
	if($file == ""){
		$arrCrit[] = "ATENCAO: Arquivo não encontrado.";
	}
	// Verificar o tamanho do arquivo
	if($file["size"] > (8 * (1024 * 1024))){
		$arrCrit[] = "ATENCAO: Tamanho do arquivo deve ser menor que 8 mb.";
	}
	// Validar o arquivo
	if(!is_uploaded_file($file["tmp_name"])){
		$arrCrit[] = "ATENCAO: Erro ao validar arquivo. *VL1.";
	}
	if (!move_uploaded_file($file["tmp_name"], $nmupload.$file["name"])) {
		$arrCrit[] = "ATENCAO: Erro ao validar arquivo. *VL2.";
	}

	// gerar erros criticos
	if(count($arrCrit) > 0){
		gerarErro($arrCrit[0]);
	}

	//pega conteudo do arquivo e bota em string
	$strFile = file_get_contents($nmupload.$file["name"]);
	
	//explode string em um array quando encontrar quebra de linha
	$arrStrFile = explode("\n",$strFile);

	$tempo     = time();
	// Nome do arquivo do upload - Depois de passar pelo "upload_file.php"
	$dirArqDne = "../../upload_files/";
	$filename  = "conspb.". $tempo . ".".$file["name"];
    $Arq       = $nmupload.$file["name"];

	//encriptacao e envio do arquivo
	require("../../includes/upload_file.php");

    // Caminho que deve ser enviado ao Mensageria / para ORACLE fazer exec do CURL
    $caminhoCompleto = $_SERVER['SERVER_NAME'].'/'.str_replace('../../','',$caminho);
    
    // Apaga o arquivo de UPLOAD que está sem Criptografia
    unlink($Arq);
	
	// Monta o xml
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= "		<dspartes>".$partes."</dspartes>";
	$xml .= "		<dsdopcao>".$opcao."</dsdopcao>";
	$xml .= "		<dsarquiv>".$NomeArq."</dsarquiv>";	 // Variável $NomeArq vem da gnuclient_upload_file.php
	$xml .= "		<dsdireto>".$caminhoCompleto."</dsdireto>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "CONSPB", "CONSPB_PROCESSAR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");

	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra crítica
 	if ($xmlObjeto->roottag->tags[0]->name == "ERRO") {
		gerarErro($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}		
	
	$bExisteCritica = false;
 	if ($xmlObjeto->roottag->tags[0]->name == "CRITICAS") {
		foreach($xmlObjeto->roottag->tags[0]->tags as $critica){
			$bExisteCritica = true;
			
			$command = "var objCritica = new Object();" .
					   "objCritica.nrdlinha = '" . getByTagName($critica->tags,'nrdlinha') . "';" .
					   "objCritica.cdtiperr = '" . getByTagName($critica->tags,'cdtiperr') . "';" .
					   "objCritica.cddotipo = '" . getByTagName($critica->tags,'cddotipo') . "';" .
					   "objCritica.nrcontro = '" . getByTagName($critica->tags,'nrcontro') . "';" .
					   "objCritica.nrctrlif = '" . getByTagName($critica->tags,'nrctrlif') . "';" .
					   "objCritica.vlconcil = '" . getByTagName($critica->tags,'vlconcil') . "';" .
					   "objCritica.dtmensag = '" . getByTagName($critica->tags,'dtmensag') . "';" .
					   "objCritica.dsdahora = '" . getByTagName($critica->tags,'dsdahora') . "';" .
					   "objCritica.dscritic = '" . getByTagName($critica->tags,'dscritic') . "';" .
					   "objCritica.dsorigem = '" . getByTagName($critica->tags,'dsorigem') . "';" .
					   "objCritica.dsorigemerro = '" . getByTagName($critica->tags,'dsorigemerro') . "';" .
					   "objCritica.dsespeci = '" . getByTagName($critica->tags,'dsespeci') . "';" .
					   
					   "objCritica.cddbanco_deb = '" . getByTagName($critica->tags,'cddbanco_deb') . "';" .
					   "objCritica.cdagenci_deb = '" . getByTagName($critica->tags,'cdagenci_deb') . "';" .
					   "objCritica.nrdconta_deb = '" . getByTagName($critica->tags,'nrdconta_deb') . "';" .
					   "objCritica.nrcpfcgc_deb = '" . getByTagName($critica->tags,'nrcpfcgc_deb') . "';" .
					   "objCritica.nmcooper_deb = '" . getByTagName($critica->tags,'nmcooper_deb') . "';" .
					   "objCritica.cddbanco_cre = '" . getByTagName($critica->tags,'cddbanco_cre') . "';" .
					   "objCritica.cdagenci_cre = '" . getByTagName($critica->tags,'cdagenci_cre') . "';" .
					   "objCritica.nrdconta_cre = '" . getByTagName($critica->tags,'nrdconta_cre') . "';" .
					   "objCritica.nrcpfcgc_cre = '" . getByTagName($critica->tags,'nrcpfcgc_cre') . "';" .
					   "objCritica.nmcooper_cre = '" . getByTagName($critica->tags,'nmcooper_cre') . "';" .
					   
					   "adicionaCritica(objCritica);";
					   
			echo "<script>" .
					"parent.framePrincipal.eval(\"" . $command . "\");" .
				 "</script>";
		}
	}
	
	if($bExisteCritica) {
		echo "<script>" .
				"parent.framePrincipal.eval(\"processaCriticas();\");" .
			 "</script>";
	} else {
		gerarErro("N&atilde;o foram identificadas inconsistencias.");	
	}

	function gerarErro($dserro,$tipo='error'){
		$dserro = str_replace("'","\\\'",$dserro);
		$dserro = str_replace('"','\\"',$dserro);
		$dserro = str_replace("\n","",$dserro);
		echo "<script>" .
				"parent.framePrincipal.eval(\"showError('".$tipo."','".utf8ToHtml($dserro)."','Alerta - Ayllos','hideMsgAguardo();');\");" .
			 "</script>";
		exit();
	}
?>