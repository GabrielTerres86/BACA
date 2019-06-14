<?
try{
	$oSoapClient = new SoapClient("https://cabalhomol.cecred.coop.br/netservices/http/Credito/WSTrocaSenhaCartaoChip?wsdl");	
}catch(SoapFault $e){
	echo $e->faultstring;
}	

echo "<br />";

try{
	$oSoapClient = new SoapClient("https://cabalprod.cecred.coop.br/netservices/http/Credito/WSTrocaSenhaCartaoChip?wsdl");	
}catch(SoapFault $e){
	echo $e->faultstring;
}	

echo "<br /><br />";
?>
<script>
var iContador = 1;
function testes(){
	var oLog 		    	 = document.getElementById('log');
	var oRetornoJson    	 = null;
	var bCheckCartaoInserido = true;
	var aTrack1				 = new Array();
	var oDate				 = new Date();
	var bPedirSenha			 = true;
	var bCheckSMC			 = true;
	iContador = 1;
	
	try{
		var oPinpad = new ActiveXObject("Gertec.PPC");
	}catch(e){
		return;
	}	
	
	/* Abre Porta */
	oRetornoJson = oPinpad.CloseSerial();
	imprimeLog(oLog, 'CloseSerial: ' + oRetornoJson);
	
	oRetornoJson = oPinpad.FindPort(2);
	imprimeLog(oLog, 'FindPort: ' + oRetornoJson);	
	
	oRetornoJson = oPinpad.OpenSerial('COM3');
	imprimeLog(oLog, 'OpenSerial: ' + oRetornoJson);	
	
	/*
	oRetornoJson = oPinpad.LCD_Clear();
	imprimeLog(oLog, 'LCD_Clear: ' + oRetornoJson);
	
	oRetornoJson = oPinpad.InitSMC(0);
	imprimeLog(oLog, 'InitSMC: ' + oRetornoJson);
	
	oRetornoJson = oPinpad.LCD_DisplayString(2,18,1,"Insira o cartao");
	imprimeLog(oLog, 'LCD_DisplayString: ' + oRetornoJson);
	
	var iCont = 0;
	while(bCheckSMC){
		oRetornoJson = oPinpad.CheckSMC(0);
		imprimeLog(oLog, 'CheckSMC: ' + oRetornoJson);		
		eval("oRetornoJson = " + oRetornoJson);		
		if ((oRetornoJson.bStatus == 1) || (iCont > 80)){
			// Acende o LED
			oPinpad.SetLED(1);
			bCheckSMC = false;
		}		
		iCont++;
	}
	
	oRetornoJson = oPinpad.LCD_Clear();
	imprimeLog(oLog, 'LCD_Clear: ' + oRetornoJson);
	
	oRetornoJson = oPinpad.LCD_DisplayString(2,18,1,"Processando...");
	imprimeLog(oLog, 'LCD_DisplayString: ' + oRetornoJson);	
	
	oRetornoJson = oPinpad.SMC_ReadTracks(0,"","");
	imprimeLog(oLog, 'SMC_ReadTracks: ' + oRetornoJson);		
	
	// Dados do Chip
	oRetornoJson = oPinpad.SMC_EMV_TagsGet(0,"5F20","");
	imprimeLog(oLog, 'SMC_EMV_TagsGet: ' + oRetornoJson);
	
	oRetornoJson = oPinpad.SMC_EMV_TagsGet(0,"5A","");
	imprimeLog(oLog, 'SMC_EMV_TagsGet: ' + oRetornoJson);
	
	oRetornoJson = oPinpad.SMC_EMV_TagsGet(0,"5F24","");
	imprimeLog(oLog, 'SMC_EMV_TagsGet: ' + oRetornoJson);
	
	oRetornoJson = oPinpad.SMC_EMV_AIDGet(0);
	imprimeLog(oLog, 'SMC_EMV_AIDGet: ' + oRetornoJson);	
	*/
	
	/*oRetornoJson = oPinpad.ChangeEMVCardPasswordStart('A0000000041010','5A5F349F269F279F109F379F36959A9C9F025F2A829F1A8C84');
	  oRetornoJson = oPinpad.ChangeEMVCardPasswordFinish(1,'68C05F0A9B8B68E3','5ED6DF578B362CFF'); 
	  imprimeLog(oLog, 'ChangeEMVCardPasswordFinish: ' + oRetornoJson);
	*/
	
	oRetornoJson = oPinpad.ChangeEMVCardPasswordStart('A0000000041010','5A');
	imprimeLog(oLog, 'ChangeEMVCardPasswordStart 5A: ' + oRetornoJson);
	oPinpad.ChangeEMVCardPasswordStop();
	
	oRetornoJson = oPinpad.ChangeEMVCardPasswordStart('A0000000041010','5F34');
	imprimeLog(oLog, 'ChangeEMVCardPasswordStart 5F34: ' + oRetornoJson);
	oPinpad.ChangeEMVCardPasswordStop();
	
	oRetornoJson = oPinpad.ChangeEMVCardPasswordStart('A0000000041010','9F26');
	imprimeLog(oLog, 'ChangeEMVCardPasswordStart 9F26: ' + oRetornoJson);
	oPinpad.ChangeEMVCardPasswordStop();
	
	oRetornoJson = oPinpad.ChangeEMVCardPasswordStart('A0000000041010','9F27');
	imprimeLog(oLog, 'ChangeEMVCardPasswordStart 9F27: ' + oRetornoJson);
	oPinpad.ChangeEMVCardPasswordStop();
	
	oRetornoJson = oPinpad.ChangeEMVCardPasswordStart('A0000000041010','9F10');
	imprimeLog(oLog, 'ChangeEMVCardPasswordStart 9F10: ' + oRetornoJson);
	oPinpad.ChangeEMVCardPasswordStop();
	
	oRetornoJson = oPinpad.ChangeEMVCardPasswordStart('A0000000041010','9F37');
	imprimeLog(oLog, 'ChangeEMVCardPasswordStart 9F37: ' + oRetornoJson);
	oPinpad.ChangeEMVCardPasswordStop();
	
	oRetornoJson = oPinpad.ChangeEMVCardPasswordStart('A0000000041010','9F36');
	imprimeLog(oLog, 'ChangeEMVCardPasswordStart 9F36: ' + oRetornoJson);
	oPinpad.ChangeEMVCardPasswordStop();
	
	oRetornoJson = oPinpad.ChangeEMVCardPasswordStart('A0000000041010','95');
	imprimeLog(oLog, 'ChangeEMVCardPasswordStart 95: ' + oRetornoJson);
	oPinpad.ChangeEMVCardPasswordStop();
	
	oRetornoJson = oPinpad.ChangeEMVCardPasswordStart('A0000000041010','9A');
	imprimeLog(oLog, 'ChangeEMVCardPasswordStart 9A: ' + oRetornoJson);
	oPinpad.ChangeEMVCardPasswordStop();
	
	oRetornoJson = oPinpad.ChangeEMVCardPasswordStart('A0000000041010','9C');
	imprimeLog(oLog, 'ChangeEMVCardPasswordStart 9C: ' + oRetornoJson);
	oPinpad.ChangeEMVCardPasswordStop();
	
	oRetornoJson = oPinpad.ChangeEMVCardPasswordStart('A0000000041010','9F02');
	imprimeLog(oLog, 'ChangeEMVCardPasswordStart 9F02: ' + oRetornoJson);
	oPinpad.ChangeEMVCardPasswordStop();
	
	oRetornoJson = oPinpad.ChangeEMVCardPasswordStart('A0000000041010','5F2A');
	imprimeLog(oLog, 'ChangeEMVCardPasswordStart 5F2A: ' + oRetornoJson);
	oPinpad.ChangeEMVCardPasswordStop();
	
	oRetornoJson = oPinpad.ChangeEMVCardPasswordStart('A0000000041010','82');
	imprimeLog(oLog, 'ChangeEMVCardPasswordStart 82: ' + oRetornoJson);
	oPinpad.ChangeEMVCardPasswordStop();
	
	oRetornoJson = oPinpad.ChangeEMVCardPasswordStart('A0000000041010','9F1A');
	imprimeLog(oLog, 'ChangeEMVCardPasswordStart 9F1A: ' + oRetornoJson);
	oPinpad.ChangeEMVCardPasswordStop();
	
	oRetornoJson = oPinpad.ChangeEMVCardPasswordStart('A0000000041010','8C');
	imprimeLog(oLog, 'ChangeEMVCardPasswordStart 8C: ' + oRetornoJson);
	oPinpad.ChangeEMVCardPasswordStop();
	
	oRetornoJson = oPinpad.ChangeEMVCardPasswordStart('A0000000041010','CD0L1');
	imprimeLog(oLog, 'ChangeEMVCardPasswordStart CD0L1: ' + oRetornoJson);
	oPinpad.ChangeEMVCardPasswordStop();
	
	oRetornoJson = oPinpad.ChangeEMVCardPasswordStart('A0000000041010','84');
	imprimeLog(oLog, 'ChangeEMVCardPasswordStart 84: ' + oRetornoJson);
	oPinpad.ChangeEMVCardPasswordStop();
	
	oRetornoJson = oPinpad.SetLED(0);
	imprimeLog(oLog, 'SetLED: ' + oRetornoJson);
	
	oRetornoJson = oPinpad.CloseSerial();	
	imprimeLog(oLog, 'CloseSerial: ' + oRetornoJson);
}

function testeMagnetico(){
	
	var oLog 		    	 = document.getElementById('log');
	var oRetornoJson    	 = null;
	var bCheckCartaoInserido = true;
	var aTrack1				 = new Array();
	var oDate				 = new Date();
	var bPassarCartao    	 = true;
	var bCheckSMC			 = true;
	iContador = 1;
	
	try{
		var oPinpad = new ActiveXObject("Gertec.PPC");
	}catch(e){
		return;
	}	
	
	try{
		/* Abre Porta */
		oRetornoJson = oPinpad.CloseSerial();
		imprimeLog(oLog, 'CloseSerial: ' + oRetornoJson);
		
		oRetornoJson = oPinpad.FindPort(2);
		imprimeLog(oLog, 'FindPort: ' + oRetornoJson);	
		
		oRetornoJson = oPinpad.OpenSerial('COM3');
		imprimeLog(oLog, 'OpenSerial: ' + oRetornoJson);	
		
		oRetornoJson = oPinpad.LCD_Clear();
		imprimeLog(oLog, 'LCD_Clear: ' + oRetornoJson);
		
		oRetornoJson = oPinpad.InitSMC(0);
		imprimeLog(oLog, 'InitSMC: ' + oRetornoJson);
		
		oRetornoJson = oPinpad.LCD_DisplayString(2,18,1,"Passe o cartao");
		imprimeLog(oLog, 'LCD_DisplayString: ' + oRetornoJson);
		
		oRetornoJson = oPinpad.ReadMagCard_Start(60);
		imprimeLog(oLog, 'ReadMagCard_Start: ' + oRetornoJson);
		
		while (bPassarCartao){
			oRetornoJson = oPinpad.ReadMagCard_Get();
			imprimeLog(oLog, 'ReadMagCard_Get: ' + oRetornoJson);
			
			eval("oRetornoJson = " + oRetornoJson);
			if (oRetornoJson.dwResult == 0){
				bPassarCartao = false;
			}else if ((oRetornoJson.dwResult == 1021) || (oRetornoJson.dwResult == 11054) || (oRetornoJson.dwResult == 1016)){
				throw { message: 'N&atilde;o foi poss&iacute;vel ler o cart&atilde;o, tente novamente.' };
			}
		}		
		
		oRetornoJson = oPinpad.CloseSerial();
		imprimeLog(oLog, 'CloseSerial: ' + oRetornoJson);
	}catch(e){
		oPinpad.CloseSerial();	
	}	
}

function testeJava(){

	var oLog 		    	 = document.getElementById('logJava');
	var oRetornoJson    	 = null;
	var bCheckCartaoInserido = true;
	var aTrack1				 = new Array();
	var oDate				 = new Date();
	var bPedirSenha			 = true;
	var oPinpad 			 = PPCjna;
	var bCheckSMC			 = true;
	iContador = 1; 
	
	/* Abre Porta */
	oRetornoJson = oPinpad.CloseSerial();
	imprimeLog(oLog, 'CloseSerial: ' + oRetornoJson);
	
	oRetornoJson = oPinpad.FindPort(2,10);
	imprimeLog(oLog, 'FindPort: ' + oRetornoJson);	
	
	oRetornoJson = oPinpad.OpenSerial(3);
	imprimeLog(oLog, 'OpenSerial: ' + oRetornoJson);	
	
	oRetornoJson = oPinpad.LCD_Clear();
	imprimeLog(oLog, 'LCD_Clear: ' + oRetornoJson);
	
	oRetornoJson = oPinpad.InitSMC(0);
	imprimeLog(oLog, 'InitSMC: ' + oRetornoJson);
	
	oRetornoJson = oPinpad.LCD_DisplayString(2,18,1,"Insira o cartao");
	imprimeLog(oLog, 'LCD_DisplayString: ' + oRetornoJson);
	
	var iCont = 0;
	while(bCheckSMC){
		oRetornoJson = oPinpad.CheckSMC(0);
		imprimeLog(oLog, 'CheckSMC: ' + oRetornoJson);		
		eval("oRetornoJson = " + oRetornoJson);		
		if ((oRetornoJson.bStatus == 1) || (iCont > 80)){
			// Acende o LED
			oPinpad.SetLED(1);
			bCheckSMC = false;
		}
		iCont++;
	}
	
	oRetornoJson = oPinpad.LCD_Clear();
	imprimeLog(oLog, 'LCD_Clear: ' + oRetornoJson);
	
	oRetornoJson = oPinpad.LCD_DisplayString(2,18,1,"Processando...");
	imprimeLog(oLog, 'LCD_DisplayString: ' + oRetornoJson);	
	
	oRetornoJson = oPinpad.SMC_ReadTracks(0,"","");
	imprimeLog(oLog, 'SMC_ReadTracks: ' + oRetornoJson);		
	
	oRetornoJson = oPinpad.SMC_EMV_TagsGet(0,"5F20","");
	imprimeLog(oLog, 'SMC_EMV_TagsGet: ' + oRetornoJson);
	
	oRetornoJson = oPinpad.SMC_EMV_TagsGet(0,"5A","");
	imprimeLog(oLog, 'SMC_EMV_TagsGet: ' + oRetornoJson);
	
	oRetornoJson = oPinpad.SMC_EMV_TagsGet(0,"5F24","");
	imprimeLog(oLog, 'SMC_EMV_TagsGet: ' + oRetornoJson);
	
	oRetornoJson = oPinpad.ChangeEMVCardPasswordStart('A0000000041010','5A5F349F269F279F109F379F36959A9C9F025F2A829F1A8C84');
	imprimeLog(oLog, 'ChangeEMVCardPasswordStart: ' + oRetornoJson);
	
	oRetornoJson = oPinpad.ChangeEMVCardPasswordFinish(1,'3A3F10D38CEDBA73','BBBBBBBBBBBBBBBB'); 
	imprimeLog(oLog, 'ChangeEMVCardPasswordFinish: ' + oRetornoJson);
	
	oRetornoJson = oPinpad.ChangeEMVCardPasswordStop();
	imprimeLog(oLog, 'ChangeEMVCardPasswordStop: ' + oRetornoJson);
	
	oRetornoJson = oPinpad.SetLED(0);
	imprimeLog(oLog, 'SetLED: ' + oRetornoJson);
	
	oRetornoJson = oPinpad.CloseSerial();	
	imprimeLog(oLog, 'CloseSerial: ' + oRetornoJson);
}

function testeMagneticoJava(){

	var oLog 		    	 = document.getElementById('logJava');
	var oRetornoJson    	 = null;
	var bCheckCartaoInserido = true;
	var aTrack1				 = new Array();
	var oDate				 = new Date();
	var bPassarCartao    	 = true;
	var bCheckSMC			 = true;
	iContador = 1;
	var oPinpad 			 = PPCjna;
	
	try{
		/* Abre Porta */
		oRetornoJson = oPinpad.CloseSerial();
		imprimeLog(oLog, 'CloseSerial: ' + oRetornoJson);
		
		oRetornoJson = oPinpad.FindPort(2,10);
		imprimeLog(oLog, 'FindPort: ' + oRetornoJson);	
		
		oRetornoJson = oPinpad.OpenSerial(3);
		imprimeLog(oLog, 'OpenSerial: ' + oRetornoJson);	
		
		oRetornoJson = oPinpad.LCD_Clear();
		imprimeLog(oLog, 'LCD_Clear: ' + oRetornoJson);
		
		oRetornoJson = oPinpad.InitSMC(0);
		imprimeLog(oLog, 'InitSMC: ' + oRetornoJson);
		
		oRetornoJson = oPinpad.LCD_DisplayString(2,18,1,"Passe o cartao");
		imprimeLog(oLog, 'LCD_DisplayString: ' + oRetornoJson);
		
		oRetornoJson = oPinpad.ReadMagCard_Start(60);
		imprimeLog(oLog, 'ReadMagCard_Start: ' + oRetornoJson);
		
		while (bPassarCartao){
			oRetornoJson = oPinpad.ReadMagCard_Get();
			imprimeLog(oLog, 'ReadMagCard_Get: ' + oRetornoJson);
			
			eval("oRetornoJson = " + oRetornoJson);
			if (oRetornoJson.dwResult == 0){
				bPassarCartao = false;
			}else if ((oRetornoJson.dwResult == 1021) || (oRetornoJson.dwResult == 11054) || (oRetornoJson.dwResult == 1016)){
				throw { message: 'N&atilde;o foi poss&iacute;vel ler o cart&atilde;o, tente novamente.' };
			}
		}		
		
		oRetornoJson = oPinpad.CloseSerial();
		imprimeLog(oLog, 'CloseSerial: ' + oRetornoJson);
	}catch(e){
		alert(e.message);
		oPinpad.CloseSerial();	
	}	
}

function fechaConexao(){
	var oPinpad = new ActiveXObject("Gertec.PPC");
	oPinpad.CloseSerial();
	oPinpad.OpenSerial('COM3');
	oPinpad.SetLED(0);
	oPinpad.CloseSerial();	
}

function imprimeLog(oLog,sTexto){	
	oLog.value += iContador + "º - Passo: " + sTexto + '\n';
	iContador++;
}

function testeJames(){

	$.ajax({
		type: "POST", 
		url: "retorna_cb.php",
		async:false,
		data: {
			redirect: "script_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			alert('Erro de requisicao');
		},
		success: function(response){
			eval(response);
		}
	});  
}

</script>
<script type="text/javascript" src="../../../scripts/jquery.js"></script>
<script type="text/javascript" src="../../../scripts/ui/jquery.ui.core.js"></script>
<script type="text/javascript" src="../../../scripts/ui/jquery.ui.datepicker.js"></script>
<script type="text/javascript" src="../../../scripts/ui/i18n/jquery.ui.datepicker-pt-BR.js"></script>
<script type="text/javascript" src="../../../scripts/funcoes.js"></script>

<input type="button" value="Ler Chip" onClick="testes()">
<input type="button" value="Ler Magnetico" onClick="testeMagnetico()">
<input type="button" value="Ler Chip Java" onClick="testeJava()">
<input type="button" value="Ler Magnetico Java" onClick="testeMagneticoJava()">
<input type="button" value="Testes James" onClick="testeJames()">
<input type="button" value="Fecha" 	  onClick="fechaConexao()">

<br /><br />
<b>Log PINPAD:</b>
<br />
<textarea style="width: 650px; height: 500px" id="log" name="log"></textarea>
<textarea style="width: 650px; height: 500px" id="logJava" name="logJava"></textarea>
<applet code="PPCjnaApplet.class" archive="ppcjna-assinado.jar" name="PPCjna" width="100" height="100"></applet>