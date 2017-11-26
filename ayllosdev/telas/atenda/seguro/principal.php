<?php
/*!
 * FONTE        : pricipal.php
 * CRIAÇÃO      : Marcelo Leandro Pereira
 * DATA CRIAÇÃO : 31/09/2011
 * OBJETIVO     : Mostrar opcao Principal da rotina de Seguro da tela ATENDA
 *
 * ALTERAÇÕES   : 25/07/2013 - Incluído o campo Complemento no endereço. (James).
 *
 *                22/06/2016 - Trazer os novos contratos de seguro adicionados a base de dados pela integração com o PROWEB.
 *                             Criação de nova tela de consulta para os seguros de vida. Projeto 333_1. (Lombardi)
 *
 *                29/08/2016 - Proj 187.2 - Sicredi Seguros (Guilherme/SUPERO)

				  21/11/2017 - Ajuste para controle das mensagens de alerta referente a seguro (Jonata - RKAM P364).
 */
session_start();

// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
require_once("../../../includes/config.php");
require_once("../../../includes/funcoes.php");
require_once("../../../includes/controla_secao.php");
// Classe para leitura do xml de retorno
require_once("../../../class/xmlfile.php");

// Verifica se tela foi chamada pelo método POST
isPostMethod();

if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
	exibeErro($msgError);
}

// Verifica se número da conta foi informado
if (!isset($_POST["nrdconta"])) {
    exibeErro("Par&acirc;metros incorretos.[Conta/DV]");
}
$nrdconta = $_POST["nrdconta"];

// Verifica se número da conta é um inteiro válido
if (!validaInteiro($nrdconta)) {
	exibeErro("Conta/dv inv&aacute;lida.");
}

$cddopcao = (isset($_POST['cddopcao'])?$_POST['cddopcao']:'');
$operacao = (isset($_POST['operacao'])?$_POST['operacao']:'');
$nrctrseg = (isset($_POST['nrctrseg'])?$_POST['nrctrseg']:'');
$cdsegura = (isset($_POST['cdsegura'])?$_POST['cdsegura']:'');
$tpseguro = (isset($_POST['tpseguro'])?$_POST['tpseguro']:'');
$cdsitpsg = (isset($_POST['cdsitpsg'])?$_POST['cdsitpsg']:'');
$executandoImpedimentos = (isset($_POST['executandoImpedimentos'])?$_POST['executandoImpedimentos']:'');

$nrctrseg = ( $nrctrseg == 'null' ) ? '' : $nrctrseg ;
$cdsegura = ( $cdsegura == 'null' ) ? '' : $cdsegura ;
$tpseguro = ( $tpseguro == 'null' ) ? '' : $tpseguro ;
$cdsitpsg = ( $cdsitpsg == 'null' ) ? '' : $cdsitpsg ;


$flgNovo = false;   // Indicador se é seguro AUTO ou VIDA NOVO

if($operacao == 'C_AUTO'){
	$procedure = 'seguro_auto';

}else if($operacao == 'C_AUTO_N' || $operacao == 'CONSULTAR_NOVO'){ // SEGURO AUTO NOVO

    // Verifica se número do Contrato foi informado
    if (!isset($_POST["idcontrato"])) {
        exibeErro("Par&acirc;metros incorretos. [Contrato]");
    } else {
        $idcontrato = $_POST["idcontrato"];
    }
    if (!validaInteiro($idcontrato)) {
        exibeErro("Contrato inv&aacute;lido!");
    }
    $flgNovo = true;
}else if($operacao == 'C_CASA'){
	$procedure = 'buscar_seguro_geral';
}else if($operacao == 'SEGUR'){
	$procedure = 'buscar_seguradora';
	$tpseguro=11;
	$cdsitpsg=1;
}else{
	$procedure = 'busca_seguros';
    if ($cddopcao == '@') {
        $flgNovo   = true;
    } // Quando veio pela tela Inicial - Consultar
}

if ($flgNovo == false) {    // FAZ O QUE SEMPRE FEZ
    // Monta o xml de requisição
    $xml  = "";
    $xml .= "<Root>";
        $xml .= "   <Cabecalho>";
        $xml .= "       <Bo>b1wgen0033.p</Bo>";
        $xml .= "       <Proc>".$procedure."</Proc>";
        $xml .= "   </Cabecalho>";
        $xml .= "   <Dados>";
        $xml .= "       <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
        $xml .= "       <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
        $xml .= "       <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
        $xml .= "       <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
        $xml .= "       <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
        $xml .= "       <nrdconta>".$nrdconta."</nrdconta>";
        $xml .= "       <nrctrseg>".$nrctrseg."</nrctrseg>";
        $xml .= "       <idseqttl>1</idseqttl>";
        $xml .= "       <idorigem>".$glbvars['idorigem']."</idorigem>";
        $xml .= "       <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
        $xml .= "       <cdsegura>".$cdsegura."</cdsegura>";
        $xml .= "       <tpseguro>".$tpseguro."</tpseguro>";
        $xml .= "       <cdsitpsg>".$cdsitpsg."</cdsitpsg>";
        $xml .= "       <flgerlog>FALSE</flgerlog>";
        $xml .= "   </Dados>";
        $xml .= "</Root>";

    // Executa script para envio do XML
    $xmlResult = getDataXML($xml);

    // Cria objeto para classe de tratamento de XML
    $xmlObjeto = getObjectXML($xmlResult);

    // Se ocorrer um erro, mostra crítica
    if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
        exibeErro($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata);
    }

    if(in_array($operacao,array('C_AUTO'))){
        $seguro_auto = $xmlObjeto->roottag->tags[0]->tags[0]->tags;

        ?><script type="text/javascript">

            var arraySeguroAuto = new Object();

            arraySeguroAuto['nmresseg'] = '<?php echo getByTagName($seguro_auto,'nmdsegur'); ?>';
            arraySeguroAuto['dsmarvei'] = '<?php echo getByTagName($seguro_auto,'dsmarvei'); ?>';
            arraySeguroAuto['dstipvei'] = '<?php echo getByTagName($seguro_auto,'dstipvei'); ?>';
            arraySeguroAuto['nranovei'] = '<?php echo getByTagName($seguro_auto,'nranovei'); ?>';
            arraySeguroAuto['nrmodvei'] = '<?php echo getByTagName($seguro_auto,'nrmodvei'); ?>';
            arraySeguroAuto['nrdplaca'] = '<?php echo getByTagName($seguro_auto,'nrdplaca'); ?>';
            arraySeguroAuto['dtinivig'] = '<?php echo getByTagName($seguro_auto,'dtinivig'); ?>';
            arraySeguroAuto['dtfimvig'] = '<?php echo getByTagName($seguro_auto,'dtfimvig'); ?>';
            arraySeguroAuto['qtparcel'] = '<?php echo getByTagName($seguro_auto,'qtparcel'); ?>';
            arraySeguroAuto['vlpreseg'] = '<?php echo getByTagName($seguro_auto,'vlpreseg'); ?>';
            arraySeguroAuto['vlpremio'] = '<?php echo getByTagName($seguro_auto,'vlpremio'); ?>';
            arraySeguroAuto['dtdebito'] = '<?php echo getByTagName($seguro_auto,'dtdebito'); ?>';

        </script><?php
    }else if(in_array($operacao,array('C_CASA'))){
        $seguros = $xmlObjeto->roottag->tags[0]->tags[0]->tags;

        ?>

        <script type="text/javascript">

            var arraySeguroCasa = new Object();

            arraySeguroCasa['nmresseg'] = '<?php echo getByTagName($seguros,'nmresseg'); ?>';
            arraySeguroCasa['nrctrseg'] = '<?php echo getByTagName($seguros,'nrctrseg'); ?>';
            arraySeguroCasa['tpplaseg'] = '<?php echo getByTagName($seguros,'tpplaseg'); ?>';
            arraySeguroCasa['ddpripag'] = '<?php echo getByTagName($seguros,'dtprideb'); ?>';
            arraySeguroCasa['ddpripag'] = arraySeguroCasa['ddpripag'].split("/");
            arraySeguroCasa['ddpripag'] = arraySeguroCasa['ddpripag'][0];

            arraySeguroCasa['ddvencto'] = '<?php echo getByTagName($seguros,'dtdebito'); ?>';
            arraySeguroCasa['ddvencto'] = arraySeguroCasa['ddvencto'].split("/");
            arraySeguroCasa['ddvencto'] = arraySeguroCasa['ddvencto'][0];

            arraySeguroCasa['vlpreseg'] = '<?php echo getByTagName($seguros,'vlpreseg'); ?>';
            arraySeguroCasa['dtinivig'] = '<?php echo getByTagName($seguros,'dtinivig'); ?>';
            arraySeguroCasa['dtfimvig'] = '<?php echo getByTagName($seguros,'dtfimvig'); ?>';
            arraySeguroCasa['flgclabe'] = '<?php echo getByTagName($seguros,'flgclabe'); ?>';
            arraySeguroCasa['nmbenvid'] = '<?php echo $seguros[28]->tags[0]->cdata; ?>';
            arraySeguroCasa['dtcancel'] = '<?php echo getByTagName($seguros,'dtcancel'); ?>';
            arraySeguroCasa['dsmotcan'] = '<?php echo getByTagName($seguros,'dsmotcan'); ?>';

            arraySeguroCasa['nrcepend'] = '<?php echo getByTagName($seguros,'nrcepend'); ?>';
            arraySeguroCasa['dsendres'] = '<?php echo getByTagName($seguros,'dsendres'); ?>';
            arraySeguroCasa['nrendere'] = '<?php echo getByTagName($seguros,'nrendres'); ?>';
            arraySeguroCasa['complend'] = '<?php echo getByTagName($seguros,'complend'); ?>';
            arraySeguroCasa['nmbairro'] = '<?php echo getByTagName($seguros,'nmbairro'); ?>';
            arraySeguroCasa['nmcidade'] = '<?php echo getByTagName($seguros,'nmcidade'); ?>';
            arraySeguroCasa['cdufresd'] = '<?php echo getByTagName($seguros,'cdufresd'); ?>';

            arraySeguroCasa['tpendcor'] = '<?php echo getByTagName($seguros,'tpendcor'); ?>';

		arraySeguroAuto['nmresseg'] = '<? echo getByTagName($seguro_auto,'nmdsegur'); ?>';
		arraySeguroAuto['dsmarvei'] = '<? echo getByTagName($seguro_auto,'dsmarvei'); ?>';
		arraySeguroAuto['dstipvei'] = '<? echo getByTagName($seguro_auto,'dstipvei'); ?>';
		arraySeguroAuto['nranovei'] = '<? echo getByTagName($seguro_auto,'nranovei'); ?>';
		arraySeguroAuto['nrmodvei'] = '<? echo getByTagName($seguro_auto,'nrmodvei'); ?>';
		arraySeguroAuto['nrdplaca'] = '<? echo getByTagName($seguro_auto,'nrdplaca'); ?>';
		arraySeguroAuto['dtinivig'] = '<? echo getByTagName($seguro_auto,'dtinivig'); ?>';
		arraySeguroAuto['dtfimvig'] = '<? echo getByTagName($seguro_auto,'dtfimvig'); ?>';
		arraySeguroAuto['qtparcel'] = '<? echo getByTagName($seguro_auto,'qtparcel'); ?>';
		arraySeguroAuto['vlpreseg'] = '<? echo getByTagName($seguro_auto,'vlpreseg'); ?>';
		arraySeguroAuto['vlpremio'] = '<? echo getByTagName($seguro_auto,'vlpremio'); ?>';
		arraySeguroAuto['dtdebito'] = '<? echo getByTagName($seguro_auto,'dtdebito'); ?>';
		
	</script><?
}else if(in_array($operacao,array('C_CASA'))){
	$seguros = $xmlObjeto->roottag->tags[0]->tags[0]->tags;
	
	?>
	
	<script type="text/javascript">
		
		var arraySeguroCasa = new Object();
		
		arraySeguroCasa['nmresseg'] = '<? echo getByTagName($seguros,'nmresseg'); ?>';
		arraySeguroCasa['nrctrseg'] = '<? echo getByTagName($seguros,'nrctrseg'); ?>';
		arraySeguroCasa['tpplaseg'] = '<? echo getByTagName($seguros,'tpplaseg'); ?>';
		arraySeguroCasa['ddpripag'] = '<? echo getByTagName($seguros,'dtprideb'); ?>';
		arraySeguroCasa['ddpripag'] = arraySeguroCasa['ddpripag'].split("/");
		arraySeguroCasa['ddpripag'] = arraySeguroCasa['ddpripag'][0];
			
		arraySeguroCasa['ddvencto'] = '<? echo getByTagName($seguros,'dtdebito'); ?>';
		arraySeguroCasa['ddvencto'] = arraySeguroCasa['ddvencto'].split("/");
		arraySeguroCasa['ddvencto'] = arraySeguroCasa['ddvencto'][0];
		
		arraySeguroCasa['vlpreseg'] = '<? echo getByTagName($seguros,'vlpreseg'); ?>';
		arraySeguroCasa['dtinivig'] = '<? echo getByTagName($seguros,'dtinivig'); ?>';
		arraySeguroCasa['dtfimvig'] = '<? echo getByTagName($seguros,'dtfimvig'); ?>';
		arraySeguroCasa['flgclabe'] = '<? echo getByTagName($seguros,'flgclabe'); ?>';
		arraySeguroCasa['nmbenvid'] = '<? echo $seguros[28]->tags[0]->cdata; ?>';
		arraySeguroCasa['dtcancel'] = '<? echo getByTagName($seguros,'dtcancel'); ?>';
		arraySeguroCasa['dsmotcan'] = '<? echo getByTagName($seguros,'dsmotcan'); ?>';
		
		arraySeguroCasa['nrcepend'] = '<? echo getByTagName($seguros,'nrcepend'); ?>';
		arraySeguroCasa['dsendres'] = '<? echo getByTagName($seguros,'dsendres'); ?>';
		arraySeguroCasa['nrendere'] = '<? echo getByTagName($seguros,'nrendres'); ?>';
		arraySeguroCasa['complend'] = '<? echo getByTagName($seguros,'complend'); ?>';
		arraySeguroCasa['nmbairro'] = '<? echo getByTagName($seguros,'nmbairro'); ?>';
		arraySeguroCasa['nmcidade'] = '<? echo getByTagName($seguros,'nmcidade'); ?>';
		arraySeguroCasa['cdufresd'] = '<? echo getByTagName($seguros,'cdufresd'); ?>';
		
		arraySeguroCasa['tpendcor'] = '<? echo getByTagName($seguros,'tpendcor'); ?>';
		
	</script><?
    }else if($operacao == 'SEGUR'){
        $seguradoras  = $xmlObjeto->roottag->tags[0]->tags;
    }else if($operacao == ''){
        $seguros = $xmlObjeto->roottag->tags[0]->tags;
    }
} else { // $flgNovo == true // SEGUROS NOVOS

    if(in_array($operacao,array('C_AUTO_N'))){

        // Monta o xml de requisição
        $xml  		= "";
        $xml 	   .= "<Root>";
        $xml 	   .= " <Dados>";
        $xml 	   .= "     <nrdconta>".$nrdconta."</nrdconta>";
        $xml 	   .= "     <idcontrato>".$idcontrato."</idcontrato>";
        $xml 	   .= " </Dados>";
        $xml 	   .= "</Root>";

        $xmlResult = mensageria($xml, "TELA_ATENDA_SEGURO", "BUSCASEGAUTO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObjeto = getObjectXML($xmlResult);

        // Se ocorrer um erro, mostra crítica
        if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {

            $msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
            exibirErro('error',$msgErro,'Alerta - Ayllos','estadoInicial();',false);

        }
        //$seguro_auto = $xmlObjeto->roottag->tags[0]->tags[0]->tags;
        $seguro_auto = $xmlObjeto->roottag->tags;

        $nmsegurado     = getByTagName($seguro_auto,'nmSegurado');
        $tpdoseguro     = getByTagName($seguro_auto,'dsTpSeguro');
        $nmsegura       = getByTagName($seguro_auto,'nmSeguradora');
        $Dtinivig       = getByTagName($seguro_auto,'dtIniVigen');
        $Dtfimvig       = getByTagName($seguro_auto,'dtFimVigen');
        $Nrproposta     = getByTagName($seguro_auto,'nrProposta');
        $Nrapolice      = getByTagName($seguro_auto,'nrApolice');
        $Nrendosso      = getByTagName($seguro_auto,'nrEndosso');
        $tpendosso      = getByTagName($seguro_auto,'dsEndosso');
        $tpsub_endosso  = getByTagName($seguro_auto,'dsSubEndosso');
        $Nmmarca        = getByTagName($seguro_auto,'nmMarca');
        $Dsmodelo       = getByTagName($seguro_auto,'nmModelo');
        $Dschassi       = getByTagName($seguro_auto,'dsChassi');
        $Dsplaca        = getByTagName($seguro_auto,'dsPlaca');
        $Nranofab       = getByTagName($seguro_auto,'nrAnoFab');
        $Nranomod       = getByTagName($seguro_auto,'nrAnoMod');
        $vlfranquia     = getByTagName($seguro_auto,'vlFranquia');
        $vlpremioliq    = getByTagName($seguro_auto,'vlPremioLiquido');
        $vlpremiotot    = getByTagName($seguro_auto,'vlPremioTotal');
        $qtparcelas     = getByTagName($seguro_auto,'qtParcelas');
        $vlparcela      = getByTagName($seguro_auto,'vlParcela');
        $diadodebito    = getByTagName($seguro_auto,'ddMelhorDia');
        $percomissao    = getByTagName($seguro_auto,'perComissao');
    } // FIM - SEGUROS AUTO NOVO
	else if(in_array($operacao,array('CONSULTAR_NOVO'))){
		// Monta o xml de requisição
        $xml  		= "";
        $xml 	   .= "<Root>";
        $xml 	   .= " <Dados>";
        $xml 	   .= "     <nrdconta>".$nrdconta."</nrdconta>";
        $xml 	   .= "     <idcontrato>".$idcontrato."</idcontrato>";
        $xml 	   .= " </Dados>";
        $xml 	   .= "</Root>";

        $xmlResult = mensageria($xml, "TELA_ATENDA_SEGURO", "BUSCASEGVIDA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObjeto = getObjectXML($xmlResult);

        // Se ocorrer um erro, mostra crítica
        if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {

            $msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
            exibirErro('error',$msgErro,'Alerta - Ayllos','estadoInicial();',false);

        }
        //$seguro_auto = $xmlObjeto->roottag->tags[0]->tags[0]->tags;
        $seguro_auto = $xmlObjeto->roottag->tags;

        $nmSegurado	     = getByTagName($seguro_auto,'nmSegurado');
		$dsTpSeguro	     = getByTagName($seguro_auto,'dsTpSeguro');
		$nmSeguradora	 = getByTagName($seguro_auto,'nmSeguradora');
		$dtIniVigen	     = getByTagName($seguro_auto,'dtIniVigen');
		$dtFimVigen	     = getByTagName($seguro_auto,'dtFimVigen');
		$nrProposta	     = getByTagName($seguro_auto,'nrProposta');
		$nrApolice	     = getByTagName($seguro_auto,'nrApolice');
		$nrEndosso	     = getByTagName($seguro_auto,'nrEndosso');
		$dsPlano	     = getByTagName($seguro_auto,'dsPlano');
		$vlCapital	     = getByTagName($seguro_auto,'vlCapital');
		$nrApoliceRenova = getByTagName($seguro_auto,'nrApoliceRenova');
		$vlPremioLiquido = getByTagName($seguro_auto,'vlPremioLiquido');
		$qtParcelas	     = getByTagName($seguro_auto,'qtParcelas');
		$vlPremioTotal	 = getByTagName($seguro_auto,'vlPremioTotal');
		$vlParcela	     = getByTagName($seguro_auto,'vlParcela');
		$ddMelhorDia	 = getByTagName($seguro_auto,'ddMelhorDia');
		$perComissao	 = getByTagName($seguro_auto,'perComissao');
		$dsObservacoes   = getByTagName($seguro_auto,'dsObservacoes');
		$registros = $xmlObjeto->roottag->tags[17]->tags;

	}
    else if($operacao == ''){ // TELA PRINCIPAL DE SEGUROS

        // Monta o xml de requisição
        $xml  		= "";
        $xml 	   .= "<Root>";
        $xml 	   .= " <Dados>";
        $xml 	   .= "     <nrdconta>".$nrdconta."</nrdconta>";
        $xml 	   .= "     <dtmvtolt>".$glbvars['dtmvtolt']."</dtmvtolt>";
        $xml 	   .= " </Dados>";
        $xml 	   .= "</Root>";

        $xmlResult = mensageria($xml, "TELA_ATENDA_SEGURO", "BUSCASEGUROS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObjeto = getObjectXML($xmlResult);

        // Se ocorrer um erro, mostra crítica
        if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {

            $msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
            exibirErro('error',$msgErro,'Alerta - Ayllos','estadoInicial();',false);

        }
        //$seguro_auto = $xmlObjeto->roottag->tags;
        //$seguros = $xmlObjeto->roottag->tags[0]->tags;
        $seguros = $xmlObjeto->roottag->tags;
    }
} // FIM - SEGUROS NOVOS

// Procura indíce da opção "@"
$idPrincipal = array_search("@",$glbvars["opcoesTela"]);

if ($idPrincipal === false) {
	$idPrincipal = 0;
}

// Função para exibir erros na tela através de javascript
function exibeErro($msgErro) {
	echo '<script type="text/javascript">';
	echo 'hideMsgAguardo();';
	echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
	echo '</script>';
	exit();
}

// Se estiver consultando, chamar a TABELA
if(in_array($operacao,array(''))) {
	include('tabela_seguro.php');
}else if(in_array($operacao,array('I'))){
	include('tipo_seguro.php');
}else if(in_array($operacao,array('TF'))){
	include('form_seguro.php');
}else if(in_array($operacao,array('TI','CONSULTAR','ALTERAR'))){
	include('form_seguro_vida_prest.php');
}else if(in_array($operacao,array('CONSULTAR_NOVO'))){
	include('form_seguro_vida_prest_novo.php');
}else if(in_array($operacao,array('C_AUTO'))){
	include('form_auto.php');
}else if(in_array($operacao,array('C_AUTO_N'))){
    include('form_auto_novo.php');
}else if(in_array($operacao,array('C_CASA'))){
	include('form_seguro_casa.php');
}else if(in_array($operacao,array('SEGUR'))) {
	include('tabela_seguradora.php');
}else if(in_array($operacao,array('I_CASA'))) {
	include('form_seguro_casa.php');
}
?>
<script type="text/javascript">

controlaLayout('<?php echo $operacao;?>');
// Esconde mensagem de aguardo
hideMsgAguardo();
// Bloqueia conteúdo que está atras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
<?php if($operacao == 'C_CASA'){ ?> formataCep(); <?php } ?>
</script>