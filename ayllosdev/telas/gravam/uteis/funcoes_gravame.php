<?php
/*!
 * FONTE        : funcoes_gravame.php
 * CRIAÇÃO      : Thaise Medeiros (Envolti)
 * DATA CRIAÇÃO : Outubro/2018 
 * OBJETIVO     : Funções específicas para as rotinas do gravame
 * --------------
 */
	$httpcode = 0;
	$postDate = '';
	$getDate = '';
	$cdcooper = 0;
	$cdagenci = 0;
	$nrdcaixa = 0;
	$idorigem = 0;
	$cdoperad = 0;	

	function parametrosParaAudit($cdcooper, $cdagenci, $nrdcaixa, $idorigem, $cdoperad) {
		$GLOBALS["cdcooper"] = $cdcooper;
		$GLOBALS["cdagenci"] = $cdagenci;
		$GLOBALS["nrdcaixa"] = $nrdcaixa;
		$GLOBALS["idorigem"] = $idorigem;
		$GLOBALS["cdoperad"] = $cdoperad;
	}

	//Função para transformar Timestamp("yyyy-mm-ddThh:mm:ss") em DateTime(dd/mm/yyyy hh:mm:ss)
	function timestampParaDateTime($timestamp) {
		$arTimestamp = explode("T", $timestamp);
		$arDate = explode("-", $arTimestamp[0]);
		$dia = $arDate[2];
		$mes = $arDate[1];
		$ano = $arDate[0];
		return $dia."/".$mes."/".$ano." ".$arTimestamp[1];
	}

	//Função para transformar string 
	function getXML($xmlStr) {
		$xmlStr = str_replace(array("\n", "\r", "\t"), '', $xmlStr);
		$xmlStr = trim(str_replace('"', "'", $xmlStr));
		$xml = simplexml_load_string($xmlStr);
		return $xml;
	}	

	//Função para pegar a URL que vem nos atributos do XML
	function getURL($xml) {
		$att = $xml->attributes();
		$url = $att['iduriservico'];
		return $url;
	}
	
	//Função para pegar a URL que vem nos atributos do XML
	function getCoopCod($xml) {
		$att = $xml->attributes();
		$coop = $att['cdcooper'];
		return $coop;
	}

	function convertXMLtoJSONAliena($xml) {
		$data = '{			"cooperativa": { "codigo": "'.getCoopCod($xml).'" },
				"sistemaNacionalGravames": '.convertXMLtoJSONnode0($xml->sistemaNacionalGravames).',
				  "objetoContratoCredito": '.convertXMLtoJSONnode0($xml->objetoContratoCredito).',
				"propostaContratoCredito": '.convertXMLtoJSONnode0($xml->propostaContratoCredito).',
					"representanteVendas": '.convertXMLtoJSONnode0($xml->representanteVendas).',
			   "estabelecimentoComercial": '.convertXMLtoJSONnode0($xml->estabelecimentoComercial).'}';
		return $data;	
	}

	//Função para converter os nós "sistemaNacionalGravames" e "objetoContratoCredito" do XML em JSON
	function convertXMLtoJSONConsulta($xml) {
		$data = '{			"cooperativa": { "codigo": "'.getCoopCod($xml).'" },
				"sistemaNacionalGravames": '.convertXMLtoJSONnode0($xml->sistemaNacionalGravames).',
				  "objetoContratoCredito": '.convertXMLtoJSONnode0($xml->objetoContratoCredito).'}';
		return $data;	
	}

	//Função para converter os nós "sistemaNacionalGravames", "objetoContratoCredito" e "propostaContratoCredito" do XML em JSON
	function convertXMLtoJSONBaixaCancel($xml) {
		$data = '{			"cooperativa": { "codigo": "'.getCoopCod($xml).'" },
				"sistemaNacionalGravames": '.convertXMLtoJSONnode0($xml->sistemaNacionalGravames).',
				  "objetoContratoCredito": '.convertXMLtoJSONnode0($xml->objetoContratoCredito).',
				"propostaContratoCredito": '.convertXMLtoJSONnode0($xml->propostaContratoCredito).'}';
		return $data;	
	}

	//Função para tratar as variáveis que serão utilizadas no POST e verificar o retorno
	function postGravame($xml, $data, $url, $authPost) {
		$xmlReturn;
		if($url == null || $url == ''){
			echo "showError('inform','N&atilde;o foi encontrada a URL.','Notifica&ccedil;&atilde;o - Ayllos','');";	
		} else {
			$arrayHeader = array("Content-Type:application/json","Accept-Charset:application/json","Authorization:".$authPost);
			$GLOBALS["postDate"] = date("d/m/Y H:i:s");
    		$xmlReturn = ChamaServico($url, "POST", $arrayHeader, $data);
			$GLOBALS["getDate"] = date("d/m/Y H:i:s");
		}
		return $xmlReturn;
	}

	//Função para fazer o POST e trazer o httpcode
	function ChamaServico($url, $method, $arrayHeader, $data) {
        $ch = curl_init($url);                                                                      
        curl_setopt($ch, CURLOPT_CUSTOMREQUEST, $method);                                                                     
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);                                                                      
        curl_setopt($ch, CURLOPT_HTTPHEADER, $arrayHeader);                                                                                                                                      
        curl_setopt($ch, CURLOPT_POSTFIELDS, $data);                                                                  
        $resultXml = curl_exec($ch);
        $GLOBALS["httpcode"] = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        return $resultXml;
    }

    function verificarRetornoAliena($xmlStr) {
    	$xmlRet = getObjectXML($xmlStr);
		$retContr = $xmlRet->roottag->tags[0]->tags[0]->cdata;
    	$retGravame = $xmlRet->roottag->tags[0]->tags[1]->cdata;
    	$GLOBALS["identificador"] = $xmlRet->roottag->tags[0]->tags[3]->cdata;
    	$dataInteracao = ($xmlRet->roottag->tags[0]->tags[2]->cdata) ? timestampParaDateTime($xmlRet->roottag->tags[0]->tags[2]->cdata) : "";
    	$idRegistro = $xmlRet->roottag->tags[0]->tags[3]->cdata;
    	gravarAuditoria($GLOBALS["postDate"], $GLOBALS["getDate"], retornarMensagemErro($xmlRet), $dataInteracao, $idRegistro, 'N', 1,  $identificador); //$retGravame, $retContr, $identificador);
    	if($GLOBALS["httpcode"] == 200 && ($retGravame == 30 || $retContr == 90)){
    		return true;
    	} else{
    		echo 'showError("error","'.utf8ToHtml('Veículo não alienado - Verificar crítica.').'","'.utf8ToHtml('Alerta - Ayllos').'","","$NaN");';
    	}
    }

	//Função para verificar o retorno do XML de alienação 
    function verificarRetornoConsulta($xmlStr) {
    	$cdoperac = 4;
    	$xmlRet = getObjectXML($xmlStr);
    	if($GLOBALS["httpcode"] == 200){
    		$qtdOcorr = $xmlRet->roottag->tags[0]->tags[0]->cdata;
    		$index = $qtdOcorr -1;
    		$interacaoGravame = $xmlRet->roottag->tags[1]->tags[$index]->tags[3]->tags[$index]->tags[0];
    		$dataInteracao = timestampParaDateTime($interacaoGravame->tags[0]->cdata);
    		$idRegistro = $xmlRet->roottag->tags[1]->tags[0]->tags[0]->tags[5]->cdata;
			//echo $qtdOcorr ; die;
    		gravarAuditoria($GLOBALS["postDate"], $GLOBALS["getDate"], '', $dataInteracao, $idRegistro, 'N', $cdoperac, '');//, '', '');
    		if ($qtdOcorr == 0) {
				exibirErro('error','N&atilde;o foi poss&iacute;vel confirmar aliena&ccedil;&atilde;o no SNG','Alerta - Ayllos','formatarInclusaoManual();',false);		
			} else {
				$seqLista = $interacaoGravame->tags[2]->cdata;
				if($seqLista != '' && $seqLista == $qtdOcorr){
					$tipoInteracao = $interacaoGravame->tags[3]->tags[0]->cdata;
					if($tipoInteracao == 'PLEDGE-OUT'){
						$contrato = $xmlRet->roottag->tags[1]->tags[$index]->tags[2]->tags[1]->cdata;
						if($contrato == $GLOBALS["nrctrpro"]){
							echo "atualizarDadosAlienacaoAuto('".$dataInteracao."', '".$idRegistro."');";
							$funcao = '$(\'html, body\').animate({scrollTop:0}, \'fast\');inclusaoManual(\'A\');';
							echo "showConfirmacao('".utf8ToHtml('Confirmar gravação da alienação automática?')."', 'Confirma&ccedil;&atilde;o - Ayllos', ".$funcao.", '', 'sim.gif', 'nao.gif');";
						} else {
							exibirErro('error','N&atilde;o foi poss&iacute;vel confirmar aliena&ccedil;&atilde;o no SNG','Alerta - Ayllos','formatarInclusaoManual();',false);		
						}
					} else {
						exibirErro('error','N&atilde;o foi poss&iacute;vel confirmar aliena&ccedil;&atilde;o no SNG','Alerta - Ayllos','formatarInclusaoManual();',false);		
					}
				} else{
					exibirErro('error','N&atilde;o foi poss&iacute;vel confirmar aliena&ccedil;&atilde;o no SNG','Alerta - Ayllos','formatarInclusaoManual();',false);		
				}
			}
		} else {
			$errorMessage = retornarMensagemErro($xmlRet);
			gravarAuditoria($GLOBALS["postDate"], $GLOBALS["getDate"], $errorMessage, '', '', 'N', $cdoperac, '');//, '', '');
		}
    }

    function verificarRetornoBaixaCancel($xmlStr, $cdoperac, $tela) {
    	$xmlRet = getObjectXML($xmlStr);
    	if ($GLOBALS["httpcode"] == 200) {
    		$dataInteracao = timestampParaDateTime($xmlRet->roottag->tags[0]->tags[0]->cdata);
    		$idRegistro = $xmlRet->roottag->tags[0]->tags[1]->cdata;
			//echo $GLOBALS["postDate"] . " - " . $GLOBALS["getDate"] . " - " . '' . " - " . $dataInteracao . " - " . $idRegistro . " - " . 'S' . " - " . $cdoperac . " - " . ''; die;
    		gravarAuditoria($GLOBALS["postDate"], $GLOBALS["getDate"], '', $dataInteracao, $idRegistro, 'S', $cdoperac, '');//, '', '');
    		if ($cdoperac == 2 && $tela != 'ADITIV') {
				echo "showError('inform','Cancelamento autom&aacute;tico da aliena&ccedil;&atilde;o efetuada com sucesso no SNG.','Notifica&ccedil;&atilde;o - Ayllos','buscaBens(1, 30);');";	
    		} else if($cdoperac == 3 && $tela != 'ADITIV') {
    			echo "showError('inform','Baixa autom&aacute;tica da aliena&ccedil;&atilde;o efetuada com sucesso no SNG.','Notifica&ccedil;&atilde;o - Ayllos','buscaBens(1, 30);');";	
    		} else {
    			$retGravame = $xmlRet->roottag->tags[0]->tags[1]->cdata;
    			if ($retGravame != 30) {
					echo "showError('error','".utf8ToHtml('Houve crítica na baixa do veículo substituído, porém o aditivo contratual será gerado e a baixa será efetuada no processo automático assim que possível.')."','Notifica&ccedil;&atilde;o - Ayllos','');";	
    			}
    		}
    	} else {
    		$errorMessage = retornarMensagemErro($xmlRet);
			gravarAuditoria($GLOBALS["postDate"], $GLOBALS["getDate"], $errorMessage, '', '', 'S', $cdoperac, '');//, '', '');
			if($cdoperac == 2 && $tela != 'ADITIV'){
				echo "showError('error','Cancelamento autom&aacute;tico da aliena&ccedil;&atilde;o n&atilde;o confirmada junto ao SNG. Erro encontrado: ".$errorMessage."','Notifica&ccedil;&atilde;o - Ayllos','');";	
			} else if($cdoperac == 3 && $tela != 'ADITIV'){
				echo "showError('error','Baixa autom&aacute;tica da aliena&ccedil;&atilde;o n&atilde;o confirmada junto ao SNG. Erro encontrado: ".$errorMessage."','Notifica&ccedil;&atilde;o - Ayllos','');";	
			} else {
					echo "showError('error','".utf8ToHtml('Houve crítica na baixa do veículo substituído, porém o aditivo contratual será gerado e a baixa será efetuada no processo automático assim que possível.')."','Notifica&ccedil;&atilde;o - Ayllos','');";	
    		}
    	}
    }

	//Função para gravar os dados na auditoria
    function gravarAuditoria($postDate, $getDate, $errorMessage, $dataInteracao, $idRegistro, $flsituac, $cdoperac, $identificador){ //, $retGravame, $retContr, $identificador) {
    	$dschassi = $cdoperac == 1 ? $GLOBALS["dschassi"] : '';
    	$dscatbem = $cdoperac == 1 ? $GLOBALS["dscatbem"] : '';
    	$dstipbem = $cdoperac == 1 ? $GLOBALS["dstipbem"] : '';
    	$dsmarbem = $cdoperac == 1 ? $GLOBALS["dsmarbem"] : '';
    	$dsbemfin = $cdoperac == 1 ? $GLOBALS["dsbemfin"] : '';
    	$nrcpfbem = $cdoperac == 1 ? $GLOBALS["nrcpfbem"] : '';
    	$tpchassi = $cdoperac == 1 ? $GLOBALS["tpchassi"] : '';
    	$uflicenc = $cdoperac == 1 ? $GLOBALS["uflicenc"] : '';
    	$nranobem = $cdoperac == 1 ? $GLOBALS["nranobem"] : '';
    	$nrmodbem = $cdoperac == 1 ? $GLOBALS["nrmodbem"] : '';
    	$ufdplaca = $cdoperac == 1 ? $GLOBALS["ufdplaca"] : '';
    	$nrdplaca = $cdoperac == 1 ? $GLOBALS["nrdplaca"] : '';
    	$nrrenava = $cdoperac == 1 ? $GLOBALS["nrrenava"] : '';

		$tpctrpro = (isset($GLOBALS["tpctrato"])) ? $GLOBALS["tpctrato"] : $GLOBALS["tpctrpro"];
		$nrctrpro = (isset($GLOBALS["nrctremp"])) ? $GLOBALS["nrctremp"] : $GLOBALS["nrctrpro"];

    	$xml      = "";
		$xml      .= "<Root>";
		$xml      .= "  <Dados>";
		$xml      .= "     <nrdconta>".$GLOBALS["nrdconta"]."</nrdconta>";
		$xml      .= "     <tpctrato>".$tpctrpro."</tpctrato>";
		$xml      .= "     <nrctrpro>".$nrctrpro."</nrctrpro>";
		$xml      .= "     <idseqbem>".$GLOBALS["idseqbem"]."</idseqbem>";
		$xml      .= "     <cdoperac>".$cdoperac."</cdoperac>";
		$xml      .= "     <dschassi>".$dschassi."</dschassi>";
		$xml      .= "     <dscatbem>".$dscatbem."</dscatbem>";
		$xml      .= "     <dstipbem>".$dstipbem."</dstipbem>";
		$xml      .= "     <dsmarbem>".$dsmarbem."</dsmarbem>";
		$xml      .= "     <dsbemfin>".$dsbemfin."</dsbemfin>";
		$xml      .= "     <nrcpfbem>".$nrcpfbem."</nrcpfbem>";
		$xml      .= "     <tpchassi>".$tpchassi."</tpchassi>";
		$xml      .= "     <uflicenc>".$uflicenc."</uflicenc>";
		$xml      .= "     <nranobem>".$nranobem."</nranobem>";
		$xml      .= "     <nrmodbem>".$nrmodbem."</nrmodbem>";
		$xml      .= "     <ufdplaca>".$ufdplaca."</ufdplaca>";
		$xml      .= "     <nrdplaca>".$nrdplaca."</nrdplaca>";
		$xml      .= "     <nrrenava>".$nrrenava."</nrrenava>";
		$xml      .= "     <dtenvgrv>".$postDate."</dtenvgrv>";
  		$xml      .= "     <dtretgrv>".$getDate."</dtretgrv>";
		$xml      .= "     <chttpsoa>".$GLOBALS["httpcode"]."</chttpsoa>";
		$xml      .= "     <dsmsgsoa>".$errorMessage['msg']."</dsmsgsoa>";
		$xml      .= "     <nrcodsoa>".$errorMessage['code']."</nrcodsoa>";
		$xml      .= "     <cdtypsoa>".$errorMessage['type']."</cdtypsoa>";
		$xml      .= "     <cdlegsoa>".$errorMessage['legacyCode']."</cdlegsoa>";
  		//$xml      .= "     <cdretgrv>".$retGravame."</cdretgrv>";
  		//$xml      .= "     <cdretctr>".$retContr."</cdretctr>";
  		$xml      .= "     <nrgravam>".$identificador."</nrgravam>";
  		$xml      .= "     <idregist>".$idRegistro."</idregist>";
  		$xml      .= "     <dtregist>".$dataInteracao."</dtregist>";
  		//$xml      .= "     <dserrcom>".$errorMessage."</dserrcom>";
  		$xml      .= "     <flsituac>".$flsituac."</flsituac>";
  		$xml      .= "  </Dados>";
		$xml      .= "</Root>";

  		// Executa script para envio do XML
  		$xmlResult = mensageria($xml,"GRVM0001","AUDITGRAVAM",$GLOBALS['cdcooper'],$GLOBALS["cdagenci"],$GLOBALS["nrdcaixa"],$GLOBALS["idorigem"],$GLOBALS["cdoperad"],"</Root>");  		
  		$xmlObj = getObjectXML($xmlResult);

		/*/ Se ocorrer um erro, mostra crítica
		if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
			exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
		}*/
    }

    //Função que trata o retorno de erro e monta a mensagem para salvar.
    function retornarMensagemErro($xmlRet) {
    	$errorMesssage['type'] = $xmlRet->roottag->tags[0]->cdata;
		$errorMesssage['code'] = $xmlRet->roottag->tags[1]->cdata;
		$errorMesssage['legacyCode'] = $xmlRet->roottag->tags[2]->cdata;
		$errorMesssage['msg'] = $xmlRet->roottag->tags[3]->cdata;
		return $errorMesssage; //type."-".$code.":".$msg;
    }

    function processarAlienacao($xmlResult, $UrlSOA, $AuthSOA) {
		$xml = getXML($xmlResult);
		$url = $UrlSOA.getURL($xml->gravameB3[0]->gravame[0]);
		$data = convertXMLtoJSONAliena($xml->gravameB3[0]->gravame[0]);		
		$xmlStr = postGravame($xml, $data, $url, $AuthSOA);
		return verificarRetornoAliena($xmlStr);
    }

    function processarBaixaCancel($xmlResult, $cdoperac, $UrlSOA, $AuthSOA) {
    	$xml = getXML($xmlResult);
    	$url = $UrlSOA.getURL($xml->gravameB3[0]->gravame[0]);
		$data = convertXMLtoJSONBaixaCancel($xml->gravameB3[0]->gravame[0]);
		$xmlStr = postGravame($xml, $data, $url, $AuthSOA);
		verificarRetornoBaixaCancel($xmlStr, $cdoperac, '');
    }

	function processarBaixaAditiv($xmlResult, $cdoperac, $UrlSOA, $AuthSOA) {
    	$xml = getXML($xmlResult);
    	$url = $UrlSOA.getURL($xml->gravameB3[0]->gravame[1]);
		$data = convertXMLtoJSONBaixaCancel($xml->gravameB3[0]->gravame[1]);
		$xmlStr = postGravame($xml, $data, $url, $AuthSOA);
		verificarRetornoBaixaCancel($xmlStr, $cdoperac, 'ADITIV');
    }

	function convertXMLtoJSONnode0($resultXml){
		//$arrSubst = array('/:{}/','/:{ }/');
		//$resultXml = preg_replace($arrSubst, ':""', json_encode($resultXml));
		$arrSubst = array(':{"0":" "}',':{ }');
		$resultXml = str_replace($arrSubst, ':" "', json_encode($resultXml));
		return $resultXml;
	}
 ?>
