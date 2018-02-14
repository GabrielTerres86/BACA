<? 
/*!
 * FONTE        : busca_dados.php
 * CRIAÇÃO      : Jaison
 * DATA CRIAÇÃO : 05/05/2016
 * OBJETIVO     : Rotina para buscar os riscos
 
    14/02/2018 - #822034 Alterada a forma como é criado o xml para ganhar performance;
                 inclusão de filtro de contas e ordenação por conta;
                 tela não carrega mais todas as contas ao entrar nas opções (Carlos)
 */

    session_start();
    require_once('../../includes/config.php');
    require_once('../../includes/funcoes.php');
    require_once('../../includes/controla_secao.php');	
    require_once('../../class/xmlfile.php');
    isPostMethod();		

    // Guardo os parâmetos do POST em variáveis	
    $contamax = 99999999;
    $cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : 'C';
    $innivris = (isset($_POST['innivris'])) ? $_POST['innivris'] : 2; // Default: A
    $containi = (isset($_POST['ctaini'])) ? $_POST['ctaini'] : 0;
    $contafim = (isset($_POST['ctafim'])) ? $_POST['ctafim'] : $contamax;
    if ($contafim == 0) {
        $contafim = $contamax;
    }
    $xml = new XmlMensageria();
    $xml->add('cdnivel_risco',$innivris)
        ->add('containi',$containi)
        ->add('contafim',$contafim);

    $xmlResult = mensageria($xml, "TELA_CADRIS", "BUSCA_RISCO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObject = getObjectXML($xmlResult);

    if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO"){
        $msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
        if ($msgErro == "") {
            $msgErro = $xmlObject->roottag->tags[0]->cdata;
        }
        exibirErro('error',$msgErro,'Alerta - Ayllos','estadoInicial()');
    }

    $registros = $xmlObject->roottag->tags[0]->tags;
?>
<div class="divRegistros">
    <table>
        <thead>
            <tr>
                <?php
                    // Se for exclusao exibe checkbox
                    if ($cddopcao == 'E') {
                        ?><th><input type="checkbox" id="select_all"/></th><?php
                    }
                ?>
                <th>Conta</th>
                <th>Nome</th>
            </tr>
        </thead>
        <tbody>
        <?php
            $conteudo = '';

            // Se for exclusao exibe checkbox
            if ($cddopcao == 'E') {
                foreach ($registros as $reg) {
                    $nrdconta = getByTagName($reg->tags,'nrdconta');                                        
                    $conteudo .= '<tr><td><input type="checkbox" class="clsCheckbox" value="'.$nrdconta.'" /></td><td>'.
                    $nrdconta.'</td><td>'.getByTagName($reg->tags,'nmprimtl').'</td></tr>';
                }
            } else if ($cddopcao == 'C') {
                foreach ($registros as $reg) {
                    $nrdconta = getByTagName($reg->tags,'nrdconta');
                    $conteudo .= '<tr><input type="hidden" id="hdn_dsjustif" value="'.getByTagName($reg->tags,'dsjustificativa').'" /><td>'.
                    $nrdconta.'</td><td>'.getByTagName($reg->tags,'nmprimtl').'</td></tr>';
                }
            }
            echo $conteudo;
        ?>
        </tbody>
    </table>
</div>