/***********************************************************************
      Fonte: lancamentos_futuros.js
      Autor: Guilherme
      Data : Fevereiro/2007                Ultima Alteracao: 04/11/2017

      Objetivo  : Biblioteca de funcoes da rotina OCORRENCIAS da tela
                  ATENDA

      Alteracoes:
              30/06/2011 - Alterado para layout padrão (Rogerius - DB1).		
 	  
	          21/07/2015 - Exclusao de lancamentos automaticos (Tiago).

            27/05/2016 - Inclusao de selecao dos debitos. (Jaison/James)

			25/07/2016 - Adicionado função controlaFoco  (Evandro - RKAM)
            
             04/11/2017 - Ajuste permitir apenas consulta de extrato quando contas demitidas
                           (Jonata - RKAM P364).
 ***********************************************************************/

var glb_gen_dstabela, glb_gen_cdhistor, glb_gen_recid; 

// Fun&ccedil;&atilde;o para acessar op&ccedil;&otilde;es da rotina
function acessaOpcaoAba(nrOpcoes, id, opcao) {
	if (opcao == "0") {	// Op&ccedil;&atilde;o Principal
		var msg = "lan&ccedil;amentos futuros";
	}
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando " + msg + " ...");
	
	// Atribui cor de destaque para aba da op&ccedil;&atilde;o
	for (var i = 0; i < nrOpcoes; i++) {
		if (id == i) { // Atribui estilos para foco da op&ccedil;&atilde;o
            $("#linkAba" + id).attr("class", "txtBrancoBold");
            $("#imgAbaEsq" + id).attr("src", UrlImagens + "background/mnu_sle.gif");
            $("#imgAbaDir" + id).attr("src", UrlImagens + "background/mnu_sld.gif");
            $("#imgAbaCen" + id).css("background-color", "#969FA9");
			continue;			
		}
		
        $("#linkAba" + i).attr("class", "txtNormalBold");
        $("#imgAbaEsq" + i).attr("src", UrlImagens + "background/mnu_nle.gif");
        $("#imgAbaDir" + i).attr("src", UrlImagens + "background/mnu_nld.gif");
        $("#imgAbaCen" + i).css("background-color", "#C6C8CA");
	}	
	
	// Carrega conte&uacute;do da op&ccedil;&atilde;o atrav&eacute;s de ajax
	$.ajax({		
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/atenda/lancamentos_futuros/principal.php",
		data: {
			nrdconta: nrdconta,
			sitaucaoDaContaCrm: sitaucaoDaContaCrm,
			redirect: "html_ajax"
		},
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')) )");
		},
        success: function (response) {
			$("#divConteudoOpcao").html(response);
            controlaFoco(opcao);
		}				
	}); 		
}

function controlaFoco(opcao) {
    $('#divConteudoOpcao').each(function () {
        $(this).find("#divBotoes > a").first().addClass("FirstInputModal").focus();
        $(this).find("#divBotoes > a").last().addClass("LastInputModal");
    });

    //Se estiver com foco na classe FluxoNavega
    $(".FirstInputModal").focus(function () {
        $(this).bind('keydown', function (e) {
            if (e.keyCode == 13) {
                $(this).click();
            }
        });
    });

    $(".LastInputModal").focus(function () {
        var pressedShift = false;

        $(this).bind('keyup', function (e) {
            if (e.keyCode == 16) {
                pressedShift = false;//Quando tecla shift for solta passa valor false 
            }
        })

        $(this).bind('keydown', function (e) {
            e.stopPropagation();
            e.preventDefault();

            if (e.keyCode == 13) {
                $('.LastInputModal').click();
            }

            if (e.keyCode == 16) {
                pressedShift = true;//Quando tecla shift for pressionada passa valor true 
            }
            if ((e.keyCode == 9) && pressedShift == true) {
                return setFocusCampo($(target), e, false, 0);
            }
            else if (e.keyCode == 9) {
                $(".FirstInputModal").focus();
            }
        });

    });

    $(".FirstInputModal").focus();

    $(".FirstInputModal").focus();
}

function controlaLayout() {

	// tabela	
	var divRegistro = $('div.divRegistros');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
	var btVoltar    = $('#btVoltar','#divBotoes');
	var btExcluir   = $('#btExcluir','#divBotoes');
	var btDebitar   = $('#btDebitar','#divBotoes');
	
	divRegistro.css({ 'height': '120px', 'width': '650px', 'overflow-y': 'auto' });
	
	var ordemInicial = new Array();
    ordemInicial = [[0, 0]];
			
	var arrayLargura = new Array();
    arrayLargura[0] = '15px';
    arrayLargura[1] = '56px';
    arrayLargura[2] = '225px';
    arrayLargura[3] = '175px';
    arrayLargura[4] = '25px';
	
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'left';
    arrayAlinha[3] = 'right';
    arrayAlinha[4] = 'center';
    arrayAlinha[5] = 'right';
	
	var metodoTabela = 'metodtab();';
	
    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

    // Botoes
    btVoltar.unbind('click').bind('click', function () {
        encerraRotina(true);
        return false;
    });

    habilitaBotao('btExcluir', 'D'); // Desabilitar
    habilitaBotao('btDebitar', 'D'); // Desabilitar
	
	// Botoes
	btVoltar.unbind('click').bind('click',function() {
		encerraRotina(true);				
		return false;
	});
		
    habilitaBotao('btExcluir', 'D'); // Desabilitar
    habilitaBotao('btDebitar', 'D'); // Desabilitar

    $('label[for="vltotal"]').addClass('rotulo txtNormalBold');
    $('#vltotal').addClass('campo').css({ 'width': '100px', 'text-align': 'right' }).desabilitaCampo();
		}
		
function confirmaExclusaoLanctoFut(){
	showConfirmacao('Confirma a exclus&atilde;o do lan&ccedil;amento?','Confirma&ccedil;&atilde;o - Ayllos','excluirLanctoFut();','bloqueiaFundo(divRotina)','sim.gif','nao.gif');	
}

function excluirLanctoFut(){

	var qtexclu = 0;

    $("input[class='clsCheckbox']:checked").each(function () {
        glb_gen_recid = $(this).attr('recid');
        if (normalizaNumero(glb_gen_recid) > 0) {
            glb_gen_dstabela = $(this).attr('dstabela');
            glb_gen_cdhistor = $(this).attr('cdhistor');
            qtexclu = qtexclu + 1;
        }
	}); 
	
    if (qtexclu != 1) {
        showError("error","Selecione apenas um registro.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
    }
	
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

function verificaCheckbox() {
    var vltotal = 0;
    var qtexclu = 0;
    var qtdebit = 0;
    $("input[class='clsCheckbox']:checked").each(function () {
        if (normalizaNumero($(this).attr('recid')) > 0 || // Excluir
            normalizaNumero($(this).attr('fldebito')) > 0) { // Debitar
            vltotal = vltotal + parseFloat($(this).val());
            qtexclu = qtexclu + (normalizaNumero($(this).attr('recid')) > 0 ? 1 : 0);
            qtdebit = qtdebit + (normalizaNumero($(this).attr('fldebito')) > 0 ? 1 : 0);
        } else {
            $(this).prop('checked', false);
        }
	});	
	
    // Somente habilita se foi selecionado apenas um registro com permissao de exclusao
    if (qtexclu == 1 && qtdebit == 0) {
        habilitaBotao('btExcluir', 'H'); // Habilitar
    } else {
        habilitaBotao('btExcluir', 'D'); // Desabilitar
    }

    // Somente habilita se foi selecionado apenas registros de debito
    if (qtexclu == 0 && qtdebit > 0) {
        habilitaBotao('btDebitar', 'H'); // Habilitar
    } else {
        habilitaBotao('btDebitar', 'D'); // Desabilitar
}

    $('#vltotal').val(vltotal == 0 ? '' : number_format(vltotal,2,',','.'));
}
	
function habilitaBotao(botao, opcao) {
    if (opcao == 'D') {
        // Desabilitar
        $("#" + botao).prop("disabled",true).addClass("botaoDesativado").attr("onClick","return false;");
    } else {
        // Habilitar
        var btLink = botao == 'btExcluir' ? 'confirmaExclusaoLanctoFut();' : 'confirmaDebitoLanctoFut();';
        $("#" + botao).prop("disabled",false).removeClass("botaoDesativado").attr("onClick",btLink);
    }
	}		

function confirmaDebitoSemSaldo(msg) {
	showConfirmacao(msg,'Confirma&ccedil;&atilde;o - Ayllos','pedeSenhaCoordenador(2,"validarDebitarLanctoFut(\'D\');","divRotina");','bloqueiaFundo(divRotina)','sim.gif','nao.gif');	
}

function confirmaDebitoLanctoFut() {
	showConfirmacao('Confirma o d&eacute;bito do lan&ccedil;amento?','Confirma&ccedil;&atilde;o - Ayllos','validarDebitarLanctoFut(\'V\');','bloqueiaFundo(divRotina)','sim.gif','nao.gif');	
}

function validarDebitarLanctoFut(acao) { // acao => 'D'ebitar - 'V'alidar
    var qtselec  = 0;
    var qtdebit  = 0;
    var vlcampos = '';

    $("input[class='clsCheckbox']:checked").each(function () {
        if (normalizaNumero($(this).attr('fldebito')) > 0) {
            vlcampos += (vlcampos == '' ? '' : ';') + 
                        $(this).attr('dtrefere') + ',' +
                        $(this).attr('cdagenci') + ',' +
                        $(this).attr('cdbccxlt') + ',' +
                        $(this).attr('nrdolote') + ',' +
                        $(this).attr('nrseqdig');
            qtdebit = qtdebit + 1;
        }
        qtselec = qtselec + 1;
    });
	
    if (qtselec != qtdebit) {
        showError("error","Selecione apenas registro de d&eacute;bito.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }
	
    showMsgAguardo("Aguarde, processando...");
		
	$.ajax({		
		type: "POST",
		dataType: "html",
        url: UrlSite + "telas/atenda/lancamentos_futuros/debitar_lancamentos.php",
		data: {
            acao: acao,
            nrdconta: nrdconta,
            vlcampos: vlcampos,
			redirect: "script_ajax"
		}, 
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
        success: function (response) {
			try {				
				eval(response);
            } catch (error) {
				hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});				

}
