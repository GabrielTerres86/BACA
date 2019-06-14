<?
/*!
 * FONTE        : form_administradoras.php
 * CRIAÇÃO      : Cristian Filipe         
 * DATA CRIAÇÃO : Setembro/2013
 * OBJETIVO     : Formulario para tela ADMCRD
 * --------------
 * ALTERAÇÕES   : 06/11/2013 - Alteração no campo Habilita PJ, transformado em CheckBox.
 *				  26/02/2014 - Revisão e Correção (Lucas).
 *				  24/03/2014 - Implementados novos campos Projeto cartão Bancoob (Jean Michel).
 *				  24/10/2014 - Alteração do campo nmresadm para maxlength de 30 (Vanessa).
 * --------------
 */
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();	

?>

<div id="divAdministradoras" name="divAdministradoras">
	<form id="frmAdministradoras" name="frmAdministradoras" class="formulario" onSubmit="return false;" style="display:block">
		<fieldset>
			<legend>Administradora</legend>
			<table width="100%">
				<tr>		
					<td>
						<label for="cdadmcrd"><? echo utf8ToHtml('C&oacute;digo:') ?></label>	
						<input name="cdadmcrd" type="text"  id="cdadmcrd" class='campo' maxlength = '2' />
						<a href="#" onclick="controlaPesquisa();" style="padding: 3px 0 0 3px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
						<label for="nmadmcrd"><? echo utf8ToHtml('Nome:') ?></label>	
						<input name="nmadmcrd" type="text"  id="nmadmcrd" class='campo'  maxlength = '50'  />
					</td>
				</tr>
				<tr>		 
					<td>
						<label for="nmresadm"><? echo utf8ToHtml('Nome&nbsp;Resumido:') ?></label>	
						<input name="nmresadm" type="text"  id="nmresadm" class='campo'  maxlength = '30' />
						
						<label for="insitadc"><? echo utf8ToHtml('Situa&ccedil;&atilde;o:') ?></label>	
						<select class='campo' id='insitadc' name='insitadc'>
							<option value='YES' selected>Ativada</option>
							<option value='NO'>Desativada</option>
						</select>
					</td>
				</tr>
				<tr>		
					<td>
						<label for="nmbandei"><? echo utf8ToHtml('Bandeira&nbsp;Cart&atilde;o:') ?></label>	
						<input name="nmbandei" type="text"  id="nmbandei" class='campo'  maxlength = '20'  />
						
						<label for="qtcarnom"><? echo utf8ToHtml('Qtd. Caracteres Nome:') ?></label>	
						<input name="qtcarnom" type="text"  id="qtcarnom" class='campo' maxlength = '2'  />	
					</td>
				</tr>
				<tr>
					<td>
						<label for="tpctahab"><? echo utf8ToHtml('Contas Habilitadas:') ?></label>
						<select class='campo rotulo' id='tpctahab' name='tpctahab'>
							<option value='0'>0 - Todas</option>
							<option value='1' selected>1 - Somente PF</option>
							<option value='2'>2 - Somente PJ</option>
						</select>
					
						<label for="inanuida"><? echo utf8ToHtml('Anuidade:') ?></label>
						<select class='campo' id='inanuida' name='inanuida'>
							<option value='0' selected>0 - N&atilde;o Cobrar</option>
							<option value='1'>1 - Apenas Pessoa Fisica</option>
							<option value='2'>2 - Apenas Pessoa Juridica</option>
							<option value='3'>3 - Cobrar para Todos</option>
						</select>
					</td>
				</tr>
				<tr>		
					<td>
						<label for="nrctamae"><? echo utf8ToHtml('BIN:') ?></label>	
						<input name="nrctamae" type="text"  id="nrctamae" class='campo' maxlength = '6'  />
												
						<label for="cdclasse"><? echo utf8ToHtml('Classe:') ?></label>	
						<input name="cdclasse" type="text"  id="cdclasse" class='campo' maxlength = '2'  />	
						
						<label for="flgcchip"><? echo utf8ToHtml('CHIP:') ?></label>	
						<input name="flgcchip" type="checkbox"  id="flgcchip" class='campo' style="border:none;"/>
					</td>
				</tr>
				<tr>
					<td>
						<label for="nrctacor"><? echo utf8ToHtml('Conta&nbsp;Corrente:') ?></label>	
						<input name="nrctacor" type="text"  id="nrctacor" class='campo' maxlength = '10' />	
						
						<label for="nrdigcta"><? echo utf8ToHtml('Dig:') ?></label>	
						<input name="nrdigcta" type="text"  id="nrdigcta" class='campo' maxlength = '2' />	
						
						<label for="nrrazcta"><? echo utf8ToHtml('Raz&atilde;o C/C:') ?></label>	
						<input name="nrrazcta" type="text"  id="nrrazcta" class='campo'  maxlength = '9'  />	
					</td>
				</tr>	
				<tr>
					<td>
						<label for="nmagecta"><? echo utf8ToHtml('Agencia:') ?></label>	
						<input name="nmagecta" type="text"  id="nmagecta" class='campo'   maxlength = '25'  />	
						
						<label for="cdagecta"><? echo utf8ToHtml('Cta.Agencia:') ?></label>	
						<input name="cdagecta" type="text"  id="cdagecta" class='campo' maxlength = '6' />	
						
						<label for="cddigage"><? echo utf8ToHtml('Dig:') ?></label>	
						<input name="cddigage" type="text"  id="cddigage" class='campo' maxlength = '3' />	
					</td>
				</tr>
				<tr>
					<td>
						<label for="dsendere"><? echo utf8ToHtml('Endere&ccedil;o:') ?></label>	
						<input name="dsendere" type="text"  id="dsendere" class='campo'  maxlength = '54' />	
					</td>
				</tr>
				<tr>
					<td>
						<label for="nmbairro"><? echo utf8ToHtml('Bairro:') ?></label>	
						<input name="nmbairro" type="text"  id="nmbairro" class='campo'  maxlength = '15'  />	
						
						<label for="nmcidade"><? echo utf8ToHtml('Cidade:') ?></label>	
						<input name="nmcidade" type="text"  id="nmcidade" class='campo'  maxlength = '15' />	
						
						<label for="cdufende"><? echo utf8ToHtml('UF:') ?></label>	
						<input name="cdufende" type="text"  id="cdufende" class='campo'  maxlength = '2'  />	
					</td>
				</tr>
				<tr>
					<td>
						<label for="nrcepend"><? echo utf8ToHtml('CEP:') ?></label>	
						<input name="nrcepend" type="text"  id="nrcepend" class='cep campo' />	
				<tr>
					<td>
						<label for="nmpescto"><? echo utf8ToHtml('Pessoa&nbsp;Contato:') ?></label>	
						<input name="nmpescto" type="text"  id="nmpescto" class='campo'  maxlength = '40'/>	
					</td>
				</tr>
					
				<tr>
					<td>
						<label for="dsdemail1"><? echo utf8ToHtml('E-mail Contato:') ?></label>
						<input name="dsdemail1" type="text"  id="dsdemail1" maxlength = '30' class='campo'  />
					</td>
				</tr>
				<tr>
					<td>
						<label for="dsdemail2">&nbsp;</label>
						<input name="dsdemail2" type="text"  id="dsdemail2"  maxlength = '30' class='campo' />	
					</td>
				</tr>
				<tr>
					<td>
						<label for="dsdemail3">&nbsp;  </label>
						<input name="dsdemail3" type="text"  id="dsdemail3"  maxlength = '30' class='campo'/>	
					</td>
				</tr>
				<tr>
					<td>
						<label for="dsdemail4">&nbsp; </label>
						<input name="dsdemail4" type="text"  id="dsdemail4" maxlength = '30' class='campo'  />	
					</td>
				</tr>
				<tr>
					<td>
						<label for="dsdemail5">&nbsp; </label>
						<input name="dsdemail5" type="text"  id="dsdemail5"  maxlength = '30' class='campo' />	
					</td>
				</tr>				
			</table>
		</fieldset>
	</form>
</div>