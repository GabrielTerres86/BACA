<?php
/*!
 * FONTE        : upload_cargas_sas_rotina.php
 * CRIAÇÃO      : Christian Grauppe - ENVOLTI
 * DATA CRIAÇÃO : Janeiro/2019
 * OBJETIVO     : Upload dos arquivos de inclusão e exclusão de cargas
 * --------------
 * ALTERAÇÕES   :
 
    08/03/2019 - Ajustes para realizar upload em todos os ambientes (Petter Rafael - Envolti)
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

	$operacao = (isset($_POST["operacao"])) ? $_POST["operacao"] : '';
	$ambiente = getAmbiente($_SERVER['SERVER_NAME']);

	if($ambiente == 'dev'){
	$dirArqDne = "/var/www/ayllos/upload_files/";
	}else if($ambiente == 'hml'){
		$dirArqDne = "/var/www/ayllos/upload_files/";
	}else{
		$dirArqDne = "../../upload_files/";
	}
	
	$tempo     = time();

	function moedaPhp($str_num){
		$resultado = str_replace('.', '', $str_num);
		$resultado = str_replace(',', '.', $resultado);
		return $resultado;
	}

	// Ler parametros passados via POST
	//$nrdconta  = $_POST['nrdconta'];
	$file = (isset($_FILES['userfile'])) ? $_FILES['userfile'] : '';

	// retorno sera de eval ou html
	$eval = (isset($_POST['redirect'])) ? true : false;

    // Local de Upload do arquivo -  Antes de passar pelo "upload_file.php"
	if ($operacao == 'L') { // I - Importar Carga via Arquivo
		$nomeArq  = "imppre_sas_m." . $tempo . ".txt";
	} else { // E - Exclusão de CPF/CNPJ via CSV
		$nomeArq  = "imppre_exclu_e." . $tempo . ".txt";
	}

	$nmupload = $dirArqDne . $nomeArq;

	// Instanciar arrays....
	$arrCrit = array();
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
	if($file == "") {
		$arrCrit[] = "ATENCAO: Arquivo n&atilde;o encontrado.";
	}
	// Verificar o tamanho do arquivo
	if($file["size"] > (8 * (1024 * 1024))) {
		$arrCrit[] = "ATENCAO: Tamanho do arquivo deve ser menor que 8 mb.";
	}
	// Validar o arquivo
	if(!is_uploaded_file($file["tmp_name"])) {
		$arrCrit[] = "ATENCAO: Erro ao validar arquivo. *VL1.";
	}

	//$nmupload = "./imppre_sas." . $tempo . ".txt";
	if (!move_uploaded_file($file["tmp_name"], $nmupload)) {
		$arrCrit[] = "ATENCAO: Erro ao validar arquivo. *VL2.";
	}

	// gerar erros criticos
	if(count($arrCrit) > 0){
		gerarErro($arrCrit[0]);
	}

	// Nome do arquivo do upload - Depois de passar pelo "upload_file.php"
	if ($operacao == 'L') { // M - Importar Carga via Arquivo
		$filename  = "imppre_sas_m." . $tempo . ".txt";
	} else { // E - Exclusão de CPF/CNPJ via CSV
		$filename  = "imppre_exclu_e." . $tempo . ".txt";
	}

	/* $dirArqDne = "/var/www/ayllos/upload_files/";
	$filename  = "imppre_sas." . $tempo . ".txt"; */
    $Arq = $nmupload;

	//encriptacao e envio do arquivo
	require("../../includes/upload_file.php");

    // Caminho que deve ser enviado ao Mensageria / para ORACLE fazer exec do CURL
	if($ambiente == 'dev'){
		$caminhoCompleto = 'ayllosdev2.cecred.coop.br/upload_files/';
	}else if($ambiente == 'hml'){
		$caminhoCompleto = $_SERVER['SERVER_NAME']. '/upload_files/';
	}else{
		$caminhoCompleto = $_SERVER['SERVER_NAME'] . '/' . str_replace('../../', '', $caminho);
	}

    // Apaga o arquivo de UPLOAD que está sem Criptografia
    unlink($Arq);

	// Monta o xml
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= "		<tpexecuc>S</tpexecuc>";
	$xml .= "		<dsarquivo>".$NomeArq."</dsarquivo>";	 // Variável $NomeArq vem da gnuclient_upload_file.php
	$xml .= "		<dsdiretor>".$caminhoCompleto."</dsdiretor>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";

	if ($operacao == 'L') {
		$nmeacao = "EXEC_CARGA_MANUAL";
		$glbvars["opcpermi"] = "L";
	} else {
		$nmeacao = "EXEC_EXCLU_MANUAL";
		$glbvars["opcpermi"] = "E";
	}

	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "TELA_IMPPRE", $nmeacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");

	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML(utf8_encode($xmlResult));

	// Se ocorrer um erro, mostra crítica
 	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
	    gerarErro($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,"","error");
    } else {
		$registros = $xmlObjeto->roottag->tags[0]->tags[0]->tags;
		$atrib = $xmlObjeto->roottag->tags[0]->attributes; 
		$msg = $atrib['MENSAGEM'];
		$flgerro = $atrib['FLGERRO'];
		$flgBloqCarga = $atrib['FLGBLOQCARGA'];

		if(empty($flgerro)){
			$flgerro = 'N';
		}
		if(empty($flgBloqCarga)){
			$flgBloqCarga = 'N';
		}
	}

	$tabelaCoop = $tabela = "";

	// Monta a tabela de retorno

	$tabela .= "<input type='hidden' name='dsarquiv' id='dsarquiv' value='".$NomeArq."' />";
	$tabela .= "<input type='hidden' name='dsdireto' id='dsdireto' value='".$caminhoCompleto."' />";
	
	$tabela .= "<div id='divRegistrosCargas'><br />";
	$tabela .=	"<div class='divRegistros'>";
	$tabela .= 	"<table>";
	$tabela .=		"<thead>";

	if ($operacao == 'L') {

		$tabela .=			"<tr>";
		$tabela .=				"<th>Coop.</th>";
		$tabela .=				"<th>Vig&ecirc;ncia</th>";
		$tabela .=				"<th>Descri&ccedil;&atilde;o</th>";
		$tabela .=				"<th>Texto Anota</th>";
		$tabela .=				"<th>Qtd. PF</th>";
		$tabela .=				"<th>Qtd. PJ</th>";
		$tabela .=				"<th>Qtd. Tot</th>";
		$tabela .=				"<th>Valor Pot. Parc. Max</th>";
		$tabela .=				"<th>Valor Pot. Lim. Max</th>";
		$tabela .=				"<th>Valor Lim. Total</th>";
		$tabela .=				"<th>Qtd. Erros</th>";
		$tabela .=			"</tr>";
		$tabela .=		"</thead>";

		$tabela .=		"<tbody>";

		// Se encontrar registros para exibir
		if (count($registros) > 0) {
			$totalValorParc = $totalValorLim = 0;
			$tabelaCoop .= "<div id='divRegistrosCoop' style='display:none;'>";
			foreach( $registros as $critic ) {
				$idlinha = getByTagName($critic->tags,'idlinha');
				$cdcooper = getByTagName($critic->tags,'cdcooper');
				$dtvigen = getByTagName($critic->tags,'dtvigen');
				$dscarga = getByTagName($critic->tags,'dscarga');
				$dsatenda = getByTagName($critic->tags,'dsatenda');
				$vlpotpar = getByTagName($critic->tags,'vlpotpar');
				$vlpotlim = getByTagName($critic->tags,'vlpotlim');
				$qtregipj = getByTagName($critic->tags,'qtregipj');
				$qtregipf = getByTagName($critic->tags,'qtregipf');
				$vlpotlimtot = getByTagName($critic->tags,'vlpotlimtot');
				$qtderros = getByTagName($critic->tags,'qtderros');
				$qtdregistros = getByTagName($critic->tags,'qtdregistros');
				$cooperados = $critic->tags[12]->tags;
				
				$totalValorParc += moedaPhp($vlpotpar);
				$totalValorLim += moedaPhp($vlpotlim);
				$totalvlpotlimtot += moedaPhp($vlpotlimtot);

				$tabela .=		"<tr id='".$idlinha."'>";
				$tabela .=			"<input type='hidden' name='idlinha' value='".$idlinha."' />";
				$tabela .=			"<input type='hidden' name='qtderros' value='".$qtderros."' />";
				$tabela .=			"<td>";

				if (count($cooperados) > 0) {
					$tabelaCoop .=	"<div class='divRegistros'>";
					$tabelaCoop .=		"<table id='cooperados".$idlinha."'>";
					$tabelaCoop .=			"<thead style='display:none;'>";
					$tabelaCoop .=				"<tr>";
					$tabelaCoop .=					"<th>Linha</th>";
					$tabelaCoop .=					"<th>Tipo Pessoa</th>";
					$tabelaCoop .=					"<th>CPF/CNPJ Raiz</th>";
					$tabelaCoop .=					"<th>Linha Cr&eacute;dito</th>";
					$tabelaCoop .=					"<th>Valor Pot. Parc. Max</th>";
					$tabelaCoop .=					"<th>Valor Pot. Lim. Max</th>";
					$tabelaCoop .=					"<th>Cr&iacute;tica</th>";
					$tabelaCoop .=				"</tr>";
					$tabelaCoop .=			"</thead>";
					$tabelaCoop .=			"<tbody>";
					
					foreach( $cooperados as $cooperado ) {
						$dscriticTest = getByTagName($cooperado->tags,'dscritic');

						if(!empty($dscriticTest)){
						$cooplinha = getByTagName($cooperado->tags,'idlinha');
						$cooptpsoa = getByTagName($cooperado->tags,'tppessoa');
						$cooptpsoa = ($cooptpsoa == '1') ? "PF" : "PJ";
						$coopcpf = getByTagName($cooperado->tags,'nrcpfcnpj');
						$cooplcr = getByTagName($cooperado->tags,'cdlcremp');
						$cooppar = getByTagName($cooperado->tags,'vlpotpar');
						$cooplim = getByTagName($cooperado->tags,'vlpotlim');
						$coopcrit = getByTagName($cooperado->tags,'dscritic');

						$tabelaCoop .=			"<tr id='coop".$cooplinha."'>";
						$tabelaCoop .=				"<td><span>".$cooplinha."</span>".$cooplinha."</td>";
						$tabelaCoop .=				"<td><span>".$cooptpsoa."</span>".$cooptpsoa."</td>";
						$tabelaCoop .=				"<td><span>".$coopcpf."</span>".$coopcpf."</td>";
						$tabelaCoop .=				"<td><span>".$cooplcr."</span>".$cooplcr."</td>";
						$tabelaCoop .=				"<td><span>".$cooppar."</span>".$cooppar."</td>";
						$tabelaCoop .=				"<td><span>".$cooplim."</span>".$cooplim."</td>";
						$tabelaCoop .=				"<td><span>".$coopcrit."</span>".$coopcrit."</td>";
						$tabelaCoop .=			"</tr>";
					}
					}

					$tabelaCoop .=			"</tbody>";
					$tabelaCoop .=		"</table>";
					$tabelaCoop .=	"</div>";
				}

				$tabela .=				"<span>".$cdcooper."</span>";
				$tabela .=				$cdcooper;
				$tabela .=			"</td>";
				$tabela .=			"<td>";
				$tabela .=				"<span>".$dtvigen."</span>";
				$tabela .=				$dtvigen;
				$tabela .=			"</td>";
				$tabela .=			"<td>";
				$tabela .=				"<span>".$dscarga."</span>";
				$tabela .=				$dscarga;
				$tabela .=			"</td>";
				$tabela .=			"<td>";
				$tabela .=				"<span>".$dsatenda."</span>";
				$tabela .=				$dsatenda;
				$tabela .=			"</td>";
				$tabela .=			"<td>";
				$tabela .=				"<span>".$qtregipf."</span>";
				$tabela .=				$qtregipf;
				$tabela .=			"</td>";
				$tabela .=			"<td>";
				$tabela .=				"<span>".$qtregipj."</span>";
				$tabela .=				$qtregipj;
				$tabela .=			"</td>";
				$tabela .=			"<td>";
				$tabela .=				"<span>".$qtdregistros."</span>";
				$tabela .=				$qtdregistros;
				$tabela .=			"</td>";
				$tabela .=			"<td>";
				$tabela .=				"<span>".$vlpotpar."</span>";
				$tabela .=				$vlpotpar;
				$tabela .=			"</td>";
				$tabela .=			"<td>";
				$tabela .=				"<span>".$vlpotlim."</span>";
				$tabela .=				$vlpotlim;
				$tabela .=			"</td>";
				$tabela .=			"<td>";
				$tabela .=				"<span>".$vlpotlimtot."</span>";
				$tabela .=				$vlpotlimtot;
				$tabela .=			"</td>";
				$tabela .=			"<td>";
				$tabela .=				"<span>".$qtderros."</span>";
				$tabela .=				$qtderros;
				$tabela .=			"</td>";
				$tabela .=		"</tr>";
			}

			$tabelaCoop .= "</div>";

			$tabela .=		"</tbody>";
			$tabela .=		"<tfoot>";
			$tabela .=			"</tr class='totalizador'>";
			$tabela .=				"<td></td>";
			$tabela .=				"<td></td>";
			$tabela .=				"<td></td>";
			$tabela .=				"<td></td>";
			$tabela .=				"<td></td>";
			$tabela .=				"<td></td>";
			$tabela .=				"<td></td>";
			$tabela .=				"<td></td>";
			$tabela .=				"<td>Total:</td>";
			$tabela .=				"<td>".number_format($totalvlpotlimtot, 2, ',', '.')."</td>";
			$tabela .=				"<td></td>";
			$tabela .=			"</tr>";
			$tabela .=		"</tfoot>";
		} else {
			$tabela .= 		"<tr><td colspan=11>Nenhum cadastro de mensagem encontrado!</td></tr>";
			$tabela .=	"</tbody>";
		}
	} else {

		$tabela .=			"<tr>";
		$tabela .=				"<th>Linha</th>";
		$tabela .=				"<th>Cooperativa</th>";
		$tabela .=				"<th>Tipo Pessoa</th>";
		$tabela .=				"<th>CPF/CNPJ Raiz</th>";
		$tabela .=				"<th>Cr&iacute;tica</th>";
		$tabela .=			"</tr>";
		$tabela .=		"</thead>";

		$tabela .=		"<tbody>";

		// Se encontrar registros para exibir
		if (count($registros) > 0) {
			$totalValorParc = $totalValorLim = 0;
			foreach( $registros as $critic ) {
				$idlinha = getByTagName($critic->tags,'idlinha');
				$cdcooper = getByTagName($critic->tags,'cdcooper');
				$tppessoa = getByTagName($critic->tags,'tppessoa');
				$nrcpfcnpj = getByTagName($critic->tags,'nrcpfcnpj');
				$dscritic = getByTagName($critic->tags,'dscritic');

				$tabela .=		"<tr id='".$idlinha."'>";
				$tabela .=			"<td>";
				$tabela .=				"<input type='hidden' name='idlinha' value='".$idlinha."' />";
				$tabela .=				"<span>".$idlinha."</span> ".$idlinha;
				$tabela .=			"</td>";
				$tabela .=			"<td>";
				$tabela .=				"<span>".$cdcooper."</span> ".$cdcooper;
				$tabela .=			"</td>";
				$tabela .=			"<td>";
				$tabela .=				"<span>".$tppessoa."</span> ".$tppessoa;
				$tabela .=			"</td>";
				$tabela .=			"<td>";
				$tabela .=				"<span>".$nrcpfcnpj."</span> ".$nrcpfcnpj;
				$tabela .=			"</td>";
				$tabela .=			"<td>";
				$tabela .=				"<span>".$dscritic."</span> ".$dscritic;
				$tabela .=			"</td>";
				$tabela .=		"</tr>";
			}
		} else {
			$tabela .= 		"<tr><td colspan=5>Nenhum cadastro de mensagem encontrado!</td></tr>";
		}
		$tabela .=		"</tbody>";
	}
	$tabela .=	"</table>";
	$tabela .=	"</div></div>";

	$tabela .= $tabelaCoop;

	$disableImp = ($flgerro == "N" || $flgBloqCarga == "N") ? "" : "adisabled";
	
	// Caso exista crítica, desabilita o botão de enviar
	// Hack utilizado na porque na tela de exclusão de carga manual não vem 
	// valor para a variavel $flgerro
	if ($operacao == 'E' && trim($dscritic) != "") {
		$disableImp =  "adisabled";
	}													   
	$tabela .=	"<div id='divBotoes' style='text-align:center; margin-bottom: 10px;' >";
	$tabela .=	"	<a href='#' class='botao ".$disableImp."' data-flgbloqcarga='".$flgBloqCarga."' id=\"btImpCargas\" name=\"btImpCargas\" onClick=\"btnImpCargas('$operacao','UPLOAD');return false;\" style=\"float:none;\">Liberar</a>";
if ($operacao == 'L') {
	$tabela .=	"	<a href='#' class='botao adisabled' id='btErros' name='btErros' onClick='btnErros();return false;' style='float:none;'>Erros de Carga</a>";
}
	$tabela .=	"</div>";

	global $eval;
	$tagant = "";
	$tagdep = "";
	if (!$eval) {
		$tagant = "<script>";
		$tagdep = "</script>";
	}

	$tabela = str_replace("'","\\\'",$tabela);
	$tabela = str_replace('"','\"',$tabela);
	echo $tagant;
	echo "parent.framePrincipal.eval(\"divListMsg.html('".$tabela."');formataTabListMsg('".$operacao."');divListMsg.show();\");";
	echo $tagdep;

	if ($msg != "") {
		gerarErro($msg,"","inform");
	}
	retornoEval("hideMsgAguardo();");

	function showCadmsg($dseval){
		global $eval;
		$dseval = str_replace("'","\\\'",$dseval);
		$dseval = str_replace('"','\"',$dseval);
		$tagantes = "";
		$tagdepos = "";
		if(!$eval){
			$tagantes = "<script>";
			$tagdepos = "</script>";
		}
		echo $tagantes."parent.framePrincipal.eval(\"$('#divViewMsg').html('".$dseval."').show();if(divConfirm.css('display') == 'none') hideMsgAguardo();\");".$tagdepos;
		exit();
	}

	function showErrorsArq($taberro,$parcial=false){
		global $eval;
		$taberro = str_replace("'","\\\'",$taberro);
		$taberro = str_replace('"','\"',$taberro);
		$taberro = str_replace("\n","",$taberro);
		$tagant = "";
		$tagdep = "";
		$callback = "hideMsgAguardo();";
		if(!$eval){
			$tagant = "<script>";
			$tagdep = "</script>";
		}
		if($parcial){
			$callback = "msgError('inform','".utf8ToHtml("Erro detectado ao enviar mensagens. Verifique os erros.")."','hideMsgAguardo();');";
		}
		echo $tagant."parent.framePrincipal.eval(\"$('#divListErr').html('".$taberro."').show();".$callback."\");".$tagdep;
		exit();
	}

	function gerarErro($dserro,$callback='',$tipo='error'){
		global $eval;
		$dserro = str_replace("'","\\\'",$dserro);
		$dserro = str_replace('"','\\"',$dserro);
		$dserro = str_replace("\n","",$dserro);
		$callback = str_replace("'","\\\'",$callback);
		$callback = str_replace('"','\\"',$callback);
		$tagant = "";
		$tagdep = "";
		if(!$eval){
			$tagant = "<script>";
			$tagdep = "</script>";
		}
		echo $tagant."parent.framePrincipal.eval(\"msgError('".$tipo."','".utf8ToHtml($dserro)."','hideMsgAguardo();".$callback."');\");".$tagdep;
		exit();
	}

	function retornoEval($dseval){
		global $eval;
		$dseval = str_replace('"','\"',$dseval);
		$tagantes = "";
		$tagdepos = "";
		if(!$eval){
			$tagantes = "<script>";
			$tagdepos = "</script>";
		}
		echo $tagantes."parent.framePrincipal.eval(\"".$dseval."\");".$tagdepos;
		exit();
	}

	function mascNum($num){
		if(strlen($num) == 1){
			return "0".$num;
		}else{
			return $num;
		}
	}

	/*
	 * Função para determinar qual é o ambiente de execução para sinalizar dinamicamente as pastas para upload
	 */
	function getAmbiente($uri){
		if(strpos($uri, 'ayllosdev')){
			return 'dev';
		}else if(strpos($uri, 'aylloshomol')){
			return 'hml';
		}else{
			return 'prd';
		}
	}