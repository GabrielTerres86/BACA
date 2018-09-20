<?php 

	//************************************************************************//
	//*** Fonte: lista_cheques_acesso.php                                  ***//
	//*** Autor: David                                                     ***//
	//*** Data : Fevereiro/2008               Ultima Alteracao: 12/07/2012 ***//
	//***                                                                  ***//
	//*** Objetivo  : Emitir lista de cheques n&atilde;o compensados       ***//
	//***                                                                  ***//	 
	//*** Alteracoes: 12/07/2012 - Alterado parametro de $pdf->Output,     ***//  
	//***   					   Condicao para  Navegador Chrome (Jorge).***//
	//***   		                                                       ***//	 
	//***             29/05/2018 - Alterada permissao da tela.             ***//  
	//***   					   PRJ366(Lombardi).                       ***//
	//************************************************************************//
	
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');	
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();
	
	// Verifica permissões de acessa a tela
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C',false)) <> '') 
		exibirErro('error',$msgError,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);

?>	
carrega_lista();

