<?php
/*!
 * FONTE        : form_seguradoras.php
 * CRIAÇÃO      : Cristian Filipe Fernandes (GATI)
 * DATA CRIAÇÃO : 19/11/2013
 * OBJETIVO     : formulario para a tela CADSEG
 * --------------
 * ALTERAÇÕES   : 19/12/2013 - Alterado label do nrcgcseg de 'Numero do CGC:'
 *							   para 'Numero do CNPJ:'. (Reinert)
 *
 *				  23/01/2014 - Ajustes gerais para liberacao. (Jorge)
 * --------------
 */
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();	
?>
<div id="divSeguradora" name="divSeguradora">
	<form id="frmInfSeguradora" name="frmInfSeguradora" class="formulario" onSubmit="return false;" style="display:none">
	
		<fieldset>
			<legend>Seguradora</legend>
			<table width="100%">
				<tr>		
					<td>
						<label for="cdsegura"><? echo utf8ToHtml('C&oacute;digo:') ?></label>	
						<input name="cdsegura" type="text"  id="cdsegura" />
						<a style="margin-top:5px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
						<label for="nmsegura"><? echo utf8ToHtml('Nome:') ?></label>	
						<input name="nmsegura" type="text"  id="nmsegura" />
					</td>
				</tr>
			</table>
			<table width="100%">
				<tr>		
					<td>
						<label for="nmresseg"><? echo utf8ToHtml('Nome Resumido:') ?></label>	
						<input name="nmresseg" type="text"  id="nmresseg" />
						
						<label for="flgativo"><? echo utf8ToHtml('Seguradora Ativa:') ?></label>
						<input type="checkbox" id='flgativo' name='flgativo'/>	

					</td>
				</tr>
				<tr>		
					<td>
						<label for="nrcgcseg"><? echo utf8ToHtml('Numero do CNPJ:') ?></label>	
						<input name="nrcgcseg" type="text"  id="nrcgcseg" />
						
						<label for="nrctrato"><? echo utf8ToHtml('Numero de Contrato:') ?></label>	
						<input name="nrctrato" type="text"  id="nrctrato" />	
					</td>
				</tr>	
				<tr>
					<td>
						<label for="nrultpra"><? echo utf8ToHtml('Ultima proposta auto:') ?></label>	
						<input name="nrultpra" type="text"  id="nrultpra" />
						
						<label for="nrlimpra"><? echo utf8ToHtml('Limite proposta auto:') ?></label>	
						<input name="nrlimpra" type="text"  id="nrlimpra" />
					</td>
				</tr>
				<tr>
					<td>
						<label for="nrultprc"><? echo utf8ToHtml('Ultima proposta casa:') ?></label>	
						<input name="nrultprc" type="text"  id="nrultprc" />
						
						<label for="nrlimprc"><? echo utf8ToHtml('Limite proposta casa:') ?></label>	
						<input name="nrlimprc" type="text"  id="nrlimprc" />
					</td>
				</tr>
				<tr>
					<td>
						<label for="dsasauto"><? echo utf8ToHtml('Assistencia:') ?></label>	
						<input name="dsasauto" type="text"  id="dsasauto"/>
					</td>
				</tr>
			</table>
		</fieldset>
	</form>
	
	<form id="frmInfHistorico" name="frmInfHistorico" class="formulario" onSubmit="return false;" style="display:none"> 
	
		<fieldset>
			<legend>Historico</legend>
			<table width="100%">
				<tr>		
					<td>
						<label for="cdhstaut1"><? echo utf8ToHtml('Hist&oacute;ricos de seguro AUTO :') ?></label>	
						<input name="cdhstaut1" type="text"  id="cdhstaut1" />		
						
						<label for="cdhstaut2">&nbsp;</label>	
						<input name="cdhstaut2" type="text"  id="cdhstaut2" />
						
						<label for="cdhstaut3">&nbsp;</label>	
						<input name="cdhstaut3" type="text"  id="cdhstaut3" />
						
						<label for="cdhstaut4">&nbsp;</label>	
						<input name="cdhstaut4" type="text"  id="cdhstaut4" />
						<label for="cdhstaut5">&nbsp;</label>	
						<input name="cdhstaut5" type="text"  id="cdhstaut5" />
					</td>
				</tr>
				<tr>		
					<td>
						<label for="cdhstaut6">&nbsp;</label>	
						<input name="cdhstaut6" type="text"  id="cdhstaut6" />
						<label for="cdhstaut7">&nbsp;</label>	
						<input name="cdhstaut7" type="text"  id="cdhstaut7" />
						<label for="cdhstaut8">&nbsp;</label>		
						<input name="cdhstaut8" type="text"  id="cdhstaut8" />
						<label for="cdhstaut9">&nbsp;</label>	
						<input name="cdhstaut9" type="text"  id="cdhstaut9" />
						<label for="cdhstaut10">&nbsp;</label>	
						<input name="cdhstaut10" type="text"  id="cdhstaut10" />
					</td>
				</tr>
				<tr>		
					<td>
						<label for="cdhstcas1"><? echo utf8ToHtml('Hist&oacute;ricos de seguro CASA :') ?></label>	
						<input name="cdhstcas1" type="text"  id="cdhstcas1" />	
						<label for="cdhstcas2">&nbsp;</label>		
						<input name="cdhstcas2" type="text"  id="cdhstcas2" />
						<label for="cdhstcas3">&nbsp;</label>			
						<input name="cdhstcas3" type="text"  id="cdhstcas3" />
						<label for="cdhstcas4">&nbsp;</label>		
						<input name="cdhstcas4" type="text"  id="cdhstcas4" />
						<label for="cdhstcas5">&nbsp;</label>		
						<input name="cdhstcas5" type="text"  id="cdhstcas5" />
					</td>
				</tr>	
				<tr>
					<td>
						<label for="cdhstcas6">&nbsp;</label>		
						<input name="cdhstcas6" type="text"  id="cdhstcas6" />
						<label for="cdhstcas7">&nbsp;</label>			
						<input name="cdhstcas7" type="text"  id="cdhstcas7" />
						<label for="cdhstcas8">&nbsp;</label>		
						<input name="cdhstcas8" type="text"  id="cdhstcas8" />
						<label for="cdhstcas9">&nbsp;</label>		
						<input name="cdhstcas9" type="text"  id="cdhstcas9" />
						<label for="cdhstcas10">&nbsp;</label>		
						<input name="cdhstcas10" type="text"  id="cdhstcas10" />
					</td>
				</tr>
				<tr>
					<td>
						<label for="dsmsgseg"><? echo utf8ToHtml('Mensagem:') ?></label>	
						<input name="dsmsgseg" type="text"  id="dsmsgseg" />
					</td>
				</tr>
			</table>
		</fieldset>
	</form>	
</div>
