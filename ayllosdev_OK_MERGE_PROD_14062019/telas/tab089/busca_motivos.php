<?php
	/*!
	 * FONTE        : busca_motivos.php
	 * CRIAÇÃO      : Mateus Zimmermann - Mouts
	 * DATA CRIAÇÃO : 23/08/2018
	 * OBJETIVO     : Rotina para buscar os motivos de anulação
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
	
	$xmlResult = mensageria($xml, "TELA_TAB089", "BUSCA_MOTIVOS_ANULACAO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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

	$motivos = $xmlObj->roottag->tags;

?>
<fieldset style="margin-top: 10px">
	<legend> <? echo utf8ToHtml('Motivos Anulação'); ?> </legend>
	<div class="divRegistros">	
		<table class="tituloRegistros" id="tbFases">
			<thead>
				<tr>
					<th>Cod</th>
					<th>Motivo</th>
					<th>Tipo Produto</th>
					<th>Data</th>
					<th>Obs.</th>
					<th>Ativo</th>
				</tr>
			</thead>
			<tbody>
				<? foreach($motivos as $motivo){?>
					<tr>					
						<td><? echo getByTagName($motivo->tags,'cdmotivo') ?></td>
						<td><? echo getByTagName($motivo->tags,'dsmotivo'); ?></td>
						<td><? echo getByTagName($motivo->tags,'dsproduto'); ?></td>
						<td><? echo getByTagName($motivo->tags,'dtcadastro'); ?></td>
						<td><? echo getByTagName($motivo->tags,'inobservacao') == 1 ? 'Sim' : 'N&atilde;o';?></td>
						<td><? echo getByTagName($motivo->tags,'idativo') == 1 ? 'Sim' : 'N&atilde;o';?></td>

						<input type="hidden" id="hcdmotivo" value="<? echo getByTagName($motivo->tags,'cdmotivo') ?>"/>
						<input type="hidden" id="hdsmotivo" value="<? echo getByTagName($motivo->tags,'dsmotivo') ?>"/>
						<input type="hidden" id="htpproduto" value="<? echo getByTagName($motivo->tags,'tpproduto') ?>"/>
						<input type="hidden" id="hinobservacao" value="<? echo getByTagName($motivo->tags,'inobservacao') ?>"/>
						<input type="hidden" id="hidativo" value="<? echo getByTagName($motivo->tags,'idativo') ?>"/>

					</tr>
				<? } ?>              
			</tbody>
		</table>
	</div>
</fieldset>			

<div id="divBotoes" name="divBotoes" style="margin-bottom:5px">
	<a href="#" class="botao" id="btVoltar"  onClick="acessaAbaMotivos(); return false;">Voltar</a>
	<a href="#" class="botao" id="btProsseguir"  onClick="mostraTelaAlterarMotivos(); return false;">Prosseguir</a>
</div>
