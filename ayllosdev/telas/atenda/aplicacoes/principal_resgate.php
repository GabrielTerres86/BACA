<?php 

	/*******************************************************************************
	 Fonte: principal_resgate.php                                      
	 Autor:                                                             
	 Data : 					                 Ultima Alteracao: 30/04/2014         
	                                                                         
	 Objetivo  : Mostra os bot�es da rotina de resgate                      
	                                                                          
	 Alteracoes:  30/04/2014 - Ajuste referente ao projeto Capta��o:
							  - Layout dos bot�es
							  - Verficar se fonte est� sendo chamado via
							    m�todo POST
						      (Adriano).
							  
	*******************************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	

?>


<div id="divResgate">

	<div id="divBotoes" style="margin-top:5px; margin-bottom :10px; text-align: center;">
		
		<a href="#" class="botao" id="btnVoltar" >Voltar</a>	
		<a href="#" class="botao" id="btResgate" onClick="acessaOpcaoCadastroResgate();return false;" >Resgate</a>	
		<a href="#" class="botao" id="btCancelamento" onClick="obtemResgates(true);return false;" >Cancelamento</a>	
		<a href="#" class="botao" id="btProximos" onClick="obtemResgates(false);return false;" >Pr&oacute;ximos</a>	

	</div>
	
</div>