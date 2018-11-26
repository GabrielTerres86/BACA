<?php
	/*!
    * FONTE        : form_incluir_lancamento.php
	* CRIAÇÃO      : Alcemir Junior - Mout's
	* DATA CRIAÇÃO : 10/10/2018
	* OBJETIVO     : form para a inclusao de lançamento da tela SLIP
	* --------------
	* ALTERAÇÕES   :
	* --------------
	*/
	
?>


<div id="divIncLancamento" name="divIncLancamento">
	<form id="frmIncLancamento" name="frmIncLancamento" class="formulario" onSubmit="return false;" style="display:block">
	

		<fieldset style="display:block;">

			<label for="dtmvtolt"><? echo utf8ToHtml("Data:") ?></label>
		    <input name="dtmvtolt" type="text"  id="dtmvtolt" class="data campo" value ="<?php echo $glbvars["dtmvtolt"]; ?>"  style="width: 75px;" disabled>
			
			<label for="cdoperad"><? echo utf8ToHtml("Operador:") ?></label>
			<input name="cdoperad" type="text"  id="cdoperad" class="campo" value ="<?php echo $glbvars["cdoperad"]; ?>" style="width: 200px;" disabled>
		</fieldset>

		<div id="divInclusaoAlteracao" name="divInclusaoAlteracao">
			<fieldset id="fsIncLancamento" style="display:block">
			<legend><? echo utf8ToHtml("Inclusão de Lançamentos") ?></legend>
				<fieldset>			
						            
					<label for="cdhistor"><? echo utf8ToHtml("Hist. Aimaro:") ?></label>
					<input name="cdhistor" type="text"  id="cdhistor" class="inteiro campo" style="width: 55px;">

					<label for="nrctadeb"><? echo utf8ToHtml("Conta Débito:") ?></label>
					<input name="nrctadeb" type="text"  id="nrctadeb" class="inteiro campo" style="width: 50px;">

					<label for="nrctacrd"><? echo utf8ToHtml("Conta Crédito:") ?></label>
					<input name="nrctacrd" type="text"  id="nrctacrd" class="inteiro campo" style="width: 50px;">

					<label for="vllanmto"><? echo utf8ToHtml("Vlr. Lanc.:") ?></label>
					<input name="vllanmto" type="text" class="campo" id="vllanmto">
					<br style="clear:both" />
					<label for="cdhistor_padrao"><? echo utf8ToHtml("Hist. Padrão:") ?></label>
					<input name="cdhistor_padrao" type="text"  id="cdhistor_padrao" class="inteiro campo" style="width: 50px;">
							
					<label for="dslancamento"><? echo utf8ToHtml("Descrição:") ?></label>
					<input name="dslancamento" type="text"  id="dslancamento" class="campo" style="width: 380px;">
				</fieldset>				          			 	

				<div id="divTabBotoesGerRis">
					<table width="100%">
						<tbody><tr>
						<div id="divBtAcoes" style="left-padding:2px ;display: flex; flex-direction: row;justify-content: center;align-items: center">
								<a href="#" class="botao" id="btMostrarGer"  name="btMostrarGer" style="display: inline-block;">Gerencial</a>	
								<a href="#" class="botao" id="btMostrarRat"  name="btMostrarRat" style="display: inline-block;">Risco Oper.</a>									
						</div>			
						</tr>
					</tbody></table>
				</div>
				
				
				<div id="divRateio" style="display:none">	

				<fieldset id="fsRiscoRat" style="display:none">
					<legend style="text-align: center" ><? echo utf8ToHtml("Risco Operacional") ?></legend>								    		
						
						<div id="incRiscoRat">
							<label for="cdrisco_operacionalRat"><? echo utf8ToHtml("Risco Oper.:") ?></label>
							<input name="cdrisco_operacionalRat" type="text"  id="cdrisco_operacionalRat" class="campo" style="width: 103px;">
														
							<a href="#" class="botao" id="btIncluirRisRat" onclick="incluirRisRat(); return false;" name="btIncluirRisRat">Incluir</a>	
						</div>

						<div id="tabRiscoRat">
							<fieldset id="fsTabRiscolRat" style="display:block">			
							<div class="divRegistros">
								
								<table class="tituloRegistros" id="tbRiscoRat">
									<thead>								
										<tr>
											<th><? echo utf8ToHtml("Risco Oper.");?></th>																				
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

										
					<fieldset id="fsGerencialRat" style="display:none">
					<legend style="text-align: center" ><? echo utf8ToHtml("Rateio Gerencial") ?></legend>								    		
						
						<div id="incGerencialRat">
							<label for="cdgerencialRat"><? echo utf8ToHtml("Gerencial:") ?></label>
							<input name="cdgerencialRat" type="text"  id="cdgerencialRat" class="inteiro campo" style="width: 55px;">
							
							<label for="vllanmtoRat"><? echo utf8ToHtml("Valor:") ?></label>
							<input name="vllanmtoRat" type="text" class="campo" id="vllanmtoRat">
							
							<a href="#" class="botao" id="btIncluirGerRat" onclick="incluirGerRat(); return false;" name="btIncluirGerRat">Incluir</a>	
						</div>

						<div id="tabGerencialRat">
							<fieldset id="fsTabGerencialRat" style="display:block">			
							<div class="divRegistros">
								
								<table class="tituloRegistros" id="tbGerencialRat">
									<thead>								
										<tr>
											<th><? echo utf8ToHtml("Gerencial");?></th>									
											<th><? echo utf8ToHtml("Valor Rateio");?></th>																					
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
				</div>
			</fieldset>
		</div>

		<div id="divResultadoLanc" style="display:block;">
							
		</div>

		<div id="divTabBotoes">
			<table width="100%">
				<tbody><tr>
					<div id="divBtAcoes" style="left-padding:2px ;display: flex; flex-direction: row;justify-content: center;align-items: center">
						<a href="#" class="botao" id="btInluirlanc" onclick="controlaInclusaoLanc(); return false;" name="btIncGerencial" style="display: inline-block;">Incluir Lanc.</a>	
						<a href="#" class="botao" id="btAlterarLanc" onclick="controlaAlteracaoLanc(); return false;" name="btIncRisco" style="display: inline-block;">Alterar Lanc.</a>	
						<a href="#" class="botao" id="btExcluirLanc" onclick="controlaExclusaoLanc(); return false;" name="btIncRisco" style="display: inline-block;">Excluir Lanc</a>	
					</div>			
				</tr>
			</tbody></table>
		</div>

	    	
	</form>		
</div>	

