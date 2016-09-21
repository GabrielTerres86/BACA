//************************************************************************//
//*** Fonte: folhas_cheque.js                                          ***//
//*** Autor: David                                                     ***//
//*** Data : Fevereiro/2008               Ultima Alteracao: 27/06/2012 ***//
//***                                                                  ***//
//*** Objetivo  : Biblioteca de funcoes da rotina Folhas de Cheque da  ***//
//***             tela ATENDA                                          ***//
//***                                                                  ***//	 
//*** Alteracoes: 													   ***//
//***			  27/06/2012 - Alterado esquema para impressao em      ***//
//***						   carrega_lista() (Jorge)    			   ***//
//************************************************************************//

// Funcao para carregar lista de cheques n&atilde;o compensados em PDF
function carrega_lista() {	
	
	var nmprimtl = $("#nmprimtl","#frmCabAtenda").val().search("E/OU") == "-1" ? $("#nmprimtl","#frmCabAtenda").val() : $("#nmprimtl","#frmCabAtenda").val().substr(0,$("#nmprimtl","#frmCabAtenda").val().search("E/OU") - 1);

	$("#nrdconta","#frmCheques").val(nrdconta);
	$("#nmprimtl","#frmCheques").val(nmprimtl);
	
	var action = $("#frmCheques").attr("action");
	var callafter = "encerraRotina(false);";
	
	carregaImpressaoAyllos("frmCheques",action,callafter);
}