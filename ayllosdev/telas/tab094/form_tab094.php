<?
/**************************************************************************************
	ATENÇÃO: SE ESTA TELA ALGUM DIA FOR LIBERADA PARA A PRODUÇÃO TEM QUE SER ALTERADA
			 PARA O NOVO LAYOUT DO AYLLOS WEB.
			 FALAR COM O GABRIEL OU DANIEL. 19/02/2013.
****************************************************************************************/

/*!
 * FONTE        	: form_tab094.php
 * CRIAÇÃO      	: Tiago
 * DATA CRIAÇÃO 	: Julho/2012
 * OBJETIVO     	: Cabeçalho para a tela TAB094
 * ÚLTIMA ALTERAÇÃO : 04/07/2013
 * --------------
 * ALTERAÇÕES   	: 27/06/2013 - Adicionados dois novos campos: mrgitgcr e mrgitgdb (Reinert).
 *					  04/07/2013 - Alterado para receber o novo layout padrão do Ayllos Web (Reinert).
 * --------------
 */ 
?>
<style>
#tabela tr td label{
	float	:	right;
}
</style>

<form id="frmTab094" name="frmTab094" class="formulario" style="display:none">	

	<fieldset id="fsetFormulario" name="fsetFormulario" style="padding:0px; margin:0px; padding-bottom:10px;">
		<legend> <? echo utf8ToHtml('Par&acirc;metros'); ?> </legend>
		<table id="tabela" name="tabela" align=center>
			<tr>
				<td><label for="mrgsrdoc"><? echo utf8ToHtml('Margem SR Doc:') ?></label></td>
				<td><input name="mrgsrdoc" id="mrgsrdoc" type="text"</td>
				<td><label for="mrgsrdoc"><? echo utf8ToHtml('%') ?></label></td>
			</tr>	
			<tr>
				<td><label for="mrgsrchq"><? echo utf8ToHtml('Margem SR Cheques:') ?></label></td>
				<td><input name="mrgsrchq" id="mrgsrchq" type="text" /></td>
				<td><label for="mrgsrdoc"><? echo utf8ToHtml('%') ?></label></td>
			</tr>
			<tr>
				<td><label for="mrgnrtit"><? echo utf8ToHtml('Margem NR Titulos:') ?></label></td>
				<td><input name="mrgnrtit" id="mrgnrtit" type="text" /></td>
				<td><label for="mrgsrdoc"><? echo utf8ToHtml('%') ?></label></td>
			</tr>
			<tr>
				<td><label for="mrgsrtit"><? echo utf8ToHtml('Margem SR Titulos:') ?></label></td>
				<td><input name="mrgsrtit" id="mrgsrtit" type="text" /></td>
				<td><label for="mrgsrdoc"><? echo utf8ToHtml('%') ?></label></td>
			</tr>
			<tr>
				<td><label for="caldevch"><? echo utf8ToHtml('Base de Calculo Devolucao Cheques Receb:') ?></label></td>
				<td><input name="caldevch" id="caldevch" type="text" /></td>
				<td><label for="mrgsrdoc"><? echo utf8ToHtml('%') ?></label></td>
			</tr>
			<tr>
				<td><label for="mrgitgcr"><? echo utf8ToHtml('Margem Cta Itg BB Credito:') ?></label></td>
				<td><input name="mrgitgcr" id="mrgitgcr" type="text" /></td>
				<td><label for="mrgsrdoc"><? echo utf8ToHtml('%') ?></label></td>
			</tr>
			<tr>
				<td><label for="mrgitgdb"><? echo utf8ToHtml('Margem Cta Itg BB Debito:') ?></label></td>
				<td><input name="mrgitgdb" id="mrgitgdb" type="text" /></td>
				<td><label for="mrgsrdoc"><? echo utf8ToHtml('%') ?></label></td>
			</tr>
			<tr>
				<td><label for="horabloq"><? echo utf8ToHtml('Horario de Bloqueio:') ?></label></td>
				<td>
					<table>
						<tr>			
							<td><input name="horabloq" id="horabloq" type="text" /></td>			
							<td><label for="mrgsrdoc"><? echo utf8ToHtml(':') ?></label></td>
							<td><input name="horabloq2" id="horabloq2" type="text" /></td>
						</tr>
					</table>
				</td>
			</tr>
			
		</table>
		
	</fieldset>
	
	<br style="clear:both" />	
	
</form>