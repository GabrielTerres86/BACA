<?php
/*!
 * FONTE        : form_opecel.php
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 23/01/2017
 * OBJETIVO     : Formulario de consulta da Tela OPECEL
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */ 

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	

?>

<form id="frmOpecel" name="frmOpecel" class="formulario" style="display: none">
	
	<div id="divConsulta" >		
		<fieldset style="margin-top: 10px">
			<legend> Dados da Operadora </legend>
			<div>				
				<label for="flgsituacao">Situa&ccedil;&atilde;o:</label>		
				<select id="flgsituacao" name="flgsituacao">
					<option value="0" selected >INATIVA</option>
					<option value="1" >ATIVA</option>	
				</select>
				</br>
				<label for="cdhisdebcop">Hist&oacute;rico d&eacute;bito cooperado:</label>		
				<input id="cdhisdebcop" name="cdhisdebcop" type="text"/>
				<a style="padding: 3px 0 0 3px;" id="btLupaCop" >
					<img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/>
				</a>	
				<input id="dshisdebcop" name="dshisdebcop" type="text"/>
				
				</br>
				
				<label for="cdhisdebcnt">Hist&oacute;rico d&eacute;bito centraliza&ccedil;&atilde;o:</label>		
				<input id="cdhisdebcnt" name="cdhisdebcnt" type="text"/>
				<a style="padding: 3px 0 0 3px;" id="btLupaCnt" >
					<img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/>
				</a>	
				<input id="dshisdebcnt" name="dshisdebcnt" type="text"/>
				</br>
				
				<label for="perreceita">Percentual de receita:</label>		
				<input id="perreceita" name="perreceita" type="text"/>
				<label class="rotulo-linha">%</label>
			</div>
		</fieldset>		
		
	</div>
	
</form>
