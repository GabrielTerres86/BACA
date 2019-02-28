/***********************************************************************
 Fonte: consig.js                                                  
 Autor: Leonardo Oliveira - GFT 
 Data : Agoso/2018                Ultima Alteração:                                                                    
 Objetivo  : Cadastro de servicos ofertados na tela CADCCO
                                                                   	 
 Alterações: 

************************************************************************/

//nomes
var NomeCabecalho = 'frmCabecalhoConsig';
var NomeFiltro = 'frmFiltroConsig';
var NomeDivBotoesFiltro = 'divBotoesFiltro';
var NomeFrmConsig = 'frmConsig';
var NomeDivConsig = 'divConsig';
var NomeDivTela = 'divTela';
var NomeDivBotoesConsig = 'divBotoesConsig';

//componentes tela
var 
    Cabecalho,
    Filtro,
    DivBotoesFiltro,
    FrmConsig,
    DivConsig,
    DivTela,
    FrmPesquisaEmpresa, // Pesquisa empresa
    DivConteudoPesquisaEmpresa,
    DivTabPesquisaEmpresas,
    DivPesquisaEmpresa,
    DivTabEmpresas,
    FecharPesquisa;

//campos
var Ccddopcao // * Cabecalho // Código Operação
    ,Ccdempres // * Filtro // Código Empresa
    ,Cindconsignado // 'Convênio Consignado'
    ,Cdtativconsignado // 'Data'
    ,Cnmextemp // * Form Consignado // Razão Social
    ,Ctpmodconvenio // Tipo de Convenio INSS/ Publico / Privado
    ,Cdtfchfol // Dia Fechamento Folha
    ,Cnrdialimiterepasse // Dia Limite para Repasse
    ,Cindautrepassecc // Autoriza Débito Repasse em C/C?
    ,Cindinterromper // Interrompe Cobrança
    ,Cdtinterromper // Data Interrupção Cobrança
    ,Cdsdemail // E-mail
    ,Cindalertaemailemp // Alertas (check box)
    ,Cdsdemailconsig // E-mail Consignado
    ,Cindalertaemailconsig; // Alertas Consignado (check box)

//labels
var Lcddopcao // * Cabecalho
    ,Lcdempres // * Filtro
    ,Lindconsignado // 'Convênio Consignado'
    ,Ldtativconsignado // 'Data'
    ,Lnmextemp // * Form Consignado // Razão Social
    ,Ltpmodconvenio // Tipo de Convenio INSS/ Publico / Privado
    ,Ldtfchfol // Dia Fechamento Folha
    ,Lnrdialimiterepasse // Dia Limite para Repasse
    ,Lindautrepassecc // Autoriza Débito Repasse em C/C?
    ,Lindinterromper // Interrompe Cobrança
    ,Ldtinterromper // Data Interrupção Cobrança
    ,Ldsdemail // E-mail
    ,Ldsdemailconsig; // E-mail Consignado


//botoes
var BtnOK, BtProsseguir, btLupa;

//auxiliares
var dtinterromperOld, dtfchfolOld;

$(document).ready(function () {
    estadoInicial();

});

function estadoInicial() {

    formataCabecalho();

    Cabecalho = $('#'+NomeCabecalho);
    Filtro = $('#'+NomeFiltro);
    DivBotoesFiltro = $('#'+NomeDivBotoesFiltro);
    FrmConsig = $('#'+NomeFrmConsig);
    DivConsig = $('#'+NomeDivConsig);

    //Cabecalho.habilitaCampo().focus().val('C');
    Filtro.css('display', 'none');
    DivBotoesFiltro.css('display', 'none');
    FrmConsig.css('display', 'none');
    DivConsig.html('').css('display', 'none');
    layoutPadrao();
}

function formataCabecalho() {

    DivTela = $('#'+NomeDivTela);
    Cabecalho = $('#'+NomeCabecalho);
    Lcddopcao = $('label[for="cddopcao"]', Cabecalho);
    Ccddopcao = $('#cddopcao', Cabecalho);
    BtnOK = $('#btOK', Cabecalho);


    Ccddopcao.habilitaCampo();
    Lcddopcao.css('width', '50px').addClass('rotulo');
    Ccddopcao.css('width', '520px');
    Cabecalho.css('display', 'block');

    DivTela.fadeTo(0, 0.1);
    removeOpacidade('divTela');
    highlightObjFocus(Cabecalho);

    //Ao clicar no botao OK
    BtnOK.unbind('click').bind('click', function () {
        // esconder cddopcao
        $('input,select').removeClass('campoErro');
        Ccddopcao.desabilitaCampo();
        BtnOK.unbind();
        formataFiltro();
    });
    controlaFocoCabecalho();
    Ccddopcao.focus();
}

function controlaFocoCabecalho() {

    Cabecalho = $('#'+NomeCabecalho);
    Ccddopcao = $('#cddopcao', Cabecalho);
    BtnOK = $('#btOK', Cabecalho);



    Ccddopcao.unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            BtnOK.click();
            return false;
        }
    });

    BtnOK.unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            BtnOK.click();
            return false;
        }
    });
    return false;
}

function formataFiltro(){

    Cabecalho = $('#'+NomeCabecalho);
    Ccddopcao = $('#cddopcao', Cabecalho);

    if (!(validaPermissao(Ccddopcao.val())))
		return false;

    Filtro = $('#'+NomeFiltro);
    DivBotoesFiltro = $('#'+NomeDivBotoesFiltro);
    BtProsseguir = $('#btProsseguir', DivBotoesFiltro);
    BtVoltar = $('#btVoltar', DivBotoesFiltro);
    BtLupa = $('#btLupa', Filtro);
    BtOK = $('#btOK', Filtro); 

    Ccdempres = $('#cdempres', Filtro); // * Filtro // Código Empresa
    Cindconsignado = $('#text_indconsignado', Filtro); // 'Convênio Consignado'
    Cdtativconsignado = $('#dtativconsignado', Filtro); // 'Data'
    Crowid = $('#rowid_emp_consig', Filtro); // rowid

    Lcdempres = $('label[for="cdempres"]', Filtro); // * Filtro // Código Empresa
    Lindconsignado = $('label[for="text_indconsignado"]', Filtro); // 'Convênio Consignado'
    Ldtativconsignado = $('label[for="dtativconsignado"]', Filtro); // 'Data'

    highlightObjFocus( Filtro );
    Lindconsignado.addClass('rotulo')
                .css('width','150px');

    Ldtativconsignado.addClass('rotulo')
                    .css('width','100px')
                    .css('float','left')
                    .css('clear','none');

    Lcdempres.addClass('rotulo')
            .css('width','150px');

    Ccdempres.css({ 'width': '100px', 'text-align': 'right' })
                .addClass('inteiro')
                .addClass('codigo pesquisa')
                .attr('maxlength', '10')
                .habilitaCampo()
                .val('');

    Cindconsignado.attr('size','4')
                .css('display', 'block');

    Ccdempres.setMask("INTEGER", "zzzzz.zz9", ".", "");
    Cdtativconsignado.attr('size','10')
        .attr('maxlength','10')
        .setMask("INTEGER", "zz/zz/zzzz", "","");

    Ccdempres.css('display', 'block');
    Filtro.css('display', 'block');
    DivBotoesFiltro.css('display', 'block');
    BtLupa.css('display','block');

    Ccdempres.habilitaCampo();
    Cindconsignado.desabilitaCampo();
    Cdtativconsignado.desabilitaCampo();

    Ccdempres.unbind('change').bind('change', function () {
        buscarDescricao();
        return false;
    });

        //Ao clicar no botao OK
    BtOK.unbind('click').bind('click', function () {
        buscarDescricao();
        return false;
    });

    Ccdempres.unbind('keypress').bind('keypress',function(e) {      
        if(e.keyCode == 13 || e.keyCode == 9){
            buscarDescricao();
            return false;
        }
    });

    //Ao clicar no botao OK
    BtProsseguir.unbind('click').bind('click', function () {
        if(!existeEmpresa()){
            buscarDescricao(function(){
                consultaParametros();
                return false;
            });
            return false;
        }
        consultaParametros();
        return false;
    });

    //Ao clicar no botao OK
    BtVoltar.unbind('click').bind('click', function () {
        voltar('1');
        return false;
    });

    BtLupa.unbind('click').bind('click',function() {
        mostraPesquisaEmpresa();
        return false;
    });
    limparCamposFiltro();
    Ccdempres.focus();
    layoutPadrao();
    return false;
}

function limparCamposFiltro(){

    Filtro = $('#'+NomeFiltro);
    Cdtativconsignado = $('#dtativconsignado', Filtro); // 'Data'
    CtextIndconsignado =  $('#text_indconsignado', Filtro);
    Crowid = $('#rowid_emp_consig', Filtro); // rowid
    CtextIndconsignado.val('');
    Cdtativconsignado.val('');
    Crowid.val('');
    return false;
}

function desabilitaFiltro(){
    Filtro = $('#'+NomeFiltro);
    DivBotoesFiltro = $('#'+NomeDivBotoesFiltro);
    BtProsseguir = $('#btProsseguir', DivBotoesFiltro);
    BtVoltar = $('#btVoltar', DivBotoesFiltro);
    BtLupa = $('#btLupa', Filtro); 

    Ccdempres = $('#cdempres', Filtro); // * Filtro // Código Empresa
    Cindconsignado = $('#indconsignado', Filtro); // 'Convênio Consignado'
    Cdtativconsignado = $('#dtativconsignado', Filtro); // 'Data'
    BtLupa.css('display','none');
    Ccdempres.desabilitaCampo();
    Cindconsignado.desabilitaCampo();
    Cdtativconsignado.desabilitaCampo();
    DivBotoesFiltro.css('display', 'none');
    return false;
}

function mostraPesquisaEmpresa(){

    Cabecalho = $('#'+NomeCabecalho);
    Ccddopcao = $('#cddopcao', Cabecalho);

    var cddopcao = Ccddopcao.val();
    var businessObject = 'TELA_CONSIG';
    var nomeProcedure = 'OBTEM_DADOS_EMP_CONSIGNADO';
    var titulo = 'Empresa';
    var qtReg = '30';
    var filtros = 'Nome da Empresa;nmextemp;150;S;;S;;|Razão Social;nmresemp;150;S;;S;;|Codigo Empresa;cdempres;;N;-1;N;;|;cddopcao;;N;' + cddopcao + ';N;|Empréstimo Consigando;indconsignado;;N;;N;;|Data;dtativconsignado;;N;;N;;|rowid;rowid_emp_consig;;N;;N;;';
    var colunas = 'Nome da Empresa;nmextemp;150;S;;S;;|Razão Social;nmresemp;150;S;;S;;|Codigo Empresa;cdempres;;S;;S;;|;cddopcao;;N;;N;|Empréstimo Consigando;indconsignado;;N;;N;;|Data;dtativconsignado;;N;;N;;|rowid;rowid_emp_consig;;N;;N;;';
    var divBloqueia = '';
    var fncOnClose = 'fecharPesquisa();';
    var nomeRotina =  NomeFiltro;
    mostraPesquisa(businessObject, nomeProcedure, titulo, qtReg, filtros, colunas, divBloqueia, fncOnClose, nomeRotina);//, cdCooper);
	return false;
}

function buscarDescricao(callback){
    limparCamposFiltro();
    Cabecalho = $('#'+NomeCabecalho);
    Ccddopcao = $('#cddopcao', Cabecalho);
    Filtro = $('#'+NomeFiltro);
    Ccdempres = $('#cdempres', Filtro);
    Cindconsignado = $('#indconsignado', Filtro);
    Crowid_emp_consig = $('#rowid_emp_consig', Filtro);
    Cdtativconsignado = $('#dtativconsignado', Filtro);

    var cdempres = Ccdempres.val();
    var cddopcao = Ccddopcao.val();
    var indconsignado = '';
    var rowid_emp_consig = '';
    var dtativconsignado = '';
    
     $.ajax({
            type: 'POST',
            url: UrlSite + 'telas/consig/manter_rotina.php',
            data: {
                cddopcao: 'B',
                cdempres: cdempres,
                consulta_cddopcao: cddopcao,
                redirect: 'script_ajax'
            },
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError(
                    'error',
                    'Nao foi possivel concluir a operacao.',
                    'Alerta - Ayllos',
                    '$("#nrconven", "#frmFiltro").focus();');
            },
            success: function (response) {
                try {
                    eval(response);
                    Ccdempres.val(cdempres);
                    Cindconsignado.val(indconsignado);
                    Crowid_emp_consig.val(rowid_emp_consig);
                    Cdtativconsignado.val(dtativconsignado);
                    fecharPesquisa();
                    if(callback){
                        callback();
                    }
                    return false;
                } catch (error) {
                    showError(
                        'error',
                        'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. ' + error.message,
                        'Alerta - Ayllos',
                        '$("#nrconven",'+NomeFiltro+').focus();');
                    return false;
                }//catch
            }//success
        });//ajax
    return false;
}

function callbackBuscarDescricao(){
    return false;
}

function fecharPesquisa(){
    Filtro = $('#'+NomeFiltro);
    Cindconsignado = $('#indconsignado', Filtro); // 'Convênio Consignado'
    CtextIndconsignado = $('#text_indconsignado', Filtro); // 'Convênio Consignado'
    var indconsignado = Cindconsignado.val();
    if(indconsignado == "1"){
        CtextIndconsignado.val("Sim");
    } else if(indconsignado == '0') {
        CtextIndconsignado.val("Não");
    }else{
        CtextIndconsignado.val('');
    }
    return false;
}

function consultaParametros(){
    DivConsig = $('#'+NomeDivConsig);
    Cabecalho = $('#'+NomeCabecalho);
    Ccddopcao = $('#cddopcao', Cabecalho);

    Filtro = $('#'+NomeFiltro);
    Ccdempres = $('#cdempres', Filtro); // * Filtro // Código Empresa
    Cindconsignado = $('#indconsignado', Filtro); // 'Convênio Consignado'
    Cdtativconsignado = $('#dtativconsignado', Filtro); // 'Data'

    var cddopcao = Ccddopcao.val();
    var cdempres = Ccdempres.val(); // * Filtro // Código Empresa
    var indconsignado = Cindconsignado.val(); // 'Convênio Consignado'
    var dtativconsignado = Cdtativconsignado.val(); // 'Data'

    if(!existeEmpresa()){
            hideMsgAguardo();
            showError(
                'error',
                'Não há código de empresa cadastrado.',
                'Alerta - Ayllos',
                '');
            return false;
    }

     $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/consig/manter_rotina.php',
        data: {
            cddopcao: '',
            consulta_cddopcao : cddopcao,
            cdempres: cdempres,
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError(
                'error',
                'Nao foi possivel concluir a operacao.',
                'Alerta - Ayllos',
                '$("#nrconven", "#frmFiltro").focus();');
        },
        success: function (response) {
            hideMsgAguardo();
            desabilitaFiltro();
            try {

                try { // Javascript
                    eval(response);
                    return false;
                } catch (error) { // Html
                    DivConsig.html(response);
                    formataTelaConsig();
                    return false;
                }//catch
                
            } catch (error) {

                showError(
                    'error',
                    'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. ' + error.message,
                    'Alerta - Ayllos',
                    '$("#nrconven",'+NomeFiltro+').focus();');
            }//catch
        }//success
    });//ajax
    return false;
}

function existeEmpresa(){
    Filtro = $('#'+NomeFiltro);
    Crowid = $('#rowid_emp_consig', Filtro);// rowid
    Cdempres = $('#cdempres', Filtro);// Código Empresa

    cdempres = Cdempres.val();
    rowid = Crowid.val();

    // console.log(rowid);

    if(!rowid || trim(rowid) == '' || rowid == 0){
        return false;
    }
    if(!cdempres || trim(cdempres) == '' || cdempres == 0){
        return false;
    }
    return true;
}

function formataTelaConsig(){
    FrmConsig = $('#'+NomeFrmConsig);
    DivConsig = $('#'+NomeDivConsig);
    DivBotoesConsig = $('#'+NomeDivBotoesConsig);

    BtConcluir = $('#btConcluir', DivBotoesConsig);
    BtVoltar = $('#btVoltar', DivBotoesConsig);

    Lnmextemp = $('label[for="nmextemp"]', FrmConsig); // * Form Consignado // Razão Social
    Ltpmodconvenio = $('label[for="select_tpmodconvenio"]', FrmConsig);  // Tipo de Convenio INSS/ Publico / Privado
    Ldtfchfol = $('label[for="dtfchfol"]', FrmConsig);  // Dia Fechamento Folha
    Lnrdialimiterepasse = $('label[for="nrdialimiterepasse"]', FrmConsig);  // Dia Limite para Repasse
    Lindautrepassecc = $('label[for="radio_indautrepassecc"]', FrmConsig);  // Autoriza Débito Repasse em C/C?
    Lindinterromper = $('label[for="radio_indinterromper"]', FrmConsig);  // Interrompe Cobrança
    Ldtinterromper = $('label[for="dtinterromper"]', FrmConsig); // Data Interrupção Cobrança
    Ldsdemail = $('label[for="dsdemail"]', FrmConsig); // E-mail
    Ldsdemailconsig = $('label[for="dsdemailconsig"]', FrmConsig); // E-mail Consignado
    Llbalertaconsig =  $('#lbalertaconsig', FrmConsig);

    Cnmextemp = $('#nmextemp', FrmConsig); // * Form Consignado // Razão Social
    Ctpmodconvenio = $('#select_tpmodconvenio', FrmConsig); // Tipo de Convenio INSS/ Publico / Privado
    Cdtfchfol = $('#dtfchfol', FrmConsig); // Dia Fechamento Folha
    Cnrdialimiterepasse = $('#nrdialimiterepasse', FrmConsig); // Dia Limite para Repasse
    Cindautrepassecc = $('#radio_indautrepassecc', FrmConsig); // Autoriza Débito Repasse em C/C?
    Cindinterromper = $('#radio_indinterromper', FrmConsig); // Interrompe Cobrança
    Cdtinterromper = $('#dtinterromper', FrmConsig); // Data Interrupção Cobrança
    Cdsdemail = $('#dsdemail', FrmConsig); // E-mail
    Cindalertaemailemp = $('#checkbox_indalertaemailemp', FrmConsig); // Alertas (check box)
    Cdsdemailconsig = $('#dsdemailconsig', FrmConsig); // E-mail Consignado
    Cindalertaemailconsig = $('#checkbox_indalertaemailconsig', FrmConsig);// Alertas Consig(check box)

    highlightObjFocus( Filtro );

    Lnmextemp.addClass('rotulo').css('width','200px');
    Ltpmodconvenio.addClass('rotulo').css('width','200px');
    Ldtfchfol.addClass('rotulo').css('width','200px');
    Lnrdialimiterepasse.addClass('rotulo').css('width','200px');
    Lindautrepassecc.addClass('rotulo').css('width','200px').css('margin-right','10px');
    Lindinterromper.addClass('rotulo').css('width','200px').css('margin-right','10px');
    Ldtinterromper.addClass('rotulo').css('width','200px');
    Ldsdemail.addClass('rotulo').css('width','200px');
    Ldsdemailconsig.addClass('rotulo').css('width','200px');
    Llbalertaconsig.addClass('rotulo').css('margin-left','400px');


    Cindautrepassecc.css('margin-left','10px');
    Cindinterromper.css('margin-left','10px');

    Cdsdemail.css('margin-right','10px');
    Cdsdemailconsig.css('margin-right','10px');

    DivConsig.css('display', 'block');
    FrmConsig.css('display', 'block');

    Cdtfchfol.attr('size','2')
            .attr('maxlength','2')
            .setMask("INTEGER", "zz", "","");
            
    Cdtfchfol.bind('blur', function () {
        if ($(this).val() == '') {
            return true;
        }

        if(!checkIsDay(Cdtfchfol)){
            return false;
        }
        return true;
    });

    Cnrdialimiterepasse.attr('size','2')
            .attr('maxlength','2')
            .setMask("INTEGER", "zz", "","");

    Cnrdialimiterepasse.bind('blur', function () {
        if ($(this).val() == '') {
            return true;
        }

        if(!checkIsDay(Cnrdialimiterepasse)){
            return false;
        }
        return true;
    });

    Cnmextemp.attr('size','50');
    Cdtinterromper.attr('size','10')
            .attr('maxlength','10')
            .setMask("INTEGER", "zz/zz/zzzz", "","");
    Cdsdemail.attr('size','30');
    Cdsdemailconsig.attr('size','30');

    controlaFocoTelaConsig();
    atualizaConvenio();

	// verificação de alteração de valores pelo usuário
    Ctpmodconvenio.unbind('change').bind('change', function(e) {
        $('#tpmodconvenio', FrmConsig).val(Ctpmodconvenio.val()); // Tipo de Convenio INSS/ Publico / Privado
		atualizaConvenio();
        return false;
    });

    $('input[name="radio_indautrepassecc"][value="0"]').unbind('change').bind('change', function(e) {
        $('#indautrepassecc', FrmConsig).val(0);
        return false;
    });

    $('input[name="radio_indautrepassecc"][value="1"]').unbind('change').bind('change', function(e) {
        $('#indautrepassecc', FrmConsig).val(1);
        return false;
    });


    $('input[name="radio_indinterromper"][value="0"]').unbind('change').bind('change', function(e) {
        $('#indinterromper', FrmConsig).val(0);
        return false;
    });

    $('input[name="radio_indinterromper"][value="1"]').unbind('change').bind('change', function(e) {
        $('#indinterromper', FrmConsig).val(1);
        return false;
    });

    Cindalertaemailemp.unbind('change').bind('change', function(e) {
        var val = Cindalertaemailemp.attr('checked') ? 1 : 0;
        $('#indalertaemailemp', FrmConsig).val(val); // Tipo de Convenio INSS/ Publico / Privado
           return false;
    });

    Cindalertaemailconsig.unbind('change').bind('change', function(e) {
        var val = Cindalertaemailconsig.attr('checked') ? 1 : 0;
        $('#indalertaemailconsig', FrmConsig).val(val); // Tipo de Convenio INSS/ Publico / Privado
           return false;
    });

    BtVoltar.unbind('click').bind('click', function () {
        voltar('2');
        return false;
    });

    BtConcluir.unbind('click').bind('click', function () {
        controlaOperacao();
        return false;
    });

    Cindinterromper.change(function() {
       showHideDtInterrupcao(this.value);
    });

    //controlaOperacao

}

function checkIsDay(field){
    if(field.val() < 1 || field.val() >31){
        showError("error", "Dia inv&aacute;lido.", "Alerta - Ayllos", "$('#"+field.attr('id')+"','#"+FrmConsig.attr('id')+"').focus()");
        field.val('');
        return false;
    }
    return true;
}

// Se Interrompe Cobrança == Não ENTAO data interrupção == ''
function showHideDtInterrupcao(value){
    if(value == 0){
         $('#dtinterromper', FrmConsig).val('');
    }else{
		if(value == 1){
			if (dtinterromperOld.length == 0)
			{
				var valData = $('#dtvmtolt', FrmConsig).val();
				$('#dtinterromper', FrmConsig).val(valData);
			}
			else
				$('#dtinterromper', FrmConsig).val(dtinterromperOld);
		}
		else
			$('#dtinterromper', FrmConsig).val(dtinterromperOld);
    }
}

function atualizaConvenio(){
    Cabecalho = $('#'+NomeCabecalho);
    Ccddopcao = $('#cddopcao', Cabecalho);
    FrmConsig = $('#'+NomeFrmConsig);
    DivConsig = $('#'+NomeDivConsig);

    Cnmextemp = $('#nmextemp', FrmConsig); // * Form Consignado // Razão Social
    Ctpmodconvenio = $('#select_tpmodconvenio', FrmConsig); // Tipo de Convenio INSS/ Publico / Privado
    Cdtfchfol = $('#dtfchfol', FrmConsig); // Dia Fechamento Folha
    Cnrdialimiterepasse = $('#nrdialimiterepasse', FrmConsig); // Dia Limite para Repasse
    Cindautrepassecc = $('#radio_indautrepassecc', FrmConsig); // Autoriza Débito Repasse em C/C?
    Cindinterromper = $('#radio_indinterromper', FrmConsig); // Interrompe Cobrança
    Hindautrepassecc = $('#indautrepassecc', FrmConsig); // HIDDEN Autoriza Débito Repasse em C/C?
    Hindinterromper = $('#indinterromper', FrmConsig); // HIDDEN Interrompe Cobrança
    Cdtinterromper = $('#dtinterromper', FrmConsig); // Data Interrupção Cobrança
    Cdsdemail = $('#dsdemail', FrmConsig); // E-mail
    Cindalertaemailemp = $('#checkbox_indalertaemailemp', FrmConsig); // Alertas (check box)
    Cdsdemailconsig = $('#dsdemailconsig', FrmConsig); // E-mail Consignado
    Cindalertaemailconsig = $('#checkbox_indalertaemailconsig', FrmConsig); // Alertas Consignado (check box)
    Hindalertaemailemp = $('#indalertaemailemp', FrmConsig); // HIDDEN Alertas (check box)
    Hindalertaemailconsig = $('#indalertaemailconsig', FrmConsig); // HIDDEN Alertas Consignado (check box)


	if (Cdtfchfol.val() != '')
		dtfchfolOld = Cdtfchfol.val();
    dtinterromperOld = Cdtinterromper.val();
    cddopcao = Ccddopcao.val();
    tpmodconvenio = Ctpmodconvenio.val();
    Cdsdemail.desabilitaCampo(); // E-mail sempre desabilitado par alteração manual
    
    // Configura os valores default para radios e checks
    $('input[name=radio_indautrepassecc]').prop('checked', false);
    $('input[name=radio_indautrepassecc][value='+Hindautrepassecc.val()+']').prop('checked', true); 
    $('input[name=radio_indinterromper]').prop('checked', false);
    $('input[name=radio_indinterromper][value='+Hindinterromper.val()+']').prop('checked', true); 
    if(Hindalertaemailemp.val() == '1')$('input[name=checkbox_indalertaemailemp]').prop('checked', true); 
    if(Hindalertaemailconsig.val() == '1')$('input[name=checkbox_indalertaemailconsig]').prop('checked', true);


    if(cddopcao == 'C' || cddopcao == 'D'){ // CONSULTA - desabilita todos os campos
        Cnmextemp.desabilitaCampo(); // * Form Consignado // Razão Social
        Cdtfchfol.desabilitaCampo(); // Dia Fechamento Folha
        Cnrdialimiterepasse.desabilitaCampo(); // Dia Limite para Repasse
        Cindautrepassecc.desabilitaCampo(); // Autoriza Débito Repasse em C/C?
        Cindinterromper.desabilitaCampo(); // Interrompe Cobrança
        Cdtinterromper.desabilitaCampo(); // Data Interrupção Cobrança
        Cindalertaemailemp.desabilitaCampo(); // Alertas (check box)
        Cdsdemailconsig.desabilitaCampo(); // E-mail Consignado
        Cindalertaemailconsig.desabilitaCampo(); // Alertas Consignado (check box)
    } else { // Se não for CONSULTA por padrão habilita todos os campos
        Cnmextemp.desabilitaCampo(); // * Form Consignado // Razão Social - por padrão nao fica desabilatado para alteração
        Cdtfchfol.habilitaCampo(); // Dia Fechamento Folha
        Cnrdialimiterepasse.habilitaCampo(); // Dia Limite para Repasse
        Cindautrepassecc.habilitaCampo(); // Autoriza Débito Repasse em C/C?
        Cindinterromper.habilitaCampo(); // Interrompe Cobrança
        Cdtinterromper.habilitaCampo(); // Data Interrupção Cobrança
        Cindalertaemailemp.habilitaCampo(); // Alertas (check box)
        Cdsdemailconsig.habilitaCampo(); // E-mail Consignado
        Cindalertaemailconsig.habilitaCampo(); // Alertas Consignado (check box)
    }

    // Select do tipo de convenivo só fica habilitado para H - Habilitar
    if(cddopcao == 'H'){
        Ctpmodconvenio.habilitaCampo();
    }else{
        Ctpmodconvenio.desabilitaCampo();
    }

    /*
        INSS = 3
        Publico = 2
        Privado = 1
    */
    if(tpmodconvenio == 1){
		if (Cdtfchfol.val() == '')
			Cdtfchfol.val(dtfchfolOld);
        if(cddopcao == 'H'){
            Cnrdialimiterepasse.val('');
            $('input[name=radio_indautrepassecc]').prop('checked', false);
            $('input[name=radio_indautrepassecc][value=1]').prop('checked', true); 
			$('#indautrepassecc', FrmConsig).val(1);
            $('input[name=radio_indinterromper]').prop('checked', false);
            $('input[name=radio_indinterromper][value=0]').prop('checked', true); 
			$('#indinterromper', FrmConsig).val(0);
        }

    }else if(tpmodconvenio == 2){// Publico
        //Autoriza Débito Repasse em C/C?
		if (Cdtfchfol.val() == '')
			Cdtfchfol.val(dtfchfolOld);
        Cindautrepassecc.desabilitaCampo();
        if(cddopcao == 'A' || cddopcao == 'H'){
            $('input[name=radio_indautrepassecc]').prop('checked', false);
			$('#indautrepassecc', FrmConsig).val(0);
			$('#indinterromper', FrmConsig).val(0);
        }
    } else if ( tpmodconvenio == 3){ // INSS
        // Limpa data de interrupção para INSS
        Cdtfchfol.val('');
        Cdsdemail.val('');
        Cdsdemailconsig.val('');
        $('input[name=radio_indautrepassecc]').prop('checked', false);
        $('input[name=radio_indinterromper]').prop('checked', false);
		$('#indautrepassecc', FrmConsig).val(0);
		$('#indinterromper', FrmConsig).val(0);
        Cindalertaemailemp.prop('checked', false); 
        Cindalertaemailconsig.prop('checked', false); 
        if(cddopcao == 'A' || cddopcao == 'H'){ // ALTERAR || HABILITAR
            // Dia Fechamento Folha
            Cdtfchfol.desabilitaCampo();
            // Autoriza Débito Repasse em C/C?
            Cindautrepassecc.desabilitaCampo();
            // Interrompe Cobrança
            Cindinterromper.desabilitaCampo();
            // Data Interrupção Cobrança
            Cdtinterromper.desabilitaCampo();
            // E-mail
            //Cdsdemail.desabilitaCampo();
            //Alerta
            Cindalertaemailemp.desabilitaCampo();
            // E-mail Consignado
            Cdsdemailconsig.desabilitaCampo();
            // Alertas Consignado
            Cindalertaemailconsig.desabilitaCampo();
        }
        if(cddopcao == 'D'){ // DESABILITAR
            // Razão Social
            Cnmextemp.desabilitaCampo();
            //Dia Limite para Repasse
            Cnrdialimiterepasse.desabilitaCampo();
         }
         if(cddopcao == 'H'){ // HABILITAR
            Cnrdialimiterepasse.val('');
         }
    } // tpmodconvenio - INSS

    showHideDtInterrupcao($('input[name=indinterromper]:checked', '#'+FrmConsig.attr('id')+'').val());

    return false;
}

function controlaFocoTelaConsig(){

    FrmConsig = $('#'+NomeFrmConsig);
    DivConsig = $('#'+NomeDivConsig);
    Cnmextemp = $('#nmextemp', FrmConsig); // * Form Consignado // Razão Social
    Ctpmodconvenio = $('#select_tpmodconvenio', FrmConsig); // Tipo de Convenio INSS/ Publico / Privado
    Cdtfchfol = $('#dtfchfol', FrmConsig); // Dia Fechamento Folha
    Cnrdialimiterepasse = $('#nrdialimiterepasse', FrmConsig); // Dia Limite para Repasse
    Cindautrepassecc = $('#radio_indautrepassecc', FrmConsig); // Autoriza Débito Repasse em C/C?
    Cindinterromper = $('#radio_indinterromper', FrmConsig); // Interrompe Cobrança
    Cdtinterromper = $('#dtinterromper', FrmConsig); // Data Interrupção Cobrança
    Cdsdemail = $('#dsdemail', FrmConsig); // E-mail
    Cindalertaemailemp = $('#checkbox_indalertaemailemp', FrmConsig); // Alertas (check box)
    Cdsdemailconsig = $('#dsdemailconsig', FrmConsig); // E-mail Consignado
    Cindalertaemailconsig = $('#checkbox_indalertaemailconsig', FrmConsig);
    
	DivBotoesConsig = $('#'+NomeDivBotoesConsig);
    BtConcluir = $('#btConcluir', DivBotoesConsig);
    BtVoltar = $('#btVoltar', DivBotoesConsig);

    Cnmextemp.unbind('keypress').bind('keypress', function(e){
            /*Se foi pressionado a telca ENTER*/
            if (e.keyCode == 9 || e.keyCode == 13) {
                Ctpmodconvenio.focus();
                return false;
            }
        });

    Ctpmodconvenio.unbind('keypress').bind('keypress', function(e){
            /*Se foi pressionado a telca ENTER*/
            if (e.keyCode == 9 || e.keyCode == 13) {
                Cdtfchfol.focus();
                return false;
            }
        });

    Cdtfchfol.unbind('keypress').bind('keypress', function(e){
            /*Se foi pressionado a telca ENTER*/
            if (e.keyCode == 9 || e.keyCode == 13) {
                Cnrdialimiterepasse.focus();
                return false;
            }
        });

    Cnrdialimiterepasse.unbind('keypress').bind('keypress', function(e){
            /*Se foi pressionado a telca ENTER*/
            if (e.keyCode == 9 || e.keyCode == 13) {
                Cindautrepassecc.focus();
                return false;
            }
        });

    Cindautrepassecc.unbind('keypress').bind('keypress', function(e){
            /*Se foi pressionado a telca ENTER*/
            if (e.keyCode == 9 || e.keyCode == 13) {
                Cindinterromper.focus();
                return false;
            }
        });

    Cindinterromper.unbind('keypress').bind('keypress', function(e){
            /*Se foi pressionado a telca ENTER*/
            if (e.keyCode == 9 || e.keyCode == 13) {
                Cdsdemail.focus();
                return false;
            }
        });

    Cdsdemail.unbind('keypress').bind('keypress', function(e){
            /*Se foi pressionado a telca ENTER*/
            if (e.keyCode == 9 || e.keyCode == 13) {
                Cindalertaemailemp.focus();
                return false;
            }
        });

    Cindalertaemailemp.unbind('keypress').bind('keypress', function(e){
            /*Se foi pressionado a telca ENTER*/
            if (e.keyCode == 9 || e.keyCode == 13) {
                Cdsdemailconsig.focus();
                return false;
            }
        });

    Cdsdemailconsig.unbind('keypress').bind('keypress', function(e){
            /*Se foi pressionado a telca ENTER*/
            if (e.keyCode == 9 || e.keyCode == 13) {
                Cindalertaemailconsig.focus();
                return false;
            }
        });

    Cindalertaemailconsig.unbind('keypress').bind('keypress', function(e){
            /*Se foi pressionado a telca ENTER*/
            if (e.keyCode == 9 || e.keyCode == 13) {
                BtConcluir.focus();
                return false;
            }
        });
    return false;
}

function voltar(flag){

    DivConsig = $('#'+NomeDivConsig);

    switch (flag) {
        case '1':
            // Voltar de filtro para cabeçalho
            estadoInicial();
            break;

        case '2':
            // Voltar de Consig para Filtro
            DivConsig.html('').css('display','none');
            formataFiltro();
            break;
    }
    return false;
}

function controlaOperacao(){
    //cabecalho
    Cabecalho = $('#'+NomeCabecalho);
    Ccddopcao = $('#cddopcao', Cabecalho);
    cddopcao = Ccddopcao.val();

    //filtro
    Filtro = $('#'+NomeFiltro);
    Ccdempres = $('#cdempres', Filtro); // * Filtro // Código Empresa
    Cindconsignado = $('#indconsignado', Filtro); // 'Convênio Consignado'
    Cdtativconsignado = $('#dtativconsignado', Filtro); // 'Data'

    cdempres = Ccdempres.val(); // * Filtro // Código Empresa
    indconsignado = Cindconsignado.val(); // 'Convênio Consignado'
    dtativconsignado = Cdtativconsignado.val(); // 'Data'

    //form
    FrmConsig = $('#'+NomeFrmConsig);
    DivConsig = $('#'+NomeDivConsig);

    Cnmextemp = $('#nmextemp', FrmConsig); // * Form Consignado // Razão Social
    Ctpmodconvenio = $('#tpmodconvenio', FrmConsig); // Tipo de Convenio INSS/ Publico / Privado
    Cdtfchfol = $('#dtfchfol', FrmConsig); // Dia Fechamento Folha
    Cnrdialimiterepasse = $('#nrdialimiterepasse', FrmConsig); // Dia Limite para Repasse
    Cindautrepassecc = $('#radio_indautrepassecc', FrmConsig); // Autoriza Débito Repasse em C/C?
    Cindinterromper = $('#radio_indinterromper', FrmConsig); // Interrompe Cobrança
    Hindautrepassecc = $('#indautrepassecc', FrmConsig); // HIDDEN Autoriza Débito Repasse em C/C?
    Hindinterromper = $('#indinterromper', FrmConsig); // HIDDEN Interrompe Cobrança
    Cdtinterromper = $('#dtinterromper', FrmConsig); // Data Interrupção Cobrança
    Cdsdemail = $('#dsdemail', FrmConsig); // E-mail
    Cindalertaemailemp = $('#indalertaemailemp', FrmConsig); // Alertas (check box)
    Cdsdemailconsig = $('#dsdemailconsig', FrmConsig); // E-mail Consignado
    Cindalertaemailconsig = $('#indalertaemailconsig', FrmConsig);// Alertas Consig(check box)

    nmextemp = Cnmextemp.val(); // * Form Consignado // Razão Social
    tpmodconvenio = Ctpmodconvenio.val(); // Tipo de Convenio INSS/ Publico / Privado
    dtfchfol = Cdtfchfol.val(); // Dia Fechamento Folha
    nrdialimiterepasse =  Cnrdialimiterepasse.val(); // Dia Limite para Repasse
    indautrepassecc = Hindautrepassecc.val(); // Autoriza Débito Repasse em C/C?
    indinterromper = Hindinterromper.val(); // Interrompe Cobrança
    dtinterromper = Cdtinterromper.val(); // Data Interrupção Cobrança
    dsdemail = Cdsdemail.val(); // E-mail
    indalertaemailemp = Cindalertaemailemp.val(); // Alertas (check box)
    dsdemailconsig = Cdsdemailconsig.val(); // E-mail Consignado
    indalertaemailconsig = Cindalertaemailconsig.val();// Alertas Consig(check box)

    


    // Validações de campos obrigatórios no front
    // Publico
    if(tpmodconvenio == 2 && (cddopcao == 'A' || cddopcao == 'H')){
        // Dia fechamento folha
        if(dtfchfol == ''){
            hideMsgAguardo();
            showError(
                'error',
                'Informe um dia v&aacute;lido.',
                'Alerta - Ayllos',
                 "$('#dtfchfol','#"+FrmConsig.attr('id')+"').focus()");
            return false;
        }
        // Interrompe cobrança
        if(!Cindinterromper.is(':checked')) {
            showError(
                'error',
                'Informe se voc&ecirc; deseja Interromper a Cobran&ccedil;a.',
                'Alerta - Ayllos',
                '');
            return false;
        }

    }

    // Privado
    if(tpmodconvenio == 1 && (cddopcao == 'A' || cddopcao == 'H')){
        // Dia fechamento folha
        if(dtfchfol == ''){
            hideMsgAguardo();
            showError(
                'error',
                'Informe um dia v&aacute;lido.',
                'Alerta - Ayllos',
                 "$('#dtfchfol','#"+FrmConsig.attr('id')+"').focus()");
            return false;
        }
        // Interrompe cobrança
        if(!Cindinterromper.is(':checked')) {
            showError(
                'error',
                'Informe se voc&ecirc; deseja Interromper a Cobran&ccedil;a.',
                'Alerta - Ayllos',
                '');
            return false;
        }
        // Autoriza debito
        if(!Cindautrepassecc.is(':checked')) {
            showError(
                'error',
                'Informe se voc&ecirc; Autoriza d&eacute;bito repasse em c/c.',
                'Alerta - Ayllos',
                '');
            return false;
        }

    }

     $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/consig/manter_rotina.php',
        data: {
            cddopcao: cddopcao,
            cdempres: cdempres,
            indconsignado: indconsignado,
            dtativconsignado: dtativconsignado,
            nmextemp: nmextemp,
            tpmodconvenio: tpmodconvenio,
            dtfchfol: dtfchfol,
            nrdialimiterepasse: nrdialimiterepasse,
            indautrepassecc: indautrepassecc,
            indinterromper: indinterromper,
            dtinterromper: dtinterromper,
            dsdemail: dsdemail,
            indalertaemailemp: indalertaemailemp,
            dsdemailconsig: dsdemailconsig,
            indalertaemailconsig: indalertaemailconsig,
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError(
                'error',
                'Nao foi possivel concluir a operacao.',
                'Alerta - Ayllos',
                '$("#nrconven", "#frmFiltro").focus();');
        },
        success: function (response) {
            hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {
                DivConsig.html(response);
                formataTelaConsig();

            }//catch
        }//success
    });//ajax
    return false;
}

function validaPermissao(cddopcao){
	var validaPerm = true;
	$.ajax({		
		type: "POST",
        async: false,
		url: UrlSite + "telas/consig/validaPermissao.php", 
		data: {
			cddopcao: cddopcao,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				hideMsgAguardo();				
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});
	return validaPerm;
}

