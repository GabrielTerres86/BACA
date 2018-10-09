<?php
/*!
 * FONTE        : form_seguro_vida_prest.php
 * CRIAÇÃO      : Michel M. Candido (GATI)
 * DATA CRIAÇÃO : 21/09/2011
 * OBJETIVO     : trazer em tela o foruario final para preenchimento dos dados
 * --------------
 * ALTERAÇÕES   :
 * 001: [30/11/2012] David (CECRED) : Validar session
 * 002: [05/03/2015] Odirlei(AMcom) : Permitir definir dia do mês para os proximos debitos
 * 003: [06/09/2018] Mateus Z(Mouts) : PRJ 438 - Adicionado campo contrato para tipo Prestamista
 */

	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");
	isPostMethod();	

	$nmresseg = $_POST["nmresseg"];
    $tipo = $_POST['tipo'];
    $operacao = $_POST['operacao'];
	
	$data = explode("/", $glbvars[dtmvtolt]);
	$dtfim = date("d/m/Y", mktime(0, 0, 0, $data[1], $data[0] + 365, $data[2]) );		

?>
<form name="frmNovo" id="frmNovo" class="formulario condensado">	

				<label id='show-consulta' style='display:none'></label>				
				<br />
				
				<input type='hidden' value='' name='nrctrseg' id='nrctrseg'/>			
				<input type='hidden' value='' name='tpseguro' id='tpseguro'/>					
				<input type='hidden' value='' name='cdsegura' id='cdsegura'/>
                <input type='hidden' value='<?php echo $data[0]; ?>' id='diamvt'/>
				
				<input type='hidden' value='' name='nrcpfcgc' id='nrcpfcgc'/>			
				<input type='hidden' value='' name='cdempres' id='cdempres'/>	
				
				<label for='nmdsegur'>Segurado:</label>
				<input name='nmdsegur' id='nmdsegur' />		
				<br />
				<label for='vlpreseg'>Valor do Premio:</label>
				<input type="text" name='vlpreseg' value='0,00' id='vlpreseg'>
			
				<label for='dtinivig' class='not'>Inicio da Vigência:</label>
				<input type="text" name='dtinivig' id='dtinivig' value="">
			<br>
				<label for='vlcapseg'>Capital Segurado:</label>
				<input type="text" name='vlcapseg' value='0,00' id='vlcapseg'>
			
				<label for='dtfimvig' class='not'>Fim da Vigência:</label>
				<input type="text" name='dtfimvig' id='dtfimvig' value="">
			<br>
				<label for='qtpreseg'>Qtd. Prest. Pagas:</label>
				<input type="text" name='qtpreseg' id='qtpreseg'>

				<label for='dtcancel' class='not'>Cancelado em:</label>
				<td ><input type="text" name='dtcancel' id='dtcancel'>
			<br>
				<label for='vlprepag'>Total Pago:</label>
				<input type="text" name='vlprepag' id='vlprepag'>
                
                <?php 
                //Tratamento para seguro de vida, solicitar o dia para os proximos debitos
                // quando cadastrar novo
                
                if ($tipo == 3 and $operacao == 'TI') { 
                  
				  echo "<label for='ddvencto' class='not'>Dia Proximos Débitos:</label>
                        <input type='number' value='".$data[0]."' name='ddvencto' id='ddvencto'>";
                } else {
                  
                  echo "<label for='dtdebito' class='not'>Proximo Débito:</label>
                        <input type='text' name='dtdebito' id='dtdebito'>";
                } 
                ?>
			<br>
				<label for='dscobert'>Cobertura:</label>
				<input type="text" name='dscobert' id='dscobert'>
		
				<label for='tpplaseg' class='not'>Plano:</label>
				<input type="text" id='tpplaseg' value='000' name='tpplaseg'  >
			<br>
			<?php 
                // Exibir campo Contrato apenas para Prestamista
                if ($tipo == 4) { ?>
                	<label for='nrctrato'>Contrato:</label>
					<input type="text" name='nrctrato' id='nrctrato'>
					<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
					<br>
            <? } ?>
			<fieldset>
				<legend>Beneficiarios</legend>					
						<?php for($i = 1; $i <= 5; $i++){?>
								<label class='not'>Beneficiario</label>
								<input type='text' name='nmbenefi_<?php echo $i?>' id='nmbenefi_<?php echo $i?>'>
								
								<label class='not parent' for='dsgraupr_<?php echo $i?>' >Parentesco</label>
								<input type='text' name='dsgraupr_<?php echo $i?>' id='dsgraupr_<?php echo $i?>' >
								
								<label class='not parent' for='txpartic_<?php echo $i?>'> %Part</label>
								<input type='text' name='txpartic_<?php echo $i?>' id='txpartic_<?php echo $i?>' >					
						<?php }?>
				</fieldset>
				
			<label for='pesquisa' class='not'>Pesquisa:</label>
			<input id='pesquisa' value=''>
			<label for='dssitseg' class='not'>Situação:</label>
			<input id='dssitseg' value=''>
</form>
<br />
<div id="divBotoes">
	<input type="image" id="btVoltar"    src="<? echo $UrlImagens; ?>botoes/voltar.gif"   />
	<input type="image" id="btContinuar"   src="<? echo $UrlImagens; ?>botoes/continuar.gif" />
	
</div>
<!-- Caso for prestamista, chamar função para a lupa tratar a lupa do contrato -->
<? if($tipo == 4){ ?>
	<script type="text/javascript">
		controlaPesquisas('TI');
	</script>
<? } ?> 