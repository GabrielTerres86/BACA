<html>
<head>
	<script>
		var UrlSite = '';
	</script>
	<style>
		body{
			margin:0px;
		}
	</style>
	<script type="text/javascript" src="../../../scripts/jquery.js"></script>
	<script type="text/javascript" src="../../../scripts/ui/jquery.ui.core.js"></script>
	<script type="text/javascript" src="../../../scripts/ui/jquery.ui.datepicker.js"></script>
	<script type="text/javascript" src="../../../scripts/ui/i18n/jquery.ui.datepicker-pt-BR.js"></script>	
	<script type="text/javascript" src="cartao_credito.js"></script>
	
	<script>
		function base64_encode(data){
  
		  var b64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';
		  var o1, o2, o3, h1, h2, h3, h4, bits, i = 0,
			ac = 0,
			enc = '',
			tmp_arr = [];

		  if (!data) {
			return data;
		  }

		  do { // pack three octets into four hexets
			o1 = data.charCodeAt(i++);
			o2 = data.charCodeAt(i++);
			o3 = data.charCodeAt(i++);

			bits = o1 << 16 | o2 << 8 | o3;

			h1 = bits >> 18 & 0x3f;
			h2 = bits >> 12 & 0x3f;
			h3 = bits >> 6 & 0x3f;
			h4 = bits & 0x3f;

			// use hexets to index into b64, and append result to encoded string
			tmp_arr[ac++] = b64.charAt(h1) + b64.charAt(h2) + b64.charAt(h3) + b64.charAt(h4);
		  } while (i < data.length);

		  enc = tmp_arr.join('');

		  var r = data.length % 3;

		  return (r ? enc.slice(0, r - 3) : enc) + '==='.slice(r || 3);
		}

		var iContador 	  = 1;
		var iNumeroCartao = 0;
		var sWTexto3      = 0;
		var sSTexto1      = 0;
		var sNTexto4      = 0;
		var sAID		  = 0;
		var aOperacao     = new Array();	
		var sNumeroCartao = 0;
		var sIdentificadorTransacao = 0;
		
		onload = function(){		
			oLog = document.getElementById('log');
			
			try{
				oPinpad = new ActiveXObject("Gertec.PPC");
			}catch(e){
				alert("Acesse com o Internet Explorer");
				return;
			}
		}
		
		function imprimeLog(sTexto){
			oLog.value += iContador + "º - Passo: " + sTexto + '\n';
			iContador++;
		}
		
		function executar(){
			iNumeroCartao = document.getElementById('numeroCartao').value.substr(3,12);
			sNumeroCartao = document.getElementById('numeroCartao').value;
			
			var oScript = document.getElementById('script');
			oLog.value = '';			
			iContador = 1;
			eval(oScript.value);
		}
	</script>
</head>

<body>	
	<div>
		<br />
		<label>Número do cartão:</label>
		<input type="text" id="numeroCartao" name="numeroCartao" value="5161590000000020" />
		<input type="button" value="Executar" onClick="executar()" />
		<input type="button" value="Fechar Porta" onClick="fechaConexaoPinpad(oPinpad)" />
		<br /><br />
	</div>	
	<div style="width:100%;">
		<div style="float:left;width:50%;">
			<b>Troca de senha CHIP - Java Script</b>
			<br />
			<textarea style="height:100%;width:100%" id="script" name="script">
var aCabalAPP     = { CABAL_CREDIT: 'A0000004421010', CABAL_DEBIT: 'A0000004422010' };
			
eval(fechaConexaoPinpad(oPinpad));

oRetornoJson = oPinpad.FindPort(2);
/*imprimeLog('FindPort: ' + oRetornoJson);*/
eval("oRetornoJson = " + oRetornoJson);

oRetornoJson = oPinpad.OpenSerial('COM' + oRetornoJson.pbPort[0]);
/*imprimeLog('OpenSerial: ' + oRetornoJson);*/

oRetornoJson = oPinpad.InitSMC(0);
/*imprimeLog('InitSMC: ' + oRetornoJson);*/

oRetornoJson = oPinpad.ResetSMC(0);
/*imprimeLog('ResetSMC: ' + oRetornoJson);*/

oRetornoJson = oPinpad.LCD_Clear();
/*imprimeLog('LCD_Clear: ' + oRetornoJson);*/

$.ajax({type: "POST",
		url: "teste_retorna_ct.php",
		async:false,
		error: function(objAjax,responseError,objExcept) {
			alert('Nao foi possivel concluir sua requisicao')
		},
		success: function(response){
			eval("var oRetornoJson = " + response);
			
			sWTexto3 = oRetornoJson.retorno;
			/*imprimeLog('Working Key: ' + sWTexto3);*/
	  }});
	  
/* Solicita senha no Pinpad */
eval(document.getElementById('solicitaPin').value);

oRetornoJson = oPinpad.StopPINBlock();
/*imprimeLog('StopPINBlock: ' + oRetornoJson);*/

oRetornoJson = oPinpad.LCD_Clear();
/*imprimeLog('LCD_Clear: ' + oRetornoJson);*/

oRetornoJson = oPinpad.LCD_DisplayString(2,18,1,"Processando...");
/*imprimeLog('LCD_DisplayString: ' + oRetornoJson);*/

$.ajax({type: "POST", 
		url: "teste_retorna_pi.php",
		async:false,
		data: {
			dataPin: base64_encode(sSTexto1),
			dataWk:  base64_encode(sWTexto3),
			redirect: "script_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			alert('N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.');
		},
		success: function(response){
			/*imprimeLog('Senha: ' + response);*/
			eval("var oRetornoJson = " + response);
			
			if (parseInt(oRetornoJson.bErro)){
				alert(oRetornoJson.retorno);
			}						
			sNTexto4 = oRetornoJson.retorno;										
		}
	  });								  

// Vamos verificar se o cartao possui debito/credito
oRetornoJson = oPinpad.SMC_EMV_AIDGet(0);
imprimeLog('SMC_EMV_AIDGet: ' + oRetornoJson);
eval("oRetornoJson = " + oRetornoJson);

if (oRetornoJson.szAIDList.length == 0) {
  for (iAPP in aCabalAPP) {

    oRetornoJson = oPinpad.ResetSMC(0);
	/*imprimeLog('ResetSMC: ' + oRetornoJson);*/
	
   	/* Verificar as aplicações presentes no chip */
	oRetornoJson = oPinpad.SMC_EMV_TagsGet(0,"84", aCabalAPP[iAPP]);
	imprimeLog('SMC_EMV_TagsGet: ' + oRetornoJson);
	eval("oRetornoJson = " + oRetornoJson);

	if (oRetornoJson.dwResult == 0) {
		aOperacao.push(aCabalAPP[iAPP]);
	}
  }
} else {
   aOperacao = oRetornoJson.szAIDList.split(';');  							
}							

for (iAPP in aOperacao) {
	sAID = aOperacao[iAPP];
	eval(document.getElementById('alteraCartaoCabal').value);
}

eval(fechaConexaoPinpad(oPinpad));
			</textarea>
		</div>
		<div style="float:right;width:50%;">
			<b>Log</b>
			<br />
			<textarea style="height:100%;width:100%;" id="log" name="log"></textarea>		
		</div>
		
		<div style="float:left;width:100%;">
			<br />
			<b>Solicita Senha PINPAD</b>
			<br />
			<textarea style="height:470px;width:100%;" id='solicitaPin' name="solicitaPin">
var oRetornoJson = [];
var bPedirPI 	 = true;

oRetornoJson = oPinpad.StartPINBlock(4,4,0,0,300,4,2,1,'Informe a senha:',2," ",3," ",5," ");
/*imprimeLog('StartPINBlock: ' + oRetornoJson);*/

while (bPedirPI){
	oRetornoJson = oPinpad.GetPINBlock(1,0,2,sWTexto3,16,'0'.charCodeAt(0),0,iNumeroCartao,10,4,3," ",6," ");
	/*imprimeLog('GetPINBlock: ' + oRetornoJson);*/
	eval("oRetornoJson = " + oRetornoJson);
	
	if (oRetornoJson.dwResult == 11054){
		alert('Tempo para informar a senha ultrapassou o limite, tente novamente.');		
		
	}else if (oRetornoJson.dwResult == 11053){
		alert('Cooperado anulou a operac&atilde;o, informe a senha novamente.');				
	}
	
	if ((oRetornoJson.bPINStatus == 4) || (parseFloat(oRetornoJson.sEncDataBlk) == 0)){
		alert('Erro ao alterar a senha. Codigo: ' + oRetornoJson.dwResult);		
	}
	
	if (oRetornoJson.bPINStatus == 0){
		bPedirPI = false;
	}
}

sSTexto1 = oRetornoJson.sEncDataBlk;
/*imprimeLog('Senha PINPAD: ' + sSTexto1);*/
			</textarea>
		</div>
		
		<div style="float:left;width:100%;">
			<br />
			<b>Altera cartao CABAL</b>
			<br />
			<textarea style="height:100%;width:100%;" id='alteraCartaoCabal' name="alteraCartaoCabal">
var oRetornoJson 		    = [];
var sTexto1				    = '';
var bRetorno 	 		    = false;

oRetornoJson = oPinpad.ResetSMC(0);
/*imprimeLog('ResetSMC: ' + oRetornoJson);*/

var oRetornoJson = oPinpad.ChangeEMVCardPasswordStart(sAID,'9F029F26829F368C9F279F105A5F349F1A955F2A9A9C9F37');	
imprimeLog('ChangeEMVCardPasswordStart: ' + oRetornoJson);
eval("oRetornoJson = " + oRetornoJson);
if (oRetornoJson.dwResult != 0){
	alert('Erro ao iniciar o processo de altera&ccedil;&atilde;o de senha.');
}

$.ajax({
	type: "POST", 
	url: "teste_retorna_cb.php",
	async:false,
	data: {
		data: base64_encode(oRetornoJson.sData),
		dataPin: sNTexto4,
		redirect: "script_ajax"
	},
	error: function(objAjax,responseError,objExcept) {
		alert("N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.");
	},
	success: function(response){
		imprimeLog('Script: ' + response);
		eval(response);
		
		// Vamos verificar se estah carregado o script de alteracao de senha no PINPAD
		if (bRetorno){
			sTexto1 = prompt("Confirma o script?",sTexto1);
			oRetornoJson = oPinpad.FinishEMVCard(0,0,0,sTexto1,0);
			imprimeLog('FinishEMVCard: ' + oRetornoJson);

			/* Confirma senha na CABAL */
			eval(document.getElementById('confirmaSenhaCabal').value);
		}		
		
		oPinpad.ChangeEMVCardPasswordStop();		
	}
});
			</textarea>
		</div>	
		
		<div style="float:left;width:100%;">
			<br />
			<b>Confirma senha CABAL</b>
			<br />
			<textarea style="height:330px;width:100%;" id='confirmaSenhaCabal' name="confirmaSenhaCabal">
var bRetorno = false;

$.ajax({
	type: "POST", 
	url: "teste_retorna_co.php",
	async:false,
	data: {
		identificadorTransacao: sIdentificadorTransacao,
		numeroCartao: sNumeroCartao,
		redirect: "script_ajax"
	},
	error: function(objAjax,responseError,objExcept) {
		alert("N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.");		
	},
	success: function(response){
		imprimeLog('Retorno Confirmação de senha: ' + response);
		eval(response);
	}
});
			</textarea>
		</div>
			
	</div>
</body>
</html>