 <?php
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Renato Darosci
 * DATA CRIAÇÃO : 07/07/2015
 * OBJETIVO     : Rotina para manter as operações da tela HOMFOL
 * --------------
 * ALTERAÇÕES   :
 *                Alterado o upload_file.php, baseado no gnuclient_upload_file.php
 *                (Guilherme/SUPERO)
 *				  09/09/2015 - Alterado para o nome do arquivo ser homfol.TIME.txt
 *							   quando feito o upload (Vanessa).
 *				  05/10/2015 - Ajuste para retornar apenas os comprovantes com erro(Vanessa).
 *
 *                21/10/2015 - Correcao na passagem da cddopcao para a validaPermissao (Marcos-Supero)
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

	// Ler parametros passados via POST
	$nrdconta  = $_POST['nrdconta'];
	$opcao     = (isset($_POST['cddopcao']))  ? $_POST['cddopcao']  : '';
	$file      = (isset($_FILES['userfile'])) ? $_FILES['userfile'] : '';

	// retorno sera de eval ou html
	$eval     = (isset($_POST['redirect'])) ? true : false;
    $tempo    = time();
    // Local de Upload do arquivo -  Antes de passar pelo "upload_file.php"
	$nmupload  = "../../upload_files/homfol." . $tempo . ".txt";

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$opcao)) <> '') {
		gerarErro("Erro ao validar permiss&atilde;o de acesso!");
	}

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
	if (!move_uploaded_file($file["tmp_name"], $nmupload)) {
		$arrCrit[] = "ATENCAO: Erro ao validar arquivo. *VL2.";
	}
    
	// Definir ação
	$nmdeacao = null;

	if ($opcao == 'C') {
		$nmdeacao = 'HOMFOL_VALIDA_COMPR_FOLHA';
	} else {
		$nmdeacao = 'HOMFOL_VALIDA_ARQ_FOLHA';
	}
	
	// gerar erros criticos
	if(count($arrCrit) > 0){
		gerarErro($arrCrit[0]);
	}

	$tempo     = time();
	// Nome do arquivo do upload - Depois de passar pelo "upload_file.php"
	$dirArqDne = "../../upload_files/";
	$filename  = "homfol.". $tempo . ".txt";
    $Arq       = $nmupload;

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
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<dsarquiv>".$NomeArq."</dsarquiv>";	 // Variável $NomeArq vem da gnuclient_upload_file.php
	$xml .= "		<dsdireto>".$caminhoCompleto."</dsdireto>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "HOMFOL", $nmdeacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");

	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra crítica
 	if ($xmlObjeto->roottag->tags[0]->name == "ERRO") {
	    gerarErro($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,"","error");
    }else{
		$registros = $xmlObjeto->roottag->tags[0]->tags;
		$arr = $xmlObjeto->roottag->tags[0];   // returns an array
	}		
	echo count($registros);
	// Se a opção for arquivo
	if ($opcao == 'F') {
	
		// Monta a tabela de retorno
		$tabela  = "<br />";
		$tabela .=	"<div class=\"divRegistros\">";
		$tabela .= 	"<table>";
		$tabela .=		"<thead>";
		$tabela .=			"<tr>";
		$tabela .=				"<th>Seq.</th>";
		$tabela .=				"<th>Conta</th>";
		$tabela .=				"<th>CPF</th>";
		$tabela .=				"<th>Origem</th>";
		$tabela .=				"<th>Valor L&iacute;quido</th>";
		$tabela .=				"<th>Observa&ccedil;&atilde;o</th>";
		$tabela .=			"</tr>";
		$tabela .=		"</thead>";

		$tabela .=		"<tbody>";
		
		// Se encontrar registros para exibir
		if(count($registros) > 0){
			foreach( $registros as $critic ) {
				
				$nrseqcri = getByTagName($critic->tags,'nrseqvld');
				$nrdconta = getByTagName($critic->tags,'dsdconta');
				$nrcpfcgc = getByTagName($critic->tags,'dscpfcgc');
				$dsorigem = getByTagName($critic->tags,'dsorigem');
				$vlrpagto = getByTagName($critic->tags,'vlrpagto');
				$dscritic = getByTagName($critic->tags,'dscritic');
					
				$tabela .=		"<tr>";
				$tabela .=			"<td>";
				$tabela .=				"<span>".$nrseqcri."</span>";
				$tabela .=				$nrseqcri;
				$tabela .=			"</td>";
				$tabela .=			"<td>";
				$tabela .=				"<span>".$nrdconta."</span>";
				$tabela .=				$nrdconta;
				$tabela .=			"</td>";
				$tabela .=			"<td>";
				$tabela .=				"<span>".$nrcpfcgc."</span>";
				$tabela .=				$nrcpfcgc;
				$tabela .=			"</td>";
				$tabela .=			"<td>";
				$tabela .=				"<span>".$dsorigem."</span>";
				$tabela .=				$dsorigem;
				$tabela .=			"</td>";
				$tabela .=			"<td>";
				$tabela .=				"<span>".$vlrpagto."</span>";
				$tabela .=				$vlrpagto;
				$tabela .=			"</td>";
				$tabela .=			"<td>";
				$tabela .=				"<span>".$dscritic."</span>";
				$tabela .=				$dscritic;
				$tabela .=			"</td>";
				$tabela .=		"</tr>";
			}
		}else{
			$tabela .= 		"<tr><td colspan=6 >Nenhum cadastro de mensagem encontrado!</td></tr>";
		}
		
		$tabela .=		"</tbody>";
		$tabela .=	"</table>";
		$tabela .=	"</div>";
		
		global $eval;
		$tagant = "";
		$tagdep = "";
		if(!$eval){
			$tagant = "<script>";
			$tagdep = "</script>";
		}
			
		// Retorna a tabela
		echo $tagant;
		echo "parent.framePrincipal.eval('cQtdregok.val(\'".$arr->attributes['QTDREGOK']."\');');";	
		echo "parent.framePrincipal.eval('cQtregerr.val(\'".$arr->attributes['QTREGERR']."\');');";	
		echo "parent.framePrincipal.eval('cQtregtot.val(\'".$arr->attributes['QTREGTOT']."\');');";	
		echo "parent.framePrincipal.eval('cVltotpag.val(\'".$arr->attributes['VLTOTPAG']."\');');";	
		echo "parent.framePrincipal.eval('divListMsg.html(\'".$tabela."\');formataTabListMsg();divListMsg.show();divViewMsg.show();');";	
		echo $tagdep;
	} else {
		
		// Monta a tabela de retorno
		$tabela  = "<br />";
		$tabela .=	"<div class=\"divRegistros\">";
		$tabela .= 	"<table>";
		$tabela .=		"<thead>";
		$tabela .=			"<tr>";
		$tabela .=				"<th>Seq.</th>";
		$tabela .=				"<th>Conta</th>";
		$tabela .=				"<th>CPF</th>";
		$tabela .=				"<th>Descri&ccedil;&atilde;o</th>";
		$tabela .=				"<th>Tipo</th>";
		$tabela .=				"<th>Valor</th>";
		$tabela .=				"<th>Observa&ccedil;&atilde;o</th>";
		$tabela .=			"</tr>";
		$tabela .=		"</thead>";

		$tabela .=		"<tbody>";
		
		// Se encontrar registros para exibir
		if(count($registros) > 0){
			foreach( $registros as $critic ) {
				
				$nrseqcri = getByTagName($critic->tags,'nrseqvld');
				$nrdconta = getByTagName($critic->tags,'dsdconta');
				$nrcpfcgc = getByTagName($critic->tags,'dscpfcgc');
				$dsdescri = getByTagName($critic->tags,'dsdescri');
				$iddstipo = getByTagName($critic->tags,'iddstipo');
				$vlrpagto = getByTagName($critic->tags,'vlrpagto');
				$dscritic = getByTagName($critic->tags,'dscritic');
					
				$tabela .=		"<tr>";
				$tabela .=			"<td>";
				$tabela .=				"<span>".$nrseqcri."</span>";
				$tabela .=				$nrseqcri;
				$tabela .=			"</td>";
				$tabela .=			"<td>";
				$tabela .=				"<span>".$nrdconta."</span>";
				$tabela .=				$nrdconta;
				$tabela .=			"</td>";
				$tabela .=			"<td>";
				$tabela .=				"<span>".$nrcpfcgc."</span>";
				$tabela .=				$nrcpfcgc;
				$tabela .=			"</td>";
				$tabela .=			"<td>";
				$tabela .=				"<span>".utf8_decode($dsdescri)."</span>";
				$tabela .=				utf8_decode($dsdescri);
				$tabela .=			"</td>";
				$tabela .=			"<td>";
				$tabela .=				"<span>".$iddstipo."</span>";
				$tabela .=				$iddstipo;
				$tabela .=			"</td>";
				$tabela .=			"<td>";
				$tabela .=				"<span>".$vlrpagto."</span>";
				$tabela .=				$vlrpagto;
				$tabela .=			"</td>";
				$tabela .=			"<td>";
				$tabela .=				"<span>".utf8_decode($dscritic)."</span>";
				$tabela .=				utf8_decode($dscritic);
				$tabela .=			"</td>";
				$tabela .=		"</tr>";
			}
		}else{
			if ($arr->attributes['QTLINERR'] == 0 ){
				$tabela .= 		"<tr><td colspan=7 >Todos os Registros Lidos com Sucesso!</td></tr>";
			}else{
				$tabela .= 		"<tr><td colspan=7 >Nenhum cadastro de mensagem encontrado!</td></tr>";
			}
		}
		
		$tabela .=		"</tbody>";
		$tabela .=	"</table>";
		$tabela .=	"</div>";
		
		global $eval;
		$tagant = "";
		$tagdep = "";
		if(!$eval){
			$tagant = "<script>";
			$tagdep = "</script>";
		}
		
		// Retorna a tabela
		echo $tagant;
		echo "parent.framePrincipal.eval('cQtdcmpok.val(\'".$arr->attributes['QTDCMPOK']."\');');";	
		echo "parent.framePrincipal.eval('cQtcmperr.val(\'".$arr->attributes['QTCMPERR']."\');');";	
		echo "parent.framePrincipal.eval('cQtcmptot.val(\'".$arr->attributes['QTCMPTOT']."\');');";	
		echo "parent.framePrincipal.eval('cQtdlinok.val(\'".$arr->attributes['QTDLINOK']."\');');";	
		echo "parent.framePrincipal.eval('cQtlinerr.val(\'".$arr->attributes['QTLINERR']."\');');";	
		echo "parent.framePrincipal.eval('cQtlintot.val(\'".$arr->attributes['QTLINTOT']."\');');";	
		
		echo "parent.framePrincipal.eval('divListMsg.html(\'".$tabela."\');formataTabListMsg();divListMsg.show();divViewMsg.show();');";	
		echo $tagdep;
	}
	
	gerarErro("Validação do arquivo realizada com sucesso!","","inform");
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
?>