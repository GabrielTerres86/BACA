/*!
 * FONTE        : simulacao.js
 * CRIAÇÃO      : Marcelo L. Periera (GATI)
 * DATA CRIAÇÃO : 22/06/2011
 * OBJETIVO     : Biblioteca de funções na rotina Simulação da tela ATENDA
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 * 000: [17/08/2011] Criada condição para não bloquear a divPrincipal quando abrir a tela de inclusão - Marcelo L. Pereira (GATI)
 * 001: [20/09/2011] Adicionada coluna de data de pagamento - Marcelo L. Pereira (GATI)
 * 002: [30/03/2012] Incluir campo %CET (Gabriel).
 * 003: [26/06/2012] Alterado funcao carregarImpressaoSimulacao(), novo esquema para impressao. (Jorge)
 * 004: [09/07/2012] Retirado campo "redirect" popup. (Jorge)
 * 005: [21/11/2012] Arrumar listagem das prestacoes ao incluir/alterar no firefox e deixar de esconder a msg de aguarde quando sao chamadas duas procedures (Gabriel)
 * 006: [04/08/2014] Ajustes referentes ao projeto CET (Lucas R./Gielow)
 * 007: [30/06/2015] Ajustes referente Projeto 215 - DV 3 (Daniel)
 * 008: [20/09/2017] Projeto 410 - Incluir campo Indicador de financiamento do IOF (Diogo - Mouts)
 * 009: [13/12/2018] Projeto 298.2 - Inclusos novos campos tpemprst e campos de carencia (Andre Clemer - Supero)
 * 010: [01/07/2019] Projeto 438 - Bloquear botões Alterar e Gerar Proposta para Simulações de origem 3 e 10. (Douglas Pagel / AMcom)
 */

//******************************

var arraySimulacoes = new Array();
var vlparepr;
//***************************************************

//**************************************************
//**       GERENCIAMENTO DA ROTINA DE SIMULAÇÕES  **
//**************************************************
var aux_cdmodali_simulacao = '';
//Controla as operações da descrição de simulações
function controlaOperacaoSimulacoes(operacao, nrSimulaInc) {
    var aux_tpfinali = 0;
		
    if (operacao == 'A_SIMULACAO' || operacao == 'E_SIMULACAO' || operacao == 'C_SIMULACAO' || operacao == 'IMP_SIMULACAO' || operacao == 'GPR') {

        indarray = '';
        $('table > tbody > tr', '#divProcSimulacoesTabela > div.divRegistros').each(function() {
            if ($(this).hasClass('corSelecao')) {
                indarray = $('input', $(this)).val();
                auxind = indarray;


                aux_dtlibera = $(this).find('#dtlibera > span').text();
                aux_dtdpagto = $(this).find('#dtdpagto > span').text();
                aux_tpfinali = $(this).find('#tpfinali').val();
                aux_cdmodali_simulacao = $(this).find('#cdmodali').val();
                aux_tpemprst = $(this).find('#tpemprst').val();
				aux_cdorigem = $(this).find('#cdorigem').val();
            }
        });
        if (indarray == '') {

            showError('error', 'Nenhuma simulação selecionada!', 'Alerta - Aimaro', 'bloqueiaFundo($("#divUsoGenerico"))');

            return false;

        }
    }

    switch (operacao) {

        //Inclusão. Mostra formulario de simulação vazio.	
        case 'I_SIMULACAO':
            showMsgAguardo("Aguarde, Abrindo formul&aacute;rio para inclus;&atilde;o...");
            controlaLayoutSimulacoes(operacao, auxind);
            break;

            //Mostra o formulario de simulação
        case 'A_SIMULACAO':
			if (aux_cdorigem == 3 || aux_cdorigem == 10) {
        	    showError('error', 'Não é permitido alterar simulação com origem em canais digitais!', 'Alerta - Aimaro', 'hideMsgAguardo(); bloqueiaFundo($("#divUsoGenerico"));');
        		return false;
        	}
            showMsgAguardo("Aguarde, Abrindo formul&aacute;rio para altera&ccedil;&atilde;o...");
            //Preencho o formulario com os dados da simulação selecionada
            buscarDadosSimulacao(auxind, operacao,'');
            //Oculta a tabela e mostra o formulario
            break;

            //Mostra o formulario de simulação somente para consulta
        case 'C_SIMULACAO':
            showMsgAguardo("Aguarde, Abrindo visualiza&ccedil;&atilde;o de dados...");
            //Preencho o formulario com os dados da simulação selecionada
            buscarDadosSimulacao(auxind, operacao,'');
            break;
        case 'D_SIMULACAO':
            showMsgAguardo("Aguarde, Abrindo visualiza&ccedil;&atilde;o de dados...");
            //Preencho o formulario com os dados da simulação selecionada
            buscarDadosSimulacao(auxind, operacao,'');
            break;
        case 'E_SIMULACAO':
            showConfirmacao('Deseja excluir simula&ccedil;&atilde;o ' + auxind + ' ?', 'Confirma&ccedil;&atilde;o - Aimaro', 'excluirSimulacao(' + auxind + ')', 'bloqueiaFundo($(\'#divUsoGenerico\'))', 'sim.gif', 'nao.gif');
            break;
        case 'IMP_SIMULACAO':
            tpemprst = parseInt(aux_tpemprst);
            showMsgAguardo("Aguarde, Gerando impress&atilde;o da simula&ccedil;&atilde;o...");
            carregarImpressaoSimulacao(auxind);
            break;
        case 'GPR':
            if (aux_cdorigem == 3 || aux_cdorigem == 10) {
        	    showError('error', 'Não é permitido gerar proposta de simulação com origem em canais digitais!', 'Alerta - Aimaro', 'hideMsgAguardo(); bloqueiaFundo($("#divUsoGenerico"));');
        		return false;
        	}
            var aux_dtmvtolt = $('#dtmvtolt', '#divProcSimulacoesTabela').val();

            // Data Liberação
            var dtlibera = parseInt(aux_dtlibera.split("/")[2].toString() + aux_dtlibera.split("/")[1].toString() + aux_dtlibera.split("/")[0].toString());

            // Data Moviemnto
            var dtmvtolt = parseInt(aux_dtmvtolt.split("/")[2].toString() + aux_dtmvtolt.split("/")[1].toString() + aux_dtmvtolt.split("/")[0].toString());

            // Data Pagamento
            var dtdpagto = parseInt(aux_dtdpagto.split("/")[2].toString() + aux_dtdpagto.split("/")[1].toString() + aux_dtdpagto.split("/")[0].toString());


            if (dtlibera != dtmvtolt) {
                showError("error", "Data de Liberação do recurso deve ser igual a data atual. Altere a Simulação.", "Alerta - Aimaro", "bloqueiaFundo($('#divRotina'));", false);
                return false;
            }

            if (dtdpagto < dtmvtolt) {
                showError("error", "Data de Pagamento deve ser maior ou igual a data atual. Altere a Simulação.", "Alerta - Aimaro", "bloqueiaFundo($('#divRotina'));", false);
                return false;
            }

            showMsgAguardo("Aguarde, Gerando proposta de empr&eacute;stimo...");
            $('#divProcSimulacoesFormulario').remove();
            $('#divProcSimulacoesTabela').remove();
            $('#divUsoGenerico').html('');
            fechaRotina($('#divUsoGenerico'));
            limpaDivGenerica();

            exibeRotina($('#divRotina'));

            var operacao = ( aux_tpfinali > 0 ) ? 'PORTAB_CRED_I' : 'GPR';

            controlaOperacao(operacao);
            //buscarDadosSimulacao(auxind, operacao);
            break;
        case 'C_INCLUSAO':
            showMsgAguardo("Aguarde, Abrindo visualiza&ccedil;&atilde;o de dados...");
            //Preencho o formulario com os dados da simulação selecionada
            operacao = 'C_SIMULACAO';
            buscarDadosSimulacao(nrSimulaInc, operacao, '');
            break;
    }
    return false;
}

// Controla o layout da descrição de bens
function controlaLayoutSimulacoes(operacao, nrSimulacao) {

    // Operação consultando
    var cTodos = $('#tpemprst,#vlemprst,#qtparepr,#cdlcremp,#cdfinemp,#dtlibera,#dtdpagto,#idcarenc,#dtcarenc,#percetop', '#frmSimulacao');
    var cTpemprst = $('#tpemprst', '#frmSimulacao');
    var cValor = $('#vlemprst', '#frmSimulacao');
    var cQtdParcela = $('#qtparepr', '#frmSimulacao');
    var cLinhaCredito = $('#cdlcremp', '#frmSimulacao');
    var cDtLiberacao = $('#dtlibera', '#frmSimulacao');
    var cDtPagto = $('#dtdpagto', '#frmSimulacao');
    var cIdcarenc = $('#idcarenc', '#frmSimulacao');
    var cDtcarenc = $('#dtcarenc', '#frmSimulacao');
    var cDescLinha = $('#dslcremp', '#frmSimulacao');
    var cPercetop = $('#percetop', '#frmSimulacao');
    var cCdmodali = $('#cdmodali', '#frmSimulacao');

    //Diogo
    var cValorIof = $('#vliofepr', '#frmSimulacao');
    var cValorTarifa = $('#vlrtarif', '#frmSimulacao');
    var cValorTotal = $('#vlrtotal', '#frmSimulacao');

    var cFinalidade = $('#cdfinemp', '#frmSimulacao');
    var cDescFinali = $('#dsfinemp', '#frmSimulacao');

    // Controla largura dos campos
    $('label', '#frmSimulacao').css({'width': '195px'}).addClass('rotulo');

    cTpemprst.addClass('rotulo').css('width', '110px');
    cValor.addClass('rotulo moeda').css('width', '90px');
    cQtdParcela.addClass('rotulo').css('width', '50px').setMask('INTEGER', 'zz9', '', '');
    cPercetop.addClass('porcento').css('width', '45px');
    cLinhaCredito.css('width', '35px').attr('maxlength', '4');
    cDtLiberacao.css('width', '90px').setMask("DATE", "", "", "divRotina");
    cDtPagto.css('width', '90px').setMask("DATE", "", "", "divRotina");
    cIdcarenc.addClass('rotulo').css('width', '108px');
    cDtcarenc.css('width', '108px').setMask("DATE", "", "", "divRotina");
    cDescLinha.css('width', '230px').desabilitaCampo();

    cFinalidade.css('width', '35px').attr('maxlength', '3');
    cDescFinali.css('width', '230px').desabilitaCampo();
    cCdmodali.css('width', '288px').desabilitaCampo();

    //Diogo
    cValorIof.addClass('rotulo moeda').css('width', '90px').desabilitaCampo();
    cValorTarifa.addClass('rotulo moeda').css('width', '90px').desabilitaCampo();
    cValorTotal.addClass('rotulo moeda').css('width', '90px').desabilitaCampo();

    if (operacao == 'C_SIMULACAO' || operacao == "E_SIMULACAO") {
        nomeForm = 'frmSimulacao';

        $('#divProcSimulacoesTabela').css('display', 'none');
        $('#divProcSimulacoesFormulario').css('display', 'block');
        $('#divProcParcelasTabela').css('display', 'block');

        // Formata o tamanho da tabela
        $('#divProcParcelasTabela').css({'height': '175px', 'width': '420px'});

        // Monta Tabela dos Itens
        $('#divProcParcelasTabela > div > table > tbody').html('');

        for (var i in arraySimulacoes) {
            $('#divProcParcelasTabela > div > table > tbody').append('<tr></tr>');
            $('#divProcParcelasTabela > div > table > tbody > tr:last-child').append('<td>' + arraySimulacoes[i]['nrparepr'] + '</td>');
            $('#divProcParcelasTabela > div > table > tbody > tr:last-child').append('<td>' + arraySimulacoes[i]['dtparepr'] + '</td>');
            $('#divProcParcelasTabela > div > table > tbody > tr:last-child').append('<td><span>' + arraySimulacoes[i]['vlparepr'].replace(',', '.') + '</span>' + number_format(parseFloat(arraySimulacoes[i]['vlparepr'].replace(/[.R$ ]*/g, '').replace(',', '.')), 2, ',', '.') + '</td>');
            vlparepr = number_format(parseFloat(arraySimulacoes[i]['vlparepr'].replace(',', '.')), 2, ',', '.');
        }

        if (operacao == "C_SIMULACAO")
            $('#btSalvar', '#divBotoesFormSimulacao').css('display', 'none');
        else {
            $('#btSalvar', '#divProcSimulacoesFormulario').bind('click', function() {
                showConfirmacao('Deseja excluir simula&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Aimaro', 'excluirSimulacao(' + nrSimulacao + ')', 'bloqueiaFundo($(\'#divUsoGenerico\'))', 'sim.gif', 'nao.gif');
                return false;
            });
        }
        cTodos.desabilitaCampo();

        var divRegistro = $('#divProcParcelasTabela > div.divRegistros');
        var tabela = $('table', divRegistro);

        divRegistro.css('height', '150px');

        var ordemInicial = new Array();
        ordemInicial = [[0, 0]];

        var arrayLargura = new Array();
        arrayLargura[0] = '140px';
        arrayLargura[1] = '140px';

        var arrayAlinha = new Array();
        arrayAlinha[0] = 'right';
        arrayAlinha[1] = 'right';
        arrayAlinha[2] = 'right';

        tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');
    } else {

        var qtprebem, valor;

        nomeForm = 'frmSimulacao';
        controlaPesquisas();

		//consiste simulacao de portabilidade para PJ
		cCdmodali.unbind('change').bind('change', function() {
			if ( $.trim(inpessoa) == 2 ) {
				showError('error', 'Finalidade não permitida para conta PJ.', 'Alerta - Aimaro', 'bloqueiaFundo($("#divUsoGenerico"),\'qtparepr\',\'frmSimulacao\')');	
				cCdmodali.val('0');
			}
		});	
	
        // Se inclusão, limpar dados do formulário
        if (operacao == 'I_SIMULACAO') {
            $('#frmSimulacao').limpaFormulario();
        } else if (operacao == 'A_SIMULACAO') {
            if ( cCdmodali.val() != 0 ) {
                cCdmodali.habilitaCampo();
            }
            //caso altere a modalidade limpa campo linha de credito
            cCdmodali.unbind('change').bind('change', function() {
                cLinhaCredito.val('');
                cDescLinha.val('');
            });
        }

        $('#divProcParcelasTabela').css('display', 'none');
        $('#divProcSimulacoesFormulario').css('display', 'block');
        $('#divProcSimulacoesTabela').css('display', 'none');

        $('#btSalvar', '#divProcSimulacoesFormulario').bind('click', function() {

            incluirAlterarSimulacao(operacao, nrSimulacao);

            //	$('#divProcSimulacoesFormulario').css({'height':'410px'});


        });

        $('#tpemprst', '#' + nomeForm).unbind('change').bind('change', function() {

            // Reseta os campos Finalidade e Linha de Credito
            cLinhaCredito.val('');
            cDescLinha.val('');
            cFinalidade.val('');
            cDescFinali.val('');

            verificaQtDiaLib();
            exibeLinhaCarencia('#' + nomeForm);
        });

        // @TODO: Verificar regra
        $('#idcarenc', '#' + nomeForm).unbind('change').bind('change', function() {
            var dtlibera = $('#dtlibera', '#' + nomeForm).val();
            var dtdpagto = $('#dtdpagto', '#' + nomeForm).val();

            if ( dtlibera == "" ) {
                showError('error', 'Data de Libera&ccedil;&atilde;o deve ser informada.', 'Alerta - Aimaro', 'bloqueiaFundo($("#divUsoGenerico"),\'dtlibera\',\'frmSimulacao\')');
                return this.selectedIndex = 0;
            }

            if (!validaData(dtlibera)) {
                showError('error', 'Data de Libera&ccedil;&atilde;o inv&aacute;lida.', 'Alerta - Aimaro', 'bloqueiaFundo($("#divUsoGenerico"),\'dtlibera\',\'frmSimulacao\')');
                return this.selectedIndex = 0;
            }
            
            if ( dtdpagto == "" ) {
                showError('error', 'Data do Pagamento da Primeira Parcela deve ser informada.', 'Alerta - Aimaro', 'bloqueiaFundo($("#divUsoGenerico"),\'dtdpagto\',\'frmSimulacao\')');
                return this.selectedIndex = 0;
            }
            
            calculaDataCarencia('#' + nomeForm);
        });

        $('#dtdpagto', '#' + nomeForm).unbind('blur').bind('blur', function() {
                // Se for Pos Fixado
                if ($('#tpemprst', '#' + nomeForm).val() == 2) {
                    calculaDataCarencia('#' + nomeForm);
                }
         });

        // Formata o tamanho do Formulário
        $('#divProcSimulacoesFormulario').css({'height': 'auto', 'width': '560px'});

        // Adicionando as classes
        cTodos.removeClass('campoErro').habilitaCampo();
        cPercetop.desabilitaCampo(); //Lucas R.

        // Valida Quantidade de parcelas
        // Ao mudar a Quantidade de parcelas, não permitir valores menores ou iguais a zero
        cQtdParcela.change(function() {
            if ($(this).hasClass('campo')) {
                qtprebem = parseFloat(cQtdParcela.val().replace(',', '.').replace('', '0'));
                if (qtprebem <= 0) {
                    showError('error', 'Parcelas a pagar deve ser maior que zero.', 'Alerta - Aimaro', 'bloqueiaFundo($("#divUsoGenerico"),\'qtparepr\',\'frmSimulacao\')');
                } else {
                    cQtdParcela.removeClass('campoErro');
                }
            }
        });

        // Valida Valor da simulação de empréstimo
        cValor.change(function() {
            valor = parseFloat(cValor.val().replace(',', '.').replace('', '0'));
            if (valor <= 0) {
                showError('error', 'Valor da simulação de empréstimo deve ser maior que zero.', 'Alerta - Aimaro', 'bloqueiaFundo($("#divUsoGenerico"),\'vlemprst\',\'frmSimulacao\')');
            } else {
                cValor.removeClass('campoErro');
            }
        });
    }

    layoutPadrao();
    hideMsgAguardo();
    removeOpacidade('divConteudoOpcao');
    exibeLinhaCarencia('#' + nomeForm);

    if (operacao != 'C_SIMULACAO') {
        $('#tpemprst', '#divProcSimulacoesFormulario').focus();
    } else {
        $('#btContinuar', '#divProcSimulacoesTabela').focus();
    }
    
    bloqueiaFundo($('#divUsoGenerico'));
    return false;
}

// Inclui/altera uma simulação
function buscarDadosSimulacao(nrsimula, operacao, tela) {


    // Carrega conteúdo da opção através de ajax
    $.ajax({
        dataType: "html",
        type: "POST",
        url: UrlSite + "telas/atenda/emprestimos/simulacao/busca_dados_simulacao.php",
        data: {
            nrdconta: nrdconta,
            idseqttl: idseqttl,
            nrsimula: nrsimula,
            operacao: operacao,
            redirect: "script_ajax" // Tipo de retorno do ajax
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            try {
				
				if ( tela != '') {
					$('#divConteudoOpcao').html(tela);
				}		
				
                eval(response);
                hideMsgAguardo();
                if (operacao == 'GPR' || operacao == 'TI')
                    bloqueiaFundo($('#divRotina'));
                else
                    bloqueiaFundo($('#divUsoGenerico'));
					
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });

}

// Inclui/altera uma simulação
function incluirAlterarSimulacao(operacao, nrsimula) {
    var tpemprst = $("#tpemprst", "#divProcSimulacoesFormulario").val();
    var vlemprst = $("#vlemprst", "#divProcSimulacoesFormulario").val();
    var qtparepr = $("#qtparepr", "#divProcSimulacoesFormulario").val();
    var cdlcremp = $("#cdlcremp", "#divProcSimulacoesFormulario").val();
    var dtlibera = $("#dtlibera", "#divProcSimulacoesFormulario").val();
    var dtdpagto = $("#dtdpagto", "#divProcSimulacoesFormulario").val();
    var percetop = $("#percetop", "#divProcSimulacoesFormulario").val();
    var cdfinemp = $("#cdfinemp", "#divProcSimulacoesFormulario").val();
    var idcarenc = $("#idcarenc", "#divProcSimulacoesFormulario").val();
    var dtcarenc = $("#dtcarenc", "#divProcSimulacoesFormulario").val();
    // Campos de uso da PORTABILIDADE
    var tpfinali = $("#tpfinali", "#divProcSimulacoesFormulario").val();
    var cdmodali = $("#cdmodali option:selected", "#divProcSimulacoesFormulario").val();
    var idfiniof = $("#idfiniof option:selected", "#divProcSimulacoesFormulario").val();
	
    if ( tpfinali == 2 && cdmodali == 0 ) {
        showError("error", "Selecione uma modalidade", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");        
        return false;
    }

	
	if ( dtlibera == "" ) {
		 showError('error', 'Data de Liberação deve ser informada.', 'Alerta - Aimaro', 'bloqueiaFundo($("#divUsoGenerico"),\'dtlibera\',\'frmSimulacao\')');
		return false;
	}
	
	if ( dtdpagto == "" ) {
		 showError('error', 'Data do Pagamento da Primeira Parcela deve ser informada.', 'Alerta - Aimaro', 'bloqueiaFundo($("#divUsoGenerico"),\'dtdpagto\',\'frmSimulacao\')');
		return false;
	}

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, Salvando a simula&ccedil;&atilde;o...");

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        dataType: "html",
        type: "POST",
        url: UrlSite + "telas/atenda/emprestimos/simulacao/inclusao_alteracao.php",
        data: {
            nrdconta: nrdconta,
            idseqttl: idseqttl,
            vlemprst: vlemprst,
            qtparepr: qtparepr,
            cdlcremp: cdlcremp,
            dtlibera: dtlibera,
            dtdpagto: dtdpagto,
            operacao: operacao,
            nrsimula: nrsimula,
            percetop: percetop,
            cdfinemp: cdfinemp,
            idfiniof: idfiniof,
            tpemprst: tpemprst,
            idcarenc: idcarenc,
            dtcarenc: dtcarenc,
            redirect: "script_ajax" // Tipo de retorno do ajax
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            try {
                hideMsgAguardo();
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

// Exclui uma simulação
function excluirSimulacao(nrsimula) {
    showMsgAguardo("Aguarde, Excluindo simula&ccedil;&atilde;o...");

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        dataType: "html",
        type: "POST",
        url: UrlSite + "telas/atenda/emprestimos/simulacao/realiza_exclusao.php",
        data: {
            nrdconta: nrdconta,
            idseqttl: idseqttl,
            nrsimula: nrsimula,
            redirect: "script_ajax" // Tipo de retorno do ajax
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}


// Função para envio de formulário de impressao
function carregarImpressaoSimulacao(nrsimula) {

    $('#sidlogin', '#formImpressao').remove();
    $('#nrdconta', '#formImpressao').remove();
    $('#idseqttl', '#formImpressao').remove();
    $('#nrsimula', '#formImpressao').remove();
    $('#flgemail', '#formImpressao').remove();
    $('#tpemprst', '#formImpressao').remove();

    // Insiro input do tipo hidden do formulário para enviá-los posteriormente
    $('#formImpressao').append('<input type="hidden" id="sidlogin" name="sidlogin" />');
    $('#formImpressao').append('<input type="hidden" id="nrdconta" name="nrdconta" />');
    $('#formImpressao').append('<input type="hidden" id="idseqttl" name="idseqttl" />');
    $('#formImpressao').append('<input type="hidden" id="nrsimula" name="nrsimula" />');
    $('#formImpressao').append('<input type="hidden" id="flgemail" name="flgemail" />');
    $('#formImpressao').append('<input type="hidden" id="tpemprst" name="tpemprst" />');

    // Agora insiro os devidos valores nos inputs criados
    $('#sidlogin', '#formImpressao').val($('#sidlogin', '#frmMenu').val());
    $('#nrdconta', '#formImpressao').val(nrdconta);
    $('#idseqttl', '#formImpressao').val(idseqttl);
    $('#nrsimula', '#formImpressao').val(nrsimula);
    $('#flgemail', '#formImpressao').val(flgemail);
    $('#tpemprst', '#formImpressao').val(tpemprst);

    var action = UrlSite + 'telas/atenda/emprestimos/simulacao/imprime_simulacao.php';
    var callafter = "bloqueiaFundo($('#divUsoGenerico'));";

    carregaImpressaoAyllos("formImpressao", action, callafter);

    return false;
}

function ajustaTela() {
    $('#divProcSimulacoesFormulario').css({'height': '545px'});
    return false;
}


function gerarProposta() {

    $('table > tbody > tr', '#divProcSimulacoesTabela > div.divRegistros').each(function() {
        if ($(this).hasClass('corSelecao')) {

            aux_nrsimula = $(this).find('#nrsimula > span').text();
			aux_cdorigem = $(this).find('#cdorigem').val();

        }
    });
	
	if (aux_cdorigem == 3 || aux_cdorigem == 10) {
		showError('error', 'Não é permitido gerar proposta de simulação com origem em canais digitais!', 'Alerta - Aimaro', 'hideMsgAguardo(); bloqueiaFundo($("#divUsoGenerico"));');
		return false;
	}

    showConfirmacao('Confirma a Geração da Proposta com Base na Simulação Nº ' + aux_nrsimula + ' ?', 'Confirma&ccedil;&atilde;o - Aimaro', 'controlaOperacaoSimulacoes(\'GPR\')', "blockBackground(parseInt($('#divRotina').css('z-index')))", 'sim.gif', 'nao.gif');

}
