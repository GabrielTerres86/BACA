/*!
 * FONTE        : seguro.js
 * CRIAÇÃO      : Marcelo L. Pereira (GATI)
 * DATA CRIAÇÃO : 12/09/2011
 * OBJETIVO     : Biblioteca de funções na rotina Seguros da tela ATENDA
 * --------------
 * ALTERAÇÕES   : Michel M Candido
 * DATA CRIAÇÃO : 19/09/2011
 * --------------
 * ALTERACOES   : 02/12/2011 - Habilitado campo dsendres da div part_2 para digitacao. (Fabricio)
 * 				  20/12/2011 - Ajuste para validacao da idade nos seguros de vida (Adriano).
 *				  27/02/2012 - Incluido a variavel global dtnscsg (Adriano). 
 *			      01/03/2012 - Ajuste nas funções buscaSeg, validaPlanoSeguro a fim de deixar
 *							   o fundo bloqueado ao mostrar a mensagem "Aguarde, processando..."
 *							   (Adriano).
 *				  28/06/2012 - Alterado esquema para impressao em  
 *                             imprimirTermoCancelamento(), imprimirPropostaSeguro()
 *							   e adicionado confirmacao de impressao em validaPlanoSeguro().
 *							 - Retirado campos "redirect" popup dos forms. (Jorge)
 *				  21/02/2013 - Incluir function habilitaBotoesSegVida(), tratamento para
 *							   Impressão correta de seguro de vida "ALTERACAO" E "INCLUSAO". 
							   (Lucas R.)
				
				  25/07/2013 - Incluído o campo Complemento no endereço. (James).
				  
				  20/11/2013 - Incluida funcao atualizaSeguradora e removido a
							   atribuicao da variavel cdsegura ao chamar a funcao controlaOperacao
							   com o parametro (""). (Reinert)
							   
				  19/09/2014 - Bloquer opcao de cancelamento do seguro do tipo prestamista(Softdesk 179295 - Lucas R.) 
                  
                  05/03/2015 - Melhorias Seguro Vida, permitir definir dia para os proximos deditos (Odirlei-AMcom)
				  
				  10/03/2015 - Ajustar o campo Capital Seguro para buscar o valor do campo vlcapseg, conforme no ayllos caracter. (James)
				  
				  03/06/2015 - Adicionado validacao no momento de definir dias para o proximo debitos (Kelvin)
				  
				  03/07/2015 - Regirado funcao dateEntry (Lucas Ranghetti/Thiago Rodrigues #303749)
				  
				  08/10/2015 - Reformulacao cadastral (Gabriel-RKAM).

				  22/06/2016 - Trazer os novos contratos de seguro adicionados a base de dados pela integração com o PROWEB.
				               Criação de nova tela de consulta para os seguros de vida. Projeto 333_1. (Lombardi) 
				  
                  22/08/2016 - Qdo for seguro de vida (tpseguro = 3) ao digitar o plano buscar o valor
                               automaticamente (Tiago/Thiago #462910).

                  25/07/2016 - Adicionado função controlaFoco.(Evandro - RKAM).

                  29/08/2016  - PROJ 187.2 - Sicredi Seguros (Guilherme/SUPERO)

                  21/11/2017 - Ajuste para controle das mensagens de alerta referente a seguro (Jonata - RKAM P364).

                  22/11/2017 - Ajuste para permitir apenas consulta de acordo com a situação da conta (Jonata - RKAM p364).

                  02/04/2018 - Chamada rotina "validaAdesaoProduto" para verificar se tipo de conta permite a contratação
                               do produto. PRJ366 (Lombardi).
 
                  02/07/2018 - Ajuste para não permitir caracteres especiais nos dados do beneficiário do seguro de vida
                               PRB0040130 (André Bohn - MoutS).

				  04/09/2018 - Alterado a impressão da proposta seguro prestamista PRJ 438 e incluído campo contrato 
				  			   para o tipo seguro prestamista. PRJ 438 (Mateus Z - MoutS).
                  04/12/2018 - Retornar saldo devedor para valor do seguro prestamista - Paulo Martins - 438 Sprint 7
                  
				  13/06/2019 - Corrigido a entrada de caracteres especiais na entrada do nome do beneficiario (Tiago)
                  24/07/2019 - P519 - Bloqueio de contratacao e cancelamento de seguros CASA/VIDA para coop CIVIA (Darlei / Supero)
 * */
 
//**************************************************
//**       GERENCIAMENTO DA ROTINA DE SEGUROS  **
//**************************************************/
// Formulário para inclusão de seguro para tipo CASA (form_seguro_casa.php)
var rNmresseg, rNrctrseg, rTpplaseg, rDstipseg, rDdpripag, rDdvencto, rVlpreseg, rDtinivig, rDtfimvig, rFlgclabe, rNmbenvid, rDtcancel, rDsmotcan, rLocrisco, rNrcepend, rDsendres, rNrendere, rComplend, rNmbairro, rNmcidade, rCdufresd, rEndcorre, rTpEndcor, rNrcepend2, rDsendres2, rNrendere2, rNmbairro2, rNmcidade2, rCdufresd2, rComplend2;
var cNmresseg, cNrctrseg, cTpplaseg, cDstipseg, cDdpripag, cDdvencto, cVlpreseg, cDtinivig, cDtfimvig, cFlgclabe, cNmbenvid, cDtcancel, cDsmotcan, cNrcepend, cDsendres, cNrendere, cComplend, cNmbairro, cNmcidade, cCdufresd, cTpencor1, cTpencor2, cTpencor3, cNrcepend2, cDsendres2, cNrendere2, cNmbairro2, cNmcidade2, cCdufresd2, cComplend2;

// variável utilizada na validação do plano de seguro na inclusão do seguro para o tipo casa
var tpplasegOld = 0;

//variavel para armazenar operacao globalmente.
var glbcdopc = ""; 
var glbctfrm = "";

var idseqttl, vlpreseg, dtprideb, flgunica, flgclabe, vlpremio, nmbenvid;
var nmsegura;
/*inicializa variavel global dentro deste escopo*/
var operacao;
var nmprimtl    = null;
var cdsitdct    = null;
var tpseguro    = null;
var idproposta  = null;
var idcontrato  = null;
var cdsexosg    = null;
var nmresseg    = null;
var inpessoa    = null;
var dspesseg    = '';
/*variaveis referentes ao endereco*/
var dsendere    = null;
var nrendere    = null;
var complend    = null;
var nmbairro    = null;
var nmcidade    = null;
var cdufende    = null;
var nrcepend    = null;
var nmdsegur    = null;
var dtiniseg    = '';
var cdsegura    = null;
var nmbenefi    = new Array();
var dsgraupr    = new Array();
var txpartic    = new Array();
var arrayPlanos = new Array();
var dtultalt    = '';
/*parametros para consulta*/
var consultar   = false;
var dsStatus    = null;
var tpplaseg    = null;
var dtinivig    = '';
var qtpreseg    = null;
var dtcancel    = '';
var dtfimvig    = '';
var vlprepag    = null;
var dtdebito    = '';
var dsSeguro    = null;
var nrctrseg    = 0;
var dtmvtolt    = '';
var qtprepag    = null;
var qtparcel    = null;
var cdsitseg    = null;
var nrcpfcgc    = 0;
var nrcpfcgcC   = null;
var nmdsegurC   = null;
var dtnascsgC   = '';
var dtnascsg    = '';
var cdsexotl    = null;
var vlseguro    = 0;
var dsMotcan	  = '';
/*variaveis refentes ao seguro tela cadastro*/
var vlplaseg    = null;
var vlmorada    = null;
var teclado     = 0;

// Inicializando os seletores dos campos do cabeçalho
var cTodos    = $('#cdsitdct,#nmresseg,#nmdsegur,#nrcpfcgc,'+
				  '#dtnascsg,#cdsexosg,#nmprimtl');		  
			  
function resetaVars(){
     cdsitdct    = null;
	 tpseguro    = null;	
	 qtparcel    = null;
	 idproposta  = null;
     idcontrato  = null;
	 cdsexosg    = null;
	 nmresseg    = null;
	 nmprimtl    = null;
	 inpessoa    = null;
	 
	 // Parâmetros para consulta
	 consultar   = false;
	 dsStatus    = null;
	 tpplaseg    = null;
	 dtinivig    = '';
	 qtpreseg    = null;
	 dtcancel    = '';
	 dtfimvig    = '';
	 vlprepag    = null;
	 dtdebito    = '';
	 dsSeguro    = null;
	 nrctrseg    = null;
	 dtiniseg    = '';
	 dtmvtolt    = '';
	 cdsegura    = null;
	 qtprepag    = null;
	 cdsitseg    = null;
	 nmbenefi    = new Array();
	 dsgraupr    = new Array();
	 txpartic    = new Array();
	 dsMotcan		 = '';
	 
	 // Variáveis referentes ao endereco
	 dsendere    = null;
	 nrendere    = null;
	 complend    = null;
	 nmbairro    = null;
	 nmcidade    = null;
	 cdufende    = null;
	 nrcepend    = null;
	 
	 // Váriaveis refentes a tela de seguro
     vlplaseg    = null;
     vlmorada    = null;
}

//Controla as operações da descrição de seguros
function controlaOperacao(operacao) {
		
		consultar = false;
		$('table > tbody > tr', 'div.divRegistros').each( function() {
			if ($(this).hasClass('corSelecao') ) {
                dsStatus   = $('#dsstatus', $(this) ).val();
                dsSeguro   = $('#dsseguro', $(this) ).val();
                tpseguro   = $('#tpseguro', $(this) ).val();
                nrctrseg   = $('#nrctrseg', $(this) ).val();
                vlpreseg   = $('#vlpreseg', $(this) ).val();
                dtdebito   = $('#dtdebito', $(this) ).val();
                dtinivig   = $('#dtinivig', $(this) ).val();
                dtfimvig   = $('#dtfimvig', $(this) ).val();
                dtprideb   = $('#dtprideb', $(this) ).val();
                flgunica   = $('#flgunica', $(this) ).val();
                qtparcel   = $('#qtparcel', $(this) ).val();
                tpplaseg   = $('#tpplaseg', $(this) ).val();
                flgclabe   = $('#flgclabe', $(this) ).val();
                vlpremio   = $('#vlpremio', $(this) ).val();
                nmbenvid   = $('#nmbenvid', $(this) ).val();
                nmresseg   = $('#nmdsegur', $(this) ).val();
                qtpreseg   = $('#qtpreseg', $(this) ).val();
                dtcancel   = $('#dtcancel', $(this) ).val();
                vlprepag   = $('#vlprepag', $(this) ).val();
                dtiniseg   = $('#dtiniseg', $(this) ).val();
                dtmvtolt   = $('#dtmvtolt', $(this) ).val();
                cdsexosg   = $('#cdsexosg', $(this) ).val();
                qtprepag   = $('#qtprepag', $(this) ).val();
                qtparcel   = $('#qtparcel', $(this) ).val();
                cdsitseg   = $('#cdsitseg', $(this) ).val();
                idorigem   = $('#idorigem', $(this) ).val();
                nmsispar   = $('#nmsispar', $(this)).val();
                idcontrato = $('#idcontrato', $(this)).val();
								dsMotcan   = $('#dsmotcan', $(this) ).val();
				cdcooper   = parseInt($('#cdcooper').val());
				
				// for para pegar os valores dos parentes caso seja vida
				if(tpseguro == 3){
					for(i = 1; i<=5; i++){
						nm = '#nmbenefi_'+i;
						ds = '#dsgraupr_'+i;
						tx = '#txpartic_'+i;
						nmbenefi[i] = $(nm,$(this)).val();
						dsgraupr[i] = $(ds,$(this)).val();
						txpartic[i] = $(tx,$(this)).val();
					}
				}
			}
		});
		
		switch (operacao) {
			case 'C' : 
				if ((tpseguro == 11 || tpseguro == 3)&&(cdcooper == 13)) {   // se for casa ou vida e cooperativa civia
					showError('error','Plano de seguro bloqueado para cancelamento, devido processo de migração para Nova Seguradora. Cancelamento deverá ser realizado via Sistema de Gestão de Seguros – SIGAS.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
					return false;
					break;
				}
				// Se for tipo novo, não é alteráveil pelo Ayllos e nem pode ser impresso
			    if (idorigem == 'N') {
			        showError('error', 'Esta ap&oacute;lice n&atilde;o permite esta opera&ccedil;&atildeo! Utilizar o sistema "' + nmsispar + '".', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
					return false;
				}
				mensagem = 'carregando etapa do cancelamento de seguro...';
				if(dsStatus.indexOf('Cancelado') >= 0){
					mostraTelaDesfazerCancelamento();
				}
				else{
					if(dsSeguro=='CASA'){
						mostraTelaMotivoCancelamento();
					}
					else if(dsSeguro=='VIDA'){
						showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Aimaro','cancelarSeguro();','','sim.gif','nao.gif'); 
					}
					else if(dsSeguro=='PRST'){ 
						// se for prestamista e seguro estiver ativo, bloqueia a opção de cancelamento
						if (tpseguro == 4 && cdsitseg != 2) { 
							hideMsgAguardo();
							showError('alert','Op&ccedil;&atilde;o bloqueada!','Alerta - Aimaro','bloqueiaFundo(divRotina);controlaOperacao("");');
							
						}else {
							showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Aimaro','cancelarSeguro();','','sim.gif','nao.gif');
						}
					}
				}
				
				return false;
				break;
			case 'SEGUR': // inclusão seguro casa - tela 1 (seleção da seguradora)
				cddopcao = 'SEGUR';
				break;
			case 'I_CASA': // inclusão seguro casa - tela 2 (dados)
				nmsegura = $('#nmsegura','#divSeguradoras').val(); 
				cdsegura = $('#cdsegura','#divSeguradoras').val();			
				cddopcao = 'I_CASA';
				break;
			case 'VI_CASA':
				operacao = 'I_CASA';
				break;
			case 'I_CASA_END': // inclusão seguro casa - tela 2 (dados)
				
				nrctrseg = $('#nrctrseg').val();
				tpplaseg = $('#tpplaseg').val();
				ddpripag = $('#ddpripag').val();
				ddvencto = $('#ddvencto').val();
				vlpreseg = $('#vlpreseg').val();
				dtinivig = $('#dtinivig').val();
				dtfimvig = $('#dtfimvig').val();
				flgclabe = $('#flgclabe').val();
				nmbenvid = $('#nmbenvid').val();
				dtcancel = $('#dtcancel').val();
				dsmotcan = $('#dsmotcan').val();
				nrcepend = $('#nrcepend').val();
				dsendres = $('#dsendres').val();
				nrendere = $('#nrendere').val();
				complend = $('#complend').val();
				nmbairro = $('#nmbairro').val();
				nmcidade = $('#nmcidade').val();
				cdufresd = $('#cdufresd').val();
				
				cddopcao = 'I_CASA_END';
				
				break;
			case 'C_CASA': // consulta casa
				cddopcao = 'C_CASA';
				break;
			case 'IMP':
				// Se for tipo novo, não é alteráveil pelo Ayllos e nem pode ser impresso
				if (idorigem == 'N'){
					showError('error','Esta ap&oacute;lice n&atilde;o permite esta opera&ccedil;&atildeo! Utilizar o sistema "' + nmsispar + '".','Alerta - Aimaro','bloqueiaFundo(divRotina)');
					return false;
				}
				
				// se for diferente de 2 (AUTO), pergunta ao usuário se quer imprimir a proposta de seguro
				if(tpseguro!=2)
					showConfirmacao('Deseja imprimir a proposta de seguro?','Confirma&ccedil;&atilde;o - Aimaro','imprimirPropostaSeguro("");','blockBackground(parseInt($("#divRotina").css("z-index")));','sim.gif','nao.gif');
				return false;
				break;
			case 'I' : //insere
				cddopcao = 'T';
				resetaVars();
				break;
			case 'TF'://tela formulario
				tpseguro = parseInt($('#tpemprst').val());
				cdcooper = parseInt($('#cdcooper').val());
				var cdprodut = 0;
				var executa_depois = '';
				switch (tpseguro) {
					case 3: //Seguro de Vida
						cdprodut = 18;
						break;
					case 4: // Seguro Prestamista
						cdprodut = 40;
						break;
					case 11: // Seguro Residência
						cdprodut = 19;
						break;
				}
				if ((tpseguro == 11 || tpseguro == 3)&&(cdcooper == 13)) {   // se for casa ou vida e cooperativa civia
					showError('error','Plano de seguro bloqueado para contratação, devido processo de migração para Nova Seguradora. Adesão deverá ser realizada via Sistema de Gestão de Seguros – SIGAS.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
					return false;
					break;
				}
            if (tpseguro == 11 || tpseguro == 4) {   // se for casa            
					executa_depois = 'valida_inclusao(' + tpseguro + ');';
				}
            else { // se não for casa
					executa_depois = 'validaAssociados();';
				}
				validaAdesaoProduto(nrdconta, cdprodut, executa_depois);
				return false;
				break;
			case 'BUSCAEND':
				buscaEnd();
				return false;
				break;
			case 'BTF':
					operacao = 'TF';
					cddopcao = 'TF';
				break;
			case 'VALTF': //valida tela formulario
				operacao = 'TF';
				cddopcao = 'TF';
				
				// Seta valores globais do escopo
				tpseguro = $('#tpemprst').val();
				cdsitdct    = $('#cdsitdct').val();
				nmprimtl    = $('#nmprimtl').val();
								
				tipo_seguro_text = $('#tpemprst').find('option').filter(':selected').text();
				if(tipo_seguro_text == 'PRESTAMISTA'){
					tipo_seguro_text = 'PREST';
				}				
				if(tpseguro == 11){
					controlaOperacao('SEGUR');
					return false;
				}
				break;
			case 'TE'://tela exclusao
					mensagem = 'processando exclus&atilde;o...';
					cddopcao = 'E';
				break;
			case 'CONSULTAR':
				consultar = true;
				
				if (idorigem == 'N' && tpseguro != 2 && tpseguro != 3){
					showError('error','Novo seguro sem tela de detalhamento – consultar sistema "' + nmsispar + '".','Alerta - Aimaro','bloqueiaFundo(divRotina)');
					return false;
				}
				
                if (tpseguro == 2){ // SEGURO AUTO (2)
                    if (idorigem == 'A') {  // SEGURO AUTO ANTIGO (A)
					operacao = 'C_AUTO';
                    }else {                 // SEGURO AUTO NOVO (N)
                        operacao = 'C_AUTO_N';
                    }
					cddopcao = 'C_AUTO';
				}else if(tpseguro == 11){
                        operacao = 'C_CASA';
                        cddopcao = 'C_CASA';
				}else if(tpseguro == 3 && idorigem == 'N'){
					operacao = 'CONSULTAR_NOVO';
					cddopcao = 'CONSULTAR_NOVO';
				}
				cddopcao = 'CONSULTAR';
				break;
		    case 'ALTERAR':
		        // Se for tipo novo, não é alteráveil pelo Ayllos e nem pode ser impresso
		        if (idorigem == 'N') {
		            showError('error', 'Esta ap&oacute;lice n&atilde;o permite esta opera&ccedil;&atildeo! Utilizar o sistema "' + nmsispar + '".', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
		            return false;
		        }

		        if (tpseguro != 3) {
		            return false;
		        }

		        consultar = true;
		        cddopcao = 'ALTERAR';
		        break;
			case 'TI'://tela insere
					
					operacao = 'TI';
					cddopcao = 'TI';
					
					if(!$('#nmdsegur').val() && !$('#nrcpfcgc').val() && !$('#dtnascsg').val() ){
						return false;
					}
					var sexo = 1;
					$('input:radio[name=cdsexosg]').each(function() {
							//Verifica qual está selecionado
							if ($(this).is(':checked'))
								sexo = parseInt($(this).val());
					});
					
					// Seta as variaveis globais deste escopo
					nmdsegur    = $('#nmdsegur').val();
					nmresseg    = $('#nmresseg').val();
					cdsexosg    = sexo;
					cdsitdct    = $('#cdsitdct').val();
					nmprimtl    = $('#nmprimtl').val();					
					inpessoa    = $('#inpessoa').val();			
					
				break;
			case 'VALIDA_INCLUSAO_VIDA':			
					validaInclusaoVida();
					
				return false;				
				break;
			case 'BUSCASEG':
					buscaSeg('CRIASEG');
					return false;
				break;
			case 'ATUALIZASEG':				
					buscaSeg('ALTERASEGURO');
				  return false;
				  break;
			case 'ALTERASEGURO':
				criaSeg('ATUALIZASEG');
				return false;
				break;
			case 'CRIASEG':
					// validaSeguroGeral(operacao, nrpagina) - nrpagina utilizado para validar o cadastro do seguro para casa.
					//validaSeguroGeral(operacao, nrpagina);
					validaSeguroGeral(operacao, 0);
				return false;				
				break;
			default   : //tela inicial
				operacao = '';
				nrctremp = '';
				cddopcao = '@';
				mensagem = 'carregando...';
				break;
		}
		
		$('.divRegistros').remove();
		showMsgAguardo('Aguarde, ' + mensagem);	
		// Executa script de através de ajax
			
		$.ajax({
			type: 'POST',
			dataType: 'html',
			url: UrlSite + 'telas/atenda/seguro/principal.php', 
			data: {
            nrdconta: nrdconta, cddopcao: cddopcao,
            nrctrseg: nrctrseg, inpessoa: inpessoa,
            tpseguro: tpseguro, cdsegura: cdsegura,
            cdsexosg: cdsexosg, nmresseg: nmresseg,
            cdsitdct: cdsitdct, nmprimtl: nmprimtl,
            operacao: operacao, idproposta: idproposta,
            idcontrato: idcontrato,
            nmsegura: nmsegura, nmdsegur: nmdsegur,
            executandoImpedimentos: executandoImpedimentos,
            sitaucaoDaContaCrm: sitaucaoDaContaCrm,
            tipo: tpseguro, redirect: 'script_ajax'
			}, 
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
			},
			success: function(response) { 
										
				if ( response.indexOf('showError("error"') == -1 ) {
					$('#divConteudoOpcao').html(response);	

					if (executandoProdutos) {
						if (operacao == '') {
							controlaOperacao('I');
						}
					}	
						
				} else {
					eval( response );
				}
				controlaFoco();
				return false;
			}				
		});		
}


//Função para controle de navegação
function controlaFoco() {
    $('#divConteudoOpcao').each(function () {
        $(this).find("#divBotoes > :input[type=image]").addClass("FluxoNavega");
        $(this).find("#divBotoes > :input[type=image]").first().addClass("FirstInputModal").focus();
        $(this).find("#divBotoes > :input[type=image]").last().addClass("LastInputModal");
    });

    //Se estiver com foco na classe FluxoNavega
    $(".FluxoNavega").focus(function () {
        $(this).bind('keydown', function (e) {
            if (e.keyCode == 13) {
                $(this).click();
            }
        });
    });

    $(".FirstInputModal").focus();
}


/*efetua validacao quando for o plano de vida*/
function validaInclusaoVida(){

			/*recupera valores do formulario*/
			var dtnascimento = $('#dtnascsg').val();
			var nmdsegur     = $('#nmdsegur').val();
			nrcpfcgc = $('#nrcpfcgc', '#forSeguro').val()
			
						
			// Executa script de através de ajax
			$.ajax({
				type: 'POST',
				dataType: 'html',
				url: UrlSite + 'telas/atenda/seguro/validar_inclusao_vida.php', 
				data: {
					nrdconta: nrdconta, cddopcao: cddopcao,
					idproposta:idproposta, tipo:tpseguro, nmdsegur:nmdsegur,
					cdsitdct:cdsitdct,dtnascsg:dtnascimento,vlmorada:vlmorada,
					inpessoa:inpessoa,nmprimtl:nmprimtl,vlpreseg:vlpreseg,
					operacao: operacao, redirect: 'script_ajax'
				}, 
				error: function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
				},
				success: function(response) {
						if ( response.indexOf('showError("error"') == -1 ) {
							 controlaOperacao('TI');
						} else {
							eval( response );
						}
				}				
			});			
}
// Controla o layout da descrição de bens
function controlaLayout(operacao) {
	
	glbcdopc = operacao;
	
	switch(operacao){
		case 'TF':
				carregaForm();
			break;			
		case 'CONSULTAR':
		case 'ALTERAR'  : //quando for alterar e consultar carrega o mesmo form
				carregaPropriedadesFormPrestVida();
			break;
		case 'CONSULTAR_NOVO':
			carregaPropriedadesFormPrestVidaNovo();
			break;
		case 'TI':		
			carregaPropriedadesFormPrestVida();
			// Carrega o titular da conta
			carregaTitular(nmresseg);
			break;
		case 'I':	
				// Aumenta tamanho do div onde o conteúdo da opção será visualizado
				carregaCombo();
			break;			

        case 'C_AUTO_N':    // SEGURO AUTO NOVO

            $('#divConteudoOpcao,#tableJanela').css({'height':'450px','width':'540px'});
            var cTodosAutoNovo  = $('input','#frmAutoNovo');

            var cNmsegurado     = $('#nmsegurado'   ,'#frmAutoNovo');
            var cTpdoseguro     = $('#tpdoseguro'   ,'#frmAutoNovo');
            var cNmsegura       = $('#nmsegura'     ,'#frmAutoNovo');
            var cDtinivig       = $('#dtinivig'     ,'#frmAutoNovo');
            var cDtfimvig       = $('#dtfimvig'     ,'#frmAutoNovo');
            var cNrproposta     = $('#nrproposta'   ,'#frmAutoNovo');
            var cNrapolice      = $('#nrapolice'    ,'#frmAutoNovo');
            var cNrendosso      = $('#nrendosso'    ,'#frmAutoNovo');
            var cTpendosso      = $('#tpendosso'    ,'#frmAutoNovo');
            var cTpsub_endosso  = $('#tpsub_endosso','#frmAutoNovo');
            var cNmmarca        = $('#nmmarca'      ,'#frmAutoNovo');
            var cDsmodelo       = $('#dsmodelo'     ,'#frmAutoNovo');
            var cDschassi       = $('#dschassi'     ,'#frmAutoNovo');
            var cDsplaca        = $('#dsplaca'      ,'#frmAutoNovo');
            var cNranofab       = $('#nranofab'     ,'#frmAutoNovo');
            var cNranomod       = $('#nranomod'     ,'#frmAutoNovo');
            var cVlfranquia     = $('#vlfranquia'   ,'#frmAutoNovo');
            var cVlpremioliq    = $('#vlpremioliq'  ,'#frmAutoNovo');
            var cVlpremiotot    = $('#vlpremiotot'  ,'#frmAutoNovo');
            var cQtparcelas     = $('#qtparcelas'   ,'#frmAutoNovo');
            var cVlparcela      = $('#vlparcela'    ,'#frmAutoNovo');
            var cDiadodebito    = $('#diadodebito'  ,'#frmAutoNovo');
            var cPercomissao    = $('#percomissao'  ,'#frmAutoNovo');

            var rNmsegurado     = $('label[for="nmsegurado"]'   ,'#frmAutoNovo');
            var rTpdoseguro     = $('label[for="tpdoseguro"]'   ,'#frmAutoNovo');
            var rNmsegura       = $('label[for="nmsegura"]'     ,'#frmAutoNovo');
            var rDtinivig       = $('label[for="dtinivig"]'     ,'#frmAutoNovo');
            var rDtfimvig       = $('label[for="dtfimvig"]'     ,'#frmAutoNovo');
            var rNrproposta     = $('label[for="nrproposta"]'   ,'#frmAutoNovo');
            var rNrapolice      = $('label[for="nrapolice"]'    ,'#frmAutoNovo');
            var rNrendosso      = $('label[for="nrendosso"]'    ,'#frmAutoNovo');
            var rTpendosso      = $('label[for="tpendosso"]'    ,'#frmAutoNovo');
            var rTpsub_endosso  = $('label[for="tpsub_endosso"]','#frmAutoNovo');
            var rNmmarca        = $('label[for="nmmarca"]'      ,'#frmAutoNovo');
            var rDsmodelo       = $('label[for="dsmodelo"]'     ,'#frmAutoNovo');
            var rDschassi       = $('label[for="dschassi"]'     ,'#frmAutoNovo');
            var rDsplaca        = $('label[for="dsplaca"]'      ,'#frmAutoNovo');
            var rNranofab       = $('label[for="nranofab"]'     ,'#frmAutoNovo');
            var rNranomod       = $('label[for="nranomod"]'     ,'#frmAutoNovo');
            var rVlfranquia     = $('label[for="vlfranquia"]'   ,'#frmAutoNovo');
            var rVlpremioliq    = $('label[for="vlpremioliq"]'  ,'#frmAutoNovo');
            var rVlpremiotot    = $('label[for="vlpremiotot"]'  ,'#frmAutoNovo');
            var rQtparcelas     = $('label[for="qtparcelas"]'   ,'#frmAutoNovo');
            var rVlparcela      = $('label[for="vlparcela"]'    ,'#frmAutoNovo');
            var rDiadodebito    = $('label[for="diadodebito"]'  ,'#frmAutoNovo');
            var rPercomissao    = $('label[for="percomissao"]'  ,'#frmAutoNovo');


            cTodosAutoNovo.addClass('campo');
            // Area 1
            rNmsegurado.addClass('rotulo-linha').css('width', '65px');
            rTpdoseguro.addClass('rotulo-linha').css('width', '100px');
            cNmsegurado.css('width', '255px');
            cTpdoseguro.css('width', '80px');
            // Area 2
            cNmsegura.css('width', '330px');
            cDtinivig.css('width', '70px');
            cDtfimvig.css('width', '70px');
            cNrproposta.css('width', '130px');
            cNrapolice.css('width', '130px');
            cNrendosso.css('width', '130px');
            cTpendosso.css('width', '195px');
            cTpsub_endosso.css('width', '195px');
            rNmsegura.addClass('rotulo-linha').css('width', '96px');
            rDtinivig.addClass('rotulo-linha').css('width', '97px');
            rNrproposta.addClass('rotulo-linha').css('width', '96px');
            rNrendosso.addClass('rotulo-linha').css('width', '96px');
            rDtfimvig.addClass('rotulo-linha').css('width', '138px');
            rNrapolice.addClass('rotulo-linha').css('width', '79px');
            rTpendosso.addClass('rotulo-linha').css('width', '79px');
            rTpsub_endosso.addClass('rotulo').css('width', '314px');
            // Area 3
            cNmmarca.css('width', '140px');
            cDschassi.css('width', '140px');
            cNranofab.css('width', '40px');
            cDsmodelo.css('width', '248px');
            cDsplaca.css('width', '70px');
            cNranomod.css('width', '40px');
            rNmmarca.addClass('rotulo-linha').css('width', '55px');
            rDschassi.addClass('rotulo-linha').css('width', '55px');
            rNranofab.addClass('rotulo-linha').css('width', '55px');
            rDsmodelo.addClass('rotulo-linha').css('width', '57px');
            rDsplaca.addClass('rotulo-linha').css('width', '57px');
            rNranomod.addClass('rotulo-linha').css('width', '157px');
            // Area 4
            cVlfranquia.css('width', '75px').css('text-align', 'right');
            cVlpremioliq.css('width', '75px').css('text-align', 'right');
            cQtparcelas.css('width', '50px').css('text-align', 'right');
            cDiadodebito.css('width', '50px').css('text-align', 'right');
            cVlpremiotot.css('width', '75px').css('text-align', 'right');
            cVlparcela.css('width', '75px').css('text-align', 'right');
            cPercomissao.css('width', '40px').css('text-align', 'right');

            rVlfranquia.addClass('rotulo-linha').css('width', '190px');
            rVlpremioliq.addClass('rotulo-linha').css('width', '190px');
            rQtparcelas.addClass('rotulo-linha').css('width', '190px');
            rDiadodebito.addClass('rotulo-linha').css('width', '190px');
            rVlpremiotot.addClass('rotulo-linha').css('width', '95px');
            rVlparcela.addClass('rotulo-linha').css('width', '120px');
            rPercomissao.addClass('rotulo-linha').css('width', '120px');

            cTodosAutoNovo.desabilitaCampo();

            break;
		case 'C_AUTO':
            $('#divConteudoOpcao,#tableJanela').css({'height':'210px','width':'500px'});
		
            var cTodos    = $('#nmresseg,#dsmarvei,#dstipvei,#nranovei,#nrmodvei,#nrdplaca,#dtinivig,#dtfimvig,#qtparcel,#vlpreseg,#dtdebito,#vlpremio','#frmAuto');
			var cNmresseg = $('#nmresseg','#frmAuto');
			var cDsmarvei = $('#dsmarvei','#frmAuto');
			var cDstipvei = $('#dstipvei','#frmAuto');
			var cNranovei = $('#nranovei','#frmAuto');
			var cNrmodvei = $('#nrmodvei','#frmAuto');
			var cNrdplaca = $('#nrdplaca','#frmAuto');
			var cDtinivig = $('#dtinivig','#frmAuto');
			var cDtfimvig = $('#dtfimvig','#frmAuto');
			var cQtparcel = $('#qtparcel','#frmAuto');
			var cVlpreseg = $('#vlpreseg','#frmAuto');
			var cDtdebito = $('#dtdebito','#frmAuto');
			var cVlpremio = $('#vlpremio','#frmAuto');
			
			var rNmresseg = $('label[for="nmresseg"]','#frmAuto');
			var rDsmarvei = $('label[for="dsmarvei"]','#frmAuto');
			var rDstipvei = $('label[for="dstipvei"]','#frmAuto');
			var rNranovei = $('label[for="nranovei"]','#frmAuto');
			var rNrmodvei = $('label[for="nrmodvei"]','#frmAuto');
			var rNrdplaca = $('label[for="nrdplaca"]','#frmAuto');
			var rDtinivig = $('label[for="dtinivig"]','#frmAuto');
			var rDtfimvig = $('label[for="dtfimvig"]','#frmAuto');
			var rQtparcel = $('label[for="qtparcel"]','#frmAuto');
			var rVlpreseg = $('label[for="vlpreseg"]','#frmAuto');
			var rDtdebito = $('label[for="dtdebito"]','#frmAuto');
			var rVlpremio = $('label[for="vlpremio"]','#frmAuto');
			
			cTodos.addClass('campo');
			
			rNmresseg.addClass('rotulo').css('width', '80px');
			cNmresseg.addClass('rotulo').css('width', '400px');
			rDsmarvei.addClass('rotulo').css('width', '80px');
			cDsmarvei.addClass('rotulo').css('width', '157px');
			rDstipvei.css('width', '70px');
			cDstipvei.css('width', '170px');
			rNranovei.addClass('rotulo').css('width', '80px');
			cNranovei.addClass('rotulo').css('width', '74px');
			rNrmodvei.css('width', '70px');
			cNrmodvei.css('width', '90px');
			rNrdplaca.css('width', '70px');
			cNrdplaca.css('width', '90px');
			
			rDtinivig.addClass('rotulo').css('width', '73px');
			cDtinivig.addClass('rotulo').css('width', '157px');
			rDtfimvig.css('width', '70px');
			cDtfimvig.css('width', '170px');
			
			rQtparcel.addClass('rotulo').css('width', '80px');
			cQtparcel.addClass('rotulo').css('width', '157px');
			rVlpreseg.css('width', '70px');
			cVlpreseg.css('width', '170px');
			rDtdebito.addClass('rotulo').css('width', '80px');
			cDtdebito.addClass('rotulo').css('width', '157px');
			rVlpremio.css('width', '70px');
			cVlpremio.css('width', '170px');
			
			
			cNmresseg.val(arraySeguroAuto['nmresseg']);
			cDsmarvei.val(arraySeguroAuto['dsmarvei']);
			cDstipvei.val(arraySeguroAuto['dstipvei']);
			cNranovei.val(arraySeguroAuto['nranovei']);
			cNrmodvei.val(arraySeguroAuto['nrmodvei']);
			cNrdplaca.val(arraySeguroAuto['nrdplaca']);
			cDtinivig.val(arraySeguroAuto['dtinivig']);
			cDtfimvig.val(arraySeguroAuto['dtfimvig']);
			cQtparcel.val(arraySeguroAuto['qtparcel']);
			cVlpreseg.val(arraySeguroAuto['vlpreseg']);
			cDtdebito.val(arraySeguroAuto['dtdebito']);
			cVlpremio.val(arraySeguroAuto['vlpremio']);
			
			cTodos.desabilitaCampo();
			
			break;

		case 'SEGUR':
			$('#divConteudoOpcao,#tableJanela').css({'height':'100px','width':'500px'});
				var divRegistro = $('#divSeguradoras');		
				var divBotoes = $('#divBotoes');		
				
				var tabela      = $('table', divRegistro );
				
				divRegistro.css({'height':'50px','border-bottom':'1px solid #777777'});
				
				var ordemInicial = new Array();
				ordemInicial = [[0,0]];
				
				var arrayLargura = new Array();
				arrayLargura[0] = '50px';
						
				var arrayAlinha = new Array();
				arrayAlinha[0] = 'right';
				arrayAlinha[1] = 'left';
				tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
				
			break;
		case 'I_CASA':
			 // Inclusão do seguro do tipo casa
			$('#divConteudoOpcao,#tableJanela').css({'height':'100px','width':'515px'});
			divRotina = $('#divRotina');
			idRotina = $('#divRotina');
		
			var frmSeguroCasa = $('#frmSeguroCasa');
			var divPart2 = $('#part_2');
			var divPart3 = $('#part_3');
			var divBotoes = $('#divBotoes');
			var cTodos = $('#nmresseg, #nrctrseg, #tpplaseg, #dstipseg, #ddpripag, #ddvencto, #vlpreseg, #dtinivig, #dtfimvig, #flgclabe, #nmbenvid, #dtcancel, #dsmotcan, #nrcepend, #dsendres, #nrendere, #complend, #nmbairro, #nmcidade, #cdufresd, #nrcepend2, #dsendres2, #nrendere2, #complend2, #nmbairro2, #nmcidade2, #cdufresd2' ,frmSeguroCasa);
			var cTodosPart2 = $('input',divPart2);
			var cTodosPart3 = $('input',divPart3);
			
			var btVoltar = $('#btVoltar', divBotoes);
			var btContinuar = $('#btContinuar', divBotoes);
			var btContinuarSalvar = $('#btContinuarSalvar', divBotoes);			
			btContinuarSalvar.css({'display':'none'});
						
			// Labels
			rNmresseg = $('label[for="nmresseg"]', frmSeguroCasa);
			rNrctrseg = $('label[for="nrctrseg"]', frmSeguroCasa);
			rTpplaseg = $('label[for="tpplaseg"]', frmSeguroCasa);
			rDstipseg = $('label[for="dstipseg"]', frmSeguroCasa);
			rDdpripag = $('label[for="ddpripag"]', frmSeguroCasa);  
			rDdvencto = $('label[for="ddvencto"]', frmSeguroCasa); 
			rVlpreseg = $('label[for="vlpreseg"]', frmSeguroCasa); 
			rDtinivig = $('label[for="dtinivig"]', frmSeguroCasa); 
			rDtfimvig = $('label[for="dtfimvig"]', frmSeguroCasa); 
			rFlgclabe = $('label[for="flgclabe"]', frmSeguroCasa); 
			rNmbenvid = $('label[for="nmbenvid"]', frmSeguroCasa);
			rDtcancel = $('label[for="dtcancel"]', frmSeguroCasa); 
			rDsmotcan = $('label[for="dsmotcan"]', frmSeguroCasa); 
			rLocrisco = $('label[for="locrisco"]', frmSeguroCasa); 
			rNrcepend = $('label[for="nrcepend"]', frmSeguroCasa);
			rDsendres = $('label[for="dsendres"]', frmSeguroCasa); 
			rNrendere = $('label[for="nrendere"]', frmSeguroCasa); 
			rComplend = $('label[for="complend"]', frmSeguroCasa); 
			rNmbairro = $('label[for="nmbairro"]', frmSeguroCasa); 
			rNmcidade = $('label[for="nmcidade"]', frmSeguroCasa); 
			rCdufresd = $('label[for="cdufresd"]', frmSeguroCasa);
			rEndcorre = $('label[for="endcorre"]', frmSeguroCasa); 
			rTpendcor = $('label[for="tpendcor"]', frmSeguroCasa);
			rNrcepend2 = $('label[for="nrcepend2"]', frmSeguroCasa);
			rDsendres2 = $('label[for="dsendres2"]', frmSeguroCasa); 
			rNrendere2 = $('label[for="nrendere2"]', frmSeguroCasa); 
			rComplend2 = $('label[for="complend2"]', frmSeguroCasa); 
			rNmbairro2 = $('label[for="nmbairro2"]', frmSeguroCasa); 
			rNmcidade2 = $('label[for="nmcidade2"]', frmSeguroCasa); 
			rCdufresd2 = $('label[for="cdufresd2"]', frmSeguroCasa);
					
			// Campos
			cNmresseg = $('#nmresseg', frmSeguroCasa); 
			cNrctrseg = $('#nrctrseg', frmSeguroCasa);
			cTpplaseg = $('#tpplaseg', frmSeguroCasa);
			cDdpripag = $('#ddpripag', frmSeguroCasa);  
			cDdvencto = $('#ddvencto', frmSeguroCasa);  
			cVlpreseg = $('#vlpreseg', frmSeguroCasa); 
			cDtinivig = $('#dtinivig', frmSeguroCasa); 
			cDtfimvig = $('#dtfimvig', frmSeguroCasa);  
			cFlgclabe = $('#flgclabe', frmSeguroCasa);
			var cFlgclabeN = $('#flgclabeN', frmSeguroCasa);
			var cFlgclabeS = $('#flgclabeS', frmSeguroCasa);
			cNmbenvid = $('#nmbenvid', frmSeguroCasa);  
			cDtcancel = $('#dtcancel', frmSeguroCasa);  
			cDsmotcan = $('#dsmotcan', frmSeguroCasa);  
			cNrcepend = $('#nrcepend', frmSeguroCasa);  
			cDsendres = $('#dsendres', frmSeguroCasa);  
			cNrendere = $('#nrendere', frmSeguroCasa);  
			cComplend = $('#complend', frmSeguroCasa); 
			cNmbairro = $('#nmbairro', frmSeguroCasa);  
			cNmcidade = $('#nmcidade', frmSeguroCasa);  
			cCdufresd = $('#cdufresd', frmSeguroCasa);
			cTpendcor1 = $('#tpendcor1', frmSeguroCasa);  
			cTpendcor2 = $('#tpendcor2', frmSeguroCasa);  
			cTpendcor3 = $('#tpendcor3', frmSeguroCasa);  
			cNrcepend2 = $('#nrcepend2', frmSeguroCasa);  
			cDsendres2 = $('#dsendres2', frmSeguroCasa);  
			cNrendere2 = $('#nrendere2', frmSeguroCasa);  
			cComplend2 = $('#complend2', frmSeguroCasa);  
			cNmbairro2 = $('#nmbairro2', frmSeguroCasa);  
			cNmcidade2 = $('#nmcidade2', frmSeguroCasa);  
			cCdufresd2 = $('#cdufresd2', frmSeguroCasa);
					
			divPart2.css({'margin':'15px 5px 5px 5px','float':'left','width':'490px'});
			divPart3.css({'margin':'5px 5px 5px 5px','float':'left','width':'490px'});
			
			$('span', frmSeguroCasa).css('background','#ddd');
			
			// 1ª linha
			rNmresseg.addClass('rotulo').css({'width':'500px','text-align':'center','margin':'10px 0'});
			rNmresseg.html('Seguradora: '+nmsegura);
			cNmresseg.val(nmsegura);
			
			// 2ª linha
			rNrctrseg.addClass('rotulo').css({'width':'70px','text-align':'left','margin-left':'80px'});			
			cNrctrseg.addClass('inteiro').css({'width':'80px'});			
			cNrctrseg.addClass('rotulo').setMask('INTEGER','zz.zzz.zz9','','');
						
			rTpplaseg.css({'width':'45px','text-align':'left','margin-left':'15px'});
			cTpplaseg.css({'width':'40px','text-align':'left'});
			cTpplaseg.addClass('rotulo').setMask('INTEGER','zz9','','');
			cTpplaseg.attr('maxlength','3');
			rDstipseg.css({'width':'65px','text-align':'left','margin-left':'15px'});
					
			// 3ª linha
			rDdpripag.addClass('rotulo').css({'width':'120px','text-align':'left'});
			cDdpripag.addClass('inteiro').css({'width':'30px','text-align':'left','float':'left'}).attr('maxlength','2');
			rDdvencto.css({'width':'140px','text-align':'left','margin-left':'167px'});
			
			//cDdvencto.css({'width':'23px','text-align':'left'}).dateEntry({dateFormat: 'd '});			
			//$(".dateEntry_control").css("width","0 px");
			cDdvencto.css({'width':'23px','text-align':'left'}).attr('maxlength','2');
			
			// 4ª linha
			rVlpreseg.addClass('rotulo').css({'width':'120px','text-align':'left'});
			cVlpreseg.css({'width':'100px'});
			
			// 5ª linha
			rDtinivig.addClass('rotulo').css({'width':'120px','text-align':'left'});
			cDtinivig.addClass('data').css({'width':'65px','text-align':'left', 'float':'left'});
			rDtfimvig.css({'width':'140px','text-align':'right','margin-left':'91px'});
			cDtfimvig.addClass('data').css({'width':'65px','text-align':'left'});
			
			// 6ª linha
			rFlgclabe.addClass('rotulo').css({'width':'120px','text-align':'left'});
			cFlgclabeN.css({'border':'none', 'background':'#ddd'});
			cFlgclabeS.css({'border':'none', 'background':'#ddd'});
			rNmbenvid.css({'margin-left':'5px'});
			cNmbenvid.css({'width':'172px'});
			cNmbenvid.attr('maxlength','40')
			
			// 7ª linha
			rDtcancel.addClass('rotulo').css({'width':'120px','text-align':'left'});
			cDtcancel.addClass('data').css({'width':'65px','float':'left'});
			
			rDsmotcan.css({'margin-left':'34px'});
			cDsmotcan.css({'width':'223px'});
			
			// 8ª linha
			rLocrisco.addClass('rotulo').css({'width':'500px','text-align':'center', 'margin':'10px 0'});
			
			// 9ª linha
			rNrcepend.addClass('rotulo').css({'width':'42px','text-align':'right'});
			cNrcepend.addClass('cep').css({'width':'65px'});
			rDsendres.css({'width':'25px','margin-left':'10px','text-align':'right'});
			cDsendres.css({'width':'248px','text-align':'left'});
			rNrendere.css({'width':'20px','margin-left':'10px','text-align':'right'});
			cNrendere.addClass('inteiro').css({'width':'40px','text-align':'left'});
			
			rComplend.css({'width':'42px','text-align':'right'});
			cComplend.css({'width':'371px','text-align':'left'});
			
			// 10ª linha
			rNmbairro.addClass('rotulo').css({'width':'42px','text-align':'right'});
			
			// 11ª linha
			rNmcidade.css({'width':'50px','text-align':'right'});
			cNmcidade.css({'width':'183px'});
			
			rCdufresd.css({'margin-left':'10px'});
			cCdufresd.css({'width':'40px','text-align':'right'});
				
			// 12ª linha - part 3
			rEndcorre.addClass('rotulo').css({'width':'500px','text-align':'center', 'margin':'10px 0'});
			
			// 13ª linha - part 3
			rTpendcor.addClass('rotulo').css({'width':'120px','text-align':'left', 'margin-left':'40px'});
			cTpendcor1.css({'border':'none'}).habilitaCampo();
			cTpendcor2.css({'border':'none'}).habilitaCampo();
			cTpendcor3.css({'border':'none'}).habilitaCampo();
			
			// 14ª linha - part 3
			rNrcepend2.addClass('rotulo').css({'width':'42px','text-align':'right'});
			cNrcepend2.addClass('cep').css({'width':'65px'});
			rDsendres2.css({'width':'25px','margin-left':'10px','text-align':'right'});
			cDsendres2.css({'width':'268px','text-align':'left'});
			
			rNrendere2.css({'width':'20px','margin-left':'10px','text-align':'right'});
			cNrendere2.addClass('inteiro').css({'width':'40px','text-align':'left'});
			
			rComplend2.css({'width':'42px','text-align':'right'});
			cComplend2.css({'width':'371px','text-align':'left'});
			
			// 15ª linha - part 3
			rNmbairro2.addClass('rotulo').css({'width':'42px','text-align':'right'});
			
			// 16ª linha - part 3
			rNmcidade2.css({'width':'50px','text-align':'right'});
			cNmcidade2.css({'width':'183px'});
			
			rCdufresd2.css({'margin-left':'10px'});
			cCdufresd2.css({'width':'40px','text-align':'right'});			
			
			cNrctrseg.habilitaCampo();
			cNrctrseg.focus();
			
			cTpplaseg.habilitaCampo();
			
			// Desabilita os campos que fazem parte da segunda parte do cadastro
			cTodosPart2.desabilitaCampo();
			$('#dsendres', divPart2).habilitaCampo();
			cTodosPart3.desabilitaCampo();
			divPart2.css({'display':'none'});
			divPart3.css({'display':'none'});
			
			if ( $.browser.msie ) {
				cNmbenvid.css({'width':'157px'});
				cDsmotcan.css({'width':'222px'});
				
				cDsendres.css({'width':'248px'});
				rNrendere.css({'margin-left':'7px'});
				rCdufresd.css({'margin-left':'4px'});
				cNmcidade.css({'width':'190px'});
				
				cDsendres2.css({'width':'266px'});
				cComplend2.css({'width':'369px'});
				cNmcidade2.css({'width':'188px'});
				rCdufresd2.css({'margin-left':'7px'});
			}
			
			cNrctrseg.unbind('keypress').bind('keypress', function(e) {
				// Se é a tecla ENTER,
				if ( e.keyCode == 13 ) {
					cTpplaseg.focus();
					return false;
				}
			});
			
			cTpplaseg.next().addClass('lupa').css('cursor','pointer');			
			cTpplaseg.unbind('keydown').bind('keydown', function(e) {
							
				if ( divPart2.css('display') == 'block' ) { return false; }
				
				// Se é a tecla ENTER, verificar numero conta e realizar as devidas operações
				if ( e.keyCode == 13) {
					carregaFormCasa();
				}
			});
			
			cDdvencto.unbind('keydown').bind('keydown', function(e) {
				// Se é a tecla ENTER,
				if ( e.keyCode == 13 ) {
					cFlgclabeN.focus();
					return false;
				}
			});			
			
			cFlgclabeN.unbind('click').bind('click', function(e) {
				cNmbenvid.desabilitaCampo();
			});
			
			cFlgclabeN.unbind('keydown').bind('keydown', function(e) {
				// Se é a tecla ENTER,
				if ( e.keyCode == 13 ) {
					cNrcepend.focus();
					return false;
				}
			});
			
			cFlgclabeS.unbind('click').bind('click', function(e) {
				cNmbenvid.habilitaCampo();
			});	
			
			cFlgclabeS.unbind('keydown').bind('keydown', function(e) {
				// Se é a tecla ENTER,
				if ( e.keyCode == 13 ) {
					cNmbenvid.focus();			
					return false;
				}
			});
			
			cNmbenvid.unbind('keydown').bind('keydown', function(e) {
				// Se é a tecla ENTER,
				if ( e.keyCode == 13 ) {
					cNrcepend.focus();
					return false;
				}
			});
			
			cNrendere.unbind('keydown').bind('keydown', function(e) {
				// Se é a tecla ENTER,
				if ( e.keyCode == 13 ) {
					cComplend.focus();
					return false;
				}
			});
			
			cComplend.unbind('keydown').bind('keydown', function(e) {
				// Se é a tecla ENTER,
				if ( e.keyCode == 13 ) {
					validaSeguroGeral('I_CASA', 1);					
					return false;
				}
			});

			// endereço de correspondência - local do risco -1
			cTpendcor1.unbind('click').bind('click', function() {
				$('input', '#part_3').val('');				
				$('#nrcepend2', '#frmSeguroCasa').val($('#nrcepend', '#frmSeguroCasa').val());
				$('#dsendres2', '#frmSeguroCasa').val($('#dsendres', '#frmSeguroCasa').val());
				$('#nrendere2', '#frmSeguroCasa').val($('#nrendere', '#frmSeguroCasa').val());
				$('#complend2', '#frmSeguroCasa').val($('#complend', '#frmSeguroCasa').val());
				$('#nmbairro2', '#frmSeguroCasa').val($('#nmbairro', '#frmSeguroCasa').val());
				$('#nmcidade2', '#frmSeguroCasa').val($('#nmcidade', '#frmSeguroCasa').val());
				$('#cdufresd2', '#frmSeguroCasa').val($('#cdufresd', '#frmSeguroCasa').val());
				$('#tipo_end_correspondencia', '#frmSeguroCasa').val('1');
			});

			cTpendcor1.unbind('keydown').bind('keydown', function(e) {
				// Se é a tecla ENTER,
				if ( e.keyCode == 13 ) {
					validaSeguroGeral('I_CASA', 2);
					return false;
				}
			});
			
			// endereço de correspondência - residencial - 2
			cTpendcor2.unbind('click').bind('click', function() {
				$('input', '#part_3').val('');
				buscarEnderecoCorrespondencia(2);
				$('#tipo_end_correspondencia', '#frmSeguroCasa').val('2');
			});
				
			cTpendcor2.unbind('keydown').bind('keydown', function(e) {
				// Se é a tecla ENTER,
				if ( e.keyCode == 13 ) {
					validaSeguroGeral('I_CASA', 2);
					return false;
				}
			});
			
			// endereço de correspondência - comercial - 3
			cTpendcor3.unbind('click').bind('click', function() {
				$('input', '#part_3').val('');
				buscarEnderecoCorrespondencia(3);
				$('#tipo_end_correspondencia', '#frmSeguroCasa').val('3');
			});			
						
			cTpendcor3.unbind('keydown').bind('keydown', function(e) {
				// Se é a tecla ENTER,
				if ( e.keyCode == 13 ) {
					validaSeguroGeral('I_CASA', 2);
					return false;
				}
			});
			
			btContinuar.css({'display':'none'});
			btContinuarSalvar.css({'display':'none'});
			btVoltar.css({'display':''});
			btVoltar.unbind('click').bind('click', function(){
				controlaOperacao('I');
			});
			
			$('#nrctrseg', '#frmSeguroCasa').focus();
			bloqueiaFundo($('#divUsoGenerico'));
			break;
		case 'C_CASA':
				// inclusão do seguro do tipo casa
				$('#divConteudoOpcao,#tableJanela').css({'height':'340px','width':'515px'});
				
				var frmSeguroCasa = $('#frmSeguroCasa');
				var divPart2 = $('#part_2');
				var divPart3 = $('#part_3');
				var divBotoes = $('#divBotoes');
				var cTodos = $('#nmresseg, #nrctrseg, #tpplaseg, #dstipseg, #ddpripag, #ddvencto, #vlpreseg, #dtinivig, #dtfimvig, #flgclabe, #nmbenvid, #dtcancel, #dsmotcan, #nrcepend, #dsendres, #nrendere, #complend, #nmbairro, #nmcidade, #cdufresd, #nrcepend2, #dsendres2, #nrendere2, #complend2, #nmbairro2, #nmcidade2, #cdufresd2' ,frmSeguroCasa);
				var cTodosPart2 = $('input',divPart2);
				var cTodosPart3 = $('input',divPart3);
				var btContinuarSalvar = $('#btContinuarSalvar', divBotoes);
				btContinuarSalvar.css({'display':'none'});

				var btVoltar = $('#btVoltar', divBotoes);
				btVoltar.click(function(){
					controlaOperacao('');
					return false;
				});
				
				// Labels
				rNmresseg = $('label[for="nmresseg"]', frmSeguroCasa);
				rNrctrseg = $('label[for="nrctrseg"]', frmSeguroCasa);
				rTpplaseg = $('label[for="tpplaseg"]', frmSeguroCasa);
				rDstipseg = $('label[for="dstipseg"]', frmSeguroCasa);
				rDdpripag = $('label[for="ddpripag"]', frmSeguroCasa);  
				rDdvencto = $('label[for="ddvencto"]', frmSeguroCasa); 
				rVlpreseg = $('label[for="vlpreseg"]', frmSeguroCasa); 
				rDtinivig = $('label[for="dtinivig"]', frmSeguroCasa); 
				rDtfimvig = $('label[for="dtfimvig"]', frmSeguroCasa); 
				rFlgclabe = $('label[for="flgclabe"]', frmSeguroCasa); 
				rNmbenvid = $('label[for="nmbenvid"]', frmSeguroCasa);
				rDtcancel = $('label[for="dtcancel"]', frmSeguroCasa); 
				rDsmotcan = $('label[for="dsmotcan"]', frmSeguroCasa); 
				rLocrisco = $('label[for="locrisco"]', frmSeguroCasa); 
				rNrcepend = $('label[for="nrcepend"]', frmSeguroCasa);
				rDsendres = $('label[for="dsendres"]', frmSeguroCasa); 
				rNrendere = $('label[for="nrendere"]', frmSeguroCasa); 
				rComplend = $('label[for="complend"]', frmSeguroCasa); 
				rNmbairro = $('label[for="nmbairro"]', frmSeguroCasa); 
				rNmcidade = $('label[for="nmcidade"]', frmSeguroCasa); 
				rCdufresd = $('label[for="cdufresd"]', frmSeguroCasa);
				rEndcorre = $('label[for="endcorre"]', frmSeguroCasa); 
				rTpendcor = $('label[for="tpendcor"]', frmSeguroCasa);
				rNrcepend2 = $('label[for="nrcepend2"]', frmSeguroCasa);
				rDsendres2 = $('label[for="dsendres2"]', frmSeguroCasa); 
				rNrendere2 = $('label[for="nrendere2"]', frmSeguroCasa); 
				rComplend2 = $('label[for="complend2"]', frmSeguroCasa); 
				rNmbairro2 = $('label[for="nmbairro2"]', frmSeguroCasa); 
				rNmcidade2 = $('label[for="nmcidade2"]', frmSeguroCasa); 
				rCdufresd2 = $('label[for="cdufresd2"]', frmSeguroCasa);
				
				// Campos
				cNmresseg = $('#nmresseg', frmSeguroCasa); 
				cNrctrseg = $('#nrctrseg', frmSeguroCasa);
				cTpplaseg = $('#tpplaseg', frmSeguroCasa);
				cDdpripag = $('#ddpripag', frmSeguroCasa);  
				cDdvencto = $('#ddvencto', frmSeguroCasa);  
				cVlpreseg = $('#vlpreseg', frmSeguroCasa); 
				cDtinivig = $('#dtinivig', frmSeguroCasa); 
				cDtfimvig = $('#dtfimvig', frmSeguroCasa);  
				cFlgclabe = $('#flgclabe', frmSeguroCasa);
				var cFlgclabeN = $('#flgclabeN', frmSeguroCasa);
				var cFlgclabeS = $('#flgclabeS', frmSeguroCasa);
				
				cNmbenvid = $('#nmbenvid', frmSeguroCasa);  
				cDtcancel = $('#dtcancel', frmSeguroCasa);  
				cDsmotcan = $('#dsmotcan', frmSeguroCasa);  
				cNrcepend = $('#nrcepend', frmSeguroCasa);  
				cDsendres = $('#dsendres', frmSeguroCasa);  
				cNrendere = $('#nrendere', frmSeguroCasa);  
				cComplend = $('#complend', frmSeguroCasa);  
				cNmbairro = $('#nmbairro', frmSeguroCasa);  
				cNmcidade = $('#nmcidade', frmSeguroCasa);  
				cCdufresd = $('#cdufresd', frmSeguroCasa);
				cTpendcor1 = $('#tpendcor1', frmSeguroCasa);  
				cTpendcor2 = $('#tpendcor2', frmSeguroCasa);  
				cTpendcor3 = $('#tpendcor3', frmSeguroCasa);  
				cNrcepend2 = $('#nrcepend2', frmSeguroCasa);  
				cDsendres2 = $('#dsendres2', frmSeguroCasa);  
				cNrendere2 = $('#nrendere2', frmSeguroCasa);  
				cComplend2 = $('#complend2', frmSeguroCasa);  
				cNmbairro2 = $('#nmbairro2', frmSeguroCasa);  
				cNmcidade2 = $('#nmcidade2', frmSeguroCasa);  
				cCdufresd2 = $('#cdufresd2', frmSeguroCasa);
				
                cNmresseg.val(arraySeguroCasa['nmresseg']);
				cNrctrseg.val(arraySeguroCasa['nrctrseg']);
				cTpplaseg.val(arraySeguroCasa['tpplaseg']);
				cDdpripag.val(arraySeguroCasa['ddpripag']);
				cDdvencto.val(arraySeguroCasa['ddvencto']);
				cVlpreseg.val(arraySeguroCasa['vlpreseg']);
				cDtinivig.val(arraySeguroCasa['dtinivig']);
				cDtfimvig.val(arraySeguroCasa['dtfimvig']);
				cFlgclabe.val(arraySeguroCasa['flgclabe']);
				cNmbenvid.val(arraySeguroCasa['nmbenvid']);
				cDtcancel.val(arraySeguroCasa['dtcancel']);
				cDsmotcan.val(arraySeguroCasa['dsmotcan']);
				cNrcepend.val(arraySeguroCasa['nrcepend']);
				cDsendres.val(arraySeguroCasa['dsendres']);
				cNrendere.val(arraySeguroCasa['nrendere']);
				cComplend.val(arraySeguroCasa['complend']);
				cNmbairro.val(arraySeguroCasa['nmbairro']);
				cNmcidade.val(arraySeguroCasa['nmcidade']);
				cCdufresd.val(arraySeguroCasa['cdufresd']);
                if(arraySeguroCasa['tpendcor']==1)  cTpendcor1.attr('checked',true);
                else if(arraySeguroCasa['tpendcor']==2) cTpendcor2.attr('checked',true);
                else if(arraySeguroCasa['tpendcor']==3) cTpendcor3.attr('checked',true);
                if(arraySeguroCasa['flgclabe']=='no')   cFlgclabeN.attr('checked',true);
                else if(arraySeguroCasa['flgclabe']=='yes') cFlgclabeS.attr('checked',true);
				
				cTodos.addClass('campo');
				
				divPart2.css({'margin':'15px 5px 5px 5px','float':'left','width':'490px'});
				divPart3.css({'margin':'5px 5px 5px 5px','float':'left','width':'490px'});
				
				// 1ª linha
				rNmresseg.addClass('rotulo').css({'width':'500px','text-align':'center','margin':'10px 0'});
				rNmresseg.html('Seguradora: '+arraySeguroCasa['nmresseg']);
				cNmresseg.val(arraySeguroCasa['nmresseg']);
				
				// 2ª linha
				rNrctrseg.addClass('rotulo').css({'width':'70px','text-align':'left','margin-left':'80px'});
				cNrctrseg.addClass('inteiro').css({'width':'80px'});
				
				rTpplaseg.css({'width':'45px','text-align':'left','margin-left':'15px'});
				cTpplaseg.css({'width':'40px','text-align':'left'});
				
				rDstipseg.css({'width':'65px','text-align':'left','margin-left':'15px'});
				
				// 3ª linha
				rDdpripag.addClass('rotulo').css({'width':'120px','text-align':'left'});
				cDdpripag.addClass('inteiro').css({'width':'30px','text-align':'left','float':'left'}).attr('maxlength','2');
				rDdvencto.css({'width':'140px','text-align':'left','margin-left':'161px'});
				cDdvencto.addClass('inteiro').css({'width':'30px','text-align':'left'}).attr('maxlength','2');
				
				// 4ª linha
				rVlpreseg.addClass('rotulo').css({'width':'120px','text-align':'left'});
				cVlpreseg.css({'width':'100px'});
				
				// 5ª linha
				rDtinivig.addClass('rotulo').css({'width':'120px','text-align':'left'});
				cDtinivig.addClass('data').css({'width':'65px','text-align':'left', 'float':'left'});
				rDtfimvig.css({'width':'140px','text-align':'right','margin-left':'91px'});
				cDtfimvig.addClass('data').css({'width':'65px','text-align':'left'});
				
				// 6ª linha
				rFlgclabe.addClass('rotulo').css({'width':'120px','text-align':'left'});
				cFlgclabeN.css({'border':'none', 'background':'#ddd'});
				cFlgclabeS.css({'border':'none', 'background':'#ddd'});
				rNmbenvid.css({'margin-left':'5px'});
				cNmbenvid.css({'width':'178px'});
				
				// 7ª linha
				rDtcancel.addClass('rotulo').css({'width':'120px','text-align':'left'});
				cDtcancel.addClass('data').css({'width':'65px'});
				rDsmotcan.css({'margin-left':'34px'});
				cDsmotcan.css({'width':'223px'});
				
				// 8ª linha
				rLocrisco.addClass('rotulo').css({'width':'500px','text-align':'center', 'margin':'10px 0'});
				
				// 9ª linha
				rNrcepend.addClass('rotulo').css({'width':'42px','text-align':'right'});
				cNrcepend.addClass('cep pesquisa').css({'width':'65px'}).attr('maxlength','9');
				rDsendres.css({'width':'25px','margin-left':'10px','text-align':'right'});
				cDsendres.css({'width':'248px','text-align':'left'});
				rNrendere.css({'width':'20px','margin-left':'10px','text-align':'right'});
				cNrendere.addClass('inteiro').css({'width':'40px','text-align':'left'});
				
				rComplend.css({'width':'42px','text-align':'right'});
				cComplend.css({'width':'371px','text-align':'left'});
				
				// 10ª linha
				rNmbairro.addClass('rotulo').css({'width':'42px','text-align':'right'});
				
				// 11ª linha
				rNmcidade.css({'width':'50px','text-align':'right'});
				cNmcidade.css({'width':'183px'});
				
				rCdufresd.css({'margin-left':'10px'});
				cCdufresd.css({'width':'40px','text-align':'right'});
				
				// 12ª linha - part 3
				rEndcorre.addClass('rotulo').css({'width':'500px','text-align':'center', 'margin':'10px 0'});
				
				// 13ª linha - part 3
				rTpendcor.addClass('rotulo').css({'width':'120px','text-align':'left', 'margin-left':'40px'});
				if(arraySeguroCasa['tpendcor']==1) cTpendcor1.attr('checked');
				if(arraySeguroCasa['tpendcor']==2) cTpendcor2.attr('checked');
				if(arraySeguroCasa['tpendcor']==3) cTpendcor3.attr('checked');
				cTpendcor1.css({'border':'none'});
				cTpendcor2.css({'border':'none'});
				cTpendcor3.css({'border':'none'});
				
				// 14ª linha - part 3
				rNrcepend2.addClass('rotulo').css({'width':'42px','text-align':'right'});
				cNrcepend2.addClass('cep pesquisa').css({'width':'65px'});
				rDsendres2.css({'width':'25px','margin-left':'10px','text-align':'right'});
				cDsendres2.css({'width':'268px','text-align':'left'});
				
				rNrendere2.css({'width':'20px','margin-left':'10px','text-align':'right'});
				cNrendere2.addClass('inteiro').css({'width':'40px','text-align':'left'});
				
				rComplend2.css({'width':'42px','text-align':'right'});
				cComplend2.css({'width':'371px','text-align':'left'});
				
				// 15ª linha - part 3
				rNmbairro2.addClass('rotulo').css({'width':'42px','text-align':'right'});
				
				// 16ª linha - part 3
				rNmcidade2.css({'width':'50px','text-align':'right'});
				cNmcidade2.css({'width':'183px'});
				
				rCdufresd2.css({'margin-left':'10px'});
				cCdufresd2.css({'width':'40px','text-align':'right'});
				
				// desabilito os campos que fazem parte da segunda parte do cadastro
				cTodos.desabilitaCampo();
				cTodosPart2.desabilitaCampo();
				cTodosPart3.desabilitaCampo();
				divPart3.css({'display':'none'});
				
				if ( $.browser.msie ) {
					cNmbenvid.css({'width':'157px'});
					cDsmotcan.css({'width':'222px'});
					
					cDsendres.css({'width':'248px'});
					rNrendere.css({'margin-left':'7px'});
					rCdufresd.css({'margin-left':'4px'});
					cNmcidade.css({'width':'190px'});
					
					cDsendres2.css({'width':'266px'});
					cComplend2.css({'width':'369px'});
					cNmcidade2.css({'width':'188px'});
					rCdufresd2.css({'margin-left':'7px'});
				}
				
				if(arraySeguroCasa['tpendcor'] > 1){
					// Atribui o endereço de correspondência de acordo com o tipo
					buscarEnderecoCorrespondencia(arraySeguroCasa['tpendcor']);
				}else{
					cCdufresd2.val(cCdufresd.val());	
					cNrcepend2.val(cNrcepend.val());
					cDsendres2.val(cDsendres.val());
					cNrendere2.val(cNrendere.val());
					cComplend2.val(cComplend.val());
					cNmcidade2.val(cNmcidade.val());
					cNmbairro2.val(cNmbairro.val());
				}
				
				$('#btCarregaForm', '#botaoOk').css({'display':'none'});
				
				cTpplaseg.next().addClass('lupa').css('cursor','auto').unbind('click').bind('click', function() { return false; });
				cNrcepend.next().addClass('lupa').css('cursor','auto').unbind('click').bind('click', function() { return false; });
				
				cNrcepend.addClass('cep').css({'width':'65px'}).attr('maxlength','9');
				
				$('#btContinuar', '#divBotoes').focus();				
			break;
		case 'C':	
				var frmMotivo = $('#frmMotivo');
				frmMotivo.css({'width':'354px'});
				var rCdMotcan = $('label[for="rCdMotcan"]',frmMotivo);
				var cCdMotcan = $('#cdmotcan',frmMotivo);
				var cDsmotcan = $('#dsmotcan',frmMotivo);
				
				cCdMotcan.addClass('campo').css({'width':'45px'}).attr('maxlength','2');
				rCdMotcan.addClass('rotulo').css({'width':'80px'});
				cDsmotcan.addClass('campo').css({'width':'200px', 'border':'1px solid #777'}).desabilitaCampo();

				cCdMotcan.val('');
				cCdMotcan.focus();
			break;
		default:
                $('#divConteudoOpcao,#tableJanela').css({'height':'210px','width':'560px'});
				var divRegistro = $('#divSeguro');		
				var tabela      = $('table', divRegistro );
				
				divRegistro.css('height','150px');
				
				var ordemInicial = new Array();
                //ordemInicial = [[0,0]];
				
				var arrayLargura = new Array();
                arrayLargura[0] = '38px';   // Coluna Tipo
                arrayLargura[1] = '96px';   // Coluna Apolice
                arrayLargura[2] = '85px';   // Coluna Ini Vigencia
                arrayLargura[3] = '85px';   // Coluna Fim Vigencia
                arrayLargura[4] = '110px';  // Coluna Seguradora
				
				var arrayAlinha = new Array();
				arrayAlinha[0] = 'right';
				arrayAlinha[1] = 'right';
				arrayAlinha[2] = 'right';
				arrayAlinha[3] = 'right';
				arrayAlinha[4] = 'right';
				arrayAlinha[5] = 'right';
				
				tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
				
				hideMsgAguardo();
				removeOpacidade('divConteudoOpcao');
				bloqueiaFundo($('#divUsoGenerico'));
	}	
	
	layoutPadrao();	
	return false;
}

function formataCep(){
	var cep = cNrcepend.val();
	if(cep.length == 9)
		cNrcepend.val(cep);
	else {
		cNrcepend.val(cep.substr(0, 5) + '-' + cep.substr(5, 3));
		cep = cNrcepend2.val();
		cNrcepend2.val(cep.substr(0, 5) + '-' + cep.substr(5, 3));
	}
}

// Carrega o combo com os tipos de seguro
function carregaCombo(){
	$('#divConteudoOpcao,#tableJanela').css({'height':'80px','width':'200px'});
	
	$('#tableJanela').css('display','none');
	// Executa script de através de ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		data:{nrdconta: nrdconta,redirect: 'script_ajax'},
		url: UrlSite + 'telas/atenda/seguro/busca_tipo.php', 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possivel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
				erros = response.split('-');
				if(erros[0] == 513){
					hideMsgAguardo();
					showError('error',response,'Alerta - Aimaro','');
				}else{
					
					$('#tableJanela').css('display','block');
					$('#tpemprst').html(response);	
					
					if(tpseguro){
						$('#tpemprst').val(tpseguro);	
					}
					
					if (executandoProdutos) {
						
						if (cdproduto == 19) {
							$('#tpemprst').val(11);
						} else if (cdproduto == 18) {
							$('#tpemprst').val(3);
						}
						
						controlaOperacao('TF');
						
					}
					
				}
		}				
	});		
}

function validaAssociados(){
	// Executa script de através de ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		data:{nrdconta: nrdconta,redirect: 'script_ajax'},
		url: UrlSite + 'telas/atenda/seguro/verifica_associados.php', 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possivel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
					if ( response.indexOf('showError("error"') == -1 ) {
						eval(response);
						controlaOperacao('BUSCAEND');
					}else{
						eval(response);
						return false;
					}
				}	
	});		
	
}
// Busca valores do seguro
function buscaSeg(operacao){
		var tpplaseg = $('#tpplaseg').val();
		$.ajax({
		type: 'POST',
		dataType: 'html',
		data:{nrdconta: nrdconta,tpseguro:tpseguro,tpplaseg:tpplaseg,
			  redirect: 'script_ajax'},
		url: UrlSite + 'telas/atenda/seguro/busca_seguro.php', 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possivel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
					if ( response.indexOf('showError("error"') == -1 ) {
						eval(response);
						if(operacao == 'ATUALIZASEG'){
							 showConfirmacao('Deseja continuar a opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Aimaro','controlaOperacao("'+operacao+'");showMsgAguardo("Aguarde,processando . . ." );','controlaOperacao("")','sim.gif','nao.gif'); 
							 return false;
						}
						showConfirmacao('Deseja continuar a opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Aimaro','controlaOperacao("'+operacao+'");showMsgAguardo("Aguarde,processando . . ." );','controlaOperacao(\'BTF\')','sim.gif','nao.gif'); 
						return false;
					}else{
						eval(response);
						return false;
					}
				}
	});
}

// Função que retorna os valores correspondentes ao endereço
function buscaEnd(){
	// Executa script de através de ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		data:{nrdconta: nrdconta,redirect: 'script_ajax'},
		url: UrlSite + 'telas/atenda/seguro/busca_endereco.php', 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possivel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
					if ( response.indexOf('showError("error"') == -1 ) {
						eval(response);
						if(!consultar){
							controlaOperacao('VALTF');
						}
					}else{
						eval(response);
						return false;
					}
				}
	});
}
function setaFormularioSeguroVolta(){
	// Caso os valores nao sejem vazios
	if(cdsexosg && nmresseg){
		$('#nmresseg').val(nmresseg);
		carregaTitular(nmresseg);
		if(cdsexosg == 1){
			$('#cdsexosg-1').attr('checked','checked');
		}else{
			$('#cdsexosg-2').attr('checked','checked');		
		}
		$('#cdsitdct').val(cdsitdct);
		$('#nmprimtl').val(nmprimtl);
		$('#nmprimtl').val(nmprimtl);
		$('#tipo').val(tpseguro);		
		$('#inpessoa').val(inpessoa);		
		$('#tpseguro').html(tipo_seguro_text);
		$('#nrctrseg').val(nrctrseg);
	}
}

// carrega form do form_seguro
function carregaForm(){
	$('#divConteudoOpcao,#tableJanela').css({'height':'200px','width':'460px'});
	setaFormularioSeguroVolta();
	
	cTodos.addClass('campo');
	$('#tableJanela').css('width','500px');
	$('#tableJanela').css('display','none');
	// Efetua alterações no tamanho do campo
	$('#tpseguro').css('width','50px');
	$('#cdsexosg').css('width','25px');
	$('#nmdsegur').css('width','350px');
	$('#cdsexosg').css('text-align','center');
	
	// Desabilita os campos do form
	$('#cdsexosg').attr('maxlength','1').addClass('inteiro');
	$('#nmdsegur,#nrcpfcgc,#dtnascsg,#seguradora').desabilitaCampo();
	$('#nrcpfcgc', '#forSeguro').desabilitaCampo();
	
	// Executa script de através de ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		data:{nrdconta: nrdconta,redirect: 'script_ajax'},
		url: UrlSite + 'telas/atenda/seguro/carrega_form_seguro.php', 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possivel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
		},
		success: function(response) {			
				$('#tableJanela').css('display','block');					
		}				
	});		
}
/*carrega o titular da conta,passando o valor de conjuge ou p-titular*/
function carregaTitular(value){

	// Reseta os valores do formulário*
	$('#nmdsegur').val('');
    
	$('#nrcpfcgc', '#forSeguro').val('');
	$('#dtnascsg').val('');
	
    var page = null;
	if(value == 'conjuge'){
		$.ajax({
				type: 'POST',
				dataType: 'html',
				data:{ 
					nrdconta: nrdconta, redirect: 'script_ajax'
				},
				url: UrlSite + 'telas/atenda/seguro/busca_inf_conjuge.php', 
				error: function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi possivel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
				},
				success: function(response) {
						eval(response);
				}
		});	
	}else if(value == 'p-titular'){
    
		$('#nmdsegur').val(nmdsegurC);
    
		$('#nrcpfcgc', '#forSeguro').val(nrcpfcgcC);
		$('#dtnascsg').val(dtnascsgC);
		$('#nrcpfcgc', '#forSeguro').desabilitaCampo();
		dtnascsg = dtnascsgC;
		nrcpfcgc = nrcpfcgcC;
		if(cdsexotl == 1)
			$('#cdsexosg-1').click();
		else if(cdsexotl == 2)
			$('#cdsexosg-2').click();
	}
		
}

// Carrega formulário de cadastro de prestamista e vida
function carregaPropriedadesFormPrestVida(){
	
	$('#frmNovo label').addClass('rotulo');
	$('.not').removeClass('rotulo');	
	
	// Seta o tamnho dos label
	$('#dssitseg').css({'width':'300px'});
	$('label[for="dtinivig"]').css('width','300px');
	
	
	$('label[for="dtfimvig"]').css('width','300px');
	$('label[for="vlcapseg"]').css('width','300px');
	$('label[for="dtcancel"]').css('width','340px');
	$('label[for="dtdebito"]').css('width','300px');
    $('label[for="ddvencto"]').css('width','300px');
	$('label[for="tpplaseg"]').css('width','253px');
	$('#nmdsegur').css('width','320px');	
	
	var part,ben,parent = ''; //inicializa as variáveis
	for(var i = 1; i<= 5; i++){
		part    += ',#txpartic_'+i;
		ben     += ',#nmbenefi_'+i;
		parent  += ',#dsgraupr_'+i;
	}
	
	// Aumenta o tamanho
	$(part).css('width','50px').addClass('porcento');
	$(ben).css('width','220px').attr('maxlength','40');
	$('.parent').css('margin-left','7px');
	$(parent).attr('maxlength','20');
		
    // Para evitar a digitação de caracteres especiais que ocasiona erro na recuperação através de XML
    $(ben+','+parent).bind("keyup", function () {
	    this.value = removeCaracteresInvalidos(this.value);
    });
	
    $(ben+','+parent).bind("blur", function () {
	    this.value = removeCaracteresInvalidos(this.value);
    });
	
	// Bloqueia a digitação de caracteres com a tecla Alt + ..
    $(ben+','+parent).bind("keydown", function (e) {
	   if (e.altKey) { return false; }
    });
		
	var label = 'label[for="vlpreseg"],label[for="vlcapseg"],'+
			    'label[for="qtpreseg"],label[for="vlprepag"],'+
				'label[for="dscobert"],label[for="nmdsegur"],'+
				'label[for="nrctrato"]';				
	$(label).css({'width':'130px','text-align':'right'});
	$('label[for="pesquisa"]').css({'width':'72px','text-align':'right'})
	
	var disable = '#dtinivig,#dtfimvig,#qtpreseg,'+
				  '#dtcancel,#dtdebito,#vlprepag,#dscobert,'+
				  '#nmbenefi,#dsgraupr,#txpartic,#nmdsegur,#dssitseg,#pesquisa';
				  
	// Seta o tamanho da div
	$('#divConteudoOpcao,#tableJanela').css({'height':'360px','width':'680px'});

	 $('#pesquisa').css('width','160px');
	 $('label[for="dssitseg"]').css('margin-left','7px');
	 $('#dssitseg').css({'width':'350px','margin-left':'20px'});
	 
	 // Máscaras moeda e inteiro
		 $('#tpplaseg,#seguradora,#qtpreseg,#ddvencto').addClass('inteiro campo').css('width','40px');
		 $('#tpplaseg').attr('maxlength','3');
         $('#ddvencto').attr('maxlength','2');
         $('#nrctrato').addClass('inteiro campo').css('width','80px');
		 $('#vlpreseg,#vlcapseg,#vlprepag').addClass('moeda campo').css('width','80px');
		 $(part).attr('maxlength','6').css('width','80px');
		 $(parent).addClass('campo');
		 $(part).addClass('campo');
		 $(ben).addClass('campo');

    // validar dia informado, apenas é permitido dia entre 1 e 28  
    $("#ddvencto").blur(function(){
          
        if ($("#ddvencto").val() < 1 || $("#ddvencto").val() > 28 ) {
             
            $('#ddvencto').val( $('#diamvt').val() );
            hideMsgAguardo();
			showError('error','Dia para proximos debitos invalido!','Alerta - Aimaro','bloqueiaFundo(divRotina)');
            
           }
    });
         
        
	// Seta estilo para as tables
	$('#tabela-1 tr td label').css('float','right');
	$('#table-2 tr td label,label[for="pesquisa"]').css('float','left');
	
	if(tpseguro == 4){
		disable+= ','+ben;
		disable+= ','+parent;
		disable+= ','+part;
	}
	
	$(disable).desabilitaCampo();
    
	// Quando estiver na tela de consulta ou Alteração chama as 2 funções
	if(consultar){
       //desabilita os botoes ateh que acabe de carregar ajax de informacoes
	    $("#btVoltar").attr("disabled",true);
	    $("#btContinuar").attr("disabled",true);
		glbctfrm = "";
		consultarSeg();
		buscaEnd();
		habilitaBotoesSegVida();
	} else {
	    if(tpseguro == 3){ /*VIDA*/
	        $('#tpplaseg').unbind('blur').bind('blur', function () {
	            buscaValorPlano($('#tpplaseg').val());
	        })
	        $('#vlpreseg').desabilitaCampo();
	        $('#vlcapseg').focus();
	    }

		$('#btContinuar').unbind('click').bind('click', function() {
				if ($("#ddvencto").val() < 1 || $("#ddvencto").val() > 28 ) {
             
					$('#ddvencto').val( $('#diamvt').val() );
					hideMsgAguardo();
					showError('error','Dia para proximos debitos invalido!','Alerta - Aimaro','bloqueiaFundo(divRotina)');
					
			    }
				else{
					// PRJ 438 - Se tipo prestamista, entao primeiro validar o contrato
					if(tpseguro == 4){
						validaContrato();
					}else{
					controlaOperacao('BUSCASEG');return false;			
				}
				
				}
				
		});
		$('#btVoltar').unbind('click').bind('click', function() {
				controlaOperacao('BTF');return false;	
		});		
	}
	
}

// Carrega formulário de cadastro de prestamista e vida
function carregaPropriedadesFormPrestVidaNovo(){
	
    var label = 'label[for="nmSegurado"],label[for="dsTpSeguro"],' +
			    'label[for="dtIniVigen"],label[for="nrProposta"],' +
                'label[for="dsPlano"]';
				
	$(label).addClass('rotulo').css({'width':'100px','text-align':'right'});

	$('label[for="nrEndosso"]').css({ 'width': '130px', 'text-align': 'right' });
    $('label[for="nmSeguradora"]').css({'width':'110px','text-align':'right'});
	$('label[for="nrApolice"]').css({'width':'210px','text-align':'right'});
	$('label[for="dtFimVigen"]').css({ 'width': '190px', 'text-align': 'right' });
	$('label[for="vlCapital"]').css({ 'width': '110px', 'text-align': 'right' });
	$('label[for="nrApoliceRenova"]').css({ 'width': '100px', 'text-align': 'right' });
	
	$('#nmSegurado').css('width','260px').desabilitaCampo();
	$('#dsTpSeguro').css('width','150px').desabilitaCampo();
	$('#nmSeguradora').css('width','150px').desabilitaCampo();
	$('#dtIniVigen').css('width','70px').desabilitaCampo();
	$('#dtFimVigen').css('width','70px').desabilitaCampo();
	$('#nrProposta').css('width','50px').desabilitaCampo();
	$('#nrApolice').css('width','50px').desabilitaCampo();
	$('#nrEndosso').css('width','50px').desabilitaCampo();
	$('#dsPlano').css('width','150px').desabilitaCampo();
	$('#vlCapital').css('width','80px').desabilitaCampo();
	$('#nrApoliceRenova').css('width','50px').desabilitaCampo();
	$('#vlPremioLiquido').css('width','80px').desabilitaCampo();
	$('#qtParcelas').css('width','80px').desabilitaCampo();
	$('#vlPremioTotal').css('width','80px').desabilitaCampo();
	$('#vlParcela').css('width','80px').desabilitaCampo();
	$('#ddMelhorDia').css('width','80px').desabilitaCampo();
	$('#perComissao').css('width','80px').desabilitaCampo();
	$('#dsObservacoes').css({'height':'50px','width':'500px'}).desabilitaCampo();
	
	var divRegistro = $('div.divRegistros');
    var tabela      = $('table', divRegistro);

    divRegistro.css('height','80px');
	
	var ordemInicial = new Array();
    ordemInicial = [[1,0]];

	var arrayLargura = new Array();
	arrayLargura[0] = '250px';
	arrayLargura[1] = '100px';
	arrayLargura[2] = '130px';

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'left';
	arrayAlinha[1] = 'center';
	arrayAlinha[2] = 'left';
	arrayAlinha[3] = 'right';
	
    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');
	
	$('#divConteudoOpcao,#tableJanela').css({'height':'210px','width':'640px'});
	
	var label = 'label[for="vlPremioLiquido"],label[for="vlPremioTotal"],label[for="ddMelhorDia"]';
	$(label).addClass('rotulo').css({'width':'150px','text-align':'right'});
	
	var label = 'label[for="qtParcelas"],label[for="vlParcela"],label[for="perComissao"]';
	$(label).css({'width':'200px','text-align':'right'});
	
	$('label[for="dsObservacoes"]').addClass('rotulo').css({'width':'100px','text-align':'right'});	
	
	$('#divConteudoOpcao,#tableJanela').css({'height':'450px'});
	
	var btVoltar = $('#btVoltar', divBotoes);
    btVoltar.click(function () {
					controlaOperacao('');
					return false;
				});
}

function habilitaBotoesSegVida(){
	if(glbctfrm != "ok"){
		setTimeout("habilitaBotoesSegVida()",500);
	}else{
		$("#btVoltar").attr("disabled",false);
		$("#btContinuar").attr("disabled",false);
	}
}

// Função responsável por validar a inclusão de um seguro
function validaSeguroGeral(operacao, nrpagina){
	
	if(operacao=='I_CASA'){
		nrctrseg = $('#nrctrseg', '#frmSeguroCasa').val();
		var nmresseg = $('#nmresseg', '#frmSeguroCasa').val();
		var tpplaseg = $('#tpplaseg', '#frmSeguroCasa').val();
		var ddpripag = $('#ddpripag', '#frmSeguroCasa').val();
		var ddvencto = $('#ddvencto', '#frmSeguroCasa').val();
		var vlpreseg = $('#vlpreseg', '#frmSeguroCasa').val();
		var dtinivig = $('#dtinivig', '#frmSeguroCasa').val();
		var dtfimvig = $('#dtfimvig', '#frmSeguroCasa').val();
		var flgclabe;
		$('input:radio[name=flgclabe]').each(function() {
			if ($(this).is(':checked'))
				flgclabe = $(this).val();
		});
		nmbenvid = $('#nmbenvid', '#frmSeguroCasa').val();
		
		// Endereço local do risco
		nrcepend = $('#nrcepend', '#frmSeguroCasa').val();
		var dsendres = $('#dsendres', '#frmSeguroCasa').val();
		nrendere = $('#nrendere', '#frmSeguroCasa').val();
		complend = $('#complend', '#frmSeguroCasa').val();
		nmbairro = $('#nmbairro', '#frmSeguroCasa').val();
		nmcidade = $('#nmcidade', '#frmSeguroCasa').val();
		var cdufresd = $('#cdufresd', '#frmSeguroCasa').val();
		
		var tpendcor = $('#tipo_end_correspondencia', '#frmSeguroCasa').val();
	}
	else{
        
		// Captura os valores do formulário
		var cdempres = $('#cdempres').val();
		var nmdsegur = $('#nmdsegur').val();
		var tpplaseg = $('#tpplaseg').val();
		var vlcapseg = $('#vlcapseg').val();
		var vlpreseg = $('#vlpreseg').val();
        // carregar dia dos proximos debitos
        var ddvencto = $('#ddvencto').val();
        
		var nmbenefi1 = $('#nmbenefi_1').val();
		var nmbenefi2 = $('#nmbenefi_2').val();
		var nmbenefi3 = $('#nmbenefi_3').val();
		var nmbenefi4 = $('#nmbenefi_4').val();
		var nmbenefi5 = $('#nmbenefi_5').val();
		
		
		var dsgraupr1 = $('#dsgraupr_1').val();
		var dsgraupr2 = $('#dsgraupr_2').val();
		var dsgraupr3 = $('#dsgraupr_3').val();
		var dsgraupr4 = $('#dsgraupr_4').val();
		var dsgraupr5 = $('#dsgraupr_5').val();
		
		var txpartic1 = $('#txpartic_1').val();
		var txpartic2 = $('#txpartic_2').val();
		var txpartic3 = $('#txpartic_3').val();
		var txpartic4 = $('#txpartic_4').val();
		var txpartic5 = $('#txpartic_5').val();
				
	}
	
	var dest = UrlSite + 'telas/atenda/seguro/valida_seguro_geral.php';
	var reccraws = "";

	
	$.ajax({
		type: 'POST',
		dataType: 'html',
		data:{
			ddpripag: ddpripag, ddvencto: ddvencto, dtinivig: dtinivig,
			dtfimvig: dtfimvig, flgclabe: flgclabe, nmbenvid: nmbenvid,
			dsendres: dsendres, cdufresd: cdufresd, tpendcor: tpendcor,
			nmresseg: nmresseg, nrpagina: nrpagina, dtnascsg: dtnascsg,
		
			nrdconta: nrdconta,tpseguro:tpseguro,nmdsegur:nmdsegur,
			dsendere:dsendere,nrendere:nrendere,complend:complend,
			nmbairro:nmbairro,nmcidade:nmcidade,cdufende:cdufende,
			nrcepend:nrcepend,vlplaseg:vlplaseg,vlmorada:vlmorada,
			tpplaseg:tpplaseg,nmprimtl:nmprimtl,cdsitdct:cdsitdct,
			nrcpfcgc:nrcpfcgc,vlcapseg:vlcapseg,vlpreseg:vlpreseg,
			cdsitseg:cdsitseg,operacao:operacao,
			nmbenefi1:nmbenefi1,nmbenefi2:nmbenefi2,nmbenefi3:nmbenefi3,
			nmbenefi4:nmbenefi4,nmbenefi5:nmbenefi5,
			
			dsgraupr1:dsgraupr1,dsgraupr2:dsgraupr2,dsgraupr3:dsgraupr3,
			dsgraupr4:dsgraupr4,dsgraupr5:dsgraupr5,
			
			txpartic1:txpartic1,txpartic2:txpartic2,txpartic3:txpartic3,
			txpartic4:txpartic4,txpartic5:txpartic5,
			
			cdempres:cdempres,cdsexosg:cdsexosg,cdsegura:cdsegura,
			nrctrseg:nrctrseg,qtparcel:qtparcel,qtprepag:qtprepag,
			
			redirect: 'script_ajax'
			},
		url: dest, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possivel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
		},
		success: function(response) { 
								
				if ( response.indexOf('showError("error"') == -1) {	 
					eval(response);
					
					// se nrpagina for 1, apenas retorno true avançando para próxima tela do cadastro
					if(nrpagina==1){
						mostraPart3SeguroCasa(operacao);
						return true;
					}
					else{ 
						criaSeg(operacao);
					}
					
					return false;
				}else{ 
					hideMsgAguardo();
					eval(response);
					return false;
				}
				
		}				
	});	
	return false;
}
// Função responsável por inserir o seguro
function criaSeg(operacao){
	
	if(operacao=='I_CASA'){
		nrctrseg = $('#nrctrseg', '#frmSeguroCasa').val();//var global do escopo
		var tpplaseg = $('#tpplaseg', '#frmSeguroCasa').val();
		var ddpripag = $('#ddpripag', '#frmSeguroCasa').val();
		var ddvencto = $('#ddvencto', '#frmSeguroCasa').val();
		var vlpreseg = $('#vlpreseg', '#frmSeguroCasa').val();
		var dtinivig = $('#dtinivig', '#frmSeguroCasa').val();
		var dtfimvig = $('#dtfimvig', '#frmSeguroCasa').val();
		var flgclabe;
		$('input:radio[name=flgclabe]').each(function() {
			//Verifica qual está selecionado
			if ($(this).is(':checked'))
				flgclabe = $(this).val();
		});
		nmbenvid = $('#nmbenvid', '#frmSeguroCasa').val();
		nrcepend = $('#nrcepend', '#frmSeguroCasa').val();
		var dsendres = $('#dsendres', '#frmSeguroCasa').val();
		nrendere = $('#nrendere', '#frmSeguroCasa').val();
		complend = $('#complend', '#frmSeguroCasa').val();
		nmbairro = $('#nmbairro', '#frmSeguroCasa').val();
		nmcidade = $('#nmcidade', '#frmSeguroCasa').val();
		var cdufresd = $('#cdufresd', '#frmSeguroCasa').val();
		
		var tpendcor = $('#tipo_end_correspondencia', '#frmSeguroCasa').val();
	}
	else{
		var cdempres = $('#cdempres').val();
		var nmdsegur = $('#nmdsegur').val();
		var tpplaseg = $('#tpplaseg').val();
		var vlcapseg = $('#vlcapseg').val();
		var vlpreseg = $('#vlpreseg').val();
        // carregar dia dos proximos debitos
        var ddvencto = $('#ddvencto').val();
        var nrctrato = $('#nrctrato').val();
		
		var nmbenefi1 = $('#nmbenefi_1').val();
		var nmbenefi2 = $('#nmbenefi_2').val();
		var nmbenefi3 = $('#nmbenefi_3').val();
		var nmbenefi4 = $('#nmbenefi_4').val();
		var nmbenefi5 = $('#nmbenefi_5').val();
		
		
		var dsgraupr1 = $('#dsgraupr_1').val();
		var dsgraupr2 = $('#dsgraupr_2').val();
		var dsgraupr3 = $('#dsgraupr_3').val();
		var dsgraupr4 = $('#dsgraupr_4').val();
		var dsgraupr5 = $('#dsgraupr_5').val();
		
		var txpartic1 = $('#txpartic_1').val();
		var txpartic2 = $('#txpartic_2').val();
		var txpartic3 = $('#txpartic_3').val();
		var txpartic4 = $('#txpartic_4').val();
		var txpartic5 = $('#txpartic_5').val();
	}
	
	var dest = UrlSite + 'telas/atenda/seguro/cria_seguro.php';
	var buscarUltimo = true;
		
	if(operacao != 'CRIASEG' && operacao != 'I_CASA'){
		dest = UrlSite + 'telas/atenda/seguro/altera_seguro.php';
		buscarUltimo = false;
		
	}
				
	var reccraws = "";
	
	$.ajax({
		type: 'POST',
		dataType: 'html', 
		data:{
			ddpripag:ddpripag, ddvencto: ddvencto, dtinivig: dtinivig,
			dtfimvig:dtfimvig, flgclabe: flgclabe, nmbenvid: nmbenvid,
			dsendres:dsendres, cdufresd: cdufresd, tpendcor: tpendcor,
			
			nrdconta:nrdconta, tpseguro:tpseguro, nmdsegur:nmdsegur,
			dsendere:dsendere, nrendere:nrendere, complend:complend, 
			nmbairro:nmbairro, nmcidade:nmcidade, cdufende:cdufende, 
			nrcepend:nrcepend, vlplaseg:vlplaseg, vlmorada:vlmorada, 
			tpplaseg:tpplaseg, nmprimtl:nmprimtl, cdsitdct:cdsitdct, 
			nrcpfcgc:nrcpfcgc, vlcapseg:vlcapseg, vlpreseg:vlpreseg, 
			operacao:operacao, cdsitseg:cdsitseg, dtnascsg:dtnascsg,
			nmbenefi1:nmbenefi1, nmbenefi2:nmbenefi2, nmbenefi3:nmbenefi3,
			nmbenefi4:nmbenefi4, nmbenefi5:nmbenefi5,
			
			dsgraupr1:dsgraupr1,dsgraupr2:dsgraupr2,dsgraupr3:dsgraupr3,
			dsgraupr4:dsgraupr4,dsgraupr5:dsgraupr5,
			
			txpartic1:txpartic1,txpartic2:txpartic2,txpartic3:txpartic3,
			txpartic4:txpartic4,txpartic5:txpartic5,
			
			cdempres:cdempres,cdsexosg:cdsexosg,cdsegura:cdsegura,
			nrctrseg:nrctrseg,qtparcel:qtparcel,qtprepag:qtprepag,
			executandoProdutos: executandoProdutos,nrctrato:nrctrato,
			
			redirect: 'script_ajax'},
		url: dest, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possivel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
				if ( response.indexOf('showError("error"') == -1) {
					if(operacao == 'I_CASA'){
						validaPlanoSeguro('frmSeguroCasa',0,false);	
					}else{
						if(buscarUltimo)
						   eval(response);
						   validaPlanoSeguro('frmNovo',reccraws,buscarUltimo);									
					} 
						
					return false;
				}else{
					hideMsgAguardo();
					eval(response);
					return false;
				}
				
		}				
	});	
	return false;
}

// Função responsável por validar a inclusão de um seguro
function buscaValorPlano(tpplaseg) {

    // Captura os valores do formulário
    //var tpplaseg = $('#tpplaseg').val();
    var tpseguro = 3;    /*VIDA*/
    var cdsegura = 5011; /*CHUBB*/

    //tpplaseg = 11;   /*Tiago o plano tem q ser digitado na tela*/

    //alert(tpplaseg + ' | ' + tpseguro + ' | ' + cdsegura + ' | ' + nrdconta);

    var dest = UrlSite + 'telas/atenda/seguro/busca_valor_plano.php';
  
    $.ajax({
        type: 'POST',
        dataType: 'html',
        data: {
            nrdconta: nrdconta,
            tpseguro: tpseguro, 
            tpplaseg: tpplaseg,            
            cdsegura: cdsegura,
  
            redirect: 'script_ajax'
        },
        url: dest,
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi possivel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
        },
        success: function (response) {
            if (response.indexOf('showError("error")') == -1) {
                eval(response);
                return false;
            } else {
                hideMsgAguardo();
                eval(response);
                return false;
            }

        }
    });
    return false;
}

function validaPlanoSeguro(formulario,reccraws,buscarUltimo){
	
	$('#nrctrseg','#'+formulario).val(nrctrseg);
	$('#cdsegura','#'+formulario).val(cdsegura);
	$('#tpseguro','#'+formulario).val(tpseguro); 
	
	var metodo = (executandoProdutos) ? "encerraRotina();" : "controlaOperacao('');";
			
	showConfirmacao('Deseja visualizar a impress&atilde;o?',
				    'Confirma&ccedil;&atilde;o - Aimaro',
					'imprimirPropostaSeguro(\''+formulario+'\',\''+reccraws+'\');',
					metodo,
					'sim.gif',
					'nao.gif');
	return false;	
}

// Função para consultar o seguro, seta o formulário com os valores
function consultarSeg(){	
			$('#divConteudoOpcao,#tableJanela').css({'height':'340px'});
            
			$('#nmdsegur').val(nmresseg);
			$('#dssitseg').val(dsStatus + (dsMotcan.length > 0 ? ' - '+dsMotcan : ''));
			
			if(tpplaseg.length == 2){
				tpplaseg = '0'+tpplaseg;
			}else if(tpplaseg.length == 1){
				tpplaseg = '00'+tpplaseg;
			}
			
			$('#tpplaseg').val(tpplaseg);
			$('#vlpreseg').val(vlpreseg);
			$('#dtinivig').val(dtinivig);
			$('#qtpreseg').val(qtpreseg);
			$('#dtcancel').val(dtcancel);
			$('#dtfimvig').val(dtfimvig);
			$('#vlprepag').val(vlprepag);
			$('#dtdebito').val(dtdebito);
			$('#dtmvtolt').val(dtmvtolt);
			$('#pesquisa').val(dspesseg);
			
			if( dsSeguro == 'PRST'){
				dsSeguro = 'PRESTAMISTA';
			}else{
				for(var i = 1; i <= 5; i++){
					if(txpartic[i] > 0){
						$('#nmbenefi_'+i).val(nmbenefi[i]);
						$('#dsgraupr_'+i).val(dsgraupr[i]);
						$('#txpartic_'+i).val(number_format(txpartic[i],2,',','.'));
					}
				}
			}
			
			$('#show-consulta').addClass('rotulo').css({'display':'block','width':'100%','text-align':'left','margin-left':'20%'});
			
			// Altera os botões do form
			var back      = $('#btVoltar');
			var continuar = $('#btContinuar');			
			back.unbind('click').bind('click', function() {
				controlaOperacao('');return false;	
			});
			
			continuar.unbind('click').bind('click', function() {
				controlaOperacao('ATUALIZASEG');return false;			
			});
			
			$('#frmNovo input[type="text"]').desabilitaCampo();
			if(cddopcao == 'CONSULTAR'){
				$('#btContinuar').css('display','none');				
			}else{
				for(var i = 1; i <= 5; i++){
					$('#nmbenefi_'+i).habilitaCampo();
					$('#dsgraupr_'+i).habilitaCampo();
					$('#txpartic_'+i).habilitaCampo();
				}										
			}

		$.ajax({
                url: UrlSite + 'telas/atenda/seguro/buscar_seguro_geral.php',
				type: 'POST',
				dataType: 'html',
				data:{nrdconta: nrdconta,redirect: 'script_ajax',
					  cdsegura:cdsegura,nrctrseg:nrctrseg,tpseguro:tpseguro			
				},
				error: function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi possivel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
				},
				success: function(response) {	
						if ( response.indexOf('showError("error"') == -1 ) {
							eval(response);	
							$('#show-consulta').html(dsseguro);
							$('#vlcapseg').val(vlseguro);
							$('#pesquisa').val(dspesseg);
							$('#dscobert').val(dscobert);
							return false;
						}else{
							eval(response);		
							return false;
							
						}
				}				
		});	
}

function mostraTelaMotivoCancelamento() {
	showMsgAguardo('Aguarde, carregando motivos de cancelamento ...');
		
	exibeRotina($('#divUsoGenerico'));
	
	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/atenda/seguro/carrega_motivo_cancelamento.php', 
		data: {
			nrdconta: nrdconta,
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Nä¯ foi possî·¥l concluir a requisiè¤¯.','Alerta - Aimaro',"blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$('#divUsoGenerico').html(response);
			layoutPadrao();	
			hideMsgAguardo();
			bloqueiaFundo($('#divUsoGenerico'));
		}				
	});
	
	return false;
}
function fechaMotivoCancelamento(){
	fechaRotina($('#divUsoGenerico'),$('#divRotina'));
	return false;	
}

function mostraPart3SeguroCasa(operacao){
	$('#divConteudoOpcao,#tableJanela').css({'height':'240px','width':'515px'});
	var divPart2 = $('#part_2');
	var divPart3 = $('#part_3');
	var divBotoes = $('#divBotoes');
	var btVoltar = $('#btVoltar', divBotoes);
	var btContinuar = $('#btContinuar', divBotoes);
	var btContinuarSalvar = $('#btContinuarSalvar', divBotoes);
	btContinuar.css({'display':'none'});
	
	divPart2.css({'display':'none'});
	divPart3.css({'display':'block'});
	
	if(operacao=='C_CASA'){		
		btContinuarSalvar.css({'display':'none'});
		btVoltar.focus();
	} else {
		btContinuarSalvar.css({'display':''});
		$('#tpendcor1', '#frmSeguroCasa').focus();
	}
	
	btVoltar.unbind('click').bind('click', function() {
		mostraPart2SeguroCasa(operacao);
		return false;
	});
}
function mostraPart2SeguroCasa(operacao){
	$('#divConteudoOpcao,#tableJanela').css({'height':'360px','width':'515px'});
	var divPart2 = $('#part_2');
	var divPart3 = $('#part_3');
	var divBotoes = $('#divBotoes');
	var btVoltar = $('#btVoltar', divBotoes);
	var btContinuar = $('#btContinuar', divBotoes);
	var btContinuarSalvar = $('#btContinuarSalvar', divBotoes);
	
	btContinuarSalvar.css({'display':'none'});
	btContinuar.css({'display':''});	
	divPart3.css({'display':'none'});
	divPart2.css({'display':'block'});
	
	btContinuar.unbind('click').bind('click', function() {
		mostraPart3SeguroCasa(operacao);
		return false;
	  });
	btVoltar.unbind('click').bind('click', function() {
		if(operacao == 'I_CASA')
			controlaOperacao('VI_CASA');
		else
			controlaOperacao('');
		return false;
	  });
}

function buscarEnderecoCorrespondencia(tipo_endereco){
	$.ajax({		
		type: "POST", 
		dataType: 'html',
		url: UrlSite + "telas/atenda/seguro/busca_endereco_correspondencia.php",
		data: {
            nrdconta: nrdconta, tpendcor: tipo_endereco,
			idseqttl: idseqttl, redirect: "html_ajax" // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Aimaro","$('#nrsennov','#frmEskeci').focus()");
		},
		success: function(response) {				
			eval(response);
		}
	});
}

// Função que controla a lupa de pesquisa
function controlaPesquisas(operacao) {
	var divUso = $("#divUsoGenerico");
	divRotina = $("#divRotina");
	var procedure, titulo, qtReg, filtrosPesq, filtrosDesc, colunas;
	if(operacao=='C'){
		var bo = 'b1wgen0033.p';
		var qtReg = '20';
		$('a','#frmMotivo').css({'cursor':'pointer'}).ponteiroMouse();
		
		// CÓDIGO DA SEGURADORA
		titulo      = 'Motivo de Cancelamento';
		procedure   = 'buscar_motivo_can';
		$('#cdmotcan','#frmMotivo').unbind('blur').bind('blur', function() {
			var filtrosDesc='flgerlog|false';
			buscaDescricao(bo,procedure,titulo,$(this).attr('name'),'dsmotcan',$(this).val(),'dsmotcan',filtrosDesc,'frmMotivo');
			return false;
		}).next().unbind('click').bind('click', function() {
			$("#divPesquisa").css({'z-index':'150'});
            filtrosPesq = 'C&oacutedigo:;cdmotcan;40px;S|Descri&ccedil&atildeo:;dsmotcan;120px;S;';
            colunas     = 'C&oacutedigo:;cdmotcan;11%;right|Descri&ccedil&atildeo:;dsmotcan;49%;left';
			fncOnClose  = 'cdmotcan = $("#cdmotcan","#frmMotivo").val();';
			mostraPesquisa(bo,procedure,titulo,qtReg, filtrosPesq, colunas, divUso, fncOnClose);
			return false;
		});
	}
	else if(operacao=='SEGUR'){			
		var bo = 'b1wgen0033.p';
		var qtReg = '20';
		$('a','#frmBuscarSeguradora').ponteiroMouse();
		// CÓDIGO DA SEGURADORA
		titulo      = 'Seguradora';
		procedure   = 'buscar_seguradora';
		$('#cdsegura','#frmBuscarSeguradora').unbind('blur').bind('blur', function() {
			var filtrosDesc='flgerlog|false';
			buscaDescricao(bo,procedure,titulo,$(this).attr('name'),'nmsegura',$(this).val(),'nmsegura',filtrosDesc,'frmBuscarSeguradora');
			return false;
		}).next().unbind('click').bind('click', function() {			
            filtrosPesq = 'C&oacutedigo:;cdsegura;60px;|Descri&ccedil&atildeo:;nmsegura;200px;';
            colunas     = 'C&oacutedigo:;cdsegura;11%;right|Descri&ccedil&atildeo:;nmsegura;49%;';
			fncOnClose  = 'cdsegura = $("#cdsegura","#frmBuscarSeguradora").val()';
			mostraPesquisa(bo,procedure,titulo,'20',filtrosPesq,colunas,divRotina,fncOnClose);
			return false;
		});	
	}
	else if(operacao=='I_CASA'){			
		var bo = 'b1wgen0033.p';
		var qtReg = '20';
		
		// CÓDIGO DA SEGURADORA
		titulo      = 'Plano de Seguro';
		procedure   = 'buscar_plano_seguro';
		$('#tpplaseg','#frmSeguroCasa').unbind('blur').bind('blur', function() {
			return false;
		}).next().unbind('click').bind('click', function() {			
			hideMsgAguardo();
			mostraZoom();
			return false;
		});
		
		var camposOrigem = 'nrcepend;dsendres;nrendere;complend;nrcxapst;nmbairro;cdufresd;nmcidade';
		$('#nrcepend','#frmSeguroCasa').buscaCEP('frmSeguroCasa', camposOrigem, divRotina);
		
		$('#nrcepend','#frmSeguroCasa').next().unbind('click').bind('click', function() {			
			var camposOrigem = 'nrcepend;dsendres;nrendere;complend;;nmbairro;cdufresd;nmcidade;';
			mostraPesquisaEndereco('frmSeguroCasa', camposOrigem, divRotina);
			return false;
		});
	}
	else if(operacao=='TI'){
		$('a','#frmNovo').ponteiroMouse();
		$('#nrctrato','#frmNovo').next().unbind('click').bind('click', function() {			
            filtrosPesq	= 'Contrato;nrctrato;80px;S;;N|;vlpreseg;80px;S;;N|Conta;nrdconta;80px;S;'+nrdconta+';N';
			colunas 	= 'Contrato;nrctremp;100%;center|;vlpreseg;0%;center;;N';
			mostraPesquisa("SEGU0003", "BUSCA_CONTRATOS_PRESTAMISTA", "Contratos", "30", filtrosPesq, colunas, divRotina);
			$('#btPesquisar').hide();
			return false;
		});
	}
}

function cancelarSeguro(){
	var cCdMotcan = $('#cdmotcan','#frmMotivo');
	showMsgAguardo('Aguarde, cancelando seguro ...');
	motivcan = cCdMotcan.val();
	$.ajax({		
		type: "POST", 
		dataType: 'html',
		url: UrlSite + "telas/atenda/seguro/cancelar_seguro.php",
		data: {
            nrdconta: nrdconta, idseqttl: idseqttl, tpseguro: tpseguro, nrctrseg: nrctrseg, motivcan: motivcan,
			redirect: "html_ajax" // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Aimaro","$('#nrsennov','#frmEskeci').focus()");
		},
		success: function(response) {
			eval(response);
		}
	});
}
function mostraTelaDesfazerCancelamento() {
	showMsgAguardo('Aguarde, carregando ...');
	exibeRotina($('#divUsoGenerico'));
	
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/atenda/seguro/desfazer_cancelamento.php', 
		data: {
			nrdconta: nrdconta, nrctrseg: nrctrseg, tpseguro: tpseguro,
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;l concluir a requisi&ccdil;&atilde;o.','Alerta - Aimaro',"blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response){
			$('#divUsoGenerico').html(response);
			layoutPadrao();	
			hideMsgAguardo();
			bloqueiaFundo($('#divUsoGenerico'));
		}
	});
	
	return false;
}
function desfazerCancelamentoSeguro(){
	showMsgAguardo('Aguarde, desfazendo cancelamento ...');
	$.ajax({		
		type: "POST", 
		dataType: 'html',
		url: UrlSite + "telas/atenda/seguro/desfazer_cancelamento_seguro.php",
		data: {
            nrdconta: nrdconta, idseqttl: idseqttl, tpseguro: tpseguro, nrctrseg: nrctrseg,
			redirect: "html_ajax" // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Aimaro","$('#nrsennov','#frmEskeci').focus()");
		},
		success: function(response) {				
			fechaMotivoCancelamento();
			controlaOperacao('');
		}
	});
}
function imprimirTermoCancelamento(){
	
	$('#sidlogin','#formImpressao').remove();
	$('#nrdconta','#formImpressao').remove();
	$('#nrctrseg','#formImpressao').remove();
	$('#tpseguro','#formImpressao').remove();
	$('#redirect','#formImpressao').remove(); 

	// Insiro input do tipo hidden do formulário para enviá-los posteriormente
	$('#formImpressao').append('<input type="hidden" id="sidlogin" name="sidlogin" />');
	$('#formImpressao').append('<input type="hidden" id="nrdconta" name="nrdconta" />');
	$('#formImpressao').append('<input type="hidden" id="nrctrseg" name="nrctrseg" />');
	$('#formImpressao').append('<input type="hidden" id="tpseguro" name="tpseguro" />');
	$('#formImpressao').append('<input type="hidden" id="tpplaseg" name="tpplaseg" />');
	$('#formImpressao').append('<input type="hidden" id="redirect" name="redirect" />'); 
	
	// Agora insiro os devidos valores nos inputs criados
	$('#sidlogin','#formImpressao').val($('#sidlogin','#frmMenu').val());
	$('#nrdconta','#formImpressao').val(nrdconta);
	$('#nrctrseg','#formImpressao').val(nrctrseg);
	$('#tpseguro','#formImpressao').val(tpseguro);
	$('#tpplaseg','#formImpressao').val(tpplaseg);	
		
	var action = UrlSite + 'telas/atenda/seguro/imprime_termo_cancelamento.php';
	$('#formImpressao').attr('action',action);
	
	var callafter = "fechaMotivoCancelamento();blockBackground(parseInt($('#divRotina').css('z-index')));controlaOperacao(\'\');";
	
	carregaImpressaoAyllos("formImpressao",action,callafter);
	
	return false;
}

function imprimirPropostaSeguro(nomeForm, reccraws){

	$('#formImpressao').html('');
	$('#formImpressao').append('<input type="hidden" id="sidlogin" name="sidlogin" />');
	$('#formImpressao').append('<input type="hidden" id="nrdconta" name="nrdconta" />');
	$('#formImpressao').append('<input type="hidden" id="nrctrseg" name="nrctrseg" />');
	$('#formImpressao').append('<input type="hidden" id="cdsegura" name="cdsegura" />'); 
	$('#formImpressao').append('<input type="hidden" id="tpseguro" name="tpseguro" />');
	$('#formImpressao').append('<input type="hidden" id="tpplaseg" name="tpplaseg" />');
	$('#formImpressao').append('<input type="hidden" id="reccraws" name="reccraws" />'); 
	$('#formImpressao').append('<input type="hidden" id="redirect" name="redirect" />'); 
	$('#formImpressao').append('<input type="hidden" id="cddopcao" name="cddopcao" />'); 
    $('#formImpressao').append('<input type="hidden" id="nrctrato" name="nrctrato" />');
	
	$('#sidlogin','#formImpressao').val( $('#sidlogin','#frmMenu').val() );
	$('#nrdconta','#formImpressao').val( nrdconta );
	$('#cddopcao','#formImpressao').val( glbcdopc );
	
	if(nomeForm!=''){
		if(nomeForm=='frmSeguroCasa')
			$('#tpseguro','#formImpressao').val('11');
		else
			$('#tpseguro','#formImpressao').val($('#tpseguro','#'+nomeForm).val());
			
		$('#nrctrseg','#formImpressao').val($('#nrctrseg','#'+nomeForm).val());			
		$('#tpplaseg','#formImpressao').val($('#tpplaseg','#'+nomeForm).val());
		$('#cdsegura','#formImpressao').val($('#cdsegura','#'+nomeForm).val());
		$('#reccraws','#formImpressao').val($('#reccraws','#'+nomeForm).val());
		$('#nrctrato','#formImpressao').val($('#nrctrato','#'+nomeForm).val());
	} 
	else{ 
		$('#nrctrseg','#formImpressao').val(nrctrseg);
		$('#tpseguro','#formImpressao').val(tpseguro);
		$('#tpplaseg','#formImpressao').val(tpplaseg);
		$('#cdsegura','#formImpressao').val(cdsegura);
	} 
	if($('#tpseguro','#formImpressao').val() == 11){
		var action = UrlSite + 'telas/atenda/seguro/imprime_proposta_seguro.php';
	}else if($('#tpseguro','#formImpressao').val() == 4){  
		// PRJ 438 - Novo relatorio para prestamista
		var action = UrlSite + 'telas/atenda/seguro/imprime_proposta_prestamista.php';
	}else{  
		var action = UrlSite + 'telas/atenda/seguro/imprime_proposta_seguro_vidaprestamista.php';
	}
	
	$('#formImpressao').attr('action',action);
	
	var callafter = "blockBackground(parseInt($('#divRotina').css('z-index')));"; 
	
	callafter += (executandoProdutos) ? "encerraRotina();" : "controlaOperacao('');";
	   
	carregaImpressaoAyllos("formImpressao",action,callafter);
	
	return false;
}
function mostraTelaSelecionarSeguradora() {
	showMsgAguardo('Aguarde, carregando seguradoras ...');
		
	exibeRotina($('#divUsoGenerico'));
	
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/atenda/seguro/carrega_seguradoras.php', 
		data: {
			nrdconta: nrdconta,
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Nä¯ foi possî·¥l concluir a requisiè¤¯.','Alerta - Aimaro',"blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$('#divUsoGenerico').html(response);
			layoutPadrao();	
			hideMsgAguardo();
			bloqueiaFundo($('#divUsoGenerico'));
		}				
	});
	
	return false;
}

function botaoVoltarCasa(opcao)
{
	if(opcao == 1){
		controlaOperacao('');
		return false;
	}
}

function mostraZoom()
{
	showMsgAguardo('Aguarde, abrindo zoom...');
			
	exibeRotina($('#divUsoGenerico'));

	showMsgAguardo("Aguarde, Carregando...");
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/atenda/seguro/zoom_plano.php', 
		data: {
			nrdconta:nrdconta, cdsegura:cdsegura,
			redirect: 'script_ajax'
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			$('#divUsoGenerico').html(response);
			layoutPadrao();	
			hideMsgAguardo();
			bloqueiaFundo($('#divUsoGenerico'));
			buscaPlanos();
		}				
	});	
}

function buscaPlanos()
{
	showMsgAguardo('Aguarde, abrindo zoom...');
			
	exibeRotina($('#divUsoGenerico'));

	showMsgAguardo("Aguarde, Carregando...");
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/atenda/seguro/buscar_plano_seguro_casa.php', 
		data: {
			nrdconta:nrdconta, cdsegura:cdsegura,
			redirect: 'script_ajax'
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			eval(response);
			bloqueiaFundo($('#divUsoGenerico'));
		}				
	});	
}

function atualizaValoresZoom(indice)
{
	fechaRotina($('#divUsoGenerico'),divRotina);
	$('#tpplaseg', '#frmSeguroCasa').val(arrayPlanos[indice]['tpplaseg']);
	teclado = 13;
	$('#tpplaseg', '#frmSeguroCasa').keypress();
	teclado = 0;
}

function exibeValor(indice)
{
	$('#vlplaseg','#frmZoom').val(arrayPlanos[indice]['vlplaseg']);
	$('#flgunica','#frmZoom').val((arrayPlanos[indice]['flgunica']=='no')?'Mensal':'Única');
	$('#qtmaxpar','#frmZoom').val(arrayPlanos[indice]['qtmaxpar']);
	$('#mmpripag','#frmZoom').val(arrayPlanos[indice]['mmpripag']);
	$('#qtdiacar','#frmZoom').val(arrayPlanos[indice]['qtdiacar']);
	$('#ddmaxpag','#frmZoom').val(arrayPlanos[indice]['ddmaxpag']);
}

function atualizaSeguradora(nomsegur, codsegur )
{
	cdsegura = $('#cdsegura','#divSeguradoras').val(codsegur);
	nmsegura = $('#nmsegura','#divSeguradoras').val(nomsegur);
}

function formataZoom()
{
	// Formata o tamanho da tabela
	$('#divZoomPlano').css({'height':'300px','width':'420px'});
	
	// Monta Tabela dos Itens
	$('#divZoomPlano > div > table > tbody').html('');	
	var registros = false;
	
	for( var i in arrayPlanos) {
		registros = true;
		$('#divZoomPlano > div > table > tbody').append('<tr onclick=exibeValor('+i+') onDblClick=atualizaValoresZoom('+i+')></tr>');
		$('#divZoomPlano > div > table > tbody > tr:last-child').append('<td>'+arrayPlanos[i]['tpplaseg']+'</td>');
		$('#divZoomPlano > div > table > tbody > tr:last-child').append('<td>'+arrayPlanos[i]['dsmorada']+'</td>');
		$('#divZoomPlano > div > table > tbody > tr:last-child').append('<td>'+arrayPlanos[i]['dsocupac']+'</td>');
	}
	
	if(registros)
		exibeValor(0);
	
	var divRegistro = $('#divRegistros', '#divZoomPlano');		
	var tabela      = $('table', divRegistro );

	divRegistro.css('height','150px');
	
	var ordemInicial = new Array();
	ordemInicial = [[0,0]];
	
	var arrayLargura = new Array();
	arrayLargura[0] = '80px';
	arrayLargura[1] = '145px';
	
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'right';
	arrayAlinha[2] = 'right';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );

    var cTodos    = $('#vlplaseg,#flgunica,#qtmaxpar,#mmpripag,#qtdiacar,#ddmaxpag','#frmZoom');
	var cVlplaseg = $('#vlplaseg','#frmZoom');
	var cFlgunica = $('#flgunica','#frmZoom');
	var cQtmaxpar = $('#qtmaxpar','#frmZoom');
	var cMmpripag = $('#mmpripag','#frmZoom');
	var cQtdiacar = $('#qtdiacar','#frmZoom');
	var cDdmaxpag = $('#ddmaxpag','#frmZoom');
	
	var rVlplaseg = $('label[for="vlplaseg"]','#frmZoom');
	var rFlgunica = $('label[for="flgunica"]','#frmZoom');
	var rQtmaxpar = $('label[for="qtmaxpar"]','#frmZoom');
	var rMmpripag = $('label[for="mmpripag"]','#frmZoom');
	var rQtdiacar = $('label[for="qtdiacar"]','#frmZoom');
	var rDdmaxpag = $('label[for="ddmaxpag"]','#frmZoom');
	
	cTodos.addClass('campo');
	
	rVlplaseg.addClass('rotulo').css('width', '60px');
	cVlplaseg.addClass('rotulo').css('width', '120px');	
	rFlgunica.css('width', '100px');
	cFlgunica.css('width', '120px');
	
	rQtmaxpar.addClass('rotulo').css('width', '220px');
	cQtmaxpar.addClass('rotulo').css('width', '183px');	

	rMmpripag.addClass('rotulo').css('width', '220px');
	cMmpripag.addClass('rotulo').css('width', '183px');	
	
	rQtdiacar.addClass('rotulo').css('width', '220px');
	cQtdiacar.addClass('rotulo').css('width', '183px');
	
	rDdmaxpag.addClass('rotulo').css('width', '220px');
	cDdmaxpag.addClass('rotulo').css('width', '183px');
	
	cTodos.desabilitaCampo();
}

function valida_inclusao(tpseguro)
{
	showMsgAguardo('Aguarde, validando inclus&atilde;o ...');
	
	$.ajax({		
		type: 'POST',
		url: UrlSite + 'telas/atenda/seguro/valida_inclusao.php',
		data: {
			nrdconta: nrdconta, idseqttl: idseqttl,
			tpseguro: tpseguro, redirect: 'script_ajax'
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
			return false;
		},
		success: function(response) {
			hideMsgAguardo();
			eval(response);
		}
	});
}

function carregaFormCasa()
{
	$('#divConteudoOpcao,#tableJanela').css({'height':'360px','width':'515px'});
	tpplaseg = normalizaNumero(cTpplaseg.val());
	var divPart2 = $('#part_2');
	var divPart3 = $('#part_3');
	var divBotoes = $('#divBotoes');
	var cTodosPart2 = $('input',divPart2);
	var cTodosPart3 = $('input',divPart3);

	if( tpplaseg != 0 ){
		// validação do número do plano
		showMsgAguardo('Aguarde, validando n&uacute;mero do plano ...');
		$.ajax({		
			type: 'POST',
			url: UrlSite + 'telas/atenda/seguro/valida_plano.php',
			data: {
				nrdconta: nrdconta, tpplaseg: tpplaseg,
				cdsegura: cdsegura, tpseguro: tpseguro,
				redirect: 'script_ajax'
			}, 
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
				return false;
			},
			success: function(response) {
				hideMsgAguardo();
				
				var retorno = response.split("|");
				if(retorno[0]=='true'){
					cTpplaseg.next().addClass('lupa').css('cursor','auto').unbind('click').bind('click', function() { return false; });
					cTpplaseg.desabilitaCampo();
					
					cNrctrseg.desabilitaCampo();
					divPart2.css({'display':'block'});
					divBotoes.css({'display':'block'});
					
					$('input[type=radio]', '#frmSeguroCasa').habilitaCampo();
					cNrcepend.habilitaCampo();
					cNrendere.habilitaCampo();
					cComplend.habilitaCampo();
					
					$('#vlpreseg','#frmSeguroCasa').val(retorno[1]);
					cNrcepend.next().css('cursor','pointer');
					
					$('#btContinuar', '#divBotoes').css({'display':''});
					$('#btCarregaForm', '#botaoOk').css({'display':'none'});
					$('#btVoltar', '#divBotoes').unbind('click').bind('click', function(){
						controlaOperacao('VI_CASA');
					})
					
					var flgunica = retorno[2];
					if(flgunica == 'no'){
						cDdvencto.habilitaCampo();
						cDdvencto.focus();
					}else{
						cDdvencto.val('');
						cDdvencto.desabilitaCampo();
						$('#flgclabeN', '#frmSeguroCasa').focus();
					}
					vlplaseg = retorno[3];
				}
				else{
					showError("error",retorno[1],"Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");
					$('#cTpplaseg').focus();
					return false;
				}
				blockBackground(parseInt($("#divRotina").css("z-index")));
				$('#btCarregaForm', '#frmSeguroCasa').unbind('click');
			}
		});
		return false;
	}else{
		cTodosPart2.desabilitaCampo();
		cTodosPart3.desabilitaCampo();
		cTpplaseg.focus();
	}

	return false;
}

// PRJ 438 - Validação do novo campo contrato
function validaContrato(){

	var nrctrato = $('#nrctrato', '#frmNovo').val();

	if(nrctrato == ''){
		showError('error','Campo contrato &eacute; obrigat&oacute;rio.','Alerta - Ayllos','hideMsgAguardo();');
	return false;
}

	$.ajax({		
		type: "POST", 
		dataType: 'html',
		url: UrlSite + "telas/atenda/seguro/valida_contrato.php",
		data: {
            nrdconta: nrdconta,
			nrctrato: nrctrato,
			redirect: "html_ajax" // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#nrsennov','#frmEskeci').focus()");
		},
		success: function(response) {				
			if ( response.indexOf('showError("error"') == -1 ) {
				controlaOperacao('BUSCASEG');
				return false;
			} else {
				$('#nrctrato', '#frmNovo').val('');
				eval(response);
	return false;
}
		}
	});
}