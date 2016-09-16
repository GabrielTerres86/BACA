<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : David Kruger   
 * DATA CRIAÇÃO : 04/02/2013
 * OBJETIVO     : Cabeçalho para a tela AGENCI
 * --------------
 * ALTERAÇÕES   : 08/01/2014 - Ajustes para homologação (Adriano)
 *				  20/06/2016 - Retirada das opções A, E e I da tela agenci - 431915 (Rafael Maciel)
 * --------------
 */
	
	session_start();
	
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;" style="display:none">
	<table width = "100%">
		<tr>		
			<td> 	
				<label for="cddopcao"><? echo utf8ToHtml('Op&ccedil;&atilde;o:') ?></label>
				<select id="cddopcao" name="cddopcao" style="width: 477px;">
					<option value="C" selected> C - Consultar ag&ecirc;ncias </option> 
<?php /*                        
                    <option value="A"> A - Alterar ag&ecirc;ncias </option>
					<option value="E"> E - Excluir ag&ecirc;ncias </option>
					<option value="I"> I - Incluir ag&ecirc;ncias </option>
*/ ?>
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" style = "text-align:right;">OK</a>
			</td>
		</tr>
        <tr>		
			<td>
				<label for="cddbanco">Banco:</label>
				<input type="text" id="cddbanco" name="cddbanco" alt="Informe o numero do banco." />	
				<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(1);return false;"><img id="CdBanc" name = "CdBanc" src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>				
				
				<input type="text" name="nmextbcc" id="nmextbcc" />
				
			</td>
		</tr>		
	</table>
</form>