<?php
/*************************************************************************
	Fonte: principal.php
	Autor: Augusto (Supero)				Ultima atualizacao: 09/07/2018
	Data : Julho/2018
	
	Objetivo: Listar os contratos de reciprocidade.
	
	Alteracoes: 

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
	
		
// Se par&acirc;metros necess&aacute;rios n&atilde;o foram informados
if (!isset($_POST["nrdconta"])) {
	exibeErro("Par&acirc;metros incorretos.");
}	
	
$nrdconta = $_POST["nrdconta"];

// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
if (!validaInteiro($nrdconta)) {
	exibeErro("Conta/dv inv&aacute;lida.");

}

// Carrega permissões do operador
include("../../../includes/carrega_permissoes.php");	
	
setVarSession("opcoesTela",$opcoesTela);

$xml  = "";
$xml .= "<Root>";
$xml .= " <Dados>";	
$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "TELA_ATENDA_COBRAN", "BUSCA_CONTRATOS_ATENDA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObjeto = getObjectXML($xmlResult);

if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO' ) {
	
   $msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
    if ($msgErro == "") {
        $msgErro = $xmlObjeto->roottag->tags[0]->cdata;
    }

    exibeErro($msgErro);
}
$contratos = $xmlObjeto->roottag->tags[0]->tags;

// Montar o xml de Requisicao de verificacao do serviço de SMS
$xml = new XmlMensageria();
$xml->add('nrdconta',$nrdconta);
$xmlResult = mensageria($xml, "ATENDA",'VERIF_SERV_SMS_COBRAN', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObject = getObjectXML($xmlResult);
$xmlDados  = $xmlObject->roottag->tags[0];

if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO") {

   $msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
    if ($msgErro == "") {
        $msgErro = $xmlObject->roottag->tags[0]->cdata;
    }

    exibeErro($msgErro);
    exit();
}

$flsitsms = getByTagName($xmlDados->tags,"flsitsms");
$dsalerta = getByTagName($xmlDados->tags,"dsalerta");
$convenio_ativo = 0;

// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
function exibeErro($msgErro) {
	echo '<script type="text/javascript">';
	echo 'hideMsgAguardo();';
	echo 'showError("error","'.addslashes($msgErro).'","Alerta - Ayllos","blockBackground(parseInt($(\"#divRotina\").css(\"z-index\")))");';
	echo '</script>';
	exit();
}
	
?>
<?/**/?>
<div id="divResultado">
	<div class="divRegistros">
		<table>
			<thead>
				<tr>
					<th>Conv&ecirc;nios ativos</th>
					<th>Negocia&ccedil;&atilde;o das tarifas</th>
					<th>Data de solicita&ccedil;&atilde;o</th>
					<th>Data da &uacute;ltima aprova&ccedil;&atilde;o</th>
					<th>Data do in&iacute;cio do contrato</th>
					<th>Fim desconto adicional</th>
					<th>Fim da reciprocidade</th>
				</tr>
			</thead>
			<tbody>
				<?  for ($i = 0; $i < count($contratos); $i++) {
					$convenios = getByTagName($contratos[$i]->tags, 'list_cnv');
					if (strpos($convenios, ',') !== false) {
						$conveniosHtml = str_replace(',', '<br>', $convenios);
					} else {
						$conveniosHtml = $convenios;
					}
					$dtcadast = getByTagName($contratos[$i]->tags, 'dtcadast');
					$idrecipr = getByTagName($contratos[$i]->tags, 'idrecipr');					
					$dtultaprov = getByTagName($contratos[$i]->tags, 'dtultaprov');
					$insitceb = getByTagName($contratos[$i]->tags, 'insitceb');
					$dtinivig = getByTagName($contratos[$i]->tags, 'dtinivig');
					$dtfimvig = getByTagName($contratos[$i]->tags, 'dtfimvig');
					$status = getByTagName($contratos[$i]->tags, 'status');
					$dtfimdesc = getByTagName($contratos[$i]->tags, 'dtfimdesc');
					$insitapr = getByTagName($contratos[$i]->tags, 'insitapr');

					// Verificar se existe algum convenio ativo(insitceb == 1)
					if ($insitceb == 1 && $convenio_ativo == 0 ){
						$convenio_ativo = $insitceb;
					}
					$mtdClick = "selecionaConvenio(this, '".$idrecipr."', '".$insitceb."', '".$convenios."');";
				?>
					<tr class="dbclick" id="convenio<?php echo $i; ?>" onFocus="<? echo $mtdClick; ?>" onClick="<? echo $mtdClick; ?>" ondblclick="acessaOpcaoDescontos('<?php echo ($insitceb == 1 || $insitceb == 3) ? 'A' : 'C';?>');">
						
						<td>
							<input type="hidden" id="insitapr" value="<?php echo $insitapr; ?>">
							<? echo $conveniosHtml; ?>
						</td>
						<td><? echo "$status ($idrecipr)"; ?></td>
						<td><? echo $dtcadast; ?></td>
						<td><? echo !empty($dtultaprov) ? $dtultaprov : '-'; ?></td>
						<td><? echo !empty($dtinivig) ? $dtinivig : '-'; ?></td>
						<td><? echo !empty($dtfimdesc) ? $dtfimdesc : '-'; ?></td>
						<td><? echo !empty($dtfimvig) ? $dtfimvig : '-'; ?></td>
						
				    </tr>
				<?} // Fim do for ?>
			</tbody>
		</table>
	</div>
</div>

<div id="divBotoes">
	<input type="hidden" id="dsdmesag" name="dsdmesag" value="<?php echo $dsdmesag; ?>">
	<input type="hidden" id="idrecipr" name="idrecipr">
	<input type="hidden" id="insitceb" name="insitceb">
	<input type="hidden" id="convenios" name="convenios">
    
    <a href="#" class="botao" <? if (in_array("H",$glbvars["opcoesTela"])) { ?> onClick="acessaOpcaoDescontos('I');return false;" <? } else { ?> style="cursor: default;" <? }  ?> >Incluir</a>
	<a href="#" class="botao" <? if (in_array("C",$glbvars["opcoesTela"])) { ?> onClick="acessaOpcaoDescontos('C');return false;" <? } else { ?> style="cursor: default;" <? } ?> >Consultar</a>
	<a href="#" id="btnAlterarConvenio" class="botao" <? if (in_array("H",$glbvars["opcoesTela"])) { ?> onClick="acessaOpcaoDescontos('A');return false;" <? } else { ?> style="cursor: default;" <? } ?> >Alterar</a>
	<a href="#" class="botao" onclick="confirmaCancelarContrato(); return false;">Cancelar</a>
    <a href="#" class="botao" onclick="abrirAprovacao(false); return false;" id="btnAbrirAprovacao">Aprovar</a>
	<a href="#" class="botao" onclick="abrirRejeicao(); return false;" id="btnAbrirRejeicao">Rejeitar</a>
	<?php //Habilitar botão apenas se possuir cobrança ativa
          // e se o serviço estiver ativo ou com algum tipo de alerta
          // que significa que serviço esta ativo para coop porém possui algum alerta para o cooperado          
          if ($convenio_ativo == 1 && 
              ($flsitsms == 1 || $dsalerta != "")) { ?>
        		<a href="#" class="botao" onclick="consultaServicoSMS('C'); return false;">Servi&ccedil;o SMS</a>
	<?php  } ?>
	<a href="#" class="botao" onclick="confirmaImpressao('SIM','1'); return false;">Termo</a>    
    <a href="#" class="botao" onclick="carregaLogCeb();return false;">Hist. Acesso</a>
	<a href="#" class="botao" onclick="carregaLogNegociacao(); return false;">Hist. Negocia&ccedil;&atilde;o</a>
	<a href="#" class="botao" onclick="carregaCobranca(); return false;">Recip. Antigo</a>
	<a href="#" id="btSair"></a>
	
	<input type="hidden" id= "flsercco" name="flsercco">
	
</div>

<script type="text/javascript">

controlaLayout('divResultado');

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));

// Se a tela foi chamada pela rotina "Produtos" então acessa a opção "Habilitar".
(executandoProdutos == true) ? consulta('S','','',true,'','') : '';

</script>
