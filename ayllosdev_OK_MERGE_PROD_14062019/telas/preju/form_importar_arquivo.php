<?php
/*
 * FONTE              :  form_importar_arquivo.php
 * CRIA��O          : Jean Cal�o (Mout�S)
 * DATA CRIA��O : 20/07/2017
 * OBJETIVO         : Cabe�alho para a tela RELSDV
 * --------------
 * ALTERA��ES    :  
 *
 *                
 * --------------
 */
?>
<form id="frmImportar" name="frmImportar" class="formulario cabecalho" onSubmit="return false;" style="display:block">
	
	
	
	<div id="divOpcoes2" style="display:block">
	    <br>
		<!--<label for="nmdarqui">Arquivo para importa&ccedil;&atilde;o: </label>-->
		<input type="file" id="nmdarqui" name="nmdarqui"  size=100 style="height: 25px;" class='campo'> <!-- value='<php echo "/micros/".$glbvars["dsdircop"]."/prejuz/prejuizo.csv"; >'/>-->
		
		<br style="clear:both" />		
		<br style="clear:both" />		
		
		<fieldset>
		<div id="exemplo" style="height:120px">
		<label style="text-align:left">
			&nbsp;&nbsp;Formato do arquivo de importa&ccedil;&atilde;o (CSV exemplo):</br>
			&nbsp;&nbsp;N� Coop;Tipo (CC ou EP);N� Conta;N� Contrato;</br>
			&nbsp;&nbsp;<? echo $glbvars["cdcooper"]; ?>;CC;748340;748340</br>
			&nbsp;&nbsp;<? echo $glbvars["cdcooper"]; ?>;EP;748340;15025</br>
		</label>
		</div>
		</fieldset>
		<br style="clear:both" />
	</div>
			
    <br style="clear:both" />				
</form>
