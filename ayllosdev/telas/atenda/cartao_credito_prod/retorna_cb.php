<?
/*!
 * FONTE        : altera_senha_cabal.php
 * CRIAÇÃO      : James Prust Júnior
 * DATA CRIAÇÃO : Junho/2014
 * OBJETIVO     : Altera senha do cartão com CHIP na CABAL
 * --------------
 * ALTERAÇÕES   : Oscar 14/11/2014 - Tratar estrutura TLV das Tags do cartao.
                  Oscar 20/11/2014 - Tratar estrutura TLV do Script de senha.  
				  James 01/12/2014 - Ajustar para retornar o script completo de alteracao de senha.
				  James 26/06/2015 - Ajuste no tratamento de erro.
 * --------------
 */
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	require_once('class_troca_senha_cabal.php');
	require_once('class_tags_emv_cartao.php');	

	isPostMethod();	
	
	if (!isset($_POST["data"]) || !isset($_POST["dataPin"])){
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro','bloqueiaFundo(divRotina);',false);		
	}

	$sTagData  = base64_decode($_POST['data']);
	$sPinBlock = base64_decode($_POST['dataPin']);
	$oTagsEmv  = new TagsEmvCartao($sTagData);
	
	$aParametros = array();
	$aParametros['amountAuthorized'] 		  	  = $oTagsEmv->getTagValueByTagName(Authorised_Amount);
	$aParametros['applicationCryptogram'] 		  = $oTagsEmv->getTagValueByTagName(Application_Cryptogram);
	$aParametros['applicationInterchangeProfile'] = $oTagsEmv->getTagValueByTagName(Application_Interchange_Profile);
	$aParametros['applicationTransactionCounter'] = $oTagsEmv->getTagValueByTagName(Transaction_Counter);
	$aParametros['cdol1'] 					      = $oTagsEmv->getTagValueByTagName(Card_Risk_Managment_Data_1);
	$aParametros['cryptogramInformation']         = $oTagsEmv->getTagValueByTagName(Cryptogram_Information_Data);
	$aParametros['dadosDaTransacao']              = $oTagsEmv->getTagValueByTagName(Card_Risk_Managment_Data_1);
	$aParametros['issuerApplicationData'] 	      = $oTagsEmv->getTagValueByTagName(Issuer_Application_Data);
	$aParametros['novoPinBlockCriptografado']     = strtoupper($sPinBlock);
	$aParametros['origem'] 						  = 'CECRED';
	$aParametros['panNumeroCartao'] 			  = $oTagsEmv->getTagValueByTagName(PAN_Number);
	$aParametros['panSequenceNumber'] 			  = $oTagsEmv->getTagValueByTagName(PAN_Sequence_Number);
	$aParametros['terminalCountryCode'] 		  = $oTagsEmv->getTagValueByTagName(Terminal_Country_Code);
	$aParametros['terminalVerificationResult']    = $oTagsEmv->getTagValueByTagName(Terminal_Verification_Results);
	$aParametros['transactionCurrencyCode'] 	  = $oTagsEmv->getTagValueByTagName(Transaction_Currency_Code);
	$aParametros['transactionDate'] 			  = $oTagsEmv->getTagValueByTagName(Transaction_Date);
	$aParametros['transactionType'] 			  = $oTagsEmv->getTagValueByTagName(Tranasction_Type);
	$aParametros['unpredictableNumber'] 		  = $oTagsEmv->getTagValueByTagName(Unpredictable_Number);
		

	$oTrocaSenhaCabal = new TrocaSenhaCabal();
	$oTrocaSenhaCabal->gerarScriptTrocaDeSenha($aParametros);
	
	// Melhorar a mensagem para informar se eh Alteracao de senha ou Confirmacao de senha, pois sera o mesmo
	switch($oTrocaSenhaCabal->getCodigoRetorno()){
		// Sucesso
		case 00: 
			echo "bRetorno = true; sTexto1 = '".$oTrocaSenhaCabal->getScriptTrocaDeSenha()."'; sIdentificadorTransacao = '".$oTrocaSenhaCabal->getIdentificadorTransacao()."';";
		break;
	
		default:
			echo "showErrorCartao('".$oTrocaSenhaCabal->getCodigoRetorno()." - Erro ao alterar senha.','bloqueiaFundo(divRotina);')";
		break;
	}
?>