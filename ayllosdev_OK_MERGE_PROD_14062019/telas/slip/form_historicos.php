<?php
	/*!
    * FONTE        : form_historicos.php
	* CRIAÇÃO      : Alcemir Junior - Mout's
	* DATA CRIAÇÃO : 10/10/2018
	* OBJETIVO     : form para a parapetrização da tela SLIP
	* --------------
	* ALTERAÇÕES   :
	* --------------
	*/
?>

<div id="divHistoricos" name="divHistoricos">
	<form id="frmHistoricos" name="frmHistoricos" class="formulario" onSubmit="return false;" style="display:block">
		
		<fieldset id="fsHistoricos" style="display:block">
		<legend><? echo utf8ToHtml("Parametrização Históricos") ?></legend>
			
			<label for="cdhistor"><? echo utf8ToHtml("Histórico:") ?></label>
			<input name="cdhistor" type="text"  id="cdhistor" class="inteiro campo" style="width: 55px;">
            
            <label for="nrctadeb"><? echo utf8ToHtml("Conta Débito:") ?></label>
			<input name="nrctadeb" type="text"  id="nrctadeb" class="inteiro campo" style="width: 55px;">

            <label for="nrctacrd"><? echo utf8ToHtml("Conta Crédito:") ?></label>
			<input name="nrctacrd" type="text"  id="nrctacrd" class="inteiro campo" style="width: 55px;">

		 	<a href="#" class="botao" id="btIncluirHist" name="btIncluirHist" style = "text-align:right;">Incluir</a>		

			<br style="clear:both" />
		    			
			<div id="tabHistoricos" style="display:block">
				<fieldset id="fsTabHistoricos">	
		    	<legend><? echo utf8ToHtml("Lista Parametrizada") ?></legend>			    	

					<div class="divRegistros">			
						<table class="tituloRegistros" id="tbHistoricos">
							<thead>								
								<tr>														
									<th><? echo utf8ToHtml("Histórico");?></th>								
									<th><? echo utf8ToHtml("Conta Débito");?></th>								
									<th><? echo utf8ToHtml("Conta Crédito");?></th>								
									<th><? echo utf8ToHtml("Exclusão");?></th>
								</tr>								
							</thead>
							<tbody>
							</tbody>
						</table>		
					</div> 
				</fieldset>
				</div>	        

		</fieldset>

	    		


	</form>		
</div>	