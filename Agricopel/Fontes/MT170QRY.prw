#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  MT170QRY  � Autor � Leandro             � Data �  26/09/2011 ���
�������������������������������������������������������������������������͹��
���Descricao � Adi��o do filtro por fornecedor padr�o do produto          ���
���          � Adi��o do filtro de status do produto para tirar inativos  ���
���          � Chamado em MATR440                                         ���
���          � Chamado em MATA170                                         ���
�������������������������������������������������������������������������͹��
���Uso       � Agricopel - SIGACOM                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function MT170QRY()

	Private cReturn := ""

	If SM0->M0_CODIGO == "01" .And. (Alltrim(SM0->M0_CODFIL) == "06" .Or. Alltrim(SM0->M0_CODFIL) == "02")

		cReturn += PARAMIXB[1]
		cReturn += " AND B1_SITUACA <> '2' "

		if FunName() == "MATA170" .And. AllTrim(MV_PAR22) <> ""
			cReturn += " AND B1_PROC = '" + MV_PAR22 + "'"
		ElseIf FunName() == "MATR440" .And. AllTrim(MV_PAR21) <> ""
			cReturn += " AND B1_PROC = '" + MV_PAR21 + "'"
		EndIf

	EndIf

Return cReturn