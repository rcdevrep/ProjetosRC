/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SX5NOTA   �Autor  �Max Ivan (Max Ivan) � Data �  27/09/2019 ���
�������������������������������������������������������������������������͹��
���Desc.     �PE executado na prepara�ao de documento, filtrando a tela de���
���          �sele�ao das series.                                         ���
�������������������������������������������������������������������������͹��
���Uso       �Agricopel                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function SX5NOTA()

    Local _lRet     := .F.

    Local _cFilial  := Paramixb[1]  //Filial
    // Local _cTabela  := Paramixb[2]  //Tabela da SX5
    Local _cChave   := Paramixb[3]  //Chave da Tabela na SX5
    // Local _cDescri  := Paramixb[4]  //Conte�do da Chave indicada

    If _cFilial <> "03" .Or. AllTrim(_cChave) <> "7"
        _lRet := .T.
    EndIf

Return(_lRet)