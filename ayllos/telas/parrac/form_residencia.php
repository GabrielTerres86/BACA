<? 
/*!
 * FONTE        : form_residencia.php
 * CRIAÇÃO      : Jonata Cardoso - (RKAM)
 * DATA CRIAÇÃO : 04/02/2015
 * OBJETIVO     : Tela para selecionar as residencias
 * --------------
 * ALTERAÇÕES   : 
 */
 
?>

<?php
 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	
	
	$nr_operacao =  substr($operacao,10,1) + 1;
?>

<form id="frmResidencia" name="frmResidencia" class="formulario" onSubmit="return false;">

	<fieldset>
		<legend><? echo utf8ToHtml('Tipo de Residência'); ?></legend>

		<br />
		<input type="checkbox" name="incasprp" id="Quitado"    value="1" <? echo (in_array("1",explode(";",$dscasprp))) ? "checked" : "" ?> > <label> 1 - Quitado    </label><br>
		<br />
		<input type="checkbox" name="incasprp" id="Financiado" value="2" <? echo (in_array("2",explode(";",$dscasprp))) ? "checked" : "" ?> > <label> 2 - Financiado </label><br>
		<br />
		<input type="checkbox" name="incasprp" id="Alugado"    value="3" <? echo (in_array("3",explode(";",$dscasprp))) ? "checked" : "" ?> > <label> 3 - Alugado    </label><br>
		<br />
		<input type="checkbox" name="incasprp" id="Familiar"   value="4" <? echo (in_array("4",explode(";",$dscasprp))) ? "checked" : "" ?> > <label> 4 - Familiar   </label><br>
		<br />
		<input type="checkbox" name="incasprp" id="Cedido"     value="5" <? echo (in_array("5",explode(";",$dscasprp))) ? "checked" : "" ?> > <label> 5 - Cedido     </label><br>
		<br />
	
	</fieldset>	

</form>

<div id="divBotoes" style="margin-bottom:8px">
    <a href="#" class="botao" id="btVoltar" onclick="fechaOpcao(); return false;">Voltar</a>  
    <a href="#" class="botao" id="btSalvar" onclick="atualizaResidencia(); fechaOpcao(); return false;">Continuar</a>   
</div>

<script> 
		
	$(document).ready(function(){
		formataResidencia();
	});

</script>