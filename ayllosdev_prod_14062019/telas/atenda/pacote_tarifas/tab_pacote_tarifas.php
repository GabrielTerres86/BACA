<?	
	
/***************************************************************************************
 * FONTE        : tab_pacote_tarifas.php				Última alteração: --/--/----
 * CRIAÇÃO      : Lombardi
 * DATA CRIAÇÃO : Abril/2016
 * OBJETIVO     : 
 
	 Alterações   : 
  		 
     30/10/2018 - Merge Changeset 26538 referente ao P435 - Tarifas Avulsas (Peter - Supero) 
 
 **************************************************************************************/
	
	// Carrega permissões do operador
	include('../../../includes/carrega_permissoes.php');	
	
	setVarSession("opcoesTela",$opcoesTela);
		
	// Carregas as opções da Rotina de Pacote de tarifas
	$flgConsulta   = (in_array('C',$glbvars["opcoesTela"]));	
	$flgAlteracao  = (in_array('A',$glbvars["opcoesTela"]));	
	$flgInclusao   = (in_array('I',$glbvars["opcoesTela"]));	
	$flgCancela    = (in_array('K',$glbvars["opcoesTela"]));	
	$flgImpressao  = (in_array('M',$glbvars["opcoesTela"]));	
	$msgErro 	   = 'Acesso n&atilde;o permitido para esta op&ccedil;&atilde;o.';
	
?>
<div class="divRegistros">	
	<table id="tituloRegistros" class="tituloRegistros">
		<thead>
			<tr>
				<th>C&oacute;digo</th>
				<th style="text-align:left;">Servi&ccedil;o Cooperativo</th>
				<th>Início Vig&ecirc;ncia</th>
				<th>Situa&ccedil;&atilde;o</th>
			</tr>
		</thead>
		<tbody>
			<? foreach( $registros as $registro ) {  $contador++;  ?>
			
				<tr>
					<td><? echo getByTagName($registro->tags,'cdpacote'); ?></td>
					<td>
						<? echo getByTagName($registro->tags,'dspacote'); ?>
						<input type="hidden" id="hd_cdpacote" 			 value="<? echo getByTagName($registro->tags,'cdpacote'); ?>" />
						<input type="hidden" id="hd_dspacote" 			 value="<? echo getByTagName($registro->tags,'dspacote'); ?>" />
						<input type="hidden" id="hd_dtinicio_vigencia"   value="<? echo getByTagName($registro->tags,'dtinicio_vigencia'); ?>" />
						<input type="hidden" id="hd_flgsituacao" 		 value="<? echo getByTagName($registro->tags,'flgsituacao'); ?>" />
						<input type="hidden" id="hd_dtcancelamento" 	 value="<? echo getByTagName($registro->tags,'dtcancelamento'); ?>" />
						<input type="hidden" id="hd_dtadesao" 	 		 value="<? echo getByTagName($registro->tags,'dtadesao'); ?>" />
						<input type="hidden" id="hd_dtdiadebito"		 value="<? echo getByTagName($registro->tags,'dtdiadebito'); ?>" />
						<input type="hidden" id="hd_perdesconto_manual"  value="<? echo getByTagName($registro->tags,'perdesconto_manual'); ?>" />
						<input type="hidden" id="hd_qtdmeses_desconto"   value="<? echo getByTagName($registro->tags,'qtdmeses_desconto'); ?>" />
						<input type="hidden" id="hd_cdreciprocidade"	 value="<? echo getByTagName($registro->tags,'cdreciprocidade'); ?>" />
						<input type="hidden" id="hd_dtass_eletronica"	 value="<? echo getByTagName($registro->tags,'dtass_eletronica'); ?>" />
					</td>
					<td><? echo getByTagName($registro->tags,'dtinicio_vigencia'); ?></td>
					<td><? echo getByTagName($registro->tags,'flgsituacao'); ?></td>
				</tr>
				
			<? } ?>	
		</tbody>
	</table>
</div>	

<div id="divBotoes">
	<? if($modalidade != 2) {?>
		<a href="#" class="botao" style="margin: 4px 0px 4px 0px; width:70px; " id="btIncluir" onClick=<? if ($flgInclusao != '') echo '"chamaTelaPacote(\'I\',\'' . $nrdconta . '\'); return false;"'; else echo '"showError(\'error\',\'' . $msgErro . '\',\'Alerta - Ayllos\',\'bloqueiaFundo(divRotina)\');return false;"';?>>Incluir </a>
	<?}?>
	<a href="#" class="botao" style="margin: 4px 0px 4px 0px; width:70px; " id="btConsultar" onClick=<? if ($flgConsulta != '') echo '"chamaTelaPacote(\'C\',\'' . $nrdconta . '\'); return false;"'; else echo '"showError(\'error\',\'' . $msgErro . '\',\'Alerta - Ayllos\',\'bloqueiaFundo(divRotina)\');return false;"';?>>Consultar </a>
	<a href="#" class="botao" style="margin: 4px 0px 4px 0px; width:120px; " id="btAlterarDebito" onClick=<? if ($flgAlteracao != '') echo '"verificaPctCancelado(' . $nrdconta . ',\'AD\');return false;"'; else echo '"showError(\'error\',\'' . $msgErro . '\',\'Alerta - Ayllos\',\'bloqueiaFundo(divRotina)\');return false;"';?>>Alterar D&eacute;bito </a>
	<a href="#" class="botao" style="margin: 4px 0px 4px 0px; width:70px; " id="btImprimir" onClick=<? if ($flgImpressao != '') echo '"chamaTelaImprimir('.$nrdconta.');return false;"'; else echo '"showError(\'error\',\'' . $msgErro . '\',\'Alerta - Ayllos\',\'bloqueiaFundo(divRotina)\');return false;"';?>>Imprimir </a>
	<? if($modalidade != 2) {?>
		<a href="#" class="botao" style="margin: 4px 0px 4px 0px; width:70px; " id="btCancelar" onClick=<? if ($flgCancela != '') echo '"verificaPctCancelado('.$nrdconta.',\'C\');return false;";'; else echo '"showError(\'error\',\'' . $msgErro . '\',\'Alerta - Ayllos\',\'bloqueiaFundo(divRotina)\');return false;"';?>>Cancelar </a>
	<?}?>	
</div>
