<?php
	/*!
    * FONTE        : form_Gerencial.php
	* CRIAÇÃO      : Alcemir Junior - Mout's
	* DATA CRIAÇÃO : 10/10/2018
	* OBJETIVO     : form Parametrizar gerenciais da tela SLIP
	* --------------
	* ALTERAÇÕES   :
	* --------------
	*/
?>

<div id="divRisco" name="divRisco">
	<form id="frmRisco" name="frmRisco" class="formulario" onSubmit="return false;" style="display:inline-block">
						 		
		<fieldset id="fsRisco" style="display:none">
		<legend style="text-align: center" ><? echo utf8ToHtml("Parametrização Risco") ?></legend>								    		
						
			<div id="tabListaRisco">
					<fieldset>
					<table width="100%">
						<thead>								
							<tr>
								<th> 
									<div id="tabRisco">
									<div class="divRegistros">
										
										<table class="tituloRegistros" id="tbRisco">
											<thead>								
												<tr>
													<th> <? echo utf8ToHtml("Código");?></th>									
													<th><? echo utf8ToHtml("Descrição");?></th>																					
												</tr>								
											</thead>
											<tbody>
											</tbody>
										</table>		
									
									</div> 
									</div>	   
								</th>									
							    <th >
								  <fieldset id="fsCtaContabil" style="display:none;">
										<legend style="text-align: center" ><? echo utf8ToHtml("Contas Contabeis Usadas") ?></legend>								    		
														
											<div id="tabCtaContabil">
												
												<div class="divRegistros">
													
													<table class="tituloRegistros" id="tbCtaContabil">
														<thead>								
															<tr>
																<th> <? echo utf8ToHtml("Código");?></th>																    																				
															</tr>								
														</thead>
														<tbody>
														</tbody>
													</table>		
												
												</div> 					
											</div>     
									</fieldset>
								</th>																					
							</tr>								
						</thead>
						<tbody>
						</tbody>
					</table>
				</fieldset>
				

									
			</div>	        
		</fieldset>

		


		<fieldset id="fsTabincRisco" style="display:none">
		<legend style="text-align: center" ><? echo utf8ToHtml("Parametrização Risco") ?></legend>								    		
			
			<div id="incRisco">
				<label for="cdrisco_operacional"><? echo utf8ToHtml("Código:") ?></label>
				<input name="cdrisco_operacional" type="text"  id="cdrisco_operacional" class="campo" style="width: 100px;">
	            <br style="clear:both" />
			 	<label for="dsrisco_operacional"><? echo utf8ToHtml("Descrição:") ?></label>
				<input name="dsrisco_operacional" type="text"  id="dsrisco_operacional" class="campo" style="width: 200px;">	            			
		    </div>

			<div id="tabIncRisco">
				<fieldset id="fstabIncRisco" style="display:block">			
				<legend style="text-align: center" ><? echo utf8ToHtml("Contas Contabeis Usadas") ?></legend>								    		
				<label for="nrconta_contabil"><? echo utf8ToHtml("Conta Contabil:") ?></label>
				<input name="nrconta_contabil" type="text"  id="nrconta_contabil" class="inteiro campo" style="width: 55px;">
				
				<a href="#" class="botao" id="btIncluirCta" onclick="incluirCtaRisco(); return false;" name="btIncluirCta">Incluir</a>	
				
				<div class="divRegistros">					
					<table class="tituloRegistros" id="tbIncRisco">
						<thead>								
							<tr>
								<th> <? echo utf8ToHtml("Código");?></th>									
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

		<div id="divTabBotoesRisco">
			<table width="100%">
				<tbody><tr>
					<div id="divBtAcoes" style="left-padding:2px ;display: flex; flex-direction: row;justify-content: center;align-items: center">
						<a href="#" class="botao" id="btInluirRisco" onclick="controlaInclusaoRisco(); return false;" name="btInluirRisco" style="display: inline-block;">Incluir</a>	
						<a href="#" class="botao" id="btAlterarRisco" onclick="controlaAlteracaoRisco(); return false;" name="btAlterarRisco" style="display: inline-block;">Alterar</a>							
					</div>			
				</tr>
			</tbody></table>
		</div>


	</form>		
</div>	