#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"


User Function XAG0081()

	local cFil := space(2)
	local cBan := space(3)
	local cAge := space(5)
	local cCon := space(10)
	local cArq := space(40)
	local dtArq := date()
	//local dDat := today()
	local lOk := .f.


	
	DEFINE MSDIALOG oDlgMain FROM 0,0 TO 210, 800 TITLE 'Ajuste Arq. Proc.' OF COLOR "W+/W" STYLE DS_MODALFRAME PIXEL

	oPnPri := tPanel():New(0,0,,oDlgMain,,,,,,400,85,.T.,.F.)
	//oPnPri :Align := CONTROL_ALIGN_ALLCLIENT

	oPnBtn := tPanel():New(86,0,,oDlgMain,,,,,CLR_HGRAY,400,20,.T.,.F.)
	//oPnBtn :Align := CONTROL_ALIGN_ALLCLIENT


	@ 003,005 Say OemToAnsi('Filial: ') Of oPnPri Pixel
	@ 001,030 MsGet cFil Picture('@!') Size 10,09 When .t. Of oPnPri Pixel
	@ 016,005 Say OemToAnsi('Banco: ') Of oPnPri Pixel
	@ 014,030 MsGet cBan Picture('@!') Size 15,09 When .t. Of oPnPri Pixel
	@ 029,005 Say OemToAnsi('Agencia: ') Of oPnPri Pixel
	@ 027,030 MsGet cAge Picture('@!') Size 20,09 When .t. Of oPnPri Pixel
	@ 042,005 Say OemToAnsi('Conta: ') Of oPnPri Pixel
	@ 040,030 MsGet cCon Picture('@!') Size 40,09 When .t. Of oPnPri Pixel
	@ 055,005 Say OemToAnsi('Arquivo: ') Of oPnPri Pixel
	@ 053,030 MsGet cArq Picture('@!') Size 90,09 When .t. Of oPnPri Pixel
	@ 068,005 Say OemToAnsi('Data: ') Of oPnPri Pixel
	@ 066,030 MsGet dtArq Picture('@E') Size 90,09 When .t. Of oPnPri Pixel



	oQuit := THButton():New(0, 0, "Cancelar", oPnBtn, {|| oDlgMain:End()},50,10 )
	oQuit:Align   := CONTROL_ALIGN_RIGHT
	oQuit:SetColor(RGB(002, 070, 112), )
	
	oSel := THButton():New(0, 0, "Excluir", oPnBtn, {|| lOk := .t., iif(valida(cFil,cBan,cAge,cCon,cArq),oDlgMain:End(),)}, 50,10  )
	oSel:Align := CONTROL_ALIGN_RIGHT
	oSel:SetColor(RGB(002, 070, 112), )
	
	ACTIVATE MSDIALOG oDlgMain centered


	if lOk

		dbSelectArea("FI0")

		FI0->(dbSetOrder(2)) //FI0_FILIAL+FI0_BCO+FI0_AGE+FI0_CTA+FI0_ARQ
		if FI0->(dbSeek(cFil + cBan + cAge + cCon + cArq))

			while FI0->(!eof()) .and. FI0->FI0_FILIAL + FI0->FI0_BCO + FI0->FI0_AGE + FI0->FI0_CTA + FI0->FI0_ARQ == cFil + cBan + cAge + cCon + cArq

				if FI0->FI0_DTPRC == dtArq

					FI0->(RecLock("FI0", .F.))
					FI0->(dbDelete())
					FI0->(MsUnLock())

					MsgInfo('Registro excluído com sucesso.','Ajuste Arq. Proc.')

				endif

				FI0->(dbSkip())

			enddo

			

		endif

	endif

	MsgInfo('Processo finalizado.','Ajuste Arq. Proc.')

Return


static function valida(cFil,cBan,cAge,cCon,cArq)

	local lVal := .f.


	FI0->(dbSetOrder(2)) //FI0_FILIAL+FI0_BCO+FI0_AGE+FI0_CTA+FI0_ARQ
	if FI0->(dbSeek(cFil + cBan + cAge + cCon + cArq))

		lVal := .t.

	else		
		msgAlert('Registro não encontrado.','Ajuste Arq. Proc.')
	endif

return lVal
