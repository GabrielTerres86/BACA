/*****************************************************************************************
 Fonte: inss.js                                                   
 Autor: Adriano                                                   
 Data : Maio/2013             					   Última Alteração: 11/04/2017
                                                                  
 Objetivo  : Biblioteca de funções da tela INSS                 
                                                                  
 Alterações: 21/01/2015 - Ajuste para diminuir a largura do campo cddopcao
                          pois no IE ele passou a jogar o botão "OK" para a
                          proxima linha 
                          (Adriano).
             
             10/03/2015 - Ajuste referente ao Histórico cadastral
                          (Adriano - Softdesk 261226).
             
             20/10/2015 - Adicionadas opções para consulta de log e 
                          relatório de prova de vida.
                        - Adicionados campos data inicial e data final no 
                          relatório de beneficiarios a pagar. Projeto 255
                          (Lombardi).
             
             24/11/2015 - Adicionada validacao de senha para as operacoes 
                          de Troca de Conta Corrente, Comprovacao de Vida 
                          e Troca de OP. Projeto 255 (Lombardi).
                          
             01/12/2015 - Adicionado alerta nas telas de consulta para 
                          caso a comprovacao de vida esteja vencida.
                          Projeto 255 (Lombardi).

             11/04/2017 - Permitir acessar o Ayllos mesmo vindo do CRM. (Jaison/Andrino)

******************************************************************************************/

var arrayTitulares        = new Array();

var detalhesLog = new Array();

var inclusao			  = false;
var possui_senha_internet = false;

//campos da linha selecionada na lista de log
var glbDtmvtolt, glbHrmvtolt, glbNrdconta, glbNmdconta, glbNrrecben, glbHistoric, glbOperador;

//campos comprova vida
var cv_nrdconta, cv_nrcpfcgc, cv_nmextttl, cv_idseqttl, cv_cdorgins, cv_cdagepac, 
    cv_cdagesic, cv_nrrecben, cv_tpnrbene, cv_dscsitua, cv_idbenefi, cv_nmprocur, 
    cv_nrdocpro, cv_dtvalprc, cv_respreno, cv_cddopcao;
    
//campos troca conta
var tc_dtcompvi, tc_cdagepac, tc_cdagesic, tc_nrrecben, tc_tpnrbene, tc_dscsitua,
    tc_idbenefi, tc_nrcpfcgc, tc_idseqttl, tc_nmbairro, tc_nrcepend, tc_dsendere,
    tc_nrendere, tc_nmcidade, tc_cdufende, tc_nmbenefi, tc_nrdddtfc, tc_nrtelefo,
    tc_cdsexotl, tc_nomdamae, tc_cdorgins, tc_orgpgant, tc_nrdconta, tc_nrctaant,
    tc_nrcpfant, tc_cddopcao, tc_sqttlant;

//campos troca conta entre coop
var to_nrrecben, to_dtcompvi, to_cdagepac, to_cdagesic, to_dscsitua, to_idbenefi, 
    to_nrcpfcgc, to_idseqttl, to_nmbairro, to_nrcepend, to_dsendere, to_nrendere, 
    to_nmcidade, to_cdufende, to_nmbenefi, to_nrdddtfc, to_nrtelefo, to_cdcopant,  
    to_cdorgins, to_orgpgant, to_nrdconta, to_nrctaant, to_nrcpfant, to_nomdamae,  
    to_cdsexotl, to_cddopcao;

//campos troca domicilio
var td_idseqttl, td_cdorgins, td_cdagepac, td_cdagesic, td_nrcpfcgc, td_nmbairro, 
    td_nrcepend, td_dsendres, td_nrendere, td_nmcidade, td_cdufdttl, td_nmextttl, 
    td_nmmaettl, td_nrdddtfc, td_nrtelefo, td_cdsexotl, td_dtnasttl, td_nrdconta, 
    td_nrrecben, td_cddopcao;

$(document).ready(function() {

	estadoInicial();
			
});


function estadoInicial() {
	
	formataCabecalho();
	
	$('#divDetalhes').html('');
	$('#divRotina').html('');
	
	$('#cddopcao','#frmCabInss').habilitaCampo().focus().val('C');
	$('#frmOpcoes').css('display','none');
	
	$('#divBeneficio').css('display','none');
	$('#divBotoesConta').css('display','none');
	$('#divConsultaLog').css('display','none');
	$('#nrdconta','#divBeneficio').val('');
	$('#idseqttl','#divBeneficio').html('');
		
	$('#divRelatorio').css('display','none');
	$('#divBotoesRelatorio').css('display','none');
	$('#divBotoesLog').css('display','none');
	
	$('#divDemonstrativo').css('display','none');
	
	layoutPadrao();
				
}

function formataCabecalho(){

	$('label[for="cddopcao"]','#frmCabInss').css('width','40px').addClass('rotulo');
	$('#cddopcao','#frmCabInss').css('width','460px');
	$('#divTela').css({'display':'inline'}).fadeTo(0,0.1);
	removeOpacidade('divTela');		
	$('#frmCabInss').css('display','block');
		
	highlightObjFocus( $('#frmCabInss') );
	$('#cddopcao','#frmCabInss').focus();
	
  controlaFoco();
	return false;
	
}

function formataOpcoes(opcao){

	switch(opcao){
	
		case 'R':
		
			formataOpcoesRelatorio();
		
		break;
		
		case 'L':
		
			formataOpcoesLog();

            // Seta os valores caso tenha vindo do CRM
            if ($("#crm_inacesso","#frmCabInss").val() == 1) {
                $("#nrdconta_log","#frmOpcoes").val($("#crm_nrdconta","#frmCabInss").val());
            }
		
		break;
		
		default:
			
			formataOpcoesBeneficio();

            // Seta os valores caso tenha vindo do CRM
            if ($("#crm_inacesso","#frmCabInss").val() == 1) {
                $("#nrcpfcgc","#frmOpcoes").val($("#crm_nrcpfcgc","#frmCabInss").val());
            }

		break;
					
	}
		
	return false;
	
}

function formataOpcoesRelatorio(){

	highlightObjFocus( $('#divRelatorio') );
	
	$('#divRelatorio').css({'border-bottom':'1px solid #777'});	
	
	
	//Label do divRelatorio
	rTprelato = $('label[for="tprelato"]','#divRelatorio');
	
	rTprelato.css('width','55px');
	
	//Campos do divRelatorio
	cTprelato = $('#tprelato','#divRelatorio').habilitaCampo().focus();
	
	cTprelato.css('width','485px');
		
	cTprelato.unbind('keypress').bind('keypress', function (e){
	
		if ( divError.css('display') == 'block' ) { return false; }		
		
		//Enter ou TAB
		if(e.keyCode == 13 || e.keyCode == 9){
		
			$(this).removeClass('campoErro').desabilitaCampo();
			$('#btProsseguir','#divBotoesRelatorio').click();
			
			return false;
			
		}
					
	});
		
	return false;
	
}

function controlaRotina(nmrotina){

	var tprelato = $('#tprelato','#divRelatorio').val();
	
	//Rejeitados
	if(tprelato == 'C'){
	
		relatorioBeneficiosRejeitados(nmrotina,tprelato);
		
	}else{ //Pagos e A pagar
	
	   acessaRotina(nmrotina,tprelato);
	   
	}
	
	return false;
	
}

function formataOpcoesBeneficio(){

	highlightObjFocus( $('#divBeneficio') );
	$('#divBeneficio').css({'border-bottom':'1px solid #777'});	
	
	todosConta = $('input','#divBeneficio');
	 
	todosConta.val('').desabilitaCampo();
	
	//Label do divBeneficio
	rNrcpfcgc = $('label[for="nrcpfcgc"]','#divBeneficio');
	rNrrecben = $('label[for="nrrecben"]','#divBeneficio');
	
	rNrcpfcgc.css('width','40px');
	rNrrecben.css('width','50px');
			
	//Campos do divBeneficio
	cNrcpfcgc = $('#nrcpfcgc','#divBeneficio');
	cNrrecben = $('#nrrecben','#divBeneficio');
		
	cNrcpfcgc.css({'width':'130px','text-align':'right'}).habilitaCampo().focus().addClass('inteiro').attr('maxlength','14');
	cNrrecben.css('width','100px').addClass('inteiro').attr('maxlength','10').habilitaCampo();
		
	// Se pressionar cNrcpfcgc
	cNrcpfcgc.unbind('keypress').bind('keypress', function(e){ 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
		
		// Se é a tecla ENTER, TAB
		if ( e.keyCode == 13  || e.keyCode == 9) {		
		
			$(this).removeClass('campoErro');
						
			var cpfCnpj = normalizaNumero($('#nrcpfcgc','#divBeneficio').val());
			
			cNrcpfcgc.val(mascara(cpfCnpj,'###.###.###-##'));
			
			$(this).desabilitaCampo();
			$('#nrrecben','#divBeneficio').focus();
							
			return false;
			
		}
										
	});		
		
	//Se pressionar cNrrecben
	cNrrecben.unbind('keypress').bind('keypress', function(e){
	
		if ( divError.css('display') == 'block' ) { return false; }		
		
		//Enter ou TAb
		if(e.keyCode == 13 || e.keyCode == 9){
		
			$(this).removeClass('campoErro');
			$(this).desabilitaCampo();
			solicitaConsultaBeneficiario($('#cddopcao','#frmCabInss').val());
			
			return false;
												
		}
		
	});
		
	layoutPadrao();
	
	return false;
	
}

function formataOpcoesLog(){

	highlightObjFocus( $('#divConsultaLog') );
	$('#divConsultaLog').css({'border-bottom':'1px solid #777'});	
	
	todosConta = $('input','#divConsultaLog');
	todosConta.val('').desabilitaCampo();
  
	//Label do divConsultaLog
	rDtmvtolt = $('label[for="dtmvtolt"]','#divConsultaLog');
	rNrrecben = $('label[for="nrrecben"]','#divConsultaLog');
	rNrdconta = $('label[for="nrdconta_log"]','#divConsultaLog');
  
	rDtmvtolt.css('width','55px');
	rNrrecben.css('width','90px');
	rNrdconta.css('width','110px');
  
	//Campos do divConsultaLog
	cDtmvtolt = $('#dtmvtolt','#divConsultaLog');
	cNrrecben = $('#nrrecben','#divConsultaLog');
	cNrdconta = $('#nrdconta_log','#divConsultaLog');
  
  cDtmvtolt.css({'width':'72px','text-align':'right'}).habilitaCampo().focus().addClass('inteiro').attr('maxlength','14').setMask("DATE","","","");
	cNrrecben.css('width','100px').addClass('inteiro').attr('maxlength','10').habilitaCampo();
	cNrdconta.css('width','73px').addClass('inteiro').attr('maxlength','10').habilitaCampo().setMask('INTEGER','9999.999-9','.-','');
  
	layoutPadrao();
	
	return false;
	
}

function formataVerificaSenha(){
  // label
  rCddsenha = $('label[for="cddsenha"]','#divSolicitaSenha');
  rCddsenha.css('width','50px').css('font-weight','bold').addClass('rotulo-linha');
  
  //Campo
	cCddsenha = $('#cddsenha','#divSolicitaSenha');
  cCddsenha.css('width','100px').attr('maxlength','8');
  cCddsenha.addClass('campo');
  cCddsenha.focus();
  
  layoutPadrao();
  
  return false;
}

function formataConsulta(){

	// linha
	( $.browser.msie ) ? $('hr','#frmConsulta').css({'margin':'0'}) : $('hr','#frmConsulta').css({'margin':'3px 0 3px 0'});
	
	todosConsulta = $('input','#frmConsulta');
	
	todosConsulta.desabilitaCampo();
	
	//Label do frmConsulta
	rRazaosoc = $('label[for="razaosoc"]','#frmConsulta');
	rCdorgins = $('label[for="cdorgins"]','#frmConsulta');
	rNmresage = $('label[for="nmresage"]','#frmConsulta');
	rNrdconta = $('label[for="nrdconta"]','#frmConsulta');
	rNmtitula = $('label[for="nmtitula"]','#frmConsulta');
	rDtcompvi = $('label[for="dtcompvi"]','#frmConsulta');
	rDtutirec = $('label[for="dtutirec"]','#frmConsulta');
	rDtdcadas = $('label[for="dtdcadas"]','#frmConsulta');
	rStacadas = $('label[for="stacadas"]','#frmConsulta');
	rDscespec = $('label[for="dscespec"]','#frmConsulta');
	rDscsitua = $('label[for="dscsitua"]','#frmConsulta');
	rDtdnasci = $('label[for="dtdnasci"]','#frmConsulta');
	rNrcpfcgc = $('label[for="nrcpfcgc"]','#frmConsulta');
	rDsendben = $('label[for="dsendben"]','#frmConsulta');
	rNmbairro = $('label[for="nmbairro"]','#frmConsulta');
	rNrcepend = $('label[for="nrcepend"]','#frmConsulta');
	rNmcidade = $('label[for="nmcidade"]','#frmConsulta');
	rCdufende = $('label[for="cdufende"]','#frmConsulta');
	rNrdddtfc = $('label[for="nrdddtfc"]','#frmConsulta');
	rNrtelefo = $('label[for="nrtelefo"]','#frmConsulta');
	rNmprocur = $('label[for="nmprocur"]','#frmConsulta');
	rNrdocpro = $('label[for="nrdocpro"]','#frmConsulta');
	rDtvalprc = $('label[for="dtvalprc"]','#frmConsulta');
	
	rRazaosoc.css('width','100px').addClass('rotulo');
	rCdorgins.css('width','100px').addClass('rotulo');
	rNmresage.css('width','50px').addClass('rotulo-linha');
	rNrdconta.css('width','100px').addClass('rotulo');
	rNmtitula.css('width','50px').addClass('rotulo-linha');
	rDtcompvi.css('width','185px').addClass('rotulo');
	rDtutirec.css('width','165px').addClass('rotulo-linha');
	rDtdcadas.css('width','185px').addClass('rotulo');
	rStacadas.css('width','185px').addClass('rotulo');
	rDscespec.css('width','185px').addClass('rotulo');
	rDscsitua.css('width','165px').addClass('rotulo-linha');
	rDtdnasci.css('width','185px').addClass('rotulo');
	rNrcpfcgc.css('width','90px').addClass('rotulo');
	rDsendben.css('width','90px').addClass('rotulo');
	rNmbairro.css('width','90px').addClass('rotulo');
	rNrcepend.css('width','30px').addClass('rotulo-linha');
	rNmcidade.css('width','90px').addClass('rotulo');	
	rCdufende.css('width','30px').addClass('rotulo-linha');	
	rNrdddtfc.css('width','149px').addClass('rotulo-linha');
	rNrtelefo.css('width','5px').addClass('rotulo-linha');
	rNmprocur.css('width','80px').addClass('rotulo');
	rNrdocpro.css('width','75px').addClass('rotulo-linha');
	rDtvalprc.css('width','80px').addClass('rotulo');
	
	
	//Campos do frmConsulta
	cRazaosoc = $('#razaosoc','#frmConsulta');
	cCdorgins = $('#cdorgins','#frmConsulta');
	cNmresage = $('#nmresage','#frmConsulta');
	cNrdconta = $('#nrdconta','#frmConsulta');
	cNmtitula = $('#nmtitula','#frmConsulta');
	cDtcompvi = $('#dtcompvi','#frmConsulta');
	cDtutirec = $('#dtutirec','#frmConsulta');
	cDtdcadas = $('#dtdcadas','#frmConsulta');
	cStacadas = $('#stacadas','#frmConsulta');
	cDscespec = $('#dscespec','#frmConsulta');
	cDscsitua = $('#dscsitua','#frmConsulta');
	cDtdnasci = $('#dtdnasci','#frmConsulta');
	cNrcpfcgc = $('#nrcpfcgc','#frmConsulta');
	cDsendben = $('#dsendben','#frmConsulta');
	cNmbairro = $('#nmbairro','#frmConsulta');
	cNrcepend = $('#nrcepend','#frmConsulta');
	cNmcidade = $('#nmcidade','#frmConsulta');
	cCdufende = $('#cdufende','#frmConsulta');
	cNrdddtfc = $('#nrdddtfc','#frmConsulta');
	cNrtelefo = $('#nrtelefo','#frmConsulta');
	cNmprocur = $('#nmprocur','#frmConsulta');
	cNrdocpro = $('#nrdocpro','#frmConsulta');
	cDtvalprc = $('#dtvalprc','#frmConsulta');
	
	cRazaosoc.css('width','425px');
	cCdorgins.css('width','120px');
	cNmresage.css('width','250px');
	cNrdconta.css('width','120px');
	cNmtitula.css('width','250px');
	cDtcompvi.css('width','80px');
	cDtutirec.css('width','35px');
	cDtdcadas.css('width','80px');
	cStacadas.css('width','340px');
	cDscespec.css('width','340px');
	cDscsitua.css('width','90px');
	cDtdnasci.css('width','80px');
	cNrcpfcgc.css('width','150px');
	cDsendben.css('width','320px');
	cNmbairro.css('width','320px');
	cNrcepend.css('width','80px').addClass('cep');
	cNmcidade.css('width','320px');
	cCdufende.css('width','35px');
	cNrdddtfc.css('width','40px');
	cNrtelefo.css('width','80px');
	cNmprocur.css('width','250px');
	cNrdocpro.css('width','123px');
	cDtvalprc.css('width','80px');
	
	layoutPadrao();
	return false;
	
}

function formataTrocaOpContaCorrente(cddopcao){

	highlightObjFocus( $('#frmTrocaOpContaCorrente') );

	//Label do frmTrocaOpContaCorrente
	rNrctaant = $('label[for="nrctaant"]','#frmTrocaOpContaCorrente');
	rOrgpgant = $('label[for="orgpgant"]','#frmTrocaOpContaCorrente');
	rNrdconta = $('label[for="nrdconta"]','#frmTrocaOpContaCorrente');
	rIdseqttl = $('label[for="idseqttl"]','#frmTrocaOpContaCorrente');
	rCdorgins = $('label[for="cdorgins"]','#frmTrocaOpContaCorrente');
	
	rNrctaant.css('width','125px').addClass('rotulo');
	rOrgpgant.css('width','150px').addClass('rotulo-linha');
	rNrdconta.css('width','125px').addClass('rotulo');
	rIdseqttl.css('width','50px').addClass('rotulo-linha');
	rCdorgins.css('width','125px').addClass('rotulo');
	
	//Campos do frmTrocaOpContaCorrente
	cNrctaant = $('#nrctaant','#frmTrocaOpContaCorrente');
	cOrgpgant = $('#orgpgant','#frmTrocaOpContaCorrente');
	cNrdconta = $('#nrdconta','#frmTrocaOpContaCorrente');
	cIdseqttl = $('#idseqttl','#frmTrocaOpContaCorrente');
	cCdorgins = $('#cdorgins','#frmTrocaOpContaCorrente');

	cNrctaant.css({'width':'95px','text-align':'right'}).desabilitaCampo();
	cOrgpgant.css('width','80px').addClass('inteiro').desabilitaCampo();
	cNrdconta.css({'width':'95px','text-align':'right'}).addClass('conta').habilitaCampo();
	cIdseqttl.css({'width':'200px'}).desabilitaCampo();
	cCdorgins.css('width','95px').attr('maxlength','6').addClass('inteiro').desabilitaCampo();
	
		
	// Evento change no campo cNrdconta
	cNrdconta.unbind("change").bind("change",function() {
				
		if ($(this).val() == "") {
			return true;
		}
				
		if ( divError.css('display') == 'block' ) { return false; }		
		
		// Valida número da conta
		if (!validaNroConta(retiraCaracteres($(this).val(),"0123456789",true))) {
		
			showError("error","Conta/dv inv&aacute;lida.","Alerta - Ayllos","$('#nrdconta','#frmTrocaOpContaCorrente').focus();blockBackground(parseInt($('#divRotina').css('z-index')));");
			return false;
			
		} 
		
		return true;
		
	});
	
	// Ao pressionar do campo cNrdconta
	cNrdconta.unbind('keypress').bind('keypress', function(e){
	
		if ( divError.css('display') == 'block' ) { return false; }		
		
		//Ao pressionar ENTER, TAB
		if(e.keyCode == 13 || e.keyCode == 9){
		
			$(this).removeClass('campoErro');
			buscaOrgaoPagador(normalizaNumero($('#nrdconta','#frmTrocaOpContaCorrente').val()),cddopcao);
			
			return false;
			
		}
		
	});
	
	//Ao pressionar do campo cIdseqttl
	cIdseqttl.unbind('keypress').bind('keypress', function(e){
		
		if ( divError.css('display') == 'block' ) { return false; }		
		
		//Ao pressionar ENTER, TAB
		if(e.keyCode == 13 || e.keyCode == 9){
		
			$(this).removeClass('campoErro');
			
			$('#btConcluir','#divBotoesTrocaOpContaCorrente').click();
			
			return false;
		}
		
	});
	
	//Adiciona o evento click ao botao btVoltar
	$('#btVoltar','#divBotoesTrocaOpContaCorrente').unbind('click').bind('click', function(){
			
		controlaVoltar('V5');
	    return false;
		
	});
	
	//Adiciona o evento click ao botao btConcluir
	$('#btConcluir','#divBotoesTrocaOpContaCorrente').unbind('click').bind('click', function(){
	
		buscaOrgaoPagador(normalizaNumero($('#nrdconta','#frmTrocaOpContaCorrente').val()),cddopcao);
		return false;	
		
	});
	
	layoutPadrao();
	
	return false;
	
}

function formataAlteracaoCadastral(){

	highlightObjFocus( $('#frmAlteracaoCadastral') );
	
	todosAlteracaoCadastral = $('input','#frmAlteracaoCadastral');
	
	todosAlteracaoCadastral.habilitaCampo();
	
	//Label frmAlteracaoCadastral
	rNrcpfcgc = $('label[for="nrcpfcgc"]','#frmAlteracaoCadastral');
	rDsendere = $('label[for="dsendere"]','#frmAlteracaoCadastral');
	rNrendere = $('label[for="nrendere"]','#frmAlteracaoCadastral');
	rNmbairro = $('label[for="nmbairro"]','#frmAlteracaoCadastral');
	rNrcepend = $('label[for="nrcepend"]','#frmAlteracaoCadastral');
	rNmcidade = $('label[for="nmcidade"]','#frmAlteracaoCadastral');
	rCdufende = $('label[for="cdufende"]','#frmAlteracaoCadastral');
	rNrdddtfc = $('label[for="nrdddtfc"]','#frmAlteracaoCadastral');
	rNrtelefo = $('label[for="nrtelefo"]','#frmAlteracaoCadastral');
	
	
	rNrcpfcgc.css('width','80px').addClass('rotulo');
	rDsendere.css('width','80px').addClass('rotulo');
	rNrendere.css('width','50px').addClass('rotulo-linha');
	rNmbairro.css('width','80px').addClass('rotulo');
	rNrcepend.css('width','30px').addClass('rotulo-linha');
	rNmcidade.css('width','80px').addClass('rotulo');
	rCdufende.css('width','30px').addClass('rotulo-linha');
	rNrdddtfc.css('width','80px').addClass('rotulo');
	rNrtelefo.css('width','5px').addClass('rotulo-linha');
		
	//Campos frmAlteracaoCadastral
	cNrcpfcgc = $('#nrcpfcgc','#frmAlteracaoCadastral');
	cDsendere = $('#dsendere','#frmAlteracaoCadastral');
	cNrendere = $('#nrendere','#frmAlteracaoCadastral');
	cNmbairro = $('#nmbairro','#frmAlteracaoCadastral');
	cNrcepend = $('#nrcepend','#frmAlteracaoCadastral');
	cNmcidade = $('#nmcidade','#frmAlteracaoCadastral');
	cCdufende = $('#cdufende','#frmAlteracaoCadastral');
	cNrdddtfc = $('#nrdddtfc','#frmAlteracaoCadastral');
	cNrtelefo = $('#nrtelefo','#frmAlteracaoCadastral');
	
	cNrcpfcgc.css('width','150px').addClass('cpf');
	cDsendere.css('width','295px').attr('maxlength','40');
	cNrendere.css('width','70px').addClass('numerocasa');
	cNmbairro.css('width','295px').attr('maxlength','17');
	cNrcepend.css('width','90px').addClass('cep');
	cNmcidade.css('width','295px').attr('maxlength','24');
	cCdufende.css('width','35px').attr('maxlength','2').addClass('alpha');
	cNrdddtfc.css('width','40px').attr('maxlength','4').addClass('inteiro');
	cNrtelefo.css('width','80px').attr('maxlength','8').addClass('inteiro');
	
	layoutPadrao();
		
	return false;
	
}

function formataTrocaDomicilio(cddopcao){

	highlightObjFocus( $('#frmTrocaDomicilio') );
	
	//Label do frmTrocaDomicilio
	rOrgbenef = $('label[for="orgbenef"]','#frmTrocaDomicilio');
	rNrdconta = $('label[for="nrdconta"]','#frmTrocaDomicilio');
	rIdseqttl = $('label[for="idseqttl"]','#frmTrocaDomicilio');
	
	rOrgbenef.css('width','230px').addClass('rotulo');
	rNrdconta.css('width','230px').addClass('rotulo');
	rIdseqttl.css('width','230px').addClass('rotulo');
	
	//Campos do frmTrocaDomicilio
	cOrgbenef = $('#orgbenef','#frmTrocaDomicilio');
	cNrdconta = $('#nrdconta','#frmTrocaDomicilio');
	cIdseqttl = $('#idseqttl','#frmTrocaDomicilio');

	cOrgbenef.css('width','200px').desabilitaCampo();
	cNrdconta.css('width','100px').addClass('conta').val($('#nrdconta','#divBeneficio').val()).habilitaCampo();
	cIdseqttl.css({'width':'200px'}).desabilitaCampo();
		
	// Evento change no campo cNrdconta
	cNrdconta.unbind("change").bind("change",function() {
				
		if ($(this).val() == "") {
			return true;
		}
				
		if ( divError.css('display') == 'block' ) { return false; }		
		
		// Valida número da conta
		if (!validaNroConta(retiraCaracteres($(this).val(),"0123456789",true))) {
		
			showError("error","Conta/dv inv&aacute;lida.","Alerta - Ayllos","$('#nrdconta','#frmTrocaOpContaCorrente').focus();");
			return false;
			
		} 
		
		return true;
		
	});
	
	// Ao pressionar do campo cNrdconta
	cNrdconta.unbind('keypress').bind('keypress', function(e){
	
		if ( divError.css('display') == 'block' ) { return false; }		
		
		//Ao pressionar ENTER, TAB
		if(e.keyCode == 13 || e.keyCode == 9){
		
			$(this).removeClass('campoErro');
			buscaTitulares(normalizaNumero($("#nrdconta","#frmTrocaDomicilio").val()),cddopcao)
						
			return false;
			
		}
		
	});
	
	//Ao pressionar do campo cIdseqttl
	cIdseqttl.unbind('keypress').bind('keypress', function(e){
		
		if ( divError.css('display') == 'block' ) { return false; }		
		
		//Ao pressionar ENTER, TAB
		if(e.keyCode == 13 || e.keyCode == 9){
		
			$(this).removeClass('campoErro');
			
			$('#btConcluir','#divBotoesTrocaDomicilio').click();	
			return false;
		}
		
	});
	
	//Adiciona o evento click ao botao btConcluir
	$('#btConcluir','#divBotoesTrocaDomicilio').unbind('click').bind('click', function(){
		
		buscaTitulares(normalizaNumero($("#nrdconta","#frmTrocaDomicilio").val()),cddopcao)
		return false;	
						
	});
	
	
	//Adiciona o evento click ao botao btVoltar
	$('#btVoltar','#divBotoesTrocaDomicilio').unbind('click').bind('click', function (){
		
		controlaVoltar('V6');
		return false;
		
	});
	
	layoutPadrao();

	return false;
	
}

function formataDemonstrativo(cddopcao){

	highlightObjFocus( $('#frmDemonstrativo') );
	
	//Label do frmDemonstrativo
	rDtvalida = $('label[for="dtvalida"]','#frmDemonstrativo');
	rDtvalida.css('width','280px').addClass('rotulo');
		
	//Campos do frmDemonstrativo
	cDtvalida = $('#dtvalida','#frmDemonstrativo');
	cDtvalida.css('width','80px').addClass('dataMesAno').attr('maxlength','7').habilitaCampo();
	
	// Evento keypress no campo cDtvalida
	cDtvalida.unbind('keypress').bind('keypress', function(e){
	
		if ( divError.css('display') == 'block' ) { return false; }		
		
		// Se é a tecla ENTER, TAB
		if ( e.keyCode == 13  || e.keyCode == 9 ) {	
		
			$(this).removeClass('campoErro');
			
			$('#btConcluir','#divBotoesDemonstrativo').click();
			
			return false;
		}
				
	});
	
	//Adiciona o evento click ao botao btVoltar
	$('#btVoltar','#divBotoesDemonstrativo').unbind('clikc').bind('click', function() {
		
		controlaVoltar('V3');
		return false;
	
	});
	
	//Adiciona o evento click no botao btConcluir
	$('#btConcluir','#divBotoesDemonstrativo').unbind('click').bind('click', function() {
	
		showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','solicitaDemonstrativo("' + cddopcao + '");','$(\'#dtvalida\',\'#frmDemonstrativo\').focus();','sim.gif','nao.gif');
		return false;
		
	});
	
	layoutPadrao();

	return false;
	
}

function formataRelatorioBeneficiosPagos(cddopcao){

	highlightObjFocus( $('#frmRelatorioBeneficiosPagos') );
	
	//Label do frmRelatorioBeneficiosPagos
	rCdagenci = $('label[for="cdagenci"]','#frmRelatorioBeneficiosPagos');
	rNrrecben = $('label[for="nrrecben"]','#frmRelatorioBeneficiosPagos');
	rDtinirec = $('label[for="dtinirec"]','#frmRelatorioBeneficiosPagos');
	rDtfinrec = $('label[for="dtfinrec"]','#frmRelatorioBeneficiosPagos');
	
	rCdagenci.css('width','200px').addClass('rotulo');
	rNrrecben.css('width','200px').addClass('rotulo');
	rDtinirec.css('width','200px').addClass('rotulo');
	rDtfinrec.css('width','200px').addClass('rotulo');
	
	//Campos do frmRelatorioBeneficiosPagos
	cCdagenci = $('#cdagenci','#frmRelatorioBeneficiosPagos');
	cNrrecben = $('#nrrecben','#frmRelatorioBeneficiosPagos');
	cDtinirec = $('#dtinirec','#frmRelatorioBeneficiosPagos');
	cDtfinrec = $('#dtfinrec','#frmRelatorioBeneficiosPagos');
			
	cCdagenci.css('width','30px').addClass('inteiro').attr('maxlength','3').habilitaCampo();
	cNrrecben.css('width','110px').addClass('inteiro').attr('maxlength','10').habilitaCampo();
	cDtinirec.css('width','80px').addClass('data').habilitaCampo();
	cDtfinrec.css('width','80px').addClass('data').habilitaCampo();
	
	//Evento keypress do campo cCdagenci
	cCdagenci.unbind('keypress').bind('keypress', function(e){
		
		if ( divError.css('display') == 'block' ) { return false; }		
		
		if(e.keyCode == 13){
		
			$(this).removeClass('campoErro');
			cNrrecben.focus();
			
			return false;
		}
		
	});
	
	//Evento keypress do campo cNrrecben
	cNrrecben.unbind('keypress').bind('keypress', function(e){
		
		if ( divError.css('display') == 'block' ) { return false; }		
		
		if(e.keyCode == 13){
		
			$(this).removeClass('campoErro');
			cDtinirec.focus();
			
			return false;
			
		}
	});
		
	//Evento keypress do campo cDtinirec
	cDtinirec.unbind('keypress').bind('keypress', function(e){
		
		if ( divError.css('display') == 'block' ) { return false; }		
		
		if(e.keyCode == 13){
		
			$(this).removeClass('campoErro');
			cDtfinrec.focus();
				
			return false;
			
		}
		
	});	
	
	//Evento keypress do campo cDtfinrec
	cDtfinrec.unbind('keypress').bind('keypress', function(e){
		
		if ( divError.css('display') == 'block' ) { return false; }		
		
		if(e.keyCode == 13 || e.keyCode == 9){
		
			$(this).removeClass('campoErro');
				
			showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','solicitaRelatorioBeneficiosPagos("' + cddopcao + '");','$(\'#cdagenci\',\'#frmRelatorioBeneficiosPagos\').focus();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));','sim.gif','nao.gif');
			
			return false;
			
		}
		
	});	
		
	//Adiciona o evento click ao botao btVoltar
	$('#btVoltar','#divBotoesRelatorioBeneficiosPagos').unbind('click').bind('click', function(){
	
		controlaVoltar('V5');
		return false;
		
	});
	
	
	//Adiciona o evento click ao botao btConcluir
	$('#btConcluir','#divBotoesRelatorioBeneficiosPagos').unbind('click').bind('click', function(){
	
		showConfirmacao('Deseja confirmar solicita&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','solicitaRelatorioBeneficiosPagos("' + cddopcao + '");','$(\'#cdagenci\',\'#frmRelatorioBeneficiosPagos\').focus();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));','sim.gif','nao.gif');
		return false;
				
	});
	
	//Adiciona o evento click ao botao btConcluir
	$('#btGerados','#divBotoesRelatorioBeneficiosPagos').unbind('click').bind('click', function(){
	
		showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','buscaRelatorioSolicitados(1,30,"PAGOS","' + cddopcao + '");','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));$(\'#cdagenci\',\'#frmRelatorioBeneficiosPagos\').focus();','sim.gif','nao.gif');
	    return false;
		
	});
	
		
	layoutPadrao();
	
	return false;
	
}

function formataRelatorioBeneficiosPagar(cddopcao){

	highlightObjFocus( $('#frmRelatorioBeneficiosPagar') );
	
	//Label do frmRelatorioBeneficiosPagar
	rCdagenci = $('label[for="cdagenci"]','#frmRelatorioBeneficiosPagar');
	rNrrecben = $('label[for="nrrecben"]','#frmRelatorioBeneficiosPagar');
	rDtinirec = $('label[for="dtinirec"]','#frmRelatorioBeneficiosPagar');
	rDtfinrec = $('label[for="dtfinrec"]','#frmRelatorioBeneficiosPagar');
		
	rCdagenci.css('width','200px').addClass('rotulo');
	rNrrecben.css('width','200px').addClass('rotulo');
	rDtinirec.css('width','200px').addClass('rotulo');
	rDtfinrec.css('width','200px').addClass('rotulo');
		
	//Campos do frmRelatorioBeneficiosPagar
	cCdagenci = $('#cdagenci','#frmRelatorioBeneficiosPagar');
	cNrrecben = $('#nrrecben','#frmRelatorioBeneficiosPagar');
	cDtinirec = $('#dtinirec','#frmRelatorioBeneficiosPagar');
	cDtfinrec = $('#dtfinrec','#frmRelatorioBeneficiosPagar');
				
	cCdagenci.css('width','30px').addClass('inteiro').attr('maxlength','3').habilitaCampo();
	cNrrecben.css('width','110px').addClass('inteiro').attr('maxlength','10').habilitaCampo();
	cDtinirec.css('width','80px').addClass('data').habilitaCampo();
	cDtfinrec.css('width','80px').addClass('data').habilitaCampo();
		
	//Evento keypress do campo cCdagenci
	cCdagenci.unbind('keypress').bind('keypress', function(e){
		
		if ( divError.css('display') == 'block' ) { return false; }		
		
		if(e.keyCode == 13){
		
			$(this).removeClass('campoErro');
			cNrrecben.focus();
			
			return false;
		}
		
	});	
	
	//Evento keypress do campo cNrrecben
	cNrrecben.unbind('keypress').bind('keypress', function(e){
		
		if ( divError.css('display') == 'block' ) { return false; }		
		
		if(e.keyCode == 13 || e.keyCode == 9){

			$(this).removeClass('campoErro');
			showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','solicitaRelatorioBeneficiosPagar("' + cddopcao + '");','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));$(\'#cdagenci\',\'#frmRelatorioBeneficiosPagar\').focus();','sim.gif','nao.gif');
			
			return false;
			
		}	
			
	});	
	
//Evento keypress do campo cDtinirec
	cDtinirec.unbind('keypress').bind('keypress', function(e){
		
		if ( divError.css('display') == 'block' ) { return false; }		
		
		if(e.keyCode == 13){
		
			$(this).removeClass('campoErro');
			cDtfinrec.focus();
				
			return false;
			
		}
		
	});	
	
	//Evento keypress do campo cDtfinrec
	cDtfinrec.unbind('keypress').bind('keypress', function(e){
		
		if ( divError.css('display') == 'block' ) { return false; }		
		
		if(e.keyCode == 13 || e.keyCode == 9){
		
			$(this).removeClass('campoErro');
				
			showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','solicitaRelatorioBeneficiosPagar("' + cddopcao + '");','$(\'#cdagenci\',\'#frmRelatorioBeneficiosPagar\').focus();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));','sim.gif','nao.gif');
			
			return false;
			
		}
		
	});	
		
	//Adiciona o evento click ao botao btVoltar
	$('#btVoltar','#divBotoesRelatorioBeneficiosPagar').unbind('click').bind('click', function(){
	
		controlaVoltar('V5');
		return false;
		
	});
		
	//Adiciona o evento click ao botao btConcluir
	$('#btConcluir','#divBotoesRelatorioBeneficiosPagar').unbind('click').bind('click', function(){
	
		showConfirmacao('Deseja confirmar solici&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','solicitaRelatorioBeneficiosPagar("' + cddopcao + '");','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));$(\'#cdagenci\',\'#frmRelatorioBeneficiosPagar\').focus();','sim.gif','nao.gif');
	    return false;
		
	});
	
	//Adiciona o evento click ao botao btConcluir
	$('#btGerados','#divBotoesRelatorioBeneficiosPagar').unbind('click').bind('click', function(){
	
		showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','buscaRelatorioSolicitados(1,30,"PAGAR","' + cddopcao + '");','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));$(\'#cdagenci\',\'#frmRelatorioBeneficiosPagar\').focus();','sim.gif','nao.gif');
	    return false;
		
	});
	
	layoutPadrao();
	
	return false;
	
}

function formataRelatorioHistoricoCadastral(cddopcao){

	highlightObjFocus( $('#frmRelatorioHistoricoCadastral') );
	
	//Label do frmRelatorioBeneficiosPagos
	rNrrecben = $('label[for="nrrecben"]','#frmRelatorioHistoricoCadastral');
		
	rNrrecben.css('width','200px').addClass('rotulo');
	
	//Campos do frmRelatorioBeneficiosPagos
	cNrrecben = $('#nrrecben','#frmRelatorioHistoricoCadastral');
				
	cNrrecben.css('width','110px').addClass('inteiro').attr('maxlength','10').habilitaCampo();
		
	//Evento keypress do campo cNrrecben
	cNrrecben.unbind('keypress').bind('keypress', function(e){
		
		if ( divError.css('display') == 'block' ) { return false; }		
		
		if(e.keyCode == 13){
		
			$(this).removeClass('campoErro');
			$('#btConcluir','#divBotoesRelatorioHistoricoCadastral').click();
			
			return false;
			
		}
	});
		
		
	//Adiciona o evento click ao botao btVoltar
	$('#btVoltar','#divBotoesRelatorioHistoricoCadastral').unbind('click').bind('click', function(){
	
		controlaVoltar('V5');
		return false;
		
	});
	
	
	//Adiciona o evento click ao botao btConcluir
	$('#btConcluir','#divBotoesRelatorioHistoricoCadastral').unbind('click').bind('click', function(){
	
		showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','solicitaRelatorioHistoricoCadastral("' + cddopcao + '");','$(\'#nrrecben\',\'#frmRelatorioHistoricoCadastral\').focus();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));','sim.gif','nao.gif');
		return false;
				
	});
		
	layoutPadrao();

	return false;
	
}

function formataRelatorioProvaVida(cddopcao){

	highlightObjFocus( $('#frmRelatorioProvaVida') );
	
	//Label do frmRelatorioProvaVida
	rCdagenci = $('label[for="cdagenci"]','#frmRelatorioProvaVida');
	rNrrecben = $('label[for="nrrecben"]','#frmRelatorioProvaVida');
	rDtinirec = $('label[for="dtinirec"]','#frmRelatorioProvaVida');
	rDtfinrec = $('label[for="dtfinrec"]','#frmRelatorioProvaVida');
	
	rCdagenci.css('width','200px').addClass('rotulo');
	rNrrecben.css('width','200px').addClass('rotulo');
	rDtinirec.css('width','200px').addClass('rotulo');
	rDtfinrec.css('width','200px').addClass('rotulo');
	
	//Campos do frmRelatorioProvaVida
	cCdagenci = $('#cdagenci','#frmRelatorioProvaVida');
	cNrrecben = $('#nrrecben','#frmRelatorioProvaVida');
	cDtinirec = $('#dtinirec','#frmRelatorioProvaVida');
	cDtfinrec = $('#dtfinrec','#frmRelatorioProvaVida');
			
	cCdagenci.css('width','30px').addClass('inteiro').attr('maxlength','3').habilitaCampo();
	cNrrecben.css('width','110px').addClass('inteiro').attr('maxlength','10').habilitaCampo();
	cDtinirec.css('width','80px').addClass('data').habilitaCampo();
	cDtfinrec.css('width','80px').addClass('data').habilitaCampo();
	
	//Evento keypress do campo cCdagenci
	cCdagenci.unbind('keypress').bind('keypress', function(e){
		
		if ( divError.css('display') == 'block' ) { return false; }		
		
		if(e.keyCode == 13){
		
			$(this).removeClass('campoErro');
			cNrrecben.focus();
			
			return false;
		}
		
	});
	
	//Evento keypress do campo cNrrecben
	cNrrecben.unbind('keypress').bind('keypress', function(e){
		
		if ( divError.css('display') == 'block' ) { return false; }		
		
		if(e.keyCode == 13){
		
			$(this).removeClass('campoErro');
			cDtinirec.focus();
			
			return false;
			
		}
	});
		
	//Evento keypress do campo cDtinirec
	cDtinirec.unbind('keypress').bind('keypress', function(e){
		
		if ( divError.css('display') == 'block' ) { return false; }		
		
		if(e.keyCode == 13){
		
			$(this).removeClass('campoErro');
			cDtfinrec.focus();
				
			return false;
			
		}
		
	});	
	
	//Evento keypress do campo cDtfinrec
	cDtfinrec.unbind('keypress').bind('keypress', function(e){
		
		if ( divError.css('display') == 'block' ) { return false; }		
		
		if(e.keyCode == 13 || e.keyCode == 9){
		
			$(this).removeClass('campoErro');
				
			showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','solicitaRelatorioBeneficiosPagos("' + cddopcao + '");','$(\'#cdagenci\',\'#frmRelatorioBeneficiosPagos\').focus();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));','sim.gif','nao.gif');
			
			return false;
			
		}
		
	});	
		
	//Adiciona o evento click ao botao btVoltar
	$('#btVoltar','#divBotoesRelatorioProvaVida').unbind('click').bind('click', function(){
	
		controlaVoltar('V5');
		return false;
		
	});
	
	
	//Adiciona o evento click ao botao btConcluir
	$('#btConcluir','#divBotoesRelatorioProvaVida').unbind('click').bind('click', function(){
	
		showConfirmacao('Deseja confirmar solicita&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','solicitaRelatorioProvaVida("' + cddopcao + '");','$(\'#cdagenci\',\'#frmRelatorioProvaVida\').focus();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));','sim.gif','nao.gif');
		return false;
				
	});
	
	//Adiciona o evento click ao botao btConcluir
	$('#btGerados','#divBotoesRelatorioProvaVida').unbind('click').bind('click', function(){
	
		showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','buscaRelatorioSolicitados(1,30,"PROVA","' + cddopcao + '");','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));$(\'#cdagenci\',\'#frmRelatorioProvaVida\').focus();','sim.gif','nao.gif');
	    return false;
		
	});
	
		
	layoutPadrao();
	
	return false;
	
}

function controlaVoltar(opcao){
	
	switch(opcao){
	
		case 'V1': 
		
			alteraSecaoNmrotina('');
			estadoInicial(); 
			
		break;
		
		case 'V2':
					
			if( $('#nrcpfcgc','#divBeneficio').hasClass('campoTelaSemBorda') ){
				$('#nrcpfcgc','#divBeneficio').val('').habilitaCampo().focus();
				$('#nrrecben','#divBeneficio').val('').habilitaCampo();
				$('input','#divBeneficio').removeClass('campoErro');
			}else{
				estadoInicial(); 
			}
			
		break;
			
		case 'V3':
			
			$('#divDetalhes').css('display','none').html('');
			$('input','#divBeneficio').val('');
			$('#divBotoesDemonstrativo').css('display','none');
			$('#divBotoesConta').css('display','block');
			$('#nrcpfcgc','#divBeneficio').habilitaCampo().focus();
			$('#nrrecben','#divBeneficio').habilitaCampo();
		
		break;
		
		case 'V4':
		
			$('input','#divBeneficio').val('');
			alteraSecaoNmrotina('');
			$('#divDetalhes').css('display','none').html('');
			$('#divBotoesConsulta').css('display','none');
			$('#divBotoesConta').css('display','block');
			$('#nrcpfcgc','#divBeneficio').habilitaCampo().focus();
			$('#nrrecben','#divBeneficio').habilitaCampo();
			
		break;		
				
		case 'V5':
		
			alteraSecaoNmrotina('');
			fechaRotina($('#divRotina'));
			$('#divRotina').html('');
			$('#tprelato','#divRelatorio').habilitaCampo().focus();
		
		break;
		
		case 'V6':
			
			$('#divDetalhes').css('display','none').html('');
			$('input','#divBeneficio').val('');
			$('#divBotoesTrocaDomicilio').css('display','none');
			$('#divBotoesConta').css('display','block');
			$('#nrcpfcgc','#divBeneficio').habilitaCampo().focus();
			$('#nrrecben','#divBeneficio').habilitaCampo();
			
		break;
		
		case 'V7':
		
			$('input,select','#frmRelatorioBeneficiosPagos').habilitaCampo().limpaFormulario(); 
			$('#frmRelatorioBeneficiosPagos').css('display','block');
			$('#btGerados','#divBotoesRelatorioBeneficiosPagos').css('display','inline');
			$('#btConcluir','#divBotoesRelatorioBeneficiosPagos').css('display','inline');
			
			$('#divTabelaRelatorios').html('');
						
			//Adiciona o evento click ao botao btVoltar
			$('#btVoltar','#divBotoesRelatorioBeneficiosPagos').unbind('click').bind('click', function(){
			
				controlaVoltar('V5');
				return false;
				
			});
			
			$('#cdagenci','#frmRelatorioBeneficiosPagos').focus();
			
		break;
		
		case 'V8':		
			
			$('input,select','#frmRelatorioBeneficiosPagar').habilitaCampo().limpaFormulario();
			$('#frmRelatorioBeneficiosPagar').css('display','block');
			$('#btGerados','#divBotoesRelatorioBeneficiosPagar').css('display','inline');
			$('#btConcluir','#divBotoesRelatorioBeneficiosPagar').css('display','inline');
			
			$('#divTabelaRelatorios').html('');
						
			//Adiciona o evento click ao botao btVoltar
			$('#btVoltar','#divBotoesRelatorioBeneficiosPagar').unbind('click').bind('click', function(){
			
				controlaVoltar('V5');
				return false;
				
			});
			
			$('#cdagenci','#frmRelatorioBeneficiosPagar').focus();
		
		break;
		
    case 'V9':
      $("#divDetalhesLog").css("display","none");
      estadoInicial();
      
    break;
		
    case 'V10':
      $("#divBotoesDetalhar").css("display","none");
      $("#divBotoesLog").css("display","block");
      $("input", "#divConsultaLog").habilitaCampo();
      $("#dtmvtolt", "#divConsultaLog").focus();
      $("#divDetalhes").html('');
            
    break;
      
	}
	
	return false;

}

function buscaTitulares(nrdconta,cddopcao) {
	
	$('input,select').removeClass('campoErro');
		
	showMsgAguardo('Aguarde, buscando titulares...');
		
		
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/inss/busca_titulares.php', 
		data: {
			nrdconta: nrdconta, 
			cddopcao: cddopcao,
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"$('#nrdconta','#divBeneficio').focus();");
		},
		success: function(response) {
			hideMsgAguardo();
			try {
				eval( response );						
			} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();$("#nrdconta","#divBeneficio").focus();');
			}
		}				
	});
	
	return false;
	
}

function solicitaConsultaBeneficiario(cddopcao){

	var nrcpfcgc = normalizaNumero($('#nrcpfcgc','#divBeneficio').val());	
	var nrrecben = $('#nrrecben','#divBeneficio').val(); 
	
	$('input,select').removeClass('campoErro');
	
	//Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, consultando benefici&aacute;rio...');
	
	inclusao = false;
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/inss/solicita_consulta_beneficiario.php',
		data: {
			cddopcao: cddopcao,
			nrcpfcgc: nrcpfcgc,
			nrrecben: nrrecben,
			redirect: 'html_ajax' // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#nrercben','#divBeneficio').focus();");							
		},
		success: function(response) {			
				hideMsgAguardo();
				if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
					try {
						$('#divDetalhes').html(response);
						return false;
					} catch(error) {						
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();$("#nrercben","#divBeneficio").focus();');
					}
				} else {
					try {
						eval( response );						
					} catch(error) {						
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();$("#nrercben","#divBeneficio").focus();');
					}
				}
		}				
	});
		
	return false;
	
}

function solicitaConsultaLog(cddopcao, dtmvtolt, nrrecben, nrdconta, nriniseq, nrregist) {
  
  if (dtmvtolt == '' && nrrecben == '' && (nrdconta == '' || nrdconta == '0000.000-0')) {
    showError('error','Pelo menos um campo do filtro deve ser preenchido.','Alerta - Ayllos','$(\'#dtmvtolt\',\'#divConsultaLog\').focus();');
    return false;
  }
  $('input,select').removeClass('campoErro');
	
	//Mostra mensagem de aguardo
  showMsgAguardo('Aguarde, consultando log...');
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/inss/consulta_log.php',
		data: {
      cddopcao: cddopcao,
			dtreglog: dtmvtolt,
			nrrecben: nrrecben,
			nrdconta: nrdconta,
      nriniseq: nriniseq,
      nrregist: nrregist,
			redirect: 'html_ajax' // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#nrercben','#divBeneficio').focus();");
		},
		success: function(response) {			
				hideMsgAguardo();
				if ( response.indexOf('showError') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
					try {
						$('#divDetalhes').html(response);
						controlaLayoutTabelaLog();
            $('#divPesquisaRodape','#divDetalhes').formataRodapePesquisa();
						$('div.divRegistros').css('display','block');
            $('#divBotoesLog').css('display','none');
						return false;
					} catch(error) {						
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();$("#nrercben","#divBeneficio").focus();');
					}
				} else {
					try {
						eval( response );
					} catch(error) {						
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();$("#nrercben","#divBeneficio").focus();');
					}
				}
		}				
	});
  
	return false;
	
}

function controlaLayoutTabelaLog() {
  
  $('#cabecalho').css('margin','0 auto');
  					
  var divRegistro = $('div.divRegistros');
  var tabela      = $('table', divRegistro );
 
  divRegistro.css('height','200px');
  $('#divDetalhes').css('display','block');
  
  var ordemInicial = new Array();
  ordemInicial = [[1,0]];

  var arrayLargura = new Array();
  arrayLargura[0] = '70px';
  arrayLargura[1] = '180px';
  arrayLargura[2] = '70px';
  arrayLargura[3] = '80px';
  //arrayLargura[4] = '80px';
 
  var arrayAlinha = new Array();
  arrayAlinha[0] = 'center';
  arrayAlinha[1] = 'left';
  arrayAlinha[2] = 'center';
  arrayAlinha[3] = 'center';
  arrayAlinha[4] = 'center';
  
  tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
  
  // seleciona o registro que é clicado
  $('table > tbody > tr', divRegistro).click( function() {
		glbDtmvtolt = $(this).find('#hd_dtmvtolt').val();
    glbHrmvtolt = $(this).find('#hd_hrmvtolt').val();
    glbNrdconta = $(this).find('#hd_nrdconta').val();
    glbNmdconta = $(this).find('#hd_nmdconta').val();
    glbNrrecben = $(this).find('#hd_nrrecben').val();
    glbHistoric = $(this).find('#hd_historic').val();
    glbOperador = $(this).find('#hd_operador').val();
	});
  
  $('table > tbody > tr:eq(0)', divRegistro).click();
  
  $('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #c0c0c0','margin':'3px 0px','padding':'10px 3px 5px 3px'});
	  
}

function carregarDetalheLog() {
  
  showMsgAguardo('Aguarde, buscando detalhamento...');
    
  // Executa script através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/inss/detalhamento_alteracao.php', 
		data: {			
      dtmvtolt: glbDtmvtolt,
      hrmvtolt: glbHrmvtolt,
      nrdconta: glbNrdconta,
      nmdconta: glbNmdconta,
      nrrecben: glbNrrecben,
      historic: glbHistoric,
      operador: glbOperador,
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			$('#divRotina').html(response);
      exibeRotina($('#divRotina'));
      hideMsgAguardo();
      bloqueiaFundo($('#divRotina'));
		}				
	});
  return false;
}

function voltarDetalhes() {
	$("#div~Rotinas").html('');
}

function solicitaAlteracaoCadastral(cddopcao){

	var nrdconta = normalizaNumero($('#nrdconta','#frmConsulta').val());
	var cdorgins = $('#cdorgins','#frmConsulta').val();
	var dtcompvi = $('#dtcompvi','#frmConsulta').val();
	var cdagepac = $('#cdagepac','#frmConsulta').val();
	var cdagesic = $('#cdagesic','#frmConsulta').val();
	var nrrecben = $('#nrrecben','#frmConsulta').val();
	var tpnrbene = $('#tpnrbene','#frmConsulta').val();
	var dscsitua = $('#dscsitua','#frmConsulta').val();
	var idbenefi = $('#idbenefi','#frmConsulta').val();
	var nrcpfcgc = normalizaNumero($('#nrcpfcgc','#frmAlteracaoCadastral').val());
	var idseqttl = $('#idseqttl','#frmConsulta').val();
	var nmbairro = $('#nmbairro','#frmAlteracaoCadastral').val();
	var nrcepend = normalizaNumero($('#nrcepend','#frmAlteracaoCadastral').val());
	var dsendere = $('#dsendere','#frmAlteracaoCadastral').val();
	var nrendere = $('#nrendere','#frmAlteracaoCadastral').val();
	var nmcidade = $('#nmcidade','#frmAlteracaoCadastral').val();
	var cdufende = $('#cdufende','#frmAlteracaoCadastral').val();
	var nmbenefi = $('#nmbenefi','#frmConsulta').val();
	var nrdddtfc = $('#nrdddtfc','#frmAlteracaoCadastral').val();
	var nrtelefo = $('#nrtelefo','#frmAlteracaoCadastral').val();
	var tpdosexo = $('#tpdosexo','#frmConsulta').val();
	var nomdamae = $('#nomdamae','#frmConsulta').val();
	
	$('input,select').removeClass('campoErro');
	
	//Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, solicitando altera&ccedil;&atilde;o cadastral...');
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/inss/solicita_alteracao_cadastral.php',
		data: {
			cddopcao: cddopcao,
			nrdconta: nrdconta,
			cdorgins: cdorgins,
			cdagepac: cdagepac,
			nrrecben: nrrecben,
			tpnrbene: tpnrbene,
			dscsitua: dscsitua,
			idbenefi: idbenefi,
			nrcpfcgc: nrcpfcgc,
			idseqttl: idseqttl,
			nmbairro: nmbairro,
			nrcepend: nrcepend,
			dsendere: dsendere,
			nrendere: nrendere,
			nmcidade: nmcidade,
			cdufende: cdufende,
			cdagesic: cdagesic,
			nmbenefi: nmbenefi,
			nrdddtfc: nrdddtfc,
			nrtelefo: nrtelefo,
			dtcompvi: dtcompvi,
			tpdosexo: tpdosexo,
			nomdamae: nomdamae,
			redirect: 'html_ajax' // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')));$('#btVoltar','#frmAlteracaoCadastral').focus();");							
		},
		success: function(response) {			
				hideMsgAguardo();				
				try {
					eval( response );						
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','blockBackground(parseInt($("#divRotina").css("z-index")));$("#btVoltar","#frmAlteracaoCadastral").focus();');
				}
				
		}				
	});
		
	return false;
	
}
//Verifica se tem senha da internet e se está ativa
function verificaSenhaInternet(retorno, nrdconta, idseqttl){  
  // Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/inss/verifica_senha_internet.php',
		data: {
			nrdconta: nrdconta,
      idseqttl: idseqttl,
       retorno: retorno,
			redirect: 'html_ajax' // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')));$('#btVoltar','#frmAlteracaoCadastral').focus();");							
		},
		success: function(response) {			
				hideMsgAguardo();				
				try {
					eval( response );
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','blockBackground(parseInt($("#divRotina").css("z-index")));$("#btVoltar","#frmAlteracaoCadastral").focus();');
				}
				
		}				
	});
		
	return false;
}
//Solicita senha ao cooperado
function solicitaSenhaInternet(retorno, nrdconta, idseqttl){
  // Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/inss/form_senha_internet.php',
		data: {
      nrdconta: nrdconta,
      idseqttl: idseqttl,
       retorno: retorno,
      redirect: 'html_ajax' // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#nrercben','#divBeneficio').focus();");							
		},
		success: function(response) {			
				hideMsgAguardo();
				if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
					try {
            $('#divRotina').html(response);
            exibeRotina($('#divRotina'));
            bloqueiaFundo($('#divRotina'));
            formataVerificaSenha();
            return false;
					} catch(error) {						
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();');
					}
				} else {
					try {
						eval( response );						
					} catch(error) {						
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();');
					}
				}
		}				
	});
		
	return false;
}
//Valida se a senha está correta
function validaSenhaInternet(retorno,nrdconta,idseqttl){
  
  var cddsenha = $('#cddsenha','#divSolicitaSenha').val();
  
	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/inss/valida_senha_internet.php',
		data: {
			nrdconta: nrdconta,
      idseqttl: idseqttl,
      cddsenha: cddsenha,
       retorno: retorno,
			redirect: 'html_ajax' // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#nrercben','#divBeneficio').focus();");							
		},
		success: function(response) {			
				hideMsgAguardo();
				if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
					try {
						if(response.indexOf(""))
              $('#divRotina').html(response);
            else
              eval(response);
						return false;
					} catch(error) {						
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();');
					}
				} else {
					try {
						eval( response );						
					} catch(error) {						
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();');
					}
				}
		}				
	});
		
	return false;
}

function alertaProvaDeVida(msgpvida){
  if(msgpvida != "") {
    // Executa script através de ajax
    $.ajax({		
      type: 'POST',
      dataType: 'html',
      url: UrlSite + 'telas/inss/msg_alerta.php', 
      data: {
        msgpvida: msgpvida,
        redirect: 'html_ajax'			
        }, 
      error: function(objAjax,responseError,objExcept) {
        hideMsgAguardo();
        showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
      },
      success: function(response) {
        $('#divRotina').html(response);
        exibeRotina($('#divRotina'));
        hideMsgAguardo();
        bloqueiaFundo($('#divRotina'));
      }				
    });
    return false;
  }
}

function solicitaComprovacaoVida(respreno,cddopcao){
  
	cv_nrdconta = normalizaNumero($('#nrdconta','#frmConsulta').val());
	cv_nrcpfcgc = normalizaNumero($('#nrcpfcgc','#frmConsulta').val());
	cv_nmextttl = $('#nmextttl','#frmConsulta').val();
	cv_idseqttl = $('#idseqttl','#frmConsulta').val();
	cv_cdorgins = $('#cdorgins','#frmConsulta').val();
	cv_cdagepac = $('#cdagepac','#frmConsulta').val();
	cv_cdagesic = $('#cdagesic','#frmConsulta').val();
	cv_nrrecben = $('#nrrecben','#frmConsulta').val();
	cv_tpnrbene = $('#tpnrbene','#frmConsulta').val();
	cv_dscsitua = $('#dscsitua','#frmConsulta').val();
	cv_idbenefi = $('#idbenefi','#frmConsulta').val();
	cv_nmprocur = $('#nmprocur','#frmConsulta').val();
	cv_nrdocpro = $('#nrdocpro','#frmConsulta').val();
	cv_dtvalprc = $('#dtvalprc','#frmConsulta').val();
	cv_respreno = respreno;
  cv_cddopcao = cddopcao;
  
  //Verifica se o beneficiario tem senha da internet cadastrada.

  verificaSenhaInternet('comprovaVida();', cv_nrdconta, cv_idseqttl);
  return false;
}

function comprovaVida() {
  $('input,select').removeClass('campoErro');
	
	//Mostra mensagem de aguardo
  showMsgAguardo('Aguarde, solicitando comprova&ccedil;&atilde;o de vida...');
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/inss/solicita_comprovacao_vida.php',
		data: {
			cddopcao: cv_cddopcao,
			nrdconta: cv_nrdconta,
			nrcpfcgc: cv_nrcpfcgc,
			nmextttl: cv_nmextttl,
			idseqttl: cv_idseqttl,
			cdorgins: cv_cdorgins,
			cdagepac: cv_cdagepac,
			nrrecben: cv_nrrecben,
			tpnrbene: cv_tpnrbene,
			idbenefi: cv_idbenefi,			
			cdagesic: cv_cdagesic,
			respreno: cv_respreno,
			nmprocur: cv_nmprocur,
			nrdocpro: cv_nrdocpro,
			dtvalprc: cv_dtvalprc,
      temsenha: possui_senha_internet,
			redirect: 'html_ajax' // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')));$('#btVoltar','#divComprovaVida').focus();");							
		},
		success: function(response) {			
				hideMsgAguardo();				
				try {
					eval( response );						
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','blockBackground(parseInt($("#divRotina").css("z-index")));$("#btVoltar","#divComprovaVida").focus();');
				}
				
		}				
	});
		
	return false;
	
}

function solicitaTrocaOpContaCorrenteEntreCoop(cddopcao){

	var i = $('#idseqttl','#frmTrocaDomicilio').val();
	
	to_nrrecben = $('#nrrecben','#divBeneficio').val();
	to_dtcompvi = $('#dtcompvi','#frmTrocaDomicilio').val();
	to_cdagepac = arrayTitulares[i]['cdagepac'];
	to_cdagesic = arrayTitulares[i]['cdagesic'];
	to_dscsitua = $('#dscsitua','#frmTrocaDomicilio').val();
	to_idbenefi = $('#idbenefi','#frmTrocaDomicilio').val();
	to_nrcpfcgc = normalizaNumero(arrayTitulares[i]['nrcpfcgc']);
	to_idseqttl = normalizaNumero(arrayTitulares[i]['idseqttl']);
	to_nmbairro = arrayTitulares[i]['nmbairro'];
	to_nrcepend = normalizaNumero(arrayTitulares[i]['nrcepend']);
	to_dsendere = arrayTitulares[i]['dsendres'];
	to_nrendere = arrayTitulares[i]['nrendere'];
	to_nmcidade = arrayTitulares[i]['nmcidade'];
	to_cdufende = arrayTitulares[i]['cdufdttl'];
	to_nmbenefi = arrayTitulares[i]['nmextttl'];
	to_nrdddtfc = arrayTitulares[i]['nrdddtfc'];
	to_nrtelefo = arrayTitulares[i]['nrtelefo'];	
	to_cdcopant = $('#cdcopant','#frmTrocaDomicilio').val();
	to_cdorgins = arrayTitulares[i]['cdorgins'];
	to_orgpgant = $('#cdorgins','#frmTrocaDomicilio').val();
	to_nrdconta = arrayTitulares[i]['nrdconta'] ;
	to_nrctaant = $('#nrctaant','#frmTrocaDomicilio').val();
	to_nrcpfant = normalizaNumero($('#nrcpfant','#frmTrocaDomicilio').val());
	to_nomdamae = arrayTitulares[i]['nmmaettl'];
  to_cdsexotl = arrayTitulares[i]['cdsexotl'];
  to_cddopcao = cddopcao;
  
  verificaSenhaInternet('trocaOpContaCorrenteEntreCoop();', to_nrdconta, to_idseqttl);
  return false;
}

function trocaOpContaCorrenteEntreCoop(){
	$('input,select').removeClass('campoErro');
	
	//Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, solicitando troca de domicilio entre cooperativa...');
	
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/inss/solicita_troca_op_conta_corrente_entre_coop.php',
		data: {
			cddopcao: to_cddopcao,
			dtcompvi: to_dtcompvi,
			cdagepac: to_cdagepac,
			cdagesic: to_cdagesic,
			nrrecben: to_nrrecben,
			dscsitua: to_dscsitua,
			idbenefi: to_idbenefi,
			nrcpfcgc: to_nrcpfcgc,
			idseqttl: to_idseqttl,
			nmbairro: to_nmbairro,
			nrcepend: to_nrcepend,
			dsendere: to_dsendere,
			nrendere: to_nrendere,
			nmcidade: to_nmcidade,
			cdufende: to_cdufende,
			nmbenefi: to_nmbenefi,
			nrdddtfc: to_nrdddtfc,
			nrtelefo: to_nrtelefo,
			nomdamae: to_nomdamae,
			cdsexotl: to_cdsexotl,
			cdcopant: to_cdcopant,
			cdorgins: to_cdorgins,
			orgpgant: to_orgpgant,
			nrdconta: to_nrdconta,
			nrctaant: to_nrctaant,			
			nrcpfant: to_nrcpfant,
      temsenha: possui_senha_internet,
			redirect: 'html_ajax' // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')));$('#orgbenef','#frmTrocaDomicilio').focus();");							
		},
		success: function(response) {			
				hideMsgAguardo();				
				try {
					eval( response );						
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','blockBackground(parseInt($("#divRotina").css("z-index")));$("#orgbenef","#frmTrocaDomicilio").focus();');
				}
				
		}			
		
	});
		
	return false;
	
}

function solicitaTrocaOPContaCorrente(cddopcao){

	i = $('#idseqttl','#frmTrocaOpContaCorrente').val();
	
	tc_dtcompvi = $('#dtcompvi','#frmConsulta').val(); 
	tc_cdagepac = arrayTitulares[i]['cdagepac']; 
	tc_cdagesic = arrayTitulares[i]['cdagesic'];
	tc_nrrecben = $('#nrrecben','#frmConsulta').val();
	tc_tpnrbene = $('#tpnrbene','#frmConsulta').val(); 
	tc_dscsitua = $('#dscsitua','#frmConsulta').val();
	tc_idbenefi = $('#idbenefi','#frmConsulta').val(); 
	tc_nrcpfcgc = arrayTitulares[i]['nrcpfcgc'];
	tc_idseqttl = arrayTitulares[i]['idseqttl'];
	tc_nmbairro = arrayTitulares[i]['nmbairro'];
	tc_nrcepend = arrayTitulares[i]['nrcepend'];
	tc_dsendere = arrayTitulares[i]['dsendres'];
	tc_nrendere = arrayTitulares[i]['nrendere'];
	tc_nmcidade = arrayTitulares[i]['nmcidade'];
	tc_cdufende = arrayTitulares[i]['cdufdttl']; 
	tc_nmbenefi = arrayTitulares[i]['nmextttl'];
	tc_nrdddtfc = arrayTitulares[i]['nrdddtfc'];
	tc_nrtelefo = arrayTitulares[i]['nrtelefo'];
	tc_cdsexotl = arrayTitulares[i]['cdsexotl'];
	tc_nomdamae = arrayTitulares[i]['nmmaettl'];
	tc_cdorgins = $('#cdorgins','#frmTrocaOpContaCorrente').val();
	tc_orgpgant = $('#orgpgant','#frmTrocaOpContaCorrente').val();	
	tc_nrdconta = arrayTitulares[i]['nrdconta'];	
	tc_nrctaant = normalizaNumero($('#nrctaant','#frmTrocaOpContaCorrente').val());	
	tc_nrcpfant = normalizaNumero($('#nrcpfcgc','#frmConsulta').val()); 
	tc_sqttlant = normalizaNumero($('#idseqttl','#frmConsulta').val()); 
	tc_cddopcao = cddopcao;
  
  verificaSenhaInternet('trocaOPContaCorrente();', tc_nrctaant, tc_sqttlant);
  
  return false;
}

function trocaOPContaCorrente(){
  
	$('input').removeClass('campoErro');
		
	//Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, solicitando troca de conta corrente...');
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/inss/solicita_troca_op_conta_corrente.php',
		data: {
			cddopcao: tc_cddopcao,
			dtcompvi: tc_dtcompvi,
			cdagepac: tc_cdagepac,
			cdagesic: tc_cdagesic,
			nrrecben: tc_nrrecben,
			tpnrbene: tc_tpnrbene,
			dscsitua: tc_dscsitua,
			idbenefi: tc_idbenefi,
			nrcpfcgc: tc_nrcpfcgc,
			idseqttl: tc_idseqttl,
			nmbairro: tc_nmbairro,
			nrcepend: tc_nrcepend,
			dsendere: tc_dsendere,
			nrendere: tc_nrendere,
			nmcidade: tc_nmcidade,
			cdufende: tc_cdufende,
			nmbenefi: tc_nmbenefi,
			nrdddtfc: tc_nrdddtfc,
			nrtelefo: tc_nrtelefo,
			cdsexotl: tc_cdsexotl,
			nomdamae: tc_nomdamae,
			cdorgins: tc_cdorgins,
			orgpgant: tc_orgpgant,
			nrdconta: tc_nrdconta,
			nrctaant: tc_nrctaant,	
			nrcpfant: tc_nrcpfant,
      temsenha: possui_senha_internet,
			redirect: 'html_ajax' // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')));$('#nrdconta','#frmTrocaOpContaCorrente').focus();");							
		},
		success: function(response) {			
				hideMsgAguardo();				
				try {
					eval( response );
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','blockBackground(parseInt($("#divRotina").css("z-index")));$("#nrdconta","#frmTrocaOpContaCorrente").focus();');
				}
				
		}				
	});
		
	return false;
	
}

function solicitaTrocaDomicilio(cddopcao,seq){
		
	td_idseqttl = arrayTitulares[seq]['idseqttl'] ;	
	td_cdorgins = arrayTitulares[seq]['cdorgins'] ;	
	td_cdagepac = arrayTitulares[seq]['cdagepac'] ;
	td_cdagesic = arrayTitulares[seq]['cdagesic'] ;
	td_nrcpfcgc = normalizaNumero(arrayTitulares[seq]['nrcpfcgc']);
	td_nmbairro = arrayTitulares[seq]['nmbairro'] ;
	td_nrcepend = arrayTitulares[seq]['nrcepend'] ;
	td_dsendres = arrayTitulares[seq]['dsendres'] ;
	td_nrendere = arrayTitulares[seq]['nrendere'] ;
	td_nmcidade = arrayTitulares[seq]['nmcidade'] ;
	td_cdufdttl = arrayTitulares[seq]['cdufdttl'] ;
	td_nmextttl = arrayTitulares[seq]['nmextttl'] ;
	td_nmmaettl = arrayTitulares[seq]['nmmaettl'] ;
	td_nrdddtfc = arrayTitulares[seq]['nrdddtfc'] ;
	td_nrtelefo = arrayTitulares[seq]['nrtelefo'] ;
	td_cdsexotl = arrayTitulares[seq]['cdsexotl'] ;
	td_dtnasttl = arrayTitulares[seq]['dtnasttl'] ;
	td_nrdconta = arrayTitulares[seq]['nrdconta'] ;
	td_nrrecben = $('#nrrecben','#divBeneficio').val();
  td_cddopcao = cddopcao;
  
  verificaSenhaInternet('trocaDomicilio();', td_nrdconta, td_idseqttl);
  
  return false;
  
}

function trocaDomicilio(){
	$('input').removeClass('campoErro');
	
	//Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, solicitando troca de domicilio...');
		
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/inss/solicita_troca_domicilio.php',
		data: {
			cddopcao: td_cddopcao,
			idseqttl: td_idseqttl,
			cdorgins: td_cdorgins,
			cdagepac: td_cdagepac,
			cdagesic: td_cdagesic,
			nrcpfcgc: td_nrcpfcgc,
			nmbairro: td_nmbairro,
			nrcepend: td_nrcepend,
			dsendres: td_dsendres,
			nrendere: td_nrendere,
			nmcidade: td_nmcidade,
			cdufdttl: td_cdufdttl,
			nmextttl: td_nmextttl,
			nmmaettl: td_nmmaettl,
			nrdddtfc: td_nrdddtfc,
			nrtelefo: td_nrtelefo,
			cdsexotl: td_cdsexotl,
			dtnasttl: td_dtnasttl,
			nrdconta: td_nrdconta,
			nrrecben: td_nrrecben,
      temsenha: possui_senha_internet,
			redirect: 'html_ajax' // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')));$('#orgbenef','#frmTrocaDomicilio').focus();");							
		},
		success: function(response) {			
				hideMsgAguardo();				
				try {
					eval( response );						
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','blockBackground(parseInt($("#divRotina").css("z-index")));$("#orgbenef","#frmTrocaDomicilio").focus();');
				}
				
		}				
	});
		
	return false;
	
}

function solicitaDemonstrativo(cddopcao) {	
	 
	var nrrecben = $('#nrrecben','#divBeneficio').val();
	var dtvalida = $('#dtvalida','#frmDemonstrativo').val();
	var nrdconta = $('#nrdconta','#frmDemonstrativo').val();
	var nrcpfcgc = normalizaNumero($('#nrcpfcgc','#frmDemonstrativo').val());
	var cdagesic = $('#cdagesic','#frmDemonstrativo').val();
			           	
	$('input').removeClass('campoErro');
	
	//Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, solicitando demonstrativo...');
		
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/inss/solicita_demonstrativo.php',
		data: {
			cddopcao: cddopcao,
			nrdconta: nrdconta,
			nrcpfcgc: nrcpfcgc,
			nrrecben: nrrecben,
			cdagesic: cdagesic,
			dtvalida: dtvalida,
			redirect: 'html_ajax' // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')));$('#orgbenef','#frmTrocaDomicilio').focus();");							
		},
		success: function(response) {			
				hideMsgAguardo();				
				try {
					eval( response );						
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','blockBackground(parseInt($("#divRotina").css("z-index")));$("#orgbenef","#frmTrocaDomicilio").focus();');
				}
				
		}				
	});
		
	return false;
	
}

function solicitaRelatorioBeneficiosPagos(cddopcao) {
	 
	var cdagesel = $('#cdagenci','#frmRelatorioBeneficiosPagos').val();
	var nrrecben = $('#nrrecben','#frmRelatorioBeneficiosPagos').val();
	var dtinirec = $('#dtinirec','#frmRelatorioBeneficiosPagos').val();
	var dtfinrec = $('#dtfinrec','#frmRelatorioBeneficiosPagos').val();
				           	
	$('input').removeClass('campoErro');
	
	//Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, solicitando relatório...');
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/inss/solicita_relatorio_beneficios_pagos.php',
		data: {
			cddopcao: cddopcao,
			cdagesel: cdagesel,
			nrrecben: nrrecben,
			dtinirec: dtinirec,
			dtfinrec: dtfinrec,
			redirect: 'html_ajax' // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')));$('#cdagenci','#frmRelatorioBeneficiosPagos').focus();");							
		},
		success: function(response) {			
				hideMsgAguardo();				
				try {
					eval( response );						
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','blockBackground(parseInt($("#divRotina").css("z-index")));$("#cdagenci","#frmRelatorioBeneficiosPagos").focus();');
				}
				
		}				
	});
	
	return false;
	
}

function solicitaRelatorioBeneficiosPagar(cddopcao) {	
	 
	var cdagesel = $('#cdagenci','#frmRelatorioBeneficiosPagar').val();
	var nrrecben = $('#nrrecben','#frmRelatorioBeneficiosPagar').val();
	var dtinirec = $('#dtinirec','#frmRelatorioBeneficiosPagar').val();
	var dtfinrec = $('#dtfinrec','#frmRelatorioBeneficiosPagar').val();
					           	
	$('input').removeClass('campoErro');
	
	//Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, solicitando relatório...');
	
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/inss/solicita_relatorio_beneficios_pagar.php',
		data: {
			cddopcao: cddopcao,
			cdagesel: cdagesel,
			nrrecben: nrrecben,
			dtinirec: dtinirec,
			dtfinrec: dtfinrec,
			redirect: 'html_ajax' // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')));$('#cdagenci','#frmRelatorioBeneficiosPagar').focus();");							
		},
		success: function(response) {			
				hideMsgAguardo();				
				try {
					eval( response );						
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','blockBackground(parseInt($("#divRotina").css("z-index")));$("#cdagenci","#frmRelatorioBeneficiosPagar").focus();');
				}
				
		}				
	});
		
	return false;
	
}

function solicitaRelatorioProvaVida(cddopcao) {
	 
	var cdagesel = $('#cdagenci','#frmRelatorioProvaVida').val();
	var nrrecben = $('#nrrecben','#frmRelatorioProvaVida').val();
	var dtinirec = $('#dtinirec','#frmRelatorioProvaVida').val();
	var dtfinrec = $('#dtfinrec','#frmRelatorioProvaVida').val();
				           	
	$('input').removeClass('campoErro');
	
	//Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, solicitando relatório...');
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/inss/solicita_relatorio_prova_vida.php',
		data: {
			cddopcao: cddopcao,
			cdagesel: cdagesel,
			nrrecben: nrrecben,
			dtinirec: dtinirec,
			dtfinrec: dtfinrec,
			redirect: 'html_ajax' // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')));$('#cdagenci','#frmRelatorioProvaVida').focus();");							
		},
		success: function(response) {			
				hideMsgAguardo();				
				try {
					eval( response );						
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','blockBackground(parseInt($("#divRotina").css("z-index")));$("#cdagenci","#frmRelatorioProvaVida").focus();');
				}
				
		}				
	});
	
	return false;
	
}

function relatorioBeneficiosRejeitados(nmrotina,cddopcao) {
	 				           	
	$('input,select').removeClass('campoErro');
	
	//Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, solicitando relatório...');
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/inss/relatorio_beneficios_rejeitados.php',
		data: {
			cddopcao: cddopcao,			
			redirect: 'html_ajax' // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#tprelato','#divRelatorio').focus();");							
		},
		success: function(response) {			
				hideMsgAguardo();				
				try {
					eval( response );						
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();$("#tprelato","#divRelatorio").focus();');
				}
				
		}						
	});
		
	return false;
	
}

function buscaRelatorioSolicitados(nriniseq,nrregist,idtiprel,cddopcao) {	
	 
	$('input').removeClass('campoErro');
	
	(idtiprel == 'PAGOS') ? $('input,select','#frmRelatorioBeneficiosPagos').desabilitaCampo() : $('input,select','#frmRelatorioBeneficiosPagar').desabilitaCampo();
	
	//Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, buscando relatórios...');
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/inss/busca_rel_solicitados.php',
		data: {
			cddopcao: cddopcao,
			idtiprel: idtiprel,
			nrregist: nrregist,
			nriniseq: nriniseq,
			redirect: 'html_ajax' // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')));");							
		},
		success: function(response) {			
				hideMsgAguardo();
				if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
					try {
						$('#divTabelaRelatorios').html(response);
						return false;
					} catch(error) {						
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','blockBackground(parseInt($("#divRotina").css("z-index")));');
					}
				} else {
					try {
						eval( response );						
					} catch(error) {						
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','blockBackground(parseInt($("#divRotina").css("z-index")));');
					}
				}
		}								
	});
		
	return false;
	
}

function solicitaRelatorioHistoricoCadastral(cddopcao) {
	 
	var nrrecben = $('#nrrecben','#frmRelatorioHistoricoCadastral').val();
					           	
	$('input').removeClass('campoErro');
	
	//Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, solicitando relatório...');
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/inss/solicita_relatorio_historico_cadastral.php',
		data: {
			cddopcao: cddopcao,			
			nrrecben: nrrecben,			
			redirect: 'html_ajax' // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')));$('#nrrecben','#frmRelatorioHistoricoCadastral').focus();");							
		},
		success: function(response) {			
				hideMsgAguardo();				
				try {
					eval( response );						
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','blockBackground(parseInt($("#divRotina").css("z-index")));$("#nrrecben","#frmRelatorioHistoricoCadastral").focus();');
				}
				
		}				
	});
	
	return false;
	
}

function buscaOrgaoPagador(nrdconta,cddopcao){
			
	$('input,select').removeClass('campoErro');
	
	//Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, buscando &oacute;rg&atilde;o pagador...');	
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/inss/busca_orgao_pagador.php',
		data: {
			cddopcao: cddopcao,
			nrdconta: nrdconta,		
			redirect: 'html_ajax' // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')));$('#orgbenef','#frmTrocaDomicilio').focus();");							
		},
		success: function(response) {			
				hideMsgAguardo();				
				try {
					eval( response );						
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','blockBackground(parseInt($("#divRotina").css("z-index")));$("#orgbenef","#frmTrocaDomicilio").focus();');
				}
				
		}				
	});
		
	return false;
	
}

// Função para acessar rotinas da tela INSS
function acessaRotina(nmrotina,cddopcao) {

	$('input,select').removeClass('campoErro');
	
	// Mostra mensagem de aguardo	
	showMsgAguardo("Aguarde, carregando rotina...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/inss/acessa_rotinas.php',
		data: {
			cddopcao: cddopcao,
			nmdatela: "INSS",
			nmrotina: nmrotina,			
			redirect: 'html_ajax' // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#nrercben','#divBeneficio').focus();");							
		},
		success: function(response) {			
				hideMsgAguardo();
				if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
					try {
						$('#divRotina').html(response);
						return false;
					} catch(error) {						
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();');
					}
				} else {
					try {
						eval( response );						
					} catch(error) {						
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();');
					}
				}
		}				
	});
	
	return false;
	
}

function alteraSecaoNmrotina(nmrotina,cddopcao){

	$('input,select').removeClass('campoErro');
	
	// Mostra mensagem de aguardo	
	showMsgAguardo("Aguarde...");
	
	// Executa script de alteração de nome da rotina na seção através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + 'telas/inss/altera_secao_nmrotina.php',
		data: {
			nmrotina: nmrotina
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo(); 
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
		}, success: function(response) {			
				hideMsgAguardo();								
		}	
		
	});	
	
	return false;
	
}

function alimentaCamposAltCad(){
	
	var cpf = $('#nrcpfttl','#frmConsulta').val();
	
	if(cpf.length <= 11){	
		$('#nrcpfcgc','#frmAlteracaoCadastral').val(mascara(cpf,'###.###.###-##'));
	}else{
		$('#nrcpfcgc','#frmAlteracaoCadastral').val(mascara(cpf,'##.###.###/####-##'));
	}
	
	$('#dsendere','#frmAlteracaoCadastral').val($('#dsendttl','#frmConsulta').val());
	$('#nrendere','#frmAlteracaoCadastral').val($('#nrendttl','#frmConsulta').val());
	$('#nmbairro','#frmAlteracaoCadastral').val($('#nmbaittl','#frmConsulta').val());
	$('#nrcepend','#frmAlteracaoCadastral').val($('#nrcepttl','#frmConsulta').val());
	$('#nmcidade','#frmAlteracaoCadastral').val($('#nmcidttl','#frmConsulta').val());
	$('#cdufende','#frmAlteracaoCadastral').val($('#ufendttl','#frmConsulta').val());
	$('#nrdddtfc','#frmAlteracaoCadastral').val($('#nrdddttl','#frmConsulta').val());
	$('#nrtelefo','#frmAlteracaoCadastral').val($('#nrtelttl','#frmConsulta').val());
		
	$('input','#frmAlteracaoCadastral').desabilitaCampo();
	
	return false;

}

function Gera_Impressao(nmarqpdf,callback) {	
	
	hideMsgAguardo();	
	
	var action = UrlSite + 'telas/inss/imprimir_pdf.php';
	
	$('#nmarqpdf','#frmCabInss').remove();	
	$('#sidlogin','#frmCabInss').remove();	
	
	$('#frmCabInss').append('<input type="hidden" id="nmarqpdf" name="nmarqpdf" value="' + nmarqpdf + '" />');	
	$('#frmCabInss').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin','#frmMenu').val() + '" />');	
	
	carregaImpressaoAyllos("frmCabInss",action,callback);
	
}

function controlaPesquisa(valor){

	switch(valor){
	
		case 1:
			controlaPesquisaCpf();
		break;
		
		case 2:
			controlaTrocaOpContaCorrente();
		break;
		
		
		case 3:
			controlaTrocaDomicilio();
		break;
		
		case 4:
			controlaRelatorioPagar();
		break;
		
		case 5:
			controlaRelatorioPagos();
		break;		

	}
	
}

function controlaPesquisaCpf(){

	// Se esta desabilitado o campo 
	if ($("#nrcpfcgc","#divBeneficio").prop("disabled") == true)  {
		return;
	}
	
	/* Remove foco de erro */
	$('input','#divBeneficio').removeClass('campoErro'); 
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtrosPesq, colunas;	
	
	//Remove a classe de Erro do form
	$('input','#divBeneficio').removeClass('campoErro');
	
	var nrcpfcgc = normalizaNumero($('#nrcpfcgc','#divBeneficio').val());
		
	bo			= 'b1wgen0091.p';
	procedure	= 'busca_crapdbi';
	titulo      = 'Benefícios';
	qtReg		= '20';					
	filtrosPesq	= 'C.P.F.;nrcpfcgc;110px;S;' + nrcpfcgc + ';S|NB;nrrecben;100px;N;0;N;codigo;';
	colunas 	= 'C.P.F.;nrcpfcgc;50%;right|NB;nrrecben;100%;left;';
	mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas,'','','divBeneficio');
	
	return false;
	
}

function controlaTrocaOpContaCorrente(){
	
	mostraPesquisaAssociado('nrdconta', 'frmTrocaOpContaCorrente',$('#divRotina'));
	
	return false;
	
}

function controlaTrocaDomicilio(){

	mostraPesquisaAssociado('nrdconta', 'frmTrocaDomicilio');
	
	return false;
	
}

function controlaRelatorioPagar(){

	// Se esta desabilitado o campo 
	if ($("#cdagenci","#frmRelatorioBeneficiosPagar").prop("disabled") == true)  {
		return;
	}
	
	/* Remove foco de erro */
	$('input','#frmRelatorioBeneficiosPagar').removeClass('campoErro'); 
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdhistor, titulo_coluna, cdgrupos, dshistor;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmRelatorioBeneficiosPagar';
	
	var divRotina = 'divRotina';
	
	//Remove a classe de Erro do form
	$('input','#'+nomeFormulario).removeClass('campoErro');
			
	bo			= 'b1wgen0059.p';
	procedure	= 'busca_pac';
	titulo      = 'Agência PA';
	qtReg		= '20';					
	filtrosPesq	= 'Cód. PA;cdagenci;30px;S;0;;codigo;|Agência PA;nmresage;200px;S;;;descricao;';
	colunas 	= 'Código;cdagepac;20%;right|Descrição;dsagepac;80%;left';
	mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas,$('#divRotina'));
		
	return false;	

}

function controlaRelatorioPagos(){

	// Se esta desabilitado o campo 
	if ($("#cdagenci","#frmRelatorioBeneficiosPagos").prop("disabled") == true)  {
		return;
	}
	
	/* Remove foco de erro */
	$('input','#frmRelatorioBeneficiosPagos').removeClass('campoErro'); 
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdhistor, titulo_coluna, cdgrupos, dshistor;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmRelatorioBeneficiosPagos';
	
	var divRotina = 'divRotina';
	
	//Remove a classe de Erro do form
	$('input','#'+nomeFormulario).removeClass('campoErro');
			
	bo			= 'b1wgen0059.p';
	procedure	= 'busca_pac';
	titulo      = 'Agência PA';
	qtReg		= '20';					
	filtrosPesq	= 'Cód. PA;cdagenci;30px;S;0;;codigo;|Agência PA;nmresage;200px;S;;;descricao;';
	colunas 	= 'Código;cdagepac;20%;right|Descrição;dsagepac;80%;left';
	mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas,$('#divRotina'));
		
	return false;	
	
}

function controlaRelatorioProvaVida(){

	// Se esta desabilitado o campo 
	if ($("#cdagenci","#frmRelatorioProvaVida").prop("disabled") == true)  {
		return;
	}
	
	/* Remove foco de erro */
	$('input','#frmRelatorioProvaVida').removeClass('campoErro'); 
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdhistor, titulo_coluna, cdgrupos, dshistor;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmRelatorioProvaVida';
	
	var divRotina = 'divRotina';
	
	//Remove a classe de Erro do form
	$('input','#'+nomeFormulario).removeClass('campoErro');
			
	bo			= 'b1wgen0059.p';
	procedure	= 'busca_pac';
	titulo      = 'Agência PA';
	qtReg		= '20';					
	filtrosPesq	= 'Cód. PA;cdagenci;30px;S;0;;codigo;|Agência PA;nmresage;200px;S;;;descricao;';
	colunas 	= 'Código;cdagepac;20%;right|Descrição;dsagepac;80%;left';
	mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas,$('#divRotina'));
		
	return false;	
	
}

function formataTabela() {

	var divRegistro = $('div.divRegistros', '#divRotina' );	
	
	var tabela      = $('table', divRegistro );
	
	divRegistro.css({'height':'207px','border-bottom':'1px dotted #777','padding-bottom':'2px'});	
			
	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '100px';
	//arrayLargura[1] = '50px';
					
	var arrayAlinha = new Array();
	arrayAlinha[1] = 'left';
	arrayAlinha[2] = 'left';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
	
	$('table > tbody > tr', divRegistro).focus( function() {
		selecionaRelatorio($(this));
	
	});
	
	// seleciona o registro que é clicado
	$('table > tbody > tr', divRegistro).click( function() {
		selecionaRelatorio($(this));

	});
			
	return false;
}

function selecionaRelatorio(tr) {
	
	var nmrelato = $('#nmrelato', tr).val();
    
	Gera_Impressao("" + nmrelato + "","$(\"#cdagenci\",\"#divRotina\").focus();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));");
	
    return false;
	
}

function controlaFoco() {

	//Ao pressionar botao cddopcao
	$('#cddopcao','#frmCabInss').unbind('keypress').bind('keypress', function(e){
    
    $('input,select').removeClass('campoErro');
		
		// Se é a tecla ENTER, TAB
		if(e.keyCode == 13 || e.keyCode == 9){
			
			$(this).desabilitaCampo();
						
			if($(this).val() == 'R'){
			
				$('#frmOpcoes').css('display','block');
				$('#divRelatorio').css('display','block');
				$('#divBotoesRelatorio').css('display','block');								
				
			}else if($('#cddopcao','#frmCabInss').val() == 'L'){
        $('#frmOpcoes').css('display','block');
        $('#divConsultaLog').css('display','block');
        $('#divBotoesLog').css('display','block');
      }
      else{
      
        $('#frmOpcoes').css('display','block');
        $('#divBeneficio').css('display','block');
        $('#divBotoesConta').css('display','block');
                                
      }
			
			$('#btOK','#frmCabInss').unbind('click');
			formataOpcoes( $(this).val() );
			
			return false;						
		}
						
	});
	
	//Ao clicar no botao OK
	$('#btOK','#frmCabInss').unbind('click').bind('click', function(){
		
    if ( $('#cddopcao','#frmCabInss').hasClass('campoTelaSemBorda')  ) { return false; }
		
		$('input,select').removeClass('campoErro');
		$('#cddopcao','#frmCabInss').desabilitaCampo();
						
		if($('#cddopcao','#frmCabInss').val() == 'R'){
		
			$('#frmOpcoes').css('display','block');
			$('#divRelatorio').css('display','block');
			$('#divBotoesRelatorio').css('display','block');
						
		}else if($('#cddopcao','#frmCabInss').val() == 'L'){
		
			$('#frmOpcoes').css('display','block');
			$('#divConsultaLog').css('display','block');
			$('#divBotoesLog').css('display','block');
			$('#dtmvtolt','#divConsultaLog').focus();
					
		}else {
			
			$('#frmOpcoes').css('display','block');
			$('#divBeneficio').css('display','block');
			$('#divBotoesConta').css('display','block');
			$('#nrdconta','#divBeneficio').focus();
			
		}
		
		$(this).unbind('click');
		
		formataOpcoes( $('#cddopcao','#frmCabInss').val() );
								
	});
	
	//Ao pressionar botao OK
	$('#btOK','#frmCabInss').unbind('keypress').bind('keypress', function(e){
	
    if ( $('#cddopcao','#frmCabInss').hasClass('campoTelaSemBorda')  ) { return false; }	
		
		$('input,select').removeClass('campoErro');
		
		// Se é a tecla ENTER, TAB
		if(e.keyCode == 13 || e.keyCode == 9){
			
			$('#cddopcao','#frmCabInss').desabilitaCampo();
			
			if($('#cddopcao','#frmCabInss').val() == 'R'){
			
				$('#frmOpcoes').css('display','block');
				$('#divRelatorio').css('display','block');
				$('#divBotoesRelatorio').css('display','block');
							
			}else if($('#cddopcao','#frmCabInss').val() == 'L'){
			
				$('#frmOpcoes').css('display','block');
				$('#divConsultaLog').css('display','block');
				$('#divBotoesLog').css('display','block');
				$('#dtmvtolt','#divConsultaLog').focus();
							
			}else{
			
				$('#frmOpcoes').css('display','block');
				$('#divBeneficio').css('display','block');
				$('#divBotoesConta').css('display','block');
				$('#nrdconta','#divBeneficio').focus();
									
			}
			
			$(this).unbind('click');				
			formataOpcoes( $('#cddopcao','#frmCabInss').val() );
			
			return false;
			
		}
					
	});	
	
	$('input','#divConsultaLog').unbind('keypress').bind('keypress', function(e) {
			if (e.keyCode == 13) {	
				solicitaConsultaLog($('#cddopcao','#frmCabInss').val()
                           ,$('#dtmvtolt','#divConsultaLog').val()
                           ,$('#nrrecben','#divConsultaLog').val()
                           ,$('#nrdconta_log','#divConsultaLog').val()
                           ,1,20);
        return false;
			}	
	});
  
  $('#nrdconta','#divConsultaLog').unbind('keypress').bind('keypress', function(e) {
			if (e.keyCode == 9) {	
				solicitaConsultaLog($('#cddopcao','#frmCabInss').val()
                           ,$('#dtmvtolt','#divConsultaLog').val()
                           ,$('#nrrecben','#divConsultaLog').val()
                           ,$('#nrdconta_log','#divConsultaLog').val()
                           ,1,20);
        return false;
			}	
	});
	
}
