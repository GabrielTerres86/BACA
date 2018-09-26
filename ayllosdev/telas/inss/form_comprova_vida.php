<?php
/*****************************************************************
  Fonte        : form_comprova_vida.php
  Criação      : Adriano
  Data criação : Junho/2013
  Objetivo     : Mostra o form de comprovação de vida da tela INSS
  --------------
	Alteracoes   : 03/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
  --------------
 ****************************************************************/ 

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();		
?>

<div id="divComprovaVida" style=";margin-top:5px; margin-bottom :10px; display:none;">

	<br />
	<br />
	
	<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('V5');">Voltar</a>
	<a href="#" class="botao" id="btCmpBene" onClick="showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Aimaro','solicitaComprovacaoVida(\'BENEFICIARIO\',\'<?echo $cddopcao;?>\');','$(\'#btVoltar\',\'#divComprovaVida\').focus();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));','sim.gif','nao.gif');return false;" >Comprovar pelo Beneficiário</a> 
	<a href="#" class="botao" id="btCmpProc" onClick="showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Aimaro','solicitaComprovacaoVida(\'PROCURADOR\',\'<?echo $cddopcao;?>\');','$(\'#btVoltar\',\'#divComprovaVida\').focus();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));','sim.gif','nao.gif');return false;">Comprovar pelo Procurador</a> 

	<br />
	<br />
	<br />
	
</div>
				
	
