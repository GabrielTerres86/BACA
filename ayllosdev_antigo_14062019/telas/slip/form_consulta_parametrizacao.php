<?php
	/*!
    * FONTE        : form_consulta_parametrizacao.php
	* CRIAÇÃO      : Alcemir Junior - Mout's
	* DATA CRIAÇÃO : 10/10/2018
	* OBJETIVO     : form para consultar parametrização da tela SLIP
	* --------------
	* ALTERAÇÕES   :
	* --------------
	*/
?>

<div id="divConParametrizacao" name="divConParametrizacao">
	<form id="frmConParametrizacao" name="frmConParametrizacao" class="formulario" onSubmit="return false;" style="display:block">
		<fieldset id="fsConParametrizacao">
		<legend><? echo utf8ToHtml("Parametrização") ?></legend>
			
			<label for="nrconta_contabil"><? echo utf8ToHtml("Conta:") ?></label>
			<input name="nrconta_contabil" type="text"  id="nrconta_contabil" class="inteiro campo" style="width: 55px;">
            
            <label for="cdhistor"><? echo utf8ToHtml("Hist. Padrão:") ?></label>
			<input name="cdhistor" type="text"  id="cdhistor" class="inteiro campo" style="width: 55px;">

		 	<a href="#" class="botao" id="btConsultaOK" name="btConsultaOK" style = "text-align:right;">Consultar</a>
	
			<br style="clear:both"/>
		    	
				<div id="tabConParametrizacao">
					<fieldset id="fsTabConParametrizacao">	
			    	<legend><? echo utf8ToHtml("Lista Parametrizada") ?></legend>			    	
				
						<div class="divRegistros">			
							<table class="tituloRegistros" id="tbConParametrizacao">
								<thead>								
									<tr>
										<th><? echo utf8ToHtml("Conta Contábil");?></th>							
										<th><? echo utf8ToHtml("Hist. Padrão");?></th>								
										<th><? echo utf8ToHtml("Gerencial");?></th>								
										<th><? echo utf8ToHtml("Risco Oper.");?></th>																	
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