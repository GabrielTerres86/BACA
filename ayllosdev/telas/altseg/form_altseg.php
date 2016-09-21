<?
/*!
 * FONTE        : form_altseg.php
 * CRIAÇÃO      : Cristian Filipe         
 * DATA CRIAÇÃO : Setembro/2013
 * OBJETIVO     : Formulario para tela ALTSEG
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();	

?>

<div id="divAltseg" name="divAltseg">
	<form id="frmInfSeguradora" name="frmInfSeguradora" class="formulario" onSubmit="return false;" style="display:none">
		<fieldset>
			<legend>Seguradora</legend>
			<table width="100%">
				<tr>
					<td>
						<label for="cdsegura"><? echo utf8ToHtml('Seguradora:') ?></label>	
						<input name="cdsegura" type="text"  id="cdsegura" class='campo'/>
						<a href="#" onclick="controlaPesquisaSeguradora();return false;" style="padding: 3px 0 0 3px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
						<input name="nmresseg" type="text"  id="nmresseg" class='campo' maxlength='3' />
					</td>
				</tr>
				<tr>		
					<td>
						<label for="tpseguro"><? echo utf8ToHtml('Tipo Seguro:') ?></label>	
						<select class='campo' name='tpseguro' id='tpseguro' >
							<option value='3'>3 - Vida</option>
							<option value='4'>4 - Prestamista</option>
							<option value='11'>11 - Casa</option>
						</select>
							
						<label for="tpplaseg"><? echo utf8ToHtml('Tipo Plano:') ?></label>	
						<input name="tpplaseg" type="text"  id="tpplaseg" class='campo' maxlength='3' />
                        <a href="#" onclick="controlaPesquisaTipoPlano();return false;" style="padding: 3px 0 0 3px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
					</td>
				</tr>
			</table>
		</fieldset>
	</form>
	<form id="frmInfPlano" name="frmInfPlano" class="formulario" onSubmit="return false;" style="display:none">
		<fieldset>
			<legend>Plano</legend>
			<table width="100%">
				<tr>		
					<td>
						<label for="dsmorada"><? echo utf8ToHtml('Descri&ccedil;&atilde;o:') ?></label>	
						<input name="dsmorada" type="text"  id="dsmorada" class='campo'/>
					</td>
				</tr>
				<tr>		
					<td>
						<label for="vlplaseg"><? echo utf8ToHtml('Valor do Premio:') ?></label>	
						<input name="vlplaseg" type="text"  id="vlplaseg" class='campo'/>
					</td>
				</tr>
				<tr>		
					<td>
						<label for="dsocupac"><? echo utf8ToHtml('Ocupa&ccedil;&atilde;o:') ?></label>	
						<input name="dsocupac" type="text"  id="dsocupac" class='campo'/>
					</td>
				</tr>
				<tr>		
					<td>
						<label for="nrtabela"><? echo utf8ToHtml('Tabela:') ?></label>	
						<input name="nrtabela" type="text"  id="nrtabela" class='campo' maxlength='2'/>
					</td>
				</tr>
				<tr>		
					<td>
						<label for="vlmorada"><? echo utf8ToHtml('Valor Cobertura:') ?></label>	
						<input name="vlmorada" type="text"  id="vlmorada" class='campo'/>
					</td>
				</tr>
				<tr>		
					<td>
						<label for="flgunica"><? echo utf8ToHtml('Tipo de Parcela:') ?></label>	
						<select class='campo' name='flgunica' id='flgunica' >
							<option value='yes'>&Uacute;nica</option>
							<option value='no'>Mensal</option>
						</select>
						
						<label for="inplaseg"><? echo utf8ToHtml('Consiste Valor:') ?></label>	
					<!--	<input type="checkbox" id='inplaseg' name='inplaseg' class='campo'>		-->
						<select class='campo' name='inplaseg' id='inplaseg' >
							<option value='1'>Sim</option>
							<option value='0'>Não</option>
						</select>
					</td>
				</tr>	
				<tr>		
					<td>
						<label for="cdsitpsg"><? echo utf8ToHtml('Situa&ccedil;&atilde;o Plano:') ?></label>	
						<select class='campo' name='cdsitpsg' id='cdsitpsg' >
							<option value='1'>A - Ativo</option>
							<option value='2'>I - Inativo</option>
						</select>
					</td>
				</tr>
				<tr>		
					<td>
						<label for="ddcancel"><? echo utf8ToHtml('Dia Limite Cancelamento:') ?></label>	
						<input name="ddcancel" type="text"  id="ddcancel" class='campo' maxlength='2'/>

						<label for="dddcorte"><? echo utf8ToHtml('Dia do Corte:') ?></label>	
						<input name="dddcorte" type="text"  id="dddcorte" class='campo' maxlength='2'/>
					</td>
				</tr>
				<tr>		
					<td>
						<label for="ddmaxpag"><? echo utf8ToHtml('Dia Max. Pagamento:') ?></label>	
						<input name="ddmaxpag" type="text"  id="ddmaxpag" class='campo'maxlength='2' />

						<label for="mmpripag"><? echo utf8ToHtml('Meses Car&ecirc;ncia:') ?></label>	
						<input name="mmpripag" type="text"  id="mmpripag" class='campo' maxlength='2'/>
					</td>
				</tr>	
				<tr>		
					<td>
						<label for="qtdiacar"><? echo utf8ToHtml('Qtd. Dias Car&ecirc;ncia:') ?></label>	
						<input name="qtdiacar" type="text"  id="qtdiacar" class='campo' maxlength='3'/>

						<label for="qtmaxpar"><? echo utf8ToHtml('Qtd. Max. Parcelas:') ?></label>	
						<input name="qtmaxpar" type="text"  id="qtmaxpar" class='campo' maxlength='2' />
					</td>
				</tr>			
			</table>
		</fieldset>
	</form>
	
	<form id="frmInfPlanoCasa" name="frmInfPlanoCasa" class="formulario" onSubmit="return false;" style="display:none">
		<fieldset>
			<legend>Plano</legend>
			<table width="100%">
				<tr>		
					<td>
						<label for="dsmorada"><? echo utf8ToHtml('Descri&ccedil;&atilde;o:') ?></label>	
						<input name="dsmorada" type="text"  id="dsmorada" class='campo'/>
					</td>
				</tr>
				<tr>		
					<td>
						<label for="vlplaseg"><? echo utf8ToHtml('Valor do Premio:') ?></label>	
						<input name="vlplaseg2" type="text"  id="vlplaseg2" class='campo'/>
					</td>
				</tr>
				<tr>		
					<td>
						<label for="dsocupac"><? echo utf8ToHtml('Ocupa&ccedil;&atilde;o:') ?></label>	
						<input name="dsocupac" type="text"  id="dsocupac" class='campo'/>
					</td>
				</tr>
				<tr>		
					<td>
						<label for="nrtabela"><? echo utf8ToHtml('Tabela:') ?></label>	
						<input name="nrtabela" type="text"  id="nrtabela" class='campo' maxlength='2'/>
					</td>
				</tr>
				<tr>		
					<td>
						<label for="flgunica"><? echo utf8ToHtml('Tipo de Parcela:') ?></label>	
						<select class='campo' name='flgunica' id='flgunica' >
							<option value='yes'>&Uacute;nica</option>
							<option value='no'>Mensal</option>
						</select>
						
						<label for="inplaseg"><? echo utf8ToHtml('Qtd.Parcelas Fixas:') ?></label>
						<!-- <input type="checkbox" id='inplaseg' name='inplaseg' class='campo'>		-->
						<select class='campo' name='inplaseg' id='inplaseg' >
							<option value='1'>Sim</option>
							<option value='0'>Não</option>
						</select>
					</td>
				</tr>	
				<tr>		
					<td>
						<label for="cdsitpsg"><? echo utf8ToHtml('Situa&ccedil;&atilde;o Plano:') ?></label>	
						<select class='campo' name='cdsitpsg' id='cdsitpsg' >
							<option value='1'>A - Ativo</option>
							<option value='2'>I - Inativo</option>
						</select>
					</td>
				</tr>
				<tr>		
					<td>
						<label for="ddcancel"><? echo utf8ToHtml('Dia Limite Cancelamento:') ?></label>	
						<input name="ddcancel" type="text"  id="ddcancel" class='campo' maxlength='2'/>

						<label for="dddcorte"><? echo utf8ToHtml('Dia do Corte:') ?></label>	
						<input name="dddcorte" type="text"  id="dddcorte" class='campo' maxlength='2'/>
					</td>
				</tr>
				<tr>		
					<td>
						<label for="ddmaxpag"><? echo utf8ToHtml('Dia Max. Pagamento:') ?></label>	
						<input name="ddmaxpag" type="text"  id="ddmaxpag" class='campo'maxlength='2' />

						<label for="mmpripag"><? echo utf8ToHtml('Meses Car&ecirc;ncia:') ?></label>	
						<input name="mmpripag" type="text"  id="mmpripag" class='campo' maxlength='2'/>
					</td>
				</tr>	
				<tr>		
					<td>
						<label for="qtdiacar"><? echo utf8ToHtml('Qtd. Dias Car&ecirc;ncia:') ?></label>	
						<input name="qtdiacar" type="text"  id="qtdiacar" class='campo' maxlength='3'/>

						<label for="qtmaxpar"><? echo utf8ToHtml('Qtd. Max. Parcelas:') ?></label>	
						<input name="qtmaxpar" type="text"  id="qtmaxpar" class='campo' maxlength='2' />
					</td>
				</tr>			
			</table>
		</fieldset>
	</form>	
	<form id="frmTabPlanos" name="frmTabPlanos" class="formulario" onSubmit="return false;" style="display:none">
		<fieldset>
			<legend>Tabela de Planos</legend>
			<div id="divTabPlanosSeguro"></div>
		</fieldset>
	</form>
	
	<form id="frmTabGarantia" name="frmTabGarantia" class="formulario" onSubmit="return false;" style="display:none">
		<fieldset>
			<legend>Franquia</legend>
			<div id="divTabGarantias"></div>
		</fieldset>
	</form>
			
</div>