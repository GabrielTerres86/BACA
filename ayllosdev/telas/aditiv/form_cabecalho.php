<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 26/09/2011
 * OBJETIVO     : Cabeçalho para a tela ADITIV
 * --------------
 * ALTERAÇÕES   : 22/11/2012 - Alterado botões do tipo tag <input> por tag <a>,
 *					           alterado layout da tela, incluso consultas atraves
 *							   de onClick tag <a> lupa.(Daniel).
 * 				  05/01/2015 - Padronizando a mascara do campo nrctremp.
 *					           10 Digitos - Campos usados apenas para visualização
 *				 	 		   8 Digitos - Campos usados para alterar ou incluir novos contratos
 *					 		   (Kelvin - SD 233714)
 *                11/04/2017 - Permitir acessar o Ayllos mesmo vindo do CRM. (Jaison/Andrino)
 * --------------
 */

?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;" style="display:none">
	<input type="hidden" name="crm_inacesso" id="crm_inacesso" value="<?php echo $_SESSION["glbvars"][$glbvars["sidlogin"]]['CRM_INACESSO']; ?>" />
	<input type="hidden" name="crm_nrdconta" id="crm_nrdconta" value="<?php echo $_SESSION["glbvars"][$glbvars["sidlogin"]]['CRM_NRDCONTA']; ?>" />
	
	<input name="idseqbem" id="idseqbem" type="hidden" value="" />
	
	<table width="100%">
		<tr>
			<td>
				<label for="cddopcao"><? echo utf8ToHtml('Opção:') ?></label>	
				<select id="cddopcao" name="cddopcao">
				<option value="C" <? echo $cddopcao == 'C' ? 'selected' : '' ?> >C - Consultar os dados do aditivo do contrato de emprestimo.</option>
				<option value="E" <? echo $cddopcao == 'E' ? 'selected' : '' ?> >E - Excluir os dados do aditivo do contrato de emprestimo.</option>
				<option value="I" <? echo $cddopcao == 'I' ? 'selected' : '' ?> >I - Incluir um aditivo contratual de emprestimo.</option>
				<option value="V" <? echo $cddopcao == 'V' ? 'selected' : '' ?> >V - Visualizar todos os aditivos contratuais do Cooperado.</option>
				<option value="X" <? echo $cddopcao == 'X' ? 'selected' : '' ?> >X - Excluir bem(ns) alienado(s) do aditivo contratual de emprestimo.</option>
				</select>
				<a href="#" class="botao" id="btnOK1">OK</a>
			</td>
		</tr>
		<tr>
			<td>
				<label for="nrdconta">Conta:</label>
				<input type="text" id="nrdconta" name="nrdconta" value="<? echo formataContaDV($nrdconta) ?>" />
				<a style="margin-top:5px;" href="#" onClick="GerenciaPesquisa(1); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>

				<label for="nrctremp"><? echo utf8ToHtml('Contrato:') ?></label>
				<input name="nrctremp" id="nrctremp" type="text" value="<? echo mascara($nrctremp,'##.###.###') ?>" autocomplete="off" />
				<a style="margin-top:5px;" href="#" onClick="GerenciaPesquisa(2); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
				
				<label for="nraditiv"><? echo utf8ToHtml('Aditivo:') ?></label>
				<input name="nraditiv" id="nraditiv" type="text" value="<? echo $nraditiv ?>"  />
				<a style="margin-top:5px;" href="#" onClick="GerenciaPesquisa(3); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>

				<label for="dtmvtolx"><? echo utf8ToHtml('A partir:') ?></label>
				<input name="dtmvtolx" id="dtmvtolx" type="text" value="<? echo $dtmvtolx ?>" />

				<label for="cdaditix"><? echo utf8ToHtml('Tipo:') ?></label>
				<select name="cdaditix" id="cdaditix" onChange="selecionaTipo(); return false;">
				<option value="1">1</option>
				<option value="2">2</option>
				<option value="3">3</option>
				<option value="4">4</option>
				<option value="5">5</option>
				<option value="6">6</option>
				<option value="7">7</option>
				<option value="8">8</option>
				</select>
				
				<a href="#" class="botao" id="btnOK2">OK</a>
			</td>
		</tr>
	</table>
	
	<label for="cdaditiv"></label>
	<select id="cdaditiv" name="cdaditiv" multiple size="8">
	<option value="1"  <? echo $cdaditiv == '1' ? 'selected' : '' ?> >1 - Alteracao Data do Debito</option>
	<option value="2"  <? echo $cdaditiv == '2' ? 'selected' : '' ?> >2 - Aplicacao Vinculada</option>
	<option value="3"  <? echo $cdaditiv == '3' ? 'selected' : '' ?> >3 - Aplicacao Vinculada Terceiro</option>
	<option value="4"  <? echo $cdaditiv == '4' ? 'selected' : '' ?> >4 - Inclusao de Fiador/Avalista</option>
	<option value="5"  <? echo $cdaditiv == '5' ? 'selected' : '' ?> >5 - Substituicao de Veiculo</option>
	<option value="6"  <? echo $cdaditiv == '6' ? 'selected' : '' ?> >6 - Interveniente Garantidor Veiculo</option>
	<option value="7"  <? echo $cdaditiv == '7' ? 'selected' : '' ?> >7 - Sub-rogacao - C/ Nota Promissoria</option>
	<option value="8"  <? echo $cdaditiv == '8' ? 'selected' : '' ?> >8 - Sub-rogacao - S/ Nota Promissoria</option>
	</select>	
	
	<br style="clear:both" />	
	
</form>