<?php 
	
	/* !
	 * FONTE        : upload_manual.php
	 * CRIACAO      : Jean Michel
	 * DATA CRIACAO : 25/09/2017
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
	$_UP['srvImg'] = $_POST['dsurl_sevidor_imagem']; //ex:https://conteudohml2.cecred.coop.br/imagens/notificacoes/banners/
	
	// Array com os tipos de erros de upload do PHP 
	$_UP['erros'][0] = 'Não houve erro'; 
	$_UP['erros'][1] = 'O arquivo no upload é maior do que o limite do PHP';
	$_UP['erros'][2] = 'O arquivo ultrapassa o limite de tamanho especifiado no HTML';
	$_UP['erros'][3] = 'O upload do arquivo foi feito parcialmente'; 
	$_UP['erros'][4] = 'Não foi feito o upload do arquivo';
	
	// Dados servidor de imagem
	$user = "conteudo";
	$pass = "c0n10.t3u1d70"; //Senha de homol: "8974e8c1acb";
		
	// Captura as informações enviadas via POST
	//CABECALHO
	$cdmensagem = (isset($_POST['hdnCdmensagem'])) ? $_POST['hdnCdmensagem'] : 0; 
	//TITULO
	$dstitulo_mensagem = (isset($_POST['dstitulo_mensagem'])) ? $_POST['dstitulo_mensagem'] : "";
	$cdicone = (isset($_POST['cdicone'])) ? $_POST['cdicone'] : 0;
	$inenviar_push = (isset($_POST['inenviar_push'])) ? $_POST['inenviar_push'] : 0;
	$dstexto_mensagem = (isset($_POST['dstexto_mensagem'])) ? $_POST['dstexto_mensagem'] : "";
	//BANNER DETALHAMENTO
	$inexibir_banner = (isset($_POST['inexibir_banner'])) ? 1 : 0;
	//CONTEUDO
	$dshtml_mensagem = (isset($_POST['dshtml_mensagem'])) ? $_POST['dshtml_mensagem'] : "";
	//BOTAO ACAO
	$inexibe_botao_acao_mobile = (isset($_POST['inexibe_botao_acao_mobile'])) ? 1 : 0;
	$dstexto_botao_acao_mobile = (isset($_POST['dstexto_botao_acao_mobile'])) ? $_POST['dstexto_botao_acao_mobile'] : "";
	$idacao_botao_acao_mobile = (isset($_POST['idacao_botao_acao_mobile'])) ? $_POST['idacao_botao_acao_mobile'] : 0;
	$dslink_acao_mobile = (isset($_POST['dslink_acao_mobile'])) ? $_POST['dslink_acao_mobile'] : "";
	$cdmenu_acao_mobile = (isset($_POST['cdmenu_acao_mobile'])) ? $_POST['cdmenu_acao_mobile'] : 0;
	$dsmensagem_acao_mobile = (isset($_POST['dsmensagem_acao_mobile'])) ? $_POST['dsmensagem_acao_mobile'] : "";
	//ENVIAR PARA
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
	$tpfiltro_mobile = (isset($_POST['tpfiltro_mobile'])) ? $_POST['tpfiltro_mobile'] : 0;
	//ENVIAR EM
	$dtenvio_mensagem = (isset($_POST['dtenvio_mensagem'])) ? $_POST['dtenvio_mensagem'] : "";
	$hrenvio_mensagem = (isset($_POST['hrenvio_mensagem'])) ? $_POST['hrenvio_mensagem'] : "";
		
	// VARIAVEIS PARA BD
	$glbvars["cdcooper"] = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : 0;
	$glbvars["cdagenci"] = (isset($_POST['cdagenci'])) ? $_POST['cdagenci'] : 0;
	$glbvars["nrdcaixa"] = (isset($_POST['nrdcaixa'])) ? $_POST['nrdcaixa'] : 0;
	$glbvars["idorigem"] = (isset($_POST['idorigem'])) ? $_POST['idorigem'] : 1;
	$glbvars["cdoperad"] = (isset($_POST['cdoperad'])) ? $_POST['cdoperad'] : "0";
		
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
				gerarErro(utf8_decode("Erro ao carregar arquivo!"));
				exit;
			}			
		}	
		$inexibir_banner = 1;
	}else{
		$nmarqimg = $_POST["nmimagem_banner"];
	}
	
	//UPLOAD ARQUIVO CSV/TXT	
	if($tpfiltro == 2){
		if(!isset($_FILES['arq_upload']['name'][1]) && trim($_FILES['arq_upload']['name'][1] == "")){
			exibeErro("Selecione um arquivo para upload!");
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
			
		$moveArq = false;
		
		// Depois verifica se é possível mover o arquivo para a pasta escolhida 
		if(move_uploaded_file($_FILES['arq_upload']['tmp_name'][1], $_UP['pasta'] . $nmarquiv)){ 
			$moveArq = true;
		}else{
			$moveArq = false;
			// Não foi possível fazer o upload, provavelmente a pasta está incorreta 
			gerarErro(utf8_decode("Erro ao carregar arquivo(2)!"));
			exit;
		}
		
		if($moveArq){
			
			$xmlConta = "<contas>";
			
			// Pega conteudo do arquivo e bota em string
			$strFile = file_get_contents($_UP['pasta'] . $nmarquiv);
			
			// Explode string em um array quando encontrar quebra de linha
			$arrStrFile = explode("\n",$strFile);
			
			// Verificacao por linha
			for($x=0;$x<count($arrStrFile);$x++){
				
				if(strpos($arrStrFile[$x],";") === false){
					$arrCrit[] = "ATENCAO: Separador de parâmetros não encontrado em linha ".($x+1).".";
				}
				$arrLinha = explode(";",$arrStrFile[$x]);
				
				$cdcooper = (is_numeric(trim($arrLinha[0])) == "") ? 0 : trim($arrLinha[0]);
				$nrdconta = (is_numeric(trim($arrLinha[1])) == "") ? 0 : trim($arrLinha[1]);
				$idseqttl = (array_key_exists($arrLinha[2])) ? trim($arrLinha[2]) : 0;
			
				if(!is_numeric($cdcooper) || (!is_numeric($nrdconta))){
					$arrCrit[] = "ATENCAO: Parâmetro incorreto em linha ".($x+1) . ".Conta: " . $nrdconta;
				}else if((strlen($cdcooper) > 2) || (strlen($nrdconta) > 8) || $nrdconta == 0 || $cdcooper == 0){
					$arrCrit[] = "ATENCAO: Conta inválida em linha ".($x+1).".";
				}else{
					$xmlConta .= "<conta><cdcooper>".trim($cdcooper)."</cdcooper><nrdconta>".trim($nrdconta)."</nrdconta><idseqttl>".trim($idseqttl)."</idseqttl></conta>";					
				}
			}
			// GERAR ERROS CRITICOS
			if(count($arrCrit) > 0){
				gerarErro(utf8_decode($arrCrit[0]));
			}
			
			$xmlConta .= "</contas>";
		}		
	}
	
	$xml  = '';
	$xml .= '<Root><Dados>';
	$xml .= '<cdmensagem>'.$cdmensagem.'</cdmensagem>';
	$xml .= '<dstitulo_mensagem>'.$dstitulo_mensagem.'</dstitulo_mensagem>';
	$xml .= '<dstexto_mensagem>'.$dstexto_mensagem.'</dstexto_mensagem>';
	$xml .= '<dshtml_mensagem><![CDATA['.$dshtml_mensagem.']]></dshtml_mensagem>';
	$xml .= '<inexibe_botao_acao_mobile>'.$inexibe_botao_acao_mobile.'</inexibe_botao_acao_mobile>';
	$xml .= '<dstexto_botao_acao_mobile>'.$dstexto_botao_acao_mobile.'</dstexto_botao_acao_mobile>';
	$xml .= '<idacao_botao_acao_mobile>'.$idacao_botao_acao_mobile.'</idacao_botao_acao_mobile>';
	$xml .= '<cdmenu_acao_mobile>'.$cdmenu_acao_mobile.'</cdmenu_acao_mobile>';
	$xml .= '<dslink_acao_mobile>'.$dslink_acao_mobile.'</dslink_acao_mobile>';
	$xml .= '<dsmensagem_acao_mobile>'.$dsmensagem_acao_mobile.'</dsmensagem_acao_mobile>';
	$xml .= '<cdicone>'.$cdicone.'</cdicone>';
	$xml .= '<inexibir_banner>'.$inexibir_banner.'</inexibir_banner>';
	$xml .= '<nmimagem_banner>'.$nmarqimg.'</nmimagem_banner>';
	$xml .= '<inenviar_push>'.$inenviar_push.'</inenviar_push>';
	$xml .= '<dtenvio_mensagem>'.$dtenvio_mensagem.'</dtenvio_mensagem>';
	$xml .= '<hrenvio_mensagem>'.$hrenvio_mensagem.'</hrenvio_mensagem>';
	$xml .= '<tpfiltro>'.$tpfiltro.'</tpfiltro>';
	$xml .= '<dsfiltro_cooperativas>'.$dsfiltro_cooperativas.'</dsfiltro_cooperativas>';
	$xml .= '<dsfiltro_tipos_conta>'.$dsfiltro_tipos_conta_fis.','.$dsfiltro_tipos_conta_jur.'</dsfiltro_tipos_conta>';
	$xml .= '<tpfiltro_mobile>'.$tpfiltro_mobile.'</tpfiltro_mobile>';
	$xml .= '<nmarquivo_csv>'.$nmarquiv.'</nmarquivo_csv>';
	$xml .= '<dsxml_destinatarios><![CDATA['.$xmlConta.']]></dsxml_destinatarios>';	
	$xml .= '</Dados></Root>';

	// Enviar XML de ida e receber String XML de resposta
	$xmlResultMantemMsgManu = mensageria($xml, 'TELA_ENVNOT','MANTEM_MSG_MANUAL', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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