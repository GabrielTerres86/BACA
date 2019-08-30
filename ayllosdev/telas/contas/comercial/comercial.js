/*!
 * FONTE        : comercial.js                              Última alteração: 31/07/2018
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 24/05/2010 
 * OBJETIVO     : Biblioteca de funções na rotina COMERCIAL da tela de CONTAS
 * --------------
 * ALTERAÇÕES   : Adicionado pesquisa CEP. ( Rodolpho/Rogérius. (DB1) )
 * 				  16/06/2011 - Incluir campo Politicamente Exposto (Gabriel)
 *				: 27/06/2011 - Adaptar campo empresa, nao chamar evento BLUR se tiver com a TELA PESQUISA aberta. ( Rogerius (DB1) )
 *				  29/11/2011 - Ajuste para inclusao do campo Justificativa (Adriano).
 *                06/02/2012 - Ajuste para não chamar 2 vezes a função mostraPesquisa (Tiago).
 * 				  19/12/2013 - Alterado nome do id vldrend2 para vldrend22 do form frmDadosComercial. Estava dando conflito. (Jorge)
 *                18/08/2015 - Reformulacao cadastral (Gabriel-RKAM)
 *                23/12/2015 - #350828 Inclusão da operação PPE (Carlos)
 *                01/12/2016 - Definir a não obrigatoriedade do PEP (Tiago/Thiago SD532690)
 *                20/02/2017 - Alterado codigo para que os caracteres com acento sejam substituidos pelos equivalentes sem acento,
 *                             ao inves de removidos. (Heitor - Chamado 614746)
 *                03/03/2017 - Ajuste devido a conversão das rotinas busca_nat_ocupacao, busca_ocupacao (Adriano - SD 614408).
 *				  27/03/2017 - Ajuste realizado para corrigir o filtro da ocupação. (Kelvin - SD 636559)	
 *                11/10/2017 - Removendo campo caixa postal (PRJ339 - Kelvin).	
 *                05/12/2017 - Alteração para buscar o Nome da Empresa a partir do CNPJ digitado e regra de alteração do nome da empresa.
 *                             (Mateus Z - Mouts)
 *                27/02/2018 - Alteração para selecionar o grupoEndereco corretamento no no js (Tiago #844280)
 *			      05/07/2018 - Ajustado rotina para que nao haja inconsistencia nas informacoes da empresa
 *							   (CODIGO, NOME E CNPJ DA EMPRESA). (INC0018113 - Kelvin)
 *				  31/07/2018 - Ajuste realizado para que ao carregar a alteração, traga as informações correta da empresa. (Kelvin)	
 *				  06/09/2018 - Ajustes nas rotinas envolvidas na unificação cadastral e CRM para	
 *                             corrigir antigos e evitar futuros problemas. (INC002926 - Kelvin)
 *                01/03/2019 - Tratamento de caracteres invalidos no campo complemento de endereco (PRB0040642 - Gabriel Mouts).
 *                07/03/2019 - Ajuste no blur, para retornar razao social do cnpj digitado, ao inves de manter nome anterior.
 *                             Gabriel Marcos (Mouts) - Chamado PRB0040571.
 *                16/07/2019 - P437 - Remoção da validação do DV matricula - Jackson Barcellos AMcom
 *
 * --------------
 */

var nrdrowid = ''; // Chave da Tabela Progress
var cdnvlcgo = ''; // Nível do cargo
var cdturnos = ''; // Cód. Turmo 
var nomeForm = 'frmDadosComercial'; // Nome do Formulário
var operacao = '';
var cddrendi = '';
var vlrdrend = '';
var nmdfield = '';
var otrsrend = '';
var flgContinuar = false;     // Controle botao Continuar	

function acessaOpcaoAba(nrOpcoes, id, opcao) {

    // Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, carregando...');

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
        url: UrlSite + 'telas/contas/comercial/principal.php',
        data: {
            nrdconta: nrdconta,
            idseqttl: idseqttl,
            flgcadas: flgcadas,
            operacao: '',
            redirect: 'html_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
        },
        success: function (response) {
            if (response.indexOf('showError("error"') == -1) {
                $('#divConteudoOpcao').html(response);
            } else {
                eval(response);
                controlaFoco(operacao);
            }
            return false;
        }
    });
}

function controlaOperacao(operacao, flgConcluir) {   

    if(operacao == 'AV')
		buscaInfEmpresa();
	
    var inpolexp = $('#inpolexp', '#' + nomeForm).val();
    var inpolexpAnt = $('#inpolexpAnt', '#' + nomeForm).val();
	
    // Se a operacao de salvar veio do botão concluir, e não do botão continuar; e o campo ppe foi alterado, ou veio da matricula:
    if ((operacao == 'AV' && flgConcluir  && inpolexp !== inpolexpAnt) || (operacao == 'AV' && flgcadas == "M")) {
        controlaOperacao('PPE');
        return false;
    }

    if ((operacao == 'CA') && (flgAlterar != '1')) { showError('error', 'Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de altera&ccedil;&atilde;o.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)'); return false; }

    if (!verificaContadorSelect()) return false;

    // Se esta fazendo o cadastro apos MATRIC, fechar rotina e ir pra proxima
    if (operacao == '' && (flgcadas == "M" || flgContinuar)) {
        buscaRendimentos(1, 30);
        flgContinuar = false;
        return false;
    }

    var mensagem = '';
    switch (operacao) {
        case 'SC': mensagem = 'Aguarde, abrindo formulário ...'; break;
        case 'CA': mensagem = 'Aguarde, abrindo formulário ...'; break;
        case 'CAE': mensagem = 'Aguarde, abrindo formulário ...'; break;
        case 'AC': showConfirmacao('Deseja cancelar operação?', 'Confirmação - Aimaro', 'controlaOperacao()', 'bloqueiaFundo(divRotina)', 'sim.gif', 'nao.gif'); return false; break;
        case 'AV': manterRotina(operacao); return false; break;
        case 'VA': manterRotina(operacao); return false; break;
        case 'PPE': manterRotina(operacao); return false; break;
        case 'PPE_ABA': manterRotina(operacao); return false; break;
        case 'PPE_ABA_ABRE': acessaOpcaoAbaDados(3, 2, 'A'); return false; break;
        default:
            mensagem = 'Aguarde, abrindo formulário ...';
            nrdrowid = '';
            break;
    }


    showMsgAguardo(mensagem);

    var cdnatopc = $('#cdnatopc', '#' + nomeForm).val();
    var cdocpttl = $('#cdocpttl', '#' + nomeForm).val();
    var tpcttrab = $('#tpcttrab', '#' + nomeForm).val();
    var cdempres = $('#cdempres', '#' + nomeForm).val();
    var dsproftl = $('#dsproftl', '#' + nomeForm).val();
    var cdnvlcgo = $('#cdnvlcgo', '#' + nomeForm).val();
    var cdturnos = $('#cdturnos', '#' + nomeForm).val();
    var dtadmemp = $('#dtadmemp', '#' + nomeForm).val();
    var vlsalari = $('#vlsalari', '#' + nomeForm).val();
    var nrcadast = $('#nrcadast', '#' + nomeForm).val();
    var tpdrendi = $('#tpdrendi', '#' + nomeForm).val();
    var vldrendi = $('#vldrendi', '#' + nomeForm).val();
    var tpdrend2 = $('#tpdrend2', '#' + nomeForm).val();
    var vldrend2 = $('#vldrend22', '#' + nomeForm).val();
    var tpdrend3 = $('#tpdrend3', '#' + nomeForm).val();
    var vldrend3 = $('#vldrend3', '#' + nomeForm).val();
    var tpdrend4 = $('#tpdrend4', '#' + nomeForm).val();
    var vldrend4 = $('#vldrend4', '#' + nomeForm).val();

    var inpolexp = $('#inpolexp', '#' + nomeForm).val();

    cdnvlcgo = normalizaNumero(cdnvlcgo);
    cdturnos = normalizaNumero(cdturnos);
    nrcadast = normalizaNumero(nrcadast);

    inpolexp = normalizaNumero(inpolexp);

    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/contas/comercial/principal.php',
        data: {
            nrdconta: nrdconta, idseqttl: idseqttl,
            operacao: operacao, nrdrowid: nrdrowid,
            cdnatopc: cdnatopc, cdocpttl: cdocpttl,
            tpcttrab: tpcttrab, cdempres: cdempres,
            dsproftl: dsproftl,
            cdnvlcgo: cdnvlcgo, cdturnos: cdturnos,
            dtadmemp: dtadmemp, vlsalari: vlsalari,
            nrcadast: nrcadast, tpdrendi: tpdrendi,
            vldrendi: vldrendi, tpdrend2: tpdrend2,
            vldrend2: vldrend2, tpdrend3: tpdrend3,
            vldrend3: vldrend3, tpdrend4: tpdrend4,
            vldrend4: vldrend4, flgcadas: flgcadas,
            inpolexp: inpolexp,
            inpessoa: inpessoa,
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
        },
        success: function (response) {
            if (response.indexOf('showError("error"') == -1) {
                $('#divConteudoOpcao').html(response);
            } else {
                eval(response);
                controlaFoco(operacao);
            }
			if(operacao == 'CA' || operacao == 'CAE'){
              $("#nmextemp").desabilitaCampo();
			  if(operacao == 'CAE'){
				  $('#nrcpfemp').val("");
				  $('#nmextemp').val("");
			  }
			  buscaInfEmpresa();
            }
            return false;
        }
    });
}

function manterRotina(operacao) {
    hideMsgAguardo();
    var mensagem = '';
    switch (operacao) {
        case 'AV': mensagem = 'Aguarde, validando ...'; break;
        case 'VA': mensagem = 'Aguarde, alterando ...'; break;
        case 'PPE': mensagem = 'Aguarde, alterando ...'; break;
        case 'PPE_ABA': mensagem = 'Aguarde, alterando ...'; break;
        default: return false; break;
    }
    showMsgAguardo(mensagem);

    cdnatopc = $('#cdnatopc', '#' + nomeForm).val();
    cdocpttl = $('#cdocpttl', '#' + nomeForm).val();
    tpcttrab = $('#tpcttrab', '#' + nomeForm).val();
    cdempres = $('#cdempres', '#' + nomeForm).val();
    nmextemp = $('#nmextemp', '#' + nomeForm).val();
    nrcpfemp = $('#nrcpfemp', '#' + nomeForm).val();
    dsproftl = $('#dsproftl', '#' + nomeForm).val();
    cdnvlcgo = $('#cdnvlcgo', '#' + nomeForm).val();
    nrcadast = $('#nrcadast', '#' + nomeForm).val();
    dtadmemp = $('#dtadmemp', '#' + nomeForm).val();
    vlsalari = $('#vlsalari', '#' + nomeForm).val();
    tpdrendi = $('#tpdrendi', '#' + nomeForm).val();
    tpdrend2 = $('#tpdrend2', '#' + nomeForm).val();
    tpdrend3 = $('#tpdrend3', '#' + nomeForm).val();
    tpdrend4 = $('#tpdrend4', '#' + nomeForm).val();
    vldrendi = $('#vldrendi', '#' + nomeForm).val();
    vldrend2 = $('#vldrend22', '#' + nomeForm).val();
    vldrend3 = $('#vldrend3', '#' + nomeForm).val();
    vldrend4 = $('#vldrend4', '#' + nomeForm).val();
    cdturnos = $('#cdturnos', '#' + nomeForm).val();
    cepedct1 = $('#cepedct1', '#' + nomeForm).val();
    endrect1 = $('#endrect1', '#' + nomeForm).val();
    nrendcom = $('#nrendcom', '#' + nomeForm).val();
    //complcom = $('#complcom', '#' + nomeForm).val();
    bairoct1 = $('#bairoct1', '#' + nomeForm).val();
    cidadct1 = $('#cidadct1', '#' + nomeForm).val();
    ufresct1 = $('#ufresct1', '#' + nomeForm).val();
    inpolexp = $('#inpolexp', '#' + nomeForm).val();
    inpolexpAnt = $('#inpolexpAnt', '#' + nomeForm).val();

    nrcpfemp = normalizaNumero(nrcpfemp);
    cdnvlcgo = normalizaNumero(cdnvlcgo);
    cdturnos = normalizaNumero(cdturnos);
    nrcadast = normalizaNumero(nrcadast);
    cepedct1 = normalizaNumero(cepedct1);
    inpolexp = normalizaNumero(inpolexp);
    complcom = removeCaracteresInvalidos($('#complcom', '#' + nomeForm).val(), true);

    nmextemp = trim(nmextemp);
    dsproftl = trim(dsproftl);

    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/contas/comercial/manter_rotina.php',
        data: {
            nrdconta: nrdconta, idseqttl: idseqttl, operacao: operacao, nrdrowid: nrdrowid,
            cdnatopc: cdnatopc, cdocpttl: cdocpttl, tpcttrab: tpcttrab, cdempres: cdempres,
            nmextemp: nmextemp, nrcpfemp: nrcpfemp, dsproftl: dsproftl,
            cdnvlcgo: cdnvlcgo, nrcadast: nrcadast, dtadmemp: dtadmemp, vlsalari: vlsalari,
            tpdrendi: tpdrendi, tpdrend4: tpdrend4, tpdrend2: tpdrend2, tpdrend3: tpdrend3,
            vldrendi: vldrendi, vldrend4: vldrend4, vldrend2: vldrend2, vldrend3: vldrend3,
            cdturnos: cdturnos, cepedct1: cepedct1, endrect1: endrect1, nrendcom: nrendcom,
            complcom: complcom, bairoct1: bairoct1, cidadct1: cidadct1, ufresct1: ufresct1,
			flgcadas: flgcadas, flgContinuar: flgContinuar,
            inpolexp: inpolexp, inpolexpAnt: inpolexpAnt,
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
        },
        success: function (response) {
            try {
                eval(response);
                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
            }
        }
    });
}

function controlaLayout(operacao) {
    altura = inpessoa == 1 ? '460px' : '360px';
    largura = '615px';
    divRotina.css('width', largura);
    $('#divConteudoOpcao').css('height', altura);

    // FIELDSET INF. PROFISSIONAIS
    var rotulos_1 = $('label[for="cdnatopc"],label[for="tpcttrab"],label[for="nrcpfemp"]', '#' + nomeForm);
    var rColFS1_60 = $('label[for="cdocpttl"],label[for="cdempres"]', '#' + nomeForm);
    var rColFS1_70 = $('label[for="cdnvlcgo"]', '#' + nomeForm);
    var rColFS1_53 = $('label[for="dsproftl"],label[for="dtadmemp"]', '#' + nomeForm);
    var rColFS1_90 = $('label[for="nmextemp"]', '#' + nomeForm);
    var rLinha_1 = $('label[for="vlsalari"]', '#' + nomeForm);
    var rLinha_11 = $('label[for="nrcadast"]', '#' + nomeForm);
    var rTurno = $('label[for="cdturnos"]', '#' + nomeForm);
    var rOtrsrend = $('label[for="otrsrend"]', '#' + nomeForm);
    var rPolitica = $('label[for="inpolexp"]', '#' + nomeForm);

    rotulos_1.addClass('rotulo').css('width', '90px');
    rColFS1_60.css('width', '79px');
    rColFS1_70.css('width', '70px');
    rColFS1_53.css('width', '60px');
    rColFS1_90.css('width', '114px');
    rLinha_1.css('width', '55px').addClass('rotulo-linha');
    rLinha_11.css('width', '71px').addClass('rotulo-linha');
    rOtrsrend.addClass('rotulo-linha').css('width', '245px');
    rTurno.addClass('rotulo').css('width', '40px');
    rPolitica.addClass('rotulo').css('width', '170px');


    var cTodos_1 = $('input,select', '#' + nomeForm + ' fieldset:eq(0)');
    var cCodigo_1 = $('#cdnatopc,#cdocpttl,#cdempres', '#' + nomeForm);
    var cDescNatOcup = $('#rsnatocp', '#' + nomeForm);
    var cDescOcupacao = $('#rsocupa', '#' + nomeForm);
    var cDescEmpresa = $('#nmresemp', '#' + nomeForm);
    var cTpCrtTrb = $('#tpcttrab', '#' + nomeForm);
    var cNomeEmp = $('#nmextemp', '#' + nomeForm);
    var cCnpj = $('#nrcpfemp', '#' + nomeForm);
    var cFuncao = $('#dsproftl', '#' + nomeForm);
    var cNivelCargo = $('#cdnvlcgo', '#' + nomeForm);
    var cTurno = $('#cdturnos', '#' + nomeForm);
    var cDtAdm = $('#dtadmemp', '#' + nomeForm);
    var cRend = $('#vlsalari', '#' + nomeForm);
    var cCadEmp = $('#nrcadast', '#' + nomeForm);
    var cPolitica = $('#inpolexp', '#' + nomeForm);
    var cOtrsrend = $('#otrsrend', '#' + nomeForm);

    cTodos_1.desabilitaCampo();
    cCodigo_1.addClass('codigo pesquisa');
    cDescNatOcup.addClass('descricao').css('width', '128px');
    cDescOcupacao.addClass('descricao').css('width', '143px');
    cDescEmpresa.addClass('descricao').css('width', '144px');
    cTpCrtTrb.css('width', '185px');
    cNomeEmp.css('width', '232px').attr('maxlength', '35').addClass('alphanum');
    cCnpj.addClass('cnpj').css('width', '120px');
    cFuncao.css('width', '117px').attr('maxlength', '20').addClass('alphanum');
    cNivelCargo.css('width', '120px');
    cTurno.css('width', '125px');
    cDtAdm.css('width', '67px').addClass('data');
    cRend.css('width', '68px').attr('alt', 'p6p3c2D').css('text-align', 'right').autoNumeric().trigger('blur');;
    cCadEmp.css('width', '58px').addClass('inteiro cadempresa');
    cOtrsrend.css('width', '68px').attr('alt', 'p6p3c2D').css('text-align', 'right').autoNumeric().trigger('blur');;
    cPolitica.css('width', '70px');


    // FIELDSET ENDERECO
    var rCep = $('label[for="cepedct1"]', '#' + nomeForm);
    var rEnd = $('label[for="endrect1"]', '#' + nomeForm);
    var rNum = $('label[for="nrendcom"]', '#' + nomeForm);
    var rCom = $('label[for="complcom"]', '#' + nomeForm);
    var rBai = $('label[for="bairoct1"]', '#' + nomeForm);
    var rEst = $('label[for="ufresct1"]', '#' + nomeForm);
    var rCid = $('label[for="cidadct1"]', '#' + nomeForm);

    rCep.addClass('rotulo').css('width', '55px');
    rEnd.addClass('rotulo-linha').css('width', '33px');
    rNum.addClass('rotulo').css('width', '55px');
    rCom.addClass('rotulo-linha').css('width', '52px');
    rBai.addClass('rotulo').css('width', '55px');
    rEst.addClass('rotulo-linha').css('width', '55px');
    rCid.addClass('rotulo').css('width', '55px');

    var cTodos_2 = $('input,select', '#' + nomeForm + ' fieldset:eq(1)');
    var cCep = $('#cepedct1', '#' + nomeForm);
    var cEnd = $('#endrect1', '#' + nomeForm);
    var cNum = $('#nrendcom', '#' + nomeForm);
    var cCom = $('#complcom', '#' + nomeForm);
    var cBai = $('#bairoct1', '#' + nomeForm);
    var cEst = $('#ufresct1', '#' + nomeForm);
    var cCid = $('#cidadct1', '#' + nomeForm);

    cCep.addClass('cep pesquisa').css('width', '65px').attr('maxlength', '9');
    cEnd.addClass('alphanum').css('width', '353px').attr('maxlength', '40');
    cNum.addClass('numerocasa').css('width', '65px').attr('maxlength', '7');
    cCom.addClass('alphanum').css('width', '353px').attr('maxlength', '40');
    cBai.addClass('alphanum').css('width', '353px').attr('maxlength', '40');
    cEst.css('width', '65px');
    cCid.addClass('alphanum').css('width', '353px').attr('maxlength', '25');

    var endDesabilita = $('#endrect1,#ufresct1,#bairoct1,#cidadct1', '#' + nomeForm);

    // ie
    if ($.browser.msie) {
        cEnd.addClass('alphanum').css('width', '356px');
        cCom.addClass('alphanum').css('width', '356px');
        cBai.addClass('alphanum').css('width', '356px');
        cCid.addClass('alphanum').css('width', '356px');
    }
    controlaFocoEnter("frmDadosComercial");
    controlaFocoEnter("frmManipulaRendi");

    //FORM ATUALIZACAO CADASTRAL
    var rIdCanalE  = $('label[for="idcanal_empresa"]' , '#' + nomeForm);
    var rDtRevisaE = $('label[for="dtrevisa_empresa"]', '#' + nomeForm);
    var rDsStatus = $('label[for="dsstatus"]', '#' + nomeForm);

    rIdCanalE.addClass('rotulo').css('width', '120px');
    rDtRevisaE.addClass('rotulo-linha').css('width', '80px');
    rDsStatus.addClass('rotulo-linha').css('width', '70px');

    var cIdCanalE  = $('#idcanal_empresa' , '#' + nomeForm);
    var cDtRevisaE = $('#dtrevisa_empresa', '#' + nomeForm);
    var cDsStatus = $('#dsstatus', '#' + nomeForm);

    cIdCanalE.css('width', '70px');
    cIdCanalE.css('text-align', 'center');
    cDtRevisaE.css('width', '90px');
    cDtRevisaE.css('text-align', 'center');
    cDsStatus.css('width', '70px');
    cDsStatus.css('text-align', 'center');
    cIdCanalE.desabilitaCampo();
    cDtRevisaE.desabilitaCampo();
    cDsStatus.desabilitaCampo();

    var rIdCanalR  = $('label[for="idcanal_renda"]' , '#' + nomeForm);
    var rDtRevisaR = $('label[for="dtrevisa_renda"]', '#' + nomeForm);

    rIdCanalR.addClass('rotulo').css('width', '120px');
    rDtRevisaR.addClass('rotulo-linha').css('width', '80px');

    var cIdCanalR  = $('#idcanal_renda' , '#' + nomeForm);
    var cDtRevisaR = $('#dtrevisa_renda', '#' + nomeForm);

    cIdCanalR.css('width', '70px');
    cIdCanalR.css('text-align', 'center');
    cDtRevisaR.css('width', '90px');
    cDtRevisaR.css('text-align', 'center');
    cIdCanalR.desabilitaCampo();
    cDtRevisaR.desabilitaCampo();


    //FORM RENDAS AUTOMATICAS
    var rDtrefere = $('label[for="dtrefere"]', '#' + nomeForm);
    var rVltotmes = $('label[for="vltotmes"]', '#' + nomeForm);

    rDtrefere.addClass('rotulo').css('width', '55px');
    rVltotmes.addClass('rotulo-linha').css('width', '100px');

    var cDtrefere = $('#dtrefere', '#' + nomeForm);
    var cVltotmes = $('#vltotmes', '#' + nomeForm);

    cDtrefere.addClass('alphanum').css('width', '80px');
    cVltotmes.addClass('alphanum').css('width', '100px');

    var cBtdetref = $('#btdetref', '#' + nomeForm);


    //FORM JUSTIFICATIVA
    $('#frmJustificativa').css('display', 'none');

    var rDsjusren = $('label[for="dsjusren"]', '#frmJustificativa');

    rDsjusren.addClass('rotulo').css('width', '70px');

    var cDsjusren = $('#dsjusren', '#frmJustificativa');

    cDsjusren.addClass('alphanum').css('width', '470px').css('overflow-y', 'scroll').css('overflow-x', 'hidden').css('height', '60').css('margin-left', '3').attr('maxlength', '160');

    cDsjusren.desabilitaCampo();

    // FIELDSET OUTROS RENDIMENTOS	
    $('#divRendimentos').css('display', 'none');
    $('#frmManipulaRendi').css('display', 'none');
    $('#divBotoesRendi').css('display', 'none');
    $('#divBotoesRendas').css('display', 'none');
    $('#divBotoesManip').css('display', 'none');

    var rCodigos = $('label[for="tpdrend2"]', '#frmManipulaRendi');
    var rValores = $('label[for="vldrend2"]', '#frmManipulaRendi');
    var rJustif = $('label[for="dsjusre2"]', '#frmManipulaRendi');

    rCodigos.addClass('rotulo').css('width', '130px');
    rValores.addClass('rotulo-linha');
    rJustif.addClass('rotulo').css('width', '70px');

    var cCodigos_3 = $('#tpdrend2', '#frmManipulaRendi');
    var cDesc_3 = $('#dsdrend2', '#frmManipulaRendi');
    var cValores_3 = $('#vldrend2', '#frmManipulaRendi');
    var cJustif = $('#dsjusre2', '#frmManipulaRendi');

    cCodigos_3.addClass('codigo pesquisa');
    cDesc_3.addClass('descricao').css('width', '150px');
    cValores_3.addClass('moeda_6').css('width', '80px');
    cJustif.addClass('alphanum').css('width', '470px').css('overflow-y', 'scroll').css('overflow-x', 'hidden').css('height', '60').css('margin-left', '3').attr('maxlength', '160');

    cCodigos_3.habilitaCampo();
    cValores_3.habilitaCampo();
    cJustif.desabilitaCampo();

    cCodigos_3.unbind('blur').bind('blur', function () { controlaPesquisaRendi(); });

    // SELETORES	
    var cTpCrtTrb = $('#tpcttrab', '#' + nomeForm);
    var cCodNatOcupacao = $('#cdnatopc', '#' + nomeForm);
    var cCodOcupacao = $('#cdocpttl', '#' + nomeForm);
    var cCodEmpresa = $('#cdempres', '#' + nomeForm);
	var cCodCnpj = $('#nrcpfemp', '#' + nomeForm);
    var cDescEmpresa = $('#nmresemp', '#' + nomeForm);
    var grupoEmpresa = $('#nmextemp,#nrcpfemp', '#' + nomeForm);
    var grupoSecao = $('#dsproftl,#cdnvlcgo,#nrcadast', '#' + nomeForm);
    var grupoTurno = $('#cdturnos,#dtadmemp,#vlsalari', '#' + nomeForm);
    var grupoEndereco = $('input,select', '#' + nomeForm + ' fieldset:eq(2)');
    var grupoRendimento = $('#tpdrendi,#tpdrend2,#tpdrend3,#tpdrend4,#vldrendi,#vldrend2,#vldrend3,#vldrend4', '#' + nomeForm);

    grupoEndereco.desabilitaCampo();


    // CONTROLE DOS COMPORTAMENTOS	
    if (operacao == 'CA' || operacao == 'CAE') {
        // Habilitando os campos necessários
        cCodNatOcupacao.habilitaCampo();
        cCodOcupacao.habilitaCampo();
        grupoRendimento.habilitaCampo();

        cPolitica.habilitaCampo();

        // Se ao abrir a rotina a  Nat. Ocupação for DIFERENTE de 11 (Sem Remuneração) AND 12 (Sem Vínculo)
        // determinados campos serão habilitados
        if ((cCodNatOcupacao.val() != 11) && (cCodNatOcupacao.val() != 12)) {

            cTpCrtTrb.habilitaCampo();
            cCodEmpresa.habilitaCampo();
            grupoSecao.habilitaCampo();
            grupoTurno.habilitaCampo();


            // Se o Tp. Contrato Trabalho é DIFERENTE 3 (Sem Vínculo) habilito determinados campos
            if (cTpCrtTrb.val() != 3) {
                cCodEmpresa.habilitaCampo();
                grupoSecao.habilitaCampo();
                grupoTurno.habilitaCampo();

                // Se cooperativa logada é 2 e empresa 88 ou empresa 81 nas demais cooperativas, habilita campos	
                if ((cooperativa == 2 && cCodEmpresa.val() == 88) || cCodEmpresa.val() == 81) {
                    grupoEmpresa.habilitaCampo();
                    grupoEndereco.habilitaCampo();
                    endDesabilita.desabilitaCampo();
                }

            } else {
                cCodEmpresa.val((cooperativa == 2 ? '88' : '81')).desabilitaCampo();
                cDescEmpresa.limpaFormulario();
                cDescEmpresa.desabilitaCampo();
                grupoEmpresa.limpaFormulario();
                grupoEmpresa.desabilitaCampo();
                grupoSecao.limpaFormulario();
                grupoSecao.desabilitaCampo();
                grupoTurno.limpaFormulario();
                grupoTurno.desabilitaCampo();
                grupoEndereco.limpaFormulario();
                grupoEndereco.desabilitaCampo();
                grupoRendimento.first().focus();
            }

        } else {
            cTodos_1.desabilitaCampo();
            cCodNatOcupacao.habilitaCampo();
            cCodOcupacao.habilitaCampo();
            cTodos_2.desabilitaCampo();
            cCodigos_3.habilitaCampo();
            cCodEmpresa.val((cooperativa == 2 ? '88' : '81')).desabilitaCampo();
            cDescEmpresa.limpaFormulario();
            grupoEmpresa.limpaFormulario().desabilitaCampo();
            grupoSecao.limpaFormulario().desabilitaCampo();
            grupoTurno.limpaFormulario().desabilitaCampo();
            grupoEndereco.limpaFormulario();
        }

		cPolitica.habilitaCampo();
		
        cCodigo_1.unbind('blur').bind('blur', function () { controlaPesquisas(); });

        // Se mudar a  Nat. Ocupação e for 11 (Sem Remuneração) ou 12 (Sem Vínculo), 
        // o Tp. Ctr. Trabalho será igual a 3 (Sem Vinculo) e determinados campos serão desabilitados
        cCodNatOcupacao.unbind('blur').bind('blur', function () {
            if (($(this).val() == 11) || ($(this).val() == 12)) {

                // Seleciono a opção 3 do select "Tp. Ctr. Trabalho" = tpcttrab
                $('#tpcttrab > option', '#' + nomeForm).removeProp('selected');
                $('#tpcttrab > option[value="3"]', '#' + nomeForm).prop('selected', true);

                // Limpa e Desabilita os campos necessários
                cTodos_1.desabilitaCampo();
                cCodNatOcupacao.habilitaCampo();
                cCodOcupacao.habilitaCampo();
                cTodos_2.desabilitaCampo();
                cCodigos_3.habilitaCampo();
                cCodEmpresa.val((cooperativa == 2 ? '88' : '81')).desabilitaCampo();
                cDescEmpresa.limpaFormulario();
                grupoEmpresa.limpaFormulario().desabilitaCampo();
                grupoSecao.limpaFormulario().desabilitaCampo();
                grupoTurno.limpaFormulario().desabilitaCampo();
                grupoEndereco.limpaFormulario();
            } else {
                cTpCrtTrb.habilitaCampo();
            }
			
			cPolitica.habilitaCampo();
			
            controlaPesquisas();
        });

        // Ao mudar a o Contrato de trabalho para 3, desabilito determinado campos
        cTpCrtTrb.unbind('change').bind('change', function () {
            if ($(this).val() == 3 || $(this).val() == 4) {
                cCodEmpresa.val((cooperativa == 2 ? '88' : '81')).desabilitaCampo();
                cDescEmpresa.limpaFormulario();
                grupoEmpresa.limpaFormulario().desabilitaCampo();
                grupoSecao.limpaFormulario().desabilitaCampo();
                grupoTurno.limpaFormulario().desabilitaCampo();
                grupoEndereco.limpaFormulario().desabilitaCampo();
                grupoRendimento.first().focus();
            } else {
                cCodEmpresa.habilitaCampo();
                grupoSecao.habilitaCampo();
                grupoTurno.habilitaCampo();
                cCodEmpresa.focus();

                // Se cooperativa logada é 2 e empresa 88 ou empresa 81 nas demais cooperativas, habilita campos	
                if ((cooperativa == 2 && cCodEmpresa.val() == 88) || cCodEmpresa.val() == 81) {
                    grupoEmpresa.habilitaCampo();
                    grupoEndereco.habilitaCampo();
                    endDesabilita.desabilitaCampo();
                }
            }
        });


        // Ao mudar a empresa habilito campos de acordo com a cooperativa logada
        cCodEmpresa.unbind('blur').bind('blur', function () {
            // Adaptar campo empresa, nao chamar evento BLUR se tiver com a TELA PESQUISA aberta. ( Rogerius (DB1) )
            if ($('#divPesquisa').css('visibility') == 'visible') { return false; }
            
			controlaPesquisas();
            controlaOperacao('CAE');			
						
        });
		
		cCodCnpj.unbind('blur').bind('blur', function () {
			
		    /* 
            
            buscaInfEmpresa() ira balizar permissoes de alteracoes 
            do cnpj, visto a existencia de cadastro na crapemp, 
            bem como o tipo de cadastro que a empresa possui no
            cadastro unificado tbcadast_pessoa.tpcadastro.   
            
		    buscaNomePessoa() fara o retorno da razao social do cnpj 
            digitado, ou seja, no blur ela sera acionada e sempre que 
            houver alteracao no cnpj, estaremos garantindo que a razao 
            social seja carregada corretamente. 
            
            */

			buscaInfEmpresa();
            buscaNomePessoa();
			
        });

        // Acionar o botao Salvar no enter do ultinmo campo
        cCadEmp.unbind("keydown").bind("keydown", function (e) {
            if (e.keyCode == 13 && isHabilitado(cCep) == false) {
                $("#btSalvar", "#divBotoes").trigger("click");
                return false;
            }
        });
    }

    cValores_3.unbind("keydown").bind("keydown", function (e) {

        if (e.keyCode == 13) {
            if (isHabilitado(cJustif) == true) {
                cJustif.focus();
            } else {
                $("#btManipConcluir", "#divBotoesManip").click();
            }
            return false;
        }
    });

    montaSelect('b1wgen0059.p', 'busca_nivel_cargo', 'cdnvlcgo', 'cdnvlcgo', 'rsnvlcgo', cdnvlcgo);
    montaSelect('b1wgen0059.p', 'busca_turnos', 'cdturnos', 'cdturnos', 'dsturnos', cdturnos);

    controlaPesquisaRendi();
    controlaPesquisas();
    layoutPadrao();
    cCadEmp.trigger('blur');
    cCep.trigger('blur');
    /*cCnpj.trigger('blur');*/
    hideMsgAguardo();
    bloqueiaFundo(divRotina);
    removeOpacidade('divConteudoOpcao');
    highlightObjFocus($('#divConteudoOpcao'));
    controlaFoco(operacao);
    divRotina.centralizaRotinaH();
    return false;
}

function controlaFoco(operacao) {
    if (in_array(operacao, [''])) {
        $('#btAlterar', '#divBotoes').focus();
    } else if (operacao == 'CAE') {
        $('#nrcpfemp', '#' + nomeForm).focus();
        // if ((cooperativa == 2 && $('#cdempres', '#' + nomeForm).val() == 88) || $('#cdempres', '#' + nomeForm).val() == 81) {
        //     $('#nmextemp', '#' + nomeForm).focus();
        // } else {
        //     $('#dsproftl', '#' + nomeForm).focus();
        // }
    } else {
        $('#cdnatopc', '#' + nomeForm).focus();
    }
    return false;
}

function retornaContaSelect() {
    return contaSelect;
}

function controlaPesquisas() {

    // Variável local para guardar o elemento anterior
    var campoAnterior = '';
    var bo, procedure, titulo, qtReg, filtrosPesq, filtrosDesc, colunas, campoDescricao;
    var camposOrigem = 'cepedct1;endrect1;nrendcom;complcom;cxpotct1;bairoct1;ufresct1;cidadct1';

    bo = 'b1wgen0059.p';

    /*-------------------------------------*/
    /*       CONTROLE DAS PESQUISAS        */
    /*-------------------------------------*/

    // Atribui a classe lupa para os links e desabilita todos
    $('a', '#' + nomeForm).addClass('lupa').css('cursor', 'auto');

    // Percorrendo todos os links
    $('a', '#' + nomeForm).each(function () {

        if (!$(this).prev().hasClass('campoTelaSemBorda')) { $(this).css('cursor', 'pointer'); }

        $(this).unbind("click").bind("click", (function () {
            if ($(this).prev().hasClass('campoTelaSemBorda')) {
                return false;
            } else {
                campoAnterior = $(this).prev().attr('name');

                // Natureza Ocupação
                if (campoAnterior == 'cdnatopc') {
                    filtrosPesq = "Cód. Nat. Ocupação;cdnatopc;30px;S;0|Natureza da Ocupação;rsnatocp;200px;S;";
                    colunas = 'Código;cdnatocp;25%;right|Natureza da Ocupação;rsnatocp;75%;left';
                    mostraPesquisa("ZOOM0001", "BUSCANATOCU", "Natureza da Ocupa&ccedil;&atilde;o", "30", filtrosPesq, colunas, divRotina);
                    return false;

                    // Código Empresa
                } else if (campoAnterior == 'cdempres') {
                    procedure = 'busca_empresa';
                    titulo = 'Empresa';
                    qtReg = '30';
                    filtrosPesq = 'Cód. Empresa;cdempres;30px;S;0|Nome Empresa;nmresemp;200px;S;';
                    colunas = 'Código;cdempres;20%;right|Empresa;nmresemp;80%;left';
                    mostraPesquisa(bo, procedure, titulo, qtReg, filtrosPesq, colunas, divRotina);
                    return false;

                    // Busca Ocupação
                } else if (campoAnterior == 'cdocpttl') {
                    filtrosPesq = 'Cód. Ocupação;cdocpttl;30px;S;0|Ocupação;rsdocupa;200px;S;';
                    colunas = 'Código;cdocupa;20%;right|Ocupação;dsdocupa;80%;left';
                    mostraPesquisa("ZOOM0001", "BUSCOCUPACAO", "Natureza de Ocupa&ccedil;&atilde;o", "30", filtrosPesq, colunas, divRotina);
                    return false;

                }

            }
            return false;
        }));
    });

    /*-------------------------------------*/
    /*   CONTROLE DAS BUSCA DESCRIÇÕES     */
    /*-------------------------------------*/

    // Natureza Ocupação
    $('#cdnatopc', '#' + nomeForm).unbind('change').bind('change', function () {
        filtrosDesc = '';
        buscaDescricao("ZOOM0001", "BUSCANATOCU", "Natureza Ocupação", $(this).attr('name'), 'rsnatocp', $(this).val(), 'rsnatocp', filtrosDesc, nomeForm);
        return false;
    });

    // Ocupação
    $('#cdocpttl', '#' + nomeForm).unbind('change').bind('change', function () {
        filtrosDesc = '';
        buscaDescricao("ZOOM0001", "BUSCOCUPACAO", "Ocupação", $(this).attr('name'), 'rsocupa', $(this).val(), 'dsdocupa', filtrosDesc, nomeForm);
        return false;
    });

    // Busca Endereco por Cep
    $('#cepedct1', '#' + nomeForm).buscaCEP(nomeForm, camposOrigem, divRotina);
}


function controlaPesquisaRendi() {

    // Variável local para guardar o elemento anterior
    var campoAnterior = '';
    var bo, procedure, titulo, qtReg, filtrosPesq, filtrosDesc, colunas, campoDescricao;

    bo = 'b1wgen0059.p';

    /*-------------------------------------*/
    /*       CONTROLE DAS PESQUISAS        */
    /*-------------------------------------*/

    // Atribui a classe lupa para os links e desabilita todos
    $('a', '#frmManipulaRendi').addClass('lupa').css('cursor', 'auto');

    // Percorrendo todos os links
    $('a', '#frmManipulaRendi').each(function () {

        if ($('#tpdrend2', '#frmManipulaRendi').val() == 6) {
            $('#dsjusre2', '#frmManipulaRendi').habilitaCampo();
        } else {
            $('#dsjusre2', '#frmManipulaRendi').desabilitaCampo();

        }

        if (!$(this).prev().hasClass('campoTelaSemBorda')) { $(this).css('cursor', 'pointer'); }

        $(this).click(function () {
            if ($(this).prev().hasClass('campoTelaSemBorda')) {
                return false;
            } else {

                campoAnterior = $(this).prev().attr('name');

                // Tipo Rendimento
                if (campoAnterior == 'tpdrend2') {
                    procedure = 'busca_tipo_rendimento';
                    titulo = 'Origem Rendimento';
                    qtReg = '30';
                    colunas = 'Código;tpdrendi;20%;right|Origem Rendimento;dsdrendi;80%;left';


                    filtrosPesq = 'Cód. Origem;' + campoAnterior + ';30px;S;0|Descrição;dsdrend2;200px;S;';
                    mostraPesquisa(bo, procedure, titulo, qtReg, filtrosPesq, colunas, divRotina);
                    return true;

                }

            }

            return false;

        });
    });

    /*-------------------------------------*/
    /*   CONTROLE DAS BUSCA DESCRIÇÕES     */
    /*-------------------------------------*/

    // Tipo Rendimento
    $('#tpdrend2', '#frmManipulaRendi').unbind('change').bind('change', function () {
        titulo = 'Origem Rendimento';
        procedure = 'busca_tipo_rendimento';
        filtrosDesc = '';

        campoDescricao = 'dsdrend2';
        nomeCampo = 'tpdrend2';

        buscaDescricao(bo, procedure, titulo, nomeCampo, campoDescricao, $(this).val(), 'dsdrendi', filtrosDesc, 'frmManipulaRendi');
        return false;

    });

    return false;

}


function tabela(qtlinhas) {

    $('fieldset').css({ 'clear': 'both', 'border': '1px solid #777', 'margin': '3px 0px', 'padding': '0 3px 5px 3px' });
    $('fieldset > legend').css({ 'font-size': '11px', 'color': '#777', 'margin-left': '5px', 'padding': '0px 2px' });

    var divRegistro = $('div.divRegistros');
    var tabela = $('table', divRegistro);
    var nrlinhas = qtlinhas - 1;

    divRegistro.css({ 'height': '80px' });

    selecionaRendimento($('table > tbody > tr:eq(' + nrlinhas + ')', divRegistro));

    var ordemInicial = new Array();
    ordemInicial = [[0, 0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '250px';


    var arrayAlinha = new Array();
    arrayAlinha[0] = 'left';
    arrayAlinha[1] = 'right';

    var metodoTabela = '';


    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

    //Seleciona o registro que tiver foco
    $('table > tbody > tr', divRegistro).focus(function () {
        selecionaRendimento($(this));

    });

    //Seleciona o registro que é clicado
    $('table > tbody > tr', divRegistro).click(function () {
        selecionaRendimento($(this));

    });

    $('#divRendimentos').css('display', 'block');
    $('#divRegistrosRodape', '#divRendimentos').formataRodapePesquisa();

    return false;
}

function tabelaReferencia(qtlinhas) {

    $('fieldset').css({ 'clear': 'both', 'border': '1px solid #777', 'margin': '3px 0px', 'padding': '0 3px 5px 3px' });
    $('fieldset > legend').css({ 'font-size': '11px', 'color': '#777', 'margin-left': '5px', 'padding': '0px 2px' });

    var divRegistro = $('div.divRegistros');
    var tabela = $('table', divRegistro);
    var nrlinhas = qtlinhas - 1;

    divRegistro.css({ 'height': '180px' });

    var ordemInicial = new Array();
    //ordemInicial = [[0, 0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '62px';
    arrayLargura[1] = '210px';
    arrayLargura[2] = '69px';


    var arrayAlinha = new Array();
    arrayAlinha[0] = 'left';
    arrayAlinha[1] = 'left';
    arrayAlinha[2] = 'right';

    var metodoTabela = '';


    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

    //Seleciona o registro que tiver foco
    $('table > tbody > tr', divRegistro).focus(function () {
        selecionaRendimento($(this));

    });

    //Seleciona o registro que é clicado
    $('table > tbody > tr', divRegistro).click(function () {
        selecionaRendimento($(this));

    });

    $('#divReferencia').css('display', 'block');
    $('#divRegistrosRodape', '#divReferencia').formataRodapePesquisa();

    return false;
}

function selecionaRendimento(tr) {

    cddrendi = $('#tpdrendi', tr).val();
    vlrdrend = $('#vldrendi', tr).val();

    $('#tpdrend2', '#frmManipulaRendi').val($('#tpdrendi', tr).val());
    $('#vldrend2', '#frmManipulaRendi').val($('#vldrendi', tr).val());
    $('#dsdrend2', '#frmManipulaRendi').val($('#dsdrendi', tr).val());

    return false;
}

function controlaRendimentos(ope) {

    operacao = ope;

    $('#dsjusre2', '#frmManipulaRendi').desabilitaCampo();

    if (operacao == 'V') {
        $('#frmManipulaRendi').css('display', 'none');
        $('#frmJustificativa').css('display', 'none');
        $('#divBotoesRendi').css('display', 'none');
        $('#divBotoesRendas').css('display', 'none');

        controlaOperacao();

    } else {
        if (operacao == 'A') {

            nmdfield = 'Alterar';

            if ($('#tpdrend2', '#frmManipulaRendi').val() == 6) {
                $('#dsjusre2', '#frmManipulaRendi').habilitaCampo();
            }

            $('#tpdrend2', '#frmManipulaRendi').habilitaCampo();
            $('#vldrend2', '#frmManipulaRendi').habilitaCampo();
            $('#dsjusre2', '#frmManipulaRendi').val('');
            $('#frmJustificativa').css('display', 'none');
            $('#divRendimentos').css('display', 'none');
            $('#divBotoesRendi').css('display', 'none');
            $('#divBotoesRendas').css('display', 'none');
            $('#divConteudoOpcao').css('height', '160px');
            $('#frmManipulaRendi').css('display', 'block');
            $('#divBotoesManip').css('display', 'block');

        } else {
            if (operacao == 'E') {

                nmdfield = 'Excluir';

                $('#tpdrend2', '#frmManipulaRendi').desabilitaCampo();
                $('#vldrend2', '#frmManipulaRendi').desabilitaCampo();
                $('#dsdrend2', '#frmManipulaRendi').desabilitaCampo();
                $('#dsjusre2', '#frmManipulaRendi').desabilitaCampo();

                $('#frmJustificativa').css('display', 'none');
                $('#divRendimentos').css('display', 'none');
                $('#divBotoesRendi').css('display', 'none');
                $('#divBotoesRendas').css('display', 'none');
                $('#divConteudoOpcao').css('height', '160px');
                $('#frmManipulaRendi').css('display', 'block');
                $('#divBotoesManip').css('display', 'block');


            } else {
                if (operacao == 'I') {

                    nmdfield = 'Incluir';

                    if ($('#tpdrend2', '#frmManipulaRendi').val() == 6) {
                        $('#dsjusre2', '#frmManipulaRendi').habilitaCampo();

                    }

                    $('#dsjusre2', '#frmManipulaRendi').val('');
                    $('#tpdrend2', '#frmManipulaRendi').habilitaCampo();
                    $('#vldrend2', '#frmManipulaRendi').habilitaCampo();
                    $('#tpdrend2', '#frmManipulaRendi').val('');
                    $('#vldrend2', '#frmManipulaRendi').val('');
                    $('#dsdrend2', '#frmManipulaRendi').val('');

                    $('#frmJustificativa').css('display', 'none');
                    $('#divRendimentos').css('display', 'none');
                    $('#divBotoesRendi').css('display', 'none');
                    $('#divBotoesRendas').css('display', 'none');
                    $('#divConteudoOpcao').css('height', '160px');
                    $('#frmManipulaRendi').css('display', 'block');
                    $('#divBotoesManip').css('display', 'block');


                } else {
                    if (operacao == 'VR') {
                        showConfirmacao('Deseja cancelar operação?', 'Confirmação - Aimaro', 'navegarRendimentos(\'VV\'); buscaRendimentos(1,30);', 'bloqueiaFundo(divRotina)', 'sim.gif', 'nao.gif');

                    }

                }

            }
        }

    }

    $('#nmdfield').html(nmdfield);
    $('.campo:first', '#frmManipulaRendi').focus();
    $('#vldrend2').trigger('blur');


}

function navegarRendimentos(opcao) {

    tpdopcao = opcao;

    if (tpdopcao == 'VV') {
        $('#frmManipulaRendi').css('display', 'none');
        $('#divBotoesManip').css('display', 'none');
        $('#frmJustificativa').css('display', 'block');
        $('#divBotoesRendi').css('display', 'block');
        $('#divRendimentos').css('display', 'block');
        $('#divConteudoOpcao').css('height', '280px')
        $('#tpdrend2', '#frmManipulaRendi').val('');
        $('#vldrend2', '#frmManipulaRendi').val('');
        $('#dsdrend2', '#frmManipulaRendi').val('');
        $('#dsjusre2', '#frmManipulaRendi').val('');
    } else {
        $('#frmManipulaRendi').css('display', 'none');
        $('#divBotoesManip').css('display', 'none');
        buscaRendimentos(1, 30);

    }

    return false;

}


function validaJustificativa(operacao) {

    var rendimento = $('#tpdrend2', '#frmManipulaRendi').val();

    if (rendimento == 6 && $('#dsjusre2', '#frmManipulaRendi').val() == '' && operacao != 'E') {
        showError('inform', 'Deve ser informado uma justificativa.', 'Alerta - Aimaro', '$(\'#dsjusren2\',\'#frmManipulaRendi\').focus;');
        return false;
    } else {
        showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Aimaro', 'gravaRendimentos(); ', 'bloqueiaFundo( $(\'#divRotina\') );', 'sim.gif', 'nao.gif');

    }

}

function gravaRendimentos() {

    hideMsgAguardo();

    var mensagem = '';

    mensagem = 'Aguarde, gravando ...';

    showMsgAguardo(mensagem);

    var cddopcao = operacao;
    var tpdrend2 = $('#tpdrend2', '#frmManipulaRendi').val();
    var vldrend2 = $('#vldrend2', '#frmManipulaRendi').val();
    var dsjusren = removeCaracteresInvalidos($('#dsjusren', '#frmJustificativa').val(),1);
    var dsjusre2 = removeCaracteresInvalidos($('#dsjusre2', '#frmManipulaRendi').val(),1);


    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + 'telas/contas/comercial/grava_rendimentos.php',
        data: {
            nrdconta: nrdconta, idseqttl: idseqttl,
            cddopcao: cddopcao, cddrendi: cddrendi,
            vlrdrend: vlrdrend, tpdrend2: tpdrend2,
            vldrend2: vldrend2, dsjusren: dsjusren,
            dsjusre2: dsjusre2, redirect: "script_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Aimaro", "$('#tpdrend2','#frmManipulaRendimentos').focus()");
        },
        success: function (response) {
            try {
                hideMsgAguardo();
                eval(response);

            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Aimaro", "$('#tpdrend2','#frmManipulaRendimentos').focus()");
            }
        }
    });


}

function buscaRendimentos(nriniseq, nrregist) {

    hideMsgAguardo();

    var mensagem = '';

    mensagem = 'Aguarde, buscando ...';

    showMsgAguardo(mensagem);


    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + 'telas/contas/comercial/busca_rendimentos.php',
        data: {
            nrdrowid: nrdrowid, nriniseq: nriniseq,
            nrregist: nrregist, redirect: "script_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Aimaro", "$('#cddopcao','#frmCabCadlng').focus()");
        },
        success: function (response) {
            try {
                hideMsgAguardo();
                eval(response);

                $('a.paginacaoAnt').unbind('click').bind('click', function () {
                    buscaRendimentos((nriniseq - nrregist), nrregist);
                });

                $('a.paginacaoProx').unbind('click').bind('click', function () {
                    buscaRendimentos((nriniseq + nrregist), nrregist);
                });

            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Aimaro", "$('#cddopcao','#frmPesqti').focus()");
            }
        }
    });

}

function buscaReferenciaFolha(nrdconta) {

    hideMsgAguardo();

    var mensagem = '';

    mensagem = 'Aguarde, buscando ...';

    showMsgAguardo(mensagem);


    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + 'telas/contas/comercial/busca_rendas_automaticas.php',
        data: {
            nrdconta: nrdconta,
            redirect: "script_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Aimaro", "$('#cddopcao','#frmCabCadlng').focus()");
        },
        success: function (response) {
            try {
                hideMsgAguardo();
                //alert(response);
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Aimaro", "$('#cddopcao','#frmPesqti').focus()");
            }
        }
    });

}

function controlaContinuar(flgPrimertela) {

    buscaInfEmpresa();
	
    var inpolexp = $('#inpolexp', '#' + nomeForm).val();
    var inpolexpAnt = $('#inpolexpAnt', '#' + nomeForm).val();

    if (inpolexp !== inpolexpAnt) {
        controlaOperacao('PPE');
    } else {

    if (flgPrimertela) {

        flgContinuar = true;

        if ($("#btAlterar", "#divBotoes").length > 0) {
            buscaRendimentos(1, 30);
        } else {
            controlaOperacao('AV');
        }
    } else {
        proximaRotina();
    }
    }
}

function voltarRotina() {
    encerraRotina(false);
    acessaRotina('CONTATOS', 'Contatos', 'contatos_pf');
}

function proximaRotina() {
    hideMsgAguardo();
    acessaOpcaoAbaDados(3, 1, '@');
}

function buscaNomePessoa(){

    var nrcpfemp = $('#nrcpfemp').val();

    hideMsgAguardo();

    var mensagem = '';

    mensagem = 'Aguarde, buscando nome da pessoa ...';

    showMsgAguardo(mensagem);

    var nrcpfemp = $('#nrcpfemp').val();

    nrcpfemp = normalizaNumero(nrcpfemp);
    
    // Nao deve buscar nome caso campo esteja zerado/em branco
    if (nrcpfemp == "" || nrcpfemp == "0" ){        
        hideMsgAguardo();
        return false;
    }
    

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + 'telas/contas/comercial/busca_nome_pessoa.php',
        data: {
            nrcpfemp: nrcpfemp,
            redirect: "script_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Aimaro", "$('#cddopcao','#frmCabCadlng').focus()");
        },
        success: function (response) {
            try {
                hideMsgAguardo();
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Aimaro", "$('#cddopcao','#frmPesqti').focus()");
            }
        }
    });
}

function buscaInfEmpresa(){

    var cdempres = $('#cdempres').val();
	var nrcpfemp = $('#nrcpfemp').val();
	var nmextemp = $('#nmextemp').val();

    hideMsgAguardo();

    var mensagem = '';

    mensagem = 'Aguarde, buscando informacoes da empresa ...';

    showMsgAguardo(mensagem);
   
    // Nao deve buscar nome caso campo esteja zerado/em branco
    if (cdempres == "" || cdempres == "0" ){        
        hideMsgAguardo();
        return false;
    }
    
    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + 'telas/contas/comercial/busca_informacoes_empresa.php',
        data: {
            cdempres: cdempres,
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			nrcpfemp: normalizaNumero(nrcpfemp),
			nmextemp: nmextemp,
            redirect: "script_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Aimaro", "$('#cddopcao','#frmCabCadlng').focus()");
        },
        success: function (response) {
            try {
                hideMsgAguardo();
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Aimaro", "$('#cddopcao','#frmPesqti').focus()");
            }
        }
    });
}

