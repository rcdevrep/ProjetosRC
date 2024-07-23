#include "topconn.ch"
#include "TOTVS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �M460MKB   �Autor  �Jaime Wikanski      � Data �  29/11/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de entrada para avaliar se deve ou nao permitir a     ���
���          �selecao para geracao da NFS                                 ���
�������������������������������������������������������������������������͹��
���Uso       � Fusus                                                      ���
�������������������������������������������������������������������������͹��
���Altera��es�10/05/2015 - Max Ivan (Nexus) - Ajustado para permitir que  ���
���          �seja mostrado em tela apenas os pedidos liberados. LUBTROL  ���
���          �19/10/2015 - Max Ivan (Nexus) - Ajustado para permitir fil- ���
���          �trar os registros a serem mostrados, pelo almoxarifado e    ���
���          �campo customizado C5_XIMPRE. AGRICOPEL                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

//User Function M460MKB()
//����������������������������������������������������������������������������������������������������������������������������������������������������������Ŀ
//�04/12/2017 - MAX IVAN (Nexus) - Mudado o nome da Fun��o (PE) de M460MKB p/ NX460MKB, e criado esta chamada dentro do fonte original da Shell.             �
//������������������������������������������������������������������������������������������������������������������������������������������������������������
User Function NX460MKB()

	Local cCondicao			:= ""
	Local _oPedImp          := Nil
	Local _aPedImp          := {"TODOS","SIM","N�O"}
	Local _oPedAlvor        := Nil
	Local _aPedAlvor        := {"TODOS","SIM","N�O"}
	Local oDlg2             := Nil

	Public _cAlmox          := Space(TamSX3("C9_LOCAL")[1])
	Public _cPedImp         := "T"
	Public _cPedAlvor       := "T"
	Public _cPedProg        := ""

	If !(Upper(Alltrim(FunName())) == "MATA460B")

		If SC5->(FieldPos("C5_XIMPRE"))> 0
			DEFINE MSDIALOG oDlg2 TITLE "Filtrar" FROM 0,0 TO 200,400 OF oDlg2 PIXEL
			@ 005,006 Say "Almoxarifado: " SIZE 65, 8 PIXEL OF oDlg2
			@ 015,006 MSGET _cAlmox Size 10,10 PIXEL OF oDlg2
			@ 030,006 Say "Pedidos Impressos? " SIZE 65, 8 PIXEL OF oDlg2
			@ 040,006 COMBOBOX _oPedImp VAR _cPedImp ITEMS _aPedImp SIZE 45,10 PIXEL OF oDlg2

			If (cEmpAnt == "01" .AND. (cFilAnt == "06" .or. cFilAnt == "19"))
				@ 055,006 Say "Pedidos Alvorada? (Somente quando Almoxarifado = 20) " SIZE 150, 8 PIXEL OF oDlg2
				@ 065,006 COMBOBOX _oPedAlvor VAR _cPedAlvor ITEMS _aPedAlvor SIZE 45,10 PIXEL OF oDlg2
			EndIf

			@ 080,070 BUTTON "&OK" SIZE 26,12 PIXEL ACTION oDlg2:End()
			ACTIVATE MSDIALOG oDlg2 CENTER
		EndIf
	Endif

Return(cCondicao)
