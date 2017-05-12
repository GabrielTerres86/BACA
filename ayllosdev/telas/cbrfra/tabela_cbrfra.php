<? 
/*!
 * FONTE          : tabela_cbrfra.php
 * CRIAÇÃO      : Rodrigo Bertelli (RKAM)
 * DATA CRIAÇÃO : 16/06/2014
 * OBJETIVO       : Tabela que apresenda os codigos de barra e cpf/cnpjs com fraude na tela CBRFRA
 *
 *  16/08/2016 - #456682  Adaptado para mostrar os cpfs/cnpjs bloqueados (Carlos)
 *  16/09/2016 - Melhoria nas mensagens, de "Código" para "Registro", para ficar genérico, conforme solicitado pelo Maicon (Carlos)
 *  15/02/2016 - Inclusão do tipo  Telefone Celular. Melhoria nas mensagens. Projeto 321 - Recarga de Celular. (Lombardi)
 */
 $search  = array('.','-');
  
?>
	<table class="tituloRegistros" style="border: 1px solid #777; border-bottom: 0px;">
		<thead>
			<tr>
                <th style="width: 60%"><?php echo ($tipo == '1') ? 'C&oacute;digos': ($tipo == '4' ? 'Telefone Celular' : 'CPF/CNPJ') ?></th>
				<th style="width: 20%">Data Inclus&atilde;o</th>
                <th class="clsexcluir" style="width: 10%; <? echo $strdisabled;?>">A&ccedil;&atilde;o</th>
				<th style="width: 2%; border: 0px;">&nbsp;</th>
			</tr>			
		</thead>
	</table>
	<div id="registros" style='border-left: 1px solid #777; overflow-y:scroll ; height: 150px'>
	<table width="100%">
	<tbody>
	<?
			$cor = "corPar";
			$i = 0;
			
			foreach($registros as $fraude) {
				// Recebo todos valores em variaveis
				
				if ($i == 0) {
					$qtregist = getByTagName($fraude->tags,'qtregist');
				}
						
				$dsfraude = getByTagName($fraude->tags,'dsfraude');				
				$dtsolici = getByTagName($fraude->tags,'dtsolici');

				if ($dsfraude == '') {
					continue;
				}
				
				if ($tipo == 2 or $tipo == 3) {
					$dsfraude = formatar($dsfraude,($tipo == 2)? 'cpf':'cnpj');
				} 

				$cor = ($cor == "corImpar") ? "corPar" : "corImpar";

				$i++;
    ?>
				<tr class="<? echo $cor; ?>">
				<td style="width: 60%; text-align: center;"><? if ($tipo == 4){ echo "(". mascara($dsfraude,"##) ##########"); } else { echo $dsfraude; } ?></td>
				<td style="width: 20%; text-align: center;"><? echo $dtsolici;?></td>
				<td class="clsexcluir" style="width: 10%; <? echo $strdisabled;?>;text-align: center; padding-left:5px;"><img title="Excluir registro de Fraude" style="cursor: pointer" src="../../imagens/geral/btn_excluir.gif" onclick="preencheCodExclusao('<? echo $dsfraude;?>')"/></td>
				</tr>
<? 			} ?>	
	</tbody>
	</table>
</div>
<div id="divPesquisaRodape" class="divPesquisaRodape">
	<table>	
		<tr>
			<td>
				<?			
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
					if (isset($nriniseq) && $nriniseq > 0) { 
						?> Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?><?
					}
				?>
			</td>
			<td>
				<?
					// Se a paginação não está na &uacute;ltima página, exibe botão proximo
					if ($qtregist > ($nriniseq + $nrregist - 1) && $nriniseq > 0) {
						?> <a class='paginacaoProx'>Pr&oacute;ximo >>></a> <?
					} else {
						?> &nbsp; <?
					}
				?>			
			</td>
		</tr>
	</table>
</div>

<script type="text/javascript">
	$('a.paginacaoAnt').unbind('click').bind('click', function() {
		realizaOperacao("C" ,<? echo "'".($nriniseq - $nrregist)."','".$nrregist."'"; ?>);
	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		realizaOperacao("C",<? echo "'".($nriniseq + $nrregist)."','".$nrregist."'"; ?>);
	});	
	$('#divPesquisaRodape').formataRodapePesquisa();
</script>