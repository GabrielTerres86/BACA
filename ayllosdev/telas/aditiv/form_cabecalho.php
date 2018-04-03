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
 *                31/10/2017 - Alteracao das descricoes das opcoes e inclusao do campo tipo de contrato.
 *                             (Jaison/Marcos Martini - PRJ404)
 * --------------
 */

?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;" style="display:none">
	<input type="hidden" name="crm_inacesso" id="crm_inacesso" value="<?php echo $_SESSION["glbvars"][$glbvars["sidlogin"]]['CRM_INACESSO']; ?>" />
	<input type="hidden" name="crm_nrdconta" id="crm_nrdconta" value="<?php echo $_SESSION["glbvars"][$glbvars["sidlogin"]]['CRM_NRDCONTA']; ?>" />
	
	<input name="idseqbem" id="idseqbem" type="hidden" value="" />
    <input name="nrctrlim" id="nrctrlim" type="hidden" value="" />
    <input name="idcobert" id="idcobert" type="hidden" value="" />
    <input name="codlinha" id="codlinha" type="hidden" value="" />
    <input name="vlropera" id="vlropera" type="hidden" value="" />
	
	<table width="100%">
		<tr>
			<td>
				<label for="cddopcao"><? echo utf8ToHtml('Opção:') ?></label>	
				<select id="cddopcao" name="cddopcao">
				<option value="C" <? echo $cddopcao == 'C' ? 'selected' : '' ?> ><? echo utf8ToHtml('C - Consultar os dados do aditivo do contrato da operação.') ?></option>
				<option value="E" <? echo $cddopcao == 'E' ? 'selected' : '' ?> ><? echo utf8ToHtml('E - Excluir os dados do aditivo do contrato da operação.') ?></option>
				<option value="I" <? echo $cddopcao == 'I' ? 'selected' : '' ?> ><? echo utf8ToHtml('I - Incluir um aditivo contratual na operação.') ?></option>
				<option value="V" <? echo $cddopcao == 'V' ? 'selected' : '' ?> ><? echo utf8ToHtml('V - Visualizar todos os aditivos contratuais do Cooperado.') ?></option>
				<option value="X" <? echo $cddopcao == 'X' ? 'selected' : '' ?> ><? echo utf8ToHtml('X - Excluir bem(ns) alienado(s) do aditivo contratual de empréstimo.') ?></option>
				</select>
				<a href="#" class="botao" id="btnOK1">OK</a>
			</td>
		</tr>
		<tr>
			<td>
				<label for="nrdconta">Conta:</label>
				<input type="text" id="nrdconta" name="nrdconta" value="<? echo formataContaDV($nrdconta) ?>" />
				<a style="margin-top:5px;" href="#" onClick="GerenciaPesquisa(1); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>

				<label for="tpctrato"><? echo utf8ToHtml('Tipo Contrato:') ?></label>
				<select name="tpctrato" id="tpctrato" onChange="return false;">
				<option value="1"><? echo utf8ToHtml('1 - Limite de Crédito') ?></option>
				<option value="2"><? echo utf8ToHtml('2 - Limite de Desconto de Cheque') ?></option>
				<option value="3"><? echo utf8ToHtml('3 - Limite de Desconto de Título') ?></option>
				<option value="90"><? echo utf8ToHtml('90 - Empréstimos/Financiamentos') ?></option>
				</select>

				<label for="nrctremp"><? echo utf8ToHtml('Contrato:') ?></label>
				<input name="nrctremp" id="nrctremp" type="text" value="<? echo mascara($nrctremp,'##.###.###') ?>" autocomplete="off" />
				<a style="margin-top:5px;" href="#" onClick="GerenciaPesquisa(2); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
				
				<label for="nraditiv"><? echo utf8ToHtml('Aditivo:') ?></label>
				<input name="nraditiv" id="nraditiv" type="text" value="<? echo $nraditiv ?>"  />
				<a style="margin-top:5px;" href="#" onClick="GerenciaPesquisa(3); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>

				<label for="dtmvtolx"><? echo utf8ToHtml('A partir:') ?></label>
				<input name="dtmvtolx" id="dtmvtolx" type="text" value="<? echo $dtmvtolx ?>" />

				<label for="cdaditix"><? echo utf8ToHtml('Tipo:') ?></label>
				<select name="cdaditix" id="cdaditix" onChange="selecionaTipo(); return false;"></select>
				
				<a href="#" class="botao" id="btnOK2">OK</a>
			</td>
		</tr>
	</table>
	
	<label for="cdaditiv"></label>
	<select id="cdaditiv" name="cdaditiv" multiple size="8"></select>	
	
	<br style="clear:both" />	
	
</form>