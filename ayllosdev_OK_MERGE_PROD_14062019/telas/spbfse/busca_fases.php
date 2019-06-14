<?php
	/*!
	 * FONTE        : busca_fases.php
	 * CRIAÇÃO      : Mateus Zimmermann (Mouts)
	 * DATA CRIAÇÃO : 18/07/2018
	 * OBJETIVO     : Rotina para buscar as fases
	 * --------------
	 * ALTERAÇÕES   : 
	 * -------------- 
	 */		

    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();			
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],"C")) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
		
	// Montar o xml de Requisicao
	$xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_SPBFSE", "BUSCA_TBSPB_FASE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);		
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		if($msgErro == null || $msgErro == ''){
			$msgErro = utf8_encode($xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata);
		}
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
		exit();
	}

	$fases = $xmlObj->roottag->tags;

?>

<div class="divRegistros">	
	<table class="tituloRegistros" id="tbFases">
		<thead>
			<tr>
				<th>C&oacute;digo</th>
				<th>Nome Fase</th>
				<th>Fase Controlada</th>
				<th>Ativo</th>
				<th>Fase Anterior</th>
			</tr>
		</thead>
		<tbody>
			<?
			if (count($fases) == 0){
			?>
				<tr style="text-align: center !important">
					<td>Fases n&atilde;o cadastradas</td>
				</tr>
			<?
			}else{
				foreach($fases as $fase){
					?>
					<tr>					
						<td><? echo getByTagName($fase->tags,'cdfase') ?></td>
						<td><? echo stringTabela(getByTagName($fase->tags,'nmfase'),28,'maiuscula'); ?></td>
						<td><b><? if (getByTagName($fase->tags,'idfase_controlada') == 1){ echo '&check;'; }?></b></td>
						<td><b><? if (getByTagName($fase->tags,'idativo') == 1){ echo '&check;'; }?></b></td>
						<td><? echo stringTabela(getByTagName($fase->tags,'nmfaseanterior'),18,'maiuscula'); ?></td>
						
						<input type="hidden" id="hcdfase" value="<? echo getByTagName($fase->tags,'cdfase') ?>"/>
						<input type="hidden" id="hnmfase" value="<? echo getByTagName($fase->tags,'nmfase') ?>"/>
						<input type="hidden" id="hidfase_controlada" value="<? echo getByTagName($fase->tags,'idfase_controlada') ?>"/>
						<input type="hidden" id="hcdfase_anterior" value="<? echo getByTagName($fase->tags,'cdfase_anterior') ?>"/>
						<input type="hidden" id="hqttempo_alerta" value="<? echo getByTagName($fase->tags,'qttempo_alerta') ?>"/>
						<input type="hidden" id="hqtmensagem_alerta" value="<? echo getByTagName($fase->tags,'qtmensagem_alerta') ?>"/>
						<input type="hidden" id="hidativo" value="<? echo getByTagName($fase->tags,'idativo') ?>"/>
						<input type="hidden" id="hidconversao" value="<? echo getByTagName($fase->tags,'idconversao') ?>"/>
						<input type="hidden" id="hdtultima_execucao" value="<? echo getByTagName($fase->tags,'dtultima_execucao') ?>"/>
						<input type="hidden" id="hidreprocessa_mensagem" value="<? echo getByTagName($fase->tags,'idreprocessa_mensagem') ?>"/>

					</tr>
				<?
				}
			}?>                
		</tbody>
	</table>
</div>						