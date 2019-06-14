<?
/*!
 * FONTE        : form_habilita.php
 * CRIAÇÃO      : Fabricio
 * DATA CRIAÇÃO : 08/12/2011
 * OBJETIVO     : Mostrar campos da opcao H = Habilitar Convenio
 * --------------
 * ALTERAÇÕES   : 08/02/2012 - Ajustes Pamcar (Adriano).
 *
 *				  19/06/2012 - Retiradas funções 'onClick' dos botões de Alteração
 * 							   e Impressão para que sejam atribuidas pelo JS (Lucas).
 *
 *				  06/03/2013 - Novo layout padrao (Gabriel).
 * --------------
 */
?>
<div id="divHabilita">
<form id="frmHabilita" name="frmHabilita" class="formulario" style="display:none;">

	
	<label for="nrdconta"><? echo utf8ToHtml('Conta/dv:') ?></label>	
	<input name="nrdconta" type="text"  id="nrdconta"  />
	
	<a href="#" onClick="mostraPesquisaAssociado('nrdconta','frmHabilita','');return false;"><img src="<?php  echo $UrlImagens; ?>geral/ico_lupa.gif" width="14" height="14" border="0"></a>

	<label for="nrdctitg"><? echo utf8ToHtml('Conta/ITG:') ?></label>	
	<input name="nrdctitg" type="text"  id="nrdctitg" />

	<a href="#" onClick="mostraPesquisaAssociado('nrdconta','frmHabilita','');return false;"><img src="<?php  echo $UrlImagens; ?>geral/ico_lupa.gif" width="14" height="14" border="0"></a>

	<input name="dssititg" type="text"  id="dssititg"  />
		
	<a href="#" class="botao" onClick="obtemDadosConta(); return false;">OK</a>	
		
	<br style="clear:both;" />
	<hr style="background-color:#666; height:1px;" />

	<label for="nmprimtl"><? echo utf8ToHtml('Nome/Raz&atilde;o Social:') ?></label>
	<input id="nmprimtl" name="nmprimtl" type="text"  />
	
	<label for="nrcpfcgc"><? echo utf8ToHtml('CPF/CNPJ:') ?></label>
	<input id="nrcpfcgc" name="nrcpfcgc" type="text"  />
	
	<br style="clear:both;" />
	<hr style="background-color:#666; height:1px;" />
	
	<label for="flgpamca"><? echo utf8ToHtml('Habilitar Conv&ecirc;nio:') ?></label>
	<select id="flgpamca" name="flgpamca" onChange="alteraCamposHabilitacao();">
		<option value="S"> Sim </option> 
		<option value="N"><? echo utf8ToHtml('N&atilde;o') ?> </option>
	</select>

	<div style="clear:both;">
	</div>
	
	<label for="vllimpaH"><? echo utf8ToHtml('Limite:') ?></label>
	<input id="vllimpaH" name="vllimpaH" type="text"  />

	<div style="clear:both;">
	</div>
	
	<label for="dddebpam"><? echo utf8ToHtml('D&eacute;bito Mensalidade:') ?></label>
	<select id="dddebpam" name="dddempam">
		<option value="1" > 01 </option> 
		<option value="10"> 10 </option>
		<option value="20"> 20 </option>
	</select>

	<div style="clear:both;">
	</div>
	
	<label for="nrctapam"><? echo utf8ToHtml('Conta Duplicada:') ?></label>
	<input id="nrctapam" name="nrctapam" type="text"  />
	
	<br style="clear:both;" />
	<hr style="background-color:#666; height:1px;" />
	
		
	<div id="divBotoes" style="margin-bottom: 10px;">	
		<a href="#" class="botao" id="btVoltar" onClick="estadoInicial(); 	return false;">Voltar</a>	
		<a href="#" class="botao" id="btnAlterar" onClick="return false;">Alterar</a>	
		<a href="#" class="botao" id="btnImprime" onClick="return false;">Imprimir Contrato</a>	
	</div>
	<div style="clear:both;">
	
	</div>
</form>
</div>

<script type='text/javascript'>
	highlightObjFocus($('#frmHabilita')); 
</script>

