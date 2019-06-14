<?php
	/*!
	 * FONTE        : busca_emails.php
	 * CRIAÇÃO      : Mateus Zimmermann - Mouts
	 * DATA CRIAÇÃO : 27/08/2018
	 * OBJETIVO     : Rotina para buscar os parametroEmails de emails da proposta
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
	
	$xmlResult = mensageria($xml, "TELA_TAB089", "BUSCA_EMAIL_PROPOSTA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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

	$parametrosEmail = $xmlObj->roottag->tags;

?>
<fieldset style="margin-top: 10px">
	<legend> <? echo utf8ToHtml('Parâmetros do E-mail'); ?> </legend>
	<div class="divRegistros">	
		<table class="tituloRegistros" id="tbFases">
			<thead>
				<tr>
					<th>Tipo Produto</th>
					<th>Periodicidade</th>
					<th>Qt. Envios</th>
					<th>Assunto</th>
					<th>Ativo</th>
				</tr>
			</thead>
			<tbody>
				<? foreach($parametrosEmail as $parametroEmail){?>
					<tr>					
						<td><? echo getByTagName($parametroEmail->tags,'dsproduto'); ?></td>
						<td><? echo getByTagName($parametroEmail->tags,'qt_periodicidade'); ?></td>
						<td><? echo getByTagName($parametroEmail->tags,'qt_envio'); ?></td>
						<td><? echo stringTabela(getByTagName($parametroEmail->tags,'ds_assunto'),32,'primeira'); ?></td>
						<td><? echo getByTagName($parametroEmail->tags,'idativo') == 1 ? 'Sim' : 'N&atilde;o';?></td>

						<input type="hidden" id="htpproduto" value="<? echo getByTagName($parametroEmail->tags,'tpproduto') ?>"/>
						<input type="hidden" id="hqt_periodicidade" value="<? echo getByTagName($parametroEmail->tags,'qt_periodicidade') ?>"/>
						<input type="hidden" id="hqt_envio" value="<? echo getByTagName($parametroEmail->tags,'qt_envio') ?>"/>
						<input type="hidden" id="hds_assunto" value="<? echo getByTagName($parametroEmail->tags,'ds_assunto') ?>"/>
						<input type="hidden" id="hds_corpo" value="<? echo getByTagName($parametroEmail->tags,'ds_corpo') ?>"/>
						<input type="hidden" id="hidativo" value="<? echo getByTagName($parametroEmail->tags,'idativo') ?>"/>

					</tr>
				<? } ?>              
			</tbody>
		</table>
	</div>
</fieldset>			

<div id="divBotoes" name="divBotoes" style="margin-bottom:5px">
	<a href="#" class="botao" id="btVoltar"  onClick="acessaAbaEmail(); return false;">Voltar</a>
	<a href="#" class="botao" id="btConsultar"  onClick="mostraTelaAlterarEmails(); return false;">Consultar</a>
	<a href="#" class="botao" id="btProsseguir"  onClick="mostraTelaAlterarEmails(); return false;">Prosseguir</a>
</div>
