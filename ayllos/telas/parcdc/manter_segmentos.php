<? 
	/*!
	 * FONTE        : manter_segmentos.php
	 * CRIAÃ‡ÃƒO      : Jean Michel
	 * DATA CRIAÃ‡ÃƒO : 07/12/2017
	 * OBJETIVO     : Rotina geral de insert, update e exclusÃ£o de segmentos e subsegmentos
	 * --------------
	 * ALTERAÃ‡Ã•ES   :
	 * -------------- 
	 */
  
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	$tpcadast       = (isset($_POST['tpcadast'])       && $_POST['tpcadast'] != null) 		? $_POST['tpcadast'] 	   : '0';
	$cddopcao       = (isset($_POST['cddopcao'])       && $_POST['cddopcao'] != null)       ? $_POST['cddopcao']       : 'C';
	$tpproduto      = (isset($_POST['tpproduto'])      && $_POST['tpproduto'] != null)      ? $_POST['tpproduto']      : '0';
	$cdsegmento     = (isset($_POST['cdsegmento'])     && $_POST['cdsegmento'] != null)     ? $_POST['cdsegmento']     : '0';
	$dssegmento     = (isset($_POST['dssegmento'])     && $_POST['dssegmento'] != null)     ? $_POST['dssegmento']     : '';
	$cdsubsegmento  = (isset($_POST['cdsubsegmento'])  && $_POST['cdsubsegmento'] != null)  ? $_POST['cdsubsegmento']  : '0';
	$dssubsegmento  = (isset($_POST['dssubsegmento'])  && $_POST['dssubsegmento'] != null)  ? $_POST['dssubsegmento']  : '';
	$nrmax_parcela  = (isset($_POST['nrmax_parcela'])  && $_POST['nrmax_parcela'] != null)  ? $_POST['nrmax_parcela']  : '0';
	$vlmax_financ   = (isset($_POST['vlmax_financ'])   && $_POST['vlmax_financ'] != null)   ? $_POST['vlmax_financ']   : '0';
	$nrcarencia     = (isset($_POST['nrcarencia'])     && $_POST['nrcarencia'] != null)   ? $_POST['nrcarencia']   : '0';
    $nmrotina       = isset($_POST["nmrotina"]) ? $_POST["nmrotina"] : $glbvars["nmrotina"];
		
	if (($msgError = validaPermissao($glbvars['nmdatela'],$nmrotina,$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	if($tpcadast == 0){ // Segmento
		// Monta o xml de requisicao
		$xml  = "<Root>";
		$xml .= " <Dados>";
		$xml .= "  <cddopcao>".$cddopcao."</cddopcao>";
		$xml .= "  <tpproduto>".$tpproduto."</tpproduto>";
		$xml .= "  <cdsegmento>".$cdsegmento."</cdsegmento>";
		$xml .= "  <dssegmento>".utf8_decode($dssegmento)."</dssegmento>";
		$xml .= " </Dados>";
		$xml .= "</Root>";
		
		// Executa script para envio do XML e cria objeto para classe de tratamento de XML
		$xmlResult = mensageria($xml, "TELA_PARCDC", "MANTER_SEGMENTOS_CDC", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObjeto = getObjectXML($xmlResult);

		if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
			
			$msgErro = utf8_encode($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata);
			if ($msgErro == "") {
				$msgErro = utf8_encode($xmlObjeto->roottag->tags[0]->cdata);
			}
		
			$msgErro = str_replace('"','',str_replace('(','',str_replace(')','',$msgErro)));	
			if ($cddopcao == 'E'){
				echo('showError("error","'.$msgErro.'","Alerta - Ayllos","fechaRotina($(\'#divUsoGenerico\')); bloqueiaFundo(divRotina);")');
			}else{
				echo('showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divUsoGenerico\').css(\'z-index\')));")');
			}
			exit();
		}else{
			if($cddopcao == "I"){
				exibirErro('inform','Inclus&atilde;o efetuada com sucesso.','Alerta - Ayllos',"fechaRotina($('#divUsoGenerico')); abreTelaParametrosCDC(); setTimeout(function(){acessaOpcaoAba(1);},700); ",false);
			}
			if($cddopcao == "A"){
				exibirErro('inform','Atualiza&ccedil;&atilde;o efetuada com sucesso.','Alerta - Ayllos',"fechaRotina($('#divUsoGenerico')); abreTelaParametrosCDC(); setTimeout(function(){acessaOpcaoAba(1);},700); ",false);	
			}
			if($cddopcao == "E"){
				exibirErro('inform','Exclus&atilde;o efetuada com sucesso.','Alerta - Ayllos',"fechaRotina($('#divUsoGenerico')); abreTelaParametrosCDC(); setTimeout(function(){acessaOpcaoAba(1);},700); ",false);	
			}	
			exit();
		}
		
	}elseif($tpcadast == 1){ // Subsegmento
	  // Monta o xml de requisicao
		$xml  = "<Root>";
		$xml .= " <Dados>";
		$xml .= "  <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";		
		$xml .= "  <cddopcao>".$cddopcao."</cddopcao>";
		$xml .= "  <cdsegmento>".$cdsegmento."</cdsegmento>";
		$xml .= "  <cdsubsegmento>".$cdsubsegmento."</cdsubsegmento>";
		$xml .= "  <dssubsegmento>".utf8_decode($dssubsegmento)."</dssubsegmento>";
		$xml .= "  <nrmax_parcela>".$nrmax_parcela."</nrmax_parcela>";
		$xml .= "  <vlmax_financ>".str_replace(",",".",str_replace(".","",$vlmax_financ))."</vlmax_financ>";
		$xml .= "  <nrcarencia>".$nrcarencia."</nrcarencia>";
		$xml .= " </Dados>";
		$xml .= "</Root>";
		
		// Executa script para envio do XML e cria objeto para classe de tratamento de XML
		$xmlResult = mensageria($xml, "TELA_PARCDC", "MANTER_SUBSEGMENTOS_CDC", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObjeto = getObjectXML($xmlResult);

		if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
			
			$msgErro = utf8_encode($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata);
			if ($msgErro == "") {
				$msgErro = utf8_decode($xmlObjeto->roottag->tags[0]->cdata);
			}
		
			$msgErro = str_replace('"','',str_replace('(','',str_replace(')','',$msgErro)));	
			
			if ($cddopcao == 'E'){
				echo('showError("error","'.$msgErro.'","Alerta - Ayllos","fechaRotina($(\'#divUsoGenerico\')); bloqueiaFundo(divRotina);")');
			}else{
				echo('showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divUsoGenerico\').css(\'z-index\')));")');
			}
			exit();
		}else{
			if($cddopcao == "I"){
				exibirErro('inform','Inclus&atilde;o efetuada com sucesso.','Alerta - Ayllos',"fechaRotina($('#divUsoGenerico')); abreTelaParametrosCDC(); setTimeout(function(){acessaOpcaoAba(1);},700); ",false);
			}
			if($cddopcao == "A"){				
				exibirErro('inform','Atualiza&ccedil;&atilde;o efetuada com sucesso. Ao alterar o Segmento e a descricao do Subsegmento, todas as cooperativas sao afetadas!','Alerta - Ayllos',"fechaRotina($('#divUsoGenerico')); abreTelaParametrosCDC(); setTimeout(function(){acessaOpcaoAba(1);},700); ",false);	
			}	
			if($cddopcao == "E"){
				exibirErro('inform','Exclus&atilde;o efetuada com sucesso.','Alerta - Ayllos',"fechaRotina($('#divUsoGenerico')); abreTelaParametrosCDC(); setTimeout(function(){acessaOpcaoAba(1);},700); ",false);	
			}		
			exit();
		}
	}
?>