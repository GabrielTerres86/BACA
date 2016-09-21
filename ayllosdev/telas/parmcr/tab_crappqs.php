<? 
/*!
 * FONTE        : tab_crappqs.php
 * CRIAÇÃO      : Jonata - (RKAM)
 * DATA CRIAÇÃO : 08/12/2014 
 * OBJETIVO     : Tabela que apresenta as perguntas dos questionarios
 * --------------
 * ALTERAÇÕES   : 
 */
 
?>

<?php
 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	
?>

<form id="frmCrappqs" name="frmCrappqs" class="formulario">

	<input type="hidden" name="nrseqper" id="nrseqper" value="<? echo $inf[0]->nrseqper; ?>">
	<input type="hidden" name="intipres" id="intipres" value="<? echo $inf[0]->intipres; ?>">
	<input type="hidden" name="dsregexi" id="dsregexi" value="<? echo $inf[0]->dsregexi; ?>">
	<input type="hidden" name="nrordper" id="nrordper" value="<? echo $inf[0]->nrordper; ?>">
	
	<fieldset>

	<legend> Perguntas </legend>
	
	<div id="tabCrappqs">
		<div class="divRegistros">	
			<table class="tituloRegistros">
				<thead>
					<tr>
						<th style="width:12%"> <? echo utf8ToHtml('Sequência');         ?> </th>
						<th style="width:38%"><? echo utf8ToHtml('Pergunta');         ?> </th>
						<th style="width:12%;"> <? echo utf8ToHtml('Obrigatória');      ?> </th>
						<th style="width:12%;"> <? echo utf8ToHtml('Resposta');         ?> </th>
						<th style="width:12%;"> <? echo utf8ToHtml('Regra de Cálculo'); ?> </th>
						<th style="width:12%;"> <? echo utf8ToHtml('Filtro Exibição'); ?> </th>
						
					</tr>
				</thead>
				<tbody>
					<?php				
					for ($i = 0; $i < $qtregist; $i++) {
					
						$nrseqper = $inf[$i]->nrseqper;
						$nrordper = $inf[$i]->nrordper;
						$dspergun = $inf[$i]->dspergun; 
						$intipres = $inf[$i]->intipres;
						$dsobriga = ($inf[$i]->inobriga == 1) ? 'Sim' : 'N&atilde;o';
						
						if ($intipres == 1) 
							$dstipres = "&Uacute;nica escolha";
						else if ($intipres == 2) 
							$dstipres = "Texto num&eacute;rico";
						else	
							$dstipres = "Texto livre";
						
						if ($inf[$i]->nrregcal == 0) 
							$dsregcal = ''; 
						else 
						if ($inf[$i]->nrregcal == 1)
							$dsregcal = 'Perfil Cr&eacute;dito ';
						else
						if ($inf[$i]->nrregcal == 2) 
							$dsregcal = 'Prazo';
						else
						if ($inf[$i]->nrregcal == 3)
							$dsregcal = 'G&ecirc;nero';
						
						$dsregexi = $inf[$i]->dsregexi; 
									
					?>
						<tr onclick="selecionaPergunta(<? echo $nrseqper; ?> , 
													   <? echo $intipres; ?> , 
													  '<? echo $dsregexi; ?>', 
													   <? echo $nrordper; ?>);">
													  
							<td style="width:12%"><? echo $nrordper; ?></td>
							<td style="width:39%"><? echo $dspergun; ?></td>
							<td style="width:12.5%"> <? echo $dsobriga; ?></td>
							<td style="width:12.5%"><? echo $dstipres; ?></td>
							<td style="width:12%"><? echo $dsregcal; ?></td>
							<td style="width:12%"><? echo ($dsregexi == '') ? 'N&atilde;o' : 'Sim'; ?></td>
							
						</tr>
				<? } ?>	
				</tbody>
			</table>
		
		</div>	
	</div>

	<div id="divBotoes" style='margin-top:0px; margin-bottom :0px'>
		<a href="#" class="botao" id="btIncluir" onclick="rotina('I_crappqs_1'); return false;">Incluir</a>
		<a href="#" class="botao" id="btAlterar" onclick="rotina('A_crappqs_1'); return false;">Alterar</a>
		<a href="#" class="botao" id="btExcluir" onclick="manter_rotina('E_crappqs_1'); return false;">Excluir</a>
	</div>

	</fieldset>

</form>


<script>
	formataTabelaPergunta();
	
	<? if ( $inf[0]->nrseqper != '' ) { ?>
		controlaOperacao('C4' , 0 , 0 , <? echo $inf[0]->nrseqper; ?>, <? echo $flgbloqu ?>);
	<? } ?>
	
</script>
