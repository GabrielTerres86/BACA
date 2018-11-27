<?php
/*!
 * FONTE        : form_cargos_funcoes.php
 * CRIAÇÃO      : André Bohn
 * DATA CRIAÇÃO : 31/08/2018
 * OBJETIVO     : Tabela que apresenda os cargos e funções na tela PESSOA
 *
 * ALTERACOES	: 
 */	
 
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	

	
?>

<div id="divCooperado">
	
	<form id="frmCooperado" name="frmCooperado" class="formulario">
		
		<input type="hidden" id="nrdconta" name="nrdconta" value="<? echo getByTagName($registros1,'nrdconta'); ?>" />							
		<input type="hidden" id="inpessoa" name="inpessoa" value="<? echo getByTagName($registros1,'inpessoa'); ?>" />							
		<input type="hidden" id="flpessoa" name="flpessoa" value="<? echo getByTagName($registros1,'flpessoa'); ?>" />							
		<input type="hidden" id="nrcpfcgc" name="nrcpfcgc" value="<? echo getByTagName($registros1,'nrcpfcgc'); ?>" />					
	
		<fieldset id="fsetCooperado" name="fsetCooperado" style="padding:0px; margin:0px; padding-bottom:10px;">
			
			<legend><? echo "Cooeperado"; ?></legend>
			
			<table  style="border:0px solid black;width:720px;padding:2px;">
				<tr>
					<th style="width:15%;">Titulares</th>
					<th style="width:15%;">Conta/Itg</th>
					<th style="width:15%;">Tipo Pessoa</th>
					<th style="width:15%;">Tipo Vinculo</th>
				</tr>
				<tr>
					<td style="width:30%;" align="left" ><? echo getByTagName($registros1,'nmprimtl'); ?></td>
					<td align="center"><? echo getByTagName($registros1,'nrdctitg');?></td>
					<td align="center"><? echo getByTagName($registros1,'dspessoa');?></td>
					<td align="center"><? echo getByTagName($registros1,'tpvincul');?></td>						
				</tr>
				<tr>
					<td  style="position:absolut;"><? echo getByTagName($registros1,'nmextttl');?></td>
				</tr>
			</table>
			
		</fieldset>
	
		<br style="clear:both" />
		
	</form>
	
	<div id="divBotoesCooperado" style='text-align:center; margin-bottom: 10px; display:block;' >
		<a href="#" class="botao" id="btAlterar" onClick="apresentaFormTipoPessoa();return false;">Alterar</a>						
	</div>
	
</div>
<div id="divTabelaCargosFuncoes">	
	
	<div class="divRegistros">	
		<table class="tituloRegistros">
			<thead>
				<tr>
					<th>CPF/CNPJ</th>
					<th>Cargo</th>
					<th><? echo utf8ToHtml('Início vigência') ?></th>
					<th><? echo utf8ToHtml('Fim vigência') ?></th>
				</tr>
			</thead>
			<tbody>
							
				<? 
				foreach($registros as $i) {
				?>			
					<tr>
						<td><span><? echo getByTagName($i->tags,'nrcpfcgc'); ?></span> <? echo getByTagName($i->tags,'nrcpfcgc'); ?> </td>
						<td><span><? echo getByTagName($i->tags,'dsfuncao'); ?></span> <? echo getByTagName($i->tags,'dsfuncao'); ?> </td>
						<td><span><? echo getByTagName($i->tags,'dtinicio_vigencia'); ?></span> <? echo getByTagName($i->tags,'dtinicio_vigencia'); ?> </td>
						<td><span><? echo getByTagName($i->tags,'dtfim_vigencia'); ?></span><? echo getByTagName($i->tags,'dtfim_vigencia'); ?> </td>
						
						<input type="hidden" id="nrdrowid" name="nrdrowid" value="<? echo getByTagName($i->tags,'rowid');  ?>" />
						<input type="hidden" id="cdfuncao" name="cdfuncao" value="<? echo getByTagName($i->tags,'cdfuncao'); ?>" />
						<input type="hidden" id="dtinicio_vigencia" name="dtinicio_vigencia" value="<? echo getByTagName($i->tags,'dtinicio_vigencia'); ?>" />
						<input type="hidden" 
						id="flgvigencia"
						name="flgvigencia"
						value="<? echo getByTagName($i->tags,'flgvigencia'); ?>" />		
							
					</tr>
			<? } ?>	
			</tbody>
		</table>
	</div>
	<div id="divPesquisaRodape" class="divPesquisaRodape">
		<table>	
			<tr>
				<td>
					<?
						//
						if (isset($qtregist) and $qtregist == 0) $nriniseq = 0;
						
						// Se a paginação não está na primeira, exibe botão voltar
						if ($nriniseq > 1) { 
							?> <a class='paginacaoAnt'><<< Anterior</a> <? 
						} else {
							?> &nbsp; <?
						}
					?>
				</td>
				<td>
					<?
						if (isset($nriniseq)) { 
							?> Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?><?
						}
					?>
				</td>
				<td>
					<?
						// Se a paginação não está na &uacute;ltima página, exibe botão proximo
						if ($qtregist > ($nriniseq + $nrregist - 1)) {
							?> <a class='paginacaoProx'>Pr&oacute;ximo >>></a> <?
						} else {
							?> &nbsp; <?
						}
					?>			
				</td>
			</tr>
		</table>
	</div>
	<div id="divBotoesTabelaCadastro" style='text-align:center; margin-bottom: 10px; display:block;' >
		<a href="#" class="botao" id="btVoltar"   name="btAlterar" onClick="controlaVoltar('2');return false;"  style="float:none;">Voltar</a>
		<a href="#" class="botao" id="btInativar"   name="btInativar" style="float:none;">Inativar</a>
		<a href="#" class="botao" id="btIncluir"   name="btIncluir"  style="float:none;">Incluir</a>																				
		<a href="#" class="botao" id="btExcluir"   name="btExcluir" style="float:none;">Excluir</a>																				
	</div>
</div>


<script type="text/javascript">

	$('a.paginacaoAnt').unbind('click').bind('click', function() {
		buscarCoopeado(<? echo "'".($nriniseq - $nrregist)."','".$nrregist."'"; ?>);
	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		buscarCoopeado(<? echo "'".($nriniseq + $nrregist)."','".$nrregist."'"; ?>);
	});	
	
	($('#flpessoa','#frmCooperado').val() == '1') ? $('#btAlterar','#divBotoesCooperado').css('display', 'inline') : $('#btAlterar','#divBotoesCooperado').css('display', 'none') ; 
	$('#divBotoesFiltro').css('display', 'none');
	$('#btConcluir','#divBotoesCooperado').css('display', 'none');
	$('#divPesquisaRodape','#divPessoa').formataRodapePesquisa();
	$('#inpessoa','#frmCooperado').desabilitaCampo();
	formataTabela();
	
</script>
