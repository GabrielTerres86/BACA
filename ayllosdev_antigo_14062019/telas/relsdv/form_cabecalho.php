<?php
/*
 * FONTE              :  form_cabecalho.php
 * CRIAÇÃO          : Jean Calão (Mout´S)
 * DATA CRIAÇÃO : Fevereiro / 2017
 * OBJETIVO         : Cabeçalho para a tela RELSDV
 * --------------
 * ALTERAÇÕES    :  
 *
 *                
 * --------------
 */
?>
<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;" style="display:block">
	
	
	
	<div id="divOpcoes2" style="display:block">
	    <br>
		<label for="nmdarqui">Arquivo para importa&ccedil;&atilde;o: </label>
		<input type="text" id="nmdarqui" name="nmdarqui"  size=100 value='<?php echo "/microsd3/".$glbvars["dsdircop"]."/relsdv/cecred2.csv"; ?>'/>
		
		<br style="clear:both" />		
		<label for="nmdarsai">Arquivo para exporta&ccedil;&atilde;o: </label>
		<input type="text" id="nmdarsai" name="nmdarsai" size=100  value='<?php echo "/microsd3/".$glbvars["dsdircop"]."/relsdv/relsaida2.csv"; ?>'/>
		
		<br style="clear:both" />		
		<br style="clear:both" />		
		
		<fieldset>
		<div id="exemplo" style="height:120px">
		<label style="text-align:left">
			&nbsp;&nbsp;Formato do arquivo de importa&ccedil;&atilde;o (CSV exemplo):</br>
			&nbsp;&nbsp;Nº Coop;Nº Conta;Nº Contrato;</br>
			&nbsp;&nbsp;<? echo $glbvars["cdcooper"]; ?>;748340;158582
		</label>
		</div>
		</fieldset>
		<br style="clear:both" />
		<fieldset>
		<div id="exemplo" style="height:120px">
		<label style="text-align:left">
			&nbsp;&nbsp;Formato do arquivo de exporta&ccedil;&atilde;o (CSV):</br>
			&nbsp;&nbsp;Nº Coop;Nº Conta;Nº Contrato;Saldo Devedor</br>
			&nbsp;&nbsp;<? echo $glbvars["cdcooper"]; ?>;748340;158582;1000.00
		</label>
		</div>
		</fieldset>
	</div>
			
    <br style="clear:both" />				
</form>
