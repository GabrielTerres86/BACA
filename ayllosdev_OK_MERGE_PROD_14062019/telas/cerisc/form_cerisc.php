<?php
/* 
 * FONTE        : form_cerisc.php
 * CRIAÇÃO      : Douglas Pagel - AMcom
 * DATA CRIAÇÃO : 06/11/2018
 * OBJETIVO     : Formulário de exibição da tela CERISC
 * ALTERAÇÕES   : 
 *                
 *
 */
?>

<form name="frmCERISC" id="frmCERISC" class="formulario" style="display:block;">	
    <br style="clear:both" />
	<input type="hidden" id="dsdepart" name="dsdepart" value="<?php echo $glbvars["dsdepart"]; ?>" />
    <input type="hidden" id="idctrlab" name="idctrlaba" value="COOPER" />
	
	<fieldset>
		<legend>Risco Melhora</legend>
		
		<label for="percliq" class='labelPri'>Percentual de liquidação para redução de risco das operações sem garantia:</label>
		<input title="Define o percentual do saldo da operação sem garantia precisa ser pago para que o sistema possa tentar calcular o risco melhora" type="text" id="percliq" name="percliq" class="inteiro" value="<?php echo $prperliq == 0 ? '' : $prperliq ?>" maxlength="6" style="text-align:right;"/>
		<label>&nbsp;%</label>		
		<br style="clear:both" />
		
		<label for="perccob" class='labelPri'>Percentual de cobertura das aplicações bloqueadas:</label>
		<input title="Define o percentual do total das aplicações bloqueadas precisa cobrir do saldo devedor do contrato para que a operação seja considerada com garantia no cálculo do risco melhora" type="text" id="perccob" name="perccob" class="inteiro" value="<?php echo $prpercob == 0 ? '' : $prpercob ?>" maxlength="6" style="text-align:right;"/>	
		<label>&nbsp;%</label>		
		<br style="clear:both" />

		<label for="nivel" class='labelPri'>Menor risco melhora possível:</label>
		<select title="Define o menor risco possível calculado pelo risco melhora, caso o contrato tenha o risco menor ou igual a este risco, ele será ignorado no cálculo do risco melhora" id="nivel" name="nivel" style="width:100px;">
			<option value='1'> AA </option>
			<option value='2'> A </option>
			<option value='3'> B </option>
			<option value='4'> C </option>
			<option value='5'> D </option>
			<option value='6'> E </option>
			<option value='7'> F </option>
			<option value='8'> G </option>
			<option value='9'> H </option>
			
		</select>   
		<br style="clear:both" />
		
	</fieldset>

</form>

<div id="divBotoes" name="divBotoes" style="margin-bottom:5px">
	<a href="#" class="botao" id="btVoltar"  onclick="estadoInicial();
	return false;">Voltar</a>
	<a href="#" class="botao" id="btContinuar"  onClick="confirmaOperacao();
	return false;">Alterar</a>
</div>
