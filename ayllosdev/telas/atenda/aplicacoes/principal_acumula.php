<?php 
    /************************************************************************
      Fonte: principal_acumula.php
      Autor: ???
      Data : ???                      �ltima Altera��o: 30/04/2014
      
      Altera��es: 30/04/2014 - Ajuste referente ao projeto Capta��o:
	  				 		   - Layout dos bot�es
	  				 		   - Verficar se fonte est� sendo chamado via
	  						     m�todo POST
	  					       (Adriano).
	  						  
	************************************************************************/

	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
	
?>	  

<div id="divAcumula">

	<div id="divBotoes" style="margin-top:5px; margin-bottom :10px; text-align: center;">
		
		<a href="#" class="botao" id="btVoltar" onClick="voltarDivPrincipal();return false;">Voltar</a>
		<a href="#" class="botao" id="btConsultar" onClick="consultaSaldoAcumulado();return false;">Consultar</a>
		<a href="#" class="botao" id="btSimular" onClick="opcaoSimulacao();return false;" >Simular</a>

	</div>
	
</div>
