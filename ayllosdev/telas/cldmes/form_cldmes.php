<?
/*!
 * FONTE        : form_cldmes.php
 * CRIAÇÃO      : Cristian Filipe         
 * DATA CRIAÇÃO : 20/11/2013								Última alteração: 17/12/2014
 * OBJETIVO     : Formulario para a tela CLDMES				
 * --------------
 * ALTERAÇÕES   : 24/11/2014 - Ajustes para liberação (Adriano)
 *                17/12/2014 - Alterado maxLength do campo do PA. (Douglas - Chamado 229676)
 * --------------
 */
	
	session_start();
	
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	function ultimoDiaMes($newData){
      /*Desmembrando a Data*/   
	  list($newDia, $newMes, $newAno) = explode("/", $newData);     
	  return date("d/m/Y", mktime(0, 0, 0, $newMes, 0, $newAno));
	  
   }
   /*Exemplo de chamada da função*/
   $ultimo_dia = ultimoDiaMes($glbvars['dtmvtolt']);
   
?>
<div id="divAnaliseMovimentacao" name="divAnaliseMovimentacao">
	<form id="frmInfConsulta" name="frmInfConsulta" class="formulario" onSubmit="return false;" style="display:none"> 
		<fieldset>
			<legend>Consulta</legend>
			<table width="100%">
				<tr>		
					<td>
						<label for="operacao"><?echo utf8ToHtml('Opera&ccedil;&atilde;o: Credito') ?></label>
						
						<label for="tdtmvtol"><? echo utf8ToHtml('Data:') ?></label>	
						<input name="tdtmvtol" type="text"  id="tdtmvtol" class='campo' value="<? echo $ultimo_dia; ?>" />	
						
						<label for="cdagepac"><? echo utf8ToHtml('PA:') ?></label>		
						<input name="cdagepac" type="text"  id="cdagepac" maxLength='3' class='campo'/>
						<a id="mtpa"  name="mtpa" href="#" onClick="controlaPesquisa();return false;" style="padding: 3px 0 0 3px;" tabindex="-1">
							<img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif">
						</a>						
						
					</td>
				</tr>
			</table>
		</fieldset>
	</form>
	<form id="frmInfFechamento" name="frmInfFechamento" class="formulario" onSubmit="return false;" style="display:none"> 
	
		<fieldset>
			<legend>Fechamento</legend>
			<table width="100%">
				<tr>		
					<td>
						<label for="operacao"><? echo utf8ToHtml('Opera&ccedil;&atilde;o: Credito'); ?></label>	

						<label for="tdtmvtol"><? echo utf8ToHtml('Data:') ;?></label>	
						<input name="tdtmvtol" type="text"  id="tdtmvtol" class='data campo' value="<? echo $ultimo_dia; ?>"/>					
						
					</td>
				</tr>
			</table>
		</fieldset>
	</form>
	<form id="frmInfMovimentacao" name="frmInfMovimentacao" class="formulario" onSubmit="return false;" style="display:none"> 
	
		<fieldset>
			<legend>Movimentações</legend>
			<div id ="divMovimentacao"></div>
		</fieldset>
	</form>	
</div>