<?php
/*
   FONTE        : form_libcrm.php
   CRIAÇÃO      : Kelvin Souza Ott
   DATA CRIAÇÃO : 09/08/2017
   OBJETIVO     : Tela de exibicao do formulario da tela libcrm
   --------------
   ALTERAÇÕES   :
 */		
 
?>


<form id="frmLibCrm" name="frmLibCrm" class="formulario" >		
	<div style="width:100%;">
		<fieldset style="width:95%; padding-left:20px; height:100px"  >
			<legend align="left"><? echo 'Parâmetros Gerais' ?></legend>
			<div style="text-align:center; margin-top: 25px;">
				<div style="display:inline-block; ">
					<label for="flgaccrm" class="rotulo" >Libera acesso ao sistema Ayllos?</label>
				</div>
				<div style="display:inline-block; ">
					<select name="flgaccrm" id="flgaccrm" class="campo">
						<option value="0">Não</option>					
						<option value="1">Sim</option>
					</select>				
				</div>
			</div>				
		</fieldset>
	</div>	
</form>
<br/>	
<div id="divBotoes" style="padding-bottom:10px; ">	
	<a href="#" class="botao" id="btnConfirmar" onClick="alteraParametros(); return false;" >Alterar</a>
</div>