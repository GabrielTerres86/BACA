 <?php  
	/*!
	 * FONTE        : upload_automatica.php
	 * CRIAÇÃO      : Jean Michel Deschamps
	 * DATA CRIAÇÃO : 25/09/2017
	 * OBJETIVO     : Rotina para salvar informações de mensagens automáticas da tela ENVNOT
	 * --------------
	 * ALTERAÇÕES   : 
	 * -------------- 
	 */

	session_cache_limiter("private");
	
	session_start();
	
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	function gerarErro($dserro){
		echo "<script>parent.framePrincipal.eval(\"showError('error','".$dserro."','Alerta - Ayllos','hideMsgAguardo();');\");</script>";
		exit;
	}
	
	//Pasta onde o arquivo vai ser salvo 
	$_UP['pasta'] = '/var/www/ayllos/upload_files/';
	$_UP['srvImg'] = $_POST['dsurl_sevidor_imagem']; //ex:https://conteudohml2.cecred.coop.br/imagens/notificacoes/banners/
	
	//Array com os tipos de erros de upload do PHP 
	$_UP['erros'][0] = 'Não houve erro'; 
	$_UP['erros'][1] = 'O arquivo no upload é maior do que o limite do PHP';
	$_UP['erros'][2] = 'O arquivo ultrapassa o limite de tamanho especifiado no HTML';
	$_UP['erros'][3] = 'O upload do arquivo foi feito parcialmente'; 
	$_UP['erros'][4] = 'Não foi feito o upload do arquivo';
	
	//Dados servidor de imagem
	$user = "conteudo";
	$pass = "8974e8c1acb";
		
	//CABECALHO	
	$cdorigem_mensagem = $_POST['hdn_cdorigem_mensagem'];
	$cdmotivo_mensagem = $_POST['hdn_cdmotivo_mensagem'];
	
	//TITULO	
	$dstitulo_mensagem = (isset($_POST['dstitulo_mensagem'])) ? $_POST['dstitulo_mensagem'] : '';
	$cdicone = (isset($_POST['cdicone'])) ? $_POST['cdicone'] : 0;
	$inmensagem_ativa = (isset($_POST['inmensagem_ativa'])) ? $_POST['inmensagem_ativa'] : 0;
	$inenviar_push = (isset($_POST['inenviar_push'])) ? $_POST['inenviar_push'] : 0;
	$dstexto_mensagem = (isset($_POST['dstexto_mensagem'])) ? $_POST['dstexto_mensagem'] : '';
	
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
	
	//RECORRENCIA
	$hrenvio_mensagem = (isset($_POST['hrenvio_mensagem'])) ? $_POST['hrenvio_mensagem'] : '';
	$intipo_repeticao = (isset($_POST['intipo_repeticao'])) ? $_POST['intipo_repeticao'] : 0;
	
	if($intipo_repeticao == 1){ //SEMANAL
		// DIAS DA SEMANA (SEGUNDA A DOMINGO)
		for($d=1;$d <= 7; $d++){
			if($nrdias_semana == ""){
				$nrdias_semana = (isset($_POST['nrdias_semana_'.$d])) ? $d : '';
			}else{
				$nrdias_semana = $nrdias_semana . ((isset($_POST['nrdias_semana_'.$d])) ? ",".$d : '');
			}
		}
		
		// PRIMEIRA A ULTIMA SEMANA DO MÊS
		for($s=1;$s <= 4; $s++){
			if($nrsemanas == ""){
				$nrsemanas = (isset($_POST['nrsemanas_'.$s])) ? $s : '';
			}else{
				$nrsemanas = $nrsemanas . ((isset($_POST['nrsemanas_'.$s])) ? ",".$s : '');
			}
		}
		
		$nrsemanas = $nrsemanas . ((isset($_POST['nrsemanas_U'])) ? ",U" : '');
		
		
	}elseif($intipo_repeticao == 2){ //MENSAL
		$nrdias_mes = (isset($_POST['nrdias_mes'])) ? $_POST['nrdias_mes'] : '';		
		//MESES
		for($m=1; $m <= 12; $m++){
			if($nrmeses == ""){
				$nrmeses = (isset($_POST['nrmeses_'.$m])) ? $m : '';
			}else{
				$nrmeses = $nrmeses . ((isset($_POST['nrmeses_'.$m])) ? ",".$m : '');
			}
		}
	}
			
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
		if ($_FILES['arq_upload']['error'][0] != 0){ 
			gerarErro(utf8_decode("Não foi possível fazer o upload. Erro: ".$_UP['erros'][$_FILES['arq_upload']['error'][0]]));
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
				shell_exec('curl -T '.$_UP['pasta'] . $nmarqimg.' -u '.$user.':'.$pass.' '.$_UP['srvImg']);			
			} catch(Exception $e){
				gerarErro(utf8_decode("Erro ao carregar arquivo!"));
				exit;
			}			
		}		
	}else{
		$nmarqimg = end(explode("/", $_POST["nmimagem_banner"]));
	}
	
	$xml  = '';
	$xml .= '<Root><Dados>';
	//CABECALHO
	$xml .= '<cdorigem_mensagem>'.$cdorigem_mensagem.'</cdorigem_mensagem>';
	$xml .= '<cdmotivo_mensagem>'.$cdmotivo_mensagem.'</cdmotivo_mensagem>';
	//TITULO
	$xml .= '<dstitulo_mensagem>'.$dstitulo_mensagem.'</dstitulo_mensagem>';
	$xml .= '<cdicone>'.$cdicone.'</cdicone>';
	$xml .= '<inmensagem_ativa>'.$inmensagem_ativa.'</inmensagem_ativa>';
	$xml .= '<inenviar_push>'.$inenviar_push.'</inenviar_push>';
	$xml .= '<dstexto_mensagem>'.$dstexto_mensagem.'</dstexto_mensagem>';
	//BANNER DETALHAMENTO
	$xml .= '<inexibir_banner>'.$inexibir_banner.'</inexibir_banner>';
	//CONTEUDO
	$xml .= '<dshtml_mensagem><![CDATA['.$dshtml_mensagem.']]></dshtml_mensagem>';
	//BOTAO ACAO
	$xml .= '<inexibe_botao_acao_mobile>'.$inexibe_botao_acao_mobile.'</inexibe_botao_acao_mobile>';
	$xml .= '<dstexto_botao_acao_mobile>'.$dstexto_botao_acao_mobile.'</dstexto_botao_acao_mobile>';
	$xml .= '<idacao_botao_acao_mobile>'.$idacao_botao_acao_mobile.'</idacao_botao_acao_mobile>';
	$xml .= '<dslink_acao_mobile>'.$dslink_acao_mobile.'</dslink_acao_mobile>';
	$xml .= '<cdmenu_acao_mobile>'.$cdmenu_acao_mobile.'</cdmenu_acao_mobile>';
	$xml .= '<dsmensagem_acao_mobile>'.$dsmensagem_acao_mobile.'</dsmensagem_acao_mobile>';
	//RECORRENCIA
	$xml .= '<hrenvio_mensagem>'.$hrenvio_mensagem.'</hrenvio_mensagem>';
	$xml .= '<intipo_repeticao>'.$intipo_repeticao.'</intipo_repeticao>';
	$xml .= '<nrdias_semana>'.$nrdias_semana.'</nrdias_semana>';
	$xml .= '<nrsemanas>'.$nrsemanas.'</nrsemanas>';
	$xml .= '<nrdias_mes>'.$nrdias_mes.'</nrdias_mes>';
	$xml .= '<nrmeses>'.$nrmeses.'</nrmeses>';	
	$xml .= '<nmimagem_banner>'.$nmarqimg.'</nmimagem_banner>';	
	$xml .= '</Dados></Root>';
	
	// Enviar XML de ida e receber String XML de resposta
	$xmlResultMantemMsgAuto = mensageria($xml, 'TELA_ENVNOT','MANTEM_MSG_AUTOMATICA', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjetoMantemMsgAuto = getObjectXML($xmlResultMantemMsgAuto);

	// Se ocorrer um erro, mostra crítica
	if (isset($xmlObjetoMantemMsgAuto->roottag->tags[0]->name) && strtoupper($xmlObjetoMantemMsgAuto->roottag->tags[0]->name) == "ERRO") {
		if($moveImg && $nmarqimg <> ""){
			try {
				shell_exec('curl -X DELETE '.$_UP['srvImg'] . $nmarqimg.' -u '.$user.':'.$pass);			
			} catch(Exception $e){
				$msgErroArq = "Erro ao deletar arquivo!";
			}			
		}
		gerarErro(utf8_decode(str_replace("'","",$xmlObjetoMantemMsgAuto->roottag->tags[0]->tags[0]->tags[4]->cdata) . $msgErroArq));
		exit;
	}else{
		gerarErro(utf8_decode("Mensagem salva com sucesso!"));
		exit;
	}	
?>