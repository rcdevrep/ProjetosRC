/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MSD2520  º Autor ³ Jean Sérgio Vieira º Data ³  15/08/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Ponto de entrada com a função de gerar as movimentações de º±±
±±º          ³ produtos resultantes.                                      º±±
±±º          ³ ROTINA JA VERIFICADA VIA XAGLOGRT                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function MSD2520

	Local Seq		:= {Alias(), IndexOrd(), Recno()}
	Local aCusto	:= {}

	dbSelectArea('SF2')
	dbSelectArea('SD2')

	dbSelectArea('SG1')
	dbSetOrder(1)
	If !dbSeek(xFilial('SG1')+SD2->D2_COD)
		Return
	EndIf

	dbSelectArea('SD3')
	dbSetOrder(2)
	dbSeek(xFilial('SD3')+SD2->D2_DOC, .T.)

	While !Eof() .AND. xFilial('SD3') == SD3->D3_FILIAL .AND. SD3->D3_DOC == SD2->D2_DOC
		reclock('SD3',.f.)
		SD3->D3_ESTORNO 	:= 'S'
		SD3->D3_CF			:= Iif(Left(SD3->D3_CF,1) == 'D','R','D')+Subs(SD3->D3_CF,2,2)
		SD3->D3_TM			:= Iif(Left(SD3->D3_CF,1) == 'D','499','999')
		SD3->D3_CHAVE		:= 'E'+Iif(Left(SD3->D3_CF,1) == 'D','9','0')
		SD3->D3_USUARIO	    := SubStr(cUsuario,7,15)
		msunlock('SD3')
		aCusto := PegaCusD3()
		B2AtuComD3(aCusto)

		reclock('SD3',.f.)
		dbdelete()
		msunlock('SD3')
		dbSelectArea('SD3')
		dbSkip()	
	EndDo

	dbSelectArea(Seq[1])
	dbSetOrder(Seq[2])
	dbGoto(Seq[3])
Return
