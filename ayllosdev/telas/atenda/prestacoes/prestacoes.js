/************************************************************************
 Fonte: prestacoes.js                                              
 Autor: Lucas R                                                 
 Data : Maio/2013                �ltima Altera��o: //
																  
 Objetivo  : Biblioteca de fun��es da rotina de Prestacoes da tela 
			 ATENDA                                               
																	 
 Altera��es:
 
 ***********************************************************************/
 
 function CarregaCooperativa() {
 // Mostra mensagem de aguardo
	showMsgAguardo("Aguarde carregando dados de emprestimos da cooperativa ...");
	
	// Carrega biblioteca javascript da rotina
	// Ao carregar efetua chamada do conte�do da rotina atrav�s de ajax
	$.getScript(UrlSite + "telas/atenda/prestacoes/cooperativa/prestacoes.js",function() {
		$.ajax({		
			type: "POST", 
			dataType: "html",
			url: UrlSite + "telas/atenda/prestacoes/cooperativa/prestacoes.php",
			data: {
				nrdconta: nrdconta,
				nmdatela: 'ATENDA',
				redirect: "html_ajax"
			},		
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			},
			success: function(response) {
				hideMsgAguardo();
				$("#divRotina").html(response);
			}				
		}); 
	});			
	 
 }
 
 function CarregaBndes() {
 
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde carregando dados do BNDES ...");
	
	// Carrega biblioteca javascript da rotina
	// Ao carregar efetua chamada do conte�do da rotina atrav�s de ajax
	$.getScript(UrlSite + "telas/atenda/prestacoes/bndes/bndes.js",function() {
		$.ajax({		
			type: "POST", 
			dataType: "html",
			url: UrlSite + "telas/atenda/prestacoes/bndes/bndes.php",			
			data: {
				nrdconta: nrdconta,
				nmdatela: 'ATENDA',
				redirect: "html_ajax"
			},		
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			},
			success: function(response) {
				hideMsgAguardo();
				$("#divRotina").html(response);
			}				
		});
	});	
 }