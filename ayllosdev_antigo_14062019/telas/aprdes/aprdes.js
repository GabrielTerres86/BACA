/*!
 * FONTE        : aprdes.php
 * CRIAÇÃO      : Luis Fernando (GFT)
 * DATA CRIAÇÃO : Março/2009
 * OBJETIVO     : Biblioteca de funções da subrotina de Mesa de Checagem
 * --------------
*/
var nomeForm;
var cTodosOpcao;

/*Filtros*/
var cNrdconta;
var cNrcpfcgc;
var cNmprimtl;
var cNrborder;
var cDtborini;
var cDtborfim;
var rNrdconta;
var rNrcpfcgc;
var rNmprimtl;
var rNrborder;
var rDtborini;
var rDtborfim;
var borderoSelecionado;
$(document).ready(function(){
	iniciaTela();
	cNrdconta.focus();
	layoutPadrao();
	$(".navigation").bind("keypress",(function(e) {
		nextField(e,this);
	}));
    borderoSelecionado = {
        nrdconta : null,
        nrborder : null
    };
    tituloSelecionado = {
        chave: null
    }
});
/*FUNÇÕES PARA CONTROLE DE NAVEGAÇÃO PADRÃO*/
function nextField(e,obj){
    if(e.keyCode == 13) { 
        var field = $("input.navigation,select.navigation,checkbox.navigation,radio.navigation");
        currentBoxNumber = field.index(obj);
        if (field[currentBoxNumber + 1] != null) {
            nextBox = field[currentBoxNumber + 1];
            if($(nextBox).prop("readonly") || $(nextBox).prop("disabled")){
            	nextField(e,nextBox);
            }
            else{
	            nextBox.focus();
	            nextBox.select();
            }
            return false;
        }
    }
}
function backField(obj){
    var field = $("input.navigation,select.navigation,checkbox.navigation,radio.navigation");
    currentBoxNumber = field.index(obj);
    if (field[currentBoxNumber - 1] != null) {
        nextBox = field[currentBoxNumber - 1];
        if($(nextBox).prop("readonly") || $(nextBox).prop("disabled")){
        	backField(nextBox);
        }
        else{
            nextBox.focus();
            nextBox.select();
        }
        return false;
    }
}

function btnVoltar(){
	backField(document.activeElement);
}

/*FUNÇÃO PARA FORMATAR OS CAMPOS*/
function iniciaTela(){
	nomeForm = "divFiltrosBorderos";
	cTodosOpcao = $('input[type="text"],input[type="checkbox"], select', '#' + nomeForm);
	cTodosOpcao.desabilitaCampo();
	rNrdconta = $("label[for='nrdconta']","#"+nomeForm);
	rNrcpfcgc = $("label[for='nrcpfcgc']","#"+nomeForm);
	rNmprimtl = $("label[for='nmprimtl']","#"+nomeForm);
	rNrborder = $("label[for='nrborder']","#"+nomeForm);
	rDtborini = $("label[for='dtborini']","#"+nomeForm);
	rDtborfim = $("label[for='dtborfim']","#"+nomeForm);

	cNrdconta = $("#nrdconta","#"+nomeForm);
	cNrcpfcgc = $("#nrcpfcgc","#"+nomeForm);
	cNmprimtl = $("#nmprimtl","#"+nomeForm);
	cNrborder = $("#nrborder","#"+nomeForm);
	cDtborini = $("#dtborini","#"+nomeForm);
	cDtborfim = $("#dtborfim","#"+nomeForm);


    rNrdconta.css({'width': '50px'}).addClass('rotulo');
    rNrcpfcgc.css({'width': '90px'}).addClass('rotulo-linha');
    rNmprimtl.css({'width': '50px'}).addClass('rotulo');
	rNrborder.css({'width': '50px'}).addClass('rotulo');
	rDtborini.css({'width': '50px'}).addClass('rotulo-linha');
	rDtborfim.css({'width': '50px'}).addClass('rotulo-linha');

    cNrdconta.css({'width': '75px'}).addClass('pesquisa conta');

	cNrdconta.habilitaCampo().addClass('conta');
	cNrcpfcgc.habilitaCampo().addClass('inteiro').attr('maxlength',14);
	cNmprimtl.css({'width': '400px'});
	cNrborder.habilitaCampo().addClass('inteiro');
	cDtborini.habilitaCampo().addClass('data');
	cDtborfim.habilitaCampo().addClass('data');

	controlaPesquisas();

	cNrdconta.unbind("focusout").bind("focusout",function(){
        cNrcpfcgc.val('');
        cNmprimtl.val('');
		if ($(this).val()!=''){
			buscaAssociadoConta();
		}
	});
	cNrcpfcgc.unbind("change").bind("change",function(){
        cNrdconta.val('');
        cNmprimtl.val('');
		if ($(this).val()!=''){
			buscaAssociadoConta();
		}
	});
	cDtborfim.unbind("keypress").bind("keypress",function(e){
    	if(e.keyCode == 13) { 
			buscarBorderos();
		}
	});

    formataLayoutTabela();
}

function controlaPesquisas() {
    /*---------------------*/
    /*  CONTROLE CONTA/DV  */
    /*---------------------*/
    var linkConta = $('a.lupaConta', '#'+nomeForm);
    if (linkConta.prev().hasClass('campoTelaSemBorda')) {
        linkConta.addClass('lupa').css('cursor', 'auto').unbind('click').bind('click', function() {
            return false;
        });
    } else {
        linkConta.css('cursor', 'pointer').unbind('click').bind('click', function() {
            mostraPesquisaAssociado('nrdconta', nomeForm);
        });
    }
    return false;
}

function buscaAssociadoConta() {
    var nrdconta = normalizaNumero($('#nrdconta', '#' + nomeForm).val());
    var nrcpfcgc = normalizaNumero($('#nrcpfcgc', '#' + nomeForm).val());
    cTodosOpcao.removeClass('campoErro');
    showMsgAguardo('Aguarde, buscando dados ...');
    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/aprdes/manter_rotina.php',
        data: {
            operacao: 'BUSCAR_ASSOCIADO',
            nrdconta: nrdconta,
            nrcpfcgc: nrcpfcgc,
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'cNrdconta.focus();');
        },
        success: function(response) {
            try {
            	hideMsgAguardo();
            	var r = $.parseJSON(response);
            	if(r.status=='erro'){
            		showError("error",r.mensagem,'Alerta - Ayllos','cNrdconta.focus();');
	            	cNrdconta.val('');
	            	cNrcpfcgc.val('');
	            	cNmprimtl.val('');
            	}
            	else{
	            	cNrdconta.val(r.nrdconta).blur();
	            	cNrcpfcgc.val(r.nrcpfcgc);
	            	cNmprimtl.val(r.nmprimtl);
            	}
                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'cNrdconta.focus();');
            }
        }
    });
    return false;
}

function buscarBorderos() {
    var nrdconta = normalizaNumero($('#nrdconta', '#' + nomeForm).val());
    var nrcpfcgc = normalizaNumero($('#nrcpfcgc', '#' + nomeForm).val());
    var nrborder = normalizaNumero($('#nrborder', '#'+ nomeForm).val());
    var dtborini = $('#dtborini', '#' + nomeForm).val();
    var dtborfim = $('#dtborfim', '#' + nomeForm).val();
    var operacao = "BUSCAR_BORDEROS";
    showMsgAguardo('Aguarde, buscando dados ...');
    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/aprdes/manter_rotina.php',
        data: {
            nrdconta: nrdconta,
            nrcpfcgc: nrcpfcgc,
            nrborder: nrborder,
            dtborini: dtborini,
			dtborfim: dtborfim,
			operacao: operacao,
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'cNrdconta.focus();');
        },
        success: function(response) {
            try {
            	hideMsgAguardo();
            	var r = $.parseJSON(response);
                var registros = $(".divRegistros","#divBorderosChecagem");
            	if(r.status=='erro'){
            		showError("error",r.mensagem,'Alerta - Ayllos','cNrdconta.focus();');
                    registros.html('');
            	}
            	else{
                    registros.parent().find("table").remove();                   //remove o cabecalho para poder regerar o formatatabela
                    registros.html(r.html);
                    formataLayoutTabela();
            	}
                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'cNrdconta.focus();');
            }
        }
    });
    return false;
}

function analisarTitulo(){
    var nrdconta = normalizaNumero(borderoSelecionado.nrdconta);
    var nrborder = normalizaNumero(borderoSelecionado.nrborder);
    if(nrdconta==0 || nrborder==0){
        showError("error","Selecione um border&ocirc; para continuar a an&aacute;lise","Alerta - Ayllos","cNrdconta.focus()");
    }
    else{
        showMsgAguardo('Aguarde, buscando dados ...');
        $.ajax({
            type: 'POST',
            url: UrlSite + 'telas/aprdes/bordero_mesa_titulos.php',
            data: {
                nrdconta: nrdconta,
                nrborder: nrborder,
                redirect: 'script_ajax'
            },
            error: function(objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'cNrdconta.focus();');
            },
            success: function(response) {
                try {
                    divRotina.html(response);
                    formataLayoutTitulos();
                    exibeRotina(divRotina);
                    ajustarCentralizacao();
                    return false;
                } catch (error) {
                    console.log(error);
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'cNrdconta.focus();');
                }
            }
        });
    }
    return false;
}

function formataLayoutTitulos(){
    var div = 'divTitulosChecagem';
    $('#'+div).css('width','1100px');
    var divDetalhes = 'divDetalheTitulo'
    $('#'+divDetalhes).css('width','800px');

    var divRegistro = $('div.divRegistros','#'+div);        
    var tabela      = $('table', divRegistro );
                    
    divRegistro.css('height','360px');
    
    var ordemInicial = new Array();
            
    var arrayLargura = new Array();
    arrayLargura[0] = '';
    arrayLargura[1] = '90px';
    arrayLargura[2] = '135px';
    arrayLargura[3] = '70px';
    arrayLargura[4] = '80px';
    arrayLargura[5] = '80px';
    arrayLargura[6] = '95px';
    arrayLargura[7] = '95px';
    arrayLargura[8] = '70px';
    
    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'center';
    arrayAlinha[3] = 'right';
    arrayAlinha[4] = 'center';
    arrayAlinha[5] = 'center';
    arrayAlinha[6] = 'center';
    arrayAlinha[7] = 'center';
    arrayAlinha[8] = 'center';
                    
    tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
    
    $('tbody > tr',tabela).each( function() {
        if ( $(this).hasClass('corSelecao') ) {
            $(this).focus();
            $(this).click();

        }
    });
}

function formataLayoutTabela(){
	var div = 'divBorderosChecagem';
	$('#'+div).css('width','940px');

	var divRegistro = $('div.divRegistros','#'+div);		
	var tabela      = $('table', divRegistro );
					
	divRegistro.css('height','410px');
	
	var ordemInicial = new Array();
			
    var arrayLargura = new Array();
    arrayLargura[0] = '80px';
    arrayLargura[1] = '80px';
    arrayLargura[2] = '130px';
    arrayLargura[3] = '150px';
    arrayLargura[4] = '150px';
    arrayLargura[5] = '150px';
    arrayLargura[6] = '';
    
            
    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'right';
    arrayAlinha[3] = 'center';
    arrayAlinha[4] = 'center';
    arrayAlinha[5] = 'center';
    arrayAlinha[6] = 'center';
    arrayAlinha[7] = 'center';
					
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
	
	$('tbody > tr',tabela).each( function() {
		if ( $(this).hasClass('corSelecao') ) {
			$(this).focus();
            $(this).click();
		}
	});
	controlaPesquisas();
}

function formataLayoutDetalhes(){
    //restrições    
    var divRestricoes                   = $('div.divRestricoes','#formParecer');
    var tabelaRestricoes                = $('table', divRestricoes );
    
    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0] = '24%';
    arrayLargura[1] = '25%';
    arrayLargura[2] = '24%';
    arrayLargura[3] = '25%';
    

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'center';
    arrayAlinha[3] = 'center';

    divRestricoes.css({'height': '210px', 'padding-bottom': '1px'});

    tabelaRestricoes.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );

    //parecer    
    var divParecer                   = $('div.divRegistrosPareceres','#formParecer');
    var tabelaParecer                = $('table', divParecer );
    
    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0] = '80px';
    arrayLargura[1] = '200px';
    arrayLargura[2] = '';
    

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'left';
    arrayAlinha[2] = 'left';

    divParecer.css({'height': '70px', 'padding-bottom': '1px'});

    tabelaParecer.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );


    // campos
    var cNmdsacad = $("#nmdsacad", "#formParecer");
    cNmdsacad.css({'width': '450px'});

    var camposFiltros = $("input[type='text'],select",'#formParecer');
    camposFiltros.desabilitaCampo();

    //criticas
    var divRegistrosTitulos             = $('div.divRegistrosTitulos','#formParecer');        
    var divRegistrosTitulosSelecionados = $('div.divRegistrosTitulosSelecionados','#formParecer');        
    var tabelaTitulos                   = $('table', divRegistrosTitulos );
    var tabelaTitulosSelecionados       = $('table', divRegistrosTitulosSelecionados );



    var ordemInicial = new Array();
            
    var arrayLargura = new Array();
    arrayLargura[0] = '48%';
    arrayLargura[1] = '50%';
    

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'center';
    
                    
    $('#formParecer').css({'margin-top': '5px'});
    divRegistrosTitulos.css({'height': '150', 'padding-bottom': '2px'});
    divRegistrosTitulosSelecionados.css({'height': '150', 'padding-bottom': '2px'});

    tabelaTitulos.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
    tabelaTitulosSelecionados.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
    
    $('tbody > tr',tabelaTitulos).each( function() {
        if ( $(this).hasClass('corSelecao') ) {
            $(this).focus();        
        }
    });
    $('tbody > tr',tabelaTitulosSelecionados).each( function() {
        if ( $(this).hasClass('corSelecao') ) {
            $(this).focus();        
        }
    });


    layoutPadrao();
    ajustarCentralizacao();
}

function selecionaBordero(nrdconta,nrborder){
    borderoSelecionado = {
        nrdconta:nrdconta,
        nrborder:nrborder
    }
}
function selecionaTitulo(chave){
    tituloSelecionado = {
        chave:chave
    }
}

function limpaFormulario(){
	formFiltrosChecagem.reset();
	cNrdconta.focus();
}

function encerraRotina(){
    divRotina.html('');
    buscarBorderos();
    fechaRotina(divRotina);
    bloqueiaFundo(divRotina);
}

function concluirChecagem(){
    nomeForm = "formFinalizarChecagem";
    var nrdconta = normalizaNumero($('#nrdconta', '#' + nomeForm).val());
    var nrborder = normalizaNumero($('#nrborder', '#' + nomeForm).val());
    var titulos = $("input[name*='titulos']",'#'+nomeForm);
    var envioTitulos = [];
    var erro = false;
    titulos.each(function(){
        var insitmch = $(this).parent().parent().find("select[name*='insitmch']").val(); 
        if(!insitmch || insitmch==''){
            showError('error', 'Preencha todos os campos de Aprova&ccedil;&atilde;o', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
            erro = true;
            return false;
        }
        var v = $(this).val()+";"+insitmch;
        envioTitulos.push(v);
    });
    if(erro){
        return false;
    }
    cTodosOpcao.removeClass('campoErro');
    showMsgAguardo('Aguarde, buscando dados ...');
    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/aprdes/manter_rotina.php',
        data: {
            operacao: 'CONCLUI_CHECAGEM',
            nrdconta: nrdconta,
            nrborder: nrborder,
            titulos: envioTitulos,
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'cNrdconta.focus();');
        },
        success: function(response) {
            try {
                hideMsgAguardo();
                var r = $.parseJSON(response);
                if(r.status=='erro'){
                    showError("error",r.mensagem,'Alerta - Ayllos','');
                }
                else{
                    showError("inform",r.mensagem,'Alerta - Ayllos','buscarBorderos();encerraRotina();');
                }
                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'cNrdconta.focus();');
            }
        }
    });
    return false;
}

function visualizarDetalhes(){
    var nrdconta = normalizaNumero($('#nrdconta', '#divListaTitulos').val());
    var nrborder = normalizaNumero($('#nrborder', '#divListaTitulos').val());
    var chave = tituloSelecionado.chave;

    if(!chave){
        showError("error","Selecione um t&iacute;tulo","Alerta - Ayllos","cNrdconta.focus()");
    }
    else{
        showMsgAguardo('Aguarde, buscando dados ...');
        $.ajax({
            type: 'POST',
            url: UrlSite + 'telas/aprdes/bordero_mesa_titulos_detalhe.php',
            data: {
                nrdconta: nrdconta,
                nrborder: nrborder,
                chave: chave,
                redirect: 'script_ajax'
            },
            error: function(objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'cNrdconta.focus();');
            },
            success: function(response) {
                try {
                    $("#divListaTitulos #divTitulosChecagem").hide();
                    $("#divListaTitulos #divDetalheTitulo").html(response).show();
                    ajustarCentralizacao();
                    return false;
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'cNrdconta.focus();');
                }
            }
        });
    }
    return false;
}

function gravaParecer(){
    var nrdconta    = normalizaNumero($('#nrdconta', '#divDetalheTitulo').val());
    var nrborder    = normalizaNumero($('#nrborder', '#divDetalheTitulo').val());
    var chave       = $('#chave', '#divDetalheTitulo').val();
    var dsparecer   = $('#dsparecer', '#divDetalheTitulo').val();
    var operacao    = "GRAVA_PARECER";

    if(!chave){
        showError("error","Selecione um t&iacute;tulo","Alerta - Ayllos","dsparecer.focus();bloqueiaFundo(divRotina)");
    }
    else if(dsparecer==''){
        showError("error","Preencha o parecer","Alerta - Ayllos","dsparecer.focus();bloqueiaFundo(divRotina)");
    }
    else{
        showMsgAguardo('Aguarde, buscando dados ...');
        $.ajax({
            type: 'POST',
            url: UrlSite + 'telas/aprdes/manter_rotina.php',
            data: {
                operacao:operacao,
                nrdconta: nrdconta,
                nrborder: nrborder,
                chave: chave,
                dsparecer: dsparecer,
                redirect: 'script_ajax'
            },
            error: function(objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'cNrdconta.focus();');
            },
            success: function(response) {
                try {
                    hideMsgAguardo();
                    var r = $.parseJSON(response);
                    if(r.status=='erro'){
                        showError("error", r.mensagem, 'Alerta - Ayllos','bloqueiaFundo(divRotina);');
                    }else{
                        showError("inform",r.mensagem,'Alerta - Ayllos','voltarDetalhe();bloqueiaFundo(divRotina);');
                    }
                    ajustarCentralizacao();
                    return false;
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'cNrdconta.focus();');
                }
            }
        });
    }
    return false;
}

function voltarDetalhe(){
    $("#divListaTitulos #divDetalheTitulo").html('').hide();
    $("#divListaTitulos #divTitulosChecagem").show();
}
function ajustarCentralizacao() {
    var x = $.browser.msie ? $(window).innerWidth() : $("body").offset().width;
    x = x - 178;
    $('#divRotina').css({ 'width': x + 'px' });
    $('#divRotina').centralizaRotinaH();
    return false;
}

function formataTabelaCriticas(div){
    var tabela = div.find("table");
    div.zebraTabela();
    tabela.css("text-align","center");
}