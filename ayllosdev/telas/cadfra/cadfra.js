/*!
 * FONTE        : cadfra.js
 * CRIAÇÃO      : Jaison
 * DATA CRIAÇÃO : 07/02/2017
 * OBJETIVO     : Biblioteca de funções da tela CADFRA
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
$(document).ready(function() {

	estadoInicial();

	highlightObjFocus( $('#frmCab') );

	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});

	return false;

});

function estadoInicial() {
	$('#frmCab').css({'display':'block'});
	$('#frmCadfra').css({'display':'none'});	
	$('#divBotoes', '#divTela').html('').css({'display':'block'});
	formataCabecalho();
	return false;
}

function controlaFoco() {

	$('#cddopcao','#frmCab').unbind('keypress').bind('keypress', function(e) {

		if ( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda') ) { return false; }

		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			eventTipoOpcao();			
			return false;
		}	
	});

	$('#btnOK','#frmCab').unbind('keypress').bind('keypress', function(e) {

		if ( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda') ) { return false; }

		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			eventTipoOpcao();
			return false;
		}	
	});

	$('#btnOK','#frmCab').unbind('click').bind('click', function(){
	
		if ( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda') ) { return false; }		
		eventTipoOpcao();
		return false;			
	});

	return false;
}

function eventTipoOpcao(){
	carregaTelaCadfra();
	return false;
}

function formataCabecalho() {

	$('input,select', '#frmCab').removeClass('campoErro');
	$('#divTela').css({'display':'inline'}).fadeTo(0,0.1);
	removeOpacidade('divTela');	

	cTodosCabecalho = $('input[type="text"],select','#frmCab'); 
	cTodosCabecalho.limpaFormulario();

	// cabecalho
	rCddopcao			= $('label[for="cddopcao"]','#frmCab'); 	
	cCddopcao			= $('#cddopcao','#frmCab'); 	

	//Rótulos
	rCddopcao.css('width','44px');	

	//Campos	
	cCddopcao.css({'width':'496px'}).habilitaCampo().focus();	

	controlaFoco();
	layoutPadrao();

	return false;
}

function trocaBotao(sNomeBotaoSalvar,sFuncaoSalvar,sFuncaoVoltar) {
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onClick="'+sFuncaoVoltar+'; return false;">Voltar</a>&nbsp;');

	if (sFuncaoSalvar != ''){
		$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btSalvar" onClick="'+sFuncaoSalvar+'; return false;">'+sNomeBotaoSalvar+'</a>');	
	}
	return false;
}

/**
	Funcao responsavel para formatar os campos em tela
*/
function formataCamposTela(cddopcao){

    highlightObjFocus($('#frmCadfra'));

    var rCdoperacao = $('label[for="cdoperacao"]', '#frmCadfra');
    var rDsoperacao = $('label[for="dsoperacao"]', '#frmCadfra');
    var rTpoperacao = $('label[for="tpoperacao"]', '#frmCadfra');

    var cCdoperacao = $('#cdoperacao', '#frmCadfra');
    var cDsoperacao = $('#dsoperacao', '#frmCadfra');
    var cTpoperacao = $('#tpoperacao', '#frmCadfra');

    rCdoperacao.addClass('rotulo').css({'width': '70px'});
    cCdoperacao.addClass('campo pesquisa').css({'width':'40px'}).attr('maxlength','3').setMask('INTEGER','zzz','','');
    cCdoperacao.habilitaCampo().focus();

    rDsoperacao.addClass('rotulo-linha').css({'width': '70px'});
    cDsoperacao.addClass('campo').css({'width':'360px'}).attr('maxlength','15');
    cDsoperacao.desabilitaCampo();

    rTpoperacao.addClass('rotulo').css({'width': '115px'});
    cTpoperacao.addClass('campo').css({'width':'100px'});
    cTpoperacao.habilitaCampo();

    cCdoperacao.unbind('keypress').bind('keypress', function(e) {
        if ( divError.css('display') == 'block' ) { return false; }
        if ( e.keyCode == 9 || e.keyCode == 13 ) {
            cTpoperacao.focus();
            return false;
        }
    });
    cCdoperacao.unbind('blur').bind('blur', function() {
        if ($(this).val() != '') {
            filtrosDesc = 'nriniseq|1;nrregist|30';
            buscaDescricao('zoom0001', 'BUSCAOPERACAO_AFRA', 'Operações de Conta Corrente', 'cdoperacao', 'dsoperacao', $(this).val(), 'dsoperacao', filtrosDesc, 'frmCadfra');
            setTimeout('unblockBackground();',350);
        }
        return false;
    });

    cTpoperacao.unbind('keypress').bind('keypress', function(e) {
        if ( divError.css('display') == 'block' ) { return false; }
        if ( e.keyCode == 9 || e.keyCode == 13 ) {
            $('#btSalvar', '#divBotoes').focus();
            return false;
        }
    });

    // Oculta
    $('#divTabCampos, #divTipo1, #divTipo2', '#frmCadfra').hide();
    
    var rFlgemail_entrega  = $('label[for="flgemail_entrega"]',  '#frmCadfra');
    var rFlgYes            = $('label[for="flgYes"]',            '#frmCadfra');
    var rFlgNo             = $('label[for="flgNo"]',             '#frmCadfra');
    var rDsemail_entrega   = $('label[for="dsemail_entrega"]',   '#frmCadfra');
    var rDsassunto_entrega = $('label[for="dsassunto_entrega"]', '#frmCadfra');
    var rDscorpo_entrega   = $('label[for="dscorpo_entrega"]',   '#frmCadfra');

    var rFlgemail_retorno  = $('label[for="flgemail_retorno"]',  '#frmCadfra');
    var rFlgYesRet         = $('label[for="flgYesRet"]',         '#frmCadfra');
    var rFlgNoRet          = $('label[for="flgNoRet"]',          '#frmCadfra');
    var rDsemail_retorno   = $('label[for="dsemail_retorno"]',   '#frmCadfra');
    var rDsassunto_retorno = $('label[for="dsassunto_retorno"]', '#frmCadfra');
    var rDscorpo_retorno   = $('label[for="dscorpo_retorno"]',   '#frmCadfra');
    
    var rFlgativo          = $('label[for="flgativo"]',          '#frmCadfra');
    var rTpretencao        = $('label[for="tpretencao"]',        '#frmCadfra');    
    var rHrretencao        = $('label[for="hrretencao"]',        '#frmCadfra');
    var rHrretencao2       = $('label[for="hrretencao2"]',       '#frmCadfra');
    var rHrretencao3       = $('label[for="hrretencao3"]',       '#frmCadfra');
    var rHrretencao4       = $('label[for="hrretencao4"]',       '#frmCadfra');
    var rHrretencao5       = $('label[for="hrretencao5"]',       '#frmCadfra');
    var rHrretencao6       = $('label[for="hrretencao6"]',       '#frmCadfra');    
    var rRotulo_inf        = $('label[for="rotulo_inf"]',        '#frmCadfra');
    var rRotulo_eml        = $('label[for="rotulo_eml"]',        '#frmCadfra');

    rFlgemail_entrega.addClass('rotulo-linha').css({'width': '360px'});
    rFlgYes.addClass('rotulo-linha').css({'width': '20px'});
    rFlgNo.addClass('rotulo-linha').css({'width': '20px'});
    rDsemail_entrega.addClass('rotulo').css({'width': '100px'});
    rDsassunto_entrega.addClass('rotulo').css({'width': '100px'});
    rDscorpo_entrega.addClass('rotulo').css({'width': '100px'});

    rFlgemail_retorno.addClass('rotulo-linha').css({'width': '360px'});
    rFlgYesRet.addClass('rotulo-linha').css({'width': '20px'});
    rFlgNoRet.addClass('rotulo-linha').css({'width': '20px'});
    rDsemail_retorno.addClass('rotulo').css({'width': '100px'});
    rDsassunto_retorno.addClass('rotulo').css({'width': '100px'});
    rDscorpo_retorno.addClass('rotulo').css({'width': '100px'});
    
    rFlgativo.addClass('rotulo').css({'width': '110px'});
    rTpretencao.addClass('rotulo').css({'width': '110px'});
    rHrretencao.addClass('rotulo').css({'width': '160px'});
    rHrretencao2.addClass('rotulo').css({'width': '130px'});
    rHrretencao3.addClass('rotulo-linha').css({'width': '75px'});
    rHrretencao4.addClass('rotulo-linha').css({'width': '40px'});
    rHrretencao5.addClass('rotulo').css({'width': '160px'});
    rHrretencao6.addClass('rotulo-linha').css({'width': '55px'});
    rRotulo_inf.addClass('rotulo-linha').css({'width': '120px', 'font-size': '10px', 'font-weight': 'normal'});
    rRotulo_eml.addClass('rotulo-linha').css({'text-align': 'left', 'font-size': '10px', 'font-weight': 'normal', 'line-height':'15px'});

    var cFlag              = $('#flgYes, #flgNo, #flgYesRet, #flgNoRet', '#frmCadfra');
    var cDsemail_entrega   = $('#dsemail_entrega',   '#frmCadfra');
    var cDsassunto_entrega = $('#dsassunto_entrega', '#frmCadfra');
    var cDscorpo_entrega   = $('#dscorpo_entrega',   '#frmCadfra');

    var cDsemail_retorno   = $('#dsemail_retorno',   '#frmCadfra');
    var cDsassunto_retorno = $('#dsassunto_retorno', '#frmCadfra');
    var cDscorpo_retorno   = $('#dscorpo_retorno',   '#frmCadfra');

    var cFlgativo          = $('#flgativo',          '#frmCadfra');
    var cTpretencao        = $('#tpretencao',        '#frmCadfra');    
    var cQtdminutos_retencao = $('#qtdminutos_retencao', '#frmCadfra');        
    var cHrretencao        = $('#hrretencao',        '#frmCadfra');
    var cHrretencao5       = $('#hrretencao5',       '#frmCadfra');
    var cHrinicio          = $('#hrinicio',          '#frmCadfra');
    var cHrfim             = $('#hrfim',             '#frmCadfra');

    cFlag.css({'background-color': '#fff'});
    cDsemail_entrega.addClass('campo').css({'width':'420px'}).attr('maxlength','100');
    cDsassunto_entrega.addClass('campo').css({'width':'420px'}).attr('maxlength','100');
    cDscorpo_entrega.addClass('campo').css({'width':'420px','height':'70px','float':'left','margin':'3px 0px 3px 3px'}).attr('maxlength','500');

    cDsemail_retorno.addClass('campo').css({'width':'420px'}).attr('maxlength','100');
    cDsassunto_retorno.addClass('campo').css({'width':'420px'}).attr('maxlength','100');
    cDscorpo_retorno.addClass('campo').css({'width':'420px','height':'70px','float':'left','margin':'3px 0px 3px 3px'}).attr('maxlength','500');

    cHrretencao.addClass('campo').css({'width':'50px','text-align':'center'}).attr('maxlength','5').setMask('STRING','99:99',':','');
    cHrretencao.mask('00:00');
    
    cHrretencao5.addClass('campo').css({'width':'35px','text-align':'center'}).attr('maxlength','2').setMask('STRING',':99',':','');
    cHrretencao5.mask('00');

    cHrinicio.addClass('campo').css({'width':'50px','text-align':'center'}).attr('maxlength','5').setMask('STRING','99:99',':','');
    cHrinicio.mask('00:00');

    cHrfim.addClass('campo').css({'width':'50px','text-align':'center'}).attr('maxlength','5').setMask('STRING','99:99',':','');
    cHrfim.mask('00:00');

    
    $('#flgativo', '#frmCadfra').unbind('keypress').bind('keypress', function(e) {
        if ( divError.css('display') == 'block' ) { return false; }
        if ( e.keyCode == 9 || e.keyCode == 13 ) {
            cTpretencao.focus();
            return false;
        }
    });
    
    $('#tpretencao', '#frmCadfra').unbind('keypress').bind('keypress', function(e) {
        if ( divError.css('display') == 'block' ) { return false; }
        if ( e.keyCode == 9 || e.keyCode == 13 ) {
            cQtdminutos_retencao.focus();
            return false;
        }
    });
    
    $('#tpretencao', '#frmCadfra').unbind('change').bind('change', function(e) {
        if ( divError.css('display') == 'block' ) { return false; }
        
        exibeIntervalo(cTpoperacao.val());
        return false;        
    });
    
    $('#qtdminutos_retencao', '#frmCadfra').unbind('keypress').bind('keypress', function(e) {
        if ( divError.css('display') == 'block' ) { return false; }
        if ( e.keyCode == 9 || e.keyCode == 13 ) {
            cHrinicio.focus();
            return false;
        }
    });

    cHrinicio.unbind('keypress').bind('keypress', function(e) {
        if ( divError.css('display') == 'block' ) { return false; }
        if ( e.keyCode == 9 || e.keyCode == 13 ) {
            cHrfim.focus();
            return false;
        }
    });

    cHrfim.unbind('keypress').bind('keypress', function(e) {
        if ( divError.css('display') == 'block' ) { return false; }
        if ( e.keyCode == 9 || e.keyCode == 13 ) {
            validaInclusao();
            return false;
        }
    });

    cHrretencao.unbind('keypress').bind('keypress', function(e) {
        if ( divError.css('display') == 'block' ) { return false; }
        if ( e.keyCode == 9 || e.keyCode == 13 ) {
            acessaOpcaoAba(1);
            $('#' + $('input[name="flgemail_entrega"]:checked').attr('id'), '#frmCadfra').focus();
            return false;
        }
    });

    $('#flgYes, #flgNo', '#frmCadfra').unbind('keypress').bind('keypress', function(e) {
        if ( divError.css('display') == 'block' ) { return false; }
        if ( e.keyCode == 9 || e.keyCode == 13 ) {
            cDsemail_entrega.focus();
            return false;
        }
    });

    cDsemail_entrega.unbind('keypress').bind('keypress', function(e) {
        if ( divError.css('display') == 'block' ) { return false; }
        if ( e.keyCode == 9 || e.keyCode == 13 ) {
            cDsassunto_entrega.focus();
            return false;
        }
    });

    cDsassunto_entrega.unbind('keypress').bind('keypress', function(e) {
        if ( divError.css('display') == 'block' ) { return false; }
        if ( e.keyCode == 9 || e.keyCode == 13 ) {
            cDscorpo_entrega.focus();
            return false;
        }
    });

    cDscorpo_entrega.unbind('keypress').bind('keypress', function(e) {
        if ( divError.css('display') == 'block' ) { return false; }
        if ( e.keyCode == 9 || (e.keyCode == 13 && !e.shiftKey) ) {
            acessaOpcaoAba(2);
            $('#' + $('input[name="flgemail_retorno"]:checked').attr('id'), '#frmCadfra').focus();
            return false;
        }
    });

    $('#flgYesRet, #flgNoRet', '#frmCadfra').unbind('keypress').bind('keypress', function(e) {
        if ( divError.css('display') == 'block' ) { return false; }
        if ( e.keyCode == 9 || e.keyCode == 13 ) {
            cDsemail_retorno.focus();
            return false;
        }
    });

    cDsemail_retorno.unbind('keypress').bind('keypress', function(e) {
        if ( divError.css('display') == 'block' ) { return false; }
        if ( e.keyCode == 9 || e.keyCode == 13 ) {
            cDsassunto_retorno.focus();
            return false;
        }
    });

    cDsassunto_retorno.unbind('keypress').bind('keypress', function(e) {
        if ( divError.css('display') == 'block' ) { return false; }
        if ( e.keyCode == 9 || e.keyCode == 13 ) {
            cDscorpo_retorno.focus();
            return false;
        }
    });

    cDscorpo_retorno.unbind('keypress').bind('keypress', function(e) {
        if ( divError.css('display') == 'block' ) { return false; }
        if ( e.keyCode == 9 || (e.keyCode == 13 && !e.shiftKey) ) {
            confirmaAcao();
            return false;
        }
    });

	layoutPadrao();
	controlaPesquisas();
    return false;
}	

function exibeIntervalo(tpoperacao) {
    
    
    if (tpoperacao == 2 ){
    
        $('#divTabCampos, #divTipo1', '#frmCadfra').hide();            
        $('#divTabCampos, #divTipo3', '#frmCadfra').hide();            
        $('#divTabCampos, #divTipo2', '#frmCadfra').show();  
        
        $('#tpretencao','#frmCadfra').desabilitaCampo();       
    }else{
        $('#divTabCampos, #divTipo1', '#frmCadfra').hide();     
        $('#divTabCampos, #divTipo2', '#frmCadfra').hide(); 
        $('#divTabCampos, #divTipo3', '#frmCadfra').hide();            
        
        if  ($('#tpretencao','#frmCadfra').val() == 2 ){        
          $('#divTabCampos, #divTipo2', '#frmCadfra').show();        
          
        }else if  ($('#tpretencao','#frmCadfra').val() == 3){        
          $('#divTabCampos, #divTipo3', '#frmCadfra').show();                  
        }else{
          $('#divTabCampos, #divTipo1', '#frmCadfra').show();     
        }
        $('#tpretencao','#frmCadfra').habilitaCampo();
    }
    
}

function controlaPesquisas() {

    var nmformul = 'frmCadfra';
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

                // Operacao
                if (campoAnterior == 'cdoperacao') {
                    filtros = 'Cód.;cdoperacao;30px;S;|Descri&ccedil&atildeo;dsoperacao;200px;S;';
                    colunas = 'C&oacutedigo;cdoperacao;20%;right|Opera&ccedil&atildeo;dsoperacao;80%;left';
                    mostraPesquisa("zoom0001", "BUSCAOPERACAO_AFRA", "Operações de Conta Corrente", "30", filtros, colunas);
                    return false;
                }
            }
        });
    });

}

/**
	Funcao responsavel para carregar a tela
*/
function carregaTelaCadfra(){

	showMsgAguardo("Aguarde...");
	
	var cCddopcao = $('#cddopcao','#frmCab');
	cCddopcao.desabilitaCampo();

	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadfra/principal.php", 
		data: {			
			cddopcao: cCddopcao.val(),
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divTela').css('z-index')))");
		},
		success : function(response) {
			hideMsgAguardo();
			try {
				$('#divCadastro').html(response);

                var nmBotao = 'Continuar';
                var nmFuncao = 'buscaDados(\'' + cCddopcao.val() + '\');';

                // Exibe os botoes
                trocaBotao(nmBotao,nmFuncao,'estadoInicial()');

				return false;
			} catch(error) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
			}
		}
	});
}

/**
	Funcao responsavel por buscar os dados
*/
function buscaDados(cddopcao) {

	showMsgAguardo("Aguarde...");

    var cdoperacao = normalizaNumero($('#cdoperacao','#frmCadfra').val());
    var tpoperacao = normalizaNumero($('#tpoperacao','#frmCadfra').val());
    
    if (cdoperacao == 0) {
        showError("error","Informe a opera&ccedil;&atilde;o.","Alerta - Ayllos","$('#cdoperacao').focus();hideMsgAguardo();");
        return false;
    }

    // Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadfra/busca_dados.php", 
		data: {			
			cddopcao: cddopcao,
            cdoperacao: cdoperacao,
            tpoperacao: tpoperacao,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divTela').css('z-index')))");
		},
		success : function(response) {
			hideMsgAguardo();
			try { 
				eval(response);
				return false;
			} catch(error) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
			}
		}
	});
}

// Funcao para acessar opcoes da rotina
function acessaOpcaoAba(id) {
    
    // Esconde as abas
    $('.clsAbas','#frmCadfra').hide();
    
	// Atribui cor de destaque para aba da opcao
	for (var i = 0; i < 3; i++) {
		if (id == i) { // Atribui estilos para foco da opcao
			$("#linkAba" + id).attr("class","txtBrancoBold");
			$("#imgAbaEsq" + id).attr("src",UrlImagens + "background/mnu_sle.gif");				
			$("#imgAbaDir" + id).attr("src",UrlImagens + "background/mnu_sld.gif");
			$("#imgAbaCen" + id).css("background-color","#969FA9");
            $("#divAba" + id).show();
			continue;			
		}
		$("#linkAba" + i).attr("class","txtNormalBold");
		$("#imgAbaEsq" + i).attr("src",UrlImagens + "background/mnu_nle.gif");			
		$("#imgAbaDir" + i).attr("src",UrlImagens + "background/mnu_nld.gif");
		$("#imgAbaCen" + i).css("background-color","#C6C8CA");
	}
}

/**
	Funcao responsavel para confirmar acao
*/
function confirmaAcao() {
    
    if ( $('#flgativo_ori', '#frmCadfra').val() == 1 && 
         $('#flgativo', '#frmCadfra').val() == 0){
        showConfirmacao('Ao Inativar a operação as Análises de fraude não serão enviadas para o sistema parceiro,<br> com isso as operações serão aprovadas automaticamente, Confirma a opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'gravarDados()', '', 'sim.gif', 'nao.gif');
    }else{
    
       showConfirmacao('Confirma a opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'gravarDados()', '', 'sim.gif', 'nao.gif');
    }
}

/**
	Funcao responsavel por gravar os dados
*/
function gravarDados() {

    var cddopcao          = $('#cddopcao',         '#frmCab').val();
    var cdoperacao        = $('#cdoperacao',       '#frmCadfra').val();
    var tpoperacao        = $('#tpoperacao',       '#frmCadfra').val();    
    var flgativo          = $('#flgativo',         '#frmCadfra').val();
    var tpretencao        = $('#tpretencao',         '#frmCadfra').val();
    
    if (tpretencao == 3 ){
      var hrretencao        = $('#hrretencao5',       '#frmCadfra').val();  
    }else {
      var hrretencao        = $('#hrretencao',       '#frmCadfra').val();
    }
    
    var flgemail_entrega  = $('input[name="flgemail_entrega"]:checked').val();
    var dsemail_entrega   = $('#dsemail_entrega',  '#frmCadfra').val();
    var dsassunto_entrega = $('#dsassunto_entrega','#frmCadfra').val();
    var dscorpo_entrega   = $('#dscorpo_entrega',  '#frmCadfra').val();

    var flgemail_retorno  = $('input[name="flgemail_retorno"]:checked').val();
    var dsemail_retorno   = $('#dsemail_retorno',  '#frmCadfra').val();
    var dsassunto_retorno = $('#dsassunto_retorno','#frmCadfra').val();
    var dscorpo_retorno   = $('#dscorpo_retorno',  '#frmCadfra').val();

    var strhoraminutos    = $('#strhoraminutos',   '#frmCadfra').val();

    showMsgAguardo("Aguarde, processando...");

    // Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadfra/manter_rotina.php", 
		data: {
			cddopcao:          cddopcao,
            cdoperacao:        normalizaNumero(cdoperacao),
			tpoperacao:        normalizaNumero(tpoperacao),
            hrretencao:        hrretencao,

            flgemail_entrega:  normalizaNumero(flgemail_entrega),
            dsemail_entrega:   dsemail_entrega,
            dsassunto_entrega: dsassunto_entrega,
            dscorpo_entrega:   dscorpo_entrega,

            flgemail_retorno:  normalizaNumero(flgemail_retorno),
            dsemail_retorno:   dsemail_retorno,
            dsassunto_retorno: dsassunto_retorno,
            dscorpo_retorno:   dscorpo_retorno,

            strhoraminutos:    strhoraminutos,
            flgativo:          flgativo,    
            tpretencao:        tpretencao,

			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divTela').css('z-index')))");
		},
		success : function(response) {
			try { 
				eval(response);
				return false;
			} catch(error) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
			}
		}
	});
}

function formataGridHora() {
    
    var divRegistro = $('#divHora');
    var tabela      = $('table', divRegistro );
    var linha       = $('table > tbody > tr', divRegistro );

    divRegistro.css({'height':'100px'});

    var ordemInicial = new Array();
    ordemInicial = [[0,0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '130px';
    arrayLargura[1] = '130px';
    arrayLargura[2] = '130px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'center';
    arrayAlinha[3] = 'center';

    tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);
    return false;	
}

function confirmaInclusao() {
    showConfirmacao("Deseja incluir este registro na lista?", 'Confirma&ccedil;&atilde;o - Ayllos', 'adicionaLinha()', '', 'sim.gif', 'nao.gif');
}

function resetaInclusao() {
    $('#hrinicio',           '#frmCadfra').val('');
    $('#hrfim',              '#frmCadfra').val('');
    $('#qtdminutos_retencao','#frmCadfra').val('').focus();
}

function adicionaLinha() {

    var hrinicio   = $('#hrinicio', '#frmCadfra').val();
    var hrfim      = $('#hrfim',    '#frmCadfra').val();
    var qtdminutos = normalizaNumero($('#qtdminutos_retencao', '#frmCadfra').val());
    var idLinParam = hrinicio.replace(':', '') + '_' + hrfim.replace(':', '') + '_' + qtdminutos;
    var linParam   = '';
    var blnAchou   = false;

    if (hrinicio == '' || hrfim == '' || qtdminutos == 0) {
        return false;
    }

    $('#tbodyHora tr').each(function(){
        if ($(this).attr('id') == idLinParam) {
            blnAchou = true;
            return false;
        }
    });

    if (blnAchou) {
        $('#' + idLinParam).show();
    } else {
        linParam += '<tr id="' + idLinParam + '">';
        linParam += '    <td align="center" width="130">' + hrinicio + '</td>';
        linParam += '    <td align="center" width="130">' + hrfim  + '</td>';
        linParam += '    <td align="center" width="130">' + qtdminutos + '</td>';
        linParam += '    <td align="center"><img onclick="confirmaExclusao(\'' + idLinParam + '\');" style="cursor:hand;" src="../../imagens/geral/servico_nao_ativo.gif" width="17" height="17" /></td>';
        linParam += '</tr>';
    }

    // Inclui nova linha
    $('#tbodyHora').append(linParam);

    resetaInclusao();
    zebrarLinhas();
    carregarStrHoraMinutos();

}

function confirmaExclusao(idLinParam) {
    showConfirmacao("Deseja excluir este registro da lista?", 'Confirma&ccedil;&atilde;o - Ayllos', 'excluirLinha("' + idLinParam + '")', '', 'sim.gif', 'nao.gif');
}

function excluirLinha(idLinParam) {
    $('#' + idLinParam).hide();
    zebrarLinhas();
    carregarStrHoraMinutos();
}

function zebrarLinhas() {
    $('#tbodyHora tr').removeClass('corImpar').removeClass('corPar');

    var nmclasse = 'corImpar'
    $('#tbodyHora tr').each(function(){
        if ($(this).is(':visible') == true) {
            $(this).addClass(nmclasse);
            nmclasse = (nmclasse == 'corImpar' ? 'corPar' : 'corImpar');
        }
    });
}

function carregarStrHoraMinutos() {
    var strhoraminutos = '';
    if ($('#divAba0','#frmCadfra').is(':visible') == true) {
        $('#tbodyHora tr').each(function(){
            if ($(this).is(':visible') == true) {
                strhoraminutos += (strhoraminutos == '' ? '' : '#') + $(this).attr('id');
            }
        });
    }
    $('#strhoraminutos','#frmCadfra').val(strhoraminutos);
}
