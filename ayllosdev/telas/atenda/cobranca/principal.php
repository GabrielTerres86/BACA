<?php
/*************************************************************************
	Fonte: principal.php
	Autor: Gabriel						Ultima atualizacao: 25/07/2016
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


// Monta o xml para a requisicao
$xmlGetDadosCobranca  = "";
$xmlGetDadosCobranca .= "<Root>";
$xmlGetDadosCobranca .= " <Cabecalho>";
$xmlGetDadosCobranca .= "   <Bo>b1wgen0082.p</Bo>";
$xmlGetDadosCobranca .= "   <Proc>carrega-convenios-ceb</Proc>";
$xmlGetDadosCobranca .= " </Cabecalho>";
$xmlGetDadosCobranca .= " <Dados>";
$xmlGetDadosCobranca .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>"; 
$xmlGetDadosCobranca .= "   <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
$xmlGetDadosCobranca .= "   <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
$xmlGetDadosCobranca .= "   <cdoperad>".$glbvars["cdoperad"]."</cdoperad>"; 
$xmlGetDadosCobranca .= "   <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
$xmlGetDadosCobranca .= "   <idorigem>".$glbvars["idorigem"]."</idorigem>";           
$xmlGetDadosCobranca .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xmlGetDadosCobranca .= "   <idseqttl>1</idseqttl>";         
$xmlGetDadosCobranca .= "   <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
$xmlGetDadosCobranca .= " </Dados>";      
$xmlGetDadosCobranca .= "</Root>";   

// Executa script para envio do XML
$xmlResult = getDataXML($xmlGetDadosCobranca);

// Cria objeto para classe de tratamento de XML
$xmlObjDadosCobranca = getObjectXML($xmlResult);


// Se ocorrer um erro, mostra cr&iacute;tica
if (isset($xmlObjDadosCobranca->roottag->tags[0]->name) && strtoupper($xmlObjDadosCobranca->roottag->tags[0]->name) == "ERRO") {
	exibeErro($xmlObjDadosCobranca->roottag->tags[0]->tags[0]->tags[4]->cdata);
} 

// Seta a tag de convenios para a variavel
$convenios = $xmlObjDadosCobranca->roottag->tags[0]->tags;
// Titulares , valor maximo de emissao de boleto
$titulares = $xmlObjDadosCobranca->roottag->tags[1]->tags;
// Emails
$emails = $xmlObjDadosCobranca->roottag->tags[2]->tags;
// Mensagem, caso o cooperado tenha o internet Banking nao liberada 
$dsdmesag = $xmlObjDadosCobranca->roottag->tags[2]->attributes["DSDMESAG"];
// Contem a quantidade de titulares a atualizar emissao de boleto
$qtTitulares = count($titulares);

// Concatena os titulares e seus valores de emissao de boleto
foreach ($titulares as $titular) {		
	 $tit_valores  = ($tit_valores ==  "") ? "" : $tit_valores . "|";
     $tit_valores .= $titular->tags[0]->cdata . ";" . $titular->tags[1]->cdata . ";" . number_format(str_replace(",",".",$titular->tags[2]->cdata),2,",",".");	 
} 

$emails_titular = '';

// Concatena todos os emails do cooperado
foreach($emails as $email) {
   $emails_titular  = ($emails_titular == '') ? '' : $emails_titular . '|';
   $emails_titular .= $email->tags[0]->cdata . ',' . $email->tags[1]->cdata;
}

// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
function exibeErro($msgErro) {
	echo '<script type="text/javascript">';
	echo 'hideMsgAguardo();';
	echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
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
					<th>Conv&ecirc;nio</th>
					<th>Origem</th>
					<th>Sit.Conv.</th>
					<th>CEB</th>
					<th>Sit.Cob.</th>
					<th>Regist.</th>
				</tr>			
			</thead>
			<tbody>
				<?  for ($i = 0; $i < count($convenios); $i++) {					   
					   
					   $nrconven =  getByTagName($convenios[$i]->tags,'nrconven');   
					   $dsorgarq =  getByTagName($convenios[$i]->tags,'dsorgarq'); 
                       $insitceb =  getByTagName($convenios[$i]->tags,'insitceb'); 
					   $flgativo = (getByTagName($convenios[$i]->tags,'flgativo') == "yes") ? "ATIVO" : "INATIVO";
					   $nrcnvceb =  getByTagName($convenios[$i]->tags,'nrcnvceb');
					   $dtcadast =  getByTagName($convenios[$i]->tags,'dtcadast');
					   $cdoperad =  getByTagName($convenios[$i]->tags,'cdoperad');		
					   $inarqcbr =  getByTagName($convenios[$i]->tags,'inarqcbr');
					   $cddemail =  getByTagName($convenios[$i]->tags,'cddemail');
  					   $dsdemail =  getByTagName($convenios[$i]->tags,'dsdemail');
					   $flgcruni =  (getByTagName($convenios[$i]->tags,'flgcruni') == "yes") ? "SIM" : "NAO";
					   $flgcebhm =  (getByTagName($convenios[$i]->tags,'flgcebhm') == "yes") ? "SIM" : "NAO";
					   $flgregis =  (getByTagName($convenios[$i]->tags,'flgregis') == "yes") ? "SIM" : "NAO";
					   $flcooexp =  (getByTagName($convenios[$i]->tags,'flcooexp') == "yes") ? "SIM" : "NAO";
					   $flceeexp =  (getByTagName($convenios[$i]->tags,'flceeexp') == "yes") ? "SIM" : "NAO";
					   $cddbanco =  getByTagName($convenios[$i]->tags,'cddbanco');
                       $flserasa =  (getByTagName($convenios[$i]->tags,'flserasa') == "yes") ? "SIM" : "NAO";
                       $flsercco =  getByTagName($convenios[$i]->tags,'flsercco');
					   $qtdfloat =  getByTagName($convenios[$i]->tags,'qtdfloat');		
					   $flprotes =  (getByTagName($convenios[$i]->tags,'flprotes') == "yes") ? "SIM" : "NAO";
					   $qtdecprz =  getByTagName($convenios[$i]->tags,'qtdecprz');
  					   $idrecipr =  getByTagName($convenios[$i]->tags,'idrecipr');
						
                       $mtdClick = "selecionaConvenio( '".$i."', '".$nrconven."','".$dsorgarq."','".$nrcnvceb."','".$insitceb."','".$dtcadast."','".$cdoperad."','".$inarqcbr."','".$cddemail."' ,'".$dsdemail."','".$flgcruni."','".$flgcebhm."','".$flgregis."','".$flcooexp."','".$flceeexp."','".$cddbanco."','".$flserasa."','".$flsercco."','".$qtdfloat."','".$flprotes."','".$qtdecprz."','".$idrecipr."');";
					?>
					<tr id="convenio<?php echo $i; ?>" onFocus="<? echo $mtdClick; ?>" onClick="<? echo $mtdClick; ?>">
						
						<td><span><? echo $nrconven;?></span>
							<?php echo formataNumericos("zz.zzz.zz9",$nrconven,'.');  ?> </td>  
							
						<td> <?php echo $dsorgarq; ?> </td>
						
						<td> <?php echo $flgativo; ?> </td>
						
						<td><span><? echo $nrcnvceb; ?></span>
							<?php echo formataNumericos("z,zz9",$nrcnvceb); ?> </td>
							
						<td> <?php 
                                   switch ($insitceb) {
                                       case 1:
                                             echo "ATIVO";
                                             break;
                                       case 2:
                                             echo "INATIVO";
                                             break;
                                       case 3:
                                             echo "PENDENTE";
                                             break;
                                       case 4:
                                             echo "BLOQUEADO";
                                             break;
                                       case 5:
                                             echo "APROVADO";
                                             break;
                                       case 6:
                                             echo utf8ToHtml('NÃO APROVADO');
                                             break;      
                                    } ?> </td>
						
						<td> <?php echo $flgregis ?> </td>
						
				    </tr>
				<?} // Fim do for ?>			
			</tbody>
		</table>
	</div>
</div>


<ul class="complemento">
<li><? echo utf8ToHtml('Última Alt.:') ?></li>
<li id="dtcadast"></li>
<li><? echo utf8ToHtml('Operador:') ?></li>
<li id="cdoperad"></li>
</ul>


<div id="divBotoes">
	<input type="hidden" id= "dsdmesag"    name="dsdmesag" value="<?php echo $dsdmesag; ?>">
	<input type="hidden" id= "qtconven"    name="qtconven" value="<?php echo count($convenios); ?>">
	<input type="hidden" id= "nrconven"    name="nrconven">
	<input type="hidden" id= "dsorgarq"    name="dsorgarq">
	<input type="hidden" id= "nrcnvceb"    name="nrcnvceb">
    <input type="hidden" id= "insitceb"    name="insitceb">
	<input type="hidden" id= "inarqcbr"    name="inarqcbr">
	<input type="hidden" id= "cddemail"    name="cddemail">
	<input type="hidden" id= "dsdemail"    name="dsdemail">
	<input type="hidden" id= "flgcruni"    name="flgcruni">
	<input type="hidden" id= "flgcebhm"    name="flgcebhm">
	<input type="hidden" id= "flgregis"    name="flgregis">
	<input type="hidden" id= "flcooexp"    name="flcooexp">
	<input type="hidden" id= "flceeexp"    name="flceeexp">
    <input type="hidden" id= "flserasa"    name="flserasa">
    <input type="hidden" id= "flseralt"    name="flseralt" value="0">
	<input type="hidden" id= "flposbol"    name="flposbol">
	<input type="hidden" id= "cddbanco"    name="cddbanco">
	<input type="hidden" id= "qtTitulares" name="qtTitulares" value="<?php echo $qtTitulares; ?>">
	<input type="hidden" id= "titulares"   name="titulares"   value="<?php echo $tit_valores; ?>">
	<input type="hidden" id= "emails_titular" name="emails_titular" value="<?php echo $emails_titular; ?>">
	<input type="hidden" id= "qtdfloat"    name="qtdfloat">
	<input type="hidden" id= "flprotes"    name="flprotes">
	<input type="hidden" id= "qtdecprz"    name="qtdecprz">
	<input type="hidden" id= "idrecipr"    name="idrecipr">

	<input type="image" src="<?php echo $UrlImagens; ?>botoes/cancelamento.gif"   <? if (in_array("X",$glbvars["opcoesTela"])) { ?> onClick="confirmaExclusao();return false;" <? } else { ?> style="cursor: default;" <? } ?> />
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/consultar.gif" <? if (in_array("C",$glbvars["opcoesTela"])) { ?> onClick="consulta('C','','','false','','');return false;" <? } else { ?> style="cursor: default;" <? } ?> />
    <input type="image" src="<?php echo $UrlImagens; ?>botoes/incluir.gif" <? if (in_array("H",$glbvars["opcoesTela"])) { ?> onClick="consulta('S','','','true','','');return false;" <? } else { ?> style="cursor: default;" <? } ?> />
    <input type="image" src="<?php echo $UrlImagens; ?>botoes/alterar.gif" <? if (in_array("H",$glbvars["opcoesTela"])) { ?> onClick="consulta('A','','','false','','');return false;" <? } else { ?> style="cursor: default;" <? } ?> />
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/impressao.gif" onClick="confirmaImpressao('','1');return false;" />
    <input type="image" src="<?php echo $UrlImagens; ?>botoes/log.gif" onClick="carregaLogCeb();return false;" />
    <input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="encerraRotina(true);return false;" />
	
	<input type="hidden" id= "flsercco"    name="flsercco">
	
</div>

<script type="text/javascript">

controlaLayout('divResultado');

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));

// Se a tela foi chamada pela rotina "Produtos" então acessa a opção "Habilitar".
(executandoProdutos == true) ? consulta('S','','','true','','') : '';

</script>