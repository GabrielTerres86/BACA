<? 
/*!
 * FONTE        : tab_crapqac.php
 * CRIAÇÃO      : Jonata - (RKAM)
 * DATA CRIAÇÃO : 29/01/2015 
 * OBJETIVO     : Tabela que apresenta as versoes da PARRAC
 * --------------
 * ALTERAÇÕES   : 12/11/2015 - Alterado a descricao dos riscos (Tiago/Rodrigo SD356389)
 *                
 *                26/04/2018 - Buscar situacoes da tabela. PRJ366 (Lombardi).
 */
 
?>

<?php
 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	
	
	$k = 0;
	
	function retornaResidencia($pr_residencia) {
	
		$tipo_residencia = "";
		$arr_residencia = explode(";",$pr_residencia);
							
		for ($k = 0; $k < count($arr_residencia); $k++) {
			
			$residencia = '';
			
			switch ($arr_residencia[$k]) {
			
				case 1: $residencia = "Quitado";    break;
				case 2: $residencia = "Financiado"; break;
				case 3: $residencia = "Alugado";    break;
				case 4: $residencia = "Familiar";   break;
				case 5: $residencia = "Cedido";     break;
							
			}
				
			$tipo_residencia .= ($tipo_residencia == '') ? $residencia : ';' . $residencia;
			
		}
		
		return $tipo_residencia;

	}
	
	function retornaSituacaoConta ($pr_conta) {
	
		$tipo_conta = "";
		$arr_conta  = explode(";",$pr_conta);
							
		$situacoes = buscaSituacoesConta();
		
		
		for ($k = 0; $k < count($arr_conta); $k++) {
			
			$conta = '';
			
			foreach ($situacoes as $situacao) {
				$cdsituacao = getByTagName($situacao->tags,'cdsituacao');
				$dssituacao = getByTagName($situacao->tags,'dssituacao');
				if ($arr_conta[$k] == $cdsituacao) {
					$conta = $dssituacao;
				}
			}
			$tipo_conta .= ($tipo_conta == '') ? $conta : ';' . $conta;
		}
		
		return $tipo_conta;
	
	}
	
?>

<form name="frmCrapqac" id="frmCrapqac" class="formulario" >

	<fieldset>
	
		<div id="divCrapqac" name="divCrapqac" style="overflow-y:scroll; height:370px;">
			
			<? for ($i=0; $i < $qtregist_ind; $i++) { ?>
			
				<fieldset>
		
				<legend> <? echo utf8ToHtml($indicadores[$i]->dsindica) ?> </legend>
		
				<? for ($j=0; $j < count($indicadores[$i]->detalhe); $j++) {  $class = "inteiro";  ?>
				
					<? $detalhe = $indicadores[$i]->detalhe[$j]; $metodo = ""; ?>
				
					<? if ($detalhe->nrordper == 0 ) {  ?>
					
						<? if ($j > 0) { ?>
							</fieldset>
						<? } ?>
								
					<fieldset>
								 
						<? if (in_array($indicadores[$i]->nrseqiac,array('3','13'))) { ?>
								
							<? if ($detalhe->inpessoa == 1) { ?>
							<legend>PF</legend>
							<? } 
							else if ($detalhe->inpessoa == 2) { ?>
								<legend>PJ</legend>
							<? }
							else { ?>
								<legend>PF e PJ</legend>
							<? } 
						} ?>
						
						<? if ( ($i >= 9 && $i <= 11) && $j == 0 ) { ?>
							<label name="nrseqqac" id="nrseqqac-<? echo $i . "-" . $j ?>" nrseqqac="<? echo $detalhe->nrseqqac ?>" style="width:220px"> <? echo utf8ToHtml($arr_criterios[$i . $j]) ?></label>
							<input name="criterio" id="criterio-<? echo $i . "-" . $j ?>" type="text" class="inteiro" style="width:90px" value="<? echo $detalhe->vlparam1; ?>" />
						    <? $margin_left = '26px'; ?>
						<? } else { ?>
							<input type="hidden" name="nrseqqac" id="nrseqqac-<? echo $i . "-" . $j ?>" nrseqqac="<? echo $detalhe->nrseqqac ?>" value="">
						<?
							$margin_left = '345px';
						} ?>

						<? if (($indicadores[$i]->dsindica == 'COMPROMETIMENTO DE RENDA' && $detalhe->inpessoa == 1) || $indicadores[$i]->dsindica != 'COMPROMETIMENTO DE RENDA') { ?>
								<label style="width:60px; margin-left: <? echo $margin_left; ?> ;"> <? echo utf8ToHtml("Situa&ccedil;&atilde;o:") ?></label>
								<select name="cdstatus" id="cdstatus-<? echo $i . $j ?>" nrseqiac="<? echo $indicadores[$i]->nrseqiac ?>" style="width:100px">
									<option value="1" <? echo ($indicadores[$i]->instatus == "1") ? "selected" : "" ?>> Ativo </option>
									<option value="2" <? echo ($indicadores[$i]->instatus == "2") ? "selected" : "" ?>> Inativo</option>
								</select>
						<?  	$margin_left_2 = '11px';
							} 
							else { 
								$margin_left_2 = '539px';
							 }									
						?>
						
						<input type="hidden" name="instatus" id="instatus-<? echo $i . "-" . $j ?>" value="1">
						
						<a href="#" class="botao" name="btMensagemPositiva" id="btMensagemPositiva-<? echo $detalhe->nrseqqac ?>" nrseqiac="<? echo $indicadores[$i]->nrseqiac ?>" nrseqqac="<? echo $detalhe->nrseqqac ?>" style="margin-left: <? echo $margin_left_2; ?>" onclick="rotina('mensagem_positiv_<? echo $detalhe->nrseqqac ?>', <? echo $i ?>);return false;" >Mensagem Positiva</a>
						<input name="inmensag" id="inmensag-<? echo $detalhe->nrseqqac ?>" type="hidden" value="<? echo $detalhe->inmensag; ?>" />
					    <input name="dsmensag" id="dsmensag-<? echo $detalhe->nrseqqac ?>" type="hidden" value="<? echo $detalhe->dsmensag; ?>" />
	
					<? } else { 
		
						// Label curto com campo curto
						if ($i <= 2 || $i == 4 || $i == 11 || $i == 13 || $i == 14 || ( ($i == 8 || $i == 9 || $i == 10 ) && $j == 1) || ($i == 9 && $j == 2)) {
							$width_label   = "220px";
							$width_campo   = "90px";
							$margin_status = "80px";
							$flg_campo     = true;
							$flg_campo_2   = false;
						} 
						else // Label curto com campo maior
						if ($i == 6) { 
							$width_campo   = "160px";
							$margin_status = "10px";
							$flg_campo     = true;
							$flg_campo_2   = false;
						} 			
						else // Label maior sem campo
						if ($i == 7  || ($i == 9 && $j == 2) || ($i == 3 && ($j == 2 || $j == 4 || $j == 6) ) || $i > 14) { 
							$width_label   = "385px";
							$margin_status = "1px";
							$flg_campo     = false;
							$flg_campo_2   = false;
						}
						else // Dois campos
						if ($i == 12 || ($i == 3 && ($j == 1 || $j == 3 || $j == 5))) {
							$width_label   = ($i == 3) ? '60px'  : '80px';
							$width_campo   = ($i == 3) ? '100px' : '80px';
							$margin_status = "10px";
							$width_label_2 = "130px";
							$flg_campo     = true;
							$flg_campo_2   = true;
							if ($i == 3) 
								$campo_2 = 'Tempo Máx. (meses):';
							else
								$campo_2 = 'Qtde Instit:';
							$width_campo_2 = '80px';
							$class_2 = 'inteiro';
						}
						else {
							$flg_campo   = true;
							$flg_campo_2 = false;
						}
						
						if ($i == 3 && $j == 1) {	?>	
						   	<input name="dscasprp" id="dscasprp" type="hidden" value="<? echo $detalhe->vlparam1; ?>" />
						<? 
							$metodo = "rotina('tipo_residencia' , this);";
							$class = "texto";
						}
						
						if ($i == 3 && $j >= 1 && $j <= 5) {
							$detalhe->vlparam1 = retornaResidencia($detalhe->vlparam1);
							$class = "texto";
						 }
						
						if ($i == 6 && $j == 1) { ?>	
						   	<input name="dssitcta" id="dssitcta" type="hidden" value="<? echo $detalhe->vlparam1; ?>" />
							
						<?	$detalhe->vlparam1 = retornaSituacaoConta($detalhe->vlparam1);
						    $metodo = "rotina('situacao_conta', this);";
							$class = "texto";
						}
											
						?>
					
						<label name="nrseqqac" id="nrseqqac-<? echo $i . "-" . $j ?>" nrseqqac="<? echo $detalhe->nrseqqac ?>" style="width:<? echo $width_label ?>;"> <? echo utf8ToHtml($arr_criterios[$i . $j]) ?></label>
						
						<? if ($flg_campo) { 
							  if ($i == 3 && ($j == 1 || $j == 3 || $j == 5)) { ?>
								<select name="criterio" id="criterio-<? echo $i . "-" . $j ?>" style="width:<? echo $width_campo ?>;" >
									<option value="1" <? echo ($detalhe->vlparam1 == "Quitado")    ? 'selected' : '' ?> > Quitado    </option>
									<option value="2" <? echo ($detalhe->vlparam1 == "Financiado") ? 'selected' : '' ?> > Financiado </option>
									<option value="3" <? echo ($detalhe->vlparam1 == "Alugado")    ? 'selected' : '' ?> > Alugado    </option>
									<option value="4" <? echo ($detalhe->vlparam1 == "Familiar")   ? 'selected' : '' ?> > Familiar   </option>
									<option value="5" <? echo ($detalhe->vlparam1 == "Cedido")     ? 'selected' : '' ?> >  Cedido    </option>
								</select>
							  <? } else { 
							
								if ( ($i == 8 || $i == 11 || $i == 13 || $i == 14) && $j == 1) {
									$class = 'moeda';
									$detalhe->vlparam1 = formataMoeda($detalhe->vlparam1);
								}?>
								
								<input name="criterio" id="criterio-<? echo $i . "-" . $j ?>" type="text" class="<? echo $class ?>" style="width:<? echo $width_campo ?>;" value="<? echo $detalhe->vlparam1; ?>" onfocus="<? echo $metodo; ?>"  />
							  <? 
						        } 
							} else { ?>								
									<input name="criterio" id="criterio-<? echo $i . "-" . $j ?>" type="hidden" value="">	
						<? } ?>
								
						<? if ($flg_campo_2) { ?>
							<label for="criterio2" name="nrseqqac2" id="nrseqqac2-<? echo $i . "-" . $j ?>"style="width:<? echo $width_label_2 ?>;"> <? echo utf8ToHtml($campo_2); ?></label>
							<input name="criterio2" id="criterio2-<? echo $i . "-" . $j ?>" nrseqqac="<? echo $detalhe->nrseqqac ?>" type="text" class="<? echo $class_2 ?>" style="width:<? echo $width_campo_2 ?>;" value="<? echo $detalhe->vlparam2; ?>" />
						<? } ?>
						
						<label for="instatus" style="margin-left:<? echo $margin_status; ?>"><? echo utf8ToHtml('Status:') ?></label>
						<select name="instatus" id="instatus-<? echo $i . "-" . $j ?>" >
							<option value="1" <? echo ($detalhe->instatus == 1) ? 'selected' : '' ?> ><? echo utf8ToHtml('Baixo risco'); ?></option>
							<option value="2" <? echo ($detalhe->instatus == 2) ? 'selected' : '' ?> ><? echo utf8ToHtml('Médio risco'); ?></option>
							<option value="3" <? echo ($detalhe->instatus == 3) ? 'selected' : '' ?> ><? echo utf8ToHtml('Alto risco'); ?></option>
						</select>
						
						<label for="espaco"></label>

						<a href="#" class="botao" name="btMensagem" id="btMensagem-<? echo $detalhe->nrseqqac ?>"  nrseqiac="<? echo $indicadores[$i]->nrseqiac ?>" onclick="rotina('mensagem_atencao_<? echo $detalhe->nrseqqac ?>',<? echo $i ?>);return false;">Mensagem</a>
					
						<input name="inmensag" id="inmensag-<? echo $detalhe->nrseqqac ?>" type="hidden" value="<? echo $detalhe->inmensag; ?>" />
						<input name="dsmensag" id="dsmensag-<? echo $detalhe->nrseqqac ?>" type="hidden" value="<? echo $detalhe->dsmensag; ?>" />
			
						
					<? } ?>
					
					<?	if ($i == 3 && ($j == 2 || $j == 4 )) { ?>
							<div style="width:100%; height:50px"></div>
					<?	} ?>
					
					<br />
		
				<? } ?>
								
				</fieldset>
				</fieldset>
				
			<? } ?>	
				
		</div>
		
	</fieldset>
	
	<div id="divBotoes" style='margin-top:0px; margin-bottom :0px;'>
		<a href="#" class="botao" id="btVoltar" onclick="estadoInicial(); return false;">Voltar</a>
		<a href="#" class="botao" id="btSalvar" onclick="habilitaAlteracao(); return false;">Alterar</a>
	</div>

</form>


<script>
	$(document).ready(function() {
		
		formataCriterios();	
		highlightObjFocus($("#frmCrapqac"));
				
		if ($("#criterio-0-1","#divCrapqac").val() == "" && cddopcao == 'A') {
			habilitaAlteracao();
		}
	});
</script>
