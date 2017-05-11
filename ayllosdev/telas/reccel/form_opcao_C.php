<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 06/03/2017
 * OBJETIVO     : Form da opção C
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

<form id="frmOpcaoC" class="formulario">
	<div style="padding:0px 0px 2px 0px;margin-bottom:4px;border-bottom:1px solid #777;">
		<table width="100%">
			<tr>		
				<td> 	
					<label for="nrdconta">Conta:</label>		
					<input id="nrdconta" name="nrdconta" type="text"/>
					<a href="#" style="padding: 3px 0 0 3px;" id="btLupaConta">
						<img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" width="14" height="14" border="0" />
					</a>
					<a href="#" class="botao" id="btnOKC" name="btnOKC" style = "text-align:right;">OK</a>	
					<label for="dtinirec">Data Inicial:</label>		
					<input id="dtinirec" name="dtinirec" type="text" tabindex="100"/>
					<label for="dtfimrec">Data Final:</label>		
					<input id="dtfimrec" name="dtfimrec" type="text" tabindex="101"/>					
					</br>
					<label for="nmprimtl">Titular:</label>		
					<input id="nmprimtl" name="nmprimtl" type="text"/>
				</td>		
			</tr> 	
		</table>			
	</div>
	<div id="divRecargas" style="display: none"></div>
</form>