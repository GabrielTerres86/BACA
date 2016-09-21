<? 
	ini_set('display_errors',1);
	ini_set('display_startup_erros',1);
	error_reporting(E_ALL);
	require_once("../../../includes/funcoes.php"); 
?>

<form action="teste_soap.php" method="post">
	<table width="100%" border="0">
		<tr>
			<td colspan="2" align="center"><h1>Testes SoapClient</h1><hr><br /></td>
		</tr>
		<tr>
			<td width="150px" align="right"><b>URL Soap:&nbsp;</b></td>
			<td><input type="text" id="urlSoap" name="urlSoap" size="100" value="https://cabalprod.cecred.coop.br/netservices/http/Credito/WSTrocaSenhaCartaoChip"></td>
		</tr>
		<tr>
			<td align="right"><b>Mostrar phpinfo:&nbsp;</b></td>
			<td>
				<select id="opcao" name="opcao">
					<option value="1">Não</option>
					<option value="2">Sim</option>					
				</select>
			</td>
		</tr>
		<tr>
			<td>&nbsp;</td>			
			<td><input type="submit" value="Testar"></td>			
		</tr>
		<tr>
			<td colspan="2" align="center"><br /><hr><h1>Resultado</h1></td>
		</tr>
	</table>
</form>

<?
if ((isset($_POST['opcao'])) && ($_POST['opcao'] != "")){
	if ($_POST['opcao'] == 2){
		echo phpinfo();
	}	
}

if ((isset($_POST['urlSoap'])) && ($_POST['urlSoap'] != "")){

	$aParametros = array();
	$aParametros['amountAuthorized'] 		  	  = '000000000000';
	$aParametros['applicationCryptogram'] 		  = '4F3551907228C666';
	$aParametros['applicationInterchangeProfile'] = '5800';
	$aParametros['applicationTransactionCounter'] = '001F';
	$aParametros['cdol1'] 					      = '1E9F02069F03069F1A0295055F2A029A039C019F37049F35019F45029F3403';
	$aParametros['cryptogramInformation']         = '80';
	$aParametros['dadosDaTransacao']              = $aParametros['cdol1'];
	$aParametros['issuerApplicationData'] 	      = '120010A00003220000000000000000000000FF';
	$aParametros['novoPinBlockCriptografado']     = '1026B1BBBCDA3889';
	$aParametros['origem'] 						  = 'CECRED';
	$aParametros['panNumeroCartao'] 			  = '5158940002620462';
	$aParametros['panSequenceNumber'] 			  = '01';
	$aParametros['terminalCountryCode'] 		  = '0076';
	$aParametros['terminalVerificationResult']    = '8080000000';
	$aParametros['transactionCurrencyCode'] 	  = '0986';
	$aParametros['transactionDate'] 			  = '140725';
	$aParametros['transactionType'] 			  = '00';
	$aParametros['unpredictableNumber'] 		  = '34587D51';

	try{
		echo "<b>Teste Normal:</b><br />";
		$sUrl = $_POST['urlSoap'];	
		$oSoapClient = new SoapClient($sUrl.'?wsdl');
		$oSoapClient->__setLocation($sUrl);	
		$oRetorno = $oSoapClient->gerarScriptTrocaSenha(array('voScriptTrocaDeSenha'=>$aParametros));
		echo "<b>Sucesso!!!!!<br/>Retorno:</b> ".$oRetorno->return;
		
		echo "<br /><br />";
		
		echo "<b>Teste Normal:</b><br />";
		$sUrl = $_POST['urlSoap'];
		$oSoapClient = new SoapClient($sUrl.'?wsdl');
		$oSoapClient->__setLocation($sUrl);
		$oRetorno = $oSoapClient->gerarScriptTrocaSenha(array('voScriptTrocaDeSenha'=>$aParametros));
		echo "<b>Sucesso!!!!!<br/>Retorno:</b> ".$oRetorno->return;	
		
		echo "<br /><br />";
		
		echo "<b>Teste Class:</b><br />";
		require_once('class_troca_senha_cabal.php');		
		$oTrocaSenhaCabal = new TrocaSenhaCabal();
		$oTrocaSenhaCabal->gerarScriptTrocaDeSenha($aParametros);
		echo "<b>Sucesso!!!!!<br/>Retorno:</b> ".$oTrocaSenhaCabal->getRetorno();
		
	}catch(SoapFault $e){
		echo "<b>Erro ao conectar:</b> ".$e->faultstring;
	}
}
?>