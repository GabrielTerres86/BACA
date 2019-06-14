/*!
 * FONTE        : ficha_cadastral.js
 * CRIAÇÃO      : Gabriel
 * DATA CRIAÇÃO : 05/08/2011 
 * OBJETIVO     : Ficha cadastral igual ao da tela CONTAS
 * 
 * ALTERACOES	: 13/03/2012 - Alterado attr target (Jorge) 
 *				  02/07/2012 - Ajuste para novo esquema de impressao e retirado campo "redirect". (Jorge)
 */	 
 

 function imprimeFichaCadastral(idseqttl) {
	
	// Se não deu erro ao abrir a nova janela, então submete o formulário			
	$('#frmCabAtenda').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin','#frmMenu').val() + '" />');		
	$('#frmCabAtenda').append('<input type="hidden" id="tpregist" name="tpregist" value="' + inpessoa + '" />');	
	$('#frmCabAtenda').append('<input type="hidden" id="nrdconta" name="nrdconta" value="' + nrdconta + '" />');
	$('#frmCabAtenda').append('<input type="hidden" id="idseqttl" name="idseqttl" value="' + idseqttl + '" />');			
	
	var action = UrlSite + 'telas/contas/ficha_cadastral/imp_fichacadastral.php';
	
	idseqttl--;	
	var callafter = "";
	if (idseqttl > 0) {
		callafter = "showConfirmacao('H&aacute; mais um Titular, deseja imprimir?','Confirma&ccedil;&atilde;o - Aimaro','blockBackground(parseInt($(\"#divRotina\").css(\"z-index\")));imprimeFichaCadastral(" + idseqttl + ");','hideMsgAguardo();','sim.gif','nao.gif');";
	}else{
		callafter = "hideMsgAguardo();";
	}
	
	carregaImpressaoAyllos("frmCabAtenda",action,callafter);
	
}