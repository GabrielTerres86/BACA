<?php
	/*!
	 * FONTE        : busca_motivos.php
	 * CRIAÇÃO      : Lucas Reinert
	 * DATA CRIAÇÃO : 20/09/2017
	 * OBJETIVO     : Rotina para buscar os motivos de desligamento
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
	
	$xmlResult = mensageria($xml, "TELA_CADMDE", "BUSCA_MOTIVOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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

?>

<div class="divRegistros">	
	<table class="tituloRegistros" id="tbMotivos">
		<thead>
			<tr>
				<th>C&oacute;digo</th>
				<th>Motivo</th>
				<th>Pessoa F&iacute;sica</th>
				<th>Pessoa Jur&iacute;dica</th>
				<th>Tipo</th>
			</tr>
		</thead>
		<tbody>
			<?
			if (count($xmlObj->roottag->tags) == 0){
			?>
				<tr>
					<td>
						Motivos n&atilde;o cadastrados
					</td>
				</tr>
			<?
			}else{
				foreach($xmlObj->roottag->tags as $motivo){
					$aux_cdmotivo = $motivo->tags[0]->cdata; // Cód. Motivo
					$aux_dsmotivo = $motivo->tags[1]->cdata; // Desc. Motivo
					$aux_flgpessf = $motivo->tags[2]->cdata; // Flag pessoa física
					$aux_flgpessj = $motivo->tags[3]->cdata; // Flag pessoa jurídica
					$aux_tpmotivo = $motivo->tags[4]->cdata; // Tipo
					$aux_dstpmotv = $motivo->tags[5]->cdata; // Descrição do tipo de motivos
					?>
					<tr>					
						<td><span><? echo $aux_cdmotivo ?></span><? echo $aux_cdmotivo ?></td>
						<td><span><? echo $aux_dsmotivo ?></span><? echo $aux_dsmotivo ?></td>
						<td><span><? echo $aux_flgpessf ?></span><b><? if ($aux_flgpessf == 1){ echo '&check;'; }?></b></td>
						<td><span><? echo $aux_flgpessj ?></span><b><? if ($aux_flgpessj == 1){ echo '&check;'; }?></b></td>
						<td><span><? echo $aux_dstpmotv ?></span><? echo $aux_dstpmotv ?></td>
						
						<input type="hidden" id="hcdmotivo" value="<? echo $aux_cdmotivo ?>"/>
						<input type="hidden" id="hdsmotivo" value="<? echo $aux_dsmotivo ?>"/>
						<input type="hidden" id="hflgpessf" value="<? echo $aux_flgpessf ?>"/>
						<input type="hidden" id="hflgpessj" value="<? echo $aux_flgpessj ?>"/>
						<input type="hidden" id="htpmotivo" value="<? echo $aux_tpmotivo ?>"/>

					</tr>
				<?
				}
			}?>                
		</tbody>
	</table>
</div>						