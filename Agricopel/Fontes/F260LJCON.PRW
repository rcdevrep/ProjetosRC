#Include 'Protheus.ch'
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �F260LJCON   �Autor  �Osmar Schimitberger �Data �211/02/2020 ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada para n�o concilar no DDA o Fornecedor     ���
���          � Fornecedor 000493 - Raizen empresa 01 - chamado 313560     ���
�������������������������������������������������������������������������͹��
���Uso       � Agricopel                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function F260LJCON()

Local cLojaFIG := PARAMIXB[2]

FIG->(DbGoto(PARAMIXB[1]))

If Alltrim(FIG->FIG_FORNEC) == "000493" .and. SM0->M0_CODIGO == "01" //Loja alterada
   cLojaFIG := "XX" //Alterado a loja para XX para N�o conciliar no DDA o fornecedor Raizen
Endif

RecLock("FIG")
FIG->FIG_LOJA := cLojaFIG
FIG->(MsUnlock())

Return cLojaFIG