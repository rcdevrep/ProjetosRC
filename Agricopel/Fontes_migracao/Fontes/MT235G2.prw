/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  MT235G2   � Autor � Leandro             � Data �  26/09/2011 ���
�������������������������������������������������������������������������͹��
���Descricao � Adi��o do filtro por armaz�m do produto                    ���
���          � Chamado em MATA235                                         ���
�������������������������������������������������������������������������͹��
���Uso       � Agricopel - SIGACOM                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function MT235G2()

	Local _lRet  := .T.
	Local cAlias := ParamIXB[1]
	Local nRecno := 0

	If SM0->M0_CODIGO == "01" .And. (SM0->M0_CODFIL == "06" .Or. SM0->M0_CODFIL == "02")

		If MV_PAR08 == 1 .And. AllTrim(MV_PAR18) <> ""
			_lRet := AllTrim(SC7->C7_LOCAL) = AllTrim(MV_PAR18)
		Else
			If MV_PAR08 == 5 

				dbSelectArea(cAlias)
				nRecno := SC1RECNO

				dbSelectArea("SC1")
				dbGoTo(nRecno)

				dbSelectArea("SB1")
				dbSetOrder(1)
				If dbSeek(xFilial("SB1")+SC1->C1_PRODUTO)

					If _lRet .And. AllTrim(MV_PAR18) <> ""
						_lRet := AllTrim(MV_PAR18) == AllTrim(SB1->B1_LOCPAD)
					EndIf

					If AllTrim(MV_PAR09) <> ""
						_lRet := AllTrim(MV_PAR09) == AllTrim(SB1->B1_PROC)
					EndIf

				EndIf

			EndIf
		EndIf

	EndIf

Return _lRet