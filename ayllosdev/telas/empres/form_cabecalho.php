<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Michel Candido         
 * DATA CRIAÇÃO : 02/05/2013
 * OBJETIVO     : Cabecalho para a tela EMPRES
 * --------------
 * ALTERAÇÕES   : 07/03/2014 - Retirado comentarios indevidos do programa.
 * --------------            - Ajustado fonte para deixar no padrao (Lucas R.)
 *
 */
	
	session_start();
	
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
?>
<form id="frmCab" name="frmCab" class="formulario cabecalho" style="display:none">
	<table width="100%">
		<tr>		
			<td> 
				<label for="nrdconta"><? echo utf8ToHtml('Conta/dv:') ?></label>	
				<input type="text" class='campo' id="nrdconta" name="nrdconta" alt="Informe o nro. da conta do cooperado." />
				<a href="#" id="pesquisaAssoc" name="pesquisaAssoc" onClick="controlaPesquisa('1');return false;"><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" ></a>
	
			
				<label for="nmprimtl"><? echo utf8ToHtml('Titular:') ?></label>	
				<input class='campo' name="nmprimtl" type="text"  id="nmprimtl"/>
				
				<label for="cdtipsfx"><? echo utf8ToHtml('T.F.:') ?></label>	
				<input class='campo' name="cdtipsfx" type="text"  id="cdtipsfx"  />
			</td>
		</tr>
		<tr>
			<td >
				<label for="nrctremp"><? echo utf8ToHtml('Contrato:') ?></label>	
				<input class='campo' name="nrctremp" type="text"  id="nrctremp"  />
				<a href="#" id="pesquisaContrato" name="pesquisaContrato" onClick="controlaPesquisa('2');return false;"><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" ></a>
	
	
				<label for="dtAte"><? echo utf8ToHtml('Calcular at&eacute;:') ?></label>	
				<input name="dtAte" class='campo data' type="text"  id="dtAte" />
			</td>
		</tr>
	</table>
</form>