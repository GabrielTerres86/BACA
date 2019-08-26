create or replace and compile java source named listaarquivosarray as
import java.io.*;
import java.sql.*;
import oracle.sql.*;
import oracle.jdbc.driver.*;
import java.util.ArrayList;

/**
 * Classe que vai receber a pasta e realizar pesquisa para listar todos os
 * arquivos contidos.
 * Retorna um ArrayList com os nomes de todos os arquivos encontrados.
 * @author Petter Rafael - Supero Tecnologia
 * @since Março/2015
 */
public class ListaArquivosArray {
    /**
     * Método privado para listar todos os arquivos de uma pasta informada.
     * É possível pesquisar por fragmentos do nome do arquivo, inclusive utilizando o caracter coringa %
     * @param path Path da pasta - inclusive - que será pesquisada
     * @param pesquisa String de pesquisa para fragmentos de nome
     * @return Retorna ArrayList contendo os nomes dos arquivos
     */
    private static String[] listar(String path, String pesquisa){
        File pasta = new File(path);
        String[] pesquisar = null;
        boolean semBusca = false;
        ArrayList arquivos = new ArrayList ();
        int tamPesq;

        try{
            if(pesquisa != null){
                tamPesq = pesquisa.length();
                pesquisar = pesquisa.split("%");
            }else{
                tamPesq = 0;
            }

            for(File arq : pasta.listFiles()){
                semBusca = false;

                if(tamPesq > 0){
                    if(arq.isFile()){
                        for(String dado : pesquisar){
                            if(dado.length() > 0){
                                if(arq.getName().indexOf(dado) == -1){
                                    semBusca = true;
                                }else if(!pesquisa.substring(0, 1).equals("%") && !pesquisa.substring(0, 1).equals(arq.getName().substring(0, 1))){
                                    semBusca = true;
                                }else if(!pesquisa.substring(pesquisa.length() - 1, pesquisa.length()).equals("%")
                                        && !pesquisa.substring(pesquisa.length() - 1, pesquisa.length()).equals(arq.getName().substring(arq.getName().length() - 1, arq.getName().length()))){
                                    semBusca = true;
                                }
                            }
                        }

                        if(!semBusca){
                            arquivos.add(arq.getName());
                        }
                    }
                }else{
                    if(arq.isFile()){
                        arquivos.add(arq.getName());
                    }
                }
            }
        }catch(Exception ex){
            arquivos.clear();
            arquivos.add("2-Erro: " + ex.toString());
        }

        String[] listaArquivos = (String[]) arquivos.toArray(new String[arquivos.size()]); 

        return listaArquivos;
    }
    
    /**
     * Método público para devolver ArrayList com todos os nomes de arquivos listados.
     * @param path Path da pasta - inclusive - que será pesquisada
     * @param pesquisa String de pesquisa para fragmentos de nome
     * @param vArrayRetorno Retorno implícito do ArrayList com os nomes dos arquivos
     */
    public static void getArquivos(oracle.sql.ARRAY[] vArrayRetorno, String path, String pesquisa)
           throws java.sql.SQLException{
        Connection conn = new OracleDriver().defaultConnection();
        ArrayDescriptor desc = ArrayDescriptor.createDescriptor("TYP_SIMPLESTRINGARRAY", conn);
        vArrayRetorno[0] = new ARRAY(desc, conn, listar(path, pesquisa));
    }
}
/
