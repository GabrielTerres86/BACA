/***********************************************************************
      Fonte: lancamentos_futuros.js
      Autor: Guilherme
      Data : Fevereiro/2007                &Uacute;ltima Altera&ccedil;&atilde;o: 21/07/2015

      Objetivo  : Biblioteca de fun&ccedil;&otilde;es da rotina OCORRENCIAS da tela
                  ATENDA

      Altera&ccedil;&otilde;es:
              30/06/2011 - Alterado para layout padrão (Rogerius - DB1).		
 	  
	          21/07/2015 - Exclusao de lancamentos automaticos (Tiago).
 ***********************************************************************/
var glb_gen_dstabela, glb_gen_cdhistor, glb_gen_recid; 

// Fun&ccedil;&atilde;o para acessar op&ccedil;&otilde;es da rotina
function acessaOpcaoAba(nrOpcoes,id,opcao) {
	if (opcao == "0") {	// Op&ccedil;&atilde;o Principal
		var msg = "lan&ccedil;amentos futuros";
	}
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando " + msg + " ...");
	
	// Atribui cor de destaque para aba da op&ccedil;&atilde;o
	for (var i = 0; i < nrOpcoes; i++) {
		if (id == i) { // Atribui estilos para foco da op&ccedil;&atilde;o
			$("#linkAba" + id).attr("class","txtBrancoBold");
			$("#imgAbaEsq" + id).attr("src",UrlImagens + "background/mnu_sle.gif");				
			$("#imgAbaDir" + id).attr("src",UrlImagens + "background/mnu_sld.gif");
			$("#imgAbaCen" + id).css("background-color","#969FA9");
			continue;			
		}
		
		$("#linkAba" + i).attr("class","txtNormalBold");
		$("#imgAbaEsq" + i).attr("src",UrlImagens + "background/mnu_nle.gif");			
		$("#imgAbaDir" + i).attr("src",UrlImagens + "background/mnu_nld.gif");
		$("#imgAbaCen" + i).css("background-color","#C6C8CA");
	}	
	
	// Carrega conte&uacute;do da op&ccedil;&atilde;o atrav&eacute;s de ajax
	$.ajax({		
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/atenda/lancamentos_futuros/principal.php",
		data: {
			nrdconta: nrdconta,
			redirect: "html_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')) )");
		},
		success: function(response) {
			$("#divConteudoOpcao").html(response);
		}				
	}); 		
}

function controlaLayout() {

	// tabela	
	var divRegistro = $('div.divRegistros');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
	var btVoltar    = $('#btVoltar','#divBotoes');
	var btExcluir    = $('#btExcluir','#divBotoes');
	
	divRegistro.css({ 'height': '160px', 'width': '650px', 'overflow-y': 'auto' });
	
	var ordemInicial = new Array();
	ordemInicial = [[0,0]];
			
	var arrayLargura = new Array();
	arrayLargura[0] = '56px';
	arrayLargura[1] = '225px';
	arrayLargura[2] = '175px';
	arrayLargura[3] = '25px';
	
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'left';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'center';
	arrayAlinha[4] = 'right';
	
	var metodoTabela = 'metodtab();';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );
	
	$('table > tbody > tr', 'div.divRegistros').focus( function() {
		glb_gen_dstabela = $(this).find("#gen_dstabela").val();  		
		glb_gen_cdhistor = $(this).find("#gen_cdhistor").val(); 
		glb_gen_recid    = $(this).find("#gen_recid").val(); 
		
		if (glb_gen_recid == 0){
			btExcluir.hide();
		}else{
			btExcluir.show();
		}
		
	}); 
	
	/*Botoes*/
	btVoltar.unbind('click').bind('click',function() {
		encerraRotina(true);				
		return false;
	});

	btExcluir.unbind('click').bind('click',function() {
		confirmaExclusaoLanctoFut();
		return false;
	});	
	
	btExcluir.hide();
}

function selecionaLautom(objeto){
	var btExcluir    = $('#btExcluir','#divBotoes');
	glb_gen_dstabela = $(objeto).find("#gen_dstabela").val();  		
	glb_gen_cdhistor = $(objeto).find("#gen_cdhistor").val(); 
	glb_gen_recid    = $(objeto).find("#gen_recid").val(); 
	
	if (glb_gen_recid == 0){
		btExcluir.hide();
	}else{
		btExcluir.show();
	}		

}

function confirmaExclusaoLanctoFut(){
	showConfirmacao('Confirma a exclusao do lan&ccedil;amento?','Confirma&ccedil;&atilde;o - Ayllos','excluirLanctoFut();','','sim.gif','nao.gif');	
}

function excluirLanctoFut(){
	
	/* teste apos preencher a temptable na b1wgen0003.consulta-lancamento-periodo
	   descomentar esta linha para ver se esta carregando certo os parametros na
	   tela
	alert(" dstabela:" + glb_gen_dstabela + " cdhistor:" + glb_gen_cdhistor + " recid:" + glb_gen_recid);	*/	   
	
	showMsgAguardo("Aguarde, registro esta sendo excluido");
		
	$.ajax({		
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/atenda/lancamentos_futuros/excluir_lancamentos_futuros.php",
		data: {
			dstabela: glb_gen_dstabela,
			cdhistor: glb_gen_cdhistor,
			genrecid: glb_gen_recid,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {				
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});				
}
