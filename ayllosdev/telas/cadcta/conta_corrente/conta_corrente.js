/*!
 * FONTE        : conta_corrente.js
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 12/05/2010 
 * OBJETIVO     : Biblioteca de funções na rotina CONTA CORRENTE da tela de CONTAS
 * --------------
 * ALTERAÇÕES   : 29/07/2010 - Fixo crapcop.cdbcoctl para Bco Emis Cheque (Guilherme)
 *		  
 *		  		  21/11/2011 - Alterado campos readonly para disabled (Jorge)
 *   
 * 		  		  09/07/2012 - Ajuste para novo esquema de impressao em  imprimeCritica() 
 * 		  			           Retirado campo "redirect" popup (Jorge)
 *  
 *		          08/02/2013 - Ajuste para novo campo em tela Grau de acesso (Lucas R.)
 *  
 *		          12/06/2013 - Consorcio (Gabriel)	
 *
 *                14/08/2013 - Alteração da sigla PAC para PA (Carlos).
 *	
 * 		  		  29/10/2013 - Bloquear o campo "Esta no SPC" para as cooperativas
 *                			   "1,16,13" (James)
 *
 * 		          05/11/2013 - Remover a condicao para bloquear o campo 
 *                			   "Esta no SPC" para as cooperativas "1,16,13"(James)
 *
 *                28/05/2014 - Inclusao do campo Libera Credito Pre Aprovado 
 *                             'flgcrdpa' (Jaison).
 *		  	      10/07/2014 - Alterações para criticar propostas de cart. cred. em aberto
 *		                       durante exclusão de titulares (Lucas Lunelli - Projeto Bancoob).
 *
 *		  		  08/08/2014 - Retirar campos do SPC e Serasa (Jonata-RKAM)
 *
 *                28/08/2014 - Incluir campo Dscadpos Projeto Cadastro Positivo (Lucas R/Thiago Rodrigues)
 *
 *                05/08/2015 - Reformulacao cadastral (Gabriel-RKAM).
 *                
 *                11/08/2015 - Projeto 218 - Melhorias Tarifas (Carlos Rafael Tanholi).
 *				  
 *				  27/10/2015 - Projeto 131 - Inclusão do campo “Exige Assinatura Conjunta em Autoatendimento”
 *							   (Jean Michel).	 
 *
 *				  02/11/2015 - Melhoria 126 - Encarteiramento de cooperados (Heitor - RKAM).
 *
 *                07/01/2016 - Remover campo de Libera Credito Pre Aprovado (Anderson).
 *
 *			      15/07/2016 - Incluir ajustes referentes a flag de devolução automatica - Melhoria 69(Lucas Ranghetti #484923)
 */
var operacao = '';
var nrdrowid = '';
var tpevento = '';
var tpevento = '';
var msgconfi = '';
var cdtipcta = ''; // Tipo da Conta
var nomeForm = 'frmContaCorrente';
var flgcreca = 'no';
var flgexclu = 'no';
var cdbcoctl = 0;
var flgfirst = true;
var flgContinuar = false;
var CriticasExcTitulares = new Array();
var idConfirmouSenha = 0;
var opCoordenador = '';
var tiposConta = [];

function acessaOpcaoAba(nrOpcoes, id, opcao) {

    // Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, carregando ' + nmrotina + ' ...');

    // Atribui cor de destaque para aba da opção
    for (var i = 0; i < nrOpcoes; i++) {
        if (!$('#linkAba' + id)) {
            continue;
        }

        if (id == i) { // Atribui estilos para foco da opção
            $('#linkAba' + id).attr('class', 'txtBrancoBold');
            $('#imgAbaEsq' + id).attr('src', UrlImagens + 'background/mnu_sle.gif');
            $('#imgAbaDir' + id).attr('src', UrlImagens + 'background/mnu_sld.gif');
            $('#imgAbaCen' + id).css('background-color', '#969FA9');
            continue;
        }

        $('#linkAba' + i).attr('class', 'txtNormalBold');
        $('#imgAbaEsq' + i).attr('src', UrlImagens + 'background/mnu_nle.gif');
        $('#imgAbaDir' + i).attr('src', UrlImagens + 'background/mnu_nld.gif');
        $('#imgAbaCen' + i).css('background-color', '#C6C8CA');
    }

    // Carrega conteúdo da opção através do Ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cadcta/conta_corrente/principal.php',
        data: {
            nrdconta: nrdconta,
            idseqttl: idseqttl,
            flgcadas: flgcadas,
            operacao: operacao,
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
        },
        success: function(response) {
            $('#divConteudoOpcao').html(response);
            return false;
        }
    });
}

function controlaOperacao(operacao) {
	
    if ((operacao == 'CA') && (flgAlterar != '1')) {
        showError('error', 'Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de altera&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
        return false;
    }
    if ((operacao == 'VT') && (flgExcluir != '1')) {
        showError('error', 'Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de exclus&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
        return false;
    }
    if ((operacao == 'VS') && (flgSolITG != '1')) {
        showError('error', 'Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de solicitar ITG.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
        return false;
    }
    if ((operacao == 'VG') && (flgEncerrar != '1')) {
        showError('error', 'Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de encerrar ITG.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
        return false;
    }
	
    // Mostra mensagem de aguardo
    var msgOperacao = '';
    switch (operacao) {
        // Consulta para Alteração
        case 'CA':
            flgexclu = 'no';
            msgOperacao = 'abrindo altera&ccedil;&atilde;o da ' + nmrotina;
            break;
            // Alteração para Consulta
        case 'AC':
            showConfirmacao('Deseja cancelar opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'controlaOperacao(\'\')', 'bloqueiaFundo(divRotina)', 'sim.gif', 'nao.gif');
            return false;
            break;
        case 'AV':  //alteração para validação
            manterRotina(operacao);
            return false;
            break;
        case 'VT': //valida exclusão de titulares
            manterRotina(operacao);
            return false;
            break;
        case 'TE': //apos validar exclui titulares
            fechaRotina($('#divUsoGenerico'), $('#divRotina'));
            manterRotina(operacao);
            return false;
            break;
            // Validação para Alteração: Salvando Alteração
        case 'VA':
            manterRotina(operacao);
            return false;
            break;
        case 'VG': //Valida encerrar ITG
            manterRotina(operacao);
            return false;
            break;
        case 'GE': //Apos validar encerra ITG
            manterRotina(operacao);
            return false;
            break;
        case 'VS': //Valida Solicitar ITG
            manterRotina(operacao);
            return false;
            break;
        case 'SE': //Apos validar solicita ITG
            manterRotina(operacao);
            return false;
            break;
        case 'OC': //Atualizar cabecalho de dados do cooperado -> obtemCabecalho()
            msgOperacao = 'carregando ' + nmrotina;
            operacao = ''
            idseqttl = $('#idseqttl', '#frmCabContas').val();
            obtemCabecalho(idseqttl, false, true);
            break;
        case 'erro':
            showError('error', msgErro, 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
            return false;
            break;
            // Qualquer outro valor: Cancelando Operação
        default:
            msgOperacao = 'carregando ' + nmrotina;
            break;
    }

    showMsgAguardo('Aguarde, ' + msgOperacao + '...');

    // Executa script de através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cadcta/conta_corrente/principal.php',
        data: {
            nrdconta: nrdconta,
            idseqttl: idseqttl,
            flgcadas: flgcadas,
            operacao: operacao,
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
        },
        success: function(response) {
            $('#divConteudoOpcao').html(response);
            return false;
        }
    });
}

function manterRotina(operacao) {
    // Primerio oculta a mensagem de aguardo
    hideMsgAguardo();
	
    var msgOperacao = '';
    switch (operacao) {
        case 'VE':
            msgOperacao = 'validando tipo de conta';
            break;
        case 'VA':
            msgOperacao = 'salvando altera&ccedil;&atilde;o da ' + nmrotina;
            break;
        case 'AV':
            msgOperacao = 'validando dados da ' + nmrotina;
            break;
        case 'VT':
            msgOperacao = 'validando dados da ' + nmrotina;
            break;
        case 'TE':
            msgOperacao = 'excluindo titulares da ' + nmrotina;
            break;
        case 'VG':
            msgOperacao = 'validando dados da ' + nmrotina;
            break;
        case 'GE':
            msgOperacao = 'encerrando ITG';
            break;
        case 'VS':
            msgOperacao = 'validando dados da ' + nmrotina;
            break;
        case 'SE':
            msgOperacao = 'solicitando/reativando ITG';
            break;
        case 'GC':
            msgOperacao = 'cadastrando Conta Consorcio';
            break;
		case 'BC':
			msgOperacao = 'Buscando Consultor';
			break;
		case 'EE':
			msgOperacao = 'Enviando email';
			break;
        default:
            return false;
            break;
    }

	if ((operacao == 'VA') && ($('#cdagepac', '#' + nomeForm).val() != cdageant) && (idConfirmouSenha == 0)) {
		showError('error', 'Para altera&ccedil;&atilde;o de PAs, &eacute; obrigat&oacute;ria a autoriza&ccedil;&atilde;o do Coordenador ou Gerente.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina); return false;');
	} else {
    // Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, ' + msgOperacao + ' ...');

    nrdrowid = '';
    cdagepac = $('#cdagepac', '#' + nomeForm).val();
    cdsitdct = $('#cdsitdct', '#' + nomeForm).val();
    cdtipcta = $('#cdtipcta', '#' + nomeForm).val();
    cdcatego = $('#cdcatego', '#' + nomeForm).val();
    cdbcochq = $('#cdbcochq', '#' + nomeForm).val();
    nrdctitg = normalizaNumero($('#nrdctitg', '#' + nomeForm).val());
    cdagedbb = $('#cdagedbb', '#' + nomeForm).val();
    cdbcoitg = $('#cdbcoitg', '#' + nomeForm).val();
    cdsecext = $('#cdsecext', '#' + nomeForm).val();
    dtcnsscr = $('#dtcnsscr', '#' + nomeForm).val();
    dtcnsspc = $('#dtcnsspc', '#' + nomeForm).val();
    dtdsdspc = $('#dtdsdspc', '#' + nomeForm).val();
    dtabtcoo = $('#dtabtcoo', '#' + nomeForm).val();
    dtelimin = $('#dtelimin', '#' + nomeForm).val();
    dtabtcct = $('#dtabtcct', '#' + nomeForm).val();
    dtdemiss = $('#dtdemiss', '#' + nomeForm).val();
    inadimpl = $('#inadimpl', '#' + nomeForm).val();
	cdconsul = $('#cdconsultor', '#' + nomeForm).val(); //Melhoria 126
   
    flgiddep = $('input[name="flgiddep"]:checked', '#' + nomeForm).val();
    tpavsdeb = $('input[name="tpavsdeb"]:checked', '#' + nomeForm).val();
    tpextcta = $('input[name="tpextcta"]:checked', '#' + nomeForm).val();
    inlbacen = $('input[name="inlbacen"]:checked', '#' + nomeForm).val();
    flgrestr = $('input[name="flgrestr"]:checked', '#' + nomeForm).val();
    indserma = $('input[name="indserma"]:checked', '#' + nomeForm).val();
	idastcjt = $('input[name="idastcjt"]:checked', '#' + nomeForm).val();
	
	flgdevolu_autom_alt = $('input[name="flgdevolu_autom"]:checked', '#' + nomeForm).val();
	opCoordenador = $('#operauto', '#frmSenha').val();
	
    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/cadcta/conta_corrente/manter_rotina.php',
        data: {
            nrdconta: nrdconta, idseqttl: idseqttl, nrdrowid: nrdrowid,
            cdagepac: cdagepac, cdsitdct: cdsitdct, cdtipcta: cdtipcta,
            cdbcochq: cdbcochq, nrdctitg: nrdctitg, cdagedbb: cdagedbb,
            cdbcoitg: cdbcoitg, cdsecext: cdsecext, dtcnsscr: dtcnsscr,
            dtcnsspc: dtcnsspc, dtdsdspc: dtdsdspc, dtabtcoo: dtabtcoo,
            dtelimin: dtelimin, dtabtcct: dtabtcct, dtdemiss: dtdemiss,
            flgiddep: flgiddep, tpavsdeb: tpavsdeb, cdcatego: cdcatego,
            tpextcta: tpextcta, flgrestr: flgrestr, inadimpl: inadimpl,
            inlbacen: inlbacen, flgexclu: flgexclu, flgcreca: flgcreca,
            operacao: operacao, flgcadas: flgcadas, indserma: indserma,
			cdconsul: cdconsul, idastcjt: idastcjt,	cdageant: cdageant,
			flgdevolu_autom: flgdevolu_autom_alt, cdopecor: opCoordenador,
			inpessoa: inpessoa,
				redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.(' + responseError + ')', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
        },
        success: function(response) {
            try {
					//Envia email de troca de PAs
					if (($('#cdagepac', '#' + nomeForm).val() != cdageant) && (operacao == 'VA')) {
						//Envia Email
						manterRotina('EE');
					}

                if (response != "") {
                    eval(response);
                }

                // Se veio direto da MATRIC, vai pra proxima rotina apos salvar
                /* Não é mais necessario
                if (operacao == 'VA' && (flgcadas == 'M' || flgContinuar) ) {
                    proximaRotina();
                }*/

                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
            }
        }
    });
}
}

function controlaLayout(operacao) {
    altura = '460px';
    largura = '612px';
    divRotina.css('width', largura);
    $('#divConteudoOpcao').css('height', altura);

    $('input', '#' + nomeForm).unbind('blur');

    // FORMATAÇÃO COMUM
    var rLinha = $('label[for="cdsitdct"],label[for="cdbcochq"],label[for="cdbcoitg"],label[for="cdagedbb"]', '#' + nomeForm);
    var cTodos = $('input, select', '#' + nomeForm);
    var cCodigo = $('#cdagepac,#cdsecext', '#' + nomeForm);
    var cRadio = $('input[type="radio"]', '#' + nomeForm);
    var cSelect = $('select', '#' + nomeForm);
    var cDatas = $('#dtabtcoo,#dtabtcct,#dtelimin,#dtdemiss,#dtcnsscr', '#' + nomeForm);

    rLinha.addClass('rotulo-linha');
    cTodos.addClass('campoTelaSemBorda').prop('disabled', true);
    cCodigo.addClass('codigo pesquisa');
    cRadio.prop('disabled', true).css({'border': 'none'});
    cSelect.prop('disabled', true);
    cDatas.addClass('data');


    // FIELDSET PRINCIPAL		
    var rPrincipal = $('label[for="cdagepac"],label[for="cdtipcta"],label[for="cdcatego"],label[for="nrdctitg"],label[for="nrctacns"]', '#' + nomeForm);
    var cSituacao = $('#cdsitdct', '#' + nomeForm);
    var cContaITG = $('#nrdctitg', '#' + nomeForm);
    var cBcoCheque = $('#cdbcochq', '#' + nomeForm);
    var cSitCtaITG = $('#dssititg', '#' + nomeForm);
    var cTipoConta = $('#cdtipcta', '#' + nomeForm);
    var cCdcatego = $('#cdcatego', '#' + nomeForm);
    var cDescPrinc = $('#dsagepac', '#' + nomeForm);
    var cAgeBcoITG = $('#cdagedbb,#cdbcoitg', '#' + nomeForm);
    var cNrctacns = $('#nrctacns', '#' + nomeForm);
    var cDscadpos = $('#dscadpos', '#' + nomeForm);
	var cCdconsul = $('#cdconsultor', '#' + nomeForm);

	

    rPrincipal.addClass('rotulo').css('width', '100px');
    cDescPrinc.addClass('descricao').css('width', '203px');
    cSituacao.css('width', '147px');
    cTipoConta.css('width', '259px');
    cCdcatego.css('width', '159px');
    cContaITG.css('width', '100px').addClass('contaitg');
    cNrctacns.css('width', '100px').addClass('conta');
    cDscadpos.css('width', '100px');
    cBcoCheque.css('width', '47px').addClass('inteiro');
    cAgeBcoITG.css('width', '47px').addClass('inteiro');
	cCdconsul.css('width', '47px').addClass('inteiro');
    cSitCtaITG.css({'background-color': '#F7F3FF', 'width': '155px', 'border': '1px solid #F7F3FF', 'color': '#333', 'text-transform': 'uppercase', 'padding-left': '0px'});

    // FIELDSET GERAL
    var rGeral_1 = $('label[for="flgiddep"],label[for="tpavsdeb"]', '#' + nomeForm);
    var rGeral_2 = $('label[for="tpextcta"],label[for="cdsecext"]', '#' + nomeForm);
    var rGeral_3 = $('label[for="flgrestr"],label[for="flgrestr"]', '#' + nomeForm);
    var rGeral_4 = $('label[for="cdconsultor"]', '#' + nomeForm);
    var rGeral_5 = $('label[for="indserma"],label[for="indserma"]', '#' + nomeForm);
	var rGeral_6 = $('label[for="idastcjt"],label[for="idastcjt"]', '#' + nomeForm);
	var rGeral_7 = $('label[for="flgdevolu_autom"],label[for="flgdevolu_autom"]', '#' + nomeForm);

    var cCdoplcpa = $('#cdoplcpa', '#' + nomeForm).val();
    var cDestino = $('#dssecext,#nmconsultor', '#' + nomeForm);
    var rDscadpos = $('label[for="dscadpos"]', '#' + nomeForm);

    rDscadpos.css('width', '210px');
    rGeral_1.addClass('rotulo').css('width', '110px');
    rGeral_2.css('width', '120px');
    rGeral_3.addClass('rotulo').css('width', '110px');
    rGeral_4.css('width', '78px');
    rGeral_5.addClass('rotulo').css('width', '110px');
	rGeral_7.css('width', '120px');
	rGeral_6.addClass('rotulo').css('width', '275px');	
	cDestino.addClass('descricao').css('width', '171px');

    // FIELDSET CONSULTAS
    var rConsultas_1 = $('label[for="dtcnsscr"]', '#' + nomeForm);
    var rConsultas_2 = $('label[for="inlbacen"]', '#' + nomeForm);
    var cConsultaDatas = $('#dtcnsscr', '#' + nomeForm);

    rConsultas_1.addClass('rotulo').css('width', '170px');
    rConsultas_2.css('width', '100px');
    cConsultaDatas.css('width', '80px');

    // FIELDSET DATAS
    var rDatas_1 = $('label[for="dtabtcoo"],label[for="dtabtcct"]', '#' + nomeForm);
    var rDatas_2 = $('label[for="dtelimin"],label[for="dtdemiss"]', '#' + nomeForm);
    var cDatasDatas = $('#dtabtcoo,#dtabtcct,#dtelimin,#dtdemiss', '#' + nomeForm);

    rDatas_1.addClass('rotulo').css('width', '170px');
    rDatas_2.css('width', '100px');
    cDatasDatas.css('width', '80px');

	var flgdevolu_autom_alt = $('input[name="flgdevolu_autom"]', '#' + nomeForm);		

    if (operacao == "CA") {
        var grupo1 = $('#cdagepac,#cdtipcta,#cdsitdct,#cdcatego,#cdbcochq,#cdsecext,#dtcnsscr,#cdconsultor', '#' + nomeForm);
        grupo1.removeClass('campoTelaSemBorda').addClass('campo').removeProp('disabled');
        cSelect.removeProp('disabled');
        cRadio.removeProp('disabled');
        cBcoCheque.desabilitaCampo();

        flgfirst = true;
		
        cTipoConta.unbind('change').bind('change', function() {
            if ($(this).val() == '8' || $(this).val() == '9' || $(this).val() == '10' || $(this).val() == '11') {
                /* Busca o codigo de banco da IF CECRED */
                cBcoCheque.val(cdbcoctl);
            }

            // Utiliza flag para evitar a chamada da função quando o método trigger for acionado
            if (flgfirst) {
                flgfirst = false;
            } else {
                manterRotina('VE');
            }
			
			var cbTiposConta = '';
			
			if (tiposConta[$(this).val()].idindividual == 1) { cbTiposConta += '<option value="0">Individual</option>'; }
			if (tiposConta[$(this).val()].idconjunta_solidaria == 1) { cbTiposConta += '<option value="1">Conjunta solid&aacute;ria</option>'; }
			if (tiposConta[$(this).val()].idconjunta_nao_solidaria == 1) { cbTiposConta += '<option value="2">Conjunta n&atilde;o solid&aacute;ria</option>'; }
			
			cCdcatego.html(cbTiposConta);
			
			cCdcatego.prop("selectedIndex", -1);
			
        });
		
		cConsultaDatas.unbind("keydown").bind("keydown",function(e) {
			if (e.keyCode == 13) {
				$("#btSalvar","#divBotoes").trigger("click");
				return false;
			}	
		});	
		
    }

    //montaSelect('b1wgen0059.p', 'Busca_Tipo_Conta', 'cdtipcta', 'cdtipcta', 'cdtipcta;dstipcta', cdtipcta);

	// Se alterar o campo de devolucao automatica, valida senha de coordenador
	flgdevolu_autom_alt.unbind('change').bind('change', function() {
		 mostraSenha();		 
	});
	
    controlaPesquisas();
    layoutPadrao();
    hideMsgAguardo();
    bloqueiaFundo(divRotina);
    //cTipoConta.trigger('change');
    cContaITG.trigger('blur');
	highlightObjFocus($('#frmContaCorrente'));
	controlaFocoEnter("frmContaCorrente");
    controlaFoco(operacao);
    divRotina.centralizaRotinaH();

    if (nvoperad != 3) {
        $("#flgrestrOp1,#flgrestrOp2", '#' + nomeForm).prop('disabled', true);
    }

	$("#cdconsultor", '#' + nomeForm).unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			manterRotina('BC');
			return false;
		}
    });

    return false;
}

function controlaFoco(operacao) {
    if (in_array(operacao, ['AC', 'FA', ''])) {
        $('#btAlterarbtAlterar', '#divBotoes').focus();
    } else if (operacao == 'CA') {
        $('#cdagepac', '#' + nomeForm).focus();

        //Quando atribui o foco em um campo pesquisa, no IE perde o primeiro change no campo
        $('#cdagepac', '#' + nomeForm).attr('aux', $('#cdagepac', '#' + nomeForm).val());

        $('#cdagepac', '#' + nomeForm).unbind('focusout').bind('focusout', function() {
            $(this).trigger('change');
            return false;
        });
        /**********************************************************************************/

    } else {
        $('#btVoltar', '#divBotoes').focus();
    }
    return false;
}

function controlaPesquisas() {
    // Variável local para guardar o elemento anterior
    var campoAnterior = '';
    var bo, procedure, titulo, qtReg, filtrosPesq, filtrosDesc, colunas, nrtopico, nritetop;

    bo = 'b1wgen0059.p';

    /*-------------------------------------*/
    /*       CONTROLE DAS PESQUISAS        */
    /*-------------------------------------*/

    // Atribui a classe lupa para os links e desabilita todos
    $('a', '#' + nomeForm).addClass('lupa').css('cursor', 'auto');

    // Percorrendo todos os links
    $('a', '#' + nomeForm).each(function() {

        if (!$(this).prev().hasClass('campoTelaSemBorda')) {
            $(this).css('cursor', 'pointer');
        }

        $(this).click(function() {
            if ($(this).prev().hasClass('campoTelaSemBorda')) {
                return false;
            } else {
                campoAnterior = $(this).prev().attr('name');

                // PA
                if (campoAnterior == 'cdagepac') {
                    procedure = 'busca_pac';
                    titulo = 'Agência PA';
                    qtReg = '20';
                    filtrosPesq = 'Cód. PA;cdagepac;30px;S;0|Agência PA;dsagepac;200px;S;';
                    colunas = 'Código;cdagepac;20%;right|Descrição;dsagepac;80%;left';
                    mostraPesquisa(bo, procedure, titulo, qtReg, filtrosPesq, colunas, divRotina);
                    return false;

                    // Destino extrato
                } else if (campoAnterior == 'cdsecext') {
                    procedure = 'busca_destino_extrato';
                    titulo = 'Destino Extrato';
                    qtReg = '20';
                    cdagepac = $('#cdagepac', '#' + nomeForm).val();
                    filtrosPesq = 'Cód. Destino;cdsecext;30px;S;0|Descrição;dssecext;200px;S;|Cód. Agência;cdagepac;30px;N;' + cdagepac + '';
                    colunas = 'Código;cdsecext;20%;right|Destino Extrato;dssecext;80%;left';
                    mostraPesquisa(bo, procedure, titulo, qtReg, filtrosPesq, colunas, divRotina);
                    return false;

                }
            }
            return false;
        });
    });

    /*-------------------------------------*/
    /*   CONTROLE DAS BUSCA DESCRIÇÕES     */
    /*-------------------------------------*/

    // PA
    $('#cdagepac', '#' + nomeForm).unbind('change').bind('change', function() {
		if ($(this).val() != cdageant) {
			idConfirmouSenha = 0;

			//Pede a senha do coordenador
			pedeSenhaCoordenador(2,'buscaPac();','');
		} else {
			buscaPac();
		}
    });

    // Destino Extrato
    $('#cdsecext', '#' + nomeForm).unbind('change').bind('change', function() {
        procedure = 'busca_destino_extrato';
        titulo = 'Destino Extrato';
        cdagepac = $('#cdagepac', '#' + nomeForm).val();
        filtrosDesc = 'cdagepac|' + cdagepac;
        buscaDescricao(bo, procedure, titulo, $(this).attr('name'), 'dssecext', $(this).val(), 'dssecext', filtrosDesc, nomeForm);
        return false;
    });
}

function buscaPac() {
	idConfirmouSenha = 1;
	bo = 'b1wgen0059.p';
	procedure = 'busca_pac';
    titulo = 'Agência PA';
    filtrosDesc = '';
    buscaDescricao(bo, procedure, titulo, $('#cdagepac', '#' + nomeForm).attr('name'), 'dsagepac', $('#cdagepac', '#' + nomeForm).val(), 'dsagepac', filtrosDesc, nomeForm);
    return false;
}

function mostraTabelaTitulares() {
    exibeRotina($('#divUsoGenerico'));

    $('#tbbens').remove();
    // Executa script de confirmação através de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/cadcta/conta_corrente/titulares.php",
        data: {
            nrdconta: nrdconta,
            idseqttl: idseqttl,
            redirect: "html_ajax"
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "Não foi possível concluir a requisição.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            $("#divUsoGenerico").html(response);
        }
    });
    return false;
}

function imprimeCritica() {

    hideMsgAguardo();
    bloqueiaFundo(divRotina);

    $('#nrdconta', '#frmContaCorrente').remove();
    $('#idseqttl', '#frmContaCorrente').remove();
    $('#inpessoa', '#frmContaCorrente').remove();
    $('#sidlogin', '#frmContaCorrente').remove();

    // Insiro input do tipo hidden do formulário para enviá-los posteriormente
    $('#frmContaCorrente').append('<input type="hidden" id="nrdconta" name="nrdconta" />');
    $('#frmContaCorrente').append('<input type="hidden" id="idseqttl" name="idseqttl" />');
    $('#frmContaCorrente').append('<input type="hidden" id="inpessoa" name="inpessoa" />');
    $('#frmContaCorrente').append('<input type="hidden" id="sidlogin" name="sidlogin" />');

    // Agora insiro os devidos valores nos inputs criados
    $('#nrdconta', '#frmContaCorrente').val(nrdconta);
    $('#idseqttl', '#frmContaCorrente').val(idseqttl);
    $('#inpessoa', '#frmContaCorrente').val(inpessoa);
    $('#sidlogin', '#frmContaCorrente').val($('#sidlogin', '#frmMenu').val());

    var action = UrlSite + 'telas/cadcta/conta_corrente/imp_critica.php';
    var callafter = "bloqueiaFundo(divRotina);";

    carregaImpressaoAyllos("frmContaCorrente", action, callafter);

}

function exibeConfirmacao(i) {

    hideMsgAguardo();

    if (i == (CriticasExcTitulares.length - 1)) {
        showConfirmacao(CriticasExcTitulares[i], 'Confirma&ccedil;&atilde;o - Ayllos', 'flgexclu=\'yes\';bloqueiaFundo(divRotina)', 'flgexclu=\'no\';bloqueiaFundo(divRotina)', 'sim.gif', 'nao.gif');
    } else {
        showError('inform', CriticasExcTitulares[i], 'Alerta - Ayllos', 'exibeConfirmacao(' + (i + 1) + ')');
    }

    return false;

}

function controlaContinuar () {
	
	flgContinuar = true;
	
	if ($("#btAlterar","#divBotoes").length > 0) {
		proximaRotina();
	} else {
		controlaOperacao('AV');
	}
	
}	

function voltarRotina() {
    fechaRotina(divRotina);
	
	if (inpessoa == 1) {
		acessaRotina('COMERCIAL', 'COMERCIAL', 'comercial_pf');
	} else {
		acessaRotina('REFERENCIAS', 'Referências', 'referencias');
	}
}

function proximaRotina() {
	
    hideMsgAguardo();
	
	if (inpessoa == 1) {
		acessaOpcaoAbaDados(2,1,'@');
	}
	else {
		encerraRotina(false);
		acessaRotina('CLIENTE FINANCEIRO', 'Cliente Financeiro', 'cliente_financeiro');
	}
}

function associaNomeConsultor(nmconsultor) {
	$("#nmconsultor","#frmContaCorrente").val(nmconsultor);
}

function mostrarPesquisaConsultor(){
	//Definição dos filtros
	var filtros	= "Código Consultor;cdconsultor;50px;S;;S;|Código Operador;cdoperador;50px;S;;S;|Nome Consultor;nmconsultor;200px;S;;S;descricao";
	//Campos que serão exibidos na tela
	var colunas = 'Código;cdconsultor;20%;right|Código;cdoperador;20%;right|Nome Operador;nmconsultor;80%;left';
	//Exibir a pesquisa
	mostraPesquisa("CADCON", "CADCON_CONSULTA_CONSULTORES", "Consultores","100",filtros,colunas);
}
