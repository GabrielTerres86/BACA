
// PRJ 438 - Sprint 14 - Variaveis relacionadas aos avalistas
var nomeDiv = 'divDscChq_Avalistas';

var nrAvalistas = 0;
var contAvalistas = 1;
var maxAvalista = 2;
var arrayAvalBusca = new Object();

var aux_nrctaav0 = '';
var aux_nmdaval0 = '';
var aux_nrcpfav0 = '';
var aux_tpdocav0 = '';
var aux_dsdocav0 = '';
var aux_nmdcjav0 = '';
var aux_cpfcjav0 = '';
var aux_tdccjav0 = '';
var aux_doccjav0 = '';
var aux_ende1av0 = '';
var aux_ende2av0 = '';
var aux_nrfonav0 = '';
var aux_emailav0 = '';
var aux_nmcidav0 = '';
var aux_cdufava0 = '';
var aux_nrcepav0 = '';
var aux_cdnacio0 = '';
var aux_vledvmt0 = '';
var aux_vlrenme0 = '';
var aux_nrender0 = '';
var aux_complen0 = '';
var aux_nrcxaps0 = '';
var aux_inpesso0 = '';
var aux_dtnasct0 = '';
var aux_vlrencj0 = '';

var aux_nrctaav1 = '';
var aux_nmdaval1 = '';
var aux_nrcpfav1 = '';
var aux_tpdocav1 = '';
var aux_dsdocav1 = '';
var aux_nmdcjav1 = '';
var aux_cpfcjav1 = '';
var aux_tdccjav1 = '';
var aux_doccjav1 = '';
var aux_ende1av1 = '';
var aux_ende2av1 = '';
var aux_nrfonav1 = '';
var aux_emailav1 = '';
var aux_nmcidav1 = '';
var aux_cdufava1 = '';
var aux_nrcepav1 = '';
var aux_cdnacio1 = '';
var aux_vledvmt1 = '';
var aux_vlrenme1 = '';
var aux_nrender1 = '';
var aux_complen1 = '';
var aux_nrcxaps1 = '';
var aux_inpesso1 = '';
var aux_dtnasct1 = '';
var aux_vlrecjg1 = '';

pessoa = 1;

// Constantes
var __BOTAO_TAB = 9;
var __BOTAO_ENTER = 13;

function formataAvalista() {

	var cTodos = $('select,input', '#' + nomeDiv + ' fieldset:eq(0)');
	var rRotulo = $('label[for="nrcpfcgc"],label[for="nmdavali"],label[for="nrctaava"],label[for="inpessoa"],label[for="cdnacion"],label[for="dtnascto"]', '#' + nomeDiv);

    rRotulo.addClass('rotulo').css('width', '80px');

    var rConta = $('label[for="nrctaava"]', '#' + nomeDiv);
    var rNmdavali = $('label[for="nmdavali"]', '#' + nomeDiv);
    var rInpessoa = $('label[for="inpessoa"]', '#' + nomeDiv);
	var rNacio = $('label[for="cdnacion"]', '#' + nomeDiv);
    var rDtnascto = $('label[for="dtnascto"]', '#' + nomeDiv);

    var cConta = $('#nrctaava', '#' + nomeDiv);
    var cCPF = $('#nrcpfcgc', '#' + nomeDiv);
    var cNome = $('#nmdavali', '#' + nomeDiv);
    var cInpessoa = $('#inpessoa', '#' + nomeDiv);
    var cNacio = $('#cdnacion', '#' + nomeDiv);
    var cDsnacio = $('#dsnacion', '#' + nomeDiv);
    var cDtnascto = $('#dtnascto', '#' + nomeDiv);

    cConta.addClass('conta pesquisa').css('width', '115px');
    cCPF.css('width', '134px');
    cNome.addClass('alphanum').css('width', '255px').attr('maxlength', '40');
    cInpessoa.css({'width': '99px'});
    cNacio.addClass('codigo pesquisa').css('width', '30px');
    cDsnacio.css('width', '150px');
    cDtnascto.addClass('data').css({'width': '100px'});

    // Se pressionar alguma tecla no campo numero da conta, verificar a tecla pressionada e toda a devida ação (keydown)
    cConta.unbind('keydown').bind('keydown', function(e, triggerEvent) {

        if(typeof triggerEvent == 'undefined'){
            triggerEvent = {keyCode: 0};
        }

        if (divError.css('display') == 'block') {
            return false;
        }

        // Se é a tecla TAB, verificar numero conta e realizar as devidas operações
        if (e.keyCode == __BOTAO_ENTER || e.keyCode == __BOTAO_TAB || triggerEvent.keyCode == __BOTAO_ENTER) {

            // Armazena o número da conta na variável global
            nrctaava = normalizaNumero($(this).val());
            nrctaavaOld = nrctaava;

            if (nrctaava != 0) {
                // Verifica se a conta é válida
                if (!validaNroConta(nrctaava)) {
                    showError('error', 'Conta/dv inv&aacute;lida.', 'Alerta - Anota', 'focaCampoErro(\'nrctaava\',\''+nomeDiv+'\');bloqueiaFundo(divRotina);');
                    return false;
                } else {
                    Busca_Associado(nrctaava, 0);
                }
            } else {
                
                limpaFormAvalistas(true);
                cInpessoa.habilitaCampo();
                cInpessoa.focus();
                
            }

            return false;
        }
    });

    // Se pressionar alguma tecla no campo, verificar a tecla pressionada e toda a devida ação
    cInpessoa.unbind('keydown').bind('keydown', function(e) {

        if (divError.css('display') == 'block') {
            return false;
        }

        // Se é a tecla ENTER, verificar numero conta e realizar as devidas operações
        if (e.keyCode == __BOTAO_ENTER || e.keyCode == __BOTAO_TAB) {
            
            pessoa = normalizaNumero(cInpessoa.val());
            if (pessoa == "" ) {
                showError('error', 'Selecione o tipo de pessoa', 'Aten;&atilde;o', '$("#inpessoa","#'+nomeDiv+'").focus();bloqueiaFundo(divRotina);');
                return false;
            }else {
                cCPF.habilitaCampo();
                cCPF.focus();
            }

            return false;
        }
    });

    // Se pressionar alguma tecla no campo, verificar a tecla pressionada e toda a devida ação (keydown)
    cCPF.unbind('change').bind('change', function (e) {

        if (divError.css('display') == 'block') {
            return false;
        }

        // Armazena o número da conta na variável global
        nrcpfcgc = normalizaNumero(cCPF.val());
        nrcpfcgcOld = nrcpfcgc;

        pessoa = normalizaNumero(cInpessoa.val());

        if (nrcpfcgc != 0) {

            // Valida o CPF
            if (!validaCpfCnpj(nrcpfcgc, pessoa)) {
                showError('error', 'CPF/CNPJ inv&aacute;lido.', 'Valida&ccedil;&atilde;o CPF', '$("#nrcpfcgc","#'+nomeDiv+'").focus();bloqueiaFundo(divRotina);');
                return false;
            } else {
                buscarContasPorCpfCnpj('aval');
            }

        }

        return false;
    
    });

    cInpessoa.unbind('change').bind('change', function(e) {

    	controlaCamposTelaAvalista(false);

    });

    controlaEventoCamposTelaAvalista();

    var cTodos_1 = $('select,input', '#' + nomeForm + ' fieldset:eq(1)');

    var rRotulo_1 = $('label[for="nmconjug"],label[for="nrctacjg"]', '#' + nomeForm);
    var rCpf_1 = $('label[for="nrcpfcjg"]', '#' + nomeForm);
    var rVlrencjg = $('label[for="vlrencjg"]', '#' + nomeForm);
    

    var cConj = $('#nmconjug', '#' + nomeForm);
    var cCPF_1 = $('#nrcpfcjg', '#' + nomeForm);
    var cNrctacjg = $('#nrctacjg', '#' + nomeForm);
    var cVlrencjg = $('#vlrencjg', '#' + nomeForm);

    rRotulo_1.addClass('rotulo').css('width', '50px');
    rCpf_1.addClass('rotulo-linha').css('width', '117px');
    rVlrencjg.addClass('rotulo-linha').css('width', '76px');

    cConj.addClass('alphanum').css('width', '200px').attr('maxlength', '40');
    cCPF_1.addClass('cpf').css('width', '134px');
    cNrctacjg.addClass('conta');
    cVlrencjg.addClass('moeda').css('width', '100px');

    cNrctacjg.unbind('keydown').bind('keydown', function (e, param1) {
        if(typeof param1 == 'undefined'){
            param1 = {keyCode: 0};
        }

        if (e.keyCode == __BOTAO_ENTER || e.keyCode == __BOTAO_TAB || param1.keyCode == __BOTAO_ENTER) {
            nrctacjg = normalizaNumero($(this).val());

            if (nrctacjg != 0) {
                // Verifica se a conta é válida
                if (!validaNroConta(nrctacjg)) {
                    showError('error', 'Conta/dv inv&aacute;lida.', 'Alerta - Anota', 'focaCampoErro(\'nrctacjg\',\''+nomeDiv+'\');bloqueiaFundo(divRotina);');
                    return false;
                } else {
                    buscarDadosContaConjuge();
                }
            }
        }
    });

    cCPF_1.unbind('keydown').bind('keydown', function (e) {
        if (e.keyCode == __BOTAO_ENTER || e.keyCode == __BOTAO_TAB) {
            // Armazena o número da conta na variável global
            nrcpfcgc = normalizaNumero(cCPF_1.val());

            if (nrcpfcgc != 0) {

                // Valida o CPF
                if (!validaCpfCnpj(nrcpfcgc, 1)) {
                    showError('error', 'CPF inv&aacute;lido.', 'Valida&ccedil;&atilde;o CPF', '$("#nrcpfcjg","#'+nomeDiv+'").focus();bloqueiaFundo(divRotina);');
                    return false;
                } else {

                    buscarContasPorCpfCnpj('aval-cje');
                }
            }
        }
    
    });

    var cTodos_2 = $('select,input', '#' + nomeDiv + ' fieldset:eq(2)');

    // RÓTULOS - ENDEREÇO
    var rCep = $('label[for="nrcepend"]', '#' + nomeDiv);
    var rEnd = $('label[for="dsendre1"]', '#' + nomeDiv);
    var rBai = $('label[for="dsendre2"]', '#' + nomeDiv);
    var rEst = $('label[for="cdufresd"]', '#' + nomeDiv);
    var rCid = $('label[for="nmcidade"]', '#' + nomeDiv);
    //Campos projeto CEP
    var rNum = $('label[for="nrendere"]', '#' + nomeDiv);
    var rCom = $('label[for="complend"]', '#' + nomeDiv);
    var rCax = $('label[for="nrcxapst"]', '#' + nomeDiv);

    rCep.addClass('rotulo').css('width', '55px');
    rEnd.addClass('rotulo-linha').css('width', '35px');
    rNum.addClass('rotulo').css('width', '55px');
    rCom.addClass('rotulo-linha').css('width', '52px');
    rCax.addClass('rotulo').css('width', '55px');
    rBai.addClass('rotulo-linha').css('width', '52px');
    rEst.addClass('rotulo').css('width', '55px');
    rCid.addClass('rotulo-linha').css('width', '52px');

    // CAMPOS - ENDEREÇO
    var cCep = $('#nrcepend', '#' + nomeDiv);
    var cEnd = $('#dsendre1', '#' + nomeDiv);
    var cBai = $('#dsendre2', '#' + nomeDiv);
    var cEst = $('#cdufresd', '#' + nomeDiv);
    var cCid = $('#nmcidade', '#' + nomeDiv);
    //Campos projeto CEP
    var cNum = $('#nrendere', '#' + nomeDiv);
    var cCom = $('#complend', '#' + nomeDiv);
    var cCax = $('#nrcxapst', '#' + nomeDiv);

    cCep.addClass('pesquisa').css('width', '65px').attr('maxlength', '9');
    cEnd.addClass('alphanum').css('width', '300px').attr('maxlength', '40');
    cNum.addClass('numerocasa').css('width', '65px').attr('maxlength', '7');
    cCom.addClass('alphanum').css('width', '300px').attr('maxlength', '40');
    cCax.addClass('caixapostal').css('width', '65px').attr('maxlength', '6');
    cBai.addClass('alphanum').css('width', '300px').attr('maxlength', '40');
    cEst.css('width', '65px');
    cCid.addClass('alphanum').css('width', '300px').attr('maxlength', '25');

    //Controle contato
    var cTodos_3 = $('select,input', '#' + nomeDiv + ' fieldset:eq(3)');

    var rFone = $('label[for="nrfonres"]', '#' + nomeDiv);
    var rEmail = $('label[for="dsdemail"]', '#' + nomeDiv);

    rFone.addClass('rotulo');
    rEmail.addClass('rotulo-linha').css('width', '55px');

    var cFone = $('#nrfonres', '#' + nomeDiv);
    var cEmail = $('#dsdemail', '#' + nomeDiv);

    cFone.addClass('alphanum').css('width', '100px').attr('maxlength', '19');
    cEmail.addClass('alphanum').css('width', '237px').attr('maxlength', '30');

    var cTodos_4 = $('select,input', '#' + nomeDiv + ' fieldset:eq(4)');

    var rRenda = $('label[for="vlrenmes"]', '#' + nomeDiv);

    rRenda.css('width', '120px');

    var cRenda = $('#vlrenmes', '#' + nomeDiv);

    cRenda.addClass('moeda').css('width', '130px');

    if (operacao == 'I' || operacao == 'A') {
    	iniciaAval();
//        habilitaAvalista(true, operacao);
    } else {
//        habilitaAvalista(false, operacao);
    	cTodos.desabilitaCampo();
        cTodos_1.desabilitaCampo();
        cTodos_2.desabilitaCampo();
        cTodos_3.desabilitaCampo();
        cTodos_4.desabilitaCampo();

        $('#btLimparAvalista', '#' + nomeDiv).hide();
    }

    $('legend:first', '#' + nomeDiv).html('Dados dos Avalistas/Fiadores 1');

	layoutPadrao();

}

function iniciaAval() {

    //var cConta = $('#nrctaava', '#' + nomeDiv); // anderson
    var cConta = $('#nrcpfcgc', '#' + nomeDiv); // anderson

    $('select,input', '#' + nomeDiv + ' fieldset').desabilitaCampo();

    if (normalizaNumero(cConta.val()) == 0) {
        cConta.habilitaCampo();
    }

    if (operacao == 'I' || operacao == 'A') {
        cConta.habilitaCampo();
    } else {
        cConta.desabilitaCampo(); // anderson
    }

    return false;
}

function Busca_Associado(nrctaava, nrcpfcgc) { 

    showMsgAguardo('Aguarde, buscando dados...');

    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/atenda/descontos/cheques/busca_avalista.php',
        data: {
            nrdconta: nrdconta, 
            nrctaava: nrctaava, 
            nrcpfcgc: nrcpfcgc,
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
        },
        success: function(response) {
            try {

                if (response.indexOf('showError("error"') == -1) {
                    eval(response);

                    hideMsgAguardo();
                    bloqueiaFundo(divRotina);

                    carregaBusca();
            		controlaCamposTelaAvalista(true);
                } else {
                    hideMsgAguardo();
                    eval(response);
                }

                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
            }
        }
    });

    return false;

}

function carregaBusca(){
	$('#nrctaava', '#' + nomeDiv).val(arrayAvalBusca['nrctaava']);
    $('#cdnacion', '#' + nomeDiv).val(arrayAvalBusca['cdnacion']);
    $('#dsnacion', '#' + nomeDiv).val(arrayAvalBusca['dsnacion']);
    $('#nmconjug', '#' + nomeDiv).val(arrayAvalBusca['nmconjug']);
    $('#dsendre1', '#' + nomeDiv).val(arrayAvalBusca['dsendre1']);
    $('#nrfonres', '#' + nomeDiv).val(telefone(arrayAvalBusca['nrfonres']));
    $('#nmcidade', '#' + nomeDiv).val(arrayAvalBusca['nmcidade']);
    $('#nrcepend', '#' + nomeDiv).val(arrayAvalBusca['nrcepend']);
    $('#nmdavali', '#' + nomeDiv).val(arrayAvalBusca['nmdavali']);
    $('#nrcpfcgc', '#' + nomeDiv).val(arrayAvalBusca['nrcpfcgc']);
    $('#nrcpfcjg', '#' + nomeDiv).val(arrayAvalBusca['nrcpfcjg']);
    $('#dsendre2', '#' + nomeDiv).val(arrayAvalBusca['dsendre2']);
    $('#dsdemail', '#' + nomeDiv).val(arrayAvalBusca['dsdemail']);
    $('#cdufresd', '#' + nomeDiv).val(arrayAvalBusca['cdufresd']);
    $('#vlrenmes', '#' + nomeDiv).val(arrayAvalBusca['vlrenmes']);
    $('#nrendere', '#' + nomeDiv).val(arrayAvalBusca['nrendere']);
    $('#complend', '#' + nomeDiv).val(arrayAvalBusca['complend']);
    $('#nrcxapst', '#' + nomeDiv).val(arrayAvalBusca['nrcxapst']);
    $('#inpessoa', '#' + nomeDiv).val(arrayAvalBusca['inpessoa']);
    $('#dtnascto', '#' + nomeDiv).val(arrayAvalBusca['dtnascto']);
    $('#vlrencjg', '#' + nomeDiv).val(arrayAvalBusca['vlrencjg']);
    $('#nrctacjg', '#' + nomeDiv).val(arrayAvalBusca['nrctacjg']);

    if (normalizaNumero($('#nrctaava', '#' + nomeDiv).val()) != 0) {
        $('select,input', '#' + nomeDiv + ' fieldset').desabilitaCampo();
    }

    $('#nrctaava', '#' + nomeDiv).habilitaCampo().focus();

    $('input', '#' + nomeDiv).trigger('blur');
}

function controlaCamposTelaAvalista(cooperado){

    if (operacao != "C") {
        $('#nrctaava','#divDscChq_Avalistas').habilitaCampo();
    } else {
        $('#nrctaava','#divDscChq_Avalistas').desabilitaCampo();
    }

    $('#nrcpfcgc','#divDscChq_Avalistas').desabilitaCampo();

	var inpessoa = $('#inpessoa', '#' + nomeDiv).val() == "" ? pessoa : $('#inpessoa', '#' + nomeDiv).val();

	if(cooperado == null){
		var nrctaava = $('#nrctaava', '#' + nomeDiv).val();
		if(nrctaava == 0){
			var cooperado = false;
		} else {
			var cooperado = true;
		}
	}

    if (inpessoa == 1) {
        $('label[for="nrctaava"]', '#' + nomeDiv).css('width', '95px');
        $('label[for="inpessoa"]', '#' + nomeDiv).css('width', '95px');
        $('label[for=nrcpfcgc]', '#' + nomeDiv).css('width', '95px');
        $('label[for=nmdavali]', '#' + nomeDiv).css('width', '95px');
        $('label[for=dtnascto]', '#' + nomeDiv).css('width', '95px');
        $('label[for=cdnacion]', '#' + nomeDiv).css('width', '95px');
        $('label[for="dtnascto"], #dtnascto', '#' + nomeDiv).text('Data Nasc.:');
    } else{
        $('label[for="nrctaava"]', '#' + nomeDiv).css('width', '100px');
        $('label[for="inpessoa"]', '#' + nomeDiv).css('width', '100px');
        $('label[for=nrcpfcgc]', '#' + nomeDiv).css('width', '100px');
        $('label[for=nmdavali]', '#' + nomeDiv).css('width', '100px');
        $('label[for=dtnascto]', '#' + nomeDiv).css('width', '100px');
        $('label[for="dtnascto"], #dtnascto', '#' + nomeDiv).text('Data da Abertura:');
    }

    if (inpessoa == 1 && cooperado == true) {
		$('label[for="nrcpfcgc"]', '#' + nomeDiv).text('CPF:');
		$('label[for="nmdavali"]', '#' + nomeDiv).text('Nome:');
		$('#divCdnacion', '#' + nomeDiv).hide();
        $('#dsnacion', '#' + nomeDiv).show();
		$('label[for="dtnascto"], #dtnascto', '#' + nomeDiv).hide();
		$('label[for="dsdemail"], #dsdemail', '#' + nomeDiv).hide();
		$('label[for="vlrenmes"]', '#' + nomeDiv).css('width', '120px').text('Rendimento Mensal:');
		$('#fsetConjugeAval', '#' + nomeDiv).show();

	} else if (inpessoa == 1 && cooperado == false) {
		$('label[for="nrcpfcgc"]', '#' + nomeDiv).text('CPF:');
		$('label[for="nmdavali"]', '#' + nomeDiv).text('Nome:');
        $('#divNacionalidade', '#' + nomeDiv).removeClass('rotulo-linha').addClass('rotulo').show();
		$('#divCdnacion', '#' + nomeDiv).removeClass('rotulo-linha').addClass('rotulo').show();
        $('#dsnacion', '#' + nomeDiv).removeClass('rotulo-linha').addClass('rotulo').show();
		$('label[for="dtnascto"], #dtnascto', '#' + nomeDiv).show();
		$('label[for="dsdemail"], #dsdemail', '#' + nomeDiv).show();
		$('label[for="vlrenmes"]', '#' + nomeDiv).css('width', '120px').text('Rendimento Mensal:');
		$('#fsetConjugeAval', '#' + nomeDiv).show();
	} else if (inpessoa == 2 && cooperado == true) {
		$('label[for="nrcpfcgc"]', '#' + nomeDiv).text('CNPJ:');
		$('label[for="nmdavali"]', '#' + nomeDiv).text('Razão Social:');
        $('#divNacionalidade', '#' + nomeDiv).hide();
		$('label[for="dtnascto"], #dtnascto', '#' + nomeDiv).hide();
		$('label[for="dsdemail"], #dsdemail', '#' + nomeDiv).hide();
		$('label[for="vlrenmes"]', '#' + nomeDiv).css('width', '150px').text('Faturamente Médio Mensal:');
		$('#fsetConjugeAval', '#' + nomeDiv).hide();
	} else if (inpessoa == 2 && cooperado == false) {
		$('label[for="nrcpfcgc"]', '#' + nomeDiv).text('CNPJ:');
		$('label[for="nmdavali"]', '#' + nomeDiv).text('Razão Social:');
        $('#divNacionalidade', '#' + nomeDiv).hide();
		$('label[for="dtnascto"], #dtnascto', '#' + nomeDiv).show();
		$('label[for="dtnascto"]', '#' + nomeDiv).text('Data da Abertura:');
		$('label[for="dsdemail"], #dsdemail', '#' + nomeDiv).show();
		$('label[for="vlrenmes"]', '#' + nomeDiv).css('width', '150px').text('Faturamente Médio Mensal:');
		$('#fsetConjugeAval', '#' + nomeDiv).hide();
	}

}

function buscarContasPorCpfCnpj(tipoConsulta){

	switch (tipoConsulta) {
		case 'aval':
			var nomeCampoCpf = 'nrcpfcgc';
			var nomeCampoConta = 'nrctaava';
			break;
		case 'aval-cje':
			var nomeCampoCpf = 'nrcpfcjg';
			var nomeCampoConta = 'nrctacjg';
			break;
	}
	
	var nrcpfcgc = $('#' + nomeCampoCpf, '#' + nomeDiv).val();
	nrcpfcgc = normalizaNumero(nrcpfcgc);

	$.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/descontos/cheques/busca_contas_por_cpf_cnpj.php',
        data: {
        	nomeCampoConta: nomeCampoConta,
        	nomeForm: nomeDiv,
            nrcpfcgc: nrcpfcgc,
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Aimaro', "unblockBackground()");
        },
        success: function(response) {
            try {
                zeraCamposDadosConjugeAvalista();
                if (response.indexOf('showError("error"') == -1) {
                	hideMsgAguardo();
                	// Se o response retornou vazio, ou seja, nenhuma conta, permitir digitação na tela
                	if (response.length == 0) {
                		if(tipoConsulta == 'aval'){
                			// Chamar função para ajustar o layout da tela Avalista passando false(nao cooperado) no parametro cooperado
                    		controlaCamposTelaAvalista(false);
                    		habilitarCamposAvalista();
                		}
                		bloqueiaFundo(divRotina);
                	// Verificar se é para exibir a tabela de contas ou se retornou apenas uma conta
                	} else if (response.indexOf("$('#" + nomeCampoConta + "','#" + nomeDiv + "').val") == -1) {
                		$('#divUsoGenerico').html(response);
                    	controlaLayoutContas();
                	} else {
                		hideMsgAguardo();
                    	eval(response);
                    	$('#' + nomeCampoConta, '#' + nomeDiv).trigger('change');
                	}
                } else {
                    hideMsgAguardo();
                    eval(response);
                }
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'unblockBackground()');
            }
        }
    });
    return false;
}

function controlaLayoutContas(){
	var divRegistro = $('#divTabelaContasPorCpfCnpj > div.divRegistros');
    var tabela = $('table', divRegistro);

    divRegistro.css('height', '150px');

    var ordemInicial = new Array();
    ordemInicial = [[0, 0]];

    var arrayLargura = new Array();

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');

    layoutPadrao();
    exibeRotina($('#divUsoGenerico'));
}

function habilitarCamposAvalista(){

	var cTodos = $('select,input', '#' + nomeDiv);
	var cTodos_1 = $('select,input', '#' + nomeDiv + ' fieldset:eq(1)');
	var cTodos_2 = $('select,input', '#' + nomeDiv + ' fieldset:eq(2)');
	var cTodos_3 = $('select,input', '#' + nomeDiv + ' fieldset:eq(3)');
	var cTodos_4 = $('select,input', '#' + nomeDiv + ' fieldset:eq(4)');
    var cConta = $('#nrctaava', '#' + nomeDiv);
    var cNome = $('#nmdavali', '#' + nomeDiv);

	// Se nao for acessado via CRM, pode habilitar os campos
    if ($('#crm_inacesso', '#' + nomeDiv).val() != 1 ) {
        cTodos.habilitaCampo();
        cTodos_1.habilitaCampo();
        cTodos_2.habilitaCampo();
        cTodos_3.habilitaCampo();
    	cTodos_4.habilitaCampo();
        cConta.desabilitaCampo().val(nrctaava);

        $('#dsendre1,#cdufresd,#dsendre2,#nmcidade,#dsnacion', '#' + nomeDiv).desabilitaCampo();
        controlaPesquisas();
        cNome.focus();
        
    }
}

// Função que controla a lupa de pesquisa
function controlaPesquisas() {		
	
	var campoAnterior = '';
	var procedure, titulo, qtReg, filtrosPesq, filtrosDesc, colunas;	
    var bo = 'zoom0001';
	
    $('a', '#' + nomeDiv).ponteiroMouse();
	
    aplicarEventosLupasTelaAvalista();
}

function aplicarEventosLupasTelaAvalista(){

    // Conta Avalista
    $('#nrctaava','#'+nomeDiv).next().unbind('click').bind('click', function () {
        if ($('#nrctaava','#'+nomeDiv).hasClass('campoTelaSemBorda')) {
            return false;
        }
        mostraPesquisaAssociado('nrctaava', nomeDiv, divRotina);
        return false;
    });
    
    // Nacionalidade
    $('#cdnacion','#'+nomeDiv).unbind('change').bind('change', function() {
        procedure    = 'BUSCANACIONALIDADES';
        titulo      = ' Nacionalidade';
        filtrosDesc = '';
        buscaDescricao('ZOOM0001',procedure,titulo,$(this).attr('name'),'dsnacion',$(this).val(),'dsnacion',filtrosDesc,nomeDiv); 
        return false;
    }).next().unbind('click').bind('click', function () {
        if ($('#cdnacion','#'+nomeDiv).hasClass('campoTelaSemBorda')) {
            return false;
        }
        bo = 'b1wgen0059.p';
        procedure = 'busca_nacionalidade';
        titulo = 'Nacionalidade';
        qtReg = '50';
        filtros = 'Codigo;cdnacion;30px;N;|Nacionalidade;dsnacion;200px;S;';
        colunas = 'Codigo;cdnacion;15%;left|Descrição;dsnacion;85%;left';
        mostraPesquisa(bo, procedure, titulo, qtReg, filtros, colunas, divRotina);
        return false;
    });

    // CEP
    var camposOrigem = 'nrcepend;dsendre1;nrendere;complend;nrcxapst;dsendre2;cdufresd;nmcidade';
    $('#nrcepend','#'+nomeDiv).unbind('change').bind('change', function() {
        mostraPesquisaEndereco(nomeDiv, camposOrigem, divRotina, $(this).val());
        return false;
    }).next().unbind('click').bind('click', function () {
        if ($('#nrcepend','#'+nomeDiv).hasClass('campoTelaSemBorda')) {
            return false;
        }
        mostraPesquisaEndereco(nomeDiv, camposOrigem, divRotina);
        return false;
    });
    
    $('#nrctaava','#divDscTit_Avalistas').focus();
}

function buscarDadosContaConjuge(){

	var nrdconta = $('#nrctacjg', '#' + nomeDiv).val();
	nrdconta = normalizaNumero(nrdconta);

	$.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/descontos/cheques/busca_dados_conta_conjuge.php',
        data: {
        	nrdconta: nrdconta,
        	nomeForm: nomeDiv,
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            try {
                hideMsgAguardo();
                bloqueiaFundo(divRotina);
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'bloqueiaFundo($(\'#divUsoGenerico\'))');
            }
        }
    });
    return false;
}

function habilitaAvalista(boHabilita, operacao) {	
    controlaCamposTelaAvalista(false);
	if (boHabilita) {
		estadoInicial(operacao);
		$('#nrctaava','#'+nomeDiv).focus();
	} else {
		$('input, select','#'+nomeDiv+' .fsAvalista').desabilitaCampo();
		$('a.pointer','#'+nomeDiv+' .fsAvalista').removeClass('pointer');
	}
}

function estadoInicial(operacao) {
	
	// Declarando variáveis úteis
	var cTodos = $('input[type="text"], select','#'+nomeDiv+' .fsAvalista:eq(0)');
    var cConta = $('#nrctaava', '#' + nomeDiv);
	
	switch(operacao) {
	case 'A':
		// Desabilita todos campos 
		cTodos.desabilitaCampo();
		
		//Habilita o campo de Nr. Conta
		cConta.habilitaCampo();	
	break;

	default:
		// Limpa o formulário e desabilita todos campos 
		cTodos.limpaFormulario();
		cTodos.desabilitaCampo();	
		
		//Habilita o campo de Nr. Conta
		cConta.habilitaCampo();	
		cConta.val('');
	break;
	}

    controlaPesquisas();
//    controlaCamposTelaAvalista(false);
	// Foca o Nr. Conta
	cConta.focus();
	
}

function limpaFormAvalistas(flgLimparArray) {

    $('input, select', '#' + nomeDiv).val('');
    
    if(flgLimparArray == true){

        var indiceAvalista = contAvalistas - 1;

        if(arrayAvalistas[indiceAvalista]){

            arrayAvalistas[indiceAvalista]['nrctaava'] = '';
            arrayAvalistas[indiceAvalista]['cdnacion'] = '';
            arrayAvalistas[indiceAvalista]['dsnacion'] = '';
            arrayAvalistas[indiceAvalista]['nmconjug'] = '';
            arrayAvalistas[indiceAvalista]['dsendre1'] = '';
            arrayAvalistas[indiceAvalista]['nrfonres'] = '';
            arrayAvalistas[indiceAvalista]['nmcidade'] = '';
            arrayAvalistas[indiceAvalista]['nrcepend'] = '';
            arrayAvalistas[indiceAvalista]['nmdavali'] = '';
            arrayAvalistas[indiceAvalista]['nrcpfcgc'] = '';
            arrayAvalistas[indiceAvalista]['nrcpfcjg'] = '';
            arrayAvalistas[indiceAvalista]['dsendre2'] = '';
            arrayAvalistas[indiceAvalista]['dsdemail'] = '';
            arrayAvalistas[indiceAvalista]['cdufresd'] = '';
            arrayAvalistas[indiceAvalista]['inpessoa'] = '';
            arrayAvalistas[indiceAvalista]['dtnascto'] = '';
            arrayAvalistas[indiceAvalista]['vlrencjg'] = '';
            arrayAvalistas[indiceAvalista]['complend'] = '';
            arrayAvalistas[indiceAvalista]['nrctacjg'] = '';
            arrayAvalistas[indiceAvalista]['nrendere'] = '';
            arrayAvalistas[indiceAvalista]['vlrenmes'] = '';
            arrayAvalistas[indiceAvalista]['nrcxapst'] = '';

        }

    }
    
    iniciaAval();

    return false;
}

function controlaVoltarAvalista(){
    // Verifica se está no Avalista 2, se sim, entao deve voltar para o Avalista 1, senão volta para a tela Rating
    if(contAvalistas == 2){
        contAvalistas = 1;
        atualizarCamposTelaAvalistas();
    } else {
		$("#frmDadosLimiteDscChq").css("width", 515);
		dscShowHideDiv("divDscChq_Observacao;divBotoesObs","divDscChq_Avalistas;divBotoesAval");
		return false;
    }   
}

function atualizarCamposTelaAvalistas(flgAttContAvalistas){

    if (flgAttContAvalistas == true) {
        contAvalistas++;
    }

    var indiceAvalista = contAvalistas - 1;

	if(arrayAvalistas[indiceAvalista]){

		$('#nrctaava', '#' + nomeDiv).val(arrayAvalistas[indiceAvalista]['nrctaava']);
		$('#cdnacion', '#' + nomeDiv).val(arrayAvalistas[indiceAvalista]['cdnacion']);
		$('#dsnacion', '#' + nomeDiv).val(arrayAvalistas[indiceAvalista]['dsnacion']);
		$('#nmconjug', '#' + nomeDiv).val(arrayAvalistas[indiceAvalista]['nmconjug']);
		$('#dsendre1', '#' + nomeDiv).val(arrayAvalistas[indiceAvalista]['dsendre1']);
		$('#nrfonres', '#' + nomeDiv).val(telefone(arrayAvalistas[indiceAvalista]['nrfonres']));
		$('#nmcidade', '#' + nomeDiv).val(arrayAvalistas[indiceAvalista]['nmcidade']);
		$('#nrcepend', '#' + nomeDiv).val(arrayAvalistas[indiceAvalista]['nrcepend']);
		$('#nmdavali', '#' + nomeDiv).val(arrayAvalistas[indiceAvalista]['nmdavali']);
		$('#nrcpfcgc', '#' + nomeDiv).val(arrayAvalistas[indiceAvalista]['nrcpfcgc']);
		$('#nrcpfcjg', '#' + nomeDiv).val(arrayAvalistas[indiceAvalista]['nrcpfcjg']);
		$('#dsendre2', '#' + nomeDiv).val(arrayAvalistas[indiceAvalista]['dsendre2']);
		$('#dsdemail', '#' + nomeDiv).val(arrayAvalistas[indiceAvalista]['dsdemail']);
		$('#cdufresd', '#' + nomeDiv).val(arrayAvalistas[indiceAvalista]['cdufresd']);
		$('#vlrenmes', '#' + nomeDiv).val(arrayAvalistas[indiceAvalista]['vlrenmes']);
		$('#inpessoa', '#' + nomeDiv).val(arrayAvalistas[indiceAvalista]['inpessoa']);
		$('#dtnascto', '#' + nomeDiv).val(arrayAvalistas[indiceAvalista]['dtnascto']);
		$('#nrendere', '#' + nomeDiv).val(arrayAvalistas[indiceAvalista]['nrendere']);
		$('#complend', '#' + nomeDiv).val(arrayAvalistas[indiceAvalista]['complend']);
		$('#nrcxapst', '#' + nomeDiv).val(arrayAvalistas[indiceAvalista]['nrcxapst']);
		$('#vlrencjg', '#' + nomeDiv).val(arrayAvalistas[indiceAvalista]['vlrencjg']);
		$('#nrctacjg', '#' + nomeDiv).val(arrayAvalistas[indiceAvalista]['nrctacjg']);

	} else {
		limpaFormAvalistas(false);
	}

    $('legend:first', '#' + nomeDiv).html('Dados dos Avalistas/Fiadores ' + contAvalistas);

    controlaCamposTelaAvalista();
    $('input', '#' + nomeDiv).trigger('blur');

}

function controlaContinuarAvalista(){

	showMsgAguardo('Aguarde, carregando avalista...');

    var aux_conta = normalizaNumero($('#nrctaava', '#' + nomeDiv).val());
    var aux_cpf = normalizaNumero($('#nrcpfcgc', '#' + nomeDiv).val());
    var indiceAvalista = contAvalistas - 1;

    if($('#nrcpfcgc', '#' + nomeDiv).val() == "" && $('#nmdavali', '#' + nomeDiv).val() == "" && $('#nrctaava', '#' + nomeDiv).val()){
        $('#nrctaava', '#' + nomeDiv).trigger('keydown',{keyCode: 13});
        return false;
    }

    if(operacao != 'I' && operacao != 'A'){
        hideMsgAguardo();
        bloqueiaFundo(divRotina);
    } else {
        if (!validaDadosAval()) {
            return false;
        }
    }

    if (aux_conta == 0 && aux_cpf == 0 && arrayAvalistas.length == 0) {
		abrirTelaDemoDescontoCheque(true);
        return false;
    }

    if(operacao == 'I' || operacao == 'A'){
        // Se os valores de conta e cpf estiverem vazios, entao pode inserir um avalista no array atual 
        if(nrAvalistas == 0 || !arrayAvalistas[indiceAvalista]){
          	insereAvalista();
        // Se os valores de conta e cpf NÃO estiverem vazios, entao será inserir os dados do avalista no array atual 	
        } else if((aux_conta || aux_cpf) && arrayAvalistas[indiceAvalista]){
           	atualizaArrayAvalistas();
        }
    }

	// Verificar se tem mais Avalistas para mostrar/incluir
    if (contAvalistas < nrAvalistas || (nrAvalistas < maxAvalista && (operacao == 'I' || operacao == 'A'))) {
		// Carregar o outro avalista
        atualizarCamposTelaAvalistas(true);
    } else {
    	abrirTelaDemoDescontoCheque(true);
    }

}

function validaDadosAval() {

	showMsgAguardo('Aguarde, validando avalista...');

    $('input,select', '#' + nomeDiv).removeClass('campoErro');

    var nmdavali = $('#nmdavali', '#' + nomeDiv).val();
    var nrcpfcgc = normalizaNumero($('#nrcpfcgc', '#' + nomeDiv).val());
    var nrctaava = normalizaNumero($('#nrctaava', '#' + nomeDiv).val());
    var nrcpfcjg = normalizaNumero($('#nrcpfcjg', '#' + nomeDiv).val());
    var dsendre1 = $('#dsendre1', '#' + nomeDiv).val();
    var cdufresd = $('#cdufresd', '#' + nomeDiv).val();
    var nrcepend = normalizaNumero($('#nrcepend', '#' + nomeDiv).val());

    var idavalis = contAvalistas;

    var inpessoa = $('#inpessoa', '#' + nomeDiv).val();
    var dtnascto = $('#dtnascto', '#' + nomeDiv).val();

    var nrcpfav1 = 0;
    var nrctaav1 = 0;

    if (arrayAvalistas.length > 0) {
        nrctaav1 = normalizaNumero(arrayAvalistas[0]['nrctaava']);
        nrcpfav1 = normalizaNumero(arrayAvalistas[0]['nrcpfcgc']);
    } else if (idavalis == 1) {
        nrctaav1 = normalizaNumero($('#nrctaava', '#' + nomeDiv).val());
        nrcpfav1 = normalizaNumero($('#nrcpfcjg', '#' + nomeDiv).val());
    }

    var aux_retorno = false;

    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        async: false,
        url: UrlSite + 'telas/atenda/descontos/cheques/valida_avalistas.php',
        data: {
            nrdconta: nrdconta, 
            nrcpfav1: nrcpfav1, 
            idavalis: idavalis,
            nmdavali: nmdavali, 
            nrcpfcgc: nrcpfcgc,
            nrctaava: nrctaava, 
            nrctaav1: nrctaav1,
            nrcpfcjg: nrcpfcjg, 
            dsendre1: dsendre1,
            cdufresd: cdufresd, 
            nrcepend: nrcepend,
            nomeform: nomeDiv,
            inpessoa: inpessoa, 
            dtnascto: dtnascto,
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
        },
        success: function(response) {
            try {

                if (response.indexOf('showError("error"') == -1) {

                    aux_retorno = true;
                    eval(response);

                    hideMsgAguardo();
                    bloqueiaFundo(divRotina);

                } else {

                    aux_retorno = false;
                    hideMsgAguardo();
                    eval(response);
                }


            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
            }
        }
    });

    return aux_retorno;
}

function insereAvalista() {

    i = arrayAvalistas.length;

    eval('var arrayAvalista' + i + ' = new Object();');
    eval('arrayAvalista' + i + '["nrctaava"] = $("#nrctaava","#'+ nomeDiv +'").val();');
    eval('arrayAvalista' + i + '["cdnacion"] = $("#cdnacion","#'+ nomeDiv +'").val();');
    eval('arrayAvalista' + i + '["dsnacion"] = $("#dsnacion","#'+ nomeDiv +'").val();');
    eval('arrayAvalista' + i + '["nmconjug"] = $("#nmconjug","#'+ nomeDiv +'").val();');
    eval('arrayAvalista' + i + '["dsendre1"] = $("#dsendre1","#'+ nomeDiv +'").val();');
    eval('arrayAvalista' + i + '["nrfonres"] = $("#nrfonres","#'+ nomeDiv +'").val();');
    eval('arrayAvalista' + i + '["nmcidade"] = $("#nmcidade","#'+ nomeDiv +'").val();');
    eval('arrayAvalista' + i + '["nrcepend"] = $("#nrcepend","#'+ nomeDiv +'").val();');
    eval('arrayAvalista' + i + '["nmdavali"] = $("#nmdavali","#'+ nomeDiv +'").val();');
    eval('arrayAvalista' + i + '["nrcpfcgc"] = $("#nrcpfcgc","#'+ nomeDiv +'").val();');
    eval('arrayAvalista' + i + '["nrcpfcjg"] = $("#nrcpfcjg","#'+ nomeDiv +'").val();');
    eval('arrayAvalista' + i + '["dsendre2"] = $("#dsendre2","#'+ nomeDiv +'").val();');
    eval('arrayAvalista' + i + '["dsdemail"] = $("#dsdemail","#'+ nomeDiv +'").val();');
    eval('arrayAvalista' + i + '["cdufresd"] = $("#cdufresd","#'+ nomeDiv +'").val();');
    eval('arrayAvalista' + i + '["vlrenmes"] = $("#vlrenmes","#'+ nomeDiv +'").val();');
    eval('arrayAvalista' + i + '["nrendere"] = $("#nrendere","#'+ nomeDiv +'").val();');
    eval('arrayAvalista' + i + '["complend"] = $("#complend","#'+ nomeDiv +'").val();');
    eval('arrayAvalista' + i + '["nrcxapst"] = $("#nrcxapst","#'+ nomeDiv +'").val();');
    eval('arrayAvalista' + i + '["inpessoa"] = $("#inpessoa","#'+ nomeDiv +'").val();');
    eval('arrayAvalista' + i + '["dtnascto"] = $("#dtnascto","#'+ nomeDiv +'").val();');
    eval('arrayAvalista' + i + '["vlrencjg"] = $("#vlrencjg","#'+ nomeDiv +'").val();');

    eval('arrayAvalistas[' + i + '] = arrayAvalista' + i + ';');

    nrAvalistas++;
    
    return false;

}

function atualizaArrayAvalistas(){

	var indiceAvalista = contAvalistas - 1;

	arrayAvalistas[indiceAvalista]['nrctaava'] = $('#nrctaava', '#' + nomeDiv).val();
	arrayAvalistas[indiceAvalista]['cdnacion'] = $('#cdnacion', '#' + nomeDiv).val();
	arrayAvalistas[indiceAvalista]['dsnacion'] = $('#dsnacion', '#' + nomeDiv).val();
	arrayAvalistas[indiceAvalista]['nmconjug'] = $('#nmconjug', '#' + nomeDiv).val();
	arrayAvalistas[indiceAvalista]['dsendre1'] = $('#dsendre1', '#' + nomeDiv).val();
	arrayAvalistas[indiceAvalista]['nrfonres'] = $('#nrfonres', '#' + nomeDiv).val();
	arrayAvalistas[indiceAvalista]['nmcidade'] = $('#nmcidade', '#' + nomeDiv).val();
	arrayAvalistas[indiceAvalista]['nrcepend'] = $('#nrcepend', '#' + nomeDiv).val();
	arrayAvalistas[indiceAvalista]['nmdavali'] = $('#nmdavali', '#' + nomeDiv).val();
	arrayAvalistas[indiceAvalista]['nrcpfcgc'] = $('#nrcpfcgc', '#' + nomeDiv).val();
	arrayAvalistas[indiceAvalista]['nrcpfcjg'] = $('#nrcpfcjg', '#' + nomeDiv).val();
	arrayAvalistas[indiceAvalista]['dsendre2'] = $('#dsendre2', '#' + nomeDiv).val();
	arrayAvalistas[indiceAvalista]['dsdemail'] = $('#dsdemail', '#' + nomeDiv).val();
	arrayAvalistas[indiceAvalista]['cdufresd'] = $('#cdufresd', '#' + nomeDiv).val();
	arrayAvalistas[indiceAvalista]['vlrenmes'] = $('#vlrenmes', '#' + nomeDiv).val();
	arrayAvalistas[indiceAvalista]['nrendere'] = $('#nrendere', '#' + nomeDiv).val();
	arrayAvalistas[indiceAvalista]['complend'] = $('#complend', '#' + nomeDiv).val();
	arrayAvalistas[indiceAvalista]['nrcxapst'] = $('#nrcxapst', '#' + nomeDiv).val();
	arrayAvalistas[indiceAvalista]['inpessoa'] = $('#inpessoa', '#' + nomeDiv).val();
	arrayAvalistas[indiceAvalista]['dtnascto'] = $('#dtnascto', '#' + nomeDiv).val();
	arrayAvalistas[indiceAvalista]['vlrencjg'] = $('#vlrencjg', '#' + nomeDiv).val();

}

function controlaEventoCamposTelaAvalista(){

	var arrCampos = [
		"nrcpfcgc", //0
		"nmdavali", //1
		"dtnascto", //2
		"cdnacion", //3
		"nrctacjg", //4
		"nrcpfcjg", //5
		"nmconjug", //6
		"vlrencjg", //7
		"nrcepend", //8
		"nrendere", //9
		"complend", //10
		"nrcxapst", //11
		"nrfonres", //12
		"dsdemail", //13
		"vlrenmes", //14
	];

    $(arrCampos).each(function(elem){
        var c = $("#"+arrCampos[elem],"#"+ nomeDiv);
		if(!((elem+1)>(arrCampos.length-1))){
			$(c).bind('keypress',function(e){
				if(e.keyCode == __BOTAO_ENTER || e.keyCode == __BOTAO_TAB){
					if($('#inpessoa',"#"+ nomeDiv).val() != "1"){
						if(arrCampos[elem] == "dtnascto")
							$("#"+arrCampos[8],"#"+ nomeDiv).focus();
						else
							$("#"+arrCampos[elem+1],"#"+ nomeDiv).focus();
					}else{
						$("#"+arrCampos[elem+1],"#"+ nomeDiv).focus();
					}
				}
			});
	}
	});

}

// Função para pegar os valores dos avalistas que estão em array e atribuir em variaveis
function geraRegsDinamicosAvalistas() {

    //Limpo as variaveis
    for (var i = 0; i < 2; i++) {
        eval('aux_nrctaav' + i + ' = 0;');
        eval('aux_nmdaval' + i + ' = "";');
        eval('aux_nrcpfav' + i + ' = "";');
        eval('aux_tpdocav' + i + ' = "";');
        eval('aux_dsdocav' + i + ' = "";');
        eval('aux_nmdcjav' + i + ' = "";');
        eval('aux_cpfcjav' + i + ' = "";');
        eval('aux_tdccjav' + i + ' = "";');
        eval('aux_doccjav' + i + ' = "";');
        eval('aux_ende1av' + i + ' = "";');
        eval('aux_ende2av' + i + ' = "";');
        eval('aux_nrfonav' + i + ' = "";');
        eval('aux_emailav' + i + ' = "";');
        eval('aux_nmcidav' + i + ' = "";');
        eval('aux_cdufava' + i + ' = "";');
        eval('aux_nrcepav' + i + ' = "";');
        eval('aux_dsnacio' + i + ' = "";');
        eval('aux_vledvmt' + i + ' = "";');
        eval('aux_vlrenme' + i + ' = "";');
        eval('aux_nrender' + i + ' = "";');
        eval('aux_complen' + i + ' = "";');
        eval('aux_nrcxaps' + i + ' = "";');
        eval('aux_inpesso' + i + ' = "";');
        eval('aux_dtnasct' + i + ' = "";');
        eval('aux_vlrencj' + i + ' = "";');
    }

    //Array avalistas
    for (var i = 0; i < arrayAvalistas.length; i++) {
        eval('aux_nrctaav' + i + ' = arrayAvalistas[' + i + '][\'nrctaava\'];');
        eval('aux_nmdaval' + i + ' = arrayAvalistas[' + i + '][\'nmdavali\'];');
        eval('aux_nrcpfav' + i + ' = arrayAvalistas[' + i + '][\'nrcpfcgc\'];');
        eval('aux_tpdocav' + i + ' = arrayAvalistas[' + i + '][\'tpdocava\'];');
        eval('aux_dsdocav' + i + ' = arrayAvalistas[' + i + '][\'nrdocava\'];');
        eval('aux_nmdcjav' + i + ' = arrayAvalistas[' + i + '][\'nmconjug\'];');
        eval('aux_cpfcjav' + i + ' = arrayAvalistas[' + i + '][\'nrcpfcjg\'];');
        eval('aux_tdccjav' + i + ' = arrayAvalistas[' + i + '][\'tpdoccjg\'];');
        eval('aux_doccjav' + i + ' = arrayAvalistas[' + i + '][\'nrdoccjg\'];');
        eval('aux_ende1av' + i + ' = arrayAvalistas[' + i + '][\'dsendre1\'];');
        eval('aux_ende2av' + i + ' = arrayAvalistas[' + i + '][\'dsendre2\'];');
        eval('aux_nrfonav' + i + ' = arrayAvalistas[' + i + '][\'nrfonres\'];');
        eval('aux_emailav' + i + ' = arrayAvalistas[' + i + '][\'dsdemail\'];');
        eval('aux_nmcidav' + i + ' = arrayAvalistas[' + i + '][\'nmcidade\'];');
        eval('aux_cdufava' + i + ' = arrayAvalistas[' + i + '][\'cdufresd\'];');
        eval('aux_nrcepav' + i + ' = arrayAvalistas[' + i + '][\'nrcepend\'];');
        eval('aux_cdnacio' + i + ' = arrayAvalistas[' + i + '][\'cdnacion\'];');
        eval('aux_vledvmt' + i + ' = arrayAvalistas[' + i + '][\'vledvmto\'];');
        eval('aux_vlrenme' + i + ' = arrayAvalistas[' + i + '][\'vlrenmes\'];');
        eval('aux_nrender' + i + ' = arrayAvalistas[' + i + '][\'nrendere\'];');
        eval('aux_complen' + i + ' = arrayAvalistas[' + i + '][\'complend\'];');
        eval('aux_nrcxaps' + i + ' = arrayAvalistas[' + i + '][\'nrcxapst\'];');
        eval('aux_inpesso' + i + ' = arrayAvalistas[' + i + '][\'inpessoa\'];');
        eval('aux_dtnasct' + i + ' = arrayAvalistas[' + i + '][\'dtnascto\'];');
        eval('aux_vlrencj' + i + ' = arrayAvalistas[' + i + '][\'vlrencjg\'];');
    }

    return false;

}

function continuarSemValidarAvalistas(){

    if (operacao == "I") { // Incluir
        validaNrContrato();
    } else if (operacao == "A") { // Alterar
        showConfirmacao("Deseja alterar os dados do limite de desconto de cheques?","Confirma&ccedil;&atilde;o - Aimaro","gravaLimiteDscChq(\'A\')","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))","sim.gif","nao.gif");
    }     
}

function maskTelefone(nrfonemp){
    fone = nrfonemp.value.replace(/[^0-9]/g,'');    
    
    fone = fone.replace(/\D/g,"");                 //Remove tudo o que não é dígito
    fone = fone.replace(/^(\d\d)(\d)/g,"($1) $2"); //Coloca parênteses em volta dos dois primeiros dígitos
    
    if (fone.length < 14)
        fone = fone.replace(/(\d{4})(\d)/,"$1-$2");    //Coloca hífen entre o quarto e o quinto dígito
    else
        fone = fone.replace(/(\d{5})(\d)/,"$1-$2");    //Coloca hífen entre o quinto e o sexto dígito
    
    nrfonemp.value = fone.substring(0, 15);
    
    return true;
}

function confirmarConta(nomeCampoConta, nomeForm){
    
    var nrdconta = $("#divTabelaContasPorCpfCnpj table tr.corSelecao").find("input[id='nrdconta']").val();

    $('#' + nomeCampoConta,'#' + nomeForm).val(nrdconta);
    fechaRotina($('#divUsoGenerico'), $('#divRotina'));
    $('#' + nomeCampoConta, '#' + nomeForm).trigger('keydown',{keyCode: 13});
    $('#divUsoGenerico').html('');

}

function zeraCamposDadosConjugeAvalista(){

    $('#nmconjug', '#frmDadosAval').val("");
    $('#nrctacjg', '#frmDadosAval').val("");
    $('#vlrencjg', '#frmDadosAval').val("");

}
