<? 
/*!
 * FONTE        : titulos_limite_formulario_motivos.php
 * CRIAÇÃO      : Mateus Zimmermann (Mouts)
 * DATA CRIAÇÃO : Agosto/2018
 * OBJETIVO     : Carregar formulário de motivos de anulação
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */

?>
<form name="frmDadosMotivos" id="frmDadosMotivos" class="formulario">	
	<fieldset>		
		<legend>Motivos</legend>

			<? foreach( $motivos as $motivo ) { ?>
				
				<input name="cdmotivo" id="cdmotivo<? echo getByTagName($motivo->tags,'cdmotivo') ?>" type="radio" class="radio" style="width: 15px; margin-top: 5px" value="<? echo getByTagName($motivo->tags,'cdmotivo') ?>" <? echo getByTagName($motivo->tags,'incheck') == 'S' ? 'checked' : '' ?> <? echo $inaltera == 'N' ? 'disabled' : '' ?> onchange="controlarMotivos(<? echo getByTagName($motivo->tags,'cdmotivo') ?>)" />
				<label for="cdmotivo<? echo getByTagName($motivo->tags,'cdmotivo') ?>" class="radio"><? echo getByTagName($motivo->tags,'dsmotivo') ?></label>
				<input name="dsmotivo" id="dsmotivo<? echo getByTagName($motivo->tags,'cdmotivo') ?>" type="hidden" value="<? echo getByTagName($motivo->tags,'dsmotivo') ?>" />
				<? if(getByTagName($motivo->tags,'dsobservacao') != '' || getByTagName($motivo->tags,'inobservacao') == 1) { ?>
					<input name="dsobservacao<? echo getByTagName($motivo->tags,'cdmotivo') ?>" id="dsobservacao<? echo getByTagName($motivo->tags,'cdmotivo') ?>" type="text" style="width: 200px" maxlength="50" value="<? echo getByTagName($motivo->tags,'dsobservacao') ?>" <? echo $inaltera == 'N' || getByTagName($motivo->tags,'incheck') == 'N' ? ' class="campoTelaSemBorda" disabled' : 'class="campo"' ?> />
				<? } ?>
				<br style="clear:both" />

			<? } ?>

	</fieldset>		
</form>

<div id="divBotoesMotivos">

	<a href="#" class="botao" id="btnVoltarLimite" onClick="voltaDiv(3,2,4,'DESCONTO DE T&Iacute;TULOS - LIMITE');">Voltar </a>

	<a href="#" class="botao" id="btnContinuarLimite" onClick="gravaMotivosAnulacao();" <? echo $inaltera == 'N' ? 'style="color: gray; cursor: default; pointer-events: none;"' : '' ?>>Concluir </a>
	
</div>

<script type="text/javascript">

	dscShowHideDiv("divOpcoesDaOpcao3","divOpcoesDaOpcao2");

	formatarTelaConsultaMotivos();
				
	layoutPadrao();
	hideMsgAguardo();
	bloqueiaFundo(divRotina);	
	
</script>