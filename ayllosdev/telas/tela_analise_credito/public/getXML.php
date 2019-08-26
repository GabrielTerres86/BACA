<?php
/* 
*
*  @author Mout's - Anderson Schloegel
*  Ailos - Projeto 438 - sprint 9 - Tela Única de Análise de Crédito
*  fevereiro/março de 2019
*
*  Arquivo responsável por converter o XML para json,
*  separar as personas e categorias,
*  gerar menu de categorias
*  fazer tratamento de string e tabelas
* 
*/

// DESATIVAR em prod
 // error_reporting(E_ALL);
 // ini_set('display_errors', 1);
ini_set('session.cookie_domain', '.cecred.coop.br' );

// novo limite de memoria
ini_set('memory_limit','1000M');

// Increase max_execution_time. If a large pdf fails, increase it even more.
ini_set('max_execution_time', 180);

// Increase this for old PHP versions (like 5.3.3). If a large pdf fails, increase it even more.
ini_set('pcre.backtrack_limit', 1000000);

// inicio
session_start();
include 'assets/classes/sys.chamadas.class.php';
include 'assets/classes/sys.getxml.class.php';

//verifica se uma requisição foi enviada
if (isset($_POST['requisicao'])) {

    // recebe qual processamento deve ser feito
    $requisicao = $_POST['requisicao'];
    $requisicao = 'pegarXML';

    # get Histórico
    if ($requisicao == 'pegarXML') {

        // verifica se existe sessão
        if(isset($_SESSION['glbvars'])){

            $_glbvars = $_SESSION['glbvars'];

            // pega XML do banco de dados
            if($_SESSION['configCore']['localhost']){

                $getXml = new GetXml($_configCore,$_glbvars,$_configCore['getParameters']);
                $projetos_json = $getXml->retornaXml();

            }else{

                // pega XML da sessao
                $projetos_json = $_SESSION['xml'];

            }

        /*
        * carrega XML local (DEV)
        */

        } else if (file_exists("xml/prototipo.xml")) {

            // carrega XML local
            $projetos_json = file_get_contents("xml/prototipo.xml");
            $projetos_json = simplexml_load_string($projetos_json);
            $projetos_json = json_encode($projetos_json);
        }

        $projetos_json      = json_decode($projetos_json, TRUE);

        /*
        * Tratar erro de retorno da resposta de recolhimento do ultimo xml gerado em tabela 
        */
        
        if(isset($projetos_json['Erro'])){
            echo json_encode(Array(
                'error' => true,
                'message' => $projetos_json['Erro']['Registro']['dscritic']
            ));
            exit();
        }

        // data da geração da proposta
        $_SESSION['data'] = 'Nenhuma data definida';

        // data que a proposta foi gerada (XML)
        if (isset($projetos_json['Dados']['data'])) {
            $_SESSION['data'] = trim($projetos_json['Dados']['data']);
        }

        if(!isset($projetos_json['personas'])){
            $projetos_json = $projetos_json['Dados'];
        }

        // gravar json em sessao pra poder consultar depois
        $token_json                 = $_SESSION['token_json'];

        // para btn homologação json
        $_SESSION[$token_json]      = $projetos_json;

        // vetor pra armazenar todas as personas
        $retorna_persona            = array();

        // vetor pra armazenar o filtro de personas
        $retorna_persona_filtro     = array();

        // vetor pra armazenar o filtro de personas (TELA)
        $retorna_persona_tela       = array();

        // vetor pra armazenar todas as categorias
        $retorna_categoria          = array();

        // vetor pra armazenar o filtro de categorias
        $retorna_categoria_filtro   = array();

        // vetor pra armazenar o filtro de categorias (TELA)
        $retorna_categoria_tela     = array();

        // vetor para armazenar todos os boxes
        $retorna_blocos             = array();

        // vetor para armazenar todos os boxes
        $retorna_blocos_pdf         = array();

        /*
        *
        * percorrer JSON
        *
        */

        // <personas>

        foreach ($projetos_json['personas'] as $key => $personas) {

            // <persona>

            // verifica se existe uma ou mais personas, e caso tenha só uma, transforma o vetor
            $personas = makeArray($personas);

            foreach ($personas as $key => $persona) {

                // grava a persona corrente dentro do vetor com todas as personas
                array_push($retorna_persona, tituloFiltro(@$persona['tituloFiltro']));
                array_push($retorna_persona_tela, tituloTela(@$persona['tituloTela']));

                // <categorias>
                foreach ($persona['categorias'] as $categorias) {

                    // verifica se existe uma ou mais categorias, e caso tenha só uma, transforma o vetor
                    $categorias = makeArray($categorias);

                    // <categoria>
                    foreach ($categorias as $categoria) {

                        // grava a persona corrente dentro do vetor com todas as personas
                        array_push($retorna_categoria, tituloFiltro(@$categoria['tituloFiltro']));
                        array_push($retorna_categoria_tela, tituloTela(@$categoria['tituloTela']));

                        // monta HTML do filtro
                        $html_filtro_categoria = '
                                                      <li class="nav-item">
                                                        <a class="nav-link filtro categoria" filtro="categoria" ativo="nao" tipo="' . tituloFiltro(@$categoria['tituloFiltro']) . '" href="#">

                                                            <i class="menu-icon far fa-circle check-categorias check-' . tituloFiltro(@$categoria['tituloFiltro']) . '""></i>';

                        switch (@$categoria['tituloFiltro']) {
                            case 'cadastro':    $icone = '<span class="ico-categoria fas fa-portrait"></span>';         break;
                            case 'proposta':    $icone = '<span class="ico-categoria fas fa-file-powerpoint"></span>';  break;
                            case 'operacoes':   $icone = '<span class="ico-categoria fas fa-file-contract"></span>';    break;
                            case 'garantia':    $icone = '<span class="ico-categoria fas fa-file-invoice"></span>';     break;
                            case 'consulta':    $icone = '<span class="ico-categoria fas fa-clipboard-list"></span>';   break;
                            case 'scr':         $icone = '<span class="ico-categoria fas fa-file-alt"></span>';         break;
                        }

                        $html_filtro_categoria .= $icone;  // icone personalizado
                        $html_filtro_categoria .= '

                                                            ' . tituloTela(@$categoria['tituloTela']) . '
                                                        </a>
                                                      </li>
                                                    ';

                        array_push($retorna_categoria_filtro, $html_filtro_categoria);


                        /*
                        *
                        *   Bloco de categoria
                        *
                        */

                        // blocos screen
                        $html = '';
                        $html .= '<div class="row persona_' . tituloFiltro(@$persona['tituloFiltro']) . ' categoria_' . tituloFiltro(@$categoria['tituloFiltro']) . ' ' . tituloFiltro(@$persona['tituloFiltro']) . '_' . tituloFiltro(@$categoria['tituloFiltro']) . '">';
                        $html .= '    <div class="col-12 grid-margin">';
                        $html .= '        <div class="card">';
                        $html .= '            <div class="card-body">';

                        $html .= '                <div class="row">';
                        $html .= '                <div class="col">';
                        $html .= '                    <h5 class="card-title mb-3">';

                        $html .= '                      <span class="titulo-card-persona">' . tituloTela(@$persona["tituloTela"]) . ':</span> <span class="titulo-card-categoria">' . tituloTela(@$categoria["tituloTela"]) . '</span>';
                        $html .= '                    </h5>';
                        $html .= '                </div>';

                        $html .= '                <div class="col ocultar-pdf">';
                        $html .= '                    <div class="text-right">';
                        $html .= '                        <a class="btn-side-by-side" persona_categoria_real="'. tituloTela(@$persona['tituloTela']).': '.tituloTela(@$categoria['tituloTela']).'" persona_categoria="'.tituloFiltro(@$persona['tituloFiltro']).'_'.tituloFiltro(@$categoria['tituloFiltro']).'">';
                        $html .= '                            <small>Comparar <i class="fas fa-columns"></i></small>';
                        $html .= '                        </a>';
                        $html .= '                    </div>';
                        $html .= '                </div>';
                        $html .= '            </div>';
                            
                        /*
                        *
                        *   Data da proposta
                        *
                        */

                        if (@$categoria['tituloFiltro'] === 'proposta') {                        
                            $html .= '                <div class="row">';
                            $html .= '                <div class="col">';
                            $html .= '                      <small>Dados da proposta gerados em: ' . $_SESSION['data'] . '</small>';
                            $html .= '                </div>';
                            $html .= '                </div>';
                        }

                        /*
                        *
                        *   Bloco de subcategoria
                        *
                        */

                        $html .= '            <div class="fluid-container">';
                        $html .= '                <div class="row ticket-card pb-2">';
                        $html .= '                    <div class="ticket-details col-md-12">';
                        $html .= '                        <div class="row">';

                        foreach ($categoria['subcategorias'] as $subcategoria) {

                            // verifica se existe uma ou mais subcategorias, e caso tenha só uma, transforma o vetor
                            $subcategoria = makeArray($subcategoria);

                            // percorre subcategorias e gera blocos
                            foreach ($subcategoria as $bloco) {

                                $html .= generateSubcategoria($bloco);

                            }
                        }

                        $html .= '                        </div>';
                        $html .= '                    </div>';
                        $html .= '                </div>';
                        $html .= '            </div>';
                        $html .= '        </div>';
                        $html .= '    </div>';
                        $html .= '</div>';

                        // grava o bloco corrente dentro do vetor com todos os blocos
                        array_push($retorna_blocos, $html);

                        // fim retorna blocos SCREEN


                        /*
                        *
                        *   PDF
                        *
                        */

                        $html_pdf = '';
                        $html_pdf .= '<br><table><tr><td><span class="titulo-categoria-pdf">' . tituloTela(@$persona["tituloTela"]) . ': '.tituloTela(@$categoria['tituloTela']) . '</span>';

                        $html_pdf .= '<p>';

                        foreach ($categoria['subcategorias'] as $subcategoria) {

                            // verifica se existe uma ou mais subcategorias, e caso tenha só uma, transforma o vetor
                            $subcategoria = makeArray($subcategoria);

                            // percorre subcategorias e gera blocos
                            foreach ($subcategoria as $bloco) {

                                $html_pdf .= generateSubcategoria($bloco, 'pdf');
                            }
                        }

                        $html_pdf .= '</p></td></tr></table>';

                        // grava o bloco corrente dentro do vetor com todos os blocos
                        array_push($retorna_blocos_pdf, $html_pdf);

                        // FIM retorna blocos PDF

                    } // fim <categoria>

                } // fim <categorias>

            } // fim <persona>

        } // fim <personas>

        // resetar keys | remover itens repetidos
        $retorna_persona                = array_values(array_unique($retorna_persona));         // todas as personas para usar no filtro (slug)
        $retorna_persona_filtro         = array_values(array_unique($retorna_persona_filtro));  // todas as personas para usar na tela   (html)
        $retorna_categoria              = array_values(array_unique($retorna_categoria));       // todas as categorias encontradas no XML para filtro   (slug)
        $retorna_categoria_filtro       = array_values(array_unique($retorna_categoria_filtro));// todas as categorias encontradas no XML para tela     (html)

        // botão para filtrar todas as categorias TODOS
        $html_filtro_categoria          = '
                                          <li class="nav-item">
                                            <a class="nav-link filtro categoria nav-link-todos" filtro="categoria" ativo="nao" tipo="todos_categoria" href="#">
                                                <i class="menu-icon far fa-circle"></i>
                                                Todas as categorias
                                            </a>
                                          </li>
                                          ';

        // adiciona o último botão dentro do vetor de filtro de categorias
        array_push($retorna_categoria_filtro, $html_filtro_categoria);

        # RETORNO DOS DADOS

        // vetor que vai receber os dados
        $dados = array();

        // insere vetores no novo vetor de retorno
        $dados['blocos']            = $retorna_blocos;          // blocos HTML com dados
        $dados['persona']           = $retorna_persona;         // todas as personas para usar no filtro (slug)
        $dados['persona_tela']      = $retorna_persona_tela;    // todas as personas para usar na tela   (texto)
        $dados['categoria']         = $retorna_categoria;       // todas as categorias para usar no filtro (slug)
        $dados['categoria_filtro']  = $retorna_categoria_filtro;// todas as categorias para usar na tela   (texto)

        // gravar blocos em sessao pra poder exibir no PDF
        $token_pdf                  = $_SESSION['token_pdf'];

        // para gerar PDF
        $_SESSION[$token_pdf]       = $retorna_blocos_pdf;

        // codifica json
        $dados = json_encode($dados);

        // manda pra tela
        print($dados);
    }
}

/*
* pra gerar uma subcategoria
*/

function generateSubcategoria($vetor = array(), $modo = 'screen') {

        $bloco = '';

        /*
        *
        *  EM CASO DE ERROS - TAG ERRO
        *
        */

        if (isset($vetor['erros'])){

            if ($modo == 'pdf') {

                # pdf
                $bloco .= '<h3>' . tituloTela(@$vetor['tituloTela']) . '</h3>';

                $bloco .= '<p class="erroTagXML">';
                $bloco .= 'Esta consulta pode conter erros!<br>';

                if (isset($vetor['erros']['erro'])) {

                    $erros = makeArray($vetor['erros']['erro']);     

                    foreach ($erros as $erro) {

                        // verifica se os campos existem
                        $cdcritic = (isset($erro['cdcritic']) ? $erro['cdcritic'] : '-');
                        $dscritic = (isset($erro['dscritic']) ? $erro['dscritic'] : '-');

                        // exibe na tela
                        $bloco .= '<br><b>CDCRITIC: ' . verificaTexto($cdcritic) .'</b><br>';
                        $bloco .= 'DSCRITIC:        ' . verificaTexto($dscritic) .'<br>';
                    }
                }

                $bloco .= '</p>';

            } else {

                # screen
                $bloco .= '<div class="bloco col-md-12">';
                $bloco .= '<h5>' . tituloTela(@$vetor['tituloTela']) . '</h5>';

                $bloco .= '<div class="erroTagXML">';
                $bloco .= ' <p><i class="fas fa-times-circle"></i> &nbsp; Esta consulta pode conter erros!</p>';

                if (isset($vetor['erros']['erro'])) {

                    $erros = makeArray($vetor['erros']['erro']);     

                    foreach ($erros as $erro) {

                        // verifica se os campos existem
                        $cdcritic = (isset($erro['cdcritic']) ? $erro['cdcritic'] : '-');
                        $dscritic = (isset($erro['dscritic']) ? $erro['dscritic'] : '-');

                        // exibe na tela
                        $bloco .= '<br><b>CDCRITIC: ' . verificaTexto($cdcritic) .'</b> <br> ';
                        $bloco .= 'DSCRITIC:        ' . verificaTexto($dscritic) .'     <br> ';
                    }
                }

                $bloco .= '</div>';
                $bloco .= '</div>';

            }

        } else if (isset($vetor['campos'])) {

        /*
        *
        *  CAMPOS
        *
        */

            // 
            if ($modo == 'pdf') {

                # pdf
                $bloco .= '<p>';
                $bloco .= '<h3>' . tituloTela(@$vetor['tituloTela']) . '</h3>';

                    foreach ($vetor['campos'] as $campo) {

                        // verifica se o primeiro registro existe
                        if (isset($campo[0])) {

                            // verifica se ele é vetor
                            if(is_array($campo[0])){

                                // percorre vetor de campos
                                foreach ($campo as $dado) {

                                    $bloco .= generateBloco($dado, 'pdf');
                                }

                            // campo
                            } else {

                                // em caso de erro no campo
                                $bloco .= warning("Este bloco não possui dado.");
                            }

                        // campo

                        } else {

                            // se não for vetor
                            $bloco .= generateBloco($campo, 'pdf');

                        }
                    }

                $bloco .= '</p>';

            } else {

                # screen
                $bloco .= '<div class="bloco col-md-12">';
                $bloco .= '<h5>' . tituloTela(@$vetor['tituloTela']) . '</h5>';

                    foreach ($vetor['campos'] as $campo) {

                        // verifica se o primeiro registro existe
                        if (isset($campo[0])) {

                            // verifica se ele é vetor
                            if(is_array($campo[0])){

                                // percorre vetor de campos
                                foreach ($campo as $dado) {

                                    $bloco .= generateBloco($dado);
                                }

                            // campo

                            } else {

                                // em caso de erro no campo
                                $bloco .= warning("Este bloco não possui dado.");
                            }

                        // campo

                        } else {

                            // se não for vetor
                            $bloco .= generateBloco($campo);

                        }
                    }

                $bloco .= '</div>';
                
            }

        } else if (isset($vetor['separador'])) {

                // em caso de erro no campo
                $bloco .= '<div class="bloco col-12 tag-separador">' . tituloTela(@$vetor['separador']['tituloTela']) . '</div>';

        } else {

                // em caso de erro no campo
                $bloco .= '<div class="bloco col-md-12">';
                $bloco .= '<h5>' . tituloTela(@$vetor['tituloTela']) . '</h5>';
                $bloco .= warning("Este bloco não possui dados.");
                $bloco .= '</div>';
        }

    return $bloco;
}

/*
* pra gerar uma bloco
*/

function generateBloco($vetor = array(), $modo = 'screen') {

    $bloco = '';

    // verifica se existe
    if (isset($vetor)) {

        // verifica se é vetor
        if (is_array($vetor)) {
    
            // trata campos que estiverem vazios
            $nome   = (!empty($vetor["nome"])   ? $vetor["nome"] . ': ' : "indefinido: ");
            $tipo   = (!empty($vetor["tipo"])   ? $vetor["tipo"]        : "indefinido");
            $valor  = (!empty($vetor["valor"])  ? $vetor["valor"]       : "-");
 
            // verifica se o tipo esta vazio
            if(!isset($vetor['tipo'])) {

                // tipo indefinido
                $vetor['tipo'] = '';
            }

            // dado de tipo: STRING
            if ($vetor["tipo"] == 'string') {

                // texto simples
                $bloco .= '<p class="title-string">';
                $bloco .= '<b> ' . verificaTexto($nome) . ' </b>';
                $bloco .= '<span class="upper">'.verificaTexto($valor).'</span>';
                $bloco .= '</p>';

            // dado de tipo: ERRO
            } elseif ($vetor["tipo"] == 'erro') {

                // se houve erro
                $bloco .= '<p class="title-erro">';
                $bloco .= '<b> ' . verificaTexto($nome) . ' </b>';
                $bloco .= '<span class="upper">'.verificaTexto($valor).'</span>';
                $bloco .= '</p>';

            // dado de tipo: LINK
            } elseif ($vetor["tipo"] == 'link') {

                // link
                $bloco .= '<p class="title-string">';

                // alteração do ambiente do digidoc
                $valor  = str_replace('GEDServidor', $_SESSION['GEDServidor'], $valor);
                $valor  = str_replace('gedervidor', $_SESSION['GEDServidor'], $valor);
                $valor  = str_replace('0303hmlged01', $_SESSION['GEDServidor'], $valor);
                $bloco .= '<b> <a href="'. verificaTexto($valor) .'" target="_blank"> ' . verificaTexto($nome) . '</a> <i class="fas fa-external-link-alt" alt="abre em outra janela" title="abre em outra janela"></i></b>';
                $bloco .= '</p>';

            // dado de tipo: TABELA
            } elseif ($vetor["tipo"] == 'table'){

                // tabela
                $bloco .= '<p class="title-table"><span class="text-gray"> <br>';

                // quando não tem titulo na tabela
                if ($nome != "indefinido: ") {
                    $bloco .= '<p><b><i>' . verificaTexto($nome) . '</i></b></p>';
                }

                $bloco .= '<div style="overflow-x:auto;">';
                $bloco .= generateTabela($valor, $modo);
                $bloco .= '</div>';
                $bloco .= '</span></p>';

            // dado de tipo: INFORMAÇÃO
            } elseif ($vetor["tipo"] == 'info'){

                // caixa azul para informações
                $bloco .= '<p class="title-string">';
                $bloco .= ' <div class="tag-personalizada tag-informacao">';
                $bloco .= '     <p><i class="fas fa-info-circle"></i> &nbsp;' . verificaTexto($nome)  . ' <span class="upper">' . verificaTexto($valor) . '</span> </p>';
                $bloco .= ' </div>';
                $bloco .= '</p>';

            // dado de tipo: AVISO
            } elseif ($vetor["tipo"] == 'warning'){

                // caixa amarela para avisos
                $bloco .= '<p class="title-string">';
                $bloco .= ' <div class="tag-personalizada tag-atencao">';
                $bloco .= '     <p><i class="fas fa-exclamation-circle"></i> &nbsp;' . verificaTexto($nome)  . ' <span class="upper">' . verificaTexto($valor) . '</span> </p>';
                $bloco .= ' </div>';
                $bloco .= '</p>';

            // dado de tipo: TÍTULO GRANDE
            } elseif ($vetor["tipo"] == 'h1'){

                // título de texto
                if ($modo == "pdf") {
                    $bloco .= '<br><span class="tag-h1">';
                    $bloco .= verificaTexto($valor);
                    $bloco .= '</span>';
                } else {
                    $bloco .= '<h1 class="tag-h1">';
                    $bloco .= verificaTexto($valor);
                    $bloco .= '</h1>';
                }

            // dado de tipo: TÍTULO MEDIO
            } elseif ($vetor["tipo"] == 'h2'){

                // título de texto
                if ($modo == "pdf") {
                    $bloco .= '<br><br><span class="tag-h2">';
                    $bloco .= verificaTexto($valor);
                    $bloco .= '</span>';
                } else {
                    $bloco .= '<h2 class="tag-h2">';
                    $bloco .= verificaTexto($valor);
                    $bloco .= '</h2>';
                }

            // dado de tipo: TÍTULO PEQUENO
            } elseif ($vetor["tipo"] == 'h3'){

                // título de texto
                if ($modo == "pdf") {
                    $bloco .= '<br><br><span class="tag-h3">';
                    $bloco .= verificaTexto($valor);
                    $bloco .= '</span><br>';
                } else {
                    $bloco .= '<h3 class="tag-h3">';
                    $bloco .= verificaTexto($valor);
                    $bloco .= '</h3>';
                }

            // dado de tipo: TEXTO PEQUENO
            } elseif ($vetor["tipo"] == 'small'){

                // título de texto
                $bloco .= '<p><small><i>';
                $bloco .= verificaTexto($valor);
                $bloco .= '</i></small><br><br></p>';

            // dado de tipo: LINHA HORIZONTAL
            } elseif ($vetor["tipo"] == 'hr'){

                // linha horizontal

                if ($modo == "pdf") {
                    $bloco .= '<br><hr class="tag-hr"><br><br>';
                } else {
                    $bloco .= '<hr class="tag-hr">';
                }


            // dado de tipo: QUEBRA DE LINHA
            } elseif ($vetor["tipo"] == 'br'){

                // quebra de linha
                $bloco .= '<p><br></p>';
             

            // dado de tipo: INDEFINIDO
            } else {

                // quando o tipo de dado não esta tratado
                $bloco .= '<p class="title-string">';
                $bloco .= ' <div class="tag-personalizada tag-desconhecida">';
                $bloco .= '     <p><i class="fas fa-times-circle"></i> &nbsp; formato de dado desconhecido<br><br></p>';
                $bloco .= '     <b>Nome do campo</b>:    ' . verificaTexto($nome)  . ' <br>';
                $bloco .= '     <b>Tipo de campo</b>:    ' . verificaTexto($tipo)  . ' <br>';
                $bloco .= ' </div>';
                $bloco .= '</p>';
             
            }
    
        } else {

            $bloco .= 'DEV> isset not array '. verificaTexto($vetor[0]) .' <br>';

        }

    } else {

        $bloco .= 'DEV> not isset ' . verificaTexto($vetor[0]) . '<br>';
    }

    return $bloco;
}

/*
* pra gerar uma tabela
*/

function generateTabela($vetor = array(), $modo = 'screen') {

    $table = '';

        if (isset($vetor['linhas'])) {

            if (is_array($vetor['linhas'])) {
        
                // quando gera HTML para PDF
                if ($modo == 'pdf') {

                    $table .= '<table class="tabela-pdf display" cellspacing="0" cellpadding="3">';
                    
                // quando gera HTML para tela
                } else {

                    $table .= '<table class="table table-striped table-dark table-sm table-bordered table-hover table-responsive-sm example">';

                }
                

                foreach ($vetor['linhas'] as $linhas) {
                        
                    // cores alternadas da tabela
                    $cont = 1;
                    $zebra = 1;
                    $ativaTfoot = 0;
                    $ativaThead = 0;

                        // percorre vetor
                        foreach ($linhas as $linha) {

                            // quando gera HTML para PDF
                            if ($modo == "pdf") {

                                // linha com cores alternadas
                                if ($zebra == 1) {

                                    // cor 1
                                    $table .= '<tr class="'. ($cont == 1 ? "primeira-linha" : "outras-linhas"). ' zebra1">';
                                    $zebra++;

                                } else {

                                    // cor 2
                                    $table .= '<tr class="'. ($cont == 1 ? "primeira-linha" : "outras-linhas"). ' zebra2">';
                                    $zebra = 1;
                                }

                            }

                            // percorre vetor de dados e escreve na tela

                            // if verifica array linha
                            if (is_array($linha)) {

                                foreach ($linha as $colunas) {

                                    // if verifica array colunas
                                    if (is_array($colunas)) {

                                        foreach ($colunas as $coluna) {

                                            // abre coluna
                                            if ($modo != 'pdf') {

                                                if ($cont === 1) {
                                                    $table .= '<thead>';
                                                    $table .= '<tr '. ($cont == 1 ? "class=\"primeira-linha\"" : "class=\"outras-linhas\""). '>';
                                                    $ativaThead = 1;
                                                } else {

                                                    if ($coluna[0] === '<b>TOTAL</b>') {
                                                        $table .= '<tfoot>';
                                                        $ativaTfoot = 1;
                                                    } else {
                                                        $ativaTfoot = 0;
                                                    }

                                                    $table .= '<tr '. ($cont == 1 ? "class=\"primeira-linha\"" : "class=\"outras-linhas\""). '>';
                                                    $ativaThead = 0;
                                                }
                                            }

                                        // if verifica array coluna
                                        if (is_array($coluna)) {



                                            // percorre celulas (td)
                                                foreach ($coluna as $conteudo) {

                                                if (($ativaTfoot === 1) || ($ativaThead === 1)) {
                                                    $table .= '<th>' . verificaTexto($conteudo) . '</th>';
                                                } else {
                                                    $table .= '<td>' . verificaTexto($conteudo) . '</td>';
                                                }

                                                    // conferir se existe dado
                                                // $table .= '<td>' . verificaTexto($conteudo) . '</td>';

                                            }

                                        // else verifica array coluna
                                        } else {

                                            // se chegou aqui, não é vetor (veio uma coluna só)
                                            if ($ativaThead == 0) {
                                                $table .= '<td>' . verificaTexto($coluna) . '</td>';
                                            } else {
                                                $table .= '<th>' . verificaTexto($coluna) . '</th>';
                                            }
                                            $ativaThead++;

                                        // fim verifica array coluna
                                        }
                                    }

                                            // fecha coluna
                                            if ($cont === 1) {
                                                $table .= '</tr>';
                                                $table .= '</thead>';
                                            } else {
                                                $table .= '</tr>';
                                                if ($coluna[0] === '<b>TOTAL</b>') {
                                                    $table .= '</tfoot>';
                                                }
                                            }

                                    // else verifica array colunas
                                    } else {

                                    // se chegou aqui, é por que só veio uma coluna na tabela. Não é pra acontecer isso.

                                    // fim verifica array colunas
                                    }
                                }

                            // else verifica array linha
                            } else {

                            // se chegou aqui, é por que a tabela não esta correta

                            }// fim verifica array linha

                            

                            $cont++;
                        }
                }

                $table .= '</table>';
            }

        } else {
            
            $table = warning("Uma tabela sem dados foi encontrada no XML");
        }

    return $table;
}

/*
* pra conferir se é um vetor ou não. Se não for, retorna um
*/

function makeArray($arr){
    
    // verifica se a primeira posição do vetor é um vetor
    if(isset($arr[0]))
        return $arr;
    $retorno = array();

    return $retorno[] = Array($arr);
}

/*
* gera chave aleatoria
*/

function generatePassword($length = 32) {

    // quais caracteres devem estar na chave gerada
    $possibleChars  = "abcdefghijklmnopqrstuvxywz0123456789ABCDEFGHIJKLMNOPQRSTUVXYWZ";
    $password       = '';

    for($i = 0; $i < $length; $i++) {
        $rand       = rand(0, strlen($possibleChars) - 1);
        $password  .= substr($possibleChars, $rand, 1);
    }

    return $password;
}

/*
* gera bloco de warning (amarelo)
*/

function warning($string = "Dados inválidos") {

    $html = '<div class="tag-inexistente"><i class="fas fa-info-circle"></i> &nbsp; ' . trim($string) . '</div>';

    return $html;

}

/*
* gera Título da tela
*/

function tituloTela($string) {

    if (empty($string)) {

        $html = 'Não definido';
    
    } else {

        $html = trim($string);

    }

    return trim($html);

}

/*
* função para verificar se existe conteúdo para exibir
*/

function verificaTexto($string = '-'){

    if(is_array($string)) {

        // verifica se é um campo que veio do fn_tag
        if ((isset($string['campo']['nome'])) && (isset($string['campo']['tipo']))  && (isset($string['campo']['valor']))) {
            return '<b>' . trim($string['campo']['nome']) . ':</b> <span class="upper">' . verificaBr($string['campo']['valor']) . '</span>';
        } else {
            return '-';
        }

    } else {

        if ($string != 0) {

            // verifica se a string esta vazia
            if (!empty($string)) {

                // verifica se existe
                if(isset($string)) {

                    return verificaBr(trim($string));
                    //return trim(strtoupper($string));

                } else {

                    // inexistente
                    return '-';

                }

            } else {
               
               // vazio
               return '-';

            }

        } else {

            // zero
            return verificaBr($string);
//            return trim(strtoupper($string));
        }
    }

}

/*
* verifica se existe quebra de linha
*/

function verificaBr($string) {

    if (strpos($string, '##br##') !== false) {

        $string = str_ireplace('##br##', '<br>', $string);

        $string = '<p class="upper" style="padding-left:15px;">'.$string.'</p>';

        return $string;

    } else {

        return $string;

    }

    // return trim(strtoupper($string));
}


/*
* gera Título da filtro
*/

function tituloFiltro($string) {

    if (empty($string)) {

        $html = 'undefined';
        die("filtroTela");
    
    } else {

        $html = strtolower(trim($string));

    }

    return trim($html);

}

?>