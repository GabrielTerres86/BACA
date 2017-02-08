/*!
 * FONTE        : funcoes.js
 * CRIA��O      : David
 * DATA CRIA��O : Julho/2007
 * OBJETIVO     : Biblioteca de fun��es JavaScript
 * --------------  
 * ALTERA��ES   :
 * --------------
 * 000: [25/07/2008] Guilherme        (CECRED) : Incluir fun��es para F2
 * 000: [06/10/2008] David            (CECRED) : Novas fun��es para validar senha de coordenador
 * 000: [12/08/2009] Guilherme        (CECRED) : Incluir fun��es enterTab
 * 000: [22/10/2009] David            (CECRED) : Ajuste na fun��o showError
 * 001: [11/02/2010] Rodolpho Telmo      (DB1) : Criado componente "limpaFormulario"
 * 002: [04/03/2010] Rodolpho Telmo      (DB1) : Criada fun��o "zebradoLinhaTabela"
 * 003: [11/03/2010] Rodolpho Telmo      (DB1) : Criada fun��o "trim"
 * 004: [11/03/2010] Rodolpho Telmo      (DB1) : Criada fun��o "exibeRotina"
 * 005: [11/03/2010] Rodolpho Telmo      (DB1) : Criada fun��o "fechaRotina"
 * 006: [11/03/2010] Rodolpho Telmo      (DB1) : Criada fun��o "bloqueiaFundo"
 * 007: [11/03/2010] Rodolpho Telmo      (DB1) : Criada fun��o "setCenterPositionH"
 * 008: [26/03/2010] Gabriel Santos      (DB1) : Criada fun��o "number_format", similar � do php
 * 009: [29/03/2010] Rodolpho Telmo      (DB1) : Criada fun��o "in_array", similar � do php
 * 010: [30/03/2010] Rodolpho Telmo      (DB1) : Criada fun��o "layoutPadrao"
 * 011: [31/03/2010] Rodolpho Telmo      (DB1) : Plugin HotKeys aplicando padr�o para acesso as funcionalidades dos bot�es em tela 
 * 012: [07/04/2010] Rodolpho Telmo      (DB1) : Criada fun��o montaHtmlImpressao
 * 013: [16/04/2010] Rodolpho Telmo      (DB1) : Criado plugin jQuery limitaTexto
 * 014: [26/04/2010] Rodolpho Telmo      (DB1) : Criado fun��o "revisaoCadastral" gen�rica
 * 015: [04/05/2010] Rodolpho Telmo      (DB1) : Criado fun��o "formataTabela"
 * 016: [04/05/2010] Rodolpho Telmo      (DB1) : Criado fun��o "zebraTabela"
 * 017: [17/05/2010] Rodolpho Telmo      (DB1) : Alterada fun��o "atalhoTeclado"
 * 018: [18/05/2010] Rodolpho Telmo      (DB1) : Sele��o de registros pelo teclado
 * 019: [18/05/2010] Rodolpho Telmo      (DB1) : Permitir Drag nas mensagens de Erro e Confirma��o.
 * 020: [18/05/2010] Rodolpho Telmo      (DB1) : Criado plugin jQuery escondeMensagem
 * 021: [20/05/2010] Rodolpho Telmo      (DB1) : Criada fun��o normalizaNumero
 * 022: [21/05/2010] Rodolpho Telmo      (DB1) : Manuten��o das HotKeys sem o uso do ALT
 * 023: [21/05/2010] Rodolpho Telmo      (DB1) : HotKeys F8 para limpar campos
 * 024: [21/05/2010] Rodolpho Telmo      (DB1) : HotKeys F7 para abrir Telas de Pesquisas
 * 025: [25/05/2010] Rodolpho Telmo      (DB1) : Criada fun��o selecionaRegistro
 * 026: [17/06/2010] Rodolpho Telmo      (DB1) : Criada fun��o focaCampoErro
 * 027: [18/06/2010] Rodolpho Telmo      (DB1) : Criado nos campos cpf e cnpj 
 * 028: [18/06/2010] Rodolpho Telmo      (DB1) : Criada fun��o verificaContadorSelect
 * 029: [18/06/2010] Gabriel Santos      (DB1) : Criada fun��o implode
 * 030: [18/06/2010] Gabriel Santos      (DB1) : Criada fun��o exibirMensagens
 * 031: [26/06/2010] Rodolpho Telmo      (DB1) : Criada fun��o desbloqueia
 * 032: [29/06/2010] Rodolpho Telmo      (DB1) : Criada fun��o truncar
 * 033: [30/06/2010] Rodolpho Telmo      (DB1) : Criada fun��o verificaSemaforo
 * 034: [12/07/2010] Rodolpho Telmo      (DB1) : Criada fun��o jQuery "formataRodapePesquisa"
 * 035: [15/07/2010] Rodolpho Telmo      (DB1) : Controle de identifica��o se as teclas shift e control est�o pressionadas
 * 036: [16/07/2010] Rodolpho Telmo      (DB1) : Criada fun��o "removeOpacidade"
 * 037: [11/08/2010] Gabriel Capoia      (DB1) : Criada fun��o "mktime", similar � do php
 * 038: [11/08/2010] Gabriel Capoia      (DB1) : Criada fun��o "dataParaTimestamp"
 * 039: [24/02/2011] Jorge 		      (CECRED) : Alterada fun��o "showError"
 * 040: [18/04/2011] Rogerius e Rodolpho (DB1) : Manuten��o dos HotKeys para a rotina do Zoom Gen�rico do Endere�o
 * 041: [28/04/2011] Rogerius e Rodolpho (DB1) : Criada a fun��o "verificaTipoPessoa"
 * 042: [28/04/2011] Rogerius e Rodolpho (DB1) : Criado extens�o jQuery "addClassCpfCnpj"
 * 043: [28/04/2011] Rodolpho Telmo      (DB1) : Criado extens�o jQuery "ponteiroMouse"
 * 044: [28/04/2011] Rodolpho Telmo      (DB1) : Adicionado comportamento nas extens�es "desabilitaCampo" e "habilitaCampo"
 * 045: [14/05/2011] Rodolpho Telmo      (DB1) : Manuten��o das fun��es "desabilitaCampo" e "habilitaCampo"
 * 046: [13/06/2011] Rog�rius Milit�o    (DB1) : Criado a fun��o "converteMoedaFloat"
 * 047: [16/06/2011] Jorge   		  (CECRED) : Alterada funcao "showError"
 * 048: [19/07/2011] Rog�rius Milit�o 	 (DB1) : Criado a fun��o "mascara" 
 * 049: [03/08/2011] Rog�rius Milit�o 	 (DB1) : Manuten��o da funcao "formataTabela" 
 * 050: [19/08/2011] Rog�rius Milit�o 	 (DB1) : Manuten��o da funcao "atalhoTeclado", adicionado a opcao btsair
 * 051: [26/08/2011] Adriano		  (CECRED) : Alterado a mascara email na funcao layoutPadrao.
 * 052: [30/08/2011] Rog�rius Milit�o 	 (DB1) : Manuten��o nas setas que percorre os registros da tabela.
 * 053: [22/09/2011] Rog�rius Milit�o 	 (DB1) : Manuten��o na tecla de atalho F1, para nao abrir o HELP no IE.
 * 054: [22/11/2011] Rog�rius Milit�o	 (DB1) : Alterado o evento para a classe INPUT.PESQUISA na funcao layoutPadrao.
 * 055: [28/11/2011] David            (CECRED) : Permitir tecla backspace somente em campos INPUT e TEXTAREA, para inibir a op��o VOLTAR do browser.
 * 056: [16/12/2011] David            (CECRED) : Substituir m�todo $(elem).attr() por $(elem).prop(). Necess�rio para propriedades 'disabled', 'readonly' e 'checked'.
 * 057: [08/02/2012] Rog�rius Milit�o 	 (DB1) : Adicionada a linha normalizaNumero(conta) na fun��o validaNroConta().
 * 058: [08/02/2012] Rog�rius Milit�o 	 (DB1) : Adicionada a linha normalizaNumero(cpfCnpj) na fun��o validaCpfCnpj().
 * 059: [10/02/2012] Rog�rius Milit�o 	 (DB1) : Criado a fun��o "isHabilitado( objeto )" para verificar se o campo est� habilitado atraves das classes.
 * 060: [10/02/2012] Rog�rius Milit�o 	 (DB1) : Manuten��o "desabilitaCampo", adicionado para remover as classes que tem focu.
 * 061: [17/02/2012] Rog�rius Milit�o 	 (DB1) : Manuten��o layoutPadrao, na opcao "pesquisa", alterado "hasClass('campo')" pela funcao "isHabilitado".
 * 062: [17/02/2012] Rog�rius Milit�o 	 (DB1) : Manuten��o ponteiroMouse, alterado "hasClass('campo')" pela funcao "isHabilitado".
 * 063: [29/03/2012] Rog�rius Milit�o	 (DB1) : Manuten��o layoutPadrao, alterado selector "a" para nao pegar campos botao $('a[class!="botao"]','.formulario').attr('tabindex','-1');	
 * 064: [26/04/2012] Rog�rius Milit�o	 (DB1) : Manuten��o layoutPadrao, no input.cpf e input.cnpj foi adicionado a "$(this).removeClass('campo').addClass('campoFocusIn');" para tratar o novo focu;
 * 065: [01/06/2012] David Kistner    (CECRED) : Criada funcao CheckNavigator()
 * 066: [03/10/2012] Adriano Marchi   (CECRED) : Incluido a classe porcento_n, moeda_15 na fun��o layoutPadrao.
 * 067: [04/04/2014] Carlos           (CECRED) : Incluida a funcao validaEmail.
 * 068: [13/06/2014] Douglas          (CECRED) : Ajustado validaEmail para utilizar express�o regular. Antes n�o validava o dom�nio do email. (Chamado 122814)
 * 069: [20/06/2014] James			  (CECRED) : Incluido a funcao replaceAll
 * 070: [02/07/2014] James			  (CECRED) : Incluido a fun��o base64_decode();
 * 071: [02/07/2014] James		      (CECRED) : Incluido a fun��o base64_encode();
 * 072: [19/12/2014] Kelvin 		  (CECRED) : Adicionado nova mascara de contrato (z.zzz.zzz.zz9) e (zz.zzz.zz9)  (Chamado 233714).
 * 073: [17/03/2015] Jonata           (Rkam)   : Ajuste na rotina de pedir senha do coordenador.
 * 074: [18/03/2015] Carlos           (CECRED) : Criada a fun��o trocaClass(classAnterior,classAtual) para trocar uma class css por outra.
 * 075: [13/07/2015] Gabriel          (RKAM)   : Criada funcao controlaFocoEnter() para automatizar o foco no ENTER dos campos de determinado frame. 
 * 076: [04/09/2015] Adriano		  (CECRED) : Ajuste para corrigir o problema de formata��o do arquivo.
 * 077: [15/10/2015] Kelvin			  (CECRED) : Criada funcao removeCaracteresInvalidos() e removeAcentos()
												 para auxiliar na remo��o dos caracteres que invalidam o xml.
 * 078: [28/10/2015] Heitor           (RKAM)   : Criada funcao utf8_decode para utilizacao de acentuacao php x js
 * 079: [23/12/2015] Adriano          (CECRED) : Ajuste na rotina layoutPadrao para criar o tratamento para a classe porcento_4. 
 * 080: [23/03/2016] James            (CECRED) : Criado a classe Taxa no INPUT
 * 081: [27/06/2016] Jaison/James     (CECRED) : Criacao de glb_codigoOperadorLiberacao.
 * 082: [19/07/2016] Andrei           (RKAM)   : Ajuste na rotina layoutPadrao para incluir o tratamento para a classe porcento_6. 
 * 083: [12/07/2016] Evandro          (RKAM)   : Adicionado a fun��o atalhoTeclado condi��o para fechar telas (divMsgsAlerta e divAnotacoes) com ESC ou F4
 * 084: [18/08/2016] Evandro          (RKAM)   : Adicionado condi��o na fun��o showConfirmacao para voltar foco a classe FirstInputModal, ao fechar janela
 * 080: [18/10/2016] Kelvin			  (CECRED) : Funcao removeCaracteresInvalidos nao estava removendo os caracteres ">" e "<", ajustado 
												 para remover os mesmos e criado uma flag para identificar se deve remover os acentos ou nao.
 * 081: [08/02/2017] Kelvin		      (CECRED) : Adicionado na funcao removeCaracteresInvalidos os caracteres ("�","�","�") para ajustar o chamado 562089.
												 
 */ 	 

var UrlSite     = parent.window.location.href.substr(0,parent.window.location.href.lastIndexOf("/") + 1); // Url do site
var UrlImagens	= UrlSite + "imagens/"; // Url para imagens     
var nmrotina    = ''; // Para armazenar o nome da rotina no uso da Ajuda (F2)
var semaforo	= 0;  // Sem�foro para n�o permitir chamar a fun��o controlaOperacao uma atr�s da outra

var divRotina; 	// Vari�vel que representa a Rotina com a qual est� se trabalhando
var divError;  	// Vari�vel que representa a div de Erros do sistema, usada para mensagens de Erros e Confirma��es
var divConfirm;	// Vari�vel que representa a div de Erros do sistema, usada para mensagens de Erros e Confirma��es

var exibeAlerta = true;		// Vari�vel l�gica (boolean) glogal que libera a fun��o "alerta()" chamar os alert() do javascript
var shift = false; 	// Vari�vel l�gica (boolean) glogal que indica se a tecla shift est� prescionada
var control = false; 	// Vari�vel l�gica (boolean) glogal que indica se a tecla control est� prescionada

var glb_codigoOperadorLiberacao = 0; // Global com operador de liberacao
	
$(document).ready(function () {

	// 053
	document.onhelp = new Function("return false"); // Previne a abertura do help no IE
	window.onhelp 	= new Function("return false"); // Previne a abertura do help no IE

	$("body").append('<div id="divAguardo"></div><div id="divError"></div><div id="divConfirm"></div><div id="divBloqueio"></div><div id="divF2"></div><div id="divUsoGenerico"></div><iframe src="' + UrlSite + 'blank.php" id="iframeBloqueio"></iframe>');
	
	// Inicializo a vari�vel divRotiva e divError com o respectivo seletor jQuery da div
	// A qualquer momento pode-se alterar o valor da divRotina com a Rotina que est� sendo implementada
	// O valor do divError n�o tem motivos para ser alterado
	divRotina 	= $('#divRotina');
	divError  	= $('#divError');	
	divConfirm  = $('#divConfirm');	
	
	// Iniciliza tirando os eventos para posteriormente bind�-los corretamente
	$(this).unbind('keyup').unbind('keydown').unbind('keypress');	
	
	$(this).unbind("keydown.backspace").bind("keydown.backspace",function(e) {
		if (getKeyValue(e) == 8) { // Tecla BACKSPACE
			var targetType = e.target.tagName.toUpperCase();			
			// Permite a tecla BACKSPACE somente em campos INPUT e TEXTAREA e se estiverem habilitados para digita��o			
			if ((targetType == "INPUT" || targetType == "TEXTAREA") && !e.target.disabled && !e.target.readonly) return true;							
			return false; 
		}		
		return true;
	});
	
	$.ajaxSetup({ data: { sidlogin: $("#sidlogin","#frmMenu").val() } });
	
	/*!
	 * ALTERA��O     : 022
	 * OBJETIVO      : Prevenir o comportamento padr�o do browser em rela��o as teclas F1 a F12, para posteriormente utilizar estas teclas para fins espec�ficos 
	 * FUNCIONAMENTO : Captura o evento da tecla pressionada e associa � fun��o previneTeclasEspeciais funcionando para IE, Chrome e FF
	 */	
	$(this).keydown( previneTeclasEspeciais );
	function previneTeclasEspeciais(event){		
		// Essecial para funcionar no IE 
		var e = (window.event) ? window.event : event;
		// Verifica se a tecla pressionada � F1 a F12 retirando a F5
		if ( ( e.keyCode >= 112 ) && ( e.keyCode <= 123 ) && ( e.keyCode != 116 ) ) { 
			if ( $.browser.msie ) {
				e.returnValue	= false; // Previne o comportamento padr�o no IE
				e.cancelBubble 	= true;  // Previne o comportamento padr�o no IE
				e.keyCode       = 0;     // Previne o comportamento padr�o no IE
				document.onhelp = new Function("return false"); // Previne a abertura do help no IE
				window.onhelp 	= new Function("return false"); // Previne a abertura do help no IE
			} else {
				e.stopPropagation(); // Previne o comportamento padr�o nos browsers bons
				e.preventDefault();  // Previne o comportamento padr�o nos browsers bons
			}
		}
	}
	
	/*!
	 * ALTERA��O     : 035
	 * OBJETIVO      : Controle de identifica��o se as teclas shift e control est�o pressionadas
	 * FUNCIONAMENTO : Ao pressionar qualquer tecla, o sistema verifica se � a shift/control, caso verdadeiro seta a vari�vel global 
	 *                 correspondente para TRUE. Ao liberar a tecla, o sistema verifica novamente se � shift/control, caso afirmativo
	 *                 volta os valores das vari�veiss globais correspondentes para FALSE.
	 */		
	$(this).keydown( function(e) {
		if (e.which == 16 ) { shift 	= true; } // Tecla Shift		
		if (e.which == 17 ) { control 	= true; } // Tecla Control
	}).keyup( function(e) {
		if (e.which == 16 ) { shift 	= false; } // Tecla Shift		
		if (e.which == 17 ) { control 	= false; } // Tecla Control
	});
	
	/*!
	 * ALTERA��O  : 018 e 051
	 * OBJETIVO   : Teclas de atalho para selecinar os registro nas tabelas pelo teclado, utilizando as setas direcionais "para cima" e "para baixo"
	 * OBSERVA��O : As tabelas devem estar criadas dentro do padr�o adotado nas rotinas no m�dulo de CONTAS
	 */	
	$(this).keyup( function(e) { 			
		var tecla = e.which;	
		if ( (tecla == 38) || (tecla == 40) ) {
			
			var nrLinhaSelecao;	
			var divRegistro;	
			var divRegistros;	
			
			if ( divError.css('display') == 'block' || divConfirm.css('display') == 'block' ){
				return true;
			}else if ( $('#divUsoGenerico').css('visibility') == 'visible' ){
				divRegistros = $('div.divRegistros','#divUsoGenerico');
			}else if( $('#divRotina').css('visibility') == 'visible' && $('div.divRegistros','#divRotina').length ){
				divRegistros = $('div.divRegistros','#divRotina');
			}else if( $('#divMatric').css('visibility') == 'visible' || $('#divMatric').css('visibility') == 'inherit' ){
				divRegistros = $('div.divRegistros','#divMatric');
			}else {
				if ( $('#divRotina').css('visibility') == 'visible') return false;
				divRegistros = $('div.divRegistros');
			}		
				
			divRegistros.each( function() {
				if ( $(this).css('display') == 'block' ) {
					divRegistro = $(this);
				}				
			});			
			
			var tabela = $('table', divRegistro);
			
			var qtdeRegistros = $('table > tbody > tr', divRegistro).length;
			// Se possui um ou nenhum registro, n�o fazer nada
			if ( qtdeRegistros > 1 ) { 
				// Descobre qual linha est� selecionada
				$('table > tbody > tr', divRegistro).each( function(i) {
					if ( $(this).hasClass( 'corSelecao' ) ) {
						nrLinhaSelecao = i;
					}					
				});	
				// Se teclou seta para cima e n�o � a primeira linha, selecionar registro acima
                if ((tecla == 38) && (nrLinhaSelecao > 0)) {
                    $('table', divRegistro).zebraTabela(nrLinhaSelecao - 1);
                    $('tbody > tr:eq(' + (nrLinhaSelecao - 1) + ') > td', tabela).first().focus();
				}
				// Se teclou seta para baixo e n�o � a ultima linha, selecionar registro abaixo
                if ((tecla == 40) && (nrLinhaSelecao < qtdeRegistros - 1)) {
                    $('table', divRegistro).zebraTabela(nrLinhaSelecao + 1);
                    $('tbody > tr:eq(' + (nrLinhaSelecao + 1) + ') > td', tabela).first().focus();
				}			
			}
		}
	});				
	
	/*!
	 * ALTERA��O  : 011
	 * OBJETIVO   : Teclas de atalho (HotKeys) para os bot�es da tela corrente (em exibi��o)
	 * Padr�o     : (   F1   ) -> Bot�o Salvar (Concluir)
	 *              (   F2   ) -> Ajuda da CECRED
	 *              (   F3   ) -> Bot�o Inserir
	 *              (   F4   ) -> Bot�o Voltar (ESC)
	 *              (   F5   ) -> Atualizar p�gina ( n�o presica implementar, pois � padr�o do Browser )
	 *              (   F7   ) -> Abre Pesquisa ( Implementa��o na fun��o layoutrPadrao() )
	 *              (   F8   ) -> Limpar Campo  ( Implementa��o na fun��o layoutrPadrao() )
	 *              (   F9   ) -> Bot�o Alterar
	 *              (   F10  ) -> Bot�o Consultar
	 *              (   F11  ) -> Bot�o Limpar
	 *              ( DELETE ) -> Bot�o Excluir
	 *              (   ESC  ) -> Bot�o Voltar
	 *              ( INSERT ) -> Bot�o Inserir	 
	 * OBSERVA��O : Para que os atalhos funcionem, os bot�es em tela devem estar com a propriedade "id" igual a um dos valores abaixo:
	 *              btIncluir | btExcluir | btVoltar | btAlterar | btSalvar | btConsultar | btLimpar
	 */	 
    $(this).keyup(atalhoTeclado);
	function atalhoTeclado(e) {

        var arrayTeclas = new Array();
        arrayTeclas[13] = 'btEnter';		// ENTER		
        arrayTeclas[45] = 'btIncluir';		// INSERT
        arrayTeclas[46] = 'btExcluir';		// DELETE
        arrayTeclas[27] = 'btVoltar';		// ESC - VOLTAR
		arrayTeclas[112] = 'btSalvar';		// F1  - SALVAR
		arrayTeclas[114] = 'btIncluir';		// F3  - INSERIR
		arrayTeclas[115] = 'btVoltar';		// F4  - VOLTAR	
		arrayTeclas[120] = 'btAlterar';		// F9  - ALTERAR
		arrayTeclas[121] = 'btConsultar';   // F10 - CONSULTAR		
		arrayTeclas[122] = 'btLimpar';      // F11 - LIMPAR
		
		// Se o divAguardo estiver sendo exibido, ent�o n�o aceitar atalhos do teclado
        if ($('#divAguardo').css('display') == 'block') { return true; }

		/*!
		 * ALTERA��O : 017
		 * OBJETIVO  : Quando o divError estiver vis�vel na tela, e a tecla � ESC (27) ou F4 for pressionada, ent�o chamar o clique do bot�o "N�o" do divError,
		 *             pois caso contr�rio a fun��o chama o clique o bot�o com o ID = 'btVoltar'
		 */
        if (divError.css('display') == 'block') {
			// Se teclar ENTER (13)	
			if (e.which == 13) {
				// $('#btnError','#divError').click();
			}			
			return true;				

        } else if (divConfirm.css('display') == 'block') {
			// Se teclar ESC (27) ou F4 (115)
            if ((e.which == 27) || (e.which == 115)) {
                $('#btnNoConfirm', '#divConfirm').click();
			}
			return true;
			
		// Se for tecla F2, abre ajuda padr�o		
        } else if (e.keyCode == 113) {
			mostraAjudaF2();
			return true;			
			

		// Se for as teclas ENTER | INSERT | DELET | ESC | F1 | F3 | F4 | F9 | F10 | F11
        } else if (in_array(e.keyCode, [13, 35, 45, 46, 27, 112, 114, 115, 120, 121, 122])) {
			
            if (typeof e.result == 'undefined') {
			
				// Se a pesquisa estiver aberta, e a tecla � ESC (27) ou F4, ent�o ativar o bot�o fechar da pesquisa				
				// ALTERA��O 040
                if ($('#divFormularioEndereco').css('visibility') == 'visible') {
                    if (e.which == 27 || e.which == 115) {
                        $('.fecharPesquisa', '#divFormularioEndereco').click();
					} else {
                        $('#' + arrayTeclas[e.which] + ':visible', '#divFormularioEndereco').click();
					}					
					return true;
				
				// ALTERA��O 040
                } else if ($('#divPesquisaEndereco').css('visibility') == 'visible') {
                    if (e.which == 27 || e.which == 115) {
                        $('.fecharPesquisa', '#divPesquisaEndereco').click();
					} else {
                        $('#' + arrayTeclas[e.which] + ':visible', '#divPesquisaEndereco').click();
					}					
					return true;				
					
                } else if ($('#divPesquisaAssociado').css('visibility') == 'visible') {
                    if (e.which == 27 || e.which == 115) {
                        $('.fecharPesquisa', '#divPesquisaAssociado').click();
					} 
					return true;						
					
                } else if ($('#divMsgsAlerta').css('visibility') == 'visible') {
                    if (e.which == 27 || e.which == 115) {
                        encerraMsgsAlerta().click();
					} 
					return true;														
				
                } else if ($('#divAnotacoes').css('visibility') == 'visible') {
                    if (e.which == 27 || e.which == 115) {
                        encerraAnotacoes().click();
                    }
                    return true;

                } else if ($('#divPesquisa').css('visibility') == 'visible') {
                    if (e.which == 27 || e.which == 115) {
                        $('.fecharPesquisa', '#divPesquisa').click();
                    }
                    return true;

				// Verifica HotKeys v�lidos					
                } else if (in_array(e.which, [13, 35, 45, 46, 27, 112, 114, 115, 120, 121, 122])) {
					
					// Se a divUsoGenerico estiver visivel, ent�o chamar os click os bot�es contidos nela
                    if ($('#divUsoGenerico').css('visibility') == 'visible') {
                        $('#' + arrayTeclas[e.which] + ':visible', '#divUsoGenerico').click();
						return true; 
					
					// Se a divRotina estiver visivel, ent�o chamar os click os bot�es contidos nela
					// 050 - adicionado a opcao btsair
                    } else if ($('#divRotina').css('visibility') == 'visible') {
                        if ($('#divRotina').find('#' + arrayTeclas[e.which]).length) {
                            $('#' + arrayTeclas[e.which] + ':visible', '#divRotina').click();
                        } else if ($('#divRotina').find('#btSair').length && e.which == 27) {
                            $('#btSair:visible', '#divRotina').click();
						}
						return true; 	
					
					// Se � a tela do Matric, chamar os click dos bot�es contidos nela
                    } else if ($('#divMsgsAlerta').css('visibility') == 'visible') {
                        $('#' + arrayTeclas[e.which] + ':visible', '#divMsgsAlerta').click();
						return true; 
					
					// Se � a tela do Matric, chamar os click dos bot�es contidos nela
                    } else if ($('#divAnota').css('visibility') == 'visible' || $('#divAnota').css('visibility') == 'inherit') {
                        $('#' + arrayTeclas[e.which] + ':visible', '#divAnota').click();
						return true;

					// Se a divRotina estiver visivel, ent�o chamar os click os bot�es contidos nela
                    } else if ($('#divTela').css('visibility') == 'visible' || $('#divTela').css('visibility') == 'inherit') {
                        $('#' + arrayTeclas[e.which] + ':visible', '#divTela').click();
						return true; 						
					
					// Se � a tela do Matric, chamar os click dos bot�es contidos nela
                    } else if ($('#divMatric').css('visibility') == 'visible' || $('#divMatric').css('visibility') == 'inherit') {
						
						//Se � pessoa juridica verifico se � um evento do bot�o de procuradores
                        if ($('#frmJuridico', '#divMatric').css('visibility') == 'visible' || $('#frmJuridico', '#divMatric').css('visibility') == 'inherit') {
							
                            var metodo = $('#' + arrayTeclas[e.which] + 'Proc:visible', '#divMatric').attr('onClick');
                            metodo = (typeof metodo == 'undefined') ? '' : metodo.toString();
							
                            if ($.browser.msie) {
                                metodo = metodo.replace('return false;', '');
                                metodo = metodo.replace('function anonymous()', '');
                                metodo = metodo.replace('{', '');
                                metodo = metodo.replace('}', '');
                            } else {
                                metodo = metodo.replace('return false;', '');
							}	
												
                            eval(metodo);
						}
                        $('#' + arrayTeclas[e.which] + ':visible', '#divMatric').click();
						return true; 
					}						
					return true; 				
				}
			}
		}
	}
	
	/*!
	 * ALTERA��O  : 019 | 040
	 * OBJETIVO   : Tornar as mensagens padr�o de Erro ou Confirma��o "Moviment�veis", permitindo arrastar a janela para qualquer dire��o, com o objetivo
	 *              de desobstruindo os dados que se encontram logo abaixo da caixa de mensagem. Funcionalidade replicada as telas de rotinas.
	 */	 
	var elementosDrag = $('#divRotina, #divError, #divConfirm, #divPesquisa, #divPesquisaEndereco, #divFormularioEndereco, #divPesquisaAssociado, #divUsoGenerico, #divMsgsAlerta');
	elementosDrag.unbind('dragstart');	
    elementosDrag.bind('dragstart', function (event) {
		return $(event.target).is('.ponteiroDrag');
	}).bind('drag', function (event) {
        $(this).css({ top: event.offsetY, left: event.offsetX });
    });  	
	
});


function highlightObjFocus(parentElement) {			
	// Verificar se o elemento pai � um objeto v�lido
	if ($.type(parentElement) != 'object' || parentElement.size() == 0) return false;
	
	// Faz pre-sele��o dos sub-elementos 
    var subElements = $('input', parentElement);
	
	// Verificar se o elemento pai tem sub-elementos	
	if (subElements.size() == 0) return true;
	
	var validTypes = new Array();
	validTypes[1] = 'textarea';
	validTypes[2] = 'text';
	validTypes[3] = 'image';
	validTypes[4] = 'password';
	validTypes[5] = 'radio';
	validTypes[6] = 'checkbox';
	validTypes[7] = 'select';
	
    $('input,textarea', parentElement).each(function () {
		var typeElement = $(this).attr('type') != undefined ? $(this).attr('type') : $(this).get(0).tagName.toLowerCase();
		
        if (in_array(typeElement, validTypes)) {
			$(this).unbind('focusout.highlightfocus')
			       .unbind('focusin.highlightfocus')
				   .bind('focusout.highlightfocus', function () {
						if (typeElement == 'image') {
							if ($(this).attr('src') == UrlImagens + 'botoes/entrar_focus.gif')
				               $(this).attr('src', $(this).attr('src').replace('_focus.gif', '.gif'));
						} else {
				           $(this).removeClass(function () {
										if (typeElement == 'text' || typeElement == 'password' || typeElement == 'select') {
											return 'campoFocusIn';											
										} else {
											return typeElement + 'FocusIn';
										}
								    })
                                  .addClass(function () {
										if (typeElement == 'text' || typeElement == 'password' || typeElement == 'select') {
											return 'campo';
										} else {											
											return typeElement;
										}
									})
						}
				    })
				   .bind('focusin.highlightfocus', function () {
						if (typeElement == 'image') {							
							if ($(this).attr('src') == UrlImagens + "botoes/entrar.gif")
				               $(this).attr('src', $(this).attr('src').replace('.gif', '_focus.gif'));
						} else {																	
				           $(this).removeClass(function () {
										if (typeElement == 'text' || typeElement == 'password' || typeElement == 'select') {
											return 'campo';
										} else {											
											return typeElement;
										}
									})
								   .addClass(function () {
										if (typeElement == 'text' || typeElement == 'password' || typeElement == 'select') {
											return 'campoFocusIn';
										} else {											
											return typeElement + 'FocusIn';
										}
								    });
						}
				    });
					
		}
	});
	
	return true;	
}

/*!
 * OBJETIVO: Fun��o para chamar a ajuda do sistema
 */
function mostraAjudaF2() {
	showMsgAguardo("Aguarde carregando dados de ajuda ...");			
	$.ajax({		
		type: "POST", 
		dataType: "html",
		url: UrlSite + "f2/busca_help.php",
		data: {
			redirect: "html_ajax"
		},		
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "");
		},
        success: function (response) {
			$("#divF2").html(response);
			// Centraliza o div na Tela
			$("#divF2").setCenterPosition();
		}				
	}); 	
}

/*!
 * OBJETIVO: Fun��o para bloquear conte�do atr�s de um div
 */
function blockBackground(zIndex) {
	$("#iframeBloqueio").css({
		width: "100%",
		height: $(document).height() + "px",
		zIndex: zIndex - 2,
		display: "block"
	}); 	
	// Propriedados do div utilizado no bloqueio
	$("#divBloqueio").css({
		width: "100%",
		height: $(document).height() + "px",
		zIndex: zIndex - 1,
		display: "block"
	}); 
}

/*!
 * OBJETIVO: Fun��o para desbloquear conte�do atr�s de um div
 */
function unblockBackground() {
	// Propriedades do div utilizado no bloqueio
	$("#divBloqueio").css({
		width: "1px",
		height: "1px",
		top: "0",
		left: "0",
		display: "none"
	});	
	$("#iframeBloqueio").css({
		width: "1px",
		height: "1px",
		top: "0",
		left: "0",
		display: "none"
	});
}

/*!
 * OBJETIVO  : Fun��o para mostrar mensagem de erro ou notifica��o
 * ALTERA��O : 019 - Para permitir Movimentar a mensagem de Error, alterou-se a forma de centraliza��o da mensagem
 * ALTERA��O : 039 - Condi��o do tipoMsg, caso venha com 'none' n�o mostrar� �cone.
 * ALTERA��O : 047 - Parametro numWidth opcional, largura da tabela de mensagem, caso nao seja passado, pega 300 como padrao.
 */	 
function showError(tipoMsg, msgError, titMsg, metodoMsg, numWidth) {
	
	// Construindo conte�do da mensagem
	var strHTML = '';
	var display = '';	
	
    if (tipoMsg == 'none')
		display = 'display:none;';
	
	larg = Number(numWidth);	
	
	if (isNaN(larg)) {		
		larg = 300; // largura padrao
	}
		
	strHTML += '<table border="0" cellpadding="0" cellspacing="0" width="' + larg + '" id="tabMsgError">';
	strHTML += '	<tr>';
	strHTML += '		<td id="tdTitError" class="ponteiroDrag">' + titMsg + '</td>';
	strHTML += '	</tr>';
	strHTML += '	<tr>';
	strHTML += '		<td height="5"></td>';
	strHTML += '	</tr>';	
	strHTML += '	<tr>';
	strHTML += '		<td style="padding: 4px 6px 4px 6px;">';	
	strHTML += '			<table border="0" cellpadding="0" cellspacing="0">';
	strHTML += '				<tr>';
	strHTML += '					<td valign="top" style="padding-right: 5px;' + display + '"><img src="' + UrlImagens + (tipoMsg == "inform" ? "geral/ico_inform.jpg" : "geral/ico_atencao.jpg") + '"></td>';
	strHTML += '					<td class="' + (tipoMsg == "inform" ? "txtCarregando" : "txtCritica") + '" nowrap><center>' + msgError + '</center></td>';
	strHTML += '				</tr>';
	strHTML += '			</table>';
	strHTML += '		</td>';
	strHTML += '	</tr>';
	strHTML += '	<tr>';
	strHTML += '		<td height="5"></td>';
	strHTML += '	</tr>';		
	strHTML += '	<tr>';
	strHTML += '		<td align="center" style="padding-bottom: 8px;"><input type="image" id="btnError" name="btnError" src="' + UrlImagens + (tipoMsg == "inform" ? "botoes/fechar.gif" : "botoes/continuar.gif") + '"></td>';
	strHTML += '	</tr>';
	strHTML += '</table>';		
	
	// Atribui o conte�do ao div da mensagem
	divError.html(strHTML);
	
	// Bloqueia o Fundo e Mostra a mensagem
    bloqueiaFundo(divError);
    divError.css('display', 'block').setCenterPosition();
	$('#btnError').focus();

	// Aplica m�todos ao evento "click" do bot�o de confirma��o
    $('#btnError').unbind('click').bind('click', function () {
		// Esconde mensagem
		divError.escondeMensagem();
		// M�todo passado por par�metro		
        if (metodoMsg != '') { eval(metodoMsg); }
		return false;
	});	
	
	return false;
}

/*!
 * OBJETIVO  : Fun��o para mostrar mensagem para confirma��o e a��es
 * ALTERA��O : 019 - Para permitir Movimentar a mensagem de Confirma��o, alterou-se esta fun��o
 */	 
function showConfirmacao(msgConfirm, titConfirm, metodoYes, metodoNo, nomeBtnYes, nomeBtnNo) {
	
	// Construindo o conte�do da mensagem
	var strHTML = "";	
	strHTML += '<table border="0" cellpadding="0" cellspacing="0" width="300">';
	strHTML += '	<tr>';
	strHTML += '		<td id="tdTitError" class="ponteiroDrag">' + titConfirm + '</td>';
	strHTML += '	</tr>';
	strHTML += '	<tr>';
	strHTML += '		<td style="padding-top: 4px; padding-right: 6px; padding-left: 6px;">';	
	strHTML += '			<table border="0" cellpadding="0" cellspacing="0">';
	strHTML += '				<tr>';
	strHTML += '					<td style="padding-right: 5px;"><img src="' + UrlImagens + 'geral/ico_interrogacao.jpg' + '"></td>';
	strHTML += '					<td class="txtCarregando" nowrap>' + msgConfirm + '</td>';
	strHTML += '				</tr>';
	strHTML += '			</table>';
	strHTML += '		</td>';
	strHTML += '	</tr>';
	strHTML += '	<tr>';
	strHTML += '		<td align="center" style="padding-bottom: 8px; padding-top: 6px;">';
	strHTML += '			<table border="0" cellpadding="0" cellspacing="0">';
	strHTML += '				<tr>';
	strHTML += '					<td><input type="image" id="btnYesConfirm" name="btnYesConfirm" src="' + UrlImagens + "botoes/" + nomeBtnYes + '"></td>';
	strHTML += '					<td width="25"></td>';		
	strHTML += '					<td><input type="image" id="btnNoConfirm" name="btnNoConfirm" src="' + UrlImagens + "botoes/" + nomeBtnNo + '"></td>';	
	strHTML += '				</tr>';
	strHTML += '			</table>';
	strHTML += '		</td>';
	strHTML += '	</tr>';
	strHTML += '</table>';	
	
	// Atribui o conte�do ao divConfirm
	divConfirm.html(strHTML);
	
	// Aplica m�todos ao evento "click" do bot�o de confirma��o
	$("#btnYesConfirm").unbind("click");
    $("#btnYesConfirm").bind("click", function () {
		// Esconde mensagem
		divConfirm.escondeMensagem();
		// M�todo passado por par�metro
		if (metodoYes != "") { 
			eval(metodoYes); 

            if ($(".FirstInputModal")) { $(".FirstInputModal").focus(); }
		}		
		return false;
	});
	
	// Aplica m�todo ao evento "click" do bot�o de cancelamento
	$("#btnNoConfirm").unbind("click");
    $("#btnNoConfirm").bind("click", function () {
		// Esconde mensagem
		divConfirm.escondeMensagem();
		// M�todo passado por par�metro

        if (metodoNo != "") {
            eval(metodoNo);
            if ($(".FirstInputModal")) { $(".FirstInputModal").focus(); }
        }
		return false;
	});
        
	// Bloqueia o Fundo e Mostra a mensagem
    bloqueiaFundo(divConfirm);
    divConfirm.css('display', 'block').setCenterPosition();
	$("#btnYesConfirm").focus(); 
}

/*!
 * OBJETIVO  : Fun��o para mostrar mensagem de Aguardo
 * ALTERA��O : 019 - Para permitir Movimentar a mensagem de Aguardo, alterou-se esta fun��o
 */	 
function showMsgAguardo(msgAguardo) {	
	// Mensagem de espera
	var strHTML = "";
	strHTML += '<table border="0" cellpadding="0" cellspacing="0">';
	strHTML += '  <tr>';
	strHTML += '    <td><img src="' + UrlImagens + 'geral/indicator.gif" width="15" height="15"></td>';
	strHTML += '    <td nowrap><strong class="txtCarregando">&nbsp;&nbsp;&nbsp;' + msgAguardo + '</strong></td>';
	strHTML += '  </tr>';
	strHTML += '</table>';		

	// Atribui conte&uacute;do ao div da mensagem
	$('#divAguardo').html(strHTML);
	
	// Bloqueia o Fundo e Mostra a mensagem
    bloqueiaFundo($('#divAguardo'));
    $('#divAguardo').css('display', 'block').setCenterPosition();
}

/*!
 * OBJETIVO  : Fun��o para esconder (ocultar) a mensagem de aguardo
 * ALTERA��O : 019 - Alterou-se a fun��o utilizando-se do novo m�todo criado "escondeMensagem()", implementado neste arquivo
 */	
function hideMsgAguardo() {
    $("#divAguardo").escondeMensagem();
}	

/*!
 * OBJETIVO  : Retirar caracteres indesejados
 * PAR�METROS: flgRetirar -> Se TRUE retira caracteres que n�o est�o na vari�vel "valid"
 *                           Se FALSE retira caracteres que est�o na vari�vel "valid"    
 */	
function retiraCaracteres(str, valid, flgRetirar) {
	
	var result = "";	// vari�vel que armazena os caracteres v&aacute;lidos
    var temp = "";	// vari�vel para armazenar caracter da string
	
	for (var i = 0; i < str.length; i++) {
        temp = str.substr(i, 1);
			
		// Se for um n&uacute;mero concatena na string result
		if ((valid.indexOf(temp) != "-1" && flgRetirar) || (valid.indexOf(temp) == "-1" && !flgRetirar)) {
			result += temp;
		}
	}
	
	return result;		
}

/*!
 * OBJETIVO  : Fun��o para validar o n�mero da conta/dv
 * PAR�METRO : conta [Obrigat�rio] -> N�mero da conta que deseja-se validar. Aceita somente n�meros
 */	
function validaNroConta(conta) {

	// 057
	conta = normalizaNumero(conta);
	
	if (parseInt(conta) == 0) {
		return false;
	}
	
	if (conta != "" && conta.length < 9) {
        var mult = 2;
        var soma = 0;
        var tam = conta.length;
		var str_aux = 0;
		
		for (var i = tam - 2; i >= 0; i--) {
            str_aux = parseInt(conta.substr(i, 1));
			soma = soma + (str_aux * mult);
			mult++;
		}

		var div = soma % 11;

		if (div > 1) {
			div = 11 - div;
        } else {
			div = 0;
		}

        if (div == conta.substr((tam - 1), 1)) {
			return true;
		}
	}
	
	return false;
}

/*!
 * OBJETIVO  : Fun��o para retirar zeros at� encontrar outro n�mero maior
 * PAR�METRO : numero [Obrigat�rio] -> N�mero a ser retirado os zeros a esquerda
 */	
function retirarZeros(numero) {
	var flgMaior = false; // Flag para verificar se foi encontrado o primeiro n&uacute;mero maior que zero
    var result = "";    // Armazena conteudo de retorno
    var temp = "";    // Armazena caracter temporario do numero
	
	// Efetua leitura de todos os caracteres do numero e atribui a vari&aacute;vel temp
	for (var i = 0; i < numero.length; i++) {
        temp = numero.substr(i, 1);
		
        if ((temp == '0') && (numero.substr(i + 1, 1) != ',')) {
			if (flgMaior) { // Se j� foi encontrado um n�mero maior que zero
				result += temp;
			}
		} else if (!isNaN(temp)) { // Se for um n�mero maior que zero
			result += temp;
			
			if (!flgMaior) {
				flgMaior = true; 
			}
		} else if (flgMaior) { // Se n�o for um n�mero
			result += temp;
		}
	}
	
	return result;
}

/*!
 * OBJETIVO  : Fun��o para retornar c�digo da tecla pressionada
 */	
function getKeyValue(e) {
	// charCode para Firefox e keyCode para IE
	var keyValue = e.charCode ? e.charCode : e.keyCode ? e.keyCode : 0;	
	return keyValue;
}

/*!
 * OBJETIVO : Fun��o para validar se � uma data v�lida
 */	
function validaData(data) {
	// Se string n&atilde;o conter 10 caracteres
	if (data.length != 10) {
		return false;
	}
	
    var dia = parseInt(data.substr(0, 2), 10);
    var mes = parseInt(data.substr(3, 2), 10);
	var ano = parseInt(data.substr(6));

	if (isNaN(dia) || isNaN(mes) || isNaN(ano) || String(ano).length != 4) {
		return false;
	}

	// Valida n&uacute;mero do m&ecirc;s
	if (mes < 1 || mes > 12) {
		return false;
	}

	// Valida se m&ecirc;s X possui 31 dias
	if ((mes == 1 || mes == 3 || mes == 5 || mes == 7 || mes == 8 || mes == 10 || mes == 12) && (dia < 1 || dia > 31)) {
		return false;
	}

	// Valida se m&ecirc;s X possui 30 dias
	if ((mes == 4 || mes == 6 || mes == 9 || mes == 11) && (dia < 1 || dia > 30)) {
		return false;
	}

	// Valida n&uacute;mero de dias para o m&ecirc;s de Fevereiro
	if (mes == 2) {
		if (dia < 1) {
			return false;
		}

		var bissexto = false;
		
		// Calcula para verificar se &eacute; ano bissexto
		if (ano % 100 == 0) {
			if (ano % 400 == 0) { 
				bissexto = true;
			}
        } else {
			if ((ano % 4) == 0) { 
				bissexto = true;
			}
		}		

		if (bissexto) { // Se for ano bissexto
			if (dia > 29) {
				return false;
			} 
        } else { // Se n&atilde;o for ano bissexto
			if (dia > 28) {
				return false;
			}
		}
	}
	
	return true;
}

/*!
 * OBJETIVO  : Fun��o para validar n�meros inteiros e decimais
 */	
function validaNumero(numero, validaFaixa, minimo, maximo) {
	// Retirar "." e "," do numero	
    numero = numero.replace(/\./g, "").replace(/,/g, ".");
	
	// Verifica se &eacute; um n&uacute;mero inteiro ou decimal
	numero = numero.search(".") == "-1" ? parseInt(numero) : parseFloat(numero); 
	
	// Se n&atilde;o for um n&uacute;mero v&aacute;lido
	if (isNaN(numero)) {
		return false;
	}
	
	// Se par&acirc;metro for true, verifica se n&uacute;mero est&aacute; dentro de uma faixa v&aacute;lida
	if (validaFaixa) {
		if (minimo == maximo) {
			if (numero >= minimo && numero <= maximo) {
				return false;
			}
		} else {
			if (numero < minimo || numero > maximo) {
				return false;
			}
		}
	}
	
	return true;
}

/*!
 * OBJETIVO   : Fun��o para validar CPF ou CNPJ
 * PAR�METROS : cpfcnpf [String ] -> [Obrigat�rio] n�mero do CPF ou CNPJ a ser validado
 *              tipo    [Integer] -> [Obrigat�rio] Tipos v�lidos: (1) para CPF e (2) para CNPJ
 */	
function validaCpfCnpj(cpfcnpj, tipo) {

	// 058
	cpfcnpj = normalizaNumero(cpfcnpj);
	
	var strCPFCNPJ = new String(parseFloat(cpfcnpj));

	if (tipo == 1) { //CPF
		var invalid = "";
        var peso = 9;
		var calculo = 0;
        var resto = 0;

		if (strCPFCNPJ.length < 5) {
			return false;
		}
		
		for (var i = 1; i < 10; i++) {
			for (var j = 0; j < 11; j++) {
				invalid += i;
			}

			if (strCPFCNPJ == invalid) {
				return false;
			}
			
			invalid = "";
		}
		
		for (i = strCPFCNPJ.length - 3; i >= 0; i--) {
            calculo = parseInt(calculo) + parseInt(strCPFCNPJ.substr(i, 1)) * peso;
			 peso--;
		}
		
		resto = parseInt(calculo) % 11;
		
		if (resto == 10) {
			digito = 0;
		} else {
			digito = resto;
		}

        peso = 8;
		calculo = digito * 9;
		
		for (i = strCPFCNPJ.length - 3; i >= 0; i--) {
            calculo = parseInt(calculo) + parseInt(strCPFCNPJ.substr(i, 1)) * peso;
			 peso--;
		}		
		
		resto = parseInt(calculo) % 11;
		
		if (resto == 10) {
			digito = digito * 10;
		} else {
			digito = (digito * 10) + resto;
		}
		
        if (strCPFCNPJ.substr(strCPFCNPJ.length - 2, 2) != digito) {
			return false;
		} else {
			return true;
		}
	} else if (tipo == 2) { //CNPJ
		if (strCPFCNPJ.length < 3)
			return false;
			
        var calculo = 0;
		var resultado = 0;
        var peso = 2;
		
		//Calculo do digito 8 do CNPJ.
        calculo = new String(parseInt(strCPFCNPJ.substr(0, 1)) * 2);
        resultado = parseInt(strCPFCNPJ.substr(1, 1)) + parseInt(strCPFCNPJ.substr(3, 1)) + parseInt(strCPFCNPJ.substr(5, 1)) +
 							  parseInt(calculo.substr(0, 1)) + parseInt(calculo.substr(1, 1));
		
        calculo = new String(parseInt(strCPFCNPJ.substr(2, 1)) * 2);
        resultado = parseInt(resultado) + parseInt(calculo.substr(0, 1)) + parseInt(calculo.substr(1, 1));
		
        calculo = new String(parseInt(strCPFCNPJ.substr(4, 1)) * 2);
        resultado = parseInt(resultado) + parseInt(calculo.substr(0, 1)) + parseInt(calculo.substr(1, 1));
									
        calculo = new String(parseInt(strCPFCNPJ.substr(6, 1)) * 2);
        resultado = parseInt(resultado) + parseInt(calculo.substr(0, 1)) + parseInt(calculo.substr(1, 1));
		
		var resto = parseInt(resultado) % 10;
		
		if (resto == 0) {
			digito = resto;
		} else {
			digito = 10 - resto;
		}
		
		calculo = 0;
		
		for (var i = strCPFCNPJ.length - 3; i >= 0; i--) {
            calculo = parseInt(calculo) + parseInt(strCPFCNPJ.substr(i, 1)) * peso;
			peso++;
		
			if (peso > 9) {
				peso = 2;
			}
		}
	
		resto = parseInt(calculo) % 11;
		
		if (resto < 2) {
			digito = 0;
		} else {
			digito = 11 - resto;
		}
		
        if (strCPFCNPJ.substr(strCPFCNPJ.length - 2, 1) != digito) {
			return false;
		}
		
		//Calculo do digito 14 do CNPJ.		
        peso = 2;
		calculo = 0;
		
		for (var i = strCPFCNPJ.length - 2; i >= 0; i--) {
            calculo = parseInt(calculo) + parseInt(strCPFCNPJ.substr(i, 1)) * peso;
			peso++;
		
			if (peso > 9) {
				peso = 2;
			}
		}
		
		resto = parseInt(calculo) % 11;
		
		if (resto < 2) {
	 		digito = 0;
		} else {
			digito = 11 - resto;
		}
		
        if (strCPFCNPJ.substr(strCPFCNPJ.length - 1, 1) != digito) {
			return false;
		} else {
			return true;
		}
	}
}

/*!
 * OBJETIVO   : Fun��o que retorna uma lista de caracteres permitidos
 */	
function charPermitido() {
    var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789\"!@#$%*() -_=+[]{}/?;:.,\\|" + String.fromCharCode(10, 13);
	return chars;
}

/*!
 * OBJETIVO: 
 */	
function cancelaPedeSenhaCoordenador(divBlock) {
    $("#divUsoGenerico").css("visibility", "hidden");
	$("#divUsoGenerico").html("");	

	if (divBlock == '') {
		unblockBackground();
	} else {
		blockBackground(parseInt($("#" + divBlock).css("z-index")));
	}
}

/*!
 * OBJETIVO: Fun��o para pedir senha de Coordenador/Gerente para processo especial
 */
function pedeSenhaCoordenador(nvopelib, nmfuncao, nmdivfnc) {
	showMsgAguardo("Informe a senha do coordenador para continuar ...");			
	
	// Resetar a Global com operador de liberacao
    glb_codigoOperadorLiberacao = 0;

	$.ajax({		
		type: "POST", 
		dataType: "html",
		url: UrlSite + "includes/pede_senha.php",
		data: {
			nvopelib: nvopelib,
			nmfuncao: nmfuncao,
			nmdivfnc: nmdivfnc,
			redirect: "html_ajax"
		},		
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "");
		},
        success: function (response) {
			$("#divUsoGenerico").html(response);
			$("#divUsoGenerico").centralizaRotinaH();
		}				
	}); 	
}

/*!
 * OBJETIVO: Fun��o para solicitar confirma��o da senha de Coordenador/Gerente para processo especial
 */
function confirmaSenhaCoordenador(nmfuncao) {
	showMsgAguardo("Aguarde, validando a senha ...");
	
    var nvopelib = $("#nvopelib", "#frmSenhaCoordenador").val();
    var cdopelib = $("#cdopelib", "#frmSenhaCoordenador").val();
    var cddsenha = $("#cddsenha", "#frmSenhaCoordenador").val();

	// Valida operador
	if ($.trim(cdopelib) == "") {
		hideMsgAguardo();
        showError("erro", "Informe o " + (nvopelib == 1 ? "Operador" : nvopelib == 2 ? "Coordenador" : "Gerente") + ".", "Alerta - Ayllos", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')));$('#cdopelib','#frmSenhaCoordenador').focus()");
		return false;
    } else {
        glb_codigoOperadorLiberacao = cdopelib; // Global com operador de liberacao
	} 
	
	// Valida senha
	if ($.trim(cddsenha) == "") {
		hideMsgAguardo();
        showError("erro", "Informe a Senha.", "Alerta - Ayllos", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')));$('#cddsenha','#frmSenhaCoordenador').focus()");
		return false;
	} 	
	
	// Executa script de saque atrav&eacute;s de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "includes/valida_senha.php", 
		data: {
			nvopelib: nvopelib,
			cdopelib: cdopelib,
			cddsenha: cddsenha,
			nmfuncao: nmfuncao,
			redirect: "script_ajax"
		}, 
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
		},
        success: function (response) {
			try {
				eval(response);
            } catch (error) {
				hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
			}
		}				
	});				
}

/*!
 * OBJETIVO: Fun��o para for�ar TAB quando der enter no campo
 */
function enterTab(f, e) { 

	if (getKeyValue(e) == 13) { 
		var i; 
		for (i = 0; i < f.form.elements.length; i++) { 
			if (f == f.form.elements[i]) { break; } 
		} 

		i = (i + 1) % f.form.elements.length; 
		for (ii = i; ii < f.form.elements.length; ii++) { 
            if ((f.form.elements[ii].readOnly != true) && (f.form.elements[ii].type != 'button')) {
				break; 
			} 
		} 
		f.form.elements[ii].focus(); 
		return false; 

	} 
	else {
		return true; 
	}
} 
 
/*!
 * ALTERA��O : 002
 * OBJETIVO  : Fun��o para resetar as cores zebradas das linhas de uma tabela
 * PAR�METRO : Recebe um seletor CSS das linhas (TR) de uma tabela
 */
function zebradoLinhaTabela(x) {
	var cor = '#F7F3F7';	
    x.each(function (e) {
		cor == '#F4F3F0' ? cor = '#FFFFFF' : cor = '#F4F3F0';
        $(this).css({ 'background-color': cor, 'color': '#444' });
	});
    x.hover(function () {
        $(this).css({ 'cursor': 'pointer', 'outline': '1px solid #6B7984', 'color': '#000' });
    }, function () {
        $(this).css({ 'cursor': 'auto', 'outline': '0px', 'color': '#444' });
	});
	return false;
}

/*!
 * ALTERA��O : 003
 * OBJETIVO  : Fun��o an�loga ao "trim" do PHP, onde limpa os espa�os em branco excedentes de uma string
 * PAR�METRO : str -> Uma string qualquer
 */
function trim(str) {
	str = str.replace(/^\s+/, '');
	for (var i = str.length - 1; i >= 0; i--) {
		if (/\S/.test(str.charAt(i))) {
			str = str.substring(0, i + 1);
			break;
		}
	}
	return str;
}

/*!
 * ALTERA��O : 004
 * OBJETIVO  : Fun��o similar � mostraRotina, com a melhoria de se passar o div a ser exibido e bloquear o fundo
 * PAR�METRO : x -> div a ser exibido
 */
function exibeRotina(x) { 
    x.css('visibility', 'visible');
	x.centralizaRotinaH();
	bloqueiaFundo(x);
	return false;
}

/*!
 * ALTERA��O : 005 
 * OBJETIVO  : Fun��o similar � mostraRotina, com a melhoria de se passar o seletor jQuery da div a ser exibida e desbloquear o fundo.
 *             Ao desbloquear o fundo, tudo � desbloqueado, mas existem situa��es que precisamos manter alguma parte do sistema bloqueado,
 *             para isso utiliza-se do segundo par�metro da fun��o, que bloqueia a rotina indicada neste par�metro
 * PAR�METRO : rotina         -> Seletor jQuery a ser fechado
 *	           bloqueiaRotina -> Seletor jQuery ao qual seu fundo ser� bloqueado
 */
function fechaRotina(rotina, bloqueiaRotina, fncFechar) { 

    //Condi��o para voltar foco na op��o selecionada
    var CaptaIdRetornoFoco = '';
    CaptaIdRetornoFoco = $(".SetFoco").attr("id");
    if (CaptaIdRetornoFoco) {
        $(CaptaIdRetornoFoco).focus();
    }

    rotina.css('visibility', 'hidden');
	unblockBackground();	
    if (typeof bloqueiaRotina == 'object') {
		bloqueiaFundo(bloqueiaRotina);		
	}
    if (typeof fncFechar != 'undefined') {
		eval(fncFechar);		
	}
	return false;
}

/*!
 * ALTERA��O : 006
 * OBJETIVO  : Fun��o similar � blockBackground, com a melhoria de se passar o div a ser bloqueado
 * PAR�METRO : div       -> div ao qual o fundo ser� bloqueado 
 *             campoFoco -> [Opcional] id do campo ao qual ser� dado o foco
 *             formFoco  -> [Opcional] id do formulario ao qual o campoFoco est� inserido
 *			   boErro    -> [Opcional] valores v�lidos (true|false), indicando se recebe a classe erro ou n�o
 */
function bloqueiaFundo(div, campoFoco, formFoco, boErro) {	
    if ((div.attr('id') != 'divMatric') && (div.attr('id') != 'divTela')) {
		zIndex = parseInt(div.css('z-index'));	
		blockBackground(zIndex);	
	}
    if ((typeof campoFoco != 'undefined') && (typeof formFoco != 'undefined')) {
        if ((typeof boErro == 'undefined') && (boErro)) {
            $('#' + campoFoco, '#' + formFoco).addClass('campoErro');
		}
        $('#' + campoFoco, '#' + formFoco).focus();
	}
		
	return true;
}

/*!
 * ALTERA��O : 008
 * OBJETIVO  : Fun��o similar � format_number do php
 * PAR�METRO : number        -> O numero a ser formatado 
 *             decimals      -> Numero de casas decimais
 *             dec_point     -> [Opcional] Separador de decimal
 *             thousands_sep -> [Opcional] Separador de milhar
 * OBSERVA��O: Se passado o 3� parametro, 4� � obrigat�rio.Se nenhum � passado, default 
 *             � ',' e '.' respectivamento do parametro 3 e 4
 */
function number_format(number, decimals, dec_point, thousands_sep) {
	var n = !isFinite(+number) ? 0 : +number, 
		prec = !isFinite(+decimals) ? 0 : Math.abs(decimals),
		sep = (typeof thousands_sep === 'undefined') ? ',' : thousands_sep, dec = (typeof dec_point === 'undefined') ? '.' : dec_point,
		s = '',
		toFixedFix = function (n, prec) {
			var k = Math.pow(10, prec);
		    return '' + Math.round(n * k) / k;
		};
	// Fix for IE parseFloat(0.55).toFixed(0) = 0;
	s = (prec ? toFixedFix(n, prec) : '' + Math.round(n)).split('.');
	if (s[0].length > 3) {
        s[0] = s[0].replace(/\B(?=(?:\d{3})+(?!\d))/g, sep);
    }
	if ((s[1] || '').length < prec) {
		s[1] = s[1] || '';
		s[1] += new Array(prec - s[1].length + 1).join('0');
    } return s.join(dec);
}

/*!
 * ALTERA��O : 009
 * OBJETIVO  : Fun��o similar � in_array do php, retorna "true" se o item existe no array e "false" caso contr�rio
 * PAR�METRO : item  -> Item que est� sendo verificado se existe no array
 *             array -> Conjunto de valores que ser�o analizados verificando se o item � igual a um deles
 */
function in_array(item, array) {
    for (var i = 0; i < array.length; i++) {
        if (item == array[i]) return true;
	}
	return false;
}

/*!
 * ALTERA��O : 010
 * OBJETIVO  : Fun��o que define m�scaras, formatos, valores permitidos e layout de v�rios elementos dos formul�rios. 
 */
function layoutPadrao() {
	
    var caracAcentuacao = '����������������������������������������������';
    var caracEspeciais = '!@#$%&*()-_+=�:<>;/?[]{}���������\\|\',.�`�^~';
    var caracSuperEspeciais = '������������<>&\'\"';
	var caracEspeciaisEmail = '!#$%&*()+=�:<>;/?[]{}���������\\|\',�`�^~';	

	// Aplicando M�scaras
    $('input.conta').setMask('INTEGER', 'zzzz.zzz-z', '.-', '');
    $('input.cheque').setMask('INTEGER', 'zzz.zzz.9', '.', '');
    $('input.renavan').setMask('INTEGER', 'zzz.zzz.zzz.zz9', '.', '');
    $('input.renavan2').setMask('INTEGER', 'zz.zzz.zzz.zz9', '.', ''); //GRAVAMES
    $('input.contaitg').setMask('STRING', '9.999.999-9', '.-', '');
    $('input.placa').setMask('STRING', '999-9999', '-', '');
    $('input.matricula').setMask('INTEGER', 'zzz.zzz', '.', '');
    $('input.cadempresa').setMask('INTEGER', 'zzzz.zzz.z', '.', '');
    $('input.cnpj').setMask('INTEGER', 'z.zzz.zzz/zzzz-zz', '/.-', '');
    $('input.cpf').setMask('INTEGER', '999.999.999-99', '.-', '');
    $('input.cep').setMask('INTEGER', 'zzzzz-zz9', '-', '');
    $('input.caixapostal').setMask('INTEGER', 'zz.zz9', '.', '');
    $('input.numerocasa').setMask('INTEGER', 'zzz.zz9', '.', '');
    $('input.contrato').setMask('INTEGER', 'z.zzz.zz9', '.', '');
    $('input.contrato2').setMask('INTEGER', 'z.zzz.zzz.zz9', '.', '');
    $('input.contrato3').setMask('INTEGER', 'zz.zzz.zz9', '.', '');
    $('input.insc_estadual').setMask('INTEGER', 'zzz.zzz.zzz.zzz', '.', '');
    $('input.dataMesAno').setMask('INTEGER', 'zz/zzzz', '/', '');
	//$('input.data'			).dateEntry({useMouseWheel:true,spinnerImage:''});   
    $('input.data').setMask("DATE", "", "", "");
    $('input.taxa').attr('alt', 'p2p3c2D').css('text-align', 'right').autoNumeric().trigger('blur');
    $('input.monetario').attr('alt', 'n9p3c2D').css('text-align', 'right').autoNumeric().trigger('blur');
    $('input.moeda').attr('alt', 'p9p3c2D').css('text-align', 'right').autoNumeric().trigger('blur');
    $('input.moeda_6').attr('alt', 'p6p3c2D').css('text-align', 'right').autoNumeric().trigger('blur');
    $('input.moeda_15').attr('alt', 'p0p3c2D').css('text-align', 'right').autoNumeric().trigger('blur');
    $('input.porcento').attr('alt', 'p3x0c2a').autoNumeric().trigger('blur');
	$('input.porcento_n').attr('alt', 'n3x0c2a').css('text-align', 'right').autoNumeric().trigger('blur');
	$('input.porcento_4').attr('alt', 'p3x0c4a').autoNumeric().trigger('blur');
	$('input.porcento_6').attr('alt', 'p3x0c6a').autoNumeric().trigger('blur');
	$('input.porcento_7'	).attr('alt','p3x0c7a').autoNumeric().trigger('blur');	
	$('input.porcento_8'	).attr('alt','p3x0c8a').autoNumeric().trigger('blur');	
	$('input.indexador'	).attr('alt','p3x0c8a').autoNumeric().trigger('blur');	
	$('input.email'			).css({'text-transform':'lowercase'}).alphanumeric({ichars: caracSuperEspeciais+caracAcentuacao+caracEspeciaisEmail});
	$('input.alpha'			).css({'text-transform':'uppercase'});
	$('input.alphanum'		).css({'text-transform':'uppercase'});		
	$('input.alphanumlower'	).css({'text-transform':'lowercase'});		
	
	$('input.alpha'			).alpha({ichars: caracAcentuacao+caracEspeciais});
	$('input.alphanum'		).alphanumeric({ichars: caracSuperEspeciais+caracAcentuacao});
	$('input.alphanumlower'	).alphanumeric({ichars: caracSuperEspeciais+caracAcentuacao});
	$('textarea.alphanum'   ).alphanumeric({ichars: caracSuperEspeciais+caracAcentuacao});
	$('input.inteiro'		).numeric({ichars: caracAcentuacao+caracEspeciais+'.,\"'});
	$('input.codigo'		).numeric({ichars: caracAcentuacao+caracEspeciais+'.,\"'});
	
	$('.descricao'			).desabilitaCampo();
	$('.campoTelaSemBorda'	).attr('tabindex','-1');	
	$('label'				).addClass("txtNormalBold");
	$('input.codigo'		).attr('maxlength','4');	
	$('a[class!="botao"]','.formulario').attr('tabindex','-1');	

	// Alinhando os campos para direita
	$('.inteiro,.porcento,.numerocasa,.caixapostal,.cep,.conta,.contrato,.contrato2,.contrato3,.contaitg,.cnpj,.cpf,.matricula,.cadempresa,.insc_estadual').css('text-align','right');	
	
	/*!
	 * ALTERA��O  : 023
	 * OBJETIVO   : Tecla de atalho F8 igual ao modo CARACTER para limpar os campos input
	 */	
	/*
	* remover esse atalho, conforme NOVO LAYOUT padr�o
	*$('input[type=\'text\'],select').keydown( function(e) {
	*	if ( e.keyCode == 119 ) {
	*		$(this).val(''); 
	*		$(this).trigger('change'); // ALTERA��O 040
	*		return false;
	*	}
	*	return true;
	*});
	*/
	
	/*!
	 * ALTERA��O  : 024
	 * OBJETIVO   : Tecla de atalho F7 igual ao modo CARACTER para abrir a Pesquisa
	 * OBSERVA��O : Aplicado somente a campos que possuem a classe "pesquisa"
	 */	
	$('input.pesquisa').unbind('keydown.zoom').bind('keydown.zoom', function(e) {
		if ( e.keyCode == 118 ) {
			if ( isHabilitado($(this)) ) {
				$(this).next().click();
				return false;
			}
		}
		return true;
	});
	
	/*!
	 * ALTERA��O  : 027
	 * OBJETIVO   : Ao entrar no campo cpf ou cnpj, verifica se n�o existe valor digitado, caso afirmativo limpa o campo para digita��o
	 */		
	$('input.cnpj').unbind('focusin').bind('focusin', function() {
		$(this).addClass('campoFocusIn');	/*064*/
		valorAtual = normalizaNumero( $(this).val() );
		valorAtual = ( valorAtual == '0' ) ? '' : valorAtual;
		$(this).val( valorAtual );
	});
	$('input.cpf').unbind('focusin').bind('focusin', function() {
		$(this).addClass('campoFocusIn');	/*064*/
		valorAtual = normalizaNumero( $(this).val() );
		valorAtual = ( valorAtual == '0' ) ? '' : valorAtual;
		$(this).val( valorAtual );
	});	
	
	return true;
}

/*!
 * ALTERA��O  : 012
 * OBJETIVO   : Fun��o que retorna uma string padr�o de aguardo para impress�o
 * PAR�METROS : titulo [String] -> T�tulo que ser� incluso na mensagem
 */
function montaHtmlImpressao( titulo ) {
	var htmlImpressao = '';
	htmlImpressao  = '<html>';
	htmlImpressao += '	<head>';
	htmlImpressao += '		<title>Impress�o CECRED - '+titulo+'</title>';
	htmlImpressao += '		<style type="text/css">';
	htmlImpressao += '      	body{background-color:#DEE3D6;text-align:center;font-size:12px;color:#333;padding:50px;}';
	htmlImpressao += '		</style>';
	htmlImpressao += '  </head>';
	htmlImpressao += '  <body>';
	htmlImpressao += '  	<center>';
	htmlImpressao += '  		<h1 style="font-size:18px;font-family:Arial,Helvetica,sans-serif;border:10px solid #fff;background-color:#F7F3F7;padding:30px 10px;font-weight:normal;width:500px;">';
	htmlImpressao += '       		Aguarde, carregando impress&atilde;o do(a)<br />'+titulo+' ...';
	htmlImpressao += '          </h1>';
	htmlImpressao += '  	</center>';
	htmlImpressao += '  </body>';
	htmlImpressao += '</html>';
	return htmlImpressao;
}

/*!
 * ALTERA��O  : 014
 * OBJETIVO   : Deixar o processo de revis�o Cadastral gen�rico. O arquivo revisaoCadastral.php agora serve para todas as rotinas de CONTAS
 * PAR�METROS : chavealt [Obrigat�rio] -> Chave de altera��o, este valor � retornado pelo progress quando � necess�ria a Revis�o Cadastral
 *              tpatlcad [Obrigat�rio] -> Tipo de altera��o, este valor � retornado pelo progress quando � necess�ria a Revis�o Cadastral
 *              businobj [Obrigat�rio] -> Business Object da rotina que est� sendo tratada
 */
function revisaoCadastral(chavealt, tpatlcad, businobj, stringArrayMsg, metodo) {
	
    if (typeof stringArrayMsg == 'undefined') stringArrayMsg = '';
    if (typeof metodo == 'undefined') metodo = 'controlaOperacao(\"\");';
		
	blockBackground(1000);
	showMsgAguardo('Aguarde, registrando revis�o cadastral ...');
	
    nrdconta = normalizaNumero(nrdconta);
			
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/revisao_cadastral.php', 
		data: {
            nrdconta: nrdconta,
            idseqttl: idseqttl,
            chavealt: chavealt,
            tpatlcad: tpatlcad,
            businobj: businobj,
            stringArrayMsg: stringArrayMsg,
            metodo: metodo,
            redirect: 'script_ajax'
		}, 
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a revis&atilde;o cadastral.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
		},
        success: function (response) {
			try {
				eval(response);
            } catch (error) {
				hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a revis&atilde;o cadastral.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
			}		
		}				
	});	 
}

/*!
 * ALTERA��O  : 021 - Cria��o
 * OBJETIVO   : Para trabalhar com o n�meros sem m�scaras
 * PARAMETROS : numero [String] -> n�mero que deseja-se normalizar
 * RETORNO    : Retorna zero caso seja vazio o n�mero passado como par�metro, ou retorna o n�mero sem m�scara
 */	 
function normalizaNumero(numero) {
	var retorno;
    numero = ((typeof numero == 'undefined') || (numero == null)) ? '' : numero;
    retorno = retiraCaracteres(numero, '0123456789,', true);
    retorno = retirarZeros(retorno);
    retorno = (retorno == '') ? 0 : retorno;
	return retorno;
}

/*!
 * ALTERA��O  : 025 - Criada fun��o
 * OBJETIVO   : Selecionar o registro corrente retornando a chave para ser enviada ao XML. 
 * OBSERVA��ES: Fun��o utilizada no in�cio da fun��o "controlaOperacao" de cada rotina. 
 *              Comumente utilizada para opera��es de Altera��o ou Exclus�o
 * RETORNO    : Retorna vazio caso n�o existam registros para serem selecionados, ou retorna a chave do registro selecionado
 */	 	
function selecionaRegistro() {
	var retorno = '';
    $('table > tbody > tr', 'div.divRegistros').each(function () {
        if ($(this).hasClass('corSelecao')) {
            retorno = $('input', $(this)).val();
		}
	});	
	return retorno;
}

/*!
 * OBJETIVO   : Inserir comportamento no link da pesquisa associado para abrir o formul�rio de pesquisa
 */	 
function controlaPesquisaAssociado(nomeForm) {
    $('a', '#' + nomeForm).addClass('lupa').css({ 'float': 'right', 'font-size': '11px', 'cursor': 'pointer' });
    $('a', '#' + nomeForm).each(function () {
        $(this).click(function () {
            mostraPesquisaAssociado('nrdconta', nomeForm);
			return false;
		});
	});
}

/*!
 * OBJETIVO  : Fun��o para exibir alertas padr�o do javascript caso a vari�vel global "exibeAlerta" estiver setada para TRUE
 *             � uma fun��o auxiliar para o programador debugar as telas
 */
function alerta(mensagem) {
    if (exibeAlerta) alert(mensagem);
}

/*!
 * ALTERA��O : 026
 * OBJETIVO  : Fun��o para padr�o de focar os campos com erro.
 * PAR�METRO : campoFoco    [String]  -> id do campo ao qual ser� dado o foco
 *             formFoco     [String]  -> id do formulario ao qual o campoFoco est� inserido
 *             desbloqueia  [Boolean] -> [Opcional] true para desbloquear e false para n�o fazer nada, por default = true
 *             divBloqueia  [String]  -> [Opcional] nome da div que o fundo ser� bloqueado
 */
function focaCampoErro(campoFoco, formFoco, desbloqueia, divBloqueia) {
	
    if (typeof desbloqueia == 'undefined') {
		unblockBackground();
	} else {
        if (desbloqueia) unblockBackground();
	}
	
    if (typeof divBloqueia != 'undefined') {
        zIndex = parseInt($('#' + divBloqueia).css('z-index'));
		blockBackground(zIndex); 
	}	
	
    $('#' + campoFoco, '#' + formFoco).addClass('campoErro');
    $('#' + campoFoco, '#' + formFoco).focus();
	
	return true;
}

/*!
 * ALTERA��O  : 030
 * OBJETIVO   : Fun��o recursiva para exibir um array de mensagens, onde cada mensagem ser� exibida por LIFO
 * PAR�METROS : strArray [Obrigatorio] -> Array de strings que ser�oo exibidas
 *              metodo 	 [Obrigatorio] -> Metodo que ser� executado ap�s a ultima mensagem do array ser exibida
 */	
function exibirMensagens(strArray, metodo) {
    if (strArray != '') {
		// Definindo as vari�veis
        var arrayMensagens = new Array();
        var novoArray = new Array();
        var elementoAtual = '';
		// Setando os valores
        arrayMensagens = strArray.split('|');
        elementoAtual = arrayMensagens.pop();
        arrayMensagens = implode('|', arrayMensagens);
		// Exibindo mensagem de erro
        showError('inform', elementoAtual, 'Alerta - Ayllos', "exibirMensagens('" + arrayMensagens + "','" + metodo + "')");
	} else {
		eval(metodo);
	}
}

/*!
 * ALTERA��O  : 029
 * OBJETIVO   : Fun��o semelhando ao implode do PHP, que retorna uma string contento todos os elementos de um array separados por um separador
 * PAR�METROS : separador   [Obrigatorio] -> Separador que ser� utilizado na montagem da string
 *              arrayPedaco [Obrigatorio] -> Array que ser� implodido 
 */	
function implode(separador, arrayPedaco) {
    return ((arrayPedaco instanceof Array) ? arrayPedaco.join(separador) : arrayPedaco);
}  

/*!
 * ALTERA��O  : 028
 * OBJETIVO   : Fun��o para verificar se existem fun��es "montaSelect" sendo executadas
 * OBSERVA��O : Utilizada pelos botoes das diversas rotinas, onde se essa fun��o retornar FALSE, n�o � para executar a a��o do bot�o
 */	
function verificaContadorSelect() {
    if (contadorSelect > 0) return false;
	return true;
}

/*!
 * ALTERA��O  : 032
 * OBJETIVO   : Fun��o para verificar se o sistema est� processando alguma fun��o "controlaOperacao", n�o permitindo cham�-la 
 *              enquanto ainda est� sendo executada
 * OBSERVA��O : Utilizada por todas rotinas
 */	
function verificaSemaforo() {
    if (semaforo > 0) return false;
	semaforo++;
	return true;
}

/*!
 * ALTERA��O  : 031
 * OBJETIVO   : Fun��o para desbloquear a tela, mas a melhoria de poder setar o foco em algum campo da tela
 * OBSERVA��O : Utilizada na tela MATRIC nos retornos de erro
 */	
function desbloqueia(campoFoco, formFoco) {
	unblockBackground();
    if ((typeof campoFoco != 'undefined') && (typeof formFoco != 'undefined')) {
        $('#' + campoFoco, '#' + formFoco).focus();
	}
	return true;
}

/*!
 * ALTERA��O  : 032
 * OBJETIVO   : Fun��o para trucar textos em javascript
 * OBSERVA��O : Utilizada na tela MATRIC apresenta��o dos dados da tabela dos procuradores
 */	
function truncar(texto, limite) {
	if (texto.length > limite) {
        texto = texto.substr(0, limite - 1) + '�';
	}
	return texto;
}

/*!
 * ALTERA��O  : 036
 * OBJETIVO   : Fun��o para remover o filtro de opacidade tanto no IE quanto no FF
 * PAR�METROS : nome [String] -> Nome da div que deseja-se voltar a visualiza��o em 100%, sem transparencia (opacidade)
 */	
function removeOpacidade(nome) {
    $('#' + nome).fadeTo(1000, 1, function () {
        if ($.browser.msie) {
			$(this).get(0).style.removeAttribute('filter');
		} else {
            $(this).css({ '-moz-opacity': '100', 'filter': 'alpha(opacity=100)', 'opacity': '100' });
		}
	});
	
}

/*!
 * ALTERA��O  : 
 * OBJETIVO   : Fun��o que dado um Array Associativo bidirecional retorna uma string contendo o nome das chaves do array separado pelo separador
 * PAR�METROS : arrayDados  [Obrigatorio] -> Array Associativo que ser� implodido
 *              separador   [Obrigatorio] -> Separador que ser� utilizado na montagem da string
 */	
function retornaCampos(arrayDados, separador) {
	var str = '';
    if (arrayDados.length > 0) {
        for (registro in arrayDados[0]) {
            str += registro + separador;
		}
        str = str.substring(0, (str.length - 1));
	}
	return str;
}

/*!
 * ALTERA��O  : 
 * OBJETIVO   : Fun��o que dado um Array Associativo bidirecional retorna uma string contendo os dados de um registro implodidos com o sepValores
				e todos os registros s�o implodidos com o sepRegs
 * PAR�METROS : arrayDados  [Obrigatorio] -> Array Associativo que ser� implodido
 *              sepValores  [Obrigatorio] -> Separador que ser� utilizado para separar os dados
 *              sepRegs     [Obrigatorio] -> Separador que ser� utilizado para separar os registros
 */
function retornaValores(arrayDados, sepValores, sepRegs, strCampos) {
	var str = '';
    var arrayCampos = new Array();
    arrayCampos = strCampos.split('|');
	
    if (arrayDados.length > 0) {
        for (registro in arrayDados) {
            for (i in arrayCampos) {
			
			//for( dado in arrayDados[registro] ) {
                str += arrayDados[registro][arrayCampos[i]] + sepValores;
			}
            str = str.substring(0, (str.length - 1));
			str += sepRegs;
		}
        str = str.substring(0, (str.length - 1));
	}
	return str;
}


/*!
 * ALTERA��O  : 046 
 * OBJETIVO   :	Fun��o que converte um valor de financeiro para float 
 * PAR�METROS : valor [String ] -> [Obrigat�rio] Valor financeiro
 * RETORNO    : Retorna um valor float
 */
function converteMoedaFloat(valor) {
	valor = valor != '' ? valor : '0';
    valor = valor.replace(/\./g, '');
    valor = valor.replace(/,/g, '.');
	valor = parseFloat(valor);
	return valor;
}

/*!
 * ALTERA��O  : 048 
 * OBJETIVO   :	Fun��o que coloca mascara em uma string 
 * PAR�METROS : v [String ] -> String que vai receber a mascara. Ex.: 1111111
			  : m [String ] -> String com o formato da mascara. Ex.: ###.###.#	
 * RETORNO    : Retorna uma string com mascara. Ex.: 111.111.1
 */
function mascara(v, m) {
    var t1 = v.length - 1; // tamanho da string
    var t2 = m.length - 1; // tamanho da mascara
	var l1 = ''; // ultima letra string
	var l2 = ''; // ultima letra mascara
	var i1 = 0; // indice string
	var i2 = 0; // indice mascara
	
	var retorno = '';	
    var ultima = '';
	
    for (i1 = t1; i1 >= 0; i1--) {
		l1 = v.charAt(i1);
        while (ultima != '#' && t2 >= i2) {
            l2 = m.charAt(t2 - i2);
            if (l2 == '#') {
				retorno = l1 + retorno;
			} else {
				retorno = l2 + retorno;
			}
			ultima = l2;
			i2++;
		}
		ultima = '';
	}	
	return retorno;
}


/*!
 * V�rias fun��es criadas como plugins do jQuery
 */
$.fn.extend({ 
	
	/*!
	 * OBJETIVO: Fun��o para centralizar objetos na tela
	 */
    setCenterPosition: function () {
		// Captura posi&ccedil;&atilde;o esquerda e do topo do documento onde a barra de rolagem est&aacute; posicionada
		var curScrollX = $(window).scrollLeft();
		var curScrollY = $(window).scrollTop(); 

		// Calcula tamanho que deve sobrar ao redor do div
		var objOffsetY = ($(window).innerHeight() - $(this).outerHeight()) / 2;
		var objOffsetX = $.browser.msie ? ($(window).innerWidth() - $(this).outerWidth()) / 2 : ($("body").offset().width - $(this).outerWidth()) / 2;
	
		// Atribui posi&ccedil;&atilde;o ao div
		$(this).css({
			left: curScrollX + objOffsetX,
			top: curScrollY + objOffsetY
		});		
	},

	/*!
	 * ALTERA��O : 007
	 * OBJETIVO  : Fun��o similar � setCenterPosition, s� que centraliza a Rotina na horizontal dentro de outro elemento "tdTela"
	 */	
    centralizaRotinaH: function () {
	
		// Calcula o centro da Tela ao qual o objeto ser� centralizado 
		var larguraRotina = $("#tdConteudoTela").innerWidth();
		var larguraObjeto = $(this).innerWidth();				
		
        var metadeRotina = Math.floor(larguraRotina / 2);
        var metadeObjeto = Math.floor(larguraObjeto / 2);
		
		// A nova posi��o ser� o metade da largura da Tela menos (-) metade da do objeto mais (+)
		// 177 = largura do menu (175px) + padding_left do menu (2px) 
		var left = metadeRotina - metadeObjeto + 178;
        $(this).css('left', left.toString());
        $(this).css('top', '91px');
	},
	
	/*!
	 * ALTERA��O : 020 - Cria��o do m�todo
	 * OBJETIVO  : Facilitar a chamada e ocultar as mensagens padr�o do sistema, onde somente um m�todo agora � respons�vel por realizar tal tarefa
	 */	
    escondeMensagem: function () {
        $(this).css({ left: '0px', top: '0px', display: 'none' });
		unblockBackground();	
	},
	
	/*!
	 * ALTERA��O 45 - Somente trabalhar com determinados tipos e tags
	 * ALTERA��O 44 - Se possui a classe pesquisa, ent�o controla ponteiro do mouse do pr�ximo campo
	 * OBJETIVO: Fun��o para desabilitar o(s) campo(s)
	 */		
    desabilitaCampo: function () {
        return this.each(function () {
			var type = this.type;
            var tag = this.tagName.toLowerCase();
            if (in_array(tag, ['input', 'select', 'textarea']) && (type != 'image')) {
                $(this).addClass('campoTelaSemBorda').removeClass('campo campoFocusIn textareaFocusIn radioFocusIn checkboxFocusIn selectFocusIn').prop('readonly', true).prop('disabled', true);
                if (type == 'radio') $(this).css('background', 'none');
                if (type == 'textarea') $(this).prop('disabled', false);
                if ($(this).hasClass('pesquisa')) $(this).next().ponteiroMouse();
			}
		});		
	},
	
	/*!
	 * ALTERA��O 45 - Somente trabalhar com determinados tipos e tags
	 * ALTERA��O 44 - Se possui a classe pesquisa, ent�o controla ponteiro do mouse do pr�ximo campo	 
	 * OBJETIVO: Fun��o para habilitar o(s) campo(s)
	 */		
    habilitaCampo: function () {
        return this.each(function () {
			var type = this.type;
            var tag = this.tagName.toLowerCase();
            if ((in_array(tag, ['input', 'select', 'textarea'])) && (type != 'image')) {
                $(this).addClass('campo').removeClass('campoTelaSemBorda').prop('readonly', false).prop('disabled', false);
                if ($(this).hasClass('pesquisa')) $(this).next().ponteiroMouse();
			}
		});		
	},
	
	/*!
	 * ALTERA��O  : 034
	 * OBJETIVO   : Fun��o respons�vel por formatar o rodap� das pesquisas gen�ricas e pesquisa associado
	 */
    formataRodapePesquisa: function () {
        $(this).css({ 'border': '1px' });
        $('table', $(this)).css({ 'width': '100%' });
		var linhaRodape = $('table > tbody > tr', $(this));
        linhaRodape.css({ 'height': '18px' });
        $('td', linhaRodape).css({ 'text-align': 'center', 'background-color': '#f7d3ce', 'color': '#333', 'padding': '0px 5px 0px 5px', 'font-size': '10px' });
        $('td:eq(0)', linhaRodape).css({ 'width': '20%' });
        $('td:eq(1)', linhaRodape).css({ 'width': '60%' });
        $('td:eq(2)', linhaRodape).css({ 'width': '20%' });
        $('td > a', linhaRodape).css({ 'width': '99%', 'display': 'block', 'cursor': 'pointer', 'color': '#333', 'font-size': '10px' });
        $('td > a', linhaRodape).hover(function () {
            $(this).css({ 'text-decoration': 'underline', 'color': '#000' });
        }, function () {
            $(this).css({ 'text-decoration': 'none', 'color': '#333' });
		});			
	},
	
	/*!
	 * ALTERA��O : 001
	 * OBJETIVO  : Plugin para limpar os dados de um formul�rio. 
	 * UTILIZA��O: Via jQuery, onde a partir de um seletor podemos disparar esta funcionalidade da seguinte forma: $('seletor').limpaFormulario
	 * PAR�METRO : Podemos passar tanto o formul�rio ou algum elemento dele para ser limpado
	 */	
    limpaFormulario: function () {
        return this.each(function () {
			// Obtenho o tipo do elemento
			var type = this.type;
			// Normaliza o nome
			var tag = this.tagName.toLowerCase();
			// Se for um formul�rio realiza a chamada para todos os seus elementos
            if (tag == 'form') return $(':input', this).limpaFormulario();
			// Para tipos TEXT | PASSWORD | TEXTAREA mudo o valor para vazio
			if (type == 'text' || type == 'password' || tag == 'textarea' || type == 'hidden') this.value = '';
			// Para CHECKBOX | RADIO deixo os elementos desmarcados
            else if (type == 'checkbox' || type == 'radio') this.checked = false;
			// Para SELECT, coloco o �ndice de sele��o para -1
			//else if (tag == 'select') this.selectedIndex = -1;
		});
	},

	/*!
	 * ALTERA��O  : 015 - Cria��o da fun��o
	 * OBJETIVO   : Facilitar o processo de formata��o e padroniza��o das tabelas que apresentam registros. Este padr�o utiliza-se do plugin jQuery TableSorter
	 *              que adiciona a funcionalidade de ordena��o das tabelas.
	 * PAR�METROS : ordemInicial     [Obrigat�rio] -> Array bidimencional representando a ordena��o inicial dos dados contidos na tabela
	 *              larguras         [Opcional]    -> Array unidimencional onde constam-se as larguras de cada coluna da tabela
	 *              alinhamento      [Opcional]    -> Array unidimencional onde constam-se os alinhamentos de cada coluna da tabela
	 *              metodoDuploClick [Opcional]    -> Metodo que ser� chamado no duplo clique na linha "registro" da tabela
	 */
    formataTabela: function (ordemInicial, larguras, alinhamento, metodoDuploClick) {

		var tabela = $(this);

		// Forma personalizada de extra��o dos dados para ordena��o, pois para n�meros e datas os dados devem ser extra�dos para serem ordenados
		// n�o da forma que s�o apresentados na tela. Portanto adotou-se o padr�o de no in�cio da tag TD, inserir uma tag SPAN com o formato do 
		// dado aceito para ordena��o
        var textExtraction = function (node) {
            if ($('span', node).length == 1) {
				return $('span', node).html();
			} else {
				return node.innerHTML;
			}
		}

		// Configura��es para o Sorter
		tabela.has("tbody > tr").tablesorter({ 
            sortList: ordemInicial,
            textExtraction: textExtraction,
            widgets: ['zebra'],
            cssAsc: 'headerSortUp',
            cssDesc: 'headerSortDown',
            cssHeader: 'headerSort'
		});

		// O thead no IE n�o funciona corretamento, portanto ele � ocultado no arquivo "estilo.css", mas seu conte�do
		// � copiado para uma tabela fora da tabela original
		var divRegistro = tabela.parent();
        divRegistro.before('<table class="tituloRegistros"><thead>' + $('thead', tabela).html() + '</thead></table>');

        var tabelaTitulo = $('table.tituloRegistros', divRegistro.parent());

		// $('thead', tabelaTitulo ).append( $('thead', tabela ).html() );
        $('thead > tr', tabelaTitulo).append('<th class="ordemInicial"></th>');

		// Formatando - Largura 
		if (typeof larguras != 'undefined') {
            for (var i in larguras) {
                $('td:eq(' + i + ')', tabela).css('width', larguras[i]);
                $('th:eq(' + i + ')', tabelaTitulo).css('width', larguras[i]);
			}		
		}	

		// Calcula o n�mero de colunas Total da tabela
        var nrColTotal = $('thead > tr > th', tabela).length;

		// Formatando - Alinhamento
		if (typeof alinhamento != 'undefined') {
            for (var i in alinhamento) {
				var nrColAtual = i;
				nrColAtual++;
                $('td:nth-child(' + nrColTotal + 'n+' + nrColAtual + ')', tabela).css('text-align', alinhamento[i]);
			}		
		}			

		// Controla Click para Ordena��o
        $('th', tabelaTitulo).each(function (i) {
            $(this).mousedown(function () {
                if ($(this).hasClass('ordemInicial')) {
					tabela.has("tbody > tr").tablesorter({ sortList: ordemInicial }).tablesorter({ sortList: ordemInicial });
				} else {
                    $('th:eq(' + i + ')', divRegistro).click();
				}
			});
            $(this).mouseup(function () {

				tabela.zebraTabela();		

                $('table > tbody > tr', divRegistro).each(function (i) {
                    $(this).unbind('click').bind('click', function () {
                        $('table', divRegistro).zebraTabela(i);
					});
				});				

                $('th', tabela).each(function (i) {
					var classes = $(this).attr('class');
                    if (classes != 'ordemInicial') {
                        $('th:eq(' + i + ')', tabelaTitulo).removeClass('headerSort headerSortUp headerSortDown');
                        $('th:eq(' + i + ')', tabelaTitulo).addClass(classes);
					}
				});				
			});			
		});	

        $('table > tbody > tr', divRegistro).each(function (i) {
            $(this).bind('click', function () {
                $('table', divRegistro).zebraTabela(i);
			});
		});

        if (typeof metodoDuploClick != 'undefined') {
            $('table > tbody > tr', divRegistro).dblclick(function () {
                eval(metodoDuploClick);
			});	

            $('table > tbody > tr', divRegistro).keypress(function (e) {
                if (e.keyCode == 13) {
                    eval(metodoDuploClick);
				}
			});

		}

        $('td:nth-child(' + nrColTotal + 'n)', tabela).css('border', '0px');

		// Iniciar com a primeira linha selecionado e retornar o valor da chave deste primerio registro, que se encontra no input do tipo hidden
		tabela.zebraTabela(0);	
		return true;
	},

	/*!
	 * ALTERA��O  : 016 - Cria��o da fun��o
	 * OBJETIVO   : Utilizada  na fun��o acima "formataTabela" � chamada atrav�s de um seletor jQuery de tabela, e ele zebra as linhas da tabela.
	 *              Caso nehum par�metro � informado, a linha que estava selecionada continua selecionada.
	 * PAR�METROS : indice [Inteiro] -> Indica a linha que deve estar selecionada, ficando com uma cor diferenciada.
	 */
    zebraTabela: function (indice) {
		
		var tabela = $(this);
		
        $('tbody > tr', tabela).removeClass('corPar corImpar corSelecao');
        $('tbody > tr:odd', tabela).addClass('corPar');
        $('tbody > tr:even', tabela).addClass('corImpar');
		
        if (typeof indice != 'undefined') {
            $('tbody > tr', tabela).removeClass('corSelecao');
            $('tbody > tr:eq(' + indice + ')', tabela).addClass('corSelecao');
		}
		
        $('tr', tabela).hover(function () {
            $(this).css({ 'cursor': 'pointer', 'outline': '1px solid #6B7984', 'color': '#000' });
        }, function () {
            $(this).css({ 'cursor': 'auto', 'outline': '0px', 'color': '#444' });
		});
		
		return false;
	},

	/*!
	 * ALTERA��O  : 013
	 * OBJETIVO   : Plugin para limitar a quantidade de linhas e colunas de um textarea. 
	 *              O n�mero de colunas e linhas aceitos pelo "textarea" ser� os valores de suas propriedades "cols" e "rows" respctivamente.
	 * UTILIZA��O : Via jQuery, onde a partir de um seletor podemos disparar esta funcionalidade da seguinte forma: $('seletor').limitaTexto;
	 */
    limitaTexto: function () {
		function limita(x) {
			var testoAux = '';
			var nrLinhasAtual, nrColunasAtual, nrLinhas, nrColunas = 0;
			var arrayLinhas = x.val().split("\n");

            nrLinhas = x.attr('rows');
			nrColunas = x.attr('cols');			
			nrLinhasAtual = arrayLinhas.length;			

            for (var i in arrayLinhas) {
				nrColunasAtual = arrayLinhas[i].length;			
                if (eval(nrColunasAtual >= nrColunas)) { arrayLinhas[i] = arrayLinhas[i].substring(0, nrColunas); }
                testoAux += (testoAux == '') ? arrayLinhas[i] : '\n' + arrayLinhas[i];
			}
            x.val(testoAux);

            if (nrLinhasAtual > nrLinhas) {
				testoAux = x.val().split("\n").slice(0, nrLinhas); 
                x.val(testoAux.join("\n"));
			}
		}

        this.each(function () {
			var textArea = $(this);
            textArea.keyup(function () { limita(textArea); });
            textArea.bind('paste', function (e) { setTimeout(function () { limita(textArea) }, 75); });
		});
		
		return this;
	},
	
	/*!
	 * ALTERA��O  : 042 
	 * OBJETIVO   : Adicionar a classe "cpf" ou "cnpj" nos campos que possuem valores v�lidos de cpf ou cnpj respectivamente
	 */
    addClassCpfCnpj: function () {
        return this.each(function () {
			var type = this.type;
			var tag = this.tagName.toLowerCase();
			if (tag == 'input' && type == 'text') {
                if (verificaTipoPessoa(this.value) == 1) {
					$(this).removeClass('cnpj').addClass('cpf'); 
                } else if (verificaTipoPessoa(this.value) == 2) {
					$(this).removeClass('cpf').addClass('cnpj'); 
				} else {
					$(this).removeClass('cpf').removeClass('cnpj');
				}
			}	
		});
	},
	
	/*!
	 * ALTERA��O  : 043
	 * OBJETIVO   : Somente aplicar comportamento para links <a> que possuem a classe "lupa", onde ser�
	 *              verificado se o campo anterior possui a classe "campo", e caso afirmativo coloca
	 *              a classe "pointer", caso negativo retira esta classe.
	 */		
    ponteiroMouse: function () {
        return this.each(function () {
			// Se n�o form TAG de link <a>, ent�o n�o faz nada
			if (this.tagName.toLowerCase() != 'a') return false;						
			// Se n�o possuir a classe "lupa", n�o faz nada
			if (!$(this).hasClass('lupa')) return false;			
			// Se o campo anterior possuir a classe "campo", ent�o adiciona a classe "pointer"
            if (isHabilitado($(this).prev())) {
				$(this).addClass('pointer');
			} else {
				$(this).removeClass('pointer');
			}
			return false;			
		});
	},
    removeOpacidade: function () {
        $(this).fadeTo(1000, 1, function () {
            if ($.browser.msie) {
				$(this).get(0).style.removeAttribute('filter');
			} else {
                $(this).css({ '-moz-opacity': '100', 'filter': 'alpha(opacity=100)', 'opacity': '100' });
			}
		});
	},
    trocaClass: function (classAnterior, classAtual) {
        return this.each(function () {
			$(this).removeClass(classAnterior).addClass(classAtual);
		});		
	}
});

/*!
 * ALTERA��O  : 037
 * OBJETIVO   : Transforma data para timestamp
 * UTILIZA��O : *     example 1: mktime(14, 10, 2, 2, 1, 2008);  
				*     returns 1: 1201871402  
				*     example 2: mktime(0, 0, 0, 0, 1, 2008);  
				*     returns 2: 1196463600  
				*     example 3: make = mktime();  
				*     example 3: td = new Date();  
				*     example 3: real = Math.floor(td.getTime()/1000);  
				*     example 3: diff = (real - make);  
				*     results 3: diff < 5  
				*     example 4: mktime(0, 0, 0, 13, 1, 1997)  
				*     returns 4: 883609200  
				*     example 5: mktime(0, 0, 0, 1, 1, 1998)  
				*     returns 5: 883609200  
				*     example 6: mktime(0, 0, 0, 1, 1, 98)  
				*     returns 6: 883609200  
 */
 function mktime() {  
     // Get UNIX timestamp for a date    
     //   
     // version: 901.2514  
     // discuss at: http://phpjs.org/functions/mktime  
     // +   original by: Kevin van Zonneveld (http://kevin.vanzonneveld.net) 
       
     var no, ma = 0, mb = 0, i = 0, d = new Date(), argv = arguments, argc = argv.length;  
   
    if (argc > 0) {
        d.setHours(0, 0, 0); d.setDate(1); d.setMonth(1); d.setYear(1972);
     }  
    
     var dateManip = {  
        0: function (tt) { return d.setHours(tt); },
        1: function (tt) { return d.setMinutes(tt); },
        2: function (tt) { var set = d.setSeconds(tt); mb = d.getDate() - 1; return set; },
        3: function (tt) { var set = d.setMonth(parseInt(tt) - 1); ma = d.getFullYear() - 1972; return set; },
        4: function (tt) { return d.setDate(tt + mb); },
        5: function (tt) { return d.setYear(tt + ma); }
     };  
       
    for (i = 0; i < argc; i++) {
        no = parseInt(argv[i] * 1);
         if (isNaN(no)) {  
             return false;  
         } else {  
             // arg is number, let's manipulate date object  
            if (!dateManip[i](no)) {
                 // failed  
                 return false;  
             }  
         }  
     }     
    return Math.floor(d.getTime() / 1000);
}

/*!
 * ALTERA��O  : 038
 * OBJETIVO   : Receber uma data no formato dd/mm/aaaa , obter as substrings referentes � ao dia, mes e ao ano e passar como parametro na 
 *				fun��o mktime.              
 * PAR�METROS : data ->  Data no formato dd/mm/aaaa. 
 */
function dataParaTimestamp(data) {
    dia = data.substr(0, 2);
    mes = data.substr(3, 2);
    ano = data.substr(6, 4);
	return mktime(0, 0, 0, mes, dia, ano);
}

/*!
 * ALTERA��O  : 041
 * OBJETIVO   : Fun��o para verificar se n�mero passado como par�metro � um CPF ou CNPJ
 * PAR�METROS : numero [String ] -> [Obrigat�rio] n�mero do CPF ou CNPJ a ser verificado
 * RETORNO    : Retorna o valor [1] para pessoa F�sica e [2] para Jur�dica e [0] quando n�o � nenhum dos dois
 */	
function verificaTipoPessoa(numero) {
    if (validaCpfCnpj(numero, 1)) {
		return 1;
    } else if (validaCpfCnpj(numero, 2)) {
		return 2;
	} else {
		return 0;
	}
}

function milisegundos() {
	return Number(new Date());	
}

/*!
 * ALTERA��O  : 059
 * OBJETIVO   : Verifica se o campo est� habilitado
 * UTILIZA��O : 
*/
function isHabilitado(objeto) {

	var classes = new Array();
	
	classes[0] = 'campo';
	classes[1] = 'campoFocusIn';
	classes[2] = 'textareaFocusIn';
	classes[3] = 'radioFocusIn';
	classes[4] = 'checkboxFocusIn';
	classes[5] = 'selectFocusIn';

    if (typeof objeto == 'object') {
        for (var i in classes) if (objeto.hasClass(classes[i])) return true;
	}
	
	return false;
}

function controlaFocoEnter(frmName) {

    var cTodos = $("input[type='text'],input[type='radio'],select,textarea", '#' + frmName);

    cTodos.unbind('keypress').bind('keypress', function (e) {
		
        if (e.keyCode == 9 || e.keyCode == 13) {
				
			var indice = cTodos.index(this);	
				
			while (true) {
			
				indice++;
				
				// Desconsiderar os que estao bloqueados
				if (jQuery(cTodos[indice]).hasClass('campoTelaSemBorda')) {
					continue;
				}

				// Se campo nao e' nullo, focar no proximo
                if (cTodos[indice] != null) {
					cTodos[indice].focus();
				}
			
				break;

			}										
			return false;
		}
	});

}

function CheckNavigator() {
	var navegador = 'undefined';
    var versao = '0';
	
    if (navigator.userAgent.search(/chrome/i) != ' -1') {
		navegador = 'chrome';
        versao = navigator.userAgent.substr(navigator.userAgent.search(/chrome/i) + 7);
        versao = versao.substr(0, versao.search(' '));
	} else if (navigator.userAgent.search(/firefox/i) != '-1') {		
		navegador = 'firefox';
        versao = navigator.userAgent.substr(navigator.userAgent.search(/firefox/i) + 8);
        versao = versao.substr(0, versao.search(' '));
	} else if (navigator.userAgent.search(/msie/i) != '-1') {
		navegador = 'msie';
		if (navigator.userAgent.search(/trident/i) != '-1') {
			versao = navigator.userAgent.substr(navigator.userAgent.search(/trident/i) + 8);
            versao = versao.substr(0, versao.search(';'));
			
			switch (versao) {
				case '4.0': versao = '8.0'; break;
				default: versao = '9.0'; break;
			}
		} else {
			versao = navigator.userAgent.substr(navigator.userAgent.search(/msie/i) + 5);
            versao = versao.substr(0, versao.search(';'));
		}		
	}
	
	return { navegador: navegador, versao: versao };
}

//funcao pode ou nao ter parametro de retorno
function verificaAguardoImpressao(callback) {		
	try {
		var httpState = parent.document.getElementById("frameBlank").contentWindow.document.readyState.toUpperCase();		
		
		if (httpState == undefined || httpState.toUpperCase() == "COMPLETE" || httpState.toUpperCase() == "INTERACTIVE") {
			hideMsgAguardo();
			
			if (callback != undefined) {
				eval(callback);			
			}		
		} else {
            setTimeout(function () { verificaAguardoImpressao(callback) }, 500);
		}
	} catch (err) {
		hideMsgAguardo();
        showError("error", "Erro no sistema de impress&atilde;o: " + err.message + "<br>Feche o navegador e reinicie o sistema Ayllos.", "Alerta - Ayllos", "");
	}			

	return true;
}

function carregaImpressaoAyllos(form, action, callback) {
	
	try {
		showMsgAguardo('Aguarde, carregando impress&atilde;o ...');
		
		var NavVersion = CheckNavigator();	
		
		if (action.search(/\?/) == '-1') {	
			action = action + '?';
		} else {
			action = action + '&';
		}
		
		action = action + 'keylink=' + milisegundos();
		
		// Configuro o formul�rio para posteriormente submete-lo
        $('#' + form).attr('method', 'post');
        $('#' + form).attr('action', action);
        $('#' + form).attr("target", (NavVersion.navegador == 'chrome' ? '_blank' : 'frameBlank'));
        $('#' + form).submit();
		verificaAguardoImpressao(callback);	
	} catch (err) {	
		hideMsgAguardo();
        showError("error", "Erro no sistema de impress&atilde;o: " + err.message + "<br>Feche o navegador e reinicie o sistema Ayllos.", "Alerta - Ayllos", "");
	}
	
	return true;
}

function normalizaTexto(strNormaliza) {

    strNormaliza = trim(strNormaliza);
    strNormaliza = strNormaliza.replace(/['"]*/g, '');

	return strNormaliza;	
}

/* http://stackoverflow.com/questions/46155/validate-email-address-in-javascript */
function validaEmail(emailAddress) {
    var re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    return re.test(emailAddress);
}

function replaceAll(str, de, para) {
    var pos = str.indexOf(de);
    while (pos > -1) {
		str = str.replace(de, para);
        pos = str.indexOf(de);
    }
    return (str);
}

function base64_decode(data) {

  var b64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';
  var o1, o2, o3, h1, h2, h3, h4, bits, i = 0,
    ac = 0,
    dec = '',
    tmp_arr = [];

  if (!data) {
    return data;
  }

  data += '';

  do { // unpack four hexets into three octets using index points in b64
    h1 = b64.indexOf(data.charAt(i++));
    h2 = b64.indexOf(data.charAt(i++));
    h3 = b64.indexOf(data.charAt(i++));
    h4 = b64.indexOf(data.charAt(i++));

    bits = h1 << 18 | h2 << 12 | h3 << 6 | h4;

    o1 = bits >> 16 & 0xff;
    o2 = bits >> 8 & 0xff;
    o3 = bits & 0xff;

    if (h3 == 64) {
      tmp_arr[ac++] = String.fromCharCode(o1);
    } else if (h4 == 64) {
      tmp_arr[ac++] = String.fromCharCode(o1, o2);
    } else {
      tmp_arr[ac++] = String.fromCharCode(o1, o2, o3);
    }
  } while (i < data.length);

  dec = tmp_arr.join('');

  return dec.replace(/\0+$/, '');
}

function base64_encode(data) {
  
  var b64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';
  var o1, o2, o3, h1, h2, h3, h4, bits, i = 0,
    ac = 0,
    enc = '',
    tmp_arr = [];

  if (!data) {
    return data;
  }

  do { // pack three octets into four hexets
    o1 = data.charCodeAt(i++);
    o2 = data.charCodeAt(i++);
    o3 = data.charCodeAt(i++);

    bits = o1 << 16 | o2 << 8 | o3;

    h1 = bits >> 18 & 0x3f;
    h2 = bits >> 12 & 0x3f;
    h3 = bits >> 6 & 0x3f;
    h4 = bits & 0x3f;

    // use hexets to index into b64, and append result to encoded string
    tmp_arr[ac++] = b64.charAt(h1) + b64.charAt(h2) + b64.charAt(h3) + b64.charAt(h4);
  } while (i < data.length);

  enc = tmp_arr.join('');

  var r = data.length % 3;

  return (r ? enc.slice(0, r - 3) : enc) + '==='.slice(r || 3);
}

/*! OBJETIVO: Remover acentos*/
function removeAcentos(str) {
    return str.replace(/[������]/g, "a").replace(/[������]/g, "A").replace(/[������]/g, "O").replace(/[������]/g, "o").replace(/[����]/g, "E").replace(/[����]/g, "e").replace(/[�]/g, "C").replace(/[�]/g, "c").replace(/[����]/g, "I").replace(/[����]/g, "i").replace(/[����]/g, "U").replace(/[����]/g, "u").replace(/[�]/g, "y").replace(/[�]/g, "N").replace(/[�]/g, "n");
}

/*! OBJETIVO  : Remover caracteres que invalidam o xml
	PARAMETROS: str           -> Texto que contera os caracteres invalidos que irao ser removidos
				flgRemAcentos -> Flag para identificar se � necess�rio remover acentuacao
*/

function removeCaracteresInvalidos(str, flgRemAcentos){
	
	//Se necessario remover acentuacao
	if (flgRemAcentos){
		return removeAcentos(str.replace(/[^A-z0-9\s�����������������������������������������������������\!\@\$\%\*\(\)\-\_\=\+\[\]\{\}\?\;\:\.\,\/\�\�\�]/g,""));				 
	}
		
	else
		return str.replace(/[^A-z0-9\s�����������������������������������������������������\!\@\$\%\*\(\)\-\_\=\+\[\]\{\}\?\;\:\.\,\/\�\�\�]/g,"");				 
	
}

function utf8_decode(str_data) {
  var tmp_arr = [],
    i = 0,
    ac = 0,
    c1 = 0,
    c2 = 0,
    c3 = 0,
    c4 = 0;

  str_data += '';

  while (i < str_data.length) {
    c1 = str_data.charCodeAt(i);
    if (c1 <= 191) {
      tmp_arr[ac++] = String.fromCharCode(c1);
      i++;
    } else if (c1 <= 223) {
      c2 = str_data.charCodeAt(i + 1);
      tmp_arr[ac++] = String.fromCharCode(((c1 & 31) << 6) | (c2 & 63));
      i += 2;
    } else if (c1 <= 239) {
      // http://en.wikipedia.org/wiki/UTF-8#Codepage_layout
      c2 = str_data.charCodeAt(i + 1);
      c3 = str_data.charCodeAt(i + 2);
      tmp_arr[ac++] = String.fromCharCode(((c1 & 15) << 12) | ((c2 & 63) << 6) | (c3 & 63));
      i += 3;
    } else {
      c2 = str_data.charCodeAt(i + 1);
      c3 = str_data.charCodeAt(i + 2);
      c4 = str_data.charCodeAt(i + 3);
      c1 = ((c1 & 7) << 18) | ((c2 & 63) << 12) | ((c3 & 63) << 6) | (c4 & 63);
      c1 -= 0x10000;
      tmp_arr[ac++] = String.fromCharCode(0xD800 | ((c1 >> 10) & 0x3FF));
      tmp_arr[ac++] = String.fromCharCode(0xDC00 | (c1 & 0x3FF));
      i += 4;
    }
  }

  return tmp_arr.join('');
}