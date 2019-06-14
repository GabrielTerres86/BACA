 <?php  
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Jorge Issamu Hamaguchi
 * DATA CRIAÇÃO : 16/07/2012 
 * OBJETIVO     : Rotina para manter as operações da tela CADMSG
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */
	session_cache_limiter("private");
	session_start();
	
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	// Inicializa
	$procedure 	= '';
	$mtdErro	= '';
	$mtdRetorno	= '';
	$dsdctitg	= '';
	$posvalid	= '';
	
	// Recebe a operação que está sendo realizada
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
	// retorno sera de eval ou html
	$eval     = (isset($_POST['redirect'])) ? true : false;
	
	if($operacao == ""){
		retornoEval("estadoInicial();");
	}

	// Recebe a operação que está sendo realizada
	$cdcadmsg		= (isset($_POST['cdcadmsg']))   ? $_POST['cdcadmsg']   : ''  ;
	$keyvalue		= (isset($_POST['keyvalue']))   ? $_POST['keyvalue']   : ''  ;	
	$dsdassun		= (isset($_POST['dsdassun']))   ? $_POST['dsdassun']   : ''  ;
	$dsdmensg		= (isset($_POST['dsdmensg']))   ? $_POST['dsdmensg']   : ''  ; 
	$cdidpara		= (isset($_POST['cdidpara']))   ? $_POST['cdidpara']   : ''  ; 
	$dsidpara		= (isset($_POST['dsidpara']))   ? $_POST['dsidpara']   : ''  ;  
	$file			= (isset($_FILES['userfile']))  ? $_FILES['userfile']   : ''  ;
	$nmupload 		= "/tmp/cadmsg.";
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$operacao)) <> '') {		
		gerarErro("Erro ao validar permiss&atilde;o de acesso!");
	}
	
	// se for consulta de Mesnagens
	if(strtoupper($operacao == "C")){
		
		// monta xml
		$xml  = "";
		$xml .= "<Root>";
		$xml .= "	<Cabecalho>";
		$xml .= "		<Bo>b1wgen0116.p</Bo>";
		$xml .= "		<Proc>carregar-cadmsg</Proc>";
		$xml .= "	</Cabecalho>";
		$xml .= "	<Dados>";
		$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
		$xml .= "		<cdcadmsg>0</cdcadmsg>";
		$xml .= "	</Dados>";
		$xml .= "</Root>";
		
		$xmlResult = getDataXML($xml);
		$xmlObjeto = getObjectXML($xmlResult);
		
		//----------------------------------------------------------------------------------------------------------------------------------	
		// Controle de Erros
		//----------------------------------------------------------------------------------------------------------------------------------
		if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {	
			$msgErro	= str_ireplace('"','',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata);
			gerarErro($msgErro);
		}else{
			$registros = $xmlObjeto->roottag->tags[0]->tags;
		}		
		
		$tabela  = "<br />";
		$tabela .=	"<div class=\'divRegistros\'>";
		$tabela .= 	"<table>";
		$tabela .=		"<thead>";
		$tabela .=			"<tr>";
		$tabela .=				"<th>Assunto</th>";
		$tabela .=				"<th>Data/Hora</th>";
		$tabela .=				"<th>Enviados</th>";
		$tabela .=				"<th>Lidos</th>";
		$tabela .=				"<th>Excluir</th>";
		$tabela .=			"</tr>";
		$tabela .=		"</thead>";

		$tabela .=		"<tbody>";
		
		if(count($registros) > 0){
			foreach( $registros as $mensgs ) {
			
				$cdcadmsg = getByTagName($mensgs->tags,'cdcadmsg');
				$cdcooper = getByTagName($mensgs->tags,'cdcooper');
				$cdidpara = getByTagName($mensgs->tags,'cdidpara');
				$cdoperad = getByTagName($mensgs->tags,'cdoperad');
				$dsidpara = getByTagName($mensgs->tags,'dsidpara');
				$dsdassun = utf8_decode(urldecode(getByTagName($mensgs->tags,'dsdassun')));
				$dtdmensg = getByTagName($mensgs->tags,'dtdmensg');
				$hrdmensg = mascNum(floor(floor(getByTagName($mensgs->tags,'hrdmensg')/60)/60)).":".mascNum(floor(getByTagName($mensgs->tags,'hrdmensg')/60)%60);
				$qttotenv = getByTagName($mensgs->tags,'qttotenv');
				$qttotlid = getByTagName($mensgs->tags,'qttotlid');
				
				$tabela .=		"<tr onclick=\"ver_cadmsg(\'".$cdcadmsg."\',\'".md5($cdcadmsg.$glbvars["cdoperad"])."\',this);\">";
				$tabela .=			"<td>";
				$tabela .=				"<span>". getByTagName($mensgs->tags,'dsdassun'). "</span>";
				$tabela .=				$dsdassun;
				$tabela .=			"</td>";
				$tabela .=			"<td>";
				$tabela .=				"<span>". (dataParaTimestamp(getByTagName($mensgs->tags,'dtdmensg')) + getByTagName($mensgs->tags,'hrdmensg')) ."</span>";
				$tabela .=				$dtdmensg." - ".$hrdmensg;
				$tabela .=			"</td>";
				$tabela .=			"<td>";
				$tabela .=				"<span>". getByTagName($mensgs->tags,'qttotenv'). "</span>";
				$tabela .=				$qttotenv;
				$tabela .=			"</td>";
				$tabela .=			"<td>";
				$tabela .=				"<span>". getByTagName($mensgs->tags,'qttotlid'). "</span>";
				$tabela .=				$qttotlid;
				$tabela .=			"</td>";
				$tabela .=			"<td>";
				$tabela .=				"<a href=\'#\' onclick=\'confExcMsg(".$cdcadmsg.",".$qttotlid.",\"".md5($cdcadmsg.$cdoperad)."\");return false;\'><img titlt=\'Excluir Mensagens\' src=\'".$UrlImagens."geral/sweetie-24-frame-close.png\' ></a>";
				$tabela .=			"</td>";
				$tabela .=		"</tr>";
			}
		}else{
			$tabela .= 		"<tr><td>Nenhum cadastro de mensagem encontrado!</td><td></td></tr>";
		}
		$tabela .=		"</tbody>";
		$tabela .=	"</table>";
		$tabela .=	"</div>";

		echo "divListMsg.html('".$tabela."');"; 

		//monta layout da tabela
		echo 'formataTabListMsg();';

		// mostra o div com a tabela
		echo 'divListMsg.show();';
		
	
	// se for inclusao de "Nova Mensagem"	
	}else if(strtoupper($operacao == "I")){
		
		$arrCrit  = array();	
		$destinos = array();
		
		if($cdidpara == "1"){
			// se destinatarios forem por cooperativa
			for($i=0;$i<count($dsidpara);$i++){
				// verificando se for "Todas as cooperativas"
				if($dsidpara[$i] == "0"){
					// zerando o array
					$destinos = array();
					$destinos[0]["cdcooper"] = "0";
					// saindo do for
					break;
				}
				$destinos[$i]["cdcooper"] = $dsidpara[$i];
			}
			
		}else if($cdidpara == "2"){
			// se destinatario for por upload file
			
			if($file["error"] > 0){
				switch($file["error"]){
					case 1:	$arrCrit[] = "ATENCAO: Tamanho do arquivo excedeu o permitido.";		break;
					case 2:	$arrCrit[] = "ATENCAO: Tamanho do arquivo deve conter menos de 1 mb."; 	break;
					case 3:	$arrCrit[] = "ATENCAO: Falha ao enviar arquivo ER3.";					break;
					case 4:	$arrCrit[] = "ATENCAO: Falha ao enviar arquivo ER4.";					break;
					case 6:	$arrCrit[] = "ATENCAO: Falha ao enviar arquivo ER6.";					break;
					case 7:	$arrCrit[] = "ATENCAO: Falha ao gravar arquivo ER7.";					break;
					case 8:	$arrCrit[] = "ATENCAO: Falha ao enviar arquivo ER8.";					break;
				}
			}
			
			if($file == ""){
				$arrCrit[] = "ATENCAO: Arquivo não encontrado.";
			}
			if($file["size"] > (1 * (1024 * 1024))){
				$arrCrit[] = "ATENCAO: Tamanho do arquivo deve ser menor que 1 mb.";
			}
			if(!is_uploaded_file($file["tmp_name"])){
				$arrCrit[] = "ATENCAO: Erro ao validar arquivo. *VL1.";
			}
			if (!move_uploaded_file($file["tmp_name"], $nmupload.$file["name"])) {
				$arrCrit[] = "ATENCAO: Erro ao validar arquivo. *VL2.";
			}
			
			$retornoAV = 1;
			$retornoAV = shell_exec('/pkg/desenweb/check_virus_ayllosweb.sh '.$nmupload.$file["name"] .' ; echo $?');
			if($retornoAV == 1){
				$arrCrit[] = "ATENCAO: Erro ao validar arquivo. *VL3.";
			}
			
			// gerar erros criticos
			if(count($arrCrit) > 0){
				gerarErro($arrCrit[0]);
			}
			
			//pega conteudo do arquivo e bota em string
			$strFile = file_get_contents($nmupload.$file["name"]);
			
			//explode string em um array quando encontrar quebra de linha
			$arrStrFile = explode("\n",$strFile);
			
			//verificacao por linha
			for($i=0;$i<count($arrStrFile);$i++){
				
				if(strpos($arrStrFile[$i],";") === false){
					$arrCrit[] = "ATENCAO: Separador de parâmetros não encontrado em linha ".($i+1).".";
				}
				$msgCdcooper = preg_replace('/\s/','',substr($arrStrFile[$i],0,strpos($arrStrFile[$i],";")));
				$msgNrdconta = preg_replace('/\s/','',substr($arrStrFile[$i],strpos($arrStrFile[$i],";")+1));
				
				if(!is_numeric($msgCdcooper) || (!is_numeric($msgNrdconta))){
					$arrCrit[] = "ATENCAO: Parâmetro incorreto em linha ".($i+1).".";
				}else if((strlen($msgCdcooper) > 8) || (strlen($msgNrdconta) > 8)){
					$arrCrit[] = "ATENCAO: Conta inválida em linha ".($i+1).".";
				}else{
					$destinos[$i]["cdcooper"] = trim($msgCdcooper);
					$destinos[$i]["nrdconta"] = trim($msgNrdconta);
				}
			}
		}
		
		//buffer para retorno de erros
		$buffer = "";
		
		//se achar erros , critica sem processar arquivo
		if(count($arrCrit) > 0){
			
			$buffer .= "<table border='0' width='100%' cellpadding='0' cellspacing='0' style='border:solid 1px gray;'>";
			
			for($i=0;$i<count($arrCrit);$i++){
				
				if($i>0){
					if   ( $cor <> "") { $cor = ""; } 
					else { $cor = " style='background-color:white;'"; }
				}
				
				$arrCrit[$i] = str_replace("ATENCAO","<span style='color:red;font-weight:bold;'>ATENCAO</span>",$arrCrit[$i]);
				
				$buffer .= "<tr>
								<td ".$cor." class='txtNormal'>".utf8ToHtml($arrCrit[$i])."</td>
							 </tr>";
			}
			$buffer .= "</table>";
			
			//gerar o erro em div de errors
			showErrorsArq($buffer);
			
		}else{
			//altera caracteres de qubra de linha por HTML
			$dsdmensg = str_replace("\r", '', $dsdmensg);
			$dsdmensg = str_replace("\n", '<br />', $dsdmensg);
			//encoda em utf8
			$dsdassun = utf8_encode($dsdassun);
			$dsdmensg = utf8_encode($dsdmensg);
			//encoda em codigo url
			$dsdassun = urlencode($dsdassun);
			$dsdmensg = urlencode($dsdmensg);
			
			// Monta o xml
			$xml  = "";
			$xml .= "<Root>";
			$xml .= "  <Cabecalho>";
			$xml .= "	    <Bo>b1wgen0116.p</Bo>";
			$xml .= "        <Proc>cadastrar-cadmsg</Proc>";
			$xml .= "  </Cabecalho>";
			$xml .= "  <Dados>";
			$xml .= "       <cdcooper>".$glbvars['cdcooper']."</cdcooper>";
			$xml .= "		<cdoperad>".$glbvars['cdoperad']."</cdoperad>";	
			$xml .= "		<dsdassun>".$dsdassun."</dsdassun>";	
			$xml .= "		<dsdmensg>".$dsdmensg."</dsdmensg>";
			$xml .= "		<cdidpara>".$cdidpara."</cdidpara>";
			$xml .= xmlFilho($destinos,'Destinatarios','Contas');
			$xml .= "  </Dados>";
			$xml .= "</Root>";
			
			$xmlResult = getDataXML($xml);

			// Cria objeto para classe de tratamento de XML
			$xmlObjeto = getObjectXML($xmlResult);
			
			//----------------------------------------------------------------------------------------------------------------------------------	
			// Controle de Erros
			//----------------------------------------------------------------------------------------------------------------------------------
			$arrCrit  = array();
			
			if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
				$erros = $xmlObjeto->roottag->tags[0]->tags;
				if(count($erros) > 1){
					for($i=0;$i<count($erros);$i++){
						$arrCrit[] = $erros[$i]->tags[4]->cdata;
					}
					$buffer .= "<table border='0' width='100%' cellpadding='0' cellspacing='0' style='border:solid 1px gray;'>";
			
					for($i=0;$i<count($arrCrit);$i++){
						
						if($i>0){
							if   ( $cor <> "") { $cor = ""; } 
							else { $cor = " style='background-color:white;'"; }
						}
						
						$buffer .= "<tr>
										<td ".$cor." class='txtNormal'><span style='color:red;font-weight:bold;'>ATENCAO</span>:&nbsp;".utf8ToHtml($arrCrit[$i])."</td>
									 </tr>";
					}
					$buffer .= "</table>";
					
					//gerar o erro em div de errors
					showErrorsArq($buffer,true);
					
				}else{
					gerarErro($erros[0]->tags[4]->cdata);
				}
			}else{
				gerarErro("Mensagens enviadas com sucesso!","btnListMsg();","inform");
			}
		}
	}
	//se for operacao de Visualizar mensagem enviada
	else if(strtoupper($operacao == "L")){
		
		$operacao = "C"; // altera para C para verificar permissao de consulta
		if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$operacao)) <> '') {		
			gerarErro("Erro ao validar permiss&atilde;o de acesso!");
		}
		
		if($keyvalue != md5($cdcadmsg.$glbvars["cdoperad"])){
			gerarErro("Chave de acesso incorreto!","hideMsgAguardo();");
		}
		
		// monta xml
		$xml  = "";
		$xml .= "<Root>";
		$xml .= "	<Cabecalho>";
		$xml .= "		<Bo>b1wgen0116.p</Bo>";
		$xml .= "		<Proc>carregar-cadmsg</Proc>";
		$xml .= "	</Cabecalho>";
		$xml .= "	<Dados>";
		$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
		$xml .= "		<cdcadmsg>".$cdcadmsg."</cdcadmsg>";
		$xml .= "	</Dados>";
		$xml .= "</Root>";

		$xmlResult = getDataXML($xml);
		$xmlObjeto = getObjectXML($xmlResult);
		
		//----------------------------------------------------------------------------------------------------------------------------------	
		// Controle de Erros
		//----------------------------------------------------------------------------------------------------------------------------------
		if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {	
			$msgErro	= str_ireplace('"','',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata);
			gerarErro($msgErro);
		}else{
			$registros = $xmlObjeto->roottag->tags[0]->tags;
		}
		
		$buffer  = "<br/><br/>";
		$buffer .= "<table width='575' border='0' align='center' cellpadding='0' style='background-color:lightyellow;border: 1px solid gray;padding:5px;' cellspacing='0'>";
		$buffer .= "  <tr><td height='10'></td></tr>";
		
		if(count($registros) > 0){
			foreach( $registros as $mensgs ) {
			
				$cdcadmsg = getByTagName($mensgs->tags,'cdcadmsg');
				$cdcooper = getByTagName($mensgs->tags,'cdcooper');
				$cdidpara = getByTagName($mensgs->tags,'cdidpara');
				$cdoperad = getByTagName($mensgs->tags,'cdoperad');
				$dsidpara = getByTagName($mensgs->tags,'dsidpara');
				$dsdassun = utf8_decode(urldecode(getByTagName($mensgs->tags,'dsdassun')));
				$dsdmensg = utf8_decode(urldecode(getByTagName($mensgs->tags,'dsdmensg')));
				$dtdmensg = getByTagName($mensgs->tags,'dtdmensg');
				$hrdmensg = mascNum(floor(floor(getByTagName($mensgs->tags,'hrdmensg')/60)/60)).":".mascNum(floor(getByTagName($mensgs->tags,'hrdmensg')/60)%60);
				$qttotenv = getByTagName($mensgs->tags,'qttotenv');
				$qttotlid = getByTagName($mensgs->tags,'qttotlid');
				
				
				$buffer .= "  <tr>";
				$buffer .= "    <td style='background-color:white;'>";
				$buffer .= "      <table width='100%' border='0' align='center' cellpadding='0' cellspacing='0'>";
				$buffer .= "        <tr>";
				$buffer .= "          <td><strong><span class='txtNormal'>Cadastro da Mensagem:&nbsp;".$cdcadmsg."</span></strong></td>";
				$buffer .= "          <td align='right' class='txtNormal'><a href='#' onclick='fecharViewCadMsg();return false;'><span style='position:relative;top:-5;'>Fechar&nbsp;</span><img src='".$UrlImagens."geral/excluir.jpg' style='position:relative;top:-4px;'></a></td>";
				$buffer .= "        </tr>";
				$buffer .= "      </table>";
				$buffer .= "    </td>";
				$buffer .= "  </tr>";
				$buffer .= "  <tr>";
				$buffer .= "    <td height='3' bgcolor='#D8E0C1' align='center' class='txtNormal'></td>";
				$buffer .= "  </tr>";
				$buffer .= "  <tr>";
				$buffer .= "    <td>";
				$buffer .= "		<table  border='0' width='100%' cellpadding='0' cellspacing='0'>";
				$buffer .= "			<tr height='15'>";
				$buffer .= "				<td class='txtNormal' width='100' align='right' ><strong>Data de envio:&nbsp;</strong></td>";
				$buffer .= "				<td class='txtNormal' width='100'>".$dtdmensg."</td>";
				$buffer .= "				<td class='txtNormal' width='70' align='right' ><strong>Hora:&nbsp;</strong></td>";
				$buffer .= "				<td class='txtNormal'>".$hrdmensg."</td>";
				$buffer .= "			</tr>";
				$buffer .= "			<tr height='15'>";
				$buffer .= "				<td class='txtNormal' align='right' ><strong>Remetente:&nbsp;</strong></td>";
				$buffer .= "				<td class='txtNormal'>CADMSG</td>";
				$buffer .= "				<td class='txtNormal' align='right' ><strong>Operador:&nbsp;</strong></td>";
				$buffer .= "				<td class='txtNormal'>".$cdoperad."</td>";
				$buffer .= "			</tr>";
				$buffer .= "			<tr height='15'>";
				$buffer .= "				<td class='txtNormal' align='right'><strong>Assunto:&nbsp;</strong></td>";
				$buffer .= "				<td class='txtNormal' colspan='3'>".$dsdassun."</td>";
				$buffer .= "			</tr>";
				$buffer .= "		</table>";
				$buffer .= "		<table width='100%' border='0' cellpadding='3' cellspacing='1'>";
				$buffer .= "			<tr><td height='5'></td></tr>";
				$buffer .= "			<tr>";
				$buffer .= "				<td align='center'  style='border-bottom: 1px solid #CBDCC5;'><span class='txtNormal'>Mensagem</span></td>";
				$buffer .= "			</tr>";
				$buffer .= "			<tr>";
				$buffer .= "				<td height='10' class='txtNormal' style='text-align:justify;'>".$dsdmensg."</td>";
				$buffer .= "			</tr>";
				$buffer .= "			<tr>";
				$buffer .= "				<td height='10'></td>";
				$buffer .= "			</tr>";
				$buffer .= "		</table>";
				$buffer .= "	</td>";
				$buffer .= "  </tr>";
			}
		}else{
			gerarErro("Nenhum cadastro de mensagem encontrado!");
		}
		
		$buffer .= "</table>";
		
		showCadmsg($buffer);
		
	}
	//se for operacao de excluir mensagens
	else if(strtoupper($operacao == "E")){
		
		if($keyvalue != md5($cdcadmsg.$glbvars["cdoperad"])){
			gerarErro("Chave de acesso incorreto!","hideMsgAguardo();");
		}
		
		// Monta o xml
		$xml  = "";
		$xml .= "<Root>";
		$xml .= "  <Cabecalho>";
		$xml .= "	    <Bo>b1wgen0116.p</Bo>";
		$xml .= "        <Proc>excluir-cadmsg</Proc>";
		$xml .= "  </Cabecalho>";
		$xml .= "  <Dados>";
		$xml .= "       <cdcooper>3</cdcooper>";
		$xml .= "		<cdoperad>".$glbvars['cdoperad']."</cdoperad>";	
		$xml .= "		<cdcadmsg>".$cdcadmsg."</cdcadmsg>";
		$xml .= "  </Dados>";
		$xml .= "</Root>";
		
		$xmlResult = getDataXML($xml);
		
		// Cria objeto para classe de tratamento de XML
		$xmlObjeto = getObjectXML($xmlResult);
		
		//----------------------------------------------------------------------------------------------------------------------------------	
		// Controle de Erros
		//----------------------------------------------------------------------------------------------------------------------------------
		if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {	
			$msgErro	= str_ireplace('"','',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata);
			gerarErro($msgErro);
		}else{
			gerarErro("Mensagens excluídas com sucesso!","btnListMsg();","inform");
		}
		
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
		$callback = "msgError('inform','".utf8ToHtml("Mensagens enviadas parcialmente.")."','hideMsgAguardo();');";
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