<?php
/*!
 * FONTE        : form_emprestimo.php
 * CRIAÇÃO      : Daniel Zimmermann  (daniel.zimmermann@cecred.coop.br)       
 * DATA CRIAÇÃO : 12/11/2013
 * OBJETIVO     : Formulario para tela EMPRES
 * --------------
 * ALTERAÇÕES   : 01/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
 * --------------
 */
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();	

?>

<div id="divEmprestimo" name="divEmprestimo">
	<form id="frmEmprestimo" name="frmEmprestimo" class="formulario" onSubmit="return false;" style="display:none">
		
		<table width="100%">
			<tr>
				<td>
					<fieldset>
						<legend>Emprestimo</legend>
						<table width='100%'>
							<tr>
								<td colspan="2">
									<label for='cdpesqui'><? echo utf8ToHtml('Pesquisa:') ?></label>
									<input name="cdpesqui" type="text"  id="cdpesqui" class='campo' />
								</td>
							</tr>
							<tr>
								<td>
									<label for="vlemprst"><? echo utf8ToHtml('Valor Emprestado:') ?></label>	
									<input name="vlemprst" type="text"  id="vlemprst" class='campo' />
									<label for="txdjuros"><? echo utf8ToHtml('Taxa Juros:') ?></label>	
									<input name="txdjuros" type="text"  id="txdjuros" class='campo'/>
								</td>
							</tr>
							<tr>
								<td>
									<label for="vlsdeved"><? echo utf8ToHtml('Saldo Devedor:') ?></label>	
									<input name="vlsdeved" type="text"  id="vlsdeved" class='campo'/>
									<label for="vljurmes"><? echo utf8ToHtml('Juros do M&ecirc;s:') ?></label>	
									<input name="vljurmes" type="text"  id="vljurmes" class='campo'/>
								</td>
							</tr>
							<tr>
								<td>
									<label for="vlpreemp"><? echo utf8ToHtml('Valor Presta&ccedil;&atilde;o:') ?></label>	
									<input name="vlpreemp" type="text"  id="vlpreemp" class='campo'/>
									<label for="vljuracu"><? echo utf8ToHtml('Juros Acumulados:') ?></label>	
									<input name="vljuracu" type="text"  id="vljuracu" class='campo'/>
								</td>
							</tr>
							<tr>
								<td>
									<label for="vlprepag"><? echo utf8ToHtml('Valor pago no M&ecirc;s:') ?></label>	
									<input name="vlprepag" type="text"  id="vlprepag"  class='campo'/>
									<label for="qtmesdec"><? echo utf8ToHtml('Meses Decorridos:') ?></label>	
									<input name="qtmesdec" type="text"  id="qtmesdec" class='campo'/>
								</td>
							</tr>
							<tr>
								<td>
									<label for="vlpreapg"><? echo utf8ToHtml('A Regularizar:') ?></label>	
									<input name="vlpreapg" type="text" id="vlpreapg" class="campo" />
									<label for="dsdpagto"><? echo utf8ToHtml('') ?></label>
									<input name="dsdpagto" type="text" id="dsdpagto" class="campo" />
								</td>
							<td>
								
							</td>
						</tr>
						</table>
					</fieldset>
				</td>
			</tr>
			<tr>		
				<td>
					<fieldset>
						<legend><? echo utf8ToHtml('Presta&ccedil;&otilde;es:') ?></legend>
						<table width='100%'>
							<tr>
								<td>
									<label for="qtprecal"><? echo utf8ToHtml('Pagas:') ?></label>	
									<input name="qtprecal" type="text"  id="qtprecal" class='campo' />
									<label for="dslcremp"><? echo utf8ToHtml('L. Credito:') ?></label>	
									<input name="dslcremp" type="text"  id="dslcremp" class='campo' />
								</td>
							</tr>
							<tr>
								<td>
									<label for="qtpreapg"><? echo utf8ToHtml('A Pagar:') ?></label>	
									<input name="qtpreapg" type="text"  id="qtpreapg" class='campo' />
									<label for="dsfinemp"><? echo utf8ToHtml('Finalidade:') ?></label>	
									<input name="dsfinemp" type="text"  id="dsfinemp" class='campo' />
								</td>
							</tr>
						</table>
					</fieldset>
				</td>
			</tr>
			<tr>
				<td>
					<fieldset>
						<legend>Avalistas</legend>
						<table width='100%'>
							<tr>
								<td><label for="nrctaav1"><? echo utf8ToHtml('Aval 1:') ?></label>
									<input name="nrctaav1" type="text"  id="nrctaav1" class='campo' />
									<input name="cpfcgc1"  type="text"  id="cpfcgc1"  class='campo' />
									<input name="nmdaval1" type="text"  id="nmdaval1" class='campo' />
									<label for="nrraval1"><? echo utf8ToHtml('Ramal:') ?></label>
									<input name="nrraval1" type="text"  id="nrraval1" class="campo"  />
								</td>
							</tr>
							<tr>
								<td><label for="nrctaav2"><? echo utf8ToHtml('Aval 2:') ?></label>
									<input name="nrctaav2" type="text"  id="nrctaav2" class='campo' />
									<input name="cpfcgc2"  type="text"  id="cpfcgc2"  class='campo' />
									<input name="nmdaval2" type="text"  id="nmdaval2" class='campo' />
									<label for="nrraval2"><? echo utf8ToHtml('Ramal:') ?></label>
									<input name="nrraval2" type="text"  id="nrraval2" class="campo"  />
								</td>
							</tr>
						</table>
					</fieldset>
				</td>
			</tr>
		</table>
	</form>
</div>