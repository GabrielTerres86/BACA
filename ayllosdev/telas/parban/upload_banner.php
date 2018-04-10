<?php 
	
	/* !
	 * FONTE        : upload_manual.php
	 * CRIACAO      : Gustavo Meyer
	 * DATA CRIACAO : 28/02/2018
	 * OBJETIVO     : Rotina para salvar informações de mensagens manuais da tela ENVNOT
	 * --------------
	 * ALTERCOES   : 
	 * -------------- 
	**/
	
	session_cache_limiter("private");
	
	session_start();
	
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
		
	// Pasta onde o arquivo vai ser salvo 
	$_UP['pasta'] = '/var/www/ayllos/upload_files/';
	$caminhoCompleto = '';
	$_UP['srvImg'] = $_POST['dsurl_sevidor_imagem']; //ex:https://conteudohml2.cecred.coop.br/imagens/notificacoes/banners/

	// Array com os tipos de erros de upload do PHP 
	$_UP['erros'][0] = 'Não houve erro'; 
	$_UP['erros'][1] = 'O arquivo no upload é maior do que o limite do PHP';
	$_UP['erros'][2] = 'O arquivo ultrapassa o limite de tamanho especifiado no HTML';
	$_UP['erros'][3] = 'O upload do arquivo foi feito parcialmente'; 
	$_UP['erros'][4] = 'Não foi feito o upload do arquivo';
	
	// VARIAVEIS PARA BD
	$glbvars["cdcooper"] = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : 0;
	$glbvars["cdagenci"] = (isset($_POST['cdagenci'])) ? $_POST['cdagenci'] : 0;
	$glbvars["nrdcaixa"] = (isset($_POST['nrdcaixa'])) ? $_POST['nrdcaixa'] : 0;
	$glbvars["idorigem"] = (isset($_POST['idorigem'])) ? $_POST['idorigem'] : 1;
	$glbvars["cdoperad"] = (isset($_POST['cdoperad'])) ? $_POST['cdoperad'] : "0";
	
	
	$cdCanal = (isset($_POST['hdncdCanal'])) ? $_POST['hdncdCanal'] : 10; //10 - mobile ou 
	
	$operacaoDaTela = (isset($_POST['hdnOpcao']) && $_POST['hdnOpcao'] != '') ? $_POST['hdnOpcao'] : 'I';
	$totalRegistrosImportados = (isset($_POST['totalRegistrosImportados']) && $_POST['totalRegistrosImportados'] > 0) ? $_POST['totalRegistrosImportados'] : 0;
	
	// Acessos de paramentros do servidor de imagem
	$xml  = '';
	$xml .=  '<Root><Dados>';
	$xml .=  '<cdcanal>'.$cdCanal.'</cdcanal>';
	$xml .=  '</Dados></Root>';
	
	//echo("<script> console.log('".$xml."');</script> ");
	
	$xmlResultParamentroServidorDeImage = mensageria($xml, 'TELA_PARBAN','TELA_BANNER_ACESSO_SERVIMAGEM', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjetoParamentroServidorDeImage = getObjectXML($xmlResultParamentroServidorDeImage);

	// Se ocorrer um erro, mostra crítica
	if (isset($xmlObjetoParamentroServidorDeImage->roottag->tags[0]->name) && strtoupper($xmlObjetoParamentroServidorDeImage->roottag->tags[0]->name) == "ERRO") {
		gerarErro($xmlObjetoParamentroServidorDeImage->roottag->tags[0]->tags[0]->tags[4]->cdata);
		exit;
	}		
	
	$paramentroServidorDeImage = $xmlObjetoParamentroServidorDeImage->roottag->tags[0]->tags[1]->tags;
	$user = getByTagName($paramentroServidorDeImage,'DSUSER_URLSERVER'); 
	$pass = getByTagName($paramentroServidorDeImage,'DSPWD_URLSERVER'); 

	// Captura as informações enviadas via POST	
	//CABECALHO
	$cdBanner = (isset($_POST['hdncdBanner'])) ? $_POST['hdncdBanner'] : 0; 
	//TITULO
	$dstitulo_banner = (isset($_POST['dstitulo_banner'])) ? $_POST['dstitulo_banner'] : "";
	$insituacao_banner = (isset($_POST['insituacao_banner'])) ? $_POST['insituacao_banner'] : 0;
 	
	
	//BANNER DETALHAMENTO
	//$inexibir_banner = (isset($_POST['inexibir_banner'])) ? 1 : 0;
	$inexibir_banner = 0;
	//BOTAO ACAO
	$inacao_banner = (isset($_POST['inacao_banner'])) ? 1 : 0;

	$inexibe_msg_confirmacao = (isset($_POST['inexibe_msg_confirmacao'])) ? 1 : 0;
	// $dstexto_botao_acao_mobile = (isset($_POST['dstexto_botao_acao_mobile'])) ? $_POST['dstexto_botao_acao_mobile'] : "";
	$idacao_banner = (isset($_POST['idacao_banner'])) ? $_POST['idacao_banner'] : 0;
	$dslink_acao_banner = (isset($_POST['dslink_acao_banner'])) ? $_POST['dslink_acao_banner'] : "";
	$cdmenu_acao_mobile = (isset($_POST['cdmenu_acao_mobile'])) ? $_POST['cdmenu_acao_mobile'] : 0;
	$dsmensagem_acao_banner = (isset($_POST['dsmensagem_acao_banner'])) ? $_POST['dsmensagem_acao_banner'] : "";
	//EXIBIR PARA
	$tpfiltro = (isset($_POST['tpfiltro'])) ? $_POST['tpfiltro'] : 1; //Tipo de Filtos(1-Filtros,2-Upload)
	
	if(isset($_POST["dsfiltro_cooperativas"])){
		foreach ($_POST["dsfiltro_cooperativas"] as $cdcooper) {
			$dsfiltro_cooperativas .= "," . $cdcooper;
		}
		$dsfiltro_cooperativas = substr($dsfiltro_cooperativas,1);	
	}else{
		$dsfiltro_cooperativas = $_POST['cdcooper'];
	}
	
	$dsfiltro_tipos_conta_fis = (isset($_POST['dsfiltro_tipos_conta_fis'])) ? $_POST['dsfiltro_tipos_conta_fis'] : 0;
	$dsfiltro_tipos_conta_jur = (isset($_POST['dsfiltro_tipos_conta_jur'])) ? $_POST['dsfiltro_tipos_conta_jur'] : 0;
	
	$dsfiltro_produto = (isset($_POST['dsfiltro_produto'])) ? $_POST['dsfiltro_produto'] : 0;
	$inoutros_filtros = ($dsfiltro_produto == 0 || $dsfiltro_produto == "") ? 0 : 1;
	//EXIBIR QUANDO
	$inexibir_quando = (isset($_POST['inexibir_quando'])) ? $_POST['inexibir_quando'] : 0;
	$dtexibir_de = (isset($_POST['dtexibir_de'])) ? $_POST['dtexibir_de'] : "";
	$dtexibir_ate = (isset($_POST['dtexibir_ate'])) ? $_POST['dtexibir_ate'] : "";

	if(deveImportarArquivoCSV($tpfiltro, $operacaoDaTela, $totalRegistrosImportados)){
		if(!arquivoCSVFoiAnexado()){
			gerarErro("Selecione um arquivo para upload.");
		}
	}
		
	// UPLOAD DE BANNERS	
	if(isset($_FILES['arq_upload']['name'][0]) && trim($_FILES['arq_upload']['name'][0] != "")){
		
		$nmarqimg = retiraAcentos(strtolower(str_replace(" ","_",$_FILES['arq_upload']['name'][0])));
		
		// VERIFICA SE JÁ EXISTE UMA IMAGEM COM MESMO NOME NO SERVIDOR
		$get_http_response_code = get_http_response_code($_UP['srvImg'].$nmarqimg);

		if ($get_http_response_code == 200 ) {
			gerarErro(utf8_decode("Já existe uma imagem de banner com o mesmo nome. Por favor, renomeie o arquivo e selecione-o novamente."));
			exit;
		}
		
		// Tamanho máximo do arquivo (em Bytes)
		$_UP['tamanho'] = 1024 * 1024 * 3; // 3Mb
		
		// Array com as extensões permitidas 
		$_UP['extensoes'] = array('jpg','png','gif','jpeg');
		
		// Verifica se houve algum erro com o upload. Se sim, exibe a mensagem do erro 
		if (trim($_FILES['arq_upload']['error'][0]) != 0 && trim($_FILES['arq_upload']['error'][0]) != "0"){ 
			gerarErro(utf8_decode("Não foi possível fazer o upload da imagem. Erro: ".$_UP['erros'][$_FILES['arq_upload']['error'][0]]));
			exit; // Para a execução do script 
		}
		
		// Faz a verificação da extensão do arquivo 
		$extensao = strtolower(end(explode('.', $nmarqimg)));
		
		// Valida extensão do arquivo
		if (array_search($extensao, $_UP['extensoes']) === false) {
			gerarErro(utf8_decode("Por favor, selecione arquivos com as seguintes extensões: jpg, png, gif ou jpeg."));
			exit;
		}
		
		// Faz a verificação do tamanho do arquivo 
		if ($_UP['tamanho'] < ($_FILES['arq_upload']['size'][0])){
			gerarErro(utf8_decode("O arquivo selecione é muito grande, selecione arquivos de até 3Mb."));
			exit; 
		}
		
		// Depois verifica se é possível mover o arquivo para a pasta escolhida 
		if(move_uploaded_file($_FILES['arq_upload']['tmp_name'][0], $_UP['pasta'] . $nmarqimg)){ 
			$moveImg = true;
		}else{
			$moveImg = false;
			// Não foi possível fazer o upload, provavelmente a pasta está incorreta 
			gerarErro(utf8_decode("Erro ao carregar arquivo(2)!"));
			exit;
		}

		if($moveImg){

			try {
			  shell_exec('curl -T '.$_UP['pasta'] . $nmarqimg . ' -u '.$user.':'.$pass.' '.$_UP['srvImg']);			
			} catch(Exception $e){
				//echo("<script> console.log('Exception');</script> ");
				gerarErro(utf8_decode("Erro ao carregar arquivo!"));
				exit;
			}			
		}	
		$inexibir_banner = 1;
	}else{
		$nmarqimg = $_POST["nmimagem_banner"];
	}
	
	//UPLOAD ARQUIVO CSV/TXT	
	if(deveImportarArquivoCSV($tpfiltro, $operacaoDaTela, $totalRegistrosImportados)){
		
		if(!arquivoCSVFoiAnexado()){
			gerarErro(utf8_decode("Selecione um arquivo para upload!"));
		}
		
		$nmarquiv = retiraAcentos(strtolower(str_replace(" ","_",$_FILES['arq_upload']['name'][1])));
			
		// Tamanho máximo do arquivo (em Bytes)
		$_UP['tamanho'] = 1024 * 1024 * 1; // 1Mb 		
	
		// Array com as extensões permitidas 
		$_UP['extensoes'] = array('txt','csv');
	
		// Verifica se houve algum erro com o upload. Se sim, exibe a mensagem do erro 
		if ($_FILES['arq_upload']['error'][1] != 0){ 
			gerarErro(utf8_decode("Não foi possível fazer o upload do arquivo CSV. Erro: " . $_UP['erros'][$_FILES['arq_upload']['error'][1]]));
			exit; // Para a execução do script 
		}
			
		// Faz a verificação da extensão do arquivo 
		$extensao = strtolower(end(explode('.', $nmarquiv)));
		
		// Valida extensão do arquivo
		if (array_search($extensao, $_UP['extensoes']) === false) {
			gerarErro(utf8_decode("Por favor, selecione arquivos com as seguintes extensões: txt ou csv."));
			exit;
		}
	
		// Faz a verificação do tamanho do arquivo 
		if ($_UP['tamanho'] < ($_FILES['arq_upload']['size'][1])){
			gerarErro(utf8_decode("O arquivo selecione é muito grande, selecione arquivos de até 1Mb."));
			exit; 
		}

		// Depois verifica se é possível mover o arquivo para a pasta escolhida 
		$nmarquiv = '003.0.parban_'.date('Ymdhis').'_'.$nmarquiv;
		if(!move_uploaded_file($_FILES['arq_upload']['tmp_name'][1], $_UP['pasta'] . $nmarquiv)){ 
			// Não foi possível fazer o upload, provavelmente a pasta está incorreta 
			gerarErro(utf8_decode("Erro ao carregar arquivo(2)!"));
			exit;
		}

		// Caminho que deve ser enviado ao Mensageria / para ORACLE fazer exec do CURL
		$caminhoCompleto = $_SERVER['SERVER_NAME'].'/upload_files/';
	}
	
	$xml  = '';
	$xml .= '<Root><Dados>';
	$xml .= '<cdbanner>'.$cdBanner.'</cdbanner>';
	$xml .= '<cdcanal>'.$cdCanal.'</cdcanal>';
	$xml .= '<dstitulo_banner>'.$dstitulo_banner.'</dstitulo_banner>';
	$xml .= '<insituacao_banner>'.$insituacao_banner.'</insituacao_banner>';
	
	$xml .= '<nmimagem_banner>'.$nmarqimg.'</nmimagem_banner>';
	//inacao_banner
	
	$xml .= '<inacao_banner>'.$inacao_banner.'</inacao_banner>';
	//$xml .= '<inexibir_banner>'.$inexibir_banner.'</inexibir_banner>';
	$xml .= '<idacao_banner>'.$idacao_banner.'</idacao_banner>';
	$xml .= '<cdmenu_acao_mobile>'.$cdmenu_acao_mobile.'</cdmenu_acao_mobile>';
	$xml .= '<dslink_acao_banner>'.$dslink_acao_banner.'</dslink_acao_banner>';
	$xml .= '<dsmensagem_acao_banner>'.$dsmensagem_acao_banner.'</dsmensagem_acao_banner>';

	$xml .= '<tpfiltro>'.$tpfiltro.'</tpfiltro>';
	$xml .= '<inexibir_quando>'.$inexibir_quando.'</inexibir_quando>';
	$xml .= '<dtexibir_de>'.$dtexibir_de.'</dtexibir_de>';
	$xml .= '<dtexibir_ate>'.$dtexibir_ate.'</dtexibir_ate>';
	$xml .= '<nmarquivo_upload>'.$nmarquiv.'</nmarquivo_upload>';
	$xml .= "<caminho_arq_upload>".$caminhoCompleto."</caminho_arq_upload>";
	$xml .= '<dsfiltro_cooperativas>'.$dsfiltro_cooperativas.'</dsfiltro_cooperativas>';
	$xml .= '<inoutros_filtros>'.$inoutros_filtros.'</inoutros_filtros>';
	$xml .= '<dsfiltro_produto>'.$dsfiltro_produto.'</dsfiltro_produto>';
	$xml .= '<inexibe_msg_confirmacao>'.$inexibe_msg_confirmacao.'</inexibe_msg_confirmacao>';

	$xml .= '<dsfiltro_tipos_conta>'.$dsfiltro_tipos_conta_fis.','.$dsfiltro_tipos_conta_jur.'</dsfiltro_tipos_conta>';
	$xml .= '</Dados></Root>';

	//echo("<script> console.log('".$xml."');</script> ");

	// Enviar XML de ida e receber String XML de resposta
	$xmlResultMantemMsgManu = mensageria($xml, 'TELA_PARBAN','TELA_BANNER_MANTEM', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjetoMantemMsgManu = getObjectXML($xmlResultMantemMsgManu);

	// Se ocorrer um erro, mostra crítica
	if (isset($xmlObjetoMantemMsgManu->roottag->tags[0]->name) && strtoupper($xmlObjetoMantemMsgManu->roottag->tags[0]->name) == "ERRO") {
		gerarErro($xmlObjetoMantemMsgManu->roottag->tags[0]->tags[0]->tags[4]->cdata);
		exit;
	}else{
		//gerarErro(utf8_decode("Cadastro efetuado com sucesso!"));
		echo "<script>parent.framePrincipal.eval(\"showError('inform','Cadastro efetuado com sucesso!','Alerta - Ayllos','hideMsgAguardo(); estadoInicial();');\");</script>";
		exit;
	}		
	
	function arquivoCSVFoiAnexado(){
		return (isset($_FILES['arq_upload']['name'][1]) && trim($_FILES['arq_upload']['name'][1]) != "");
	}
	
	function deveImportarArquivoCSV($tpfiltro, $operacaoDaTela, $totalRegistrosImportados){
		
		if($tpfiltro == 1){
			if($operacaoDaTela == 'I'){
				return true;
				
			}
			
			if($operacaoDaTela == 'CM'){
	
				if($totalRegistrosImportados == 0){
					return true;
				}
				
				if(arquivoCSVFoiAnexado()){
					return true;
				}
			}
		}
    
		return false;
	}
	
	function gerarErro($dserro){
		if(($moveImg) && $nmarqimg <> ""){
			try {
			  $resultExec = shell_exec('curl -X DELETE '.$_UP['srvImg'] . $nmarqimg.' -u '.$user.':'.$pass);	
				$msgErroArq = "";
			} catch(Exception $e){
				$msgErroArq = " Erro ao deletar arquivo!";
			}
			if(trim($resultExec) == ""){
				gerarErro(utf8_decode("Erro ao acessar servidor de imagens!"));
				exit;
			}	
		}
		echo "<script>parent.framePrincipal.eval(\"showError('error','".$dserro . $msgErroArq."','Alerta - Ayllos','hideMsgAguardo();');\");</script>";
		exit;
	}
?>