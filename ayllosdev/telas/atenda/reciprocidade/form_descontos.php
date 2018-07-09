<?php
/*************************************************************************
	Fonte: principal.php
	Autor: Gabriel						Ultima atualizacao: 27/03/2017
	Data : Dezembro/2010
	
	Objetivo: Listar os convenios de cobranca.
	
	Alteracoes: 19/05/2011 - Mostrar Cob Registrada (Guilherme).

				14/07/2011 - Alterado para layout padrão (Gabriel - DB1)
				
				10/05/2013 - Retirado campo de valor maximo do boleto. 
						     vllbolet (Jorge)

				19/09/2013 - Inclusao do campo Convenio Homologado (Carlos)
				
				28/04/2015 - Incluido campos cooperativa emite e expede e
							 cooperado emite e expede. (Reinert)

				30/09/2015 - Ajuste para inclusão das novas telas "Produtos"
						    (Gabriel - Rkam -> Projeto 217).
						  
                24/11/2015 - Inclusao do indicador de negativacao pelo Serasa.
                             (Jaison/Andrino)

				18/02/2016 - PRJ 213 - Reciprocidade. (Jaison/Marcos)

                28/04/2016 - PRJ 318 - Ajustes projeto Nova Plataforma de cobrança (Odirlei/AMcom)

				25/07/2016 - Corrigi a inicializacao da variavel $emails_titular 
							 e o retorno de erro do XML de dados.SD 479874 (Carlos R.)

				04/08/2016 - Adicionado campo de forma de envio de arquivo de cobrança. (Reinert)

				13/12/2016 - PRJ340 - Nova Plataforma de Cobranca - Fase II. (Jaison/Cechet)  

                27/03/2017 - Adicionado botão "Dossiê DigiDOC". (Projeto 357 - Reinert)

*************************************************************************/

session_start();
	
// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es
require_once("../../../includes/config.php");
require_once("../../../includes/funcoes.php");		
require_once("../../../includes/controla_secao.php");

// Verifica se tela foi chamada pelo m&eacute;todo POST
isPostMethod();	
		
// Classe para leitura do xml de retorno
require_once("../../../class/xmlfile.php");

// Carrega permissões do operador
include("../../../includes/carrega_permissoes.php");	


// Monta o xml para a requisicao
$xml  = "";
$xml .= "<Root>";
$xml .= " <Dados>";
$xml .= "   <nmdominio>TPMESES_RECIPRO</nmdominio>";
$xml .= " </Dados>";     
$xml .= "</Root>";

// Executa script para envio do XML
$xmlResult = mensageria($xml, "TELA_ATENDA_COBRAN", "BUSCA_DOMINIO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

$meses = $xmlObj->roottag->tags[0]->tags;

// Se ocorrer um erro, mostra crítica
if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
	exibeErro(utf8_encode($msgErro));
}

// Monta o xml para a requisicao
$xml  = "";
$xml .= "<Root>";
$xml .= " <Dados>";
$xml .= "   <nmdominio>TPFLOATING_RECIPR</nmdominio>";
$xml .= " </Dados>";     
$xml .= "</Root>";

// Executa script para envio do XML
$xmlResult = mensageria($xml, "TELA_ATENDA_COBRAN", "BUSCA_DOMINIO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

$floats = $xmlObj->roottag->tags[0]->tags;

// Se ocorrer um erro, mostra crítica
if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
	exibeErro(utf8_encode($msgErro));
}

?>
<div id="divConveniosRegistros">
	<div class="divRegistros">
		<table style="table-layout: fixed;">
			<thead>
				<tr><th>C&ocirc;nvenio</th>
					<th>&nbsp;</th>
				</tr>			
			</thead>
			<tbody>
				<tr>
					<td width="60%">XXX002</td>
					<td width="40%">
						<img src="<?php echo $UrlImagens; ?>icones/ico_editar.png" onClick="return false;" border="0" style="margin-right:5px;width:12px" title="Editar Conv&ecirc;nio"/>
						<img src="<?php echo $UrlImagens; ?>geral/excluir.gif" onClick="return false;" border="0" title="Excluir Conv&ecirc;nio"/>
					</td>
				</tr>
				<tr>
					<td width="60%">XXX004</td>
					<td width="40%">
						<img src="<?php echo $UrlImagens; ?>icones/ico_editar.png" onClick="return false;" border="0" style="margin-right:5px;width:12px" title="Editar Conv&ecirc;nio"/>
						<img src="<?php echo $UrlImagens; ?>geral/excluir.gif" onClick="return false;" border="0" title="Excluir Conv&ecirc;nio"/>
					</td>
				</tr>
			</tbody>		
		</table>
	</div>
</div>
<div align="center">
	<a href="#" class="botao" style="float:none; padding: 3px 6px; margin: 15px 0" id="btnConveniosCobranca" onClick="return false;">Conv&ecirc;nios de Cobran&ccedil;a</a>
</div>
<table width="100%" class="tabelaDesconto">
	<tr class="corPar">
		<td width="60%">Boletos liquidados</td>
		<td align="right" width="40%">
			<span>Qtd</span>
			<input name="" id="" class="campo inteiro" value="" />
		</td>
	</tr>
	<tr class="corImpar">
		<td>Volume liquida&ccedil;&atilde;o</td>
		<td align="right">
			<span>R$</span>
			<input name="" id="" class="campo valor" value="" />
		</td>
	</tr>
	<tr class="corPar">
		<td>Floating</td>
		<td align="right">
			<select class="campo">
			<?php foreach($floats as $floating) {
				echo '<option value="' . getByTagName($floating->tags,"cddominio") . '">' . getByTagName($floating->tags,"dscodigo") . '</option>';
			} ?>
			</select>
		</td>
	</tr>
	<tr class="corImpar">
		<td>Vincula&ccedil;&atilde;o</td>
		<td align="right">
			<input name="" id="" class="campo campoTelaSemBorda" disabled value="" />
		</td>
	</tr>
	<tr class="corPar">
		<td>Aplica&ccedil;&otilde;es</td>
		<td align="right">
			<span>R$</span>
			<input name="" id="" class="campo inteiro" value="" />
		</td>
	</tr>
	<tr class="corImpar">
		<td>Data fim do contrato</td>
		<td align="right">
			<select class="campo">
			<?php foreach($meses as $mes) {
				echo '<option value="' . getByTagName($mes->tags,"cddominio") . '">' . getByTagName($mes->tags,"dscodigo") . '</option>';
			} ?>
			</select>
		</td>
	</tr>
	<tr class="corPar">
		<td>D&eacute;bito reajuste da tarifa</td>
		<td align="right">
			<input name="" id="" class="campo valor" value="" />
		</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
	</tr>
	<tr class="corImpar">
		<td>Desconto concedido COO</td>
		<td align="right">
			<span>%</span>
			<input name="" id="" class="campo campoTelaSemBorda" disabled value="" />
		</td>
	</tr>
	<tr class="corPar">
		<td>Desconto concedido CEE</td>
		<td align="right">
			<span>%</span>
			<input name="" id="" class="campo campoTelaSemBorda" disabled value="" />
		</td>
	</tr>
	<tr class="corImpar">
		<td>Tarifa reciprocidade COO</td>
		<td align="right">
			<span>R$</span>
			<input name="" id="" class="campo campoTelaSemBorda" disabled value="" />
		</td>
	</tr>
	<tr class="corPar">
		<td>Tarifa reciprocidade CEE</td>
		<td align="right">
			<span>R$</span>
			<input name="" id="" class="campo campoTelaSemBorda" disabled value="" />
		</td>
	</tr>
</table>
<fieldset style="border:1px solid #777777; margin:5px 3px 0;padding:3px">
	<legend align="left">Desconto adicional</legend>
	<table width="100%" class="tabelaDesconto">
		<tr class="corPar">
			<td width="60%">Desconto adicional COO</td>
			<td align="right" width="40%">
				<span>R$</span>
				<input name="" id="" class="campo valor" value="" />
			</td>
		</tr>
		<tr class="corImpar">
			<td>Data fim desc. Adicional COO</td>
			<td align="right">
				<input name="" id="" class="campo data" value="" />
			</td>
		</tr>
		<tr class="corPar">
			<td>Desconto adicional CEE</td>
			<td align="right">
				<input name="" id="" class="campo valor" value="" />
			</td>
		</tr>
		<tr class="corImpar">
			<td>Data fim desc. Adicional CEE</td>
			<td align="right">
				<input name="" id="" class="campo data" value="" />
			</td>
		</tr>
	</table>
</fieldset>
<fieldset style="border:1px solid #777777; margin:5px 3px 0;padding:3px">
	<legend align="left">Desconto adicional</legend>
	<table width="100%" class="tabelaDesconto">
		<tr>
			<td width="60%">&nbsp;</td>
			<td width="40%">&nbsp;</td>
		</tr>
		<tr class="corPar">
			<td>Tarifa negociada COO</td>
			<td align="right">
				<span>R$</span>
				<input name="" id="" class="campo valor" value="" />
			</td>
		</tr>
		<tr class="corImpar">
			<td>Tarifa negociada CEE</td>
			<td align="right"
				<span>R$</span>
				<input name="" id="" class="campo data" value="" />
			</td>
		</tr>
	</table>
</fieldset>
<fieldset style="border:1px solid #777777; margin:5px 3px 0;padding:3px">
	<legend align="left">Justificativa desconto adicional:</legend>
	<table width="100%" class="tabelaDesconto">
		<tr class="corPar">
			<td>
				<textarea class="textarea" style="width: 100%;min-height: 70px;"></textarea>
			</td>
		</tr>
	</table>
</fieldset>


<div id="divBotoes" style="margin:5px">
    <a href="#" class="botao" <? if (in_array("C",$glbvars["opcoesTela"])) { ?> onClick="consulta('C','','','true','','');return false;" <? } else { ?> style="cursor: default;" <? } ?> >Continuar</a>
    <a href="#" class="botao" onclick="carregaLogCeb(); return false;">Solicitar aprova&ccedil;&atilde;o</a>
    <a href="#" class="botao" onclick="consulta('A','','','true','','');return false;">Tarifas instru&ccedil;&atilde;o</a>
	<a href="#" class="botao" onclick="encerraRotina(true); return false;">Voltar</a>
</div>

<script type="text/javascript">

controlaLayout('divConveniosRegistros');

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));

// Se a tela foi chamada pela rotina "Produtos" então acessa a opção "Habilitar".
(executandoProdutos == true) ? consulta('S','','','true','','') : '';

//$('.inteiro').setMask('INTEGER', 'zzz.zzz.zzz', '.', '');
$('.valor').setMask('DECIMAL', 'zz.zzz.zz9,99', '.', '');
$('.inteiro').setMask('DECIMAL', 'zz.zzz.zzz', '.', '');

</script>
