<?php
/*!
 * FONTE        : form_cldsed.php
 * CRIAÇÃO      : Cristian Filipe         
 * DATA CRIAÇÃO : 21/11/2013
 * OBJETIVO     : Formulario para a tela CLDSED
 * --------------
 * ALTERAÇÕES   : 05/08/2014 - Alteração da Nomeclatura para PA (Vanessa).
 *
 *                23/12/2014 - Ajustes nos campos das opções C, J e F (Douglas - Chamado 143945)
 *
 *				  06/06/2016 - Limitando a quantidade de caracteres nos campos e desabilitando a lov 
 *							   caso não tenha dado dois clicks, conforme solicitado no chamado 461240
 *							   (Kelvin)
 *
	*			      01/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
 * --------------
 */
	
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
?>
<div id="divCldsed" name="divCldsed">

	<!-- Form opção C e J -->	
	<form id="frmInfConsultaMovimentacao" name="frmInfConsultaMovimentacao" class="formulario" onSubmit="return false;" style="display:none"> <!-- ALTERAR PARA NONE -->
		<fieldset>
			<legend>Consulta Movimentação</legend>
			<table width="100%">
				<tr>		
					<td>
						<label for="operacao"><?echo utf8ToHtml('Opera&ccedil;&atilde;o: Credito') ?></label>
						
						<label for="flextjus"><? echo utf8ToHtml('Com Justificativa:') ?></label>	
						<input type="checkbox" id='flextjus' name='flextjus'>						
						
						<label for="dtmvtolt"><? echo utf8ToHtml('Data:') ?></label>	
						<input name="dtmvtolt" type="text"  id="dtmvtolt" class='campo'/>		
					</td>
				</tr>
			</table>
		</fieldset>
		
		<fieldset id="fieldMovimentacao" style="display:none">
			<legend>Movimentações</legend>
			<table width="100%">
			
			<div id ="divTabMovimentacao"></div>
				<tr>		
					<td>
						<label for="nmprimtl"><? echo utf8ToHtml('Nome:') ?></label>	
						<input name="nmprimtl" type="text"  id="nmprimtl" class='campo'/>
					</td>
				</tr>
				<tr>		
					<td>
						<label for="inpessoa"><? echo utf8ToHtml('Tp. Pessoa:') ?></label>	
						<input name="inpessoa" type="text"  id="inpessoa" class='campo'/>
						
						<label for="cdoperad"><? echo utf8ToHtml('Ope. PA:') ?></label>	
						<input name="cdoperad" type="text"  id="cdoperad" class='campo'/>
						
						<label for="opeenvcf"><? echo utf8ToHtml('Ope. Sede:') ?></label>	
						<input name="opeenvcf" type="text"  id="opeenvcf" class='campo'/>
					</td>
				</tr>
				<tr>		
					<td>
						<label for="cddjusti"><? echo utf8ToHtml('Justificativa:') ?></label>	
						<input name="cddjusti" type="text"  id="cddjusti" class='campo' maxlength="5"/>	
					
						<a id="tbJustificativa" onclick="controlaPesquisa(1);return false;" href="#" style="padding: 3px 0 0 3px;" tabindex="-1">
							<img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif">
						</a>	
						<input name="dsdjusti" type="text"  id="dsdjusti" class='campo' maxlength="1000"/>	
					</td>
				</tr>
				<tr>		
					<td>
						<label for="dsobserv"><? echo utf8ToHtml('Comp.Jusi:') ?></label>	
						<input name="dsobserv" type="text"  id="dsobserv" class='campo' maxlength="1000"/>	
					</td>
				</tr>
				<tr>		
					<td>
						<label for="infrepcf"><? echo utf8ToHtml('COAF:') ?></label>				
						<select class='campo' name='infrepcf' id='infrepcf' >
							<option value='Nao Informar'>Nao Informar</option>
							<option value='Informar'>Informar</option>
						</select>
					</td>
				</tr>
				<tr>		
					<td>
						<label for="dsobsctr"><? echo utf8ToHtml('Parecer Sede:') ?></label>				
						<input name="dsobsctr" type="text"  id="dsobsctr" class='campo' maxlength="1000"/>
					</td>
				</tr>
			</table>	
		</fieldset>		
	</form>
	
	<!-- Form opção F e X -->
	<form id="frmInfFechamento" name="frmInfFechamento" class="formulario" onSubmit="return false;" style="display:none"> <!-- ALTERAR PARA NONE -->
		<fieldset>
			<legend>Fechamento</legend>
			<table width="100%">
				<tr>		
					<td>
						<label for="operacao"><?echo utf8ToHtml('Opera&ccedil;&atilde;o: Credito') ?></label>
						
						<label for="dtmvtolt"><? echo utf8ToHtml('Data:') ?></label>	
						<input name="dtmvtolt" type="text"  id="dtmvtolt" class='data campo'/>	
					</td>
				</tr>
			</table>
		</fieldset>
	</form>
	 <!-- Form opção P-->
	<form id="frmInfConsultaDetalheMov" name="frmInfConsultaDetalheMov" class="formulario" onSubmit="return false;" style="display:none">
	
		<fieldset>
			<legend>Consulta detalhada</legend>
			<table width="100%">
				<tr>		
					<td>
						<label for="nrdconta"><? echo utf8ToHtml('Conta/dv:') ?></label>	
						<input name="nrdconta" type="text"   id="nrdconta"  class='campo'/>	
						
						<label for="dtrefini"><? echo utf8ToHtml('Inicial:') ?></label>	
						<input name="dtrefini" type="text"  id="dtrefini" class='data campo'/>
								
						<label for="dtreffim"><? echo utf8ToHtml('Final:') ?></label>	
						<input name="dtreffim" type="text"  id="dtreffim" class='data campo' value="<?php echo $glbvars["dtmvtolt"];?>"/>	
						<input type="hidden" id="dtPadrao" value="<?php echo $glbvars["dtmvtolt"];?>"/>
					</td>
				</tr>
				<tr>		
					<td>
						<label for="cdstatus"><? echo utf8ToHtml('Status:') ?></label>	
						<select class='campo' name='cdstatus' id='cdstatus' >
							<option value='1'>1 - Todos</option>
							<option value='2'>2 - Em Analise</option>
							<option value='3'>3 - Fechado</option>
						</select>
						
						<label for="cdincoaf"><? echo utf8ToHtml('COAF:') ?></label>	
						<select class='campo' name='cdincoaf' id='cdincoaf' >
							<option value='1'>1 - Todos</option>
							<option value='2'>2 - Ja Informado</option>
						</select>	
						
						<label for="saida"><? echo utf8ToHtml('Saida:') ?></label>	
						<select class='campo' name='saida' id='saida' >
							<option value='T'>T - Tela</option>
							<option value='A'>A - Arquivo</option>
							<option value='I'>I - Impressora</option>
						</select>
					</td>
				</tr>
			</table>
		</fieldset>
		<fieldset id="fieldMovimentacao2" style="display:none">
			<table width="100%">
			<legend>Movimentações</legend>
			<div id ="divTabMovimentacao2">--</div>
			<table width="100%">
				<tr>		
					<td>
						<label for="dsdjusti"><? echo utf8ToHtml('Justificativa:') ;?></label>	
						<input name="dsdjusti" type="text"  id="dsdjusti" class='campo'/>		
					</td>
				</tr>
				<tr>		
					<td>
						<label for="infrepcf"><? echo utf8ToHtml('COAF:'); ?></label>				
						<input name="infrepcf" type="text"  id="infrepcf" class='campo'/>		
					</td>
				</tr>
				<tr>		
					<td>
						<label for="dsstatus"><? echo utf8ToHtml('Status:'); ?></label>				
						<input name="dsstatus" type="text"  id="dsstatus" class='campo'/>	
					</td>
				</tr>
			</table>			
		</fieldset>
	</form>	
	 <!-- Form opção T-->
	<form id="frmInfListaMovimentacoes" name="frmInfListaMovimentacoes" class="formulario" onSubmit="return false;" style="display:none">
	
		<fieldset>
			<legend>Consulta lista de Movimentações</legend>
			<table width="100%">
				<tr>		
					<td>						
						<label for="dtrefini"><? echo utf8ToHtml('Inicial:') ?></label>	
						<input name="dtrefini" type="text"  id="dtrefini" class='data campo'/>
								
						<label for="dtreffim"><? echo utf8ToHtml('Final:') ?></label>	
						<input name="dtreffim" type="text"  id="dtreffim" class='data campo' value="<?php echo $glbvars["dtmvtolt"];?>"/>						
						
						<label for="saida"><? echo utf8ToHtml('Saida:') ?></label>	
						<select class='campo' name='saida' id='saida' >
							<option value='T'>T - Tela</option>
							<option value='A'>A - Arquivo</option>
							<option value='I'>I - Impressora</option>
						</select>
					</td>
				</tr>
			</table>
		</fieldset>
		<fieldset id="fieldMovimentacao3" style="display:none">
			<table width="100%">
			<legend>Movimentações</legend>
			<div id ="divTabMovimentacao3"></div>
			<table width="100%">
				<tr>		
					<td>
						<label for="tpvincul"><? echo utf8ToHtml('Vinculo:') ?></label>	
						<input name="tpvincul" type="text"  id="tpvincul" class='campo'/>	
						
						<label for="infrepcf"><? echo utf8ToHtml('COAF:') ?></label>				
						<input name="infrepcf" type="text"  id="infrepcf" class='campo'/>	

						<label for="dsstatus"><? echo utf8ToHtml('Status:') ?></label>	
						<input name="dsstatus" type="text"  id="dsstatus" class='campo'/>	
					</td>
				</tr>
				<tr>		
					<td>
						<label for="cddjusti"><? echo utf8ToHtml('Justificativa:') ?></label>	
						<input name="cddjusti" type="text"  id="cddjusti" class='campo'/>	
					</td>
				</tr>
				<tr>		
					<td>
						<label for="dsobserv"><? echo utf8ToHtml('Comp.Justi:') ?></label>	
						<input name="dsobserv" type="text"  id="dsobserv" class='campo'/>	
					</td>
				</tr>
				<tr>		
					<td>
						<label for="dsobsctr"><? echo utf8ToHtml('Parecer Sede:') ?></label>				
						<input name="dsobsctr" type="text"  id="dsobsctr" class='campo'/>		
					</td>
				</tr>
			</table>			
		</fieldset>
	</form>					
</div>