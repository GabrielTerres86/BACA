/**
 * Autor: Bruno Luiz Katzjarowski - Mout's
 * Data: 27/11/2018
 * Ultima alteração: 14/05/2019
 * 
 * Alterações: 30/05/2019 - Ajuste no link do Digidoc para pegar usar o número conta e contrato 
 *                          formatados - PRJ 438 (Mateus Z / Mouts)
 *
 *             14/05/2019 - Adicionar novo rating - P450 no limite de crédito (Luiz Otávio Olinger Momm - AMCOM)
 * 
 */
$(document).ready(function(){

    hideMsgAguardo();
    blockBackground(97);
    formatarTabela();
    atribuirEventosBotoes();

    $('#btVoltar').focus();
    $('#btVoltar').blur();
});

/**
 * Formatar tabela da tela principal de limite de crédito
 */
function formatarTabela(){
    var tabela = $('#tabelaTelaPrincipal');
    var arrLargura = getLarguraTabelaPrincipal();
    var arrAlinhamento = getAlinhamentoTabelaPrincipal();
    var ordemInicial = Array();

    $(tabela).formataTabela(ordemInicial, arrLargura, arrAlinhamento, "doubleClickTabelaPrincipal();");

    $('#divRotina').css({
        'width': '950px'
    });
    $('#divConteudoOpcao').css({
        'width': '1100px'
    });
    $('.botao').css({
        'margin-top':'5px'
    });
    ajustarCentralizacao();
}

/**
 * Atribuir evento aos botoes em form_tela_principal.php
 */
function atribuirEventosBotoes(){

    /**
     * Atribuir evento ao botão Consultar Imagem
     */
    $('#btConsultarImagem').bind('click',function(e){
        e.preventDefault();
        if(aux_hasAtivo){
            window.open('http://'+aux_GEDServidor+'/smartshare/clientes/viewerexterno.aspx?tpdoc='+aux_tpdocmto+'&conta='+var_globais.nrdcontaFormatada+'&contrato='+aux_limites.ativo.nrctrlimFormatado+'&cooperativa='+aux_cdcooper, '_blank');   
            aux_operacao = 'CI';
        }else{
            showError("error",
                "Conta DEVE ter limite ATIVO.",
                "Alerta - Aimaro",
                "blockBackground(parseInt($('#divRotina').css('z-index')))");
        }
        return false;
    });

    /**
     * Atribuir Evento ao botão Renovar
     */
    $("#btRenovar").bind('click',function(e){
        e.preventDefault();
        if(aux_hasAtivo){
            acessaTela('R');
            aux_operacao = 'R';
        }else{
            showError("error",
                "Conta DEVE ter limite ATIVO.",
                "Alerta - Aimaro",
                "blockBackground(parseInt($('#divRotina').css('z-index')))");
        }
        return false;
    });

    /**
     * Atribuir evento ao botão Cancelar Limite Atual
     */
    $('#btCancelarLimite').bind('click',function(){
        if(!aux_hasAtivo){
            showError("error",
            "Conta DEVE ter limite ATIVO.",
            "Alerta - Aimaro",
            "blockBackground(parseInt($('#divRotina').css('z-index')))");
        }else{
            showConfirmacao('Deseja cancelar o ' + strTitRotinaLC + ' atual?','Confirmação - Aimaro',
            'cancelarLimiteAtual('+aux_limites.ativo.nrctrlim+')',
            "blockBackground(parseInt($('#divRotina').css('z-index')))",
            'sim.gif','nao.gif');
            aux_operacao = 'CL';
            return false;
        }
    });

    /**
     * Atribuir evento ao botão Excluir Novo Limite da tela principal
     */
    $('#btExcluirNovoLimite').bind('click',function(e){
        e.preventDefault();
        if(getHasLimiteEmEstudo()){
            showConfirmacao('Deseja excluir o novo ' + strTitRotinaLC + '?','Confirma&ccedil;&atilde;o - Aimaro',
            'excluirNovoLimite()',
            "blockBackground(parseInt($('#divRotina').css('z-index')))",
            'sim.gif','nao.gif');
            aux_operacao = 'EX';
        }else{
            showError("error",
            "Conta DEVE ter limite em ESTUDO.",
            "Alerta - Aimaro",
            "blockBackground(parseInt($('#divRotina').css('z-index')))");
        }
        return false;
    });

    /**
     * Atribuir evento ao botão Alterar da tela principal
     */
    $('#btAlterarLimite').bind('click',function(e){
        e.preventDefault();
        
        if(getHasLimiteEmEstudo()){
            mostraTelaAltera();
            aux_operacao = 'A';
        }else{
            showError("error",
                "Conta DEVE ter limite em ESTUDO.",
                "Alerta - Aimaro",
                "blockBackground(parseInt($('#divRotina').css('z-index')))");
        }
        return false;
    });

    /**
     * Atribuir evento ao botão Efetivar da tela principal
     */
    $('#btEfetivar').bind('click',function(e){
        e.preventDefault();
        if(getHasLimiteEmEstudo()){
            acessaTela('E');
            aux_operacao = 'E';
        }else{
            showError("error",
                "Conta DEVE ter limite em ESTUDO.",
                "Alerta - Aimaro",
                "blockBackground(parseInt($('#divRotina').css('z-index')))");            
        }
        return false;
    });

    /**
     * Atribuir evento ao botão Imprimir da tela principal
     */
    $('#btImprimir').bind('click',function(e){
        e.preventDefault();
        acessaTela('I');
        aux_operacao = 'IMP';
        return false;
    });

    /**
     * Atribuir evento ao botão Consultar Limite Ativo da tela principal
     */
    $('#btConsultarLimiteAtivo').bind('click',function(e){
        e.preventDefault();
        aux_opcaoAtiva = "CONSULTA_ATIVO";
        if(!aux_hasAtivo){
            showError("error",
            "Conta DEVE ter limite ATIVO.",
            "Alerta - Aimaro",
            "blockBackground(parseInt($('#divRotina').css('z-index')))");
        }else{
            acessaTela('A');
            aux_operacao = 'CA';
        }
        return false;
    });

    /**
     * Atribuir evento ao botão Consutlar Limite Proposto da tela principal
     */
    $('#btConsultarLimiteProposto').bind('click',function(e){
        e.preventDefault();
        aux_opcaoAtiva = "CONSULTA_PROPOSTO";
        if(getHasLimiteEmEstudo()){
            acessaTela('P');
            aux_operacao = 'CP';
        }else{
            showError("error",
                "Não existe limite proposto para consulta.",
                "Alerta - Aimaro",
                "blockBackground(parseInt($('#divRotina').css('z-index')))");
        }
        return false;
    });
    
    /**
     * Atribuir evento ao botão ultimas Alterações da tela principal
     */
    $('#btUltimasAlteracoes').bind('click',function(e){
        e.preventDefault();
        acessaTela('U');
        aux_operacao = 'U';
        return false;
    });

    /**
     * Atribui evento ao botão incluir da tela principal (novo limite)
     */
    $('#btIncluirNovoLimite').bind('click',function(e){
        e.preventDefault();
        if(getHasLimiteEmEstudo()){
            showError("error",
                "Conta POSSUI limite em ESTUDO.",
                "Alerta - Aimaro",
                "blockBackground(parseInt($('#divRotina').css('z-index')))");
        }else{
            acessaTela('N');
            aux_operacao = 'I';
        }
        return false;
    });

    /**
     * Atribui evento ao botão voltar da tela principal
     */
    $('#btVoltar').bind('click',function(e){
        e.preventDefault();
        encerraRotina(true);
        return false;
    });
}

/**
 * Subtituir a funcao confirmaNovoLimite
 */
function efetivarLimiteCredito(){
    
    var nrcpfcgc = $("#nrcpfcgc", "#frmCabAtenda").val().replace(".", "").replace(".", "").replace("-", "").replace("/", "");
    var nrctrrat = ""; //Já estava indo vazio
    var idcobope = var_globais.idcobope;

    var camposRS = ""; //retornaCampos(arrayRatingSingulares, '|');
    var dadosRtS = ""; //retornaValores(arrayRatingSingulares, ';', '|', camposRS);

    showMsgAguardo("Aguarde, confirmando novo " + strTitRotinaLC + " ...");
	// Executa script de confirmação através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/atenda/limite_credito/confirma_novo_limite.php", 
		data: {
			nrdconta: nrdconta,
			inconfir: 1,
			nrcpfcgc: nrcpfcgc,
			nrctrrat: nrctrrat,
			flgratok: true,
            idcobope: idcobope,
			/** Variaveis ref ao rating singulares **/
			camposRS: camposRS,
			dadosRtS: dadosRtS,
			redirect: "script_ajax"
		}, 
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
        success: function (response) {
			try {
				eval(response);
            } catch (error) {
				hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		} 				
	});	
}

/**
 * Função trigger de double click para a tabela principal
 */
function doubleClickTabelaPrincipal(){
}


/**
 * Define a largura das colunas para a tabela principal
 */
function getLarguraTabelaPrincipal(){
    return Array(
        '100px', //DTPROPOS -> Data Proposta
        '100px', //DTINIVIG -> Data Efetivação
        '100px', //NRCTRLIM -> Número do Contrato
        '100px', //VLLIMITE -> Valor do Limite de Crédito
        '100px', //CDDLINHA -> Taxa
        '100px', //DTFIMVIG -> Vigência do Contrato
        '100px', //DTRENOVA -> Data da Renovação
        '110px', //INSITLIM -> Situação
        '60px'   //Nota Rating
        //'50px'  //INSITLIM -> Situação
    );
}


/**
 * Retorna alinhamento das colunas para a tabela principal
 */
function getAlinhamentoTabelaPrincipal(){
    return Array(
        'center', //DTPROPOS -> Data Proposta
        'center', //DTINIVIG -> Data Efetivação
        'center', //NRCTRLIM -> Número do Contrato
        'right',  //VLLIMITE -> Valor do Limite de Crédito
        'center', //CDDLINHA -> Taxa
        'center', //DTFIMVIG -> Vigência do Contrato
        'center', //DTRENOVA -> Data da Renovação
        'center',  //INSITLIM -> Situação
        'center',  //pr_dsrisco_rating -> Nota Rating
        'center'   //pr_origem_rating -> Retorno (Origem Rating)
    );
}

function desabilitarBotao(bt){
    $(bt).css({
        'color': 'gray',
        'cursor': 'default', 
        'pointer-events': 'none'
    });
}

/**
 * Verifica se conta já possui cadastro de limite em estudo (1) parametro: lfgsitua
 */
function getHasLimiteEmEstudo(){
    var hasEstudo = false;

    var tabela = $('#tabelaTelaPrincipal');
    $('tr',tabela).each(function(){
        if($(this).data('lfgsitua') == "1"){
            hasEstudo = true;
        }
    });

    return hasEstudo;
}