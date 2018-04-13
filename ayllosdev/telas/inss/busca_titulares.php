<? 
/*****************************************************************************************************
 * FONTE        : busca_titulares.php     Última alteração: 10/03/2015
 * CRIAÇÃO      : Adriano
 * DATA CRIAÇÃO : 04/09/2013
 * OBJETIVO     : Rotina para buscar todos os titulares da conta em questão
 
 Alterações: 10/03/2015 - Realizado a chamada da rotina direto no oracle
						  devido a conversão para PLSQSL
						  (Adriano).

			 04/04/2018 - Chamada da rotina para verificar se o tipo de conta permite produto 
				          33 - INSS. PRJ366 (Lombardi).
 
 ******************************************************************************************************/
?>
 
<? 
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();		
		
	// Guardo os parâmetos do POST em variáveis	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
	$nrregist = (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 30;
	$nriniseq = (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 1;
	
	// Montar o xml de Requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";	
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <cdprodut>". 33 ."</cdprodut>"; //INSS
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "CADA0006", "VALIDA_ADESAO_PRODUTO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObject = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','',false);
	}
	
	// Monta o xml de requisição
	$xmlBuscaTitulares  = "";
	$xmlBuscaTitulares .= "<Root>";
	$xmlBuscaTitulares .= "  <Dados>";
	$xmlBuscaTitulares .= "		   <nrdconta>".$nrdconta."</nrdconta>";
	$xmlBuscaTitulares .= "	  	   <nriniseq>".$nriniseq."</nriniseq>";
	$xmlBuscaTitulares .= "		   <nrregist>".$nrregist."</nrregist>";
	$xmlBuscaTitulares .= "  </Dados>";
	$xmlBuscaTitulares .= "</Root>";	
	
	
	// Executa script para envio do XML	
	$xmlResult = mensageria($xmlBuscaTitulares, "INSS", "BSCTTLINSS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");	

	$xmlBuscaTitularesObj = getObjectXML($xmlResult);
	
	if ( strtoupper($xmlBuscaTitularesObj->roottag->tags[0]->name) == 'ERRO' ) {
		
		$msgErro = $xmlBuscaTitularesObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo	= $xmlBuscaTitularesObj->roottag->tags[0]->attributes['NMDCAMPO'];
		
		if(!empty($nmdcampo)){ 
			
			if($glbvars['nmrotina'] == 'CONSULTA'){
				$mtdErro = "$('input,select','#frmTrocaOpContaCorrente').removeClass('campoErro');focaCampoErro('".$nmdcampo."','frmTrocaOpContaCorrente');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));";  
			}else{
				$mtdErro = "$('input,select','#frmTrocaDomicilio').removeClass('campoErro');focaCampoErro('".$nmdcampo."','frmTrocaDomicilio');";
			}
								
		}
			
		exibirErro('error',$msgErro,'Alerta - Ayllos',$mtdErro,false);		
				
	}
	
	$registros = $xmlBuscaTitularesObj->roottag->tags;
	$qtregist  = $xmlBuscaTitularesObj->roottag->attributes["QTREGIST"];	
			
	echo 'arrayTitulares = new Array();';
		
	for($i=0; $i<count($registros); $i++){
					
		$idseqttl = getByTagName($registros[$i]->tags,'idseqttl');
		$nmextttl = getByTagName($registros[$i]->tags,'idseqttl')." - ". getByTagName($registros[$i]->tags,'nmextttl');
		$titulares = $titulares."<option value='".$idseqttl."'>".$nmextttl."</option>";
			
		echo 'var titular'.getByTagName($registros[$i]->tags,"idseqttl").' = new Object();';
						
		echo 'titular'.getByTagName($registros[$i]->tags,"idseqttl").'["nrdconta"] = "'.getByTagName($registros[$i]->tags,"nrdconta").'";';
		echo 'titular'.getByTagName($registros[$i]->tags,"idseqttl").'["cdagepac"] = "'.getByTagName($registros[$i]->tags,"cdagepac").'";';
		echo 'titular'.getByTagName($registros[$i]->tags,"idseqttl").'["cdorgins"] = "'.getByTagName($registros[$i]->tags,"cdorgins").'";';
		echo 'titular'.getByTagName($registros[$i]->tags,"idseqttl").'["nrcpfcgc"] = "'.getByTagName($registros[$i]->tags,"nrcpfcgc").'";';
		echo 'titular'.getByTagName($registros[$i]->tags,"idseqttl").'["nmextttl"] = "'.getByTagName($registros[$i]->tags,"nmextttl").'";';
		echo 'titular'.getByTagName($registros[$i]->tags,"idseqttl").'["nmbairro"] = "'.getByTagName($registros[$i]->tags,"nmbairro").'";';
		echo 'titular'.getByTagName($registros[$i]->tags,"idseqttl").'["nmcidade"] = "'.getByTagName($registros[$i]->tags,"nmcidade").'";';
		echo 'titular'.getByTagName($registros[$i]->tags,"idseqttl").'["nrcepend"] = "'.getByTagName($registros[$i]->tags,"nrcepend").'";';
		echo 'titular'.getByTagName($registros[$i]->tags,"idseqttl").'["cdufdttl"] = "'.getByTagName($registros[$i]->tags,"cdufdttl").'";';
		echo 'titular'.getByTagName($registros[$i]->tags,"idseqttl").'["dsendres"] = "'.getByTagName($registros[$i]->tags,"dsendres").'";';
		echo 'titular'.getByTagName($registros[$i]->tags,"idseqttl").'["nrendere"] = "'.getByTagName($registros[$i]->tags,"nrendere").'";';
		echo 'titular'.getByTagName($registros[$i]->tags,"idseqttl").'["cdagesic"] = "'.getByTagName($registros[$i]->tags,"cdagesic").'";';
		echo 'titular'.getByTagName($registros[$i]->tags,"idseqttl").'["idseqttl"] = "'.getByTagName($registros[$i]->tags,"idseqttl").'";';
		echo 'titular'.getByTagName($registros[$i]->tags,"idseqttl").'["nrdddtfc"] = "'.getByTagName($registros[$i]->tags,"nrdddtfc").'";';
		echo 'titular'.getByTagName($registros[$i]->tags,"idseqttl").'["nrtelefo"] = "'.getByTagName($registros[$i]->tags,"nrtelefo").'";';
		echo 'titular'.getByTagName($registros[$i]->tags,"idseqttl").'["nmmaettl"] = "'.getByTagName($registros[$i]->tags,"nmmaettl").'";';
		echo 'titular'.getByTagName($registros[$i]->tags,"idseqttl").'["cdsexotl"] = "'.getByTagName($registros[$i]->tags,"cdsexotl").'";';
		echo 'titular'.getByTagName($registros[$i]->tags,"idseqttl").'["dtnasttl"] = "'.getByTagName($registros[$i]->tags,"dtnasttl").'";';
		echo 'titular'.getByTagName($registros[$i]->tags,"idseqttl").'["cdcooper"] = "'.getByTagName($registros[$i]->tags,"cdcooper").'";';
		
		echo 'arrayTitulares["'.getByTagName($registros[$i]->tags,"idseqttl").'"] = titular'.getByTagName($registros[$i]->tags,"idseqttl").';';
			
	}
		
	if($glbvars['nmrotina'] == 'CONSULTA'){
	
		echo 'blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));';
		echo '$("#btConcluir","#divBotoesTrocaOpContaCorrente").unbind("click").bind("click", function(){';
		echo '	 showConfirmacao(\'Deseja confirmar opera&ccedil;&atilde;o?\',\'Confirma&ccedil;&atilde;o - Ayllos\',\'solicitaTrocaOPContaCorrente("'.$cddopcao.'");\',\'$("#nrdconta","#frmTrocaOpContaCorrente").focus();blockBackground(parseInt($("#divRotina").css("z-index")));\',"sim.gif","nao.gif");';
		echo '	 return false;';
		echo '});';
		echo '$("#idseqttl","#frmTrocaOpContaCorrente").html("'.$titulares.'").habilitaCampo().focus();';
	
	}else{
	
		echo '$("#btConcluir","#divBotoesTrocaDomicilio").unbind("click").bind("click", function(){';
		echo '	if(inclusao){';
		echo '		showConfirmacao(\'Deseja confirmar opera&ccedil;&atilde;o?\',\'Confirma&ccedil;&atilde;o - Ayllos\',\'solicitaTrocaDomicilio("'.$cddopcao.'",$("#idseqttl","#frmTrocaDomicilio").val());\',\'$("#nrdconta","#frmTrocaDomicilio").focus();\',"sim.gif","nao.gif");		';		
		echo '		return false;';
		echo '	}else{';
		echo '		showConfirmacao(\'Deseja confirmar opera&ccedil;&atilde;o?\',\'Confirma&ccedil;&atilde;o - Ayllos\',\'solicitaTrocaOpContaCorrenteEntreCoop("'.$cddopcao.'",$("#idseqttl","#frmTrocaDomicilio").val());\',\'$("#nrdconta","#frmTrocaDomicilio").focus();\',"sim.gif","nao.gif");';
		echo '		return false;';
		echo '	}';
		echo '});';
		echo '$("#idseqttl","#frmTrocaDomicilio").html("'.$titulares.'").habilitaCampo().focus();';
	
	}
			
?>