<?php 

	/************************************************************************
	 Fonte: principal_resgatar_varias.php                                               
	 Autor: Fabricio                                                     
	 Data : Agosto/2011                		�ltima altera��o: 30/04/2014 
	                                                                  
	 Objetivo  : Mostra div com os bot�es da tela "Resgatar V�rios"                                         
	                                                                  
	 Altera��es: 30/04/2014 - Ajuste referente ao projeto Capta��o:
							  - Layout dos bot�es
							  - Verficar se fonte est� sendo chamado via
							    m�todo POST
						      (Adriano).				  
							  
	************************************************************************/
?>

<div id="divResgatarVarias">

	<div id="divBotoes" style="margin-top:5px; margin-bottom :10px; text-align: center;">

		<a href="#" class="botao" id="btnVoltar2" >Voltar</a>
		<a href="#" class="botao" id="btAutomatica" onClick="acessaOpcaoResgates(true);return false;" >Autom&aacute;tica</a>
		<a href="#" class="botao" id="btManual" onClick="acessaOpcaoResgates(false);return false;" >Manual</a>
		<a href="#" class="botao" id="btCancelamento" onClick="obtemResgatesVarias(true);return false;">Cancelamento</a>
		<a href="#" class="botao" id="btProximos" onClick="obtemResgatesVarias(false);return false;" >Pr&oacute;ximos</a>

	</div>
	
</div>