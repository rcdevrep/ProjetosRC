
#INCLUDE "TOTVS.CH"
/*/{Protheus.doc} FA040DEL
Como finalidade permitir executar rotinas personalizadas após o termino do processamento de exclusão do título .   
@type     function
@author      Jader Berto
@since       2024.08.06
/*/

User Function FA040DEL()
Local cArquivo := ""
Local cPathXML:= "\cci_xml"


    cArquivo := Alltrim(SE1->E1_FILIAL) + Alltrim(SE1->E1_PREFIXO) + Alltrim(SE1->E1_NUM) + Alltrim(SE1->E1_PARCELA) + '.xml'

    cPathXML += '\'+ Alltrim(Replace(Replace(Replace(SA1->A1_CGC,'.',''),'-',''),'/',''))

    cPathXML += '\'+ Alltrim(SE1->E1_CLIENTE)+ Alltrim(SE1->E1_LOJA)

    cPathXML += '\'+ Year2Str(SE1->E1_EMISSAO)

    cPathXML += '\'+ Month2Str(SE1->E1_EMISSAO)


    If File(cPathXML+'\'+cArquivo)
        FErase(cPathXML+'\'+cArquivo)
    EndIf

Return( Nil )
