/*!
 * FONTE        : pessoa.js
 * CRIAÇÃO      : André Bohn         
 * DATA CRIAÇÃO : 31/08/2018
 * OBJETIVO     : Biblioteca de funções da tela PESSOA
 * --------------
 * ALTERAÇÕES   : 
 *				  
 *				 1 - Desabilitar campo dtinicio_vigencia se flgvigencia em cdfuncao em Cargo/Funcao (incluir/Inativar)
 					 Bruno Luz K. (mouts) - 17/09/2018
 				 2 - Desabilitar campo dtinicio_vigencia se a primeira option inicial estiver com flgvigencia = 0
 				 	 Bruno Luiz K. (Mouts) - 19/09/2018
 * --------------
 */


$(document).ready(function () {

    estadoInicial();

});

function estadoInicial() {

    formataCabecalho();
        
    $('#cddopcao', '#frmCabPessoa').habilitaCampo().focus().val('M');
    $('#frmFiltro').css('display', 'none');
    $('#divFiltro').css('display', 'none');
    $('#divBotoesFiltro').css('display', 'none');
    $('#frmPessoa').css('display', 'none');
    $('#divPessoa').html('').css('display', 'none');

    layoutPadrao();

}

function formataCabecalho() {

    $('label[for="cddopcao"]', '#frmCabPessoa').css('width', '50px').addClass('rotulo');
    $('#cddopcao', '#frmCabPessoa').css('width', '610px');
    $('#divTela').fadeTo(0, 0.1);
    removeOpacidade('divTela');
    $('#frmCabPessoa').css('display', 'block');

    highlightObjFocus($('#frmCabPessoa'));
    $('#cddopcao', '#frmCabPessoa').focus();

    //Ao pressionar botao cddopcao
    $('#cddopcao', '#frmCabPessoa').unbind('keypress').bind('keypress', function (e) {

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $('#btOK', '#frmCabPessoa').click();
            return false;
        }

    });

    //Ao clicar no botao OK
    $('#btOK', '#frmCabPessoa').unbind('click').bind('click', function () {

		$('input,select').removeClass('campoErro');
		$('#cddopcao', '#frmCabPessoa').desabilitaCampo();
	
		apresentaFormFiltro();
		
    });

    //Ao pressionar botao OK
    $('#btOK', '#frmCabPessoa').unbind('keypress').bind('keypress', function (e) {

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {


            $('#btOK', '#frmCabPessoa').click();

			apresentaFormFiltro();            

        }

    });

    return false;

}

function apresentaFormFiltro() {   

    var cddopcao = $('#cddopcao', '#frmCabPessoa').val();
	
	$.ajax({
        type: 'POST',
        url: UrlSite + 'telas/pessoa/monta_filtro.php',
        data: {
            cddopcao: cddopcao,
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Nao foi possivel concluir a operacao.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function (response) {
            hideMsgAguardo();
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {

                    $('#divFiltro').html(response);
                    
                    return false;
                } catch (error) {

                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "estadoInicial();");
                }
            } else {
                try {

                    eval(response);
                } catch (error) {

                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "estadoInicial();");
                }
            }
        }
    });

    return false;

}

function formataFiltro(){
	
	highlightObjFocus( $('#frmFiltro') );   
    
    //Label dos campos
    $('label[for="nrdconta"]', "#frmFiltro").addClass("rotulo").css({ "width": "90px" });
            
    //Campos 
    $("#nrdconta", "#frmFiltro").css({ 'width': '110px', 'text-align': 'right' }).addClass('conta').attr('maxlength', '10').habilitaCampo();
	
    $('#divFiltro').css('display', 'block');
    $('#divBotoesFiltro').css('display', 'block');
	
	// Ao pressionar do campo nrdconta
	$('#nrdconta', '#frmFiltro').unbind('keydown').bind('keydown', function(e){
	
		if ( divError.css('display') == 'block' ) { return false; }		
		
		$('input,select').removeClass('campoErro');

		// Se é a tecla ENTER, TAB, F1
		if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

			$('#btProsseguir', '#divBotoesFiltro').click();

			return false;

		}
		
	});
	
		
	controlaPesquisas();
	layoutPadrao();   
	$("#nrdconta", "#frmFiltro").val(''); 	 
	$("#nrdconta", "#frmFiltro").focus();
	
    return false;

}

function controlaPesquisas() {

    var nmformul = 'frmFiltro';
    var campoAnterior = '';
    var lupas = $('a', '#' + nmformul);

	 
    // Atribui a classe lupa para os links
    lupas.addClass('lupa').css('cursor', 'pointer');

    // Percorrendo todos os links
    lupas.each(function() {
        $(this).unbind('click').bind('click', function() {

            if ($(this).prev().hasClass('campoTelaSemBorda')) {
                return false;
            } else {
                // Obtenho o nome do campo anterior
                campoAnterior = $(this).prev().attr('name');

                if (campoAnterior == 'nrdconta') {
					
                    mostraPesquisaAssociado('nrdconta', nmformul);
					return false;
					
				}	
            }
        });
    });
}

function controlaVoltar(tipo) {

    switch (tipo) {

        case '1':

            estadoInicial();

        break;
		
		case '2':

            $('#divPessoa').html('');
            $('#divRotina').html('');
			apresentaFormFiltro();

        break;
		
    }

    return false;

}

function buscarCooperado(nriniseq,nrregist) {

	var cddopcao = $('#cddopcao','#frmCabPessoa').val(); 
	var nrdconta = normalizaNumero($('#nrdconta','#frmFiltro').val()); 
	
	//Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, buscando ...');
	
	$('input', '#frmFiltro').removeClass('campoErro').desabilitaCampo();
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/pessoa/buscar_cooperado.php',
		data: {
			cddopcao: cddopcao,	
			nrdconta: nrdconta,
		    nriniseq: nriniseq,			
			nrregist: nrregist,				
			redirect: 'html_ajax' // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","estadoInicial();");							
		},
		success: function(response) {			
				hideMsgAguardo();
				if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
					try {
						$('#divPessoa').html(response);
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

//Funcao para formatar a tabela com as ocorrências encontradas na consulta
function formataTabela(){

	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'0 3px 5px 3px'});
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
		
	var divRegistro = $('div.divRegistros');		
	var tabela      = $('table',divRegistro );	
	var linha		= $('table > tbody > tr', divRegistro );
									
	divRegistro.css({ 'height': '150px', 'width' : '100%'});
			
	var ordemInicial = new Array();
					
	var arrayLargura = new Array(); 
	    arrayLargura[0] = '140px';
	    arrayLargura[1] = '250px';
	    arrayLargura[2] = '150px';
							
	var arrayAlinha = new Array();
		arrayAlinha[0] = 'right';
		arrayAlinha[1] = 'left';
		arrayAlinha[2] = 'center';
		arrayAlinha[3] = 'center';

	tabela.formataTabela(ordemInicial,arrayLargura,arrayAlinha,'');
	
	$('#divRegistros').css('display','block');
	$('#divRegistrosRodape','#divCadgrp').formataRodapePesquisa();		
	$('#divPessoa').css('display','block');
	
	//Seleciona o registro que é clicado
	$('table > tbody > tr', divRegistro).click( function() {		
		
		var	cdfuncao = $('input[name="cdfuncao"]', $(this) ).val();
		var	nrdrowid = $('input[name="nrdrowid"]', $(this) ).val();
		var	flgvigencia = $('input[name="flgvigencia "]', $(this) ).val();
		var	dtinicio_vigencia = $('input[name="dtinicio_vigencia"]', $(this) ).val();

		//Ao clicar no botao btExcluir
		$('#btExcluir','#divBotoesTabelaCadastro').unbind('click').bind('click', function(){
			showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?',
				'Confirma&ccedil;&atilde;o - Ayllos',
				'excluirCargoFuncao("' + cdfuncao + '", "' + nrdrowid + '");',
				'$(\'#btVoltar\',\'#divBotoesTabelaCadastro\').focus();',
				'sim.gif',
				'nao.gif');
		});	

		//Ao clicar no botao btInativar
		$('#btInativar','#divBotoesTabelaCadastro').unbind('click').bind('click', function(){
			
			//TODO - Adicionar flag
			apresentaFormCargoFuncao('A',cdfuncao,nrdrowid,dtinicio_vigencia, flgvigencia);
			
		});	
		
				
	});			
	
	//Deixa o primeiro registro ja selecionado
	$('table > tbody > tr', divRegistro).each(function (i) {

		if ($(this).hasClass('corSelecao')) {
			
			var	cdfuncao = $('input[name="cdfuncao"]', $(this) ).val();
			var	nrdrowid = $('input[name="nrdrowid"]', $(this) ).val();
			var	dtinicio_vigencia = $('input[name="dtinicio_vigencia"]', $(this) ).val();
		
			//Ao clicar no botao btExcluir
			$('#btExcluir','#divBotoesTabelaCadastro').unbind('click').bind('click', function(){
				
				showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','excluirCargoFuncao( "' + cdfuncao + '", "' + nrdrowid + '");','$(\'#btVoltar\',\'#divBotoesTabelaCadastro\').focus();','sim.gif','nao.gif');
							
			});	

			//Ao clicar no botao btInativar
			$('#btInativar','#divBotoesTabelaCadastro').unbind('click').bind('click', function(){
				
				apresentaFormCargoFuncao('A',cdfuncao,nrdrowid,dtinicio_vigencia);
							
			});	
			
		}

	});
	
	//Ao clicar no botao btIncluir
	$('#btIncluir','#divBotoesTabelaCadastro').unbind('click').bind('click', function(){
		
		apresentaFormCargoFuncao('I');
		
	});
			
	return false;
	
}

function apresentaFormTipoPessoa() {

    var cddopcao = $("#cddopcao","#frmCabPessoa").val();
	var nrdconta = $('#nrdconta',"#frmCooperado").val();
	
	$('input,select').removeClass('campoErro');
	
    showMsgAguardo("Aguarde ...");
	
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/pessoa/apresenta_form_tipo_pessoa.php",
        data: {
            cddopcao : cddopcao,
            nrdconta : nrdconta,
			redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "estadoInicial();");
        },
        success: function (response) {

			hideMsgAguardo();
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divRotina').html(response);
					return false;
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$(\'#btAlterar\',\'#divBotoesCooperado\').focus();');
				}
			} else {
				try {
					eval( response );						
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$("#btAlterar","#divBotoesCooperado").focus();');
				}
			}
			
        }

    });

    return false;

}

function formataFormTipoPessoa(){
	
	highlightObjFocus( $('#frmTipoPessoa') );   
    
    //Label dos campos
    $('label[for="inpessoa"]', "#frmTipoPessoa").addClass("rotulo").css({ "width": "100px" });
            
    //Campos 
    $('#inpessoa', '#frmTipoPessoa').css({ 'width': '160px'}).habilitaCampo();   
	
    $('#frmTipoPessoa').css('display', 'block');
    $('#divBotoesTipoPessoa').css('display', 'block');
	
	// Ao pressionar do campo inpessoa
	$('#inpessoa', '#frmTipoPessoa').unbind('keydown').bind('keydown', function(e){
	
		if ( divError.css('display') == 'block' ) { return false; }		
		
		$('input,select').removeClass('campoErro');

		// Se é a tecla ENTER, TAB, F1
		if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

			$('#btConcluir', '#divBotoesBuscaGrupo').click();

			return false;

		}
		
	});
	
	layoutPadrao(); 
	$('#inpessoa', '#frmTipoPessoa').focus();

    return false;

}

function apresentaFormCargoFuncao(cdoperac,cdfuncao,nrdrowid,dtinicio_vigencia, flgvigencia) {

    var cddopcao = $("#cddopcao","#frmCabPessoa").val();
	var nrcpfcgc = normalizaNumero($("#nrcpfcgc","#frmCooperado").val());

	$('input,select').removeClass('campoErro');
	
    showMsgAguardo("Aguarde ...");
	
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/pessoa/apresenta_form_cargo_funcao.php",
        data: {
            cddopcao : cddopcao,
            cdoperac : cdoperac, //I = Inlcuir, A = Inativar (tela)
            nrcpfcgc : nrcpfcgc,
            cdfuncao : cdfuncao,
			dtinicio_vigencia : dtinicio_vigencia,
			flgvigencia: flgvigencia,
            nrdrowid : nrdrowid,
			redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "estadoInicial();");
        },
        success: function (response) {

			hideMsgAguardo();
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divRotina').html(response);

					/* Descomentar if caso queira usar somente na tela de incluir */
					//if(cdoperac == "I"){
						/* 
						   Ao Inserir os valores do select cdfuncao verificar se o primeiro
						   option possui a flgvigencia como zero, se sim desabilitar campo
						   dtinicio_vigencia 
						*/
					//}

					return false;
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$("#btInativar","#divBotoesTabelaCadastro").focus();');
				}
			} else {
				try {
					eval( response );						
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$("#btInativar","#divBotoesTabelaCadastro").focus();');
				}
			}
			
        }

    });

    return false;

}

function formataFormCargoFuncao(cdoperac){
	
	highlightObjFocus( $('#frmCargoFuncao') );   
    
    //Label dos campos
    $('label[for="dtinicio_vigencia"]', "#frmCargoFuncao").addClass("rotulo").css({ "width": "100px" });
    $('label[for="dtfim_vigencia"]', "#frmCargoFuncao").addClass("rotulo").css({ "width": "100px" });
    $('label[for="cdfuncao"]', "#frmCargoFuncao").addClass("rotulo").css({ "width": "100px" });
            
    //Campos 
    $('#dtinicio_vigencia', '#frmCargoFuncao').css('width','100px').addClass('data');//.habilitaCampo();
    $('#dtfim_vigencia', '#frmCargoFuncao').css('width','100px').addClass('data');//.habilitaCampo();
    $('#cdfuncao', '#frmCargoFuncao').css({ 'width': '250px'}).habilitaCampo();   
	
    $('#frmCargoFuncao').css('display', 'block');
    $('#divBotoesCargoFuncao').css('display', 'block');
	
	// Ao pressionar do campo dtinicio_vigencia
	$('#dtinicio_vigencia', '#frmCargoFuncao').unbind('keydown').bind('keydown', function(e){
	
		if ( divError.css('display') == 'block' ) { return false; }		
		
		$('input,select').removeClass('campoErro');

		// Se é a tecla ENTER, TAB, F1
		if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

			 $(this).nextAll('.campo:first').focus();

			return false;

		}
		
	});
	
	// Ao pressionar do campo dtfim_vigencia
	$('#dtfim_vigencia', '#frmCargoFuncao').unbind('keydown').bind('keydown', function(e){
	
		if ( divError.css('display') == 'block' ) { return false; }		
		
		$('input,select').removeClass('campoErro');

		// Se é a tecla ENTER, TAB, F1
		if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

			 $(this).nextAll('.campo:first').focus();

			return false;

		}
		
	});
	
	
	// Ao pressionar do campo cdfuncao
	$('#cdfuncao', '#frmCargoFuncao').unbind('keydown').bind('keydown', function(e){
	
		if ( divError.css('display') == 'block' ) { return false; }		
		
		$('input,select').removeClass('campoErro');

		// Se é a tecla ENTER, TAB, F1
		if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

			$('#btConcluir', '#divBotoesCargoFuncao').click();

			return false;

		}
		
	});
	
	layoutPadrao(); 
	


	if(cdoperac == 'A'){
		
		$('#dtinicio_vigencia', '#frmCargoFuncao').css('width','100px').addClass('data');//.desabilitaCampo();
		$('#dtfim_vigencia', '#frmCargoFuncao').css('width','100px').addClass('data');//.habilitaCampo();
		$('#cdfuncao', '#frmCargoFuncao').desabilitaCampo();   
		$('#dtinicio_vigencia', '#frmCargoFuncao').focus();
	
	}else{
		
		/*if ($('#cdfuncao', '#frmCargoFuncao') = 1) {
		  $('#dtinicio_vigencia', '#frmCargoFuncao').css('width','100px').addClass('data').habilitaCampo();
		} else {
		  $('#dtinicio_vigencia', '#frmCargoFuncao').css('width','100px').addClass('data').desabilitaCampo();
		}*/
        $('#dtinicio_vigencia', '#frmCargoFuncao').css('width','100px').addClass('data').habilitaCampo();
		$('#dtfim_vigencia', '#frmCargoFuncao').css('width','100px').addClass('data').desabilitaCampo();
		$('#cdfuncao', '#frmCargoFuncao').habilitaCampo();   
		$('#dtinicio_vigencia', '#frmCargoFuncao').focus();		
		
	}

    return false;

}

function setBehaviorFormCargoFuncao(cdoperac){

	if($('#cdfuncao option:selected').data('flgvigencia') == 0){
		$('#dtinicio_vigencia').desabilitaCampo();
		$('#dtfim_vigencia').desabilitaCampo();
	}else{
		if(cdoperac == "I")
			$('#dtinicio_vigencia').habilitaCampo();
		else{
			$('#dtinicio_vigencia').desabilitaCampo();
		}
		$('#dtfim_vigencia').habilitaCampo();
	}

	$('#cdfuncao').unbind('change').bind('change',function(){
		var optSelected = $("option:selected", this);
		if($(optSelected).data('flgvigencia') == 0){
			$('#dtinicio_vigencia').val('').desabilitaCampo();
		}else{
			$('#dtinicio_vigencia').val('').habilitaCampo();
			$('#dtinicio_vigencia').val('').focus();
		}
	});
}

function excluirCargoFuncao(cdfuncao, nrdrowid) {

    var cddopcao = $('#cddopcao', '#frmCabPessoa').val();    
	var nrcpfcgc = normalizaNumero($('#nrcpfcgc', '#frmCooperado').val());
	
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, efetuando exclus&atilde;o...");

    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/pessoa/excluir_cargo_funcao.php",
        data: {
            cddopcao: cddopcao,
            nrcpfcgc: nrcpfcgc,
			cdfuncao: cdfuncao,
			nrdrowid: nrdrowid,
            redirect: "html_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {            
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {            
			hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '$("#btExcluir","#divBotoesTabelaCadastro").focus();');
            }
        }
    });

    return false;
}
 
function alterarTipoPessoa() {

    var cddopcao = $("#cddopcao", "#frmCabPessoa").val();
	var inpessoa = $('#inpessoa','#frmTipoPessoa').val();
	var nrdconta = normalizaNumero($('#nrdconta','#frmTipoPessoa').val());
	
	$('input,select').removeClass('campoErro');
	
    showMsgAguardo("Aguarde, alterando ...");

	$('input,select').removeClass('campoErro');
	
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/pessoa/alterar_tipo_pessoa.php",
        data: {
            cddopcao         : cddopcao,                
			inpessoa         : inpessoa,        
			nrdconta         : nrdconta,
			redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "estadoInicial();");
        },
        success: function (response) {

            hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'blockBackground(parseInt($("#divRotina").css("z-index")));$("#btAlterar","#divBotoesCooperado").focus();');
            }
        }

    });

    return false;

}

function inativarCargoFuncao() {

    var cddopcao = $("#cddopcao", "#frmCabPessoa").val();
	var dtinicio_vigencia = $('#dtinicio_vigencia','#frmCargoFuncao').val();
	var dtfim_vigencia = $('#dtfim_vigencia','#frmCargoFuncao').val();
	var nrcpfcgc = normalizaNumero($("#nrcpfcgc","#frmCooperado").val());
	var nrdrowid = $('#nrdrowid','#frmCargoFuncao').val();
	var cdfuncao = $('#cdfuncao_inativar','#frmCargoFuncao').val();
	
	$('input,select').removeClass('campoErro');
	
    showMsgAguardo("Aguarde, alterando ...");

	$('input,select').removeClass('campoErro');
	
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/pessoa/inativar_cargo_funcao.php",
        data: {
            cddopcao         : cddopcao,                
			dtinicio_vigencia: dtinicio_vigencia,        
			dtfim_vigencia   : dtfim_vigencia,
			nrcpfcgc         : nrcpfcgc,
			nrdrowid         : nrdrowid,
			cdfuncao         : cdfuncao,
			redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "estadoInicial();");
        },
        success: function (response) {

            hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'blockBackground(parseInt($("#divRotina").css("z-index")));$("#btInativar","#divBotoesTabelaCadastro").focus();');
            }
        }

    });

    return false;

}


function incluirCargoFuncao() {

    var cddopcao = $("#cddopcao", "#frmCabPessoa").val();
	var dtinicio_vigencia = $('#dtinicio_vigencia','#frmCargoFuncao').val();
	var nrcpfcgc = normalizaNumero($("#nrcpfcgc","#frmCooperado").val());
	var cdfuncao = $('#cdfuncao','#frmCargoFuncao').val();
	
	$('input,select').removeClass('campoErro');
	
    showMsgAguardo("Aguarde, alterando ...");

	$('input,select').removeClass('campoErro');
	
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/pessoa/incluir_cargo_funcao.php",
        data: {
            cddopcao         : cddopcao,                
			dtinicio_vigencia: dtinicio_vigencia,        
			nrcpfcgc         : nrcpfcgc,
			cdfuncao         : cdfuncao,
			redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "estadoInicial();");
        },
        success: function (response) {

            hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'blockBackground(parseInt($("#divRotina").css("z-index")));$("#btVoltar","#divBotoesCargoFuncao").focus();');
            }
        }

    });

    return false;

}
