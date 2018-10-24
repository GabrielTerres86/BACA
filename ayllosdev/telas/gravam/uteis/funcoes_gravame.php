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

	function parametrosParaAudit($cdcooper, $cdagenci, $nrdcaixa, $idorigem, $cdoperad){
		$GLOBALS["cdcooper"] = $cdcooper;
		$GLOBALS["cdagenci"] = $cdagenci;
		$GLOBALS["nrdcaixa"] = $nrdcaixa;
		$GLOBALS["idorigem"] = $idorigem;
		$GLOBALS["cdoperad"] = $cdoperad;
	}
	
	//Função para transformar Timestamp("yyyy-mm-ddThh:mm:ss") em DateTime(dd/mm/yyyy hh:mm:ss)
	function timestampParaDateTime($timestamp){
		$arTimestamp = explode("T", $timestamp);
		$arDate = explode("-", $arTimestamp[0]);
		$dia = $arDate[2];
		$mes = $arDate[1];
		$ano = $arDate[0];
		return $dia."/".$mes."/".$ano." ".$arTimestamp[1];
	}

	//Função para transformar string 
	function getXML($xmlStr){
		$xmlStr = str_replace(array("\n", "\r", "\t"), '', $xmlStr);
		$xmlStr = trim(str_replace('"', "'", $xmlStr));
		$xml = simplexml_load_string($xmlStr);
		return $xml;
	}	

	//Função para pegar a URL que vem nos atributos do XML
	function getURL($xml){
		$att = $xml->gravameB3[0]->gravame[0]->attributes();
		$url = $att['iduriservico'];
		return $url;
	}
	
	//Função para converter os nós "sistemaNacionalGravames" e "objetoContratoCredito" do XML em JSON
	function convertXMLtoJSONInclusao($xml){
		$sistNac = json_encode($xml->gravameB3[0]->gravame[0]->sistemaNacionalGravames);
		$objContr = json_encode($xml->gravameB3[0]->gravame[0]->objetoContratoCredito);
		$data = '{"sistemaNacionalGravames": '.$sistNac.',
					"objetoContratoCredito": '.$objContr.'}';
		return $data;	
	}

	//Função para converter os nós "sistemaNacionalGravames" e "objetoContratoCredito" do XML em JSON
	function convertXMLtoJSONBaixaCancel($xml){
		$sistNac = json_encode($xml->gravameB3[0]->gravame[0]->sistemaNacionalGravames);
		$objContr = json_encode($xml->gravameB3[0]->gravame[0]->objetoContratoCredito);
		$propostaContratoCredito = json_encode($xml->gravameB3[0]->gravame[0]->propostaContratoCredito);
		$data = '{"sistemaNacionalGravames": '.$sistNac.',
					"objetoContratoCredito": '.$objContr.',
					"propostaContratoCredito": '.$propostaContratoCredito.'}';
		return $data;	
	}

	//Função para tratar as variáveis que serão utilizadas no POST e verificar o retorno
	function postGravame($xml, $data, $url, $authPost){
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
	function ChamaServico($url, $method, $arrayHeader, $data){
        $ch = curl_init($url);                                                                      
        curl_setopt($ch, CURLOPT_CUSTOMREQUEST, $method);                                                                     
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);                                                                      
        curl_setopt($ch, CURLOPT_HTTPHEADER, $arrayHeader);                                                                                                                                      
        curl_setopt($ch, CURLOPT_POSTFIELDS, $data);                                                                  
        $resultXml = curl_exec($ch);
        $GLOBALS["httpcode"] = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        return $resultXml;
    }

	//Função para verificar o retorno do XML de alienação 
    function verificarRetornoInclusao($xmlStr){
    	$cdoperac = 4;
    	$xmlRet = getObjectXML($xmlStr);
    	if($GLOBALS["httpcode"] == 200){
    		$qtdOcorr = $xmlRet->roottag->tags[0]->tags[0]->cdata;
    		$index = $qtdOcorr -1;
    		$interacaoGravame = $xmlRet->roottag->tags[1]->tags[$index]->tags[3]->tags[$index]->tags[0];
    		$dataInteracao = timestampParaDateTime($interacaoGravame->tags[0]->cdata);
    		$idRegistro = $xmlRet->roottag->tags[1]->tags[0]->tags[0]->tags[5]->cdata;
    		gravarAuditoria($GLOBALS["postDate"], $GLOBALS["getDate"], '', $dataInteracao, $idRegistro, 'N', $cdoperac);
    		if($qtdOcorr == 0){
				tratarErro();
			} else {
				$seqLista = $interacaoGravame->tags[2]->cdata;
				if($seqLista != '' && $seqLista == $qtdOcorr){
					$tipoInteracao = $interacaoGravame->tags[3]->tags[0]->cdata;
					if($tipoInteracao == 'PLEDGE_OUT'){
						$contrato = $xmlRet->roottag->tags[1]->tags[$index]->tags[2]->tags[1]->cdata;
						if($contrato == $GLOBALS["nrctrpro"]){
							echo "atualizarDadosAlienacaoAuto('".$dataInteracao."', '".$idRegistro."');";
							$funcao = '$(\'html, body\').animate({scrollTop:0}, \'fast\');inclusaoManual(\'A\');';
							echo "showConfirmacao('Confirmar grava&ccedil;&atilde;o da aliena&ccedil;&atilde;o autom&aacute;tica?', 'Confirma&ccedil;&atilde;o - Ayllos', ".$funcao.", '', 'sim.gif', 'nao.gif');";
						} else {
							tratarErro();
						}
					} else {
						tratarErro();
					}
				} else{
					tratarErro();
				}
			}
		} else {
			$errorMessage = retornarMensagemErro($xmlRet);
			gravarAuditoria($GLOBALS["postDate"], $GLOBALS["getDate"], $errorMessage, '', '', 'N', $cdoperac);
		}
    }

    function verificarRetornoBaixaCancel($xmlStr, $cdoperac){
    	$xmlRet = getObjectXML($xmlStr);
    	if($GLOBALS["httpcode"] == 200){
    		$dataInteracao = timestampParaDateTime($xmlRet->roottag->tags[0]->tags[0]->cdata);
    		$idRegistro = $xmlRet->roottag->tags[0]->tags[1]->cdata;
    		gravarAuditoria($GLOBALS["postDate"], $GLOBALS["getDate"], '', $dataInteracao, $idRegistro, 'S', $cdoperac);
    		if($cdoperac == 2){
				echo "showError('inform','Cancelamento autom&aacute;tico da aliena&ccedil;&atilde;o efetuada com sucesso no SNG.','Notifica&ccedil;&atilde;o - Ayllos','buscaBens(1, 30);');";	
    		} else if($cdoperac == 3) {
    			echo "showError('inform','Baixa autom&aacute;tica da aliena&ccedil;&atilde;o efetuada com sucesso no SNG.','Notifica&ccedil;&atilde;o - Ayllos','buscaBens(1, 30);');";	
    		}
    	} else{
    		$errorMessage = retornarMensagemErro($xmlRet);
			gravarAuditoria($GLOBALS["postDate"], $GLOBALS["getDate"], $errorMessage, '', '', 'S', $cdoperac);
			if($cdoperac == 2){
				echo "showError('error','Cancelamento autom&aacute;tico da aliena&ccedil;&atilde;o n&atilde;o confirmada junto ao SNG. Erro encontrado: ".$errorMessage."','Notifica&ccedil;&atilde;o - Ayllos','');";	
			} else if($cdoperac == 3){
				echo "showError('error','Baixa autom&aacute;tica da aliena&ccedil;&atilde;o n&atilde;o confirmada junto ao SNG. Erro encontrado: ".$errorMessage."','Notifica&ccedil;&atilde;o - Ayllos','');";	
			}
    	}
    }


    //Função que trata o retorno de erro e monta a mensagem para salvar.
    function retornarMensagemErro($xmlRet){
    	$type = $xmlRet->roottag->tags[0]->cdata;
		$code = $xmlRet->roottag->tags[1]->cdata;
		$msg = $xmlRet->roottag->tags[2]->cdata;
		return $type."-".$code.":".$msg;
    }

	//Função para gravar os dados na auditoria
    function gravarAuditoria($postDate, $getDate, $errorMessage, $dataInteracao, $idRegistro, $flsituac, $cdoperac){
    	$xml      = "";
		$xml      .= "<Root>";
		$xml      .= "  <Dados>";
		$xml      .= "     <nrdconta>".$GLOBALS["nrdconta"]."</nrdconta>";
		$xml      .= "     <tpctrato>".$GLOBALS["tpctrpro"]."</tpctrato>";
		$xml      .= "     <nrctrpro>".$GLOBALS["nrctrpro"]."</nrctrpro>";
		$xml      .= "     <idseqbem>".$GLOBALS["idseqbem"]."</idseqbem>";
		$xml      .= "     <cdoperac>".$cdoperac."</cdoperac>";
		$xml      .= "     <dschassi/>";
		$xml      .= "     <dscatbem/>";
		$xml      .= "     <dstipbem/>";
		$xml      .= "     <dsmarbem/>";
		$xml      .= "     <dsbemfin/>";
		$xml      .= "     <nrcpfbem/>";
		$xml      .= "     <tpchassi/>";
		$xml      .= "     <uflicenc/>";
		$xml      .= "     <nranobem/>";
		$xml      .= "     <nrmodbem/>";
		$xml      .= "     <ufdplaca/>";
		$xml      .= "     <nrdplaca/>";
		$xml      .= "     <nrrenava/>";
		$xml      .= "     <dtenvgrv>".$postDate."</dtenvgrv>";
  		$xml      .= "     <dtretgrv>".$getDate."</dtretgrv>";
  		/*campos novos aguardando informação */
  		$xml      .= "     <cdretgrv/>";
  		$xml      .= "     <cdretctr/>";
  		$xml      .= "     <nrgravam/>"; 
  		$xml      .= "     <idregist>".$idRegistro."</idregist>";
  		$xml      .= "     <dtregist>".$dataInteracao."</dtregist>";
  		$xml      .= "     <dserrcom>".$errorMessage."</dserrcom>";
  		$xml      .= "     <flsituac>".$flsituac."</flsituac>";  
  		$xml      .= "  </Dados>";
  		$xml      .= "</Root>";

  		 // Executa script para envio do XML  
  		$xmlResult = mensageria($xml,"GRVM0001","AUDITGRAVAM",$GLOBALS['cdcooper'],$GLOBALS["cdagenci"],$GLOBALS["nrdcaixa"],$GLOBALS["idorigem"],$GLOBALS["cdoperad"],"</Root>");  		
  		$xmlObj = getObjectXML($xmlResult);
    }

	//Função para tratar o erro de verificações do XML
    function tratarErro(){
    	exibirErro('error','N&atilde;o foi poss&iacute;vel confirmar aliena&ccedil;&atilde;o no SNG','Alerta - Ayllos','formatarInclusaoManual();',false);		
    }
 ?>
