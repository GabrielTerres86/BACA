<?php 
/*!
 * FONTE        : contas/ppe/formulario_ppe.php
 * CRIAÇÃO      : Carlos Henrique (CECRED)
 * DATA CRIAÇÃO : 24/05/2010 
 * OBJETIVO     : Formulário de dados de Comercial/PPE da tela de CONTAS
 * --------------
 * ALTERAÇÕES   : 
 */	
?>
<form name="frmDadosPpe" id="frmDadosPpe" class="formulario">
<fieldset>
	<legend>Pessoa Exposta Politicamente</legend>
	
	<input name="inpolexp" id="inpolexp" type="hidden" value="<? echo getByTagName($ppe,'inpolexp') ?>" />
	<input name="nmextttl" id="nmextttl" type="hidden" value="<? echo getByTagName($ppe,'nmextttl') ?>" />
	<input name="rsocupa"  id="rsocupa"  type="hidden" value="<? echo getByTagName($ppe,'rsocupa') ?>" />
	<input name="nrcpfcgc" id="nrcpfcgc" type="hidden" value="<? echo formatar(getByTagName($ppe,'nrcpfcgc'),'cpf',true)  ?>" />
	
	<input name="nrdconta" id="nrdconta" type="hidden" value="<? echo getByTagName($ppe,'nrdconta') ?>" />
	<input name="cidade"   id="cidade"   type="hidden" value="<? echo getByTagName($ppe,'cidade') ?>" />
	
	<div style="height:36px">
		<label for="tpexposto">Tp. Exposto:</label>
		<select name="tpexposto" id="tpexposto" onchange="atualizaTipoExposto(this)">
			<option value=""> - </option>
			<option value="1" <? if (getByTagName($ppe,'tpexposto') == '1') { echo " selected"; } ?>>1 - Exerce/Exerceu</option>
			<option value="2" <? if (getByTagName($ppe,'tpexposto') == '2') { echo " selected"; } ?>>2 - Relacionamento</option>
		</select>
		
		<div style="float:right">
			<label for="cdocpttl">Ocupação:</label>
			<input name="cdocpttl" id="cdocpttl" type="text" value="<? echo getByTagName($ppe,'cdocupacao') ?>" size="2" />
			<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
			<!-- cdocpttl, filtrar pela tabela gncdocp e o campo de descrição dsdocupa-->	
			<input name="rsocupa" id="rsocupa" type="text" value="<? echo getByTagName($ppe,'rsocupa') ?>" size="25" />
		</div>
	</div>
	<div style="height:60px">
		<div id="divExposto1">
			<label for="nmempresa">Nome Empresa:</label>
			<input name="nmempresa" id="nmempresa" type="text" value="<? echo getByTagName($ppe,'nmempresa') ?>" size="42" maxlength="35" />
			<div style="float:right; height:40px">
				<label for="nrcnpj_empresa">CNPJ:</label>
				<input name="nrcnpj_empresa" id="nrcnpj_empresa" class="cnpj" type="text" value="<? echo formatar(getByTagName($ppe,'nrcnpj_empresa'),'cnpj',true) ?>" size="17" />
			</div>
			<div style="float:left; height:40px">
				<label for="dtinicio">Dt. Início:</label>
				<input name="dtinicio" id="dtinicio" type="text" value="<? echo getByTagName($ppe,'dtinicio') ?>" />			
				<label for="dttermino" style="width:85px">Dt. Término:</label>
				<input name="dttermino" id="dttermino" type="text" value="<? echo getByTagName($ppe,'dttermino') ?>" />
			</div>
		</div>
		<div id="divExposto2">
			<!-- tbcadast_politico_exposto.NMPOLITICO -->
			<label for="nmpolitico">Nome Político:</label>
			<input name="nmpolitico" id="nmpolitico" type="text" value="<? echo getByTagName($ppe,'nmpolitico') ?>" size="45" maxlength="60" />
			
			<div style="float:right; height:40px">
				<label for="nrcpf_politico">CPF:</label>
				<input name="nrcpf_politico" id="nrcpf_politico" type="text" class="cpf" value="<? echo getByTagName($ppe,'nrcpf_politico') ?>" size="14" />
			</div>
			<div style="float:left; height:40px">
				<!-- Tipo de Relacionamento/Ligação: campo obrigatório, texto livre. tbcadast_politico_exposto.CDRELACIONAMENTO-->
				<label for="cdrelacionamento">Tp. relacionamento:</label>
				<input name="cdrelacionamento" id="cdrelacionamento" type="text" value="<? echo getByTagName($ppe,'cdrelacionamento') ?>" size="2" />
				<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
				<!-- craptab dstextab = 'CONJUGE,1,PAI/MAE,2,FILHO(A),3,COMPANHEIRO(A),4,OUTROS,5,COLABORADOR(A),6,ENTEADO(A),7,NENHUM,9'
				where craptab.cdcooper > 0 AND
					  craptab.nmsistem = 'CRED'                     AND
					  craptab.tptabela = 'GENERI'                   AND
					  craptab.cdempres = 0                          AND
					  craptab.cdacesso = 'VINCULOTTL'               AND
					  craptab.tpregist = 0;-->
				<input name="dsrelacionamento" id="dsrelacionamento" type="text" value="<? echo getByTagName($ppe,'dsrelacionamento') ?>" size="30" />
			</div>
		</div>		
	</div>
	
<!--	<br style="clear:both" />-->
</fieldset>
</form>
<div id="divBotoes">
	<input type="image" id="btVoltar"     src="<? echo $UrlImagens; ?>botoes/cancelar.gif"  onClick="controlaOperacao('AC');return false;" />
	
	<?  if (getByTagName($ppe,'inpolexp') == 1) { ?>
		<input type="image" id="btPpeAlterar" src="<? echo $UrlImagens; ?>botoes/alterar.gif"   onClick="controlaOperacao('VA');" />
	<?  } ?>
	<?  if (getByTagName($ppe,'inpolexp') <> 2) { ?>
	<input type="image" id="btContinuar"  src="<? echo $UrlImagens; ?>botoes/continuar.gif" onClick="proximaRotina();" />	
	<?  } ?>
</div>
<script>
$('#divExposto1','#'+nomeForm).css('display', '<? echo ($tpexposto == 1)? 'block':'none' ?>');
$('#divExposto2','#'+nomeForm).css('display', '<? echo ($tpexposto == 2)? 'block':'none' ?>');
$('#dtinicio','#'+nomeForm).css({'width':'75px'}).addClass('data');
$('#dttermino','#'+nomeForm).css({'width':'75px'}).addClass('data');
$('#nrcpfcgc','#'+nomeForm).setMask('INTEGER', 'zzz.zzz.zzz-zz', '.', '');
</script>
