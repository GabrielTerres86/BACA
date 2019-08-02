/**
 * Autor: Mateus Zimmermann - Mout's
 * Data: 05/12/2018
 * 
 * Alterações:
 */

// PRJ 438 - Sprint 7 - Variaveis relacionadas aos avalistas
var nrAvalistas = 0;
var contAvalistas = 1;
var maxAvalista = 2;
var arrayAvalBusca = new Object();

// Constantes
var __BOTAO_TAB = 9;
var __BOTAO_ENTER = 13;

// PRJ 438 - Sprint 7
function formataAvalista(){

	var nomeForm = 'divDadosAvalistas';

	var cTodos = $('select,input', '#' + nomeForm + ' fieldset:eq(0)');
    //var rRotulo = $('label[for="qtpromis"],label[for="nrcpfcgc"],label[for="tpdocava"],label[for="nmdavali"],label[for="nrctaava"],label[for="inpessoa"],label[for="cdnacion"]', '#' + nomeForm);
    var rRotulo = $('label[for="qtpromis"],label[for="nrcpfcgc"],label[for="tpdocava"],label[for="nmdavali"],label[for="nrctaava"],label[for="inpessoa"], label[for="dtnascto"], label[for="cdnacion"]', '#' + nomeForm); // Rafael Ferreira (Mouts) - Story 13447

    var rConta = $('label[for="nrctaava"]', '#' + nomeForm);
    var rNmdavali = $('label[for="nmdavali"]', '#' + nomeForm);
    var rInpessoa = $('label[for="inpessoa"]', '#' + nomeForm);
    var rDtnascto = $('label[for="dtnascto"]', '#' + nomeForm);

    var cQntd = $('#qtpromis', '#' + nomeForm);
    var cConta = $('#nrctaava', '#' + nomeForm);
    var cCPF = $('#nrcpfcgc', '#' + nomeForm);
    var cNome = $('#nmdavali', '#' + nomeForm);
    var cDoc = $('#tpdocava', '#' + nomeForm);
    var cNrDoc = $('#nrdocava', '#' + nomeForm);
    var cInpessoa = $('#inpessoa', '#' + nomeForm);
    var cNacio = $('#cdnacion', '#' + nomeForm);
    var cDsnacio = $('#dsnacion', '#' + nomeForm);
    var cDtnascto = $('#dtnascto', '#' + nomeForm);

    rRotulo.addClass('rotulo').css('width', '80px');
    rConta.css('width', '80px');
    rInpessoa.css('width', '80px');
    rNmdavali.css('width', '80px');
    //rDtnascto.addClass('rotulo-linha').css('width', '95px');
    rDtnascto.addClass('rotulo').css('width', '80px'); // Rafael Ferreira (Mouts) - Story 13447

    cQntd.css('width', '60px').setMask('INTEGER', 'zz9', '', '');
    cConta.addClass('conta pesquisa').css('width', '115px');
    cCPF.css('width', '134px');
    cNome.addClass('alphanum').css('width', '255px').attr('maxlength', '40');
    cDoc.css('width', '50px').hide();
    cNrDoc.addClass('alphanum').css('width', '202px').attr('maxlength', '40');        
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
                    showError('error', 'Conta/dv inv&aacute;lida.', 'Alerta - Anota', 'focaCampoErro(\'nrctaava\',\'divDadosAvalistas\');bloqueiaFundo(divRotina);');
                    return false;
                } else {
                    Busca_Associado(nrctaava, 0);
                }
            } else {
                
                cInpessoa.habilitaCampo();
                cInpessoa.focus();
                
            }

            return false;
        }
    });

    // Se pressionar alguma tecla no campo numero da conta, verificar a tecla pressionada e toda a devida ação
    cInpessoa.unbind('keydown').bind('keydown', function(e) { // Zimmermann

        if (divError.css('display') == 'block') {
            return false;
        }

        // Se é a tecla ENTER, verificar numero conta e realizar as devidas operações
        if (e.keyCode == 9) {
            
            pessoa = normalizaNumero(cInpessoa.val());
            if (pessoa == "" ) {
                showError('error', 'Selecione o tipo de pessoa', 'Aten;&atilde;o', '$("#inpessoa","#divDadosAvalistas").focus();bloqueiaFundo(divRotina);');
                return false;
            }else {
            
                cCPF.habilitaCampo();
                cCPF.focus();
            }

            return false;
        }
    });
    
    // Se pressionar alguma tecla no campo numero da conta, verificar a tecla pressionada e toda a devida ação (keydown)
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
                    showError('error', 'CPF/CNPJ inv&aacute;lido.', 'Valida&ccedil;&atilde;o CPF', '$("#nrcpfcgc","#divDadosAvalistas").focus();bloqueiaFundo(divRotina);');
                    return false;
                } else {

                    buscarContasPorCpfCnpj('aval');

                }

                // Caso em que o cpf é zero
            }

            return false;
    
    });

    cInpessoa.unbind('change').bind('change', function(e) {

    	controlaCamposTelaAvalista(false);

    });

    cNacio.unbind('change').bind('change', function(e) {
    	cDtnascto.focus();
    });

    var cTodos_1 = $('select,input', '#' + nomeForm + ' fieldset:eq(1)');

    var rRotulo_1 = $('label[for="nmconjug"],label[for="tpdoccjg"],label[for="nrctacjg"]', '#' + nomeForm);
    var rCpf_1 = $('label[for="nrcpfcjg"]', '#' + nomeForm);
    var rDoc_1 = $('label[for="tpdoccjg"]', '#' + nomeForm);
    var rVlrencjg = $('label[for="vlrencjg"]', '#' + nomeForm);
    

    var cConj = $('#nmconjug', '#' + nomeForm);
    var cCPF_1 = $('#nrcpfcjg', '#' + nomeForm);
    var cDoc_1 = $('#tpdoccjg', '#' + nomeForm);
    var cNrDoc_1 = $('#nrdoccjg', '#' + nomeForm);
    var cNrctacjg = $('#nrctacjg', '#' + nomeForm);
    var cVlrencjg = $('#vlrencjg', '#' + nomeForm);

    rRotulo_1.addClass('rotulo').css('width', '50px');
    rCpf_1.addClass('rotulo-linha').css('width', '117px');
    rDoc_1.hide();
    rVlrencjg.addClass('rotulo-linha').css('width', '70px');

    cConj.addClass('alphanum').css('width', '200px').attr('maxlength', '40');
    cCPF_1.addClass('cpf').css('width', '134px');
    cDoc_1.css('width', '50px').hide();
    cNrDoc_1.addClass('alphanum').css('width', '197px').attr('maxlength', '40').hide();
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
                    showError('error', 'Conta/dv inv&aacute;lida.', 'Alerta - Anota', 'focaCampoErro(\'nrctacjg\',\'divDadosAvalistas\');bloqueiaFundo(divRotina);');
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
                    showError('error', 'CPF inv&aacute;lido.', 'Valida&ccedil;&atilde;o CPF', '$("#nrcpfcjg","#divDadosAvalistas").focus();bloqueiaFundo(divRotina);');
                    return false;
                } else {

                    buscarContasPorCpfCnpj('aval-cje');
                }
            }
        }
    
    });

    var cTodos_2 = $('select,input', '#' + nomeForm + ' fieldset:eq(2)');

    // RÓTULOS - ENDEREÇO
    var rCep = $('label[for="nrcepend"]', '#' + nomeForm);
    var rEnd = $('label[for="dsendre1"]', '#' + nomeForm);
    var rBai = $('label[for="dsendre2"]', '#' + nomeForm);
    var rEst = $('label[for="cdufresd"]', '#' + nomeForm);
    var rCid = $('label[for="nmcidade"]', '#' + nomeForm);
    //Campos projeto CEP
    var rNum = $('label[for="nrendere"]', '#' + nomeForm);
    var rCom = $('label[for="complend"]', '#' + nomeForm);
    var rCax = $('label[for="nrcxapst"]', '#' + nomeForm);

    rCep.addClass('rotulo').css('width', '55px');
    rEnd.addClass('rotulo-linha').css('width', '35px');
    rNum.addClass('rotulo').css('width', '55px');
    rCom.addClass('rotulo-linha').css('width', '52px');
    rCax.addClass('rotulo').css('width', '55px');
    rBai.addClass('rotulo-linha').css('width', '52px');
    rEst.addClass('rotulo').css('width', '55px');
    rCid.addClass('rotulo-linha').css('width', '52px');

    // CAMPOS - ENDEREÇO
    var cCep = $('#nrcepend', '#' + nomeForm);
    var cEnd = $('#dsendre1', '#' + nomeForm);
    var cBai = $('#dsendre2', '#' + nomeForm);
    var cEst = $('#cdufresd', '#' + nomeForm);
    var cCid = $('#nmcidade', '#' + nomeForm);
    //Campos projeto CEP
    var cNum = $('#nrendere', '#' + nomeForm);
    var cCom = $('#complend', '#' + nomeForm);
    var cCax = $('#nrcxapst', '#' + nomeForm);

    cCep.addClass('pesquisa').css('width', '65px').attr('maxlength', '9');
    cEnd.addClass('alphanum').css('width', '300px').attr('maxlength', '40');
    cNum.addClass('numerocasa').css('width', '65px').attr('maxlength', '7');
    cCom.addClass('alphanum').css('width', '300px').attr('maxlength', '40');
    cCax.addClass('caixapostal').css('width', '65px').attr('maxlength', '6');
    cBai.addClass('alphanum').css('width', '300px').attr('maxlength', '40');
    cEst.css('width', '65px');
    cCid.addClass('alphanum').css('width', '300px').attr('maxlength', '25');

    //Controle contato
    var cTodos_3 = $('select,input', '#' + nomeForm + ' fieldset:eq(3)');

    var rFone = $('label[for="nrfonres"]', '#' + nomeForm);
    var rEmail = $('label[for="dsdemail"]', '#' + nomeForm);

    rFone.addClass('rotulo');
    rEmail.addClass('rotulo-linha').css('width', '55px');

    var cFone = $('#nrfonres', '#' + nomeForm);
    var cEmail = $('#dsdemail', '#' + nomeForm);

    cFone.addClass('alphanum').css('width', '100px').attr('maxlength', '19');
    cEmail.addClass('alphanum').css('width', '237px').attr('maxlength', '30');

    var cTodos_4 = $('select,input', '#' + nomeForm + ' fieldset:eq(4)');

    var rEndiv = $('label[for="vledvmto"]', '#' + nomeForm);
    var rRenda = $('label[for="vlrenmes"]', '#' + nomeForm);

    rRenda.css('width', '120px');
    rEndiv.addClass('rotulo').css('width', '105px').hide();

    var cEndiv = $('#vledvmto', '#' + nomeForm);
    var cRenda = $('#vlrenmes', '#' + nomeForm);

    cEndiv.addClass('moeda').css('width', '130px').hide();
    cRenda.addClass('moeda').css('width', '130px');

    if (aux_cddopcao == 'N') {
    	iniciaAval();
    } else {
    	cTodos.desabilitaCampo();
        cTodos_1.desabilitaCampo();
        cTodos_2.desabilitaCampo();
        cTodos_3.desabilitaCampo();
        cTodos_4.desabilitaCampo();

        $('#btLimpar', '#divDadosAvalistas').hide();
    }

    $('legend:first', '#divDadosAvalistas').html('Dados dos Avalistas/Fiadores 1');

}

function iniciaAval() {

	var nomeForm = 'divDadosAvalistas';

    var cConta = $('#nrctaava', '#' + nomeForm);

    $('select,input', '#' + nomeForm + ' fieldset').desabilitaCampo();

    if (normalizaNumero(cConta.val()) == 0) {
        cConta.habilitaCampo();
    }

    if (aux_cddopcao == 'N') {
        cConta.habilitaCampo();
    }

    return false;
}

// PRJ 438 - Sprint 7
function Busca_Associado(nrctaava, nrcpfcgc) { 

    showMsgAguardo('Aguarde, buscando dados...');

    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/atenda/limite_credito/busca_avalista.php',
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

// PRJ 438 - Sprint 7
function carregaBusca(){

    var nomeForm = 'divDadosAvalistas';

	$('#nrctaava', '#' + nomeForm).val(arrayAvalBusca['nrctaava']);
    $('#cdnacion', '#' + nomeForm).val(arrayAvalBusca['cdnacion']);
    $('#dsnacion', '#' + nomeForm).val(arrayAvalBusca['dsnacion']);
    $('#tpdocava', '#' + nomeForm).val(arrayAvalBusca['tpdocava']);
    $('#nmconjug', '#' + nomeForm).val(arrayAvalBusca['nmconjug']);
    $('#tpdoccjg', '#' + nomeForm).val(arrayAvalBusca['tpdoccjg']);
    $('#dsendre1', '#' + nomeForm).val(arrayAvalBusca['dsendre1']);
    $('#nrfonres', '#' + nomeForm).val(telefone(arrayAvalBusca['nrfonres']));
    $('#nmcidade', '#' + nomeForm).val(arrayAvalBusca['nmcidade']);
    $('#nrcepend', '#' + nomeForm).val(arrayAvalBusca['nrcepend']);
    $('#nmdavali', '#' + nomeForm).val(arrayAvalBusca['nmdavali']);
    $('#nrcpfcgc', '#' + nomeForm).val(arrayAvalBusca['nrcpfcgc']);
    $('#nrdocava', '#' + nomeForm).val(arrayAvalBusca['nrdocava']);
    $('#nrcpfcjg', '#' + nomeForm).val(arrayAvalBusca['nrcpfcjg']);
    $('#nrdoccjg', '#' + nomeForm).val(arrayAvalBusca['nrdoccjg']);
    $('#dsendre2', '#' + nomeForm).val(arrayAvalBusca['dsendre2']);
    $('#dsdemail', '#' + nomeForm).val(arrayAvalBusca['dsdemail']);
    $('#cdufresd', '#' + nomeForm).val(arrayAvalBusca['cdufresd']);
    $('#vlrenmes', '#' + nomeForm).val(arrayAvalBusca['vlrenmes']);
    $('#vledvmto', '#' + nomeForm).val(arrayAvalBusca['vledvmto']);
    $('#nrendere', '#' + nomeForm).val(arrayAvalBusca['nrendere']);
    $('#complend', '#' + nomeForm).val(arrayAvalBusca['complend']);
    $('#nrcxapst', '#' + nomeForm).val(arrayAvalBusca['nrcxapst']);
    $('#inpessoa', '#' + nomeForm).val(arrayAvalBusca['inpessoa']);
    $('#dtnascto', '#' + nomeForm).val(arrayAvalBusca['dtnascto']);
    $('#vlrencjg', '#' + nomeForm).val(arrayAvalBusca['vlrencjg']);
    $('#nrctacjg', '#' + nomeForm).val(arrayAvalBusca['nrctacjg']);

    if (normalizaNumero($('#nrctaava', '#' + nomeForm).val()) != 0) {
        $('select,input', '#' + nomeForm + ' fieldset').desabilitaCampo();
    }

    $('#nrctaava', '#' + nomeForm).habilitaCampo().focus();

    $('input', '#' + nomeForm).trigger('blur');
}

// PRJ 438 - Sprint 7
function controlaCamposTelaAvalista(cooperado){

	var inpessoa = $('#inpessoa', '#divDadosAvalistas').val();

	if(cooperado == null){
		var nrctaava = $('#nrctaava', '#divDadosAvalistas').val();
		if(nrctaava == 0){
			var cooperado = false;
		} else {
			var cooperado = true;
		}
	}

	// Rafael Ferreira (Mouts) - Story 13447
    if (inpessoa == 1) {
        $('label[for="nrctaava"]', '#divDadosAvalistas').css('width', '95px');
        $('label[for="inpessoa"]', '#divDadosAvalistas').css('width', '95px');
        $('label[for=nrcpfcgc]', '#divDadosAvalistas').css('width', '95px');
        $('label[for=nmdavali]', '#divDadosAvalistas').css('width', '95px');
        $('label[for=dtnascto]', '#divDadosAvalistas').css('width', '95px');
        //$('label[for=divCdnacion]', '#divDadosAvalistas').css('width', '95px');
        $('label[for=cdnacion]', '#divDadosAvalistas').css('width', '95px');
        $('label[for="dtnascto"], #dtnascto', '#divDadosAvalistas').text('Data Nasc.:');
    } else{
        $('label[for="nrctaava"]', '#divDadosAvalistas').css('width', '100px');
        $('label[for="inpessoa"]', '#divDadosAvalistas').css('width', '100px');
        $('label[for=nrcpfcgc]', '#divDadosAvalistas').css('width', '100px');
        $('label[for=nmdavali]', '#divDadosAvalistas').css('width', '100px');
        $('label[for=dtnascto]', '#divDadosAvalistas').css('width', '100px');
        $('label[for="dtnascto"], #dtnascto', '#divDadosAvalistas').text('Data da Abertura:');
    }
	if (inpessoa == 1 && cooperado == true) {

		$('label[for="nrcpfcgc"]', '#divDadosAvalistas').text('CPF:');
		$('label[for="nmdavali"]', '#divDadosAvalistas').text('Nome:');
		$('#divCdnacion', '#divDadosAvalistas').hide();
        $('#dsnacion', '#divDadosAvalistas').show();
		$('label[for="dtnascto"], #dtnascto', '#divDadosAvalistas').hide();
		$('label[for="dsdemail"], #dsdemail', '#divDadosAvalistas').hide();
		$('label[for="vlrenmes"]', '#divDadosAvalistas').css('width', '120px').text('Rendimento Mensal:');
		$('#fsetConjugeAval', '#divDadosAvalistas').show();

	} else if (inpessoa == 1 && cooperado == false) {

		$('label[for="nrcpfcgc"]', '#divDadosAvalistas').text('CPF:');
		$('label[for="nmdavali"]', '#divDadosAvalistas').text('Nome:');
        $('#divNacionalidade', '#divDadosAvalistas').removeClass('rotulo-linha').addClass('rotulo').show(); // Rafael Ferreira (Mouts) - Story 13447
		$('#divCdnacion', '#divDadosAvalistas').removeClass('rotulo-linha').addClass('rotulo').show(); // Rafael Ferreira (Mouts) - Story 13447
        $('#dsnacion', '#divDadosAvalistas').removeClass('rotulo-linha').addClass('rotulo').show(); // Rafael Ferreira (Mouts) - Story 13447
		$('label[for="dtnascto"], #dtnascto', '#divDadosAvalistas').show();
		$('label[for="dsdemail"], #dsdemail', '#divDadosAvalistas').show();
		$('label[for="vlrenmes"]', '#divDadosAvalistas').css('width', '120px').text('Rendimento Mensal:');
		$('#fsetConjugeAval', '#divDadosAvalistas').show();

	} else if (inpessoa == 2 && cooperado == true) {

		$('label[for="nrcpfcgc"]', '#divDadosAvalistas').text('CNPJ:');
		$('label[for="nmdavali"]', '#divDadosAvalistas').text('Razão Social:');
		//$('#divCdnacion', '#divDadosAvalistas').hide();
        $('#divNacionalidade', '#divDadosAvalistas').hide(); // Rafael Ferreira (Mouts) - Story 13447
		$('label[for="dtnascto"], #dtnascto', '#divDadosAvalistas').hide();
		$('label[for="dsdemail"], #dsdemail', '#divDadosAvalistas').hide();
		$('label[for="vlrenmes"]', '#divDadosAvalistas').css('width', '150px').text('Faturamente Médio Mensal:');
		$('#fsetConjugeAval', '#divDadosAvalistas').hide();

	} else if (inpessoa == 2 && cooperado == false) {

		$('label[for="nrcpfcgc"]', '#divDadosAvalistas').text('CNPJ:');
		$('label[for="nmdavali"]', '#divDadosAvalistas').text('Razão Social:');
        $('#divNacionalidade', '#divDadosAvalistas').hide(); // Rafael Ferreira (Mouts) - Story 13447
		$('label[for="dtnascto"], #dtnascto', '#divDadosAvalistas').show();
		$('label[for="dtnascto"]', '#divDadosAvalistas').text('Data da Abertura:');
		$('label[for="dsdemail"], #dsdemail', '#divDadosAvalistas').show();
		$('label[for="vlrenmes"]', '#divDadosAvalistas').css('width', '150px').text('Faturamente Médio Mensal:');
		$('#fsetConjugeAval', '#divDadosAvalistas').hide();

	}

}

// PRJ 438 - Sprint 7
function limpaFormAvalistas(flgLimparArray) {

    $('input, select', '#divDadosAvalistas').val('');
    
    if(flgLimparArray == true){

        var indiceAvalista = contAvalistas - 1;

        if(arrayAvalistas[indiceAvalista]){

            arrayAvalistas[indiceAvalista]['nrctaava'] = '';
            arrayAvalistas[indiceAvalista]['cdnacion'] = '';
            arrayAvalistas[indiceAvalista]['dsnacion'] = '';
            arrayAvalistas[indiceAvalista]['tpdocava'] = '';
            arrayAvalistas[indiceAvalista]['nmconjug'] = '';
            arrayAvalistas[indiceAvalista]['tpdoccjg'] = '';
            arrayAvalistas[indiceAvalista]['dsendre1'] = '';
            arrayAvalistas[indiceAvalista]['nrfonres'] = '';
            arrayAvalistas[indiceAvalista]['nmcidade'] = '';
            arrayAvalistas[indiceAvalista]['nrcepend'] = '';
            arrayAvalistas[indiceAvalista]['nmdavali'] = '';
            arrayAvalistas[indiceAvalista]['nrcpfcgc'] = '';
            arrayAvalistas[indiceAvalista]['nrdocava'] = '';
            arrayAvalistas[indiceAvalista]['nrcpfcjg'] = '';
            arrayAvalistas[indiceAvalista]['nrdoccjg'] = '';
            arrayAvalistas[indiceAvalista]['dsendre2'] = '';
            arrayAvalistas[indiceAvalista]['dsdemail'] = '';
            arrayAvalistas[indiceAvalista]['cdufresd'] = '';
            arrayAvalistas[indiceAvalista]['inpessoa'] = '';
            arrayAvalistas[indiceAvalista]['dtnascto'] = '';
            arrayAvalistas[indiceAvalista]['vlrencjg'] = '';
            arrayAvalistas[indiceAvalista]['complend'] = '';
            arrayAvalistas[indiceAvalista]['nrctacjg'] = '';
            arrayAvalistas[indiceAvalista]['nrendere'] = '';
            arrayAvalistas[indiceAvalista]['vledvmto'] = '';
            arrayAvalistas[indiceAvalista]['vlrenmes'] = '';
            arrayAvalistas[indiceAvalista]['nrcxapst'] = '';
        }
    }
    
    iniciaAval();

    return false;
}

function buscarContasPorCpfCnpj(tipoConsulta){

	var nomeForm = 'divDadosAvalistas';

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
	
	//var nrcpfcgc = $('#nrcpfcgc', '#frmDadosAval').val();
	var nrcpfcgc = $('#' + nomeCampoCpf, '#' + nomeForm).val();
	nrcpfcgc = normalizaNumero(nrcpfcgc);

	$.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/limite_credito/busca_contas_por_cpf_cnpj.php',
        data: {
        	nomeCampoConta: nomeCampoConta,
        	nomeForm: nomeForm,
            nrcpfcgc: nrcpfcgc,
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Aimaro', "unblockBackground()");
        },
        success: function(response) {
            try {
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
                	} else if (response.indexOf("$('#" + nomeCampoConta + "','#" + nomeForm + "').val") == -1) {
                		$('#divUsoGenerico').html(response);
                    	controlaLayoutContas();
                	} else {
                		hideMsgAguardo();
                    	eval(response);
                    	$('#' + nomeCampoConta, '#' + nomeForm).trigger('change');
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

function confirmarConta(nomeCampoConta, nomeForm){
	
	var nrdconta = $("#divTabelaContasPorCpfCnpj table tr.corSelecao").find("input[id='nrdconta']").val();

	$('#' + nomeCampoConta,'#' + nomeForm).val(nrdconta);
	fechaRotina($('#divUsoGenerico'), $('#divRotina'));
	$('#' + nomeCampoConta, '#' + nomeForm).trigger('change');

	$('#divUsoGenerico').html('');

}

function habilitarCamposAvalista(){

	var nomeForm = 'divDadosAvalistas';

	var cTodos = $('select,input', '#' + nomeForm);
	var cTodos_1 = $('select,input', '#' + nomeForm + ' fieldset:eq(1)');
	var cTodos_2 = $('select,input', '#' + nomeForm + ' fieldset:eq(2)');
	var cTodos_3 = $('select,input', '#' + nomeForm + ' fieldset:eq(3)');
	var cTodos_4 = $('select,input', '#' + nomeForm + ' fieldset:eq(4)');
	var cQntd = $('#qtpromis', '#' + nomeForm);
    var cConta = $('#nrctaava', '#' + nomeForm);
    var cNome = $('#nmdavali', '#' + nomeForm);

	// Se nao for acessado via CRM, pode habilitar os campos
    if ($('#crm_inacesso', '#' + nomeForm).val() != 1 ) {
        cTodos.habilitaCampo();
        cTodos_1.habilitaCampo();
        cTodos_2.habilitaCampo();
        cTodos_3.habilitaCampo();
    	cTodos_4.habilitaCampo();
        cConta.desabilitaCampo().val(nrctaava);

        $('#dsendre1,#cdufresd,#dsendre2,#nmcidade,#dsnacion', '#' + nomeForm).desabilitaCampo();
        controlaPesquisas();
        cNome.focus();
        
    }
}

function insereAvalista() {

    i = arrayAvalistas.length;

    eval('var arrayAvalista' + i + ' = new Object();');
    eval('arrayAvalista' + i + '["nrctaava"] = $("#nrctaava","#divDadosAvalistas").val();');
    eval('arrayAvalista' + i + '["cdnacion"] = $("#cdnacion","#divDadosAvalistas").val();');
    eval('arrayAvalista' + i + '["dsnacion"] = $("#dsnacion","#divDadosAvalistas").val();');
    eval('arrayAvalista' + i + '["tpdocava"] = $("#tpdocava","#divDadosAvalistas").val();');
    eval('arrayAvalista' + i + '["nmconjug"] = $("#nmconjug","#divDadosAvalistas").val();');
    eval('arrayAvalista' + i + '["tpdoccjg"] = $("#tpdoccjg","#divDadosAvalistas").val();');
    eval('arrayAvalista' + i + '["dsendre1"] = $("#dsendre1","#divDadosAvalistas").val();');
    eval('arrayAvalista' + i + '["nrfonres"] = $("#nrfonres","#divDadosAvalistas").val();');
    eval('arrayAvalista' + i + '["nmcidade"] = $("#nmcidade","#divDadosAvalistas").val();');
    eval('arrayAvalista' + i + '["nrcepend"] = $("#nrcepend","#divDadosAvalistas").val();');
    eval('arrayAvalista' + i + '["nmdavali"] = $("#nmdavali","#divDadosAvalistas").val();');
    eval('arrayAvalista' + i + '["nrcpfcgc"] = $("#nrcpfcgc","#divDadosAvalistas").val();');
    eval('arrayAvalista' + i + '["nrdocava"] = $("#nrdocava","#divDadosAvalistas").val();');
    eval('arrayAvalista' + i + '["nrcpfcjg"] = $("#nrcpfcjg","#divDadosAvalistas").val();');
    eval('arrayAvalista' + i + '["nrdoccjg"] = $("#nrdoccjg","#divDadosAvalistas").val();');
    eval('arrayAvalista' + i + '["dsendre2"] = $("#dsendre2","#divDadosAvalistas").val();');
    eval('arrayAvalista' + i + '["dsdemail"] = $("#dsdemail","#divDadosAvalistas").val();');
    eval('arrayAvalista' + i + '["cdufresd"] = $("#cdufresd","#divDadosAvalistas").val();');
    eval('arrayAvalista' + i + '["vlrenmes"] = $("#vlrenmes","#divDadosAvalistas").val();');
    eval('arrayAvalista' + i + '["vledvmto"] = $("#vledvmto","#divDadosAvalistas").val();');
    eval('arrayAvalista' + i + '["nrendere"] = $("#nrendere","#divDadosAvalistas").val();');
    eval('arrayAvalista' + i + '["complend"] = $("#complend","#divDadosAvalistas").val();');
    eval('arrayAvalista' + i + '["nrcxapst"] = $("#nrcxapst","#divDadosAvalistas").val();');
    eval('arrayAvalista' + i + '["inpessoa"] = $("#inpessoa","#divDadosAvalistas").val();');
    eval('arrayAvalista' + i + '["dtnascto"] = $("#dtnascto","#divDadosAvalistas").val();');
    eval('arrayAvalista' + i + '["vlrencjg"] = $("#vlrencjg","#divDadosAvalistas").val();');

    eval('arrayAvalistas[' + i + '] = arrayAvalista' + i + ';');

    nrAvalistas++;
    
    return false;

}

function validaDadosAval() {

	showMsgAguardo('Aguarde, validando avalista...');

	var nomeForm = 'divDadosAvalistas';

    $('input,select', '#' + nomeForm).removeClass('campoErro');

    var qtpromis = $('#qtpromis', '#' + nomeForm).val();
    var nmdavali = $('#nmdavali', '#' + nomeForm).val();
    var nrcpfcgc = normalizaNumero($('#nrcpfcgc', '#' + nomeForm).val());
    var nrctaava = normalizaNumero($('#nrctaava', '#' + nomeForm).val());
    var nrcpfcjg = normalizaNumero($('#nrcpfcjg', '#' + nomeForm).val());
    var dsendre1 = $('#dsendre1', '#' + nomeForm).val();
    var cdufresd = $('#cdufresd', '#' + nomeForm).val();
    var nrcepend = normalizaNumero($('#nrcepend', '#' + nomeForm).val());

    var idavalis = contAvalistas;

    var inpessoa = $('#inpessoa', '#' + nomeForm).val();
    var dtnascto = $('#dtnascto', '#' + nomeForm).val();

    // if (operacao == 'AI_DADOS_AVAL' || operacao == 'I_DADOS_AVAL') {
    //     idavalis++;
    // }

    var nrcpfav1 = 0;
    var nrctaav1 = 0;

    if (arrayAvalistas.length > 0) {
        nrctaav1 = normalizaNumero(arrayAvalistas[0]['nrctaava']);
        nrcpfav1 = normalizaNumero(arrayAvalistas[0]['nrcpfcgc']);
    } else if (idavalis == 1) {
        nrctaav1 = normalizaNumero($('#nrctaava', '#' + nomeForm).val());
        nrcpfav1 = normalizaNumero($('#nrcpfcjg', '#' + nomeForm).val());
    }

    var aux_retorno = false;

    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        async: false,
        url: UrlSite + 'telas/atenda/limite_credito/valida_avalistas.php',
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
            nomeform: nomeForm,
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

function buscarDadosContaConjuge(){

	var nomeForm = 'divDadosAvalistas';	
	var nrdconta = $('#nrctacjg', '#' + nomeForm).val();
	nrdconta = normalizaNumero(nrdconta);

	$.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/limite_credito/busca_dados_conta_conjuge.php',
        data: {
        	nrdconta: nrdconta,
        	nomeForm: nomeForm,
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Aimaro', "blockBackground(parseInt($('#divRotina').css('z-index')))");
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

// PRJ 438 - Sprint 7 - Funcao para nao validar os Avalistas novamente
function continuarSemValidarAvalistas(){
    if(flgProposta){
		showConfirmacao("Deseja alterar o " + strTitRotinaLC + "?","Confirma&ccedil;&atilde;o - Aimaro","alterarNovoLimite();","acessaOpcaoAba(8,0,\'@\');","sim.gif","nao.gif");
	}else{
		// Mostra mensagem para confirmar cadastro do novo limite de crédito
		showConfirmacao("Deseja cadastrar o novo " + strTitRotinaLC + "?","Confirma&ccedil;&atilde;o - Aimaro","cadastrarNovoLimite()","acessaOpcaoAba(8,0,\'@\');","sim.gif","nao.gif");
	}
}

function atualizarCamposTelaAvalistas(flgAttContAvalistas){

    if (flgAttContAvalistas == true) {
        contAvalistas++;
    }

    var indiceAvalista = contAvalistas - 1;

	if(arrayAvalistas[indiceAvalista]){

		$('#nrctaava', '#divDadosAvalistas').val(arrayAvalistas[indiceAvalista]['nrctaava']);
		$('#cdnacion', '#divDadosAvalistas').val(arrayAvalistas[indiceAvalista]['cdnacion']);
		$('#dsnacion', '#divDadosAvalistas').val(arrayAvalistas[indiceAvalista]['dsnacion']);
		$('#tpdocava', '#divDadosAvalistas').val(arrayAvalistas[indiceAvalista]['tpdocava']);
		$('#nmconjug', '#divDadosAvalistas').val(arrayAvalistas[indiceAvalista]['nmconjug']);
		$('#tpdoccjg', '#divDadosAvalistas').val(arrayAvalistas[indiceAvalista]['tpdoccjg']);
		$('#dsendre1', '#divDadosAvalistas').val(arrayAvalistas[indiceAvalista]['dsendre1']);
		$('#nrfonres', '#divDadosAvalistas').val(telefone(arrayAvalistas[indiceAvalista]['nrfonres']));
		$('#nmcidade', '#divDadosAvalistas').val(arrayAvalistas[indiceAvalista]['nmcidade']);
		$('#nrcepend', '#divDadosAvalistas').val(arrayAvalistas[indiceAvalista]['nrcepend']);
		$('#nmdavali', '#divDadosAvalistas').val(arrayAvalistas[indiceAvalista]['nmdavali']);
		$('#nrcpfcgc', '#divDadosAvalistas').val(arrayAvalistas[indiceAvalista]['nrcpfcgc']);
		$('#nrdocava', '#divDadosAvalistas').val(arrayAvalistas[indiceAvalista]['nrdocava']);
		$('#nrcpfcjg', '#divDadosAvalistas').val(arrayAvalistas[indiceAvalista]['nrcpfcjg']);
		$('#nrdoccjg', '#divDadosAvalistas').val(arrayAvalistas[indiceAvalista]['nrdoccjg']);
		$('#dsendre2', '#divDadosAvalistas').val(arrayAvalistas[indiceAvalista]['dsendre2']);
		$('#dsdemail', '#divDadosAvalistas').val(arrayAvalistas[indiceAvalista]['dsdemail']);
		$('#cdufresd', '#divDadosAvalistas').val(arrayAvalistas[indiceAvalista]['cdufresd']);
		$('#vlrenmes', '#divDadosAvalistas').val(arrayAvalistas[indiceAvalista]['vlrenmes']);
		$('#vledvmto', '#divDadosAvalistas').val(arrayAvalistas[indiceAvalista]['vledvmto']);
		$('#inpessoa', '#divDadosAvalistas').val(arrayAvalistas[indiceAvalista]['inpessoa']);
		$('#dtnascto', '#divDadosAvalistas').val(arrayAvalistas[indiceAvalista]['dtnascto']);
		$('#nrendere', '#divDadosAvalistas').val(arrayAvalistas[indiceAvalista]['nrendere']);
		$('#complend', '#divDadosAvalistas').val(arrayAvalistas[indiceAvalista]['complend']);
		$('#nrcxapst', '#divDadosAvalistas').val(arrayAvalistas[indiceAvalista]['nrcxapst']);
		$('#vlrencjg', '#divDadosAvalistas').val(arrayAvalistas[indiceAvalista]['vlrencjg']);
		$('#nrctacjg', '#divDadosAvalistas').val(arrayAvalistas[indiceAvalista]['nrctacjg']);

	} else {
		limpaFormAvalistas(false);
	}

    $('legend:first', '#divDadosAvalistas').html('Dados dos Avalistas/Fiadores ' + contAvalistas);

    controlaCamposTelaAvalista();
    $('input', '#divDadosAvalistas').trigger('blur');

}

function controlaContinuarAvalista(){

	showMsgAguardo('Aguarde, carregando avalista...');

	var nomeForm = 'divDadosAvalistas'; 

    var aux_conta = normalizaNumero($('#nrctaava', '#' + nomeForm).val());
    var aux_cpf = normalizaNumero($('#nrcpfcgc', '#' + nomeForm).val());
    var indiceAvalista = contAvalistas - 1;

    if($('#nrcpfcgc', '#' + nomeForm).val() == "" && $('#nmdavali', '#' + nomeForm).val() == "" && $('#nrctaava', '#' + nomeForm).val()){
        $('#nrctaava', '#' + nomeForm).trigger('keydown',{keyCode: 13});
        return false;
    }

    if(aux_cddopcao != 'N'){
        hideMsgAguardo();
        bloqueiaFundo(divRotina);
    } else {
        if (!validaDadosAval()) {
            return false;
        }
    }

    if (aux_conta == 0 && aux_cpf == 0 && arrayAvalistas.length == 0) {
		abrirTelaDemoLimiteCredito(true);
        return false;
    }

    // Se for novo limite ou alteracao
    if(aux_cddopcao == 'N'){
        // Se os valores de conta e cpf estiverem vazios, entao pode inserir um avalista no array atual 
        if(nrAvalistas == 0 || !arrayAvalistas[indiceAvalista]){
        	insereAvalista();

        // Se os valores de conta e cpf NÃO estiverem vazios, entao será inserir os dados do avalista no array atual 	
        } else if((aux_conta || aux_cpf) && arrayAvalistas[indiceAvalista]){
        	atualizaArrayAvalistas();
        }
    }

	// Verificar se tem mais Avalistas para mostrar/incluir
	if (contAvalistas < nrAvalistas || (nrAvalistas < maxAvalista && aux_cddopcao == 'N')) {
		// Carregar o outro avalista
        atualizarCamposTelaAvalistas(true);
    } else {
    	abrirTelaDemoLimiteCredito(true);
    }

}

function atualizaArrayAvalistas(){

	var indiceAvalista = contAvalistas - 1;

	arrayAvalistas[indiceAvalista]['nrctaava'] = $('#nrctaava', '#divDadosAvalistas').val();
	arrayAvalistas[indiceAvalista]['cdnacion'] = $('#cdnacion', '#divDadosAvalistas').val();
	arrayAvalistas[indiceAvalista]['dsnacion'] = $('#dsnacion', '#divDadosAvalistas').val();
	arrayAvalistas[indiceAvalista]['tpdocava'] = $('#tpdocava', '#divDadosAvalistas').val();
	arrayAvalistas[indiceAvalista]['nmconjug'] = $('#nmconjug', '#divDadosAvalistas').val();
	arrayAvalistas[indiceAvalista]['tpdoccjg'] = $('#tpdoccjg', '#divDadosAvalistas').val();
	arrayAvalistas[indiceAvalista]['dsendre1'] = $('#dsendre1', '#divDadosAvalistas').val();
	arrayAvalistas[indiceAvalista]['nrfonres'] = $('#nrfonres', '#divDadosAvalistas').val();
	arrayAvalistas[indiceAvalista]['nmcidade'] = $('#nmcidade', '#divDadosAvalistas').val();
	arrayAvalistas[indiceAvalista]['nrcepend'] = $('#nrcepend', '#divDadosAvalistas').val();
	arrayAvalistas[indiceAvalista]['nmdavali'] = $('#nmdavali', '#divDadosAvalistas').val();
	arrayAvalistas[indiceAvalista]['nrcpfcgc'] = $('#nrcpfcgc', '#divDadosAvalistas').val();
	arrayAvalistas[indiceAvalista]['nrdocava'] = $('#nrdocava', '#divDadosAvalistas').val();
	arrayAvalistas[indiceAvalista]['nrcpfcjg'] = $('#nrcpfcjg', '#divDadosAvalistas').val();
	arrayAvalistas[indiceAvalista]['nrdoccjg'] = $('#nrdoccjg', '#divDadosAvalistas').val();
	arrayAvalistas[indiceAvalista]['dsendre2'] = $('#dsendre2', '#divDadosAvalistas').val();
	arrayAvalistas[indiceAvalista]['dsdemail'] = $('#dsdemail', '#divDadosAvalistas').val();
	arrayAvalistas[indiceAvalista]['cdufresd'] = $('#cdufresd', '#divDadosAvalistas').val();
	arrayAvalistas[indiceAvalista]['vlrenmes'] = $('#vlrenmes', '#divDadosAvalistas').val();
	arrayAvalistas[indiceAvalista]['vledvmto'] = $('#vledvmto', '#divDadosAvalistas').val();
	arrayAvalistas[indiceAvalista]['nrendere'] = $('#nrendere', '#divDadosAvalistas').val();
	arrayAvalistas[indiceAvalista]['complend'] = $('#complend', '#divDadosAvalistas').val();
	arrayAvalistas[indiceAvalista]['nrcxapst'] = $('#nrcxapst', '#divDadosAvalistas').val();
	arrayAvalistas[indiceAvalista]['inpessoa'] = $('#inpessoa', '#divDadosAvalistas').val();
	arrayAvalistas[indiceAvalista]['dtnascto'] = $('#dtnascto', '#divDadosAvalistas').val();
	arrayAvalistas[indiceAvalista]['vlrencjg'] = $('#vlrencjg', '#divDadosAvalistas').val();

}

// PRJ 468 - Sprint 7
function controlaVoltarAvalista(){
    // Verifica se está no Avalista 2, se sim, entao deve voltar para o Avalista 1, senão volta para a tela Rating
    if(contAvalistas == 2){
        contAvalistas = 1;
        atualizarCamposTelaAvalistas();
    } else {
        $('#frmNovoLimite').css('width', 515);
        lcrShowHideDiv('divFormRating','divDadosAvalistas'); 
        return false;
    }   
}

function aplicarEventosLupasTelaAvalista(){

    // Conta Avalista
    $('#nrctaava','#'+nomeForm).next().unbind('click').bind('click', function () {
        if ($('#nrctaava','#'+nomeForm).hasClass('campoTelaSemBorda')) {
            return false;
        }
        mostraPesquisaAssociado('nrctaava', nomeForm, divRotina);
        return false;
    });
    

    // Nacionalidade
    $('#cdnacion','#'+nomeForm).unbind('change').bind('change', function() {
        procedure    = 'BUSCANACIONALIDADES';
        titulo      = ' Nacionalidade';
        filtrosDesc = '';
        buscaDescricao('ZOOM0001',procedure,titulo,$(this).attr('name'),'dsnacion',$(this).val(),'dsnacion',filtrosDesc,'divDadosAvalistas'); 
        return false;
    }).next().unbind('click').bind('click', function () {
        if ($('#cdnacion','#'+nomeForm).hasClass('campoTelaSemBorda')) {
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
    $('#nrcepend','#'+nomeForm).unbind('change').bind('change', function() {
        mostraPesquisaEndereco(nomeForm, camposOrigem, divRotina, $(this).val());
        return false;
    }).next().unbind('click').bind('click', function () {
        if ($('#nrcepend','#'+nomeForm).hasClass('campoTelaSemBorda')) {
            return false;
        }
        mostraPesquisaEndereco(nomeForm, camposOrigem, divRotina);
        return false;
    });
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