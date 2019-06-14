<?php 

	/************************************************************************
	 Fonte: principal_resgatar_varias.php                                               
	 Autor: Fabricio                                                     
	 Data : Agosto/2011                		Última alteração: 30/04/2014 
	                                                                  
	 Objetivo  : Mostra div com os botões da tela "Resgatar Vários"                                         
	                                                                  
	 Alterações: 30/04/2014 - Ajuste referente ao projeto Captação:
							  - Layout dos botões
							  - Verficar se fonte está sendo chamado via
							    método POST
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