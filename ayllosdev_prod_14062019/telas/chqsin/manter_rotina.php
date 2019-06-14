<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Rodrigo Bertelli (RKAM)
 * DATA CRIAÇÃO : 27/06/2014
 * OBJETIVO     : Mantem a rotina das informacoes de inclusao e delecao na tela CHQSIN
 *
 * Alteração    : 16/10/2015 - (Lucas Ranghetti #326872) - Alteração referente ao projeto melhoria 217, cheques sinistrados fora.
 */
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();

 $intcodconta = $_POST['codbanco'];
 $intcodagenc = $_POST['codagencia'];
 $intcodchequ = $_POST['nrconta'];
 $strmotivo = $_POST['dscmotivo'];
 $datinclusao = $_POST['datinc'];
 $stracao = $_POST['stracao'];
 $cdtipchq = $_POST['cdtipchq'];
 $nrcheque = $_POST['nrcheque'];
 $nrchqini = $_POST['nrchqini'];
 $nrchqfim = $_POST['nrchqfim'];
 $camposDc = (isset($_POST['camposDc']))  ? $_POST['camposDc']  : '' ;
 $dadosDc  = (isset($_POST['dadosDc']))   ? $_POST['dadosDc']   : '' ;
 
 //rotina da exclusao de codigos com fraude cheques internos
 if($stracao == 'E1'){
	 
	 // Cheques internos
	if($cdtipchq == 'I'){
		$strnomacao = 'EXCCHQSIN';
		$xmlexclusao  = "";
		$xmlexclusao .= "<Root>";
		$xmlexclusao .= " <Dados>";
		$xmlexclusao .= "    <dtmvtolt>".$datinclusao."</dtmvtolt>";
		$xmlexclusao .= "    <cdbccxlt>".$intcodconta."</cdbccxlt>";
		$xmlexclusao .= "    <cdagectl>".$intcodagenc."</cdagectl>";
		$xmlexclusao .= "    <nrctachq>".$intcodchequ."</nrctachq>";
		$xmlexclusao .= " </Dados>";
		$xmlexclusao .= "</Root>";
		
		 $xmlResultExc = mensageria($xmlexclusao, "CHQSIN", $strnomacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["nmoperad"], "</Root>");
		 $xmlObjExc = getObjectXML($xmlResultExc);
		 
		if(strtoupper($xmlObjExc->roottag->tags[0]->name == 'ERRO')){
			$msgErro = $xmlObjExc->roottag->tags[0]->cdata;
			if($msgErro == ""){
				$msgErro = $xmlObjExc->roottag->tags[0]->tags[0]->tags[4]->cdata;
			}
			exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
		} 
	}else{
		// Cheques fora
		$strnomacao = 'EXCLUI_CHQSIN_FORA';
		$xmlexclusao  = "";
		$xmlexclusao .= "<Root>";
		$xmlexclusao .= " <Dados>";
		$xmlexclusao .=      retornaXmlFilhos( $camposDc, $dadosDc, 'ChequesFora', 'Itens');
		$xmlexclusao .= " </Dados>";
		$xmlexclusao .= "</Root>";
		
		 $xmlResultExc = mensageria($xmlexclusao, "CHQSIN", $strnomacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		 $xmlObjExc = getObjectXML($xmlResultExc);
		 
		if(strtoupper($xmlObjExc->roottag->tags[0]->name == 'ERRO')){
			$msgErro = $xmlObjExc->roottag->tags[0]->cdata;
			if($msgErro == ""){
				$msgErro = $xmlObjExc->roottag->tags[0]->tags[0]->tags[4]->cdata;
			}
			exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
		}
	} 
}

if($stracao == 'I1' ){
 
	// Cheques internos
	if($cdtipchq == 'I'){
		$strnomacao = 'INCCHQSIN';
		$xmlInclusao  = "";
		$xmlInclusao .= "<Root>";
		$xmlInclusao .= " <Dados>";
		$xmlInclusao .= "    <dtmvtolt>".$datinclusao."</dtmvtolt>";
		$xmlInclusao .= "    <cdbccxlt>".$intcodconta."</cdbccxlt>";
		$xmlInclusao .= "    <cdagectl>".$intcodagenc."</cdagectl>";
		$xmlInclusao .= "    <nrctachq>".$intcodchequ."</nrctachq>";
		$xmlInclusao .= "    <dsmotivo>".$strmotivo."</dsmotivo>";
		$xmlInclusao .= "    <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
		$xmlInclusao .= " </Dados>";
		$xmlInclusao .= "</Root>";
		
		$xmlResultInc = mensageria($xmlInclusao, "CHQSIN", $strnomacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["nmoperad"], "</Root>");
		$xmlObjInc = getObjectXML($xmlResultInc);
		
		if(strtoupper($xmlObjInc->roottag->tags[0]->name == 'ERRO')){
			$msgErro = $xmlObjInc->roottag->tags[0]->cdata;
			if($msgErro == ""){
				$msgErro = $xmlObjInc->roottag->tags[0]->tags[0]->tags[4]->cdata;
			}
			exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
		} else{
			$msgOK = "Cheque com Sinistro inclu&iacute;do com sucesso!";
			exibirErro('inform',$msgOK,'Alerta - Ayllos','unblockBackground();hideMsgAguardo();',false);
		}
	}else{
		// Cheques fora
		$strnomacao = 'INSERE_CHQSIN_FORA';
		$xmlInclusao  = "";
		$xmlInclusao .= "<Root>";
		$xmlInclusao .= " <Dados>";
		$xmlInclusao .= "    <cdbccxlt>".$intcodconta."</cdbccxlt>";
		$xmlInclusao .= "    <cdagectl>".$intcodagenc."</cdagectl>";
		$xmlInclusao .= "    <nrctachq>".$intcodchequ."</nrctachq>";
		$xmlInclusao .= "    <nrchqini>".$nrchqini."</nrchqini>";
		$xmlInclusao .= "    <nrchqfim>".$nrchqfim."</nrchqfim>";
		$xmlInclusao .= "    <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
		$xmlInclusao .= " </Dados>";
		$xmlInclusao .= "</Root>";
		
		$xmlResultInc = mensageria($xmlInclusao, "CHQSIN", $strnomacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["nmoperad"], "</Root>");
		$xmlObjInc = getObjectXML($xmlResultInc);
		
		if(strtoupper($xmlObjInc->roottag->tags[0]->name == 'ERRO')){
			$msgErro = $xmlObjInc->roottag->tags[0]->cdata;
			if($msgErro == ""){
				$msgErro = $xmlObjInc->roottag->tags[0]->tags[0]->tags[4]->cdata;
			}
			exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
		} else{
			$msgOK = "Cheque com Sinistro inclu&iacute;do com sucesso!";
			exibirErro('inform',$msgOK,'Alerta - Ayllos','unblockBackground();hideMsgAguardo();',false);
		}
	}
}
?>