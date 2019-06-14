<?php
	/*!
    * FONTE        : form_parametrizacao.php
	* CRIAÇÃO      : Alcemir Junior - Mout's
	* DATA CRIAÇÃO : 10/10/2018
	* OBJETIVO     : form para a parapetrização da tela SLIP
	* --------------
	* ALTERAÇÕES   :
	* --------------
	*/
?>

<div id="divParametrizacao" name="divParametrizacao">
	<form id="frmParametrizacao" name="frmParametrizacao" class="formulario" onSubmit="return false;" style="display:block">
		<fieldset id="fsParametrizacao" style="display:block">
		<legend><? echo utf8ToHtml("Parametrização") ?></legend>
			
			<label for="nrconta_contabil"><? echo utf8ToHtml("Conta:") ?></label>
			<input name="nrconta_contabil" type="text"  id="nrconta_contabil" class="inteiro campo" style="width: 55px;">
            
            <label for="cdhistor"><? echo utf8ToHtml("Hist. Padrão:") ?></label>
			<input name="cdhistor" type="text"  id="cdhistor" class="inteiro campo" style="width: 55px;">

			<label for="idexige_rateio_gerencial"><? echo utf8ToHtml("Necessita Gerencial:") ?></label>
			<select class="campo" id="idexige_rateio_gerencial" name="idexige_rateio_gerencial">
				<option value="S"><? echo utf8ToHtml("Sim") ?></option>
				<option value="N"><? echo utf8ToHtml("Não") ?></option>
			</select>

			<label for="idexige_risco_operacional"><? echo utf8ToHtml("Necessita Risco Oper.:") ?></label>
			<select class="campo" id="idexige_risco_operacional" name="idexige_risco_operacional">
				<option value="S"><? echo utf8ToHtml("Sim") ?></option>
				<option value="N"><? echo utf8ToHtml("Não") ?></option>
		 	</select>

		 	<a href="#" class="botao" id="btIncluirParam" name="btIncluirParam" style = "text-align:right;">Incluir</a>
		


			<br style="clear:both" />
		    			
			<div id="tabParametrizacao" style="display:block" >
				<fieldset id="fsTabParametrizacao">	
		    	<legend><? echo utf8ToHtml("Lista Parametrizada") ?></legend>			    	

					<div class="divRegistros">			
						<table class="tituloRegistros" id="tbParametrizacao">
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