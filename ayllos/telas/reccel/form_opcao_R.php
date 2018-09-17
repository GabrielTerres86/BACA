<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 06/03/2017
 * OBJETIVO     : Form da opção R
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

<form id="frmOpcaoR" class="formulario">
	<div style="padding:0px 0px 2px 0px;margin-bottom:4px;border-bottom:1px solid #777;">
		<table width="100%">
			<tr>		
				<td> 		
					<label for="nrdconta">Conta:</label>		
					<input id="nrdconta" name="nrdconta" type="text"/>
					<a href="#" style="padding: 3px 0 0 3px;" id="btLupaConta">
						<img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" width="14" height="14" border="0" />
					</a>
					<a href="#" class="botao" id="btnOKR" name="btnOKR" style = "text-align:right;">OK</a>	
					<label for="nmprimtl">Titular:</label>		
					<input id="nmprimtl" name="nmprimtl" type="text"/>
				</td>		
			</tr> 	
		</table>								
	</div>
	<div id="divEfetuaRecarga" style="display: none">
		<fieldset>
			<legend>Dados da Recarga</legend>
			<input type="hidden" id="cdseq_favorito" name="cdseq_favorito"/>
			<input type="hidden" id="dstelefo" name="dstelefo"/>
			<label for="nrdddtel">DDD/Telefone:</label>		
			<input id="nrdddtel" name="nrdddtel" type="text"/>

			<label for="nrtelefo">-</label>		
			<input id="nrtelefo" name="nrtelefo" type="text"/>

			<a href="#" style="padding: 3px 0 0 3px;" id="btLupaTelefo">
				<img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" width="14" height="14" border="0" />
			</a>
			<a href="#" onclick="mostraPesquisaTelefone(); return false;" style="margin-left: 1px">Buscar Favoritos</a>
			</br>

			<label for="nrdddtel2">Confirme DDD/Telefone:</label>		
			<input id="nrdddtel2" name="nrdddtel" type="text"/>

			<label for="nrtelefo2">-</label>		
			<input id="nrtelefo2" name="nrtelefo" type="text"/>

			</br>
			
			<label for="nmoperadora">Operadora:</label>		
			<select id="nmoperadora" name="nmoperadora">
				<option value="0;0" selected>Selecione a operadora</option> 
			</select>
			
			</br>
			
			<label for="vlrecarga">Valor:</label>		
			<select id="vlrecarga" name="vlrecarga">
				
			</select>

		</fieldset>
	</div>
</form>