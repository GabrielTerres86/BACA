/*!
 * FONTE        : protecao_credito.js
 * CRIAÇÃO      : Gabriel Ramirez (RKAM)
 * DATA CRIAÇÃO : 14/04/2015
 * OBJETIVO     : Biblioteca de funções da rotina de consultas automatizadas
 * --------------
 * ALTERAÇÕES   : 12/09/2018 - P442 - Novos campos das Consultas (Marcos-Envolit)
 *
 */
 

function formata_protecao (operacao, nrinfcad , dsinfcad ) {

	var nomeForm = 'frmOrgaos';
	var altura   = '360px';
	var largura  = '510px';
		
	var cTodos    = $('select,input','#'+ nomeForm);
	var cNmtitcon = $('#nmtitcon','#'   + nomeForm);
	var cDtconbir = $('#dtconbir','#'   + nomeForm);
	var cInreapro = $('#inreapro','#'   + nomeForm);
	var cNrinfcad = $('#nrinfcad','#'   + nomeForm);
	var cDsinfcad = $('#dsinfcad','#'   + nomeForm);
	var cDtcnsspc = $('#dtcnsspc','#'   + nomeForm);
	var cQtnegati = $('input[name="qtnegati"]','#'   + nomeForm);
	var cVlnegati = $('input[name="vlnegati"]','#'   + nomeForm);
	var cNrcpfcgc = $('#nrcpfcgc','#'   + nomeForm);
	var cNmtitsoc = $('#nmtitsoc','#'   + nomeForm);
	var cDtdrisco = $('#dtdrisco','#'   + nomeForm);
	var cQtopescr = $('#qtopescr','#'   + nomeForm);
	var cQtifoper = $('#qtifoper','#'   + nomeForm);
	var cVltotsfn = $('#vltotsfn','#'   + nomeForm);
	var cVlopescr = $('#vlopescr','#'   + nomeForm);
	var cVlrpreju = $('#vlrpreju','#'   + nomeForm);
	var cQtnegati_coluna = $("#qtnegati_coluna" , "#"+ nomeForm);
	var cVlnegati_coluna = $("#vlnegati_coluna" , "#"+ nomeForm);
	var cDtultneg_coluna = $("#dtultneg_coluna" , "#"+ nomeForm);
			
	var rRotulo   = $('label[for="nmtitcon"],label[for="dsconsul"],label[for="dtconbir"],' 		     + 
					  'label[for="dsnegati"],label[for="dtconbir"],label[for="nrinfcad"]'  			 + 
					  'label[for="qtnegati_coluna"],label[for="nrcpfcgc"],label[for="dtdrisco"],' +
					  'label[for="vltotsfn"]', '#'+nomeForm );
					  
	var rAlinha   = $('label[for="nmtitcon"],label[for="dtconbir"]');
	var rAlinha_2 = $('label[for="dtcnsspc"],label[for="nrinfcad"]');				  
	
	var rInreapro = $('label[for="inreapro"]');		
	var rDsconsul = $('label[for="dsconsul"]');
	var rDsnegati = $('label[for="dsnegati"]');
	var rVlnegati = $('label[for="vlnegati"]');
	var rNmtitsoc = $('label[for="nmtitsoc"]');
	var rDtdrisco = $('label[for="dtdrisco"]');
	var rQtopescr = $('label[for="qtopescr"]');
	var rQtifoper = $('label[for="qtifoper"]');
	var rVltotsfn = $('label[for="vltotsfn"]');
	var rVlopescr = $('label[for="vlopescr"]');
	var rVlrpreju = $('label[for="vlrpreju"]');
	
	
	var rqtnegati_coluna = $('label[for="qtnegati_coluna"]','#'+nomeForm );
	var rvlnegati_coluna = $('label[for="vlnegati_coluna"]','#'+nomeForm );
	var rdtultneg_coluna = $('label[for="dtultneg_coluna"]','#'+nomeForm );

	cTodos.desabilitaCampo();
	cNmtitcon.css('width','280px');
	cDtconbir.css('width','75px');
	cInreapro.css('width','40px');
	cDtcnsspc.css('width','75px');
	cNrinfcad.css('width','40px');
	cDsinfcad.css('width','250px');
	cQtnegati.css('width','80px').css('text-align','right');
	cDtdrisco.css('width','75px').css('text-align','right');
	cQtopescr.css('width','46px').css('text-align','right');
	cQtifoper.css('width','42px').css('text-align','right');
	cVlnegati.css('width','90px').css('text-align','right');	
	cVltotsfn.css('width','75px').css('text-align','right');
	cVlopescr.css('width','80px').css('text-align','right');
	cVlrpreju.css('width','80px').css('text-align','right');
	cQtnegati_coluna.css('width','92px').css('text-align','right');
	cVlnegati_coluna.css('width','80px').css('text-align','right');
	cDtultneg_coluna.css('width','75px');
	cNrcpfcgc.css('width','90px');
	cNmtitsoc.css('width','180px');

	rRotulo.addClass('rotulo'); 
	rAlinha.css('width','170px').css('text-align','right');
	rAlinha_2.css('width','130px').css('text-align','right');
	rInreapro.css('width','130px').css('text-align','right');
	rDsconsul.css('width','100%').css('text-align','center');
	rDsnegati.css('width','170px').css('text-align','left');
	rVlnegati.css('width','40px');
	rNmtitsoc.css('width','50px');
	rqtnegati_coluna.css('width','92px').css('text-align','center');
	rvlnegati_coluna.css('width','80px').css('text-align','center');
	rdtultneg_coluna.css('width','85px');
	rDtdrisco.css('width','90px');
	rQtopescr.css('width','90px');
	rQtifoper.css('width','100px');
	
	rVltotsfn.css('width','90px');
	rVlopescr.css('width','57px');
	rVlrpreju.css('width','60px');

	cNrinfcad.val(nrinfcad);
		
	if (operacao == 'A_PROTECAO_TIT' || operacao == "I_PROTECAO_TIT") {
		cDtcnsspc.habilitaCampo();
		cNrinfcad.habilitaCampo();
	}
			
	controlaPesquisasProtecao();
	
	cNrinfcad.trigger('change');
	
	layoutPadrao();
	removeOpacidade('divConteudoOpcao');
	bloqueiaFundo(divRotina);
	
	return false;
		
}

function controlaPesquisasProtecao () {

	var nomeForm = 'frmOrgaos';

	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, nrtopico, nritetop;

	// Atribui a classe lupa para os links de desabilita todos
	var lupas = $('a:not(.lupaFat)','#'+nomeForm);

	lupas.addClass('lupa').css('cursor','auto');

	// Percorrendo todos os links
	lupas.each( function() {
	
		if ( !$(this).prev().hasClass('campoTelaSemBorda') ) $(this).css('cursor','pointer');
		
		$(this).unbind('click').bind('click', function() {

			if ( $(this).prev().hasClass('campoTelaSemBorda') ) {
				return false;	
			}
			
			// Obtenho o nome do campo anterior
			campoAnterior = $(this).prev().attr('name');
						
			 if ( campoAnterior == 'nrinfcad' ) {
				bo			= 'b1wgen0059.p';
				procedure   = 'busca_seqrating';
				titulo      = 'Itens do Rating';
				qtReg		= '20';
				nrtopico    = ( inpessoa == 1 ) ? '1' : '3';
				nritetop    = ( inpessoa == 1 ) ? '4' : '3';
				filtros		= 'C&oacuted. Inf. Cadastral;nrinfcad;30px;S;0|Inf. Cadastral;dsinfcad;200px;S;|;nrtopico;;;'+nrtopico+';N|;nritetop;;;'+nritetop+';N|;flgcompl;;;no;N';
				colunas 	= 'Seq. Item;nrseqite;20%;right|Descri&ccedil&atildeo Seq. Item;dsseqite;80%;left;dsseqit1';
				mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,divRotina);
				return false;
			}				
		});	
	});

	$('#nrinfcad','#'+nomeForm).unbind('change').bind('change',function() {	
		bo			= 'b1wgen0059.p';
		procedure   = 'busca_seqrating';
		titulo      = 'Informa&ccedil&atildeo Cadastral';
		nrtopico    = ( inpessoa == 1 ) ? '1' : '3';
		nritetop    = ( inpessoa == 1 ) ? '4' : '3';
		filtrosDesc = 'nrtopico|'+nrtopico+';nritetop|'+nritetop+';flgcompl|no;nrseqite|'+$(this).val();
		buscaDescricao(bo,procedure,titulo,$(this).attr('name'),'dsinfcad',$(this).val(),'dsseqit1',filtrosDesc,nomeForm);
	});	
	
	$('#nrinfcad','#'+nomeForm).unbind('keypress').bind('keypress',function(e) {	
		if ( e.keyCode == 13 ) {	
			return false;
		}
	});
}