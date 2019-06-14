/*****************************************************************************************
 Fonte: repext.js                                                   
 Autor: Mateus Zimmermann - Mouts
 Data : Abril/2018             					   Última Alteração:         
                                                                  
 Objetivo  : Biblioteca de funções da tela REPEXT
                                                                  
 Alterações:  
						  
******************************************************************************************/


$(document).ready(function() {

	estadoInicial();
			
});

function estadoInicial() {
	
	formataCabecalho();
	$('#frmFiltro').css('display','none');
	$('#divTabela').html('');
	$('#divBotoesFiltro').css('display','none');
	$('#divBotoesIncluir').css('display','none');
	$('#cddopcao','#frmCabRepext').habilitaCampo().focus().val('C');
	
	layoutPadrao();
				
}

function formataCabecalho(){

	$('label[for="cddopcao"]','#frmCabRepext').css('width','40px').addClass('rotulo');
	$('#cddopcao','#frmCabRepext').css('width','610px');
	$('#divTela').css({'display':'block'}).fadeTo(0,0.1);
	removeOpacidade('divTela');		
	$('#frmCabRepext').css('display','block');
		
	highlightObjFocus( $('#frmCabRepext') );
	
	//Ao pressionar botao cddopcao
	$('#cddopcao','#frmCabRepext').unbind('keypress').bind('keypress', function(e){
    
		$('input,select').removeClass('campoErro');
			
		// Se é a tecla ENTER, TAB
		if(e.keyCode == 13 || e.keyCode == 9){
			
			$('#btOK','#frmCabRepext').click();
			$(this).desabilitaCampo();			
			
			return false;						
			
		}
						
	});
	
	//Ao clicar no botao OK
	$('#btOK','#frmCabRepext').unbind('click').bind('click', function(){
		
		if ( $('#cddopcao','#frmCabRepext').hasClass('campoTelaSemBorda')  ) { return false; }
		
		$('#cddopcao','#frmCabRepext').desabilitaCampo();		
		$(this).unbind('click');
		
		if ($('#cddopcao','#frmCabRepext').val() == 'D' || $('#cddopcao','#frmCabRepext').val() == 'P') {
			controlaOperacao();
		} else {
			formataFiltro();
		}
								
	});
	
	$('#cddopcao','#frmCabRepext').focus();	
    
	return false;
	
}

function formataFiltro(){

	highlightObjFocus( $('#frmFiltro') );
	$('#fsetFiltro').css({'border-bottom':'1px solid #777'});	
	
	$('input, select','#frmFiltro').val('').removeAttr('tabindex');;
	
	//Label do frmFiltro
	var rDtinicio     = $('label[for="dtinicio"]','#frmFiltro');
	var rDtfinal      = $('label[for="dtfinal"]','#frmFiltro');
	var rInsituacao   = $('label[for="insituacao"]','#frmFiltro');
	var rInreportavel = $('label[for="inreportavel"]','#frmFiltro');
	var rNrcpfcgc     = $('label[for="nrcpfcgc"]','#frmFiltro');
	
	rDtinicio.addClass("rotulo").css('width','100px');
	rDtfinal.addClass("rotulo-linha").css('width','20px');
	rInsituacao.addClass("rotulo-linha").css('width','60px');
	rInreportavel.addClass("rotulo-linha").css('width','70px');
	rNrcpfcgc.addClass("rotulo").css('width','100px');
	  
	//Campos do frmFiltro
	var cDtinicio     = $('#dtinicio','#frmFiltro');
	var cDtfinal      = $('#dtfinal','#frmFiltro');
	var cInsituacao   = $('#insituacao','#frmFiltro');
	var cInreportavel = $('#inreportavel','#frmFiltro');
	var cNrcpfcgc     = $('#nrcpfcgc','#frmFiltro');
	var cNmpessoa     = $('#nmpessoa','#frmFiltro');

    cDtinicio.css({'width':'80px'}).addClass('data').habilitaCampo();
    cDtfinal.css({'width':'80px'}).addClass('data').habilitaCampo();
    cInsituacao.css({'width':'120px'}).habilitaCampo();
    cInreportavel.css({'width':'120px'}).habilitaCampo();
    cNrcpfcgc.css({'width':'130px'}).habilitaCampo();
    cNmpessoa.css({'width':'418px'}).addClass('alphanum').desabilitaCampo();
		
	// Percorrendo todos os links
    $('input, select', '#frmFiltro').each(function () {
		
		//Define ação para o campo
		$(this).unbind('keypress').bind('keypress', function (e) {

			$('input,select').removeClass('campoErro');
			
			if (divError.css('display') == 'block') { return false; }

			// Se é a tecla ENTER, TAB
			if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {
				
				$(this).nextAll('.campo:first').focus();

				return false;
			}
			
		});
		
	});

	$('#frmFiltro').css('display','block');
	$('#divBotoesFiltro').css('display','block');
	
	controlaPesquisas();
	
	layoutPadrao();
	
	return false;
	
}

function controlaPesquisas() {

	// Variável local para guardar o elemento anterior
    var campoAnterior = '';
    //var nomeForm = 'frmFiltro';
	
    /*-------------------------------------*/
    /*       CONTROLE DAS PESQUISAS        */
    /*-------------------------------------*/

    // Atribui a classe lupa para os links e desabilita todos
    $('a', '#frmFiltro').addClass('lupa').css('cursor', 'auto');

    // Percorrendo todos os links
    $('a', '#frmFiltro').each(function () {
	
		if (!$(this).prev().hasClass('campoTelaSemBorda')) { $(this).css('cursor', 'pointer'); }
		
        $(this).unbind("click").bind("click", (function () {
			
            if ($(this).prev().hasClass('campoTelaSemBorda')) {
				
                return false;
				
            } else {
				
                campoAnterior = $(this).prev().attr('name');
				
				// nrcpfcgc
                if (campoAnterior == 'nrcpfcgc') {
					
					var filtrosPesq = "CPF;nrcpfcgc;100px;S;0|Nome;nmpessoa;200px;S;";
                    var colunas = 'CPF;nrcpfcgc;25%;right|Nome;nmpessoa;75%;left';
                    mostraPesquisa("TELA_REPEXT", "BUSCA_PESSOAS_REPORTAVEIS", "Pessoa", "30", filtrosPesq, colunas, '','','frmFiltro');
                    
					return false;
                }

            }
            
        }));
    });

    // Atribui a classe lupa para os links e desabilita todos
    $('a', '#frmAlterarCompliance').addClass('lupa').css('cursor', 'auto');

    // Percorrendo todos os links
    $('a', '#frmAlterarCompliance').each(function () {
	
		if (!$(this).prev().hasClass('campoTelaSemBorda')) { $(this).css('cursor', 'pointer'); }
		
        $(this).unbind("click").bind("click", (function () {
			
            if ($(this).prev().hasClass('campoTelaSemBorda')) {
				
                return false;
				
            } else {
				
                campoAnterior = $(this).prev().attr('name');
				
				// cdtipo_declarado
                if (campoAnterior == 'cdtipo_declarado') {
					
					var filtrosPesq = "Código;cdtipo_declarado;100px;S;|Descrição;dstipo_declarado;200px;S;|Tipo;idtipo_dominio;100px;S;D|Situação;insituacao;100px;S;A";
                    var colunas = 'Código;cdtipo_dominio;25%;right|Descrição;dstipo_dominio;75%;left';
                    mostraPesquisa("TELA_REPEXT", "BUSCA_DOMINIO_TIPO", "Tipo Declarado", "30", filtrosPesq, colunas, '','','frmAlterarCompliance');

                    // esconder os campos e labels tipo e situacao da tela de pesquisa
                    $('label[for="idtipo_dominioPesquisa"]','#formPesquisa').css('display','none');
                    $('#idtipo_dominioPesquisa', '#formPesquisa').css('display','none');
                    $('label[for="insituacaoPesquisa"]','#formPesquisa').css('display','none');
                    $('#insituacaoPesquisa', '#formPesquisa').css('display','none');
                    
					return false;

				// cdtipo_proprietario	
                } else if (campoAnterior == 'cdtipo_proprietario') {
					
					var filtrosPesq = "Código;cdtipo_proprietario;100px;S;|Descrição;dstipo_proprietario;200px;S;|Tipo;idtipo_dominio;100px;S;P|Situação;insituacao;100px;S;A";
                    var colunas = 'CPF;cdtipo_dominio;25%;right|Descrição;dstipo_dominio;75%;left';
                    mostraPesquisa("TELA_REPEXT", "BUSCA_DOMINIO_TIPO", "Tipo Proprietario", "30", filtrosPesq, colunas, '','','frmAlterarCompliance');
                    
                    // esconder os campos e labels tipo e situacao da tela de pesquisa
                    $('label[for="idtipo_dominioPesquisa"]','#formPesquisa').css('display','none');
                    $('#idtipo_dominioPesquisa', '#formPesquisa').css('display','none');
                    $('label[for="insituacaoPesquisa"]','#formPesquisa').css('display','none');
                    $('#insituacaoPesquisa', '#formPesquisa').css('display','none');

					return false;
                }
            }            
        }));
    });

    /*-------------------------------------*/
    /*   CONTROLE DA BUSCA DESCRIÇÕES      */
    /*-------------------------------------*/

	// filtro nrcpfcgc
    $('#nrcpfcgc','#frmFiltro').unbind('blur').bind('blur', function(e) {
		buscaDescricao("TELA_REPEXT", "VALIDA_PESSOA", "Pessoa", $(this).attr('name'), 'nmpessoa', normalizaNumero($(this).val()), 'nmpessoa', '', 'frmFiltro');
		return false;
	});

	// tipo declarado
    $('#cdtipo_declarado','#frmAlterarCompliance').unbind('blur').bind('blur', function(e) {
		buscaDescricao("TELA_REPEXT", "VALIDA_TIPO_DECLARADO", "Tipo Declarado", $(this).attr('name'), 'dstipo_declarado', $(this).val().toUpperCase(), 'dstipo_dominio', '', 'frmAlterarCompliance');
		validaTipoDeclarado(2);
		return false;
	});

	// tipo proprietario
    $('#cdtipo_proprietario','#frmAlterarCompliance').unbind('blur').bind('blur', function(e) {
		buscaDescricao("TELA_REPEXT", "VALIDA_TIPO_PROPRIETARIO", "Tipo Proprietario", $(this).attr('name'), 'dstipo_proprietario', $(this).val().toUpperCase(), 'dstipo_dominio', '', 'frmAlterarCompliance');
		return false;
	});
	
}

function formataCompliance(){

	highlightObjFocus( $('#frmDetalhes') );
	$('#fsetDetalhes').css({'border-bottom':'1px solid #777'});	
	
	$('input','#frmDetalhes').val('');
	
	//Label do frmDetalhes
	var rDsnacion = $('label[for="dsnacion"]','#frmDetalhes');
	var rCdpais   = $('label[for="cdpais"]','#frmDetalhes');
	var rNmpais   = $('label[for="nmpais"]','#frmDetalhes');
	var rInacordo = $('label[for="inacordo"]','#frmDetalhes');
	var rDtinicio = $('label[for="dtinicio"]','#frmDetalhes');
	var rDtfinal  = $('label[for="dtfinal"]','#frmDetalhes');	
	
	rDsnacion.addClass("rotulo").css('width','100px');
	rCdpais.addClass("rotulo").css('width','100px');
	rNmpais.addClass("rotulo-linha").css('width','100px');
	rInacordo.addClass("rotulo").css('width','100px');
	rDtinicio.addClass("rotulo-linha").css('width','93px');
	rDtfinal.addClass("rotulo-linha").css('width','70px');
  
	//Campos do frmDetalhes
	var cDsnacion = $('#dsnacion','#frmDetalhes');	
	var cCdpais   = $('#cdpais','#frmDetalhes');
	var cNmpais   = $('#nmpais','#frmDetalhes');
	var cInacordo = $('#inacordo','#frmDetalhes');
	var cDtinicio = $('#dtinicio','#frmDetalhes');
	var cDtfinal  = $('#dtfinal','#frmDetalhes');
  
    cDsnacion.css({'width':'400px'}).addClass('alphanum').attr('maxlength','25').habilitaCampo();
    cCdpais.css({'width':'33px'}).addClass('alphanum').habilitaCampo();
    cNmpais.css({'width':'364px', 'text-transform': 'uppercase'}).habilitaCampo();
    cInacordo.css({'width':'75px'}).habilitaCampo();
    cDtinicio.css({'width':'75px'}).addClass('data').habilitaCampo();
    cDtfinal.css({'width':'75px'}).addClass('data').habilitaCampo();
		
	// Percorrendo todos os links
    $('input, select', '#frmDetalhes').each(function () {
		
		//Define ação para o campo
		$(this).unbind('keypress').bind('keypress', function (e) {

			$('input,select').removeClass('campoErro');
			
			if (divError.css('display') == 'block') { return false; }

			// Se é a tecla ENTER, TAB
			if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {
				
				$(this).nextAll('.campo:first').focus();

				return false;
			}
			
		});
		
	});
	
	$('#divBotoesFiltro').css('display','none');
	$('#frmDetalhes').css('display','block');
	$('#divBotoesCompliance').css('display','block');
	$('input, select','#frmFiltro').desabilitaCampo();
	layoutPadrao();
	
	$('#dsnacion','#frmDetalhes').focus();
	
	return false;
	
}

function buscarDadosCompliance(nriniseq,nrregist){	

	var cddopcao     = $('#cddopcao','#frmCabRepext').val();
	var nrcpfcgc     = $('#nrcpfcgc','#frmFiltro').val();
	var dtinicio     = $('#dtinicio','#frmFiltro').val();
	var dtfinal      = $('#dtfinal','#frmFiltro').val();
	var insituacao   = $('#insituacao','#frmFiltro').val();
	var inreportavel = $('#inreportavel','#frmFiltro').val();

	nrcpfcgc = normalizaNumero(nrcpfcgc);
	nrcpfcgc = (nrcpfcgc != '' && nrcpfcgc != 0) ? nrcpfcgc : '';
		
	showMsgAguardo( "Aguarde, buscando compliances..." );
	
    //Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/repext/buscar_dados_compliance.php", 
        data: {
			cddopcao     : cddopcao,
			nrcpfcgc     : nrcpfcgc,       
			dtinicio     : dtinicio,      
			dtfinal      : dtfinal,       
			insituacao   : insituacao,    
			inreportavel : inreportavel,
			nrregist     : nrregist,
			nriniseq     : nriniseq,
			redirect     : "script_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#cddopcao','#frmCab').focus();");
        },
        success: function(response) {
            hideMsgAguardo();
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divTabela').html(response);
					return false;
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();estadoInicial();');
				}
			} else {
				try {
					eval( response );						
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();estadoInicial();');
				}
			}
		}
    });
    return false;
	
}

function excluirNacionalidade(){
	
	var cddopcao = $('#cddopcao','#frmCabRepext').val();
	var cdnacion = $('#cdnacion','#frmFiltro').val();
	
	showMsgAguardo( "Aguarde, excluíndo nacionalidade..." );
	
    //Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/repext/excluir_nacionalidades.php", 
        data: {
			cddopcao: cddopcao,
			cdnacion: cdnacion,
            redirect: "script_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#cdnacion','#frmFiltro').focus();");
        },
        success: function(response) {
			try {
				eval(response);				
			} 
			catch (error) {
				showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#cdnacion','#frmFiltro').focus();");
			}
		}
    });
    return false;
	
	
}

function formataTabelaCompliance(){
	
	var divRegistro = $('div.divRegistros', '#divTabela');
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );

    divRegistro.css({ 'height': '150px', 'width' : '100%'});
	$('#divRegistrosRodape','#divTabela').formataRodapePesquisa();	
		
	var ordemInicial = new Array();

	var arrayLargura = new Array();
    arrayLargura[0] = '300px';
    arrayLargura[1] = '120px';
    arrayLargura[2] = '75px';
    arrayLargura[3] = '70px';
	
    var arrayAlinha = new Array();
	arrayAlinha[0] = 'left';
	arrayAlinha[1] = 'center';
	arrayAlinha[2] = 'center';
	arrayAlinha[3] = 'center';
	arrayAlinha[4] = 'center';
	
	var metodoTabela = '';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela);
	
	$('table > tbody > tr', divRegistro).each( function(i) {
		
		if ( $(this).hasClass( 'corSelecao' ) ) {
		
			selecionaCompliance($(this));
	
			var intem_socio = $('#intem_socio', $(this) ).val();

			if (intem_socio == 'N') {
				$('#btSocios', '#divBotoesCompliance').css('display','none');
			} else if (intem_socio == 'S') {
				$('#btSocios', '#divBotoesCompliance').css('display','');
			}			
		}		
	});	
	
	//seleciona a cooperado que é clicado
	$('table > tbody > tr', divRegistro).click( function() {
		
		selecionaCompliance($(this));

		var intem_socio = $('#intem_socio', $(this) ).val();

		if (intem_socio == 'N') {
			$('#btSocios', '#divBotoesCompliance').css('display','none');
		} else if (intem_socio == 'S') {
			$('#btSocios', '#divBotoesCompliance').css('display','');
		}		
	});
	
	$('#divTabela').css('display','block');
	$('#frmCompliance').css('display','block');
	
	return false;
	
}

function selecionaCompliance(tr){

	var nrCPFCooperadoSelecionado = $('#nrcpfcgc', tr ).val();

	nrCPF = normalizaNumero(nrCPFCooperadoSelecionado);

	buscarDadosFatcaCrs(nrCPF);
	buscarDadosContas(nrCPF);

	return false;
	
}

function controlaOperacao(){
	
	var cddopcao = $('#cddopcao','#frmCabRepext').val();
	
	switch(cddopcao){
		
		case 'C':
		
			buscarDadosCompliance(1,30);
							
		break;		
		
		case 'D':
		
			buscarTipoDeclarado(1,30);
		
		break;
		
		case 'P':
		
			buscarTipoProprietario(1,30);
		
		break;
		
		
	};
	
	return false;
	
}

function controlaVoltar(op){
	
	
	switch(op){
		
		case '1':
		
			estadoInicial();
			
		break;
		
		case '2':
		
			$('#divTabela').css('display','none');
			formataFiltro();
		
		break;
		
		
	};
	
	return false;
	
}

function buscarDadosContas(nrcpf,nriniseq,nrregist){
		
	var nrcpfcgc = nrcpf;
		
	showMsgAguardo( "Aguarde, buscando dados contas..." );
	
    //Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/repext/buscar_dados_contas.php", 
        data: {
			nrcpfcgc : nrcpfcgc,       
			nrregist : nrregist,
			nriniseq : nriniseq,
			redirect : "script_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#cddopcao','#frmCab').focus();");
        },
        success: function(response) {
            hideMsgAguardo();
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divDadosContas').html(response);
					return false;
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();estadoInicial();');
				}
			} else {
				try {
					eval( response );						
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();estadoInicial();');
				}
			}
		}
    });
    return false;
	
}

function buscarDadosFatcaCrs(nrcpf){
		
	var nrcpfcgc = nrcpf;
		
	showMsgAguardo( "Aguarde, buscando dados contas..." );
	
    //Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/repext/buscar_dados_fatca_crs.php", 
        data: {
			nrcpfcgc : nrcpfcgc,       
			redirect : "script_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#cddopcao','#frmCab').focus();");
        },
        success: function(response) {
            hideMsgAguardo();
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divDadosFatcaCrs').html(response);
					return false;
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();estadoInicial();');
				}
			} else {
				try {
					eval( response );						
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();estadoInicial();');
				}
			}
		}
    });
    return false;
	
}

function formataTabelaContas(){
	
	var divRegistro = $('#divTabelaContas', '#divTabela');
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );

    divRegistro.css({ 'height': '150px', 'width' : '100%'});
	$('#divRegistrosRodape','#divTabela').formataRodapePesquisa();	
		
	var ordemInicial = new Array();

	var arrayLargura = new Array();
    arrayLargura[0] = '160px';
    arrayLargura[1] = '40px';
    arrayLargura[2] = '90px';
    arrayLargura[3] = '200px';
    arrayLargura[4] = '70px';
	
    var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'center';
	arrayAlinha[2] = 'center';
	arrayAlinha[3] = 'center';
	arrayAlinha[4] = 'center';
	arrayAlinha[5] = 'center';
	
	var metodoTabela = '';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

	$('#frmContas').css('display','block');
	
	return false;
	
}

function formataFatcaCrs(){

	highlightObjFocus( $('#frmFatcaCrs') );
	$('#fsetFatcaCrs').css({'margin-bottom':'2px','border-bottom':'1px solid #777'});
	
	//Label do frmFatcaCrs
	var rInacordo        = $('label[for="inacordo"]','#frmFatcaCrs');
	var rDtinicio        = $('label[for="dtinicio"]','#frmFatcaCrs');
	var rDtfinal         = $('label[for="dtfinal"]','#frmFatcaCrs');
	var rCdpais          = $('label[for="cdpais"]','#frmFatcaCrs');
	var rNmpais          = $('label[for="nmpais"]','#frmFatcaCrs');
	var rNridentificacao = $('label[for="nridentificacao"]','#frmFatcaCrs');
	var rCdpais_exterior = $('label[for="cdpais_exterior"]','#frmFatcaCrs');
	var rNmpais_exterior = $('label[for="nmpais_exterior"]','#frmFatcaCrs');
	
	rInacordo.addClass("rotulo").css('width','100px');
	rDtinicio.addClass("rotulo-linha").css('width','70px');
	rDtfinal.addClass("rotulo-linha").css('width','70px');
	rCdpais.addClass("rotulo").css('width','285px');
	rNridentificacao.addClass("rotulo").css('width','50px');
	rCdpais_exterior.addClass("rotulo-linha").css('width','100px');
  
	//Campos do frmFatcaCrs
	var cInacordo        = $('#inacordo','#frmFatcaCrs');
	var cDtinicio        = $('#dtinicio','#frmFatcaCrs');
	var cDtfinal         = $('#dtfinal','#frmFatcaCrs');
	var cCdpais          = $('#cdpais','#frmFatcaCrs');
	var cNmpais          = $('#nmpais','#frmFatcaCrs');
	var cNridentificacao = $('#nridentificacao','#frmFatcaCrs');
	var cCdpais_exterior = $('#cdpais_exterior','#frmFatcaCrs');
	var cNmpais_exterior = $('#nmpais_exterior','#frmFatcaCrs');

	var cTodos = $('input', '#frmFatcaCrs');
  	
  	cInacordo.css({'width':'257px'});
  	cDtinicio.css({'width':'75px'}).addClass('data');
    cDtfinal.css({'width':'75px'}).addClass('data');
    cCdpais.css({'width':'40px'}).addClass('alphanum');
    cNmpais.css({'width':'331px', 'text-transform': 'uppercase'});
    cNridentificacao.css({'width':'129px'});
    cCdpais_exterior.css({'width':'40px'}).addClass('alphanum');
    cNmpais_exterior.css({'width':'331px', 'text-transform': 'uppercase'});

    cTodos.desabilitaCampo();
	
	$('#frmFatcaCrs').css('display','block');
	layoutPadrao();
	
	return false;
	
}

function buscarTipoDeclarado(nriniseq,nrregist){
		
	showMsgAguardo( "Aguarde, buscando tipos declarado..." );
	
    //Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/repext/buscar_tipo_declarado.php", 
        data: {
			nrregist : nrregist,
			nriniseq : nriniseq,
			redirect : "script_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#cddopcao','#frmCab').focus();");
        },
        success: function(response) {
            hideMsgAguardo();
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divTabela').html(response);
					return false;
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();estadoInicial();');
				}
			} else {
				try {
					eval( response );						
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();estadoInicial();');
				}
			}
		}
    });
    return false;
	
}

function buscarTipoProprietario(nriniseq,nrregist){
		
	showMsgAguardo( "Aguarde, buscando tipos proprietario..." );
	
    //Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/repext/buscar_tipo_proprietario.php", 
        data: {
			nrregist : nrregist,
			nriniseq : nriniseq,
			redirect : "script_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#cddopcao','#frmCab').focus();");
        },
        success: function(response) {
            hideMsgAguardo();
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divTabela').html(response);
					return false;
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();estadoInicial();');
				}
			} else {
				try {
					eval( response );						
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();estadoInicial();');
				}
			}
		}
    });
    return false;
	
}

function formataTabelaTipoDeclarado(){
	
	var divRegistro = $('div.divRegistros', '#divTabela');
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );

    divRegistro.css({ 'height': '150px', 'width' : '100%'});
	$('#divRegistrosRodape','#divTabela').formataRodapePesquisa();	
		
	var ordemInicial = new Array();

	var arrayLargura = new Array();
    arrayLargura[0] = '170px';
    arrayLargura[1] = '170px';
    arrayLargura[2] = '170px';

    var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'left';
	arrayAlinha[2] = 'center';
	arrayAlinha[3] = 'center';
	
	var metodoTabela = '';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela);
	
	$('#divTabela').css('display','block');
	
	return false;
	
}

function formataTabelaTipoProprietario(){
	
	var divRegistro = $('div.divRegistros', '#divTabela');
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );

    divRegistro.css({ 'height': '150px', 'width' : '100%'});
	$('#divRegistrosRodape','#divTabela').formataRodapePesquisa();	
		
	var ordemInicial = new Array();

	var arrayLargura = new Array();
    arrayLargura[0] = '240px';
    arrayLargura[1] = '240px';
	
    var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'left';
	arrayAlinha[2] = 'center';
	
	var metodoTabela = '';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

	$('#divTabela').css('display','block');
	
	return false;
	
}

function mostraFormTipoProprietario( op ) {
	
	showMsgAguardo('Aguarde, abrindo formulario ...');

	var cdtipo_dominio = '';
	var dstipo_dominio = '';
	var insituacao     = '';
	var cddopcao       = op;

	// caso seja alteração, pegar os dados do registro selecionado
	if (op == 'A') {

		if ( $('table > tbody > tr', 'div.divRegistros').hasClass('corSelecao') ) {
					
			$('table > tbody > tr', 'div.divRegistros').each( function() {
				if ( $(this).hasClass('corSelecao') ) {
					 
					cdtipo_dominio = $('#cdtipo_dominio', $(this) ).val();
					dstipo_dominio = $('#dstipo_dominio', $(this) ).val();
					insituacao     = $('#insituacao', $(this) ).val();
				}
			});
		}
	}

	$('#divRotina').html('');
	
	// Executa script de confirmação através de ajax
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/repext/form_tipo_proprietario.php', 
		data	: {	
			        cddopcao       : cddopcao,
					cdtipo_dominio : cdtipo_dominio,
				    dstipo_dominio : dstipo_dominio,
					insituacao     : insituacao,  
					redirect: 'html_ajax'
		}, 
		error	: function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success	: function(response) {
			$('#divRotina').html(response);
			formataFormTipoProprietario(cddopcao);
			return false;
		}
	});
	return false;
	
}

function formataFormTipoProprietario(cddopcao) {

	rCdtipo_dominio = $('label[for="cdtipo_dominio"]', '#frmTipoProprietario');
	rInsituacao     = $('label[for="insituacao"]', '#frmTipoProprietario');
	rDstipo_dominio = $('label[for="dstipo_dominio"]', '#frmTipoProprietario');
	
	rCdtipo_dominio.addClass('rotulo').css({'width':'80px'});
	rInsituacao.addClass('rotulo-linha').css({'width':'73px'});
	rDstipo_dominio.addClass('rotulo').css({'width':'80px'});
	
	cCdtipo_dominio = $('#cdtipo_dominio','#frmTipoProprietario');
	cInsituacao     = $('#insituacao','#frmTipoProprietario');
	cDstipo_dominio = $('#dstipo_dominio','#frmTipoProprietario');

	cTodos = $('input, select','#frmTipoProprietario');
	
	cCdtipo_dominio.css({'width':'150px'}).addClass('alphanum');
	cInsituacao.css({'width':'120px'});
	cDstipo_dominio.css({'width':'350px'}).addClass('alphanum');
	
	$('#divRotina').css({'width':'500px'});
	$('#divConteudo').css({'width':'500px'});
	
	cTodos.habilitaCampo();

	if (cddopcao == 'A') {
		cCdtipo_dominio.desabilitaCampo();
	}
	
	hideMsgAguardo();
	layoutPadrao();
	bloqueiaFundo( $('#divRotina') );
	exibeRotina( $('#divRotina') );	
	return false;
}

function manterRotina( operacao ) {
		
	hideMsgAguardo();		
	
	if (operacao == 'IP' || operacao == 'AP') {
		var frmNome = 'frmTipoProprietario';
	} else if (operacao == 'ID' || operacao == 'AD') {
		var frmNome = 'frmTipoDeclarado';
	} else if (operacao == 'AC') {
		var frmNome = 'frmAlterarCompliance';
	}

	var mensagem = '';

	var idtipo_dominio = '';
	var inoperacao     = '';


	switch(operacao) {
		case 'ID': 
			mensagem       = 'Aguarde, inserindo dados tipo declarado ...';
			idtipo_dominio = 'D';
			inoperacao     = 'I';
			cddopcao       = 'D';
			break;
		case 'IP': 
			mensagem = 'Aguarde, inserindo dados tipo proprietario ...'; 	
			idtipo_dominio = 'P';
			inoperacao     = 'I';
			cddopcao       = 'P';
			break;
		case 'AD': 
			mensagem = 'Aguarde, alterando dados tipo declarado ...';
			idtipo_dominio = 'D';
			inoperacao     = 'A';
			cddopcao       = 'D';
			break;
		case 'AP': 
			mensagem = 'Aguarde, alterando dados tipo proprietario ...';
			idtipo_dominio = 'P';
			inoperacao     = 'A';
			cddopcao       = 'P';
			break;
		case 'AC': 
			mensagem = 'Aguarde, alterando dados compliance ...';
			inoperacao     = 'A';
			cddopcao       = 'C';
			break;	
		default: 
			return false; 
			break;
	}

	var cdtipo_dominio       = $('#cdtipo_dominio','#'+frmNome).val();
	var insituacao           = $('#insituacao','#'+frmNome).val();
	var dstipo_dominio       = $('#dstipo_dominio','#'+frmNome).val();
	var inexige_proprietario = $('#inexige_proprietario','#'+frmNome).val();

	var nrcpfcgc            = $('#nrcpfcgc','#'+frmNome).val();
	var inreportavel        = $('#inreportavel','#'+frmNome).val();
	var cdtipo_declarado    = $('#cdtipo_declarado','#'+frmNome).val();
	var cdtipo_proprietario = $('#cdtipo_proprietario','#'+frmNome).val();
	var dsjustificativa     = $('#dsjustificativa','#'+frmNome).val();

	nrcpfcgc = normalizaNumero(nrcpfcgc);

	showMsgAguardo( mensagem );	
	
	$.ajax({		
			type  : 'POST',
			url   : UrlSite + 'telas/repext/manter_rotina.php',
			data: {
				cddopcao             : cddopcao,
				operacao	         : operacao,
				idtipo_dominio       : idtipo_dominio,
				inoperacao           : inoperacao,
				cdtipo_dominio       : cdtipo_dominio,
				insituacao           : insituacao,
				dstipo_dominio       : dstipo_dominio,
				inexige_proprietario : inexige_proprietario,
				nrcpfcgc             : nrcpfcgc,
				inreportavel         : inreportavel,
				cdtipo_declarado     : cdtipo_declarado,
				cdtipo_proprietario  : cdtipo_proprietario,
				dsjustificativa      : dsjustificativa,
				redirect	         : 'script_ajax'
			}, 
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','fechaRotina($("#divRotina"));');
			},
			success: function(response) {
				try {
					eval(response);
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','fechaRotina($("#divRotina"));');
				}
			}
		});

	return false;	
	                     
}

function mostraFormTipoDeclarado( op ) {
	
	showMsgAguardo('Aguarde, abrindo formulario ...');

	var cdtipo_dominio       = '';
	var dstipo_dominio       = '';
	var insituacao           = '';
	var inexige_proprietario = '';
	var cddopcao             = op;

	// caso seja alteração, pegar os dados do registro selecionado
	if (op == 'A') {

		if ( $('table > tbody > tr', 'div.divRegistros').hasClass('corSelecao') ) {
					
			$('table > tbody > tr', 'div.divRegistros').each( function() {
				if ( $(this).hasClass('corSelecao') ) {
					 
					cdtipo_dominio       = $('#cdtipo_dominio', $(this) ).val();
					dstipo_dominio       = $('#dstipo_dominio', $(this) ).val();
					insituacao           = $('#insituacao', $(this) ).val();
					inexige_proprietario = $('#inexige_proprietario', $(this) ).val();
				}
			});
		}
	}

	$('#divRotina').html('');
	
	// Executa script de confirmação através de ajax
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/repext/form_tipo_declarado.php', 
		data	: {	
			        cddopcao             : cddopcao,
					cdtipo_dominio       : cdtipo_dominio,
				    dstipo_dominio       : dstipo_dominio,
					insituacao           : insituacao,
					inexige_proprietario : inexige_proprietario,
					redirect: 'html_ajax'
		}, 
		error	: function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success	: function(response) {
			$('#divRotina').html(response);
			formataFormTipoDeclarado(cddopcao);
			return false;
		}
	});
	return false;
	
}

function formataFormTipoDeclarado(cddopcao) {

	rCdtipo_dominio       = $('label[for="cdtipo_dominio"]', '#frmTipoDeclarado');
	rInexige_proprietario = $('label[for="inexige_proprietario"]', '#frmTipoDeclarado');
	rInsituacao           = $('label[for="insituacao"]', '#frmTipoDeclarado');
	rDstipo_dominio       = $('label[for="dstipo_dominio"]', '#frmTipoDeclarado');	
	
	
	rCdtipo_dominio.addClass('rotulo').css({'width':'70px'});
	rInexige_proprietario.addClass('rotulo-linha').css({'width':'110px'});
	rInsituacao.addClass('rotulo-linha').css({'width':'60px'});
	rDstipo_dominio.addClass('rotulo').css({'width':'70px'});
	
	cCdtipo_dominio       = $('#cdtipo_dominio','#frmTipoDeclarado');
	cInexige_proprietario = $('#inexige_proprietario','#frmTipoDeclarado');
	cInsituacao           = $('#insituacao','#frmTipoDeclarado');
	cDstipo_dominio       = $('#dstipo_dominio','#frmTipoDeclarado');

	cTodos = $('input, select','#frmTipoDeclarado');
	
	cCdtipo_dominio.css({'width':'100px'}).addClass('alphanum');
	cInexige_proprietario.css({'width':'60px'});
	cInsituacao.css({'width':'60px'});
	cDstipo_dominio.css({'width':'402px'}).addClass('alphanum');	
	
	$('#divRotina').css({'width':'500px'});
	$('#divConteudo').css({'width':'500px'});
	
	cTodos.habilitaCampo();

	if (cddopcao == 'A') {
		cCdtipo_dominio.desabilitaCampo();
	}
	
	hideMsgAguardo();
	layoutPadrao();
	bloqueiaFundo( $('#divRotina') );
	exibeRotina( $('#divRotina') );	
	return false;
}

function mostraFormCompliance() {
	
	showMsgAguardo('Aguarde, abrindo formulario ...');

	var cdtipo_dominio       = '';
	var dstipo_dominio       = '';
	var insituacao           = '';
	var inexige_proprietario = '';

	if ( $('table > tbody > tr', '#frmCompliance').hasClass('corSelecao') ) {
				
		$('table > tbody > tr', '#frmCompliance').each( function() {
			if ( $(this).hasClass('corSelecao') ) {

				nrcpfcgc            = $('#nrcpfcgc', $(this) ).val(); 
				inreportavel        = $('#inreportavel', $(this) ).val();
				cdtipo_declarado    = $('#cdtipo_declarado', $(this) ).val();
				dstipo_declarado    = $('#dstipo_declarado', $(this) ).val();
				cdtipo_proprietario = $('#cdtipo_proprietario', $(this) ).val();
				dstipo_proprietario = $('#dstipo_proprietario', $(this) ).val();
				dsjustificativa     = $('#dsjustificativa', $(this) ).val();
			}
		});
	}

	$('#divRotina').html('');
	
	// Executa script de confirmação através de ajax
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/repext/form_compliance.php', 
		data	: {	
					nrcpfcgc            : nrcpfcgc,
				    inreportavel        : inreportavel,
					cdtipo_declarado    : cdtipo_declarado,
					dstipo_declarado    : dstipo_declarado,
					cdtipo_proprietario : cdtipo_proprietario,
					dstipo_proprietario : dstipo_proprietario,
					dsjustificativa     : dsjustificativa,                         
					redirect            : 'html_ajax'
		}, 
		error	: function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success	: function(response) {
			$('#divRotina').html(response);
			formataFormCompliance();
			return false;
		}
	});
	return false;
	
}

function formataFormCompliance() {

	rInreportavel        = $('label[for="inreportavel"]', '#frmAlterarCompliance');
	rCdtipo_declarado    = $('label[for="cdtipo_declarado"]', '#frmAlterarCompliance');
	rCdtipo_proprietario = $('label[for="cdtipo_proprietario"]', '#frmAlterarCompliance');
	rDsjustificativa     = $('label[for="dsjustificativa"]', '#frmAlterarCompliance');
	
	rInreportavel.addClass('rotulo').css({'width':'110px'});
	rCdtipo_declarado.addClass('rotulo').css({'width':'110px'});
	rCdtipo_proprietario.addClass('rotulo').css({'width':'110px'});
	rDsjustificativa.addClass('rotulo').css({'width':'110px'});
	
	cInreportavel        = $('#inreportavel','#frmAlterarCompliance');
	cCdtipo_declarado    = $('#cdtipo_declarado','#frmAlterarCompliance');
	cDstipo_declarado    = $('#dstipo_declarado','#frmAlterarCompliance');
	cCdtipo_proprietario = $('#cdtipo_proprietario','#frmAlterarCompliance');
	cDstipo_proprietario = $('#dstipo_proprietario','#frmAlterarCompliance');
	cDsjustificativa     = $('#dsjustificativa','#frmAlterarCompliance');

	cTodos = $('input, textarea, select','#frmAlterarCompliance');
	
	cInreportavel.css({'width':'100px'});
	cCdtipo_declarado.addClass('alphanum').css({'width':'100px'});
	cDstipo_declarado.css({'width':'250px'});
	cCdtipo_proprietario.addClass('alphanum').css({'width':'100px'});
	cDstipo_proprietario.css({'width':'250px'});
	cDsjustificativa.addClass('alphanum').css({'width':'370px', 'height':'60px', 'resize':'none', 'text-transform':'uppercase'});
	
	$('#divRotina').css({'width':'500px'});
	$('#divConteudo').css({'width':'500px'});
	
	cTodos.habilitaCampo();

	cDstipo_declarado.desabilitaCampo();   
	cDstipo_proprietario.desabilitaCampo();
	
	hideMsgAguardo();
	validaTipoDeclarado(1);
	controlaPesquisas();
	layoutPadrao();
	bloqueiaFundo( $('#divRotina') );
	exibeRotina( $('#divRotina') );	
	return false;
}

function buscarSocios(nriniseq,nrregist){

	if ( $('table > tbody > tr', '#frmCompliance').hasClass('corSelecao') ) {
				
		$('table > tbody > tr', '#frmCompliance').each( function() {
			if ( $(this).hasClass('corSelecao') ) {

				nrcpfcgc = $('#nrcpfcgc', $(this) ).val(); 
				nmpessoa = $('#nmpessoa', $(this) ).val();
			}
		});
	}

	nrcpfcgc = normalizaNumero(nrcpfcgc);
		
	showMsgAguardo( "Aguarde, buscando socios..." );

	$('#divRotina').html('');
	
    //Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/repext/buscar_socios.php", 
        data: {
			nrcpfcgc : nrcpfcgc,
			nmpessoa : nmpessoa,
			nrregist : nrregist,
			nriniseq : nriniseq,
			redirect : "script_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#cddopcao','#frmCab').focus();");
        },
        success: function(response) {
            hideMsgAguardo();
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divRotina').html(response);
					return false;
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();estadoInicial();');
				}
			} else {
				try {
					eval( response );						
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();estadoInicial();');
				}
			}
		}
    });
    return false;
	
}

function formataFormSocios() {

	rNrcpfcgc       = $('label[for="nrcpfcgc"]','#frmSocios');
	rCdtipo_dominio = $('label[for="cdtipo_dominio"]', '#frmSocios');
	rInsituacao     = $('label[for="insituacao"]', '#frmSocios');
	rDstipo_dominio = $('label[for="dstipo_dominio"]', '#frmSocios');
	
	rNrcpfcgc.addClass("rotulo").css('width','100px');
	rCdtipo_dominio.addClass('rotulo').css({'width':'80px'});
	rInsituacao.addClass('rotulo-linha').css({'width':'73px'});
	rDstipo_dominio.addClass('rotulo').css({'width':'80px'});	
	
	cNrcpfcgc       = $('#nrcpfcgc','#frmSocios');
	cNmpessoa       = $('#nmpessoa','#frmSocios');
	cCdtipo_dominio = $('#cdtipo_dominio','#frmSocios');
	cInsituacao     = $('#insituacao','#frmSocios');
	cDstipo_dominio = $('#dstipo_dominio','#frmSocios');
	
	cNrcpfcgc.css({'width':'130px'}).addClass('cpf');
	cNmpessoa.css({'width':'400px'}).addClass('alphanum');
	cCdtipo_dominio.css({'width':'150px'});
	cInsituacao.css({'width':'120px'});
	cDstipo_dominio.css({'width':'350px'});

	cTodos = $('input','#frmSocios');
	
	$('#divRotina').css({'width':'700px'});
	$('#divConteudo').css({'width':'700px'});
	
	cTodos.desabilitaCampo();
	
	hideMsgAguardo();
	bloqueiaFundo( $('#divRotina') );
	exibeRotina( $('#divRotina') );	
	return false;
}

function formataTabelaSocios(){
	
	var divRegistro = $('div.divRegistros', '#divRotina');
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );

    divRegistro.css({ 'height': '150px', 'width' : '100%'});
	$('#divRegistrosRodape','#divTabela').formataRodapePesquisa();	
		
	var ordemInicial = new Array();

	var arrayLargura = new Array();
    arrayLargura[0] = '300px';
    arrayLargura[1] = '90px';
    arrayLargura[2] = '100px';
    arrayLargura[3] = '75px';
	
    var arrayAlinha = new Array();
	arrayAlinha[0] = 'left';
	arrayAlinha[1] = 'center';
	arrayAlinha[2] = 'center';
	arrayAlinha[3] = 'center';
	arrayAlinha[4] = 'center';
	
	var metodoTabela = '';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela);
	
	$('table > tbody > tr', divRegistro).each( function(i) {
		
		if ( $(this).hasClass( 'corSelecao' ) ) {
		
			selecionaSocio($(this));
			
		}	
		
	});	
	
	//seleciona o socio que é clicado
	$('table > tbody > tr', divRegistro).click( function() {
		
		selecionaSocio($(this));
		
	});
	
	$('#frmSocios').css('display','block');
	
	return false;
	
}

function selecionaSocio(tr){

	var socioSelecionado = $('#nrcpfcgc_socio', tr ).val();

	buscarDadosSocio(socioSelecionado);
	
	return false;
	
}

function buscarDadosSocio(nrcpf){
		
	var nrcpfcgc = normalizaNumero(nrcpf);
		
	showMsgAguardo( "Aguarde, buscando dados socio..." );
	
    //Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/repext/buscar_dados_socio.php", 
        data: {
			nrcpfcgc : nrcpfcgc,
			redirect : "script_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#cddopcao','#frmCab').focus();");
        },
        success: function(response) {
            hideMsgAguardo();
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divDadosSocio').html(response);
					return false;
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();estadoInicial();');
				}
			} else {
				try {
					eval( response );						
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();estadoInicial();');
				}
			}
		}
    });
    return false;
	
}

function formataDadosSocio(){

	highlightObjFocus( $('#frmDadosSocio') );
	$('#fsetDadosSocio').css({'border-bottom':'1px solid #777'});	
	
	//Label do frmDadosSocio
	var rCdpais          = $('label[for="cdpais"]','#frmDadosSocio');
	var rNmpais          = $('label[for="nmpais"]','#frmDadosSocio');
	var rNridentificacao = $('label[for="nridentificacao"]','#frmDadosSocio');
	var rInacordo        = $('label[for="inacordo"]','#frmDadosSocio');
	
	rCdpais.addClass("rotulo").css('width','335px');
	rNridentificacao.addClass("rotulo").css('width','100px');
	rInacordo.addClass("rotulo-linha").css('width','85px');
  
	//Campos do frmDadosSocio
	var cCdpais          = $('#cdpais','#frmDadosSocio');
	var cNmpais          = $('#nmpais','#frmDadosSocio');
	var cNridentificacao = $('#nridentificacao','#frmDadosSocio');
	var cInacordo        = $('#inacordo','#frmDadosSocio');

	var cTodos = $('input', '#frmDadosSocio');
    	
    cCdpais.css({'width':'33px'}).addClass('alphanum');
    cNmpais.css({'width':'211px', 'text-transform': 'uppercase'});
    cNridentificacao.css({'width':'180px'});
    cInacordo.css({'width':'211px'});

    cTodos.desabilitaCampo();
	
	$('#frmDadosSocio').css('display','block');
	layoutPadrao();
	bloqueiaFundo( $('#divRotina') );
	
	return false;
	
}

function buscarLogAlteracoes(flgSocio){

	if (flgSocio == 'S') {
		if ( $('table > tbody > tr', '#frmSocios').hasClass('corSelecao') ) {
					
			$('table > tbody > tr', '#frmSocios').each( function() {
				if ( $(this).hasClass('corSelecao') ) {

					nrcpfcgc = $('#nrcpfcgc_socio', $(this) ).val(); 
				}
			});
		}
	} else if (flgSocio == 'N') {
		if ( $('table > tbody > tr', '#frmCompliance').hasClass('corSelecao') ) {
					
			$('table > tbody > tr', '#frmCompliance').each( function() {
				if ( $(this).hasClass('corSelecao') ) {

					nrcpfcgc = $('#nrcpfcgc', $(this) ).val(); 
				}
			});
		}
	}

	nrcpfcgc = normalizaNumero(nrcpfcgc);
		
	showMsgAguardo( "Aguarde, buscando o log de alteracoes..." );

	$('#divRotina').html('');
	
    //Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/repext/buscar_log_alteracoes.php", 
        data: {
			nrcpfcgc     : nrcpfcgc,
			redirect     : "script_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#cddopcao','#frmCab').focus();");
        },
        success: function(response) {
            hideMsgAguardo();
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divRotina').html(response);
					return false;
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();estadoInicial();');
				}
			} else {
				try {
					eval( response );						
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();estadoInicial();');
				}
			}
		}
    });
    return false;
	
}

function formataLogAlteracoes() {
	
	divRegistros = $('div.divRegistros', '#formLogAlteracoes' );
	
	divRegistros.css({'height':'335px','padding-bottom':'2px'});
	
	var rDtaltera   = $('label[for="dtaltera"]',divRegistros);
	var rTpaltera	= $('label[for="tpaltera"]',divRegistros);
	var	rNmoperad   = $('label[for="nmoperad"]',divRegistros);
		
	rDtaltera.addClass('rotulo').css({'width':'30px'});
	rTpaltera.addClass('rotulo-linha').css({'padding-left': '35px'});
	rNmoperad.addClass('rotulo-linha').css({'padding-left': '35px'});

	var cDtaltera = $('#dtaltera',divRegistros);
	var cTpaltera = $('#tpaltera',divRegistros);
	var cNmoperad = $('#nmoperad',divRegistros);
	var cDsaltera = $('#dsaltera',divRegistros);
	
	cDtaltera.css({'width':'80px'}).desabilitaCampo();
	cTpaltera.css({'width':'25px'}).desabilitaCampo();
	cNmoperad.css({'width':'300px'}).desabilitaCampo();
	cDsaltera.desabilitaCampo();

	$('#divRotina').css({'width':'720px'});
	$('#divConteudo').css({'width':'720px'});

	hideMsgAguardo();
	bloqueiaFundo( $('#divRotina') );
	exibeRotina( $('#divRotina') );	
	return false;
}

function dossieDigidoc(flgSocio) {

	showMsgAguardo('Aguarde...');

	GEDServidor = $('#gedservidor', '#frmCompliance').val();

	var form = (flgSocio == 'S') ? '#frmSocios' : '#frmCompliance';

	if ( $('table > tbody > tr', form).hasClass('corSelecao') ) {

		$('table > tbody > tr', form).each( function() {
			if ( $(this).hasClass('corSelecao') ) {

				var cdcooper = $('#cdcooper', $(this)).val().replace(/^0+/, '');
				var nrdconta = 0;
				var nrcpfcgc = 0;

				if(flgSocio == 'S'){
					nrdconta = $('#nrdconta', $(this) ).val();
					nrcpfcgc = $('#nrcpfcgc_socio', $(this)).val();
				} else {
					nrcpfcgc = $('#nrcpfcgc', $(this)).val();

					$('table > tbody > tr', '#frmContas').each( function() {
						if ( $(this).hasClass('corSelecao')) {
							nrdconta = $('#nrdconta', $(this)).val();
							nrdconta = normalizaNumero(nrdconta);
						}
					});
				}

				// Executa script de confirmação através de ajax
				$.ajax({
					type: 'POST',
					dataType: 'html',
					url: UrlSite + 'telas/repext/dossie_digidoc.php',
					data: {
						cdcooper: cdcooper,
					    nrcpfcgc: nrcpfcgc,
					    nrdconta: nrdconta,
					    redirect: 'html_ajax'
					},
					error: function(objAjax,responseError,objExcept) {
						hideMsgAguardo();

						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',"unblockBackground()");
					},
					success: function(response) {
						hideMsgAguardo();
						$('#divRotina').html(response);
						exibeRotina($('#divRotina'));
					    $('#divRotina').css({'margin-top': '170px'});
					    $('#divRotina').css({'width': '400px'});
					    $('#divRotina').centralizaRotinaH();
						bloqueiaFundo( $('#divRotina') );			
					    layoutPadrao();

						return false;
					}				
				});
			}
		});
	}
}

function validaTipoDeclarado(op){

	var cdtipo_declarado = $('#cdtipo_declarado','#frmAlterarCompliance').val();
	
	// Executa script de através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/repext/valida_tipo_declarado.php', 
		data: {
			cdtipo_declarado: cdtipo_declarado,
			redirect: "html_ajax"
		},  
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			try {
                hideMsgAguardo();
                eval(response);

                var inexige_proprietario = $('#inexige_proprietario','#frmAlterarCompliance').val();

                if (inexige_proprietario == 'N') {
                	cCdtipo_proprietario.val('');
                	cDstipo_proprietario.val('');
					cCdtipo_proprietario.desabilitaCampo();
					// Controle de foco dependendo se estiver acessando a tela ou alterando o campo
					if (op == 1) {
						cInreportavel.focus();
					} else if (op == 2) {
						cDsjustificativa.focus();
					}
                } else {
                	cCdtipo_proprietario.habilitaCampo();
                	// Controle de foco dependendo se estiver acessando a tela ou alterando o campo
					if (op == 1) {
						cInreportavel.focus();
					} else if (op == 2) {
						cCdtipo_proprietario.focus();
					}
                }

            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#tpdrend2','#frmManipulaRendimentos').focus()");
            }	
		}				
	});	
}
